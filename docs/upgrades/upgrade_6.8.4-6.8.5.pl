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
use WebGUI::Session;
use WebGUI::SQL;


my $toVersion = "6.8.5"; # make this match what version you're going to
my $quiet; # this line required


start(); # this line required

# upgrade functions go here

modifyDataFormSecurity();
fixFolderTemplate();
finish(); # this line required

#-------------------------------------------------
sub modifyDataFormSecurity {
	print "\tAdding Who Can View Form Entries property to DataForm Wobject.\n" unless ($quiet);
	my $sql = "alter table DataForm add column (groupToViewEntries varchar(22) not null default '7')";
	WebGUI::SQL->write($sql);
}

#-------------------------------------------------
sub fixFolderTemplate {
	print "\tFixing the folder template.\n" unless ($quiet);
	
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
 <a href="<tmpl_var url>"><img src="<tmpl_var icon.small>" border="0" alt="<tmpl_var title>" /></a>
 <a href="<tmpl_var url>"><tmpl_var title></a>
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
 <a href="<tmpl_var file.url>"><img src="<tmpl_var icon.small>" border="0" alt="<tmpl_var title>" /></a>
 <a href="<tmpl_var file.url>"><tmpl_var title> </td> <td class="tableData" valign="top">
 <tmpl_var synopsis></td><td class="tableData" valign="top">^D("%z %Z",<tmpl_var date.epoch>);</td>
 <td class="tableData" valign="top"><tmpl_var size></td></tr>
</tmpl_loop>
</table>
END
	my $asset = WebGUI::Asset->new("PBtmpl0000000000000078","WebGUI::Asset::Template");
	$asset->addRevision({template=>$folderTemplate})->commit;

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

