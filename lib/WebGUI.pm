package WebGUI;
our $VERSION = "6.9.0";
our $STATUS = "beta";

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
use Time::HiRes;
use WebGUI::Affiliate;
use WebGUI::Asset;
use WebGUI::Cache;
use WebGUI::Config;
use WebGUI::ErrorHandler;
use WebGUI::Grouping;
use WebGUI::HTTP;
use WebGUI::International;
use WebGUI::Operation;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::Setting;
use WebGUI::SQL;
use WebGUI::Style;
use WebGUI::URL;
use WebGUI::Utility;
use WebGUI::PassiveProfiling;
use Apache2::Request;
use Apache2::RequestRec ();
use Apache2::RequestIO ();
use Apache2::Const -compile => qw(OK DECLINED NOT_FOUND);
use Apache2::ServerUtil ();

#-------------------------------------------------------------------
sub handler {
	my $r = shift;
	my $s = Apache2::ServerUtil->server;
	$s->add_version_component("WebGUI/".$WebGUI::VERSION);
	$config = WebGUI::Config->new($s->dir_config('WebguiRoot'),$r->dir_config('WebguiConfig'));
	foreach my $url ($config->get("extrasURL"), @{$config->get("passthruUrls")}) {
		return Apache2::Const::DECLINED if ($r->uri =~ m/^$url/);
	}
	my $uploads = $config->get("uploadsURL");
	if ($r->uri =~ m/^$uploads/) {
		$r->set_handlers(PerlAccessHandler => \&uploadsHandler);
	} else {
		$r->set_handlers(PerlResponseHandler => \&contentHandler);
		$r->set_handlers(PerlTransHandler => sub { return Apache2::Const::OK });
	}
	return Apache2::Const::DECLINED;
}


#-------------------------------------------------------------------	
sub contentHandler {
	### inherit Apache request.
	my $r = shift;
	### Instantiate the API for this httpd instance.
	my $s = Apache2::ServerUtil->server;
	### Open new or existing user session based on user-agent's cookie.
	my $session = WebGUI::Session->open($s->dir_config('WebguiRoot'),$r->dir_config('WebguiConfig'),$r, $s);
	### form variables
	foreach ($session{req}->param) {
		$session{form}{$_} = $session{req}->body($_) || $session{req}->param($_);
	}
	if ($session->env->get("HTTP_X_MOZ") eq "prefetch") { # browser prefetch is a bad thing
		$session->http->setStatus("403","We don't allow prefetch, because it increases bandwidth, hurts stats, and can break web sites.");
		$r->print($session->http->getHeader);
	} elsif ($session->setting->get("specialState") eq "upgrading") {
		upgrading($r);
	} elsif ($session->setting->get("specialState") eq "init") {
		$r->print(setup());
	} else {
		my $output = "";
		if ($session->errorHandler->canShowPerformanceIndicators) {
			my $t = [Time::HiRes::gettimeofday()];
			$output = page($session);
			$t = Time::HiRes::tv_interval($t) ;
			$output =~ s/<\/title>/ : ${t} seconds<\/title>/i;
		} else {
			$output = page($session);
		}
		$r->print($session->http->getHeader());
		$r->print($output) unless ($session->http->isRedirect());
		#WebGUI::Affiliate::grabReferral();	# process affilliate tracking request
	}
	$session->close;
	return Apache2::Const::OK;
}

