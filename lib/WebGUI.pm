package WebGUI;
our $VERSION = "5.5.0";

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2003 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com			info@plainblack.com
#-------------------------------------------------------------------

use strict qw(vars subs);
use Tie::CPHash;
use WebGUI::Affiliate;
use WebGUI::Cache;
use WebGUI::ErrorHandler;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Macro;
use WebGUI::Operation;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Style;
use WebGUI::Page;
use WebGUI::Template;
use WebGUI::URL;
use WebGUI::Utility;


#-------------------------------------------------------------------	
sub _generateDebug {
        if ($session{setting}{showDebug} || ($session{form}{debug}==1 && WebGUI::Privilege::isInGroup(3))) {
		return WebGUI::ErrorHandler::showDebug();
        }
	return "";
}

#-------------------------------------------------------------------	
sub _generatePage {
	my ($canEdit, $pageEdit, $sth, $wobject, %contentHash, $originalWobject, $sql, $extra, %hash, $cmd, $w, $template,$canEditWobject);
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
	        	$canEditWobject = WebGUI::Privilege::canEditWobject($wobject->{wobjectId}); 
                        if ($session{var}{adminOn} && $canEditWobject) {
                        	$contentHash{"page.position".${$wobject}{templatePosition}} .= "\n<hr>"
                                	.wobjectIcon()
                                        .deleteIcon('func=delete&wid='.${$wobject}{wobjectId})
                                        .editIcon('func=edit&wid='.${$wobject}{wobjectId})
                                        .moveUpIcon('func=moveUp&wid='.${$wobject}{wobjectId})
                                        .moveDownIcon('func=moveDown&wid='.${$wobject}{wobjectId})
                                        .moveTopIcon('func=moveTop&wid='.${$wobject}{wobjectId})
                                        .moveBottomIcon('func=moveBottom&wid='.${$wobject}{wobjectId})
                                        .cutIcon('func=cut&wid='.${$wobject}{wobjectId})
                                        .copyIcon('func=copy&wid='.${$wobject}{wobjectId});
				if (${$wobject}{namespace} ne "WobjectProxy" && isIn("WobjectProxy",@{$session{config}{wobjects}})) {
                                        $contentHash{"page.position".${$wobject}{templatePosition}} .= 
						shortcutIcon('func=createShortcut&wid='.${$wobject}{wobjectId})
				}
                                $contentHash{"page.position".${$wobject}{templatePosition}} .= '<br>';
                        }
                        
		        if(!WebGUI::Privilege::canViewWobject($wobject->{wobjectId})){ next; }  
			if (${$wobject}{namespace} eq "WobjectProxy") {
                                $originalWobject = $wobject;
                                my ($wobjectProxy) = WebGUI::SQL->quickHashRef("select * from WobjectProxy where wobjectId=".${$wobject}{wobjectId});
                                $wobject = WebGUI::SQL->quickHashRef("select * from wobject where wobject.wobjectId=".$wobjectProxy->{proxiedWobjectId});
                                if (${$wobject}{namespace} eq "") {
                                        $wobject = $originalWobject;
                                } else {
                                        ${$wobject}{startDate} = ${$originalWobject}{startDate};
                                        ${$wobject}{endDate} = ${$originalWobject}{endDate};
                                        ${$wobject}{templatePosition} = ${$originalWobject}{templatePosition};
                                        ${$wobject}{_WobjectProxy} = ${$originalWobject}{wobjectId};
					if ($wobjectProxy->{overrideTitle}) {
						${$wobject}{title} = ${$originalWobject}{title};
					}
					if ($wobjectProxy->{overrideDisplayTitle}) {
						${$wobject}{displayTitle} = ${$originalWobject}{displayTitle};
					}
					if ($wobjectProxy->{overrideDescription}) {
						${$wobject}{description} = ${$originalWobject}{description};
					}
					if ($wobjectProxy->{overrideTemplate}) {
						${$wobject}{templateId} = $wobjectProxy->{proxiedTemplateId};
					}
                                }
                        }
                        $extra = WebGUI::SQL->quickHashRef("select * from ".$wobject->{namespace}." 
				where wobjectId=".$wobject->{wobjectId});
                        tie %hash, 'Tie::CPHash';
                        %hash = (%{$wobject},%{$extra});
                        $wobject = \%hash;
                        $cmd = "WebGUI::Wobject::".${$wobject}{namespace};
                        $w = eval{$cmd->new($wobject)};
                        WebGUI::ErrorHandler::fatalError("Couldn't instanciate wobject: ${$wobject}{namespace}. Root cause: ".$@) if($@);
			if ($w->inDateRange) {
                        	$contentHash{"page.position".${$wobject}{templatePosition}} .= '<div class="wobject"><div class="wobject'
					.${$wobject}{namespace}.'" id="wobjectId'.${$wobject}{wobjectId}.'">';
                                $contentHash{"page.position".${$wobject}{templatePosition}} .= '<a name="'
					.${$wobject}{wobjectId}.'"></a>';
                                $contentHash{"page.position".${$wobject}{templatePosition}} .= eval{$w->www_view};
                                WebGUI::ErrorHandler::fatalError("Wobject runtime error: ${$wobject}{namespace}. Root cause: ".$@) if($@);
                                $contentHash{"page.position".${$wobject}{templatePosition}} .= "</div></div>\n\n";
			}
		}
                $sth->finish;
                $template = $session{page}{templateId};
	} else {
                $contentHash{"page.position1"} = WebGUI::Privilege::noAccess();
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
                                unless (${$wobject}{pageId} == $session{page}{pageId}
								|| ${$wobject}{pageId} == 2
								|| ${$wobject}{pageId} == 3
								|| ${$wobject}{_WobjectProxy} ne "") {
                                        $output .= WebGUI::International::get(417);
                                        WebGUI::ErrorHandler::security("access wobject [".$session{form}{wid}."] on page '"
                                                .$session{page}{title}."' [".$session{page}{pageId}."].");
                                } else {
                                        if (WebGUI::Privilege::canViewPage()) {
                                                $cmd = "WebGUI::Wobject::".${$wobject}{namespace};
                                                $w = eval{$cmd->new($wobject)};
                                                WebGUI::ErrorHandler::fatalError("Couldn't instanciate wobject: ${$wobject}{namespace}. Root Cause: ".$@) if($@);
                				if ($session{form}{func} =~ /^[A-Za-z]+$/) {
                                                	$cmd = "www_".$session{form}{func};
                                                	$output = eval{$w->$cmd};
                                                	WebGUI::ErrorHandler::fatalError("Wobject runtime error: ${$wobject}{namespace} / $session{form}{func}. Root cause: ".$@) if($@);
						} else {
							WebGUI::ErrorHandler::security("execute an invalid function: ".$session{form}{func});
						}
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
                        WebGUI::ErrorHandler::security("call a non-existent operation: $session{form}{op}. Root cause: ".$@) if($@);
                } else {
                        WebGUI::ErrorHandler::security("execute an invalid operation: ".$session{form}{op});
                }
        }
	return $output;
}

