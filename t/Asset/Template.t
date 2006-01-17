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
use WebGUI::Asset::Template;
use Test::More tests => 8; # increment this value for each test you create

my $session = initialize();  # this line is required

my $list = WebGUI::Asset::Template->getList($session);
ok(defined $list, "getList()");
my $template = " <tmpl_var variable> <tmpl_if conditional>true</tmpl_if> <tmpl_loop loop>XY</tmpl_loop> ";
my %var = (
	variable=>"AAAAA",
	conditional=>1,
	loop=>[{},{},{},{},{}]
	);
my $output = WebGUI::Asset::Template->processRaw($session,$template,\%var);
ok($output =~ m/AAAAA/, "processRaw() - variables");
ok($output =~ m/true/, "processRaw() - conditionals");
ok($output =~ m/XYXYXYXYXY/, "processRaw() - loops");
my $importNode = WebGUI::Asset::Template->getImportNode($session);
my $template = $importNode->addChild({className=>"WebGUI::Asset::Template", title=>"test", url=>"testingtemplates", template=>$template});
ok(defined $template, "creating a template");
$output = $template->process(\%var);
ok($output =~ m/AAAAA/, "process() - variables");
ok($output =~ m/true/, "process() - conditionals");
ok($output =~ m/XYXYXYXYXY/, "process() - loops");


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

