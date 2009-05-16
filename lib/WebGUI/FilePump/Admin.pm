package WebGUI::FilePump::Admin;

use strict;
use Tie::IxHash;
use WebGUI::AdminConsole;
use WebGUI::HTMLForm;
use WebGUI::International;
use WebGUI::Pluggable;
use WebGUI::Utility;

=head1 NAME

Package WebGUI::FilePump::Admin

=head1 DESCRIPTION

Web interface for making, building, and editing FilePump bundles.

=cut

#----------------------------------------------------------------------------

=head2 canView ( session [, user] )

Returns true if the user can administrate this operation. user defaults to 
the current user.

=cut

sub canView {
    my $session     = shift;
    my $user        = shift || $session->user;
    return $user->isInGroup( 3 );
}

#-------------------------------------------------------------------

=head2 www_deleteBundle ( )

Deletes a bundle, identified by the form variable, bundleId.

=cut

sub www_deleteBundle {
    my $session = shift;
    return $session->privilege->insufficient() unless canView($session);
    my $bundle = WebGUI::FilePump::Bundle->new($session, $session->form->get("bundleId"));
    if (defined $bundle) {
        $bundle->delete;
    }
    return www_manage($session);
}

#------------------------------------------------------------------

=head2 www_demoteFile ( session )

Moves a bundle file down one position.  The kind of file is set by the form variable filetype,
the id of the bundle is bundleId, and the id of the file to move is fileId.

=head3 session

A reference to the current session.

=cut

sub www_demoteFile {
	my $session = shift;
	return $session->privilege->insufficient() unless canView($session);
    my $bundle = WebGUI::FilePump::Bundle->new($session, $session->form->get("bundleId"));
    if (defined $bundle) {
    }
	return www_manage($session);
}

#-------------------------------------------------------------------

=head2 www_editBundle ( )

Displays a form to add or edit a bundle.

=cut

sub www_editBundle {
    my ($session, $error) = @_;
    return $session->privilege->insufficient() unless canView($session);

    if ($error) {
        $error = qq|<div class="error">$error</div>\n|;
    }
    ##Make a PassiveAnalytics rule to use to populate the form.
    my $bundleId = $session->form->get('bundleId'); 
    my $bundle;
    if ($bundleId) {
        $bundle = WebGUI::FilePump::Bundle->new($session, $bundle);
    }
    else {
        ##We need a temporary rule so that we can call dynamicForm, below
        $bundleId = 'new';
        $bundle   = WebGUI::FilePump::Bundle->create($session, {});
    }

    ##Build the form
	my $form = WebGUI::HTMLForm->new($session);
	$form->hidden( name=>"op",       value=>"filePump");
	$form->hidden( name=>"func",     value=>"filePumpSave");
	$form->hidden( name=>"bundleId", value=>$bundleId);
    $form->dynamicForm([WebGUI::FilePump::Bundle->crud_definition($session)], 'properties', $bundle);
	$form->submit;

	my $i18n = WebGUI::International->new($session, 'PassiveAnalytics');
	my $ac   = WebGUI::AdminConsole->new($session,'passiveAnalytics');
	$ac->addSubmenuItem($session->url->page("op=passiveAnalytics;func=editRuleflow"), $i18n->get("manage ruleset"));
    if ($ruleId eq 'new') {
        $rule->delete;
    }
	return $ac->render($error.$form->print,$i18n->get('Edit Rule'));
}

#-------------------------------------------------------------------

=head2 www_editBundleSave ( )

Saves the results of www_editBundle().

=cut

sub www_editBundleSave {
    my $session = shift;
    my $form    = $session->form;
    return $session->privilege->insufficient() unless canView($session);
    return www_manage($session);
}

#------------------------------------------------------------------

=head2 www_promoteFile ( session )

Moves a bundle file up one position.  The kind of file is set by the form variable filetype,
the id of the bundle is bundleId, and the id of the file to move is fileId.

=head3 session

A reference to the current session.

=cut

sub www_promoteFile {
	my $session = shift;
	return $session->privilege->insufficient() unless canView($session);
    my $bundle = WebGUI::FilePump::Bundle->new($session, $session->form->get("bundleId"));
    if (defined $bundle) {
    }
	return www_manage($session);
}

#-------------------------------------------------------------------

=head2 www_manage ( session )

Display a list of available bundles.  Provide ways to add, edit and delete them.

=head3 $session

A WebGUI session object.

=cut

sub www_manage {
    my $session = shift;
    return $session->privilege->insufficient() unless canView($session);
    my $ac = WebGUI::AdminConsole->new($session,'passiveAnalytics');
    $ac->addSubmenuItem($session->url->page('op=filePump;func=add'), $i18n->get('add a bundle'));
    return $ac->render($error.$f->print.$addmenu.$steps, 'Passive Analytics');
}


1;
