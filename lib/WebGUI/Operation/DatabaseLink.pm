package WebGUI::Operation::DatabaseLink;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2003 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use Exporter;
use strict;
use Tie::CPHash;
use WebGUI::DatabaseLink;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Operation::Shared;
use WebGUI::Paginator;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;

our @ISA = qw(Exporter);
our @EXPORT = qw(&www_copyDatabaseLink &www_deleteDatabaseLink &www_deleteDatabaseLinkConfirm 
	&www_editDatabaseLink &www_editDatabaseLinkSave &www_listDatabaseLinks);

#-------------------------------------------------------------------
sub _submenu {
        my (%menu);
        tie %menu, 'Tie::IxHash';
	$menu{WebGUI::URL::page('op=editDatabaseLink&dlid=new')} = WebGUI::International::get(982);
	if (($session{form}{op} eq "editDatabaseLink" && $session{form}{dlid} ne "new") || $session{form}{op} eq "deleteDatabaseLink") {
                $menu{WebGUI::URL::page('op=editDatabaseLink&dlid='.$session{form}{dlid})} = WebGUI::International::get(983);
                $menu{WebGUI::URL::page('op=copyDatabaseLink&dlid='.$session{form}{dlid})} = WebGUI::International::get(984);
		$menu{WebGUI::URL::page('op=deleteDatabaseLink&dlid='.$session{form}{dlid})} = WebGUI::International::get(985);
		$menu{WebGUI::URL::page('op=listDatabaseLinks')} = WebGUI::International::get(986);
	}
        return menuWrapper($_[0],\%menu);
}

#-------------------------------------------------------------------
sub www_copyDatabaseLink {
        return WebGUI::Privilege::insufficient unless (WebGUI::Privilege::isInGroup(3));
	my (%db);
	tie %db, 'Tie::CPHash';
	%db = WebGUI::SQL->quickHash("select * from databaseLink where databaseLinkId=$session{form}{dlid}");
        WebGUI::SQL->write("insert into databaseLink (databaseLinkId,title,DSN,username,identifier) values (".getNextId("databaseLinkId").", 
		".quote('Copy of '.$db{title}).", ".quote($db{DSN}).", ".quote($db{username}).", ".quote($db{identifier}).")");
        return www_listDatabaseLinks();
}

#-------------------------------------------------------------------
sub www_deleteDatabaseLink {
        return WebGUI::Privilege::insufficient unless (WebGUI::Privilege::isInGroup(3));
        my ($output);
        $output .= helpIcon(70);
	$output .= '<h1>'.WebGUI::International::get(987).'</h1>';
        $output .= WebGUI::International::get(988).'<p>';
        foreach my $using (WebGUI::DatabaseLink::whatIsUsing($session{form}{dlid})) {
        	if ($using->{title}) {
				$output .= '<li>'.WebGUI::International::get(1,'SQLReport').' <a href="'.WebGUI::URL::page('func=edit&wid='.$using->{wobjectId},$using->{urlizedTitle}).'">'
					.$using->{title}.'</a> '.WebGUI::International::get(989).' <a href="'.WebGUI::URL::gateway($using->{urlizedTitle}).'">'.$using->{menuTitle}.'</a>.</li>';
			} else {
				$output .= '<li>'.'Group'.' <a href="'.WebGUI::URL::page('op=editGroup&gid='.$using->{groupId}).'">'.$using->{groupName}.'</a>.</li>';
			}
		}
        $output .= '<p><div align="center"><a href="'.
		WebGUI::URL::page('op=deleteDatabaseLinkConfirm&dlid='.$session{form}{dlid})
		.'">'.WebGUI::International::get(44).'</a>';
        $output .= '&nbsp;&nbsp;&nbsp;&nbsp;<a href="'.WebGUI::URL::page('op=listDatabaseLinks').
		'">'.WebGUI::International::get(45).'</a></div>';
        return _submenu($output);
}

#-------------------------------------------------------------------
sub www_deleteDatabaseLinkConfirm {
        return WebGUI::Privilege::insufficient unless (WebGUI::Privilege::isInGroup(3));
        WebGUI::SQL->write("delete from databaseLink where databaseLinkId=".$session{form}{dlid});
        return www_listDatabaseLinks();
}

#-------------------------------------------------------------------
sub www_editDatabaseLink {
        return WebGUI::Privilege::insufficient unless (WebGUI::Privilege::isInGroup(3));
        my ($output, %db, $f);
	tie %db, 'Tie::CPHash';
	if ($session{form}{dlid} eq "new") {

	} else {
               	%db = WebGUI::SQL->quickHash("select * from databaseLink where databaseLinkId=$session{form}{dlid}");
	}
        $output .= helpIcon(69);
	$output .= '<h1>'.WebGUI::International::get(990).'</h1>';
	$f = WebGUI::HTMLForm->new;
        $f->hidden("op","editDatabaseLinkSave");
        $f->hidden("dlid",$session{form}{dlid});
	$f->readOnly($session{form}{dlid},WebGUI::International::get(991));
        $f->text("title",WebGUI::International::get(992),$db{title});
        $f->text("DSN",WebGUI::International::get(993),$db{DSN});
        $f->text("username",WebGUI::International::get(994),$db{username});
        $f->text("identifier",WebGUI::International::get(995),$db{identifier});
        $f->submit;
	$output .= $f->print;
        return _submenu($output);
}

#-------------------------------------------------------------------
sub www_editDatabaseLinkSave {
        return WebGUI::Privilege::insufficient unless (WebGUI::Privilege::isInGroup(3));
	if ($session{form}{dlid} eq "new") {
		$session{form}{dlid} = getNextId("databaseLinkId");
		WebGUI::SQL->write("insert into databaseLink (databaseLinkId) values ($session{form}{dlid})");
	}
	    WebGUI::SQL->write("update databaseLink set title=".quote($session{form}{title}).", DSN=".quote($session{form}{DSN}).",
		username=".quote($session{form}{username}).", identifier=".quote($session{form}{identifier})." where databaseLinkId=".$session{form}{dlid});
        return www_listDatabaseLinks();
}

#-------------------------------------------------------------------
sub www_listDatabaseLinks {
        return WebGUI::Privilege::adminOnly() unless(WebGUI::Privilege::isInGroup(3));
        my ($output, $p, $sth, %data, @row, $i);
        $output = helpIcon(68);
	$output .= '<h1>'.WebGUI::International::get(996).'</h1>';
        $sth = WebGUI::SQL->read("select * from databaseLink order by title");
	$row[$i] = '<tr><td valign="top" class="tableData"></td><td valign="top" class="tableData">'.WebGUI::International::get(1076).'</td></tr>';
	$i++;
        while (%data = $sth->hash) {
                $row[$i] = '<tr><td valign="top" class="tableData">'
			.deleteIcon('op=deleteDatabaseLink&dlid='.$data{databaseLinkId})
			.editIcon('op=editDatabaseLink&dlid='.$data{databaseLinkId})
			.copyIcon('op=copyDatabaseLink&dlid='.$data{databaseLinkId})
			.'</td>';
                $row[$i] .= '<td valign="top" class="tableData">'.$data{title}.'</td></tr>';
                $i++;
        }
	$sth->finish;
        $p = WebGUI::Paginator->new(WebGUI::URL::page('op=listDatabaseLinks'));
	$p->setDataByArrayRef(\@row);
        $output .= '<table border=1 cellpadding=3 cellspacing=0 align="center">';
        $output .= $p->getPage;
        $output .= '</table>';
        $output .= $p->getBarTraditional;
        return _submenu($output);
}


1;
