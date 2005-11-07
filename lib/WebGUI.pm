package WebGUI;
our $VERSION = "6.8.0";
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
use WebGUI::Utility;
use WebGUI::PassiveProfiling;
use Apache2::Request;
use Apache2::RequestRec ();
use Apache2::RequestIO ();
use Apache2::Const -compile => qw(OK DECLINED);
use Apache2::ServerUtil ();

#-------------------------------------------------------------------	
sub handler {
        my $r = shift;
        my $s = Apache2::ServerUtil->server;
	my $config = WebGUI::Config::getConfig($s->dir_config('WebguiRoot'),$r->dir_config('WebguiConfig'));
	foreach my $url ($config->{extrasURL}, @{$config->{passthruUrls}}) {
		return Apache2::Const::DECLINED if ($r->uri =~ m/^$url/);
	}
	my $uploads = $config->{uploadsURL};
	if ($r->uri =~ m/^$uploads/) {
		$r->handler('perl-script');
		$r->set_handlers(PerlAccessHandler => \&uploadsHandler);	
	} else {
        	$r->handler('perl-script');
        	$r->set_handlers(PerlResponseHandler => \&contentHandler);
        	$r->set_handlers(PerlTransHandler => sub { return Apache2::Const::OK });
	}
        return Apache2::Const::DECLINED;
}


#-------------------------------------------------------------------	
sub contentHandler {
	my $r = shift;
        my $s = Apache2::ServerUtil->server;
	WebGUI::HTTP::getCookies();
	WebGUI::Session::open($s->dir_config('WebguiRoot'),$r->dir_config('WebguiConfig'),$r);
	### Apache2::Request object
	$session{req} = Apache2::Request->new($r, POST_MAX => 1024 * $session{setting}{maxAttachmentSize});        
	### Add Apache Request stuff to Session
	$session{wguri} = $r->uri;
	### check to see if client is proxied and adjust remote_addr as necessary
	if ($ENV{HTTP_X_FORWARDED_FOR} ne "") {
		$session{env}{REMOTE_ADDR} = $ENV{HTTP_X_FORWARDED_FOR};
	}
	### form variables
	foreach ($session{req}->param) {
		$session{form}{$_} = $session{req}->param($_);
	}
	if ($session{env}{HTTP_X_MOZ} eq "prefetch") { # browser prefetch is a bad thing
		WebGUI::HTTP::setStatus("403","We don't allow prefetch, because it increases bandwidth, hurts stats, and can break web sites.");
		$r->print(WebGUI::HTTP::getHeader());
	} elsif ($session{setting}{specialState} eq "upgrading") {
		$r->print(upgrading());
	} elsif ($session{setting}{specialState} eq "init") {
		return $r->print(setup());
	} else {
		my $output = page();
		WebGUI::Affiliate::grabReferral();	# process affilliate tracking request
		if (WebGUI::HTTP::isRedirect()) {
                	$output = WebGUI::HTTP::getHeader();
        	} else {
                	$output = WebGUI::HTTP::getHeader().$output;
       			if (WebGUI::ErrorHandler::canShowDebug()) {
				$output .= WebGUI::ErrorHandler::showDebug();
       			}
        	}
		$r->print($output);
	}
	WebGUI::Session::close();
	return Apache2::Const::OK;
}

#-------------------------------------------------------------------
sub page {
	my $assetUrl = shift;
	my $output = processOperations();
	if ($output eq "") {
		my $asset = WebGUI::Asset->newByUrl($assetUrl,$session{form}{revision});
		if (defined $asset) {
			$session{asset} = $asset;
			my $method = "view";
			if (exists $session{form}{func}) {
				$method = $session{form}{func};
				unless ($method =~ /^[A-Za-z]+$/) {
					WebGUI::ErrorHandler::security("tried to call a non-existent method $method on $assetUrl");
					$method = "view";
				}
			}
			$method = "www_".$method;
			$output = eval{$asset->$method()};
			if ($@) {
				WebGUI::ErrorHandler::warn("Couldn't call method ".$method." on asset for ".$session{wguri}." Root cause: ".$@);
				$output = $asset->www_view;
			} else {
				if ($output eq "" && $method ne "view") {
					$output = $asset->www_view;
				}
			}
		} else {
			my $notFound = WebGUI::Asset->getNotFound;
			$session{asset} = $notFound;
			$output = $notFound->www_view;
		}
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
sub uploadsHandler {
	my $r = shift;
        my $s = Apache2::ServerUtil->server;
	my $ok = Apache2::Const::OK();
        my $notfound = Apache2::Const::NOT_FOUND();
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
        			WebGUI::HTTP::getCookies();
        			WebGUI::Session::open($s->dir_config('WebguiRoot'),$r->dir_config('WebguiConfig'),$r);
        			### Apache2::Request object
        			$session{req} = $r;
                                WebGUI::Session::refreshSessionVars($session{cookie}{wgSession});
				my $hasPrivs = ($session{user}{userId} eq $privs[0] || WebGUI::Grouping::isInGroup($privs[1]) || WebGUI::Grouping::isInGroup($privs[2]));
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
        my $output = WebGUI::HTTP::getHeader();
	open(FILE,"<".$session{config}{webguiRoot}."/docs/maintenance.html");
	while (<FILE>) {
		$output .= $_;
	}
	close(FILE);
	return $output;
}



1;


