package WebGUI::Operation::Trash;

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
use strict qw(vars subs);
use Tie::CPHash;
use WebGUI::DateTime;
use WebGUI::Icon;
use WebGUI::Operation::Shared;
use WebGUI::Paginator;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;

our @ISA = qw(Exporter);
our @EXPORT = qw(&www_cutTrashItem &www_deleteTrashItem &www_deleteTrashItemConfirm
		&www_emptyTrash &www_emptyTrashConfirm &www_manageTrash);

#-------------------------------------------------------------------
sub _purgePage {
}

#-------------------------------------------------------------------
sub _purgeUserTrash {
        my (%properties, $base, $extended, $b, $wobjectId, $namespace, $w, $cmd, $userId, $bufferId, $a, $pageId);
        tie %properties, 'Tie::CPHash';

	$userId = $session{user}{userId};

        #WebGUI::ErrorHandler::audit("emptying user trash");

        # Delete wobjects
        $b = WebGUI::SQL->read("select * from wobject where pageId=3 and bufferUserId=" . $userId);
        while ($base = $b->hashRef) {
                $extended = WebGUI::SQL->quickHashRef("select * from ".$base->{namespace}."
                        where wobjectId=".$base->{wobjectId});
                %properties = (%{$base}, %{$extended});
                $cmd = "WebGUI::Wobject::".$properties{namespace};
                $w = $cmd->new(\%properties);
                $w->purge;
        }
        $b->finish;

        # Delete pages and all subpages
        $a = WebGUI::SQL->read("select pageId from page where parentId=3 and bufferUserId=" . $userId);
        while (($pageId) = $a->array) {
                _recursePageTree($pageId);
                _purgeWobjects($pageId);
                WebGUI::SQL->write("delete from page where pageId=$pageId");
        }
        $a->finish;
}

#-------------------------------------------------------------------
sub _purgeWobject {
	my (%properties, $base, $extended, $b, $wobjectId, $namespace, $w, $cmd);
	tie %properties, 'Tie::CPHash';
	$b = WebGUI::SQL->read("select * from wobject where wobjectId=$_[0]");
        while ($base = $b->hashRef) {
		$extended = WebGUI::SQL->quickHashRef("select * from ".$base->{namespace}." 
			where wobjectId=".$base->{wobjectId});
		%properties = (%{$base}, %{$extended});
        	$cmd = "WebGUI::Wobject::".$properties{namespace};
                $w = $cmd->new(\%properties);
		$w->purge;
        }
        $b->finish;
}

#-------------------------------------------------------------------
sub _purgeWobjects {
	my (%properties, $base, $extended, $b, $wobjectId, $namespace, $w, $cmd);
	tie %properties, 'Tie::CPHash';
	$b = WebGUI::SQL->read("select * from wobject where pageId=$_[0]");
        while ($base = $b->hashRef) {
		$extended = WebGUI::SQL->quickHashRef("select * from ".$base->{namespace}." 
			where wobjectId=".$base->{wobjectId});
		%properties = (%{$base}, %{$extended});
        	$cmd = "WebGUI::Wobject::".$properties{namespace};
                $w = $cmd->new(\%properties);
		$w->purge;
        }
        $b->finish;
}

#-------------------------------------------------------------------
sub _recursePageTree {
        my ($a, $pageId);
        $a = WebGUI::SQL->read("select pageId from page where parentId=$_[0]");
        while (($pageId) = $a->array) {
                _recursePageTree($pageId);
		_purgeWobjects($pageId);
                WebGUI::SQL->write("delete from page where pageId=$pageId");
        }
        $a->finish;
}

#-------------------------------------------------------------------
sub _submenu {
        my (%menu);
        tie %menu, 'Tie::IxHash';
	$menu{WebGUI::URL::page('op=manageTrash')} = WebGUI::International::get(10);
	if ($session{form}{systemTrash} ne "1") {
		$menu{WebGUI::URL::page('op=emptyTrash')} = WebGUI::International::get(11);
	}
	if ( ($session{setting}{sharedTrash} ne "1") && (WebGUI::Privilege::isInGroup(3)) ) {
		$menu{WebGUI::URL::page('op=manageTrash&systemTrash=1')} = WebGUI::International::get(964);
		if ($session{form}{systemTrash} eq "1") {
			$menu{WebGUI::URL::page('op=emptyTrash&systemTrash=1')} = WebGUI::International::get(967);
		}
	}
        return menuWrapper($_[0],\%menu);
}


#-------------------------------------------------------------------
sub www_cutTrashItem {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::isInGroup(4));
	if ($session{form}{wid} ne "") {
		if ( ($session{setting}{sharedTrash} ne "1") && (!(WebGUI::Privilege::isInGroup(3)) ) ) {
			my ($bufferUserId) = WebGUI::SQL->quickArray("select bufferUserId from wobject "
								."where wobjectId=" .$session{form}{wid});
			return WebGUI::Privilege::insufficient() unless ($bufferUserId eq $session{user}{userId});
		}
		WebGUI::SQL->write("update wobject set pageId=2, "
				."bufferUserId=". $session{user}{userId} .", "
				."bufferDate=". time() .", "
				."bufferPrevId=3 "
				."where wobjectId=" .$session{form}{wid});
		WebGUI::ErrorHandler::audit("moved wobject ". $session{form}{wid} ." from trash to clipboard");
	} elsif ($session{form}{pageId} ne "") {
		if ( ($session{setting}{sharedTrash} ne "1") && (!(WebGUI::Privilege::isInGroup(3)) ) ) {
			my ($bufferUserId) = WebGUI::SQL->quickArray("select bufferUserId from page "
								."where pageId=" .$session{form}{pageId});
			return WebGUI::Privilege::insufficient() unless ($bufferUserId eq $session{user}{userId});
		}
		WebGUI::SQL->write("update page set parentId=2, "
				."bufferUserId=". $session{user}{userId} .", "
				."bufferDate=". time() .", "
				."bufferPrevId=3 "
				."where pageId=" .$session{form}{pageId});
        	WebGUI::ErrorHandler::audit("moved page ". $session{form}{pageId} ." from trash to clipboard");
	}
        WebGUI::Session::refreshPageInfo($session{page}{pageId});
        return "";
}

#-------------------------------------------------------------------
sub www_deleteTrashItem {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::isInGroup(4));
        my ($output);
	if ($session{form}{wid} ne "") {
        	$output .= helpIcon(14);
	} elsif ($session{form}{pageId} ne "") {
        	$output .= helpIcon(3);
	}
        $output .= '<h1>'.WebGUI::International::get(42).'</h1>';
        $output .= WebGUI::International::get(966).'<p>';
	if ($session{form}{wid} ne "") {
        	$output .= '<div align="center"><a href="'.WebGUI::URL::page('op=deleteTrashItemConfirm&wid='
			.$session{form}{wid}) . '">'.WebGUI::International::get(44).'</a>';
	} elsif ($session{form}{pageId} ne "") {
        	$output .= '<div align="center"><a href="'.WebGUI::URL::page('op=deleteTrashItemConfirm&pageId='
			.$session{form}{pageId}) . '">'.WebGUI::International::get(44).'</a>';
	}
        $output .= '&nbsp;&nbsp;&nbsp;&nbsp;<a href="'.WebGUI::URL::page().'">'
		.WebGUI::International::get(45).'</a></div>';
        return $output;
}

#-------------------------------------------------------------------
sub www_deleteTrashItemConfirm {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::isInGroup(4));
	if ($session{form}{wid} ne "") {
		if ( ($session{setting}{sharedTrash} eq "1") || (WebGUI::Privilege::isInGroup(3)) ) {
			_purgeWobject($session{form}{wid});
		} else {
			my ($bufferUserId) = WebGUI::SQL->quickArray("select bufferUserId from wobject "
								."where wobjectId=" .$session{form}{wid});
			return WebGUI::Privilege::insufficient() unless ($bufferUserId eq $session{user}{userId});
			_purgeWobject($session{form}{wid});
		}
		WebGUI::ErrorHandler::audit("purged wobject ". $session{form}{wid} ." from trash");
	} elsif ($session{form}{pageId} ne "") {
		if ( ($session{setting}{sharedTrash} eq "1") || (WebGUI::Privilege::isInGroup(3)) ) {
			_recursePageTree($session{form}{pageId});
			_purgeWobjects($session{form}{pageId});
                	WebGUI::SQL->write("delete from page where pageId=" .$session{form}{pageId});
		} else {
			my ($bufferUserId) = WebGUI::SQL->quickArray("select bufferUserId from page "
								."where pageId=" .$session{form}{pageId});
			return WebGUI::Privilege::insufficient() unless ($bufferUserId eq $session{user}{userId});
			_recursePageTree($session{form}{pageId});
			_purgeWobjects($session{form}{pageId});
                	WebGUI::SQL->write("delete from page where pageId=" .$session{form}{pageId});
		}
        	WebGUI::ErrorHandler::audit("purged page ". $session{form}{pageId} ." from trash");
	}
        WebGUI::Session::refreshPageInfo($session{page}{pageId});
        return "";
}

