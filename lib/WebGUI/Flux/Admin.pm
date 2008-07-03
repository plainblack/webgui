package WebGUI::Flux::Admin;

use strict;
use Class::InsideOut qw{ :std };
use WebGUI::Flux;
use Readonly;
use WebGUI::AdminConsole;
use WebGUI::HTMLForm;
use WebGUI::International;
use WebGUI::Flux;
use WebGUI::Flux::Rule;

=head1 NAME

Package WebGUI::Flux::Admin

=head1 DESCRIPTION

All the admin stuff that didn't fit elsewhere.
This module will remain mostly empty until the Flux GUI is implemented. 

=head1 SYNOPSIS

 use WebGUI::Flux::Admin;

 my $admin = WebGUI::Flux::Admin->new($session);

=head1 METHODS

These subroutines are available from this package:

=cut

readonly session => my %session;

#-------------------------------------------------------------------

=head2 new ( session )

Constructor. 

=head3 session

A reference to the current session.

=cut

sub new {
    my ( $class, $session ) = @_;
    unless ( defined $session && $session->isa("WebGUI::Session") ) {
        WebGUI::Error::InvalidObject->throw(
            expected => "WebGUI::Session",
            got      => ( ref $session ),
            error    => "Need a session."
        );
    }
    my $self = register $class;
    my $id   = id $self;
    $session{$id} = $session;
    return $self;
}

#-------------------------------------------------------------------

=head2 session () 

Returns a reference to the current session.

=cut

#-------------------------------------------------------------------

=head2 canManage ( [ $user ] )

Determine whether or not a user can manage Flux functions

=head3 $user

An optional WebGUI::User object to check for permission to do Flux functions.  If
this is not used, it uses the current session user object.

=cut

sub canManage {
    my $self = shift;
    my $user = shift || $self->session->user;
    return $user->isInGroup( $self->session->setting->get('groupIdAdminCommerce') );
}

#-------------------------------------------------------------------

=head2 getAdminConsole ()

Returns a reference to the admin console with all submenu items already added.

=cut

sub getAdminConsole {
    my $self = shift;
    my $ac   = WebGUI::AdminConsole->new( $self->session, 'flux' );
    my $i18n = WebGUI::International->new( $self->session, 'Flux' );
    my $url  = $self->session->url;
    $ac->addSubmenuItem( $url->page("flux=admin"), 'Flux Admin' );
    $ac->addSubmenuItem( $url->page("flux=graph"), 'View Flux Graph' );
    return $ac;
}

#-------------------------------------------------------------------

=head2 www_graph () 

Display a simple page showing the Flux Graph. This is currently just a proof-of-concept. 
You can view this at: http://dev.localhost.localdomain/?flux=admin&method=graph or by running
 > prove Flux.t
and then viewing /uploads/FluxGraph.png in an image viewer.

=cut

sub www_graph {
    my $self = shift;

    # Check permissions..
    return $self->session->privilege->insufficient
        if !$self->canManage();

    my $ac = $self->getAdminConsole();

    WebGUI::Flux->generateGraph( $self->session );

    # Return a simple hard-coded page displaying the Flux Graph.
    my $graph = qq{<img src="/uploads/FluxGraph.png">};

    return $ac->render( $graph, 'Flux Graph' );
}

#-------------------------------------------------------------------

=head2 www_admin ()

Displays the general Flux settings.

=cut

