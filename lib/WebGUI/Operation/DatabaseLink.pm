package WebGUI::Operation::DatabaseLink;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
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
use WebGUI::Grouping;
use WebGUI::Icon;
use WebGUI::Id;
use WebGUI::International;
use WebGUI::Paginator;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;

#-------------------------------------------------------------------
sub _submenu {
        my $workarea = shift;
        my $title = shift;
        $title = WebGUI::International::get($title) if ($title);
        my $help = shift;
        my $ac = WebGUI::AdminConsole->new("databases");
        if ($help) {
                $ac->setHelp($help);
        }
	$ac->addSubmenuItem(WebGUI::URL::page('op=editDatabaseLink;dlid=new'), WebGUI::International::get(982));
	if (($session{form}{op} eq "editDatabaseLink" && $session{form}{dlid} ne "new") || $session{form}{op} eq "deleteDatabaseLink") {
                $ac->addSubmenuItem(WebGUI::URL::page('op=editDatabaseLink;dlid='.$session{form}{dlid}), WebGUI::International::get(983));
                $ac->addSubmenuItem(WebGUI::URL::page('op=copyDatabaseLink;dlid='.$session{form}{dlid}), WebGUI::International::get(984));
		$ac->addSubmenuItem(WebGUI::URL::page('op=deleteDatabaseLink;dlid='.$session{form}{dlid}), WebGUI::International::get(985));
		$ac->addSubmenuItem(WebGUI::URL::page('op=listDatabaseLinks'), WebGUI::International::get(986));
	}
        return $ac->render($workarea, $title);
}

#-------------------------------------------------------------------
sub www_copyDatabaseLink {
        return WebGUI::Privilege::insufficient unless (WebGUI::Grouping::isInGroup(3));
	my (%db);
	tie %db, 'Tie::CPHash';
	%db = WebGUI::SQL->quickHash("select * from databaseLink where databaseLinkId=".quote($session{form}{dlid}));
        WebGUI::SQL->write("insert into databaseLink (databaseLinkId,title,DSN,username,identifier) values (".quote(WebGUI::Id::generate()).", 
		".quote($db{title}." (copy)").", ".quote($db{DSN}).", ".quote($db{username}).", ".quote($db{identifier}).")");
        return www_listDatabaseLinks();
}

#-------------------------------------------------------------------
sub www_deleteDatabaseLink {
        return WebGUI::Privilege::insufficient unless (WebGUI::Grouping::isInGroup(3));
        my ($output);
        $output .= WebGUI::International::get(988).'<p>';
        $output .= '<p><div align="center"><a href="'.
		WebGUI::URL::page('op=deleteDatabaseLinkConfirm;dlid='.$session{form}{dlid})
		.'">'.WebGUI::International::get(44).'</a>';
        $output .= '&nbsp;&nbsp;&nbsp;&nbsp;<a href="'.WebGUI::URL::page('op=listDatabaseLinks').
		'">'.WebGUI::International::get(45).'</a></div>';
        return _submenu($output,"987","database link delete");
}

#-------------------------------------------------------------------
sub www_deleteDatabaseLinkConfirm {
        return WebGUI::Privilege::insufficient unless (WebGUI::Grouping::isInGroup(3));
        WebGUI::SQL->write("delete from databaseLink where databaseLinkId=".quote($session{form}{dlid}));
        return www_listDatabaseLinks();
}

#-------------------------------------------------------------------
sub www_editDatabaseLink {
        return WebGUI::Privilege::insufficient unless (WebGUI::Grouping::isInGroup(3));
        my ($output, %db, $f);
	tie %db, 'Tie::CPHash';
	if ($session{form}{dlid} eq "new") {

	} else {
               	%db = WebGUI::SQL->quickHash("select * from databaseLink where databaseLinkId=".quote($session{form}{dlid}));
	}
	$f = WebGUI::HTMLForm->new(
		-extras=>'autocomplete="off"'
		);
        $f->hidden(
		-name => "op",
		-value => "editDatabaseLinkSave",
        );
        $f->hidden(
		-name => "dlid",
		-value => $session{form}{dlid},
        );
	$f->readOnly(
		-value => $session{form}{dlid},
		-label => WebGUI::International::get(991),
		-hoverHelp => WebGUI::International::get('991 description'),
	);
        $f->text(
		-name => "title",
		-label => WebGUI::International::get(992),
		-hoverHelp => WebGUI::International::get('992 description'),
		-value => $db{title},
        );
        $f->text(
		-name => "DSN",
		-label => WebGUI::International::get(993),
		-hoverHelp => WebGUI::International::get('993 description'),
		-value => $db{DSN},
        );
        $f->text(
		-name => "dbusername",
		-label => WebGUI::International::get(994),
		-hoverHelp => WebGUI::International::get('994 description'),
		-value => $db{username},
        );
        $f->password(
		-name => "dbidentifier",
		-label => WebGUI::International::get(995),
		-hoverHelp => WebGUI::International::get('995 description'),
		-value => $db{identifier},
        );
        $f->submit;
	$output .= $f->print;
        return _submenu($output,"990","database link add/edit");
}

#-------------------------------------------------------------------
sub www_editDatabaseLinkSave {
        return WebGUI::Privilege::insufficient unless (WebGUI::Grouping::isInGroup(3));
	if ($session{form}{dlid} eq "new") {
		$session{form}{dlid} = WebGUI::Id::generate();
		WebGUI::SQL->write("insert into databaseLink (databaseLinkId) values (".quote($session{form}{dlid}).")");
	}
	    WebGUI::SQL->write("update databaseLink set title=".quote($session{form}{title}).", DSN=".quote($session{form}{DSN}).",
		username=".quote($session{form}{dbusername}).", identifier=".quote($session{form}{dbidentifier})." where databaseLinkId=".quote($session{form}{dlid}));
        return www_listDatabaseLinks();
}

#-------------------------------------------------------------------
sub www_listDatabaseLinks {
        return WebGUI::Privilege::adminOnly() unless(WebGUI::Grouping::isInGroup(3));
        my ($output, $p, $sth, %data, @row, $i);
        $sth = WebGUI::SQL->read("select * from databaseLink order by title");
	$row[$i] = '<tr><td valign="top" class="tableData"></td><td valign="top" class="tableData">'.WebGUI::International::get(1076).'</td></tr>';
	$i++;
        while (%data = $sth->hash) {
                $row[$i] = '<tr><td valign="top" class="tableData">'
			.deleteIcon('op=deleteDatabaseLink;dlid='.$data{databaseLinkId})
			.editIcon('op=editDatabaseLink;dlid='.$data{databaseLinkId})
			.copyIcon('op=copyDatabaseLink;dlid='.$data{databaseLinkId})
			.'</td>';
                $row[$i] .= '<td valign="top" class="tableData">'.$data{title}.'</td></tr>';
                $i++;
        }
	$sth->finish;
        $p = WebGUI::Paginator->new(WebGUI::URL::page('op=listDatabaseLinks'));
	$p->setDataByArrayRef(\@row);
        $output .= '<table border="1" cellpadding="3" cellspacing="0" align="center">';
        $output .= $p->getPage;
        $output .= '</table>';
        $output .= $p->getBarTraditional;
        return _submenu($output,"database links manage");
}


1;
