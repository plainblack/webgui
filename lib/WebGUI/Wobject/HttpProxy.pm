package WebGUI::Wobject::HttpProxy;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2003 Plain Black LLC.
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
use WebGUI::HTMLForm;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::Wobject;
use WebGUI::Wobject::HttpProxy::Parse;
use WebGUI::Cache;

our @ISA = qw(WebGUI::Wobject);


#-------------------------------------------------------------------
sub name {
        return WebGUI::International::get(3,$_[0]->get("namespace"));
}

#-------------------------------------------------------------------
sub new {
        my $class = shift;
        my $property = shift;
        my $self = WebGUI::Wobject->new(
                -properties=>$property,
                -extendedProperties=>{
			proxiedUrl=>{
				defaultValue=>'http://'
				}, 
			timeout=>{
				defaultValue=>30
				}, 
			removeStyle=>{
				defaultValue=>1
				}, 
			filterHtml=>{
				defaultValue=>"javascript"
				}, 
			followExternal=>{
				defaultValue=>1
				}, 
                        rewriteUrls=>{
                                defaultValue=>1
                                },
			followRedirect=>{
				defaultValue=>0
				} 
			}
                );
        bless $self, $class;
}

#-------------------------------------------------------------------
sub uiLevel {
	return 5;
}

#-------------------------------------------------------------------
sub www_edit {
	my %hash;
	tie %hash, 'Tie::IxHash';
	%hash=(5=>5,10=>10,20=>20,30=>30,60=>60);
       	my $privileges = WebGUI::HTMLForm->new;
       	my $properties = WebGUI::HTMLForm->new;
       	my $layout = WebGUI::HTMLForm->new;
        $properties->url(
		-name=>"proxiedUrl", 
		-label=>WebGUI::International::get(1,$_[0]->get("namespace")),
		-value=>$_[0]->getValue("proxiedUrl")
		);
        $privileges->yesNo(
        	-name=>"followExternal",
                -label=>WebGUI::International::get(5,$_[0]->get("namespace")),
                -value=>$_[0]->getValue("followExternal")
                );
        $properties->yesNo(
                -name=>"followRedirect",
                -label=>WebGUI::International::get(8,$_[0]->get("namespace")),
                -value=>$_[0]->getValue("followRedirect")
                );
        $properties->yesNo(
                -name=>"rewriteUrls",
                -label=>WebGUI::International::get(12,$_[0]->get("namespace")),
                -value=>$_[0]->getValue("rewriteUrls")
                );
        $layout->yesNo(
                -name=>"removeStyle",
                -label=>WebGUI::International::get(6,$_[0]->get("namespace")),
                -value=>$_[0]->getValue("removeStyle")
                );
	$layout->filterContent(
		-name=>"filterHtml",
		-value=>$_[0]->getValue("filterHtml")
		);
        $properties->select(
		-name=>"timeout", 
		-options=>\%hash, 
		-label=>WebGUI::International::get(4,$_[0]->get("namespace")),
		-value=>[$_[0]->getValue("timeout")]
		);
        return $_[0]->SUPER::www_edit(
		-properties=>$properties->printRowsOnly,
		-layout=>$layout->printRowsOnly,
		-privileges=>$privileges->printRowsOnly,
		-helpId=>1,
		-headingId=>2
		);
}


