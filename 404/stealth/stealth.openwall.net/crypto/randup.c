/* Problem:
 * _rs_forkdetect() of libressl RAND does not detect clone() and
 * creating of childs in a new PID namespace leaves 'pid' and '_rs_pid' of 1 so
 * that 'rs' is not zeroed out and _rs_stir() is not called when it should.
 * At the same time RAND_add() and RAND_load_file() are NOPs but are
 * commonly used in server/fork/clone environments to add entropy
 * to the pool to avoid cloning of PRNG state.
 * Solution:
 * _rs_forked = 1 in RAND_add() and RAND_load_file() to emulate that
 * behavior.
 *
 * cc -std=c99 -Wall rand.c -lcrypto -I/usr/local/libressl/include -L/usr/local/libressl/lib64 -Wl,--rpath=/usr/local/libressl/lib64
 *
 * credits: opmsg team https://github.com/stealth/opmsg
 *
 */

#define _GNU_SOURCE
#include <stdio.h>
#include <stdint.h>
#include <sched.h>
#include <openssl/rand.h>
#include <unistd.h>
#include <sys/syscall.h>
#include <sys/types.h>
#include <sys/wait.h>

unsigned char cstack1[1024*1024];
unsigned char cstack2[1024*1024];
unsigned char cstack3[1024*1024];


int child3(void *vp)
{
	uint32_t r = 0;

	RAND_load_file("/dev/urandom", 8);
	RAND_bytes((unsigned char *)&r, sizeof(r));
	printf("Child3 random (%d):  %x\n", getpid(), r);

	return 0;
}


int child2(void *vp)
{
	uint32_t r = 0;

	clone(child3, cstack3 + sizeof(cstack3), CLONE_NEWPID, NULL);

	RAND_load_file("/dev/urandom", 8);
	RAND_bytes((unsigned char *)&r, sizeof(r));
	printf("Child2 random (%d):  %x\n", getpid(), r);

	sleep(1);
	return 0;
}


int child1(void *vp)
{
	uint32_t r = 0;

	RAND_load_file("/dev/urandom", 8);
	RAND_bytes((unsigned char *)&r, sizeof(r));
	printf("Child1 random (%d):  %x\n", getpid(), r);

	clone(child2, cstack2 + sizeof(cstack2), CLONE_NEWPID, NULL);

	sleep(2);
	return 0;
}


int main()
{
	uint32_t r = 0;

	if (geteuid()) {
		printf("CLONE_PID needs CAP_SYS_ADMIN\n");
		exit(1);
	}

	// void call on LibreSSL anyway (note manpage semantics differencies)
	printf("RAND_load_file=%d\n", RAND_load_file("/dev/urandom", 128));

	RAND_bytes((unsigned char *)&r, sizeof(r));
	printf("Parent random (%d): %x\n", getpid(), r);

	clone(child1, cstack1 + sizeof(cstack1), CLONE_NEWPID, NULL);

	// waitpid() would be the right thing, but in PID namespaces the PIDs are
	// wrong
	sleep(3);

	return 0;
}


