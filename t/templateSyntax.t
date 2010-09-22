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
use warnings;

use WebGUI::Test;
use WebGUI::Session;
use Data::Dumper;
use WebGUI::Asset::Template;

#The goal of this test is to locate poorly used macros in the default
#templates;

use Test::More; # increment this value for each test you create
my $numTests = 0;

my $session = WebGUI::Test->session;

# put your tests here

$numTests = $session->db->quickScalar('select count(distinct(assetId)) from template');

plan tests => $numTests;

my $getATemplate = WebGUI::Asset::Template->getIsa($session);

while (my $templateAsset = $getATemplate->()) {
    my $output = $templateAsset->process({});
    unlike(
        $output,
        qr/\AError processing template:/,
        sprintf "%s: %s (%s) has no syntax errors",
            $templateAsset->getTitle, $templateAsset->getId, $templateAsset->getUrl
    );
}


