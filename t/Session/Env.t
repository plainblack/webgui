#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use FindBin;
use strict;
use lib "$FindBin::Bin/../lib";

use WebGUI::Test;
use WebGUI::Session;

use Test::More tests => 3; # increment this value for each test you create
use Test::MockObject::Extends;

my $session = WebGUI::Test->session;


cmp_ok($session->env->get("PATH"), 'ne', "", "get() one valid entry");

#Replace the ENV hash so that we can test getIp.

my $env = $session->env;
$env    = Test::MockObject::Extends->new($env);

my %mockEnv = (
    REMOTE_ADDR          => '192.168.0.2',
);

$env->mock('get', sub { return $mockEnv{$_[1]}});

is ($env->getIp(), $mockEnv{'REMOTE_ADDR'}, 'getIp');

$mockEnv{HTTP_X_FORWARDED_FOR} = '10.0.2.5',
is ($env->getIp(), $mockEnv{'HTTP_X_FORWARDED_FOR'}, 'getIp with HTTP forwarding');
