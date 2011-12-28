package WebGUI::Asset::Wobject::HttpProxy;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use URI;
use LWP;
use HTTP::Cookies;
use HTTP::Request::Common;
use HTML::Entities;
use WebGUI::International;
use WebGUI::Storage;
use WebGUI::Asset::Wobject::HttpProxy::Parse;
use WebGUI::Macro;
use Tie::IxHash;

use Moose;
use WebGUI::Definition::Asset;
extends 'WebGUI::Asset::Wobject';
define assetName => ['assetName', 'Asset_HttpProxy'];
define icon      => 'httpProxy.gif';
define tableName => 'HttpProxy';
property templateId => (
                fieldType => "template",
                default   => 'PBtmpl0000000000000033',
                namespace => 'HttpProxy',
                tab       => 'display',
                label     => ['http proxy template title', 'Asset_HttpProxy'],
                hoverHelp => ['http proxy template title description', 'Asset_HttpProxy'],
         );

property proxiedUrl => (
                fieldType => "url",
                default   => 'http://',
                tab       => 'properties',
                label     => [1, 'Asset_HttpProxy'],
                hoverHelp => ['1 description', 'Asset_HttpProxy'],
         );

property useAmpersand => (
                fieldType => "yesNo",
                default   => 0,
                tab       => 'properties',
                label     => ["use ampersand", 'Asset_HttpProxy'],
                hoverHelp => ["use ampersand help", 'Asset_HttpProxy'],
         );

property timeout => (
                fieldType => "selectBox",
                default   => 30,
                tab       => 'properties',
                options   => \&_timeout_options,
                label     => [4, 'Asset_HttpProxy'],
                hoverHelp => ['4 description', 'Asset_HttpProxy'],
         );
sub _timeout_options {
	my %timeoutOptions;
	tie %timeoutOptions, 'Tie::IxHash';
	%timeoutOptions = map{$_ => $_} (5, 10, 20, 30, 60);
    return \%timeoutOptions;
}

property removeStyle => (
                fieldType => "yesNo",
                default   => 1,
                tab       => 'display',
                label     => [6, 'Asset_HttpProxy'],
                hoverHelp => ['6 description', 'Asset_HttpProxy'],
         );

property cacheTimeout => (
                fieldType => "interval",
                default   => 0,
                tab       => 'display',
                label     => ['cache timeout', 'Asset_HttpProxy'],
                hoverHelp => ['cache timeout description', 'Asset_HttpProxy'],
                uiLevel   => 8,
         );

property filterHtml => (
                fieldType => "filterContent",
                default   => "javascript",
                tab       => 'display',
                label     => [418, 'WebGUI', 'Asset_HttpProxy'],
                hoverHelp => ['418 description', 'WebGUI', 'Asset_HttpProxy'],
         );
            
property urlPatternFilter => (
                fieldType    => "textarea",
                default      => "",
                tab          => "display",
                label        => ["url pattern filter label", 'Asset_HttpProxy'],
                hoverHelp    => ["url pattern filter hover help", 'Asset_HttpProxy'],
         );
            
property followExternal => (
                fieldType => "yesNo",
                default   => 1,
                tab       => 'security',
                label     => [5, 'Asset_HttpProxy'],
                hoverHelp => ['5 description', 'Asset_HttpProxy'],
         );

property rewriteUrls => (
                fieldType => "yesNo",
                default   => 1,
                tab       => 'properties',
                label     => [12, 'Asset_HttpProxy'],
                hoverHelp => ['12 description', 'Asset_HttpProxy'],
         );

property followRedirect => (
                fieldType => "yesNo",
                default   => 0,
                tab       => 'security',
                label     => [8, 'Asset_HttpProxy'],
                hoverHelp => ['8 description', 'Asset_HttpProxy'],
         );

property searchFor => (
                fieldType => "text",
                default   => undef,
                tab       => 'display',
                label     => [13, 'Asset_HttpProxy'],
                hoverHelp => ['13 description', 'Asset_HttpProxy'],
         );

