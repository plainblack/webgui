package WebGUI::Account;

use strict;

use Moose;
use WebGUI::BestPractices;

has session => (
    is       => 'ro',
    required => 1,
);

has module => (
    is       => 'ro',
);

has method => (
    is       => 'rw',
    default  => 'view',
);

has uid => (
    is       => 'rw',
    default  => 'view',
);

has bare => (
    is       => 'rw',
    default  => 0,
);

has store => (
    is       => 'rw',
    default  => sub { return {}; },
);

use WebGUI::Exception;
use Carp qw(croak);
use WebGUI::International;
use WebGUI::Pluggable;

=head1 NAME

Package WebGUI::Account::Profile

=head1 DESCRIPTION

This is the class which is used to display a users's profile information

=head1 SYNOPSIS

    use base 'WebGUI::Account';

    currentState("edit");

=head1 METHODS

These subroutines are available from this package:

=cut

#-------------------------------------------------------------------

=head2 session ()

Returns a reference to the current WebGUI::Session object.

=cut

#-------------------------------------------------------------------

=head2 module ()

Returns the string representation of the name of the last Account module called.

=cut

#-------------------------------------------------------------------

=head2 method ()

Returns the string representation of the name of the last method called on the module().

=cut

#-------------------------------------------------------------------

=head2 uid ( [ userId ] )

Returns the userId of the WebGUI::User who's account is being interacted with.

=head3 userId

Optionally set the userId. Normally this is never needed, but is provided for completeness.

=cut

#-------------------------------------------------------------------

=head2 bare ( [ flag ] )

Returns whether or not the Account system should return a method's content
without the layout and style templates.  This would normally be used for
returning JSON or XML data out of the account system.

=head3 flag

Optionally set bare to be true, or false.

=cut

#-------------------------------------------------------------------

=head2 store ( [ hashRef ] )

Returns a hash reference attached to this account object that contains arbitrary data.

=head2 hashRef

A hash reference of data to store.

=cut

#-------------------------------------------------------------------

=head2 appendCommonVars ( var )

Appends common template variables that all most templates will use

=head3 var

The hash reference to append template variables to

=cut

sub appendCommonVars {
    my $self    = shift;
    my $var     = shift;
    my $session = $self->session;
    my $user    = $self->getUser;

    $var->{'profile_user_id'  } = $user->userId;
    $var->{'user_full_name'   } = $user->getWholeName;
    $var->{'user_member_since'} = $user->dateCreated;
    $var->{'view_profile_url' } = $user->getProfileUrl;
    $var->{'root_url'         } = $session->url->page("op=account");
    $var->{'back_url'         } = $session->url->getBackToSiteURL;
}


#-------------------------------------------------------------------

=head2 callMethod ( [ method, args, uid ] ) 

Calls the method passed in

=head3 method

Method to call.  If no method is passed in, the view method is called

=head3 args

array reference of arguments to pass to the method being called.

=head3 uid

uid to set in the object.

=cut

sub callMethod {
    my $self     = shift;
    my $method   = shift || "view";
    my $args     = shift;
    my $uid      = shift;

    my $module   = $self->module;

    #Set the method in the object
    $self->method($method);
    #Set the uid in the object
    $self->uid($uid);

    $method = "www_".$method;

    unless ($self->can($method)) {
        WebGUI::Error::MethodNotFound->throw(
            error  => qq{Could not locate method $method in the $module module of the account system},
            method => $method
        );
        return undef;
    }

    unless ($self->canView) {
        my $session = $self->session;
        $session->output->print($session->privilege->insufficient);
        return undef;
    }
   
    #Try to call the method
    my $output = eval { $self->$method(@{$args}) };

    #Croak on error
    if($@) {
        croak "Unable to run $method on $module: $@";
        return undef;
    }

    #Return the output from the method call
    return $output;
}

#-------------------------------------------------------------------

