package WebGUI::Widget::MessageBoard;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001 Plain Black Software.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Utility;
use WebGUI::Widget;

#-------------------------------------------------------------------
sub _getBoardProperties {
        my (%board);
	%board = WebGUI::SQL->quickHash("select widget.title, widget.displayTitle, widget.description, MessageBoard.groupToPost, MessageBoard.messagesPerPage, MessageBoard.editTimeout from widget left join MessageBoard on (widget.widgetId=MessageBoard.widgetId) where widget.widgetId=$_[0]",$session{dbh});
        return %board;
}

#-------------------------------------------------------------------
sub _traverseReplyTree {
	my ($sth, @data, $html, $depth, $i);
	for ($i=0;$i<=$_[1];$i++) {
		$depth .= "&nbsp;&nbsp;";
	}
	$sth = WebGUI::SQL->read("select messageId,substring(subject,1,30),username,date_format(dateOfPost,'%c/%e %l:%i%p') from message where pid=$_[0] order by messageId", $session{dbh});
	while (@data = $sth->array) {
		$html .= '<tr';
		if ($session{form}{mid} eq $data[0]) {
			$html .= ' class="highlight"';
		}
		$html .= '><td class="tableData">'.$depth.'<a href="'.$session{page}{url}.'?func=showMessage&mid='.$data[0].'&wid='.$session{form}{wid}.'">'.$data[1].'</a></td><td class="tableData">'.$data[2].'</td><td class="tableData">'.$data[3].'</td></tr>';
		$html .= _traverseReplyTree($data[0],$_[1]+1);
	}
	$sth->finish;
	return $html;
}

#-------------------------------------------------------------------
sub widgetName {
        return "Message Board";
}

