#!/usr/bin/perl

use lib "../../lib";
use FileHandle;
use File::Path;
use File::Copy;
use Getopt::Long;
use strict;
use WebGUI::Group;
use WebGUI::HTML;
use WebGUI::Id;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;


my $configFile;
my $quiet;

GetOptions(
    'configFile=s'=>\$configFile,
	'quiet'=>\$quiet
);

WebGUI::Session::open("../..",$configFile);

print "\tReplacing session.page template variables with the ^Page  macro.\n" unless ($quiet);
my $sth = WebGUI::SQL->read("select assetId,template from template");
while (my ($id, $template) = $sth->array) {
	$template =~ s/\<tmpl_var\s+session\.page\.(.*?)\>/^Page($1);/xsig;
	WebGUI::SQL->setRow("template","assetId",{
		assetId=>$id,
		template=>$template
		});
}
$sth->finish;

WebGUI::Session::close();


