#!/usr/bin/perl

use lib "../../lib";
use Getopt::Long;
use Parse::PlainConfig;
use strict;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::Utility;

 
my $configFile;
my $quiet;

GetOptions(
    'configFile=s'=>\$configFile,
	'quiet'=>\$quiet
);

#print "\tUpdating config file.\n" unless ($quiet);

my $pathToConfig = '../../etc/'.$configFile;

WebGUI::Session::open("../..",$configFile);

print "\tAdding new columns to wobject.\n" unless ($quiet);
#Add new columns
WebGUI::SQL->write("alter table wobject add ownerId Integer Not Null Default 0");
WebGUI::SQL->write("alter table wobject add groupIdEdit Integer Not Null Default 3");
WebGUI::SQL->write("alter table wobject add groupIdView Integer Not Null Default 3");

print "\tUpdating Wobject Privileges.\n" unless ($quiet);
#setting wobject privileges to page privileges
my $page;
my $wobject;
my $sth = WebGUI::SQL->read("select * from page");
while($page = $sth->hashRef){
   my $sth2 = WebGUI::SQL->read("select * from wobject where pageId=".$page->{pageId});
   while($wobject = $sth2->hashRef){
      WebGUI::SQL->write("update wobject set ownerId=".$page->{ownerId}.", groupIdEdit=".$page->{groupIdEdit}.", groupIdView=".$page->{groupIdView}." where wobjectId=".$wobject->{wobjectId});
   }
}

WebGUI::Session::close();
