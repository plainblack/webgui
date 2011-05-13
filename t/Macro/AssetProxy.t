#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;

use WebGUI::Test;
use WebGUI::Session;
use WebGUI::Asset;

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

plan tests => 2;

use WebGUI::Macro::AssetProxy;

$session->asset(WebGUI::Asset->getDefault($session));

my $output;
$output = WebGUI::Macro::AssetProxy::process($session);
is $output,  undef, 'calling AssetProxy with no identifier returns no error message in normal mode';

$session->user({userId => 3});
$output = WebGUI::Macro::AssetProxy::process($session);
like $output, qr/Invalid Asset URL/, '..., adminOn, return error message';
