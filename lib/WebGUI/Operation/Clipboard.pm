package WebGUI::Operation::Clipboard;

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
use WebGUI::DateTime;
use WebGUI::Grouping;
use WebGUI::HTMLForm;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Operation::Shared;
use WebGUI::Page;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::TabForm;
use WebGUI::URL;
use WebGUI::Utility;

our @ISA = qw(Exporter);
our @EXPORT = qw(&www_deleteClipboardItem &www_deleteClipboardItemConfirm
		&www_emptyClipboard &www_emptyClipboardConfirm &www_manageClipboard);

#-------------------------------------------------------------------
sub _submenu {
        my (%menu);
        tie %menu, 'Tie::IxHash';
	$menu{WebGUI::URL::page('op=manageClipboard')} = WebGUI::International::get(949);
	if ($session{form}{systemClipboard} ne "1") {
		$menu{WebGUI::URL::page('op=emptyClipboard')} = WebGUI::International::get(950);
	}
	if ( ($session{setting}{sharedClipboard} ne "1") && (WebGUI::Privilege::isInGroup(3)) ) {
		$menu{WebGUI::URL::page('op=manageClipboard&systemClipboard=1')} = WebGUI::International::get(954);
		if ($session{form}{systemClipboard} eq "1") {
			$menu{WebGUI::URL::page('op=emptyClipboard&systemClipboard=1')} = WebGUI::International::get(959);
		}
	}
        return menuWrapper($_[0],\%menu);
}


#-------------------------------------------------------------------
sub www_deleteClipboardItem {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::isInGroup(4));
        my ($output);
	if ($session{form}{wid} ne "") {
        	$output .= helpIcon(14);
	} elsif ($session{form}{pageId} ne "") {
        	$output .= helpIcon(3);
	}
        $output .= '<h1>'.WebGUI::International::get(42).'</h1>';
        $output .= WebGUI::International::get(956).'<p>';
	if ($session{form}{wid} ne "") {
        	$output .= '<div align="center"><a href="'.WebGUI::URL::page('op=deleteClipboardItemConfirm&wid='
			.$session{form}{wid}) . '">'.WebGUI::International::get(44).'</a>';
	} elsif ($session{form}{pageId} ne "") {
        	$output .= '<div align="center"><a href="'.WebGUI::URL::page('op=deleteClipboardItemConfirm&pageId='
			.$session{form}{pageId}) . '">'.WebGUI::International::get(44).'</a>';
	}
        $output .= '&nbsp;&nbsp;&nbsp;&nbsp;<a href="'.WebGUI::URL::page().'">'
		.WebGUI::International::get(45).'</a></div>';
        return $output;
}

#-------------------------------------------------------------------
sub www_deleteClipboardItemConfirm {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::isInGroup(4));
	if ($session{form}{wid} ne "") {
		if ( ($session{setting}{sharedClipboard} eq "1") || (WebGUI::Privilege::isInGroup(3)) ) {
			WebGUI::SQL->write("update wobject set pageId=3, "
                		."bufferDate=".time().", "
                		."bufferUserId=".$session{user}{userId} .", "
                		."bufferPrevId=2 "
				."where pageId=2 "
				."and wobjectId=" . $session{form}{wid}
				);
		} else {
			WebGUI::SQL->write("update wobject set pageId=3, "
                		."bufferDate=".time().", "
                		."bufferUserId=".$session{user}{userId} .", "
                		."bufferPrevId=2 "
				."where pageId=2 "
				."and wobjectId=" . $session{form}{wid} ." "
                		."and bufferUserId=".$session{user}{userId}
				);
		}
		WebGUI::ErrorHandler::audit("moved wobject ". $session{form}{wid} ." from clipboard to trash");
	} elsif ($session{form}{pageId} ne "") {
		if ( ($session{setting}{sharedClipboard} eq "1") || (WebGUI::Privilege::isInGroup(3)) ) {
        		WebGUI::SQL->write("update page set parentId=3, "
                		."bufferDate=".time().", "
                		."bufferUserId=".$session{user}{userId} .", "
                		."bufferPrevId=2 "
                		."where parentId=2 "
                		."and pageId=".$session{form}{pageId}
				);
		} else {
        		WebGUI::SQL->write("update page set parentId=3, "
                		."bufferDate=".time().", "
                		."bufferUserId=".$session{user}{userId} .", "
                		."bufferPrevId=2 "
                		."where parentId=2 "
                		."and pageId=".$session{form}{pageId} ." "
                		."and bufferUserId=".$session{user}{userId}
				);
		}
        	WebGUI::ErrorHandler::audit("moved page ". $session{form}{pageId} ." from clipboard to trash");
	}
        WebGUI::Session::refreshPageInfo($session{page}{pageId},'op=manageClipboard');
        return "";
}

