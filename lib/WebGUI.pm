package WebGUI;
our $VERSION = "4.7.0";

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com			info@plainblack.com
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
use WebGUI::URL;
use WebGUI::Utility;


#-------------------------------------------------------------------	
sub _generateDebug {
	my ($debug);
        if ($session{setting}{showDebug} || ($session{form}{debug}==1 && WebGUI::Privilege::isInGroup(3))) {
                $debug = '<div style="background-color: #ffdddd;color: #000000;">'.$session{debug}{warning}.'</div>';
                $debug .= '<div style="background-color: #800000;color: #ffffff;">'.$session{debug}{security}.'</div>';
                $debug .= '<div style="background-color: #ffffdd;color: #000000;">'.$session{debug}{audit}.'</div>';
                $debug .= '<table bgcolor="#ffffff" style="color: #000000; font-size: 10pt; font-family: helvetica;">';
                while (my ($section, $hash) = each %session) {
                        while (my ($key, $value) = each %$hash) {
                                if (ref $value eq 'ARRAY') {
                                        $value = '['.join(', ',@$value).']';
                                } elsif (ref $value eq 'HASH') {
                                        $value = '{'.join(', ',map {"$_ => $value->{$_}"} keys %$value).'}';
                                }
                                unless (lc($key) eq "password" || lc($key) eq "identifier") {
                                        $debug .= '<tr><td align="right"><b>'.$section.'.'.$key.':</b></td><td>'.$value.'</td>';
                                }
                        }
                        $debug .= '<tr height=10><td>&nbsp;</td><td>&nbsp</td></tr>';
                }
                $debug .='</table>';
        }
	return $debug;
}

