#!/usr/bin/perl
use Test::More tests => 355;
use Test::WWW::Selenium;
use Test::WWW::Selenium::HTML;
use WebGUI::Paths -inc;
use WebGUI::Config;
use strict;

WebGUI::Paths->siteConfigs or die "no configuration files found";

my $config             = undef;
my $webguiSiteUrl      = undef;
my $browser            = undef;
my $seleniumServer     = undef;
my $seleniumServerPort = undef;
if ( my $config_file = $ENV{WEBGUI_CONFIG} ){
   my $webguiTestConfigFilename = WebGUI::Paths->configBase . '/' . $config_file;
   $config = WebGUI::Config->new( $webguiTestConfigFilename ) or die "failed to load configuration file: $webguiTestConfigFilename: $!";
   
   eval{
      $webguiSiteUrl      = $config->{config}->{selenium}->{webgui_url};
      $browser            = $config->{config}->{selenium}->{browser}; # firefox, iexplore, safari
      $seleniumServer     = $config->{config}->{selenium}->{server};
      $seleniumServerPort = $config->{config}->{selenium}->{port};
      
   } || die "Can't get Selenium configuration values from configuration file: $webguiTestConfigFilename\n";   

}else{
   die "Please read the instructions, you must specify a PERL5LIB and WEBGUI_CONFIG file value!\n";
   
}

# 
my $sel = Test::WWW::Selenium->new(
   host        => $seleniumServer,
   port        => $seleniumServerPort,
   browser     => "*$browser",
   browser_url => $webguiSiteUrl );

my $selh = Test::WWW::Selenium::HTML->new( $sel );

$selh->diag_body_text_on_failure(0);

#------------------------- Run All Tests here -----------------------
if ( $ARGV[0] eq 'install' ){
   ok(1, "Setup initial WebGUI test site.");
   $selh->run(path => "webguiInitialSetup.html");
   
}else{
   ok(1, "Login test");
   $selh->run(path => "login.html");
   
}

# Test basic interface links
ok(1, "Turn On Admin test");
$selh->run(path => "turnOnAdmin.html");
ok(1, "Admin Console tests");
$selh->run(path => "adminConsole.html");
ok(1, "Version Tags tests");
$selh->run(path => "versionTags.html");
ok(1, "Clipboard test");
$selh->run(path => "clipboard.html");
ok(1, "Asset Helpers tests");
$selh->run(path => "assetHelpers.html");
ok(1, "New Content->Basic tests");
$selh->run(path => "newContentBasic.html");
ok(1, "New Content->Community tests");
$selh->run(path => "newContentCommunity.html");
ok(1, "New Content->Intranet tests");
$selh->run(path => "newContentIntranet.html");
ok(1, "New Content->Prototypes tests");
$selh->run(path => "newContentPrototypes.html");
ok(1, "New Content->Shop tests");
$selh->run(path => "newContentShop.html");
ok(1, "New Content->Utilities tests");
$selh->run(path => "newContentUtilities.html");

# Frameless admin functions
ok(1, "FRAMELESS->Active Sessions");
$selh->run(path => "frameless/activeSessions.html");
ok(1, "FRAMELESS->Addons");
$selh->run(path => "frameless/addons.html");
ok(1, "FRAMELESS->Advertising");
$selh->run(path => "frameless/advertising.html");
ok(1, "FRAMELESS->Asset History");
$selh->run(path => "frameless/assetHistory.html");
ok(1, "FRAMELESS->Cache");
$selh->run(path => "frameless/cache.html");
ok(1, "FRAMELESS->Clipboard");
$selh->run(path => "frameless/clipboard.html");
ok(1, "FRAMELESS->Content Filters");
$selh->run(path => "frameless/contentFilters.html");
ok(1, "FRAMELESS->Content Profiling");
$selh->run(path => "frameless/contentProfiling.html");
ok(1, "FRAMELESS->Databases");
$selh->run(path => "frameless/databases.html");
ok(1, "FRAMELESS->File Pump");
$selh->run(path => "frameless/filePump.html");
ok(1, "FRAMELESS->Graphics");
$selh->run(path => "frameless/graphics.html");
ok(1, "FRAMELESS->Groups");
$selh->run(path => "frameless/groups.html");
ok(1, "FRAMELESS->Inbox");
$selh->run(path => "frameless/inbox.html");
ok(1, "FRAMELESS->LDAP Connections");
$selh->run(path => "frameless/ldapLinks.html");
ok(1, "FRAMELESS->Login History");
$selh->run(path => "frameless/loginHistory.html");
ok(1, "FRAMELESS->Passive Analytics");
$selh->run(path => "frameless/passiveAnalytics.html");
ok(1, "FRAMELESS->Scheduler");
$selh->run(path => "frameless/scheduler.html");
ok(1, "FRAMELESS->Settings");
$selh->run(path => "frameless/settings.html");
ok(1, "FRAMELESS->Shop");
$selh->run(path => "frameless/shop.html");
ok(1, "FRAMELESS->Spectre");
$selh->run(path => "frameless/spectre.html");
ok(1, "FRAMELESS->Template Help");
$selh->run(path => "frameless/templateHelp.html");
ok(1, "FRAMELESS->Trash");
$selh->run(path => "frameless/trash.html");
ok(1, "FRAMELESS->User Profiling");
$selh->run(path => "frameless/userProfiling.html");
ok(1, "FRAMELESS->Users");
$selh->run(path => "frameless/users.html");
ok(1, "FRAMELESS->Version Tags");
$selh->run(path => "frameless/versionTags.html");
ok(1, "FRAMELESS->Workflow");
$selh->run(path => "frameless/workflow.html");
