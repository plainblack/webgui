package WebGUI::Session::Request;
use strict;
use parent qw(Plack::Request);
use WebGUI::Session::Response;

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

=head2 clientIsSpider ( )

Returns true is the client/agent is a spider/indexer or some other non-human interface, determined
by checking the user agent against a list of known spiders.

=cut

sub clientIsSpider {

    my $self = shift;
    my $userAgent = $self->user_agent;

    return 1 if $userAgent eq ''
             || $userAgent =~ m<(^wre\/|      # the WRE wget's http://localhost/ every 2-3 minutes 24 hours a day...
                                 ^morpheus|
                                 libwww|
                                 s[pb]ider|
                                 bot|
                                 robo|
                                 sco[ou]t|
                                 crawl|
                                 miner|
                                 reaper|
                                 finder|
                                 search|
                                 engine|
                                 download|
                                 fetch|
                                 scan|
                                 slurp)>ix;

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


# This is only temporary
sub TRACE { 
    shift->env->{'psgi.errors'}->print(join '', @_, "\n");
}

1;
