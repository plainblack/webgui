package WebGUI::Discussion;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black Software.
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
use WebGUI::HTML;
use WebGUI::International;
use WebGUI::Session;
use WebGUI::Shortcut;
use WebGUI::SQL;
use WebGUI::URL;

#-------------------------------------------------------------------
sub _deleteReplyTree {
        my ($sth, %data, $messageId);
        $sth = WebGUI::SQL->read("select messageId from discussion where pid=$_[0] order by messageId");
        while (%data = $sth->hash) {
                _deleteReplyTree($data{messageId});
                WebGUI::SQL->write("delete from discussion where messageId=$data{messageId}");
        }
        $sth->finish;
}

#-------------------------------------------------------------------
sub _duplicateReplyTree {
        my ($sth, %data, $newMessageId);
        $sth = WebGUI::SQL->read("select * from discussion where pid=$_[0] order by messageId");
        while (%data = $sth->hash) {
                $newMessageId = getNextId("messageId");
		WebGUI::SQL->write("insert into discussion values ($newMessageId, $_[2], $_[3], $_[1], $data{userId}, "
			.quote($data{username}).", ".quote($data{subject}).", ".quote($data{message}).
			", $data{dateOfPost}, $_[4])");
                _duplicateReplyTree($data{messageId},$newMessageId,$_[2],$_[3],$_[4]);
        }
        $sth->finish;
}

#-------------------------------------------------------------------
sub duplicate {
        my ($sth, %data, $newMessageId, $oldSubId, $newSubId);
	$oldSubId = $_[2] || 0;
	$newSubId = $_[3] || 0;
        $sth = WebGUI::SQL->read("select * from discussion where widgetId=$_[0] and pid=0 and subId=$oldSubId order by messageId");
        while (%data = $sth->hash) {
                $newMessageId = getNextId("messageId");
		WebGUI::SQL->write("insert into discussion values ($newMessageId, $newMessageId, $_[1], 0, $data{userId}, ".quote($data{username}).", ".quote($data{subject}).", ".quote($data{message}).", $data{dateOfPost}, $newSubId)");
		_duplicateReplyTree($data{messageId},$newMessageId,$newMessageId,$_[1],$newSubId);
        }
        $sth->finish;
}

#-------------------------------------------------------------------
sub deleteMessage {
        my ($output);
        $output = '<h1>'.WebGUI::International::get(42).'</h1>';
        $output .= WebGUI::International::get(401);
        $output .= '<p>';
        $output .= '<div align="center"><a href="'.WebGUI::URL::page('func=deleteMessageConfirm&wid='.
        $session{form}{wid}.'&mid='.$session{form}{mid}).'">';
        $output .= WebGUI::International::get(44);
        $output .= '</a>';
        $output .= '&nbsp;&nbsp;&nbsp;&nbsp;<a href="'.WebGUI::URL::page('func=showMessage&wid='.
	$session{form}{wid}.'&mid='.$session{form}{mid}).'">';
        $output .= WebGUI::International::get(45);
        $output .= '</a></div>';
        return $output;
}

#-------------------------------------------------------------------
sub deleteMessageConfirm {
	_deleteReplyTree($session{form}{mid});
	WebGUI::SQL->write("delete from discussion where messageId=$session{form}{mid}");
        return "";
}

#-------------------------------------------------------------------
sub editMessage {
        my ($html, %message);
	tie %message, 'Tie::CPHash';
        %message = getMessage($session{form}{mid});
        $html = '<h1>'.WebGUI::International::get(228).'</h1>';
        $html .= formHeader().'<table>';
        $html .= WebGUI::Form::hidden("func","editMessageSave");
        $html .= WebGUI::Form::hidden("wid",$session{form}{wid});
        $html .= WebGUI::Form::hidden("sid",$session{form}{sid});
        $html .= WebGUI::Form::hidden("mid",$session{form}{mid});
        $html .= '<tr><td class="formDescription">'.WebGUI::International::get(229).
		'</td><td>'.WebGUI::Form::text("subject",30,255,$message{subject}).'</td></tr>';
        $html .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(230).
		'</td><td>'.WebGUI::Form::textArea("message",$message{message},50,6,1).'</td></tr>';
        $html .= '<tr><td></td><td>'.WebGUI::Form::submit(WebGUI::International::get(62)).'</td></tr>';
        $html .= '</table></form>';
	$html .= showMessage();
        return $html;
}

