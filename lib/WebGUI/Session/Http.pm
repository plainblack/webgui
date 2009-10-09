package WebGUI::Session::Http;

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
use WebGUI::Utility;

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
 ($code, $description) = $http->getStatus();
 $description = $http->getStatusDescription();
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

=head2 getCacheControl  ( ) 

Returns the cache control setting from this object.

=cut

sub getCacheControl {
	my $self = shift;
	return $self->{_http}{cacheControl} || 1;
}

#-------------------------------------------------------------------

=head2 getCookies ( )

Retrieves the cookies from the HTTP header and returns a hash reference containing them.

=cut

sub getCookies {
	my $self = shift;
	if ($self->session->request) {
	    if ($self->session->request->isa('WebGUI::Session::Plack')) {
	        return $self->session->request->request->cookies;
	    }
	    
		# Have to require this instead of using it otherwise it causes problems for command-line scripts on some platforms (namely Windows)
		require APR::Request::Apache2;
		my $jarHashRef = APR::Request::Apache2->handle($self->session->request)->jar();
		return $jarHashRef if $jarHashRef;
		return {};
	}
	else {
		return {};
	}
}


#-------------------------------------------------------------------

=head2 getLastModified ( ) 

Returns the stored epoch date when the page as last modified.

=cut

sub getLastModified {
	my $self = shift;
	return $self->{_http}{lastModified};
}

#-------------------------------------------------------------------

=head2 getMimeType ( ) 

Returns the current mime type of the document to be returned.

=cut

sub getMimeType {
	my $self = shift;
	return $self->{_http}{mimetype} || "text/html; charset=UTF-8";
}

#-------------------------------------------------------------------

=head2 getNoHeader ( )

Returns whether or not a HTTP header will be printed.

=cut

sub getNoHeader {
	my $self = shift;
        return $self->{_http}{noHeader};
}

#-------------------------------------------------------------------

=head2 getRedirectLocation ( )

Return the location that was set via setRedirect

=cut

sub getRedirectLocation {
	my $self = shift;
	return $self->{_http}{location};
}


#-------------------------------------------------------------------

