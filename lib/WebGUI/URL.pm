package WebGUI::URL;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2003 Plain Black LLC.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut


use strict;
use URI::Escape;
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
 $url = WebGUI::URL::makeCompliant($string);
 $url = WebGUI::URL::page($url,$pairs);
 $string = WebGUI::URL::unescape($string);
 $url = WebGUI::URL::urlize($string);

=head1 METHODS

These subroutines are available from this package:

=cut



#-------------------------------------------------------------------
sub _getSiteURL {
	my $site;
	if ($session{setting}{hostToUse} eq "sitename") {
		$site = $session{config}{sitename} || $session{env}{HTTP_HOST};
	} else {
		$site = $session{env}{HTTP_HOST} || $session{config}{sitename};
	}
	my $proto = "http://";
	if ($session{env}{SERVER_PORT} == 443) {
		$proto = "https://";
	}
	return $proto.$site;
}

#-------------------------------------------------------------------

=head2 append ( url, pairs ) 

Returns a URL after adding some information to the end of it.

=over

=item url

The URL to append information to.

=item pairs

Name value pairs to add to the URL in the form of:

 name1=value1&name2=value2&name3=value3

=back

=cut

sub append {
	my ($url);
	$url = $_[0];
	if ($url =~ /\?/) {
		$url .= '&amp;'.$_[1];
	} else {
		$url .= '?'.$_[1];
	}
	return $url;
}

#-------------------------------------------------------------------

=head2 escape ( string )

Encodes a string to make it safe to pass in a URL.

NOTE: See WebGUI::URL::unescape()

=over

=item string

The string to escape.

=back

=cut

sub escape {
	return uri_escape($_[0]);
}


#-------------------------------------------------------------------

=head2 gateway ( pageURL [ , pairs ] )

Generate a URL based on WebGUI's gateway script.

=over

=item pageURL

The urlized title of a page that you wish to create a URL for.

=item pairs

Name value pairs to add to the URL in the form of:

 name1=value1&name2=value2&name3=value3

=back

=cut

sub gateway {
        my $url = _getSiteURL().$session{config}{scripturl}.'/'.$_[0];
	if ($_[1]) {
		$url = append($url,$_[1]);
	}
        if ($session{setting}{preventProxyCache} == 1) {
                $url = append($url,"noCache=".randint(0,1000).';'.time());
        }
        return $url;
}

#-------------------------------------------------------------------

=head2 makeCompliant ( string )

Returns a string that has made into a WebGUI compliant URL.

=over

=item string

The string to make compliant. This is usually a page title or a filename.

=back

=cut 

sub makeCompliant {
        my ($value);
	$value = $_[0];
        $value =~ s/\s+$//;            		#removes trailing whitespace
        $value =~ s/^\s+//;            		#removes leading whitespace
	$value =~ s/^\\//;			#removes leading slash
        $value =~ s/ /_/g;              	#replaces whitespace with underscores
        $value =~ s/\.$//;             		#removes trailing period
        $value =~ s/[^A-Za-z0-9\-\.\_\/]//g; 	#removes all funky characters
	$value =~ s/^\///;			#removes a preceeding /
        return $value;
}

#-------------------------------------------------------------------

=head2 page ( [ pairs ] )

Returns the URL of the current page.

=over

=item pairs

Name value pairs to add to the URL in the form of:

 name1=value1&name2=value2&name3=value3

=back

=cut

sub page {
	my $url = _getSiteURL().$session{page}{url};
	if ($_[0]) {
		$url = append($url,$_[0]);
	}
	if ($session{setting}{preventProxyCache} == 1) {
		$url = append($url,"noCache=".randint(0,1000).';'.time());
	}
	return $url;
}

#-------------------------------------------------------------------

=head2 unescape

Decodes a string that was URL encoded.

NOTE: See WebGUI::URL::escape()

=over

=item string

The string to unescape.

=back

=cut

sub unescape {
	return uri_unescape($_[0]);
}

#-------------------------------------------------------------------

=head2 urlize ( string )

Returns a url that is safe for WebGUI pages.

=over

=item string

 The string to urlize.

=back

=cut

sub urlize {
	my ($value);
        $value = lc($_[0]);		#lower cases whole string
	$value = makeCompliant($value);
	$value =~ s/\/$//;
        return $value;
}


1;
