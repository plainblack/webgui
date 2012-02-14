package WebGUI::Asset::Wobject::HttpProxy;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
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
use WebGUI::Asset::Wobject;
use WebGUI::Asset::Wobject::HttpProxy::Parse;
use WebGUI::Cache;
use WebGUI::Macro;
use Apache2::Upload;

our @ISA = qw(WebGUI::Asset::Wobject);

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
	my $seperator = ($self->get("useAmpersand")) ? "&" : ";";
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
sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift;
	my $i18n = WebGUI::International->new($session,"Asset_HttpProxy");
	my %timeoutOptions;
	tie %timeoutOptions, 'Tie::IxHash';
	%timeoutOptions = map{$_ => $_} (5, 10, 20, 30, 60);

	push(@{$definition}, {
		assetName => $i18n->get('assetName'),
		uiLevel => 5,
		icon => 'httpProxy.gif',
		tableName => 'HttpProxy',
		className => 'WebGUI::Asset::Wobject::HttpProxy',
		autoGenerateForms => 1,
		properties => {
			templateId => {
				fieldType => "template",
				defaultValue => 'PBtmpl0000000000000033',
				namespace => 'HttpProxy',
				tab => 'display',
				label => $i18n->get('http proxy template title'),
				hoverHelp => $i18n->get('http proxy template title description'),
				},

			proxiedUrl => {
				fieldType => "url",
				defaultValue => 'http://',
				tab => 'properties',
				label => $i18n->get(1),
				hoverHelp => $i18n->get('1 description'),
				},

			useAmpersand => {
				fieldType => "yesNo",
				defaultValue => 0,
				tab => 'properties',
				label => $i18n->get("use ampersand"),
				hoverHelp => $i18n->get("use ampersand help")
				},

			timeout => {
				fieldType => "selectBox",
				defaultValue => 30,
				tab => 'properties',
				options => \%timeoutOptions,
				label => $i18n->get(4),
				hoverHelp => $i18n->get('4 description'),
				},

			removeStyle => {
				fieldType => "yesNo",
				defaultValue => 1,
				tab => 'display',
				label => $i18n->get(6),
				hoverHelp => $i18n->get('6 description'),
				},

			cacheTimeout => {
				fieldType => "interval",
				defaultValue => 0,
				tab => 'display',
				label => $i18n->get('cache timeout'),
				hoverHelp => $i18n->get('cache timeout description'),
				uiLevel => 8,
				},

			filterHtml => {
				fieldType => "filterContent",
				defaultValue => "javascript",
				tab => 'display',
				label => $i18n->get(418, 'WebGUI'),
				hoverHelp => $i18n->get('418 description', 'WebGUI'),
				},
            
            urlPatternFilter=>{
                fieldType => "textarea",
                defaultValue => "",
                tab          => "display",
                label        => $i18n->get("url pattern filter label"),
                hoverHelp    => $i18n->get("url pattern filter hover help"),
                },
            
			followExternal => {
				fieldType => "yesNo",
				defaultValue => 1,
				tab => 'security',
				label => $i18n->get(5),
				hoverHelp => $i18n->get('5 description'),
				},

            rewriteUrls => {
				fieldType => "yesNo",
                defaultValue => 1,
				tab => 'properties',
				label => $i18n->get(12),
				hoverHelp => $i18n->get('12 description'),
                },

			followRedirect => {
				fieldType => "yesNo",
				defaultValue => 0,
				tab => 'security',
				label => $i18n->get(8),
				hoverHelp => $i18n->get('8 description'),
				},

			searchFor => {
				fieldType => "text",
                                defaultValue => undef,
				tab => 'display',
				label => $i18n->get(13),
				hoverHelp => $i18n->get('13 description'),
                                },

                        stopAt => {
				fieldType => "text",
                                defaultValue => undef,
				tab => 'display',
				label => $i18n->get(14),
				hoverHelp => $i18n->get('14 description'),
                                },

			cookieJarStorageId => {
                                noFormPost => 1,
                                fieldType => "hidden",
                                defaultValue => undef
                                }
			}
		});
        return $class->SUPER::definition($session, $definition);
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
	unless ($self->get("cookieJarStorageId")) {
		$storage = WebGUI::Storage->create($self->session);
		$self->update({cookieJarStorageId=>$storage->getId});
	} else {
		$storage = WebGUI::Storage->get($self->session,$self->get("cookieJarStorageId"));
	}
	return $storage;
}

#-------------------------------------------------------------------

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

sub prepareView {
	my $self = shift;
	$self->SUPER::prepareView();
	my $template = WebGUI::Asset::Template->new($self->session, $self->get("templateId"));
    if (!$template) {
        WebGUI::Error::ObjectNotFound::Template->throw(
            error      => qq{Template not found},
            templateId => $self->get("templateId"),
            assetId    => $self->getId,
        );
    }
	$template->prepare($self->getMetaDataAsTemplateVariables);
	$self->{_viewTemplate} = $template;
}


#-------------------------------------------------------------------

=head2 purge

Extend the base method to delete all cookie jars for this HttpProxy

=cut

sub purge {
    my $self = shift;
    my $id      = $self->getId;
    my $session = $self->session;
    my @storageIds = $session->db->buildArray("select cookieJarStorageId from HttpProxy where assetId=?",[$id]);
    my $success    = $self->SUPER::purge;
    return 0 unless $success;
    foreach my $storageId (@storageIds) {
        my $storage = WebGUI::Storage->get($session, $storageId);
        $storage->delete if defined $storage;
    }
    return 1;
}

#-------------------------------------------------------------------

=head2 purgeRevision

Extend the base method to delete the cookie jar for this revision.

=cut

