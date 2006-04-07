package WebGUI;
our $VERSION = "6.99.0";
our $STATUS = "beta";

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
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
use WebGUI::International;
use WebGUI::Operation;
use WebGUI::Session;
use WebGUI::Utility;
use WebGUI::PassiveProfiling;
use Apache2::Request;
use Apache2::RequestRec ();
use Apache2::RequestIO ();
use Apache2::Const -compile => qw(OK DECLINED NOT_FOUND DIR_MAGIC_TYPE);
use Apache2::ServerUtil ();

#-------------------------------------------------------------------

=head2 handler ( requestObject )

Primary http init/response handler for WebGUI.  This method decides whether to hand off the request to contentHandler() or uploadsHandler()

=head3 requestObject

The Apache2::RequestRec object passed in by Apache's mod_perl.

=cut

sub handler {
	my $r = shift;
	my $s = Apache2::ServerUtil->server;
	my $config = WebGUI::Config->new($s->dir_config('WebguiRoot'),$r->dir_config('WebguiConfig'));
	$r->push_handlers(PerlFixupHandler => \&fixupHandler) if (defined $config->get("passthruUrls"));
	foreach my $url ($config->get("extrasURL"), @{$config->get("passthruUrls")}) {
		return Apache2::Const::DECLINED if ($r->uri =~ m/^$url/);
	}
	my $uploads = $config->get("uploadsURL");
	if ($r->uri =~ m/^$uploads/) {
		$r->push_handlers(PerlAccessHandler => \&uploadsHandler);
	} else {
		$r->push_handlers(PerlResponseHandler => \&contentHandler);
		$r->push_handlers(PerlTransHandler => sub { return Apache2::Const::OK });
	}
	return Apache2::Const::DECLINED;
}


#-------------------------------------------------------------------	

=head2 contentHandler ( requestObject )

Creates the WebGUI session, handles exceptional request 
headers, handles special states, prints the response headers,
and (usually) prints the output of page().

=head3 requestObject

The Apache2::RequestRec object passed in by Apache's mod_perl.

=cut

sub contentHandler {
	### inherit Apache request.
	my $r = shift;
	### Instantiate the API for this httpd instance.
	my $s = Apache2::ServerUtil->server;
	### Open new or existing user session based on user-agent's cookie.
	my $session = WebGUI::Session->open($s->dir_config('WebguiRoot'),$r->dir_config('WebguiConfig'),$r, $s);
	if ($session->env->get("HTTP_X_MOZ") eq "prefetch") { # browser prefetch is a bad thing
		$session->http->setStatus("403","We don't allow prefetch, because it increases bandwidth, hurts stats, and can break web sites.");
		$session->http->getHeader;
	} elsif ($session->setting->get("specialState") eq "upgrading") {
		upgrading($session);
	} elsif ($session->setting->get("specialState") eq "init") {
		setup($session);
	} else {
		my $output = "";
		if ($session->errorHandler->canShowPerformanceIndicators) {
			my $t = [Time::HiRes::gettimeofday()];
			$output = page($session);
			$t = Time::HiRes::tv_interval($t) ;
			if ($output =~ /<\/title>/) {
				$output =~ s/<\/title>/ : ${t} seconds<\/title>/i;
			} else {
				$session->output->print("\nPage generated in $t seconds.\n");
			}
		} else {
			$output = page($session);
		}
		$session->http->setCookie("wgSession",$session->var->{_var}{sessionId}) unless $session->var->{_var}{sessionId} eq $session->http->getCookies->{"wgSession"};
		$session->http->getHeader();
		$session->output->print($output) unless ($session->http->isRedirect());
		WebGUI::Affiliate::grabReferral($session);	# process affilliate tracking request
	}
	$session->close;
	return Apache2::Const::OK;
}

#-------------------------------------------------------------------

=head2 fixupHandler ( requestObject )

This method is here to allow proper handling of DirectoryIndexes
when someone is using the passthruUrls feature.

=head3 requestObject

The Apache2::RequestRec object passed in by Apache's mod_perl.

=cut

sub fixupHandler {
	my $r = shift;
	
	if ($r->handler eq 'perl-script' &&  # Handler is Perl
	    -d $r->filename              &&  # Filename requested is a directory
	    $r->is_initial_req)		     # and this is the initial request
	{
	    $r->handler(Apache2::Const::DIR_MAGIC_TYPE);  # Hand off to mod_dir
	    return Apache2::Const::OK;
	}
	return Apache2::Const::DECLINED;  # just pass it on
}

#-------------------------------------------------------------------

=head2 page ( session , [ assetUrl ] )

Processes operations (if any), then tries the requested method on the asset corresponding to the requested URL.  If that asset fails to be created, it tries the default page.

=head3 session

The current WebGUI::Session object.

=head3 assetUrl

Optionally pass in a URL to be loaded.

=cut

