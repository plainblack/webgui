package WebGUI::Operation::Replacements;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::AdminConsole;
use WebGUI::HTMLForm;
use WebGUI::International;
use WebGUI::SQL;

=head1 NAME

Package WebGUI::Operation::Replacements

=head1 DESCRIPTION

Operation handler for conditional editing of submitted WebGUI content, similar to
a search and replace function in word processors.

#----------------------------------------------------------------------------

=head2 _submenu ( $session, $workarea, $title )

Utility routine for creating the AdminConsole for Replacement functions.

=head3 $session

The current WebGUI session object.

=head3 $workarea

The content to display to the user.

=head3 $title

The title of the Admin Console.  This should be an entry in the i18n
table in the WebGUI namespace.

=cut

sub _submenu {
    my $session = shift;
    my $workarea = shift;
    my $title = shift;
    my $i18n = WebGUI::International->new($session);
    $title = $i18n->get($title) if ($title);
    my $ac = WebGUI::AdminConsole->new($session,"contentFilters");
    $ac->addSubmenuItem($session->url->page("op=editReplacement;replacementId=new"), $i18n->get(1047));
    $ac->addSubmenuItem($session->url->page("op=listReplacements"), $i18n->get("content filters"));
    return $ac->render($workarea, $title);
}

#----------------------------------------------------------------------------

=head2 canView ( session [, user] )

Returns true if the user can administrate this operation. user defaults to 
the current user.

=cut

sub canView {
    my $session     = shift;
    my $user        = shift || $session->user;
    return $user->isInGroup( $session->setting->get("groupIdAdminReplacements") );
}

#-------------------------------------------------------------------

=head2 www_deleteReplacement ( $session )

Delete a replacement specified by the form variable C<replacementId>.
Returns the user to the List Replacements screen, www_listReplacements.

=cut

sub www_deleteReplacement {
	my $session = shift;
	return $session->privilege->adminOnly() unless canView($session);
	$session->db->write("delete from replacements where replacementId=".$session->db->quote($session->form->process("replacementId")));
	return www_listReplacements($session);
}

#-------------------------------------------------------------------

=head2 www_editReplacement ( $session )

Add a new, or edit an existing specified by the form variable
C<replacementId> if the user is in group Admin (3).  Allows the user
to enter in a string to search for and the text to replace it with.

Calls www_editReplacementSave on submission.

=cut

sub www_editReplacement {
	my $session = shift;
	return $session->privilege->adminOnly() unless canView($session);
	my $data = $session->db->getRow("replacements","replacementId",$session->form->process("replacementId"));
	my $i18n = WebGUI::International->new($session);
	my $f = WebGUI::HTMLForm->new($session);
	$f->submit;
	$f->hidden(
		-name=>"op",
		-value=>"editReplacementSave"
		);
	$f->hidden(
		-name=>"replacementId",
		-value=>$session->form->process("replacementId")
		);
	$f->readOnly(
		-label=>$i18n->get(1049),
		-value=>$session->form->process("replacementId")
		);
	$f->text(
		-name=>"searchFor",
		-label=>$i18n->get(1050),
		-hoverHelp=>$i18n->get('1050 description'),
		-value=>$data->{searchFor}
		);
	$f->textarea(
		-label=>$i18n->get(1051),
		-hoverHelp=>$i18n->get('1051 description'),
		-name=>"replaceWith",
		-value=>$data->{replaceWith}
		);
	$f->submit;
	return _submenu($session,$f->print,"1052");
}

#-------------------------------------------------------------------

=head2 www_editReplacementSave ( $session )

Form post processor for www_editReplacement. 

Returns the user to www_listReplacements.

=cut

sub www_editReplacementSave {
	my $session = shift;
	return $session->privilege->adminOnly() unless canView($session);
	$session->db->setRow("replacements","replacementId",{
		replacementId=>$session->form->process("replacementId"),
		searchFor=>$session->form->process("searchFor"),
		replaceWith=>$session->form->process("replaceWith")
		});
	return www_listReplacements($session);
}

#-------------------------------------------------------------------

=head2 www_listReplacements ( $session )

List all replacements and provides URls for replacements to be added or 
deleted.

=cut

sub www_listReplacements {
	my $session = shift;
	return $session->privilege->adminOnly() unless canView($session);
	my $i18n = WebGUI::International->new($session);
	my $output = '<table>';
	$output .= '<tr><td></td><td class="tableHeader">'.$i18n->get(1050).'</td><td class="tableHeader">'.$i18n->get(1051).'</td></tr>';
	my $sth = $session->db->read("select replacementId,searchFor,replaceWith from replacements order by searchFor");
	while (my $data = $sth->hashRef) {
		$output .= '<tr><td>'.$session->icon->delete("op=deleteReplacement;replacementId=".$data->{replacementId})
			.$session->icon->edit("op=editReplacement;replacementId=".$data->{replacementId}).'</td>';
		$data->{replaceWith} =~ s/\&/\&amp\;/g;
		$data->{replaceWith} =~ s/\</\&lt\;/g;
        	$data->{replaceWith} =~ s/\>/\&gt\;/g;
		$output .= '<td class="tableData">'.$data->{searchFor}.'</td><td class="tableData">'.$data->{replaceWith}.'</td></tr>';
	}
	$sth->finish;
	$output .= '</table>';
	return _submenu($session,$output);
}



1;