=head2 getStatus ( ) {

Returns the current HTTP status code.  If no code has been set,
the code returned will be 200.

=cut

sub getStatus {
	my $self = shift;
	$self->{_http}{statusDescription} = $self->{_http}{statusDescription} || "OK";
	my $status = $self->{_http}{status} || "200";
	return $status;
}


#-------------------------------------------------------------------

=head2 getStatusDescription ( ) {

Returns the current HTTP status description.  If no description has
been set, "OK" will be returned.

=cut

sub getStatusDescription {
	my $self = shift;
	return $self->{_http}{statusDescription} || "OK";
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

=head2 ifModifiedSince ( epoch )

Returns 1 if the epoch is greater than the modified date check.

=cut

sub ifModifiedSince {
    my $self = shift;
    my $epoch = shift;
    require APR::Date;
    my $modified = $self->session->request->headers_in->{'If-Modified-Since'};
    return 1 if ($modified eq "");
    $modified = APR::Date::parse_http($modified);
    return ($epoch > $modified);
}

#-------------------------------------------------------------------

=head2 isRedirect ( )

Returns a boolean value indicating whether the current page will redirect to some other location.

=cut

sub isRedirect {
	my $self = shift;
	return isIn($self->getStatus(), qw(302 301));
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

Generates and sends HTTP headers for a response.

=cut

sub sendHeader {
	my $self = shift;
	return undef if ($self->{_http}{noHeader});
	return $self->_sendMinimalHeader unless defined $self->session->db(1);

	my ($request, $datetime, $config, $var) = $self->session->quick(qw(request datetime config var));
	return undef unless $request;
	my $userId = $var->get("userId");
	
	# send webgui session cookie
	my $cookieName = $config->getCookieName;
	$self->setCookie($cookieName,$var->getId, $config->getCookieTTL, $config->get("cookieDomain")) unless $var->getId eq $self->getCookies->{$cookieName};

	$self->setNoHeader(1);
	my %params;
	if ($self->isRedirect()) {
		$request->headers_out->set(Location => $self->getRedirectLocation);
		$request->status($self->getStatus);
	} else {
		$request->content_type($self->getMimeType);
		my $cacheControl = $self->getCacheControl;
		my $date = ($userId eq "1") ? $datetime->epochToHttp($self->getLastModified) : $datetime->epochToHttp;
		# under these circumstances, don't allow caching
		if ($userId ne "1" ||  $cacheControl eq "none" || $self->session->setting->get("preventProxyCache")) {
			$request->headers_out->set("Cache-Control" => "private, max-age=1");
			$request->no_cache(1);
		} 
		# in all other cases, set cache, but tell it to ask us every time so we don't mess with recently logged in users
		else {
			$request->headers_out->set('Last-Modified' => $date);
  			$request->headers_out->set('Cache-Control' => "must-revalidate, max-age=" . $cacheControl);
			# do an extra incantation if the HTTP protocol is really old
			if ($request->protocol =~ /(\d\.\d)/ && $1 < 1.1) {
				my $date = $datetime->epochToHttp(time() + $cacheControl);
  				$request->headers_out->set('Expires' => $date);
			}
  		}
		if ($self->getFilename) {
                        $request->headers_out->set('Content-Disposition' => qq{attachment; filename="}.$self->getFilename().'"');
		}
		$request->status($self->getStatus());
		$request->status_line($self->getStatus().' '.$self->getStatusDescription());
	}
	return undef;
}

sub _sendMinimalHeader {
	my $self = shift;
	my $request = $self->session->request;
	$request->content_type('text/html; charset=UTF-8');
	$request->headers_out->set('Cache-Control' => 'private');
	$request->no_cache(1);
	$request->status($self->getStatus());
	$request->status_line($self->getStatus().' '.$self->getStatusDescription());
	return undef;
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
	$self->{_http}{cacheControl} = $timeout;
}

#-------------------------------------------------------------------

=head2 setCookie ( name, value [ , timeToLive, domain ] ) 

Sends a cookie to the browser.

=head3 name

The name of the cookie to set. Must be unique from all other cookies from this domain or it will overwrite that cookie.

=head3 value

The value to set.

=head3 timeToLive

The time that the cookie should remain in the browser. Defaults to "+10y" (10 years from now).
This may be "session" to indicate that the cookie is for the current browser session only.

=head3 domain

Explicitly set the domain for this cookie.

=cut

sub setCookie {
	my $self = shift;
	my $name = shift;
	my $value = shift;
	my $ttl = shift;
	my $domain = shift;
	$ttl = (defined $ttl ? $ttl : '+10y');

	if ($self->session->request) {
		require Apache2::Cookie;
		my $cookie = Apache2::Cookie->new($self->session->request,
			-name=>$name,
			-value=>$value,
			-path=>'/'
		);

		$cookie->expires($ttl) if $ttl ne 'session';
		$cookie->domain($domain) if ($domain);
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

=head2 getFilename ( )

Returns the default filename for the document.

=cut

sub getFilename {
	my $self = shift;
	return $self->{_http}{filename};
}



#-------------------------------------------------------------------

=head2 setLastModified ( epoch ) 

=head3 epoch

The epoch date when the page was last modified.

=cut

sub setLastModified {
	my $self = shift;
	my $epoch = shift;
	$self->{_http}{lastModified} = $epoch;
}

#-------------------------------------------------------------------

=head2 setMimeType ( mimetype )

Override mime type for the document, which is defaultly "text/html; charset=UTF-8". Also see setFilename().

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

=head2 setRedirect ( url, [ type ] )

Sets the necessary information in the HTTP header to redirect to another URL.

=head3 url

The URL to redirect to.  To prevent infinite loops, no redirect will be set if
url is the same as the current page, as found through $session->url->page.

=head3 type

Defaults to 302 (temporary redirect), but you can optionally set 301 (permanent redirect).

=cut

sub setRedirect {
	my $self = shift;
	my $url = shift;
    my $type = shift || 302;
	my @params = $self->session->form->param;
	return undef if ($url eq $self->session->url->page() && scalar(@params) < 1); # prevent redirecting to self
	$self->session->errorHandler->info("Redirecting to $url");
	$self->setRedirectLocation($url);
	$self->setStatus($type, "Redirect");
	$self->session->style->setMeta({"http-equiv"=>"refresh",content=>"0; URL=".$url});
}


#-------------------------------------------------------------------

=head2 setRedirectLocation ( url )

Sets the HTTP redirect URL.

=cut

sub setRedirectLocation {
	my $self = shift;
	$self->{_http}{location} = shift;
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

