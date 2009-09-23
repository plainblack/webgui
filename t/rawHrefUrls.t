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
use WebGUI::Asset::Template;
use HTML::Parser;

#The goal of this test is to find CSS and JavaScript links that do not
#use either the Extras macro, or the Gateway macro.

use Test::More; # increment this value for each test you create
my $numTests = 0;

my $session = WebGUI::Test->session;
my $lib = WebGUI::Test->lib;

##Find the name of the International macro in the user's config file.

#note "International macro name = $international";

##Regexp setup for parsing out the Macro calls.
my $macro     = qr{
                    \^
                    /
                    ;
                }xms;

# put your tests here

$numTests = $session->db->quickScalar('select count(distinct(assetId)) from template');

plan tests => $numTests;

my $validLinks = 0;

sub checkLinks {
    my ($tag, $attrs) = @_;
    if ($tag eq 'link' && $attrs->{href}) {
        if ($attrs->{href} !~ /\s*\^(?:\/|Extras)/) {
            $validLinks = 0;
        }
    }
    elsif ($tag eq 'script' && $attrs->{src}) {
        if ($attrs->{src} !~ /\s*\^(?:\/|Extras)/) {
            $validLinks = 0;
        }
    }
}

my $parser = HTML::Parser->new(
    api_version => 3,
    report_tags => [ qw/link script/ ],
    start_h     => [ \&checkLinks, 'tag, attr'],
);

my $getATemplate = WebGUI::Asset::Template->getIsa($session);

TEMPLATE: while (my $templateAsset = $getATemplate->()) {
    my $template = $templateAsset->get('template');
    my $header   = $templateAsset->get('extraHeadTags');
    if(! $header) {
        ok(1, sprintf "%s: %s (%s) has no rooted link urls", $templateAsset->getTitle, $templateAsset->getId, $templateAsset->getUrl);
        next TEMPLATE;
    }
    $validLinks = 1;
    $parser->parse($header);
    ok($validLinks, sprintf "%s: %s (%s) has no rooted link urls", $templateAsset->getTitle, $templateAsset->getId, $templateAsset->getUrl);
}


