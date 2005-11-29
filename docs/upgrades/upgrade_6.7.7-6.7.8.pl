use lib "../../lib";
use strict;
use Getopt::Long;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Asset;
use WebGUI::Setting;

my $toVersion = "6.7.8";
my $configFile;
my $quiet;

start();
protectUserProfileFields();
correctEditProfileTemplate();
fixCalendarTemplates();
finish();

#-------------------------------------------------
sub fixCalendarTemplates {
        print "\tFixing bugs in calendar templates.\n" unless ($quiet);
my $template = <<STOP;
<h1><tmpl_var title></h1>

<table width="100%" cellspacing="0" cellpadding="5" border="0">
<tr>
<td valign="top" class="tableHeader" width="100%">
<b><tmpl_var start.label>:</b> <tmpl_var start.date><br />
<b><tmpl_var end.label>:</b> <tmpl_var end.date><br />
</td><td valign="top" class="tableMenu" nowrap="1">

<tmpl_if canEdit>
     <a href="<tmpl_var edit.url>"><tmpl_var edit.label></a><br />
     <a href="<tmpl_var delete.url>"><tmpl_var delete.label></a><br />
</tmpl_if>

<tmpl_if previous.url>
     <a href="<tmpl_var previous.url>"><tmpl_var previous.label></a><br />
</tmpl_if>

<tmpl_if next.url>
     <a href="<tmpl_var next.url>"><tmpl_var next.label></a><br />
</tmpl_if>

</td></tr>
</table>
<tmpl_var description>

<tmpl_loop others_loop>
<tmpl_if __FIRST__>
<p /><b>Events Near This One</b><br />
</tmpl_if>
<ul>
<li><a href="<tmpl_var url>"><tmpl_var title></a></li>
</ul>
</tmpl_loop>
STOP
	my $asset = WebGUI::Asset->new("PBtmpl0000000000000023","WebGUI::Asset::Template");
	$asset->addRevision({template=>$template})->commit if (defined $asset);
	$template = <<STOP;
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
	<table border="1">
	<tr><td colspan=7 class="tableHeader"><tmpl_var month> <tmpl_var year></td></tr>
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
				<tmpl_if hasEvents>
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
STOP
	$asset = WebGUI::Asset->new("PBtmpl0000000000000105","WebGUI::Asset::Template");
	$asset->addRevision({template=>$template})->commit if (defined $asset);
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
sub protectUserProfileFields {
        print "\tProtecting all default user fields.\n" unless ($quiet);
	WebGUI::SQL->write("update userProfileField set protected=1 where fieldName in ('discussionLayout','INBOXNotifications','alias','signature','publicProfile','publicEmail','toolbar')");
}

#-------------------------------------------------
sub correctEditProfileTemplate {
        print "\tFixing Edit Profile template.\n" unless ($quiet);
	my $tmplAsset = WebGUI::Asset->newByDynamicClass("PBtmpl0000000000000051");
	my $template = $tmplAsset->get('template');
	$template =~ s/create.form.footer/profile.form.footer/;
	$tmplAsset->addRevision({ template=>$template });
	$tmplAsset->commit;
}

#-------------------------------------------------
sub finish {
	WebGUI::Session::close();
}

