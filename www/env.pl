#!/usr/bin/perl
use CGI;
my $cgi = CGI->new();
print $cgi->header;

foreach (keys %ENV) {
       print $_."=".$ENV{$_}."<br>\n";
}
