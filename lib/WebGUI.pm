package WebGUI;
our $VERSION = "6.0.0";

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
use WebGUI::International;
use WebGUI::Macro;
use WebGUI::Operation;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Style;
use WebGUI::Page;
use WebGUI::URL;


#-------------------------------------------------------------------	
sub _generatePage {
	my $content = shift;
	if ($session{form}{op} eq "" && $session{setting}{trackPageStatistics} && $session{form}{wid} ne "new") {
		WebGUI::SQL->write("insert into pageStatistics (dateStamp, userId, username, ipAddress, userAgent, referer,
			pageId, pageTitle, wobjectId, wobjectFunction) values (".time().",".$session{user}{userId}
			.",".quote($session{user}{username}).",
			".quote($session{env}{REMOTE_ADDR}).", ".quote($session{env}{HTTP_USER_AGENT}).",
			".quote($session{env}{HTTP_REFERER}).", ".$session{page}{pageId}.", 
			".quote($session{page}{title}).", ".quote($session{form}{wid}).", ".quote($session{form}{func}).")");
	}
	my $output = WebGUI::Macro::process(WebGUI::Style::process($content));
        if ($session{setting}{showDebug} || ($session{form}{debug}==1 && WebGUI::Privilege::isInGroup(3))) {
		$output .= WebGUI::ErrorHandler::showDebug();
        }
	return $output;
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
	my ($wobject, $output, $proxyWobjectId, $cmd, $w);
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
	WebGUI::Session::open($_[0],$_[1]);
        my $useCache = ($session{form}{op} eq "" && $session{form}{wid} eq "" && $session{form}{makePrintable} eq "" 
		&& (($session{page}{cacheTimeout} > 10 && $session{user}{userId} !=1) || ($session{page}{cacheTimeoutVisitor} > 10 && $session{user}{userId} == 1)) 
		&& not $session{var}{adminOn});
	my ($output, $cache);
        if ($useCache) {
                $cache = WebGUI::Cache->new("page_".$session{page}{pageId}."_".$session{user}{userId});
                $output = $cache->get;
        }
	my $operationOutput = _processOperations();
	WebGUI::Affiliate::grabReferral();
	my $wobjectOutput = _processFunctions();
	if ($operationOutput eq "" && $wobjectOutput eq "" && $session{form}{action2} ne "") {
		_processAction($session{form}{action2});
		$operationOutput = _processOperations();
        	$wobjectOutput = _processFunctions();
	}
	if ($output ne "") {
		$output = WebGUI::Session::httpHeader().$output;
	} elsif ($session{header}{mimetype} ne "text/html") {
		$output = WebGUI::Session::httpHeader().$operationOutput.$wobjectOutput;
	} elsif ($operationOutput ne "") {
		$output = WebGUI::Session::httpHeader()._generatePage($operationOutput);
        } elsif ($session{page}{redirectURL} && !$session{var}{adminOn}) {
              	$output = WebGUI::Session::httpRedirect(WebGUI::Macro::process($session{page}{redirectURL}));
        } elsif ($session{header}{redirect} ne "") {
                $output = $session{header}{redirect};
	} elsif ($wobjectOutput ne "") {
		$output = WebGUI::Session::httpHeader()._generatePage($wobjectOutput);
	} else {
		$output = _generatePage(WebGUI::Page::generate());
		my $ttl;
		if ($session{user}{userId} == 1) {
			$ttl = $session{page}{cacheTimeoutVisitor};
		} else {
			$ttl = $session{page}{cacheTimeout};
		}
		$cache->set($output, $ttl) if ($useCache);
		$output = WebGUI::Session::httpHeader().$output;
	}
	WebGUI::Session::close();
	return $output;
}




1;


