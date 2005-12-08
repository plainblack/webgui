#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use lib "../../lib";
use strict;
use Getopt::Long;
use WebGUI::Session;
use File::Path;
use WebGUI::SQL;
use WebGUI::Asset;

my $toVersion = "6.8.1"; # make this match what version you're going to
my $quiet; # this line required


start(); # this line required

upgradeRichEditor();
fixCSFaqTemplateAnchors();
updateProfileSystem();
convertDashboardPrefs();
fixPosts();
fixIOB();

finish(); # this line required


#-------------------------------------------------
sub fixIOB  {
	print "\tFixing IOB.\n" unless ($quiet);
	WebGUI::SQL->write("alter table InOutBoard_statusLog add column createdBy varchar(22) binary");
}

#-------------------------------------------------
sub fixPosts {
	print "\tFixing posts.\n" unless ($quiet);
	WebGUI::SQL->write("update Post set dateUpdated=".time()." where dateUpdated=0");
}

#-------------------------------------------------
sub updateProfileSystem {
	print "\tUpdating user profile system.\n" unless ($quiet);
	WebGUI::SQL->write("alter table userProfileField change fieldLabel label varchar(255) not null default 'Undefined'");
	WebGUI::SQL->write("alter table userProfileField change dataType fieldType varchar(128) not null default 'text'");
	WebGUI::SQL->write("alter table userProfileField change dataValues possibleValues text");
	WebGUI::SQL->write("alter table userProfileCategory change categoryName label varchar(255) not null default 'Undefined'");
	WebGUI::SQL->write("alter table userProfileCategory add column protected int not null default 0");
	WebGUI::SQL->write("update userProfileCategory set protected=1 where profileCategoryId in ('1','2','3','4','5','6','7')");
}

#-------------------------------------------------
sub upgradeRichEditor {
	print "\tUpgrade rich editor\n" unless ($quiet);
	rmtree("../../www/extras/tinymce");
}

