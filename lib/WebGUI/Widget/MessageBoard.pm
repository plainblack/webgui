package WebGUI::Widget::MessageBoard;

our $namespace = "MessageBoard";

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
use WebGUI::International;
use WebGUI::Macro;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::Shortcut;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::Utility;
use WebGUI::Widget;

#-------------------------------------------------------------------
sub duplicate {
        my (%data, $newWidgetId, $pageId);
        tie %data, 'Tie::CPHash';
        %data = getProperties($namespace,$_[0]);
	$pageId = $_[1] || $data{pageId};
        $newWidgetId = create($pageId,$namespace,$data{title},$data{displayTitle},
		$data{description},$data{processMacros},$data{templatePosition});
	WebGUI::SQL->write("insert into MessageBoard values ($newWidgetId, $data{groupToPost}, '$data{messagesPerPage}', '$data{editTimeout}')");
	WebGUI::Discussion::duplicate($_[0],$newWidgetId);
}

#-------------------------------------------------------------------
sub purge {
        purgeWidget($_[0],$_[1],$namespace);
	WebGUI::Discussion::purgeWidget($_[0],$_[1]);
}

#-------------------------------------------------------------------
sub widgetName {
        return WebGUI::International::get(2,$namespace);
}

#-------------------------------------------------------------------
sub www_add {
        my ($output, %hash, @array);
	tie %hash, "Tie::IxHash";
      	if (WebGUI::Privilege::canEditPage()) {
                $output = helpLink(1,$namespace);
		$output .= '<h1>'.WebGUI::International::get(1,$namespace).'</h1>';
		$output .= formHeader();
                $output .= WebGUI::Form::hidden("widget",$namespace);
                $output .= WebGUI::Form::hidden("func","addSave");
                $output .= '<table>';
                $output .= tableFormRow(WebGUI::International::get(99),
			WebGUI::Form::text("title",20,128,'Message Board'));
                $output .= tableFormRow(WebGUI::International::get(174),WebGUI::Form::checkbox("displayTitle",1,1));
                $output .= tableFormRow(WebGUI::International::get(175),WebGUI::Form::checkbox("processMacros",1));
		%hash = WebGUI::Widget::getPositions();
                $output .= tableFormRow(WebGUI::International::get(363),
			WebGUI::Form::selectList("templatePosition",\%hash));
		$output .= tableFormRow(WebGUI::International::get(85),
			WebGUI::Form::textArea("description",'',50,5,1));
                $output .= tableFormRow(WebGUI::International::get(3,$namespace),
			WebGUI::Form::groupList("groupToPost",2));
                $output .= tableFormRow(WebGUI::International::get(21,$namespace),
                        WebGUI::Form::groupList("groupToModerate",4));
                $output .= tableFormRow(WebGUI::International::get(4,$namespace),
			WebGUI::Form::text("messagesPerPage",20,2,30));
                $output .= tableFormRow(WebGUI::International::get(5,$namespace),
			WebGUI::Form::text("editTimeout",20,3,1));
                $output .= formSave();
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
		$widgetId = create($session{page}{pageId},$session{form}{widget},$session{form}{title},$session{form}{displayTitle},$session{form}{description},$session{form}{processMacros},$session{form}{templatePosition});
		WebGUI::SQL->write("insert into MessageBoard values ($widgetId, $session{form}{groupToPost}, '$session{form}{messagesPerPage}', '$session{form}{editTimeout}', $session{form}{groupToModerate})");
		return "";
	} else {
		return WebGUI::Privilege::insufficient();
	}
}

