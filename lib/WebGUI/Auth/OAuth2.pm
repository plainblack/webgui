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

	my @providerSettings = split( '\n', $setting->get( "${className}Providers" ) );
	my $config = undef;
	foreach my $providerSetting ( @providerSettings ){
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
	   $session->log->debug( $self->_i18n->get("return page") . $return_to );
	
      return Net::OAuth2::Client->new(
      	$config->{id},
	      $config->{secret},
   	   site => $config->{site}
      )->web_server( redirect_uri => $return_to );
		
	}
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
   
   if ( my $id = shift ){
      my $session = $self->session;
      my ( $db ) = $session->quick( qw( db ) );	
      my $userId  = $db->quickScalar( 
         "SELECT userId FROM authentication WHERE authMethod = ? AND fieldName = ? AND fieldData = ?",
         [ $className, "id", $id ]
      );
     
      # Returning user
      if ( $userId ) {
         $session->log->debug( "userid: $userId" ); 
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

   $f->template(
      name        => "${className}TemplateIdChooseUsername",
      value       => $setting->get( "${className}TemplateIdChooseUsername" ),
      label       => $self->_i18n->get('choose username template'),
      hoverHelp   => $self->_i18n->get('choose username template help'),
      namespace   => qq|Auth/${className}/ChooseUsername|
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
	
	if ( $provider ){  
	   $scratch->set( "${className}_provider", $provider );
	   if ( my $redirectUrl = $self->_client->authorize_url ){	  
		   $http->setRedirect( $redirectUrl );
	      $http->sendHeader();
		   return;
			
		}else{
         $session->log->debug( 'redirect url setup failed' );
			 
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
         if ( my $user = $self->_getUser( $data->{id} )  ){
            $self->user( $user );
            $self->login();
            return;
         
         }else{
            # if the users does not exists try to create a new user
				$scratch->set( "${className}_id", $data->{id} );
				$scratch->set( "${className}_email", $data->{email} );
            my $tmpl = $self->_getTemplateChooseUsername;
            my $var = {
               message => $self->_i18n->get( "create webgui username" )
            };
            return $tmpl->process( $var );
		  
		   }
		
      } else {
         $session->log->warn("Got invalid response from provider: " . $response->status_line);		  
         $error = $self->_i18n->get('error default') . $response->status_line;
      
		}
		  
	}else{
      $session->log->warn("Invalid access token!");		  
      $error = $self->_i18n->get('invalid access token');
		  
	}
   $self->error($error);
   $session->log->error($error) if $error;

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
   
   $session->log->debug( "Getting ${className}_email value" );
   my $id = $scratch->get( "${className}_id" );
   # Don't allow just anybody to set a username
   return unless $id;

   my $username = $form->get( 'newUsername' );
	my $email = $form->get( 'email' ) || $scratch->get( "${className}_email" );	
   if ( $username =~ /\S/ && ! WebGUI::User->newByUsername( $session, $username ) ) {
      $session->log->debug( 'create new user: ' . $username );		  
      my $user = WebGUI::User->create( $self->session );
      $user->username( $username );
		$user->profileField( 'email', $email );
      $self->saveParams( $user->userId, $self->authMethod, { id => $id } );        
      $self->user( $user );
      return $self->login;
      
    }

    $session->log->debug( $self->_i18n->get( "webgui username taken" ) . $username );
    # Username is again taken! Noooooo!
    my $tmpl = $self->_getTemplateChooseUsername;
    my $var = {
       message => sprintf( $self->_i18n->get( "webgui username taken" ), $username )
    };

    return $tmpl->process( $var );
}

1;
