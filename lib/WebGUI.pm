package WebGUI;
our $VERSION = "3.8.0";

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black Software.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict qw(vars subs);
use Tie::CPHash;
use Tie::IxHash;
use WebGUI::ErrorHandler;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Operation;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Style;
use WebGUI::Template;
use WebGUI::Template::Default;
use WebGUI::URL;
use WebGUI::Utility;

#-------------------------------------------------------------------
sub _displayAdminBar {
	my (%hash2, $miscSelect, $adminSelect, $clipboardSelect, 
		%hash, $output, $contentSelect, $key);
	tie %hash, "Tie::IxHash";
	tie %hash2, "Tie::IxHash";
  #--content adder
	$hash{WebGUI::URL::page()} = WebGUI::International::get(1);
	$hash{WebGUI::URL::page('op=editPage&npp='.$session{page}{pageId})} = WebGUI::International::get(2);
	$hash{WebGUI::URL::page('op=selectPackageToDeploy')} = WebGUI::International::get(376);
	foreach $key (keys %{$session{wobject}}) {
		$hash2{WebGUI::URL::page('func=edit&wid=new&namespace='.$key)} = $session{wobject}{$key};
	}
	%hash2 = sortHash(%hash2);
	%hash = (%hash, %hash2);
	$contentSelect = WebGUI::Form::selectList("contentSelect",\%hash,"","","","goContent()");
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
        $clipboardSelect = WebGUI::Form::selectList("clipboardSelect",\%hash2,"","","","goClipboard()");
   #--admin functions
	%hash = ();
	if (WebGUI::Privilege::isInGroup(3,$session{user}{userId})) {
        	%hash = ( 
			WebGUI::URL::page('op=listGroups')=>WebGUI::International::get(5), 
			WebGUI::URL::page('op=manageSettings')=>WebGUI::International::get(4), 
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
			WebGUI::URL::page('op=listImages')=>WebGUI::International::get(394),
			WebGUI::URL::page('op=viewPageTree')=>WebGUI::International::get(447),
			%hash
		);
	}
        if (WebGUI::Privilege::isInGroup(5,$session{user}{userId})) {
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
sub page {
	my ($debug, %contentHash, $w, $cmd, $pageEdit, $wobject, $wobjectOutput, $extra, 
		$sth, $httpHeader, $header, $footer, $content, $operationOutput, $adminBar, %hash);
	WebGUI::Session::open($_[0],$_[1]);
	# For some reason we have to pre-cache the templates when running under mod_perl
	# so that's what we're doing with this next command.
	WebGUI::Template::loadTemplates();
	if ($session{form}{debug}==1 && WebGUI::Privilege::isInGroup(3)) {
		$debug = '<table bgcolor="#ffffff" style="color: #000000; font-size: 10pt; font-family: helvetica;">';
		while (my ($section, $hash) = each %session) {
			while (my ($key, $value) = each %$hash) {
				if (ref $value eq 'ARRAY') {
					$value = '['.join(', ',@$value).']';
				} elsif (ref $value eq 'HASH') {
					$value = '{'.join(', ',map {"$_ => $value->{$_}"} keys %$value).'}';
				}
				$debug .= '<tr><td align="right"><b>'.$section.'.'.$key.':</b></td><td>'.$value.'</td>';
			}
			$debug .= '<tr height=10><td>&nbsp;</td><td>&nbsp</td></tr>';
		}
		$debug .='</table>';
	}
	if (exists $session{form}{op}) {
		$cmd = "WebGUI::Operation::www_".$session{form}{op};
		$operationOutput = &$cmd();
	}
	if (exists $session{form}{func} && exists $session{form}{wid}) {
		if ($session{form}{wid} eq "new") {
			$wobject = {wobjectId=>$session{form}{wid},namespace=>$session{form}{namespace},pageId=>$session{page}{pageId}};
		} else {
			$wobject = WebGUI::SQL->quickHashRef("select * from wobject where wobject.wobjectId=".$session{form}{wid});	
			$extra = WebGUI::SQL->quickHashRef("select * from ${$wobject}{namespace} where wobjectId=${$wobject}{wobjectId}");
                        tie %hash, 'Tie::CPHash';
                        %hash = (%{$wobject},%{$extra});
                        $wobject = \%hash;
		}
		if (${$wobject}{pageId} != $session{page}{pageId} && ${$wobject}{pageId} != 2) {
			$wobjectOutput = WebGUI::International::get(417);
			WebGUI::ErrorHandler::warn($session{user}{username}." [".$session{user}{userId}."] attempted to access wobject [".$session{form}{wid}."] on page '".$session{page}{title}."' [".$session{page}{pageId}."].");
		} else {
			$cmd = "WebGUI::Wobject::".${$wobject}{namespace};
			$w = $cmd->new($wobject);
			$cmd = "www_".$session{form}{func};
                       	$wobjectOutput = $w->$cmd;
		}
                # $wobjectOutput = WebGUI::International::get(381); # bad error
	}
	if ($operationOutput ne "") {
		$contentHash{A} = $operationOutput;
		$content = WebGUI::Template::Default::generate(\%contentHash);
	} elsif ($wobjectOutput ne "") {
		$contentHash{A} = $wobjectOutput;
		$content = WebGUI::Template::Default::generate(\%contentHash);
	} else {
		if (WebGUI::Privilege::canViewPage()) {
			if ($session{var}{adminOn}) {
                        	$pageEdit = "\n<br>"
					.pageIcon()
					.editIcon('op=editPage')
					.moveUpIcon('op=movePageUp')
					.moveDownIcon('op=movePageDown')
					.cutIcon('op=cutPage')
					.deleteIcon('op=deletePage')
					."\n";
                	}	
			$sth = WebGUI::SQL->read("select * from wobject where pageId=$session{page}{pageId} order by sequenceNumber, wobjectId");
			while ($wobject = $sth->hashRef) {
				if ($session{var}{adminOn}) {
                       			$contentHash{${$wobject}{templatePosition}} .= "\n<hr>"
						.editIcon('func=edit&wid='.${$wobject}{wobjectId})
						.moveUpIcon('func=moveUp&wid='.${$wobject}{wobjectId})
						.moveDownIcon('func=moveDown&wid='.${$wobject}{wobjectId})
						.moveTopIcon('func=moveTop&wid='.${$wobject}{wobjectId})
						.moveBottomIcon('func=moveBottom&wid='.${$wobject}{wobjectId})
						.copyIcon('func=copy&wid='.${$wobject}{wobjectId})
						.cutIcon('func=cut&wid='.${$wobject}{wobjectId})
						.deleteIcon('func=delete&wid='.${$wobject}{wobjectId})
						.'<br>';
				}
				$extra = WebGUI::SQL->quickHashRef("select * from ${$wobject}{namespace} where wobjectId=${$wobject}{wobjectId}");
				tie %hash, 'Tie::CPHash';
				%hash = (%{$wobject},%{$extra});
				$wobject = \%hash;
				$cmd = "WebGUI::Wobject::".${$wobject}{namespace};
				$w = $cmd->new($wobject);
				if ($w->inDateRange) {
					$contentHash{${$wobject}{templatePosition}} .= '<a name="'.${$wobject}{wobjectId}.'"></a>'
						.$w->www_view."<p>\n\n";
				}
			}
			$sth->finish;
			$cmd = "use WebGUI::Template::".$session{page}{template};
			eval($cmd);
			$cmd = "WebGUI::Template::".$session{page}{template}."::generate";
			$content = &$cmd(\%contentHash);
		} else {
			$contentHash{A} = WebGUI::Privilege::noAccess();
			$content = WebGUI::Template::Default::generate(\%contentHash);
		}
	}
	if ($session{var}{adminOn}) {
		$adminBar = _displayAdminBar();
	}
	if ($session{header}{redirect} ne "") {
		return $session{header}{redirect};
	} else {
		$httpHeader = WebGUI::Session::httpHeader();
		($header, $footer) = WebGUI::Style::getStyle();
		WebGUI::Session::close();
		return $httpHeader.$adminBar.$header.$pageEdit.$content.$footer.$debug;
	}
}




1;


