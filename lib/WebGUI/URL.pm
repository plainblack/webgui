package WebGUI::URL;

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
use URI;
use URI::Escape;
use WebGUI::International;
use WebGUI::Session;
use WebGUI::Utility;


=head1 NAME

Package WebGUI::URL

=head1 DESCRIPTION

This package provides URL writing functionality. It is important that all WebGUI URLs be written using these methods so that they can contain any extra information that WebGUI needs to add to the URLs in order to function properly.

=head1 SYNOPSIS

 use WebGUI::URL;
 $url = WebGUI::URL::append($url,$pairs);
 $string = WebGUI::URL::escape($string);
 $url = WebGUI::URL::gateway($url,$pairs);
 $url = WebGUI::URL::getSiteURL();
 WebGUI::URL::setSiteURL($url);
 $url = WebGUI::URL::makeCompliant($string);
 $url = WebGUI::URL::makeAbsolute($url);
 $url = WebGUI::URL::page($url,$pairs);
 $string = WebGUI::URL::unescape($string);
 $url = WebGUI::URL::urlize($string);

=head1 METHODS

These subroutines are available from this package:

=cut



#-------------------------------------------------------------------

=head2 append ( url, pairs ) 

Returns a URL after adding some information to the end of it.

=head3 url

The URL to append information to.

=head3 pairs

Name value pairs to add to the URL in the form of:

 name1=value1;name2=value2;name3=value3

=cut

sub append {
	my ($url);
	$url = $_[0];
	if ($url =~ /\?/) {
		$url .= ';'.$_[1];
	} else {
		$url .= '?'.$_[1];
	}
	return $url;
}

#-------------------------------------------------------------------

=head2 escape ( string )

Encodes a string to make it safe to pass in a URL.

B<NOTE:> See WebGUI::URL::unescape()

=head3 string

The string to escape.

=cut

sub escape {
	return uri_escape($_[0]);
}


#-------------------------------------------------------------------

=head2 gateway ( pageURL [ , pairs ] )

Generate a URL based on WebGUI's gateway script.

=head3 pageURL

The urlized title of a page that you wish to create a URL for.

=head3 pairs

Name value pairs to add to the URL in the form of:

 name1=value1;name2=value2;name3=value3

=cut

sub gateway {
	$_[0] =~ s/^\///;
        my $url = '/'.$_[0];
        if ($session{setting}{preventProxyCache} == 1) {
                $url = append($url,"noCache=".randint(0,1000).';'.time());
        }
	if ($_[1]) {
		$url = append($url,$_[1]);
	}
        return $url;
}

#-------------------------------------------------------------------
                                                                                                                             
=head2 makeAbsolute ( url , [ baseURL ] )
                                                                                                                             
Returns an absolute url.
                                                                                                                             
=head3 url
                                                                                                                             
The url to make absolute.
                                                                                                                            
=head3 baseURL

The base URL to use. This defaults to current page url.
 
=cut
                                                                                                                             
sub makeAbsolute {
	my $url = shift;
	my $baseURL = shift || page();
	return URI->new_abs($url,$baseURL);
}

#-------------------------------------------------------------------

=head2 setSiteURL ( )

Sets an alternate site url. 

=cut

sub setSiteURL {
	$session{url}{siteURL} = shift;
}

#-------------------------------------------------------------------

=head2 getSiteURL ( )

Returns a constructed site url. The returned
value can be overridden using the setSiteURL function.

=cut

sub getSiteURL { 
	return $session{url}{siteURL} if (defined $session{url}{siteURL});
        my $site;
        my @sitenames;
        if (ref $session{config}{sitename} eq "ARRAY") {
                @sitenames = @{$session{config}{sitename}};
        } else {
                push(@sitenames,$session{config}{sitename});
        }
        if ($session{setting}{hostToUse} eq "sitename" || !isIn($session{env}{HTTP_HOST},@sitenames)) {
                $site = $session{config}{defaultSitename};
        } else {
                $site = $session{env}{HTTP_HOST} || $session{config}{defaultSitename};
        }
        my $proto = "http://";
        if ($session{env}{HTTPS} eq "on") {
                $proto = "https://";
        }
        return $proto.$site;
}


#-------------------------------------------------------------------

=head2 makeCompliant ( string )

Returns a string that has made into a WebGUI compliant URL based upon the language being submitted.

=head3 string

The string to make compliant. This is usually a page title or a filename.

=cut 

sub makeCompliant {
	my $url = shift;
	return WebGUI::International::makeUrlCompliant($url);
}

#-------------------------------------------------------------------

=head2 page ( [ pairs, useSiteUrl, skipPreventProxyCache ] )

Returns the URL of the current page.

=head3 pairs

Name value pairs to add to the URL in the form of:

 name1=value1;name2=value2;name3=value3

=head3 useSiteUrl

If set to "1" we'll use the full site URL rather than the script (gateway) URL.

=head3 skipPreventProxyCache

If set to "1" we'll skip adding the prevent proxy cache code to the url.

=cut

sub page {
	my $pairs = shift;
        my $useFullUrl = shift;
	my $skipPreventProxyCache = shift;
        my $url;
        if ($useFullUrl) {
                $url = getSiteURL();
        }
        $url .= '/';
	my $pathinfo;
        if ($session{asset}) {
                $pathinfo = $session{asset}->get("url");
        } else {
                $pathinfo = $session{wguri};
                $pathinfo =~ s/^\/(.*)/$1/;
        }
        $url .= $pathinfo;
        if ($session{setting}{preventProxyCache} == 1 && !$skipPreventProxyCache) {
                $url = append($url,"noCache=".randint(0,1000).';'.time());
        }
        if ($pairs) {
                $url = append($url,$pairs);
        }
        return $url;
}

#-------------------------------------------------------------------

=head2 unescape

Decodes a string that was URL encoded.

B<NOTE:> See WebGUI::URL::escape()

=head3 string

The string to unescape.

=cut

sub unescape {
	return uri_unescape($_[0]);
}

#-------------------------------------------------------------------

=head2 urlize ( string )

Returns a url that is safe for WebGUI pages.

=head3 string

 The string to urlize.

=cut

sub urlize {
	my ($value);
        $value = lc($_[0]);		#lower cases whole string
	$value = makeCompliant($value);
	$value =~ s/\/$//;
        return $value;
}


1;
