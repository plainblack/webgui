#!/usr/bin/perl

my $webguiRoot;

BEGIN {
        $webguiRoot = "/data/WebGUI";
        unshift (@INC, $webguiRoot."/lib");
}

$|=1;

use strict;
print "\nStarting WebGUI ".$WebGUI::VERSION."\n";

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
use Digest::MD5 ();
use Image::Magick ();
use File::Copy ();
use File::Path ();
use FileHandle ();
use Net::SMTP ();
use POSIX ();
use URI::Escape ();
use SOAP::Lite ();
use Time::HiRes ();


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
use Date::Manip ();
use Tie::CPHash ();
use Tie::IxHash ();
# use XML::RSSLite ();
use XML::Simple ();

#----------------------------------------
# WebGUI modules.
#----------------------------------------

# core
use WebGUI ();
use WebGUI::Affiliate ();
use WebGUI::Asset ();
use WebGUI::Auth ();
use WebGUI::Cache ();
use WebGUI::Config ();
use WebGUI::DatabaseLink ();
use WebGUI::DateTime ();
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
use WebGUI::Operation ();
use WebGUI::Paginator ();
use WebGUI::Privilege ();
use WebGUI::Search ();
use WebGUI::Session ();
use WebGUI::SQL ();
use WebGUI::Storage ();
use WebGUI::Style ();
use WebGUI::TabForm ();
use WebGUI::URL ();
use WebGUI::User ();
use WebGUI::Utility ();

# help
#use WebGUI::Help::Article ();
#use WebGUI::Help::Asset ();
#use WebGUI::Help::AuthLDAP ();
#use WebGUI::Help::AuthWebGUI ();
#use WebGUI::Help::DataForm ();
#use WebGUI::Help::EventsCalendar ();
#use WebGUI::Help::HttpProxy ();
#use WebGUI::Help::IndexedSearch ();
#use WebGUI::Help::MessageBoard ();
#use WebGUI::Help::Poll ();
#use WebGUI::Help::Product ();
#use WebGUI::Help::SQLReport ();
#use WebGUI::Help::Survey ();
#use WebGUI::Help::SyndicatedContent ();
#use WebGUI::Help::Collaboration ();
#use WebGUI::Help::WebGUI ();
#use WebGUI::Help::Shortcut ();
#use WebGUI::Help::WSClient ();

# i18n
use WebGUI::i18n::English ();
use WebGUI::i18n::English::Article ();
use WebGUI::i18n::English::Collaboration ();
use WebGUI::i18n::English::Asset ();
#use WebGUI::i18n::English::AuthLDAP ();
use WebGUI::i18n::English::AuthWebGUI ();
use WebGUI::i18n::English::Navigation ();
use WebGUI::i18n::English::WebGUI ();
use WebGUI::i18n::English::WebGUIProfile ();

# you can significantly reduce your memory usage by preloading the plugins used on your sites, only the most commonly used ones are preloaded by default

# assets 
use WebGUI::Asset::File ();
use WebGUI::Asset::File::Image ();
use WebGUI::Asset::Snippet ();
use WebGUI::Asset::Template ();
use WebGUI::Asset::Wobject ();
use WebGUI::Asset::Wobject::Article ();
use WebGUI::Asset::Wobject::Layout ();
use WebGUI::Asset::Wobject::Navigation ();
use WebGUI::Asset::Wobject::Collaboration ();

# auth methods
use WebGUI::Auth::WebGUI ();

#use Net::LDAP ();  # used by ldap authentication
use WebGUI::Auth::LDAP ();

# macros
use WebGUI::Macro::AdminBar ();
use WebGUI::Macro::AssetProxy ();
use WebGUI::Macro::Extras ();
use WebGUI::Macro::FileUrl ();
use WebGUI::Macro::JavaScript ();
use WebGUI::Macro::PageUrl ();
use WebGUI::Macro::Slash_gatewayUrl ();
use WebGUI::Macro::Spacer ();
use WebGUI::Macro::StyleSheet ();



#----------------------------------------
# Preload all site configs.
#----------------------------------------
WebGUI::Config::loadAllConfigs($webguiRoot);



print "WebGUI Started!\n";


1;


