use lib "../../lib";
use strict;
use Getopt::Long;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Asset;
use WebGUI::Setting;

my $toVersion = "6.7.7";
my $configFile;
my $quiet;
my %fixedTemplates;

start();
removingThreadedView();
fixTemplates();
finish();

#-------------------------------------------------
sub removingThreadedView {
        print "\tRemoving threaded views from CS in favor of nested views.\n" unless ($quiet);
	#
	# (template fixes moved into fixTemplates function)
	#
	WebGUI::SQL->write("update userSessionScratch set value='nested' where value='threaded' and name='discussionLayout'");
	WebGUI::SQL->write("update userProfileData set fieldData='nested' where fieldData='threaded' and fieldName='discussionLayout'");
	WebGUI::SQL->write("update userProfileField set dataValues='{
  flat=>WebGUI::International::get(510),
  nested=>WebGUI::International::get(1045)
}', dataDefault=".quote("['nested']")." where fieldName='discussionLayout'");
}

#-------------------------------------------------
sub fixTemplates {
	print "\tFixing templates.\n" unless ($quiet);
	loadFixedTemplates();
	foreach my $assetId (keys %fixedTemplates) {
		my $asset = WebGUI::Asset->new($assetId, "WebGUI::Asset::Template");
		$asset->addRevision({template=>$fixedTemplates{$assetId}})->commit if (defined $asset);
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

#-------------------------------------------------
# No interesting code below this line, only templates
sub loadFixedTemplates {
$fixedTemplates{DPUROtmpl0000000000001} = << 'END';
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>

<tmpl_if session.var.adminOn>
	<p><tmpl_var controls></p>
</tmpl_if>

<p>
<a href="<tmpl_var rss.url.0.9>">RSS 0.90</a>
<a href="<tmpl_var rss.url.0.91>">RSS 0.91</a>
<a href="<tmpl_var rss.url.1.0>">RSS 1.0</a>
<a href="<tmpl_var rss.url.2.0>">RSS 2.0</a>
</p>

<tmpl_if displayTitle>
	<h1><tmpl_var title></h1>
</tmpl_if>

<tmpl_if description>
	<tmpl_var description>
	<p />
</tmpl_if>

<h1>
<tmpl_if channel.link>
	<a href="<tmpl_var channel.link>" target="_blank"><tmpl_var channel.title></a>
<tmpl_else>
	<tmpl_var channel.title>
</tmpl_if>
</h1>

<tmpl_if channel.description>
	<tmpl_var channel.description><p />
</tmpl_if>

<tmpl_loop item_loop>

<tmpl_if new_rss_site>
<!-- We're in a new RSS group. Output the header. -->
<h2><a href="<tmpl_var site_link>" target="_blank"><tmpl_var site_title></a></h2>
</tmpl_if>

<li>
	<tmpl_if link>
		<a href="<tmpl_var link>" target="_blank"><tmpl_var title></a>
	<tmpl_else>
		<tmpl_var title>
	</tmpl_if>
	<tmpl_if description>
		- <tmpl_var description>
	</tmpl_if>
<b><tmpl_var site_title></b>
<br />

</tmpl_loop>
END

$fixedTemplates{GNvjCFQWjY2AF2uf0aCM8Q} = << 'END';
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>

<tmpl_if session.var.adminOn>
	<p><tmpl_var controls></p>
</tmpl_if>

<tmpl_if displayTitle>
	<h1><tmpl_var title></h1>
</tmpl_if>

<tmpl_if description>
	<tmpl_var description><p />
</tmpl_if>

<h1>
<tmpl_if channel.link>
	<a href="<tmpl_var channel.link>" target="_blank"><tmpl_var channel.title></a>
<tmpl_else>
	<tmpl_var channel.title>
</tmpl_if>
</h1>

<tmpl_if channel.description>
	<tmpl_var channel.description><p />
</tmpl_if>

<tmpl_loop item_loop>
	<b><tmpl_var title></b>
	<tmpl_if description>
		<br />
		<tmpl_var description>
	</tmpl_if>
	<tmpl_if link>
		<br />
		<a href="<tmpl_var link>" target="_blank" style="font-size: 9px;">Read More...</a>
	</tmpl_if>
	<br />
	<br />
</tmpl_loop>
END

$fixedTemplates{PBtmpl0000000000000001} = << 'END';
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
<script type="text/javascript" defer="defer">
	initAdminConsole(<tmpl_if application.title>true<tmpl_else>false</tmpl_if>,<tmpl_if submenu_loop>true<tmpl_else>false</tmpl_if>);
</script>
END

$fixedTemplates{PBtmpl0000000000000002} = << 'END';
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>

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

$fixedTemplates{PBtmpl0000000000000003} = << 'END';
<table cellpadding="3" cellspacing="0" border="1">
<tr>
	<td class="tableHeader">
		<a href="<tmpl_var attachment.url>"><img src="<tmpl_var session.config.extrasURL>/attachment.gif" border="0" alt="<tmpl_var attachment.name>" /></a>
	</td>
	<td>
		<a href="<tmpl_var attachment.url>"><img src="<tmpl_var attachment.icon>" align="middle" width="16" height="16" border="0" alt="<tmpl_var attachment.name>" /><tmpl_var attachment.name></a>
	</td>
</tr>
</table>
END

$fixedTemplates{PBtmpl0000000000000004} = << 'END';
<h1>
	<tmpl_var title>
</h1>

<tmpl_var account.message>
<tmpl_if account.form.karma>
<br /><br />
<table>
<tr>
	<td class="formDescription">
		<tmpl_var account.form.karma.label>
	</td>
	<td class="tableData">
	 	<tmpl_var account.form.karma>
	</td>
</tr>
</table>
</tmpl_if>

<div class="accountOptions">
	<ul>
		<tmpl_loop account.options>
			<li><tmpl_var options.display></li>
		</tmpl_loop>
	</ul>
</div>
END

$fixedTemplates{PBtmpl0000000000000010} = << 'END';
<h1><tmpl_var title></h1>

<tmpl_if account.message>
	<tmpl_var account.message>
</tmpl_if>

<tmpl_var account.form.header>
<table>
<tmpl_if account.form.karma>
<tr>
	<td class="formDescription" valign="top"><tmpl_var account.form.karma.label></td>
	<td class="tableData"><tmpl_var account.form.karma></td>
</tr>
</tmpl_if>
<tr>
	<td class="formDescription" valign="top"><tmpl_var account.form.username.label></td>
	<td class="tableData"><tmpl_var account.form.username></td>
</tr>
<tr>
	<td class="formDescription" valign="top"><tmpl_var account.form.password.label></td>
	<td class="tableData"><tmpl_var account.form.password></td>
</tr>
<tr>
	<td class="formDescription" valign="top"><tmpl_var account.form.passwordConfirm.label></td>
	<td class="tableData"><tmpl_var account.form.passwordConfirm></td>
</tr>
<tr>
	<td class="formDescription" valign="top"></td>
	<td class="tableData"><tmpl_var account.form.submit></td>
</tr>
</table>
<tmpl_var account.form.footer>

<div class="accountOptions">
	<ul>
		<tmpl_loop account.options>
			<li><tmpl_var options.display></li>
		</tmpl_loop>
	</ul>
</div>
END

$fixedTemplates{PBtmpl0000000000000020} = << 'END';
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>
<tmpl_if session.var.adminOn>
	<p><tmpl_var controls></p>
</tmpl_if>

<tmpl_if displayTitle>
	<h1><tmpl_var title></h1>
</tmpl_if>

<tmpl_if error_loop>
<ul>
<tmpl_loop error_loop>
	<li><b><tmpl_var error.message></b>
</tmpl_loop>
</ul>
</tmpl_if>

<tmpl_if description>
	<tmpl_var description>
	<p />
</tmpl_if>

<tmpl_if canEdit>
	<a href="<tmpl_var entryList.url>"><tmpl_var entryList.label></a>
	&middot; <a href="<tmpl_var export.tab.url>"><tmpl_var export.tab.label></a>
	<tmpl_if entryId>
		&middot; <a href="<tmpl_var delete.url>"><tmpl_var delete.label></a>
	</tmpl_if>
	<tmpl_if session.var.adminOn>
		&middot; <a href="<tmpl_var addField.url>"><tmpl_var addField.label></a>
		&middot; <a href="<tmpl_var addTab.url>"><tmpl_var addTab.label></a>
	</tmpl_if>
	<p />
</tmpl_if>

<tmpl_var form.start>
<table>
<tmpl_loop field_loop>
	<tmpl_unless field.isHidden>
		<tr><td class="formDescription" valign="top">
		<tmpl_if session.var.adminOn><tmpl_if canEdit><tmpl_var field.controls></tmpl_if></tmpl_if>
		<tmpl_var field.label>
		</td><td class="tableData" valign="top">
		<tmpl_if field.isDisplayed>
			<tmpl_var field.value>
		<tmpl_else>
			<tmpl_var field.form>
		</tmpl_if>
		<tmpl_if field.required>*</tmpl_if>
		<span class="formSubtext"><br /><tmpl_var field.subtext></span>
		</td></tr>
	</tmpl_unless>
</tmpl_loop>
<tr><td></td><td><tmpl_var form.send></td></tr>
</table>

<tmpl_var form.end>
END

$fixedTemplates{PBtmpl0000000000000022} = << 'END';
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>

<tmpl_if session.var.adminOn>
	<p><tmpl_var controls></p>
</tmpl_if>

<tmpl_if displayTitle>
	<h1><tmpl_var title></h1>
</tmpl_if>

<tmpl_if description>
	<tmpl_var description>
	<p />
</tmpl_if>

<tmpl_if session.var.adminOn>
	<a href="<tmpl_var addevent.url>"><tmpl_var addevent.label></a>
	<p />
</tmpl_if>

<tmpl_loop month_loop>
	<table border="1" width="100%">
	<tr><td colspan=7 class="tableHeader"><h2 align="center"><tmpl_var month> <tmpl_var year></h2></td></tr>
	<tr>
	<tmpl_if session.user.firstDayOfWeek>
		<th class="tableData"><tmpl_var monday.label></th>
		<th class="tableData"><tmpl_var tuesday.label></th>
		<th class="tableData"><tmpl_var wednesday.label></th>
		<th class="tableData"><tmpl_var thursday.label></th>
		<th class="tableData"><tmpl_var friday.label></th>
		<th class="tableData"><tmpl_var saturday.label></th>
		<th class="tableData"><tmpl_var sunday.label></th>
	<tmpl_else>
		<th class="tableData"><tmpl_var sunday.label></th>
		<th class="tableData"><tmpl_var monday.label></th>
		<th class="tableData"><tmpl_var tuesday.label></th>
		<th class="tableData"><tmpl_var wednesday.label></th>
		<th class="tableData"><tmpl_var thursday.label></th>
		<th class="tableData"><tmpl_var friday.label></th>
		<th class="tableData"><tmpl_var saturday.label></th>
	</tmpl_if>
	</tr><tr>
	<tmpl_loop prepad_loop>
		<td>&nbsp;</td>
	</tmpl_loop>
 	<tmpl_loop day_loop>
		<tmpl_if isStartOfWeek>
			<tr>
		</tmpl_if>
		<td class="table<tmpl_if isToday>Header<tmpl_else>Data</tmpl_if>" width="14%" valign="top" align="left"><p><b><tmpl_var day></b></p>
		<tmpl_loop event_loop>
			<tmpl_if name>
				&middot;<a href="<tmpl_var url>"><tmpl_var name></a><br />
			</tmpl_if>
		</tmpl_loop>
		</td>
		<tmpl_if isEndOfWeek>
			</tr>
		</tmpl_if>
	</tmpl_loop>
	<tmpl_loop postpad_loop>
		<td>&nbsp;</td>
	</tmpl_loop>
	</tr>
	</table>
</tmpl_loop>

<tmpl_if pagination.pageCount.isMultiple>
	<div class="pagination">
		<tmpl_var pagination.previousPage>  &middot; <tmpl_var pagination.pageList.upTo20> &middot; <tmpl_var pagination.nextPage>
	</div>
</tmpl_if>
END

$fixedTemplates{PBtmpl0000000000000026} = << 'END';
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>

<tmpl_if session.var.adminOn>
	<p><tmpl_var controls></p>
</tmpl_if>

<style type="text/css">
.forumHead {
	background-color: #eeeeee;
	border-bottom: 1px solid #cccccc;
	padding: 2px;
	padding-bottom: 4px;
	font-size: 13px;
	font-weight: bold;
}
.oddThread {
	font-size: 13px;
	border-bottom: 1px dashed #83cc83;
	padding-bottom: 4px;
}
.evenThread {
	font-size: 13px;
	border-bottom: 1px dashed #aaaaff;
	padding-bottom: 4px;
}
</style>

<tmpl_if displayTitle>
	<h1><tmpl_var title></h1>
</tmpl_if>

<tmpl_if description>
	<tmpl_var description>
</tmpl_if>

<p>
	<tmpl_if user.canPost>
		<a href="<tmpl_var add.url>"><tmpl_var add.label></a>
		&bull;
	</tmpl_if>
	<tmpl_unless user.isVisitor>
		<tmpl_if user.isSubscribed>
			<a href="<tmpl_var unsubscribe.url>"><tmpl_var unsubscribe.label></a>
		<tmpl_else>
			<a href="<tmpl_var subscribe.url>"><tmpl_var subscribe.label></a>
		</tmpl_if>
		&bull;
	</tmpl_unless>
	<a href="<tmpl_var search.url>"><tmpl_var search.label></a>
</p>

<table width="100%">
<tr>
	<tmpl_if user.isModerator>
		<td class="forumHead"><tmpl_var status.label></td>
	</tmpl_if>
	<td class="forumHead"><tmpl_var subject.label></td>
	<td class="forumHead"><tmpl_var user.label></td>
	<td class="forumHead"><a href="<tmpl_var sortby.views.url>"><tmpl_var views.label></a></td>
	<td class="forumHead"><a href="<tmpl_var sortby.replies.url>"><tmpl_var replies.label></a></td>
	<td class="forumHead"><a href="<tmpl_var sortby.rating.url>"><tmpl_var rating.label></a></td>
	<td class="forumHead"><a href="<tmpl_var sortby.date.url>"><tmpl_var date.label></a></td>
	<tmpl_if displayLastReply>
		<td class="forumHead"><a href="<tmpl_var sortby.lastreply.url>"><tmpl_var lastReply.label></a></td>
	</tmpl_if>
</tr>
<tmpl_loop post_loop>
<tr>
	<tmpl_if user.isModerator>
		<td class="<tmpl_if __ODD__>oddThread<tmpl_else>evenThread</tmpl_if>"><tmpl_var status></td>
	</tmpl_if>
	<td class="<tmpl_if __ODD__>oddThread<tmpl_else>evenThread</tmpl_if>"><a href="<tmpl_var url>"><tmpl_var title></a></td>
	<tmpl_if user.isVisitor>
		<td class="<tmpl_if __ODD__>oddThread<tmpl_else>evenThread</tmpl_if>"><tmpl_var username></td>
	<tmpl_else>
		<td class="<tmpl_if __ODD__>oddThread<tmpl_else>evenThread</tmpl_if>"><a href="<tmpl_var userProfile.url>"><tmpl_var username></a></td>
	</tmpl_if>
	<td class="<tmpl_if __ODD__>oddThread<tmpl_else>evenThread</tmpl_if>" align="center"><tmpl_var views></td>
	<td class="<tmpl_if __ODD__>oddThread<tmpl_else>evenThread</tmpl_if>" align="center"><tmpl_var replies></td>
	<td class="<tmpl_if __ODD__>oddThread<tmpl_else>evenThread</tmpl_if>" align="center"><tmpl_var rating></td>
	<td class="<tmpl_if __ODD__>oddThread<tmpl_else>evenThread</tmpl_if>"><tmpl_var dateSubmitted.human> @ <tmpl_var timeSubmitted.human></td>
	<tmpl_if displayLastReply>
		<td  class="<tmpl_if __ODD__>oddThread<tmpl_else>evenThread</tmpl_if>" style="font-size: 11px;">
			<a href="<tmpl_var lastReply.url>"><tmpl_var lastReply.title></a>
			by
			<tmpl_if lastReply.user.isVisitor>
				<tmpl_var lastReply.username>
			<tmpl_else>
				<a href="<tmpl_var lastReply.userProfile.url>"><tmpl_var lastReply.username></a>
			</tmpl_if>
			on <tmpl_var lastReply.dateSubmitted.human> @ <tmpl_var lastReply.timeSubmitted.human>
		</td>
	</tmpl_if>
</tr>
</tmpl_loop>
</table>

<tmpl_if pagination.pageCount.isMultiple>
	<div class="pagination">
		<tmpl_var pagination.previousPage>  &middot; <tmpl_var pagination.pageList.upTo10> &middot; <tmpl_var pagination.nextPage>
	</div>
</tmpl_if>
END

$fixedTemplates{PBtmpl0000000000000029} = << 'END';
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>

<tmpl_if preview.title>
	<p><b><tmpl_var preview.title></b></p>
</tmpl_if>

<tmpl_if preview.content>
	<p><tmpl_var preview.content></p>
</tmpl_if>

<h1><tmpl_var message.header.label></h1>

<tmpl_var form.header>
<table>
	<tmpl_if isNewPost>
		<tmpl_if user.isVisitor>
			<tr>
				<td><tmpl_var visitorName.label></td>
				<td><tmpl_var visitorName.form></td>
			</tr>
		</tmpl_if>
	</tmpl_if>
	<tr>
		<td><tmpl_var subject.label></td>
		<td><tmpl_var title.form></td>
	</tr>
	<tr>
		<td><tmpl_var message.label></td>
		<td><tmpl_var content.form></td>
	</tr>
	<tr>
		<td><tmpl_var contentType.label></td>
		<td><tmpl_var contentType.form></td>
	</tr>
	<tmpl_if attachment.form>
		<tr>
			<td><tmpl_var attachment.label></td>
			<td><tmpl_var attachment.form></td>
		</tr>
	</tmpl_if>
	<tmpl_if isNewPost>
		<tmpl_unless user.isVisitor>
			<tr>
				<td><tmpl_var subscribe.label></td>
				<td><tmpl_var subscribe.form></td>
			</tr>
		</tmpl_unless>
		<tmpl_if isNewThread>
			<tmpl_if user.isModerator>
				<tr>
					<td><tmpl_var lock.label></td>
					<td><tmpl_var lock.form></td>
				</tr>
				<tr>
					<td><tmpl_var stick.label></td>
					<td><tmpl_var sticky.form></td>
				</tr>
			</tmpl_if>
		</tmpl_if>
	</tmpl_if>
	<tr>
		<td></td>
		<td><tmpl_if usePreview><tmpl_var form.preview></tmpl_if><tmpl_var form.submit></td>
	</tr>
</table>
<tmpl_var form.footer>

<tmpl_if isReply>
	<p><b><tmpl_var reply.title></b></p>
	<tmpl_var reply.content>
</tmpl_if>
END

$fixedTemplates{PBtmpl0000000000000031} = << 'END';
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>

<tmpl_if session.var.adminOn>
	<p><tmpl_var controls></p>
</tmpl_if><tmpl_var form.header>

<table width="100%" class="tableMenu">
<tr><td align="right" width="15%">
	<h1><tmpl_var search.label></h1>
	</td>
	<td valign="top" width="70%" align="center">
		<table>
			<tr><td class="tableData"><tmpl_var all.label></td><td class="tableData"><tmpl_var all.form></td></tr>
			<tr><td class="tableData"><tmpl_var exactphrase.label></td><td class="tableData"><tmpl_var exactphrase.form></td></tr>
			<tr><td class="tableData"><tmpl_var atleastone.label></td><td class="tableData"><tmpl_var atleastone.form></td></tr>
			<tr><td class="tableData"><tmpl_var without.label></td><td class="tableData"><tmpl_var without.form></td></tr>
			<tr><td class="tableData"><tmpl_var results.label></td><td class="tableData"><tmpl_var results.form></td></tr>
		</table>
	</td><td width="15%">
			<tmpl_var form.search>
	</td>
</tr></table>
<tmpl_var form.footer>
<tmpl_if doit>
	<table width="100%" cellspacing="0" cellpadding="3" border="0">
	<tr>
		<td class="tableHeader"><tmpl_var title.label></td>
		<td class="tableHeader"><tmpl_var user.label></td>
		<td class="tableHeader"><tmpl_var date.label></td>
	</tr>
	<tmpl_loop post_loop>
		<tr>
			<td class="tableData"><a href="<tmpl_var url>"><tmpl_var title></a></td>
			<tmpl_if user.isVisitor>
				<td class="tableData"><tmpl_var username></td>
			<tmpl_else>
				<td class="tableData"><a href="<tmpl_var userProfile.url>"><tmpl_var username></a></td>
			</tmpl_if>
			<td class="tableData"><tmpl_var date> @ <tmpl_var time></td>
		</tr>
	</tmpl_loop>
	</table>
</tmpl_if>

<tmpl_if pagination.pageCount.isMultiple>
	<div class="pagination">
		<tmpl_var pagination.previousPage> &middot; <tmpl_var pagination.pageList.upTo10> &middot; <tmpl_var pagination.nextPage>
	</div>
</tmpl_if>
END

$fixedTemplates{PBtmpl0000000000000032} = << 'END';
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a> 

<tmpl_if session.var.adminOn> 
	<p><tmpl_var controls></p>
</tmpl_if>

<style type="text/css">
	.postBorder {
		border: 1px solid #cccccc;
		margin-bottom: 10px;
	}
 	.postBorderCurrent {
		border: 3px dotted black;
		margin-bottom: 10px;
	}
	.postSubject {
		border-bottom: 1px solid #cccccc;
		font-weight: bold;
		padding: 3px;
	}
	.postData {
		border-bottom: 1px solid #cccccc;
		font-size: 11px;
		background-color: #eeeeee;
		color: black;
		padding: 3px;
	}
	.postControls {
		border-top: 1px solid #cccccc;
		background-color: #eeeeee;
		color: black;
		padding: 3px;
	}
	.postMessage {
		padding: 3px;
	}
	.currentThread {
		background-color: #eeeeee;
	}
	.threadHead {
		font-weight: bold;
		border-bottom: 1px solid #cccccc;
		font-size: 11px;
		background-color: #eeeeee;
		color: black;
		padding: 3px;
	}
	.threadData {
		font-size: 11px;
		padding: 3px;
	}
</style>
	
<div style="float: left; width: 70%">
	<h1><a href="<tmpl_var collaboration.url>"><tmpl_var collaboration.title></a></h1>
</div>
<div style="width: 30%; float: left; text-align: right;">
	<tmpl_if layout.isFlat>
		<a href="<tmpl_var layout.nested.url>"><tmpl_var layout.nested.label></a>
	<tmpl_else>
		<a href="<tmpl_var layout.flat.url>"><tmpl_var layout.flat.label></a>
	</tmpl_if>
</div>
<div style="clear: both;"></div>

<tmpl_if layout.isFlat>
<!-- begin flat layout -->
	<tmpl_loop post_loop>
		<div class="postBorder<tmpl_if isCurrent>Current</tmpl_if>">
			<a name="<tmpl_var assetId>"></a>
			<div class="postSubject">
				<tmpl_var title>
			</div>
			<div class="postData">
				<div style="float: left; width: 50%">
					<b><tmpl_var user.label>:</b> 
						<tmpl_if user.isVisitor>
							<tmpl_var username>
						<tmpl_else>
							<a href="<tmpl_var userProfile.url>"><tmpl_var username></a>
						</tmpl_if>
						<br />
					<b><tmpl_var date.label>:</b> <tmpl_var dateSubmitted.human><br />
				</div>	
				<div>
					<b><tmpl_var views.label>:</b> <tmpl_var views><br />
					<b><tmpl_var rating.label>:</b> <tmpl_var rating>
						<tmpl_unless hasRated>
							 &nbsp; &nbsp;<tmpl_var rate.label> [ <a href="<tmpl_var rate.url.1>">1</a>, <a href="<tmpl_var rate.url.2>">2</a>, <a href="<tmpl_var rate.url.3>">3</a>, <a href="<tmpl_var rate.url.4>">4</a>, <a href="<tmpl_var rate.url.5>">5</a> ]
						</tmpl_unless>
						<br />
					<tmpl_if user.isModerator>
						<b><tmpl_var status.label>:</b> <tmpl_var status> &nbsp; &nbsp; [ <a href="<tmpl_var approve.url>"><tmpl_var approve.label></a> | <a href="<tmpl_var deny.url>"><tmpl_var deny.label></a> ]<br />
					<tmpl_else>	
						<tmpl_if user.isPoster>
							<b><tmpl_var status.label>:</b> <tmpl_var status><br />
						</tmpl_if>	
					</tmpl_if>	
				</div>	
			</div>
			<div class="postMessage">
				<tmpl_var content>
<tmpl_loop attachment_loop>
	<div style="float: left; padding: 5px;"><a href="<tmpl_var url>"><tmpl_if isImage><img src="<tmpl_var thumbnail>" border="0" alt="<tmpl_var filename>" /><tmpl_else><img src="<tmpl_var icon>" border="0" alt="<tmpl_var filename>" align="middle" /> <tmpl_var filename></tmpl_if></a></div>
</tmpl_loop>
<div style="clear: both;"></div>

			</div>
			<tmpl_unless isLocked>
				<div class="postControls">
					<tmpl_if user.canReply>
						<a href="<tmpl_var reply.url>">[<tmpl_var reply.label>]</a>
					</tmpl_if>
					<tmpl_if user.canEdit>
						<a href="<tmpl_var edit.url>">[<tmpl_var edit.label>]</a>
						<a href="<tmpl_var delete.url>">[<tmpl_var delete.label>]</a>
					</tmpl_if>
				</div>
			</tmpl_unless>
		</div>
	</tmpl_loop>
<!-- end flat layout -->
</tmpl_if>

<tmpl_if layout.isNested>
<!-- begin nested layout -->
	<tmpl_loop post_loop>
		<div style="margin-left: <tmpl_var depthX10>px;">
			<div class="postBorder<tmpl_if isCurrent>Current</tmpl_if>">
				<a name="<tmpl_var assetId>"></a>
				<div class="postSubject">
					<tmpl_var title>
				</div>
				<div class="postData">
					<div style="float: left; width: 50%">
						<b><tmpl_var user.label>:</b> 
							<tmpl_if user.isVisitor>
								<tmpl_var username>
							<tmpl_else>
								<a href="<tmpl_var userProfile.url>"><tmpl_var username></a>
							</tmpl_if>
							<br />
						<b><tmpl_var date.label>:</b> <tmpl_var dateSubmitted.human><br />
					</div>	
					<div>
						<b><tmpl_var views.label>:</b> <tmpl_var views><br />
						<b><tmpl_var rating.label>:</b> <tmpl_var rating>
							<tmpl_unless hasRated>
								 &nbsp; &nbsp;<tmpl_var rate.label> [ <a href="<tmpl_var rate.url.1>">1</a>, <a href="<tmpl_var rate.url.2>">2</a>, <a href="<tmpl_var rate.url.3>">3</a>, <a href="<tmpl_var rate.url.4>">4</a>, <a href="<tmpl_var rate.url.5>">5</a> ]
							</tmpl_unless>
							<br />
						<tmpl_if user.isModerator>
							<b><tmpl_var status.label>:</b> <tmpl_var status> &nbsp; &nbsp; [ <a href="<tmpl_var approve.url>"><tmpl_var approve.label></a> | <a href="<tmpl_var deny.url>"><tmpl_var deny.label></a> ]<br />
						<tmpl_else>	
							<tmpl_if user.isPoster>
								<b><tmpl_var status.label>:</b> <tmpl_var status><br />
							</tmpl_if>	
						</tmpl_if>	
					</div>	
				</div>
				<div class="postMessage">
					<tmpl_var content>
<tmpl_loop attachment_loop>
	<div style="float: left; padding: 5px;"><a href="<tmpl_var url>"><tmpl_if isImage><img src="<tmpl_var thumbnail>" border="0" alt="<tmpl_var filename>" /><tmpl_else><img src="<tmpl_var icon>" border="0" alt="<tmpl_var filename>" align="middle" /> <tmpl_var filename></tmpl_if></a></div>
</tmpl_loop>
<div style="clear: both;"></div>

				</div>
				<tmpl_unless isLocked>
					<div class="postControls">
						<tmpl_if user.canReply>
							<a href="<tmpl_var reply.url>">[<tmpl_var reply.label>]</a>
						</tmpl_if>
						<tmpl_if user.canEdit>
							<a href="<tmpl_var edit.url>">[<tmpl_var edit.label>]</a>
							<a href="<tmpl_var delete.url>">[<tmpl_var delete.label>]</a>
						</tmpl_if>
					</div>
				</tmpl_unless>
			</div>
		</div>
	</tmpl_loop>
<!-- end nested layout -->
</tmpl_if>

<tmpl_if pagination.pageCount.isMultiple>
	<div class="pagination" style="margin-top: 20px;">
		[ <tmpl_var pagination.previousPage> | <tmpl_var pagination.pageList.upTo10> | <tmpl_var pagination.nextPage> ]
	</div>
</tmpl_if>

<div style="margin-top: 20px;">
	<tmpl_if previous.url>
		<a href="<tmpl_var previous.url>">[<tmpl_var previous.label>]</a> 
	</tmpl_if>	
	<tmpl_if next.url>
		<a href="<tmpl_var next.url>">[<tmpl_var next.label>]</a> 
	</tmpl_if>	
	<tmpl_if user.canPost>
		<a href="<tmpl_var add.url>">[<tmpl_var add.label>]</a>
	</tmpl_if>
	<tmpl_if user.isModerator>
		<tmpl_if isSticky>
			<a href="<tmpl_var unstick.url>">[<tmpl_var unstick.label>]</a>
		<tmpl_else>
			<a href="<tmpl_var stick.url>">[<tmpl_var stick.label>]</a>
		</tmpl_if>
		<tmpl_if isLocked>
			<a href="<tmpl_var unlock.url>">[<tmpl_var unlock.label>]</a>
		<tmpl_else>
			<a href="<tmpl_var lock.url>">[<tmpl_var lock.label>]</a>
		</tmpl_if>
	</tmpl_if>
	<tmpl_unless user.isVisitor>
		<tmpl_if user.isSubscribed>
			<a href="<tmpl_var unsubscribe.url>">[<tmpl_var unsubscribe.label>]</a>
		<tmpl_else>
			<a href="<tmpl_var subscribe.url>">[<tmpl_var subscribe.label>]</a>
		</tmpl_if>
	</tmpl_unless>
</div>
END

$fixedTemplates{PBtmpl0000000000000033} = << 'END';
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>

<tmpl_if session.var.adminOn>
	<p><tmpl_var controls></p>
</tmpl_if>

<tmpl_if displayTitle>
	<h1><tmpl_var title></h1>
</tmpl_if>

<tmpl_if description>
	<tmpl_var description>
	<p />
</tmpl_if>

<tmpl_if search.for>
	<tmpl_if content>
		<!-- Display search string. Remove if unwanted -->
		<tmpl_var search.for>
	<tmpl_else>
		<!-- Error: Starting point not found -->
		<b>Error: Search string <i><tmpl_var search.for></i> not found in content.</b>
	</tmpl_if>
</tmpl_if>

<tmpl_var content>

<tmpl_if stop.at>
	<tmpl_if content.trailing>
		<!-- Display stop search string. Remove if unwanted -->
		<tmpl_var stop.at>
	<tmpl_else>
		<!-- Warning: End point not found -->
		<b>Warning: Ending search point <i><tmpl_var stop.at></i> not found in content.</b>
	</tmpl_if>
</tmpl_if>
END

$fixedTemplates{PBtmpl0000000000000034} = << 'END';
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>

<tmpl_if session.var.adminOn>
	<p><tmpl_var controls></p>
</tmpl_if>

<tmpl_if displayTitle>
	<h1><tmpl_var title></h1>
</tmpl_if>

<tmpl_if description>
	<tmpl_var description><p />
</tmpl_if>

<table class="tableMenu" width="100%">
	<tbody>
	<tr>
	<td align="center" width="15%"><h1><tmpl_var int.search></h1></td>
	<td valign="top" align="middle">
	<table>
	<form method="post" action="<tmpl_var actionURL>">
	<tbody>
	<tr>
	<td colspan="2" class="tableData">
		<input maxLength="255" size="30" value='<tmpl_var query>' name="query">
	</td>
	<td class="tableData"><tmpl_var submit></td>
	</tr>
	<tr>
	<td class="tableData" valign="top"></td>
	<td class="tableData" valign="top">
	   <tmpl_loop contentTypesSimple>
	     <tmpl_unless __FIRST__>
	     	<input type="checkbox" name="contentTypes" value="<tmpl_var value>"
		<tmpl_if type_content>
		   <tmpl_if query>
			<tmpl_if selected>checked="1"</tmpl_if>
		   <tmpl_else>
			checked="1"
		   </tmpl_if>
		<tmpl_else>
		   <tmpl_if selected>checked="1"</tmpl_if>
		</tmpl_if>
		><tmpl_var name>
		<br />
	     </tmpl_unless>
	   </tmpl_loop>
	</td>
        <td></td>
      </tbody>
      </form>
      </table>
      </td>
    </tr>
  </tbody>
</table>

<p />
<tmpl_if numberOfResults>
	<p>Results <tmpl_var startNr> - <tmpl_var endNr> of about <tmpl_var numberOfResults>
	containing <b>"<tmpl_var queryHighlighted>"</b>. Search took <b><tmpl_var duration></b> seconds.</p>
	<ol style="Margin-Top: 0px; Margin-Bottom: 0px;" start="<tmpl_var startNr>">
	<tmpl_loop resultsLoop>
		<li>
			<a href="<tmpl_var location>"><tmpl_if header><tmpl_var header><tmpl_else>No Title</tmpl_if></a>
			<div>
			<tmpl_if "body">
				<span class="preview"><tmpl_var "body"></span><br />
			</tmpl_if>
			<span style="color:#666666;">Location: <tmpl_var crumbTrail></span>
			<br />
			<br />
			</div>
		</li>
	</tmpl_loop>
	</ol>
</tmpl_if>

<tmpl_if pagination.pageCount.isMultiple>
	<div class="pagination">
		<tmpl_var pagination.previousPage> &middot; <tmpl_var pagination.pageList.upTo20> &middot; <tmpl_var pagination.nextPage>
	</div>
</tmpl_if>
END

$fixedTemplates{PBtmpl0000000000000047} = << 'END';
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>

<tmpl_if session.var.adminOn>
	<p><tmpl_var controls></p>
</tmpl_if>

<tmpl_if displayTitle>
	<h1><tmpl_var title></h1>
</tmpl_if>

<tmpl_if description>
	<tmpl_var description>
	<p />
</tmpl_if>

<tmpl_if session.var.adminOn>
	<a href="<tmpl_var forum.add.url>"><tmpl_var forum.add.label></a>
	<p />
</tmpl_if>

<tmpl_if areMultipleForums>
	<table width="100%" cellpadding="3" cellspacing="0">
		<tr>
			<tmpl_if session.var.adminOn>
				<td></td>
			</tmpl_if>
			<td class="tableHeader"><tmpl_var title.label></td>
			<td class="tableHeader"><tmpl_var views.label></td>
			<td class="tableHeader"><tmpl_var rating.label></td>
			<td class="tableHeader"><tmpl_var threads.label></td>
			<td class="tableHeader"><tmpl_var replies.label></td>
			<td class="tableHeader"><tmpl_var lastpost.label></td>
		</tr>
		<tmpl_loop forum_loop>
			<tr>
				<tmpl_if session.var.adminOn>
					<td><tmpl_var forum.controls></td>
				</tmpl_if>
				<td class="tableData">
					<a href="<tmpl_var forum.url>"><tmpl_var forum.title></a><br />
					<span style="font-size: 10px;"><tmpl_var forum.description></span>
				</td>
				<td class="tableData" align="center"><tmpl_var forum.views></td>
				<td class="tableData" align="center"><tmpl_var forum.rating></td>
				<td class="tableData" align="center"><tmpl_var forum.threads></td>
				<td class="tableData" align="center"><tmpl_var forum.replies></td>
				<td class="tableData"><span style="font-size: 10px;">
					<a href="<tmpl_var forum.lastpost.url>"><tmpl_var forum.lastpost.subject></a>
					by
					<tmpl_if forum.lastpost.user.isVisitor>
						<tmpl_var forum.lastpost.user.name>
					<tmpl_else>
						<a href="<tmpl_var forum.lastpost.user.profile>"><tmpl_var forum.lastpost.user.name></a>
					</tmpl_if>
					on <tmpl_var forum.lastpost.date> @ <tmpl_var forum.lastpost.time>
				</span></td>
			</tr>
		</tmpl_loop>
	</table>
<tmpl_else>
	<h2><tmpl_var default.title></h2>
	<tmpl_if session.var.adminOn>
		<tmpl_var default.controls><br />
	</tmpl_if>
	<tmpl_var default.description>
	<p />
	<tmpl_var default.listing>
</tmpl_if>
END

$fixedTemplates{PBtmpl0000000000000049} = << 'END';
<tmpl_var displayTitle>
<b><tmpl_var message.subject></b><br />
<tmpl_var message.dateOfEntry><br />
<tmpl_var message.status><br /><br />
<tmpl_var message.text><p />

<div class="accountOptions">
	<ul>
	<tmpl_if message.takeAction>
		<li><tmpl_var message.takeAction></li>
	</tmpl_if>
	<tmpl_loop message.accountOptions>
		<li><tmpl_var options.display></li>
	</tmpl_loop>
	</ul>
</div>
END

$fixedTemplates{PBtmpl0000000000000054} = << 'END';
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>

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

$fixedTemplates{PBtmpl0000000000000055} = << 'END';
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>

<tmpl_if session.var.adminOn>
	<p><tmpl_var controls></p>
</tmpl_if>

<tmpl_if displayTitle>
	<h1><tmpl_var title></h1>
</tmpl_if>

<tmpl_if description>
	<tmpl_var description>
	<p />
</tmpl_if>

<span class="pollQuestion"><tmpl_var question></span><br />

<tmpl_if canVote>
	<tmpl_var form.start>
	<tmpl_loop answer_loop>
		<tmpl_var answer.form> <tmpl_var answer.text><br />
	</tmpl_loop>
	<p />
	<tmpl_var form.submit>
	<tmpl_var form.end>
<tmpl_else>
	<tmpl_loop answer_loop>
		<span class="pollAnswer"><hr size="1"><tmpl_var answer.text><br /></span>
		<table cellpadding=0 cellspacing=0 border=0><tr>
			<td width="<tmpl_var answer.graphWidth>" class="pollColor"><img src="^Extras;spacer.gif" alt="" height="1" width="1" /></td>
			<td class="pollAnswer">&nbsp;&nbsp;<tmpl_var answer.percent>% (<tmpl_var answer.total>)</td>
		</tr></table>
	</tmpl_loop>
	<span class="pollAnswer"><hr size="1"><b><tmpl_var responses.label>:</b> <tmpl_var responses.total></span>
</tmpl_if>
END

$fixedTemplates{PBtmpl0000000000000056} = << 'END';
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>

<tmpl_if session.var.adminOn>
	<p><tmpl_var controls></p>
</tmpl_if>

<style type="text/css">

.productFeatureHeader, .productSpecificationHeader, .productRelatedHeader, .productAccessoryHeader, .productBenefitHeader {
	font-weight: bold;
	font-size: 15px;
}

.productFeature, .productSpecification, .productRelated, .productAccessory, .productBenefit {
	font-size: 12px;
}

.productAttributeSeperator {
	background-color: black;
}

</style>

<tmpl_if displayTitle>
	<h1><tmpl_var title></h1>
</tmpl_if>

<table width="100%" cellpadding="3" cellspacing="0" border="0">
<tr>
	<td class="content" valign="top">
		<tmpl_if description><tmpl_var description><p /></tmpl_if>
		<tmpl_if price><b>Price:</b> <tmpl_var price><br /></tmpl_if>
		<tmpl_if productnumber><b>Product Number:</b> <tmpl_var productNumber><br /></tmpl_if>
		<br />
		<tmpl_if brochure.url><a href="<tmpl_var brochure.url>"><img src="<tmpl_var brochure.icon>" alt="<tmpl_var brochure.icon>" border=0 align="absmiddle" /><tmpl_var brochure.label></a><br /></tmpl_if>
		<tmpl_if manual.url><a href="<tmpl_var manual.url>"><img src="<tmpl_var manual.icon>" alt="<tmpl_var manual.icon>" border=0 align="absmiddle" /><tmpl_var manual.label></a><br /></tmpl_if>
		<tmpl_if warranty.url><a href="<tmpl_var warranty.url>"><img src="<tmpl_var warranty.icon>" alt="<tmpl_var warranty.icon>" border=0 align="absmiddle" /><tmpl_var warranty.label></a><br /></tmpl_if>
	</td>
	<td valign="top">
		<tmpl_if thumbnail1><a href="<tmpl_var image1>"><img src="<tmpl_var thumbnail1>" alt="<tmpl_var thumbnail1>" border="0" /></a><p /></tmpl_if>
		<tmpl_if thumbnail2><a href="<tmpl_var image2>"><img src="<tmpl_var thumbnail2>" alt="<tmpl_var thumbnail2>" border="0" /></a><p /></tmpl_if>
		<tmpl_if thumbnail3><a href="<tmpl_var image3>"><img src="<tmpl_var thumbnail3>" alt="<tmpl_var thumbnail3>" border="0" /></a><p /></tmpl_if>
	</td>
</tr>
</table>

<table border="0" cellpadding="0" cellspacing="5">
<tr>
	<td valign="top" class="productFeature">
		<div class="productFeatureHeader">Features</div>
		<tmpl_if session.var.adminOn><a href="<tmpl_var addfeature.url>"><tmpl_var addfeature.label></a><p /></tmpl_if>
		<tmpl_loop feature_loop>
			<tmpl_if session.var.adminOn><tmpl_var feature.controls></tmpl_if>
			<tmpl_var feature.feature><br />
		</tmpl_loop>
		<p />
	</td>
	<td class="productAttributeSeperator">
		<img src="^Extras;spacer.gif" alt="" width="1" height="1" />
	</td>
	<td valign="top" class="productBenefit">
		<div class="productBenefitHeader">Benefits</div>
		<tmpl_if session.var.adminOn><a href="<tmpl_var addBenefit.url>"><tmpl_var addBenefit.label></a><p /></tmpl_if>
		<tmpl_loop benefit_loop>
			<tmpl_if session.var.adminOn><tmpl_var benefit.controls></tmpl_if>
			<tmpl_var benefit.benefit><br />
		</tmpl_loop>
		<p />
	</td>
	<td class="productAttributeSeperator">
		<img src="^Extras;spacer.gif" alt="" width="1" height="1" />
	</td>
	<td valign="top" class="productSpecification">
		<div class="productSpecificationHeader">Specifications</div>
		<tmpl_if session.var.adminOn><a href="<tmpl_var addSpecification.url>"><tmpl_var addSpecification.label></a><p /></tmpl_if>
		<tmpl_loop specification_loop>
			<tmpl_if session.var.adminOn><tmpl_var specification.controls></tmpl_if>
			<b><tmpl_var specification.label>:</b> <tmpl_var specification.specification> <tmpl_var specification.units><br />
		</tmpl_loop>
		<p />
	</td>
	<td class="productAttributeSeperator">
		<img src="^Extras;spacer.gif" alt="" width="1" height="1" />
	</td>
	<td valign="top" class="productAccessory">
		<div class="productAccessoryHeader">Accessories</div>
		<tmpl_if session.var.adminOn><a href="<tmpl_var addaccessory.url>"><tmpl_var addaccessory.label></a><p /></tmpl_if>
		<tmpl_loop accessory_loop>
			<tmpl_if session.var.adminOn><tmpl_var accessory.controls></tmpl_if>
			<a href="<tmpl_var accessory.url>"><tmpl_var accessory.title></a><br />
		</tmpl_loop>
		<p />
	</td>
	<td class="productAttributeSeperator">
		<img src="^Extras;spacer.gif" alt="" width="1" height="1" />
	</td>
	<td valign="top" class="productRelated">
		<div class="productRelatedHeader">Related Products</div>
		<tmpl_if session.var.adminOn><a href="<tmpl_var addRelatedProduct.url>"><tmpl_var addRelatedProduct.label></a><p /></tmpl_if>
		<tmpl_loop relatedproduct_loop>
			<tmpl_if session.var.adminOn><tmpl_var RelatedProduct.controls></tmpl_if>
			<a href="<tmpl_var relatedproduct.url>"><tmpl_var relatedproduct.title></a><br />
		</tmpl_loop>
	</td>
</tr>
</table>
END

$fixedTemplates{PBtmpl0000000000000059} = << 'END';
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>

<tmpl_if session.var.adminOn>
	<p><tmpl_var controls></p>
</tmpl_if>

<tmpl_if displayTitle>
	<h1><tmpl_var title></h1>
</tmpl_if>

<tmpl_if description>
	<tmpl_var description>
	<p />
</tmpl_if>

<tmpl_if debugMode>
	<ul>
	<tmpl_loop debug_loop>
		<li><tmpl_var debug.output></li>
	</tmpl_loop>
	</ul>
</tmpl_if>

<table width="100%" cellspacing=0 cellpadding=0 style="border: 1px solid black;">
<tr>
<tmpl_loop columns_loop>
	<td class="tableHeader"><tmpl_var column.name></td>
</tmpl_loop>
</tr>
<tmpl_loop rows_loop>
	<tr>
	<tmpl_loop row.field_loop>
		<td class="tableData"><tmpl_var field.value></td>
	</tmpl_loop>
	</tr>
	<!-- Handle nested query2 -->
	<tmpl_if hasNest>
		<tr>
		<td colspan="<tmpl_var columns.count>">
		<table width="100%" cellspacing=0 cellpadding=0>
		<tr>
		<td width="20">&nbsp;</td>
		<td>
		<table width="100%" cellspacing=0 cellpadding=0 style="border: 1px solid black;">
		<tr>
		<tmpl_loop query2.columns_loop>
			<td class="tableHeader"><tmpl_var column.name></td>
		</tmpl_loop>
		</tr>
		<tmpl_loop query2.rows_loop>
			<tr>
			<tmpl_loop query2.row.field_loop>
				<td class="tableData"><tmpl_var field.value></td>
			</tmpl_loop>
			</tr>
			<!-- Handle nested query3 -->
			<tmpl_if query2.hasNest>
				<tr>
				<td colspan="<tmpl_var query2.columns.count>">
				<table width="100%" cellspacing=0 cellpadding=0>
				<tr>
				<td width="20">&nbsp;</td>
				<td>
				<table width="100%" cellspacing=0 cellpadding=0 style="border: 1px solid black;">
				<tr>
				<tmpl_loop query3.columns_loop>
					<td class="tableHeader"><tmpl_var column.name></td>
				</tmpl_loop>
				</tr>
				<tmpl_loop query3.rows_loop>
					<tr>
					<tmpl_loop query3.row.field_loop>
						<td class="tableData"><tmpl_var field.value></td>
					</tmpl_loop>
					</tr>
		   			<!-- Handle nested query4 -->
					<tmpl_if query3.hasNest>
						<tr>
						<td colspan="<tmpl_var query3.columns.count>">
						<table width="100%" cellspacing=0 cellpadding=0>
						<tr>
						<td width="20">&nbsp;</td>
						<td>
						<table width="100%" cellspacing=0 cellpadding=0 style="border: 1px solid black;">
						<tr>
						<tmpl_loop query4.columns_loop>
							<td class="tableHeader"><tmpl_var column.name></td>
						</tmpl_loop>
						</tr>
						<tmpl_loop query4.rows_loop>
							<tr>
							<tmpl_loop query4.row.field_loop>
								<td class="tableData"><tmpl_var field.value></td>
							</tmpl_loop>
				   			<!-- Handle nested query5 -->
							<tmpl_if query4.hasNest>
								<tr>
								<td colspan="<tmpl_var query4.columns.count>">
								<table width="100%" cellspacing=0 cellpadding=0>
								<tr>
								<td width="20">&nbsp;</td>
								<td>
								<table width="100%" cellspacing=0 cellpadding=0 style="border: 1px solid black;">
								<tr>
								<tmpl_loop query5.columns_loop>
									<td class="tableHeader"><tmpl_var column.name></td>
								</tmpl_loop>
								</tr>
								<tmpl_loop query5.rows_loop>
									<tr>
									<tmpl_loop query5.row.field_loop>
										<td class="tableData"><tmpl_var field.value></td>
									</tmpl_loop>
									</tr>
								</tmpl_loop>
								</table>
								</td>
								</tr>
								</table>
						        	</td>
				        			</tr>
							</tmpl_if>
							</tr>
						</tmpl_loop>
						</table>
						</td>
						</tr>
						</table>
				        	</td>
				        	</tr>
					</tmpl_if>
				</tmpl_loop>
				</table>
				</td>
				</tr>
				</table>
			        </td>
			        </tr>
			</tmpl_if>
		</tmpl_loop>
		</table>
		</td>
		</tr>
		</table>
		</td>
		</tr>
	</tmpl_if>
</tmpl_loop>
</table>

<tmpl_if pagination.pageCount.isMultiple>
	<div class="pagination">
		<tmpl_var pagination.previousPage> <tmpl_var pagination.pageList.upTo20> <tmpl_var pagination.nextPage>
	</div>
</tmpl_if>
END

$fixedTemplates{PBtmpl0000000000000060} = << 'END';
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
	"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<title>^Page("title"); - WebGUI</title>
	<tmpl_var head.tags>
	<style type="text/css">

div.topwrapper {
	position: relative;
}

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

	<div class="topwrapper">

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

	</div>

</body>
</html>
END

$fixedTemplates{PBtmpl0000000000000061} = << 'END';
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>

<tmpl_if session.var.adminOn>
	<p><tmpl_var controls></p>
</tmpl_if>

<tmpl_if displayTitle>
	<h1><tmpl_var title></h1>
</tmpl_if>

<tmpl_if description>
	<tmpl_var description>
	<p />
</tmpl_if>

<tmpl_if user.canTakeSurvey>
	<tmpl_if response.isComplete>
		<tmpl_if mode.isSurvey>
			<tmpl_var thanks.survey.label>
		<tmpl_else>
			<tmpl_var thanks.quiz.label>
			<div align="center">
				<b><tmpl_var questions.correct.count.label>:</b> <tmpl_var questions.correct.count> / <tmpl_var questions.total>
				<br />
				<b><tmpl_var questions.correct.percent.label>:</b><tmpl_var questions.correct.percent>%
			</div>
		</tmpl_if>
		<tmpl_if user.canRespondAgain>
			<br /><br /><a href="<tmpl_var start.newResponse.url>"><tmpl_var start.newResponse.label></a>
		</tmpl_if>
	<tmpl_else>
		<tmpl_if response.id>
			<tmpl_var form.header>
			<table width="100%" cellpadding="3" cellspacing="0" border="0" class="content">
				<tr>
					<td valign="top">
					<tmpl_loop question_loop>
						<p><tmpl_var question.question></p>
						<tmpl_var question.answer.label><br />
						<tmpl_var question.answer.field><br />
						<br />
						<tmpl_if question.allowComment>
							<tmpl_var question.comment.label><br />
							<tmpl_var question.comment.field><br />
						</tmpl_if>
					</tmpl_loop>
					</td>
					<td valign="top" nowrap="1">
						<b><tmpl_var questions.sofar.label>:</b> <tmpl_var questions.sofar.count> / <tmpl_var questions.total> <br />
						<tmpl_unless mode.isSurvey>
							<b><tmpl_var questions.correct.count.label>:</b> <tmpl_var questions.correct.count> / <tmpl_var questions.sofar.count><br />
							<b><tmpl_var questions.correct.percent.label>:</b><tmpl_var questions.correct.percent>% / 100%<br />
						</tmpl_unless>
					</td>
				</tr>
			</table>
			<div align="center"><tmpl_var form.submit></div>
			<tmpl_var form.footer>
		<tmpl_else>
			<a href="<tmpl_var start.newResponse.url>"><tmpl_var start.newResponse.label></a>
		</tmpl_if>
	</tmpl_if>
<tmpl_else>
	<tmpl_if mode.isSurvey>
		<tmpl_var survey.noprivs.label>
	<tmpl_else>
		<tmpl_var quiz.noprivs.label>
	</tmpl_if>
</tmpl_if>
<br />
<br />
<tmpl_if user.canViewReports>
	<a href="<tmpl_var report.gradebook.url>"><tmpl_var report.gradebook.label></a>
	&bull;
	<a href="<tmpl_var report.overview.url>"><tmpl_var report.overview.label></a>
	&bull;
	<a href="<tmpl_var delete.all.responses.url>"><tmpl_var delete.all.responses.label></a>
	<br />
	<a href="<tmpl_var export.answers.url>"><tmpl_var export.answers.label></a>
	&bull;
	<a href="<tmpl_var export.questions.url>"><tmpl_var export.questions.label></a>
	&bull;
	<a href="<tmpl_var export.responses.url>"><tmpl_var export.responses.label></a>
	&bull;
	<a href="<tmpl_var export.composite.url>"><tmpl_var export.composite.label></a>
</tmpl_if>

<tmpl_if session.var.adminOn>
	<p><a href="<tmpl_var section.add.url>"><tmpl_var section.add.label></a></p>
	<p><a href="<tmpl_var question.add.url>"><tmpl_var question.add.label></a></p>
<tmpl_loop section.edit_loop>
<tmpl_var section.edit.controls>
<tmpl_var section.edit.sectionName><br /><br />
	<tmpl_loop section.questions_loop>
		&nbsp;&nbsp;<tmpl_var question.edit.controls>
          	<tmpl_var question.edit.question>
		<br />
        </tmpl_loop>
</tmpl_loop>
</tmpl_if>
END

$fixedTemplates{PBtmpl0000000000000063} = << 'END';
<h1><tmpl_var title></h1>

<tmpl_if user.canViewReports>
	<a href="<tmpl_var survey.url>"><tmpl_var survey.label></a>
	&bull;
	<a href="<tmpl_var report.gradebook.url>"><tmpl_var report.gradebook.label></a>
	&bull;
	<a href="<tmpl_var delete.all.responses.url>"><tmpl_var delete.all.responses.label></a>
	<br />
	<a href="<tmpl_var export.answers.url>"><tmpl_var export.answers.label></a>
	&bull;
	<a href="<tmpl_var export.questions.url>"><tmpl_var export.questions.label></a>
	&bull;
	<a href="<tmpl_var export.responses.url>"><tmpl_var export.responses.label></a>
	&bull;
	<a href="<tmpl_var export.composite.url>"><tmpl_var export.composite.label></a>
</tmpl_if>

<br />
<br />

<script type="text/javascript" defer="defer">
<!--
function toggleDiv(divId) {
   if (document.getElementById(divId).style.visibility == "none") {
	document.getElementById(divId).style.display = "block";
   } else {
	document.getElementById(divId).style.display = "none";
   }
}
//-->
</script>

<tmpl_loop question_loop>
	<b><tmpl_var question></b>
	<tmpl_if question.isRadioList>
		<table class="tableData">
		<tr class="tableHeader"><td width="60%"><tmpl_var answer.label></td>
		<td width="20%"><tmpl_var response.count.label></td>
		<td width="20%"><tmpl_var response.percent.label></td></tr>
		<tmpl_loop answer_loop>
			<tmpl_if answer.isCorrect>
				<tr class="highlight">
			<tmpl_else>
				<tr>
			</tmpl_if>
			<td><tmpl_var answer></td>
			<td><tmpl_var answer.response.count></td>
			<td><tmpl_var answer.response.percent></td>
			<tmpl_if allowComment>
				<td><a href="#" onclick="toggle('comment<tmpl_var answer.id>');"><tmpl_var show.comments.label></a></td>
			</tmpl_if>
			</tr>
			<tmpl_if question.allowComment>
				<tr id="comment<tmpl_var answer.id>">
				<td colspan="3">
				<tmpl_loop comment_loop>
					<p><tmpl_var answer.comment></p>
				</tmpl_loop>
				</td>
				</tr>
			</tmpl_if>
		</tmpl_loop>
		</table>
	<tmpl_else>
		<br />
		<a href="#" onclick="toggle('response<tmpl_var question.id>');"><tmpl_var show.answers.label></a>
		<br />
		<div id="response<tmpl_var question.id>">
		<tmpl_loop answer_loop>
			<p><tmpl_var answer.response></p>
			<tmpl_if question.allowComment>
				<blockquote><tmpl_var answer.comment></blockquote>
			</tmpl_if>
		</tmpl_loop>
		</div>
	</tmpl_if>
	<br /><br /><br />
</tmpl_loop>

<tmpl_if pagination.pageCount.isMultiple>
	<div class="pagination">
		<tmpl_var pagination.previousPage> &middot; <tmpl_var pagination.pageList.upTo20> &middot; <tmpl_var pagination.nextPage>
	</div>
</tmpl_if>
END

$fixedTemplates{PBtmpl0000000000000065} = << 'END';
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>

<tmpl_if session.var.adminOn>
	<p><tmpl_var controls></p>
</tmpl_if>

<tmpl_if displayTitle>
	<h1><tmpl_var title></h1>
</tmpl_if>

<tmpl_if description>
	<tmpl_var description>
	<p />
</tmpl_if>

<h1>
<tmpl_if channel.link>
	<a href="<tmpl_var channel.link>" target="_blank"><tmpl_var channel.title></a>
<tmpl_else>
	<tmpl_var channel.title>
</tmpl_if>
</h1>

<tmpl_if channel.description>
	<tmpl_var channel.description>
	<p />
</tmpl_if>

<tmpl_loop item_loop>
<li>
	<tmpl_if link>
		<a href="<tmpl_var link>" target="_blank"><tmpl_var title></a>
	<tmpl_else>
		<tmpl_var title>
	</tmpl_if>
	<tmpl_if description>
		- <tmpl_var description>
	</tmpl_if>
	<br />
</tmpl_loop>
END

$fixedTemplates{PBtmpl0000000000000066} = << 'END';
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>

<tmpl_if session.var.adminOn>
	<tmpl_var controls>
</tmpl_if>

<style type="text/css">

.forumHead {
	background-color: #eeeeee;
	border-bottom: 1px solid #cccccc;
	padding: 2px;
	padding-bottom: 4px;
	font-size: 13px;
	font-weight: bold;
}

.oddThread {
	font-size: 13px;
	border-bottom: 1px dashed #83cc83;
	padding-bottom: 4px;
}

.evenThread {
	font-size: 13px;
	border-bottom: 1px dashed #aaaaff;
	padding-bottom: 4px;
}

</style>

<tmpl_if displayTitle>
	<h1><tmpl_var title></h1>
</tmpl_if>

<tmpl_if description>
	<tmpl_var description>
</tmpl_if>

<p>
	<tmpl_if user.canPost>
		<a href="<tmpl_var add.url>"><tmpl_var add.label></a>
		&bull;
	</tmpl_if>
	<tmpl_unless user.isVisitor>
		<tmpl_if user.isSubscribed>
			<a href="<tmpl_var unsubscribe.url>"><tmpl_var unsubscribe.label></a>
		<tmpl_else>
			<a href="<tmpl_var subscribe.url>"><tmpl_var subscribe.label></a>
		</tmpl_if>
		&bull;
	</tmpl_unless>
	<a href="<tmpl_var search.url>"><tmpl_var search.label></a>
</p>

<table width="100%">
<tr>
	<tmpl_if user.isModerator>
		<td class="forumHead"><tmpl_var status.label></td>
	</tmpl_if>
	<td class="forumHead"><a href="<tmpl_var sortby.title.url>"><tmpl_var title.label></a></td>
	<td class="forumHead"><a href="<tmpl_var sortby.date.url>"><tmpl_var date.label></a></td>
	<td class="forumHead"><a href="<tmpl_var sortby.username.url>"><tmpl_var by.label></a></td>
</tr>
<tmpl_loop post_loop>
<tr>
	<tmpl_if user.isModerator>
		<td class="<tmpl_if __ODD__>oddThread<tmpl_else>evenThread</tmpl_if>"><tmpl_var status></td>
	</tmpl_if>
	<td class="<tmpl_if __ODD__>oddThread<tmpl_else>evenThread</tmpl_if>"><a href="<tmpl_var url>"><tmpl_var title></a><tmpl_if user.isPoster> (<tmpl_var status>)</tmpl_if></td>
	<td class="<tmpl_if __ODD__>oddThread<tmpl_else>evenThread</tmpl_if>"><tmpl_var dateUpdated.human></td>
	<tmpl_if user.isVisitor>
		<td class="<tmpl_if __ODD__>oddThread<tmpl_else>evenThread</tmpl_if>"><tmpl_var username></td>
	<tmpl_else>
		<td class="<tmpl_if __ODD__>oddThread<tmpl_else>evenThread</tmpl_if>"><a href="<tmpl_var userProfile.url>"><tmpl_var username></a></td>
	</tmpl_if>
</tr>
</tmpl_loop>
</table>

<tmpl_if pagination.pageCount.isMultiple>
	<div class="pagination">
		<tmpl_var pagination.previousPage> &middot; <tmpl_var pagination.pageList.upTo10> &middot; <tmpl_var pagination.nextPage>
	</div>
</tmpl_if>
END

$fixedTemplates{PBtmpl0000000000000067} = << 'END';
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a> 

<tmpl_if session.var.adminOn> 
	<p><tmpl_var controls></p>
</tmpl_if>

<h1><tmpl_var title></h1>

<div style="float: right; font-size: 11px; border: 1px solid #cccccc; padding: 2px; margin: 2px;">
	<b><tmpl_var user.label>:</b> 
		<tmpl_if user.isVisitor>
			<tmpl_var username>
		<tmpl_else>
			<a href="<tmpl_var userProfile.url>"><tmpl_var username></a>
		</tmpl_if>
		<br />
	<b><tmpl_var date.label>:</b> <tmpl_var dateSubmitted.human><br />
	<b><tmpl_var views.label>:</b> <tmpl_var views><br />
	<b><tmpl_var rating.label>:</b> <tmpl_var rating>
		<tmpl_unless hasRated>
			 &nbsp; &nbsp;<tmpl_var rate.label> [ <a href="<tmpl_var rate.url.1>">1</a>, <a href="<tmpl_var rate.url.2>">2</a>, <a href="<tmpl_var rate.url.3>">3</a>, <a href="<tmpl_var rate.url.4>">4</a>, <a href="<tmpl_var rate.url.5>">5</a> ]
		</tmpl_unless>
		<br />
	<tmpl_if user.isModerator>
		<b><tmpl_var status.label>:</b> <tmpl_var status> &nbsp; &nbsp; [ <a href="<tmpl_var approve.url>"><tmpl_var approve.label></a> | <a href="<tmpl_var deny.url>"><tmpl_var deny.label></a> ]<br />
	<tmpl_else>	
		<tmpl_if user.isPoster>
			<b><tmpl_var status.label>:</b> <tmpl_var status><br />
		</tmpl_if>	
	</tmpl_if>	
</div>

<tmpl_var content>

<tmpl_if attachment_loop>
	<br />
		<tmpl_loop attachment_loop>
			<div style="float: left; padding: 5px;">
				<a href="<tmpl_var url>"><tmpl_if isImage><img src="<tmpl_var thumbnail>" border="0" alt="<tmpl_var filename>" /><tmpl_else><img src="<tmpl_var icon>" border="0" alt="<tmpl_var filename>" align="middle" /> <tmpl_var filename></tmpl_if></a>
			</div>
		</tmpl_loop>
		<div style="clear: both;"></div>
	<br />
</tmpl_if>

<tmpl_if userDefined1>
	<p><tmpl_var userDefined1></p>
</tmpl_if>

<tmpl_if userDefined2>
	<p><tmpl_var userDefined2></p>
</tmpl_if>
	
<tmpl_if userDefined3>
	<p><tmpl_var userDefined3></p>
</tmpl_if>

<tmpl_if userDefined4>
	<p><tmpl_var userDefined4></p>
</tmpl_if>

<tmpl_if userDefined5>
	<p><tmpl_var userDefined5></p>
</tmpl_if>

<tmpl_unless isLocked>
	<p>
		<tmpl_if user.canReply>
			<a href="<tmpl_var reply.url>">[<tmpl_var reply.label>]</a>
		</tmpl_if>
		<tmpl_if user.canEdit>
			<a href="<tmpl_var edit.url>">[<tmpl_var edit.label>]</a>
			<a href="<tmpl_var delete.url>">[<tmpl_var delete.label>]</a>
		</tmpl_if>
	</p>
</tmpl_unless>

<tmpl_if repliesAllowed>
	<style type="text/css">
		.postBorder {
			border: 1px solid #cccccc;
			margin-bottom: 10px;
		}
		.postBorderCurrent {
			border: 3px dotted black;
			margin-bottom: 10px;
		}
		.postSubject {
			border-bottom: 1px solid #cccccc;
			font-weight: bold;
			padding: 3px;
		}
		.postData {
			border-bottom: 1px solid #cccccc;
			font-size: 11px;
			background-color: #eeeeee;
			color: black;
			padding: 3px;
		}
		.postControls {
			border-top: 1px solid #cccccc;
			background-color: #eeeeee;
			color: black;
			padding: 3px;
		}
		.postMessage {
			padding: 3px;
		}
		.currentThread {
			background-color: #eeeeee;
		}
		.threadHead {
			font-weight: bold;
			border-bottom: 1px solid #cccccc;
			font-size: 11px;
			background-color: #eeeeee;
			color: black;
			padding: 3px;
		}
		.threadData {
			font-size: 11px;
			padding: 3px;
		}
	</style>

	<div style="float: left; width: 70%">
		<h1><tmpl_var replies.label></h1>
	</div>
	<div style="width: 30%; float: left; text-align: right;">
	<tmpl_if layout.isFlat>
		<a href="<tmpl_var layout.nested.url>"><tmpl_var layout.nested.label></a>
	<tmpl_else>
		<a href="<tmpl_var layout.flat.url>"><tmpl_var layout.flat.label></a>
	</tmpl_if>
	</div>
	<div style="clear: both;"></div>
	
	<tmpl_if layout.isFlat>
	<!-- begin flat layout -->
		<tmpl_loop post_loop>
			<tmpl_unless isThreadRoot>
				<div class="postBorder<tmpl_if isCurrent>Current</tmpl_if>">
					<a name="<tmpl_var assetId>"></a>
					<div class="postSubject">
						<tmpl_var title>
					</div>
					<div class="postData">
						<div style="float: left; width: 50%">
							<b><tmpl_var user.label>:</b> 
								<tmpl_if user.isVisitor>
									<tmpl_var username>
								<tmpl_else>
									<a href="<tmpl_var userProfile.url>"><tmpl_var username></a>
								</tmpl_if>
								<br />
							<b><tmpl_var date.label>:</b> <tmpl_var dateSubmitted.human><br />
						</div>	
						<div>
							<b><tmpl_var views.label>:</b> <tmpl_var views><br />
							<b><tmpl_var rating.label>:</b> <tmpl_var rating>
								<tmpl_unless hasRated>
									 &nbsp; &nbsp;<tmpl_var rate.label> [ <a href="<tmpl_var rate.url.1>">1</a>, <a href="<tmpl_var rate.url.2>">2</a>, <a href="<tmpl_var rate.url.3>">3</a>, <a href="<tmpl_var rate.url.4>">4</a>, <a href="<tmpl_var rate.url.5>">5</a> ]
								</tmpl_unless>
								<br />
							<tmpl_if user.isModerator>
								<b><tmpl_var status.label>:</b> <tmpl_var status> &nbsp; &nbsp; [ <a href="<tmpl_var approve.url>"><tmpl_var approve.label></a> | <a href="<tmpl_var deny.url>"><tmpl_var deny.label></a> ]<br />
							<tmpl_else>	
								<tmpl_if user.isPoster>
									<b><tmpl_var status.label>:</b> <tmpl_var status><br />
								</tmpl_if>	
							</tmpl_if>	
						</div>	
					</div>
					<div class="postMessage">
						<tmpl_var content>
						<tmpl_loop attachment_loop>
							<div style="float: left; padding: 5px;"><a href="<tmpl_var url>"><tmpl_if isImage><img src="<tmpl_var thumbnail>" border="0" alt="<tmpl_var filename>" /><tmpl_else><img src="<tmpl_var icon>" border="0" alt="<tmpl_var filename>" align="middle" /> <tmpl_var filename></tmpl_if></a></div>
						</tmpl_loop>
						<div style="clear: both;"></div>
					</div>
					<tmpl_unless isLocked>
						<div class="postControls">
							<tmpl_if user.canReply>
								<a href="<tmpl_var reply.url>">[<tmpl_var reply.label>]</a>
							</tmpl_if>
							<tmpl_if user.canEdit>
								<a href="<tmpl_var edit.url>">[<tmpl_var edit.label>]</a>
								<a href="<tmpl_var delete.url>">[<tmpl_var delete.label>]</a>
							</tmpl_if>
						</div>
					</tmpl_unless>
				</div>
			</tmpl_unless>
		</tmpl_loop>
	<!-- end flat layout -->
	</tmpl_if>
	
	<tmpl_if layout.isNested>
	<!-- begin nested layout -->
		<tmpl_loop post_loop>
			<tmpl_unless isThreadRoot>
				<div style="margin-left: <tmpl_var depthX10>px;">
					<div class="postBorder<tmpl_if isCurrent>Current</tmpl_if>">
						<a name="<tmpl_var assetId>"></a>
						<div class="postSubject">
							<tmpl_var title>
						</div>
						<div class="postData">
							<div style="float: left; width: 50%">
								<b><tmpl_var user.label>:</b> 
									<tmpl_if user.isVisitor>
										<tmpl_var username>
									<tmpl_else>
										<a href="<tmpl_var userProfile.url>"><tmpl_var username></a>
									</tmpl_if>
									<br />
								<b><tmpl_var date.label>:</b> <tmpl_var dateSubmitted.human><br />
							</div>	
							<div>
								<b><tmpl_var views.label>:</b> <tmpl_var views><br />
								<b><tmpl_var rating.label>:</b> <tmpl_var rating>
									<tmpl_unless hasRated>
										 &nbsp; &nbsp;<tmpl_var rate.label> [ <a href="<tmpl_var rate.url.1>">1</a>, <a href="<tmpl_var rate.url.2>">2</a>, <a href="<tmpl_var rate.url.3>">3</a>, <a href="<tmpl_var rate.url.4>">4</a>, <a href="<tmpl_var rate.url.5>">5</a> ]
									</tmpl_unless>
									<br />
								<tmpl_if user.isModerator>
									<b><tmpl_var status.label>:</b> <tmpl_var status> &nbsp; &nbsp; [ <a href="<tmpl_var approve.url>"><tmpl_var approve.label></a> | <a href="<tmpl_var deny.url>"><tmpl_var deny.label></a> ]<br />
								<tmpl_else>	
									<tmpl_if user.isPoster>
										<b><tmpl_var status.label>:</b> <tmpl_var status><br />
									</tmpl_if>	
								</tmpl_if>	
							</div>	
						</div>
						<div class="postMessage">
							<tmpl_var content>
							<tmpl_loop attachment_loop>
								<div style="float: left; padding: 5px;"><a href="<tmpl_var url>"><tmpl_if isImage><img src="<tmpl_var thumbnail>" border="0" alt="<tmpl_var filename>" /><tmpl_else><img src="<tmpl_var icon>" border="0" alt="<tmpl_var filename>" align="middle" /> <tmpl_var filename></tmpl_if></a></div>
							</tmpl_loop>
							<div style="clear: both;"></div>
						</div>
						<tmpl_unless isLocked>
							<div class="postControls">
								<tmpl_if user.canReply>
									<a href="<tmpl_var reply.url>">[<tmpl_var reply.label>]</a>
								</tmpl_if>
								<tmpl_if user.canEdit>
									<a href="<tmpl_var edit.url>">[<tmpl_var edit.label>]</a>
									<a href="<tmpl_var delete.url>">[<tmpl_var delete.label>]</a>
								</tmpl_if>
							</div>
						</tmpl_unless>
					</div>
				</div>
			</tmpl_unless>
		</tmpl_loop>
	<!-- end nested layout -->
	</tmpl_if>
	
	<tmpl_if pagination.pageCount.isMultiple>
		<div class="pagination" style="margin-top: 20px;">
			[ <tmpl_var pagination.previousPage> | <tmpl_var pagination.pageList.upTo10> | <tmpl_var pagination.nextPage> ]
		</div>
	</tmpl_if>
</tmpl_if>	

<div style="margin-top: 20px;">
	<tmpl_if previous.url>
		<a href="<tmpl_var previous.url>">[<tmpl_var previous.label>]</a> 
	</tmpl_if>	
	<a href="<tmpl_var collaboration.url>">[<tmpl_var back.label>]</a>
	<tmpl_if next.url>
		<a href="<tmpl_var next.url>">[<tmpl_var next.label>]</a> 
	</tmpl_if>	
	<tmpl_if user.canPost>
		<a href="<tmpl_var add.url>">[<tmpl_var add.label>]</a>
	</tmpl_if>
	<tmpl_if user.isModerator>
		<tmpl_if isSticky>
			<a href="<tmpl_var unstick.url>">[<tmpl_var unstick.label>]</a>
		<tmpl_else>
			<a href="<tmpl_var stick.url>">[<tmpl_var stick.label>]</a>
		</tmpl_if>
		<tmpl_if isLocked>
			<a href="<tmpl_var unlock.url>">[<tmpl_var unlock.label>]</a>
		<tmpl_else>
			<a href="<tmpl_var lock.url>">[<tmpl_var lock.label>]</a>
		</tmpl_if>
	</tmpl_if>
	<tmpl_unless user.isVisitor>
		<tmpl_if user.isSubscribed>
			<a href="<tmpl_var unsubscribe.url>">[<tmpl_var unsubscribe.label>]</a>
		<tmpl_else>
			<a href="<tmpl_var subscribe.url>">[<tmpl_var subscribe.label>]</a>
		</tmpl_if>
	</tmpl_unless>
</div>
END

$fixedTemplates{PBtmpl0000000000000068} = << 'END';
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>

<tmpl_if preview.title><p><b><tmpl_var preview.title></b></p></tmpl_if>
<tmpl_unless isReply><tmpl_if preview.synopsis><p><i><tmpl_var preview.synopsis></i></p></tmpl_if></tmpl_unless>
<tmpl_if preview.content><p><tmpl_var preview.content></p></tmpl_if>

<tmpl_if isReply>
	<h1><tmpl_var message.header.label></h1>
<tmpl_else>
	<h1><tmpl_var submission.header.label></h1>
</tmpl_if>

<tmpl_var form.header>
<table>
	<tmpl_if isNewPost>
		<tmpl_if user.isVisitor>
			<tr>
				<td><tmpl_var visitorName.label></td>
				<td><tmpl_var visitorName.form></td>
			</tr>
		</tmpl_if>
	</tmpl_if>
	<tr>
		<td><tmpl_var title.label></td>
		<td><tmpl_var title.form></td>
	</tr>
	<tmpl_unless isReply>
		<tr>
			<td><tmpl_var synopsis.label></td>
			<td><tmpl_var synopsis.form></td>
		</tr>
	</tmpl_unless>
	<tr>
		<td><tmpl_var body.label></td>
		<td><tmpl_var content.form></td>
	</tr>
	<tr>
		<td><tmpl_var contentType.label></td>
		<td><tmpl_var contentType.form></td>
	</tr>
	<tmpl_unless isReply>
		<tmpl_if attachment.form>
			<tr>
				<td><tmpl_var attachment.label></td>
				<td><tmpl_var attachment.form></td>
			</tr>
		</tmpl_if>
	</tmpl_unless>
	<tmpl_if isNewPost>
		<tmpl_unless user.isVisitor>
			<tr>
				<td><tmpl_var subscribe.label></td>
				<td><tmpl_var subscribe.form></td>
			</tr>
		</tmpl_unless>
		<tmpl_if isNewThread>
			<tmpl_if user.isModerator>
				<tr>
					<td><tmpl_var lock.label></td>
					<td><tmpl_var lock.form></td>
				</tr>
				<tr>
					<td><tmpl_var stick.label></td>
					<td><tmpl_var sticky.form></td>
				</tr>
			</tmpl_if>
		</tmpl_if>
	</tmpl_if>
	<tmpl_unless isReply>
		<tr>
			<td><tmpl_var startDate.label></td>
			<td><tmpl_var startDate.form></td>
		</tr>
		<tr>
			<td><tmpl_var endDate.label></td>
			<td><tmpl_var endDate.form></td>
		</tr>
	</tmpl_unless>
	<tr>
		<td></td>
		<td><tmpl_if usePreview><tmpl_var form.preview></tmpl_if><tmpl_var form.submit></td>
	</tr>
</table>
<tmpl_var form.footer>

<tmpl_if isReply>
	<p><b><tmpl_var reply.title></b></p>
	<tmpl_var reply.content>
</tmpl_if>
END

$fixedTemplates{PBtmpl0000000000000069} = << 'END';
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>

<tmpl_if session.var.adminOn>
	<p><tmpl_var controls></p>
</tmpl_if>

<h1><tmpl_var title></h1>

<tmpl_if description>
	<tmpl_var description><br /><br />
</tmpl_if>

<tmpl_if results>
	<tmpl_loop results>
		The current temp is: <tmpl_var result>
	</tmpl_loop>
<tmpl_else>
	Failed to retrieve temp.
</tmpl_if>
END

$fixedTemplates{PBtmpl0000000000000077} = << 'END';
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>

<tmpl_if session.var.adminOn>
	<p><tmpl_var controls></p>
</tmpl_if>

<style type="text/css">

.forumHead {
	background-color: #eeeeee;
	border-bottom: 1px solid #cccccc;
	padding: 2px;
	padding-bottom: 4px;
	font-size: 13px;
	font-weight: bold;
}

.oddThread {
	font-size: 13px;
	border-bottom: 1px dashed #83cc83;
	padding-bottom: 4px;
}

.evenThread {
	font-size: 13px;
	border-bottom: 1px dashed #aaaaff;
	padding-bottom: 4px;
}

</style>

<tmpl_if displayTitle>
	<h1><tmpl_var title></h1>
</tmpl_if>

<tmpl_if description>
	<tmpl_var description>
</tmpl_if>

<p>
	<tmpl_if user.canPost>
		<a href="<tmpl_var add.url>"><tmpl_var add.label></a>
		&bull;
	</tmpl_if>
	<tmpl_unless user.isVisitor>
		<tmpl_if user.isSubscribed>
			<a href="<tmpl_var unsubscribe.url>"><tmpl_var unsubscribe.label></a>
		<tmpl_else>
			<a href="<tmpl_var subscribe.url>"><tmpl_var subscribe.label></a>
		</tmpl_if>
		&bull;
	</tmpl_unless>
	<a href="<tmpl_var search.url>"><tmpl_var search.label></a>
</p>

<table width="100%">
<tr>
	<tmpl_if user.isModerator>
		<td class="forumHead"><tmpl_var status.label></td>
	</tmpl_if>
	<td class="forumHead"><tmpl_var job.title.label></td>
	<td class="forumHead"><tmpl_var location.label></td>
	<td class="forumHead"><tmpl_var compensation.label></td>
	<td class="forumHead"><tmpl_var date.label></td>
</tr>

<tmpl_loop post_loop>
<tr>
	<tmpl_if user.isModerator>
		<td class="<tmpl_if __ODD__>oddThread<tmpl_else>evenThread</tmpl_if>"><tmpl_var status></td>
	</tmpl_if>
	<td class="<tmpl_if __ODD__>oddThread<tmpl_else>evenThread</tmpl_if>"><a href="<tmpl_var url>"><tmpl_var title></a><tmpl_if user.isPoster> (<tmpl_var status>)</tmpl_if></td>
	<td class="<tmpl_if __ODD__>oddThread<tmpl_else>evenThread</tmpl_if>"><tmpl_var userDefined2></td>
	<td class="<tmpl_if __ODD__>oddThread<tmpl_else>evenThread</tmpl_if>"><tmpl_var userDefined1></td>
	<td class="<tmpl_if __ODD__>oddThread<tmpl_else>evenThread</tmpl_if>"><tmpl_var dateSubmitted.human></td>
</tr>
</tmpl_loop>
</table>

<tmpl_if pagination.pageCount.isMultiple>
	<div class="pagination">
		<tmpl_var pagination.previousPage> &middot; <tmpl_var pagination.pageList.upTo10> &middot; <tmpl_var pagination.nextPage>
	</div>
</tmpl_if>
END

$fixedTemplates{PBtmpl0000000000000078} = << 'END';
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>

<tmpl_if session.var.adminOn>
	<p><tmpl_var controls></p>
</tmpl_if>

<tmpl_if displayTitle>
	<h1><tmpl_var title></h1>
</tmpl_if>

<tmpl_if description>
	<tmpl_var description>
</tmpl_if>

<table width="100%" cellpadding="3" cellspacing="0" class="content">
<tmpl_loop subfolder_loop>
<tr>
    	<td class="tableData" valign="top">
		<a href="<tmpl_var url>"><img src="<tmpl_var icon.small>" border="0" alt="<tmpl_var title>" /></a> <a href="<tmpl_var url>"><tmpl_var title></a>
	</td>

	<td class="tableData" valign="top" colspan="3">
		<tmpl_var synopsis>
	</td>
</tr>
</tmpl_loop>

<tmpl_loop file_loop>
<tr>
 	<td valign="top" class="tableData">
		<tmpl_if session.var.adminOn>
			<tmpl_if canEdit>
				<tmpl_var controls>
			</tmpl_if>
		</tmpl_if>
		<a href="<tmpl_var url>"><img src="<tmpl_var icon.small>" border="0" alt="<tmpl_var title>" /></a> <a href="<tmpl_var url>"><tmpl_var title>
	</td>
   	<td class="tableData" valign="top">
		<tmpl_var synopsis>
	</td>
     	<td class="tableData" valign="top">
		^D("%z %Z",<tmpl_var date.epoch>);
	</td>
   	<td class="tableData" valign="top">
		<tmpl_var size>
	</td>
</tr>
</tmpl_loop>

</table>
END

$fixedTemplates{PBtmpl0000000000000079} = << 'END';
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>

<tmpl_if session.var.adminOn>
	<tmpl_var controls>
</tmpl_if>

<tmpl_if displayTitle>
	<h1><tmpl_var title></h1>
</tmpl_if>

<tmpl_if description>
	<tmpl_var description>
</tmpl_if>

<p>
	<tmpl_if user.canPost>
		<a href="<tmpl_var add.url>">[<tmpl_var add.label>]</a>
	</tmpl_if>
	<tmpl_unless user.isVisitor>
		<tmpl_if user.isSubscribed>
			<a href="<tmpl_var unsubscribe.url>">[<tmpl_var unsubscribe.label>]</a>
		<tmpl_else>
			<a href="<tmpl_var subscribe.url>">[<tmpl_var subscribe.label>]</a>
		</tmpl_if>
	</tmpl_unless>
	<tmpl_if pagination.pageCount.isMultiple>
		<a href="<tmpl_var search.url>">[<tmpl_var search.label>]</a>
	</tmpl_if>
</p>

<tmpl_loop post_loop>
	<tmpl_if user.isPoster>
		<tmpl_unless session.var.adminOn>
			<div>[<a href="<tmpl_var edit.url>"><tmpl_var edit.label></a>]</div>
		</tmpl_unless>
	</tmpl_if>
	<tmpl_if user.isModerator>
		<div>
			<tmpl_if session.var.adminOn>
				<tmpl_var controls>
			<tmpl_else>
				<tmpl_unless user.isPoster>
					<tmpl_unless session.var.adminOn>
						[<a href="<tmpl_var edit.url>"><tmpl_var edit.label></a>]
					</tmpl_unless>
				</tmpl_unless>
			</tmpl_if>
			(<a href="<tmpl_var url>"><tmpl_var status></a>)
		</div>
	</tmpl_if>
	<h2><tmpl_var title></h2>
	<tmpl_var content>
	<p />
</tmpl_loop>

<tmpl_if pagination.pageCount.isMultiple>
	<div class="pagination">
		<tmpl_var pagination.previousPage> &middot; <tmpl_var pagination.pageList.upTo10> &middot; <tmpl_var pagination.nextPage>
	</div>
</tmpl_if>
END

$fixedTemplates{PBtmpl0000000000000080} = << 'END';
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>

<tmpl_if session.var.adminOn>
	<tmpl_var controls>
</tmpl_if>

<tmpl_if displayTitle>
	<h1><tmpl_var title></h1>
</tmpl_if>

<tmpl_if description>
	<tmpl_var description>
</tmpl_if>

<p>
	<tmpl_if user.canPost>
		<a href="<tmpl_var add.url>">[<tmpl_var add.label>]</a>
	</tmpl_if>
	<tmpl_unless user.isVisitor>
		<tmpl_if user.isSubscribed>
			<a href="<tmpl_var unsubscribe.url>">[<tmpl_var unsubscribe.label>]</a>
		<tmpl_else>
			<a href="<tmpl_var subscribe.url>">[<tmpl_var subscribe.label>]</a>
		</tmpl_if>
	</tmpl_unless>
	<tmpl_if pagination.pageCount.isMultiple>
		<a href="<tmpl_var search.url>">[<tmpl_var search.label>]</a>
	</tmpl_if>
</p>

<ul>
	<tmpl_loop post_loop>
	   <li><a href="#<tmpl_var assetId>"><span class="faqQuestion"><tmpl_var title></span></a>
	</tmpl_loop>
</ul>

<tmpl_loop post_loop>
	<tmpl_if user.isPoster>
		<tmpl_unless session.var.adminOn>
			<div>[<a href="<tmpl_var edit.url>"><tmpl_var edit.label></a>]</div>
		</tmpl_unless>
	</tmpl_if>
	<tmpl_if user.isModerator>
		<div>
			<tmpl_if session.var.adminOn>
				<tmpl_var controls>
			<tmpl_else>
				<tmpl_unless user.isPoster>
					<tmpl_unless session.var.adminOn>
						[<a href="<tmpl_var edit.url>"><tmpl_var edit.label></a>]
					</tmpl_unless>
				</tmpl_unless>
			</tmpl_if>
			(<a href="<tmpl_var url>"><tmpl_var status></a>)
		</div>
	</tmpl_if>
	<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a><span class="faqQuestion"><tmpl_var title></span><br />
	<tmpl_var content>
	<p><a href="#top">[top]</a></p>
</tmpl_loop>

<tmpl_if pagination.pageCount.isMultiple>
	<div class="pagination">
		<tmpl_var pagination.previousPage>  &middot; <tmpl_var pagination.pageList.upTo10> &middot; <tmpl_var pagination.nextPage>
	</div>
</tmpl_if>
END

$fixedTemplates{PBtmpl0000000000000081} = << 'END';
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>

<tmpl_if session.var.adminOn>
	<tmpl_var controls>
</tmpl_if>

<tmpl_if displayTitle>
	<h1><tmpl_var title></h1>
</tmpl_if>

<tmpl_if description>
	<tmpl_var description>
</tmpl_if>

<p>
	<tmpl_if user.canPost>
		<a href="<tmpl_var add.url>">[<tmpl_var add.label>]</a>
	</tmpl_if>
	<tmpl_unless user.isVisitor>
		<tmpl_if user.isSubscribed>
			<a href="<tmpl_var unsubscribe.url>">[<tmpl_var unsubscribe.label>]</a>
		<tmpl_else>
			<a href="<tmpl_var subscribe.url>">[<tmpl_var subscribe.label>]</a>
		</tmpl_if>
	</tmpl_unless>
	<tmpl_if pagination.pageCount.isMultiple>
		<a href="<tmpl_var search.url>">[<tmpl_var search.label>]</a>
	</tmpl_if>
</p>

<tmpl_loop post_loop>
	<tmpl_if user.isPoster>
		<tmpl_unless session.var.adminOn>
			<div>[<a href="<tmpl_var edit.url>"><tmpl_var edit.label></a>]</div>
		</tmpl_unless>
	</tmpl_if>
	<tmpl_if user.isModerator>
		<div>
			<tmpl_if session.var.adminOn>
				<tmpl_var controls>
			<tmpl_else>
				<tmpl_unless user.isPoster>
					<tmpl_unless session.var.adminOn>
						[<a href="<tmpl_var edit.url>"><tmpl_var edit.label></a>]
					</tmpl_unless>
				</tmpl_unless>
			</tmpl_if>
			(<a href="<tmpl_var url>"><tmpl_var status></a>)
		</div>
	</tmpl_if>
	<b>Q: <tmpl_var title></span></b><br />
	A: <tmpl_var content>
	<p />
</tmpl_loop>

<tmpl_if pagination.pageCount.isMultiple>
	<div class="pagination">
		<tmpl_var pagination.previousPage> &middot; <tmpl_var pagination.pageList.upTo10> &middot; <tmpl_var pagination.nextPage>
	</div>
</tmpl_if>
END

$fixedTemplates{PBtmpl0000000000000082} = << 'END';
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>

<tmpl_if session.var.adminOn>
	<tmpl_var controls>
</tmpl_if>

<tmpl_if displayTitle>
	<h1><tmpl_var title></h1>
</tmpl_if>

<tmpl_if description>
	<tmpl_var description>
</tmpl_if>

<p>
	<tmpl_if user.canPost>
		<a href="<tmpl_var add.url>">[<tmpl_var add.label>]</a>
	</tmpl_if>
	<tmpl_unless user.isVisitor>
		<tmpl_if user.isSubscribed>
			<a href="<tmpl_var unsubscribe.url>">[<tmpl_var unsubscribe.label>]</a>
		<tmpl_else>
			<a href="<tmpl_var subscribe.url>">[<tmpl_var subscribe.label>]</a>
		</tmpl_if>
	</tmpl_unless>
	<tmpl_if pagination.pageCount.isMultiple>
		<a href="<tmpl_var search.url>">[<tmpl_var search.label>]</a>
	</tmpl_if>
</p>

<ul>
	<tmpl_loop post_loop>
		<li>
			<tmpl_if user.isPoster>
				<tmpl_unless session.var.adminOn>
					[<a href="<tmpl_var edit.url>"><tmpl_var edit.label></a>]
				</tmpl_unless>
			</tmpl_if>
			<tmpl_if user.isModerator>
				<tmpl_if session.var.adminOn>
					<tmpl_var controls>
				<tmpl_else>
					<tmpl_unless user.isPoster>
						<tmpl_unless session.var.adminOn>
							[<a href="<tmpl_var edit.url>"><tmpl_var edit.label></a>]
						</tmpl_unless>
					</tmpl_unless>
				</tmpl_if>
				(<a href="<tmpl_var url>"><tmpl_var status></a>)
			</tmpl_if>
			<tmpl_if userDefined1><a href="<tmpl_var userDefined1>"	<tmpl_if userDefined2>target="_blank"</tmpl_if>></tmpl_if><tmpl_var title><tmpl_if userDefined1></a></tmpl_if>
			<tmpl_if content>
					  - <tmpl_var content>
			</tmpl_if>
		</li>
	</tmpl_loop>
</ul>

<tmpl_if pagination.pageCount.isMultiple>
	<div class="pagination">
		<tmpl_var pagination.previousPage>  &middot; <tmpl_var pagination.pageList.upTo10> &middot; <tmpl_var pagination.nextPage>
	</div>
</tmpl_if>
END

$fixedTemplates{PBtmpl0000000000000083} = << 'END';
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>

<tmpl_if session.var.adminOn>
	<tmpl_var controls>
</tmpl_if>

<tmpl_if displayTitle>
	<h1><tmpl_var title></h1>
</tmpl_if>

<tmpl_if description>
	<tmpl_var description>
</tmpl_if>

<p>
	<tmpl_if user.canPost>
		<a href="<tmpl_var add.url>">[<tmpl_var add.label>]</a>
	</tmpl_if>
	<tmpl_unless user.isVisitor>
		<tmpl_if user.isSubscribed>
			<a href="<tmpl_var unsubscribe.url>">[<tmpl_var unsubscribe.label>]</a>
		<tmpl_else>
			<a href="<tmpl_var subscribe.url>">[<tmpl_var subscribe.label>]</a>
		</tmpl_if>
	</tmpl_unless>
	<tmpl_if pagination.pageCount.isMultiple>
		<a href="<tmpl_var search.url>">[<tmpl_var search.label>]</a>
	</tmpl_if>
</p>

<tmpl_loop post_loop>
	<tmpl_if user.isPoster>
		<tmpl_unless session.var.adminOn>
			<div>[<a href="<tmpl_var edit.url>"><tmpl_var edit.label></a>]</div>
		</tmpl_unless>
	</tmpl_if>
	<tmpl_if user.isModerator>
		<div>
			<tmpl_if session.var.adminOn>
				<tmpl_var controls>
			<tmpl_else>
				<tmpl_unless user.isPoster>
					<tmpl_unless session.var.adminOn>
						[<a href="<tmpl_var edit.url>"><tmpl_var edit.label></a>]
					</tmpl_unless>
				</tmpl_unless>
			</tmpl_if>
			(<a href="<tmpl_var url>"><tmpl_var status></a>)
		</div>
	</tmpl_if>
	<p>
		<tmpl_if userDefined1><a href="<tmpl_var userDefined1>"	<tmpl_if userDefined2>target="_blank"</tmpl_if>></tmpl_if><tmpl_var title><tmpl_if userDefined1></a></tmpl_if>
		<tmpl_if content>
				  - <tmpl_var content>
		</tmpl_if>
	</p>
</tmpl_loop>

<tmpl_if pagination.pageCount.isMultiple>
	<div class="pagination">
		<tmpl_var pagination.previousPage> &middot; <tmpl_var pagination.pageList.upTo10> &middot; <tmpl_var pagination.nextPage>
	</div>
</tmpl_if>
END

$fixedTemplates{PBtmpl0000000000000084} = << 'END';
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>

<tmpl_if session.var.adminOn>
	<p><tmpl_var controls></p>
</tmpl_if>

<tmpl_if displayTitle>
	<h1><tmpl_var title></h1>
</tmpl_if>

<tmpl_if pagination.isFirstPage>
<tmpl_if image.url>
	<div align="center"><img src="<tmpl_var image.url>" alt="<tmpl_var image.url>" border="0" /></div>
</tmpl_if>
</tmpl_if>

<tmpl_if description>
	<tmpl_var description>
	<p />
</tmpl_if>

<tmpl_if pagination.isLastPage>
<tmpl_if linkurl>
	<tmpl_if linktitle>
		<p />
		<a href="<tmpl_var linkUrl>"><tmpl_var linkTitle></a>
	</tmpl_if>
</tmpl_if>
<tmpl_var attachment.box>
<p />
</tmpl_if>

<tmpl_if pagination.pageCount.isMultiple>
<tmpl_var pagination.previousPage>
&middot;
<tmpl_var pagination.pageList.upTo20>
&middot;
<tmpl_var pagination.nextPage>
</tmpl_if>

<tmpl_if pagination.isLastPage>
<tmpl_if allowDiscussion>
	<table width="100%" cellspacing="2" cellpadding="1" border="0">
	<tr>
	<td align="center" width="50%" class="tableMenu"><a href="<tmpl_var replies.URL>"><tmpl_var replies.label> (<tmpl_var replies.count>)</a></td>
	<td align="center" width="50%" class="tableMenu"><a href="<tmpl_var post.url>"><tmpl_var post.label></a></td>
	</tr>
	</table>
</tmpl_if>
</tmpl_if>
END

$fixedTemplates{PBtmpl0000000000000086} = << 'END';
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>

<tmpl_if session.var.adminOn>
	<p><tmpl_var controls></p>
</tmpl_if>

<tmpl_if displayTitle>
	<h1><tmpl_var title></h1>
</tmpl_if>

<tmpl_if description>
	<tmpl_var description>
	<p />
</tmpl_if>

<tmpl_if session.var.adminOn>
	<a href="<tmpl_var addevent.url>"><tmpl_var addevent.label></a>
	<p />
</tmpl_if>

<tmpl_loop month_loop>
	<tmpl_loop day_loop>
		<tmpl_loop event_loop>
			<tmpl_if isFirstDayOfEvent>
				<tmpl_unless dateIsSameAsPrevious>
					<b>
						<tmpl_var start.day.dayOfWeek> <tmpl_var start.month> <tmpl_var start.day><tmpl_unless startEndYearMatch>, <tmpl_ start.year> -
						<tmpl_var end.day.dayOfWeek> <tmpl_var end.month> <tmpl_var end.day></tmpl_unless><tmpl_unless startEndMonthMatch> - <tmpl_var end.day.dayOfWeek> <tmpl_var end.month> <tmpl_var end.day><tmpl_else><tmpl_unless startEndDayMatch> - <tmpl_var end.day></tmpl_unless></tmpl_unless>, <tmpl_var end.year>
					</b>
				</tmpl_unless>
				<blockquote>
					<tmpl_if session.var.adminOn>
						<a href="<tmpl_var url>">
					</tmpl_if>
					<i><tmpl_var name></i>
					<tmpl_if session.var.adminOn>
						</a>
					</tmpl_if>
					<tmpl_if description>
						- <tmpl_var description>
					</tmpl_if description>
				</blockquote>
			</tmpl_if>
		</tmpl_loop>
	</tmpl_loop>
</tmpl_loop>

<tmpl_if pagination.pageCount.isMultiple>
	<div class="pagination">
		<tmpl_var pagination.previousPage> &middot; <tmpl_var pagination.pageList.upTo20> &middot; <tmpl_var pagination.nextPage>
	</div>
</tmpl_if>
END

$fixedTemplates{PBtmpl0000000000000094} = << 'END';
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>

<tmpl_if showAdmin>
	<p><tmpl_var controls></p>
</tmpl_if>

^RawHeadTags(<style type="text/css">
.firstColumn {
	float: left;
	width: 50%;
}
.secondColumn {
	float: left;
	width: auto;
	max-width: 50%;
}
.endFloat {
	clear: both;
}
</style>);

<tmpl_if displayTitle>
	<h1><tmpl_var title></h1>
</tmpl_if>

<tmpl_if description>
	<p><tmpl_var description></p>
</tmpl_if>

<!-- begin position 1 -->
<div class="layoutColumnPadding">
<tmpl_if showAdmin>
	<table border="0" id="position1" class="content"><tbody>
</tmpl_if>
<tmpl_loop position1_loop>
	<tmpl_if showAdmin>
		<tr id="td<tmpl_var id>">
		<td><div id="td<tmpl_var id>_div" class="dragable">
	</tmpl_if>

	<div class="content"><tmpl_var dragger.icon><tmpl_var content></div>

	<tmpl_if showAdmin>
		</div></td>
		</tr>
	</tmpl_if>
</tmpl_loop>

<tmpl_if showAdmin>
	</tbody></table>
</tmpl_if>
</div>

<!-- end position 1 -->

<div class="endFloat">&nbsp;</div>

<!-- begin position 2 -->
<div class="firstColumn"><div class="layoutColumnPadding">
<tmpl_if showAdmin>
	<table border="0" id="position2" class="content"><tbody>
</tmpl_if>

<tmpl_loop position2_loop>
	<tmpl_if showAdmin>
		<tr id="td<tmpl_var id>">
		<td><div id="td<tmpl_var id>_div" class="dragable">
	</tmpl_if>

	<div class="content"><tmpl_var dragger.icon><tmpl_var content></div>

	<tmpl_if showAdmin>
		</div></td>
		</tr>
	</tmpl_if>
</tmpl_loop>

<tmpl_if showAdmin>
	</tbody></table>
</tmpl_if>
</div></div>
<!-- end position 2 -->

<!-- begin position 3 -->
<div class="firstColumn"><div class="layoutColumnPadding">
<tmpl_if showAdmin>
	<table border="0" id="position3" class="content"><tbody>
</tmpl_if>

<tmpl_loop position3_loop>
	<tmpl_if showAdmin>
		<tr id="td<tmpl_var id>">
		<td><div id="td<tmpl_var id>_div" class="dragable">
	</tmpl_if>

	<div class="content"><tmpl_var dragger.icon><tmpl_var content></div>

	<tmpl_if showAdmin>
		</div></td>
		</tr>
	</tmpl_if>
</tmpl_loop>

<tmpl_if showAdmin>
	</tbody></table>
</tmpl_if>
</div> </div>
<!-- end position 3 -->

<div class="endFloat">&nbsp;</div>

<!-- begin position 4 -->
<div class="layoutColumnPadding">
<tmpl_if showAdmin>
	<table border="0" id="position4" class="content"><tbody>
</tmpl_if>

<tmpl_loop position4_loop>
	<tmpl_if showAdmin>
		<tr id="td<tmpl_var id>">
		<td><div id="td<tmpl_var id>_div" class="dragable">
	</tmpl_if>

	<div class="content"><tmpl_var dragger.icon><tmpl_var content></div>

	<tmpl_if showAdmin>
		</div></td>
		</tr>
	</tmpl_if>
</tmpl_loop>

<tmpl_if showAdmin>
	</tbody></table>
</tmpl_if>
</div>
<!-- end position 4 -->

<tmpl_if showAdmin>
	<table><tr id="blank" class="hidden"><td><div><div class="empty">&nbsp;</div></div></td></tr></table>
	<tmpl_var dragger.init>
</tmpl_if>
END

$fixedTemplates{PBtmpl0000000000000095} = << 'END';
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>

<tmpl_if session.var.adminOn>
	<p><tmpl_var controls></p>
</tmpl_if>

<style type="text/css">

.productOptions {
	font-family: Helvetica, Arial, sans-serif;
	font-size: 11px;
}

</style>

<tmpl_if displayTitle>
	<h1><tmpl_var title></h1>
</tmpl_if>

<tmpl_if image1>
	<img src="<tmpl_var image1>" alt="<tmpl_var image1>" border="0" />
	<p />
</tmpl_if>

<table width="100%" cellpadding="3" cellspacing="0" border="0">
<tr>
	<td class="content" valign="top" width="66%">
		<tmpl_if description>
			<tmpl_var description>
			<p />
		</tmpl_if>
		<b>Benefits</b><br />
		<tmpl_if session.var.adminOn>
			<a href="<tmpl_var addBenefit.url>"><tmpl_var addBenefit.label></a>
			<p />
		</tmpl_if>
		<tmpl_loop benefit_loop>
			&middot;<tmpl_if session.var.adminOn><tmpl_var benefit.controls></tmpl_if><tmpl_var benefit.benefit><br />
		</tmpl_loop>
	</td>
	<td valign="top" width="34%" class="productOptions">
		<tmpl_if thumbnail2>
			<a href="<tmpl_var image2>"><img src="<tmpl_var thumbnail2>" alt="<tmpl_var thumbnail2>" border="0" /></a>
			<p />
		</tmpl_if>
		<b>Specifications</b><br />
		<tmpl_if session.var.adminOn>
			<a href="<tmpl_var addSpecification.url>"><tmpl_var addSpecification.label></a>
			<p />
		</tmpl_if>
		<tmpl_loop specification_loop>
			&middot;<tmpl_if session.var.adminOn><tmpl_var specification.controls></tmpl_if><b><tmpl_var specification.label>:</b> <tmpl_var specification.specification> <tmpl_var specification.units><br />
		</tmpl_loop>
		<b>Options</b><br />
		<tmpl_if session.var.adminOn>
			<a href="<tmpl_var addaccessory.url>"><tmpl_var addaccessory.label></a>
			<p />
		</tmpl_if>
		<tmpl_loop accessory_loop>
			&middot;<tmpl_if session.var.adminOn><tmpl_var accessory.controls></tmpl_if><a href="<tmpl_var accessory.url>"><tmpl_var accessory.title></a><br />
		</tmpl_loop>
		<b>Other Products</b><br />
		<tmpl_if session.var.adminOn>
			<a href="<tmpl_var addRelatedProduct.url>"><tmpl_var addRelatedProduct.label></a>
			<p />


		</tmpl_if>
		<tmpl_loop relatedproduct_loop>
			&middot;<tmpl_if session.var.adminOn><tmpl_var RelatedProduct.controls></tmpl_if><a href="<tmpl_var relatedproduct.url>"><tmpl_var relatedproduct.title></a><br />
		</tmpl_loop>
	</td>
</tr>
</table>
END

$fixedTemplates{PBtmpl0000000000000097} = << 'END';
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>

<tmpl_if session.var.adminOn>
	<tmpl_var controls>
</tmpl_if>

<style type="text/css">

.forumHead {
	background-color: #eeeeee;
	border-bottom: 1px solid #cccccc;
	padding: 2px;
	padding-bottom: 4px;
	font-size: 13px;
	font-weight: bold;
}

.oddThread {
	font-size: 13px;
	border-bottom: 1px dashed #83cc83;
	padding-bottom: 4px;
}

.evenThread {
	font-size: 13px;
	border-bottom: 1px dashed #aaaaff;
	padding-bottom: 4px;
}

</style>

<tmpl_if displayTitle>
	<h1><tmpl_var title></h1>
</tmpl_if>

<tmpl_if description>
	<tmpl_var description>
</tmpl_if>

<p>
	<tmpl_if user.canPost>
		<a href="<tmpl_var add.url>"><tmpl_var add.label></a>
		&bull;
	</tmpl_if>
	<tmpl_unless user.isVisitor>
		<tmpl_if user.isSubscribed>
			<a href="<tmpl_var unsubscribe.url>"><tmpl_var unsubscribe.label></a>
		<tmpl_else>
			<a href="<tmpl_var subscribe.url>"><tmpl_var subscribe.label></a>
		</tmpl_if>
		&bull;
	</tmpl_unless>
	<a href="<tmpl_var search.url>"><tmpl_var search.label></a>
</p>

<table width="100%">
<tr>
	<tmpl_if user.isModerator>
		<td class="forumHead"><tmpl_var status.label></td>
	</tmpl_if>
	<td class="forumHead"><a href="<tmpl_var sortby.title.url>"><tmpl_var title.label></a></td>
	<td class="forumHead"><tmpl_var thumbnail.label></td>
	<td class="forumHead"><a href="<tmpl_var sortby.date.url>"><tmpl_var date.label></a></td>
	<td class="forumHead"><a href="<tmpl_var sortby.username.url>"><tmpl_var by.label></a></td>
</tr>
<tmpl_loop post_loop>
	<tr>
		<tmpl_if user.isModerator>
			<td class="<tmpl_if __ODD__>oddThread<tmpl_else>evenThread</tmpl_if>"><tmpl_var status></td>
		</tmpl_if>
		<td class="<tmpl_if __ODD__>oddThread<tmpl_else>evenThread</tmpl_if>"><a href="<tmpl_var url>"><tmpl_var title></a><tmpl_if user.isPoster> (<tmpl_var status>)</tmpl_if></td>
		<td class="<tmpl_if __ODD__>oddThread<tmpl_else>evenThread</tmpl_if>" style="text-align: center;">
			<tmpl_if thumbnail>
				 <a href="<tmpl_var url>"><img src="<tmpl_var thumbnail>" border="0" alt="<tmpl_var title>" /></a>
			<tmpl_else>
				 &nbsp;
			</tmpl_if>
		</td>
		<td class="<tmpl_if __ODD__>oddThread<tmpl_else>evenThread</tmpl_if>"><tmpl_var dateUpdated.human></td>
		<tmpl_if user.isVisitor>
			<td class="<tmpl_if __ODD__>oddThread<tmpl_else>evenThread</tmpl_if>"><tmpl_var username></td>
		<tmpl_else>
			<td class="<tmpl_if __ODD__>oddThread<tmpl_else>evenThread</tmpl_if>"><a href="<tmpl_var userProfile.url>"><tmpl_var username></a></td>
		</tmpl_if>
	</tr>
</tmpl_loop>
</table>

<tmpl_if pagination.pageCount.isMultiple>
	<div class="pagination">
		<tmpl_var pagination.previousPage> &middot; <tmpl_var pagination.pageList.upTo10> &middot; <tmpl_var pagination.nextPage>
	</div>
</tmpl_if>
END

$fixedTemplates{PBtmpl0000000000000098} = << 'END';
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a> 

<tmpl_if session.var.adminOn> 
	<p><tmpl_var controls></p>
</tmpl_if>

<h1><tmpl_var title></h1>

<tmpl_if user.isModerator>
	<div style="float: right; font-size: 11px; border: 1px solid #cccccc; padding: 2px; margin: 2px;">
		<b><tmpl_var status.label>:</b> <tmpl_var status> &nbsp; &nbsp; [ <a href="<tmpl_var approve.url>"><tmpl_var approve.label></a> | <a href="<tmpl_var deny.url>"><tmpl_var deny.label></a> ]<br />
	</div>
</tmpl_if>	

<tmpl_if content>
	<b>Job Description</b><br />
	<p><tmpl_var content></p>
</tmpl_if>

<tmpl_if userDefined3>
	<b>Job Requirements</b><br />
	<p><tmpl_var userDefined3></p>
</tmpl_if>

<table>
<tr>
	<td class="tableHeader">Date Posted</td>
	<td class="tableData"><tmpl_var dateSubmitted.human></td>
</tr>
<tr>
	<td class="tableHeader">Location</td>
	<td class="tableData"><tmpl_var userDefined2></td>
</tr>
<tr>
	<td class="tableHeader">Compensation</td>
	<td class="tableData"><tmpl_var userDefined1></td>
</tr>
<tr>
	<td class="tableHeader">Views</td>
	<td class="tableData"><tmpl_var views></td>
</tr>
</table>

<tmpl_if attachment_loop>
	<br />
		<tmpl_loop attachment_loop>
			<div style="float: left; padding: 5px;">
				<a href="<tmpl_var url>"><tmpl_if isImage><img src="<tmpl_var thumbnail>" border="0" alt="<tmpl_var filename>" /><tmpl_else><img src="<tmpl_var icon>" border="0" alt="<tmpl_var filename>" align="middle" /> <tmpl_var filename></tmpl_if></a>
			</div>
		</tmpl_loop>
		<div style="clear: both;"></div>
	<br />
</tmpl_if>

<tmpl_unless isLocked>
	<p>
		<tmpl_if user.canReply>
			<a href="<tmpl_var reply.url>">[<tmpl_var reply.label>]</a>
		</tmpl_if>
		<tmpl_if user.canEdit>
			<a href="<tmpl_var edit.url>">[<tmpl_var edit.label>]</a>
			<a href="<tmpl_var delete.url>">[<tmpl_var delete.label>]</a>
		</tmpl_if>
	</p>
</tmpl_unless>

<tmpl_if repliesAllowed>

	<style>
		.postBorder {
			border: 1px solid #cccccc;
			margin-bottom: 10px;
		}
		.postBorderCurrent {
			border: 3px dotted black;
			margin-bottom: 10px;
		}
		.postSubject {
			border-bottom: 1px solid #cccccc;
			font-weight: bold;
			padding: 3px;
		}
		.postData {
			border-bottom: 1px solid #cccccc;
			font-size: 11px;
			background-color: #eeeeee;
			color: black;
			padding: 3px;
		}
		.postControls {
			border-top: 1px solid #cccccc;
			background-color: #eeeeee;
			color: black;
			padding: 3px;
		}
		.postMessage {
			padding: 3px;
		}
		.currentThread {
			background-color: #eeeeee;
		}
		.threadHead {
			font-weight: bold;
			border-bottom: 1px solid #cccccc;
			font-size: 11px;
			background-color: #eeeeee;
			color: black;
			padding: 3px;
		}
		.threadData {
			font-size: 11px;
			padding: 3px;
		}
	</style>

	<div style="float: left; width: 70%">
		<h1><tmpl_var replies.label></h1>
	</div>
	<div style="width: 30%; float: left; text-align: right;">
	<tmpl_if layout.isFlat>
		<a href="<tmpl_var layout.nested.url>"><tmpl_var layout.nested.label></a>
	<tmpl_else>
		<a href="<tmpl_var layout.flat.url>"><tmpl_var layout.flat.label></a>
	</tmpl_if>
	</div>
	<div style="clear: both;"></div>
	
	<tmpl_if layout.isFlat>
	<!-- begin flat layout -->
		<tmpl_loop post_loop>
			<tmpl_unless isThreadRoot>
				<div class="postBorder<tmpl_if isCurrent>Current</tmpl_if>">
					<a name="<tmpl_var assetId>"></a>
					<div class="postSubject">
						<tmpl_var title>
					</div>
					<div class="postData">
						<div style="float: left; width: 50%">
							<b><tmpl_var user.label>:</b> 
								<tmpl_if user.isVisitor>
									<tmpl_var username>
								<tmpl_else>
									<a href="<tmpl_var userProfile.url>"><tmpl_var username></a>
								</tmpl_if>
								<br />
							<b><tmpl_var date.label>:</b> <tmpl_var dateSubmitted.human><br />
						</div>	
						<div>
							<b><tmpl_var views.label>:</b> <tmpl_var views><br />
							<b><tmpl_var rating.label>:</b> <tmpl_var rating>
								<tmpl_unless hasRated>
									 &nbsp; &nbsp;<tmpl_var rate.label> [ <a href="<tmpl_var rate.url.1>">1</a>, <a href="<tmpl_var rate.url.2>">2</a>, <a href="<tmpl_var rate.url.3>">3</a>, <a href="<tmpl_var rate.url.4>">4</a>, <a href="<tmpl_var rate.url.5>">5</a> ]
								</tmpl_unless>
								<br />
							<tmpl_if user.isModerator>
								<b><tmpl_var status.label>:</b> <tmpl_var status> &nbsp; &nbsp; [ <a href="<tmpl_var approve.url>"><tmpl_var approve.label></a> | <a href="<tmpl_var deny.url>"><tmpl_var deny.label></a> ]<br />
							<tmpl_else>	
								<tmpl_if user.isPoster>
									<b><tmpl_var status.label>:</b> <tmpl_var status><br />
								</tmpl_if>	
							</tmpl_if>	
						</div>	
					</div>
					<div class="postMessage">
						<tmpl_var content>
						<tmpl_loop attachment_loop>
							<div style="float: left; padding: 5px;"><a href="<tmpl_var url>"><tmpl_if isImage><img src="<tmpl_var thumbnail>" border="0" alt="<tmpl_var filename>" /><tmpl_else><img src="<tmpl_var icon>" border="0" alt="<tmpl_var filename>" align="middle" /> <tmpl_var filename></tmpl_if></a></div>
						</tmpl_loop>
						<div style="clear: both;"></div>
					</div>
					<tmpl_unless isLocked>
						<div class="postControls">
							<tmpl_if user.canReply>
								<a href="<tmpl_var reply.url>">[<tmpl_var reply.label>]</a>
							</tmpl_if>
							<tmpl_if user.canEdit>
								<a href="<tmpl_var edit.url>">[<tmpl_var edit.label>]</a>
								<a href="<tmpl_var delete.url>">[<tmpl_var delete.label>]</a>
							</tmpl_if>
						</div>
					</tmpl_unless>
				</div>
			</tmpl_unless>
		</tmpl_loop>
	<!-- end flat layout -->
	</tmpl_if>
	
	<tmpl_if layout.isNested>
	<!-- begin nested layout -->
		<tmpl_loop post_loop>
			<tmpl_unless isThreadRoot>
				<div style="margin-left: <tmpl_var depthX10>px;">
					<div class="postBorder<tmpl_if isCurrent>Current</tmpl_if>">
						<a name="<tmpl_var assetId>"></a>
						<div class="postSubject">
							<tmpl_var title>
						</div>
						<div class="postData">
							<div style="float: left; width: 50%">
								<b><tmpl_var user.label>:</b> 
									<tmpl_if user.isVisitor>
										<tmpl_var username>
									<tmpl_else>
										<a href="<tmpl_var userProfile.url>"><tmpl_var username></a>
									</tmpl_if>
									<br />
								<b><tmpl_var date.label>:</b> <tmpl_var dateSubmitted.human><br />
							</div>	
							<div>
								<b><tmpl_var views.label>:</b> <tmpl_var views><br />
								<b><tmpl_var rating.label>:</b> <tmpl_var rating>
									<tmpl_unless hasRated>
										 &nbsp; &nbsp;<tmpl_var rate.label> [ <a href="<tmpl_var rate.url.1>">1</a>, <a href="<tmpl_var rate.url.2>">2</a>, <a href="<tmpl_var rate.url.3>">3</a>, <a href="<tmpl_var rate.url.4>">4</a>, <a href="<tmpl_var rate.url.5>">5</a> ]
									</tmpl_unless>
									<br />
								<tmpl_if user.isModerator>
									<b><tmpl_var status.label>:</b> <tmpl_var status> &nbsp; &nbsp; [ <a href="<tmpl_var approve.url>"><tmpl_var approve.label></a> | <a href="<tmpl_var deny.url>"><tmpl_var deny.label></a> ]<br />
								<tmpl_else>	
									<tmpl_if user.isPoster>
										<b><tmpl_var status.label>:</b> <tmpl_var status><br />
									</tmpl_if>	
								</tmpl_if>	
							</div>	
						</div>
						<div class="postMessage">
							<tmpl_var content>
							<tmpl_loop attachment_loop>
								<div style="float: left; padding: 5px;"><a href="<tmpl_var url>"><tmpl_if isImage><img src="<tmpl_var thumbnail>" border="0" alt="<tmpl_var filename>" /><tmpl_else><img src="<tmpl_var icon>" border="0" alt="<tmpl_var filename>" align="middle" /> <tmpl_var filename></tmpl_if></a></div>
							</tmpl_loop>
							<div style="clear: both;"></div>
						</div>
						<tmpl_unless isLocked>
							<div class="postControls">
								<tmpl_if user.canReply>
									<a href="<tmpl_var reply.url>">[<tmpl_var reply.label>]</a>
								</tmpl_if>
								<tmpl_if user.canEdit>
									<a href="<tmpl_var edit.url>">[<tmpl_var edit.label>]</a>
									<a href="<tmpl_var delete.url>">[<tmpl_var delete.label>]</a>
								</tmpl_if>
							</div>
						</tmpl_unless>
					</div>
				</div>
			</tmpl_unless>
		</tmpl_loop>
	<!-- end nested layout -->
	</tmpl_if>
	
	<tmpl_if pagination.pageCount.isMultiple>
		<div class="pagination" style="margin-top: 20px;">
			[ <tmpl_var pagination.previousPage> | <tmpl_var pagination.pageList.upTo10> | <tmpl_var pagination.nextPage> ]
		</div>
	</tmpl_if>
</tmpl_if>	

<div style="margin-top: 20px;">
	<tmpl_if previous.url>
		<a href="<tmpl_var previous.url>">[<tmpl_var previous.label>]</a> 
	</tmpl_if>	
	<a href="<tmpl_var collaboration.url>">[<tmpl_var back.label>]</a>
	<tmpl_if next.url>
		<a href="<tmpl_var next.url>">[<tmpl_var next.label>]</a> 
	</tmpl_if>	
	<tmpl_if user.canPost>
		<a href="<tmpl_var add.url>">[<tmpl_var add.label>]</a>
	</tmpl_if>
	<tmpl_if user.isModerator>
		<tmpl_if isSticky>
			<a href="<tmpl_var unstick.url>">[<tmpl_var unstick.label>]</a>
		<tmpl_else>
			<a href="<tmpl_var stick.url>">[<tmpl_var stick.label>]</a>
		</tmpl_if>
		<tmpl_if isLocked>
			<a href="<tmpl_var unlock.url>">[<tmpl_var unlock.label>]</a>
		<tmpl_else>
			<a href="<tmpl_var lock.url>">[<tmpl_var lock.label>]</a>
		</tmpl_if>
	</tmpl_if>
	<tmpl_unless user.isVisitor>
		<tmpl_if user.isSubscribed>
			<a href="<tmpl_var unsubscribe.url>">[<tmpl_var unsubscribe.label>]</a>
		<tmpl_else>
			<a href="<tmpl_var subscribe.url>">[<tmpl_var subscribe.label>]</a>
		</tmpl_if>
	</tmpl_unless>
</div>
END

$fixedTemplates{PBtmpl0000000000000099} = << 'END';
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>

<tmpl_if preview.title><p><b><tmpl_var preview.title></b></p></tmpl_if>
<tmpl_if preview.content><p><tmpl_var preview.content></p></tmpl_if>

<tmpl_if isReply>
	<h1><tmpl_var message.header.label></h1>
<tmpl_else>
	<h1><tmpl_var question.header.label></h1>
</tmpl_if>

<tmpl_var form.header>
<table>
	<tmpl_if isReply>
		<tr>
			<td><tmpl_var subject.label></td>
			<td><tmpl_var title.form></td>
		</tr>
		<tr>
			<td><tmpl_var message.label></td>
			<td><tmpl_var content.form></td>
		</tr>
	<tmpl_else>
		<tr>
			<td><tmpl_var question.label></td>
			<td><tmpl_var title.form.textarea></td>
		</tr>
		<tr>
			<td><tmpl_var answer.label></td>
			<td><tmpl_var content.form></td>
		</tr>
		<tmpl_if attachment.form>
			<tr>
				<td><tmpl_var attachment.label></td>
				<td><tmpl_var attachment.form></td>
			</tr>
		</tmpl_if>
	</tmpl_if>
	<tr>
		<td><tmpl_var contentType.label></td>
		<td><tmpl_var contentType.form></td>
	</tr>
	<tmpl_if isNewPost>
		<tmpl_unless user.isVisitor>
			<tr>
				<td><tmpl_var subscribe.label></td>
				<td><tmpl_var subscribe.form></td>
			</tr>
		</tmpl_unless>
		<tmpl_if isNewThread>
			<tmpl_if user.isModerator>
				<tr>
					<td><tmpl_var lock.label></td>
					<td><tmpl_var lock.form></td>
				</tr>
				<tr>
					<td><tmpl_var stick.label></td>
					<td><tmpl_var sticky.form></td>
				</tr>
			</tmpl_if>
		</tmpl_if>
	</tmpl_if>
	<tr>
		<td></td>
		<td><tmpl_if usePreview><tmpl_var form.preview></tmpl_if><tmpl_var form.submit></td>
	</tr>
</table>
<tmpl_var form.footer>

<tmpl_if isReply>
	<p><b><tmpl_var reply.title></b></p>
	<tmpl_var reply.content>
</tmpl_if>
END

$fixedTemplates{PBtmpl0000000000000100} = << 'END';
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>

<tmpl_if session.var.adminOn>
	<p><tmpl_var controls></p>
</tmpl_if>

<style type="text/css">
.googleDetail {
	font-size: 9px;
}
</style>

<h1><tmpl_var title></h1>

<tmpl_if description>
	<tmpl_var description><br /><br />
</tmpl_if>

<form method="post">
	<input type="hidden" name="func" value="view">
	<input type="hidden" name="wid" value="<tmpl_var wobjectId>">
	<input type="hidden" name="targetWobjects" value="doGoogleSearch">
	<input type="text" name="q"><input type="submit" value="Search">
</form>

<tmpl_if results>
	<tmpl_loop results>
		<tmpl_if resultElements>
			<p>You searched for <b><tmpl_var searchQuery></b>. We found around <tmpl_var estimatedTotalResultsCount> matching records.</p>
		</tmpl_if>

		<tmpl_loop resultElements>
			<a href="<tmpl_var URL>">
			<tmpl_if title>
				<tmpl_var title>
			<tmpl_else>
				<tmpl_var url>
			</tmpl_if>
			</a><br />
			<tmpl_if snippet>
				<tmpl_var snippet><br />
			</tmpl_if>
			<div class="googleDetail">
			<tmpl_if summary>
				<b>Description:</b> <tmpl_var summary><br />
			</tmpl_if>
			<a href="<tmpl_var URL>"><tmpl_var URL></a>
			<tmpl_if cachedSize>
				- <tmpl_var cachedSize>
			</tmpl_if>
			</div><br />
		</tmpl_loop>
	</tmpl_loop>
<tmpl_else>
	Could not retrieve results from Google.
</tmpl_if>
END

$fixedTemplates{PBtmpl0000000000000101} = << 'END';
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>

<tmpl_if session.var.adminOn>
	<tmpl_var controls>
</tmpl_if>

<tmpl_if displayTitle>
	<h1><tmpl_var title></h1>
</tmpl_if>

<tmpl_if description>
	<tmpl_var description>
</tmpl_if>

<p>
	<tmpl_if user.canPost>
		<a href="<tmpl_var add.url>">[<tmpl_var add.label>]</a>
	</tmpl_if>
	<tmpl_unless user.isVisitor>
		<tmpl_if user.isSubscribed>
			<a href="<tmpl_var unsubscribe.url>">[<tmpl_var unsubscribe.label>]</a>
		<tmpl_else>
			<a href="<tmpl_var subscribe.url>">[<tmpl_var subscribe.label>]</a>
		</tmpl_if>
	</tmpl_unless>
	<tmpl_if pagination.pageCount.isMultiple>
		<a href="<tmpl_var search.url>">[<tmpl_var search.label>]</a>
	</tmpl_if>
</p>

<ol>
	<tmpl_loop post_loop>
		<li>
			<tmpl_if user.isPoster>
				<tmpl_unless session.var.adminOn>
					[<a href="<tmpl_var edit.url>"><tmpl_var edit.label></a>]
				</tmpl_unless>
			</tmpl_if>
			<tmpl_if user.isModerator>
				<tmpl_if session.var.adminOn>
					<tmpl_var controls>
				<tmpl_else>
					<tmpl_unless user.isPoster>
						<tmpl_unless session.var.adminOn>
							[<a href="<tmpl_var edit.url>"><tmpl_var edit.label></a>]
						</tmpl_unless>
					</tmpl_unless>
				</tmpl_if>
				(<a href="<tmpl_var url>"><tmpl_var status></a>)
			</tmpl_if>
			<tmpl_if userDefined1><a href="<tmpl_var userDefined1>"	<tmpl_if userDefined2>target="_blank"</tmpl_if>></tmpl_if><tmpl_var title><tmpl_if userDefined1></a></tmpl_if>
			<tmpl_if content>
					  - <tmpl_var content>
			</tmpl_if>
		</li>
	</tmpl_loop>
</ol>

<tmpl_if pagination.pageCount.isMultiple>
	<div class="pagination">
		<tmpl_var pagination.previousPage> &middot; <tmpl_var pagination.pageList.upTo10> &middot; <tmpl_var pagination.nextPage>
	</div>
</tmpl_if>
END

$fixedTemplates{PBtmpl0000000000000103} = << 'END';
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>

<tmpl_if session.var.adminOn>
	<p><tmpl_var controls></p>
</tmpl_if>

<tmpl_if displayTitle>
	<h1><tmpl_var title></h1>
</tmpl_if>

<tmpl_if pagination.isFirstPage>
<tmpl_if image.url>
	<table width="100%" border="0" cellpadding="0" cellspacing="0"><tr><td class="content">
	<img src="<tmpl_var image.url>" alt="<tmpl_var image.url>" align="left" border="0" />
</tmpl_if>
</tmpl_if>

<tmpl_if description>
	<tmpl_var description>
	<p />
</tmpl_if>

<tmpl_if pagination.isLastPage>
<tmpl_if linkurl>
	<tmpl_if linktitle>
		<p />
		<a href="<tmpl_var linkUrl>"><tmpl_var linkTitle></a>
	</tmpl_if>
</tmpl_if>

<tmpl_var attachment.box> <p />
</tmpl_if>

<tmpl_if pagination.isFirstPage>
<tmpl_if image.url>
	</td></tr></table>
</tmpl_if>
</tmpl_if>

<tmpl_if pagination.pageCount.isMultiple>
<tmpl_var pagination.previousPage>
&middot;
<tmpl_var pagination.pageList.upTo20>
&middot;
<tmpl_var pagination.nextPage>
</tmpl_if>

<tmpl_if pagination.isLastPage>
<tmpl_if allowDiscussion>
	<p />
	<table width="100%" cellspacing="2" cellpadding="1" border="0">
	<tr><td align="center" width="50%" class="tableMenu"><a href="<tmpl_var replies.URL>"><tmpl_var replies.label> (<tmpl_var replies.count>)</a></td>
	<td align="center" width="50%" class="tableMenu"><a href="<tmpl_var post.url>"><tmpl_var post.label></a></td></tr>
	</table>
</tmpl_if>
</tmpl_if>
END

$fixedTemplates{PBtmpl0000000000000104} = << 'END';
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>

<tmpl_if session.var.adminOn>
	<p><tmpl_var controls></p>
</tmpl_if>

<tmpl_var acknowledgement>
<p />
<table border="0">
<tmpl_loop field_loop>
<tmpl_unless field.isMailField><tmpl_unless field.isHidden>
	<tr><td class="tableHeader"><tmpl_var field.label></td>
	<td class="tableData"><tmpl_var field.value></td></tr>
</tmpl_unless></tmpl_unless>
</tmpl_loop>
</table>
<p />
<a href="<tmpl_var back.url>"><tmpl_var back.label></a>
END

$fixedTemplates{PBtmpl0000000000000105} = << 'END';
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>

<tmpl_if session.var.adminOn>
	<p><tmpl_var controls></p>
</tmpl_if>

<tmpl_if displayTitle>
	<h1><tmpl_var title></h1>
</tmpl_if>

<tmpl_if description>
	<tmpl_var description>
	<p />
</tmpl_if>

<tmpl_if session.var.adminOn>
	<a href="<tmpl_var addevent.url>"><tmpl_var addevent.label></a>
	<p />
</tmpl_if>

<tmpl_loop month_loop>
	<table border="1" width="100%">
	<tr><td colspan=7 class="tableHeader"><h2 align="center"><tmpl_var month> <tmpl_var year></h2></td></tr>
	<tr>
	<tmpl_if session.user.firstDayOfWeek>
		<th class="tableData"><tmpl_var monday.label.short></th>
		<th class="tableData"><tmpl_var tuesday.label.short></th>
		<th class="tableData"><tmpl_var wednesday.label.short></th>
		<th class="tableData"><tmpl_var thursday.label.short></th>
		<th class="tableData"><tmpl_var friday.label.short></th>
		<th class="tableData"><tmpl_var saturday.label.short></th>
		<th class="tableData"><tmpl_var sunday.label.short></th>
	<tmpl_else>
		<th class="tableData"><tmpl_var sunday.label.short></th>
		<th class="tableData"><tmpl_var monday.label.short></th>
		<th class="tableData"><tmpl_var tuesday.label.short></th>
		<th class="tableData"><tmpl_var wednesday.label.short></th>
		<th class="tableData"><tmpl_var thursday.label.short></th>
		<th class="tableData"><tmpl_var friday.label.short></th>
		<th class="tableData"><tmpl_var saturday.label.short></th>
	</tmpl_if>
	</tr><tr>
	<tmpl_loop prepad_loop>
		<td>&nbsp;</td>
	</tmpl_loop>
 	<tmpl_loop day_loop>
		<tmpl_if isStartOfWeek>
			<tr>
		</tmpl_if>
		<td class="table<tmpl_if isToday>Header<tmpl_else>Data</tmpl_if>" width="28" valign="top" align="left"><p><b>
				<tmpl_if url>
					<a href="<tmpl_var url>"><tmpl_var day></a>
				<tmpl_else>
					<tmpl_var day>
				</tmpl_if>
		</b></p></td>
		<tmpl_if isEndOfWeek>
			</tr>
		</tmpl_if>
	</tmpl_loop>
	<tmpl_loop postpad_loop>
		<td>&nbsp;</td>
	</tmpl_loop>
	</tr>
	</table>
</tmpl_loop>

<tmpl_if pagination.pageCount.isMultiple>
	<div class="pagination">
		<tmpl_var pagination.previousPage> &middot; <tmpl_var pagination.pageList.upTo20> &middot; <tmpl_var pagination.nextPage>
	</div>
</tmpl_if>
END

$fixedTemplates{PBtmpl0000000000000107} = << 'END';
<a href="<tmpl_var file.url>"><img src="<tmpl_var file.icon>" alt="<tmpl_var file.icon>" align="middle" border="0" /><tmpl_var file.name></a>(<tmpl_var file.size>)
END

$fixedTemplates{PBtmpl0000000000000109} = << 'END';
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>

<tmpl_if showAdmin>
<p><tmpl_var controls></p>
</tmpl_if>

^RawHeadTags(<style type="text/css">
.firstColumn {
  float: left;
  width: 33%;
}
.secondColumn {
        float: left;
        width: 33%;
}
.thirdColumn {
        float: left;
        width: auto;
        max-width: 33%;
}
.endFloat {
 clear: both;
}
</style>);

<tmpl_if displayTitle>
  <h1><tmpl_var title></h1>
</tmpl_if>

<tmpl_if description>
  <p><tmpl_var description></p>
</tmpl_if>

<!-- begin position 1 -->
<div class="layoutColumnPadding">
<tmpl_if showAdmin>
	<table border="0" id="position1" class="content"><tbody>
</tmpl_if>

<tmpl_loop position1_loop>
	<tmpl_if showAdmin>
            	<tr id="td<tmpl_var id>">
            		<td><div id="td<tmpl_var id>_div" class="dragable">
	</tmpl_if>

	<div class="content"><tmpl_var dragger.icon><tmpl_var content></div>

	<tmpl_if showAdmin>
         			</div></td>
            	</tr>
	</tmpl_if>
</tmpl_loop>

<tmpl_if showAdmin>
            </tbody></table>
</tmpl_if>
</div>
<!-- end position 1 -->

<div class="endFloat">&nbsp;</div>

<!-- begin position 2 -->
<div class="firstColumn"><div class="layoutColumnPadding">
<tmpl_if showAdmin>
	<table border="0" id="position2" class="content"><tbody>
</tmpl_if>

<tmpl_loop position2_loop>
	<tmpl_if showAdmin>
            	<tr id="td<tmpl_var id>">
            		<td><div id="td<tmpl_var id>_div" class="dragable">
	</tmpl_if>

	<div class="content"><tmpl_var dragger.icon><tmpl_var content></div>

	<tmpl_if showAdmin>
         			</div></td>
            	</tr>
	</tmpl_if>
</tmpl_loop>

<tmpl_if showAdmin>
            </tbody></table>
</tmpl_if>
</div></div>
<!-- end position 2 -->

<!-- begin position 3 -->
<div class="secondColumn"><div class="layoutColumnPadding">
<tmpl_if showAdmin>
	<table border="0" id="position3" class="content"><tbody>
</tmpl_if>

<tmpl_loop position3_loop>
	<tmpl_if showAdmin>
            	<tr id="td<tmpl_var id>">
            		<td><div id="td<tmpl_var id>_div" class="dragable">
	</tmpl_if>

	<div class="content"><tmpl_var dragger.icon><tmpl_var content></div>

	<tmpl_if showAdmin>
         			</div></td>
            	</tr>
	</tmpl_if>
</tmpl_loop>

<tmpl_if showAdmin>
            </tbody></table>
</tmpl_if>
</div></div>
<!-- end position 3 -->

<!-- begin position 4 -->
<div class="secondColumn"><div class="layoutColumnPadding">
<tmpl_if showAdmin>
	<table border="0" id="position4" class="content"><tbody>
</tmpl_if>

<tmpl_loop position4_loop>
	<tmpl_if showAdmin>
            	<tr id="td<tmpl_var id>">
            		<td><div id="td<tmpl_var id>_div" class="dragable">
	</tmpl_if>

	<div class="content"><tmpl_var dragger.icon><tmpl_var content></div>

	<tmpl_if showAdmin>
         			</div></td>
            	</tr>
	</tmpl_if>
</tmpl_loop>

<tmpl_if showAdmin>
            </tbody></table>
</tmpl_if>
</div></div>
<!-- end position 4 -->

<div class="endFloat">&nbsp;</div>

<tmpl_if showAdmin>
	<table><tr id="blank" class="hidden"><td><div><div class="empty">&nbsp;</div></div></td></tr></table>
            <tmpl_var dragger.init>
</tmpl_if>

END

$fixedTemplates{PBtmpl0000000000000110} = << 'END';
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>

<tmpl_if session.var.adminOn>
	<p><tmpl_var controls></p>
</tmpl_if>

<style type="text/css">

.productFeatureHeader, .productSpecificationHeader, .productRelatedHeader, .productAccessoryHeader, .productBenefitHeader {
	font-weight: bold;
	font-size: 15px;
}

.productFeature, .productSpecification, .productRelated, .productAccessory, .productBenefit {
	font-size: 12px;
}

</style>

<tmpl_if displayTitle>
	<h1><tmpl_var title></h1>
</tmpl_if>

<tmpl_if description>
	<tmpl_var description>
	<p />
</tmpl_if>

<table width="100%" cellpadding="3" cellspacing="0" border="0">
<tr>
	<td align="center">
		<tmpl_if thumbnail1>
			<a href="<tmpl_var image1>"><img src="<tmpl_var thumbnail1>" alt="<tmpl_var thumbnail1>" border="0" /></a>
		</tmpl_if>
	</td>
	<td align="center">
		<tmpl_if thumbnail2>
			<a href="<tmpl_var image2>"><img src="<tmpl_var thumbnail2>" alt="<tmpl_var thumbnail2>" border="0" /></a>
		</tmpl_if>
	</td>
	<td align="center">
		<tmpl_if thumbnail3>
			<a href="<tmpl_var image3>"><img src="<tmpl_var thumbnail3>" alt="<tmpl_var thumbnail3>" border="0" /></a>
		</tmpl_if>
	</td>
</tr>
</table>

<table border="0" cellpadding="0" cellspacing="5" width="100%">
<tr>
	<td valign="top" class="tableData" width="35%">
		<b>Features</b><br />
		<tmpl_if session.var.adminOn>
			<a href="<tmpl_var addfeature.url>"><tmpl_var addfeature.label></a><p />
		</tmpl_if>
		<tmpl_loop feature_loop>
			&middot;<tmpl_if session.var.adminOn><tmpl_var feature.controls></tmpl_if><tmpl_var feature.feature><br />
		</tmpl_loop>
		<p />
		<b>Benefits</b><br/>
		<tmpl_if session.var.adminOn>
			<a href="<tmpl_var addBenefit.url>"><tmpl_var addBenefit.label></a>
			<p />
		</tmpl_if>
		<tmpl_loop benefit_loop>
			&middot;<tmpl_if session.var.adminOn><tmpl_var benefit.controls></tmpl_if><tmpl_var benefit.benefit><br />
		</tmpl_loop>
		<p />
	</td>
	<td valign="top" class="tableData" width="35%">
		<b>Specifications</b><br />
		<tmpl_if session.var.adminOn>
			<a href="<tmpl_var addSpecification.url>"><tmpl_var addSpecification.label></a><p />
		</tmpl_if>
		<tmpl_loop specification_loop>
			&middot;<tmpl_if session.var.adminOn><tmpl_var specification.controls></tmpl_if><b><tmpl_var specification.label>:</b> <tmpl_var specification.specification> <tmpl_var specification.units><br />
		</tmpl_loop>
		<p />
		<b>Accessories</b><br />
		<tmpl_if session.var.adminOn>
			<a href="<tmpl_var addaccessory.url>"><tmpl_var addaccessory.label></a>
			<p />
		</tmpl_if>
		<tmpl_loop accessory_loop>
			&middot;<tmpl_if session.var.adminOn><tmpl_var accessory.controls></tmpl_if><a href="<tmpl_var accessory.url>"><tmpl_var accessory.title></a><br />
		</tmpl_loop>
		<p />
		<b>Related Products</b><br />
		<tmpl_if session.var.adminOn>
			<a href="<tmpl_var addRelatedProduct.url>"><tmpl_var addRelatedProduct.label></a>
			<p />
		</tmpl_if>
		<tmpl_loop relatedproduct_loop>
			&middot;<tmpl_if session.var.adminOn><tmpl_var RelatedProduct.controls></tmpl_if><a href="<tmpl_var relatedproduct.url>"><tmpl_var relatedproduct.title></a><br />
		</tmpl_loop>
		<p />
	</td>
	<td class="tableData" valign="top" width="30%">
		<tmpl_if price>
			<b>Price:</b> <tmpl_var price><br />
		</tmpl_if>
		<tmpl_if productnumber>
			<b>Product Number:</b> <tmpl_var productNumber><br />
		</tmpl_if>
		<br />
		<tmpl_if brochure.url>
			<a href="<tmpl_var brochure.url>"><img src="<tmpl_var brochure.icon>" alt="<tmpl_var brochure.icon>" border=0 align="absmiddle" /><tmpl_var brochure.label></a><br />
		</tmpl_if>
		<tmpl_if manual.url>
			<a href="<tmpl_var manual.url>"><img src="<tmpl_var manual.icon>" alt="<tmpl_var manual.icon>" border=0 align="absmiddle" /><tmpl_var manual.label></a><br />
		</tmpl_if>
		<tmpl_if warranty.url>
			<a href="<tmpl_var warranty.url>"><img src="<tmpl_var warranty.icon>" alt="<tmpl_var warranty.icon>" border=0 align="absmiddle" /><tmpl_var warranty.label></a><br />
		</tmpl_if>
	</td>
</tr>
</table>
END

$fixedTemplates{PBtmpl0000000000000111} = << 'END';
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

	<div align="center"><a href="^PageUrl;"><img src="^Extras;plainblack.gif" alt="plainblack" border="0" /></a></div>

	<tmpl_var body.content>

	<div align="center">&copy; 2001-2005 Plain Black Corporation</div>

</body>
</html>
END

$fixedTemplates{PBtmpl0000000000000112} = << 'END';
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>

<tmpl_if session.var.adminOn>
	<p><tmpl_var controls></p>
</tmpl_if>

<tmpl_if displayTitle>
	<h1><tmpl_var title></h1>
</tmpl_if>

<tmpl_if description>
	<tmpl_var description>
</tmpl_if>

<p>
	<tmpl_if user.canPost>
		<a href="<tmpl_var add.url>"><tmpl_var add.label></a>
		&bull;
	</tmpl_if>
	<tmpl_unless user.isVisitor>
		<tmpl_if user.isSubscribed>
			<a href="<tmpl_var unsubscribe.url>"><tmpl_var unsubscribe.label></a>
		<tmpl_else>
			<a href="<tmpl_var subscribe.url>"><tmpl_var subscribe.label></a>
		</tmpl_if>
		&bull;
	</tmpl_unless>
	<a href="<tmpl_var search.url>"><tmpl_var search.label></a>
</p>

<style type="text/css">

.weblogTitleBar {
	font-weight: bold;
	font-size: 14px;
}

.weblogLegend {
	font-size: 9px;
	color: #999999;
}

.weblogReadMore {
	text-align: right;
	font-size: 9px;
	width: 100%;
}

.weblogSynopsis {
	border: 1px solid #bbbbbb;
	font-size: 13px;
	padding: 5px;
	-moz-border-radius: 6px;
}

</style>

<p />

<tmpl_loop post_loop>
	<div class="weblogTitleBar">
		<tmpl_var title>
	</div>
	<fieldset class="weblogSynopsis">
		<legend class="weblogLegend" align="left">
			<tmpl_var by.label> <a href="<tmpl_var userProfile.url>"><tmpl_var username></a>
			-
			<tmpl_var dateSubmitted.human>
			<tmpl_if replies>
				- <tmpl_var replies> <tmpl_var replies.label>
			</tmpl_if>
			<tmpl_if user.isPoster>
				 - <tmpl_var status>
			<tmpl_else>
				<tmpl_if user.isModerator>
					- <tmpl_var status>
				</tmpl_if>
			</tmpl_if>
		</legend>
		<tmpl_if thumbnail>
			<a href="<tmpl_var url>"><img src="<tmpl_var thumbnail>" border="0" alt="<tmpl_var title>" align="right" /></a>
		</tmpl_if>
		<tmpl_var synopsis>
		<div class="weblogReadMore">
			<a href="<tmpl_var url>"><tmpl_var readmore.label></a>
		</div>
	</fieldset>
	<p />
</tmpl_loop>

<tmpl_if pagination.pageCount.isMultiple>
	<div class="pagination">
		<tmpl_var pagination.previousPage> &middot; <tmpl_var pagination.pageList.upTo10> &middot; <tmpl_var pagination.nextPage>
	</div>
</tmpl_if>
						 
END

$fixedTemplates{PBtmpl0000000000000113} = << 'END';
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a> 

<tmpl_if session.var.adminOn> 
	<p><tmpl_var controls></p>
</tmpl_if>

<h1><tmpl_var title></h1>

<tmpl_if user.isModerator>
	<div style="float: right; font-size: 11px; border: 1px solid #cccccc; padding: 2px; margin: 2px;">
		<b><tmpl_var status.label>:</b> <tmpl_var status> &nbsp; &nbsp; [ <a href="<tmpl_var approve.url>"><tmpl_var approve.label></a> | <a href="<tmpl_var deny.url>"><tmpl_var deny.label></a> ]<br />
	</div>
</tmpl_if>	

<tmpl_if content>
	<b>Link Description</b><br />
	<p><tmpl_var content></p>
</tmpl_if>

<b>Link URL</b><br />
<a href="<tmpl_var userDefined1>"><tmpl_var userDefined1></a>

<tmpl_if attachment_loop>
	<br />
		<tmpl_loop attachment_loop>
			<div style="float: left; padding: 5px;">
				<a href="<tmpl_var url>"><tmpl_if isImage><img src="<tmpl_var thumbnail>" border="0" alt="<tmpl_var filename>" /><tmpl_else><img src="<tmpl_var icon>" border="0" alt="<tmpl_var filename>" align="middle" /> <tmpl_var filename></tmpl_if></a>
			</div>
		</tmpl_loop>
		<div style="clear: both;"></div>
	<br />
</tmpl_if>

<tmpl_unless isLocked>
	<p>
		<tmpl_if user.canReply>
			<a href="<tmpl_var reply.url>">[<tmpl_var reply.label>]</a>
		</tmpl_if>
		<tmpl_if user.canEdit>
			<a href="<tmpl_var edit.url>">[<tmpl_var edit.label>]</a>
			<a href="<tmpl_var delete.url>">[<tmpl_var delete.label>]</a>
		</tmpl_if>
	</p>
</tmpl_unless>

<tmpl_if repliesAllowed>
	<style type="text/css">
		.postBorder {
			border: 1px solid #cccccc;
			margin-bottom: 10px;
		}
		.postBorderCurrent {
			border: 3px dotted black;
			margin-bottom: 10px;
		}
		.postSubject {
			border-bottom: 1px solid #cccccc;
			font-weight: bold;
			padding: 3px;
		}
		.postData {
			border-bottom: 1px solid #cccccc;
			font-size: 11px;
			background-color: #eeeeee;
			color: black;
			padding: 3px;
		}
		.postControls {
			border-top: 1px solid #cccccc;
			background-color: #eeeeee;
			color: black;
			padding: 3px;
		}
		.postMessage {
			padding: 3px;
		}
		.currentThread {
			background-color: #eeeeee;
		}
		.threadHead {
			font-weight: bold;
			border-bottom: 1px solid #cccccc;
			font-size: 11px;
			background-color: #eeeeee;
			color: black;
			padding: 3px;
		}
		.threadData {
			font-size: 11px;
			padding: 3px;
		}
	</style>

	<div style="float: left; width: 70%">
		<h1><tmpl_var replies.label></h1>
	</div>
	<div style="width: 30%; float: left; text-align: right;">
	<tmpl_if layout.isFlat>
		<a href="<tmpl_var layout.nested.url>"><tmpl_var layout.nested.label></a>
	<tmpl_else>
		<a href="<tmpl_var layout.flat.url>"><tmpl_var layout.flat.label></a>
	</tmpl_if>
	</div>
	<div style="clear: both;"></div>
	
	<tmpl_if layout.isFlat>
	<!-- begin flat layout -->
		<tmpl_loop post_loop>
			<tmpl_unless isThreadRoot>
				<div class="postBorder<tmpl_if isCurrent>Current</tmpl_if>">
					<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>
					<div class="postSubject">
						<tmpl_var title>
					</div>
					<div class="postData">
						<div style="float: left; width: 50%">
							<b><tmpl_var user.label>:</b> 
								<tmpl_if user.isVisitor>
									<tmpl_var username>
								<tmpl_else>
									<a href="<tmpl_var userProfile.url>"><tmpl_var username></a>
								</tmpl_if>
								<br />
							<b><tmpl_var date.label>:</b> <tmpl_var dateSubmitted.human><br />
						</div>	
						<div>
							<b><tmpl_var views.label>:</b> <tmpl_var views><br />
							<b><tmpl_var rating.label>:</b> <tmpl_var rating>
								<tmpl_unless hasRated>
									 &nbsp; &nbsp;<tmpl_var rate.label> [ <a href="<tmpl_var rate.url.1>">1</a>, <a href="<tmpl_var rate.url.2>">2</a>, <a href="<tmpl_var rate.url.3>">3</a>, <a href="<tmpl_var rate.url.4>">4</a>, <a href="<tmpl_var rate.url.5>">5</a> ]
								</tmpl_unless>
								<br />
							<tmpl_if user.isModerator>
								<b><tmpl_var status.label>:</b> <tmpl_var status> &nbsp; &nbsp; [ <a href="<tmpl_var approve.url>"><tmpl_var approve.label></a> | <a href="<tmpl_var deny.url>"><tmpl_var deny.label></a> ]<br />
							<tmpl_else>	
								<tmpl_if user.isPoster>
									<b><tmpl_var status.label>:</b> <tmpl_var status><br />
								</tmpl_if>	
							</tmpl_if>	
						</div>	
					</div>
					<div class="postMessage">
						<tmpl_var content>
						<tmpl_loop attachment_loop>
							<div style="float: left; padding: 5px;"><a href="<tmpl_var url>"><tmpl_if isImage><img src="<tmpl_var thumbnail>" border="0" alt="<tmpl_var filename>" /><tmpl_else><img src="<tmpl_var icon>" border="0" alt="<tmpl_var filename>" align="middle" /> <tmpl_var filename></tmpl_if></a></div>
						</tmpl_loop>
						<div style="clear: both;"></div>
					</div>
					<tmpl_unless isLocked>
						<div class="postControls">
							<tmpl_if user.canReply>
								<a href="<tmpl_var reply.url>">[<tmpl_var reply.label>]</a>
							</tmpl_if>
							<tmpl_if user.canEdit>
								<a href="<tmpl_var edit.url>">[<tmpl_var edit.label>]</a>
								<a href="<tmpl_var delete.url>">[<tmpl_var delete.label>]</a>
							</tmpl_if>
						</div>
					</tmpl_unless>
				</div>
			</tmpl_unless>
		</tmpl_loop>
	<!-- end flat layout -->
	</tmpl_if>
	
	<tmpl_if layout.isNested>
	<!-- begin nested layout -->
		<tmpl_loop post_loop>
			<tmpl_unless isThreadRoot>
				<div style="margin-left: <tmpl_var depthX10>px;">
					<div class="postBorder<tmpl_if isCurrent>Current</tmpl_if>">
						<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>
						<div class="postSubject">
							<tmpl_var title>
						</div>
						<div class="postData">
							<div style="float: left; width: 50%">
								<b><tmpl_var user.label>:</b> 
									<tmpl_if user.isVisitor>
										<tmpl_var username>
									<tmpl_else>
										<a href="<tmpl_var userProfile.url>"><tmpl_var username></a>
									</tmpl_if>
									<br />
								<b><tmpl_var date.label>:</b> <tmpl_var dateSubmitted.human><br />
							</div>	
							<div>
								<b><tmpl_var views.label>:</b> <tmpl_var views><br />
								<b><tmpl_var rating.label>:</b> <tmpl_var rating>
									<tmpl_unless hasRated>
										 &nbsp; &nbsp;<tmpl_var rate.label> [ <a href="<tmpl_var rate.url.1>">1</a>, <a href="<tmpl_var rate.url.2>">2</a>, <a href="<tmpl_var rate.url.3>">3</a>, <a href="<tmpl_var rate.url.4>">4</a>, <a href="<tmpl_var rate.url.5>">5</a> ]
									</tmpl_unless>
									<br />
								<tmpl_if user.isModerator>
									<b><tmpl_var status.label>:</b> <tmpl_var status> &nbsp; &nbsp; [ <a href="<tmpl_var approve.url>"><tmpl_var approve.label></a> | <a href="<tmpl_var deny.url>"><tmpl_var deny.label></a> ]<br />
								<tmpl_else>	
									<tmpl_if user.isPoster>
										<b><tmpl_var status.label>:</b> <tmpl_var status><br />
									</tmpl_if>	
								</tmpl_if>	
							</div>	
						</div>
						<div class="postMessage">
							<tmpl_var content>
							<tmpl_loop attachment_loop>
								<div style="float: left; padding: 5px;"><a href="<tmpl_var url>"><tmpl_if isImage><img src="<tmpl_var thumbnail>" border="0" alt="<tmpl_var filename>" /><tmpl_else><img src="<tmpl_var icon>" border="0" alt="<tmpl_var filename>" align="middle" /> <tmpl_var filename></tmpl_if></a></div>
							</tmpl_loop>
							<div style="clear: both;"></div>
						</div>
						<tmpl_unless isLocked>
							<div class="postControls">
								<tmpl_if user.canReply>
									<a href="<tmpl_var reply.url>">[<tmpl_var reply.label>]</a>
								</tmpl_if>
								<tmpl_if user.canEdit>
									<a href="<tmpl_var edit.url>">[<tmpl_var edit.label>]</a>
									<a href="<tmpl_var delete.url>">[<tmpl_var delete.label>]</a>
								</tmpl_if>
							</div>
						</tmpl_unless>
					</div>
				</div>
			</tmpl_unless>
		</tmpl_loop>
	<!-- end nested layout -->
	</tmpl_if>
	
	<tmpl_if pagination.pageCount.isMultiple>
		<div class="pagination" style="margin-top: 20px;">
			[ <tmpl_var pagination.previousPage> | <tmpl_var pagination.pageList.upTo10> | <tmpl_var pagination.nextPage> ]
		</div>
	</tmpl_if>
</tmpl_if>	

<div style="margin-top: 20px;">
	<tmpl_if previous.url>
		<a href="<tmpl_var previous.url>">[<tmpl_var previous.label>]</a> 
	</tmpl_if>	
	<a href="<tmpl_var collaboration.url>">[List All Links]</a>
	<tmpl_if next.url>
		<a href="<tmpl_var next.url>">[<tmpl_var next.label>]</a> 
	</tmpl_if>	
	<tmpl_if user.canPost>
		<a href="<tmpl_var add.url>">[<tmpl_var add.label>]</a>
	</tmpl_if>
	<tmpl_if user.isModerator>
		<tmpl_if isSticky>
			<a href="<tmpl_var unstick.url>">[<tmpl_var unstick.label>]</a>
		<tmpl_else>
			<a href="<tmpl_var stick.url>">[<tmpl_var stick.label>]</a>
		</tmpl_if>
		<tmpl_if isLocked>
			<a href="<tmpl_var unlock.url>">[<tmpl_var unlock.label>]</a>
		<tmpl_else>
			<a href="<tmpl_var lock.url>">[<tmpl_var lock.label>]</a>
		</tmpl_if>
	</tmpl_if>
	<tmpl_unless user.isVisitor>
		<tmpl_if user.isSubscribed>
			<a href="<tmpl_var unsubscribe.url>">[<tmpl_var unsubscribe.label>]</a>
		<tmpl_else>
			<a href="<tmpl_var subscribe.url>">[<tmpl_var subscribe.label>]</a>
		</tmpl_if>
	</tmpl_unless>
</div>
END

$fixedTemplates{PBtmpl0000000000000114} = << 'END';
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>

<tmpl_if preview.title><p><b><tmpl_var preview.title></b></p></tmpl_if>
<tmpl_if preview.content><p><tmpl_var preview.content></p></tmpl_if>
<tmpl_if preview.userDefined1><p><a href="<tmpl_var preview.userDefined1>" <tmpl_if preview.userDefined2>target="_blank"</tmpl_if>><tmpl_var preview.userDefined1></a></p></tmpl_if>

<tmpl_if isReply>
	<h1><tmpl_var message.header.label></h1>
<tmpl_else>
	<h1><tmpl_var link.header.label></h1>
</tmpl_if>

<tmpl_var form.header>
<table>
	<tmpl_if isReply>
		<tr>
			<td><tmpl_var subject.label></td>
			<td><tmpl_var title.form></td>
		</tr>
		<tr>
			<td><tmpl_var message.label></td>
			<td><tmpl_var content.form></td>
		</tr>
	<tmpl_else>
		<tr>
			<td><tmpl_var title.label></td>
			<td><tmpl_var title.form></td>
		</tr>
		<tr>
			<td><tmpl_var url.label></td>
			<td><tmpl_var userDefined1.form></td>
		</tr>
		<tr>
			<td><tmpl_var newWindow.label></td>
			<td><tmpl_var userDefined1.form.yesNo></td>
		</tr>
		<tr>
			<td><tmpl_var description.label></td>
			<td><tmpl_var content.form></td>
		</tr>
		<tmpl_if attachment.form>
			<tr>
				<td><tmpl_var attachment.label></td>
				<td><tmpl_var attachment.form></td>
			</tr>
		</tmpl_if>
	</tmpl_if>
	<tr>
		<td><tmpl_var contentType.label></td>
		<td><tmpl_var contentType.form></td>
	</tr>
	<tmpl_if isNewPost>
		<tmpl_unless user.isVisitor>
			<tr>
				<td><tmpl_var subscribe.label></td>
				<td><tmpl_var subscribe.form></td>
			</tr>
		</tmpl_unless>
		<tmpl_if isNewThread>
			<tmpl_if user.isModerator>
				<tr>
					<td><tmpl_var lock.label></td>
					<td><tmpl_var lock.form></td>
				</tr>
				<tr>
					<td><tmpl_var stick.label></td>
					<td><tmpl_var sticky.form></td>
				</tr>
			</tmpl_if>
		</tmpl_if>
	</tmpl_if>
	<tr>
		<td></td>
		<td><tmpl_if usePreview><tmpl_var form.preview></tmpl_if><tmpl_var form.submit></td>
	</tr>
</table>
<tmpl_var form.footer>

<tmpl_if isReply>
	<p><b><tmpl_var reply.title></b></p>
	<tmpl_var reply.content>
	<tmpl_if reply.userDefined1><p><a href="<tmpl_var reply.userDefined1>" <tmpl_if reply.userDefined2>target="_blank"</tmpl_if>><tmpl_var reply.userDefined1></a></p></tmpl_if>
</tmpl_if>
END

$fixedTemplates{PBtmpl0000000000000115} = << 'END';
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>

<tmpl_if session.var.adminOn>
	<p><tmpl_var controls></p>
</tmpl_if>

<tmpl_if displayTitle>
	<h1><tmpl_var title></h1>
</tmpl_if>

<tmpl_if pagination.isFirstPage>
<tmpl_if image.url>
	<table width="100%" border="0" cellpadding="0" cellspacing="0"><tr><td class="content">
		<table align="right">
		<tr><td align="center">
			<tmpl_if linkUrl>
				<a href="<tmpl_var linkUrl>">
				<img src="<tmpl_var image.url>" alt="<tmpl_var image.url>" border="0" /><br /><tmpl_var linkTitle>
				</a>
			<tmpl_else>
				<img src="<tmpl_var image.url>" alt="<tmpl_var image.url>" border="0" /><br /><tmpl_var linkTitle>
			</tmpl_if>
		</td></tr>
		</table>
</tmpl_if>
</tmpl_if>

<tmpl_if description>
	<tmpl_var description>
	<p />
</tmpl_if>

<tmpl_if pagination.isLastPage>
	<tmpl_var attachment.box>
	<p />
</tmpl_if>

<tmpl_if pagination.isFirstPage>
<tmpl_if image.url>
	</td></tr></table>
</tmpl_if>
</tmpl_if>

<tmpl_if pagination.pageCount.isMultiple>
<tmpl_var pagination.previousPage>
&middot;
<tmpl_var pagination.pageList.upTo20>
&middot;
<tmpl_var pagination.nextPage>
</tmpl_if>

<tmpl_if pagination.isLastPage>
<tmpl_if allowDiscussion>
	<p />
	<table width="100%" cellspacing="2" cellpadding="1" border="0">
	<tr><td align="center" width="50%" class="tableMenu"><a href="<tmpl_var replies.URL>"><tmpl_var replies.label> (<tmpl_var replies.count>)</a></td>
	<td align="center" width="50%" class="tableMenu"><a href="<tmpl_var post.url>"><tmpl_var post.label></a></td></tr>
	</table>
</tmpl_if>
</tmpl_if>
END

$fixedTemplates{PBtmpl0000000000000116} = << 'END';
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>

<tmpl_if session.var.adminOn>
	<p><tmpl_var controls></p>
</tmpl_if>

<tmpl_if displayTitle>
	<h1><tmpl_var title></h1>
</tmpl_if>

<tmpl_if error_loop>
	<ul>
		<tmpl_loop error_loop>
			<li><b><tmpl_var error.message></b></li>
		</tmpl_loop>
	</ul>
</tmpl_if>

<tmpl_if description>
	<tmpl_var description>
	<p />
</tmpl_if>

<tmpl_if canEdit>
	<a href="<tmpl_var entryList.url>"><tmpl_var entryList.label></a>
		&middot; <a href="<tmpl_var export.tab.url>"><tmpl_var export.tab.label></a>
	<tmpl_if entryId>
		&middot; <a href="<tmpl_var delete.url>"><tmpl_var delete.label></a>
	</tmpl_if>
	<tmpl_if session.var.adminOn>
		&middot; <a href="<tmpl_var addField.url>"><tmpl_var addField.label></a>
		&middot; <a href="<tmpl_var addTab.url>"><tmpl_var addTab.label></a>
	</tmpl_if>
	<p />
</tmpl_if>
<tmpl_var form.start>
<link href="/extras/tabs/tabs.css" rel="stylesheet" rev="stylesheet" type="text/css">
<div class="tabs">
	<tmpl_loop tab_loop>
		<span onclick="toggleTab(<tmpl_var tab.sequence>)" id="tab<tmpl_var tab.sequence>" class="tab"><tmpl_var tab.label>
		<tmpl_if session.var.adminOn>
			<tmpl_if canEdit>
				<tmpl_var tab.controls>
			</tmpl_if>
		</tmpl_if>
		</span>
	</tmpl_loop>
</div>
<tmpl_loop tab_loop>
	<tmpl_var tab.start>
		<table>
			<tmpl_loop tab.field_loop>
				<tmpl_unless tab.field.isHidden>
						<tr>
							<td class="formDescription" valign="top">
								<tmpl_if session.var.adminOn>
									<tmpl_if canEdit>
										<tmpl_var tab.field.controls>
									</tmpl_if>
								</tmpl_if>
								<tmpl_var tab.field.label>
							</td>
							<td class="tableData" valign="top">
								<tmpl_if tab.field.isDisplayed>
									<tmpl_var tab.field.value>
								<tmpl_else>
									<tmpl_var tab.field.form>
								</tmpl_if>
								<tmpl_if tab.field.isRequired>*</tmpl_if>
								<span class="formSubtext">
									<br />
									<tmpl_var tab.field.subtext>
								</span>
							</td>
						</tr>
				</tmpl_unless>
			</tmpl_loop>
			<tr>
				<td colspan="2">
					<span class="tabSubtext"><tmpl_var tab.subtext></span>
				</td>
			</tr>
		</table>
		<br />
		<tmpl_var form.save>
	<tmpl_var tab.end>
</tmpl_loop>
<tmpl_var tab.init>
<tmpl_var form.end>
END

$fixedTemplates{PBtmpl0000000000000117} = << 'END';
<tmpl_if displayTitle>
	<h1><tmpl_var title></h1>
</tmpl_if>

<tmpl_if description>
	<p><tmpl_var description></p>
</tmpl_if>

<script type="text/javascript" defer="defer">
<!--
function go(formObj) {
	if (formObj.chooser.options[formObj.chooser.selectedIndex].value != "none") {
		location = formObj.chooser.options[formObj.chooser.selectedIndex].value;
	}
}
//-->
</script>

<form>
<tmpl_if session.var.adminOn><tmpl_var controls></tmpl_if>
<select name="chooser" size=1 onChange="go(this.form)">
<option value=none>Where do you want to go?</option>
<tmpl_loop page_loop>
	<option value="<tmpl_var page.url>"><tmpl_loop page.indent_loop>&nbsp;&nbsp;</tmpl_loop>- <tmpl_var page.menuTitle></option>
</tmpl_loop>
</select>
</form>
END

$fixedTemplates{PBtmpl0000000000000118} = << 'END';
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>

<tmpl_if showAdmin>
<p><tmpl_var controls></p>
</tmpl_if>

^RawHeadTags(<style type="text/css">
.firstColumn {
  float: left;
  width: 33%;
}
.secondColumn {
        float: left;
        width: 33%;
}
.thirdColumn {
        float: left;
        width: auto;
        max-width: 33%;
}
.endFloat {
 clear: both;
}
</style>);

<tmpl_if displayTitle>
  <h1><tmpl_var title></h1>
</tmpl_if>

<tmpl_if description>
  <p><tmpl_var description></p>
</tmpl_if>

<!-- begin position 1 -->
<div class="firstColumn"><div class="layoutColumnPadding">
<tmpl_if showAdmin>
	<table border="0" id="position1" class="content"><tbody>
</tmpl_if>

<tmpl_loop position1_loop>
	<tmpl_if showAdmin>
            	<tr id="td<tmpl_var id>">
            		<td><div id="td<tmpl_var id>_div" class="dragable">
	</tmpl_if>

	<div class="content"><tmpl_var dragger.icon><tmpl_var content></div>

	<tmpl_if showAdmin>
         			</div></td>
            	</tr>
	</tmpl_if>
</tmpl_loop>

<tmpl_if showAdmin>
            </tbody></table>
</tmpl_if>
</div></div>
<!-- end position 1 -->

<!-- begin position 2 -->
<div class="secondColumn"><div class="layoutColumnPadding">
<tmpl_if showAdmin>
	<table border="0" id="position2" class="content"><tbody>
</tmpl_if>

<tmpl_loop position2_loop>
	<tmpl_if showAdmin>
            	<tr id="td<tmpl_var id>">
            		<td><div id="td<tmpl_var id>_div" class="dragable">
	</tmpl_if>

	<div class="content"><tmpl_var dragger.icon><tmpl_var content></div>

	<tmpl_if showAdmin>
         			</div></td>
            	</tr>
	</tmpl_if>
</tmpl_loop>

<tmpl_if showAdmin>
            </tbody></table>
</tmpl_if>
</div></div>
<!-- end position 2 -->

<!-- begin position 3 -->
<div class="thirdColumn"><div class="layoutColumnPadding">
<tmpl_if showAdmin>
	<table border="0" id="position3" class="content"><tbody>
</tmpl_if>

<tmpl_loop position3_loop>
	<tmpl_if showAdmin>
            	<tr id="td<tmpl_var id>">
            		<td><div id="td<tmpl_var id>_div" class="dragable">
	</tmpl_if>

	<div class="content"><tmpl_var dragger.icon><tmpl_var content></div>

	<tmpl_if showAdmin>
         			</div></td>
            	</tr>
	</tmpl_if>
</tmpl_loop>

<tmpl_if showAdmin>
            </tbody></table>
</tmpl_if>
</div></div>
<!-- end position 3 -->

<div class="endFloat">&nbsp;</div>

<!-- begin position 4 -->
<div class="layoutColumnPadding">
<tmpl_if showAdmin>
	<table border="0" id="position4" class="content"><tbody>
</tmpl_if>

<tmpl_loop position4_loop>
	<tmpl_if showAdmin>
            	<tr id="td<tmpl_var id>">
            		<td><div id="td<tmpl_var id>_div" class="dragable">
	</tmpl_if>

	<div class="content"><tmpl_var dragger.icon><tmpl_var content></div>

	<tmpl_if showAdmin>
         			</div></td>
            	</tr>
	</tmpl_if>
</tmpl_loop>

<tmpl_if showAdmin>
            </tbody></table>
</tmpl_if>
</div>
<!-- end position 4 -->

<tmpl_if showAdmin>
	<table><tr id="blank" class="hidden"><td><div><div class="empty">&nbsp;</div></div></td></tr></table>
            <tmpl_var dragger.init>
</tmpl_if>
END

$fixedTemplates{PBtmpl0000000000000119} = << 'END';
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>

<tmpl_if session.var.adminOn>
	<p><tmpl_var controls></p>
</tmpl_if>

<style type="text/css">
.productCollateral {
	font-size: 11px;
}
</style>

<tmpl_if displayTitle>
	<h1><tmpl_var title></h1>
</tmpl_if>

<table width="100%">
<tr><td valign="top" class="productCollateral" width="100">
<img src="^Extras;spacer.gif" alt="" width="100" height="1" /><br />
<tmpl_if brochure.url>
	<a href="<tmpl_var brochure.url>"><img src="<tmpl_var brochure.icon>" alt="<tmpl_var brochure.icon>" border=0 align="absmiddle" /><tmpl_var brochure.label></a><br />
</tmpl_if>
<tmpl_if manual.url>
	<a href="<tmpl_var manual.url>"><img src="<tmpl_var manual.icon>" alt="<tmpl_var manual.icon>" border=0 align="absmiddle" /><tmpl_var manual.label></a><br />
</tmpl_if>
<tmpl_if warranty.url>
	<a href="<tmpl_var warranty.url>"><img src="<tmpl_var warranty.icon>" alt="<tmpl_var warranty.icon>" border=0 align="absmiddle" /><tmpl_var warranty.label></a><br />
</tmpl_if>
<br />
<div align="center">
<tmpl_if thumbnail1>
	<a href="<tmpl_var image1>"><img src="<tmpl_var thumbnail1>" alt="<tmpl_var thumbnail1>" border="0" /></a><p />
</tmpl_if>
<tmpl_if thumbnail2>
	<a href="<tmpl_var image2>"><img src="<tmpl_var thumbnail2>" alt="<tmpl_var thumbnail2>" border="0" /></a><p />
</tmpl_if>
<tmpl_if thumbnail3>
	<a href="<tmpl_var image3>"><img src="<tmpl_var thumbnail3>" alt="<tmpl_var thumbnail3>" border="0" /></a><p />
</tmpl_if>
</div>
</td><td valign="top" class="content" width="100%">
<tmpl_if description>
<tmpl_var description><p />
</tmpl_if>

<b>Specs:</b><br/>
<tmpl_if session.var.adminOn>
	<a href="<tmpl_var addSpecification.url>"><tmpl_var addSpecification.label></a><p />
</tmpl_if>
<tmpl_loop specification_loop>
	&middot;<tmpl_if session.var.adminOn><tmpl_var specification.controls></tmpl_if><b><tmpl_var specification.label>:</b> <tmpl_var specification.specification> <tmpl_var specification.units><br />
</tmpl_loop>
<p />

<b>Features:</b><br/>
<tmpl_if session.var.adminOn>
	<a href="<tmpl_var addfeature.url>"><tmpl_var addfeature.label></a><p />
</tmpl_if>
<tmpl_loop feature_loop>
	&middot;<tmpl_if session.var.adminOn><tmpl_var feature.controls></tmpl_if><tmpl_var feature.feature><br />
</tmpl_loop>
<p />

<b>Options:</b><br />
<tmpl_if session.var.adminOn>
	<a href="<tmpl_var addaccessory.url>"><tmpl_var addaccessory.label></a><p />
</tmpl_if>
<tmpl_loop accessory_loop>
	&middot;<tmpl_if session.var.adminOn><tmpl_var accessory.controls></tmpl_if><a href="<tmpl_var accessory.url>"><tmpl_var accessory.title></a><br />
</tmpl_loop>

</td></tr>
</table>
END

$fixedTemplates{PBtmpl0000000000000121} = << 'END';
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>

<tmpl_if session.var.adminOn>
	<p><tmpl_var controls></p>
</tmpl_if>

<tmpl_if displayTitle>
	<h1><tmpl_var title></h1>
</tmpl_if>

<tmpl_if description>
	<tmpl_var description>
</tmpl_if>

<p>
	<tmpl_if user.canPost>
		<a href="<tmpl_var add.url>"><tmpl_var add.label></a>
		&bull;
	</tmpl_if>
	<tmpl_unless user.isVisitor>
		<tmpl_if user.isSubscribed>
			<a href="<tmpl_var unsubscribe.url>"><tmpl_var unsubscribe.label></a>
		<tmpl_else>
			<a href="<tmpl_var subscribe.url>"><tmpl_var subscribe.label></a>
		</tmpl_if>
		&bull;
	</tmpl_unless>
	<a href="<tmpl_var search.url>"><tmpl_var search.label></a>
</p>

<style type="text/css">
.picture {
	padding: 0px;
	margin: 10px;
	float: left;
	width: 150px;
	font-size: 12px;
	height: 100px;
	overflow: hidden;
}
</style>

<br />

<tmpl_loop post_loop>
	<div class="picture">
		<div style="text-align: center;">
			<tmpl_if user.isPoster><div>(<tmpl_var status>)</div></tmpl_if>
			<div><a href="<tmpl_var url>"><img src="<tmpl_var thumbnail>" border="0" alt="<tmpl_var title>" /></a></div>
			<div><a href="<tmpl_var url>"><tmpl_var title></a></div>
		</div>
	</div>
</tmpl_loop>

<div style="clear: both;"></div>

<tmpl_if pagination.pageCount.isMultiple>
	<div class="pagination">
		<tmpl_var pagination.previousPage> &middot; <tmpl_var pagination.pageList.upTo10> &middot; <tmpl_var pagination.nextPage>
	</div>
</tmpl_if>
END

$fixedTemplates{PBtmpl0000000000000122} = << 'END';
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>

<tmpl_if preview.title><p><b><tmpl_var preview.title></b></p></tmpl_if>
<tmpl_if preview.content><p><tmpl_var preview.content></p></tmpl_if>
<tmpl_if preview.userDefined3><p><tmpl_var preview.userDefined3></p></tmpl_if>
<tmpl_if preview.userDefined1><p><tmpl_var preview.userDefined1></p></tmpl_if>
<tmpl_if preview.userDefined2><p><tmpl_var preview.userDefined2></p></tmpl_if>

<tmpl_if isReply>
	<h1><tmpl_var message.header.label></h1>
<tmpl_else>
	<h1><tmpl_var job.header.label></h1>
</tmpl_if>

<tmpl_var form.header>
<table>
	<tmpl_if isReply>
		<tr>
			<td><tmpl_var subject.label></td>
			<td><tmpl_var title.form></td>
		</tr>
		<tr>
			<td><tmpl_var message.label></td>
			<td><tmpl_var content.form></td>
		</tr>
	<tmpl_else>
		<tr>
			<td><tmpl_var job.title.label></td>
			<td><tmpl_var title.form></td>
		</tr>
		<tr>
			<td><tmpl_var synopsis.label></td>
			<td><tmpl_var synopsis.form></td>
		</tr>
		<tr>
			<td><tmpl_var job.description.label></td>
			<td><tmpl_var content.form></td>
		</tr>
		<tr>
			<td><tmpl_var job.requirements.label></td>
			<td><tmpl_var userDefined3.form.htmlarea></td>
		</tr>
		<tr>
			<td><tmpl_var compensation.label></td>
			<td><tmpl_var userDefined1.form></td>
		</tr>
		<tr>
			<td><tmpl_var location.label></td>
			<td><tmpl_var userDefined2.form></td>
		</tr>
		<tmpl_if attachment.form>
			<tr>
				<td><tmpl_var attachment.label></td>
				<td><tmpl_var attachment.form></td>
			</tr>
		</tmpl_if>
		<tr>
			<td><tmpl_var startDate.label></td>
			<td><tmpl_var startDate.form></td>
		</tr>
		<tr>
			<td><tmpl_var endDate.label></td>
			<td><tmpl_var endDate.form></td>
		</tr>
	</tmpl_if>
	<tr>
		<td><tmpl_var contentType.label></td>
		<td><tmpl_var contentType.form></td>
	</tr>
	<tmpl_if isNewPost>
		<tmpl_unless user.isVisitor>
			<tr>
				<td><tmpl_var subscribe.label></td>
				<td><tmpl_var subscribe.form></td>
			</tr>
		</tmpl_unless>
		<tmpl_if isNewThread>
			<tmpl_if user.isModerator>
				<tr>
					<td><tmpl_var lock.label></td>
					<td><tmpl_var lock.form></td>
				</tr>
				<tr>
					<td><tmpl_var stick.label></td>
					<td><tmpl_var sticky.form></td>
				</tr>
			</tmpl_if>
		</tmpl_if>
	</tmpl_if>
	<tr>
		<td></td>
		<td><tmpl_if usePreview><tmpl_var form.preview></tmpl_if><tmpl_var form.submit></td>
	</tr>
</table>
<tmpl_var form.footer>

<tmpl_if isReply>
	<p><b><tmpl_var reply.title></b></p>
	<tmpl_var reply.content>
	<tmpl_if reply.userDefined3><p><tmpl_var reply.userDefined3></p></tmpl_if>
	<tmpl_if reply.userDefined1><p><tmpl_var reply.userDefined1></p></tmpl_if>
	<tmpl_if reply.userDefined2><p><tmpl_var reply.userDefined2></p></tmpl_if>
</tmpl_if>
END

$fixedTemplates{PBtmpl0000000000000123} = << 'END';
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>

<tmpl_if session.var.adminOn>
	<p><tmpl_var controls></p>
</tmpl_if>

<tmpl_if displaytitle>
	<tmpl_if linkurl>
		<a href="<tmpl_var linkurl>">
	</tmpl_if>
	<span class="itemTitle"><tmpl_var title></span>
	<tmpl_if linkurl>
		</a>
	</tmpl_if>
</tmpl_if>

<tmpl_if attachment.name>
	<tmpl_if displaytitle> - </tmpl_if>
	<a href="<tmpl_var attachment.url>"><img src="<tmpl_var attachment.Icon>" border="0" alt="<tmpl_var attachment.name>" width="16" height="16" border="0" align="middle" /></a>
</tmpl_if>

<tmpl_if description>
  - <tmpl_var description>
</tmpl_if>
END

$fixedTemplates{PBtmpl0000000000000125} = << 'END';
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>

<tmpl_if showAdmin>
<p><tmpl_var controls></p>
</tmpl_if>

^RawHeadTags(<style type="text/css">
.firstColumn {
  float: left;
  width: 33%;
}
.secondColumn {
        float: left;
        width: auto;
        max-width: 65%;
}
.endFloat {
 clear: both;
}
</style>);

<tmpl_if displayTitle>
  <h1><tmpl_var title></h1>
</tmpl_if>

<tmpl_if description>
  <p><tmpl_var description></p>
</tmpl_if>

<!-- begin position 1 -->
<div class="firstColumn"><div class="layoutColumnPadding">
<tmpl_if showAdmin>
	<table border="0" id="position1" class="content"><tbody>
</tmpl_if>

<tmpl_loop position1_loop>
	<tmpl_if showAdmin>
            	<tr id="td<tmpl_var id>">
            		<td><div id="td<tmpl_var id>_div" class="dragable">
	</tmpl_if>

	<div class="content"><tmpl_var dragger.icon><tmpl_var content></div>

	<tmpl_if showAdmin>
         			</div></td>
            	</tr>
	</tmpl_if>
</tmpl_loop>

<tmpl_if showAdmin>
            </tbody></table>
</tmpl_if>
</div></div>
<!-- end position 1 -->

<!-- begin position 2 -->
<div class="secondColumn"><div class="layoutColumnPadding">
<tmpl_if showAdmin>
	<table border="0" id="position2" class="content"><tbody>
</tmpl_if>

<tmpl_loop position2_loop>
	<tmpl_if showAdmin>
            	<tr id="td<tmpl_var id>">
            		<td><div id="td<tmpl_var id>_div" class="dragable">
	</tmpl_if>

	<div class="content"><tmpl_var dragger.icon><tmpl_var content></div>

	<tmpl_if showAdmin>
         			</div></td>
            	</tr>
	</tmpl_if>
</tmpl_loop>

<tmpl_if showAdmin>
            </tbody></table>
</tmpl_if>
</div></div>
<!-- end position 2 -->

<div class="endFloat">&nbsp;</div>

<tmpl_if showAdmin>
	<table><tr id="blank" class="hidden"><td><div><div class="empty">&nbsp;</div></div></td></tr></table>
            <tmpl_var dragger.init>
</tmpl_if>

END

$fixedTemplates{PBtmpl0000000000000128} = << 'END';
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>

<tmpl_if session.var.adminOn>
	<p><tmpl_var controls></p>
</tmpl_if>

<tmpl_if displayTitle>
	<h1><tmpl_var title></h1>
</tmpl_if>

<tmpl_if description>
	<tmpl_var description>
</tmpl_if>

<p>
	<tmpl_if user.canPost>
		<a href="<tmpl_var add.url>"><tmpl_var add.label></a>
		&bull;
	</tmpl_if>
	<tmpl_unless user.isVisitor>
		<tmpl_if user.isSubscribed>
			<a href="<tmpl_var unsubscribe.url>"><tmpl_var unsubscribe.label></a>
		<tmpl_else>
			<a href="<tmpl_var subscribe.url>"><tmpl_var subscribe.label></a>
		</tmpl_if>
		&bull;
	</tmpl_unless>
	<a href="<tmpl_var search.url>"><tmpl_var search.label></a>
</p>

<style type="text/css">
.ad {
	border: 1px dotted #aaaaaa;
	padding: 10px;
	margin: 0px;
	float: left;
	width: 140px;
	font-size: 12px;
	height: 175px;
	overflow: hidden;
}
</style>

<br />

<tmpl_loop post_loop>
	<div class="ad">
		<div style="text-align: center;">
			<b><a href="<tmpl_var url>"><tmpl_var title></a></b><br />
			<tmpl_if user.isPoster>(<tmpl_var status>)</tmpl_if>
			<tmpl_if thumbnail>
				<div style="margin: 3px;">
					<a href="<tmpl_var url>"><img src="<tmpl_var thumbnail>" alt="<tmpl_var thumbnail>" border="0" /></a>
				</div>
			</tmpl_if>
		</div>
		<tmpl_var synopsis>
	</div>
</tmpl_loop>

<div style="clear: both;"></div>

<tmpl_if pagination.pageCount.isMultiple>
	<div class="pagination">
		<tmpl_var pagination.previousPage> &middot; <tmpl_var pagination.pageList.upTo10> &middot; <tmpl_var pagination.nextPage>
	</div>
</tmpl_if>
END

$fixedTemplates{PBtmpl0000000000000129} = << 'END';
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>

<tmpl_if session.var.adminOn>
	<p><tmpl_var controls></p>
</tmpl_if>

<tmpl_if displaytitle>
	<tmpl_if linkurl>
		<a href="<tmpl_var linkurl>" target="_blank">
	</tmpl_if>
	<span class="itemTitle"><tmpl_var title></span>
	<tmpl_if linkurl>
		</a>
	</tmpl_if>
</tmpl_if>

<tmpl_if attachment.name>
	<tmpl_if displaytitle> - </tmpl_if>
	<a href="<tmpl_var attachment.url>" target="_blank"><img src="<tmpl_var attachment.Icon>" border="0" alt="<tmpl_var attachment.name>" width="16" height="16" border="0" align="middle" /></a>
</tmpl_if>

<tmpl_if description>
  - <tmpl_var description>
</tmpl_if>
END

$fixedTemplates{PBtmpl0000000000000130} = << 'END';
<tmpl_if displayTitle>
	<h1><tmpl_var title></h1>
</tmpl_if>

<tmpl_if description>
	<p><tmpl_var description></p>
</tmpl_if>

^StyleSheet("<tmpl_var session.config.extrasURL>/Navigation/dtree/dtree.css");
^JavaScript("<tmpl_var session.config.extrasURL>/Navigation/dtree/dtree.js");

<tmpl_if session.var.adminOn>
	<tmpl_var controls>
</tmpl_if>

<div class="dtree">
<script type="text/javascript">
<!--
	// Path to dtree directory
	_dtree_url = "<tmpl_var session.config.extrasURL>/Navigation/dtree/";

	d = new dTree('d');
	<tmpl_loop page_loop>
	d.add(
		'<tmpl_var page.assetId escape=JS>',
		<tmpl_if __first__>-99<tmpl_else>'<tmpl_var page.parentId escape=JS>'</tmpl_if>,
		'<tmpl_var page.menuTitle escape=JS>',
		'<tmpl_var page.url escape=JS>',
		'<tmpl_var page.synopsis escape=JS>'
		<tmpl_if page.newWindow>,'_blank'</tmpl_if>
	);
	</tmpl_loop>
	document.write(d);
//-->
</script>
</div>
END

$fixedTemplates{PBtmpl0000000000000131} = << 'END';
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>

<tmpl_if showAdmin>
<p><tmpl_var controls></p>
</tmpl_if>

^RawHeadTags(<style type="text/css">
.firstColumn {
  float: left;
  width: 65%;
}
.secondColumn {
        float: left;
        width: auto;
        max-width: 33%;
}
.endFloat {
 clear: both;
}
</style>);

<tmpl_if displayTitle>
  <h1><tmpl_var title></h1>
</tmpl_if>

<tmpl_if description>
  <p><tmpl_var description></p>
</tmpl_if>

<!-- begin position 1 -->
<div class="firstColumn"><div class="layoutColumnPadding">
<tmpl_if showAdmin>
	<table border="0" id="position1" class="content"><tbody>
</tmpl_if>

<tmpl_loop position1_loop>
	<tmpl_if showAdmin>
            	<tr id="td<tmpl_var id>">
            		<td><div id="td<tmpl_var id>_div" class="dragable">
	</tmpl_if>

	<div class="content"><tmpl_var dragger.icon><tmpl_var content></div>

	<tmpl_if showAdmin>
         			</div></td>
            	</tr>
	</tmpl_if>
</tmpl_loop>

<tmpl_if showAdmin>
            </tbody></table>
</tmpl_if>
</div></div>
<!-- end position 1 -->

<!-- begin position 2 -->
<div class="secondColumn"><div class="layoutColumnPadding">
<tmpl_if showAdmin>
	<table border="0" id="position2" class="content"><tbody>
</tmpl_if>

<tmpl_loop position2_loop>
	<tmpl_if showAdmin>
            	<tr id="td<tmpl_var id>">
            		<td><div id="td<tmpl_var id>_div" class="dragable">
	</tmpl_if>

	<div class="content"><tmpl_var dragger.icon><tmpl_var content></div>

	<tmpl_if showAdmin>
         			</div></td>
            	</tr>
	</tmpl_if>
</tmpl_loop>

<tmpl_if showAdmin>
            </tbody></table>
</tmpl_if>
</div></div>
<!-- end position 2 -->

<div class="endFloat">&nbsp;</div>

<tmpl_if showAdmin>
	<table><tr id="blank" class="hidden"><td><div><div class="empty">&nbsp;</div></div></td></tr></table>
            <tmpl_var dragger.init>
</tmpl_if>

END

$fixedTemplates{PBtmpl0000000000000133} = << 'END';
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>

<tmpl_if session.var.adminOn>
	<tmpl_var controls>
</tmpl_if>

<tmpl_if displayTitle>
	<h1><tmpl_var title></h1>
</tmpl_if>

<tmpl_if description>
	<tmpl_var description>
</tmpl_if>

<p>
	<tmpl_if user.canPost>
		<a href="<tmpl_var add.url>">[<tmpl_var add.label>]</a>
	</tmpl_if>
	<tmpl_unless user.isVisitor>
		<tmpl_if user.isSubscribed>
			<a href="<tmpl_var unsubscribe.url>">[<tmpl_var unsubscribe.label>]</a>
		<tmpl_else>
			<a href="<tmpl_var subscribe.url>">[<tmpl_var subscribe.label>]</a>
		</tmpl_if>
	</tmpl_unless>
	<tmpl_if pagination.pageCount.isMultiple>
		<a href="<tmpl_var search.url>">[<tmpl_var search.label>]</a>
	</tmpl_if>
</p>

<tmpl_loop post_loop>

<div><b>On <tmpl_var dateSubmitted.human> <a href="<tmpl_var userProfile.url>"><tmpl_var username></a> from <a href="<tmpl_var url>">the '<tmpl_var title>' department</a> wrote</b></div>
<div><i><tmpl_var synopsis></i></div>
<div><a href="<tmpl_var url>"><tmpl_var readmore.label></a></div>
<p />

</tmpl_loop>

<tmpl_if pagination.pageCount.isMultiple>
	<div class="pagination">
		<tmpl_var pagination.previousPage> &middot; <tmpl_var pagination.pageList.upTo10> &middot; <tmpl_var pagination.nextPage>
	</div>
</tmpl_if>
END

$fixedTemplates{PBtmpl0000000000000134} = << 'END';
<tmpl_if displayTitle>
	<h1><tmpl_var title></h1>
</tmpl_if>

<tmpl_if description>
	<p><tmpl_var description></p>
</tmpl_if>

<tmpl_if session.var.adminOn>
	<tmpl_var controls>
</tmpl_if>

<style type="text/css">
/* CoolMenus 4 - default styles - do not edit */
.cCMAbs {
	position: absolute;
	visibility: hidden;
	left: 0;
	top: 0;
}
/* CoolMenus 4 - default styles - end */

/*Styles for level 0*/
.cLevel0,.cLevel0over {
	position: absolute;
	padding: 2px;
	font-family: tahoma, arial, helvetica;
	font-size: 12px;
	font-weight: bold;
}

.cLevel0 {
	background-color: navy;
	layer-background-color: navy;
	color: white;
	text-align: center;
}

.cLevel0over {
	background-color: navy;
	layer-background-color: navy;
	color: white;
	cursor: pointer;
	cursor: hand;
	text-align: center;
}

.cLevel0border {
	position: absolute;
	visibility: hidden;
	background-color: #569635;
	layer-background-color: #006699;
}

/*Styles for level 1*/
.cLevel1, .cLevel1over {
	position: absolute;
	padding: 2px;
	font-family: tahoma, arial, helvetica;
	font-size: 11px;
	font-weight:bold;
}

.cLevel1 {
	background-color: navy;
	layer-background-color: navy;
	color: white;
}

.cLevel1over {
	background-color: #336699;
	layer-background-color: #336699;
	color: yellow;
	cursor: pointer;
	cursor: hand;
}

.cLevel1border {
	position: absolute;
	visibility: hidden;
	background-color: #006699;
	layer-background-color: #006699;
}

/*Styles for level 2*/
.cLevel2, .cLevel2over {
	position: absolute;
	padding: 2px;
	font-family: tahoma, arial, helvetica;
	font-size: 10px;
	font-weight: bold;
}

.cLevel2 {
	background-color: navy;
	layer-background-color: navy;
	color:white;
}

.cLevel2over {
	background-color: #0099cc;
	layer-background-color: #0099cc;
	color: yellow;
	cursor:pointer;
	cursor:hand;
}

.cLevel2border {
	position: absolute;
	visibility: hidden;
	background-color: #006699;
	layer-background-color: #006699;
}

</style>

^JavaScript("<tmpl_var session.config.extrasURL>/coolmenus/coolmenus4.js");
<script type="text/javascript">
/*****************************************************************************
Copyright (c) 2001 Thomas Brattli (webmaster@dhtmlcentral.com)

DHTML coolMenus - Get it at coolmenus.dhtmlcentral.com
Version 4.0_beta
This script can be used freely as long as all copyright messages are
intact.

Extra info - Coolmenus reference/help - Extra links to help files ****
CSS help: http://coolmenus.dhtmlcentral.com/projects/coolmenus/reference.asp?m=37
General: http://coolmenus.dhtmlcentral.com/reference.asp?m=35
Menu properties: http://coolmenus.dhtmlcentral.com/properties.asp?m=47
Level properties: http://coolmenus.dhtmlcentral.com/properties.asp?m=48

Background bar properties: http://coolmenus.dhtmlcentral.com/properties.asp?m=49
Item properties: http://coolmenus.dhtmlcentral.com/properties.asp?m=50
******************************************************************************/

/***
This is the menu creation code - place it right after you body tag
Feel free to add this to a stand-alone js file and link it to your page.
**/

//Menu object creation
coolmenu=new makeCM("coolmenu") //Making the menu object. Argument: menuname

coolmenu.frames = 0

//Menu properties
coolmenu.onlineRoot=""
coolmenu.pxBetween=2
coolmenu.fromLeft=200
coolmenu.fromTop=100
coolmenu.rows=1
coolmenu.menuPlacement="center"   //The whole menu alignment, left, center, or right

coolmenu.resizeCheck=1
coolmenu.wait=1000
coolmenu.fillImg="cm_fill.gif"
coolmenu.zIndex=100

//Background bar properties
coolmenu.useBar=0
coolmenu.barWidth="100%"
coolmenu.barHeight="menu"
coolmenu.barClass="cBar"
coolmenu.barX=0
coolmenu.barY=0
coolmenu.barBorderX=0
coolmenu.barBorderY=0
coolmenu.barBorderClass=""

//Level properties - ALL properties have to be spesified in level 0
coolmenu.level[0]=new cm_makeLevel() //Add this for each new level
coolmenu.level[0].width=110
coolmenu.level[0].height=21
coolmenu.level[0].regClass="cLevel0"
coolmenu.level[0].overClass="cLevel0over"
coolmenu.level[0].borderX=1
coolmenu.level[0].borderY=1
coolmenu.level[0].borderClass="cLevel0border"

coolmenu.level[0].offsetX=0
coolmenu.level[0].offsetY=0
coolmenu.level[0].rows=0
coolmenu.level[0].arrow=0
coolmenu.level[0].arrowWidth=0
coolmenu.level[0].arrowHeight=0
coolmenu.level[0].align="bottom"

//EXAMPLE SUB LEVEL[1] PROPERTIES - You have to specify the properties you want different from LEVEL[0] - If you want all items to look the same just remove this
coolmenu.level[1]=new cm_makeLevel() //Add this for each new level (adding one to the number)
coolmenu.level[1].width=coolmenu.level[0].width+20
coolmenu.level[1].height=25
coolmenu.level[1].regClass="cLevel1"
coolmenu.level[1].overClass="cLevel1over"
coolmenu.level[1].borderX=1
coolmenu.level[1].borderY=1
coolmenu.level[1].align="right"
coolmenu.level[1].offsetX=0
coolmenu.level[1].offsetY=0
coolmenu.level[1].borderClass="cLevel1border"

//EXAMPLE SUB LEVEL[2] PROPERTIES - You have to specify the properties you want different from LEVEL[1] OR LEVEL[0] - If you want all items to look the same just remove this
coolmenu.level[2]=new cm_makeLevel() //Add this for each new level (adding one to the number)
coolmenu.level[2].width=coolmenu.level[0].width+20
coolmenu.level[2].height=25
coolmenu.level[2].offsetX=0
coolmenu.level[2].offsetY=0
coolmenu.level[2].regClass="cLevel2"
coolmenu.level[2].overClass="cLevel2over"
coolmenu.level[2].borderClass="cLevel2border"

//EXAMPLE SUB LEVEL[2] PROPERTIES - You have to specify the properties you want different from LEVEL[1] OR LEVEL[0] - If you want all items to look the same just remove this
coolmenu.level[3]=new cm_makeLevel() //Add this for each new level (adding one to the number)
coolmenu.level[3].width=coolmenu.level[0].width+20
coolmenu.level[3].height=25
coolmenu.level[3].offsetX=0
coolmenu.level[3].offsetY=0
coolmenu.level[3].regClass="cLevel2"
coolmenu.level[3].overClass="cLevel2over"
coolmenu.level[3].borderClass="cLevel2border"

<tmpl_loop page_loop>
coolmenu.makeMenu('coolmenu_<tmpl_var page.assetId escape=JS>'.replace(/\-/g,"a"),'coolmenu_<tmpl_var page.parent.assetId escape=JS>'.replace(/\-/g,"a"),"<tmpl_var page.menuTitle escape=JS>",'<tmpl_var page.url escape=JS>'<tmpl_if page.newWindow>,'_blank'</tmpl_if>);
</tmpl_loop>

coolmenu.construct();

</script>
END

$fixedTemplates{PBtmpl0000000000000135} = << 'END';
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>

<tmpl_if showAdmin>
	<p><tmpl_var controls></p>
</tmpl_if>

^RawHeadTags(<style type="text/css">
.firstColumn {
	float: left;
	width: 50%;
}

.secondColumn {
	float: left;
	width: auto;
	max-width: 50%;
}

.endFloat {
	clear: both;
}
</style>);

<tmpl_if displayTitle>
	<h1><tmpl_var title></h1>
</tmpl_if>

<tmpl_if description>
	<p><tmpl_var description></p>
</tmpl_if>

<!-- begin position 1 -->
<div class="firstColumn"><div class="layoutColumnPadding">
<tmpl_if showAdmin>
	<table border="0" id="position1" class="content"><tbody>
</tmpl_if>

<tmpl_loop position1_loop>
	<tmpl_if showAdmin>
		<tr id="td<tmpl_var id>">
		<td><div id="td<tmpl_var id>_div" class="dragable">
	</tmpl_if>

	<div class="content"><tmpl_var dragger.icon><tmpl_var content></div>

	<tmpl_if showAdmin>
		</div></td>
		</tr>
	</tmpl_if>
</tmpl_loop>

<tmpl_if showAdmin>
	</tbody></table>
</tmpl_if>
</div></div>
<!-- end position 1 -->

<!-- begin position 2 -->
<div class="secondColumn"><div class="layoutColumnPadding">
<tmpl_if showAdmin>
	<table border="0" id="position2" class="content"><tbody>
</tmpl_if>

<tmpl_loop position2_loop>
	<tmpl_if showAdmin>
		<tr id="td<tmpl_var id>">
		<td><div id="td<tmpl_var id>_div" class="dragable">
	</tmpl_if>

	<div class="content"><tmpl_var dragger.icon><tmpl_var content></div>

	<tmpl_if showAdmin>
		</div></td>
		</tr>
	</tmpl_if>
</tmpl_loop>

<tmpl_if showAdmin>
	</tbody></table>
</tmpl_if>
</div></div>
<!-- end position 2 -->

<div class="endFloat">&nbsp;</div>

<tmpl_if showAdmin>
	<table><tr id="blank" class="hidden"><td><div><div class="empty">&nbsp;</div></div></td></tr></table>
	<tmpl_var dragger.init>
</tmpl_if>
END

$fixedTemplates{PBtmpl0000000000000140} = << 'END';
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>

<tmpl_if session.var.adminOn>
	<p><tmpl_var controls></p>
	<div style="width: 100%; border: 1px groove black;">
		<div style="width: 100%; background-image: url(<tmpl_var session.config.extrasURL>/opaque.gif);">
			<div style="text-align: center; font-weight: bold;"><a href="<tmpl_var originalURL>"><tmpl_var shortcut.label></a></div>
		</div>
</tmpl_if>
<tmpl_var shortcut.content>
<tmpl_if session.var.adminOn>
		<div style="width: 100%; background-image: url(<tmpl_var session.config.extrasURL>/opaque.gif);">
			<div style="text-align: center; font-weight: bold;"><a href="<tmpl_var originalURL>"><tmpl_var shortcut.label></a></div>
		</div>
	</div>
</tmpl_if>
END

$fixedTemplates{PBtmpl0000000000000141} = << 'END';
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>

<tmpl_if session.var.adminOn>
	<p><tmpl_var controls></p>
</tmpl_if>

<tmpl_if displayTitle>
	<h1><tmpl_var title></h1>
</tmpl_if>

<tmpl_if error_loop>
	<ul>
		<tmpl_loop error_loop>
			<li><b><tmpl_var error.message></b></li>
		</tmpl_loop>
	</ul>
</tmpl_if>

<tmpl_if description>
	<tmpl_var description>
	<p />
</tmpl_if>

<tmpl_if canEdit>
	<a href="<tmpl_var entryList.url>"><tmpl_var entryList.label></a>
	&middot; <a href="<tmpl_var export.tab.url>"><tmpl_var export.tab.label></a>
	<tmpl_if entryId>
		&middot; <a href="<tmpl_var delete.url>"><tmpl_var delete.label></a>
	</tmpl_if>
	<tmpl_if session.var.adminOn>
		&middot; <a href="<tmpl_var addField.url>"><tmpl_var addField.label></a>
		&middot; <a href="<tmpl_var addTab.url>"><tmpl_var addTab.label></a>
	</tmpl_if>
	<p />
</tmpl_if>
<tmpl_var form.start>
<table>
        <tmpl_loop field_loop>
                <tmpl_unless field.isHidden>
                        <tr>
                                <td class="formDescription" valign="top">
                                        <tmpl_if session.var.adminOn>
                                                <tmpl_if canEdit>
                                                        <tmpl_var field.controls>
                                                </tmpl_if>
                                        </tmpl_if>
                                        <tmpl_var field.label>
                                </td>
                                <td class="tableData" valign="top">
                                        <tmpl_if field.isDisplayed>
                                                <tmpl_var field.value>
                                        <tmpl_else>
                                                <tmpl_var field.form>
                                        </tmpl_if>
                                        <tmpl_if field.isRequired>*</tmpl_if>
                                        <span class="formSubtext">
                                                <br />
                                                <tmpl_var field.subtext>
                                        </span>
                                </td>
                        </tr>
                </tmpl_unless>
        </tmpl_loop>
</table>
<br />
<tmpl_var form.save>
<tmpl_var form.end>
END

$fixedTemplates{wCIc38CvNHUK7aY92Ww4SQ} = << 'END';
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>

<tmpl_if session.var.adminOn>
	<p><tmpl_var controls></p>
</tmpl_if>

<tmpl_if displayTitle>
	<h1><tmpl_var title></h1>
</tmpl_if>

<tmpl_if description>
	<tmpl_var description>
	<p />
</tmpl_if>

<tmpl_if user.canPost>
	<a href="<tmpl_var add.url>"> <tmpl_var addlink.label></a><p />
</tmpl_if>

<tmpl_loop post_loop>
	<tmpl_if user.isPoster>
		<tmpl_unless session.var.adminOn>[<a href="<tmpl_var edit.url>"><tmpl_var edit.label></a>]</tmpl_unless>
	</tmpl_if>
	<tmpl_if user.isModerator>
		<tmpl_if session.var.adminOn>
			<tmpl_var controls>
		<tmpl_else>
			<tmpl_unless user.isPoster>
				<tmpl_unless session.var.adminOn>[<a href="<tmpl_var edit.url>"><tmpl_var edit.label></a>]</tmpl_unless>
			</tmpl_unless>
		</tmpl_if>
		<br />
	</tmpl_if>

	<a href="<tmpl_var userDefined1>"<tmpl_if userDefined2>target="_blank"</tmpl_if>><span class="linkTitle"><tmpl_var title></span></a>

	<tmpl_if content>
		<br />
		<tmpl_var content>
	</tmpl_if>

	<p />
</tmpl_loop>
END
}
