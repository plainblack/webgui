package WebGUI::Wobject::MessageBoard;

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
use WebGUI::Discussion;
use WebGUI::HTML;
use WebGUI::HTMLForm;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::Utility;
use WebGUI::Wobject;

our @ISA = qw(WebGUI::Wobject);
our $namespace = "MessageBoard";
our $name = WebGUI::International::get(2,$namespace);

#-------------------------------------------------------------------
sub _canEditMessage {
        my (%message);
        tie %message, 'Tie::CPHash';
        %message = WebGUI::Discussion::getMessage($_[1]);
        if (
		(time()-$message{dateOfPost}) < 3600*$_[0]->get("editTimeout") 
		&& $message{userId} eq $session{user}{userId} 
		|| WebGUI::Privilege::isInGroup($_[0]->get("groupToModerate"))
		) {
		return 1;
	} else {
		return 0;
	}
}

#-------------------------------------------------------------------
sub duplicate {
        my ($w);
	$w = $_[0]->SUPER::duplicate($_[1]);
        $w = WebGUI::Wobject::MessageBoard->new({wobjectId=>$w,namespace=>$namespace});
        $w->set({
		groupToPost=>$_[0]->get("groupToPost"),
		messagesPerPage=>$_[0]->get("messagesPerPage"),
		editTimeout=>$_[0]->get("editTimeout"),
		groupToModerate=>$_[0]->get("groupToModerate")
		});
	WebGUI::Discussion::duplicate($_[0]->get("wobjectId"),$w->get("wobjectId"));
}

#-------------------------------------------------------------------
sub new {
        my ($self, $class, $property);
        $class = shift;
        $property = shift;
        $self = WebGUI::Wobject->new($property);
        bless $self, $class;
}

#-------------------------------------------------------------------
sub purge {
	WebGUI::Discussion::purge($_[0]->get("wobjectId"));
	$_[0]->SUPER::purge();
}

#-------------------------------------------------------------------
sub set {
        $_[0]->SUPER::set($_[1],[qw(editTimeout groupToPost groupToModerate messagesPerPage)]);
}

