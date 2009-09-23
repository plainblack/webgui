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
use lib "$FindBin::Bin/lib";

use WebGUI::Test;
use WebGUI::Asset;
use WebGUI::Session;
use File::Find;

#The goal of this test is to check that mandatory template
#variables exist in their templates.

my @tmplVarTable = (
	## Templates from WebGUI::AdminConsole.pm
	{
		id   => 'PBtmpl0000000000000137',
		var  => [ ],
	},
	{
		id   => 'PBtmpl0000000000000001',
		var  => [ qw(application.workarea) ],
		loop => [ qw(application_loop)]
	},
	## Templates from WebGUI::Operation::Help.pm
	{
		id   => 'PBtmplHelp000000000001',
		var  => [ qw(body) ],
		loop => [ qw(fields) ],
		if   => [ qw(fields) ],
	},
	## Login, account and password templates
	{
		id   => 'PBtmpl0000000000000010',
		var => [ ],
	},
	{
		id   => 'PBtmpl0000000000000011',
		var  => [ ],
	},
	{
		id   => 'PBtmpl0000000000000012',
		var  => [ ],
	},
	{
		id   => 'PBtmpl0000000000000013',
		var  => [ ],
	},
	{
		id   => 'PBtmpl0000000000000014',
		var  => [ ],
	},
	{
		id   => 'PBtmpl0000000000000020',
		if   => [ qw(field.isRequired) ],
	},
	## Templates with editing toolbars
	###Matrix Default View
	{
		id   => 'matrixtmpl000000000001',
		var  => [ qw(controls) ],
	},
	###Article
	{
		id   => 'PBtmpl0000000000000002',
		var  => [ qw(controls) ],
	},
	###Dashboard
	{
		id   => 'DashboardViewTmpl00001',
		var  => [ qw(controls) ],
	},
	###DataForm
	{
		id   => 'PBtmpl0000000000000141',
		var  => [ qw(controls) ],
	},
	###Folder
	{
		id   => 'PBtmpl0000000000000078',
		var  => [ qw(controls) ],
	},
	###HttpProxy
	{
		id   => 'PBtmpl0000000000000033',
		var  => [ qw(controls) ],
	},
	###Layout
	{
		id   => 'PBtmpl0000000000000054',
		var  => [ qw(controls) ],
	},
	###MessageBoard
	{
		id   => 'PBtmpl0000000000000047',
		var  => [ qw(controls) ],
	},
	###MultiSearch
	{
		id   => 'MultiSearchTmpl0000001',
		var  => [ qw(controls) ],
	},
	###Poll
	{
		id   => 'PBtmpl0000000000000055',
		var  => [ qw(controls) ],
	},
	###SQL Report
	{
		id   => 'PBtmpl0000000000000059',
		var  => [ qw(controls) ],
	},
	###Stock Data
	{
		id   => 'StockDataTMPL000000001',
		var  => [ qw(controls) ],
	},
	###Survey
	{
		id   => 'PBtmpl0000000000000061',
		var  => [ qw(controls) ],
	},
	###SyndicatedContent
	{
		id   => 'PBtmpl0000000000000065',
		var  => [ qw(controls) ],
	},
	###Weather Data
	{
		id   => 'WeatherDataTmpl0000001',
		var  => [ qw(controls) ],
	},
);

use Test::More; # increment this value for each test you create
my $numTests = 0;

my $session = WebGUI::Test->session;

my @varTypes = qw( var loop if );

foreach my $tmpl (@tmplVarTable) {
	++$numTests; #Check for template existance
	foreach my $varType (@varTypes) {
		next unless exists $tmpl->{$varType};
		$tmpl->{numTests} += scalar @{ $tmpl->{$varType} };
	}
	$numTests += $tmpl->{numTests};
}

# put your tests here

plan tests => $numTests;

#note("planning on $numTests tests");

foreach my $tmpl ( @tmplVarTable ) {
	my $tmplId = $tmpl->{id};
	my $tmplAsset = WebGUI::Asset->newByDynamicClass($session, $tmplId);
	my $tmplExists = is(ref($tmplAsset), 'WebGUI::Asset::Template', "$tmplId exists");
	SKIP: {
		skip("$tmplId could not be found",  $tmpl->{numTests} ) unless $tmplExists;
		my $tmplName = $tmplAsset->get('title');
		my $template = $tmplAsset->get('template');
		foreach my $varType ( @varTypes ) {
			foreach my $var ( @{ $tmpl->{$varType} }) {
				ok( $template=~qr/(?i)<tmpl_$varType\s+$var/, "Checking for $var of type $varType in $tmplName, id=$tmplId");
			}
		}
	}
}


