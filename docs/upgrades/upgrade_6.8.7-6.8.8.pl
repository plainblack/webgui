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
use WebGUI::Asset;
use WebGUI::User;
use WebGUI::Session;
use WebGUI::SQL;


my $toVersion = "6.8.8"; # make this match what version you're going to
my $quiet; # this line required


start(); # this line required

# upgrade functions go here

setAdminFirstDayOfWeek();
upgradeMultiSearchTemplate();
fixFAQTemplateLinks();
fixFolderTemplateLinks();

finish(); # this line required


#-------------------------------------------------
sub setAdminFirstDayOfWeek {
	print "\tSet the first day of the week profile field for Admin.\n" unless ($quiet);
	my $admin = WebGUI::User->new('3');
	$admin->profileField('firstDayOfWeek',0);
}

#-------------------------------------------------
sub upgradeMultiSearchTemplate {
	print "\tInternationalizing the MultiSearch template.\n" unless ($quiet);
	
my $folderTemplate = <<END;
<a name="<tmpl_var assetId>"></a>

<tmpl_if session.var.adminOn>
   <p><tmpl_var controls></p>
</tmpl_if>

<tmpl_if displayTitle>
    <h1><tmpl_var title></h1>
</tmpl_if>

<tmpl_if description>
    <tmpl_var description><p />
</tmpl_if>
<script type="text/javascript">
function domultisearch() {
var sf=document.multisearchform;
var submitto = sf.sengines.options[sf.sengines.selectedIndex].value + escape(sf.searchterms.value);
window.open(submitto);
return false;
}
</script>
<div style="width:100%">
<form name="multisearchform" onSubmit="return domultisearch();">
<table border="1" cellpadding="10" cellspacing="0" bgcolor="#F2F2F2">
<tr>
<td align="center"><div style="position:float;width=40%;">
<tmpl_var search>:&nbsp;
<select name="sengines">
<option value="http://www.google.com/search?q=" selected>Google</option>
<option value="http://news.google.com/news?q=">Google News</option>
<option value="http://www.flickr.com/photos/tags/">Flickr Photos</option>
<option value="http://www.digg.com/search?submit=Submit&search=">Digg.com</option>
<option value="http://www.altavista.com/web/results?q=">Alta Vista</option>
<option value="http://search.yahoo.com/search?p=">Yahoo!</option>
</select></div><div style="position:float;width=40%;">
&nbsp;&nbsp;<tmpl_var for>:&nbsp;
<input type="text" name="searchterms">
<tmpl_var submit></div>
</td>
</tr>
</table>
</form>
</div>
END
	my $asset = WebGUI::Asset->new("MultiSearchTmpl0000001","WebGUI::Asset::Template");
	$asset->addRevision({template=>$folderTemplate})->commit;

}

#-------------------------------------------------
sub fixFAQTemplateLinks {
	print "\tFix top link inside CS FAQ template.\n" unless ($quiet);
	
my $folderTemplate = <<END;
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
	   <li><a href="#id<tmpl_var assetId>"><span class="faqQuestion"><tmpl_var title></span></a>
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
	<p><a href="#id<tmpl_var parentId>">[top]</a></p>
</tmpl_loop>

<tmpl_if pagination.pageCount.isMultiple>
	<div class="pagination">
		<tmpl_var pagination.previousPage>  &middot; <tmpl_var pagination.pageList.upTo10> &middot; <tmpl_var pagination.nextPage>
	</div>
</tmpl_if>
END
	my $asset = WebGUI::Asset->new("PBtmpl0000000000000080","WebGUI::Asset::Template");
	$asset->addRevision({template=>$folderTemplate})->commit;

}

#-------------------------------------------------
sub fixFolderTemplateLinks {
	print "\tFix Folder links and viewing rights for Folder children.\n" unless ($quiet);
	
my $folderTemplate = <<END;
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>

<tmpl_if session.var.adminOn> <p><tmpl_var controls></p> </tmpl_if>
	
<tmpl_if displayTitle> <h1><tmpl_var title></h1> </tmpl_if>
		
<tmpl_if description> <tmpl_var description> </tmpl_if>
			
<tmpl_if session.var.adminOn> <p><a href="<tmpl_var url>?func=add&class=WebGUI::Asset::FilePile">Add files.</a></p> </tmpl_if>
				
<table width="100%" cellpadding="3" cellspacing="0" class="content"> 
<tmpl_loop subfolder_loop> 

 <tr>
 <td class="tableData" valign="top">
<tmpl_if canView>
	<a href="<tmpl_var url>"><img src="<tmpl_var icon.small>" border="0" alt="<tmpl_var title>" /></a>
	<a href="<tmpl_var url>"><tmpl_var title></a>
<tmpl_else>
	<img src="<tmpl_var icon.small>" border="0" alt="<tmpl_var title>" /><tmpl_var title>
</tmpl_if>
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
<tmpl_if canView>
 <a href="<tmpl_if isFile><tmpl_var file.url><tmpl_else><tmpl_var url></tmpl_if>"><img src="<tmpl_var icon.small>" border="0" alt="<tmpl_var title>" /></a>
 <a href="<tmpl_if isFile><tmpl_var file.url><tmpl_else><tmpl_var url></tmpl_if>"><tmpl_var title></a>
<tmpl_else>
 <img src="<tmpl_var icon.small>" border="0" alt="<tmpl_var title>" /><tmpl_var title>
</tmpl_if>
</td> <td class="tableData" valign="top">
 <tmpl_var synopsis></td><td class="tableData" valign="top">^D("%z %Z",<tmpl_var date.epoch>);</td>
 <td class="tableData" valign="top"><tmpl_var size></td></tr>
</tmpl_loop>
</table>
END
	my $asset = WebGUI::Asset->new("PBtmpl0000000000000078","WebGUI::Asset::Template");
	$asset->addRevision({template=>$folderTemplate})->commit;

}



##-------------------------------------------------
#sub exampleFunction {
#	print "\tWe're doing some stuff here that you should know about.\n" unless ($quiet);
#	# and here's our code
#}



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

