package WebGUI::Session::Http;

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
use Scalar::Util qw( weaken blessed );
use HTTP::Date ();

sub _deprecated {
    my $alt = shift;
    my $method = (caller(1))[3];
    Carp::carp("$method is deprecated. Use 'WebGUI::$alt' instead.");
}

=head1 NAME

Package WebGUI::Session::Http

=head1 DESCRIPTION

This package allows the manipulation of HTTP protocol information.

*** This module is deprecated in favor of L<WebGUI::Session::Request> and
L<WebGUI::Session::Response>.

=head1 SYNOPSIS

 use WebGUI::Session::Http;

 my $http = WebGUI::Session::Http->new($session);

 $http->sendHeader();

 $boolean = $http->isRedirect();
 
 $http->setCookie($name,$value);
 $http->setNoHeader($bool);
 $http->setRedirect($url);

=head1 METHODS

These methods are available from this package:

=cut

#-------------------------------------------------------------------

=head2 new ( session )

Constructor. 

=head3 session

A reference to the current session.

=cut

sub new {
	my $class = shift;
	my $session = shift;
    my $self = bless { _session => $session }, $class;
    weaken $self->{_session};
    return $self;
}

#-------------------------------------------------------------------

=head2 session ( )

Returns the reference to the current session.

=cut

sub session {
	my $self = shift;
	return $self->{_session};
}


#-------------------------------------------------------------------

=head2 getCacheControl  ( ) 

Returns the cache control setting from this object.

=cut

sub getCacheControl {
	my $self = shift;
	return $self->session->response->getCacheControl;
}

#-------------------------------------------------------------------

=head2 getCookies ( )

Retrieves the cookies from the HTTP header and returns a hash reference containing them.

=cut

sub getCookies {
	my $self = shift;
	_deprecated('Session::Request::cookies');
	return $self->session->request->cookies;
}


#-------------------------------------------------------------------

=head2 getLastModified ( ) 

Returns the stored epoch date when the page as last modified.

=cut

sub getLastModified {
	my $self = shift;
	return $self->session->response->getLastModified;
}

#-------------------------------------------------------------------

=head2 getNoHeader ( )

Returns whether or not a HTTP header will be printed.

=cut

sub getNoHeader {
	my $self = shift;
    return $self->session->response->getNoHeader;
}

#-------------------------------------------------------------------

=head2 getStreamedFile ( ) {

Returns the location of a file to be streamed thru mod_perl, if one has been set.

=cut

sub getStreamedFile {
	my $self = shift;
	_deprecated('Session::Response::getStreamedFile');
	return $self->session->response->getStreamedFile;
}


#-------------------------------------------------------------------

=head2 isRedirect ( )

Returns a boolean value indicating whether the current page will redirect to some other location.

=cut

sub isRedirect {
	my $self = shift;
	_deprecated('Session::Response::isRedirect');
    return $self->session->response->isRedirect;
}


#-------------------------------------------------------------------

=head3 sendHeader

Moved to L<WebGUI::Session::Response>.

=cut

sub sendHeader {
	my $self = shift;
	_deprecated('Session::Response::sendHeader');
    $self->session->response->sendHeader(@_);
}


#-------------------------------------------------------------------

=head2 setCacheControl  ( timeout ) 

Sets the cache control headers.

=head3 timeout

Either the number of seconds until the cache expires, or the word "none" to disable cache completely for this request.

=cut

sub setCacheControl {
	my $self = shift;
	_deprecated('Session::Response::setCacheControl');
	$self->session->response->setCacheControl(@_);
}

#-------------------------------------------------------------------

=head2 setCookie ( name, value [ , timeToLive, domain ] ) 

Moved to L<WebGUI::Session::Response>.

sub setCookie {
	my $self = shift;
	_deprecated('Session::Request');
    $self->session->response->setCookie(@_);
}


#-------------------------------------------------------------------

=head2 setLastModified ( epoch ) 

=head3 epoch

The epoch date when the page was last modified.

=cut

sub setLastModified {
	my $self = shift;
	_deprecated('Session::Response::setLastModified');
	$self->session->response->setLastModified(@_);
}

#-------------------------------------------------------------------

=head2 setNoHeader ( boolean )

Disables the printing of a HTTP header. Useful in situations when content is not
returned to a browser (export to disk for example).

=head3 boolean 

Any value other than 0 will disable header printing.

=cut

sub setNoHeader {
	my $self = shift;
	_deprecated('Session::Response::setNoHeader');
    $self->session->response->setNoHeader(@_);
}

#-------------------------------------------------------------------

=head2 setRedirect ( url, [ type ] )

Moved to L<WebGUI::Session::Response>.

=cut

sub setRedirect {
	my $self = shift;
	_deprecated('Session::Response');
    $self->session->response->setRedirect(@_);
}


#-------------------------------------------------------------------

=head2 setStreamedFile ( ) {

Set a file to be streamed thru mod_perl.

=cut

sub setStreamedFile {
	my $self = shift;
	_deprecated('Session::Response');
	$self->session->response->setStreamedFile(@_);
}


1;

