#!/usr/bin/perl
use strict;

use lib "/data/WebGUI/lib";  # Edit to match your WebGUI installation directory.


print "Starting WebGUI ".$WebGUI::VERSION."\t\t";
$ENV{GATEWAY_INTERFACE} =~ /^CGI-Perl/ or die "GATEWAY_INTERFACE not Perl!";

#----------------------------------------
# Enable the mod_perl environment. 
#----------------------------------------
use Apache::Registry (); # Uncomment this for use with mod_perl 1.0
#use ModPerl::Registry (); # Uncomment this for use with mod_perl 2.0


#----------------------------------------
# System controlled Perl modules.
#----------------------------------------
eval "use Cache::FileCache ();"; # eval, may not be installed
use CGI (); CGI->compile(':all');
use CGI::Carp ();
use CGI::Util ();
use Date::Calc ();
eval "use Image::Magick ();"; # eval, may not be installed
use File::Copy ();
use File::Path ();
use FileHandle ();
use Net::SMTP ();
use POSIX ();
use URI::Escape ();


#----------------------------------------
# Database connectivity.
#----------------------------------------
#use Apache::DBI (); # Uncomment if you want to enable connection pooling. Not recommended on low memory - high traffic systems.
use DBI ();
DBI->install_driver("mysql"); # Change to match your database driver.



#----------------------------------------
# Distributed utilities external to WebGUI.
#----------------------------------------
use HTML::CalendarMonthSimple ();
#use HTML::Parser (); # commented because it is causing problems with attachments
#use HTML::TagFilter (); # commented because it is causing problems with attachments
use Net::LDAP ();
use Parse::PlainConfig ();
#use Authen::Smb (); #uncomment when using this type of authentication.
use Tie::CPHash ();
use Tie::IxHash ();
use Tree::DAG_Node ();

#----------------------------------------
# WebGUI modules.
#----------------------------------------
use WebGUI ();
use WebGUI::Attachment ();
use WebGUI::Authentication ();
use WebGUI::Cache ();
use WebGUI::Collateral ();
use WebGUI::CollateralFolder ();
use WebGUI::DatabaseLink ();
use WebGUI::DateTime ();
#use WebGUI::Discussion (); # compile problems when this is included
use WebGUI::ErrorHandler ();
use WebGUI::Form ();
use WebGUI::FormProcessor ();
use WebGUI::Group ();
use WebGUI::Grouping ();
use WebGUI::HTMLForm ();
use WebGUI::HTML ();
use WebGUI::Icon ();
use WebGUI::International ();
use WebGUI::Macro ();
use WebGUI::Mail ();
use WebGUI::MessageLog ();
use WebGUI::Navigation ();
use WebGUI::Node ();
use WebGUI::Persistent ();
use WebGUI::Persistent::Query ();
use WebGUI::Persistent::Tree ();
use WebGUI::Persistent::Query::Delete ();
use WebGUI::Persistent::Query::Insert ();
use WebGUI::Persistent::Query::Select ();
use WebGUI::Persistent::Query::Update ();
use WebGUI::Operation ();
use WebGUI::Operation::Account ();
use WebGUI::Operation::Admin ();
use WebGUI::Operation::Clipboard ();
use WebGUI::Operation::Collateral ();
use WebGUI::Operation::DatabaseLink ();
use WebGUI::Operation::Group ();
use WebGUI::Operation::Help ();
use WebGUI::Operation::International ();
use WebGUI::Operation::Package ();
use WebGUI::Operation::Page ();
use WebGUI::Operation::ProfileSettings ();
use WebGUI::Operation::Root ();
use WebGUI::Operation::Scratch ();
use WebGUI::Operation::Search ();
use WebGUI::Operation::Settings ();
use WebGUI::Operation::Shared ();
use WebGUI::Operation::Statistics ();
use WebGUI::Operation::Style ();
use WebGUI::Operation::Template ();
use WebGUI::Operation::Theme ();
use WebGUI::Operation::Trash ();
use WebGUI::Operation::User ();
use WebGUI::Operation::WebGUI ();
use WebGUI::Page ();
use WebGUI::Paginator ();
use WebGUI::Privilege ();
use WebGUI::Search ();
use WebGUI::Session ();
use WebGUI::SQL ();
use WebGUI::Style ();
use WebGUI::TabForm ();
use WebGUI::Template ();
use WebGUI::URL ();
use WebGUI::User ();
use WebGUI::Utility ();
use WebGUI::Wobject ();

print "[  OK  ]\n";


1;


