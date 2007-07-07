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
use Text::Balanced qw(extract_codeblock);
use File::Find;
use Data::Dumper;

#The goal of this test is to verify all the i18n labels in
#the help files.  It used to be glommed into the same test as
#the code scanner, but was broken out due to speed issues.

use Test::More; # increment this value for each test you create
my $numTests = 0;

my $session = WebGUI::Test->session;
my $lib = WebGUI::Test->lib;

# put your tests here

my %helpTable;

my @helpFileSet = WebGUI::Operation::Help::_getHelpFilesList($session);

foreach my $helpSet (@helpFileSet) {
	my $helpName = $helpSet->[1];
	my $help = WebGUI::Operation::Help::_load($session, $helpName);
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

my @helpLabels;
my @sqlLabels;
my @libLabels;
my @objLabels;


@helpLabels = getHelpLabels();

$numTests = scalar(@helpLabels);

plan tests => $numTests;

my $i18n = WebGUI::International->new($session);

foreach my $label ( @helpLabels ) {
	ok($i18n->get(@{ $label }{qw(label namespace )} ),
	sprintf "label: %s->%s inside %s->%s->%s", @{ $label }{'namespace', 'label', 'topic', 'entry', 'tag', });
}

sub getHelpLabels {
	my @helpLabels = ();
	foreach my $topic ( keys %helpTable ) {
		foreach my $entry ( keys %{ $helpTable{$topic} }) {
			##Check the title and body data
			push @helpLabels, {
				topic=>$topic,
				entry=>$entry,
				tag=>'title',
				namespace=>$topic, ##default
				label=>$helpTable{$topic}{$entry}{'title'},
			};
			if (ref $helpTable{$topic}{$entry}{'body'} ne 'CODE') {
				push @helpLabels, {
					topic=>$topic,
					entry=>$entry,
					tag=>'body',
					namespace=>$topic, ##default
					label=>$helpTable{$topic}{$entry}{'body'},
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
			my $variableEntries = getHelpVariables($helpTable{$topic}{$entry}{variables});
			foreach my $variable ( @{ $variableEntries } ) {
				my $namespace = exists $variable->{namespace} ?  $variable->{namespace} : $topic;
				my $one = {
					topic=>$topic,
					entry=>$entry,
					tag=>'variables',
					namespace=>$namespace,
				};
				if ($variable->{description}) {
					$one->{label} = $variable->{description},
				}
				else {
					$one->{label} = $variable->{name},
				}
				push @helpLabels, $one;
			}
		}
	}
	return @helpLabels;
}

sub getHelpVariables {
	my ($variables) = @_; ##An arrayref of variables, possibly with nested variables in loops
	my $tmplVars = [];
	foreach my $var ( @{ $variables } ) {
		if ( exists $var->{variables} ) {
			push @{ $tmplVars }, @{ getHelpVariables($var->{variables}) };
			delete $var->{variables};
		}
		push @{ $tmplVars }, $var;
	}
	return $tmplVars;
}


