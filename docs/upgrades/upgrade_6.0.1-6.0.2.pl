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
my $sth = WebGUI::SQL->read("select * from template where namespace in ('SQLReport','USS','Article','FileManager')");
while (my $data = $sth->hashRef) {
	$data->{template} =~ s/isFirstPage/pagination.isFirstPage/ig;
	$data->{template} =~ s/isLastPage/pagination.isLastPage/ig;
	$data->{template} =~ s/firstPage/pagination.firstPage/ig;
	$data->{template} =~ s/lastPage/pagination.lastPage/ig;
	$data->{template} =~ s/nextPage/pagination.nextPage/ig;
	$data->{template} =~ s/pageList/pagination.pageList.upTo20/ig;
	$data->{template} =~ s/previousPage/pagination.previousPage/ig;
	$data->{template} =~ s/multiplePages/pagination.pageCount.isMultiple/ig;
	$data->{template} =~ s/numberOfPages/pagination.pageCount/ig;
	$data->{template} =~ s/pageNumber/pagination.pageNumber/ig;
	WebGUI::SQL->write("update template set template=".quote($data->{template})." where namespace=".quote($data->{namespace})." and templateId=".quote($data->{templateId}));
}
$sth->finish;

print "\tFixing submission controls.\n" unless ($quiet);
my $sth = WebGUI::SQL->read("select * from template where namespace in ('USS')");
while (my $data = $sth->hashRef) {
	$data->{template} =~ s/\<tmpl_var submission\.controls\>/<tmpl_if session.var.adminOn><tmpl_var submission.controls><tmpl_else><tmpl_unless submission.currentUser>[<a href="<tmpl_var submission.edit.url>"><tmpl_var submission.edit.label><\/a>]<\/tmpl_unless><\/tmpl_if>/ig;
	$data->{template} =~ s/\[<a href="\<tmpl_var submission\.edit\.url\>"\>\<tmpl_var submission\.edit\.label\>\<\/a\>\]/<tmpl_unless session.var.adminOn>[<a href="<tmpl_var submission.edit.url>"><tmpl_var submission.edit.label><\/a>]<\/tmpl_unless>/ig;
	WebGUI::SQL->write("update template set template=".quote($data->{template})." where namespace=".quote($data->{namespace})." and templateId=".quote($data->{templateId}));
}
$sth->finish;

WebGUI::Session::close();


