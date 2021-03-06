package WebGUI::Content::Asset;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2012 Plain Black Corporation.
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

=head1 NAME

Package WebGUI::Content::Asset

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
URL are tried, to find an asset that matches.  If it finds an Asset, then it calls the
dispatch method on it.  An Asset's dispatch always returns SOMETHING, so if a matching
asset is found, this is the last stop.

=head3 $session

A WebGUI::Session object.

=head4 $assetUrl

The URL for this request.

=cut

sub dispatch {
    my $session      = shift;
	my $assetUrl     = shift;
    $assetUrl        =~ s{/$}{};
    my $permutations = getUrlPermutations($assetUrl);
    foreach my $url (@{ $permutations }) {
        if (my $asset = getAsset($session, $url)) {
            ##Passive Analytics Logging
            WebGUI::PassiveAnalytics::Logging::log($session, $asset);
            # display from cache if page hasn't been modified.
            if ($session->user->isVisitor
             && !$session->request->ifModifiedSince($asset->getContentLastModified, $session->setting->get('maxCacheTimeout'))) {
                $session->response->status("304");
                $session->response->sendHeader;
                return "chunked";
            } 

            my $fragment = $assetUrl;
            $fragment =~ s/$url//;
            $session->asset($asset);
            my $output = eval { $asset->dispatch($fragment); };
            if( $@ ) {
                my $e = WebGUI::Error->caught('WebGUI::Error');
                if( $session->request->env->{'webgui.debug'} ) {
                    $e->rethrow; 
                } else
                {
                    $session->log->error( "Problem with dispatching $url: " . $e, $e );
                }
            }
            return $output if defined $output;
        }
    }
    $session->clearAsset;
    if ($session->isAdminOn) {
        my $asset = eval { WebGUI::Asset->newByUrl($session, $session->url->getRefererUrl) } || WebGUI::Asset->getDefault($session);
        return $asset->addMissing($assetUrl);
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
	if (Exception::Class->caught()) {
		$session->log->warn("Couldn't instantiate asset for url: ".$assetUrl." Root cause: ".$@);
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
    ##Handle empty urls (sitename only)
    return ['/'] if !$url
                 ||  $url eq '/';
    my @permutations = ();
    if ($url =~ /\.\w+$/) {
        push @permutations, $url;
        $url =~ s/\.\w+$//;
    }
    my @fragments = split /\//, $url;
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
    my ($log, $asset, $request, $config) = $session->quick(qw(errorHandler asset request config));
    my $output = "";
    if (my $perfLog = $log->performanceLogger) { #show performance indicators if required
        my $t = [Time::HiRes::gettimeofday()];
        $output = dispatch($session, getRequestedAssetUrl($session));
        $perfLog->({ time => Time::HiRes::tv_interval($t), type => 'Page' });
    }
    else {
        $output = dispatch($session, getRequestedAssetUrl($session));
    }
    return $output;
}

1;
