use lib "../../lib";
use strict;
use Getopt::Long;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Asset;
use WebGUI::Setting;

my $toVersion = "6.7.5";
my $configFile;
my $quiet;

start();

fixSurveyAnswerDefinition();
fixTemplates();
fixArticles();
sleep(1); # have to wait a second to add these revisions because you can't have two revisions of the same thing in the same second
fixTemplatesExtras();

finish();


#-------------------------------------------------
sub fixSurveyAnswerDefinition {
        print "\tFixing definition of survey answers.\n" unless ($quiet);
	WebGUI::SQL->write("alter table Survey_answer change gotoQuestion gotoQuestion varchar(22) binary");
}

#-------------------------------------------------
sub fixTemplates {
	print "\tFixing templates...\n" unless ($quiet);

	# AdminConsole > Admin Console
	my $template = <<END;
^StyleSheet(^Extras;adminConsole/adminConsole.css);
^JavaScript(^Extras;adminConsole/adminConsole.js);

<div id="application_title">
	<tmpl_var application.title>
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
			<a href="#" onclick="toggleAdminConsole()"><tmpl_var toggle.on.label></a><br />
		</div>
		<div id="console_toggle_off">
			<a href="#" onclick="toggleAdminConsole()"><tmpl_var toggle.off.label></a><br />
		</div>
	</div>
	<div id="adminConsoleApplicationSubmenu" class="adminConsoleApplicationSubmenu">
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
<div id="console_title">
	<tmpl_var console.title>
</div>
<div id="application_help">
	<tmpl_if help.url>
		<a href="<tmpl_var help.url>" target="_blank"><img src="^Extras;adminConsole/small/help.gif" alt="?" border="0" /></a>
	</tmpl_if>
</div>
<div id="application_icon">
	<img src="<tmpl_var application.icon>" border="0" title="<tmpl_var application.title>" alt="<tmpl_var application.title>" />
</div>
<div class="adminConsoleTitleIconMedalian">
<img src="^Extras;adminConsole/medalian.gif" border="0" alt="*" />
</div>
<div id="console_icon">
	<img src="<tmpl_var console.icon>" border="0" title="<tmpl_var console.title>" alt="<tmpl_var console.title>" />
</div>
<script type="text/javascript">
	initAdminConsole(<tmpl_if application.title>true<tmpl_else>false</tmpl_if>,<tmpl_if submenu_loop>true<tmpl_else>false</tmpl_if>);
</script>
END
	WebGUI::Asset->new("PBtmpl0000000000000001","WebGUI::Asset::Template")->addRevision({template=>$template})->commit;

	# Article > Default Article
	my $template = <<END;
<a name="<tmpl_var assetId>"></a>
<tmpl_if session.var.adminOn>
	<p><tmpl_var controls></p>
</tmpl_if>	
<tmpl_if displayTitle>
	<h1><tmpl_var title></h1>
</tmpl_if>

<tmpl_if pagination.isFirstPage>
<tmpl_if image.url>
	<table width="100%" border="0" cellpadding="0" cellspacing="0"><tr><td class="content">
	<img src="<tmpl_var image.url>" align="right" border="0" alt="<tmpl_var image.url>" />
</tmpl_if>
</tmpl_if>

<tmpl_if description>
	<tmpl_var description>
</tmpl_if>

<tmpl_if pagination.isLastPage>
	<tmpl_if linkUrl>
	<tmpl_if linkTitle>
		<p />
		<a href="<tmpl_var linkUrl>"><tmpl_var linkTitle></a>
	</tmpl_if>
	</tmpl_if>
	<tmpl_var attachment.box>
</tmpl_if>

<tmpl_if pagination.pageCount.isMultiple>
<tmpl_var pagination.previousPage>
&middot;
<tmpl_var pagination.pageList.upTo20>
&middot;
<tmpl_var pagination.nextPage>
</tmpl_if>

<tmpl_if pagination.isFirstPage>
<tmpl_if image.url>
	</td></tr></table>
</tmpl_if>
</tmpl_if>

<tmpl_if pagination.isLastPage>
<tmpl_if allowDiscussion>
	<p>
	<table width="100%" cellspacing="2" cellpadding="1" border="0">
	<tr>
	<td align="center" width="50%" class="tableMenu"><a href="<tmpl_var replies.URL>"><tmpl_var replies.label> (<tmpl_var replies.count>)</a></td>
	<td align="center" width="50%" class="tableMenu"><a href="<tmpl_var post.url>"><tmpl_var post.label></a></td>
	</tr>
	</table>
</tmpl_if>
</tmpl_if>
END
	WebGUI::Asset->new("PBtmpl0000000000000002","WebGUI::Asset::Template")->addRevision({template=>$template})->commit;

	# Layout > Default Page
	my $template = <<END;
<a name="<tmpl_var assetId>"></a>

<tmpl_if showAdmin>
	<p><tmpl_var controls></p>
</tmpl_if>

<tmpl_if displayTitle>
	<h1><tmpl_var title></h1>
</tmpl_if>

<tmpl_if description>
	<p><tmpl_var description></p>
</tmpl_if>

<div class="layoutColumnPadding">
<tmpl_if showAdmin>
	<table border="0" id="position1" class="content"><tbody>
</tmpl_if>

<tmpl_loop position1_loop>
	<tmpl_if showAdmin>
		<tr id="td<tmpl_var id>"><td><div id="td<tmpl_var id>_div" class="dragable">
	</tmpl_if>

	<div class="content"><tmpl_var dragger.icon><tmpl_var content></div>

	<tmpl_if showAdmin>
		</div></td></tr>
	</tmpl_if>
</tmpl_loop>

<tmpl_if showAdmin>
	</tbody></table>
</tmpl_if>
</div>

<tmpl_if showAdmin>
	<table><tr id="blank" class="hidden"><td><div><div class="empty">&nbsp;</div></div></td></tr></table>
	<tmpl_var dragger.init>
</tmpl_if>
END
	WebGUI::Asset->new("PBtmpl0000000000000054","WebGUI::Asset::Template")->addRevision({template=>$template})->commit;

	# Macro/AdminBar > DHTML Admin Bar
	$template = <<END;
^StyleSheet(^Extras;slidePanel/slidePanel.css);
^JavaScript(^Extras;slidePanel/slidePanel.js);

<script type="text/javascript">
//<![CDATA[

	var slider = new createSlidePanelBar("WebGUIAdminBar");
	var panel;

	panel = new createPanel("adminconsole","Admin Console");
<tmpl_loop adminConsole_loop>
	<tmpl_if canUse>panel.addLink("<tmpl_var icon.small>","<tmpl_var title escape=JS>","<tmpl_var url escape=JS>");</tmpl_if>
</tmpl_loop>
	slider.addPanel(panel);

	panel = new createPanel("clipboard","Clipboard");
<tmpl_loop clipboard_loop>
	panel.addLink("<tmpl_var icon.small>","<tmpl_var label escape=JS>","<tmpl_var url escape=JS>");
</tmpl_loop>
	slider.addPanel(panel);

	panel = new createPanel("packages","Packages");
<tmpl_loop package_loop>
	panel.addLink("<tmpl_var icon.small>","<tmpl_var label escape=JS>","<tmpl_var url escape=JS>");
</tmpl_loop>
	slider.addPanel(panel);

	panel = new createPanel("assets","New Content");
<tmpl_loop container_loop>
	panel.addLink("<tmpl_var icon.small>","<tmpl_var label escape=JS>","<tmpl_var url escape=JS>");
</tmpl_loop>
	panel.addLink("^Extras;/spacer.gif","<hr>","");

<tmpl_loop contentTypes_loop>
	panel.addLink("<tmpl_var icon.small>","<tmpl_var label escape=JS>","<tmpl_var url escape=JS>");
</tmpl_loop>
	slider.addPanel(panel);
	slider.draw();

//]]>
</script>
END
	WebGUI::Asset->new("PBtmpl0000000000000090","WebGUI::Asset::Template")->addRevision({template=>$template})->commit;

	# Navigation > verticalMenu
	my $template = <<END;
<tmpl_if displayTitle>
	<h1><tmpl_var title></h1>
</tmpl_if>
<tmpl_if description>
	<p><tmpl_var description></p>
</tmpl_if>
<tmpl_if session.var.adminOn>
<tmpl_var controls><br />
</tmpl_if>
<span class="verticalMenu">
<tmpl_loop page_loop>
<tmpl_var page.indent><a class="verticalMenu"
	<tmpl_if page.newWindow>target="_blank"</tmpl_if> href="<tmpl_var page.url>">
	<tmpl_if page.isCurrent>
		<span class="selectedMenuItem"><tmpl_var page.menuTitle></span>
	<tmpl_else><tmpl_var page.menuTitle></tmpl_if></a><br />
</tmpl_loop>
</span>
END
	WebGUI::Asset->new("PBtmpl0000000000000048","WebGUI::Asset::Template")->addRevision({template=>$template})->commit;

	# style > Admin Console
	my $template = <<END;
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
	"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<title>WebGUI <tmpl_var session.webgui.version>-<tmpl_var session.webgui.status> Admin Console</title>
	<link rel="icon" href="^Extras;favicon.png" type="image/png" />
	<link rel="shortcut icon" href="^Extras;favicon.ico" />
	<tmpl_var head.tags>
</head>
<body>
	<tmpl_var body.content>
</body>
</html>
END
	WebGUI::Asset->new("PBtmpl0000000000000137","WebGUI::Asset::Template")->addRevision({template=>$template})->commit;

	# style > Fail Safe
	my $template = <<END;
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
	"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<title>^Page("title"); - WebGUI</title>
	<tmpl_var head.tags>
	<style type="text/css">

.menu {
	position: absolute;
	top: 25px;
	left: 10px;
	width: 180px;
	font-family: helvetica, arial;
	font-size: 12px;
}

.contentArea {
	border: 1px solid #cccccc;
	margin: 25px 10px 10px 190px;
	padding: 5px;
	font-family: helvetica, arial;
	min-height: 400px;
}

/* Hides from non-ie: the holly hack \*/
* html .adminConsoleWorkArea {
	zoom: 1.00;
	display: inline;
}
/* End hide from non-ie */

	</style>
</head>
<body>

	^AdminBar;

	<div class="menu">
		^AssetProxy(flexmenu);
	</div>

	<div class="contentArea">
		<tmpl_var body.content>
		<br />
		<br />
		<hr />
		^LoginToggle; &nbsp; ^a(^@;); &nbsp; ^H; &nbsp; ^AdminToggle;
	</div>

</body>
</html>
END
	WebGUI::Asset->new("PBtmpl0000000000000060","WebGUI::Asset::Template")->addRevision({template=>$template})->commit;

	# style > Make Page Printable
	my $template = <<END;
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
	"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<title>^Page(title); - <tmpl_var session.setting.companyName></title>
	<link rel="icon" href="^Extras;favicon.png" type="image/png" />
	<link rel="shortcut icon" href="^Extras;favicon.ico" />
	<tmpl_var head.tags>
	<style type="text/css">

.content {
	background-color: #ffffff;
	color: #000000;
	font-family: helvetica, arial;
	font-size: 10pt;
	padding: 10pt;
}

H1 {
	font-family: helvetica, arial;
	font-size: 16pt;
}

A {
	color: #EF4200;
}

.pagination {
	font-family: helvetica, arial;
	font-size: 8pt;
	text-align: center;
}

.formDescription {
	font-family: helvetica, arial;
	font-size: 10pt;
	font-weight: bold;
}

.formSubtext {
	font-family: helvetica, arial;
	font-size: 8pt;
}

.highlight {
	background-color: #dddddd;
}

.tableMenu {
	background-color: #cccccc;
	font-size: 8pt;
	font-family: Helvetica, Arial;
}

.tableMenu a {
	text-decoration: none;
}

.tableHeader {
	background-color: #cccccc;
	font-size: 10pt;
	font-family: Helvetica, Arial;
}

.tableData {
	font-size: 10pt;
	font-family: Helvetica, Arial;
}

.pollAnswer {
	font-family: Helvetica, Arial;
	font-size: 8pt;
}

.pollColor {
	background-color: #444444;
}

.pollQuestion {
	font-face: Helvetica, Arial;
	font-weight: bold;
}

.faqQuestion {
	font-size: 12pt;
	font-weight: bold;
	color: #000000;
}

	</style>
</head>
<body onload="window.print()">

	^AdminBar("");

	<div align="center"><a href="^PageUrl;"><img src="^Extras;plainblack.gif" border="0" /></a></div>

	<tmpl_var body.content>

	<div align="center">&copy; 2001-2005 Plain Black Corporation</div>

</body>
</html>
END
	WebGUI::Asset->new("PBtmpl0000000000000111","WebGUI::Asset::Template")->addRevision({template=>$template})->commit;

	# style > WebGUI 6
	my $template = <<END;
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
	"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<title>^Page(title); - <tmpl_var session.setting.companyName></title>
	<link rel="icon" href="^Extras;favicon.png" type="image/png" />
	<link rel="shortcut icon" href="^Extras;favicon.ico" />
	<tmpl_var head.tags>
	<style type="text/css">

.nav,  A.nav:hover, .verticalMenu {
	font-size: 10px;
	text-decoration: none;
}

.pageTitle, .pageTitle A {
	font-size: 30px;
}

input:focus, textarea:focus {
	background-color: #D5E0E1;
}

input, textarea, select {
	-moz-border-radius: 6px;
	background-color: #B9CDCF;
	border: ridge;
}

.wgBoxTop {
	background-image: url("^Extras;styles/webgui6/hdr_bg_corner_right.jpg");
	width: 195px;
	height: 93px;
}

.wgBoxBottom {
	background-image: url("^Extras;styles/webgui6/content_bg_clouds.jpg");
	padding-bottom: 21px;
	width: 529px;
	height: 88px;
}

.logo {
	background-image: url("^Extras;styles/webgui6/hdr_bg_corner_left.jpg");
	background-color: #F4F4F4;
	width: 195px;
	height: 93px;
	padding-bottom: 25px;
}

.login {
	width: 334px;
	height: 93px;
	background-image: url("^Extras;styles/webgui6/hdr_bg_center.jpg");
	background-color: #C1D6D8;
	padding-top: 5px;
	font-family: Arial, Helvetica, sans-serif;
	font-size: 10px;
	font-weight: bold;
	color: #EC4300;
}

input.loginBoxField {
	font-size: 10px;
	background-color: white;
}

.loginBox {
	font-size: 10px;
}

input.loginBoxButton {
	font-size: 10px;
}

.iconBox {
	background-image: url("^Extras;styles/webgui6/content_bg_corner_left_top.jpg");
	width: 195px;
	height: 88px;
	vertical-align: bottom;
	text-align: center;
}

.dateLeft {
	background-image: url("^Extras;styles/webgui6/date_bg_left.jpg");
	width: 53px;
	height: 59px;
}

.dateRight {
	width: 53px;
	height: 59px;
	background-image: url("^Extras;styles/webgui6/date_right_bg.jpg");
}

.date {
	color: #393C3C;
	font-family: Arial, Helvetica, sans-serif;
	font-size: 11px;
	font-weight: bold;
}

.contentbgLeft {
	background-image: url("^Extras;styles/webgui6/content_bg_left.jpg");
	width: 53px;
}

.contentbgRight {
	background-image: url("^Extras;styles/webgui6/content_bg_right.jpg");
}

.content {
	color: #000000;
	font-family: Arial, Helvetica, sans-serif;
	font-size: 10pt;
	padding: 5px;
}

body{
	background-color: #D5E0E1;
	color: Black;
	font-family: Arial, Helvetica, sans-serif;
	font-size: 10pt;
	margin: 0;
	padding: 0px;
	background-image: url("^Extras;styles/webgui6/bg.gif");
	background-position: top;
	background-repeat: repeat-x;
}

a {
	color:#EC4300;
	font-family: Arial, Helvetica, sans-serif;
	font-weight: bold;
	text-decoration: underline;
}

a:hover {
	color: #EC4300;
	font-family: Arial, Helvetica, sans-serif;
	font-weight: bold;
	text-decoration: none;
}

.adminBar {
	background-color: #CCCCCC;
	font-family: helvetica, arial;
}

.tableMenu {
	background-color: #CCCCCC;
	font-size: 10pt;
	font-family: Helvetica, Arial;
}

.tableMenu a {
	font-size: 10pt;
	text-decoration: none;
}

.tableHeader {
	background-color: #CECECE;
	font-size: 10pt;
	font-family: Helvetica, Arial;
}

.tableData {
	font-size: 10pt;
	font-family: Helvetica, Arial;
}

.pollColor {
	background-color: #CCCCCC;
	border: thin solid #393C3C;
}

.pagination {
	font-family: helvetica, arial;
	font-size: 8pt;
	text-align: center;
}

h1, h2, h3, h4, h5, h6 {
	font-family: helvetica, arial;
	color: #EC4300;
}

h1 {
	font-size: 14pt;
	font-family: helvetica, arial;
	color: #EC4300;
}

.tab {
	border: 1px solid black;
	background-color: #eeeeee;
}

.tabBody {
	border: 1px solid black;
	border-top: 1px solid black;
	border-left: 1px solid black;
	background-color: #dddddd;
}

div.tabs {
	line-height: 15px;
	font-size: 14px;
}

.tabHover {
	background-color: #cccccc;
}

.tabActive {
	background-color: #dddddd;
}

	</style>
</head>
<body>

^AdminBar("PBtmpl0000000000000090");

<!-- logo / login table starts here -->
<table border="0" cellspacing="0" cellpadding="0" align="center">
	<tr>
		<td width="195" align="center" class="logo"><a href="http://www.plainblack.com/webgui"><img border="0" src="^Extras;styles/webgui6/wg_logo.gif" alt="WebGUI logo" /></a></td>
		<td width="334" align="center" valign="top" class="login">^L("17","","PBtmpl0000000000000092"); ^AdminToggle;</td>
		<td width="195" align="center" class="wgBoxTop" valign="bottom"><a href="http://www.plainblack.com/webgui"><img border="0" src="^Extras;styles/webgui6/wg_box_top.gif" alt="" /></a></td>
	</tr>
</table>

<!-- logo / login table ends here -->
<table border="0" cellspacing="0" cellpadding="0" align="center">
	<tr>
	<!-- print, email icons here -->
		<td class="iconBox">
&nbsp; &nbsp; &nbsp; &nbsp;
<a href="^H(linkonly);"><img border="0" src="^Extras;styles/webgui6/icon_home.gif" title="Go Home" alt="home" /></a>
<a href="^/;tell_a_friend"><img border="0" src="^Extras;styles/webgui6/icon_email.gif" alt="Email" title="Email a friend about this site." /></a>
<a href="^r(linkonly);"><img border="0" src="^Extras;styles/webgui6/icon_print.gif" alt="Print" title="Make page printable." /></a>
<a href="site_map"><img border="0" src="^Extras;styles/webgui6/icon_site_map.gif" title="View the site map." alt="Site Map" /></a> <a href="http://www.plainblack.com"><img border="0" src="^Extras;styles/webgui6/icon_pb.gif" alt="Plain Black Icon" title="Visit plainblack.com." /></a>
</td>
	<!-- box clouds here -->
		<td class="wgBoxBottom">^Spacer(56,1);<a href="http://www.plainblack.com/what_is_webgui"><img border="0" src="^Extras;styles/webgui6/txt_the_last.gif" alt="the LAST web solution you'll ever NEED" /></a>^Spacer(26,1);<a href="http://www.plainblack.com/webgui"><img border="0" src="^Extras;styles/webgui6/wg_box_bottom.gif" alt="" /></a></td>
	</tr>
</table>

<!-- date & page title table start here -->
<table width="724" border="0" cellspacing="0" cellpadding="0" align="center">
	<tr>
		<td class="dateLeft">^Spacer(53,59);</td>
		<td width="141" bgcolor="#BDC6C7" class="date">^D("%c %D, %y");</td>
		<td><img border="0" src="^Extras;styles/webgui6/date_right_shadow.gif" alt="" /></td>
		<td width="467" bgcolor="#B9CDCF"><div class="pageTitle">^PageTitle;</div></td>
		<td class="dateRight">^Spacer(53,59);</td>
	</tr>
</table>
<!-- date and page title table end here -->

<!-- left nav & content table start here -->
<table width="724" border="0" cellspacing="0" cellpadding="0" align="center">
	<tr>



		<td class="contentbgLeft">^Spacer(53,1);</td>
		<!-- nav column -->
		<td width="142" valign="top" bgcolor="#E2E1E1" style="width: 142px;">
<br /> <div class="nav">
^AssetProxy("flexmenu_1002");
</div> <br /> <br />
<a href="http://www.plainblack.com/webgui"><img border="0" src="^Extras;styles/webgui6/powered_by_aqua_blue.gif" alt="Powered by WebGUI" /></a>
</td>

		<td valign="top" bgcolor="#F4F4F4"><img border="0" src="^Extras;styles/webgui6/lnav_shadow.jpg" alt="" /></td>
		<!-- content column -->
		<td width="466" valign="top" bgcolor="#F4F4F4" class="content">
			<tmpl_var body.content>
		</td>
		<td class="contentbgRight">^Spacer(53,1);</td>
	</tr>
</table>
<!-- left nav & content table end here -->

<!-- footer -->
<table width="724" border="0" cellspacing="0" cellpadding="0" align="center">
	<tr>
		<td><img border="0" src="^Extras;styles/webgui6/footer.jpg" alt="" /></td>
	</tr>
	<tr>
		<td align="center"><a href="http://www.plainblack.com"><img border="0" src="^Extras;styles/webgui6/logo_pb.gif" alt="plainblack" /></a><br /><span style="font-size: 11px;"><a href="http://www.plainblack.com/design">Design by Plain Black</a></span></td>
	</tr>
</table>

</body>
</html>
END
	my $asset = WebGUI::Asset->new("B1bNjWVtzSjsvGZh9lPz_A","WebGUI::Asset::Template");
	$asset->addRevision({template=>$template})->commit if (defined $asset);

	# style > WebGUI 6 Admin Style
	my $template = <<END;
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
	"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<title>^Page(title); - <tmpl_var session.setting.companyName></title>
	<link rel="icon" href="^Extras;favicon.png" type="image/png" />
	<link rel="shortcut icon" href="^Extras;favicon.ico" />
	<tmpl_var head.tags>
	<style>

input:focus, textarea:focus {
	background-color: #D5E0E1;
}

input, textarea, select {
	-moz-border-radius: 6px;
	background-color: #B9CDCF;
	border: ridge;
}

.content {
	color: #000000;
	font-family: Arial, Helvetica, sans-serif;
	font-size: 10pt;
	padding: 5px;
}

body {
	background-color: #D5E0E1;
	color: Black;
	font-family: Arial, Helvetica, sans-serif;
	font-size: 10pt;
	margin: 0;
	padding: 0px;
	background-position: top;
	background-repeat: repeat-x;
}

a {
	color:#EC4300;
	font-family: Arial, Helvetica, sans-serif;
	font-weight: bold;
	text-decoration: underline;
}

a:hover {
	color: #EC4300;
	font-family: Arial, Helvetica, sans-serif;
	font-weight: bold;
	text-decoration: none;
}

.adminBar {
	background-color: #CCCCCC;
	font-family: helvetica, arial;
}

.tableMenu {
	background-color: #CCCCCC;
	font-size: 10pt;
	font-family: Helvetica, Arial;
}

.tableMenu a {
	font-size: 10pt;
	text-decoration: none;
}

.tableHeader {
	background-color: #CECECE;
	font-size: 10pt;
	font-family: Helvetica, Arial;
}

.tableData {
	font-size: 10pt;
	font-family: Helvetica, Arial;
}

.pagination {
	font-family: helvetica, arial;
	font-size: 8pt;
	text-align: center;
}

h1 {
	font-size: 14pt;
	font-family: helvetica, arial;
	color: #EC4300;
}

.tab {
	-moz-border-radius: 6px 6px 0px 0px;
	border: 1px solid black;
	background-color: #eeeeee;
}

.tabBody {
	border: 1px solid black;
	border-top: 1px solid black;
	border-left: 1px solid black;
	background-color: #dddddd;
}

div.tabs {
	line-height: 15px;
	font-size: 14px;
}

.tabHover {
	background-color: #cccccc;
}

.tabActive {
	background-color: #dddddd;
}

	</style>
</head>
<body>

	^AdminBar("PBtmpl0000000000000090");<br /><br />

	<div class="content" style="padding: 10px;">
		<tmpl_var body.content>
	</div>

	<div width="100%" style="color: white; padding: 3px; background-color: black; text-align: center;">
		^H; / ^PageTitle; / ^AdminToggle; / ^LoginToggle; / ^a;
	</div>

</body>
</html>
END
	my $asset = WebGUI::Asset->new("9tBSOV44a9JPS8CcerOvYw","WebGUI::Asset::Template");
	$asset->addRevision({template=>$template})->commit if (defined $asset);
}

