#!/usr/bin/perl
use strict;

use lib "/data/WebGUI/lib";

print "Starting WebGUI ".$WebGUI::VERSION."\t\t";
$ENV{GATEWAY_INTERFACE} =~ /^CGI-Perl/ or die "GATEWAY_INTERFACE not Perl!";

#----------------------------------------
# System controlled Perl modules.
#----------------------------------------
use Apache::Registry (); # Uncomment this for use with mod_perl 1.0
#use ModPerl::Registry (); # Uncomment this for use with mod_perl 2.0
use CGI (); CGI->compile(':all');
use CGI::Carp ();
use URI::Escape ();
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
eval " use Cache::FileCache (); "; # check to see if it will load;


#----------------------------------------
# Database connectivity.
#----------------------------------------
use DBI ();
DBI->install_driver("mysql"); # Change to match your database driver.
#use Apache::DBI (); # Uncomment if you want to enable connection pooling. Not recommended on low memory - high traffic systems.



#----------------------------------------
# Distributed utilities external to WebGUI.
#----------------------------------------
#use HTML::Parser (); # commented because it is causing problems with attachments
#use HTML::TagFilter (); # commented because it is causing problems with attachments
use Data::Config ();


#----------------------------------------
# WebGUI modules.
#----------------------------------------
use WebGUI ();
use WebGUI::Attachment ();
use WebGUI::DateTime ();
#use WebGUI::Discussion (); # compile problems when this is included
use WebGUI::ErrorHandler ();
use WebGUI::Form ();
use WebGUI::HTMLForm ();
use WebGUI::HTML ();
use WebGUI::Icon ();
use WebGUI::International ();
use WebGUI::Macro ();
use WebGUI::Mail ();
use WebGUI::MessageLog ();
use WebGUI::Node ();
use WebGUI::Operation ();
use WebGUI::Operation::Account ();
use WebGUI::Operation::Admin ();
use WebGUI::Operation::Collateral ();
use WebGUI::Operation::Group ();
use WebGUI::Operation::Help ();
use WebGUI::Operation::International ();
use WebGUI::Operation::Package ();
use WebGUI::Operation::Page ();
use WebGUI::Operation::ProfileSettings ();
use WebGUI::Operation::Root ();
use WebGUI::Operation::Search ();
use WebGUI::Operation::Settings ();
use WebGUI::Operation::Shared ();
use WebGUI::Operation::Statistics ();
use WebGUI::Operation::Style ();
use WebGUI::Operation::Template ();
use WebGUI::Operation::Trash ();
use WebGUI::Operation::User ();
use WebGUI::Page ();
use WebGUI::Paginator ();
use WebGUI::Privilege ();
#use WebGUI::Profile (); # compile problems when this is included
use WebGUI::Search ();
use WebGUI::Session ();
use WebGUI::SQL ();
use WebGUI::Style ();
use WebGUI::Template ();
use WebGUI::URL ();
use WebGUI::User ();
use WebGUI::Utility ();
use WebGUI::Wobject ();

print "[  OK  ]";


1;