#-------------------------------------------------------------------
sub www_emptyClipboard {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::isInGroup(4));
        my ($output);
	my $output = helpIcon(67);
        $output .= '<h1>'.WebGUI::International::get(42).'</h1>';
        $output .= WebGUI::International::get(951).'<p>';
	if ( ($session{setting}{sharedClipboard} ne "1") && (WebGUI::Privilege::isInGroup(3)) ) {
        	$output .= '<div align="center"><a href="'.WebGUI::URL::page('op=emptyClipboardConfirm&systemClipboard=1')
                	.'">'.WebGUI::International::get(44).'</a>';
	} else {
        	$output .= '<div align="center"><a href="'.WebGUI::URL::page('op=emptyClipboardConfirm')
                	.'">'.WebGUI::International::get(44).'</a>';
	}
        $output .= '&nbsp;&nbsp;&nbsp;&nbsp;<a href="'.WebGUI::URL::page().'">'
                .WebGUI::International::get(45).'</a></div>';
        return $output;
}

#-------------------------------------------------------------------
sub www_emptyClipboardConfirm {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::isInGroup(4));
	my ($allUsers);
	if ($session{setting}{sharedClipboard} eq "1") {
		$allUsers = 1;
	} elsif ($session{form}{systemClipboard} eq "1") {
		return WebGUI::Privilege::adminOnly() unless (WebGUI::Privilege::isInGroup(3));
		$allUsers = 1;
	} else {
		$allUsers = 0;
	}
	if ($allUsers eq "1") {
        	WebGUI::SQL->write("update page set parentId=3, "
                	."bufferDate=".time().", "
                	."bufferUserId=".$session{user}{userId} .", "
                	."bufferPrevId=2 "
                	."where parentId=2 ");
        	WebGUI::SQL->write("update wobject set pageId=3, "
                	."bufferDate=".time().", "
                	."bufferUserId=".$session{user}{userId} .", "
                	."bufferPrevId=2 "
                	."where pageId=2 ");
        	WebGUI::ErrorHandler::audit("emptied clipboard to trash");
	} else {
        	WebGUI::SQL->write("update page set parentId=3, "
                	."bufferDate=".time().", "
                	."bufferUserId=".$session{user}{userId} .", "
                	."bufferPrevId=2 "
                	."where parentId=2 "
                	."and bufferUserId=".$session{user}{userId});
        	WebGUI::SQL->write("update wobject set pageId=3, "
                	."bufferDate=".time().", "
                	."bufferUserId=".$session{user}{userId} .", "
                	."bufferPrevId=2 "
                	."where pageId=2 "
                	."and bufferUserId=".$session{user}{userId});
        	WebGUI::ErrorHandler::audit("emptied user clipboard to trash");
	}
        WebGUI::Session::refreshPageInfo($session{page}{pageId});
        return "";
}

