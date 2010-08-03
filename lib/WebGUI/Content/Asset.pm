package WebGUI::Content::Asset;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2009 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use LWP::MediaTypes qw(guess_media_type);
use Time::HiRes;
use WebGUI::Asset;
use WebGUI::PassiveAnalytics::Logging;
use URI;

use Apache2::Const -compile => qw(OK);

=head1 NAME

Package WebGUI::Content::MyHandler

=head1 DESCRIPTION

A content handler that serves up assets.

=head1 SYNOPSIS

 use WebGUI::Content::Asset;
 my $output = WebGUI::Content::Asset::handler($session);

=head1 SUBROUTINES

These subroutines are available from this package:

=cut

#-------------------------------------------------------------------

=head2 dispatch ( $session, $assetUrl )

Attempts to return the output from an asset, based on its url.  All permutations of the
URL are tried, to find an asset that matches.

=head3 $session

A WebGUI::Session object.

=head4 $assetUrl

The URL for this request.

=cut

sub dispatch {
    my $session      = shift;
	my $assetUrl     = shift;
    return undef unless $assetUrl;
    my $permutations = getUrlPermutations($assetUrl);
    foreach my $url (@{ $permutations }) {
        if (my $asset = getAsset($session, $url)) {
            # display from cache if page hasn't been modified.
            if ($session->user->isVisitor
             && !$session->http->ifModifiedSince($asset->getContentLastModified, $session->setting->get('maxCacheTimeout'))) {
                $session->http->setStatus("304","Content Not Modified");
                $session->http->sendHeader;
                $session->close;
                return "chunked";
            } 

            my $fragment = $assetUrl;
            $fragment =~ s/$url//;
            my $output = eval { $asset->dispatch($fragment); };
            if ($@) {
                $session->errorHandler->warn("Couldn't call method ".$method." on asset for url: ".$session->url->getRequestedUrl." Root cause: ".$@);
                if ($method ne "view") {
                    $output = tryAssetMethod($session,$asset,'view');
                } else {
                    # fatals return chunked
                    $output = 'chunked';
                }
            }
            return $output if defined $output;
        }
    }
    return undef;
}

#-------------------------------------------------------------------

=head2 getAsset ( session [, assetUrl ] )

Returns an asset based upon the requested asset URL, or optionally pass one in.

=cut

sub getAsset {
    my $session = shift;
	my $assetUrl = shift;
	my $asset = eval{WebGUI::Asset->newByUrl($session,$assetUrl,$session->form->process("revision"))};
	if ($@) {
		$session->errorHandler->warn("Couldn't instantiate asset for url: ".$assetUrl." Root cause: ".$@);
	}
    return $asset;
}

#-------------------------------------------------------------------

=head2 getRequestedAssetUrl ( session [, assetUrl ] )

Returns an asset based upon the requested asset URL, or optionally pass one in.

=cut

sub getRequestedAssetUrl {
    my $session = shift;
	my $assetUrl = shift || $session->url->getRequestedUrl;
    return $assetUrl;
}

#-------------------------------------------------------------------

=head2 getUrlPermutations ( $url )

Returns an array reference of permutations for the URL.

=head3 $url

The URL to permute.

=cut

sub getUrlPermutations {
    my $url          = shift;
    my @permutations = ();
    return \@permutations if !$url;
    if ($url =~ /\.\w+$/) {
        push @permutations, $url;
        $url =~ s/\.\w+$//;
    }
    my $uri       = URI->new($url);
    my @fragments = $uri->path_segments();
    FRAG: while (@fragments) {
        last FRAG if $fragments[-1] eq '';
        push @permutations, join "/", @fragments;
        pop @fragments;
    }
    return \@permutations;
}

#-------------------------------------------------------------------

=head2 handler ( session ) 

The content handler for this package.

=cut

sub handler {
    my ($session) = @_;
    my ($errorHandler, $http, $var, $asset, $request, $config) = $session->quick(qw(errorHandler http var asset request config));
    my $output = "";
    if ($errorHandler->canShowPerformanceIndicators) { #show performance indicators if required
        my $t = [Time::HiRes::gettimeofday()];
        $output = page($session);
        $t = Time::HiRes::tv_interval($t) ;
        if ($output =~ /<\/title>/) {
            $output =~ s/<\/title>/ : ${t} seconds<\/title>/i;
        } 
        else {
            # Kludge.
            my $mimeType = $http->getMimeType();
            if ($mimeType eq 'text/css') {
                $session->output->print("\n/* Page generated in $t seconds. */\n");
            } 
            elsif ($mimeType =~ m{text/html}) {
                $session->output->print("\nPage generated in $t seconds.\n");
            } 
            else {
                # Don't apply to content when we don't know how
                # to modify it semi-safely.
            }
        }
    } 
    else {

        my $asset = getAsset($session, getRequestedAssetUrl($session));

        # display from cache if page hasn't been modified.
        if ($var->get("userId") eq "1"
         && defined $asset
         && !$http->ifModifiedSince($asset->getContentLastModified, $session->setting->get('maxCacheTimeout'))) {
            $http->setStatus("304","Content Not Modified");
            $http->sendHeader;
            $session->close;
            return "chunked";
        } 

        # return the page.
        else {					
            $output = page($session, undef, $asset);
        }
    }

    my $filename = $http->getStreamedFile();
    if ((defined $filename) && ($config->get("enableStreamingUploads") eq "1")) {
        my $ct = guess_media_type($filename);
        my $oldContentType = $request->content_type($ct);
        if ($request->sendfile($filename) ) {
            $session->close;
            return Apache2::Const::OK;
        } 
        else {
            $request->content_type($oldContentType);
        }
    }

    return $output;
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
	my $assetUrl = getRequestedAssetUrl($session, shift);
	my $asset = shift || getAsset($session, $assetUrl);
	my $output = undef;
	if (defined $asset) {
		my $method = "view";
		if ($session->form->param("func")) {
			$method = $session->form->param("func");
			unless ($method =~ /^[A-Za-z0-9]+$/) {
				$session->errorHandler->security("to call a non-existent method $method on $assetUrl");
				$method = "view";
			}
		}
        ##Passive Analytics Logging
        WebGUI::PassiveAnalytics::Logging::log($session, $asset);

		$output = tryAssetMethod($session,$asset,$method);
		$output = tryAssetMethod($session,$asset,"view") unless ($output || ($method eq "view"));
	}
	if ($output eq "") {
		if ($session->var->isAdminOn) { # they're expecting it to be there, so let's help them add it
			my $asset = WebGUI::Asset->newByUrl($session, $session->url->getRefererUrl) || WebGUI::Asset->getDefault($session);
			$output = $asset->addMissing($assetUrl);
		}
	}
	return $output;
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
	my $state = $asset->get("state");
	return undef if ($state ne "published" && $state ne "archived" && !$session->var->isAdminOn); # can't interact with an asset if it's not published
	$session->asset($asset);
	my $methodToTry = "www_".$method;
	my $output = eval{$asset->$methodToTry()};
    if (my $e = Exception::Class->caught('WebGUI::Error::ObjectNotFound::Template')) {
        $session->errorHandler->error(sprintf "%s templateId: %s assetId: %s", $e->error, $e->templateId, $e->assetId);
    }
	elsif ($@) {
		$session->errorHandler->warn("Couldn't call method ".$method." on asset for url: ".$session->url->getRequestedUrl." Root cause: ".$@);
		if ($method ne "view") {
			$output = tryAssetMethod($session,$asset,'view');
		} else {
			# fatals return chunked
			$output = 'chunked';
		}
	}
	return $output;
}

1;

