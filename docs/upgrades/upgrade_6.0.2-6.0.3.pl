#!/usr/bin/perl

use lib "../../lib";
use Getopt::Long;
use Parse::PlainConfig;
use strict;
use WebGUI::Session;
use WebGUI::International;
use WebGUI::SQL;


my $configFile;
my $quiet;

GetOptions(
        'configFile=s'=>\$configFile,
	'quiet'=>\$quiet
);

WebGUI::Session::open("../..",$configFile);

print "\tFixing pagination template variables.\n" unless ($quiet);
my $sth = WebGUI::SQL->read("select * from template where namespace in ('Article')");
while (my $data = $sth->hashRef) {
	$data->{template} =~ s/pagination\.ispagination\.firstPage/pagination.isFirstPage/ig;
	$data->{template} =~ s/pagination\.ispagination\.lastPage/pagination.isLastPage/ig;
	WebGUI::SQL->write("update template set template=".quote($data->{template})." where namespace=".quote($data->{namespace})." and templateId=".quote($data->{templateId}));
}
$sth->finish;


WebGUI::Session::close();


