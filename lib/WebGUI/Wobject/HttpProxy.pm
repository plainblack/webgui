package WebGUI::Wobject::HttpProxy;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------
# Len Kranendonk - 20021212

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
use WebGUI::ProxyParse;

our @ISA = qw(WebGUI::Wobject);
our $namespace = "HttpProxy";
our $name = WebGUI::International::get(3,$namespace);


#-------------------------------------------------------------------
sub duplicate {
        my ($w);
	$w = $_[0]->SUPER::duplicate($_[1]);
        $w = WebGUI::Wobject::WobjectProxy->new({wobjectId=>$w,namespace=>$namespace});
        $w->set({
		proxiedUrl=>$_[0]->get("proxiedUrl"),
                timeout=>$_[0]->get("timeout"),
		removeStyle=>$_[0]->get("removeStyle"),
		filterHtml=>$_[0]->get("filterHtml"),
		followExternal=>$_[0]->get("followExternal"),
		followRedirect=>$_[0]->get("followRedirect"),
		cookiebox=>$_[0]->get("cookiebox")
		});
}

#-------------------------------------------------------------------
sub new {
        my ($self, $class, $property);
        $class = shift;
        $property = shift;
        $self = WebGUI::Wobject->new($property);
        bless $self, $class;
}

#-------------------------------------------------------------------
sub set {
        $_[0]->SUPER::set($_[1],[qw(proxiedUrl timeout removeStyle filterHtml followExternal followRedirect cookiebox)]);
}

#-------------------------------------------------------------------
sub www_copy {
        if (WebGUI::Privilege::canEditPage()) {
		$_[0]->duplicate;
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_edit {
        my (%htmlFilter, $output, $f, $startDate, $endDate, $templatePosition, $proxiedUrl, %hash);
        if (WebGUI::Privilege::canEditPage()) {
		%hash=(5=>5,10=>10,20=>20,30=>30,60=>60);
		%htmlFilter = ('none'=>WebGUI::International::get(420), 'most'=>WebGUI::International::get(421),
                	'javascript'=>WebGUI::International::get(526), 'all'=>WebGUI::International::get(419));
                $output = helpIcon(1,$namespace);
		$output .= '<h1>'.WebGUI::International::get(2,$namespace).'</h1>';
		$templatePosition = $_[0]->get("templatePosition") || '0';
        	$startDate = $_[0]->get("startDate") || $session{page}{startDate};
        	$endDate = $_[0]->get("endDate") || $session{page}{endDate};
        	$f = WebGUI::HTMLForm->new;
                $f->url("proxiedUrl", WebGUI::International::get(1,$namespace),$_[0]->get("proxiedUrl")||'http://');
                $f->yesNo(
                        -name=>"followExternal",
                        -label=>WebGUI::International::get(5,$namespace),
                        -value=>($_[0]->get("wobjectId") eq "new") ? 1 : $_[0]->get("followExternal"),
                        -uiLevel=>5
                        );
                $f->yesNo(
                        -name=>"followRedirect",
                        -label=>WebGUI::International::get(8,$namespace),
                        -value=>$_[0]->get("followRedirect"),
                        -uiLevel=>5
                        );
                $f->yesNo(
                        -name=>"removeStyle",
                        -label=>WebGUI::International::get(6,$namespace),
                        -value=>($_[0]->get("wobjectId") eq "new") ? 1 : $_[0]->get("removeStyle"),
                        -uiLevel=>5
                        );

		$f->select("filterHtml",\%htmlFilter,WebGUI::International::get(7,$namespace),[$_[0]->get("filterHtml")||"javascript"]);
                $f->select("timeout", \%hash, WebGUI::International::get(4,$namespace),[$_[0]->get("timeout")||30]);
		$f->text("cookiebox", WebGUI::International::get(9,$namespace),$_[0]->get("cookiebox")||'/tmp');
        	$output .= $_[0]->SUPER::www_edit($f->printRowsOnly);
		return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_editSave {
        if (WebGUI::Privilege::canEditPage()) {
		$_[0]->SUPER::www_editSave();
                $_[0]->set({
			proxiedUrl=>$session{form}{proxiedUrl},
                        timeout=>$session{form}{timeout},
			removeStyle=>$session{form}{removeStyle},
			filterHtml=>$session{form}{filterHtml},
			followExternal=>$session{form}{followExternal},
			followRedirect=>$session{form}{followRedirect},
			cookiebox=>$session{form}{cookiebox}
			});
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_view {
   my (%formdata, @formUpload, $jar, $redirect, $cookiebox, $response, $header, 
       $output, $userAgent, $proxiedUrl, $request, $content);

   $output = $_[0]->displayTitle;
   $output .= $_[0]->description;
   $output = $_[0]->processMacros($output);

   if(not(-w $_[0]->get("cookiebox") && -r $_[0]->get("cookiebox"))) {
      return "<b>Error while opening cookie directory ".$_[0]->get("cookiebox")."</b><p><i>$!</i>";
   }

   $cookiebox = $_[0]->get("cookiebox").'/'.$namespace.'_cookie_'.WebGUI::URL::escape($session{var}{sessionId}).'.jar';
   $jar = HTTP::Cookies->new(File => $cookiebox, AutoSave => 1);

   if($session{form}{wid} == $_[0]->get("wobjectId") && $session{form}{func}!~/editSave/i) {
      $proxiedUrl = $session{form}{FormAction} || $session{form}{proxiedUrl} || $_[0]->get("proxiedUrl") ;
   } else {
      $proxiedUrl = $_[0]->get("proxiedUrl");
      $session{env}{REQUEST_METHOD}='GET';
   }

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

      if($session{env}{REQUEST_METHOD}=~/GET/i 
         || $redirect != 0) {  # request_method is also GET after a redirection. Just to make sure we're
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
   
      if($response->content_type eq "text/html" || 
        ($response->content_type eq "" && $content=~/<html/gis)) {
  
         my $p = WebGUI::ProxyParse->new($proxiedUrl, $content, $_[0]->get("wobjectId"));
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
      } elsif ($response->content_type eq "text/plain") {
         $content = '<PRE>'.HTML::Entities::encode($response->content).'</PRE>';
      } elsif ($response->content_type =~ /image\//i) {
         $content = '<p align="center"><img src='.$proxiedUrl.' border=0></p>';
      } elsif ($response->content_type ne "") { # content_type we don't know about
         $content = "<h1>Can't proxy \"".($response->content_type)."\" content.</h1>
      	          Try Fetching it directly <a href='$proxiedUrl'>here</a>.";
      } else {
         $content = "<H1>The request didn't return any data.</H1>
   		  Try Fetching it directly <a href='$proxiedUrl'>here</a>.";
      } 
   } else { # Fetching page failed...
      $content = "<b>Getting <a href='$proxiedUrl'>$proxiedUrl</a> failed</b>".
   	      "<p><i>GET status line: ".$response->status_line."</i>";
   }
   return $output.$content;
}
1;