sub www_admin {
    my $self = shift;

    # Check permissions..
    return $self->session->privilege->insufficient
        if !$self->canManage();

    my $i18n    = WebGUI::International->new( $self->session, 'Flux' );
    my $ac      = $self->getAdminConsole();
    my $setting = $self->session->setting();

    my $output = q{};

    if ( !$setting->get('fluxEnabled') ) {
        $output .= <<EOSM;
<div class="error">
Flux is currently disabled site-wide.
</div>
EOSM
    }

    # Build a TabForm..
    use Tie::IxHash;
    my %tabs;
    tie %tabs, 'Tie::IxHash';
    %tabs = (
        settings => { label => 'Settings' },
        rules    => { label => 'Rules' }
    );
    my $form = WebGUI::TabForm->new( $self->session, \%tabs );
    $form->hidden( { name => 'flux', value => 'adminSave' } );
    $form->submit;

    # Build the Settings tab..
    my $settings_tab = $form->getTab('settings');
    $settings_tab->yesNo(
        name  => 'fluxEnabled',
        value => $setting->get('fluxEnabled'),
        label => 'Flux Enabled',
        hoverHelp =>
            'Controls whether Flux is enabled site-wide. If you disable, per-wobject Flux settings will not be shown or used.',
    );
    $settings_tab->group(
        name      => 'groupIdAdminFlux',
        value     => $setting->get('groupIdAdminFlux'),
        label     => $i18n->get('who can manage'),
        hoverHelp => $i18n->get('who can manage help'),
    );

    # Build the Rules tab..
    my $rules_tab   = $form->getTab('rules');
    my $rule_output = q{};
    foreach my $rule ( @{ WebGUI::Flux->getRules( $self->session ) } ) {
        my $name        = $rule->get('name');
        my $id          = $rule->getId();
        my $edit_icon   = $self->session->icon->edit("flux=editRule&id=$id");
        my $manage_icon = $self->session->icon->manage("flux=manageRule&id=$id");
        my $delete_icon = $self->session->icon->delete("flux=deleteRule&id=$id");
        $rule_output .= <<"END_RULEROW";
<tr>
    <td class='formDescription' valign="top" style="width: 180px;">
        $name
    </td>
    <td class='tableData' valign="top">
        $edit_icon
    </td>
    <td class='tableData' valign="top">
        $manage_icon
    </td>
    <td class='tableData' valign="top">
        $delete_icon
    </td>
 </tr>
END_RULEROW

    }
    $rules_tab->raw($rule_output);

    return $ac->render( $output . $form->print, 'Flux Admin' );
}

#-------------------------------------------------------------------

=head2 www_adminSave () 

Saves the general Flux settings.

=cut

sub www_adminSave {
    my $self = shift;
    return $self->session->privilege->adminOnly() unless ( $self->session->user->isInGroup("3") );
    my ( $setting, $form ) = $self->session->quick(qw(setting form));
    $setting->set( "fluxEnabled",      $form->get( "fluxEnabled",      "yesNo" ) );
    $setting->set( "groupIdAdminFlux", $form->get( "groupIdAdminFlux", "group" ) );
    return $self->www_admin();
}

#-------------------------------------------------------------------

=head2 www_editRule ()

Displays the edit Rule page.

=cut

sub www_editRule {
    my $self    = shift;
    my $session = $self->session;

    # Check permissions..
    return $self->session->privilege->insufficient
        if !$self->canManage();

    my $i18n = WebGUI::International->new( $self->session, 'Flux' );
    my $ac = $self->getAdminConsole();

    my $rule_id = $session->form->get('id');
    return undef
        if !$rule_id;

    my $rule = WebGUI::Flux::Rule->new( $session, $rule_id );

    # Build an HTMLForm..
    my $form = WebGUI::HTMLForm->new($session);
    $form->hidden( name => 'flux', value => 'editRuleSave' );
    $form->hidden( name => 'id',   value => $rule_id );

    $form->text(
        name      => 'name',
        value     => $rule->get('name'),
        label     => 'Rule Name',
        hoverHelp => 'The name of this Flux Rule',
    );
    $form->yesNo(
        name      => 'sticky',
        value     => $rule->get('sticky'),
        label     => 'Is Sticky',
        hoverHelp => 'Whether or not the Flux Rule is sticky',
    );

    $form->submit;
    return $ac->render( $form->print, 'Edit Rule' );
}

#-------------------------------------------------------------------

=head2 www_editRuleSave () 

Saves Flux Rule edits.

=cut

sub www_editRuleSave {
    my $self = shift;
    my $session = $self->session;
    return $session->privilege->adminOnly() unless ( $session->user->isInGroup("3") );
    
    my $rule_id = $session->form->get('id');
    return undef
        if !$rule_id;

    my $rule = WebGUI::Flux::Rule->new( $session, $rule_id );
    $rule->update( {
        name => $session->form->get('name'),
        sticky => $session->form->get('sticky'),
    });
    return $self->www_admin();
}

1;
