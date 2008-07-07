#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2007 Plain Black Corporation.
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
use lib "$FindBin::Bin/../lib"; ##t/lib

use WebGUI::Test;
use WebGUI::Operation::Help;
use WebGUI::International;
use WebGUI::Session;
use Data::Dumper;
use WebGUI::Asset::Template;

#The goal of this test is to locate all of the international labels that it
#can and verify that they exist in all loaded language models

use Test::More; # increment this value for each test you create
my $numTests = 0;
plan skip_all => 'set CODE_COP to enable this test' unless $ENV{CODE_COP};

my $session = WebGUI::Test->session;
my $lib = WebGUI::Test->lib;

# put your tests here

my $digits  = qr/(\d+)/;
my $bareword  = qr/([^,)]+)/;  ##Anything that's not a comma
my $quotelike = qr/((['])([^'\s\$]+\s*)+([']))/;
my $sub_args  = qr/(($quotelike|$bareword)(?:,\s*)?)+/;  ##Don't really need spaces
my $macro     = qr/
			  \^International
			  \(			##Opening paren
			    ($sub_args)
			  \);			##Closing paren and semicolon
		    /x;

my $getATemplate = WebGUI::Asset::Template->getIsa($session);

my @templateLabels;
my @questionableTemplates;

while (my $templateAsset = $getATemplate->()) {
    my $template = $templateAsset->get('template');
    if (!$template) {
        push @questionableTemplates, {
            url        => $templateAsset->getUrl,
            id         => $templateAsset->getId,
            title      => $templateAsset->getTitle,
        };
    }
    while ($template =~ /$macro/msgc) {
        my ($label, $namespace) = split /,/, $1;
        push @templateLabels, {
            label      => $label,
            namespace  => $namespace,
            url        => $templateAsset->getUrl,
            id         => $templateAsset->getId,
            title      => $templateAsset->getTitle,
        };
    }
}

$numTests = scalar @templateLabels | scalar @questionableTemplates;

plan tests => $numTests;

my $i18n = WebGUI::International->new($session);

foreach my $label ( @templateLabels ) {
	ok($i18n->get(@{ $label }{qw(label namespace )} ),
	sprintf "label: %s->%s inside %s, id: %s, url: %s", @{ $label }{qw/namespace label title id url/});
}

foreach my $label ( @questionableTemplates ) {
	fail(
        sprintf "Empty template:  %s, id: %s, url: %s", @{ $label }{qw/title id url/}
    );
}
