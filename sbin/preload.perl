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



use CGI (); CGI->compile(':all');
use CGI::Carp ();
use CGI::Util ();
use File::Copy ();
use File::Path ();
use FileHandle ();
use POSIX ();
use URI::Escape ();
use HTTP::Request ();
use HTTP::Headers ();
use Digest::MD5 ();
use DBI ();
use HTML::Parser ();
use HTML::TagFilter ();
use HTML::Template ();
use Parse::PlainConfig ();
use Net::SMTP ();
use Log::Log4perl ();
use Tie::IxHash ();
use Tie::CPHash ();
use Time::HiRes ();
use DateTime ();
use DateTime::Format::Strptime ();
use DateTime::TimeZone ();
use Image::Magick ();
use Storable;
use XML::Simple ();
use Compress::Zlib (); 
use Archive::Tar ();
use IO::Zlib ();

####
# less commonly used so you may not want them to load into memory
###
#use SOAP::Lite (); # used only by WS Client
#use Net::LDAP (); # used only by LDAP authentication module
#use XML::RSSLite (); # used only by syndicated content wobject
#use HTML::Highlight (); # used only by search engine



#----------------------------------------
# Database connectivity.
#----------------------------------------
#use Apache::DBI (); # Uncomment if you want to enable connection pooling. Not recommended on low memory systems, or systems using database slaves
DBI->install_driver("mysql"); # Change to match your database driver.



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
use WebGUI::Session ();
use WebGUI::Setting ();
use WebGUI::SQL ();
use WebGUI::Storage ();
use WebGUI::Style ();
use WebGUI::TabForm ();
use WebGUI::URL ();
use WebGUI::User ();
use WebGUI::Utility ();

# help
#use WebGUI::Help::Asset_Article ();
#use WebGUI::Help::Asset ();
#use WebGUI::Help::Asset_DataForm ();
#use WebGUI::Help::Asset_EventsCalendar ();
#use WebGUI::Help::Asset_HttpProxy ();
#use WebGUI::Help::Asset_IndexedSearch ();
#use WebGUI::Help::Asset_MessageBoard ();
#use WebGUI::Help::Asset_Poll ();
#use WebGUI::Help::Asset_Product ();
#use WebGUI::Help::Asset_SQLReport ();
#use WebGUI::Help::Asset_Survey ();
#use WebGUI::Help::Asset_SyndicatedContent ();
#use WebGUI::Help::Asset_Collaboration ();
#use WebGUI::Help::Asset_Shortcut ();
#use WebGUI::Help::Asset_WSClient ();
#use WebGUI::Help::AuthLDAP ();
#use WebGUI::Help::AuthWebGUI ();
#use WebGUI::Help::WebGUI ();

# i18n
use WebGUI::i18n::English ();
use WebGUI::i18n::English::Asset ();
use WebGUI::i18n::English::Asset_Article ();
use WebGUI::i18n::English::Asset_Collaboration ();
use WebGUI::i18n::English::Asset_Navigation ();
#use WebGUI::i18n::English::AuthLDAP ();
use WebGUI::i18n::English::AuthWebGUI ();
use WebGUI::i18n::English::WebGUI ();
use WebGUI::i18n::English::DateTime ();
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
#use WebGUI::Auth::LDAP ();

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


