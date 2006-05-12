package WebGUI::Session::Http;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2006 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut


use strict;
use Apache2::Cookie;
use APR::Request::Apache2;

=head1 NAME

Package WebGUI::Session::Http

=head1 DESCRIPTION

This package allows the manipulation of HTTP protocol information.

=head1 SYNOPSIS

 use WebGUI::Session::Http;

 my $http = WebGUI::Session::Http->new($session);

 $http->sendHeader();

 $cookies = $http->getCookies();
 $mimetype = $http->getMimeType();
 $code = $http->getStatus();
 $boolean = $http->isRedirect();
 
 $http->setCookie($name,$value);
 $http->setFilename($filename,$mimetype);
 $http->setMimeType($mimetype);
 $http->setNoHeader($bool);
 $http->setRedirect($url);

=head1 METHODS

These methods are available from this package:

=cut

#-------------------------------------------------------------------

=head2 DESTROY ( )

Deconstructor.

=cut

sub DESTROY {
        my $self = shift;
        undef $self;
}



#-------------------------------------------------------------------

=head2 getCookies ( )

Retrieves the cookies from the HTTP header and returns a hash reference containing them.

=cut

sub getCookies {
	my $self = shift;
	if ($self->session->request) {
		my $jarHashRef = APR::Request::Apache2->handle($self->session->request)->jar();
		return $jarHashRef if $jarHashRef;
		return {};
	}
	else {
		return {};
	}
}


#-------------------------------------------------------------------

=head2 getMimeType ( ) 

Returns the current mime type of the document to be returned.

=cut

sub getMimeType {
	my $self = shift;
	return $self->{_http}{mimetype} || "text/html";
}

#-------------------------------------------------------------------

