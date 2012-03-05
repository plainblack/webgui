package WebGUI::Auth::OAuth2;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com			info@plainblack.com
#-------------------------------------------------------------------
use strict;
use base 'WebGUI::Auth';
use Net::OAuth2::Client;
use JSON;
my $VERSION = '0.0.1';

=head1 WebGUI::Auth::OAuth2

=head2  A WebGUI Authentication module implementation of the OAuth2 framework
    
    "OAuth 2.0 is the next evolution of the OAuth protocol which was originally created in late 2006.
	  
	  OAuth 2.0 focuses on client developer simplicity while providing specific authorization flows
     for web applications, desktop applications, mobile phones, and living room devices.
     This specification is being developed within the IETF OAuth WG and is based on the OAuth WRAP proposal."
    
    Reference: OpenID Foundation (http://oauth.net/2/)

    WebGUI::Auth::OAuth2 Developer:  Daniel Maldonado   
                                     danny_mk@yahoo.com
                 
=cut

#----------------------------------------------------------------------------

=head2 new ( ... )

Create a new object

=cut

sub new {
   my $self = shift->SUPER::new(@_);
   return bless $self, __PACKAGE__; # Auth requires rebless
}

#-------------------------------------------------------------------

=head2 _client
  
=cut

sub _client {
   my $self = shift;
	my $session = $self->session;
	my ( $scratch, $setting, $url ) = $session->quick( qw( scratch setting url ) );
   my $className = $self->_getClassName; 	
   my $provider = $scratch->get( "${className}_provider" );

	my @providerSessings = split( '\n', $setting->get( "${className}Providers" ) );
	my $config = undef;
	foreach my $providerSetting ( @providerSessings ){
		my ( $savedProvider, $savedSite, $savedId, $savedSecret ) = split( ',', $providerSetting );
      if ( $savedProvider eq $provider ){
		   $config = {
		      id     => $savedId,
				secret => $savedSecret,
				site   => $savedSite
			};
		   last; # ugly but sometimes necessary
		}
		  
	}
	
   if ( $config ){
		my $returnToPage = qq|op=auth&authType=${className}&method=callback|; # Redirect URL's have problems with the semicolon ";"
	   my $return_to = $url->page( $returnToPage, 1, 1 );
	   $session->errorHandler->debug( $self->_i18n->get("return page") . $return_to );
	
      return Net::OAuth2::Client->new(
      	$config->{id},
	      $config->{secret},
   	   site => $config->{site}
      )->web_server( redirect_uri => $return_to );
		
	}
}
      
#-------------------------------------------------------------------

=head2 _checkOAuth2SecurityLists
  
  Private method wich attempts to match patterns in the Accept and Deny Admin settings.
  
  Accept list override Deny lists.  If there is a pattern in the accept list the 
  identity MUST contain the pattern and the Deny list is not checked.
  
  If there are no entries in the accept list then the Deny list is checked.  If the 
  identity is matched to a pattern from the deny list then the user is not allowed to Authenticate.
  
  If there are no entries in the Accept or Deny lists then all Provider Validated accounts are
  allowed access.

=cut

sub _checkOauthSecurityLists {
   my $self = shift; 
   my $openIdUri = shift;
   my $className = $self->_getClassName; 
	
   my $session = $self->session;
   my ( $setting ) = $session->quick(qw( setting ));	
   
   my @acceptList = split( '\n', $setting->get( "${className}AcceptList" ) );
   chomp(@acceptList);
   
   my $currentPattern = undef;
   
   if ( @acceptList ){
      while($currentPattern = shift(@acceptList)){
         $currentPattern =~ s/\s//g;
         if ($currentPattern && $openIdUri =~ m/$currentPattern/g ){
            return 1; # Good it is on the accept list
         }
      }
      $self->session->errorHandler->security( $self->_i18n->get('warnNoMatchAcceptList') . "[$openIdUri]");
      return;   
   }

   my @denyList = split( '\n', $setting->get( "${className}DenyList" ));
   chomp(@denyList);
   
   if ( @denyList ){
      while($currentPattern = shift(@denyList)){
         $currentPattern =~ s/\s//g;
         if ($currentPattern && $openIdUri =~ m/$currentPattern/g ){
            # found it on the deny list
            $session->errorHandler->security( $self->_i18n->get('warnFoundOnDenyList') . "[$openIdUri][$currentPattern]");
            return;
         }
      }
   }

   return 1;
}

#-------------------------------------------------------------------
sub _i18n{
   my $self = shift;
   my $className = $self->_getClassName; 
   return WebGUI::International->new( $self->session, "Auth_${className}" )
}

#-------------------------------------------------------------------
# Returns the name of the class without the full package name
sub _getClassName{
   return __PACKAGE__ =~ m/(.*)::(.*)$/ ? $2 : "";
}

#-------------------------------------------------------------------

=head2 _getUserName(hash profile)
  
  Private method used to get the actual username from within WebGUI by
  matching the ... entered in the login form.

  Returns username if found or "" when there is no match for the ...

=head3 ...

  A string value representing a valid openId URI.  

  For more information on ... please do an Inernet search using your 
  favorite search engine.

=cut

sub _getUser{
   my $self = shift;
   my $className = $self->_getClassName;
   
   if ( my $username = shift ){
      my $session = $self->session;
      my ( $db ) = $session->quick( qw( db ) );	
      my $userId  = $db->quickScalar( 
         "SELECT userId FROM authentication WHERE authMethod = ? AND fieldName = ? AND fieldData = ?",
         [ $className, "username", $username ]
      );
     
      # Returning user
      if ( $userId ) {
         $session->errorHandler->debug( "userid: $userId" ); 
         return WebGUI::User->new( $session, $userId );
         
      }     
   }
}

#----------------------------------------------------------------------------

=head2 _getTemplateChooseUsername ( )

Get the template to choose a username

=cut

sub _getTemplateChooseUsername {
   my ( $self ) = @_;
   $self->session->errorHandler->debug( $self->_i18n->get('return user template') . $self->_getClassName . "TemplateIdChooseUsername" );
   my $templateId = $self->session->setting->get( $self->_getClassName . "TemplateIdChooseUsername" );
   $self->session->errorHandler->debug( 'templateid: ' . $templateId );   
   return WebGUI::Asset::Template->new( $self->session, $templateId );
}

#----------------------------------------------------------------------------

=head2 editUserSettingsForm ( )

Return the form to edit the settings of this Auth module

=cut

sub editUserSettingsForm {
   my $self = shift;
   my $className = $self->_getClassName;
   my $session = $self->session;
   my ( $setting ) = $session->quick(qw( setting ));

   my $f = WebGUI::HTMLForm->new( $session );

   $f->yesNo(
      name        => "${className}Enabled",
      value       => $setting->get( "${className}Enabled" ),
      label       => $self->_i18n->get('enabled'),
      hoverHelp   => $self->_i18n->get('enabled help')
   );
   
   $f->textarea(
      name        => "${className}Providers",
      value       => $setting->get( "${className}Providers" ),
      label       => $self->_i18n->get('provider list'),
      hoverHelp   => $self->_i18n->get('provider list help'),
      rows        => 5,
      cols        => 40
   );
	
   $f->textarea(
      name        => "${className}AcceptList",
      value       => $setting->get( "${className}AcceptList" ),
      label       => $self->_i18n->get('accept list'),
      hoverHelp   => $self->_i18n->get('accept list help'),
      rows        => 5,
      cols        => 40
   );

   $f->textarea(
      name        => "${className}DenyList",
      value       => $setting->get( "${className}DenyList" ),
      label       => $self->_i18n->get('deny list'),
      hoverHelp   => $self->_i18n->get('deny list help'),
      rows        => 5,
      cols        => 40
   );

   $f->template(
      name        => "${className}TemplateIdChooseUsername",
      value       => $setting->get( "${className}TemplateIdChooseUsername" ),
      label       => $self->_i18n->get('choose username template'),
      hoverHelp   => $self->_i18n->get('choose username template help'),
      namespace   => 'Auth/OAuth2/ChooseUsername'
   );   

   return $f->printRowsOnly;
}

#----------------------------------------------------------------------------

=head2 editUserSettingsFormSave ( )

Process the form for this Auth module's settings

=cut

sub editUserSettingsFormSave {
   my $self    = shift;
   my $className = $self->_getClassName;
   my $session = $self->session;
   my ( $form, $setting ) = $session->quick(qw( form setting ));

   $setting->set( "${className}Enabled",    $form->get( "${className}Enabled" ) );
   $setting->set( "${className}Providers",  $form->get( "${className}Providers" ) );	
   $setting->set( "${className}AcceptList", $form->get( "${className}AcceptList" ) );
   $setting->set( "${className}DenyList",   $form->get( "${className}DenyList" ) );
   $setting->set( "${className}TemplateIdChooseUsername", $form->get( "${className}TemplateIdChooseUsername" ) );   

   return;
}

#-----------------------------------------------------------------------------------------------
#
#  
#
#-----------------------------------------------------------------------------------------------
sub www_login{
   my $self = shift;
   my $className = $self->_getClassName;
   my $session = $self->session;
   my ( $form, $http, $scratch, $setting ) = $session->quick( qw( form http scratch setting ) );
   
   my $provider = $form->process('provider');  
   # Do not allow the users to use this module unless it is enabled
   if ( ! $setting->get( "${className}Enabled" ) ){	  
      $session->errorHandler->security( sprintf( $self->_i18n->get( 'disabled' ), $provider ) );
      $self->logout();
      return $self->displayLogin;
   }
  
   # Make sure anonymous registration is enabled 
   if ( ! $setting->get("anonymousRegistration") ) {
      $session->errorHandler->security( $self->_i18n->get( 'no registration hack' ) );
      return $self->displayLogin;
   }
	
	if ( $provider && $self->_checkOauthSecurityLists( $provider ) ){  
	   $scratch->set( "${className}_provider", $provider );
	   if ( my $redirectUrl = $self->_client->authorize_url ){	  
		   $http->setRedirect( $redirectUrl );
	      $http->sendHeader();
		   return;
			
		}else{
          $session->errorHandler->info( 'url setup' );
			 
		}
              
   }

	$session->errorHandler->security( sprintf( $self->_i18n->get("invalid provider") ) );      
   $self->logout(); # make sure the user is logged out

}

#-------------------------------------------------------------------

=head2 sub www_callback ( )

   On the trip back from the provider.

=cut

sub www_callback {
   my $self = shift;
   my $className = $self->_getClassName;
   my $session = $self->session;
   my ( $form, $scratch, $setting ) = $session->quick( qw( form scratch setting ) );

   my $error = "";
   if ( my $access_token = $self->_client->get_access_token( $form->process('code') ) ){
		# Use the access token to fetch a protected resource
      my $response = $access_token->get('/me');  
		  
		# Do something with said resource...
      if ( $response->is_success ) {
		   my $data = decode_json( $response->decoded_content );
         # if this user already exists just login
         if ( my $user = $self->_getUser( $data->{email} )  ){
            $self->user( $user );
            $self->login();
            return;
         
         }else{
            # if the users does not exists try to create a new user
            $session->errorHandler->debug( "Creating new user with email: " . $data->{email} );
				$scratch->set( "${className}_email", $data->{email} );
            my $tmpl = $self->_getTemplateChooseUsername;
            my $var = {
               message => $self->_i18n->get( "create webgui username" )
            };
            return $tmpl->process( $var );		
		  
		   }
		
      } else {
         $session->errorHandler->warn("Got invalid response from provider: " . $response->status_line);		  
         $error = $self->_i18n->get('error default') . $response->status_line;
      
		}
		  
	}else{
      $session->errorHandler->warn("Invalid access token!");		  
      $error = $self->_i18n->get('invalid access token');
		  
	}
   $self->error($error);
   $session->errorHandler->error($error) if $error;

   # Return 1 on successful authentication
   return $error eq "";
}

#----------------------------------------------------------------------------

=head2 www_setUsername ( )


=cut

sub www_setUsername {
   my ( $self ) = @_;
   my $session = $self->session;
   my ( $form, $scratch, $db ) = $session->quick( qw( form scratch db ) );
   my $className = $self->_getClassName();
   
   $session->errorHandler->info( "Getting ${className}_email value" );
   my $userEmail = $scratch->get( "${className}_email" );
   $session->errorHandler->info( 'User email: ' . $userEmail );
   # Don't allow just anybody to set a username
   return unless $userEmail;

   my $username = $form->get( 'newUsername' );
   if ( ! WebGUI::User->newByUsername( $session, $username ) ) {
      $session->errorHandler->info( 'create new user: ' . $username );
        
      my $user = WebGUI::User->create( $self->session );
      $user->username( $username );
      $self->saveParams( $user->userId, $self->authMethod, { "username" => $username, "email" => $userEmail } );        
      $self->user( $user );
      return $self->login;
      
    }

    $session->errorHandler->info( $self->_i18n->get( "webgui username taken" ) . $username );
    # Username is again taken! Noooooo!
    my $tmpl = $self->_getTemplateChooseUsername;
    my $var = {
       message => sprintf( $self->_i18n->get( "webgui username taken" ), $username )
    };

    return $tmpl->process( $var );
}

1;