#-------------------------------------------------------------------
sub www_view {
   my (%formdata, @formUpload, $redirect, $response, $header, 
       $userAgent, $proxiedUrl, $request, $content, $ttl);

   	my $output = $_[0]->displayTitle;
   	$output .= $_[0]->description;

   	my $node = WebGUI::Node->new("temp",$_[0]->get("namespace")."_cookies");
	$node->create;
	my $cookiebox = WebGUI::URL::escape($session{var}{sessionId});
   	$cookiebox =~ s/[^A-Za-z0-9\-\.\_]//g;  #removes all funky characters
   	$cookiebox .= '.cookie';
	$cookiebox = $node->getPath.$session{os}{slash}.$cookiebox;
   	my $jar = HTTP::Cookies->new(File => $cookiebox, AutoSave => 1, Ignore_Discard => 1);

   if($session{form}{wid} == $_[0]->get("wobjectId") && $session{form}{func}!~/editSave/i) {
      $proxiedUrl = $session{form}{FormAction} || $session{form}{proxiedUrl} || $_[0]->get("proxiedUrl") ;
   } else {
      $proxiedUrl = $_[0]->get("proxiedUrl");
      $session{env}{REQUEST_METHOD}='GET';
   }

   $redirect=0; 

   return $output unless ($proxiedUrl ne "");
   
   my $cachedContent = WebGUI::Cache->new($proxiedUrl,"URL");
   my $cachedHeader = WebGUI::Cache->new($proxiedUrl,"HEADER");
   $header = $cachedHeader->get;
   $content = $cachedContent->get;
   unless ($content && $session{env}{REQUEST_METHOD}=~/GET/i) {
      $redirect=0; 
      until($redirect == 5) { # We follow max 5 redirects to prevent bouncing/flapping
      $userAgent = new LWP::UserAgent;
      $userAgent->agent($session{env}{HTTP_USER_AGENT});
      $userAgent->timeout($_[0]->get("timeout"));
      $userAgent->env_proxy;

      $proxiedUrl = URI->new($proxiedUrl);

      #my $allowed_url = URI->new($_[0]->get('proxiedUrl'))->abs;;

      #if ($_[0]->get("followExternal")==0 && $proxiedUrl !~ /\Q$allowed_url/i) {
      if ($_[0]->get("followExternal")==0 && 
          (URI->new($_[0]->get('proxiedUrl'))->host) ne (URI->new($proxiedUrl)->host) ) {
         return "<h1>You are not allowed to leave ".$_[0]->get("proxiedUrl")."</h1>";
      }

      $header = new HTTP::Headers;
	$header->referer($_[0]->get("proxiedUrl")); # To get around referrer blocking

      if($session{env}{REQUEST_METHOD}=~/GET/i || $redirect != 0) {  # request_method is also GET after a redirection. Just to make sure we're
                               						# not posting the same data over and over again.
         if($redirect == 0 && $session{form}{wid} == $_[0]->get("wobjectId")) {
            foreach my $input_name (keys %{$session{form}}) {
               next if ($input_name !~ /^HttpProxy_/); # Skip non proxied form var's
               $input_name =~ s/^HttpProxy_//;
               $proxiedUrl=WebGUI::URL::append($proxiedUrl,"$input_name=$session{form}{'HttpProxy_'.$input_name}");
            }
         }
         $request = HTTP::Request->new(GET => $proxiedUrl, $header) || return "wrong url"; # Create GET request
      } else { # It's a POST

         my $contentType = 'application/x-www-form-urlencoded'; # default Content Type header

         # Create a %formdata hash to pass key/value pairs to the POST request
         foreach my $input_name (keys %{$session{form}}) {
   	 next if ($input_name !~ /^HttpProxy_/); # Skip non proxied form var's
   	 $input_name =~ s/^HttpProxy_//;
   
            my $uploadFile = $session{cgi}->tmpFileName($session{form}{'HttpProxy_'.$input_name});
   
            if(-r $uploadFile) { # Found uploaded file
      	       @formUpload=($uploadFile, qq/$session{form}{'HttpProxy_'.$input_name}/);
   	       $formdata{$input_name}=\@formUpload;
	       $contentType = 'form-data'; # Different Content Type header for file upload
   	    } else {
   	      $formdata{$input_name}=qq/$session{form}{'HttpProxy_'.$input_name}/;
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
      $redirect=5 if (not $_[0]->get("followRedirect")); # No redirection. Overruled by setting
   }
   
   if($response->is_success) {
      $content = $response->content;
      $header = $response->content_type; 
      if($response->content_type eq "text/html" || 
        ($response->content_type eq "" && $content=~/<html/gis)) {
  
         my $p = WebGUI::Wobject::HttpProxy::Parse->new($proxiedUrl, $content, $_[0]->get("wobjectId"),$_[0]->get("rewriteUrls"));
         $content = $p->filter; # Rewrite content. (let forms/links return to us).
         $p->DESTROY; 
   
         if ($content =~ /<frame/gis) {
            $content = "<h1>HttpProxy: Can't display frames</h1>
                        Try fetching it directly <a href='$proxiedUrl'>here.</a>";
         } else {
            $content =~ s/\<style.*?\/style\>//isg if ($_[0]->get("removeStyle"));
            $content = WebGUI::HTML::cleanSegment($content);
            $content = WebGUI::HTML::filter($content, $_[0]->get("filterHtml"));
         }
      }
   } else { # Fetching page failed...
      $content = "<b>Getting <a href='$proxiedUrl'>$proxiedUrl</a> failed</b>".
   	      "<p><i>GET status line: ".$response->status_line."</i>";
   }
   if ($session{user}{userId} == 1) {
      $ttl = $session{page}{cacheTimeoutVisitor};
      } else {
          $ttl = $session{page}{cacheTimeout};
      }

   $cachedContent->set($content,$ttl);
   $cachedHeader->set($header,$ttl);
   }

   if($header ne "text/html") {
	$session{header}{mimetype} = $header; 
	return $content;
   } else {
   	return $output.$content;
   }
}
1;
