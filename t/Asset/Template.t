#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use lib '../../lib';
use Getopt::Long;
use WebGUI::Session;
use WebGUI::Asset;
use Test::More tests => 1; # increment this value for each test you create

my $session = initialize();  # this line is required

my $importNode = WebGUI::Asset->getImportNode($session);
my $template = $importNode->addChild({className=>"WebGUI::Asset::Template", title=>"test", url=>"testingtemplates"});
ok(defined $template, "creating a template");


cleanup($session); # this line is required



sub initialize {
	$|=1; # disable output buffering
	my $configFile;
	GetOptions(
        	'configFile=s'=>\$configFile
	);
	exit 1 unless ($configFile);
	my $session = WebGUI::Session->open("../..",$configFile);
}

sub cleanup {
	my $session = shift;
	$session->close();
}

