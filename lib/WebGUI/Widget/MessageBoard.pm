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
use Tie::CPHash;
use WebGUI::DateTime;
use WebGUI::International;
use WebGUI::Macro;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Utility;
use WebGUI::Widget;

#-------------------------------------------------------------------
sub _getBoardProperties {
        my (%board);
	tie %board, 'Tie::CPHash';
	%board = WebGUI::SQL->quickHash("select * from widget, MessageBoard where widget.widgetId=MessageBoard.widgetId and widget.widgetId=$_[0]",$session{dbh});
        return %board;
}

#-------------------------------------------------------------------
sub _traverseReplyTree {
	my ($sth, @data, $html, $depth, $i);
	for ($i=0;$i<=$_[1];$i++) {
		$depth .= "&nbsp;&nbsp;";
	}
	$sth = WebGUI::SQL->read("select messageId,subject,username,dateOfPost from message where pid=$_[0] order by messageId", $session{dbh});
	while (@data = $sth->array) {
		$html .= '<tr';
		if ($session{form}{mid} eq $data[0]) {
			$html .= ' class="highlight"';
		}
		$html .= '><td class="tableData">'.$depth.'<a href="'.$session{page}{url}.'?func=showMessage&mid='.$data[0].'&wid='.$session{form}{wid}.'">'.substr($data[1],0,30).'</a></td><td class="tableData">'.$data[2].'</td><td class="tableData">'.epochToHuman($data[3],"%M/%D %H:%n%p").'</td></tr>';
		$html .= _traverseReplyTree($data[0],$_[1]+1);
	}
	$sth->finish;
	return $html;
}

#-------------------------------------------------------------------
sub purge {
        WebGUI::SQL->write("delete from message where widgetId=$_[0]",$_[1]);
        WebGUI::SQL->write("delete from MessageBoard where widgetId=$_[0]",$_[1]);
        purgeWidget($_[0],$_[1]);
}

#-------------------------------------------------------------------
sub widgetName {
        return WebGUI::International::get(223);
}