=head2 getStatus ( ) {

Returns the current HTTP status code, if one has been set.

=cut

sub getStatus {
	my $self = shift;
	$self->{_http}{statusDescription} = $self->{_http}{statusDescription} || "OK";
	return $self->{_http}{status} || "200";
}


#-------------------------------------------------------------------

=head2 getStreamedFile ( ) {

Returns the location of a file to be streamed thru mod_perl, if one has been set.

=cut

sub getStreamedFile {
	my $self = shift;
	return $self->{_http}{streamlocation} || undef;
}


#-------------------------------------------------------------------

=head2 isRedirect ( )

Returns a boolean value indicating whether the current page will redirect to some other location.

=cut

sub isRedirect {
	my $self = shift;
	return ($self->getStatus() eq "302");
}


#-------------------------------------------------------------------

=head2 new ( session )

Constructor. 

=head3 session

A reference to the current session.

=cut

sub new {
	my $class = shift;
	my $session = shift;
	bless {_session=>$session}, $class;
}


#-------------------------------------------------------------------

=head2 sendHeader ( ) 

Generates and sends HTTP headers.

=cut

sub sendHeader {
	my $self = shift;
	return undef if ($self->{_http}{noHeader});
	my $request = $self->session->request;
	return undef unless $request;
	$self->{_http}{noHeader} = 1;
	my %params;
	if ($self->isRedirect()) {
		$request->headers_out->set(Location => $self->{_http}{location});
		$request->status(301);
	} else {
		$request->content_type($self->{_http}{mimetype} || "text/html");
		my $date = $self->session->datetime->epochToHuman(($self->{_http}{lastModified} || time()), "%W, %d %C %y %j:%m:%s %t");
		$request->headers_out->set('Last-Modified' => $date);
		if ($self->{_http}{cacheControl} eq "none" || $self->session->setting->get("preventProxyCache") || ($self->{_http}{cacheControl} eq "" && $self->session->var->get("userId") ne "1")) {
			$request->headers_out->set("Cache-Control" => "private");
			$request->no_cache(1);
		} elsif ($self->{_http}{cacheControl} ne "" && $request->protocol =~ /(\d\.\d)/ && $1 >= 1.1){
			my $extras = "";
			$extras .= ", private" unless ($self->session->var->get("userId") eq "1");
    			$request->headers_out->set('Cache-Control' => "max-age=" . $self->{_http}{cacheControl}.$extras);
  		} elsif ($self->{_http}{cacheControl} ne "") {
			$request->headers_out->set("Cache-Control" => "private") unless ($self->session->var->get("userId") eq "1");
			my $date = $self->session->datetime->epochToHuman(time() + $self->{_http}{cacheControl}, "%W, %d %C %y %j:%m:%s %t");
    			$request->headers_out->set('Expires' => $date);
  		}
		if ($self->{_http}{filename}) {
                        $request->headers_out->set('Content-Disposition' => qq!attachment; filename="$self->{_http}{filename}"!);
		}
	}
	$request->status_line($self->getStatus().' '.$self->{_http}{statusDescription});
	return;
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

=head2 setCacheControl  ( timeout ) 

Sets the cache control headers.

=head3 timeout

Either the number of seconds until the cache expires, or the word "none" to disable cache completely for this request.

=cut

sub setCacheControl {
	my $self = shift;
	my $timeout = shift;
	$self->{_http}{cacheControl};
}

#-------------------------------------------------------------------

=head2 setCookie ( name, value [ , timeToLive ] ) 

Sends a cookie to the browser.

=head3 name

The name of the cookie to set. Must be unique from all other cookies from this domain or it will overwrite that cookie.

=head3 value

The value to set.

=head3 timeToLive

The time that the cookie should remain in the browser. Defaults to "+10y" (10 years from now).

=cut

sub setCookie {
	my $self = shift;
	my $name = shift;
	my $value = shift;
	my $ttl = shift;
	$ttl = (defined $ttl ? $ttl : '+10y');
	if ($self->session->request) {
		my $cookie = Apache2::Cookie->new($self->session->request,
			-name=>$name,
			-value=>$value,
			-expires=>$ttl,
			-path=>'/'
		);
		$cookie->bake($self->session->request);
	}
}


#-------------------------------------------------------------------

=head2 setFilename ( filename [, mimetype] )

Override the default filename for the document, which is usually the page url. Usually used with setMimeType().

=head3 filename

The filename to set.

=head3 mimetype

The mimetype for this file. Defaults to "application/octet-stream".

=cut

sub setFilename {
	my $self = shift;
	$self->{_http}{filename} = shift;
	my $mimetype = shift || "application/octet-stream";
	$self->setMimeType($mimetype);
}



#-------------------------------------------------------------------

=head2 setLastModified ( epoch ) 

=cut

sub setLastModified {
	my $self = shift;
	my $epoch = shift;
	$self->{_http}{lastModified} = $epoch;
}

#-------------------------------------------------------------------

=head2 setMimeType ( mimetype )

Override mime type for the document, which is defaultly "text/html". Also see setFilename().

B<NOTE:> By setting the mime type to something other than "text/html" WebGUI will automatically not process the normal page contents. Instead it will return only the content of your Wobject function or Operation.

=head3 mimetype

The mime type for the document.

=cut

sub setMimeType {
	my $self = shift;
	$self->{_http}{mimetype} = shift;
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
        $self->{_http}{noHeader} = shift;
}

#-------------------------------------------------------------------

=head2 setRedirect ( url )

Sets the necessary information in the HTTP header to redirect to another URL.

=head3 url

The URL to redirect to.

=cut

sub setRedirect {
	my $self = shift;
	my $url = shift;
	return undef if ($url eq $self->session->url->page()); # prevent redirecting to self
	$self->{_http}{location} = $url;
	$self->setStatus("302", "Redirect");
	$self->session->style->setMeta({"http-equiv"=>"refresh",content=>"0; URL=".$url});
}


#-------------------------------------------------------------------

=head2 setStatus ( code, description )

Sets the HTTP status code.

=head3 code

An HTTP status code. It is a 3 digit status number.

=head3 description

An HTTP status code description. It is a little one line of text that describes the status code.

=cut

sub setStatus {
	my $self = shift;
	$self->{_http}{status} = shift;
	$self->{_http}{statusDescription} = shift;
}

#-------------------------------------------------------------------

=head2 setStreamedFile ( ) {

Set a file to be streamed thru mod_perl.

=cut

sub setStreamedFile {
	my $self = shift;
	$self->{_http}{streamlocation} = shift;
}


1;

