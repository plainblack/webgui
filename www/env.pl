#!/usr/bin/perl
print "Content-type: text/html\n\n";

foreach (keys %ENV) {
       print $_."=".$ENV{$_}."<br>\n";
}
