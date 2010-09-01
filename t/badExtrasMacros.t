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
my $lib = WebGUI::Test->lib;

##Find the name of the International macro in the user's config file.

#note "International macro name = $international";

##Regexp setup for parsing out the Macro calls.
my $macro     = qr{
                    \^
                    Extras
                    (?: \( \) )?
                    ;
                }xms;

# put your tests here

$numTests = $session->db->quickScalar('select count(distinct(assetId)) from template');

plan tests => $numTests;

my $getATemplate = WebGUI::Asset::Template->getIsa($session);

my @templateLabels;

while (my $templateAsset = $getATemplate->()) {
    my $template = $templateAsset->get('template');
    my $header   = $templateAsset->get('extraHeadTags');
    my $match =  ($template =~ $macro);
    if ($header) {
        $match ||= ($header =~ $macro);
    }
    ok(!$match, sprintf "%s: %s (%s) has no bad extras macros", $templateAsset->getTitle, $templateAsset->getId, $templateAsset->getUrl);
}