#-------------------------------------------------------------------
sub editMessageSave {
        if ($session{form}{subject} eq "") {
        	$session{form}{subject} = WebGUI::International::get(232);
        }
        if ($session{form}{message} eq "") {
                $session{form}{subject} .= ' '.WebGUI::International::get(233);
        }
        WebGUI::SQL->write("update discussion set subject=".quote($session{form}{subject}).
		", message=".quote("\n --- (Edited at ".localtime(time).
		" by $session{user}{username}) --- \n\n".$session{form}{message}).
		", subId='$session{form}{sid}' where messageId=$session{form}{mid}");
        return showMessage();
}

#-------------------------------------------------------------------
sub getMessage {
	my (%message);
        tie %message, 'Tie::CPHash';
        %message = WebGUI::SQL->quickHash("select * from discussion where messageId='$_[0]'");
	$message{subject} = WebGUI::HTML::filter($message{subject},'all');
	$message{message} = WebGUI::HTML::filter($message{message},$session{setting}{filterContributedHTML});
	unless ($message{message} =~ /\<div\>/ig || $message{message} =~ /\<br\>/ig || $message{message} =~ /\<p\>/ig) {
		$message{message} =~ s/\n/\<br\>/g;
	}
	return %message;
}

#-------------------------------------------------------------------
sub postNewMessage {
	my ($html);
	$html = '<h1>'.WebGUI::International::get(231).'</h1>';
	$html .= formHeader().'<table>';
	$html .= WebGUI::Form::hidden("func","postNewMessageSave");
	$html .= WebGUI::Form::hidden("wid",$session{form}{wid});
	$html .= WebGUI::Form::hidden("sid",$session{form}{sid});
	if ($session{user}{userId} == 1) {
		$html .= tableFormRow(WebGUI::International::get(438),WebGUI::Form::text("visitorName",30,35));
	}
	$html .= '<tr><td class="formDescription">'.WebGUI::International::get(229).'</td><td>'.WebGUI::Form::text("subject",30,255).'</td></tr>';
	$html .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(230).'</td><td>'.WebGUI::Form::textArea("message",'',50,6,1).'</td></tr>';
        $html .= '<tr><td></td><td>'.WebGUI::Form::submit(WebGUI::International::get(62)).'</td></tr>';
	$html .= '</table></form>';
	return $html;
}

#-------------------------------------------------------------------
sub postNewMessageSave {
	my ($mid, $visitor);
        if ($session{form}{subject} eq "") {
        	$session{form}{subject} = WebGUI::International::get(232);
        }
	if ($session{form}{message} eq "") {
        	$session{form}{subject} .= ' '.WebGUI::International::get(233);
        }
	if ($session{form}{visitorName} eq "") {
		$visitor = $session{user}{username};
	} else {
		$visitor = $session{form}{visitorName};
	}
	$mid = getNextId("messageId");
	WebGUI::SQL->write("insert into discussion values ($mid, $mid, $session{form}{wid}, 0, $session{user}{userId}, ".quote($visitor).", ".quote($session{form}{subject}).", ".quote($session{form}{message}).", ".time().", '$session{form}{sid}')");
	return "";
}

#-------------------------------------------------------------------
sub postReply {
	my ($html, $subject);
	($subject) = WebGUI::SQL->quickArray("select subject from discussion where messageId=$session{form}{mid}");
	$subject = "Re: ".$subject;
        $html = '<h1>'.WebGUI::International::get(234).'</h1>';
        $html .= formHeader().'<table>';
        $html .= WebGUI::Form::hidden("func","postReplySave");
        $html .= WebGUI::Form::hidden("wid",$session{form}{wid});
        $html .= WebGUI::Form::hidden("sid",$session{form}{sid});
        $html .= WebGUI::Form::hidden("mid",$session{form}{mid});
	if ($session{user}{userId} == 1) {
		$html .= tableFormRow(WebGUI::International::get(438),WebGUI::Form::text("visitorName",30,35));
	}
	$html .= '<tr><td class="formDescription">'.WebGUI::International::get(229).'</td><td>'.WebGUI::Form::text("subject",30,255,$subject).'</td></tr>';
	$html .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(230).'</td><td>'.WebGUI::Form::textArea("message",'',50,6,1).'</td></tr>';
        $html .= '<tr><td></td><td>'.WebGUI::Form::submit(WebGUI::International::get(62)).'</td></tr>';
	$html .= '</table></form>';
	$html .= showMessage();
	return $html;
}

