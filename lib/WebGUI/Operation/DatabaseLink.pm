package WebGUI::Operation::DatabaseLink;

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
use Tie::CPHash;
use WebGUI::AdminConsole;
use WebGUI::DatabaseLink;
use WebGUI::International;

#-------------------------------------------------------------------
sub _submenu {
	my $session = shift;
        my $workarea = shift;
        my $title = shift;
	my $i18n = WebGUI::International->new($session);
        $title = $i18n->get($title) if ($title);
        my $help = shift;
        my $ac = WebGUI::AdminConsole->new($session,"databases");
        if ($help) {
                $ac->setHelp($help);
        }
	$ac->addSubmenuItem($session->url->page('op=editDatabaseLink;dlid=new'), $i18n->get(982));
	if (($session->form->process("op") eq "editDatabaseLink" && $session->form->process("dlid") ne "new") || $session->form->process("op") eq "deleteDatabaseLink") {
                $ac->addSubmenuItem($session->url->page('op=editDatabaseLink;dlid='.$session->form->process("dlid")), $i18n->get(983));
                $ac->addSubmenuItem($session->url->page('op=copyDatabaseLink;dlid='.$session->form->process("dlid")), $i18n->get(984));
		$ac->addSubmenuItem($session->url->page('op=deleteDatabaseLink;dlid='.$session->form->process("dlid")), $i18n->get(985));
		$ac->addSubmenuItem($session->url->page('op=listDatabaseLinks'), $i18n->get(986));
	}
        return $ac->render($workarea, $title);
}

#-------------------------------------------------------------------
sub www_copyDatabaseLink {
	my $session = shift;
        return $session->privilege->insufficient unless ($session->user->isInGroup(3));
	WebGUI::DatabaseLink->new($session,$session->form->process("dlid"))->copy;
        return www_listDatabaseLinks();
}

#-------------------------------------------------------------------
sub www_deleteDatabaseLink {
	my $session = shift;
        return $session->privilege->insufficient unless ($session->user->isInGroup(3));
	my $i18n = WebGUI::International->new($session);
        my ($output);
        $output .= $i18n->get(988).'<p>';
        $output .= '<p><div align="center"><a href="'.
		$session->url->page('op=deleteDatabaseLinkConfirm;dlid='.$session->form->process("dlid"))
		.'">'.$i18n->get(44).'</a>';
        $output .= '&nbsp;&nbsp;&nbsp;&nbsp;<a href="'.$session->url->page('op=listDatabaseLinks').
		'">'.$i18n->get(45).'</a></div>';
        return _submenu($session,$output,"987","database link delete");
}

#-------------------------------------------------------------------
sub www_deleteDatabaseLinkConfirm {
	my $session = shift;
        return $session->privilege->insufficient unless ($session->user->isInGroup(3));
	WebGUI::DatabaseLink->new($session,$session->form->process("dlid"))->delete;
        return www_listDatabaseLinks();
}

#-------------------------------------------------------------------
sub www_editDatabaseLink {
	my $session = shift;
        return $session->privilege->insufficient unless ($session->user->isInGroup(3));
        my ($output, %db, $f);
	tie %db, 'Tie::CPHash';
	if ($session->form->process("dlid") eq "new") {
		
	} elsif ($session->form->process("dlid") eq "0") {
		
	} else {
               	%db = %{WebGUI::DatabaseLink->new($session,$session->form->process("dlid"))->get}; 
	}
	my $i18n = WebGUI::International->new($session);
	$f = WebGUI::HTMLForm->new($session,
		-extras=>'autocomplete="off"'
		);
        $f->hidden(
		-name => "op",
		-value => "editDatabaseLinkSave",
        );
        $f->hidden(
		-name => "dlid",
		-value => $session->form->process("dlid"),
        );
	$f->readOnly(
		-value => $session->form->process("dlid"),
		-label => $i18n->get(991),
		-hoverHelp => $i18n->get('991 description'),
	);
        $f->text(
		-name => "title",
		-label => $i18n->get(992),
		-hoverHelp => $i18n->get('992 description'),
		-value => $db{title},
        );
        $f->text(
		-name => "DSN",
		-label => $i18n->get(993),
		-hoverHelp => $i18n->get('993 description'),
		-value => $db{DSN},
        );
        $f->text(
		-name => "dbusername",
		-label => $i18n->get(994),
		-hoverHelp => $i18n->get('994 description'),
		-value => $db{username},
        );
        $f->password(
		-name => "dbidentifier",
		-label => $i18n->get(995),
		-hoverHelp => $i18n->get('995 description'),
		-value => $db{identifier},
        );
        $f->submit;
	$output .= $f->print;
        return _submenu($session,$output,"990","database link add/edit");
}

#-------------------------------------------------------------------
sub www_editDatabaseLinkSave {
	my $session = shift;
        return $session->privilege->insufficient unless ($session->user->isInGroup(3));
	my $params = {
		title=>$session->form->process("title"),
		username=>$session->form->process("dbusername"),
		identifier=>$session->form->process("dbidentifier"),
		DSN=>$session->form->process("DSN")
		};
	if ($session->form->process("dlid") eq "new") {
		WebGUI::DatabaseLink->create($session,$params);
	} else {
		WebGUI::DatabaseLink->new($session,$session->form->process("dlid"))->set($params);
	}
        return www_listDatabaseLinks();
}

#-------------------------------------------------------------------
sub www_listDatabaseLinks {
	my $session = shift;
        return $session->privilege->adminOnly() unless($session->user->isInGroup(3));
	my $links = WebGUI::DatabaseLink->getList($session);
        my $output = '<table border="1" cellpadding="3" cellspacing="0" align="center">';
	my $i18n = WebGUI::International->new($session);
	foreach my $id (keys %{$links}) {
		$output .= '<tr><td valign="top" class="tableData"></td><td valign="top" class="tableData">'.$i18n->get(1076).'</td></tr>';
                $output = '<tr><td valign="top" class="tableData">'
			.$session->icon->delete('op=deleteDatabaseLink;dlid='.$id)
			.$session->icon->edit('op=editDatabaseLink;dlid='.$id)
			.$session->icon->copy('op=copyDatabaseLink;dlid='.$id)
			.'</td>';
                $output .= '<td valign="top" class="tableData">'.$links->{$id}.'</td></tr>';
        }
        $output .= '</table>';
        return _submenu($session,$output,"database links manage");
}


1;
