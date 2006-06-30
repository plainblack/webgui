package WebGUI::Asset::Wobject::WSClient;

use strict;
use Data::Structure::Util;
use Data::Dumper;
use Digest::MD5;
use SOAP::Lite;
use Storable;
use WebGUI::Cache;
use WebGUI::International;
use WebGUI::Macro;
use WebGUI::Paginator;
use WebGUI::Asset::Wobject;

our @ISA = qw(WebGUI::Asset::Wobject);


#-------------------------------------------------------------------
sub _create_cache_key {
   my ($self, $call, $param_str) = @_;
   my $cache_key;
   $cache_key = $_[0]->get('sharedCache')
      ? Digest::MD5::md5_hex($call, $param_str)
      : Digest::MD5::md5_hex($call, $param_str, $self->session->getId);
   $self->session->errorHandler->warn(($_[0]->get('sharedCache')?'shared':'session')
      . " cache_key=$cache_key md5_hex($call, $param_str)");
   return $cache_key;
}


#-------------------------------------------------------------------
sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift;
my $httpHeaderFieldType;
   if ($session->config->get('soapHttpHeaderOverride')) {
      $httpHeaderFieldType = 'text';
   } else {
      $httpHeaderFieldType = 'hidden';
   }
	my $i18n = WebGUI::International->new($session, "Asset_WSClient");
	push(@{$definition}, {
		assetName=>$i18n->get('assetName'),
		uiLevel=>9,
		icon=>'web_services.gif',
		tableName=>'WSClient',
		className=>'WebGUI::Asset::Wobject::WSClient',
		properties=>{
			templateId =>{
				fieldType=>"template",
				defaultValue=>'PBtmpl0000000000000069'
				},
         callMethod             => {
            fieldType     => 'textarea',
		defaultValue=>undef
         },
         debugMode        => {
            fieldType     => 'integer',
            defaultValue  => 0,
         },
         execute_by_default => {
            fieldType     => 'yesNo',
            defaultValue  => 1,
         },
         paginateAfter    => {
            defaultValue  => 100,
		fieldType=>"integer"
         },
         paginateVar    => {
            fieldType     => 'text',
		defaultValue=>undef
         },
         params           => {
            fieldType     => 'textarea',
         },
         preprocessMacros => {
            fieldType     => 'integer',
            defaultValue  => 0,
         },
         proxy            => {
            fieldType     => 'text',
            defaultValue  => $session->config->get('soapproxy'),
         },
         uri              => {
            fieldType     => 'text',
            defaultValue  => $session->config->get('soapuri')
         },
         decodeUtf8       => {
            fieldType     => "yesNo",
            defaultValue  => 0,
         },
         httpHeader       => {
            fieldType     => $httpHeaderFieldType,
		defaultValue=>undef
         },
         cacheTTL         => {
            fieldType     => 'interval',
            defaultValue  => 60,
         },
         sharedCache      => {
            fieldType     => 'integer',
            defaultValue  => '0',
         }
		}
		});
        return $class->SUPER::definition($session, $definition);
}