#-------------------------------------------------------------------
sub page {
	my ($cache, $debug, $positions, $wobjectOutput, $pageEdit, $httpHeader, $content, $operationOutput, $template);
	WebGUI::Session::open($_[0],$_[1]);
        my $useCache = ($session{form}{op} eq "" && $session{form}{wid} eq "" && $session{form}{makePrintable} eq "" 
		&& (($session{page}{cacheTimeout} > 10 && $session{user}{userId} !=1) || ($session{page}{cacheTimeout} > 10 && $session{user}{userId} == 1)) 
		&& not $session{var}{adminOn});
        if ($useCache) {
                $cache = WebGUI::Cache->new("page_".$session{page}{pageId}."_".$session{user}{userId});
                $content = $cache->get;
        }
	$operationOutput = _processOperations();
	WebGUI::Affiliate::grabReferral();
	$wobjectOutput = _processFunctions();
	if ($operationOutput eq "" && $wobjectOutput eq "" && $session{form}{action2} ne "") {
		_processAction($session{form}{action2});
		$operationOutput = _processOperations();
        	$wobjectOutput = _processFunctions();
	}
	if ($operationOutput eq "" && $session{setting}{trackPageStatistics} && $session{form}{wid} ne "new" && $session{header}{mimetype} eq "text/html") {
		WebGUI::SQL->write("insert into pageStatistics (dateStamp, userId, username, ipAddress, userAgent, referer,
			pageId, pageTitle, wobjectId, wobjectFunction) values (".time().",".$session{user}{userId}
			.",".quote($session{user}{username}).",
			".quote($session{env}{REMOTE_ADDR}).", ".quote($session{env}{HTTP_USER_AGENT}).",
			".quote($session{env}{HTTP_REFERER}).", ".$session{page}{pageId}.", 
			".quote($session{page}{title}).", ".quote($session{form}{wid}).", ".quote($session{form}{func}).")");
	}
	if ($session{header}{mimetype} ne "text/html") {
		$httpHeader = WebGUI::Session::httpHeader();
		WebGUI::Session::close();
		return $httpHeader.$operationOutput.$wobjectOutput;
	} elsif ($operationOutput ne "") {
		$positions->{"page.position1"} = $operationOutput;
        } elsif ($session{page}{redirectURL} && !$session{var}{adminOn}) {
                $httpHeader = WebGUI::Session::httpRedirect(WebGUI::Macro::process($session{page}{redirectURL}));
                WebGUI::Session::close();
                return $httpHeader;
        } elsif ($session{header}{redirect} ne "") {
                $httpHeader = $session{header}{redirect};
                WebGUI::Session::close();
                return $httpHeader;
	} elsif ($wobjectOutput ne "") {
		$positions->{"page.position1"} = $wobjectOutput;
	} elsif (!($useCache && defined $content)) {
		($positions, $template, $pageEdit) = _generatePage();
	}
	$httpHeader = WebGUI::Session::httpHeader();
	unless ($useCache && defined $content) {
		$content = WebGUI::Macro::process(WebGUI::Template::process(WebGUI::Style::get($pageEdit.WebGUI::Page::getTemplate($template)), $positions));
		my $ttl;
		if ($session{user}{userId} == 1) {
			$ttl = $session{page}{cacheTimeoutVisitor};
		} else {
			$ttl = $session{page}{cacheTimeout};
		}
		$cache->set($content, $ttl) if ($useCache);
	}
	$debug = _generateDebug();
	WebGUI::Session::close();
	return $httpHeader.$content.$debug;
}




1;


