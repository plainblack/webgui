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

use WebGUI::Test;
use WebGUI::Session;
use WebGUI::Operation::Help;

use Data::Dumper;

#The goal of this test is to verify that all entries in the lib/WebGUI/Help
#directory correctly resolve to other Help entries.  The total number of
#tests will be dynamic, based on how many "related" and "isa" entries are set up
#in the Help files.  Calling Test::plan will be delayed.

use Test::More;
my $numTests = 0;

my $session = WebGUI::Test->session;

my @helpFileSet = WebGUI::Pluggable::findAndLoad('WebGUI::Help');

my %helpTable;

foreach my $helpSet (@helpFileSet) {
    my ($namespace) = $helpSet =~ m{WebGUI::Help::(.+$)};
	my $help = WebGUI::Operation::Help::_load($session, $namespace);
	$helpTable{ $namespace } = $help;
}

##Scan #1, how many tests do we expect?

my @relatedHelp = ();
my @isaHelp = ();
foreach my $topic ( keys %helpTable ) {
	foreach my $entry ( keys %{ $helpTable{$topic} }) {
		my @related = @{ $helpTable{$topic}{$entry}{related} };
		foreach my $relHash (@related) { ##Inplace modify
			$relHash->{parentEntry} = $entry;
			$relHash->{parentTopic} = $topic;
		}
		push @relatedHelp, @related;
		my @isas = @{ $helpTable{$topic}{$entry}{isa} };
		foreach my $isaHash ( @isas ) {
			$isaHash->{parentEntry} = $entry;
			$isaHash->{parentTopic} = $topic;
		}
		push @isaHelp, @isas;
	}
}


plan tests => scalar @relatedHelp + scalar @isaHelp;

##Each array element is a hash with two keys, tag (entry) and namespace (topic).

foreach my $related (@relatedHelp) {
	my ($topic, $entry, $parentTopic, $parentEntry) = @{ $related }{'namespace', 'tag', 'parentTopic', 'parentEntry'};
	ok( exists $helpTable{$topic}{$entry}, "Help entry: $topic -> '$entry' from $parentTopic -> $parentEntry");
}

foreach my $isa (@isaHelp) {
	my ($topic, $entry, $parentTopic, $parentEntry) = @{ $isa }{'namespace', 'tag', 'parentTopic', 'parentEntry'};
	ok( exists $helpTable{$topic}{$entry}, "Help entry: $topic -> $entry from $parentTopic -> $parentEntry");
}
