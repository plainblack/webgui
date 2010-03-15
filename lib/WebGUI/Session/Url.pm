package WebGUI::Session::Url;

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
use URI;
use URI::Escape;
use WebGUI::International;
use WebGUI::Utility;


=head1 NAME

Package WebGUI::Session::Url

=head1 DESCRIPTION

This package provides URL writing functionality. It is important that all WebGUI URLs be written using these methods so that they can contain any extra information that WebGUI needs to add to the URLs in order to function properly.

=head1 SYNOPSIS

 use WebGUI::Session::Url;

 $url = WebGUI::Session::Url->new($session);

 $string = $url->append($base, $pairs);
 $string = $url->escape($string);
 $string = $url->extras($path);
 $string = $url->gateway($pageUrl, $pairs);
 $string = $url->getRequestedUrl;
 $string = $url->getSiteURL;
 $string = $url->makeCompliant($string);
 $string = $url->makeAbsolute($string);
 $string = $url->page($pairs);
 $string = $url->unescape($string);
 $string = $url->urlize($string);

 $url->setSiteURL($string);

=head1 METHODS

These subroutines are available from this package:

=cut



#-------------------------------------------------------------------

=head2 append ( url, pairs )

Returns a URL after adding form parameters to the end of it.  This will always
use the correct character for appending form parameters, so it can safely
be called several times.  If no parameters exist in the string, it will append
with '?'.  Otherwise, it uses a semicolon.

=head3 url

The URL to append information to.

=head3 pairs

Name value pairs, as a single string, to add to the end of the URL

    name1=value1;name2=value2;name3=value3
 or name1=value1
 or name1=value1;name2=value2

=cut

