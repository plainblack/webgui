#!/usr/bin/perl

use lib "../../lib";
use Getopt::Long;
use strict;
use WebGUI::Id;
use WebGUI::Page;
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

print "\tFixing navigation template variables.\n" unless ($quiet);
my $sth = WebGUI::SQL->read("select * from template where namespace in ('Navigation')");
while (my $data = $sth->hashRef) {
        $data->{template} =~ s/page.current/basepage/ig;
        $data->{template} =~ s/isMy/is/ig;
        $data->{template} =~ s/isCurrent/isBasepage/ig;
        $data->{template} =~ s/inCurrentRoot/inBranch/ig;
        WebGUI::SQL->write("update template set template=".quote($data->{template})." where namespace=".quote($data->{namespace})." and templateId=".quote($data->{templateId}));
}
$sth->finish;


print "\tMoving site icons into style templates.\n" unless ($quiet);
my $type = lc($session{setting}{siteicon});
$type =~ s/.*\.(.*?)$/$1/;
my $tags = '	
	<link rel="icon" href="'.$session{setting}{siteicon}.'" type="image/'.$type.'" />
	<link rel="SHORTCUT ICON" href="'.$session{setting}{favicon}.'" />
	<tmpl_var head.tags>
	';
$sth = WebGUI::SQL->read("select templateId,template from template where namespace='style'");
while (my ($id,$template) = $sth->array) {
	$template =~ s/\<tmpl_var head\.tags\>/$tags/ig;
	WebGUI::SQL->write("update template set template=".quote($template)." where templateId=".quote($id)." and namespace='style'");
}
$sth->finish;
WebGUI::SQL->write("delete from settings where name in ('siteicon','favicon')");



WebGUI::Session::close();


