package WebGUI;
our $VERSION = "3.9.0";

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
use WebGUI::ErrorHandler;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Operation;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Style;
use WebGUI::Template;

#-------------------------------------------------------------------
sub page {
	my ($debug, %contentHash, $w, $cmd, $pageEdit, $wobject, $wobjectOutput, $extra, 
		$sth, $httpHeader, $header, $footer, $content, $operationOutput, $adminBar, %hash);
	WebGUI::Session::open($_[0],$_[1]);
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
		$contentHash{0} = $operationOutput;
		$content = WebGUI::Template::generate(\%contentHash,1);
	} elsif ($wobjectOutput ne "") {
		$contentHash{0} = $wobjectOutput;
		$content = WebGUI::Template::generate(\%contentHash,1);
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
			$content = WebGUI::Template::generate(\%contentHash,$session{page}{templateId});
		} else {
			$contentHash{0} = WebGUI::Privilege::noAccess();
			$content = WebGUI::Template::generate(\%contentHash,1);
		}
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


