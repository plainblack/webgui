use lib "../../lib";
use strict;
use Getopt::Long;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Asset;

my $toVersion = "6.7.2";
my $configFile;
my $quiet;

start();

fixTimeFields();
fixSpelling();
fixCSTemplate();
speedUpAdminConsole();
removeOldFiles();

finish();

#-------------------------------------------------
sub removeOldFiles {
        print "\tRemoving files that are no longer needed.\n" unless ($quiet);
	unlink("../../lib/WebGUI/Search.pm");
}

#-------------------------------------------------
sub speedUpAdminConsole {
        print "\tMaking admin console load faster.\n" unless ($quiet);
	my $template = <<END;
^StyleSheet(^Extras;/adminConsole/adminConsole.css);
^JavaScript(^Extras;/adminConsole/adminConsole.js);

<div id="application_title">
       <tmpl_var application.title>
</div>
<div id="console_title">
       <tmpl_var console.title>
</div>
<div id="application_workarea">
       <tmpl_var application.workArea>
</div>
<div id="console_workarea">
        <div class="adminConsoleSpacer">
            &nbsp;
        </div>
        <tmpl_loop application_loop>
                <tmpl_if canUse>
                     <div class="adminConsoleApplication">
                           <a href="<tmpl_var url>"><img src="<tmpl_var icon>" border="0" title="<tmpl_var title>" alt="<tmpl_var title>" /></a><br />
                           <a href="<tmpl_var url>"><tmpl_var title></a>
                     </div>
               </tmpl_if>
       </tmpl_loop>
        <div class="adminConsoleSpacer">
            &nbsp;
        </div>
</div>
<div class="adminConsoleMenu">
        <div id="adminConsoleMainMenu" class="adminConsoleMainMenu">
                <div id="console_toggle_on">
                        <a href="#" onClick="toggleAdminConsole()"><tmpl_var toggle.on.label></a><br />
                </div>
                <div id="console_toggle_off">
                        <a href="#" onClick="toggleAdminConsole()"><tmpl_var toggle.off.label></a><br />
                </div>
        </div>
        <div id="adminConsoleApplicationSubmenu"  class="adminConsoleApplicationSubmenu">
              <tmpl_loop submenu_loop>
                        <a href="<tmpl_var url>" <tmpl_var extras>><tmpl_var label></a><br />
              </tmpl_loop>
        </div>
        <div id="adminConsoleUtilityMenu" class="adminConsoleUtilityMenu">
                <a href="<tmpl_var backtosite.url>"><tmpl_var backtosite.label></a><br />
                ^AdminToggle;<br />
                ^LoginToggle;<br />
        </div>
</div>
<div id="application_help">
  <tmpl_if help.url>
    <a href="<tmpl_var help.url>" target="_blank"><img src="^Extras;/adminConsole/small/help.gif" alt="?" border="0" /></a>
  </tmpl_if>
</div>
<div id="application_icon">
    <img src="<tmpl_var application.icon>" border="0" title="<tmpl_var application.title>" alt="<tmpl_var application.title>" />
</div>
<div class="adminConsoleTitleIconMedalian">
<img src="^Extras;/adminConsole/medalian.gif" border="0" alt="*" />
</div>
<div id="console_icon">
     <img src="<tmpl_var console.icon>" border="0" title="<tmpl_var console.title>" alt="<tmpl_var console.title>" />
</div>
<script lang="JavaScript">
  initAdminConsole(<tmpl_if application.title>true<tmpl_else>false</tmpl_if>,<tmpl_if submenu_loop>true<tmpl_else>false</tmpl_if>);
</script>

END
	my $asset = WebGUI::Asset->new("PBtmpl0000000000000001","WebGUI::Asset::Template");
	$asset->addRevision({template=>$template})->commit;
}


#-------------------------------------------------
sub fixTimeFields {
        print "\tFixing time fields.\n" unless ($quiet);
	WebGUI::SQL->write("update DataForm_field set type=".quote('TimeField')." where type=".quote('time'));
	WebGUI::SQL->write("update userProfileField set dataType=".quote('TimeField')." where dataType=".quote('time'));
}

#-------------------------------------------------
sub fixCSTemplate {
        print "\tFixing CS Search template.\n" unless ($quiet);
	my $asset = WebGUI::Asset->new("PBtmpl0000000000000031","WebGUI::Asset::Template");
	my $template = $asset->get("template");
	$template =~ s/<tmpl_var date>/<tmpl_var dateSubmitted.human>/ixsg;
	$template =~ s/<tmpl_var time>/<tmpl_var timeSubmitted.human>/ixsg;
	$asset->addRevision({template=>$template})->commit;
}


#-------------------------------------------------
sub fixSpelling {
        print "\tFixing a few spelling problems.\n" unless ($quiet);
	my $asset = WebGUI::Asset->new("PBtmplCP00000000000001","WebGUI::Asset::Template");
	$asset->addRevision({url=>"default_product_template"})->commit;
	$asset = WebGUI::Asset->new("PBtmpl0000000000000134","WebGUI::Asset::Template");
	my $template = $asset->get("template");
	$template =~ s/spesify/specify/ixsg;
	$asset->addRevision({template=>$template})->commit;
}

#-------------------------------------------------
sub start {
	$|=1; #disable output buffering
	GetOptions(
    		'configFile=s'=>\$configFile,
        	'quiet'=>\$quiet
	);
	WebGUI::Session::open("../..",$configFile);
	WebGUI::Session::refreshUserInfo(3);
	WebGUI::SQL->write("insert into webguiVersion values (".quote($toVersion).",'upgrade',".time().")");
}

#-------------------------------------------------
sub finish {
	WebGUI::Session::close();
}

