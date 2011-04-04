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

##Regexp setup for parsing out the Macro calls.
my $macro     = qr{
                    \^
                    /
                    ;
                }xms;

# put your tests here

$numTests = $session->db->quickScalar('select count(distinct(assetId)) from template');

plan tests => 3*$numTests;

my $validLinks = 0;

my $nonRootLink = qr{
    ^
    \s*                       #Optional whitespace
    (?: \^ (?: / | Extras))   #Gateway or Extras macro
    |                         # OR
    <tmpl_var                 #A template variable
}x;

sub checkLinks {
    my ($tag, $attrs) = @_;
    if ($tag eq 'link' && $attrs->{href}) {
        if ($attrs->{href} !~ $nonRootLink) {
            $validLinks = 0;
        }
    }
    elsif ($tag eq 'script' && $attrs->{src}) {
        if ($attrs->{src} !~ $nonRootLink) {
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
    my $header   = $templateAsset->get('extraHeadTags');
    if(! $header) {
        ok(1, sprintf "%s: %s (%s) has no rooted link urls in the head tags", $templateAsset->getTitle, $templateAsset->getId, $templateAsset->getUrl);
    }
    else {
        $validLinks = 1;
        $parser->parse($header);
        ok($validLinks, sprintf "%s: %s (%s) has no rooted link urls in the head tags", $templateAsset->getTitle, $templateAsset->getId, $templateAsset->getUrl);
    }
    my $template   = $templateAsset->get('template');
    if(! $template) {
        ok(1, sprintf "%s: %s (%s) has no rooted link urls in the template", $templateAsset->getTitle, $templateAsset->getId, $templateAsset->getUrl);
    }
    else {
        $validLinks = 1;
        $parser->parse($template);
        ok($validLinks, sprintf "%s: %s (%s) has no rooted link urls in the template", $templateAsset->getTitle, $templateAsset->getId, $templateAsset->getUrl);
    }
    my $bad_attachments = 0;
    foreach my $attachment (@{ $templateAsset->getAttachments }) {
        ++$bad_attachments if $attachment->{url} !~ $nonRootLink;
    }
    ok $bad_attachments == 0, sprintf "%s: %s (%s) has no rooted link urls in the template attachments", $templateAsset->getTitle, $templateAsset->getId, $templateAsset->getUrl;
}
