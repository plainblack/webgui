package WebGUI::HTTP;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2004 Plain Black LLC.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut


use strict;
use WebGUI::International;
use WebGUI::Session;

=head1 NAME

Package WebGUI::HTTP

=head1 DESCRIPTION

This package allows the manipulation of HTTP protocol information.

=head1 SYNOPSIS

use WebGUI::HTTP;
 $header = WebGUI::HTTP::getHeader();
 WebGUI::HTTP::setRedirect($url);
 WebGUI::HTTP::setCookie($name,$value);

=head1 METHODS

These subroutines are available from this package:

=cut



#-------------------------------------------------------------------

=head2 getHeader ( ) 

Generates an HTTP header.

=cut

sub getHeader {
	my $header;
	unless (exists $session{http}{location}) {
		unless ($session{http}{charset}) {
			$session{http}{charset} = WebGUI::International::getLanguage($session{page}{languageId},"charset") || "ISO-8859-1";
		}
		unless ($session{http}{mimetype}) {
			$session{http}{mimetype} = "text/html";
		}
		if ($session{setting}{preventProxyCache}) {
       	        	$session{http}{expires} = "-1d";
       	 	}
		$header = $session{cgi}->header( 
			-type => $session{http}{mimetype},
			-charset => $session{http}{charset},
			-cookie => $session{http}{cookie}, 
			-status => $session{http}{status},
			-attachment => $session{http}{filename},
			-expires => $session{http}{expires}
			);
	} else {
		$header = $session{cgi}->header( 
			-cookie => $session{http}{cookie}, 
			-location => $session{http}{location},
			-status => $session{http}{status}
			);
	}
	return $header;
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
	return $session{http}{status} || "200 OK";
}


#-------------------------------------------------------------------

=head2 setCookie ( name, value [ , timeToLive ] ) 

Sends a cookie to the browser.

=over

=item name

The name of the cookie to set. Must be unique from all other cookies from this domain or it will overwrite that cookie.

=item value

The value to set.

=item timeToLive

The time that the cookie should remain in the browser. Defaults to "+10y" (10 years from now).

=back

=cut

sub setCookie {
        my $ttl = $_[2] || '+10y';
	my $domain;
        push @{$session{http}{cookie}}, $session{cgi}->cookie(
                -name=>$_[0],
                -value=>$_[1],
                -expires=>$ttl,
                -path=>'/',
                -domain=>$domain
                );
}


#-------------------------------------------------------------------

=head2 setFilename ( filename [, mimetype] )

Override the default filename for the document, which is usually the page url. Usually used with setMimeType().

=over

=item filename

The filename to set.

=item mimetype

The mimetype for this file. Defaults to "application/octet-stream".

=back

=cut

sub setFilename {
	$session{http}{filename} = shift;
	my $mimetype = shift || "application/octet-stream";
	setMimeType($mimetype);
}



#-------------------------------------------------------------------

=head2 setMimeType ( mimetype )

Override mime type for the document, which is defaultly "text/html". Also see setFilename().

NOTE: By setting the mime type to something other than "text/html" WebGUI will automatically not process the normal page contents. Instead it will return only the content of your Wobject function or Operation.

=over

=item mimetype

The mime type for the document.

=back

=cut

sub setMimeType {
	$session{http}{mimetype} = shift;
}


#-------------------------------------------------------------------

=head2 setRedirect ( url )

Sets the necessary information in the HTTP header to redirect to another URL.

=over

=item url

The URL to redirect to.

=back

=cut

sub setRedirect {
	$session{http}{location} = shift;
	setStatus("302 Redirect");
}


#-------------------------------------------------------------------

=head2 setStatus ( status )

Sets the HTTP status code.

=over

=item status

An HTTP status code. It takes the form of "NNN Message" where NNN is a 3 digit status number and Message is some text explaining the status number.

=back

=cut

sub setStatus {
	$session{http}{status} = shift;
}

1;