#-------------------------------------------------------------------
sub www_add {
        my ($output, %hash);
	tie %hash, "Tie::IxHash";
      	if (WebGUI::Privilege::canEditPage()) {
                $output = '<a href="'.$session{page}{url}.'?op=viewHelp&hid=32"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a><h1>Add Message Board</h1><form method="post" enctype="multipart/form-data" action="'.$session{page}{url}.'">';
                $output .= WebGUI::Form::hidden("widget","MessageBoard");
                $output .= WebGUI::Form::hidden("func","addSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">Title</td><td>'.WebGUI::Form::text("title",20,30,'Message Board').'</td></tr>';
                $output .= '<tr><td class="formDescription">Display the title?</td><td>'.WebGUI::Form::checkbox("displayTitle",1,1).'</td></tr>';
		$output .= '<tr><td class="formDescription">Description</td><td>'.WebGUI::Form::textArea("description",'').'</td></tr>';
                %hash = WebGUI::SQL->buildHash("select groupId,groupName from groups where groupName<>'Reserved' order by groupName",$session{dbh});
                $output .= '<tr><td class="formDescription" valign="top">Who can post?</td><td>'.WebGUI::Form::selectList("groupToPost",\%hash,'',1).'</td></tr>';
                $output .= '<tr><td class="formDescription">Messages Per Page</td><td>'.WebGUI::Form::text("messagesPerPage",20,2,50).'</td></tr>';
                $output .= '<tr><td class="formDescription">Edit Timeout</td><td>'.WebGUI::Form::text("editTimeout",20,3,1).'</td></tr>';
                $output .= '<tr><td></td><td>'.WebGUI::Form::submit("save").'</td></tr>';
                $output .= '</table></form>';
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
	return $output;
}

#-------------------------------------------------------------------
sub www_addSave {
	my ($widgetId);
	if (WebGUI::Privilege::canEditPage()) {
		$widgetId = create();
		WebGUI::SQL->write("insert into MessageBoard set widgetId=$widgetId, groupToPost=$session{form}{groupToPost}, messagesPerPage=$session{form}{messagesPerPage}, editTimeout=$session{form}{editTimeout}",$session{dbh});
		return "";
	} else {
		return WebGUI::Privilege::insufficient();
	}
}

#-------------------------------------------------------------------
sub www_edit {
        my ($output, %board, %hash, @array);
	tie %hash, "Tie::IxHash";
        if (WebGUI::Privilege::canEditPage()) {
		%board = _getBoardProperties($session{form}{wid});
                $output = '<a href="'.$session{page}{url}.'?op=viewHelp&hid=33"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a><h1>Edit Message Board</h1><form method="post" enctype="multipart/form-data" action="'.$session{page}{url}.'">';
                $output .= WebGUI::Form::hidden("wid",$session{form}{wid});
                $output .= WebGUI::Form::hidden("func","editSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">Title</td><td>'.WebGUI::Form::text("title",20,30,$board{title}).'</td></tr>';
                $output .= '<tr><td class="formDescription">Display the title?</td><td>'.WebGUI::Form::checkbox("displayTitle","1",$board{displayTitle}).'</td></tr>';
		$output .= '<tr><td class="formDescription">Description</td><td>'.WebGUI::Form::textArea("description",$board{description}).'</td></tr>';
                %hash = WebGUI::SQL->buildHash("select groupId,groupName from groups where groupName<>'Reserved' order by groupName",$session{dbh});
		$array[0] = $board{groupToPost};
                $output .= '<tr><td class="formDescription" valign="top">Who can post?</td><td>'.WebGUI::Form::selectList("groupToPost",\%hash,\@array,1).'</td></tr>';
                $output .= '<tr><td class="formDescription">Messages Per Page</td><td>'.WebGUI::Form::text("messagesPerPage",20,2,$board{messagesPerPage}).'</td></tr>';
                $output .= '<tr><td class="formDescription">Edit Timeout</td><td>'.WebGUI::Form::text("editTimeout",20,2,$board{editTimeout}).'</td></tr>';
                $output .= '<tr><td></td><td>'.WebGUI::Form::submit("save").'</td></tr>';
                $output .= '</table></form>';
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_editSave {
        if (WebGUI::Privilege::canEditPage()) {	
		update();
                WebGUI::SQL->write("update MessageBoard set groupToPost=$session{form}{groupToPost}, messagesPerPage=$session{form}{messagesPerPage}, editTimeout=$session{form}{editTimeout} where widgetId=$session{form}{wid}",$session{dbh});
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_editMessage {
        my ($html, %board, %message);
        %board = _getBoardProperties($session{form}{wid});
        if (WebGUI::Privilege::isInGroup($board{groupToPost},$session{user}{userId})) {
        	%message = WebGUI::SQL->quickHash("select * from message where messageId=$session{form}{mid}",$session{dbh});
                $html .= '<table width="100%"><tr><td class="boardTitle">';
                if ($board{displayTitle}) {
                        $html .= $board{title};
                }
                $html .= '<td align="right" valign="bottom" class="boardMenu">Editing Message...</td></tr></table>';
                $html .= '<form action="'.$session{page}{url}.'" method="post"><table>';
                $html .= WebGUI::Form::hidden("func","editMessageSave");
                $html .= WebGUI::Form::hidden("wid",$session{form}{wid});
                $html .= WebGUI::Form::hidden("mid",$session{form}{mid});
                $html .= '<tr><td class="formDescription">Subject</td><td>'.WebGUI::Form::text("subject",30,255,$message{subject}).'</td></tr>';
                $html .= '<tr><td class="formDescription" valign="top">Message</td><td>'.WebGUI::Form::textArea("message",$message{message},50,6,1).'</td></tr>';
                $html .= '<tr><td></td><td>'.WebGUI::Form::submit("Save This Edit").'</td></tr>';
                $html .= '</table></form>';
		$html .= www_showMessage();
        } else {
                $html = WebGUI::Privilege::insufficient();
        }
        return $html;
}

#-------------------------------------------------------------------
sub www_editMessageSave {
        my (%board);
        %board = _getBoardProperties($session{form}{wid});
        if (WebGUI::Privilege::isInGroup($board{groupToPost},$session{user}{userId})) {
                if ($session{form}{subject} eq "") {
                        $session{form}{subject} = 'no subject';
                }
                if ($session{form}{message} eq "") {
                        $session{form}{subject} .= ' (eom)';
                }
                WebGUI::SQL->write("update message set subject=".quote($session{form}{subject}).", message=".quote("\n --- (Edited at ".localtime(time).") --- \n\n".$session{form}{message})." where messageId=$session{form}{mid}",$session{dbh});
                return www_showMessage();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_postNewMessage {
	my ($html, %board);
	%board = _getBoardProperties($session{form}{wid});
	if (WebGUI::Privilege::isInGroup($board{groupToPost},$session{user}{userId})) {
	        $html .= '<table width="100%"><tr><td class="boardTitle">';
        	if ($board{displayTitle}) {
                	$html .= $board{title};
        	}
		$html .= '<td align="right" valign="bottom" class="boardMenu">Posting New Message...</td></tr></table>';
		$html .= '<form action="'.$session{page}{url}.'" method="post"><table>';
		$html .= WebGUI::Form::hidden("func","postNewMessageSave");
		$html .= WebGUI::Form::hidden("wid",$session{form}{wid});
		$html .= '<tr><td class="formDescription">Subject</td><td>'.WebGUI::Form::text("subject",30,255).'</td></tr>';
		$html .= '<tr><td class="formDescription" valign="top">Message</td><td>'.WebGUI::Form::textArea("message",'',50,6,1).'</td></tr>';
                $html .= '<tr><td></td><td>'.WebGUI::Form::submit("Post This Message").'</td></tr>';
		$html .= '</table></form>';
	} else {
		$html = WebGUI::Privilege::insufficient();
	}	
	return $html;
}

#-------------------------------------------------------------------
sub www_postNewMessageSave {
	my ($mid, %board);
	%board = _getBoardProperties($session{form}{wid});
	if (WebGUI::Privilege::isInGroup($board{groupToPost},$session{user}{userId})) {
                if ($session{form}{subject} eq "") {
                        $session{form}{subject} = 'no subject';
                }
		if ($session{form}{message} eq "") {
        		$session{form}{subject} .= ' (eom)';
                }
		$mid = getNextId("messageId");
		WebGUI::SQL->write("insert into message set messageId=$mid, userId=$session{user}{userId}, username=".quote($session{user}{username}).", subject=".quote($session{form}{subject}).", message=".quote($session{form}{message}).", widgetId=$session{form}{wid}, pid=0, dateOfPost=now()",$session{dbh});
		WebGUI::SQL->write("update message set rid=$mid where messageId=$mid",$session{dbh});
		return "";
	} else {
		return WebGUI::Privilege::insufficient();
	}	
}

#-------------------------------------------------------------------
sub www_postReply {
	my ($html, %board, $subject);
	%board = _getBoardProperties($session{form}{wid});
	if (WebGUI::Privilege::isInGroup($board{groupToPost},$session{user}{userId})) {
		($subject) = WebGUI::SQL->quickArray("select subject from message where messageId=$session{form}{mid}", $session{dbh});
		$subject = "Re: ".$subject;
                $html .= '<table width="100%"><tr><td class="boardTitle">';
                if ($board{displayTitle}) {
                        $html .= $board{title};
                }
                $html .= '<td align="right" valign="bottom" class="boardMenu">Posting Reply...</td></tr></table>';
                $html .= '<form action="'.$session{page}{url}.'" method="post"><table>';
                $html .= WebGUI::Form::hidden("func","postReplySave");
                $html .= WebGUI::Form::hidden("wid",$session{form}{wid});
                $html .= WebGUI::Form::hidden("mid",$session{form}{mid});
		$html .= '<tr><td class="formDescription">Subject</td><td>'.WebGUI::Form::text("subject",30,255,$subject).'</td></tr>';
		$html .= '<tr><td class="formDescription" valign="top">Message</td><td>'.WebGUI::Form::textArea("message",'',50,6,1).'</td></tr>';
                $html .= '<tr><td></td><td>'.WebGUI::Form::submit("Post This Reply").'</td></tr>';
		$html .= '</table></form>';
		$html .= www_showMessage();
	} else {
		$html = WebGUI::Privilege::insufficient();
	}	
	return $html;
}

#-------------------------------------------------------------------
sub www_postReplySave {
	my ($rid, %board, $mid);
	%board = _getBoardProperties($session{form}{wid});
	if (WebGUI::Privilege::isInGroup($board{groupToPost},$session{user}{userId})) {
                if ($session{form}{subject} eq "") {
                        $session{form}{subject} = 'no subject';
                }
	 	if ($session{form}{message} eq "") {
                	$session{form}{subject} .= ' (eom)';
                }
		$mid = getNextId("messageId");
		($rid) = WebGUI::SQL->quickArray("select rid from message where messageId=$session{form}{mid}",$session{dbh});
		WebGUI::SQL->write("insert into message set messageId=$mid, userId=$session{user}{userId}, username=".quote($session{user}{username}).", subject=".quote($session{form}{subject}).", message=".quote($session{form}{message}).", rid=$rid, widgetId=$session{form}{wid}, pid=$session{form}{mid}, dateOfPost=now()", $session{dbh});
		return www_showMessage();
	} else {
		return WebGUI::Privilege::insufficient();
	}	
}

#-------------------------------------------------------------------
sub www_showMessage {
	my (@data, $html, %board, %message);
	%message = WebGUI::SQL->quickHash("select * from message where messageId=$session{form}{mid}",$session{dbh});
	%board = _getBoardProperties($session{form}{wid});
	$html .= '<table width="100%"><tr><td class="boardTitle">';
        if ($board{displayTitle}) {
                $html .= $board{title};
        }
	$html .= '</td><td align="right" valign="bottom" class="boardMenu">';
	@data = WebGUI::SQL->quickArray("select unix_timestamp()-unix_timestamp(dateOfPost) from message where messageId=$session{form}{mid}",$session{dbh});
	if ($data[0] < 3600*$board{editTimeout} && $message{'userId'} eq $session{user}{userId}) {
		$html .= '<a href="'.$session{page}{url}.'?func=editMessage&mid='.$session{form}{mid}.'&wid='.$session{form}{wid}.'">Edit Message</a> &middot; ';
	}
	$html .= '<a href="'.$session{page}{url}.'?func=postReply&mid='.$session{form}{mid}.'&wid='.$session{form}{wid}.'">Post Reply</a></td></tr></table>';
	$html .= '<table width="100%"><tr><td class="tableHeader">';
	$html .= "<b>Subject:</b> ".$message{subject}."<br>";
	$html .= "<b>Author:</b> ".$message{username}."<br>";
	$html .= "<b>Date:</b> ".$message{dateOfPost}."<br>";
	$html .= "<b>Message ID:</b> ".$message{widgetId}."-".$message{rid}."-".$message{pid}."-".$message{messageId}."<br>";
	$html .= '</td>';
	$html .= '</tr><tr><td colspan=2 class="boardMessage">';
	$message{message} =~ s/\n/\<br\>/g;
	$html .= $message{message};
	$html .= '</td></tr></table><p><div align="center" class="boardMenu">';
	@data = WebGUI::SQL->quickArray("select max(messageId) from message where widgetId=$message{widgetId} and pid=0 and messageId<$message{rid}",$session{dbh});
	if ($data[0] ne "") {
		$html .= '<a href="'.$session{page}{url}.'?func=showMessage&mid='.$data[0].'&wid='.$session{form}{wid}.'">&laquo; Previous Thread</a>';
	} else {
		$html .= '&laquo; Previous Thread</a>';
	}
	$html .= ' &middot; <a href="'.$session{page}{url}.'">Back To Message List</a> &middot; ';
	@data = WebGUI::SQL->quickArray("select min(messageId) from message where widgetId=$message{widgetId} and pid=0 and messageId>$message{rid}",$session{dbh});
	if ($data[0] ne "") {
		$html .= '<a href="'.$session{page}{url}.'?func=showMessage&mid='.$data[0].'&wid='.$session{form}{wid}.'">Next Thread &raquo;</a>';
	} else {
		$html .= 'Next Thread &raquo;';
	}	
	$html .= '</div><table border=0 cellpadding=2 cellspacing=1 width="100%">';
	$html .= '<tr><td class="tableHeader">Subject</td><td class="tableHeader">Author</td><td class="tableHeader">Date</td></tr>';
	@data = WebGUI::SQL->quickArray("select messageId,substring(subject,1,30),username,date_format(dateOfPost,'%c/%e %l:%i%p') from message where messageId=$message{rid}",$session{dbh});
	$html .= '<tr';
	if ($session{form}{mid} eq $message{rid}) {
		$html .= ' class="highlight"';
	}
	$html .= '><td class="tableData"><a href="'.$session{page}{url}.'?func=showMessage&mid='.$data[0].'&wid='.$message{widgetId}.'">'.$data[1].'</a></td><td class="tableData">'.$data[2].'</td><td class="tableData">'.$data[3].'</td></tr>';
	$html .= _traverseReplyTree($message{rid},1);
	$html .= "</table>";
	return $html;
}

#-------------------------------------------------------------------
sub www_view {
	my ($sth, @data, $html, %board, $itemsPerPage, $currentPage, $totalItems);
	%board = _getBoardProperties($_[0]);
        $itemsPerPage = $board{messagesPerPage};
        if ($session{form}{pageNumber} < 1) {
                $currentPage = 1;
        } else {
                $currentPage = $session{form}{pageNumber};
        }
	if ($board{description} ne "") {
		$html .= $board{description}.'<p>';
	}
        ($totalItems) = WebGUI::SQL->quickArray("select count(*) from message where widgetId=$_[0]",$session{dbh});
	$html .= '<table width="100%"><tr><td class="boardTitle">';
	if ($board{displayTitle}) {
		$html .= $board{title};
	}
	$html .= '</td><td align="right" valign="bottom" class="boardMenu"><a href="'.$session{page}{url}.'?func=postNewMessage&wid='.$_[0].'">Post New Message</a></td></tr></table>';
	$html .= '<table border=0 cellpadding=2 cellspacing=1 width="100%">';
	$html .= '<tr><td class="tableHeader">Subject</td><td class="tableHeader">Author</td><td class="tableHeader">Thread Started</td><td class="tableHeader">Replies</td><td class="tableHeader">Last Reply</td></tr>';
	$sth = WebGUI::SQL->read("select messageId,substring(subject,1,30),count(messageId)-1,username,date_format(dateOfPost,'%c/%e %l:%i%p'),date_format(max(dateOfPost),'%c/%e %l:%i%p'),max(messageId) from message where widgetId=$_[0] group by rid order by messageId desc limit ".(($currentPage*$itemsPerPage)-$itemsPerPage).",".$itemsPerPage, $session{dbh});
	while (@data = $sth->array) {
		$html .= '<tr><td class="tableData"><a href="'.$session{page}{url}.'?func=showMessage&mid='.$data[0].'&wid='.$_[0].'">'.$data[1].'</a></td><td class="tableData">'.$data[3].'</td><td class="tableData">'.$data[4].'</td><td class="tableData">'.$data[2].'</td><td class="tableData"><a href="'.$session{page}{url}.'?func=showMessage&mid='.$data[6].'&wid='.$_[0].'">'.$data[5].'</a></td></tr>';
	}
	$html .= "</table>";
	$sth->finish;
    	$html .= '<div class="pagination">';
	if ($currentPage > 1) {
    		$html .= '<a href="'.$session{page}{url}.'?pageNumber='.($currentPage-1).'">&laquo;Previous Page</a>';
    	} else {
    		$html .= '&laquo;Previous Page';
    	}
    	$html .= ' &middot; ';
    	if ($currentPage < round($totalItems/$itemsPerPage)) {
    		$html .= '<a href="'.$session{page}{url}.'?pageNumber='.($currentPage+1).'">Next Page&raquo;</a>';
    	} else {
		$html .= 'Next Page&raquo;';
    	}
	$html .= '</div>';
	return $html;
}







1;
