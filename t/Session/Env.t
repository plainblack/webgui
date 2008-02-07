#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2008 Plain Black Corporation.
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

my $session = WebGUI::Test->session;

cmp_ok($session->env->get("PATH"), 'ne', "", "get() one entry");

#Replace the ENV hash so that we can test getIp.

my $origEnvHash = $session->env->{_env};

my %newEnv = ( REMOTE_ADDR => '192.168.0.2' );

$session->env->{_env} = \%newEnv;

is ($session->env->getIp(), $newEnv{'REMOTE_ADDR'}, 'getIp');

$newEnv{'HTTP_X_FORWARDED_FOR'} = '10.0.2.5';

is ($session->env->getIp(), $newEnv{'HTTP_X_FORWARDED_FOR'}, 'getIp with HTTP forwarding');
