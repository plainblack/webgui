#! /usr/bin/perl
use strict;

use lib "/data/WebGUI/lib";

print "Starting WebGUI ".$WebGUI::VERSION."\t\t";
$ENV{GATEWAY_INTERFACE} =~ /^CGI-Perl/ or die "GATEWAY_INTERFACE not Perl!";

use Apache::Registry (); 
#use Apache::DBI (); # Uncomment if you want to enable connection pooling. Not recommended on low memory - high traffic systems.
use CGI (); CGI->compile(':all');
use CGI::Carp ();
use DBI ();
use DBD::mysql ();
use URI::Escape ();
use Data::Config ();
use Date::Calc ();
use HTML::CalendarMonthSimple ();
eval "use Image::Magick ();"; # eval, may not be installed
use Tie::CPHash ();
use Tie::IxHash ();
use Net::LDAP ();
use Net::SMTP ();
use File::Copy ();
use File::Path ();
use FileHandle ();
use POSIX ();
#use HTML::Parser (); # commented because it is causing problems with attachments
#use HTML::TagFilter (); # commented because it is causing problems with attachments
use WebGUI ();

print "[  OK  ]";

1;