#-------------------------------------------------------------------
sub www_emptyTrash {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::isInGroup(4));
        my ($output);
	$output = helpIcon(46);
        $output .= '<h1>'.WebGUI::International::get(42).'</h1>';
        $output .= WebGUI::International::get(162).'<p>';
        $output .= WebGUI::International::get(651).'<p>';
	if ($session{form}{systemTrash} eq "1") {
        	$output .= '<div align="center"><a href="'.WebGUI::URL::page('op=emptyTrashConfirm&systemTrash=1')
                	.'">'.WebGUI::International::get(44).'</a>';
	} else {
        	$output .= '<div align="center"><a href="'.WebGUI::URL::page('op=emptyTrashConfirm')
                	.'">'.WebGUI::International::get(44).'</a>';
	}
        $output .= '&nbsp;&nbsp;&nbsp;&nbsp;<a href="'.WebGUI::URL::page().'">'
                .WebGUI::International::get(45).'</a></div>';
        return $output;
}

#-------------------------------------------------------------------
sub www_emptyTrashConfirm {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::isInGroup(4));
	my ($allUsers);
	if ($session{setting}{sharedTrash} eq "1") {
		$allUsers = 1;
	} elsif ($session{form}{systemTrash} eq "1") {
		return WebGUI::Privilege::adminOnly() unless (WebGUI::Privilege::isInGroup(3));
		$allUsers = 1;
	} else {
		$allUsers = 0;
	}
	if ($allUsers eq "1") {
		_recursePageTree(3);
		_purgeWobjects(3);
        	WebGUI::ErrorHandler::audit("emptied system trash");
	} else {
		_purgeUserTrash();
        	WebGUI::ErrorHandler::audit("emptied user trash");
	}
        WebGUI::Session::refreshPageInfo($session{page}{pageId});
        return "";
}

