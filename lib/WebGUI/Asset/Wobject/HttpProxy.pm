package WebGUI::Asset::Wobject::HttpProxy;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
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

our @ISA = qw(WebGUI::Asset::Wobject);

#-------------------------------------------------------------------
sub appendToUrl {
	my $self = shift;
        my $url = shift;
	my $paramSet = shift;
	my $seperator = ($self->get("useAmpersand")) ? "&" : ";";
        if ($url =~ /\?/) {
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
	push(@{$definition}, {
		assetName=>$i18n->get('assetName'),
		uiLevel => 5,
		icon=>'httpProxy.gif',
		tableName=>'HttpProxy',
		className=>'WebGUI::Asset::Wobject::HttpProxy',
		properties=>{
			templateId =>{
				fieldType=>"template",
				defaultValue=>'PBtmpl0000000000000033'
				},
			proxiedUrl=>{
				fieldType=>"url",
				defaultValue=>'http://'
				}, 
			useAmpersand=>{
				fieldType=>"yesNo",
				defaultValue=>0
				},
			timeout=>{
				fieldType=>"selectBox",
				defaultValue=>30
				}, 
			removeStyle=>{
				fieldType=>"yesNo",
				defaultValue=>1
				}, 
			cacheTimeout=>{
				fieldType=>"interval",
				defaultValue=>0
				},
			filterHtml=>{
				fieldType=>"filterContent",
				defaultValue=>"javascript"
				}, 
			followExternal=>{
				fieldType=>"yesNo",
				defaultValue=>1
				}, 
                        rewriteUrls=>{
				fieldType=>"yesNo",
                                defaultValue=>1
                                },
			followRedirect=>{
				fieldType=>"yesNo",
				defaultValue=>0
				},
			searchFor=>{
				fieldType=>"text",
                                defaultValue=>undef
                                },
                        stopAt=>{
				fieldType=>"text",
                                defaultValue=>undef
                                },
			cookieJarStorageId=>{
                                noFormPost=>1,
                                fieldType=>"hidden",
                                defaultValue=>undef
                                }
			}
		});
        return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------
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
sub getEditForm {
	my $self = shift;
	my $i18n = WebGUI::International->new($self->session,"Asset_HttpProxy");
	my $tabform = $self->SUPER::getEditForm();
   	$tabform->getTab("display")->template(
      		-value=>$self->getValue('templateId'),
                -label=>$i18n->get('http proxy template title'),
                -hoverHelp=>$i18n->get('http proxy template title description'),
      		-namespace=>"HttpProxy"
   		);
	my %hash;
	tie %hash, 'Tie::IxHash';
	%hash=(5=>5,10=>10,20=>20,30=>30,60=>60);
        $tabform->getTab("properties")->url(
		-name=>"proxiedUrl", 
		-label=>$i18n->get(1),
		-hoverHelp=>$i18n->get('1 description'),
		-value=>$self->getValue("proxiedUrl")
		);
        $tabform->getTab("security")->yesNo(
        	-name=>"followExternal",
                -label=>$i18n->get(5),
                -hoverHelp=>$i18n->get('5 description'),
                -value=>$self->getValue("followExternal")
                );
        $tabform->getTab("security")->yesNo(
                -name=>"followRedirect",
                -label=>$i18n->get(8),
                -hoverHelp=>$i18n->get('8 description'),
                -value=>$self->getValue("followRedirect")
                );
        $tabform->getTab("properties")->yesNo(
                -name=>"rewriteUrls",
                -label=>$i18n->get(12),
                -hoverHelp=>$i18n->get('12 description'),
                -value=>$self->getValue("rewriteUrls")
                );
        $tabform->getTab("display")->interval(
                -name=>"cacheTimeout",
                -label=>$i18n->get('cache timeout'),
                -hoverHelp=>$i18n->get('cache timeout description'),
		-uiLevel => 8,
                -value=>$self->getValue("cacheTimeout")
                );
        $tabform->getTab("display")->yesNo(
                -name=>"removeStyle",
                -label=>$i18n->get(6),
                -hoverHelp=>$i18n->get('6 description'),
                -value=>$self->getValue("removeStyle")
                );
	$tabform->getTab("display")->filterContent(
		-name=>"filterHtml",
                -label=>$i18n->get(418, 'WebGUI'),
                -hoverHelp=>$i18n->get('418 description', 'WebGUI'),
		-value=>$self->getValue("filterHtml"),
		);
        $tabform->getTab("properties")->selectBox(
		-name=>"timeout", 
		-options=>\%hash, 
		-label=>$i18n->get(4),
		-hoverHelp=>$i18n->get('4 description'),
		-value=>[$self->getValue("timeout")]
		);
        $tabform->getTab("display")->text(
                -name=>"searchFor",
                -label=>$i18n->get(13),
                -hoverHelp=>$i18n->get('13 description'),
                -value=>$self->getValue("searchFor")
                );
        $tabform->getTab("display")->text(
                -name=>"stopAt",
                -label=>$i18n->get(14),
                -hoverHelp=>$i18n->get('14 description'),
                -value=>$self->getValue("stopAt")
                );
	$tabform->getTab("properties")->yesNo(
		name=>"useAmpersand",
		value=>$self->getValue("useAmpersand"),
		label=>$i18n->get("use ampersand"),
		hoverHelp=>$i18n->get("use ampersand help")
		);
	return $tabform;
}


#-------------------------------------------------------------------

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

sub prepareView {
	my $self = shift;
	$self->SUPER::prepareView();
	my $template = WebGUI::Asset::Template->new($self->session, $self->get("templateId"));
	$template->prepare;
	$self->{_viewTemplate} = $template;
}


#-------------------------------------------------------------------
sub purge {
	my $self = shift;
	$self->getCookieJar->delete;	
	$self->SUPER::purge;
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
sub view {
	my $self = shift;
	my $cookiebox = $self->session->url->escape($self->session->var->get("sessionId"));
	my $requestMethod = $self->session->env->get("REQUEST_METHOD");
   	$cookiebox =~ s/[^A-Za-z0-9\-\.\_]//g;  #removes all funky characters
   	$cookiebox .= '.cookie';
   	my $jar = HTTP::Cookies->new(File => $self->getCookieJar->getPath($cookiebox), AutoSave => 1, Ignore_Discard => 1);
   my (%var, %formdata, $redirect, $response, $header, $userAgent, $proxiedUrl, $request);

   if($self->session->form->param("func")!~/editSave/i) {
      $proxiedUrl = $self->session->form->process("FormAction") || $self->session->form->process("proxiedUrl") || $self->get("proxiedUrl") ;
   } else {
      $proxiedUrl = $self->get("proxiedUrl");
	$requestMethod = "GET";
   }

   $redirect=0; 

   return $self->processTemplate({},$self->get("templateId")) unless ($proxiedUrl ne "");
   
   my $cachedContent = WebGUI::Cache->new($self->session,$proxiedUrl,"URL");
   my $cachedHeader = WebGUI::Cache->new($self->session,$proxiedUrl,"HEADER");
   $var{header} = $cachedHeader->get;
   $var{content} = $cachedContent->get;
   unless ($var{content} && $requestMethod=~/GET/i) {
      $redirect=0; 
      until($redirect == 5) { # We follow max 5 redirects to prevent bouncing/flapping
      $userAgent = new LWP::UserAgent;
      $userAgent->agent($self->session->env->get("HTTP_USER_AGENT"));
      $userAgent->timeout($self->get("timeout"));
      $userAgent->env_proxy;

      $proxiedUrl = URI->new($proxiedUrl);

      #my $allowed_url = URI->new($self->get('proxiedUrl'))->abs;;

      #if ($self->get("followExternal")==0 && $proxiedUrl !~ /\Q$allowed_url/i) {
      if ($self->get("followExternal")==0 && 
          (URI->new($self->get('proxiedUrl'))->host) ne (URI->new($proxiedUrl)->host) ) {
	$var{header} = "text/html";
         return "<h1>You are not allowed to leave ".$self->get("proxiedUrl")."</h1>";
      }

      $header = new HTTP::Headers;
	$header->referer($self->get("proxiedUrl")); # To get around referrer blocking

      if($requestMethod=~/GET/i || $redirect != 0) {  # request_method is also GET after a redirection. Just to make sure we're
                               						# not posting the same data over and over again.
         if($redirect == 0) {
            foreach my $input_name ($self->session->form->param) {
               next if ($input_name !~ /^HttpProxy_/); # Skip non proxied form var's
               $input_name =~ s/^HttpProxy_//;
               $proxiedUrl=$self->appendToUrl($proxiedUrl,"$input_name=".$self->session->form->process('HttpProxy_'.$input_name));
            }
         }
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
			 $formdata{$input_name}=$self->session->form->process('HttpProxy_'.$input_name);
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
         $redirect++;
      } elsif ($response->content_type eq "text/html" && $response->content =~ 
                     /<meta[^>]+refresh[^>]+content[^>]*url=([^\s'"<>]+)/gis) {
         # redirection through meta refresh
         my $refreshUrl = $1;
         if($refreshUrl=~ /^http/gis) { #Refresh value is absolute
   	 $proxiedUrl=$refreshUrl;
         } else { # Refresh value is relative
   	 $proxiedUrl =~ s/[^\/\\]*$//; #chop off everything after / in $proxiedURl
            $proxiedUrl .= URI::URL::url($refreshUrl)->rel($proxiedUrl); # add relative path
         }
         $redirect++;
      } else { 
         $redirect = 5; #No redirection found. Leave loop.
      }
      $redirect=5 if (not $self->get("followRedirect")); # No redirection. Overruled by setting
   }
   
   if($response->is_success) {
      $var{content} = $response->content;
      $var{header} = $response->content_type; 
      if($response->content_type eq "text/html" || 
        ($response->content_type eq "" && $var{content}=~/<html/gis)) {
 
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
	 my $p = WebGUI::Asset::Wobject::HttpProxy::Parse->new($self->session, $proxiedUrl, $var{content}, $self->getId,$self->get("rewriteUrls"),$self->getUrl);
	 $var{content} = $p->filter; # Rewrite content. (let forms/links return to us).
	 $p->DESTROY;
   
         if ($var{content} =~ /<frame/gis) {
		$var{header} = "text/html";
            $var{content} = "<h1>HttpProxy: Can't display frames</h1>
                        Try fetching it directly <a href='$proxiedUrl'>here.</a>";
         } else {
            $var{content} =~ s/\<style.*?\/style\>//isg if ($self->get("removeStyle"));
            $var{content} = WebGUI::HTML::cleanSegment($var{content});
            $var{content} = WebGUI::HTML::filter($var{content}, $self->get("filterHtml"));
         }
      }
   } else { # Fetching page failed...
	$var{header} = "text/html";
      $var{content} = "<b>Getting <a href='$proxiedUrl'>$proxiedUrl</a> failed</b>".
   	      "<p><i>GET status line: ".$response->status_line."</i>";
   }
	unless ($self->get("cacheTimeout") <= 10) {
	   $cachedContent->set($var{content},$self->get("cacheTimeout"));
	   $cachedHeader->set($var{header},$self->get("cacheTimeout"));
	  }
   }

   if($var{header} ne "text/html") {
	$self->session->http->setMimeType($var{header});
	return $var{content};
   } else {
   	return $self->processTemplate(\%var,undef,$self->{_viewTemplate});
   }
}


#-------------------------------------------------------------------

sub www_view {
        my $self = shift;
        return $self->session->privilege->noAccess() unless $self->canView;
	$self->prepareView;
        my $output = $self->view;
        # this is s a stop gap. we need to do something here that deals with the real www_view and caching, etc.
        if ($self->session->http->getMimeType() ne "text/html") {
                return $output;
        } else {
                return $self->processStyle($output);
        }
}

1;
