package WebGUI;
our $VERSION = "1.0.0";

#-------------------------------------------------------------------
# WebGUI is Copyright 2001 Plain Black Software.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict qw(vars subs);
use Tie::IxHash;
use WebGUI::Operation;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Style;

#-------------------------------------------------------------------
sub _displayAdminBar {
	my ($widgetName, $key, %hash2, $miscSelect, $adminSelect, $clipboardSelect, $widget, @widgetArray, %hash, $output, $contentSelect);
	tie %hash, "Tie::IxHash";
	tie %hash2, "Tie::IxHash";
  #--content adder
	@widgetArray = @_;
	$hash2{$session{page}{url}} = "Add content...";
	$hash2{$session{page}{url}.'?op=addPage'} = 'Page';
	foreach $widget (@widgetArray) {
		$widgetName = "WebGUI::Widget::".$widget."::widgetName";
		$hash2{$session{page}{url}.'?func=add&widget='.$widget} = &$widgetName;
	}
	$contentSelect = WebGUI::Form::selectList("contentSelect",\%hash2,"","","","goContent()");
  #--clipboard paster
	%hash2 = ( $session{page}{url}=> "Paste from clipboard..." );
	%hash = WebGUI::SQL->buildHash("select pageId,title from page where parentId=2 order by title",$session{dbh});
	foreach $key (keys %hash) {
		$hash2{$session{page}{url}.'?op=pastePage&pageId='.$key} = $hash{$key};
	}
        %hash = WebGUI::SQL->buildHash("select widgetId,title from widget where pageId=2 order by title",$session{dbh});
        foreach $key (keys %hash) {
                $hash2{$session{page}{url}.'?func=paste&wid='.$key} = $hash{$key};
        }
        $clipboardSelect = WebGUI::Form::selectList("clipboardSelect",\%hash2,"","","","goClipboard()");
   #--admin functions
	%hash = ();
	if (WebGUI::Privilege::isInGroup(3,$session{user}{userId})) {
        	%hash = ( 
			$session{page}{url}.'?op=editSettings'=>'Edit Settings', 
			$session{page}{url}.'?op=listGroups'=>'Manage Groups', 
			$session{page}{url}.'?op=listStyles'=>'Manage Styles', 
			$session{page}{url}.'?op=listUsers'=>'Manage Users',
			$session{env}{SCRIPT_NAME}.'/clipboard'=>'View Clipboard',
			$session{env}{SCRIPT_NAME}.'/trash'=>'View Trash',
			$session{page}{url}.'?op=purgeTrash'=>'Empty Trash'
		);
	}
        %hash = ( $session{page}{url}=>'Admin...', 
		$session{page}{url}.'?op=switchOffAdmin'=>'Turn Admin Off',
		$session{page}{url}.'?op=viewHelpIndex'=>'View Help Index',
		$session{page}{url}.'?op=viewPendingSubmissions'=>'View Pending Submissions', 
		%hash
	);
        $adminSelect = WebGUI::Form::selectList("adminSelect",\%hash,"","","","goAdmin()");
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
sub _loadWidgets {
	my (@files, $file, $use, @widget, $i);
	opendir (DIR,"../lib/WebGUI/Widget") or die "Can't get widget directory!\n";
	@files = readdir(DIR);
	foreach $file (@files) {
        	unless ($file eq "." || $file eq "..") {
        		$file =~ s/\.pm//;
			$widget[$i] = $file;
                        $use = "use WebGUI::Widget::".$widget[$i];
                        eval($use);
			$i++;
		}
	}
	closedir(DIR);
	return @widget;
}

#-------------------------------------------------------------------
sub page {
	my ($preContent, $postContent, $widgetType, $function, $functionOutput, $widget, @availableWidgets, @widgetList, $sth, $httpHeader, $header, $footer, $content, $operationOutput, $operation, $adminBar);
	WebGUI::Session::open();
	$preContent = '<table cellpadding="0" cellspacing="0" border="0" width="100%"><tr><td valign="top" class="content">';
	$postContent = '</td></tr></table>';
	@availableWidgets = _loadWidgets();
	if (exists $session{form}{op}) {
		$operation = "WebGUI::Operation::www_".$session{form}{op};
		$operationOutput = &$operation();
	}
	if (exists $session{form}{func}) {
		if (exists $session{form}{widget}) {
			$widgetType = $session{form}{widget};
		} else {
			($widgetType) = WebGUI::SQL->quickArray("select widgetType from widget where widgetId='$session{form}{wid}'",$session{dbh});
		}
       		$function = "WebGUI::Widget::".$widgetType."::www_".$session{form}{func};
               	$functionOutput = &$function();
	}
	if ($operationOutput ne "") {
		$content = $operationOutput;
	} elsif ($functionOutput ne "") {
		$content = $functionOutput;
	} else {
		#if (WebGUI::Privilege::canViewPage($session{page}{pageId})) {
		if (WebGUI::Privilege::canViewPage()) {
			if ($session{var}{adminOn}) {
                        	$content .= '<a href="'.$session{page}{url}.'?op=editPage"><img src="'.$session{setting}{lib}.'/edit.gif" border=0></a><a href="'.$session{page}{url}.'?op=cutPage"><img src="'.$session{setting}{lib}.'/cut.gif" border=0></a><a href="'.$session{page}{url}.'?op=deletePage"><img src="'.$session{setting}{lib}.'/delete.gif" border=0></a><a href="'.$session{page}{url}.'?op=movePageUp"><img src="'.$session{setting}{lib}.'/leftArrow.gif" border=0></a><a href="'.$session{page}{url}.'?op=movePageDown"><img src="'.$session{setting}{lib}.'/rightArrow.gif" border=0></a>';
                	}	
			$sth = WebGUI::SQL->read("select widgetId, widgetType from widget where pageId=".$session{page}{pageId}." order by sequenceNumber, widgetId",$session{dbh});
			while (@widgetList = $sth->array) {
				if ($session{var}{adminOn}) {
                       			$content .= '<hr><a href="'.$session{page}{url}.'?func=edit&wid='.$widgetList[0].'"><img src="'.$session{setting}{lib}.'/edit.gif" border=0></a><a href="'.$session{page}{url}.'?func=cut&wid='.$widgetList[0].'"><img src="'.$session{setting}{lib}.'/cut.gif" border=0></a><a href="'.$session{page}{url}.'?wid='.$widgetList[0].'&func=delete"><img src="'.$session{setting}{lib}.'/delete.gif" border=0></a><a href="'.$session{page}{url}.'?func=moveUp&wid='.$widgetList[0].'"><img src="'.$session{setting}{lib}.'/upArrow.gif" border=0></a><a href="'.$session{page}{url}.'?func=moveDown&wid='.$widgetList[0].'"><img src="'.$session{setting}{lib}.'/downArrow.gif" border=0></a><a href="'.$session{page}{url}.'?func=jumpUp&wid='.$widgetList[0].'"><img src="'.$session{setting}{lib}.'/jumpUp.gif" border=0></a><a href="'.$session{page}{url}.'?func=jumpDown&wid='.$widgetList[0].'"><img src="'.$session{setting}{lib}.'/jumpDown.gif" border=0></a><br>';
				}
				$widget = "WebGUI::Widget::".$widgetList[1]."::www_view";
				$content .= &$widget($widgetList[0])."<p>";
			}
			$sth->finish;
		} else {
			$content = ' <h1>Permission Denied!</h1> You do not have sufficient privileges to access this page. ';
		}
	}
	if ($session{var}{adminOn}) {
		$adminBar = _displayAdminBar(@availableWidgets);
	}
	$httpHeader = WebGUI::Session::httpHeader();
	($header, $footer) = WebGUI::Style::getStyle();
	WebGUI::Session::close();
	return $httpHeader.$adminBar.$header.$preContent.$content.$postContent.$footer;
}




1;
