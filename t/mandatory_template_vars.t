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
use WebGUI::Asset;
use File::Find;
# ---- END DO NOT EDIT ----

#The goal of this test is to check that mandatory template
#variables exist in their templates.

my @tmplVarTable = (
	## Templates from WebGUI:Operation::Profile.pm
	{
		id   => 'PBtmpl0000000000000051',
		vars => [ qw(profile.form.footer profile.form.header profile.form.hidden profile.form.submit) ],
	},
	{
		id   => 'PBtmpl0000000000000052',
		vars => [ ],
	},
	## Templates from WebGUI::AdminConsole.pm
	{
		id   => 'PBtmpl0000000000000137',
		vars => [ ],
	},
	{
		id   => 'PBtmpl0000000000000001',
		vars => [ qw(application_loop application.workarea) ],
	},
	## Templates from WebGUI::Operation::MessageLog.pm
	{
		id   => 'PBtmpl0000000000000050',
		vars => [ qw(message.loop) ],
	},
	{
		id   => 'PBtmpl0000000000000049',
		vars => [ qw(message.takeAction) ],
	},
	## Templates from WebGUI::Operation::Help.pm
	{
		id   => 'PBtmplHelp000000000001',
		vars => [ qw(body fields) ],
	},
	## Login, account and password templates
	{
		id   => 'PBtmpl0000000000000010',
		vars => [ ],
	},
	{
		id   => 'PBtmpl0000000000000011',
		vars => [ ],
	},
	{
		id   => 'PBtmpl0000000000000012',
		vars => [ ],
	},
	{
		id   => 'PBtmpl0000000000000013',
		vars => [ ],
	},
	{
		id   => 'PBtmpl0000000000000014',
		vars => [ ],
	},
	{
		id   => 'PBtmpl0000000000000020',
		vars => [ qw(field.isRequired) ],
	},

);

use Test::More; # increment this value for each test you create
my $numTests = 0;

initialize();  # this line is required

foreach my $tmpl (@tmplVarTable) {
	++$numTests; #Check for template existance
	$numTests += scalar @{ $tmpl->{vars} }; #Check for each mandatory variable
}

# put your tests here

plan tests => $numTests;

diag("planning on $numTests tests");

foreach my $tmpl ( @tmplVarTable ) {
	my $tmplId = $tmpl->{id};
	my $tmplAsset = WebGUI::Asset->newByDynamicClass($tmplId);
	my $tmplExists = is(ref($tmplAsset), 'WebGUI::Asset::Template', "$tmplId exists");
	SKIP: {
		skip("$tmplId could not be found", scalar @{ $tmpl->{vars} }) unless $tmplExists;
		my $tmplName = $tmplAsset->get('title');
		my $template = $tmplAsset->get('template');
		foreach my $var ( @{ $tmpl->{vars} }) {
			ok( $template=~qr/$var/, "Checking for $var in $tmplName, id=$tmplId");
		}
	}
}

cleanup(); # this line is required

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

