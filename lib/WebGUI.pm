package WebGUI;
our $VERSION = "6.6.5";
our $STATUS = "gamma";

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
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
use WebGUI::Asset;
use WebGUI::Cache;
use WebGUI::ErrorHandler;
use WebGUI::Grouping;
use WebGUI::HTTP;
use WebGUI::International;
use WebGUI::Operation;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Style;
use WebGUI::URL;
use WebGUI::PassiveProfiling;


#-------------------------------------------------------------------	
sub _processOperations {
	my ($cmd, $output);
	my $op = $session{form}{op};
	my $opNumber = shift || 1;
        if ($op) {
		$output = WebGUI::Operation::execute($op);
        }
	$opNumber++;
	if ($output eq "" && exists $session{form}{"op".$opNumber}) {
		my $urlString = WebGUI::URL::unescape($session{form}{"op".$opNumber});
		my @pairs = split(/\&/,$urlString);
		my %form;
		foreach my $pair (@pairs) {
			my @param = split(/\=/,$pair);
			$form{$param[0]} = $param[1];
		}
		$session{form} = \%form;
		$output = _processOperations($opNumber);
	}
	return $output;
}

#-------------------------------------------------------------------
sub _setup {
	require WebGUI::Operation::WebGUI;
	my $output = WebGUI::Operation::WebGUI::www_setup();
        $output = WebGUI::HTTP::getHeader().$output;
	WebGUI::Session::close();
	return $output;
}

#-------------------------------------------------------------------
sub _upgrading {
	my $webguiRoot = shift;
        my $output = WebGUI::HTTP::getHeader();
	open(FILE,"<".$webguiRoot."/docs/maintenance.html");
	while (<FILE>) {
		$output .= $_;
	}
	close(FILE);
	WebGUI::Session::close();
	return $output;
}


#-------------------------------------------------------------------
sub page {
	my $webguiRoot = shift;
	my $configFile = shift;
	my $useExistingSession = shift;   # used for static page generation functions where  you may generate more than one asset at a time.
	my $assetUrl = shift;
	my $fastcgi = shift;
	WebGUI::Session::open($webguiRoot,$configFile,$fastcgi) unless ($useExistingSession);
	return _upgrading($webguiRoot) if ($session{setting}{specialState} eq "upgrading");
	return _setup() if ($session{setting}{specialState} eq "init");
	my $output = _processOperations();
	if ($output eq "") {
		my $asset = WebGUI::Asset->newByUrl($assetUrl);
		$session{asset} = $asset;
		my $method = "view";
		if (exists $session{form}{func}) {
			$method = $session{form}{func};
		}
		$method = "www_".$method;
		$output = eval{$asset->$method()};
		if ($@) {
			WebGUI::ErrorHandler::warn("Couldn't call method ".$method." on asset for ".$session{env}{PATH_INFO}." Root cause: ".$@);
			$output = $asset->www_view;
		} else {
			if ($output eq "" && $method ne "view") {
				$output = $asset->www_view;
			}
		}
	}
	WebGUI::Affiliate::grabReferral();	# process affilliate tracking request
	if (WebGUI::HTTP::isRedirect() && !$useExistingSession) {
                $output = WebGUI::HTTP::getHeader();
        } else {
                $output = WebGUI::HTTP::getHeader().$output;
       		if ($session{setting}{showDebug} || ($session{form}{debug}==1 && WebGUI::Grouping::isInGroup(3))) {
			$output .= WebGUI::ErrorHandler::showDebug();
       		}
        }
	# This allows an operation or wobject to write directly to the browser.
	$output = undef if ($session{page}{empty});
	WebGUI::Session::close() unless ($useExistingSession);
	return $output;
}




1;