#-------------------------------------------------------------------
sub postReplySave {
	my ($rid, $mid, $visitor);
        if ($session{form}{subject} eq "") {
        	$session{form}{subject} = WebGUI::International::get(232);
        }
 	if ($session{form}{message} eq "") {
               	$session{form}{subject} .= ' '.WebGUI::International::get(233);
        }
        if ($session{form}{visitorName} eq "") {
                $visitor = $session{user}{username};
        } else {
                $visitor = $session{form}{visitorName};
        }
	$mid = getNextId("messageId");
	($rid) = WebGUI::SQL->quickArray("select rid from discussion where messageId=$session{form}{mid}");
	WebGUI::SQL->write("insert into discussion values ($mid, $rid, $session{form}{wid}, $session{form}{mid}, $session{user}{userId}, ".quote($visitor).", ".quote($session{form}{subject}).", ".quote($session{form}{message}).", ".time().", '$session{form}{sid}')");
	return "";
}

#-------------------------------------------------------------------
sub purgeWidget {
	WebGUI::SQL->write("delete from discussion where widgetId=$_[0]",$_[1]);
}

#-------------------------------------------------------------------
sub showMessage {
	my ($html, %message);
	tie %message, 'Tie::CPHash';
	%message = getMessage($session{form}{mid});
	if ($message{messageId}) {
        	$html = '<table width="100%" cellpadding=3 cellspacing=1 border=0><tr><td class="tableHeader">';
        	$html .= '<b>'.WebGUI::International::get(237).'</b>'.$message{subject}.'<br>';
        	$html .= '<b>'.WebGUI::International::get(238).'</b> <a href="'.WebGUI::URL::page('op=viewProfile&uid='.$message{userId}).'">'.$message{username}.'</a><br>';
        	$html .= "<b>".WebGUI::International::get(239)."</b> ".epochToHuman($message{dateOfPost},"%w, %c %D, %y at %H:%n%p")."<br>";
        	$html .= "<b>".WebGUI::International::get(240)."</b> ".$message{widgetId}."-".$message{rid}."-".$message{pid}."-".$message{messageId}."<br>";
        	$html .= '</td></tr><tr><td class="tableData">';
        	$html .= $message{message};
        	$html .= '</td></tr></table>';
	} else {
		$html = WebGUI::International::get(402);
	}
	return $html;
}

#-------------------------------------------------------------------
sub showReplyTree {
	my (@data, $html, %message);
	tie %message, 'Tie::CPHash';
	%message = getMessage($session{form}{mid});
	if ($message{messageId}) {
		$html .= '<table border=0 cellpadding=2 cellspacing=1 width="100%">';
		$html .= '<tr><td class="tableHeader">'.WebGUI::International::get(229).
			'</td><td class="tableHeader">'.WebGUI::International::get(244).
			'</td><td class="tableHeader">'.WebGUI::International::get(245).'</td></tr>';
		$html .= traverseReplyTree($message{rid},0);
		$html .= "</table>";
	}
	return $html;
}

#-------------------------------------------------------------------
sub traverseReplyTree {
        my ($sth, @data, $html, $depth, $i);
        for ($i=0;$i<=$_[1];$i++) {
                $depth .= "&nbsp;&nbsp;";
        }
        $sth = WebGUI::SQL->read("select messageId,subject,username,dateOfPost,userId from discussion where pid=$_[0] order by messageId");
        while (@data = $sth->array) {
		$data[1] = WebGUI::HTML::filter($data[1],'all');
                $html .= '<tr';
                if ($session{form}{mid} eq $data[0]) {
                        $html .= ' class="highlight"';
                }
                $html .= '><td class="tableData">'.$depth.'<a href="'.WebGUI::URL::page('func=showMessage&mid='.$data[0].'&wid='.$session{form}{wid}.'&sid='.$session{form}{sid}).'">'.substr($data[1],0,30).'</a></td><td class="tableData"><a href="'.WebGUI::URL::page('op=viewProfile&uid='.$data[4]).'">'.$data[2].'</a></td><td class="tableData">'.epochToHuman($data[3],"%M/%D %H:%n%p").'</td></tr>';
                $html .= traverseReplyTree($data[0],$_[1]+1);
        }
        $sth->finish;
        return $html;
}


1;