#-------------------------------------------------------------------
sub page {
	my $session = shift;
	my $assetUrl = shift;
	my $output = processOperations();
	if ($output eq "") {
		my $asset = eval{WebGUI::Asset->newByUrl($session,$assetUrl,$session{form}{revision})};
		if ($@) {
			$session->errorHandler->warn("Couldn't instantiate asset for url: ".$session->url->getRequestedUrl." Root cause: ".$@);
		}
		if (defined $asset) {
			my $method = "view";
			if (exists $session{form}{func}) {
				$method = $session{form}{func};
				unless ($method =~ /^[A-Za-z]+$/) {
					$session->security("tried to call a non-existent method $method on $assetUrl");
					$method = "view";
				}
			}
			$output = tryAssetMethod($asset,$method);
			$output = tryAssetMethod($asset,"view") unless ($method eq "view" || $output);
		}
	}
	if ($output eq "") {
		$session->http->setStatus("404","Page Not Found");
		my $notFound = WebGUI::Asset->getNotFound($session);
		if (defined $notFound) {
			$output = tryAssetMethod($notFound,'view');
		} else {
			$session->errorHandler->error("The notFound page failed to be created!");
			$output = "An error was encountered while processing your request.";
		}
		$output = "An error was encountered while processing your request." unless $output ne '';
	}
	return $output;
}


#-------------------------------------------------------------------
sub processOperations {
	my ($cmd, $output);
	my $op = $session{form}{op};
	my $opNumber = shift || 1;
	if ($op) {
		$output = WebGUI::Operation::execute($op);
	}
	$opNumber++;
	if ($output eq "" && exists $session{form}{"op".$opNumber}) {
		my $urlString = WebGUI::URL::unescape($session{form}{"op".$opNumber});
		my @pairs = split(/\;/,$urlString);
		my %form;
		foreach my $pair (@pairs) {
			my @param = split(/\=/,$pair);
			$form{$param[0]} = $param[1];
		}
		$session{form} = \%form;
		$output = processOperations($opNumber);
	}
	return $output;
}


#-------------------------------------------------------------------
sub setup {
	require WebGUI::Operation::WebGUI;
	my $output = WebGUI::Operation::WebGUI::www_setup();
	return WebGUI::HTTP::getHeader().$output;
}


#-------------------------------------------------------------------
sub tryAssetMethod {
	my $asset = shift;
	my $method = shift;
	$session{asset} = $asset;
	my $methodToTry = "www_".$method;
	my $output = eval{$asset->$methodToTry()};
	if ($@) {
		WebGUI::ErrorHandler::warn("Couldn't call method ".$method." on asset for url: ".$session{requestedUrl}." Root cause: ".$@);
		$output = tryAssetMethod($asset,'view') if ($method ne "view");
	}
	return $output;
}

#-------------------------------------------------------------------
sub uploadsHandler {
	my $r = shift;
	my $ok = Apache2::Const::OK;
	my $notfound = Apache2::Const::NOT_FOUND;
	if (-e $r->filename) {
		my $path = $r->filename;
		$path =~ s/^(\/.*\/).*$/$1/;
		if (-e $path.".wgaccess") {
			my $fileContents;
			open(FILE,"<".$path.".wgaccess");
			while (<FILE>) {
				$fileContents .= $_;
			}
			close(FILE);
			my @privs = split("\n",$fileContents);
			unless ($privs[1] eq "7" || $privs[1] eq "1") {
				my $s = Apache2::ServerUtil->server;
				WebGUI::Session::open($s->dir_config('WebguiRoot'),'modperl',"false");
				$session{cookie} = APR::Request::Apache2->handle($r)->jar();
				if ($session{cookie}{wgSession} eq "") {
					WebGUI::Session::start(1); #setting up a visitor session
				} else {
					WebGUI::Session::setupSessionVars($session{cookie}{wgSession});
				}
				$session{req}->user($session{var}{username}) if $session{req};
				my $hasPrivs = ($session{var}{userId} eq $privs[0] || WebGUI::Grouping::isInGroup($privs[1]) || WebGUI::Grouping::isInGroup($privs[2]));
				WebGUI::Session::close();
				if ($hasPrivs) {
					return $ok;
				} else {
					return 401;
				}
			}
		}
		return $ok;
	} else {
		return $notfound;
	}
}


#-------------------------------------------------------------------
sub upgrading {
	my $r = shift;
        $r->print(WebGUI::HTTP::getHeader());
	open(FILE,"<".$session{config}{webguiRoot}."/docs/maintenance.html");
	while (<FILE>) {
		$r->print($_);
	}
	close(FILE);
}



1;


