package WebGUI::Operation::Page;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001 Plain Black Software.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use Exporter;
use strict;
use WebGUI::Form;
use WebGUI::International;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Utility;

our @ISA = qw(Exporter);
our @EXPORT = qw(&www_movePageUp &www_movePageDown &www_addPage &www_addPageSave &www_cutPage &www_deletePage &www_deletePageConfirm &www_editPage &www_editPageSave &www_pastePage);

#-------------------------------------------------------------------
sub _recursivelyChangePrivileges {
        my ($sth, $pageId);
        $sth = WebGUI::SQL->read("select pageId from page where parentId=$_[0]",$session{dbh});
        while (($pageId) = $sth->array) {
        	WebGUI::SQL->write("update page set ownerId=$session{form}{ownerId}, ownerView=$session{form}{ownerView}, ownerEdit=$session{form}{ownerEdit}, groupId='$session{form}{groupId}', groupView=$session{form}{groupView}, groupEdit=$session{form}{groupEdit}, worldView=$session{form}{worldView}, worldEdit=$session{form}{worldEdit} where pageId=$pageId",$session{dbh});
                _recursivelyChangePrivileges($pageId);
        }
	$sth->finish;
}

#-------------------------------------------------------------------
sub _recursivelyChangeStyle {
	my ($sth, $pageId);
	$sth = WebGUI::SQL->read("select pageId from page where parentId=$_[0]",$session{dbh});	
	while (($pageId) = $sth->array) {
		WebGUI::SQL->write("update page set styleId=$session{form}{styleId} where pageId=$pageId",$session{dbh});
		_recursivelyChangeStyle($pageId);
	}
	$sth->finish;
}

#-------------------------------------------------------------------
sub _reorderPages {
        my ($sth, $i, $pid);
        $sth = WebGUI::SQL->read("select pageId from page where parentId=$_[0] order by sequenceNumber",$session{dbh});
        while (($pid) = $sth->array) {
                WebGUI::SQL->write("update page set sequenceNumber='$i' where pageId=$pid",$session{dbh});
                $i++;
        }
        $sth->finish;
}