#-------------------------------------------------------------------
sub www_copy {
        if (WebGUI::Privilege::canEditPage()) {
                duplicate($session{form}{wid});
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteMessage {
        my (%board, %message);
        tie %board, 'Tie::CPHash';
        tie %message, 'Tie::CPHash';
        %board = getProperties($namespace,$session{form}{wid});
        %message = WebGUI::Discussion::getMessage($session{form}{mid});
        if ((time()-$message{dateOfPost}) < 3600*$board{editTimeout} && $message{userId} eq $session{user}{userId} ||
                WebGUI::Privilege::isInGroup($board{groupToModerate})) {
                return WebGUI::Discussion::deleteMessage();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteMessageConfirm {
        my (%board,%message);
        tie %board, 'Tie::CPHash';
        tie %message, 'Tie::CPHash';
        %board = getProperties($namespace,$session{form}{wid});
        %message = WebGUI::Discussion::getMessage($session{form}{mid});
        if ((time()-$message{dateOfPost}) < 3600*$board{editTimeout} && $message{userId} eq $session{user}{userId} ||
                WebGUI::Privilege::isInGroup($board{groupToModerate})) {
                return WebGUI::Discussion::deleteMessageConfirm();
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
		%board = getProperties($namespace,$session{form}{wid});
                $output = helpLink(1,$namespace);
		$output .= '<h1>'.WebGUI::International::get(6,$namespace).'</h1>';
		$output .= formHeader();
                $output .= WebGUI::Form::hidden("wid",$session{form}{wid});
                $output .= WebGUI::Form::hidden("func","editSave");
                $output .= '<table>';
                $output .= tableFormRow(WebGUI::International::get(99),
			WebGUI::Form::text("title",20,128,$board{title}));
                $output .= tableFormRow(WebGUI::International::get(174),
			WebGUI::Form::checkbox("displayTitle","1",$board{displayTitle}));
                $output .= tableFormRow(WebGUI::International::get(175),
			WebGUI::Form::checkbox("processMacros","1",$board{processMacros}));
		%hash = WebGUI::Widget::getPositions();
                $array[0] = $board{templatePosition};
                $output .= tableFormRow(WebGUI::International::get(363),
			WebGUI::Form::selectList("templatePosition",\%hash,\@array));
		$output .= tableFormRow(WebGUI::International::get(85),
			WebGUI::Form::textArea("description",$board{description},50,5,1));
                $output .= tableFormRow(WebGUI::International::get(3,$namespace),
			WebGUI::Form::groupList("groupToPost",$board{groupToPost}));
                $output .= tableFormRow(WebGUI::International::get(21,$namespace),
                        WebGUI::Form::groupList("groupToModerate",$board{groupToModerate}));
                $output .= tableFormRow(WebGUI::International::get(4,$namespace),
			WebGUI::Form::text("messagesPerPage",20,2,$board{messagesPerPage}));
                $output .= tableFormRow(WebGUI::International::get(5,$namespace),
			WebGUI::Form::text("editTimeout",20,2,$board{editTimeout}));
                $output .= formSave();
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
                WebGUI::SQL->write("update MessageBoard set groupToPost=$session{form}{groupToPost}, messagesPerPage=$session{form}{messagesPerPage}, editTimeout=$session{form}{editTimeout}, groupToModerate=$session{form}{groupToModerate} where widgetId=$session{form}{wid}");
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_editMessage {
        my (%board,%message);
	tie %board, 'Tie::CPHash';
	tie %message, 'Tie::CPHash';
        %board = getProperties($namespace,$session{form}{wid}); 
        %message = WebGUI::Discussion::getMessage($session{form}{mid}); 
        if ((time()-$message{dateOfPost}) < 3600*$board{editTimeout} && $message{userId} eq $session{user}{userId} ||
		WebGUI::Privilege::isInGroup($board{groupToModerate})) {
		return WebGUI::Discussion::editMessage();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_editMessageSave {
        my (%board,%message);
	tie %board, 'Tie::CPHash';
	tie %message, 'Tie::CPHash';
        %board = getProperties($namespace,$session{form}{wid}); 
        %message = WebGUI::Discussion::getMessage($session{form}{mid}); 
        if ((time()-$message{dateOfPost}) < 3600*$board{editTimeout} && $message{userId} eq $session{user}{userId} ||
                WebGUI::Privilege::isInGroup($board{groupToModerate})) {
		WebGUI::Discussion::editMessageSave();
		return www_showMessage();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_postNewMessage {
	my (%board);
	tie %board, 'Tie::CPHash';
	%board = getProperties($namespace,$session{form}{wid}); 
	if (WebGUI::Privilege::isInGroup($board{groupToPost},$session{user}{userId})) {
		return WebGUI::Discussion::postNewMessage();
	} else {
		return WebGUI::Privilege::insufficient();
	}	
}

#-------------------------------------------------------------------
sub www_postNewMessageSave {
	my (%board);
	tie %board, 'Tie::CPHash';
	%board = getProperties($namespace,$session{form}{wid}); 
	if (WebGUI::Privilege::isInGroup($board{groupToPost},$session{user}{userId})) {
		return WebGUI::Discussion::postNewMessageSave();
	} else {
		return WebGUI::Privilege::insufficient();
	}	
}

#-------------------------------------------------------------------
sub www_postReply {
	my (%board);
	tie %board, 'Tie::CPHash';
	%board = getProperties($namespace,$session{form}{wid}); 
	if (WebGUI::Privilege::isInGroup($board{groupToPost},$session{user}{userId})) {
		return WebGUI::Discussion::postReply();
	} else {
		return WebGUI::Privilege::insufficient();
	}	
}

#-------------------------------------------------------------------
sub www_postReplySave {
	my (%board);
	tie %board, 'Tie::CPHash';
	%board = getProperties($namespace,$session{form}{wid});
	if (WebGUI::Privilege::isInGroup($board{groupToPost},$session{user}{userId})) {
		WebGUI::Discussion::postReplySave();
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
	%message = WebGUI::Discussion::getMessage($session{form}{mid});
	%board = getProperties($namespace,$session{form}{wid}); 
	if ($message{messageId}) {
		$html .= '<h1>'.$message{subject}.'</h1>';
		$html .= '<table width="100%" cellpadding=3 cellspacing=1 border=0><tr><td class="tableHeader">';
        	$html .= '<b>'.WebGUI::International::get(7,$namespace).'</b> <a href="'.
			WebGUI::URL::page('op=viewProfile&uid='.$message{userId}).'">'.$message{username}.'</a><br>';
        	$html .= "<b>".WebGUI::International::get(8,$namespace)."</b> ".
			epochToHuman($message{dateOfPost},"%w, %c %D, %y at %H:%n%p")."<br>";
        	$html .= "<b>".WebGUI::International::get(9,$namespace)."</b> ".
			$message{widgetId}."-".$message{rid}."-".$message{pid}."-".$message{messageId}."<br>";
        	$html .= '</td>';
		$html .= '<td rowspan=2 valign="top" class="tableMenu" nowrap>';
		$html .= '<a href="'.WebGUI::URL::page('func=postReply&mid='.$session{form}{mid}.
			'&wid='.$session{form}{wid})
			.'">'.WebGUI::International::get(13,$namespace).'</a><br>';
       	 	if ((time()-$message{dateOfPost}) < 3600*$board{editTimeout} && 
			$message{userId} eq $session{user}{userId} ||
                	WebGUI::Privilege::isInGroup($board{groupToModerate})) {
			$html .= '<a href="'.WebGUI::URL::page('func=editMessage&mid='.$session{form}{mid}.
				'&wid='.$session{form}{wid}).'">'.WebGUI::International::get(12,$namespace).'</a><br>';
                	$html .= '<a href="'.WebGUI::URL::page('func=deleteMessage&mid='.$session{form}{mid}.
                        	'&wid='.$session{form}{wid}).'">'.WebGUI::International::get(22,$namespace).'</a><br>';
		}
        	$html .= '<a href="'.WebGUI::URL::page().'">'.WebGUI::International::get(11,$namespace).'</a><br>';
		@data = WebGUI::SQL->quickArray("select max(messageId) from discussion where widgetId=$message{widgetId} and pid=0 and messageId<$message{rid}");
        	if ($data[0] ne "") {
                $html .= '<a href="'.WebGUI::URL::page('func=showMessage&mid='.$data[0].'&wid='.
			$session{form}{wid}).'">&laquo; '.WebGUI::International::get(10,$namespace).'</a><br>';
        	}
        	@data = WebGUI::SQL->quickArray("select min(messageId) from discussion where widgetId=$message{widgetId} and pid=0 and messageId>$message{rid}");
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
			$message{widgetId}).'">'.substr($data[1],0,30).'</a></td><td class="tableData"><a href="'.
			WebGUI::URL::page('op=viewProfile&uid='.$data[4]).'">'.$data[2].
			'</a></td><td class="tableData">'.
			epochToHuman($data[3],"%M/%D %H:%n%p").'</td></tr>';
		$html .= WebGUI::Discussion::traverseReplyTree($message{rid},1);
		$html .= "</table>";
	} else { 
		$html = WebGUI::International::get(402);
	}
	return $html;
}

#-------------------------------------------------------------------
sub www_view {
	my ($sth, @data, $html, %board, $itemsPerPage, $i, $pn, $lastId, @last, $replies);
	tie %board, 'Tie::CPHash';
	%board = getProperties($namespace,$_[0]);
        $itemsPerPage = $board{messagesPerPage};
        if ($session{form}{pn} < 1) {
                $pn = 0;
        } else {
                $pn = $session{form}{pn};
        }
        if ($board{displayTitle}) {
                $html = '<h1>'.$board{title}.'</h1>';
        }
	if ($board{description} ne "") {
		$html .= $board{description}.'<p>';
	}
	if ($board{processMacros}) {
		$html = WebGUI::Macro::process($html);
	}
	$html .= '<table width="100%" cellpadding=2 cellspacing=1 border=0><tr>'.
		'<td align="right" valign="bottom" class="tableMenu"><a href="'.
		WebGUI::URL::page('func=postNewMessage&wid='.$_[0]).'">'.
		WebGUI::International::get(17,$namespace).'</a></td></tr></table>';
	$html .= '<table border=0 cellpadding=2 cellspacing=1 width="100%">';
	$html .= '<tr><td class="tableHeader">'.WebGUI::International::get(229).'</td><td class="tableHeader">'.WebGUI::International::get(15,$namespace).'</td><td class="tableHeader">'.WebGUI::International::get(18,$namespace).'</td><td class="tableHeader">'.WebGUI::International::get(19,$namespace).'</td><td class="tableHeader">'.WebGUI::International::get(20,$namespace).'</td></tr>';
	#$sth = WebGUI::SQL->read("select messageId,subject,count(*)-1,username,dateOfPost,max(dateOfPost),max(messageId) from discussion where widgetId=$_[0] group by rid order by messageId desc");
	$sth = WebGUI::SQL->read("select messageId,subject,username,dateOfPost,userId from discussion where widgetId=$_[0] and pid=0 order by messageId desc");
	while (@data = $sth->array) {
		$data[1] = WebGUI::HTML::filter($data[1],'all');
		if ($i >= ($itemsPerPage*$pn) && $i < ($itemsPerPage*($pn+1))) {
			@last = WebGUI::SQL->quickArray("select messageId,dateOfPost,username,subject,userId from discussion where widgetId=$_[0] and rid=$data[0] order by dateOfPost desc");
			$last[3] = WebGUI::HTML::filter($last[3],'all');
			($replies) = WebGUI::SQL->quickArray("select count(*)-1 from discussion where rid=$data[0]");
			$html .= '<tr><td class="tableData"><a href="'.WebGUI::URL::page('func=showMessage&mid='.
				$data[0].'&wid='.$_[0]).'">'.substr($data[1],0,30).
				'</a></td><td class="tableData"><a href="'.
				WebGUI::URL::page('op=viewProfile&uid='.$data[4]).'">'.$data[2].
				'</a></td><td class="tableData">'.epochToHuman($data[3],"%M/%D %H:%n%p").
				'</td><td class="tableData">'.$replies.
				'</td><td class="tableData"><span style="font-size: 8pt;"><a href="'.
				WebGUI::URL::page('func=showMessage&mid='.$last[0].'&wid='.$_[0]).'">'.
				substr($last[3],0,30).'</a> @ '.epochToHuman($last[1],"%M/%D %H:%n%p").
				' by <a href="'.WebGUI::URL::page('op=viewProfile&uid='.$last[4]).'">'.$last[2].
				'</a></span></td></tr>';
		}
       		$i++;
        }
        $html .= '</table>';
	if ($i > $itemsPerPage) {
        	$html .= '<div class="pagination">';
        	if ($pn > 0) {
                	$html .= '<a href="'.WebGUI::URL::page('pn='.($pn-1)).'">&laquo;'.
				WebGUI::International::get(91).'</a>';
        	} else {
                	$html .= '&laquo;'.WebGUI::International::get(91);
        	}
        	$html .= ' &middot; ';
        	if (($pn+1) < round(($i/$itemsPerPage))) {
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
