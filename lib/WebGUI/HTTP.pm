package WebGUI::HTTP;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2005 Plain Black Corporation.
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
use WebGUI::Session;
use WebGUI::Style;

=head1 NAME

Package WebGUI::HTTP

=head1 DESCRIPTION

This package allows the manipulation of HTTP protocol information.

=head1 SYNOPSIS

 use WebGUI::HTTP;

 $cookies = WebGUI::HTTP::getCookies();
 $header = WebGUI::HTTP::getHeader();
 $mimetype = WebGUI::HTTP::getMimeType();
 $code = WebGUI::HTTP::getStatus();
 $boolean = WebGUI::HTTP::isRedirect();
 
 WebGUI::HTTP::setCookie($name,$value);
 WebGUI::HTTP::setFilename($filename,$mimetype);
 WebGUI::HTTP::setMimeType($mimetype);
 WebGUI::HTTP::setNoHeader($bool);
 WebGUI::HTTP::setRedirect($url);

=head1 METHODS

These subroutines are available from this package:

=cut



#-------------------------------------------------------------------

=head2 getCookies ( )

Retrieves the cookies from the HTTP header, persists them to the session, and returns a hash reference containing them.

=cut

sub getCookies {
	$WebGUI::Session::session{cookie} = APR::Request::Apache2->handle($session{req})->jar();
	return $WebGUI::Session::session{cookie};
}


#-------------------------------------------------------------------

=head2 getHeader ( ) 

Generates an HTTP header.

=cut

sub getHeader {
	return undef if ($session{http}{noHeader});	
	my %params;
	if (isRedirect()) {
		$session{req}->headers_out->set(Location => $session{http}{location});
		$session{req}->status(301);
	} else {
		$session{req}->content_type($session{http}{mimetype} || "text/html");
		if ($session{setting}{preventProxyCache}) {
       	        	$params{"-expires"} = "-1d";
       	 	}
		if ($session{http}{filename}) {
			$params{"-attachment"} = $session{http}{filename};
		}
	}
	$params{"-cookie"} = $session{http}{cookie};
	my $status = getStatus();
        # $session{req}->custom_response($status, '<!-- '.$session{http}{statusDescription}.' -->' );
        $session{req}->status($status);
	return;
}


#-------------------------------------------------------------------

=head2 getMimeType ( ) 

Returns the current mime type of the document to be returned.

=cut

sub getMimeType {
	return $session{http}{mimetype} || "text/html";
}


#-------------------------------------------------------------------

=head2 getStatus ( ) {

Returns the current HTTP status code, if one has been set.

=cut

sub getStatus {
	return $session{http}{status} || "200";
}


#-------------------------------------------------------------------

=head2 isRedirect ( )

Returns a boolean value indicating whether the current page will redirect to some other location.

=cut

sub isRedirect {
	return (getStatus() eq "302");
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
	my $name = shift;
	my $value = shift;
        my $ttl = shift;
        $ttl = (defined $ttl ? $ttl : '+10y');
	if (exists $session{req}) {
		my $cookie = Apache2::Cookie->new($session{req},
							-name=>$name,
							-value=>$value,
							-expires=>$ttl,
							-path=>'/'
						);
		$cookie->bake($session{req});
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
	$session{http}{filename} = shift;
	my $mimetype = shift || "application/octet-stream";
	setMimeType($mimetype);
}



#-------------------------------------------------------------------

=head2 setMimeType ( mimetype )

Override mime type for the document, which is defaultly "text/html". Also see setFilename().

B<NOTE:> By setting the mime type to something other than "text/html" WebGUI will automatically not process the normal page contents. Instead it will return only the content of your Wobject function or Operation.

=head3 mimetype

The mime type for the document.

=cut

sub setMimeType {
	$session{http}{mimetype} = shift;
}

#-------------------------------------------------------------------

=head2 setNoHeader ( boolean )

Disables the printing of a HTTP header. Useful in situations when content is not
returned to a browser (export to disk for example).

=head3 boolean 

Any value other than 0 will disable header printing.

=cut

sub setNoHeader {
        $session{http}{noHeader} = shift;
}

#-------------------------------------------------------------------

=head2 setRedirect ( url )

Sets the necessary information in the HTTP header to redirect to another URL.

=head3 url

The URL to redirect to.

=cut

sub setRedirect {
	$session{http}{location} = shift;
	setStatus("302", "Redirect");
	WebGUI::Style::setMeta({"http-equiv"=>"refresh",content=>"0; URL=".$session{http}{location}});
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
	$session{http}{status} = shift;
	$session{http}{statusDescription} = shift;
}

1;
