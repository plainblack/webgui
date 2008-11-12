package WebGUI::Account;

use strict;

use Class::InsideOut qw{ :std };
use WebGUI::Exception;
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
public store    => my %store;  #This is an all purpose hash to store stuff in: $store{id $self}->{something} = "something"

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
        $pairs = q{op=account;module=}.$form->get("module").q{;do=}.$form->get("do");
    }

    my $uid = $form->get("uid");
    $pairs .= ";uid=".$uid if($appendUID && $uid);

    return $session->url->page($pairs);
}

#-------------------------------------------------------------------

=head2 new ( $session )

Constructor.

=head3 $session

A WebGUI::Session object.

=cut

sub new {
    my $class         = shift;
    my $session       = shift;

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
    $store   { $id      } = {};
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
