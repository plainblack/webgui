use strict;
use warnings;
use Test::More tests => 4;

use Plack::Test;
use Plack::Util;
use HTTP::Request::Common;
use WebGUI::Paths;

my $app = Plack::Util::load_psgi( WebGUI::Paths->defaultPSGI );

test_psgi $app, sub {
    my $cb = shift;

    my $res = $cb->( GET "/" );
    is $res->code,      200;
    like $res->content, qr/My Company/;

    $res = $cb->( GET "/?op=editSettings" );
    is $res->code,      401;
    like $res->content, qr/Administrative Function/;

};