#-------------------------------------------------------------------
sub www_manageTrash {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::isInGroup(4));

	my ($sth, @data, @row, @sorted_row, $i, $p, $allUsers);
	my $output = helpIcon(66);

	# Add appropriate html page header
	if ($session{setting}{sharedTrash} eq "1") {
		$allUsers = 1;
        	$output .= '<h1>'. WebGUI::International::get(962) .'</h1>';
	} elsif ($session{form}{systemTrash} eq "1") {
		return WebGUI::Privilege::adminOnly() unless (WebGUI::Privilege::isInGroup(3));
		$allUsers = 1;
        	$output .= '<h1>'. WebGUI::International::get(965) .'</h1>';
	} else {
		$allUsers = 0;
        	$output .= '<h1>'. WebGUI::International::get(962) .'</h1>';
	}

	# Generate list of pages in trash
	if ($allUsers) {
		$sth = WebGUI::SQL->read("select pageId,title,urlizedTitle,bufferUserId,bufferDate,bufferPrevId "
			."from page where parentId=3 order by bufferDate");
	} else {
		$sth = WebGUI::SQL->read("select pageId,title,urlizedTitle,bufferUserId,bufferDate,bufferPrevId "
			."from page where parentId=3 and bufferUserId="
			. $session{user}{userId} . " order by bufferDate");
	}
        while (@data = $sth->array) {
		my ($pageId,$title,$urlizedTitle,$bufferUserId,$bufferDate,$bufferPrevId,$url,$htmlData);
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

		# create html row data
		$htmlData = '<tr>';
		$htmlData .= '<td valign="top" class="tableData">'
				.pageIcon()
				.deleteIcon('op=deleteTrashItem&pageId='.$pageId)
				.cutIcon('op=cutTrashItem&pageId='.$pageId);
		$htmlData .= '</td>';
		$htmlData .= '<td valign="top" class="tableData">'. $title .'</td>';
		$htmlData .= '<td valign="top" class="tableData">'. WebGUI::International::get(2) .'</td>';
		$htmlData .= '<td valign="top" class="tableData">'. $bufferDate .'</td>';
		$htmlData .= '<td valign="top" class="tableData">'. $bufferPrevId .'</td>';
		if ($allUsers) {
			$htmlData .= '<td valign="top" class="tableData">'. $bufferUserId .'</td>';
		}
		$htmlData .= '</tr>';

		# store row data in array of arrays with integer bufferDate for later sorting
		push @row, [$data[4], $htmlData];
        }

	# Generate list of wobjects in clipboard
	if ($allUsers) {
		$sth = WebGUI::SQL->read("select wobjectId,namespace,title,bufferUserId,bufferDate,bufferPrevId "
			. "from wobject where pageId=3 order by bufferDate");
	} else {
		$sth = WebGUI::SQL->read("select wobjectId,namespace,title,bufferUserId,bufferDate,bufferPrevId "
			. "from wobject where pageId=3 and bufferUserId="
			. $session{user}{userId} ." order by bufferDate");
	}
        while (@data = $sth->array) {
		my ($wobjectId,$namespace,$title,$bufferUserId,$bufferDate,$bufferPrevId,$url,$htmlData);

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

		# create html row data
		$htmlData = '<tr>';
		$htmlData .= '<td valign="top" class="tableData">'
				.wobjectIcon()
				.deleteIcon('op=deleteTrashItem&wid='.$wobjectId)
				.cutIcon('op=cutTrashItem&wid='.$wobjectId);
		$htmlData .= '</td>';
		$htmlData .= '<td valign="top" class="tableData">'. $title .'</td>';
		$htmlData .= '<td valign="top" class="tableData">'. $namespace .'</td>';
		$htmlData .= '<td valign="top" class="tableData">'. $bufferDate .'</td>';
		$htmlData .= '<td valign="top" class="tableData">'. $bufferPrevId .'</td>';
		if ($allUsers) {
			$htmlData .= '<td valign="top" class="tableData">'. $bufferUserId .'</td>';
		}
		$htmlData .= '</tr>';

		# store row data in array of arrays with integer bufferDate for later sorting
		push @row, [$data[4], $htmlData];
        }
        $sth->finish;

	# Reverse sort row htmlData by bufferDate
	@sorted_row = sort {$b->[0] <=> $a->[0]} @row;
	@row = ();
 	for $i ( 0 .. $#sorted_row ) {
		push @row, $sorted_row[$i][1];
	}

	# Create output with pagination
        $output .= '<table border=1 cellpadding=5 cellspacing=0 align="center">';
        $output .= '<tr><th></th>';
	$output .= '<th>'. WebGUI::International::get(99) .'</th>';
	$output .= '<th>'. WebGUI::International::get(783) .'</th>';
	$output .= '<th>'. WebGUI::International::get(963) .'</th>';
	$output .= '<th>'. WebGUI::International::get(953) .'</th>';
	if ($allUsers) {
		$output .= '<th>'. WebGUI::International::get(50) .'</th>';
	}
	$output .= '</tr>';
	if ($session{form}{systemTrash} eq "1") {
        	$p = WebGUI::Paginator->new(WebGUI::URL::page('op=manageTrash&systemTrash=1'));
	} else {
        	$p = WebGUI::Paginator->new(WebGUI::URL::page('op=manageTrash'));
	}
	$p->setDataByArrayRef(\@row);
        $output .= $p->getPage($session{form}{pn});
        $output .= '</table>';
        $output .= $p->getBarTraditional($session{form}{pn});
        return _submenu($output);
}

1;
