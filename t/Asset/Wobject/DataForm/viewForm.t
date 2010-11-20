# vim:syntax=perl
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#------------------------------------------------------------------

# Test the viewList and related methods of the DataForm
#
#

use FindBin;
use strict;
use lib "$FindBin::Bin/../../../lib";
use Test::More;
use Test::Deep;
use WebGUI::Test;    # Must use this before any other WebGUI modules
use WebGUI::Session;

#----------------------------------------------------------------------------
# Init
my $session = WebGUI::Test->session;

my $df = WebGUI::Test->asset->addChild( { 
    className   => 'WebGUI::Asset::Wobject::DataForm', 
    defaultview => 0,
    templateId  => 'PBtmpl0000000000000141',
} );

# Add fields to the dataform
$df->createField( "bigName",      { type => "textarea", isHidden => 0, } );
$df->createField( "messageCount", { type => "integer",  isHidden => 0, } );

#----------------------------------------------------------------------------
# Tests

plan tests => 4;    # Increment this number for each test you create

#----------------------------------------------------------------------------
# Test getListTemplateVars

$df->prepareView();
my $output = $df->view();

ok $output, 'got some output';
ok $output !~ m/<link   [^>+] href/msx, 'no CSS link tags in the output';
ok $output !~ m/<script [^>+] src /msx, 'no JavaScript script tags with src in the output';
ok $output !~ m/    <style>       /msx, 'no JavaScript script tags with src in the output';

#vim:ft=perl
