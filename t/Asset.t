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
use warnings;
no warnings qw(uninitialized);
use lib "$FindBin::Bin/lib";

use WebGUI::Test;

use Test::More;
use Test::Deep;
use Test::Exception;

plan tests => 5;

my $session = WebGUI::Test->session;

my $asset;

$asset = WebGUI::Asset->new({session => $session, });

isa_ok $asset, 'WebGUI::Asset';
isa_ok $asset->session, 'WebGUI::Session';
is $asset->session->getId, $session->getId, 'asset was assigned the correct session';

can_ok $asset, 'title', 'menuTitle';
is $asset->title, 'Untitled', 'title: default is untitled';
is $asset->title, 'Untitled', 'menuTitle: default is untitled';