property stopAt => (
                fieldType => "text",
                default   => undef,
                tab       => 'display',
                label     => [14, 'Asset_HttpProxy'],
                hoverHelp => ['14 description', 'Asset_HttpProxy'],
         );

property cookieJarStorageId => (
                noFormPost => 1,
                fieldType  => "hidden",
                default    => undef
         );
has '+uiLevel' => (
    default => 5,
);


#-------------------------------------------------------------------

=head2 appendToUrl ($url, $paramSet)

Append some parameters to a URL, similar to $session->url->append.  This method
also will either append with an ampersand or a semi-colon, based on the useAmersand
asset property.

=head3 $url

The URL to use as a base.

=head3 $paramSet

A string of parameters to add to the URL.

=cut

sub appendToUrl {
	my $self = shift;
        my $url = shift;
	my $paramSet = shift;
	my $seperator = ($self->useAmpersand) ? "&" : ";";
	if (index($url, '?') == length($url)-1) {
		$url .= $paramSet;
	} elsif (index($url, '?') >= 0) {
                $url .= $seperator.$paramSet;
        } else {
                $url .= '?'.$paramSet;
        }
        return $url;
}


#-------------------------------------------------------------------

=head2 getContentLastModified 

Override the base method to say that the asset content is never cached.

=cut

sub getContentLastModified {
    return time;
}


#-------------------------------------------------------------------

=head2 getCookieJar 

Return a WebGUI::Storage object to hold cookie data.

=cut

sub getCookieJar {
	my $self = shift;
	my $storage;
	unless ($self->cookieJarStorageId) {
		$storage = WebGUI::Storage->create($self->session);
		$self->update({cookieJarStorageId=>$storage->getId});
	} else {
		$storage = WebGUI::Storage->get($self->session,$self->cookieJarStorageId);
	}
	return $storage;
}

#-------------------------------------------------------------------

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

override prepareView => sub {
	my $self = shift;
	super();
	my $template = WebGUI::Asset::Template->newById($self->session, $self->templateId);
    if (!$template) {
        WebGUI::Error::ObjectNotFound::Template->throw(
            error      => qq{Template not found},
            templateId => $self->templateId,
            assetId    => $self->getId,
        );
    }
	$template->prepare($self->getMetaDataAsTemplateVariables);
	$self->{_viewTemplate} = $template;
};


#-------------------------------------------------------------------

=head2 purge

Extend the base method to delete the cookie jar

=cut

override purge => sub {
	my $self = shift;
	$self->getCookieJar->delete;	
	super();
};


#-------------------------------------------------------------------

=head2 purgeCache ( )

See WebGUI::Asset::purgeCache() for details.

=cut

override purgeCache => sub {
	my $self = shift;
    my $cache = $self->session->cache;
	eval {
        $cache->remove($self->proxiedUrl."_URL");
	    $cache->remove($self->proxiedUrl."_HEADER");
    };
	super();
};

#-------------------------------------------------------------------

=head2 view 

Main screen for the HttpProxy.

=cut

