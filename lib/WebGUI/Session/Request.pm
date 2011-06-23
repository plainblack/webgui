package WebGUI::Session::Request;
use strict;
use parent qw(Plack::Request);
use WebGUI::Session::Response;
use HTTP::BrowserDetect;

=head1 SYNOPSIS

    my $session = WebGUI::Session->open(...);
    my $request = $session->request;

=head1 DESCRIPTION

WebGUI's PSGI request utility class. Sub-classes L<Plack::Request>.

An instance of this object is created automatically when the L<WebGUI::Session>
is created.

=head1 METHODS

=cut 

#-------------------------------------------------------------------

=head2 browser

Returns a HTTP::BrowserDetect object for the request.

=cut

sub browser {
    my $self = shift;
    return $self->env->{'webgui.browser'} ||= HTTP::BrowserDetect->new($self->user_agent);
}

#-------------------------------------------------------------------

=head2 clientIsSpider ( )

Returns true is the client/agent is a spider/indexer or some other non-human interface, determined
by checking the user agent against a list of known spiders.

=cut

sub clientIsSpider {
    my $self = shift;

    return 1
        if $self->user_agent eq ''
            || $self->user_agent =~ /^wre/
            || $self->browser->robot;
    return 0;

}

#-------------------------------------------------------------------

=head2 callerIsSearchSite ( )

Returns true if the remote address matches a site which is a known indexer or spider.

=cut

sub callerIsSearchSite {

    my $self = shift;
    my $remoteAddress = $self->address;

    return 1 if $remoteAddress =~ /203\.87\.123\.1../    # Blaiz Enterprise Rawgrunt search
             || $remoteAddress =~ /123\.113\.184\.2../   # Unknown Yahoo Robot
             || $remoteAddress == '';

    return 0;

}

#-------------------------------------------------------------------

=head2 ifModifiedSince ( epoch [, maxCacheTimeout] )

Returns 1 if the epoch is greater than the modified date check.

=head3 epoch

The date that the requested content was last modified in epoch format.

=head3 maxCacheTimeout

A modifier to the epoch, that allows us to set a maximum timeout where content will appear to
have changed and a new page request will be allowed to be processed.

=cut

sub ifModifiedSince {
    my $self            = shift;
    my $epoch           = shift;
    my $maxCacheTimeout = shift;
    my $modified        = $self->header('If-Modified-Since');
    return 1 if ($modified eq "");
    $modified = HTTP::Date::str2time($modified);
    ##Implement a step function that increments the epoch time in integer multiples of
    ##the maximum cache time.  Used to handle the case where layouts containing macros
    ##(like assetproxied Navigations) can be periodically updated.
    if ($maxCacheTimeout) {
        my $delta = time() - $epoch;
        $epoch   += $delta - ($delta % $maxCacheTimeout);
    }
    return ($epoch > $modified);
}

#-------------------------------------------------------------------

=head2 new_response ()

Creates a new L<WebGUI::Session::Response> object.

N.B. A L<WebGUI::Session::Response> object is automatically created when L<WebGUI::Session> 
is instantiated, so in most cases you will not need to call this method.
See L<WebGUI::Session/response>

=cut

sub new_response {
    my $self = shift;
    return WebGUI::Session::Response->new(@_);
}

#-------------------------------------------------------------------

=head2 requestNotViewed ( )

Returns true is the client/agent is a spider/indexer or some other non-human interface

=cut

sub requestNotViewed {

    my $self = shift;
    return $self->clientIsSpider();
        # || $self->callerIsSearchSite();   # this part is currently left out because
                                            # it has minimal effect and does not manage
                                            # IPv6 addresses.  it may be useful in the 
                                            # future though

}

#-------------------------------------------------------------------

=head2 secure ( )

Returns true if this is a secure connection. The connection is secure if it's 
https or if SSLPROXY is true

=cut

sub secure {
    my ( $self ) = @_;
    if ( $self->header('SSLPROXY') ) {
        return 1;
    }
    return $self->SUPER::secure;
}

# This is only temporary
sub TRACE { 
    shift->env->{'psgi.errors'}->print(join '', @_, "\n");
}

1;