#-------------------------------------------------------------------
sub www_copy {
        if (WebGUI::Privilege::canEditPage()) {
		$_[0]->duplicate;
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteMessage {
        if (_canEditMessage($_[0],$session{form}{mid})) {
                return WebGUI::Discussion::deleteMessage();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteMessageConfirm {
	if (_canEditMessage($_[0],$session{form}{mid})) {
                return WebGUI::Discussion::deleteMessageConfirm();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_edit {
        my ($output, $f, $groupToModerate, $messagesPerPage, $editTimeout);
        if (WebGUI::Privilege::canEditPage()) {
		if ($_[0]->get("wobjectId") eq "new") {
                        $editTimeout = 1;
                } else {
			$editTimeout = $_[0]->get("editTimeout");
		}
		$groupToModerate = $_[0]->get("groupToModerate") || 4;
		$messagesPerPage = $_[0]->get("messagesPerPage") || 50;
                $output = helpIcon(1,$namespace);
		$output .= '<h1>'.WebGUI::International::get(6,$namespace).'</h1>';
		$f = WebGUI::HTMLForm->new;
                $f->group("groupToPost",WebGUI::International::get(3,$namespace),[$_[0]->get("groupToPost")]);
		$f->group("groupToModerate",WebGUI::International::get(21,$namespace),[$groupToModerate]);
                $f->integer("messagesPerPage",WebGUI::International::get(4,$namespace),$messagesPerPage);
                $f->integer("editTimeout",WebGUI::International::get(5,$namespace),$editTimeout);
		$output .= $_[0]->SUPER::www_edit($f->printRowsOnly);
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_editSave {
        if (WebGUI::Privilege::canEditPage()) {	
		$_[0]->SUPER::www_editSave();
                $_[0]->set({
			messagesPerPage=>$session{form}{messagesPerPage},
			groupToPost=>$session{form}{groupToPost},
			editTimeout=>$session{form}{editTimeout},
			groupToModerate=>$session{form}{groupToModerate}
			});
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_editMessage {
	if (_canEditMessage($_[0],$session{form}{mid})) {
		return WebGUI::Discussion::editMessage();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_editMessageSave {
	if (_canEditMessage($_[0],$session{form}{mid})) {
		WebGUI::Discussion::editMessageSave();
		return $_[0]->www_showMessage();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_postNewMessage {
	if (WebGUI::Privilege::isInGroup($_[0]->get("groupToPost"),$session{user}{userId})) {
		return WebGUI::Discussion::postNewMessage();
	} else {
		return WebGUI::Privilege::insufficient();
	}	
}

#-------------------------------------------------------------------
sub www_postNewMessageSave {
	if (WebGUI::Privilege::isInGroup($_[0]->get("groupToPost"),$session{user}{userId})) {
		return WebGUI::Discussion::postNewMessageSave();
	} else {
		return WebGUI::Privilege::insufficient();
	}	
}

#-------------------------------------------------------------------
sub www_postReply {
	if (WebGUI::Privilege::isInGroup($_[0]->get("groupToPost"),$session{user}{userId})) {
		return WebGUI::Discussion::postReply();
	} else {
		return WebGUI::Privilege::insufficient();
	}	
}

#-------------------------------------------------------------------
sub www_postReplySave {
	if (WebGUI::Privilege::isInGroup($_[0]->get("groupToPost"),$session{user}{userId})) {
		WebGUI::Discussion::postReplySave();
		return $_[0]->www_showMessage();
	} else {
		return WebGUI::Privilege::insufficient();
	}	
}

#-------------------------------------------------------------------
sub www_showMessage {
	my (@data, $html, %message);
	tie %message, 'Tie::CPHash';
	%message = WebGUI::Discussion::getMessage($session{form}{mid});
	if ($message{messageId}) {
		$html .= '<h1>'.$message{subject}.'</h1>';
		$html .= '<table width="100%" cellpadding=3 cellspacing=1 border=0><tr><td class="tableHeader">';
        	$html .= '<b>'.WebGUI::International::get(7,$namespace).'</b> <a href="'.
			WebGUI::URL::page('op=viewProfile&uid='.$message{userId}).'">'.$message{username}.'</a><br>';
        	$html .= "<b>".WebGUI::International::get(8,$namespace)."</b> ".
			epochToHuman($message{dateOfPost},"%z %Z")."<br>";
        	$html .= "<b>".WebGUI::International::get(9,$namespace)."</b> ".
			$message{wobjectId}."-".$message{rid}."-".$message{pid}."-".$message{messageId}."<br>";
        	$html .= '</td>';
		$html .= '<td rowspan=2 valign="top" class="tableMenu" nowrap>';
		$html .= '<a href="'.WebGUI::URL::page('func=postReply&mid='.$session{form}{mid}.
			'&wid='.$session{form}{wid})
			.'">'.WebGUI::International::get(13,$namespace).'</a><br>';
       	 	if (_canEditMessage($_[0],$session{form}{mid})) {
			$html .= '<a href="'.WebGUI::URL::page('func=editMessage&mid='.$session{form}{mid}.
				'&wid='.$session{form}{wid}).'">'.WebGUI::International::get(12,$namespace).'</a><br>';
                	$html .= '<a href="'.WebGUI::URL::page('func=deleteMessage&mid='.$session{form}{mid}.
                        	'&wid='.$session{form}{wid}).'">'.WebGUI::International::get(22,$namespace).'</a><br>';
		}
        	$html .= '<a href="'.WebGUI::URL::page().'">'.WebGUI::International::get(11,$namespace).'</a><br>';
		@data = WebGUI::SQL->quickArray("select max(messageId) from discussion where wobjectId=$message{wobjectId} and pid=0 and messageId<$message{rid}");
        	if ($data[0] ne "") {
                $html .= '<a href="'.WebGUI::URL::page('func=showMessage&mid='.$data[0].'&wid='.
			$session{form}{wid}).'">&laquo; '.WebGUI::International::get(10,$namespace).'</a><br>';
        	}
        	@data = WebGUI::SQL->quickArray("select min(messageId) from discussion where wobjectId=$message{wobjectId} and pid=0 and messageId>$message{rid}");
        	if ($data[0] ne "") {
                	$html .= '<a href="'.WebGUI::URL::page('func=showMessage&mid='.$data[0].'&wid='.
			$session{form}{wid}).'">'.WebGUI::International::get(14,$namespace).' &raquo;</a><br>';
        	}
		$html .= '</tr><tr><td class="tableData">';
		$html .= $message{message};
		$html .= '</td></tr></table>';
		$html .= '<table border=0 cellpadding=2 cellspacing=1 width="100%">';
		$html .= '<tr><td class="tableHeader">'.WebGUI::International::get(229).
			'</td><td class="tableHeader">'.WebGUI::International::get(15,$namespace).
			'</td><td class="tableHeader">'.WebGUI::International::get(16,$namespace).'</td></tr>';
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
		$html .= WebGUI::Discussion::traverseReplyTree($message{rid},1);
		$html .= "</table>";
	} else { 
		$html = WebGUI::International::get(402);
	}
	return $html;
}

#-------------------------------------------------------------------
sub www_view {
	my ($sth, @data, $html, $i, $pn, $lastId, @last, $replies);
        if ($session{form}{pn} < 1) {
                $pn = 0;
        } else {
                $pn = $session{form}{pn};
        }
	$html = $_[0]->displayTitle;
        $html .= $_[0]->description;
	$html = $_[0]->processMacros($html);
	$html .= '<table width="100%" cellpadding=2 cellspacing=1 border=0><tr>'.
		'<td align="right" valign="bottom" class="tableMenu"><a href="'.
		WebGUI::URL::page('func=postNewMessage&wid='.$_[0]->get("wobjectId")).'">'.
		WebGUI::International::get(17,$namespace).'</a></td></tr></table>';
	$html .= '<table border=0 cellpadding=2 cellspacing=1 width="100%">';
	$html .= '<tr><td class="tableHeader">'.WebGUI::International::get(229).'</td>
		<td class="tableHeader">'.WebGUI::International::get(15,$namespace).'</td>
		<td class="tableHeader">'.WebGUI::International::get(18,$namespace).'</td>
		<td class="tableHeader">'.WebGUI::International::get(19,$namespace).'</td>
		<td class="tableHeader">'.WebGUI::International::get(20,$namespace).'</td></tr>';
	$sth = WebGUI::SQL->read("select messageId,subject,username,dateOfPost,userId 
		from discussion where wobjectId=".$_[0]->get("wobjectId")." and pid=0 order by messageId desc");
	while (@data = $sth->array) {
		$data[1] = WebGUI::HTML::filter($data[1],'all');
		if ($i >= ($_[0]->get("messagesPerPage")*$pn) && $i < ($_[0]->get("messagesPerPage")*($pn+1))) {
			@last = WebGUI::SQL->quickArray("select messageId,dateOfPost,username,subject,userId 
				from discussion where wobjectId=".$_[0]->get("wobjectId")." and rid=$data[0] order by dateOfPost desc");
			$last[3] = WebGUI::HTML::filter($last[3],'all');
			($replies) = WebGUI::SQL->quickArray("select count(*) from discussion where rid=$data[0]");
			$replies -= 1;
			$html .= '<tr><td class="tableData"><a 
				href="'.WebGUI::URL::page('func=showMessage&mid='.$data[0].'&wid='.$_[0]->get("wobjectId"))
				.'">'.substr($data[1],0,30).'</a></td>
				<td class="tableData"><a href="'.WebGUI::URL::page('op=viewProfile&uid='.$data[4]).'">'.$data[2].'</a></td>
				<td class="tableData">'.epochToHuman($data[3],"%z %Z").'</td>
				<td class="tableData">'.$replies.'</td>
				<td class="tableData"><span style="font-size: 8pt;"><a 
				href="'.WebGUI::URL::page('func=showMessage&mid='.$last[0].'&wid='.$_[0]->get("wobjectId")).'">'.substr($last[3],0,30).'</a> 
				@ '.epochToHuman($last[1],"%z %Z").' by <a href="'.WebGUI::URL::page('op=viewProfile&uid='.$last[4]).'">'.$last[2].'</a>
				</span></td></tr>';
		}
       		$i++;
        }
        $html .= '</table>';
	if ($i > $_[0]->get("messagesPerPage")) {
        	$html .= '<div class="pagination">';
        	if ($pn > 0) {
                	$html .= '<a href="'.WebGUI::URL::page('pn='.($pn-1)).'">&laquo;'.
				WebGUI::International::get(91).'</a>';
        	} else {
                	$html .= '&laquo;'.WebGUI::International::get(91);
        	}
        	$html .= ' &middot; ';
        	if (($pn+1) < round(($i/$_[0]->get("messagesPerPage")))) {
        		$html .= '<a href="'.WebGUI::URL::page('pn='.($pn+1)).'">'.
				WebGUI::International::get(92).'&raquo;</a>';
        	} else {
        		$html .= WebGUI::International::get(92).'&raquo;';
        	}
        	$html .= '</div>';
	}
	return $html;
}

1;

