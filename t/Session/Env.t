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

use Test::More tests => 2; # increment this value for each test you create

my $session = WebGUI::Test->session;


cmp_ok($session->env->get("REMOTE_ADDR"), 'ne', "", "get() one valid entry");

my $env = $session->env;
$session->request->env->{REMOTE_ADDR} = '192.168.0.2';
is ($env->getIp, '192.168.0.2', 'getIp');