=head2 displayContent ( content[, withoutStyle] ) 

Wraps the content in the style and layout of the account pluggin

=head3 content

Content to wrap in the pluggin style and layout

=head3 withoutStyle

Return the layout without the style wrapper

=cut

sub displayContent {
    my $self    = shift;
    my $content = shift;
    my $noStyle = shift;
    my $session = $self->session;

    ##Don't do any templating if we're sending back data like JSON or XML.
    return $content if $self->bare;

    ##Don't do any templating if we're sending back data like JSON or XML.
    return $content if $self->bare;

    #Wrap content into the layout
    my $var         = {};
    $var->{content} = $content;

    my $configs     = $session->config->get("account");
    my $method      = $self->method || "view";

    # Get fieldsets for avaiable account methods in the order they exist in the config file and append them to the template
    my @pluggins    = ();
    foreach my $account (@{$configs}) {
        #Instantiate the pluggin
        my $instance     = undef;
        my $identifier   = $account->{identifier};
        #Use the currently instantiated pluggin if we are checking this pluggin
        if($account->{identifier} eq $self->module) {
            $instance = $self;
        }
        else {
            #Eval it as we don't want to fail if there's a problem with another method in the config file
            $instance = eval { WebGUI::Content::Account->createInstance($session,$identifier) };
            if (my $e = WebGUI::Error->caught) {
                $session->log->warn("Couldn't instantiate Account Pluggin ".$account->{className}." ... skipping");
                next;
            }
            elsif(!$instance->isa('WebGUI::Account')) {
                $session->log->warn((ref $instance)." is not a subclass of WebGUI::Account ... skipping");
                next;
            }
            #Set the current uid state in the instance
            $instance->uid($self->uid);
        }
        
        #Skip this module if the user can't view it
        next unless ($instance->canView);
            
        #Push the tab variables onto the template
        my %hash                     = %{$account};
       
        $hash{'is_'.$identifier    } = "true";
        $hash{'is_method_'.$self->method } = "true";
        $hash{'url'                } = $instance->getUrl("module=$identifier",1);
        $hash{'isActive'           } = "true" if($identifier eq $self->module);
        WebGUI::Macro::process($session,\$hash{'title'});
        push(@pluggins,\%hash);       
    }
    $var->{'account_loop'} = \@pluggins;

    #Append common display variables to the layout template
    $self->appendCommonVars($var); 

    #Process the layout template
    my $output      = $self->processTemplate($var,$self->getLayoutTemplateId);
    
    return $output if($noStyle);
    #Wrap the layout in the user style
    $session->response->setCacheControl("none");
    return $session->style->process($output,$self->getStyleTemplateId);    
}


#-------------------------------------------------------------------

=head2 canView ( )

Override this method to create permission levels for your Account Pluggin

=cut

sub canView {
    my $self = shift;
    return 1;
}

#-------------------------------------------------------------------

=head2 editSettingsForm ( )

Override this method to create settings for your Account Pluggin

=cut

sub editSettingsForm {
    my $self = shift;
    return WebGUI::FormBuilder->new( $self->session );
}

#-------------------------------------------------------------------

=head2 editSettingsFormSave ( )

Override this method to create settings for your Account Pluggin

=cut

sub editSettingsFormSave {
    my $self = shift;
    return "";
}

#-------------------------------------------------------------------

=head2 getLayoutTemplateId ( )

Override this method to return the template Id for the account layout.  The default
account layout draws a tabbed interface to the different account plugins, and displays
the content from a particular screen from the account plugin.

=cut

sub getLayoutTemplateId {
    my $self = shift;
    return "N716tpSna0iIQTKxS4gTWA";
}

#-------------------------------------------------------------------

=head2 getStyleTemplateId ( )

Override this method to return the template for the main style.  The style would
be for the page that the account layout template is embedded in.

=cut

sub getStyleTemplateId {
    my $self = shift;
    return $self->session->setting->get("userFunctionStyleId");
}


