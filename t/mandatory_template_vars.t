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
use WebGUI::Asset;
use WebGUI::Session;
use File::Find;
# ---- END DO NOT EDIT ----

#The goal of this test is to check that mandatory template
#variables exist in their templates.

my @tmplVarTable = (
	## Templates from WebGUI:Operation::Profile.pm
	{
		id   => 'PBtmpl0000000000000051',
		var  => [ qw(profile.form.footer profile.form.header profile.form.hidden profile.form.submit) ],
	},
	{
		id   => 'PBtmpl0000000000000052',
		var  => [ ],
	},
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
	## Templates from WebGUI::Operation::MessageLog.pm
	{
		id   => 'PBtmpl0000000000000050',
		loop => [ qw(message.loop) ],
	},
	{
		id  => 'PBtmpl0000000000000049',
		var => [ qw(message.takeAction) ],
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
	###EventsCalendar
	{
		id   => 'PBtmpl0000000000000022',
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
	###Navigation
	{
		id   => 'PBtmpl0000000000000048',
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
	###WS Client
	{
		id   => 'PBtmpl0000000000000069',
		var  => [ qw(controls) ],
	},

);

use Test::More; # increment this value for each test you create
my $numTests = 0;

my $session = initialize();  # this line is required

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

diag("planning on $numTests tests");

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

cleanup($session); # this line is required

# ---- DO NOT EDIT BELOW THIS LINE -----

sub initialize {
        $|=1; # disable output buffering
        my $configFile;
        GetOptions(
                'configFile=s'=>\$configFile
        );
        exit 1 unless ($configFile);
        my $session = WebGUI::Session->open("..",$configFile);
}

sub cleanup {
        my $session = shift;
        $session->close();
}

