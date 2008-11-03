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

=head2 handler ( session ) 

The content handler for this package.

=cut

sub handler {
    my $session = shift;
    my $form    = $session->form;

    my $output  = undef;

    my $op      = $session->form->get("op");
    my $configs = $session->config->get("account");
    
    if ($configs->{$op}) {
        return $session->privilege->insufficient if($session->user->isVisitor);
        #$session->errorHandler->warn("Loading module : ".$configs->{$op}->{className});

        #Create Pluggin Object
        #Don't eval this as pluggable will croak and we want WebGUI::URL::Content to handle the exception 
        my $pluggin = WebGUI::Pluggable::instanciate($configs->{$op}->{className}, "new", [ $session ] );
        
        #Check to make sure pluggin is a subclass of WebGUI::Account
        unless($pluggin->isa('WebGUI::Account')) {
            my $plugginType = ref $pluggin;
            WebGUI::Error::InvalidObject->throw(
                expected => 'WebGUI::Account',
                got      => $plugginType,
                error    => '$plugginType is not a subclass of WebGUI::Accout'
            );
        }
        
        #Process the method call
        my $method = $session->form->get("do") || "view";
        $method = "www_".$method;
           
        if($pluggin->can($method)) {
            $output = eval { $pluggin->$method($session) };
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
        my $layoutId    = $pluggin->getLayoutTemplateId;
        $output         = $pluggin->processTemplate($var,$layoutId);

        #Wrap the layout in the user style
        $session->http->setCacheControl("none");
        $output = $session->style->process($output,$session->setting->get("userFunctionStyleId"));
    }

    return $output;
}


1;

