package WebGUI::Session::Env;

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

=head1 NAME

Package WebGUI::Session::Env

=head1 DESCRIPTION

This package allows you to reference environment variables.

=head1 SYNOPSIS

$env = WebGUI::Session::Env->new;

$value = $env->get('REMOTE_ADDR');

return 'not gonna see it' if $env->requestNotViewed() ;

=head1 METHODS

These methods are available from this package:

=cut


#-------------------------------------------------------------------

=head2 callerIsSearchSite ( )

Returns true if the remote address matches a site which is a known indexer or spider.

=cut

sub callerIsSearchSite {

    my $self = shift;
    my $remoteAddress = $self->getIp;

    return 1 if $remoteAddress =~ /203\.87\.123\.1../    # Blaiz Enterprise Rawgrunt search
             || $remoteAddress =~ /123\.113\.184\.2../   # Unknown Yahoo Robot
             || $remoteAddress == '';

    return 0;

}


#-------------------------------------------------------------------

=head2 clientIsSpider ( )

Returns true is the client/agent is a spider/indexer or some other non-human interface, determined
by checking the user agent against a list of known spiders.

=cut


sub clientIsSpider {

    my $self = shift;
    my $userAgent = $self->get('HTTP_USER_AGENT');

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

=head2 get( varName ) 

Retrieves the current value of an environment variable.

=head3 varName

The name of the variable.

=cut

sub get {
    my $self = shift;
    my $var = shift;
    return $$self->{$var};
}


#-------------------------------------------------------------------

=head2 new ( )

Constructor. Returns an env object.

=cut

sub new {
    my $class = shift;
    my $session = shift;
    my $env;
    if ($session->request) {
        $env = $session->request->env;
    }
    else {
        $env = {};
    }
    return bless \$env, $class;
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

=head2 sslRequest ( )

Returns true if a https request was made.

HTTP_SSLPROXY is set by mod_proxy in the WRE so that WebGUI knows that the original request
was made via SSL.

=cut

sub sslRequest {
    my $self = shift;
    return $self->get('psgi.url_scheme') eq 'https';
}


1;

