#! /usr/bin/perl
use strict;

use lib "/data/WebGUI/lib";

print "Staring WebGUI ".$WebGUI::VERSION."\t\t";
$ENV{GATEWAY_INTERFACE} =~ /^CGI-Perl/ or die "GATEWAY_INTERFACE not Perl!";

use Apache::Registry (); 
use Apache::DBI ();
use CGI (); CGI->compile(':all');
use CGI::Carp ();
use DBI ();
use DBD::mysql ();
use HTML::Parser ();
use Data::Config ();
use Date::Calc ();
use HTML::CalendarMonthSimple ();
use Image::Magick ();
use Tie::CPHash ();
use Tie::IxHash ();
use Net::LDAP ();
use Net::SMTP ();
use File::Copy ();
use File::Path ();
use FileHandle ();
use HTML::TagFilter ();
use POSIX ();
use WebGUI ();

print "[  OK  ]";

1;


