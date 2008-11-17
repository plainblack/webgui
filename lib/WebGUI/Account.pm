package WebGUI::Account;

use strict;

use Class::InsideOut qw{ :std };
use WebGUI::Exception;
use Carp qw(croak);
use WebGUI::International;
use WebGUI::Pluggable;
use WebGUI::Utility;

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

readonly session => my %session;
readonly module  => my %module;
public   method  => my %method;
public   uid     => my %uid;
public   store   => my %store;  #This is an all purpose hash to store stuff in: $store{id $self}->{something} = "something"

#-------------------------------------------------------------------

=head2 appendAccountLinks ( session , var)

    Class method which appends common links to preform various account tasks

=head3 session

    WebGUI::Session object

=head3 var

    hash ref to append template variables to

=cut

sub appendAccountLinks {
    my $class   = shift;
    my $session = shift;
    my $var     = shift;

    return unless $var;

	my $i18n    = WebGUI::International->new($session);
    my $format  = q{<a href="%s">%s</a>};
	my @array   = ();
        
    #Turn Admin On
	if ($session->user->isInGroup(12)) {
        if ($session->var->isAdminOn) {
            $var->{'admin_mode_url' }  = $session->url->page('op=switchOffAdmin');
            $var->{'admin_mode_text'} = $i18n->get(12);
		}
        else {
            $var->{'admin_mode_url' }  = $session->url->page('op=switchOnAdmin');
            $var->{'admin_mode_text'} = $i18n->get(63);
		}
	    push(@array,{
            'options.display' => sprintf($format,$var->{'admin_mode_url'},$var->{'admin_mode_text'})
        });
	}

    #Pluggin - delete eventually
    if ($session->setting->get('userInvitationsEnabled')) {
        push @array, {
            'options.display' => sprintf('<a href=%s>%s</a>', $session->url->page('op=inviteUser'), $i18n->get('invite a friend')),
        };
    }

    #Logout
    $var->{'logout_url' } = $session->url->page('op=auth;method=logout');
    $var->{'logout_text'} = $i18n->get(64);
    push(@array,{
        'options.display' => sprintf($format,$var->{'logout_url'},$var->{'logout_text'})
    });

    #Deactivate Account
	if ($session->setting->get("selfDeactivation") && !$session->user->isAdmin){
        $var->{'self_deactivation_url' } = $session->url->page('op=auth;method=deactivateAccount');
        $var->{'self_deactivation_text'} = $i18n->get(65);
        push(@array,{
            'options.display' => sprintf($format,$var->{'self_deactivation_url' },$var->{'self_deactivation_text'})
        });
	}

    #Return to site
    $var->{'return_to_site_url' } = $session->url->getBackToSiteURL;
    $var->{'return_to_site_link'} = $i18n->get(493);
    push(@array,{
        'options.display' => sprintf($format,$var->{'return_to_site_url'},$var->{'return_to_site_link'})
    });

    $var->{'account.options'} = \@array;
}


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
    my $user    = $session->user;

    $var->{'user_full_name'   } = $user->getWholeName;
    $var->{'user_member_since'} = $user->dateCreated;
    $var->{'view_profile_url' } = $user->getProfileUrl;
    $var->{'root_url'         } = $session->url->page("op=account");
    #$var->{'back_url'          } = $session->env->get("HTTP_REFERER") || $var->{'view_profile_url'}
}


#-------------------------------------------------------------------

=head2 callMethod ( [ method, args, uid ] ) 

Calls the method passed in

=method

Method to call.  If no method is passed in, the view method is called

=args

array reference of arguments to pass to the method being called.

=uid

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

=content

Content to wrap in the pluggin style and layout

=withoutStyle

Return the layout without the style wrapper

=cut

sub displayContent {
    my $self    = shift;
    my $content = shift;
    my $noStyle = shift;
    my $session = $self->session;

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
        my $identifier               = $account->{identifier};
       
        $hash{'is_'.$identifier    } = "true";
        $hash{'is_method_'.$self->method } = "true";
        $hash{'url'                } = $instance->getUrl("module=$identifier",1);
        $hash{'isActive'           } = "true" if($identifier eq $self->module);
        WebGUI::Macro::process(\$hash{'title'});
        push(@pluggins,\%hash);       
    }
    $var->{'account_loop'} = \@pluggins;

    #Append common display variables to the layout template
    $self->appendCommonVars($var); 

    #Process the layout template
    my $output      = $self->processTemplate($var,$self->getLayoutTemplateId);
    
    return $output if($noStyle);
    #Wrap the layout in the user style
    $session->http->setCacheControl("none");
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
    return "";
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

    Override this method to return the template Id for the account layout.

=cut

sub getLayoutTemplateId {
    my $self = shift;
    return "N716tpSna0iIQTKxS4gTWA";
}

#-------------------------------------------------------------------

=head2 getStyleTemplate ( )

    Override this method to return the template for the main style.

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

    If this flag is set and uid is passed along the url, the uid passed in will be
    appended to the end of it to the end of the url

=cut

sub getUrl {
    my $self      = shift;
    my $pairs     = shift;
    my $appendUID = shift;

    my $session   = $self->session;
    my $form      = $session->form;
    
    if($pairs) {
        #Append op=account to the url if it doesn't already exist
        unless ($pairs =~ m/op=account/){
            $pairs = "op=account;".$pairs;
        }
    }
    else {
        $pairs = q{op=account;module=}.$self->module.q{;do=}.$self->method;
    }

    my $uid = $self->uid;
    $pairs .= ";uid=".$uid if($appendUID && $uid);

    return $session->url->page($pairs);
}

#-------------------------------------------------------------------

=head2 new ( session, module [,method ,uid] )

Constructor.

=head3 $session

A WebGUI::Session object.

=head3 module

The module being called

=cut

sub new {
    my $class         = shift;
    my $session       = shift;
    my $module        = shift;

    unless (ref $session eq 'WebGUI::Session') {
        WebGUI::Error::InvalidObject->throw(
            expected =>"WebGUI::Session",
            got      =>(ref $session),
            error    => q{Must provide a session variable}
        );
    }

    my $self              = register $class;
    my $id                = id $self;

    $session { $id      } = $session;
    $module  { $id      } = $module;
    $store   { $id      } = {};
    $method  { $id      } = "view";
    $uid     { $id      } = undef;

    return $self;
}

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

    $template = WebGUI::Asset->new($session, $templateId,"WebGUI::Asset::Template") unless (defined $template);

    unless (defined $template) {
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
