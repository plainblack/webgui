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
use WebGUI::Session;
use WebGUI::Operation::Help;

#The goal of this test is to verify that all entries in the lib/WebGUI/Help
#directory correctly resolve to other Help entries.  The total number of
#tests will be dynamic, based on how many "related" entries are set up
#in the Help files.  Calling Test::plan will be delayed.

use Test::More;
my $numTests = 0;

my $session = WebGUI::Test->session;

my @helpFileSet = WebGUI::Operation::Help::_getHelpFilesList($session);

my %helpTable;

foreach my $helpSet (@helpFileSet) {
	my $helpName = $helpSet->[1];
	my $help = WebGUI::Operation::Help::_load($session, $helpName);
	$helpTable{ $helpName } = $help;
}

##Scan #1, how many tests do we expect?

my @relatedHelp = ();
foreach my $topic ( keys %helpTable ) {
	foreach my $entry ( keys %{ $helpTable{$topic} }) {
		my @related = WebGUI::Operation::Help::_related($session, $helpTable{$topic}{$entry}{related});
		foreach my $relHash (@related) {
			$relHash->{parentEntry} = $entry;
			$relHash->{parentTopic} = $topic;
		}
		push @relatedHelp, @related;
		$numTests += scalar @related;
	}
}

plan tests => $numTests;

##Each array element is a hash with two keys, tag (entry) and namespace (topic).

foreach my $related (@relatedHelp) {
	my ($topic, $entry, $parentTopic, $parentEntry) = @{ $related }{'namespace', 'tag', 'parentTopic', 'parentEntry'};
	ok( exists $helpTable{$topic}{$entry}, "Help entry: $topic -> $entry from $parentTopic -> $parentEntry");
}