#-------------------------------------------------------------------	
sub _generatePage {
	my ($canEdit, $pageEdit, $sth, $wobject, %contentHash, $originalWobject, $sql, $extra, %hash, $cmd, $w, $template);
	if (WebGUI::Privilege::canViewPage()) {
        	if ($session{var}{adminOn}) {
                	$canEdit = WebGUI::Privilege::canEditPage();
                        if ($canEdit) {
                        	$pageEdit = "\n<br>"
                                	.pageIcon()
                                        .deleteIcon('op=deletePage')
                                        .editIcon('op=editPage')
                                        .moveUpIcon('op=movePageUp')
                                        .moveDownIcon('op=movePageDown')
                                        .cutIcon('op=cutPage')
                                        ."\n";
                        }
                }
                $sth = WebGUI::SQL->read("select * from wobject where pageId=$session{page}{pageId} 
			order by sequenceNumber, wobjectId");
                while ($wobject = $sth->hashRef) {
                        if ($session{var}{adminOn} && $canEdit) {
                        	$contentHash{"template.position".${$wobject}{templatePosition}} .= "\n<hr>"
                                	.wobjectIcon()
                                        .deleteIcon('func=delete&wid='.${$wobject}{wobjectId})
                                        .editIcon('func=edit&wid='.${$wobject}{wobjectId})
                                        .moveUpIcon('func=moveUp&wid='.${$wobject}{wobjectId})
                                        .moveDownIcon('func=moveDown&wid='.${$wobject}{wobjectId})
                                        .moveTopIcon('func=moveTop&wid='.${$wobject}{wobjectId})
                                        .moveBottomIcon('func=moveBottom&wid='.${$wobject}{wobjectId})
                                        .cutIcon('func=cut&wid='.${$wobject}{wobjectId})
                                        .copyIcon('func=copy&wid='.${$wobject}{wobjectId})
                                        .'<br>';
                        }
                        if (${$wobject}{namespace} eq "WobjectProxy") {
                                $originalWobject = $wobject;
                                ($wobject) = WebGUI::SQL->quickArray("select proxiedWobjectId from WobjectProxy 
					where wobjectId=".${$wobject}{wobjectId});
                                $wobject = WebGUI::SQL->quickHashRef("select * from wobject where wobject.wobjectId=".$wobject);
                                if (${$wobject}{namespace} eq "") {
                                        $wobject = $originalWobject;
                                } else {
                                        ${$wobject}{templatePosition} = ${$originalWobject}{templatePosition};
                                        ${$wobject}{_WobjectProxy} = ${$originalWobject}{wobjectId};
                                }
                        }
                        my $sql = "select * from ".$wobject->{namespace}." where wobjectId=".$wobject->{wobjectId};
                        $extra = WebGUI::SQL->quickHashRef("select * from ".$wobject->{namespace}." 
				where wobjectId=".$wobject->{wobjectId});
                        tie %hash, 'Tie::CPHash';
                        %hash = (%{$wobject},%{$extra});
                        $wobject = \%hash;
                        $cmd = "WebGUI::Wobject::".${$wobject}{namespace};
                        $w = eval{$cmd->new($wobject)};
                        WebGUI::ErrorHandler::fatalError("Couldn't instanciate wobject: ${$wobject}{namespace}. Root cause: ".$@) if($@);
                        if ($w->inDateRange) {
                        	$contentHash{"template.position".${$wobject}{templatePosition}} .= '<div class="wobject'
					.${$wobject}{namespace}.'" id="wobjectId'.${$wobject}{wobjectId}.'">';
                                $contentHash{"template.position".${$wobject}{templatePosition}} .= '<a name="'
					.${$wobject}{wobjectId}.'"></a>';
                                $contentHash{"template.position".${$wobject}{templatePosition}} .= eval{$w->www_view};
                                WebGUI::ErrorHandler::fatalError("Wobject runtime error: ${$wobject}{namespace}. Root cause: ".$@) if($@);
                                $contentHash{"template.position".${$wobject}{templatePosition}} .= "</div>\n\n";
                        }
		}
                $sth->finish;
                $template = $session{page}{templateId};
	} else {
                $contentHash{"template.position".1} = WebGUI::Privilege::noAccess();
        }
	return (\%contentHash,$template,$pageEdit);
}

#-------------------------------------------------------------------	
sub _processAction {
	my ($urlString, %form, $pair, @pairs, @param);
	$urlString = WebGUI::URL::unescape($_[0]);
	@pairs = split(/\&/,$urlString);
	foreach $pair (@pairs) {
		@param = split(/\=/,$pair);
		$form{$param[0]} = $param[1];
	}
	$session{form} = \%form;
}

#-------------------------------------------------------------------	
sub _processFunctions {
	my ($wobject, $extra, %hash, $output, $proxyWobjectId, $cmd, $w);
        if (exists $session{form}{func} && exists $session{form}{wid}) {
                if ($session{form}{func} =~ /^[A-Za-z]+$/) {
                        if ($session{form}{wid} eq "new") {
                                $wobject = {wobjectId=>"new",namespace=>$session{form}{namespace},pageId=>$session{page}{pageId}};
                        } else {
                                $wobject = WebGUI::SQL->quickHashRef("select * from wobject where wobjectId="
                                        .$session{form}{wid});
                                if (${$wobject}{namespace} eq "") {
                                        WebGUI::ErrorHandler::warn("Wobject [$session{form}{wid}] appears to be missing or "
                                                ."corrupt, but was requested "
                                                ."by $session{user}{username} [$session{user}{userId}].");
                                        $wobject = ();
                                } else {
                                        $extra = WebGUI::SQL->quickHashRef("select * from ${$wobject}{namespace}
                                                where wobjectId=${$wobject}{wobjectId}");
                                        tie %hash, 'Tie::CPHash';
                                        %hash = (%{$wobject},%{$extra});
                                        $wobject = \%hash;
                                }
                        }
                        if ($wobject) {
                                if (${$wobject}{pageId} != $session{page}{pageId}) {
                                        ($proxyWobjectId) = WebGUI::SQL->quickArray("select wobject.wobjectId from
                                                wobject,WobjectProxy
                                                where wobject.wobjectId=WobjectProxy.wobjectId
                                                and wobject.pageId=".$session{page}{pageId}."
                                                and WobjectProxy.proxiedWobjectId=".${$wobject}{wobjectId});
                                        ${$wobject}{_WobjectProxy} = $proxyWobjectId;
                                }
                                unless (${$wobject}{pageId} == $session{page}{pageId} || ${$wobject}{pageId} == 2 || ${$wobject}{_WobjectProxy} ne "") {
                                        $output .= WebGUI::International::get(417);
                                        WebGUI::ErrorHandler::security("access wobject [".$session{form}{wid}."] on page '"
                                                .$session{page}{title}."' [".$session{page}{pageId}."].");
                                } else {
                                        if (WebGUI::Privilege::canViewPage()) {
                                                $cmd = "WebGUI::Wobject::".${$wobject}{namespace};
                                                $w = eval{$cmd->new($wobject)};
                                                WebGUI::ErrorHandler::fatalError("Couldn't instanciate wobject: ${$wobject}{namespace}. Root Cause: ".$@) if($@);
                                                $cmd = "www_".$session{form}{func};
                                                $output = eval{$w->$cmd};
                                                WebGUI::ErrorHandler::fatalError("Wobject runtime error: ${$wobject}{namespace} / $session{form}{func}. Root cause: ".$@) if($@);
                                        } else {
                                                $output = WebGUI::Privilege::noAccess();
                                        }
                                }
                        }
                } else {
                        WebGUI::ErrorHandler::security("execute an invalid function on wobject "
                                .$session{form}{wid}.": ".$session{form}{func});
                }
        }
	return $output;
}


#-------------------------------------------------------------------	
sub _processOperations {
	my ($cmd, $output);
        if (exists $session{form}{op}) {
                if ($session{form}{op} =~ /^[A-Za-z]+$/) {
                        $cmd = "WebGUI::Operation::www_".$session{form}{op};
                        $output = eval($cmd);
                        WebGUI::ErrorHandler::security("call a non-existent operation: $session{form}{op}.") if($@);
                } else {
                        WebGUI::ErrorHandler::security("execute an invalid operation: ".$session{form}{op});
                }
        }
	return $output;
}

#-------------------------------------------------------------------
sub page {
	my ($positions, $wobjectOutput, $pageEdit, $httpHeader, $content, $operationOutput, $template);
	WebGUI::Session::open($_[0],$_[1]);
	$operationOutput = _processOperations();
	$wobjectOutput = _processFunctions();
	if ($operationOutput eq "" && $wobjectOutput eq "" && $session{form}{action2} ne "") {
		_processAction($session{form}{action2});
		$operationOutput = _processOperations();
        	$wobjectOutput = _processFunctions();
	}
	if ($session{header}{mimetype} ne "text/html") {
		$httpHeader = WebGUI::Session::httpHeader();
		WebGUI::Session::close();
		return $httpHeader.$operationOutput.$wobjectOutput;
        } elsif ($session{page}{redirectURL}) {
                $httpHeader = WebGUI::Session::httpRedirect($session{page}{redirectURL});
		WebGUI::Session::close();
		return $httpHeader;
        } elsif ($session{header}{redirect} ne "") {
                $httpHeader = $session{header}{redirect};
                WebGUI::Session::close();
                return $httpHeader;
	} elsif ($operationOutput ne "") {
		$positions->{"template.position".1} = $operationOutput;
	} elsif ($wobjectOutput ne "") {
		$positions->{"template.position".1} = $wobjectOutput;
	} else {
		($positions, $template, $pageEdit) = _generatePage();
	}
	$httpHeader = WebGUI::Session::httpHeader();
	$content = WebGUI::Template::process(
		WebGUI::Macro::process(
			WebGUI::Style::get(
				$pageEdit
				.WebGUI::Template::get($template)
			)
		),
		$positions
	);
	WebGUI::Session::close();
	return $httpHeader.$content._generateDebug();
}




1;