#-------------------------------------------------
sub fixArticles {
	print "\tFixing articles...\n" unless ($quiet);

	# home/key_benefits
	my $description = <<END;
<img align="right" style="position: relative;" src="^Extras;styles/webgui6/img_hands.jpg" alt="" />
<dl>
<dt><b>Easy to Use</b></dt>
<dd style="margin-bottom: 1em;">If you can use a web browser, then you can manage a web site with
WebGUI. WebGUI's unique WYSIWYG inline content editing interface
ensures that you know where you are and what your content will look
like while you're editing. In addition, you don't need to install and
learn any complicated programs, you can edit everything with your
trusty web browser.</dd>

<dt><b>Flexible Designs</b></dt>
<dd style="margin-bottom: 1em;">WebGUI's powerful templating system ensures that no two WebGUI
sites ever need to look the same. You're not restricted in how your
content is laid out or how your navigation functions.</dd>

<dt><b>Work Faster</b></dt>
<dd style="margin-bottom: 1em;">Though there is some pretty cool technology behind the scenes that
makes WebGUI work, our first concern has always been usability and not
technology. After all if it's not useful, why use it? With that in mind
WebGUI has all kinds of wizards, short cuts, online help, and other
aids to help you work faster.</dd>

<dt><b>Localized Content</b></dt>
<dd style="margin-bottom: 1em;">With WebGUI there's no need to limit yourself to one language or
timezone. It's a snap to build a multi-lingual site with WebGUI. In
fact, even WebGUI's built in functions and online help have been
translated to more than 15 languages. User's can also adjust their
local settings for dates, times, and other localized oddities.</dd>

<dt><b>Pluggable By Design</b></dt>
<dd style="margin-bottom: 1em;">When <a href="http://www.plainblack.com/">Plain Black</a> created
WebGUI we knew we wouldn't be able to think of everything you want to
use WebGUI for, so we made most of WebGUI's functions pluggable. This
allows you to add new features to WebGUI and still be able to upgrade
the core system without a fuss.</dd>
</dl>
END
	my $asset = WebGUI::Asset->new("sWVXMZGibxHe2Ekj1DCldA","WebGUI::Asset::Wobject::Article");
	$asset->addRevision({description=>$description})->commit if (defined $asset);
}

#-------------------------------------------------
sub fixTemplatesExtras {
	print "\tFixing built-in templates with the Extras Macro.\n" unless ($quiet);
	my @tmpls = WebGUI::SQL->buildArray("select distinct assetId from template");
	foreach my $id (@tmpls) {
		my $asset = WebGUI::Asset->new($id,"WebGUI::Asset::Template");
		my $template = $asset->get("template");
		$template =~ s/\^Extras;\//^Extras;/ixsg;
		$asset->addRevision({template=>$template})->commit;
	}
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

