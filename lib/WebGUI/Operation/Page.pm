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
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Utility;

our @ISA = qw(Exporter);
our @EXPORT = qw(&www_addPage &www_addPageSave &www_cutPage &www_deletePage &www_deletePageConfirm &www_editPage &www_editPageSave &www_pastePage);

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
sub www_addPage {
	my ($output);
	if (WebGUI::Privilege::canEditPage()) {
		$output = '<a href="'.$session{page}{url}.'?op=viewHelp&hid=1"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a><h1>Add Page</h1><form method="post" action="'.$session{page}{url}.'">';
		$output .= WebGUI::Form::hidden("op","addPageSave");
		$output .= '<table>';
		$output .= '<tr><td class="formDescription">Title</td><td>'.WebGUI::Form::text("title",20,30,$session{form}{title}).'</td></tr>';
		$output .= '<tr><td class="formDescription">Meta Tags</td><td>'.WebGUI::Form::textArea("metaTags",$session{form}{metaTags}).'</td></tr>';
		$output .= '<tr><td></td><td>'.WebGUI::Form::submit("create").'</td></tr>';
		$output .= '</table></form>';	
		return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_addPageSave {
	my (%parent, $urlizedTitle, $test);
	if (WebGUI::Privilege::canEditPage()) {
		%parent = WebGUI::SQL->quickHash("select * from page where pageId=$session{page}{pageId}",$session{dbh});	
		$urlizedTitle = urlizeTitle($session{form}{title});
		while (($test) = WebGUI::SQL->quickArray("select urlizedTitle from page where urlizedTitle='$urlizedTitle'",$session{dbh})) {
			$urlizedTitle .= 2;
		}
		WebGUI::SQL->write("insert into page set pageId=".getNextId("pageId").", parentId=$session{page}{pageId}, title=".quote($session{form}{title}).", styleId=$parent{styleId}, ownerId=$session{user}{userId}, ownerView=$parent{ownerView}, ownerEdit=$parent{ownerEdit}, groupId='$parent{groupId}', groupView=$parent{groupView}, groupEdit=$parent{groupEdit}, worldView=$parent{worldView}, worldEdit=$parent{worldEdit}, metaTags=".quote($session{form}{metaTags}).", urlizedTitle='$urlizedTitle'",$session{dbh});
		return "";
	} else {
		return WebGUI::Privilege::insufficient();
	}
}

#-------------------------------------------------------------------
sub www_cutPage {
        if (WebGUI::Privilege::canEditPage() && $session{page}{pageId}!=1) {
                WebGUI::SQL->write("update page set parentId=2 where pageId=".$session{page}{pageId},$session{dbh});
                WebGUI::Session::refreshPageInfo($session{page}{parentId});
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deletePage {
	my ($output);
	if (WebGUI::Privilege::canEditPage() && $session{page}{pageId}!=1) {
		$output .= '<a href="'.$session{page}{url}.'?op=viewHelp&hid=3"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a><h1>Please Confirm</h1>';
		$output .= 'Are you certain that you wish to delete this page, its content, and all items under it?<p>';
		$output .= '<div align="center"><a href="'.$session{page}{url}.'?op=deletePageConfirm">Yes, I\'m sure.</a>';
		$output .= '&nbsp;&nbsp;&nbsp;&nbsp;<a href="'.$session{page}{url}.'">No, I made a mistake.</a></div>';
		return $output;
	} else {
		return WebGUI::Privilege::insufficient();
	}
}

#-------------------------------------------------------------------
sub www_deletePageConfirm {
        if (WebGUI::Privilege::canEditPage() && $session{page}{pageId}!=1) {
		WebGUI::SQL->write("update page set parentId=3 where pageId=".$session{page}{pageId},$session{dbh});
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
                $output = '<a href="'.$session{page}{url}.'?op=viewHelp&hid=2"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a><h1>Edit Page</h1><form method="post" action="'.$session{page}{url}.'">';
                $output .= WebGUI::Form::hidden("op","editPageSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">Title</td><td>'.WebGUI::Form::text("title",20,30,$session{page}{title}).'</td></tr>';
                $output .= '<tr><td class="formDescription">Meta Tags</td><td>'.WebGUI::Form::textArea("metaTags",$session{page}{metaTags}).'</td></tr>';
		%hash = WebGUI::SQL->buildHash("select styleId,name from style where name<>'Reserved' order by name",$session{dbh});
		$array[0] = $session{page}{styleId};
                $output .= '<tr><td class="formDescription">Style</td><td>'.WebGUI::Form::selectList("styleId",\%hash,\@array).' '.WebGUI::Form::checkbox("recurseStyle","yes").' <span class="formSubtext">Check to give this style to all sub-pages.</span></td></tr>';
                $output .= '<tr><td class="formDescription">Page URL</td><td>'.WebGUI::Form::text("urlizedTitle",20,30,$session{page}{urlizedTitle}).'</td></tr>';
		%hash = WebGUI::SQL->buildHash("select user.userId,user.username from user,groupings where groupings.groupId=4 and groupings.userId=user.userId order by user.username",$session{dbh});
		$array[0] = $session{page}{ownerId};
                $output .= '<tr><td class="formDescription">Owner</td><td>'.WebGUI::Form::selectList("ownerId",\%hash,\@array).' '.WebGUI::Form::checkbox("recursePrivs","yes").' <span class="formSubtext">Check to give these privileges to all sub-pages.</span></td></tr>';
		$array[0] = $session{page}{ownerView};
                $output .= '<tr><td class="formDescription">Owner can view?</td><td>'.WebGUI::Form::selectList("ownerView",\%yesNo,\@array).'</td></tr>';
		$array[0] = $session{page}{ownerEdit};
                $output .= '<tr><td class="formDescription">Owner can edit?</td><td>'.WebGUI::Form::selectList("ownerEdit",\%yesNo,\@array).'</td></tr>';
		%hash = WebGUI::SQL->buildHash("select groupId,groupName from groups where groupName<>'Reserved' order by groupName",$session{dbh});
		$array[0] = $session{page}{groupId};
                $output .= '<tr><td class="formDescription">Group</td><td>'.WebGUI::Form::selectList("groupId",\%hash,\@array).'</td></tr>';
		$array[0] = $session{page}{groupView};
                $output .= '<tr><td class="formDescription">Group can view?</td><td>'.WebGUI::Form::selectList("groupView",\%yesNo,\@array).'</td></tr>';
		$array[0] = $session{page}{groupEdit};
                $output .= '<tr><td class="formDescription">Group can edit?</td><td>'.WebGUI::Form::selectList("groupEdit",\%yesNo,\@array).'</td></tr>';
		$array[0] = $session{page}{worldView};
                $output .= '<tr><td class="formDescription">Anybody can view?</td><td>'.WebGUI::Form::selectList("worldView",\%yesNo,\@array).'</td></tr>';
		$array[0] = $session{page}{worldEdit};
                $output .= '<tr><td class="formDescription">Anybody can Edit?</td><td>'.WebGUI::Form::selectList("worldEdit",\%yesNo,\@array).'</td></tr>';
                $output .= '<tr><td></td><td>'.WebGUI::Form::submit("save").'</td></tr>';
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
sub www_pastePage {
        my ($output);
        if (WebGUI::Privilege::canEditPage()) {
                WebGUI::SQL->write("update page set parentId=$session{page}{pageId} where pageId=$session{form}{pageId}",$session{dbh});
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}


1;
