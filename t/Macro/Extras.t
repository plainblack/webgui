#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
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
use WebGUI::Macro;
use WebGUI::Session;
use WebGUI::Macro_Config;

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

my @added_macros = ();
push @added_macros, WebGUI::Macro_Config::enable_macro($session, 'Extras', 'Extras');

my @testSets = (
	{ ##Just get the extras path
	macroText => q!^Extras();!,
	path => q!!,
	output => $session->url->extras(),
	},
	{ ##Note that trailing slash is appended
	macroText => q!^Extras();!,
	path => q!!,
	output => $session->config->get("extrasURL").'/',
	},
	{ ##append a path, example from docs
	macroText => q!^Extras(%s);!,
	path => q!path/to/something/in/extras/folder!,
	output => $session->url->extras('path/to/something/in/extras/folder'),
	},
	{ ##double slashes are removed
	macroText => q!^Extras(%s);!,
	path => q!/path/to/something/in/extras/folder!,
	output => $session->url->extras('path/to/something/in/extras/folder'),
	},
);

my $numTests = scalar @testSets;

plan tests => $numTests;

foreach my $testSet (@testSets) {
	my $output = sprintf $testSet->{macroText}, $testSet->{path};
	my $macro = $output;
	WebGUI::Macro::process($session, \$output);
	is($output, $testSet->{output}, 'testing '.$macro);
}

END {
	foreach my $macro (@added_macros) {
		next unless $macro;
		$session->config->deleteFromHash("macros", $macro);
	}
}