sub page {
	my $session = shift;
	my $assetUrl = shift || $session->url->getRequestedUrl;
	my $output = processOperations($session);
	if ($output eq "") {
		my $asset = eval{WebGUI::Asset->newByUrl($session,$assetUrl,$session->form->process("revision"))};
		if ($@) {
			$session->errorHandler->warn("Couldn't instantiate asset for url: ".$assetUrl." Root cause: ".$@);
		}
		if (defined $asset) {
			my $method = "view";
			if ($session->form->process("func")) {
				$method = $session->form->process("func");
				unless ($method =~ /^[A-Za-z]+$/) {
					$session->errorHandler->security("to call a non-existent method $method on $assetUrl");
					$method = "view";
				}
			}
			$output = tryAssetMethod($session,$asset,$method);
			$output = tryAssetMethod($session,$asset,"view") unless ($output || ($method eq "view"));
		}
	}
	if (defined($output) and $output eq "") {
		if ($session->var->isAdminOn) { # they're expecting it to be there, so let's help them add it
			my $asset = WebGUI::Asset->newByUrl($session, $session->url->getRefererUrl) || WebGUI::Asset->getDefault($session);
			$session->http->setRedirect($asset->getUrl("func=add;class=WebGUI::Asset::Wobject::Layout;url=".$assetUrl));
		} else { # not in admin mode, so can't create it,  so display not found
			$session->http->setStatus("404","Page Not Found");
			my $notFound = WebGUI::Asset->getNotFound($session);
			if (defined $notFound) {
				$output = tryAssetMethod($session,$notFound,'view');
			} else {
				$session->errorHandler->error("The notFound page could not be instanciated!");
				$output = "An error was encountered while processing your request.";
			}
			$output = "An error was encountered while processing your request." if $output eq '';
		}
	}
	if ($output eq "chunked") {
		$output = undef;
	}
	if ($session->errorHandler->canShowDebug()) {
		$output .= $session->errorHandler->showDebug();
	}
	return $output;
}


#-------------------------------------------------------------------

=head2 processOperations ( session )

Calls the operation dispatcher using the requested operation.  Currently only handles one operation per request.

=head3 session

The current WebGUI::Session object.

=cut

sub processOperations {
	my $session = shift;
	my $output = "";
	my $op = $session->form->process("op");
#	my $opNumber = shift || 1;
	if ($op) {
		$output = WebGUI::Operation::execute($session,$op);
	}
#	$opNumber++;
#	if ($output eq "" && $session->form->process("op".$opNumber)) {
#		my $urlString = $session->url->unescape($session->form->process("op".$opNumber));
#		my @pairs = split(/\;/,$urlString);
#		my %form;
#		foreach my $pair (@pairs) {
#			my @param = split(/\=/,$pair);
#			$form{$param[0]} = $param[1];
#		}
#		$session{form} = \%form;
#		$output = processOperations($session,$opNumber);
#	}
	return $output;
}


#-------------------------------------------------------------------

=head2 setup ( session )

Handles a specialState: "setup"

=head3 session

The current WebGUI::Session object.

=cut

sub setup {
	my $session = shift;
	require WebGUI::Operation::WebGUI;
	$session->http->getHeader;
	$session->output->print(WebGUI::Operation::WebGUI::www_setup($session));
}


#-------------------------------------------------------------------

=head2 tryAssetMethod ( session )

Tries an asset method on the requested asset.  Tries the "view" method if that method fails.

=head3 session

The current WebGUI::Session object.

=cut

sub tryAssetMethod {
	my $session = shift;
	my $asset = shift;
	my $method = shift;
	$session->asset($asset);
	my $methodToTry = "www_".$method;
	my $output = eval{$asset->$methodToTry()};
	if ($@) {
		$session->errorHandler->warn("Couldn't call method ".$method." on asset for url: ".$session->url->getRequestedUrl." Root cause: ".$@);
		$output = tryAssetMethod($session,$asset,'view') if ($method ne "view");
	}
	return $output;
}

#-------------------------------------------------------------------

=head2 uploadsHandler ( requestObject )

Primary http init/response handler for WebGUI.  

=head3 requestObject

The Apache2::RequestRec object passed in by handler().

=cut

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
				my $session = WebGUI::Session->open($s->dir_config('WebguiRoot'),$r->dir_config('WebguiConfig'),$r, $s);
				my $hasPrivs = ($session->var->get("userId") eq $privs[0] || $session->user->isInGroup($privs[1]) || $session->user->isInGroup($privs[2]));
				$session->close();
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

=head2 upgrading ( session )

Handles a specialState: "upgrading"

=head3 session

The current WebGUI::Session object.

=cut

sub upgrading {
	my $session = shift;
	$session->http->getHeader;
	open(FILE,"<".$session->config->getWebguiRoot."/docs/maintenance.html");
	while (<FILE>) {
		$session->output->print($_);
	}
	close(FILE);
}

1;