sub view {
	my $self = shift;
	my %var; 
	my %formdata; 
	my $redirect 	= 0; 
	my $response; 
	my $header; 
	my $proxiedUrl = $self->proxiedUrl;
	WebGUI::Macro::process($self->session,\$proxiedUrl);

	my $i18n = WebGUI::International->new($self->session, 'Asset_HttpProxy');
	
	### Set up a cookie jar
	my $cookiebox = $self->session->url->escape($self->session->getId);
	$cookiebox =~ s/[^A-Za-z0-9\-\.\_]//g;  #removes all funky characters
	$cookiebox .= '.cookie';
	my $jar = HTTP::Cookies->new(File => $self->getCookieJar->getPath($cookiebox), AutoSave => 1, Ignore_Discard => 1);
	
	
	### Find the URL we're proxying
	if ($self->session->form->param("func")!~/editSave/i) {	# Ignore ?func=editSave
		$proxiedUrl = $self->session->form->process("FormAction") || $self->session->form->process("proxiedUrl") || $proxiedUrl ;
	}
	
	return $self->processTemplate({},$self->templateId) 
		unless ($proxiedUrl ne "");
	
	my $requestMethod = $self->session->request->method || "GET";
	
	### Do we have cached content to get?
    my $cache = $self->session->cache;
	if ($requestMethod =~ /^GET$/i) {
        eval {
		    $var{header} 	= $cache->get($proxiedUrl.'_HEADER');
		    $var{content} 	= $cache->get($proxiedUrl."_URL");
        };
	}
	
	# Unless we have cached content
	unless ($var{content}) {
		
		# Get new content
		REDIRECT: for my $redirect (0..4) { # We follow max 5 redirects to prevent bouncing/flapping
			
			my $userAgent = new LWP::UserAgent;
			$userAgent->agent($self->session->request->user_agent);
			$userAgent->timeout($self->timeout);
			$userAgent->env_proxy;
			
			
			$proxiedUrl 	= URI->new($proxiedUrl);
			
			
			# Set request method to GET after a redirect, so we're
			# not posting the same data over and over
			$requestMethod	= "GET"		if $redirect > 0;
			
			
			## Make sure the user isn't leaving where we've allowed
			if ($self->followExternal==0 
				&& (URI->new($self->proxiedUrl)->host) ne (URI->new($proxiedUrl)->host) ) {
				$var{header} 	= "text/html";
				$var{content} 	= sprintf $i18n->get('may not leave error message'), $self->proxiedUrl;
				last;
			}
			
			
			$header = new HTTP::Headers;
			$header->referer($self->proxiedUrl); # To get around referrer blocking
			
			
			my $request;	# Create the request
			if($requestMethod=~/GET/i) {  
				my $params	= $self->session->form->paramsHashRef();
				for my $key (keys %{$params}) {
					my $value = $params->{$key};
					next unless ($key =~ s/^HttpProxy_//); # Skip non-proxied params
					if (ref $value eq "ARRAY") {
						# Param value is an array reference
						# Add all values to URL
						for my $subvalue (@$value) {
							$proxiedUrl = $self->appendToUrl($proxiedUrl,"$key=$subvalue");
						}
					} else {
						$proxiedUrl = $self->appendToUrl($proxiedUrl,"$key=$value");
					}
				}
				### DEBUG
				#require Data::Dumper;
				#$self->session->log->warn("DEBUG: ".Data::Dumper::Dumper($params));
				#$self->session->log->warn("URL: $proxiedUrl");
				
				$request = HTTP::Request->new(GET => $proxiedUrl, $header) || return "wrong url"; # Create GET request
			} else { # It's a POST
		
				my $contentType = 'application/x-www-form-urlencoded'; # default Content Type header
				
				# Create a %formdata hash to pass key/value pairs to the POST request
				foreach my $input_name ($self->session->request->param) {
					$input_name =~ s/^HttpProxy_// or next;
					
					my (@upload) = grep{defined} $self->session->request->upload('HttpProxy_'.$input_name);
					if (@upload) { # Found uploaded file
						my $upload = $upload[0];
						$formdata{$input_name}=[$upload->tempname, $self->session->form->process('HttpProxy_'.$input_name)];
						$contentType = 'form-data'; # Different Content Type header for file upload
					} else {
						$formdata{$input_name}=[($self->session->form->process('HttpProxy_'.$input_name))];
					}
				}
				# Create POST request
				$request = HTTP::Request::Common::POST($proxiedUrl, \%formdata, Content_Type => $contentType);
			}
			$jar->add_cookie_header($request);
			
			
			$response = $userAgent->simple_request($request);
			
			$jar->extract_cookies($response);
			
			if ($response->is_redirect) { # redirected by http header
				$proxiedUrl = URI::URL::url($response->header("Location"))->abs($proxiedUrl);;
			} elsif ($response->content_type eq "text/html" 
				&& $response->content =~ /<meta[^>]+refresh[^>]+content[^>]*url=([^\s'"<>]+)/gis) {
				# redirection through meta refresh
				my $refreshUrl = $1;
				if($refreshUrl=~ /^http/gis) { #Refresh value is absolute
					$proxiedUrl=$refreshUrl;
				} else { # Refresh value is relative
					$proxiedUrl =~ s/[^\/\\]*$//; #chop off everything after / in $proxiedURl
					$proxiedUrl .= URI::URL::url($refreshUrl)->rel($proxiedUrl); # add relative path
				}
			} else { 
				last REDIRECT;
			}
			##At least 1 time through the loop
			last REDIRECT if (not $self->followRedirect); # No redirection. Overruled by setting
		}
		
		if($response->is_success) {
			$var{content} = $response->decoded_content || $response->content;
			$var{header} = $response->content_type;
			if($response->content_type eq "text/html"
			    || ($response->content_type eq "" && $var{content}=~/<html/gis)) {
				
				$var{"search.for"} = $self->searchFor;
				$var{"stop.at"} = $self->stopAt;
				if ($var{"search.for"}) {
					$var{content} =~ /^(.*?)\Q$var{"search.for"}\E(.*)$/gis;
					$var{"content.leading"} = $1 || $var{content};
					$var{content} = $2;
				}
				if ($var{"stop.at"}) {
					$var{content} =~ /(.*?)\Q$var{"stop.at"}\E(.*)$/gis;
					$var{content} = $1 || $var{content};
					$var{"content.trailing"} = $2;
				}
				my $p = WebGUI::Asset::Wobject::HttpProxy::Parse->new($self->session, $proxiedUrl, $var{content}, $self->getId,$self->rewriteUrls,$self->getUrl,$self->urlPatternFilter);
				$var{content} = $p->filter; # Rewrite content. (let forms/links return to us).
				undef $p;
		
				if ($var{content} =~ /<frame/gis) {
					$var{header} = "text/html";
					$var{content} = sprintf $i18n->get('no frame error message'), $proxiedUrl;
				} else {
					$var{content} =~ s/\<style.*?\/style\>//isg if ($self->removeStyle);
					$var{content} = WebGUI::HTML::cleanSegment($var{content}, 1);
					$var{content} = WebGUI::HTML::filter($var{content}, $self->filterHtml);
				}
			}
		} else { # Fetching page failed...
			$var{header} = "text/html";
			$var{content} = sprintf $i18n->get('fetch page error'), $proxiedUrl, $proxiedUrl, $response->status_line;
		}
		unless ($self->cacheTimeout <= 10) {
			eval{
                $cache->set($proxiedUrl.'URL', $var{content}, $self->cacheTimeout);
			    $cache->set($proxiedUrl.'HEADER', $var{header}, $self->cacheTimeout);
            };
		}
	}
	
	
	$self->session->response->content_type($var{header});
	
	if($var{header} ne "text/html") {
		return $var{content};
	} else {
	    my $content = $var{content};
	    $var{content} = '~~~';
	    my $output = $self->processTemplate(\%var,undef,$self->{_viewTemplate});
	    WebGUI::Macro::process($self->session, \$output);
	    my ($head, $foot) = split('~~~', $output);
	    return $head . $content . $foot;
	}
}


#-------------------------------------------------------------------

=head2 www_view 

Override the base method to handle non-HTML mime types.

=cut

sub www_view {
    my $self = shift;
    return $self->session->privilege->noAccess() unless $self->canView;
    $self->prepareView;
    my $output = $self->view;
    if ($self->session->response->content_type ne "text/html") {
        return $output;
    } else {
        $self->session->response->sendHeader;
        my $style = $self->processStyle($self->getSeparator, { noHeadTags => 1 });
        my ($head, $foot) = split($self->getSeparator,$style);
        $self->session->output->print($head);
        $self->session->output->print($output, 1); # Do not process macros
        $self->session->output->print($foot);
        return "chunked";
    }
}

__PACKAGE__->meta->make_immutable;
1;
