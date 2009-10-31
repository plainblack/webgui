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
use WebGUI::Macro::International;
use Data::Dumper;

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

my @testSets = (
    {
        input   => ['none', 'Asset'],
        output  => q!None!,
        comment => q|explicit namespace|,
    },
    {
        input   => ['change url', 'Asset'],
        output  => q!Change URL!,
        comment => q|space in label|,
    },
    {
        input   => ['webgui', 'WebGUI'],
        output  => q!WebGUI!,
        comment => q|explicit namespace #2|,
    },
    {
        input   => ['webgui', ''],
        output  => q!WebGUI!,
        comment => q|default namespace|,
    },
    {
        input   => ['template listFilesForUser title', 'Asset_Gallery', 'plainblack'],
        output  => q{plainblack's Gallery},
        comment => q{Third and more arguments are passed to sprintf()},
    },
);

my $numTests = scalar @testSets;

plan tests => $numTests;

foreach my $testSet (@testSets) {
	my $output = WebGUI::Macro::International::process($session, @{ $testSet->{input} });
	is($output, $testSet->{output}, $testSet->{comment} );
}