#-------------------------------------------------------------------
sub www_manageClipboard {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::isInGroup(4));
	my ($sth, @data, @row, $i, $p, $allUsers);
	my $output = helpIcon(65);

	if ($session{setting}{sharedClipboard} eq "1") {
		$allUsers = 1;
        	$output .= '<h1>'. WebGUI::International::get(948) .'</h1>';
	} elsif ($session{form}{systemClipboard} eq "1") {
		return WebGUI::Privilege::adminOnly() unless (WebGUI::Privilege::isInGroup(3));
		$allUsers = 1;
        	$output .= '<h1>'. WebGUI::International::get(955) .'</h1>';
	} else {
		$allUsers = 0;
        	$output .= '<h1>'. WebGUI::International::get(948) .'</h1>';
	}
	


	#
	# Generate list of pages
	#
	if ($allUsers) {
		$sth = WebGUI::SQL->read("select pageId,title,urlizedTitle,bufferUserId,bufferDate,bufferPrevId "
			."from page where parentId=2 order by bufferDate desc,bufferUserId");
	} else {
		$sth = WebGUI::SQL->read("select pageId,title,urlizedTitle,bufferUserId,bufferDate,bufferPrevId "
			."from page where parentId=2 and bufferUserId="
			. $session{user}{userId} . " order by bufferDate desc");
	}
        while (@data = $sth->array) {
		my ($pageId,$title,$urlizedTitle,$bufferUserId,$bufferDate,$bufferPrevId,$url);
		$pageId = $data[0];
		$title = $data[1];
		$urlizedTitle = $data[2];
		$title = '<a href="'. WebGUI::URL::gateway($urlizedTitle) .'">' .$title .'</a>';

		$bufferUserId = $data[3];
		if ($bufferUserId ne "") {
			my ($bufferUsername) = WebGUI::SQL->quickArray("select username from users where userId=".$bufferUserId);
			$bufferUserId = '<a href="' .WebGUI::URL::page('op=viewProfile&uid='.$bufferUserId) .'">'
					.$bufferUsername .'</a>';
		}
		$bufferDate = epochToHuman($data[4]);
		$bufferPrevId = $data[5];
		if ($bufferPrevId ne "") {
			($bufferPrevId,$url) = WebGUI::SQL->quickArray("select title,urlizedTitle "
									."from page where pageId=".$bufferPrevId);
			if ($url ne "") {
                		$bufferPrevId = '<a href="'. WebGUI::URL::gateway($url) .'">' .$bufferPrevId .'</a>';
			}
		}
                $row[$i] = '<tr>';
                $row[$i] .= '<td valign="top" class="tableData">'
				.pageIcon()
				.deleteIcon('op=deleteClipboardItem&pageId='.$pageId)
				.pasteIcon('op=pastePage&pageId='.$pageId);
                $row[$i] .= '</td>';
                $row[$i] .= '<td valign="top" class="tableData">'.$title;
                $row[$i] .= '</td>';
                $row[$i] .= '<td valign="top" class="tableData">'.WebGUI::International::get(2);
                $row[$i] .= '</td>';
                $row[$i] .= '<td valign="top" class="tableData">'.$bufferDate;
                $row[$i] .= '</td>';
                $row[$i] .= '<td valign="top" class="tableData">'.$bufferPrevId;
                $row[$i] .= '</td>';
		if ($allUsers) {
                	$row[$i] .= '<td valign="top" class="tableData">'.$bufferUserId;
                	$row[$i] .= '</td>';
		}
                $row[$i] .= '</tr>';
                $i++;
        }

	#
	# Generate list of wobjects
	#
	if ($allUsers) {
		$sth = WebGUI::SQL->read("select wobjectId,namespace,title,bufferUserId,bufferDate,bufferPrevId "
			. "from wobject where pageId=2 order by bufferDate desc,bufferUserId");
	} else {
		$sth = WebGUI::SQL->read("select wobjectId,namespace,title,bufferUserId,bufferDate,bufferPrevId "
			. "from wobject where pageId=2 and bufferUserId="
			. $session{user}{userId} ." order by bufferDate desc");
	}
        while (@data = $sth->array) {
		my ($wobjectId,$namespace,$title,$bufferUserId,$bufferDate,$bufferPrevId,$url);

		$wobjectId = $data[0];
		$namespace = $data[1];
		$title = $data[2];
		$title = '<a href="'. WebGUI::URL::page('func=view&wid='. $wobjectId) .'">'. $title .'</a>';

		$bufferPrevId = $data[5];
		if ($bufferPrevId ne "") {
			($bufferPrevId,$url) = WebGUI::SQL->quickArray("select title,urlizedTitle "
									."from page where pageId=".$bufferPrevId);
			if ($url ne "") {
                		$bufferPrevId = '<a href="'. WebGUI::URL::gateway($url) .'">' .$bufferPrevId .'</a>';
			}
		}
		$bufferDate = epochToHuman($data[4]);

		$bufferUserId = $data[3];
		if ($bufferUserId ne "") {
			my ($bufferUsername) = WebGUI::SQL->quickArray("select username from users where userId=".$bufferUserId);
			$bufferUserId = '<a href="' .WebGUI::URL::page('op=viewProfile&uid='.$bufferUserId) .'">'
					.$bufferUsername .'</a>';
		}

                $row[$i] = '<tr>';
                $row[$i] .= '<td valign="top" class="tableData">'
				.wobjectIcon()
				.deleteIcon('op=deleteClipboardItem&wid='.$wobjectId)
				.pasteIcon('func=paste&wid='.$wobjectId);
                $row[$i] .= '<td valign="top" class="tableData">'.$title;
                $row[$i] .= '</td>';
                $row[$i] .= '<td valign="top" class="tableData">'.$namespace;
                $row[$i] .= '</td>';
                $row[$i] .= '<td valign="top" class="tableData">'.$bufferDate;
                $row[$i] .= '</td>';
                $row[$i] .= '<td valign="top" class="tableData">'.$bufferPrevId;
                $row[$i] .= '</td>';
		if ($allUsers) {
                	$row[$i] .= '<td valign="top" class="tableData">'.$bufferUserId;
                	$row[$i] .= '</td>';
		}
                $row[$i] .= '</tr>';
                $i++;
        }
        $sth->finish;
	if ($session{form}{systemClipboard} eq "1") {
        	$p = WebGUI::Paginator->new(WebGUI::URL::page('op=manageClipboard&systemClipboard=1'),\@row);
	} else {
        	$p = WebGUI::Paginator->new(WebGUI::URL::page('op=manageClipboard'),\@row);
	}
        $output .= '<table border=1 cellpadding=5 cellspacing=0 align="center">';
        $output .= '<tr><th></th>'
		.'<th>'. WebGUI::International::get(99) .'</th>'
		.'<th>'. WebGUI::International::get(783) .'</th>'
		.'<th>'. WebGUI::International::get(952) .'</th>'
		.'<th>'. WebGUI::International::get(953) .'</th>';
		if ($allUsers) {
			$output .= '<th>'. WebGUI::International::get(50) .'</th>'
			.'</tr>';
		} else {
			$output .= '</tr>';
		}
        $output .= $p->getPage($session{form}{pn});
        $output .= '</table>';
        $output .= $p->getBarTraditional($session{form}{pn});
        return _submenu($output);
}

1;
