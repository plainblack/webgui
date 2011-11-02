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
use lib "$FindBin::Bin/lib"; ##t/lib

use WebGUI::Test;
use WebGUI::Session;
use Data::Dumper;
use WebGUI::Asset;
use WebGUI::Asset::Template;
use WebGUI::Macro;

#The goal of this test is to find template attachments that do not resolve.

use Test::More; # increment this value for each test you create
my $numTests = 0;

my $session = WebGUI::Test->session;

# put your tests here

$numTests = $session->db->quickScalar('select count(distinct(assetId)) from template');

my $getATemplate = WebGUI::Asset::Template->getIsa($session);

WebGUI::Test->originalConfig('extrasURL');
$session->config->set('extrasURL', '');

TEMPLATE: while (my $templateAsset = $getATemplate->()) {
    my $bad_attachments = 0;
    foreach my $attachment (@{ $templateAsset->getAttachments }) {
        my $url = $attachment->{url};
        WebGUI::Macro::process($session, \$url);
        my $url_exists = 0;
        if ($attachment->{url} =~ /\^Extras/) {
            ##File system path for /extras, adjust the URL for that.
            $url = $session->config->get('extrasPath') . $url;
            $url_exists = -e $url;
        }
        else {
            my $asset = eval { WebGUI::Asset->newByUrl($session, $url) };
            $url_exists = defined $asset;
        }
        ok $url_exists, sprintf "%s: %s (%s) has a bad attachment url: %s", $templateAsset->getTitle, $templateAsset->getId, $templateAsset->getUrl, $attachment->{url};
    }
}

done_testing;