#-------------------------------------------------------------------
sub getEditForm {
	my $self = shift;
	my $tabform = $self->SUPER::getEditForm();
	my $i18n = WebGUI::International->new($self->session, "Asset_WSClient");
   $tabform->getTab("display")->template(
      -name      => 'templateId',
      -value     => $self->getValue('templateId'),
      -namespace => "WSClient",
      -label => $i18n->get(72),
      -hoverHelp => $i18n->get('72 description'),
   );
   $tabform->getTab("display")->yesNo (
      -name  => 'preprocessMacros',
      -label => $i18n->get(8),
      -hoverHelp => $i18n->get('8 description'),
      -value => $self->get('preprocessMacros'),
   );
  	$tabform->getTab("display")->integer(
      -name  => 'paginateAfter',
      -label => $i18n->get(13),
      -hoverHelp => $i18n->get('13 description'),
      -value => $self->getValue("paginateAfter")
   );
   $tabform->getTab("display")->text (
      -name  => 'paginateVar',
      -label => $i18n->get(14),
      -hoverHelp => $i18n->get('14 description'),
      -value => $self->get('paginateVar'),
   );
   $tabform->getTab("properties")->text (
      -name  => 'uri',
      -label => $i18n->get(2),
      -hoverHelp => $i18n->get('2 description'),
      -value => $self->get('uri'),
   );
   $tabform->getTab("properties")->text (
      -name  => 'proxy',
      -label => $i18n->get(3),
      -hoverHelp => $i18n->get('3 description'),
      -value => $self->get('proxy'),
   );
   $tabform->getTab("properties")->text (
      -name  => 'callMethod',
      -label => $i18n->get(4),
      -hoverHelp => $i18n->get('4 description'),
      -value => $self->get('callMethod'),
   );
   $tabform->getTab("properties")->textarea ( 
      -name  => 'params',
      -label => $i18n->get(5),
      -hoverHelp => $i18n->get('5 description'),
      -value => $self->get('params'),
   );
   if ($self->session->config->get('soapHttpHeaderOverride')) {
      $tabform->getTab("properties")->text (
         -name  => 'httpHeader',
         -label => $i18n->get(16),
         -hoverHelp => $i18n->get('16 description'),
         -value => $self->get('httpHeader'),
      );
   } else {
      $tabform->getTab("properties")->hidden (
         -name  => 'httpHeader',
         -label => $i18n->get(16),
         -value => $self->get('httpHeader'),
      );
   }
   $tabform->getTab("properties")->yesNo (
      -name  => 'execute_by_default',
      -label => $i18n->get(11),
      -hoverHelp => $i18n->get('11 description'),
      -value => $self->get('execute_by_default'),
   );
   $tabform->getTab("properties")->yesNo (
      -name  => 'debugMode',
      -label => $i18n->get(9),
      -hoverHelp => $i18n->get('9 description'),
      -value => $self->get('debugMode'),
   );
      $tabform->getTab("properties")->yesNo (
         -name  => 'decodeUtf8',
         -label => $i18n->get(15),
         -hoverHelp => $i18n->get('15 description'),
         -value => $self->get('decodeUtf8'),
      );
   my $cacheopts = {
	0 => $i18n->get(29),
	1 => $i18n->get(19),
   };
   $tabform->getTab("properties")->radioList (
      -name    => 'sharedCache',
      -options => $cacheopts,
      -label   => $i18n->get(28),
      -hoverHelp   => $i18n->get('28 description'),
      -value   => $self->get('sharedCache'),
   );
   $tabform->getTab("properties")->interval (
      -name     => 'cacheTTL',
      -label    => $i18n->get(27),
      -hoverHelp    => $i18n->get('27 description'),
      -value    => $self->get('cacheTTL'),
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
sub view {
   my ( $arr_ref,                      # temp var holding params
        $cache_key,                    # unique cache identifier
        $cache,                        # cache object
        $call,                         # SOAP method call
	@exclude_params,               # input params NOT to pass to next pg
        $p,                            # pagination object
        $param_str,                    # raw SOAP params before parsing
        @params,                       # params to soap method call	
	$query_string,                 # query string to pass thru to next pg
        @result,                       # SOAP result reference	
	%seen,                         # counts diff bxt input & output params
        $soap,                         # SOAP object
        @targetWobjects,               # list of non-default wobjects to exec
        $url,                          # current page url
        %var                          # HTML::Template variables
   );
   my $self= shift;
   # this page, with important params
   $url = $self->getUrl("func=view");
	my $i18n = WebGUI::International->new($self->session, "Asset_WSClient");

    # This could belong up towards the top of the script, but it's nice to
    # have it down right close to the impacted code.  Add to this list params
    # that should never, ever be passed across multiple results pages
    @exclude_params = qw(cache func pn wid);

   # this page, with important params
    @seen{@exclude_params} = ();
    foreach ($self->session->form->param) {
       unless (exists $seen{$_}) {
          $query_string .= $self->session->url->escape($_) . '='
             . $self->session->url->escape($self->session->form->process($_)) . ';';
       }
    }
    $url = $self->session->url->page($query_string);


   # snag our SOAP call and preprocess if needed
   if ($self->get('preprocessMacros')) {
	$call = $self->get("callMethod");
       WebGUI::Macro::process($self->session,\$call);
	$param_str = $self->get("params");
      WebGUI::Macro::process($self->session,\$param_str);
    } else {
       $call        = $self->get('callMethod');
       $param_str   = $self->get('params');
   }

   # see if we can shortcircuit this whole process
   if ((ref $self->session->form->process('disableWobjects') && grep /^$call$/,
         @{$self->session->form->process('disableWobjects')}) ||
        ($self->session->form->process('disableWobjects') && grep /^$call$/,
         $self->session->form->process('disableWobjects'))) {
                                                                                
      $self->session->errorHandler->warn("disabling soap call $call");
      $var{'disableWobject'} = 1;
      return $self->processTemplate(\%var,$self->get("templateId"));
   }

   # advanced use, if you want to pass SOAP results to a single, particular
   # wobject on a page
   if (ref $self->session->form->process('targetWobjects')) {
      @targetWobjects = @{$self->session->form->process('targetWobjects')};
   } else {
      push @targetWobjects, $self->session->form->process('targetWobjects');
   }

   # check to see if this exact query has already been cached, using either
   # a cache specific to this session, or a shared global cache
   if ($self->session->form->process('cache')) {
      if ($self->session->form->process('targetWobjects')
         && grep /^$call$/, @targetWobjects) {

         $cache_key = $self->session->form->process('cache');
         $self->session->errorHandler->warn("passed a cache_key for $call");
      } else {
         $self->session->errorHandler->warn("cache_key not applicable to $call ");
         $cache_key = _create_cache_key($self, $call, $param_str);
      }
   } else {
      $cache_key = _create_cache_key($self, $call, $param_str);
   }
   $cache = WebGUI::Cache->new($self->session,$cache_key,
      $i18n->get(4));

   # passing a form param WSClient_skipCache lets us ignore even good caches
   if (!$self->session->form->process('WSClient_skipCache')) {
      @result = Storable::thaw($cache->get);
   }
   
   # prep SOAP unless we found cached data
   if (!$result[0]) {
      # this is the magic right here.  We're allowing perl to parse out 
      # the ArrayOfHash info so that we don't have to regex it ourselves
      # FIXME:  we need to protect against eval-ing unknown strings
      # the solution is to normalize all params to another table
      eval "\$arr_ref = [$param_str];";
      eval { @params = @$arr_ref; };
      $self->session->errorHandler->debug($i18n->get(22)) if $@ && $self->get('debugMode');

      if ($self->get('execute_by_default') || grep /^$call$/,
         @targetWobjects) {

         # there's certainly a better pattern match than this to check for 
         # valid looking uri, but I haven't hunted for the relevant RFC yet
         if ($self->get("uri") =~ m!.+/.+!) {

            $self->session->errorHandler->debug('uri=' . $self->get("uri"))
               if $self->get('debugMode');
            $soap = $self->_instantiate_soap;

         } else {
            $self->session->errorHandler->debug($i18n->get(23)) if $self->get('debugMode');
         }
      }
   }

   # continue if our SOAP connection was successful or we have cached data
   if (defined $soap || $result[0]) {

      if (!$result[0]) {
         eval {
            # here's the rub.  `perldoc SOAP::Lite` says, "the method in
            # question will return the current object (if not stated
            # otherwise)".  That "not stated otherwise" bit is important.
            my $return = $soap->$call(@params);
         
            $self->session->errorHandler->debug("$call(" . (join ',', @params) . ')')
               if $self->get('debugMode');

            # The possible return types I've come across include a SOAP object,
            # a hash reference, a blessed object or a simple scalar.  Each type
            # requires different handling (woohoo!) before being passed to the
            # template system
            $self->session->errorHandler->debug($i18n->get(24) .  (ref $return ? ref $return : 'scalar')) if $self->get('debugMode');

            # SOAP object
            if ((ref $return) =~ /SOAP/i) {
               @result = $return->paramsall;

            # hashref
            } elsif (ref $return eq 'HASH') {
               @result = $return;

            # blessed object, to be stripped with Data::Structure::Util
            } elsif ( ref $return) {
               $self->session->errorHandler->warn("Data::Structure::Util::unbless($return)");
               @result = Data::Structure::Util::unbless($return);

            # scalar value, we hope
            } else {
               # there's got to be a way to get into the SOAP body and find the
               # key name for the value returned, but I haven't figured it out
               @result = { 'result' => $return };
            }

            $cache->set(Storable::freeze(@result),
               $self->get('cacheTTL'));
         };

         # did the soap call fault?
         if ($@) {
            $self->session->errorHandler->debug($@) if $self->get('debugMode');
            $var{'soapError'} = $@;
            $self->session->errorHandler->debug($i18n->get(25) . $var{'soapError'})
               if $self->get('debugMode');
         }

      # cached data was found
      } else {
         $self->session->errorHandler->warn("Using cached data");
      }

        $self->session->errorHandler->debug(Dumper(@result)) if     
           $self->get('debugMode');

      # Do we need to decode utf8 data?  Will only decode if modules were
      # loaded and the wobject requests it
      if ($self->{'decodeUtf8'}) {
         if (Data::Structure::Util::has_utf8(\@result)) {
            @result = @{Data::Structure::Util::utf8_off(\@result)};
         }
      }

      # pagination is tricky because we don't know the specific portion of the
      # data we need to paginate.  Trust the user to have told us the right 
      # thing.  If not, try to Do The Right Thing
      if (scalar @result > 1) {
         # this case hasn't ever happened running against my dev SOAP::Lite
         # services, but let's assume it might.  If our results array has
         # more than one element, let's hope if contains scalars
         $p = WebGUI::Paginator->new($self->session,$url, $self->get('paginateAfter'));
	$p->setDataByArrayRef(\@result);
         @result = ();
         @result = @$p;

      } else {

         # In my experience, the most common case.  We have an array
         # containing a single hashref for which we have been given a key name
         if (my $aref = $result[0]->{$self->get('paginateVar')}) {

            $var{'numResults'} = scalar @$aref;
            $p = WebGUI::Paginator->new($self->session,$url,  $self->get('paginateAfter'));
		$p->setDataByArrayRef($aref);
            $result[0]->{$self->get('paginateVar')} = $p->getPageData;

         } else {

            if ((ref $result[0]) =~ /HASH/) {

               # this may not paginate the one that they want, but it will
               # prevent the wobject from dying
               for (keys %{$result[0]}) {
                  if ((ref $result[0]->{$_}) =~ /ARRAY/) {
                       $p = WebGUI::Paginator->new($self->session,$url,  $self->get('paginateAfter'));
			$p->setDataByArrayRef($result[0]->{$_});
                     last;
                  }
               }
               $p ||= WebGUI::Paginator->new($self->session,$url);
               $result[0]->{$_} = $p->getPageData;
               
            } elsif ((ref $result[0]) =~ /ARRAY/) {
               $p = WebGUI::Paginator->new($self->session,$url, $self->get('paginateAfter'));
		$p->setDataByArrayRef($result[0]);
               $result[0] = $p->getPageData;

            } else {
               $p = WebGUI::Paginator->new($self->session,$url, $self->get('paginateAfter'));
		$p->setDataByArrayRef([$result[0]]);
               $result[0] = $p->getPageData;
            }
         }
      }

      # set pagination links
      if ($p) {
	$p->appendTemplateVars(\%var);
         for ('pagination.firstPage','pagination.lastPage','pagination.nextPage','pagination.pageList',
		'pagination.previousPage', 'pagination.pageList.upTo20', 'pagination.pageList.upTo10') {
            $var{$_} =~ s/\?/\?cache=$cache_key\;/g;
         }
      }
   } else {
      $self->session->errorHandler->debug($i18n->get(26) . $@) if $self->get('debugMode');
   }
   # did they request a funky http header?
   if ($self->session->config->get('soapHttpHeaderOverride') &&
      $self->get("httpHeader")) {

      $self->session->http->setMimeType($self->get("httpHeader"));
      $self->session->errorHandler->warn("changed mimetype: " .  $self->get("httpHeader"));
   }

   # Note, we still process our template below even though it will never
   # be displayed if the redirectURL is set.  Not sure how important it is
   # to do it this way, but it certainly is the least obtrusive to default
   # webgui flow.  This feature currently requires a patched WebGUI.pm file.
   if ($self->session->form->process('redirectURL')) {
    $self->session->http->setRedirect($self->session->form->process('redirectURL'));
   }

   $var{'results'} = \@result;
   return $self->processTemplate(\%var, undef, $self->{_viewTemplate});
}   


sub _instantiate_soap {
   my ($soap, @wobject);
   my $self = shift;

   # a wsdl file was specified
   # we don't use fault handling with wsdls becuase they seem to behave 
   # differently.  Not sure if that is by design.
     if ( ($self->get("uri") =~ m/\.wsdl\s*$/i) || ($self->get("uri") =~ m/\.\w*\?wsdl\s*$/i) ) {
      $self->session->errorHandler->debug('wsdl=' . $self->get('uri'))
         if $self->get('debugMode');

      # instantiate SOAP service
      $soap = SOAP::Lite->service($self->get('uri'));
                                                                                
   # standard uri namespace
   } else {
      $self->session->errorHandler->debug('uri=' . $self->get('uri'))
         if $self->get('debugMode');

      # instantiate SOAP service, with fault handling
      $soap = new SOAP::Lite     
         on_fault => sub {    
            my ($soap, $res) = @_;     
     	    die ref $res ? $res->faultstring : $soap->transport->status, "\n";
         };
      $soap->uri($self->get('uri'));
                                                                                
      # proxy the call if requested
      if ($self->get("proxy") && $soap) {

         $self->session->errorHandler->debug('proxy=' . $self->get('proxy'))
            if $self->get('debugMode');
         $soap->proxy($self->get('proxy'),
            options => {compress_threshold => 10000});
      }
   }

   return $soap;
}
1;