#-------------------------------------------------
sub convertDashboardPrefs {
	print "\tConverting Dashboard preferences\n" unless ($quiet);
	#purge all Fields.
	my $a = WebGUI::SQL->read("select assetId from asset where className='WebGUI::Asset::Field'");
	while (my ($assetId) = $a->array) {
		WebGUI::SQL->write("delete from asset where assetId=.quote($assetId)");
		WebGUI::SQL->write("delete from assetData where assetId=.quote($assetId)");
	}
	unlink("../../lib/WebGUI/Asset/Field.pm");
	WebGUI::SQL->write("DROP TABLE `wgField`");
	WebGUI::SQL->write("ALTER TABLE `Dashboard` DROP COLUMN mapFieldId");
	WebGUI::SQL->write("ALTER TABLE `Dashboard` ADD COLUMN `isInitialized` TINYINT UNSIGNED NOT NULL DEFAULT 0");
	WebGUI::SQL->write("ALTER TABLE `Dashboard` ADD COLUMN `assetsToHide` TEXT");
	WebGUI::SQL->write("ALTER TABLE `Shortcut` ADD COLUMN `prefFieldsToShow` TEXT");
	WebGUI::SQL->write("ALTER TABLE `Shortcut` ADD COLUMN `prefFieldsToImport` TEXT");
	WebGUI::SQL->write("ALTER TABLE `Shortcut` ADD COLUMN `showReloadIcon` TINYINT UNSIGNED NOT NULL DEFAULT 0");
	my $asset = WebGUI::Asset->new("DashboardViewTmpl00001","WebGUI::Asset::Template");
	if (defined $asset) {  ##Can't update what doesn't exist
		my $template = <<STOP;

<style type="text/css"> \@import "^Extras;wobject/Dashboard/draggable.css"; </style>
<style type="text/css"> \@import "^Extras;wobject/Dashboard/dashboard.css"; </style>
<script src="^Extras;wobject/Dashboard/draggable.js" type="text/javascript"></script>
<!--[if IE]>
<style type="text/css">
div.dragTitle
{
	overflow-x:hidden;
}
</style>
<![endif]-->

<div id="dashboardContainer">
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>">
</a>
<table id="dashboardChooserContainer" width="100%" border="0">
<tr>
<td id="leftBox">
<div style="display:none;cursor: hand;" id="hideNewContentButton" onclick="makeInactive(this);makeInactive(document.getElementById('availableBox'));makeActive(document.getElementById('showNewContentButton'));">Hide New Content List</div>
<div id="availableBox"><div id="availableBox2">
<div id="availableDashlets">
<table cellpadding="0" cellspacing="0" border="0" id="position1" class="dashboardColumn">
<tbody class="availableDashlet">
<tmpl_loop position1_loop><tr id="td<tmpl_var id>"><td><div id="td<tmpl_var id>_div" class="dragable"><div class="dragTrigger"><div class="dragTitle"><span class="headerTitle" id="hdrtd<tmpl_var id>_span"><tmpl_var dashletTitle></span></span><span class="options" onmouseover="this.className='options optionsHoverIE'" onmouseout="this.className='options'"><tmpl_if canEditUserPrefs><a onclick="dashboard_toggleEditForm(event,'<tmpl_var id>','<tmpl_var shortcutUrl>')"><img src="^Extras;wobject/Dashboard/edit_btn.jpg" border="0"></a></tmpl_if><a onclick="dragable_deleteContent(event,this<tmpl_if canPersonalize>,'true'</tmpl_if>);this.parentNode.onmouseout();"><img src="^Extras;wobject/Dashboard/delete_btn.jpg" border="0"></a><tmpl_if showReloadIcon><a onclick="dashboard_reloadDashlet(event,'<tmpl_var id>','<tmpl_var shortcutUrl>')"><img src="^Extras;wobject/Dashboard/reload.gif" border="0"></a></tmpl_if><br /></span></div></div>
<div class="content" id="ct<tmpl_var id>_div"><tmpl_var content></div></div></td></tr></tmpl_loop>
</tbody></table>
</div></div></div>
</td>
<td id="rightBox">
<table cellpadding="0" cellspacing="0" border="0" width="100%">
<tr><td style="width:80px;">			<div id="showNewContentButton"  onclick="makeInactive(this);makeActive(document.getElementById('availableBox'));makeActive(document.getElementById('hideNewContentButton'));">Add New Content</div></td><td>
<tmpl_if showAdmin>
<p>
<tmpl_var controls>
</p>
</tmpl_if>

<tmpl_if displayTitle>
<h1 style="text-align:center">
<tmpl_var title>
</h1>
</tmpl_if>



<tmpl_if description>
<p>
<tmpl_var description>
</p>
</tmpl_if>
</td><td valign="top" class="login">^L("17","","PBtmpl0000000000000092"); ^AdminToggle(Modify the Default User's Perspective,Leave Default User Perspective (Admin Mode));</td></tr></table>
<script type="text/javascript" src="^Extras;js/at/AjaxRequest.js"></script>
<script type="text/javascript">
function submitForm(theform,idToReplace,shortcutUrl) {

var status = AjaxRequest.submit(
theform
,{
'parameters':{
},
'onSuccess':function(req){
var myArray = req.responseText.split(/beginDebug/mg,1);
document.getElementById("ct" + idToReplace + "_div").innerHTML = myArray[0];
var existingForm = document.getElementById("form" + idToReplace + "_div");
throwAway = existingForm.parentNode.removeChild(existingForm);
var hoopla = AjaxRequest.get(
		{
			'url':shortcutUrl
			,'parameters':{
				'func':"getNewTitle"
			}
			,'onSuccess':function(req){
				var myArr557 = req.responseText.split(/beginDebug/mg,1);
				document.getElementById("hdrtd" + idToReplace + "_span").innerHTML = myArr557[0];
			}
		}
	);
	}
	}
);
return status;
	}
function makeActive(o) { o.style.display = "inline"; }
function makeInactive(o) { o.style.display = "none"; }
function AjaxRequestBegin() {  }
function AjaxRequestEnd() {  }
</script>
<div id="columnsContainerDiv">
<table cellpadding="0" cellspacing="8" border="0" id="columnsContainerTable" width="100%">
<tr>
<td width="33%">
<table cellpadding="0" cellspacing="0" border="0" id="position2" class="dashboardColumn" width="100%">
<tbody>
<tmpl_loop position2_loop><tr id="td<tmpl_var id>"><td><div id="td<tmpl_var id>_div" class="dragable"><div class="dragTrigger"><div class="dragTitle"><span class="headerTitle" id="hdrtd<tmpl_var id>_span"><tmpl_var dashletTitle></span></span><span class="options" onmouseover="this.className='options optionsHoverIE'" onmouseout="this.className='options'"><tmpl_if canEditUserPrefs><a onclick="dashboard_toggleEditForm(event,'<tmpl_var id>','<tmpl_var shortcutUrl>')"><img src="^Extras;wobject/Dashboard/edit_btn.jpg" border="0"></a></tmpl_if><a onclick="dragable_deleteContent(event,this<tmpl_if canPersonalize>,'true'</tmpl_if>);this.parentNode.onmouseout();"><img src="^Extras;wobject/Dashboard/delete_btn.jpg" border="0"></a><tmpl_if showReloadIcon><a onclick="dashboard_reloadDashlet(event,'<tmpl_var id>','<tmpl_var shortcutUrl>')"><img src="^Extras;wobject/Dashboard/reload.gif" border="0"></a></tmpl_if><br /></span></div></div>
<div class="content" id="ct<tmpl_var id>_div"><tmpl_var content></div></div></td></tr></tmpl_loop>
</tbody>
</table>
</td>
<td width="2px" bgcolor="gray" height="500px">
</td>
<td width="33%">
<table cellpadding="0" cellspacing="0" border="0" id="position3" class="dashboardColumn" width="100%">
<tbody>
<tmpl_loop position3_loop><tr id="td<tmpl_var id>"><td><div id="td<tmpl_var id>_div" class="dragable"><div class="dragTrigger"><div class="dragTitle"><span class="headerTitle"><span class="headerTitle" id="hdrtd<tmpl_var id>_span"><tmpl_var dashletTitle></span></span><span class="options" onmouseover="this.className='options optionsHoverIE'" onmouseout="this.className='options'"><tmpl_if canEditUserPrefs><a onclick="dashboard_toggleEditForm(event,'<tmpl_var id>','<tmpl_var shortcutUrl>')"><img src="^Extras;wobject/Dashboard/edit_btn.jpg" border="0"></a></tmpl_if><a onclick="dragable_deleteContent(event,this<tmpl_if canPersonalize>,'true'</tmpl_if>);this.parentNode.onmouseout();"><img src="^Extras;wobject/Dashboard/delete_btn.jpg" border="0"></a><tmpl_if showReloadIcon><a onclick="dashboard_reloadDashlet(event,'<tmpl_var id>','<tmpl_var shortcutUrl>')"><img src="^Extras;wobject/Dashboard/reload.gif" border="0"></a></tmpl_if><br /></span></div></div>
<div class="content" id="ct<tmpl_var id>_div"><tmpl_var content></div></div></td></tr></tmpl_loop>
</tbody>
</table>
</td>
<td width="2px" bgcolor="gray" height="500px"></td>
<td width="33%">
<table cellpadding="0" cellspacing="0" border="0" id="position4" class="dashboardColumn" width="100%">
<tbody>
<tmpl_loop position4_loop><tr id="td<tmpl_var id>"><td><div id="td<tmpl_var id>_div" class="dragable"><div class="dragTrigger"><div class="dragTitle"><span class="headerTitle"><span class="headerTitle" id="hdrtd<tmpl_var id>_span"><tmpl_var dashletTitle></span></span><span class="options" onmouseover="this.className='options optionsHoverIE'" onmouseout="this.className='options'"><tmpl_if canEditUserPrefs><a onclick="dashboard_toggleEditForm(event,'<tmpl_var id>','<tmpl_var shortcutUrl>')"><img src="^Extras;wobject/Dashboard/edit_btn.jpg" border="0"></a></tmpl_if><a onclick="dragable_deleteContent(event,this<tmpl_if canPersonalize>,'true'</tmpl_if>);this.parentNode.onmouseout();"><img src="^Extras;wobject/Dashboard/delete_btn.jpg" border="0"></a><tmpl_if showReloadIcon><a onclick="dashboard_reloadDashlet(event,'<tmpl_var id>','<tmpl_var shortcutUrl>')"><img src="^Extras;wobject/Dashboard/reload.gif" border="0"></a></tmpl_if><br /></span></div></div>
<div class="content" id="ct<tmpl_var id>_div"><tmpl_var content></div></div></td></tr></tmpl_loop>
</tbody>
</table>
</td>
</tr>
</table>
</div>
<table class="blankTable"><tr id="blank" class="hidden"><td class="blankColumn"><div><div class="empty">&nbsp;</div></div></td></tr></table>
<tmpl_var dragger.init>
</td></tr></table></div>
STOP
		$asset->addRevision({template=>$template})->commit;
	}
}

#-------------------------------------------------
sub fixCSFaqTemplateAnchors {
	print "\tFix Anchors in the CS FAQ Template\n" unless ($quiet);
	my $asset = WebGUI::Asset->new("PBtmpl0000000000000080","WebGUI::Asset::Template");
	if (defined $asset) {  ##Can't update what doesn't exist
		my $template = $asset->get("template");
		$template =~ s/(<a href="#)(<tmpl_var assetId>)/${1}id${2}/;
		$asset->addRevision({template=>$template})->commit;
	}
}


# ---- DO NOT EDIT BELOW THIS LINE ----

#-------------------------------------------------
sub start {
	my $configFile;
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

