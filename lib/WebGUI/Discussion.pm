package WebGUI::Discussion;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black LLC.
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
use WebGUI::MessageLog;
use WebGUI::Paginator;
use WebGUI::Privilege;
use WebGUI::Search;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::User;

our %status =("Approved"=>WebGUI::International::get(560),
        "Denied"=>WebGUI::International::get(561),
        "Pending"=>WebGUI::International::get(562));

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
	tie %data, 'Tie::CPHash';
        $sth = WebGUI::SQL->read("select * from discussion where pid=$_[0] order by messageId");
        while (%data = $sth->hash) {
                $newMessageId = getNextId("messageId");
		WebGUI::SQL->write("insert into discussion values ($newMessageId, $_[2], $_[3], $_[1], $data{userId}, "
			.quote($data{username}).", ".quote($data{subject}).", ".quote($data{message}).
			", $data{dateOfPost}, $_[4], $data{views}, $data{locked}, ".quote($data{status}).")");
                _duplicateReplyTree($data{messageId},$newMessageId,$_[2],$_[3],$_[4]);
        }
        $sth->finish;
}

#-------------------------------------------------------------------
sub _lockReplyTree {
        my ($sth, %data, $messageId);
        tie %data, 'Tie::CPHash';
        $sth = WebGUI::SQL->read("select messageId from discussion where pid=$_[0] order by messageId");
        while (%data = $sth->hash) {
                _lockReplyTree($data{messageId});
                WebGUI::SQL->write("update discussion set locked=1 where messageId=$data{messageId}");
        }
        $sth->finish;
}

#-------------------------------------------------------------------
sub _unlockReplyTree {
        my ($sth, %data, $messageId);
        tie %data, 'Tie::CPHash';
        $sth = WebGUI::SQL->read("select messageId from discussion where pid=$_[0] order by messageId");
        while (%data = $sth->hash) {
                _unlockReplyTree($data{messageId});
                WebGUI::SQL->write("update discussion set locked=0 where messageId=$data{messageId}");
        }
        $sth->finish;
}

#-------------------------------------------------------------------
sub approvePost {
	my (%message);
        tie %message, 'Tie::CPHash';
        %message = getMessage($session{form}{mid});
        WebGUI::SQL->write("update discussion set status='Approved' where messageId=$session{form}{mid}");
	WebGUI::MessageLog::addInternationalizedEntry($message{userId},'',
        	WebGUI::URL::page('func=showMessage&wid='.$session{form}{wid}.'&sid='
                .$session{form}{sid}.'&mid='.$session{form}{mid}), 579);
        WebGUI::MessageLog::completeEntry($session{form}{mlog});
        return WebGUI::Operation::www_viewMessageLog();
}

#-------------------------------------------------------------------
sub canEditMessage {
        my (%message);
        tie %message, 'Tie::CPHash';
        %message = getMessage($_[1]);
        if (    # is the message owner
		(
			(time()-$message{dateOfPost}) < $_[0]->get("editTimeout") 
			&& $message{userId} eq $session{user}{userId}
			&& !($message{locked})
		)
		# is a moderator
                || WebGUI::Privilege::isInGroup($_[0]->get("groupToModerate"))
                ) {
                return 1;
        } else {
                return 0;
        }
}

#-------------------------------------------------------------------
sub canPostReply {
        if (WebGUI::Privilege::isInGroup($_[0]->get("groupToPost")) && !(${$_[1]}{locked}) && ${$_[1]}{status} eq "Approved") {
		return 1;
	} else {
		return 0;
	}
}

#-------------------------------------------------------------------
sub denyPost {
        my (%message);
        tie %message, 'Tie::CPHash';
        %message = getMessage($session{form}{mid});
        WebGUI::SQL->write("update discussion set status='Denied' where messageId=$session{form}{mid}");
        WebGUI::MessageLog::addInternationalizedEntry($message{userId},'',
                WebGUI::URL::page('func=showMessage&wid='.$session{form}{wid}.'&sid='
                .$session{form}{sid}.'&mid='.$session{form}{mid}), 580);
        WebGUI::MessageLog::completeEntry($session{form}{mlog});
        return WebGUI::Operation::www_viewMessageLog();
}

