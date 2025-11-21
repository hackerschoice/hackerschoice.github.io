#!/usr/bin/perl

# With timediff you can check whether web-servers have a correctly setup
# time. Might also be useful to check for virtual hosts, RTT and server-load,
# but it'd require more complex diff algo than just printing it :)
#
# stealth@lopht:~> ./timediff.pl google.com google.de google.in google.cn google.ru google.pl
# google.com      -> Date: Wed, 04 Nov 2009 19:09:41 GMT
# google.de       -> Date: Wed, 04 Nov 2009 19:09:41 GMT
# google.in       -> Date: Wed, 04 Nov 2009 19:09:42 GMT
# google.ru       -> Date: Wed, 04 Nov 2009 19:09:42 GMT
# google.pl       -> Date: Wed, 04 Nov 2009 19:09:42 GMT
# google.cn       -> Date: Wed, 04 Nov 2009 19:09:42 GMT
# stealth@lopht:~> ./timediff.pl microsoft.com oracle.com time.com spiegel.de thc.org
# microsoft.com   -> Date: Wed, 04 Nov 2009 19:14:06 GMT
# oracle.com      -> Date: Wed, 04 Nov 2009 19:14:07 GMT
# time.com        -> Date: Wed, 04 Nov 2009 19:14:06 GMT
# spiegel.de      -> Date: Wed, 04 Nov 2009 19:14:07 GMT
# thc.org -> Date: Wed, 04 Nov 2009 13:50:14 GMT
# stealth@lopht:~>
#
# (C) 2009 stealth under the GPL.

use IO::Socket;
use IO::Select;

my $peers = new IO::Select;
my %peer2name = ();

foreach $host (@ARGV) {
	my $peer = IO::Socket::INET->new(PeerAddr => $host,
	                                 PeerPort => 80,
	                                 Proto => 'tcp',
	                                 Type => SOCK_STREAM);
	if (defined $peer) {
		print $peer "HEAD / HTTP/1.0\r\n\r\n";
		$peers->add($peer);
		$peer2name{$peer} = $host;
	}
}


for (;;) {
	my $buf = "";
	my $peer = "";
	foreach $peer ($peers->can_read(1)) {
		$peer->recv($buf, 1024);
		$buf =~ /(Date:.+\r\n)/; $buf = $1;
		print $peer2name{$peer}."\t-> ".$buf;
		$buf = "";
		$peers->remove($peer);
		close($peer);
	}
	last if ($peers->count() == 0);
}



