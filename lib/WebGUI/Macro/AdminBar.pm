package WebGUI::Macro::AdminBar;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use Tie::IxHash;
use WebGUI::Form;
use WebGUI::International;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::Utility;

#-------------------------------------------------------------------
sub _replacement {
	my (%hash2, $miscSelect, $adminSelect, $clipboardSelect, %hash, $output, $contentSelect, $key);
	tie %hash, "Tie::IxHash";
	tie %hash2, "Tie::IxHash";
  #--content adder
	$hash{WebGUI::URL::page()} = WebGUI::International::get(1);
	$hash{WebGUI::URL::page('op=editPage&npp='.$session{page}{pageId})} = WebGUI::International::get(2);
	if ($session{user}{uiLevel} >= 7) {
		$hash{WebGUI::URL::page('op=selectPackageToDeploy')} = WebGUI::International::get(376);
	}
	foreach $key (keys %{$session{wobject}}) {
		$hash2{WebGUI::URL::page('func=edit&wid=new&namespace='.$key)} = $session{wobject}{$key};
	}
	%hash2 = sortHash(%hash2);
	%hash = (%hash, %hash2);
        $contentSelect = WebGUI::Form::selectList({
		name=>"contentSelect",
		options=>\%hash,
		extras=>'onChange="goContent()"'
		});
  #--clipboard paster
	%hash2 = ();
	$hash2{WebGUI::URL::page()} = WebGUI::International::get(3);
	%hash = WebGUI::SQL->buildHash("select pageId,title from page where parentId=2 order by title");
	foreach $key (keys %hash) {
		$hash2{WebGUI::URL::page('op=pastePage&pageId='.$key)} = $hash{$key};
	}
        %hash = WebGUI::SQL->buildHash("select wobjectId,title from wobject where pageId=2 order by title");
        foreach $key (keys %hash) {
                $hash2{WebGUI::URL::page('func=paste&wid='.$key)} = $hash{$key};
        }
        $clipboardSelect = WebGUI::Form::selectList({
		name=>"clipboardSelect",
		options=>\%hash2,
		extras=>'onChange="goClipboard()"'
		});
   #--admin functions
	%hash = ();
	if (WebGUI::Privilege::isInGroup(3,$session{user}{userId})) {
        	%hash = ( 
			WebGUI::URL::page('op=listGroups')=>WebGUI::International::get(5), 
			WebGUI::URL::page('op=manageSettings')=>WebGUI::International::get(4), 
			WebGUI::URL::page('op=listLanguages')=>WebGUI::International::get(585),
			WebGUI::URL::page('op=listUsers')=>WebGUI::International::get(7),
			WebGUI::URL::gateway('trash')=>WebGUI::International::get(10),
			WebGUI::URL::page('op=listRoots')=>WebGUI::International::get(410),
			WebGUI::URL::page('op=viewStatistics')=>WebGUI::International::get(144)
		);
	}
	if (WebGUI::Privilege::isInGroup(4,$session{user}{userId})) {
        	%hash = ( 
			'http://validator.w3.org/check?uri=http%3A%2F%2F'.$session{env}{SERVER_NAME}.
				WebGUI::URL::page()=>WebGUI::International::get(399),
			WebGUI::URL::page('op=viewPageTree')=>WebGUI::International::get(447),
			%hash
		);
	}
        if (WebGUI::Privilege::isInGroup($session{setting}{styleManagersGroup},$session{user}{userId})) {
                %hash = (
			WebGUI::URL::page('op=listStyles')=>WebGUI::International::get(6), 
			%hash
                );
        }
        if (WebGUI::Privilege::isInGroup(6,$session{user}{userId})) {
                %hash = (
			WebGUI::URL::gateway('packages')=>WebGUI::International::get(374),
                        %hash
                );
        }
        if (WebGUI::Privilege::isInGroup($session{setting}{templateManagersGroup},$session{user}{userId})) {
                %hash = (
                        WebGUI::URL::page('op=listTemplates')=>WebGUI::International::get(508),
                        %hash
                );
        }
        if (WebGUI::Privilege::isInGroup($session{setting}{imageManagersGroup},$session{user}{userId})) {
                %hash = (
                        WebGUI::URL::page('op=listImages')=>WebGUI::International::get(394),
                        %hash
                );
        }
        %hash = (  
		WebGUI::URL::page('op=viewHelpIndex')=>WebGUI::International::get(13),
		%hash
	);
	%hash = sortHash(%hash);
        %hash = ( 
		WebGUI::URL::page()=>WebGUI::International::get(82), 
		WebGUI::URL::page('op=switchOffAdmin')=>WebGUI::International::get(12),
		%hash
	);
	$adminSelect = WebGUI::Form::selectList({
		name=>"adminSelect",
		options=>\%hash,
		extras=>'onChange="goAdmin()"'
		});
  #--output admin bar
	$output = '
	<div class="adminBar"><table class="adminBar" width="100%" cellpadding="3" cellspacing="0" border="0"><tr>
	<script language="JavaScript" type="text/javascript">	<!--
	function goContent(){
		location = document.content.contentSelect.options[document.content.contentSelect.selectedIndex].value
	}
        function goAdmin(){
                location = document.admin.adminSelect.options[document.admin.adminSelect.selectedIndex].value
        }
        function goClipboard(){
                location = document.clipboard.clipboardSelect.options[document.clipboard.clipboardSelect.selectedIndex].value
        }
	//-->	</script>
	<form name="content"> <td>'.$contentSelect.'</td> </form>
	<form name="clipboard"> <td align="center">'.$clipboardSelect.'</td> </form>
        <form name="admin"> <td align="center">'.$adminSelect.'</td> </form> 
	</tr></table></div>
	';
	return $output;
}

#-------------------------------------------------------------------
sub process {
        my ($output,$temp);
        $output = $_[0];
	if ($session{var}{adminOn}) {
        	$output =~ s/\^AdminBar\;/_replacement()/ge;
	} else {
		$output =~ s/\^AdminBar\;//g;
	}
        return $output;
}



1;