#-------------------------------------------------------------------
sub duplicate {
        my ($sth, %data, $newMessageId, $oldSubId, $newSubId);
	tie %data, 'Tie::CPHash';
	$oldSubId = $_[2] || 0;
	$newSubId = $_[3] || 0;
        $sth = WebGUI::SQL->read("select * from discussion where wobjectId=$_[0] and pid=0 and subId=$oldSubId order by messageId");
        while (%data = $sth->hash) {
                $newMessageId = getNextId("messageId");
		WebGUI::SQL->write("insert into discussion values ($newMessageId, $newMessageId, $_[1], 0, 
			$data{userId}, ".quote($data{username}).", ".quote($data{subject}).", "
			.quote($data{message}).", $data{dateOfPost}, $newSubId, $data{views}, $data{locked},
			".quote($data{status}).")");
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
	my ($output, $subject);
	$subject = $_[0];
	if ($_[5] ne "") {
		$subject = '<a href="'.$_[5].'">'.$subject.'</a>';
	}
	$output = '<b>'.WebGUI::International::get(237).'</b> '.$subject.'<br>' if ($_[0] ne "");
        $output .= '<b>'.WebGUI::International::get(238).'</b> 
		<a href="'.WebGUI::URL::page('op=viewProfile&uid='.$_[1]).'">'.$_[2].'</a><br>' if ($_[1] && $_[2] ne "");
        $output .= "<b>".WebGUI::International::get(239)."</b> ".epochToHuman($_[3],"%z %Z")."<br>" if ($_[3]);
	$output .= "<b>".WebGUI::International::get(514).":</b> ".$_[4]."<br>" if ($_[4]);
	$output .= "<b>".WebGUI::International::get(553).":</b> ".$_[6]."<br>" if ($_[6]);
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
sub getMessage {
	my (%message);
        tie %message, 'Tie::CPHash';
        %message = WebGUI::SQL->quickHash("select * from discussion where messageId='$_[0]'");
	return %message;
}

#-------------------------------------------------------------------
sub lockThread {
        _lockReplyTree($session{form}{mid});
        WebGUI::SQL->write("update discussion set locked=1 where messageId=$session{form}{mid}");
        return "";
}

#-------------------------------------------------------------------
sub post {
	my ($html, $header, $footer, $f, %message);
	tie %message, 'Tie::CPHash';
	$f = WebGUI::HTMLForm->new;
	if ($session{form}{replyTo} ne "") { 		# is a reply
		$header = WebGUI::International::get(234);
		%message = getMessage($session{form}{replyTo});
		$footer = formatHeader($message{subject},$message{userId},$message{username},$message{dateOfPost},$message{views},
			'',$message{status})
			.'<p>'.formatMessage($message{message});
		$message{message} = "";
		$message{subject} = "Re: ".$message{subject} unless ($message{subject} =~ /^Re:/);
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
		$footer = formatHeader($message{subject},$message{userId},$message{username},$message{dateOfPost},$message{views},
			'',$message{status})
			.'<p>'.formatMessage($message{message});
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
	my ($u, $rid, $status, $username, $pid);
        if ($session{form}{subject} eq "") {
        	$session{form}{subject} = WebGUI::International::get(232);
        } else {
		$session{form}{subject} = WebGUI::HTML::filter($session{form}{subject},'all');
	}
 	if ($session{form}{message} eq "") {
              		$session{form}{subject} .= ' '.WebGUI::International::get(233);
        }
	if ($session{form}{mid} eq "new") {
	       	if ($session{user}{userId} == 1) {
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
		if ($_[0]->get("moderationType") eq "before") {
			$status = "Pending";
			WebGUI::MessageLog::addInternationalizedEntry('',$_[0]->get("groupToModerate"),
				WebGUI::URL::page('func=showMessage&wid='.$session{form}{wid}.'&sid='
				.$session{form}{sid}.'&mid='.$session{form}{mid}),
				578,'WebGUI','pending');
		} else {
			$status = "Approved";
		}
		WebGUI::SQL->write("insert into discussion (messageId, wobjectId, subId, rid, pid, userId, username, status) values
			($session{form}{mid},$session{form}{wid},$session{form}{sid},$rid,$pid,$session{user}{userId},"
			.quote($username).", '$status')");
	} elsif ($session{setting}{addEditStampToPosts}) {
		$session{form}{message} = "\n --- (Edited at ".epochToHuman(time())." by $session{user}{username}) --- \n\n"
			.$session{form}{message};
	}
	WebGUI::SQL->write("update discussion set subject=".quote($session{form}{subject}).", 
		message=".quote($session{form}{message}).", dateOfPost=".time()." where messageId=$session{form}{mid}");
        if ($session{setting}{useKarma}) {
        	$u = WebGUI::User->new($session{user}{userId});
	               $u->karma($_[0]->get("karmaPerPost"),"Discussion ("
				.$session{form}{wid}."/".$session{form}{sid}.")","Made a post.");
        }
	return "";
}

#-------------------------------------------------------------------
sub purge {
	WebGUI::SQL->write("delete from discussion where wobjectId=$_[0]");
}

#-------------------------------------------------------------------
sub search {
	my ($p, $i, $output, $constraints, $sql, $sth, %data, @row, $url);
	$output = WebGUI::Search::form({wid=>"$session{form}{wid}",sid=>"$session{form}{sid}",func=>'search'});
	$constraints = WebGUI::Search::buildConstraints([qw(username subject message)]);
	if ($constraints ne "") {
		tie %data, 'Tie::CPHash';
        	$url = WebGUI::URL::page('func=search&wid='.$session{form}{wid}.'&sid='.$session{form}{sid}
			.'&all='.WebGUI::URL::escape($session{form}{all})
                	.'&exactPhrase='.WebGUI::URL::escape($session{form}{exactPhrase}).'&atLeastOne='
			.WebGUI::URL::escape($session{form}{atLeastOne}).'&numResults='.$session{form}{numResults}
                	.'&without='.WebGUI::URL::escape($session{form}{without}));
		$output .= '<table border=0 cellpadding=2 cellspacing=1 width="100%">';
		$output .= '<tr><td class="tableHeader">'.WebGUI::International::get(229).
                	'</td><td class="tableHeader">'.WebGUI::International::get(244).
                        '</td><td class="tableHeader">'.WebGUI::International::get(245).'</td></tr>';
        	$sql = "select * from discussion where wobjectId=$session{form}{wid} ";
        	$sql .= " and subId=$session{form}{sid} " if ($session{form}{sid});
        	$sql .= " and ".$constraints." order by dateOfPost desc";
		$sth = WebGUI::SQL->read($sql);
		while (%data = $sth->hash) {
			$data{subject} = substr(WebGUI::HTML::filter($data{subject},'all'),0,30);
                        $row[$i] .= '<tr><td class="tableData"><a href="'.WebGUI::URL::page('func=showMessage&mid='.
                                $data{messageId}.'&wid='.$session{form}{wid}.'&sid='.$session{form}{sid}).'">'.$data{subject}.
                                '</a></td><td class="tableData"><a href="'.
                                WebGUI::URL::page('op=viewProfile&uid='.$data{userId}).'">'.$data{username}.
                                '</a></td><td class="tableData">'.epochToHuman($data{dateOfPost}).
                                '</td></tr>';
			$i++;
		}
		$sth->finish;
        	$p = WebGUI::Paginator->new($url,\@row,$session{form}{numResults});
        	$output .= $p->getPage($session{form}{pn});
        	$output .= '</table>';
       		$output .= $p->getBarTraditional($session{form}{pn});
	}
	return $output;
}

#-------------------------------------------------------------------
sub showMessage {
        my (@data, $html, %message, $sqlAdd);
        tie %message, 'Tie::CPHash';
	if ($session{form}{mid} eq "") {
		($session{form}{mid}) = WebGUI::SQL->quickArray("select min(messageId) from discussion 
			where wobjectId=$session{form}{wid}");
	}
	if ($session{form}{sid}) {
		$sqlAdd = " and subId=$session{form}{sid}";
	}
	if ($session{form}{mid} eq "") {
        	($session{form}{mid}) = WebGUI::SQL->quickArray("select min(messageId) from discussion 
			where wobjectId=$session{form}{wid}".$sqlAdd);
	}
	WebGUI::SQL->write("update discussion set views=views+1 where messageId=$session{form}{mid}");
        %message = getMessage($session{form}{mid});
        if ($message{messageId}) {
                $html .= '<h1>'.$message{subject}.'</h1>';
                $html .= '<table width="100%" cellpadding=3 cellspacing=1 border=0><tr>';
		$html .= '<td class="tableHeader" width="100%" valign="top">';
		$html .= formatHeader($message{subject},$message{userId},$message{username},$message{dateOfPost},
			$message{views},'',$message{status});
                $html .= '</td>';
                $html .= '<td rowspan=2 valign="top" class="tableMenu" nowrap="1">';
		if (canPostReply($_[1],\%message)) {
			$html .= '<a href="'.WebGUI::URL::page('func=post&replyTo='.$session{form}{mid}.'&wid='
				.$session{form}{wid}.'&sid='.$session{form}{sid})
                        	.'">'.WebGUI::International::get(577).'</a><br>';
		} 
        	@data = WebGUI::SQL->quickArray("select max(messageId) from discussion 
			where wobjectId=$message{wobjectId} and pid=0 and messageId<$message{rid} 
			and (userId=$session{user}{userId} or status='Approved') ".$sqlAdd);
        	if ($data[0] ne "") {
                	$html .= '<a href="'.WebGUI::URL::page('func=showMessage&mid='.$data[0].'&sid='.$session{form}{sid}.'&wid='.
                        	$session{form}{wid}).'">&laquo; '.WebGUI::International::get(513).'</a><br>';
        	}
        	@data = WebGUI::SQL->quickArray("select min(messageId) from discussion 
			where wobjectId=$message{wobjectId} and pid=0 and messageId>$message{rid}
			and (userId=$session{user}{userId} or status='Approved')".$sqlAdd);
        	if ($data[0] ne "") {
                	$html .= '<a href="'.WebGUI::URL::page('func=showMessage&mid='.$data[0].'&sid='.$session{form}{sid}.'&wid='.
                        	$session{form}{wid}).'">'.WebGUI::International::get(512).' &raquo;</a><br>';
        	}
		if (canEditMessage($_[1],$session{form}{mid})) {
                	$html .= '<a href="'.WebGUI::URL::page('func=post&mid='.$session{form}{mid}.
                        	'&wid='.$session{form}{wid}.'&sid='.$session{form}{sid}).'">'
				.WebGUI::International::get(575).'</a><br>';
                	$html .= '<a href="'.WebGUI::URL::page('func=deleteMessage&mid='.$session{form}{mid}.
                                '&wid='.$session{form}{wid}.'&sid='.$session{form}{sid}).'">'
				.WebGUI::International::get(576).'</a><br>';
        	}
		if (WebGUI::Privilege::isInGroup($_[1]->get("groupToModerate"))) {
			unless ($message{locked}) {
				$html .= '<a href="'.WebGUI::URL::page('func=lockThread&wid='.$session{form}{wid}
					.'&sid='.$session{form}{sid}.'&mid='.$session{form}{mid}).'">'
					.WebGUI::International::get(570).'</a><br>';
			} else {
				$html .= '<a href="'.WebGUI::URL::page('func=unlockThread&wid='.$session{form}{wid}
					.'&sid='.$session{form}{sid}.'&mid='.$session{form}{mid}).'">'
					.WebGUI::International::get(571).'</a><br>';
			}
			if ($message{status} ne "Approved") {
                		$html .= '<a href="'.WebGUI::URL::page('func=approvePost&wid='.$session{form}{wid}.
                        		'&sid='.$session{form}{sid}.'&mid='.$session{form}{mid}.'&mlog='.$session{form}{mlog}).'">'.
                        		WebGUI::International::get(572).'</a><br>';
                		$html .= '<a href="'.WebGUI::URL::page('op=viewMessageLog').'">'.
                        		WebGUI::International::get(573).'</a><br>';
                		$html .= '<a href="'.WebGUI::URL::page('func=denyPost&wid='.$session{form}{wid}.
                        		'&sid='.$session{form}{sid}.'&mid='.$session{form}{mid}.'&mlog='.$session{form}{mlog}).'">'.
                        		WebGUI::International::get(574).'</a><br>';
        		}

		}
        	$html .= '<a href="'.WebGUI::URL::page('func=search&wid='.$session{form}{wid}.'&sid='.$session{form}{sid}).'">'
                	.WebGUI::International::get(364).'</a><br>';
		$html .= $_[0];
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
	my (@data, $html, $sql, %message, $sth, %data);
	tie %message, 'Tie::CPHash';
	tie %data, 'Tie::CPHash';
	%message = getMessage($session{form}{mid});
	if ($message{messageId}) {
		$html .= '<table border=0 cellpadding=2 cellspacing=1 width="100%">';
		if ($session{user}{discussionLayout} eq "threaded") {
			$html .= '<tr><td class="tableHeader">'.WebGUI::International::get(229).
				'</td><td class="tableHeader">'.WebGUI::International::get(244).
				'</td><td class="tableHeader">'.WebGUI::International::get(245).'</td></tr>';
			@data = WebGUI::SQL->quickArray("select messageId,subject,username,dateOfPost,userId,status
				from discussion where messageId=$message{rid}");
                	$html .= '<tr';
                	if ($session{form}{mid} eq $message{rid}) {
                        	$html .= ' class="highlight"';
                	}
                	$html .= '><td class="tableData"><a href="'.WebGUI::URL::page('func=showMessage&mid='.$data[0].'&wid='.
                        	$message{wobjectId}).'">'.substr($data[1],0,30).'</a>';
			if ($data[4] == $session{user}{userId}) {
				$html .= ' ('.$status{$data[5]}.')';
			}
			$html .= '</td><td class="tableData"><a href="'.
                        	WebGUI::URL::page('op=viewProfile&uid='.$data[4]).'">'.$data[2].
                        	'</a></td><td class="tableData">'.
                        	epochToHuman($data[3],"%z %Z").'</td></tr>';
			$html .= traverseReplyTree($message{rid},0);
		} else {
        		$sql = "select * from discussion where rid=$message{rid} and wobjectId=$session{form}{wid}";
        		if ($session{form}{sid}) {
                		$sql .= " and subId=$session{form}{sid}";
        		}
			$sql .= " and (status='Approved' or userId=$session{user}{userId})";
        		$sql .= " order by messageId";
        		$sth = WebGUI::SQL->read($sql);
                	while (%data = $sth->hash) {
				unless ($data{messageId} == $session{form}{mid} && $data{messageId} == $data{rid}) { # don't show first message.
                        		$html .= '<tr><td class="tableHeader">';
                        		$html .= formatHeader($data{subject},$data{userId},$data{username},$data{dateOfPost},$data{views}, 
						WebGUI::URL::page('func=showMessage&mid='.$data{messageId}.'&wid='.$session{form}{wid}),
						$data{status});
                        		$html .= '</td></tr><tr class="tableData"><td ';
					if ($data{messageId} == $message{messageId}) {
						$html .= 'class="highlight"';
					}
					$html .= '>'.formatMessage($data{message}).'<br/><br/></td></tr>';
				}
                	}
			$sth->finish;
		}
		$html .= "</table>";
	}
	return $html;
}

#-------------------------------------------------------------------
sub showThreads {
        my ($sth, %data, $html, $sql);
	tie %data, 'Tie::CPHash';
        $sql = "select * from discussion where wobjectId=$session{form}{wid}";
        $sql .= " and subId=$session{form}{sid}" if ($session{form}{sid});
	$sql .= " and (status='Approved' or userId=$session{user}{userId})";
       	$html .= '<table border=0 cellpadding=2 cellspacing=1 width="100%">';
	if ($session{user}{discussionLayout} eq "threaded") {
        	$sql .= " and pid=0 order by dateOfPost desc";
        	$sth = WebGUI::SQL->read($sql);
                $html .= '<tr><td class="tableHeader">'.WebGUI::International::get(229).'</td>
                        <td class="tableHeader">'.WebGUI::International::get(244).'</td>
                        <td class="tableHeader">'.WebGUI::International::get(245).'</td></tr>' if ($sth->rows);
                while (%data = $sth->hash) {
                        $data{subject} = WebGUI::HTML::filter($data{subject},'all');
                        $html .= '<tr';
                        if ($data{messageId} == $session{form}{mid}) {
                                $html .= ' class="highlight"';
                        }
                        $html .= '><td class="tableData"><a href="'.WebGUI::URL::page('func=showMessage&mid='.
                                $data{messageId}.'&wid='.$session{form}{wid}.'&sid='.$session{form}{sid}).'">'.substr($data{subject},0,30).
                                '</a>';
                        if ($data{userId} == $session{user}{userId}) {
                                $html .= ' ('.$status{$data{status}}.')';
                        }
                        $html .= '</td><td class="tableData"><a href="'.
                                WebGUI::URL::page('op=viewProfile&uid='.$data{userId}).'">'.$data{username}.
                                '</a></td><td class="tableData">'.epochToHuman($data{dateOfPost},"%z %Z").
                                '</td></tr>';
                        $html .= WebGUI::Discussion::traverseReplyTree($data{messageId},1);
                }
	} else {
        	$sql .= " order by dateOfPost";
        	$sth = WebGUI::SQL->read($sql);
		while (%data = $sth->hash) {
			$html .= '<tr><td class="tableHeader">';
			$html .= formatHeader($data{subject},$data{userId},$data{username},$data{dateOfPost},$data{views},
				WebGUI::URL::page('func=showMessage&mid='.$data{messageId}.'&wid='.$session{form}{wid}),
				$data{status});
			$html .= '</td></tr><tr class="tableData"><td ';
			if ($data{messageId} eq $session{form}{mid}) {
				$html .= 'class="highlight"';
			}
			$html .= '>'.formatMessage($data{message}).'<br/><br/></td></tr>';
		}
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
        $sth = WebGUI::SQL->read("select messageId,subject,username,dateOfPost,userId,status from discussion where pid=$_[0]
		and (status='Approved' or userId=$session{user}{userId}) order by messageId");
        while (@data = $sth->array) {
		$data[1] = WebGUI::HTML::filter($data[1],'all');
                $html .= '<tr';
                if ($session{form}{mid} eq $data[0]) {
                        $html .= ' class="highlight"';
                }
                $html .= '><td class="tableData">'.$depth.'<a href="'.WebGUI::URL::page('func=showMessage&mid='.$data[0]
			.'&wid='.$session{form}{wid}.'&sid='.$session{form}{sid}).'">'.substr($data[1],0,30).'</a>';
                if ($data[4] == $session{user}{userId}) {
                        $html .= ' ('.$status{$data[5]}.')';
                }
                $html .= '</td><td class="tableData"><a href="'.WebGUI::URL::page('op=viewProfile&uid='.$data[4]).'">'
			.$data[2].'</a></td><td class="tableData">'.epochToHuman($data[3],"%z %Z").'</td></tr>';
                $html .= traverseReplyTree($data[0],$_[1]+1);
        }
        $sth->finish;
        return $html;
}

#-------------------------------------------------------------------
sub unlockThread {
        _unlockReplyTree($session{form}{mid});
        WebGUI::SQL->write("update discussion set locked=0 where messageId=$session{form}{mid}");
        return "";
}




1;
