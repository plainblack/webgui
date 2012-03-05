package WebGUI::Auth::OpenId;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2007 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com			info@plainblack.com
#-------------------------------------------------------------------
use strict;
use base 'WebGUI::Auth';
use HTTP::Request;
use JSON; # used to read the return values from the provider
use LWPx::ParanoidAgent;
use Net::OpenID::Consumer;
my $VERSION = '0.0.1';

=head1 WebGUI::Auth::OpenId

=head2  A WebGUI Authentication module implementation of the OpenId framework
    
    "OpenID is an open, decentralized, free framework for user-centric digital identity.

    OpenID starts with the concept that anyone can identify themselves on the Internet 
    the same way websites do-with a URI (also called a URL or web address). Since URIs 
    are at the very core of Web architecture, they provide a solid foundation 
    for user-centric identity.

    The first piece of the OpenID framework is authentication -- how you prove ownership of a URI. 
    Today, websites require usernames and passwords to login, which means that many people use the 
    same password everywhere. 
    
    With OpenID Authentication (see specs), your username is your URI, and your 
    password (or other credentials) stays safely stored on your 
    OpenID Provider (which you can run yourself, or use a third-party identity provider).

    To login to an OpenID-enabled website (even one you've never been to before), 
    just type your OpenID URI. The website will then redirect you to your OpenID Provider to 
    login using whatever credentials it requires. Once authenticated, your OpenID provider will 
    send you back to the website with the necessary credentials to log you in. 
    By using Strong Authentication where needed, the OpenID Framework can be used for all 
    types of transactions, both extending the use of pure single-sign-on as well as the 
    sensitivity of data shared."
    
    Reference: OpenID Foundation (http://openid.net)

    WebGUI::Auth::OpenId Developer:  Daniel Maldonado   
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

=head2 _checkOpenIdSecurityLists
  
  Private method wich attempts to match patterns in the Accept and Deny Admin settings.
  
  Accept list override Deny lists.  If there is a pattern in the accept list the 
  openId identity MUST contain the pattern and the Deny list is not checked.
  
  If there are no entries in the accept list then the Deny list is checked.  If the openId 
  identity is matched to a pattern from the deny list then the user is not allowed to Authenticate.
  
  If there are no entries in the Accept or Deny lists then all Provider Validated accounts are
  allowed access.

=cut

sub _checkOpenIdSecurityLists {
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
  matching the OpenIdUri entered in the login form.

  Returns username if found or "" when there is no match for the openIdUri

=head3 openIdUri

  A string value representing a valid openId URI.  

  For more information on OpenId please do an Inernet search using your 
  favorite search engine.

=cut

sub _getUser{
   my $self = shift;
   my $className = $self->_getClassName;
   
   if ( my $openIdUri = shift ){
      my $session = $self->session;
      my ( $db ) = $session->quick( qw( db ) );	
      my $userId  = $db->quickScalar( 
         "SELECT userId FROM authentication WHERE authMethod = ? AND fieldName = ? AND fieldData = ?",
         [ $className, "identity", $openIdUri ]
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
      name        => "${className}AcceptList",
      value       => $setting->get( "${className}AcceptList" ),
      label       => $self->_i18n->get('accept list'),
      hoverHelp   => $self->_i18n->get('accept list help'),
      rows        => 10,
      cols        => 40
   );

   $f->textarea(
      name        => "${className}DenyList",
      value       => $setting->get( "${className}DenyList" ),
      label       => $self->_i18n->get('deny list'),
      hoverHelp   => $self->_i18n->get('deny list help'),
      rows        => 10,
      cols        => 40
   );
   
   $f->template(
      name        => "${className}TemplateIdChooseUsername",
      value       => $setting->get( "${className}TemplateIdChooseUsername" ),
      label       => $self->_i18n->get('choose username template'),
      hoverHelp   => $self->_i18n->get('choose username template help'),
      namespace   => 'Auth/OpenId/ChooseUsername'
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

   $setting->set( "${className}Enabled",    $form->get( "${className}Enabled" )    );
   $setting->set( "${className}AcceptList", $form->get( "${className}AcceptList" ) );
   $setting->set( "${className}DenyList",   $form->get( "${className}DenyList" )   );
   $setting->set( "${className}TemplateIdChooseUsername", $form->get( "${className}TemplateIdChooseUsername" )   );   

   return;
}

#-----------------------------------------------------------------------------------------------
#
#  Use OpenId or Net::OpenID::Consumer
#
#-----------------------------------------------------------------------------------------------
sub www_login{
   my $self = shift;
   my $className = $self->_getClassName;
   my $session = $self->session;
   my ( $form, $http, $id, $scratch, $url, $setting ) = $session->quick( qw( form http id scratch url setting ) );
   
   my $openIdUri = $form->process('openIdUri');
      
   # Do not allow the users to use this module unless it is enabled
   if ( ! $setting->get( "${className}Enabled" ) ){
      $session->errorHandler->security( sprintf( $self->_i18n->get( 'disabled' ), $openIdUri ) );
      $self->logout();
      return $self->displayLogin;
   }
   
   # Make sure anonymous registration is enabled 
   if ( ! $setting->get("anonymousRegistration") ) {    
      $session->errorHandler->security( $self->_i18n->get( 'no registration hack' ) );
      return $self->displayLogin;
   }   

   if ( $openIdUri ){
      # Lets check the Accept and Deny lists...      
      if ( $self->_checkOpenIdSecurityLists( $openIdUri ) ){         
         my $openIdSecret = $id->generate();
         my $csr = Net::OpenID::Consumer->new(
            ua    => LWPx::ParanoidAgent->new,
            args  => $form->paramsHashRef,
            consumer_secret => $openIdSecret
         );
      
         if ( my $claimed_identity = $csr->claimed_identity( $openIdUri ) ) {
            my $returnToPage = qq|op=auth;authType=${className};method=callback|;
            $session->errorHandler->debug( $self->_i18n->get("return page") . $returnToPage );
      
            my $return_to = $url->page( $returnToPage, 1, 1 );
            my $check_url = $claimed_identity->check_url(
               return_to  => $return_to,
               trust_root => $url->getSiteURL(),
               delayed_return  => 1
            );
            
            $scratch->set( "${className}_secret", $openIdSecret );
            $scratch->set( "${className}_uri", $openIdUri );
      
            $http->setRedirect( $check_url );
            $http->sendHeader();         
         
         }else{
            $session->errorHandler->security( sprintf( $self->_i18n->get("invalid identity"),  $openIdUri ) );
            
         }

      }
      
   }else{
      $session->errorHandler->security( sprintf( $self->_i18n->get("invalid identity"),  $openIdUri ) );      
      $self->logout(); # make sure the user is logged out
      
   }

}

#-------------------------------------------------------------------

=head2 sub www_callback ( )

   Attempt to connect to the open id provider.

   If the connection is successful and the user approves of this site
   the user is considered a valid openId user.

   Note: This method does not ensure that the user is valid in WebGUI.
   i.e., it does not validate their username or ensure their account is active.


=cut

sub www_callback {
   my $self = shift;
   my $className = $self->_getClassName;
   my $session = $self->session;
   my ( $form, $http, $scratch, $setting ) = $session->quick( qw( form http scratch setting ) );

   my $csr = Net::OpenID::Consumer->new(
      ua    => LWPx::ParanoidAgent->new,
      args  => $form->paramsHashRef,
      consumer_secret => $scratch->get( "${className}_secret" )
   );

   my $error = "";
   my $info = "";  
   if ( my $setup_url = $csr->user_setup_url ) {
      $http->setRedirect($setup_url);
      $http->sendHeader();     
      
   } elsif ( $csr->user_cancel ) {
      # restore web app state to prior to check_url
      $session->errorHandler->debug( $self->_i18n->get('error default') . $csr->user_cancel );
      
   } elsif ( my $vident = $csr->verified_identity ){
      $error = ""; #You are $verified_url !";
      
      # if this user already exists just login
      if ( my $user = $self->_getUser( $scratch->get( "${className}_uri" ) ) ){
         $self->user( $user );
         $self->login();
         return;
         
      }
      
      # if the users does not exists try to create a new user
      $session->errorHandler->debug("Creating new user!");
      my $tmpl = $self->_getTemplateChooseUsername;
      my $var = {
         message => $self->_i18n->get( "create webgui username" )
      };
      return $tmpl->process( $var );
      

   } else {
      $error = $self->_i18n->get('error default') . $csr->err; 

   }
   $self->error($error);
   $session->errorHandler->error($error) if $error;

   # Return 1 on successful authentication
   return $error eq "";
}

#----------------------------------------------------------------------------

=head2 www_setUsername ( )

Set the username for an OpenId user. Only used as part of the initial OpenId
registration.

=cut

sub www_setUsername {
   my ( $self ) = @_;
   my $session = $self->session;
   my ( $form, $scratch, $db ) = $session->quick( qw( form scratch db ) );
   my $className = $self->_getClassName();
   
   $session->errorHandler->info( "Getting ${className}_uri value" );
   my $userIdentity = $scratch->get( "${className}_uri" );
   $session->errorHandler->info( 'User identity (uri): ' . $userIdentity );
   # Don't allow just anybody to set a username
   return unless $userIdentity;

   my $username = $form->get( 'newUsername' );
   
   if ( $username =~ /\S/ && ! WebGUI::User->newByUsername( $session, $username ) ) {
      $session->errorHandler->info( 'create new user: ' . $username );
        
      my $user = WebGUI::User->create( $self->session );
      $user->username( $username );
      $self->saveParams( $user->userId, $self->authMethod, { 
         "identity" => $userIdentity,
      } );        

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