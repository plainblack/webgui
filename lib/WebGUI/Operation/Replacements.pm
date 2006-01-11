package WebGUI::Operation::Replacements;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::AdminConsole;
use WebGUI::Grouping;
use WebGUI::Icon;
use WebGUI::HTMLForm;
use WebGUI::International;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;

#-------------------------------------------------------------------
sub _submenu {
	my $session = shift;
        my $workarea = shift;
        my $title = shift;
        $title = WebGUI::International::get($title) if ($title);
        my $help = shift;
        my $ac = WebGUI::AdminConsole->new($session,"contentFilters");
        if ($help) {
                $ac->setHelp($help);
        }
        $ac->addSubmenuItem($session->url->page("op=editReplacement;replacementId=new"), WebGUI::International::get(1047));
        $ac->addSubmenuItem($session->url->page("op=listReplacements"), WebGUI::International::get("content filters"));
        return $ac->render($workarea, $title);
}


#-------------------------------------------------------------------
sub www_deleteReplacement {
	my $session = shift;
	return $session->privilege->adminOnly() unless ($session->user->isInGroup(3));
	$session->db->write("delete from replacements where replacementId=".$session->db->quote($session->form->process("replacementId")));
	return www_listReplacements();
}

#-------------------------------------------------------------------
sub www_editReplacement {
	my $session = shift;
	return $session->privilege->adminOnly() unless ($session->user->isInGroup(3));
	my $data = $session->db->getRow("replacements","replacementId",$session->form->process("replacementId"));
	my $f = WebGUI::HTMLForm->new;
	$f->hidden(
		-name=>"op",
		-value=>"editReplacementSave"
		);
	$f->hidden(
		-name=>"replacementId",
		-value=>$session->form->process("replacementId")
		);
	$f->readOnly(
		-label=>WebGUI::International::get(1049),
		-value=>$session->form->process("replacementId")
		);
	$f->text(
		-name=>"searchFor",
		-label=>WebGUI::International::get(1050),
		-hoverHelp=>WebGUI::International::get('1050 description'),
		-value=>$data->{searchFor}
		);
	$f->textarea(
		-label=>WebGUI::International::get(1051),
		-hoverHelp=>WebGUI::International::get('1051 description'),
		-name=>"replaceWith",
		-value=>$data->{replaceWith}
		);
	$f->submit;
	return _submenu($f->print,"1052",'replacements edit');
}

#-------------------------------------------------------------------
sub www_editReplacementSave {
	my $session = shift;
	return $session->privilege->adminOnly() unless ($session->user->isInGroup(3));
	$session->db->setRow("replacements","replacementId",{
		replacementId=>$session->form->process("replacementId"),
		searchFor=>$session->form->process("searchFor"),
		replaceWith=>$session->form->process("replaceWith")
		});
	return www_listReplacements();
}

#-------------------------------------------------------------------
sub www_listReplacements {
	my $session = shift;
	return $session->privilege->adminOnly() unless ($session->user->isInGroup(3));
	my $output = '<table>';
	$output .= '<tr><td></td><td class="tableHeader">'.WebGUI::International::get(1050).'</td><td class="tableHeader">'.WebGUI::International::get(1051).'</td></tr>';
	my $sth = $session->db->read("select replacementId,searchFor,replaceWith from replacements order by searchFor");
	while (my $data = $sth->hashRef) {
		$output .= '<tr><td>'.deleteIcon("op=deleteReplacement;replacementId=".$data->{replacementId})
			.editIcon("op=editReplacement;replacementId=".$data->{replacementId}).'</td>';
		$data->{replaceWith} =~ s/\&/\&amp\;/g;
		$data->{replaceWith} =~ s/\</\&lt\;/g;
        	$data->{replaceWith} =~ s/\>/\&gt\;/g;
		$output .= '<td class="tableData">'.$data->{searchFor}.'</td><td class="tableData">'.$data->{replaceWith}.'</td></tr>';
	}
	$sth->finish;
	$output .= '</table>';
	return _submenu($output);
}



1;
