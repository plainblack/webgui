#!/usr/bin/perl
use strict;

use lib "/data/WebGUI/lib";  # Edit to match your WebGUI installation directory.


print "Starting WebGUI ".$WebGUI::VERSION."\t\t";
$ENV{GATEWAY_INTERFACE} =~ /^CGI-Perl/ or die "GATEWAY_INTERFACE not Perl!";

#----------------------------------------
# Enable the mod_perl environment. 
#----------------------------------------
#use Apache::Registry (); # Uncomment this for use with mod_perl 1.0
use ModPerl::Registry (); # Uncomment this for use with mod_perl 2.0


#----------------------------------------
# System controlled Perl modules.
#----------------------------------------
use Cache::FileCache ();
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
use SOAP::Lite ();


#----------------------------------------
# Database connectivity.
#----------------------------------------
#use Apache::DBI (); # Uncomment if you want to enable connection pooling. Not recommended on low memory systems.
use DBI ();
DBI->install_driver("mysql"); # Change to match your database driver.



#----------------------------------------
# Distributed utilities external to WebGUI.
#----------------------------------------
#use HTML::Parser (); # commented because it is causing problems with attachments
#use HTML::TagFilter (); # commented because it is causing problems with attachments
use Parse::PlainConfig ();
use Tie::CPHash ();
use Tie::IxHash ();
use Tree::DAG_Node ();

#----------------------------------------
# WebGUI modules.
#----------------------------------------

# core
use WebGUI ();
use WebGUI::Affiliate ();
use WebGUI::Attachment ();
use WebGUI::Auth ();
use WebGUI::Cache ();
use WebGUI::Collateral ();
use WebGUI::CollateralFolder ();
use WebGUI::DatabaseLink ();
use WebGUI::DateTime ();
use WebGUI::ErrorHandler ();
use WebGUI::Form ();
use WebGUI::FormProcessor ();
use WebGUI::Forum ();
use WebGUI::Forum::Post ();
use WebGUI::Forum::Thread ();
use WebGUI::Forum::UI ();
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
use WebGUI::Operation ();
use WebGUI::Persistent ();
use WebGUI::Persistent::Query ();
use WebGUI::Persistent::Tree ();
use WebGUI::Persistent::Query::Delete ();
use WebGUI::Persistent::Query::Insert ();
use WebGUI::Persistent::Query::Select ();
use WebGUI::Persistent::Query::Update ();
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

# help
use WebGUI::Help::Article ();
use WebGUI::Help::AuthLDAP ();
use WebGUI::Help::AuthSMB ();
use WebGUI::Help::AuthWebGUI ();
use WebGUI::Help::DataForm ();
use WebGUI::Help::EventsCalendar ();
use WebGUI::Help::FileManager ();
use WebGUI::Help::HttpProxy ();
use WebGUI::Help::IndexedSearch ();
use WebGUI::Help::MessageBoard ();
use WebGUI::Help::Poll ();
use WebGUI::Help::Product ();
use WebGUI::Help::SiteMap ();
use WebGUI::Help::SQLReport ();
use WebGUI::Help::Survey ();
use WebGUI::Help::SyndicatedContent ();
use WebGUI::Help::USS ();
use WebGUI::Help::WebGUI ();
use WebGUI::Help::WobjectProxy ();
use WebGUI::Help::WSClient ();

# i18n
use WebGUI::i18n::English ();
use WebGUI::i18n::English::Article ();
use WebGUI::i18n::English::AuthLDAP ();
use WebGUI::i18n::English::AuthSMB ();
use WebGUI::i18n::English::AuthWebGUI ();
use WebGUI::i18n::English::DataForm ();
use WebGUI::i18n::English::EventsCalendar ();
use WebGUI::i18n::English::FileManager ();
use WebGUI::i18n::English::HttpProxy ();
use WebGUI::i18n::English::IndexedSearch ();
use WebGUI::i18n::English::MessageBoard ();
use WebGUI::i18n::English::Navigation ();
use WebGUI::i18n::English::Poll ();
use WebGUI::i18n::English::Product ();
use WebGUI::i18n::English::SiteMap ();
use WebGUI::i18n::English::SQLReport ();
use WebGUI::i18n::English::Survey ();
use WebGUI::i18n::English::SyndicatedContent ();
use WebGUI::i18n::English::USS ();
use WebGUI::i18n::English::WebGUI ();
use WebGUI::i18n::English::WebGUIProfile ();
use WebGUI::i18n::English::WobjectProxy ();
use WebGUI::i18n::English::WSClient ();

# operations
use WebGUI::Operation::Auth ();
use WebGUI::Operation::Admin ();
use WebGUI::Operation::Clipboard ();
use WebGUI::Operation::Collateral ();
use WebGUI::Operation::DatabaseLink ();
use WebGUI::Operation::Group ();
use WebGUI::Operation::Help ();
use WebGUI::Operation::MessageLog ();
use WebGUI::Operation::Navigation ();
use WebGUI::Operation::Package ();
use WebGUI::Operation::Page ();
use WebGUI::Operation::Profile ();
use WebGUI::Operation::ProfileSettings ();
use WebGUI::Operation::Replacements ();
use WebGUI::Operation::Root ();
use WebGUI::Operation::Scratch ();
use WebGUI::Operation::Settings ();
use WebGUI::Operation::Shared ();
use WebGUI::Operation::Statistics ();
use WebGUI::Operation::Style ();
use WebGUI::Operation::Template ();
use WebGUI::Operation::Theme ();
use WebGUI::Operation::Trash ();
use WebGUI::Operation::User ();
use WebGUI::Operation::WebGUI ();

# you can significantly reduce your memory usage by preloading the plugins used on your sites, only the most commonly used ones are preloaded by default

# wobjects
use WebGUI::Wobject::Article ();
use WebGUI::Wobject::USS ();

# auth methods
use WebGUI::Auth::WebGUI ();

#use WebGUI::Auth::LDAP ();
#use Net::LDAP ();  # used by ldap authentication

#use WebGUI::Auth::SMB ();
#use Authen::Smb (); #uncomment when using this type of authentication.

# macros
use WebGUI::Macro::AdminBar ();
use WebGUI::Macro::Navigation ();

print "[  OK  ]\n";


1;


