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
use WebGUI::HTMLForm;
use WebGUI::International;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;

#-------------------------------------------------------------------
sub _deleteReplyTree {
        my ($sth, %data, $messageId);
	tie %data, 'Tie::CPHash';
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
        $sth = WebGUI::SQL->read("select * from discussion where wobjectId=$_[0] and pid=0 and subId=$oldSubId order by messageId");
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
sub formatHeader {
	my $output;
	$output = '<b>'.WebGUI::International::get(237).'</b> '.formatSubject($_[0]).'<br>' if ($_[0] ne "");
        $output .= '<b>'.WebGUI::International::get(238).'</b> 
		<a href="'.WebGUI::URL::page('op=viewProfile&uid='.$_[1]).'">'.$_[2].'</a><br>' if ($_[1] && $_[2] ne "");
        $output .= "<b>".WebGUI::International::get(239)."</b> ".epochToHuman($_[3],"%z %Z")."<br>" if ($_[3]);
	$output .= "<b>".WebGUI::International::get(514).":</b> ".$_[4]."<br>" if ($_[4]);
	return $output;
}

#-------------------------------------------------------------------
sub formatMessage {
        my $output;
	$output = $_[0];
	$output = WebGUI::HTML::filter($output);
	unless ($output =~ /\<div\>/ig || $output =~ /\<br\>/ig || $output =~ /\<p\>/ig) {
		$output =~ s/\n/\<br\>/g;
	}
        return $output;
}

#-------------------------------------------------------------------
sub formatSubject {
        my $output;
        $output = $_[0];
        $output = WebGUI::HTML::filter($output,'all');
        return $output;
}

#-------------------------------------------------------------------
sub getMessage {
	my (%message);
        tie %message, 'Tie::CPHash';
        %message = WebGUI::SQL->quickHash("select * from discussion where messageId='$_[0]'");
	return %message;
}

#-------------------------------------------------------------------
sub post {
	my ($html, $header, $footer, $f, %message);
	tie %message, 'Tie::CPHash';
	$f = WebGUI::HTMLForm->new;
	if ($session{form}{replyTo} ne "") { 		# is a reply
		$header = WebGUI::International::get(234);
		%message = getMessage($session{form}{replyTo});
		$footer = formatHeader($message{subject},$message{userId},$message{username},$message{dateOfPost},$message{views})
			.'<p>'.formatMessage($message{message});
		$message{message} = "";
		$message{subject} = formatSubject("Re: ".$message{subject});
		$session{form}{mid} = "new";
		$f->hidden("replyTo",$session{form}{replyTo});
        	if ($session{user}{userId} == 1) {
                	$f->text("visitorName",WebGUI::International::get(438));
        	}
	} elsif ($session{form}{mid} eq "new") { 	# is an entirely new thread
		$header = WebGUI::International::get(231);
        	if ($session{user}{userId} == 1) {
                	$f->text("visitorName",WebGUI::International::get(438));
        	}
	} else {					# is editing an existing message
		$header = WebGUI::International::get(228);
		%message = getMessage($session{form}{mid});
		$footer = formatHeader($message{subject},$message{userId},$message{username},$message{dateOfPost},$message{views})
			.'<p>'.formatMessage($message{message});
		$message{subject} = formatSubject($message{subject});
	}
        $f->hidden("func","postSave");
        $f->hidden("wid",$session{form}{wid});
        $f->hidden("sid",$session{form}{sid});
        $f->hidden("mid",$session{form}{mid});
	$f->text("subject",WebGUI::International::get(229),$message{subject});
	$f->HTMLArea("message",WebGUI::International::get(230),$message{message});
	$f->submit;
	$html = '<h1>'.$header.'</h1>';
	$html .= $f->print;
	$html .= '<p/>'.$footer;
	return $html;
}

#-------------------------------------------------------------------
sub postSave {
	my ($rid, $username, $pid);
        if ($session{form}{subject} eq "") {
        	$session{form}{subject} = WebGUI::International::get(232);
        }
 	if ($session{form}{message} eq "") {
               	$session{form}{subject} .= ' '.WebGUI::International::get(233);
        }
	if ($session{form}{mid} eq "new") {
	        if ($session{user}{userId} = 1) {
        	        if ($session{form}{visitorName} eq "") {
                	        $username = $session{user}{username};
                	} else {
                	        $username = $session{form}{visitorName};
                	}
        	} else {
                	$username = $session{user}{username};
        	}
		if ($session{form}{sid} eq "") {
			$session{form}{sid} = 0;
		}
		$session{form}{mid} = getNextId("messageId");
		if ($session{form}{replyTo} ne "") {
			($rid) = WebGUI::SQL->quickArray("select rid from discussion where messageId=$session{form}{replyTo}");
			$pid = $session{form}{replyTo};
		} else {
			$rid = $session{form}{mid};
			$pid = 0;
		}
		WebGUI::SQL->write("insert into discussion (messageId, wobjectId, subId, rid, pid, userId, username) values
			($session{form}{mid},$session{form}{wid},$session{form}{sid},$rid,$pid,$session{user}{userId},".quote($username).")");
	} elsif ($session{setting}{addEditStampToPosts}) {
		$session{form}{message} = "\n --- (Edited at ".localtime(time)." by $session{user}{username}) --- \n\n".$session{form}{message};
	}
	WebGUI::SQL->write("update discussion set subject=".quote($session{form}{subject}).", 
		message=".quote($session{form}{message}).", dateOfPost=".time()." where messageId=$session{form}{mid}");
	return "";
}

#-------------------------------------------------------------------
sub purge {
	WebGUI::SQL->write("delete from discussion where wobjectId=$_[0]");
}

#-------------------------------------------------------------------
sub showMessage {
        my (@data, $html, %message, $sqlAdd);
        tie %message, 'Tie::CPHash';
	if ($session{form}{sid}) {
		$sqlAdd = " and subId=$session{form}{sid}";
	}
	if ($session{form}{mid} eq "") {
        	($session{form}{mid}) = WebGUI::SQL->quickArray("select min(messageId) from discussion where wobjectId=$session{form}{wid}".$sqlAdd);
	}
	WebGUI::SQL->write("update discussion set views=views+1 where messageId=$session{form}{mid}");
        %message = getMessage($session{form}{mid});
        if ($message{messageId}) {
                $html .= '<h1>'.$message{subject}.'</h1>';
                $html .= '<table width="100%" cellpadding=3 cellspacing=1 border=0><tr><td class="tableHeader">';
		$html .= formatHeader($message{subject},$message{userId},$message{username},$message{dateOfPost},$message{views});
                $html .= '</td>';
                $html .= '<td rowspan=2 valign="top" class="tableMenu" nowrap>';
		$html .= $_[0];
        	@data = WebGUI::SQL->quickArray("select max(messageId) from discussion 
			where wobjectId=$message{wobjectId} and pid=0 and messageId<$message{rid}".$sqlAdd);
        	if ($data[0] ne "") {
                	$html .= '<a href="'.WebGUI::URL::page('func=showMessage&mid='.$data[0].'&sid='.$session{form}{sid}.'&wid='.
                        	$session{form}{wid}).'">&laquo; '.WebGUI::International::get(513).'</a><br>';
        	}
        	@data = WebGUI::SQL->quickArray("select min(messageId) from discussion 
			where wobjectId=$message{wobjectId} and pid=0 and messageId>$message{rid}".$sqlAdd);
        	if ($data[0] ne "") {
                	$html .= '<a href="'.WebGUI::URL::page('func=showMessage&mid='.$data[0].'&sid='.$session{form}{sid}.'&wid='.
                        	$session{form}{wid}).'">'.WebGUI::International::get(512).' &raquo;</a><br>';
        	}
                $html .= '</tr><tr><td class="tableData">';
                $html .= formatMessage($message{message}).'<p>';
                $html .= '</td></tr></table>';
        } else {
                $html = WebGUI::International::get(402);
        }
        return $html;
}

#-------------------------------------------------------------------
sub showReplyTree {
	my (@data, $html, %message, @data);
	tie %message, 'Tie::CPHash';
	%message = getMessage($session{form}{mid});
	if ($message{messageId}) {
		$html .= '<table border=0 cellpadding=2 cellspacing=1 width="100%">';
		$html .= '<tr><td class="tableHeader">'.WebGUI::International::get(229).
			'</td><td class="tableHeader">'.WebGUI::International::get(244).
			'</td><td class="tableHeader">'.WebGUI::International::get(245).'</td></tr>';
		@data = WebGUI::SQL->quickArray("select messageId,subject,username,dateOfPost,userId from discussion where messageId=$message{rid}");
                $data[1] = WebGUI::HTML::filter($data[1],'all');
                $html .= '<tr';
                if ($session{form}{mid} eq $message{rid}) {
                        $html .= ' class="highlight"';
                }
                $html .= '><td class="tableData"><a href="'.WebGUI::URL::page('func=showMessage&mid='.$data[0].'&wid='.
                        $message{wobjectId}).'">'.substr($data[1],0,30).'</a></td><td class="tableData"><a href="'.
                        WebGUI::URL::page('op=viewProfile&uid='.$data[4]).'">'.$data[2].
                        '</a></td><td class="tableData">'.
                        epochToHuman($data[3],"%z %Z").'</td></tr>';
		$html .= traverseReplyTree($message{rid},0);
		$html .= "</table>";
	}
	return $html;
}

#-------------------------------------------------------------------
sub showThreads {
        my ($sth, %data, $html, $sql);
        $sql = "select * from discussion where wobjectId=$session{form}{wid}";
        if ($session{form}{sid}) {
                $sql .= " and subId=$session{form}{sid}";
        }
        $sql .= " and pid=0 order by messageId desc";
        $sth = WebGUI::SQL->read($sql);
       	$html .= '<table border=0 cellpadding=2 cellspacing=1 width="100%">';
	if ($session{user}{discussionLayout} eq "flat") {
		while (%data = $sth->hash) {
			$html .= '<tr><td class="tableHeader">';
			$html .= formatHeader($data{subject},$data{userId},$data{username},$data{dateOfPost},$data{views});
			$html .= '</td></tr>';
			$html .= '<tr><td class="tableData">'.formatMessage($data{message}).'</td></tr>';
		}
	} else {
        	$html .= '<table border=0 cellpadding=2 cellspacing=1 width="100%">';
       		$html .= '<tr><td class="tableHeader">'.WebGUI::International::get(229).'</td>
                	<td class="tableHeader">'.WebGUI::International::get(244).'</td>
                	<td class="tableHeader">'.WebGUI::International::get(245).'</td></tr>';
        	while (%data = $sth->hash) {
                	$data{subject} = WebGUI::HTML::filter($data{subject},'all');
                	$html .= '<tr';
                	if ($data{messageId} == $session{form}{mid}) {
                        	$html .= ' class="highlight"';
                	}
                	$html .= '><td class="tableData"><a href="'.WebGUI::URL::page('func=showMessage&mid='.
                                $data{messageId}.'&wid='.$session{form}{wid}.'&sid='.$session{form}{sid}).'">'.substr($data{subject},0,30).
                                '</a></td><td class="tableData"><a href="'.
                                WebGUI::URL::page('op=viewProfile&uid='.$data{userId}).'">'.$data{username}.
                                '</a></td><td class="tableData">'.epochToHuman($data{dateOfPost},"%z %Z").
                                '</td></tr>';
                	$html .= WebGUI::Discussion::traverseReplyTree($data{messageId},1);
        	}
        	$html .= '</table>';
	}
       	$html .= '</table>';
	$sth->finish;
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
                $html .= '><td class="tableData">'.$depth.'<a href="'.WebGUI::URL::page('func=showMessage&mid='.$data[0].'&wid='.$session{form}{wid}.'&sid='.$session{form}{sid}).'">'.substr($data[1],0,30).'</a></td><td class="tableData"><a href="'.WebGUI::URL::page('op=viewProfile&uid='.$data[4]).'">'.$data[2].'</a></td><td class="tableData">'.epochToHuman($data[3],"%z %Z").'</td></tr>';
                $html .= traverseReplyTree($data[0],$_[1]+1);
        }
        $sth->finish;
        return $html;
}


1;