#-------------------------------------------------------------------
sub www_addPage {
	my ($output);
	if (WebGUI::Privilege::canEditPage()) {
		$output = '<a href="'.$session{page}{url}.'?op=viewHelp&hid=1"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a>';
		$output .= '<h1>'.WebGUI::International::get(98).'</h1>';
		$output .= '<form method="post" action="'.$session{page}{url}.'">';
		$output .= WebGUI::Form::hidden("op","addPageSave");
		$output .= '<table>';
		$output .= '<tr><td class="formDescription">'.WebGUI::International::get(99).'</td><td>'.WebGUI::Form::text("title",20,30,$session{form}{title}).'</td></tr>';
		$output .= '<tr><td class="formDescription">'.WebGUI::International::get(100).'</td><td>'.WebGUI::Form::textArea("metaTags",$session{form}{metaTags}).'</td></tr>';
		$output .= '<tr><td></td><td>'.WebGUI::Form::submit(WebGUI::International::get(62)).'</td></tr>';
		$output .= '</table></form>';	
		return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_addPageSave {
	my ($urlizedTitle, $test, $nextSeq);
	if (WebGUI::Privilege::canEditPage()) {
		($nextSeq) = WebGUI::SQL->quickArray("select max(sequenceNumber)+1 from page where parentId=$session{page}{pageId}",$session{dbh});
		$urlizedTitle = urlizeTitle($session{form}{title});
		while (($test) = WebGUI::SQL->quickArray("select urlizedTitle from page where urlizedTitle='$urlizedTitle'",$session{dbh})) {
			$urlizedTitle .= 2;
		}
		WebGUI::SQL->write("insert into page values (".getNextId("pageId").", $session{page}{pageId}, ".quote($session{form}{title}).", $session{page}{styleId}, $session{user}{userId}, $session{page}{ownerView}, $session{page}{ownerEdit}, $session{page}{groupId}, $session{page}{groupView}, $session{page}{groupEdit}, $session{page}{worldView}, $session{page}{worldEdit}, '$nextSeq', ".quote($session{form}{metaTags}).", '$urlizedTitle')",$session{dbh});
		return "";
	} else {
		return WebGUI::Privilege::insufficient();
	}
}

#-------------------------------------------------------------------
sub www_cutPage {
        if ($session{page}{pageId} < 26) {
                return WebGUI::Privilege::vitalComponent();
        } elsif (WebGUI::Privilege::canEditPage()) {
                WebGUI::SQL->write("update page set parentId=2 where pageId=".$session{page}{pageId},$session{dbh});
		_reorderPages($session{page}{parentId});
                WebGUI::Session::refreshPageInfo($session{page}{parentId});
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deletePage {
	my ($output);
	if ($session{page}{pageId} < 26) {
		return WebGUI::Privilege::vitalComponent();
	} elsif (WebGUI::Privilege::canEditPage()) {
		$output .= '<a href="'.$session{page}{url}.'?op=viewHelp&hid=3"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a>';
		$output .= '<h1>'.WebGUI::International::get(42).'</h1>';
		$output .= WebGUI::International::get(101).'<p>';
		$output .= '<div align="center"><a href="'.$session{page}{url}.'?op=deletePageConfirm">'.WebGUI::International::get(44).'</a>';
		$output .= '&nbsp;&nbsp;&nbsp;&nbsp;<a href="'.$session{page}{url}.'">'.WebGUI::International::get(45).'</a></div>';
		return $output;
	} else {
		return WebGUI::Privilege::insufficient();
	}
}

#-------------------------------------------------------------------
sub www_deletePageConfirm {
        if ($session{page}{pageId} < 25) {
		return WebGUI::Privilege::vitalComponent();
        } elsif (WebGUI::Privilege::canEditPage()) {
		WebGUI::SQL->write("update page set parentId=3 where pageId=".$session{page}{pageId},$session{dbh});
		_reorderPages($session{page}{parentId});
		WebGUI::Session::refreshPageInfo($session{page}{parentId});
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_editPage {
        my ($output, %yesNo, %hash, @array);
	tie %hash, "Tie::IxHash";
        if (WebGUI::Privilege::canEditPage()) {
		%yesNo = ("0"=>"No", "1"=>"Yes");
                $output = '<a href="'.$session{page}{url}.'?op=viewHelp&hid=2"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a>';
		$output .= '<h1>'.WebGUI::International::get(102).'</h1>';
		$output .= '<form method="post" action="'.$session{page}{url}.'">';
                $output .= WebGUI::Form::hidden("op","editPageSave");
                $output .= '<table>';
		$output .= '<tr><td colspan=2><b>'.WebGUI::International::get(103).'</b></td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(99).'</td><td>'.WebGUI::Form::text("title",20,30,$session{page}{title}).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(104).'</td><td>'.WebGUI::Form::text("urlizedTitle",20,30,$session{page}{urlizedTitle}).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(100).'</td><td>'.WebGUI::Form::textArea("metaTags",$session{page}{metaTags}).'</td></tr>';
		$output .= '<tr><td colspan=2><hr size=1><b>'.WebGUI::International::get(105).'</b></td></tr>';
		%hash = WebGUI::SQL->buildHash("select styleId,name from style where name<>'Reserved' order by name",$session{dbh});
		$array[0] = $session{page}{styleId};
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(105).'</td><td>'.WebGUI::Form::selectList("styleId",\%hash,\@array).' <span class="formSubtext"><a href="'.$session{page}{url}.'?op=listStyles">'.WebGUI::International::get(6).'</a></span></td></tr>';
                $output .= '<tr><td class="formDescription"></td><td>'.WebGUI::Form::checkbox("recurseStyle","yes").' <span class="formSubtext">'.WebGUI::International::get(106).'</span></td></tr>';
		$output .= '<tr><td colspan=2><hr size=1><b>'.WebGUI::International::get(107).'</b></td></tr>';
		%hash = WebGUI::SQL->buildHash("select users.userId,users.username from users,groupings where groupings.groupId=4 and groupings.userId=users.userId order by users.username",$session{dbh});
		$array[0] = $session{page}{ownerId};
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(108).'</td><td>'.WebGUI::Form::selectList("ownerId",\%hash,\@array).' <span class="formSubtext"><a href="'.$session{page}{url}.'?op=listUsers">'.WebGUI::International::get(7).'</a></span></td></tr>';
		$array[0] = $session{page}{ownerView};
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(109).'</td><td>'.WebGUI::Form::selectList("ownerView",\%yesNo,\@array).'</td></tr>';
		$array[0] = $session{page}{ownerEdit};
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(110).'</td><td>'.WebGUI::Form::selectList("ownerEdit",\%yesNo,\@array).'</td></tr>';
		%hash = WebGUI::SQL->buildHash("select groupId,groupName from groups where groupName<>'Reserved' order by groupName",$session{dbh});
		$array[0] = $session{page}{groupId};
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(111).'</td><td>'.WebGUI::Form::selectList("groupId",\%hash,\@array).' <span class="formSubtext"><a href="'.$session{page}{url}.'?op=listGroups">'.WebGUI::International::get(5).'</a></span></td></tr>';
		$array[0] = $session{page}{groupView};
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(112).'</td><td>'.WebGUI::Form::selectList("groupView",\%yesNo,\@array).'</td></tr>';
		$array[0] = $session{page}{groupEdit};
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(113).'</td><td>'.WebGUI::Form::selectList("groupEdit",\%yesNo,\@array).'</td></tr>';
		$array[0] = $session{page}{worldView};
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(114).'</td><td>'.WebGUI::Form::selectList("worldView",\%yesNo,\@array).'</td></tr>';
		$array[0] = $session{page}{worldEdit};
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(115).'</td><td>'.WebGUI::Form::selectList("worldEdit",\%yesNo,\@array).'</td></tr>';
                $output .= '<tr><td class="formDescription"></td><td>'.WebGUI::Form::checkbox("recursePrivs","yes").' <span class="formSubtext">'.WebGUI::International::get(116).'</span></td></tr>';
                $output .= '<tr><td></td><td>'.WebGUI::Form::submit(WebGUI::International::get(62)).'</td></tr>';
                $output .= '</table></form>';
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_editPageSave {
        my (%parent, $urlizedTitle, $test);
        if (WebGUI::Privilege::canEditPage()) {
                $urlizedTitle = urlizeTitle($session{form}{urlizedTitle});
                while (($test) = WebGUI::SQL->quickArray("select urlizedTitle from page where urlizedTitle='$urlizedTitle' and pageId<>$session{page}{pageId}",$session{dbh})) {
                        $urlizedTitle .= 2;
                }
                WebGUI::SQL->write("update page set title=".quote($session{form}{title}).", styleId=$session{form}{styleId}, ownerId=$session{form}{ownerId}, ownerView=$session{form}{ownerView}, ownerEdit=$session{form}{ownerEdit}, groupId='$session{form}{groupId}', groupView=$session{form}{groupView}, groupEdit=$session{form}{groupEdit}, worldView=$session{form}{worldView}, worldEdit=$session{form}{worldEdit}, metaTags=".quote($session{form}{metaTags}).", urlizedTitle='$urlizedTitle' where pageId=$session{page}{pageId}",$session{dbh});
		if ($session{form}{recurseStyle} eq "yes") {
			_recursivelyChangeStyle($session{page}{pageId});
		}
		if ($session{form}{recursePrivs} eq "yes") {
			_recursivelyChangePrivileges($session{page}{pageId});
		}
		WebGUI::Session::refreshPageInfo($session{page}{pageId});
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_movePageDown {
        my (@data, $thisSeq);
        if (WebGUI::Privilege::canEditPage()) {
                ($thisSeq) = WebGUI::SQL->quickArray("select sequenceNumber from page where pageId=$session{page}{pageId}",$session{dbh});
                @data = WebGUI::SQL->quickArray("select pageId from page where parentId=$session{page}{parentId} and sequenceNumber=$thisSeq+1",$session{dbh});
                if ($data[0] ne "") {
                        WebGUI::SQL->write("update page set sequenceNumber=sequenceNumber+1 where pageId=$session{page}{pageId}",$session{dbh});
                        WebGUI::SQL->write("update page set sequenceNumber=sequenceNumber-1 where pageId=$data[0]",$session{dbh});
                }
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_movePageUp {
        my (@data, $thisSeq);
        if (WebGUI::Privilege::canEditPage()) {
                ($thisSeq) = WebGUI::SQL->quickArray("select sequenceNumber from page where pageId=$session{page}{pageId}",$session{dbh});
                @data = WebGUI::SQL->quickArray("select pageId from page where parentId=$session{page}{parentId} and sequenceNumber=$thisSeq-1",$session{dbh});
                if ($data[0] ne "") {
                        WebGUI::SQL->write("update page set sequenceNumber=sequenceNumber-1 where pageId=$session{page}{pageId}",$session{dbh});
                        WebGUI::SQL->write("update page set sequenceNumber=sequenceNumber+1 where pageId=$data[0]",$session{dbh});
                }
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_pastePage {
        my ($output, $nextSeq);
		($nextSeq) = WebGUI::SQL->quickArray("select max(sequenceNumber)+1 from page where parentId=$session{page}{pageId}",$session{dbh});
        if (WebGUI::Privilege::canEditPage()) {
                WebGUI::SQL->write("update page set parentId=$session{page}{pageId}, sequenceNumber='$nextSeq' where pageId=$session{form}{pageId}",$session{dbh});
		_reorderPages($session{page}{pageId});
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}


1;