sub append {
	my $self = shift;
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

=head2 DESTROY ( )

Deconstructor.

=cut

sub DESTROY {
        my $self = shift;
        undef $self;
}


#-------------------------------------------------------------------

=head2 escape ( string )

Encodes a string to make it safe to pass in a URL.

B<NOTE:> See $self->session->url->unescape()

=head3 string

The string to escape.

=cut

sub escape {
	my $self = shift;
	return URI::Escape::uri_escape_utf8(shift);
}


#-------------------------------------------------------------------

=head2 extras ( path )

Combines the base extrasURL defined in the config file with a specified path.

=head3 path

The path to the thing in the extras folder that you're
referencing. Note that the leading / is not necessary.  Multiple
consecutive slashes in the path part of the URL will be replaced with a single slash.

=cut

sub extras {
    my $self   = shift;
    my $path   = shift;
    my $url    = $self->session->config->get("extrasURL");
    my $cdnCfg = $self->session->config->get('cdn');
    if ( $cdnCfg and $cdnCfg->{'enabled'} and $cdnCfg->{'extrasCdn'} ) {
        unless ( $path and grep $path =~ m/$_/, @{ $cdnCfg->{'extrasExclude'} } ) {
            if ($cdnCfg->{'extrasSsl'} && $self->session->env->sslRequest) {
                $url = $cdnCfg->{'extrasSsl'};
            }
            else {
                $url = $cdnCfg->{'extrasCdn'};
            }
        }    # if excluded, stick with regular extrasURL
    }
    $url .= '/' . $path;
    $url =~ s$(?<!:)/{2,}$/$g;    ##Remove //, unless it's after a :, which can't be a valid URL character
    return $url;
} ## end sub extras

#-------------------------------------------------------------------

=head2 gateway ( pageURL [ , pairs ] )

Generate a URL based on WebGUI's location directive.

=head3 pageURL

The url of an asset that you wish to create a fully qualified URL for.

=head3 pairs

Name value pairs to add to the URL in the form of:

 name1=value1;name2=value2;name3=value3

=head3 skipPreventProxyCache

If preventing proxy caching is enabled in the settings, then if
skipPreventProxyCache is a 1 will override that and prevent the
noCache param from being added to the URL.

=cut

sub gateway {
	my $self = shift;
	my $pageUrl = shift;
	my $pairs = shift;
	my $skipPreventProxyCache = shift;
        my $url = $self->session->config->get("gateway").'/'.$pageUrl;
	$url =~ s/\/+/\//g;
        if ($self->session->setting->get("preventProxyCache") == 1 and !$skipPreventProxyCache) {
                $url = $self->append($url,"noCache=".randint(0,1000).':'.$self->session->datetime->time());
        }
	if ($pairs) {
		$url = $self->append($url,$pairs);
	}
        return $url;
}

#-------------------------------------------------------------------

=head2 getBackToSiteURL ( )

Tries to return a URL to take the user back to the last page they were at before
using an operation or other function.  This will always include the gateway
url from the config file.

=cut

sub getBackToSiteURL {
    my $self = shift;
    my $url;
	if (defined $self->session->asset) {
		my $importNode = WebGUI::Asset->getImportNode($self->session);
		my $importNodeLineage = $importNode->get("lineage");
		my $media = WebGUI::Asset->getMedia($self->session);
		my $mediaLineage = $media->get("lineage");
		my $assetLineage = $self->session->asset->get("lineage");
		if ( $assetLineage =~ /^$importNodeLineage/
          || $assetLineage eq "000001"
          || $assetLineage =~ /^$mediaLineage/
          || $self->session->asset->get("state") ne "published" ##Parent state is okay be definition
        ) {
			$url = WebGUI::Asset->getDefault($self->session)->getUrl;
		}
        else {
            my $container = $self->session->asset->getContainer;
            ##Container may be under a different version tag if this asset has been moved.
            if (defined $container) {
                $url = $container->getUrl;
            }
            else {
                $url = $self->session->url->page();
            }
		}
	} else {
		$url = $self->session->url->page();
	}
    return $url;
}


#-------------------------------------------------------------------

=head2 getRefererUrl ( )

Returns the URL of the page this request was refered from (no gateway, no query params, just the page url). Returns undef if there was no referer.

=cut

sub getRefererUrl {
	my $self = shift;
	my $referer = $self->session->env->get("HTTP_REFERER");
	return undef unless ($referer);
	my $url = $referer;
	my $gateway = $self->session->config->get("gateway");
	$url =~ s{https?://[A-Za-z0-9\.-]+$gateway/*([^?]*)\??.*$}{$1};
	if ($url eq $referer) { ##s/// failed
		return undef;
	} else {
		return $url;
	}
}

#-------------------------------------------------------------------

=head2 forceSecureConnection( url )

Attempts to create an SSL connection with the current or passed in url.  Returns 1
if it was forced to use SSL.  Returns 0 if it wasn't.

When this method returns 1, the calling method should return the 'redirect' flag.

=head3 url

The optional url that the page should forward to as an SSL connection.  If the URL
is not passed in, it will attempt to get one from the L<page> method, or finally from %ENV.

=cut

sub forceSecureConnection {
    my $self = shift;
    my $url = shift;
    my ($conf, $env, $http) = $self->session->quick(qw(config env http));
   
    if ($conf->get("sslEnabled") && !$env->sslRequest){
   
        $url = $self->session->url->page if(! $url);
        $url = $env->get('QUERY_STRING') if(! $url);

        my $siteURL = $self->getSiteURL();

        if($url !~ /^$siteURL/i){
            $url = $siteURL . $url;
        }
        if($env->get('QUERY_STRING')){ 
            $url .= "?". $env->get('QUERY_STRING');
        }
        if($url =~ /^http/i) {
            $url =~ s/^https?/https/i;
            $http->setRedirect($url);
            return 1;
        }
    } 
    return 0;
}


#-------------------------------------------------------------------

=head2 getRequestedUrl ( )

Returns the URL of the page requested (no gateway, no query params, just the page url).

=cut

sub getRequestedUrl {
	my $self = shift;
	return undef unless ($self->session->request);
	unless ($self->{_requestedUrl}) {
		$self->{_requestedUrl} = $self->session->request->path_info; # TODO - is path_info right?
		my $gateway = $self->session->config->get("gateway");
		$self->{_requestedUrl} =~ s/^$gateway([^?]*)\??.*$/$1/;
	}
	return $self->{_requestedUrl};
}


#-------------------------------------------------------------------

=head2 getSiteURL ( )

Returns a constructed site url. The returned value can be overridden using the setSiteURL function.

=cut

sub getSiteURL {
    my $self = shift;
    unless ($self->{_siteUrl}) {
        my $site = "";
        my $sitenames = $self->session->config->get("sitename");
        my ($http_host,$currentPort) = split(':', $self->session->env->get("HTTP_HOST"));
        if ($self->session->setting->get("hostToUse") eq "HTTP_HOST" and isIn($http_host,@{$sitenames})) {
                $site = $http_host;
        } else {
                $site = $sitenames->[0];
        }
        my $proto = "http://";
        if ($self->session->env->sslRequest) {
                $proto = "https://";
        }
		my $port = "";
        $port = ":".$self->session->config->get("webServerPort") if ($self->session->config->get("webServerPort"));
        $self->{_siteUrl} = $proto.$site.$port;
    }
    return $self->{_siteUrl};
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
	my $self = shift;
	my $url = shift;
	my $baseURL = shift;
	$baseURL = $self->page() unless $baseURL;
	return URI->new_abs($url,$baseURL);
}

#-------------------------------------------------------------------

=head2 makeCompliant ( string )

Returns a string that has made into a WebGUI compliant URL based upon the language being submitted.

=head3 string

The string to make compliant. This is usually a page title or a filename.

=cut

sub makeCompliant {
	my $self = shift;
	my $url = shift;
	my $i18n = WebGUI::International->new($self->session);
	return $i18n->makeUrlCompliant($url);
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

=head2 page ( [ pairs, useSiteUrl, skipPreventProxyCache ] )

Returns the URL of the current page, including the configured site gateway.

=head3 pairs

Name and value pairs as a string to add to the URL that will be returned.

 name1=value1;name2=value2;name3=value3

=head3 useSiteUrl

If set to "1" we'll use the full site URL rather than the script (gateway) URL.

=head3 skipPreventProxyCache

If preventing proxy caching is enabled in the settings, then if
skipPreventProxyCache is a 1 it will prevent the code that prevents
proxy caching from being added.  If that doesn't make your head hurt
then you'll understand the rest of wG just fine.

=cut

sub page {
    my $self = shift;
    my $pairs = shift;
    my $useFullUrl = shift;
    my $skipPreventProxyCache = shift;
    my $url;
    if ($useFullUrl) {
        $url = $self->getSiteURL();
    }
    my $path = $self->session->asset ? $self->session->asset->get("url") : URI::Escape::uri_escape_utf8($self->getRequestedUrl, "^A-Za-z0-9\-_.!~*'()/");
    $url .= $self->gateway($path, $pairs, $skipPreventProxyCache);
    return $url;
}

#-------------------------------------------------------------------

=head2 session ( )

Returns a reference to the current session.

=cut

sub session {
	my $self = shift;
	return $self->{_session};
}


#-------------------------------------------------------------------

=head2 setSiteURL ( )

Sets an alternate site url for this session variable.

=cut

sub setSiteURL {
	my $self = shift;
	$self->{_siteUrl} = shift;
}

#-------------------------------------------------------------------

=head2 unescape

Decodes a string that was URL encoded.

B<NOTE:> See $self->session->url->escape()

=head3 string

The string to unescape.

=cut

sub unescape {
	my $self = shift;
	return uri_unescape(shift);
}

#-------------------------------------------------------------------

=head2 urlize ( string )

Returns a url that is safe for WebGUI pages.  Strings are lower-cased, run through
$self->makeCompliant and then have any relative segments and trailing slashes removed.

=head3 string

The string to urlize.

=cut

sub urlize {
    my $self = shift;
    my ($value);
    $value = lc(shift);		#lower cases whole string
    $value = $self->makeCompliant($value);

    # remove /./ or /../
    $value =~ s{(^|/)(?:\.\.?/)*}{$1}g;

    # remove trailing slashes
    $value =~ s/\/$//;
    return $value;
}


1;
