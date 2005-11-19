#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

# ---- BEGIN DO NOT EDIT ----
use strict;
use lib '../lib';
use Getopt::Long;
use WebGUI::Session;
use WebGUI::Operation::Help;
use WebGUI::International;
use Data::Dumper;
use File::Find;
# ---- END DO NOT EDIT ----

#The goal of this test is to locate all of the international labels that it
#can and verify that they exist in all loaded language models

use Test::More; # increment this value for each test you create
my $numTests = 0;

initialize();  # this line is required

# put your tests here

my %helpTable;

my @helpFileSet = WebGUI::Operation::Help::_getHelpFilesList();

foreach my $helpSet (@helpFileSet) {
	my $helpName = $helpSet->[1];
	my $help = WebGUI::Operation::Help::_load($helpName);
	$helpTable{ $helpName } = $help;
}

##Scan #1, find all labels in the help system.  body, title, @fields

## Array of hashes
## each hash will have:
##	topic -> which help file it is from
##	entry -> which entry in the help file
##	tag   -> which tag in the entry in the help file
##	namespace -> which help file it is form
##	label -> which help file it is form

my @helpLabels = ();
foreach my $topic ( keys %helpTable ) {
	foreach my $entry ( keys %{ $helpTable{$topic} }) {
		##Check the title and body data
		foreach my $tag ('title','body') {
			push @helpLabels, {
				topic=>$topic,
				entry=>$entry,
				tag=>$tag,
				namespace=>$topic, ##default
				label=>$helpTable{$topic}{$entry}{$tag},
			};
		}

		##Add all labels in the fields array
		foreach my $field (@{ $helpTable{$topic}{$entry}{fields} }) {
			push @helpLabels, {
				topic=>$topic,
				entry=>$entry,
				tag=>'fields',
				namespace=>$field->{namespace},
				label=>$field->{title},
			},
			{
				topic=>$topic,
				entry=>$entry,
				tag=>'fields',
				namespace=>$field->{namespace},
				label=>$field->{description},
			},;
		}
	}
}

$numTests = scalar @helpLabels;

diag("Planning on running $numTests tests\n");

#find(\&label_finder_pm, '../');

plan tests => $numTests;

foreach my $i18n ( @helpLabels ) {
	ok(WebGUI::International::get(@{ $i18n }{qw(label namespace )} ),
	sprintf "label: %s->%s inside %s->%s->%s", @{ $i18n }{'namespace', 'label', 'topic', 'entry', 'tag', });
}

cleanup(); # this line is required

sub label_finder_pm {
	local $_;
	next unless /\.pm/;
}


# ---- DO NOT EDIT BELOW THIS LINE -----

sub initialize {
	$|=1; # disable output buffering
	my $configFile;
	GetOptions(
        	'configFile=s'=>\$configFile
	);
	exit 1 unless ($configFile);
	WebGUI::Session::open("..",$configFile);
}

sub cleanup {
	WebGUI::Session::close();
}