sub purgeRevision {
	my $self = shift;
	$self->getCookieJar->delete;	
	$self->SUPER::purgeRevision;
}


#-------------------------------------------------------------------

=head2 purgeCache ( )

See WebGUI::Asset::purgeCache() for details.

=cut

sub purgeCache {
	my $self = shift;
	WebGUI::Cache->new($self->session,$self->get("proxiedUrl"),"URL")->delete;
	WebGUI::Cache->new($self->session,$self->get("proxiedUrl"),"HEADER")->delete;
	$self->SUPER::purgeCache;
}

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
	my $proxiedUrl = $self->get("proxiedUrl");
	WebGUI::Macro::process($self->session,\$proxiedUrl);

	my $i18n = WebGUI::International->new($self->session, 'Asset_HttpProxy');
	
	### Set up a cookie jar
	my $cookiebox = $self->session->url->escape($self->session->var->get("sessionId"));
	$cookiebox =~ s/[^A-Za-z0-9\-\.\_]//g;  #removes all funky characters
	$cookiebox .= '.cookie';
	my $jar = HTTP::Cookies->new(File => $self->getCookieJar->getPath($cookiebox), AutoSave => 1, Ignore_Discard => 1);
	
	
	### Find the URL we're proxying
	if ($self->session->form->param("func")!~/editSave/i) {	# Ignore ?func=editSave
		$proxiedUrl = $self->session->form->process("FormAction") || $self->session->form->process("proxiedUrl") || $proxiedUrl ;
	}
	
	return $self->processTemplate({},$self->get("templateId")) 
		unless ($proxiedUrl ne "");
	
	my $requestMethod = $self->session->env->get("REQUEST_METHOD") || "GET";
	
	### Do we have cached content to get?
	my $cacheContent = WebGUI::Cache->new($self->session,$proxiedUrl,"URL");
	my $cacheHeader = WebGUI::Cache->new($self->session,$proxiedUrl,"HEADER");
	if ($requestMethod =~ /^GET$/i)
	{
		$var{header} 	= $cacheHeader->get;
		$var{content} 	= $cacheContent->get;
	}
	
	# Unless we have cached content
	unless ($var{content}) {
		
		# Get new content
		REDIRECT: for my $redirect (0..4) { # We follow max 5 redirects to prevent bouncing/flapping
			
			my $userAgent = new LWP::UserAgent;
			$userAgent->agent($self->session->env->get("HTTP_USER_AGENT"));
			$userAgent->timeout($self->get("timeout"));
			$userAgent->env_proxy;
			
			
			$proxiedUrl 	= URI->new($proxiedUrl);
			
			
			# Set request method to GET after a redirect, so we're
			# not posting the same data over and over
			$requestMethod	= "GET"		if $redirect > 0;
			
			
			## Make sure the user isn't leaving where we've allowed
			if ($self->get("followExternal")==0 
				&& (URI->new($self->get('proxiedUrl'))->host) ne (URI->new($proxiedUrl)->host) ) {
				$var{header} 	= "text/html";
				$var{content} 	= sprintf $i18n->get('may not leave error message'), $self->get("proxiedUrl");
				last;
			}
			
			
			$header = new HTTP::Headers;
			$header->referer($self->get("proxiedUrl")); # To get around referrer blocking
			
			
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
				#$self->session->errorHandler->warn("DEBUG: ".Data::Dumper::Dumper($params));
				#$self->session->errorHandler->warn("URL: $proxiedUrl");
				
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
			last REDIRECT if (not $self->get("followRedirect")); # No redirection. Overruled by setting
		}
		
		if($response->is_success) {
			$var{content} = $response->decoded_content || $response->content;
			$var{header} = $response->content_type;
			if($response->content_type eq "text/html"
			    || ($response->content_type eq "" && $var{content}=~/<html/gis)) {
				
				$var{"search.for"} = $self->getValue("searchFor");
				$var{"stop.at"} = $self->getValue("stopAt");
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
				my $p = WebGUI::Asset::Wobject::HttpProxy::Parse->new($self->session, $proxiedUrl, $var{content}, $self->getId,$self->get("rewriteUrls"),$self->getUrl,$self->get("urlPatternFilter"));
				$var{content} = $p->filter; # Rewrite content. (let forms/links return to us).
				$p->DESTROY;
		
				if ($var{content} =~ /<frame/gis) {
					$var{header} = "text/html";
					$var{content} = sprintf $i18n->get('no frame error message'), $proxiedUrl;
				} else {
					$var{content} =~ s/\<style.*?\/style\>//isg if ($self->get("removeStyle"));
					$var{content} = WebGUI::HTML::cleanSegment($var{content}, 1);
					$var{content} = WebGUI::HTML::filter($var{content}, $self->get("filterHtml"));
				}
			}
		} else { # Fetching page failed...
			$var{header} = "text/html";
			$var{content} = sprintf $i18n->get('fetch page error'), $proxiedUrl, $proxiedUrl, $response->status_line;
		}
		unless ($self->get("cacheTimeout") <= 10) {
			$cacheContent->set($var{content},$self->get("cacheTimeout"));
			$cacheHeader->set($var{header},$self->get("cacheTimeout"));
		}
	}
	
	
	$self->session->http->setMimeType($var{header});
	
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
    if ($self->session->http->getMimeType ne "text/html") {
        return $output;
    } else {
        $self->session->http->sendHeader;
        my $style = $self->processStyle($self->getSeparator, { noHeadTags => 1 });
        my ($head, $foot) = split($self->getSeparator,$style);
        $self->session->output->print($head);
        $self->session->output->print($output, 1); # Do not process macros
        $self->session->output->print($foot);
        return "chunked";
    }
}

1;