#-------------------------------------------------------------------

=head2 getUrl ( [pairs,appendUID] )

Builds the url for the current page.

=head3 pairs

name value pairs to append to the page url.  If pairs is not passed in
the current module and do values will be used.

=head3 appendUID

If this flag is set and uid is passed as a URL param, that uid will be
appended to the end of the url.

=cut

sub getUrl {
    my $self      = shift;
    my $pairs     = shift;
    my $appendUID = shift;

    my $session   = $self->session;
    
    my $uid = $self->uid;
    if($pairs) {
        #Append op=account to the url if it doesn't already exist
        unless ($pairs =~ m/op=account/){
            $pairs = "op=account;".$pairs;
        }
    }
    else {
        $pairs = q{op=account;module=}.$self->module.q{;do=}.$self->method;
    }

    $pairs .= ";uid=".$uid if($appendUID && $uid);

    return $session->url->page($pairs);
}

#-------------------------------------------------------------------

=head2 getUser

Gets the user, either specified by the uid URL parameter, or the
session user.

=cut

sub getUser {
    my $self      = shift;
    if ($self->uid) {
        return WebGUI::User->new($self->session, $self->uid);
    }
    else {
        return $self->session->user;
    }
}

#-------------------------------------------------------------------

=head2 new ( session, module [,method ,uid] )

Constructor.

=head3 $session

A WebGUI::Session object.

=head3 module

The module being called

=cut

around BUILDARGS => sub {
    my $orig  = shift;
    my $class = shift;
    my $properties;
    if (ref $_[0] eq 'HASH') {
        $properties = $_[0];
    }
    else {
        $properties->{session} = shift;
    }
    if (!(blessed $properties->{session} && ref $properties->{session} eq 'WebGUI::Session')) {
        WebGUI::Error::InvalidObject->throw(
            expected =>"WebGUI::Session",
            got      =>(ref $properties->{session}),
            error    => q{Must provide a session variable}
        );
    }

    return $class->$orig($properties);
};

#-------------------------------------------------------------------

=head2 processTemplate ( vars, templateId, template )

Returns the content generated from this template.  It adds the Asset control
bar to the template variables, as well as all Asset properties and metadata.

=head3 vars

A hash reference containing variables and loops to pass to the template engine.

=head3 templateId

An id referring to a particular template in the templates table.

=head3 template

Instead of passing in a templateId, you may pass in a template object.

=cut

sub processTemplate {
    my $self       = shift;
    my $session    = $self->session;

    my $var        = shift;
    my $templateId = shift;
    my $template   = shift;
    my $className  = ref $self;

    # Sanity checks
    if (ref $var ne "HASH") {
        $session->log->error("First argument to processTemplate() should be a hash reference.");
        my $i18n = WebGUI::International->new($session, 'Account');
        return sprintf($i18n->get('Error: Cannot instantiate template'),$templateId,$className);
    }

    if (!defined $template) {
        $template = eval { WebGUI::Asset->newById($session, $templateId); };
    }

    if (Exception::Class->caught()) {
        $session->log->error("Can't instantiate template $templateId for class ".$className);
        my $i18n = WebGUI::International->new($session, 'Account');
        return sprintf($i18n->get('Error: Cannot instantiate template'),$templateId,$className);
    }

    return $template->process($var);
}


#-------------------------------------------------------------------

=head2 showError ( vars )

Returns a general error screen with the message passed in.

=head3 vars

Variable hash ref to append errors to

=head3 error

Error message to display

=head3 url

URL to display to the user to go back to a safe place

=head3 templateId

temlateId to use to display error

=cut

sub showError {
    my $self  = shift;

    my $var                 = shift || {};
    $var->{'error_message'} = shift;
    $var->{'back_url'     } = shift;
    
    my $templateId          = shift;
    
    return $self->processTemplate($var,$templateId)
}

1;
