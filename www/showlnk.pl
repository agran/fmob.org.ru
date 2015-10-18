#!/usr/bin/perl
use strict();
use IO::Socket;

my $squareid  = 24872;
my $orientation = 1; # 0 - horizontal 1 - vertical

my $EOL = "\015\012";
my $BLANK = $EOL x 2;

my $socket = IO::Socket::INET->new(
    PeerAddr => 'link233.link.ru',
    PeerPort => 80,
    Proto    => "tcp",
    Type     => SOCK_STREAM,
    Timeout  => 5
);

if($socket){
    $socket->autoflush(1);
    print $socket sprintf("GET /show?sqid=%d&ori=%d HTTP/1.0", $squareid, $orientation) . $BLANK;
    my $content;
    while ( <$socket> ) {
        $content .= $_;
    }
    close($socket);
    $content =~ s/.*\r\n\r\n(.*)/$1/igs;
    print $content;

}

exit();
