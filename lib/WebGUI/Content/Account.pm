package WebGUI::Content::Account;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2008 Plain Black Corporation.
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
use WebGUI::Exception::Account;
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

    my $op      = $form->get("op");
    return undef unless ($op eq "account");

    my $output  = undef;

    my $module  = $form->get("module") || $session->config->get("profileModuleIdentifier");
    
    my $configs = $session->config->get("account");
    my $config  = __PACKAGE__->getAccountConfig($session,$module,$configs);

    if (defined $config) {
        #Visitor cannot do anything to the profile.
        return $session->privilege->insufficient if($session->user->isVisitor);

        #Create Pluggin Object
        #Don't eval this as pluggable will croak and we want WebGUI::URL::Content to handle the exception 
        my $pluggin = WebGUI::Pluggable::instanciate($config->{className}, "new", [ $session ] );
        
        #Check to make sure pluggin is a subclass of WebGUI::Account
        unless($pluggin->isa('WebGUI::Account')) {
            my $plugginType = ref $pluggin;
            WebGUI::Error::InvalidObject->throw(
                expected => 'WebGUI::Account',
                got      => $plugginType,
                error    => '$plugginType is not a subclass of WebGUI::Accout'
            );
        }
        
        #Check to see if the user has permission to see what they are calling
        return $session->privilege->insufficient unless ($pluggin->canView);
        
        #Process the method call
        my $method = $form->get("do") || "view";
        $method = "www_".$method;
        
        if($pluggin->can($method)) {
            $output = $pluggin->$method;
        }
        else {
            WebGUI::Error::MethodNotFound->throw(
                error  => "Couldn't call non-existant method $method",
                method => $method
            );
        }

        #Wrap content returned from method call into the layout
        my $var         = {};
        $var->{content} = $output;

        # Get fieldsets for avaiable account methods in the order they exist in the config file
        my @pluggins    = ();
        foreach my $account (@{$configs}) {
            #Instantiate the pluggin
            #Use the currently instantiated pluggin if we are checking this pluggin
            my $instance = undef;
            if($account->{identifier} eq $module) {
                $instance = $pluggin;
            }
            else {
                $instance = eval { WebGUI::Pluggable::instanciate($account->{className}, "new", [ $session ] ) };
                if (my $e = WebGUI::Error->caught) {
                    $session->log->warn("Couldn't instantiate Account Pluggin ".$account->{className}." ... skipping");
                    next;
                }
                elsif(!$pluggin->isa('WebGUI::Account')) {
                    $session->log->warn((ref $instance)." is not a subclass of WebGUI::Account ... skipping");
                    next;
                }
            }
            #Skip this module if the user can't view this
            next unless ($instance->canView);
            
            #Push the tab variables onto the template
            my %hash = %{$account};
            my $identifier = $account->{identifier};
            $hash{'is_'.$identifier} = "true";
            $hash{'url'            } = $instance->getUrl("module=$identifier",1);
            $hash{'isActive'       } = "true" if($identifier eq $module);
            WebGUI::Macro::process(\$hash{'title'});
            push(@pluggins,\%hash);
        }
        $var->{'account_loop'} = \@pluggins;

        my $layoutId    = $pluggin->getLayoutTemplateId;
        #Process the layout template
        $output         = $pluggin->processTemplate($var,$layoutId);
        #Wrap the layout in the user style
        $output         = $session->style->userStyle($output);
    }

    return $output;
}


1;

