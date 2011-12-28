package WebGUI::Content::Account;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2012 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use WebGUI::Session;
use WebGUI::Exception;
use Carp qw(croak);

=head1 NAME

Package WebGUI::Content::Account

=head1 DESCRIPTION

A content handler that opens up all the account functionality. Account modules are accessed via the url like this:

 /pagename?op=module;do=www_method
 
For example:

 /home?op=profile;do=edit

In the above we're accessing the www_edit method in the WebGUI::Account::Profile module.

Module op relationships are stored in the config file as such

account : {
    "profile" : "WebGUI::Account::Profile",
    "inbox"   : "WebGUI::Account::Inbox",
    "network" : "WebGUI::Account::Network",
    "user"    : "WebGUI::Account::User",
    "custom"  : "WebGUI::Account::Custom"
}

=head1 SYNOPSIS

 use WebGUI::Content::Account;
 my $output = WebGUI::Content::Account::handler($session);

=head1 SUBROUTINES

These subroutines are available from this package:

=cut


#-------------------------------------------------------------------

=head2 createInstance ( session, module ) 

Creates an instance of an account pluggin

=head3 session

WebGUI::Session object

=head3 module

Module the method is in.  Defaults to the profileModuleIdentifier in the config file

=cut

sub createInstance {
    my $class   = shift;
    my $session = shift;
    my $module  = shift || $session->config->get("profileModuleIdentifier");

    #Get the account config to work with
    my $configs = $session->config->get("account");
    my $config  = __PACKAGE__->getAccountConfig($session,$module,$configs);

    #Throw an error if the config file isn't found
    unless (defined $config) {
        WebGUI::Error->throw( error => qq{Could not locate module $module in the account system});
        return undef;
    }

    #Create Pluggin Object
    #Don't eval this as pluggable will croak and we want the calling module to handle the exception 
    my $pluggin = WebGUI::Pluggable::instanciate(
            $config->{className},
            "new",
            [  $session, $module ]
    );
        
    #Check to make sure pluggin is a subclass of WebGUI::Account
    unless($pluggin->isa('WebGUI::Account')) {
        my $plugginType = ref $pluggin;
        WebGUI::Error::InvalidObject->throw(
            expected => 'WebGUI::Account',
            got      => $plugginType,
            error    => '$plugginType is not a subclass of WebGUI::Accout'
        );
        return undef;
    }

    return $pluggin;
}



#-------------------------------------------------------------------

=head2 getAccountConfig ( op, configs ) 

Searches the account config array passed in and returns the hash reference which
contains the op value passed in.  If no op value is found, undef is returned;

=head3 op

op to search for

=head3 configs

array ref with account config hashes

=cut

sub getAccountConfig {
    my $class   = shift;
    my $session = shift;
    my $module  = shift;
    my $configs = shift || $session->config->get("account");
        
    foreach my $config (@{$configs}) {
        return $config if ($config->{identifier} eq $module);
    }

    return undef;
}

#-------------------------------------------------------------------

=head2 handler ( session ) 

The content handler for this package.

=cut

sub handler {
    my $session = shift;
    my $form    = $session->form;
    my $setting = $session->setting;

    #Pass through if it's not the account op
    return undef unless ($form->get("op") eq "account");

    #Visitor cannot access the acccount system
    return $session->privilege->noAccess if($session->user->isVisitor);

    my $module   = $form->get("module");
    my $method   = $form->get("do");
    my $uid      = $form->get("uid");

    my $instance = __PACKAGE__->createInstance($session,$module);
    
    #Let the content handler handle trapping errors
    my $output   = $instance->callMethod($method,[],$uid);
    return undef unless (defined $output);
    
    return $instance->displayContent($output);
    
}


1;