#-------------------------------------------------------------------
sub www_add {
        my ($output, %hash, @array);
	tie %hash, "Tie::IxHash";
      	if (WebGUI::Privilege::canEditPage()) {
                $output = '<a href="'.$session{page}{url}.'?op=viewHelp&hid=32"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a>';
		$output .= '<h1>'.WebGUI::International::get(222).'</h1>';
		$output .= '<form method="post" enctype="multipart/form-data" action="'.$session{page}{url}.'">';
                $output .= WebGUI::Form::hidden("widget","MessageBoard");
                $output .= WebGUI::Form::hidden("func","addSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(99).'</td><td>'.WebGUI::Form::text("title",20,30,'Message Board').'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(174).'</td><td>'.WebGUI::Form::checkbox("displayTitle",1,1).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(175).'</td><td>'.WebGUI::Form::checkbox("processMacros",1).'</td></tr>';
		$output .= '<tr><td class="formDescription">'.WebGUI::International::get(85).'</td><td>'.WebGUI::Form::textArea("description",'').'</td></tr>';
                %hash = WebGUI::SQL->buildHash("select groupId,groupName from groups where groupName<>'Reserved' order by groupName",$session{dbh});
		$array[0] = 2;
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(224).'</td><td>'.WebGUI::Form::selectList("groupToPost",\%hash,\@array).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(225).'</td><td>'.WebGUI::Form::text("messagesPerPage",20,2,30).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(226).'</td><td>'.WebGUI::Form::text("editTimeout",20,3,1).'</td></tr>';
                $output .= '<tr><td></td><td>'.WebGUI::Form::submit(WebGUI::International::get(62)).'</td></tr>';
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
		WebGUI::SQL->write("insert into MessageBoard values ($widgetId, $session{form}{groupToPost}, '$session{form}{messagesPerPage}', '$session{form}{editTimeout}')",$session{dbh});
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
		tie %board, 'Tie::CPHash';
		%board = _getBoardProperties($session{form}{wid});
                $output = '<a href="'.$session{page}{url}.'?op=viewHelp&hid=32"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a>';
		$output .= '<h1>'.WebGUI::International::get(227).'</h1>';
		$output .= '<form method="post" enctype="multipart/form-data" action="'.$session{page}{url}.'">';
                $output .= WebGUI::Form::hidden("wid",$session{form}{wid});
                $output .= WebGUI::Form::hidden("func","editSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(99).'</td><td>'.WebGUI::Form::text("title",20,30,$board{title}).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(174).'</td><td>'.WebGUI::Form::checkbox("displayTitle","1",$board{displayTitle}).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(175).'</td><td>'.WebGUI::Form::checkbox("processMacros","1",$board{processMacros}).'</td></tr>';
		$output .= '<tr><td class="formDescription">'.WebGUI::International::get(85).'</td><td>'.WebGUI::Form::textArea("description",$board{description}).'</td></tr>';
                %hash = WebGUI::SQL->buildHash("select groupId,groupName from groups where groupName<>'Reserved' order by groupName",$session{dbh});
		$array[0] = $board{groupToPost};
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(224).'</td><td>'.WebGUI::Form::selectList("groupToPost",\%hash,\@array,1).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(225).'</td><td>'.WebGUI::Form::text("messagesPerPage",20,2,$board{messagesPerPage}).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(226).'</td><td>'.WebGUI::Form::text("editTimeout",20,2,$board{editTimeout}).'</td></tr>';
                $output .= '<tr><td></td><td>'.WebGUI::Form::submit(WebGUI::International::get(62)).'</td></tr>';
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
	tie %message, 'Tie::CPHash';
	tie %board, 'Tie::CPHash';
        %board = _getBoardProperties($session{form}{wid});
        if (WebGUI::Privilege::isInGroup($board{groupToPost},$session{user}{userId})) {
        	%message = WebGUI::SQL->quickHash("select * from message where messageId=$session{form}{mid}",$session{dbh});
                $html .= '<table width="100%"><tr><td class="boardTitle">';
                if ($board{displayTitle}) {
                        $html .= $board{title};
                }
                $html .= '<td align="right" valign="bottom" class="boardMenu">'.WebGUI::International::get(228).'</td></tr></table>';
                $html .= '<form action="'.$session{page}{url}.'" method="post"><table>';
                $html .= WebGUI::Form::hidden("func","editMessageSave");
                $html .= WebGUI::Form::hidden("wid",$session{form}{wid});
                $html .= WebGUI::Form::hidden("mid",$session{form}{mid});
                $html .= '<tr><td class="formDescription">'.WebGUI::International::get(229).'</td><td>'.WebGUI::Form::text("subject",30,255,$message{subject}).'</td></tr>';
                $html .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(230).'</td><td>'.WebGUI::Form::textArea("message",$message{message},50,6,1).'</td></tr>';
                $html .= '<tr><td></td><td>'.WebGUI::Form::submit(WebGUI::International::get(62)).'</td></tr>';
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
	tie %board, 'Tie::CPHash';
        %board = _getBoardProperties($session{form}{wid});
        if (WebGUI::Privilege::isInGroup($board{groupToPost},$session{user}{userId})) {
                if ($session{form}{subject} eq "") {
                        $session{form}{subject} = WebGUI::International::get(232);
                }
                if ($session{form}{message} eq "") {
                        $session{form}{subject} .= ' '.WebGUI::International::get(233);
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
	tie %board, 'Tie::CPHash';
	%board = _getBoardProperties($session{form}{wid});
	if (WebGUI::Privilege::isInGroup($board{groupToPost},$session{user}{userId})) {
	        $html .= '<table width="100%"><tr><td class="boardTitle">';
        	if ($board{displayTitle}) {
                	$html .= $board{title};
        	}
		$html .= '<td align="right" valign="bottom" class="boardMenu">'.WebGUI::International::get(231).'</td></tr></table>';
		$html .= '<form action="'.$session{page}{url}.'" method="post"><table>';
		$html .= WebGUI::Form::hidden("func","postNewMessageSave");
		$html .= WebGUI::Form::hidden("wid",$session{form}{wid});
		$html .= '<tr><td class="formDescription">'.WebGUI::International::get(229).'</td><td>'.WebGUI::Form::text("subject",30,255).'</td></tr>';
		$html .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(230).'</td><td>'.WebGUI::Form::textArea("message",'',50,6,1).'</td></tr>';
                $html .= '<tr><td></td><td>'.WebGUI::Form::submit(WebGUI::International::get(62)).'</td></tr>';
		$html .= '</table></form>';
	} else {
		$html = WebGUI::Privilege::insufficient();
	}	
	return $html;
}

#-------------------------------------------------------------------
sub www_postNewMessageSave {
	my ($mid, %board);
	tie %board, 'Tie::CPHash';
	%board = _getBoardProperties($session{form}{wid});
	if (WebGUI::Privilege::isInGroup($board{groupToPost},$session{user}{userId})) {
                if ($session{form}{subject} eq "") {
                        $session{form}{subject} = WebGUI::International::get(232);
                }
		if ($session{form}{message} eq "") {
        		$session{form}{subject} .= ' '.WebGUI::International::get(233);
                }
		$mid = getNextId("messageId");
		WebGUI::SQL->write("insert into message values ($mid, $mid, $session{form}{wid}, 0, $session{user}{userId}, ".quote($session{user}{username}).", ".quote($session{form}{subject}).", ".quote($session{form}{message}).", ".time().")",$session{dbh});
		return "";
	} else {
		return WebGUI::Privilege::insufficient();
	}	
}

#-------------------------------------------------------------------
sub www_postReply {
	my ($html, %board, $subject);
	tie %board, 'Tie::CPHash';
	%board = _getBoardProperties($session{form}{wid});
	if (WebGUI::Privilege::isInGroup($board{groupToPost},$session{user}{userId})) {
		($subject) = WebGUI::SQL->quickArray("select subject from message where messageId=$session{form}{mid}", $session{dbh});
		$subject = "Re: ".$subject;
                $html .= '<table width="100%"><tr><td class="boardTitle">';
                if ($board{displayTitle}) {
                        $html .= $board{title};
                }
                $html .= '<td align="right" valign="bottom" class="boardMenu">'.WebGUI::International::get(234).'</td></tr></table>';
                $html .= '<form action="'.$session{page}{url}.'" method="post"><table>';
                $html .= WebGUI::Form::hidden("func","postReplySave");
                $html .= WebGUI::Form::hidden("wid",$session{form}{wid});
                $html .= WebGUI::Form::hidden("mid",$session{form}{mid});
		$html .= '<tr><td class="formDescription">'.WebGUI::International::get(229).'</td><td>'.WebGUI::Form::text("subject",30,255,$subject).'</td></tr>';
		$html .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(230).'</td><td>'.WebGUI::Form::textArea("message",'',50,6,1).'</td></tr>';
                $html .= '<tr><td></td><td>'.WebGUI::Form::submit(WebGUI::International::get(62)).'</td></tr>';
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
	tie %board, 'Tie::CPHash';
	%board = _getBoardProperties($session{form}{wid});
	if (WebGUI::Privilege::isInGroup($board{groupToPost},$session{user}{userId})) {
                if ($session{form}{subject} eq "") {
                        $session{form}{subject} = WebGUI::International::get(232);
                }
	 	if ($session{form}{message} eq "") {
                	$session{form}{subject} .= ' '.WebGUI::International::get(233);
                }
		$mid = getNextId("messageId");
		($rid) = WebGUI::SQL->quickArray("select rid from message where messageId=$session{form}{mid}",$session{dbh});
		WebGUI::SQL->write("insert into message values ($mid, $rid, $session{form}{wid}, $session{form}{mid}, $session{user}{userId}, ".quote($session{user}{username}).", ".quote($session{form}{subject}).", ".quote($session{form}{message}).", ".time().")", $session{dbh});
		return www_showMessage();
	} else {
		return WebGUI::Privilege::insufficient();
	}	
}

#-------------------------------------------------------------------
sub www_showMessage {
	my (@data, $html, %board, %message);
	tie %message, 'Tie::CPHash';
	tie %board, 'Tie::CPHash';
	%message = WebGUI::SQL->quickHash("select * from message where messageId=$session{form}{mid}",$session{dbh});
	%board = _getBoardProperties($session{form}{wid});
	$html .= '<table width="100%"><tr><td class="boardTitle">';
        if ($board{displayTitle}) {
                $html .= $board{title};
        }
	$html .= '</td><td align="right" valign="bottom" class="boardMenu">';
	if ((time()-$message{dateOfPost}) < 3600*$board{editTimeout} && $message{'userId'} eq $session{user}{userId}) {
		$html .= '<a href="'.$session{page}{url}.'?func=editMessage&mid='.$session{form}{mid}.'&wid='.$session{form}{wid}.'">'.WebGUI::International::get(235).'</a> &middot; ';
	}
	$html .= '<a href="'.$session{page}{url}.'?func=postReply&mid='.$session{form}{mid}.'&wid='.$session{form}{wid}.'">'.WebGUI::International::get(236).'</a></td></tr></table>';
	$html .= '<table width="100%"><tr><td class="tableHeader">';
	$html .= "<b>".WebGUI::International::get(237)."</b> ".$message{subject}."<br>";
	$html .= "<b>".WebGUI::International::get(238)."</b> ".$message{username}."<br>";
	$html .= "<b>".WebGUI::International::get(239)."</b> ".epochToHuman($message{dateOfPost},"%w, %c %D, %y at %H:%n%p")."<br>";
	$html .= "<b>".WebGUI::International::get(240)."</b> ".$message{widgetId}."-".$message{rid}."-".$message{pid}."-".$message{messageId}."<br>";
	$html .= '</td>';
	$html .= '</tr><tr><td colspan=2 class="boardMessage">';
	$message{message} =~ s/\n/\<br\>/g;
	$html .= $message{message};
	$html .= '</td></tr></table><p><div align="center" class="boardMenu">';
	@data = WebGUI::SQL->quickArray("select max(messageId) from message where widgetId=$message{widgetId} and pid=0 and messageId<$message{rid}",$session{dbh});
	if ($data[0] ne "") {
		$html .= '<a href="'.$session{page}{url}.'?func=showMessage&mid='.$data[0].'&wid='.$session{form}{wid}.'">&laquo; '.WebGUI::International::get(241).'</a>';
	} else {
		$html .= '&laquo; '.WebGUI::International::get(241).'</a>';
	}
	$html .= ' &middot; <a href="'.$session{page}{url}.'">'.WebGUI::International::get(242).'</a> &middot; ';
	@data = WebGUI::SQL->quickArray("select min(messageId) from message where widgetId=$message{widgetId} and pid=0 and messageId>$message{rid}",$session{dbh});
	if ($data[0] ne "") {
		$html .= '<a href="'.$session{page}{url}.'?func=showMessage&mid='.$data[0].'&wid='.$session{form}{wid}.'">'.WebGUI::International::get(243).' &raquo;</a>';
	} else {
		$html .= WebGUI::International::get(243).' &raquo;';
	}	
	$html .= '</div><table border=0 cellpadding=2 cellspacing=1 width="100%">';
	$html .= '<tr><td class="tableHeader">'.WebGUI::International::get(229).'</td><td class="tableHeader">'.WebGUI::International::get(244).'</td><td class="tableHeader">'.WebGUI::International::get(245).'</td></tr>';
	@data = WebGUI::SQL->quickArray("select messageId,subject,username,dateOfPost from message where messageId=$message{rid}",$session{dbh});
	$html .= '<tr';
	if ($session{form}{mid} eq $message{rid}) {
		$html .= ' class="highlight"';
	}
	$html .= '><td class="tableData"><a href="'.$session{page}{url}.'?func=showMessage&mid='.$data[0].'&wid='.$message{widgetId}.'">'.substr($data[1],0,30).'</a></td><td class="tableData">'.$data[2].'</td><td class="tableData">'.epochToHuman($data[3],"%M/%D %H:%n%p").'</td></tr>';
	$html .= _traverseReplyTree($message{rid},1);
	$html .= "</table>";
	return $html;
}

#-------------------------------------------------------------------
sub www_view {
	my ($sth, @data, $html, %board, $itemsPerPage, $i, $pn, $lastId, @last, $replies);
	tie %board, 'Tie::CPHash';
	%board = _getBoardProperties($_[0]);
        $itemsPerPage = $board{messagesPerPage};
        if ($session{form}{pn} < 1) {
                $pn = 0;
        } else {
                $pn = $session{form}{pn};
        }
	if ($board{description} ne "") {
		$html = $board{description}.'<p>';
	}
	if ($board{processMacros}) {
		$html = WebGUI::Macro::process($html);
	}
	$html .= '<table width="100%"><tr><td class="boardTitle">';
	if ($board{displayTitle}) {
		$html .= $board{title};
	}
	$html .= '</td><td align="right" valign="bottom" class="boardMenu"><a href="'.$session{page}{url}.'?func=postNewMessage&wid='.$_[0].'">'.WebGUI::International::get(246).'</a></td></tr></table>';
	$html .= '<table border=0 cellpadding=2 cellspacing=1 width="100%">';
	$html .= '<tr><td class="tableHeader">'.WebGUI::International::get(229).'</td><td class="tableHeader">'.WebGUI::International::get(244).'</td><td class="tableHeader">'.WebGUI::International::get(247).'</td><td class="tableHeader">'.WebGUI::International::get(248).'</td><td class="tableHeader">'.WebGUI::International::get(249).'</td></tr>';
	#$sth = WebGUI::SQL->read("select messageId,subject,count(*)-1,username,dateOfPost,max(dateOfPost),max(messageId) from message where widgetId=$_[0] group by rid order by messageId desc", $session{dbh});
	$sth = WebGUI::SQL->read("select messageId,subject,username,dateOfPost from message where widgetId=$_[0] and pid=0 order by messageId desc", $session{dbh});
	while (@data = $sth->array) {
		if ($i >= ($itemsPerPage*$pn) && $i < ($itemsPerPage*($pn+1))) {
			@last = WebGUI::SQL->quickArray("select messageId,dateOfPost,username,subject from message where widgetId=$_[0] and rid=$data[0] order by dateOfPost desc",$session{dbh});
			($replies) = WebGUI::SQL->quickArray("select count(*)-1 from message where rid=$data[0]",$session{dbh});
			$html .= '<tr><td class="tableData"><a href="'.$session{page}{url}.'?func=showMessage&mid='.$data[0].'&wid='.$_[0].'">'.substr($data[1],0,30).'</a></td><td class="tableData">'.$data[2].'</td><td class="tableData">'.epochToHuman($data[3],"%M/%D %H:%n%p").'</td><td class="tableData">'.$replies.'</td><td class="tableData"><a href="'.$session{page}{url}.'?func=showMessage&mid='.$last[0].'&wid='.$_[0].'">'.substr($last[3],0,30).'</a><span style="font-size: 8pt;"> @ '.epochToHuman($last[1],"%M/%D %H:%n%p").' by '.$last[2].'</span></td></tr>';
		}
       		$i++;
        }
        $html .= '</table>';
        $html .= '<div class="pagination">';
        if ($pn > 0) {
                $html .= '<a href="'.$session{page}{url}.'?pn='.($pn-1).'">&laquo;'.WebGUI::International::get(91).'</a>';
        } else {
                $html .= '&laquo;'.WebGUI::International::get(91);
        }
        $html .= ' &middot; ';
        if (($pn+1) < round(($i/$itemsPerPage))) {
        	$html .= '<a href="'.$session{page}{url}.'?pn='.($pn+1).'">'.WebGUI::International::get(92).'&raquo;</a>';
        } else {
        	$html .= WebGUI::International::get(92).'&raquo;';
        }
        $html .= '</div>';
	return $html;
}

1;
