package WebGUI::Widget::Article;

our $namespace = "Article";

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
use WebGUI::Attachment;
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
use WebGUI::Widget;

#-------------------------------------------------------------------
sub _showReplies {
        my ($sth, @data, $html, %board);
        tie %board, 'Tie::CPHash';
        %board = getProperties($namespace,$session{form}{wid});
        $html .= '<table border=0 cellpadding=2 cellspacing=1 width="100%">';
        $html .= '<tr><td class="tableHeader">'.WebGUI::International::get(229).'</td><td class="tableHeader">'.WebGUI::International::get(22,$namespace).'</td><td class="tableHeader">'.WebGUI::International::get(23,$namespace).'</td></tr>';
        $sth = WebGUI::SQL->read("select messageId,subject,username,dateOfPost,userId from discussion where widgetId=$session{form}{wid} and pid=0 order by messageId desc");
        while (@data = $sth->array) {
		$data[1] = WebGUI::HTML::filter($data[1],'all');
                $html .= '<tr';
		if ($data[0] == $session{form}{mid}) {
			$html .= ' class="highlight"';
		}
		$html .= '><td class="tableData"><a href="'.WebGUI::URL::page('func=showMessage&mid='.
                                $data[0].'&wid='.$session{form}{wid}).'">'.substr($data[1],0,30).
                                '</a></td><td class="tableData"><a href="'.
                                WebGUI::URL::page('op=viewProfile&uid='.$data[4]).'">'.$data[2].
                                '</a></td><td class="tableData">'.epochToHuman($data[3],"%M/%D %H:%n%p").
                                '</td></tr>';
                $html .= WebGUI::Discussion::traverseReplyTree($data[0],1);
        }
        $html .= '</table>';
        return $html;
}

#-------------------------------------------------------------------
sub duplicate {
	my (%data, $newWidgetId, $pageId, $file);
	tie %data, 'Tie::CPHash';
	%data = getProperties($namespace,$_[0]);
	$pageId = $_[1] || $data{pageId};
	$newWidgetId = create($pageId,$namespace,$data{title},$data{displayTitle},
		$data{description},$data{processMacros},$data{templatePosition});
	$file = WebGUI::Attachment->new($data{image},$_[0]);
	$file->copy($newWidgetId);
        $file = WebGUI::Attachment->new($data{attachment},$_[0]);
        $file->copy($newWidgetId);
	WebGUI::SQL->write("insert into Article values ($newWidgetId, $data{startDate}, $data{endDate}, ".
		quote($data{body}).", ".quote($data{image}).", ".quote($data{linkTitle}).", ".
		quote($data{linkURL}).", ".quote($data{attachment}).", '$data{convertCarriageReturns}', ".
		quote($data{alignImage}).", '$data{allowDiscussion}', $data{groupToPost}, $data{groupToModerate}, $data{editTimeout})");
	WebGUI::Discussion::duplicate($_[0],$newWidgetId);
}

#-------------------------------------------------------------------
sub purge {
	purgeWidget($_[0],$_[1],$namespace);
	WebGUI::Discussion::purgeWidget($_[0],$_[1]);
}

#-------------------------------------------------------------------
sub widgetName {
	return WebGUI::International::get(1,$namespace);
}

#-------------------------------------------------------------------
sub www_add {
        my ($output, %hash, @array);
	tie %hash, "Tie::IxHash";
      	if (WebGUI::Privilege::canEditPage()) {
                $output = helpLink(1,$namespace);
		$output .= '<h1>'.WebGUI::International::get(2,$namespace).'</h1>';
		$output .= formHeader();
                $output .= WebGUI::Form::hidden("widget",$namespace);
                $output .= WebGUI::Form::hidden("func","addSave");
                $output .= '<table>';
                $output .= tableFormRow(WebGUI::International::get(99),WebGUI::Form::text("title",20,128,'Article'));
                $output .= tableFormRow(WebGUI::International::get(174),WebGUI::Form::checkbox("displayTitle",1,1));
                $output .= tableFormRow(WebGUI::International::get(175),WebGUI::Form::checkbox("processMacros",1,1));
		%hash = WebGUI::Widget::getPositions();
                $output .= tableFormRow(WebGUI::International::get(363),WebGUI::Form::selectList("templatePosition",\%hash));
                $output .= tableFormRow(WebGUI::International::get(3,$namespace),WebGUI::Form::text("startDate",20,30,epochToSet(time()),1));
                $output .= tableFormRow(WebGUI::International::get(4,$namespace),WebGUI::Form::text("endDate",20,30,'01/01/2037',1));
                $output .= tableFormRow(WebGUI::International::get(5,$namespace),WebGUI::Form::textArea("body",'',50,10,1));
                $output .= tableFormRow(WebGUI::International::get(6,$namespace),WebGUI::Form::file("image"));
		%hash = (
			right => WebGUI::International::get(15,$namespace),
			left => WebGUI::International::get(16,$namespace),
			center => WebGUI::International::get(17,$namespace)
			);
		$array[0] = "right";
                $output .= tableFormRow(WebGUI::International::get(14,$namespace),
			WebGUI::Form::selectList("alignImage",\%hash,\@array));
                $output .= tableFormRow(WebGUI::International::get(7,$namespace),WebGUI::Form::text("linkTitle",20,128));
                $output .= tableFormRow(WebGUI::International::get(8,$namespace),WebGUI::Form::text("linkURL",20,2048));
                $output .= tableFormRow(WebGUI::International::get(9,$namespace),WebGUI::Form::file("attachment"));
		$output .= tableFormRow(WebGUI::International::get(10,$namespace),WebGUI::Form::checkbox("convertCarriageReturns",1).' <span style="font-size: 8pt;">'.WebGUI::International::get(11,$namespace).'</span>');
                $output .= tableFormRow(WebGUI::International::get(18,$namespace),
			WebGUI::Form::checkbox("allowDiscussion",1));
                $output .= tableFormRow(WebGUI::International::get(19,$namespace),
                        WebGUI::Form::groupList("groupToPost",2));
                $output .= tableFormRow(WebGUI::International::get(20,$namespace),
                        WebGUI::Form::groupList("groupToModerate",4));
                $output .= tableFormRow(WebGUI::International::get(21,$namespace),
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
	my ($widgetId, $image, $attachment);
	if (WebGUI::Privilege::canEditPage()) {
		$widgetId = create($session{page}{pageId},$session{form}{widget},
			$session{form}{title},$session{form}{displayTitle},
			$session{form}{description},$session{form}{processMacros},
			$session{form}{templatePosition});
		$image = WebGUI::Attachment->new("",$widgetId);
		$image->save("image");
		$attachment = WebGUI::Attachment->new("",$widgetId);
		$attachment->save("attachment");
		WebGUI::SQL->write("insert into Article values ($widgetId, '".
			setToEpoch($session{form}{startDate})."', '".
			setToEpoch($session{form}{endDate})."', ".
			quote($session{form}{body}).", ".
			quote($image->getFilename).", ".
			quote($session{form}{linkTitle}).", ".
			quote($session{form}{linkURL}).", ".
			quote($attachment->getFilename).
			", '$session{form}{convertCarriageReturns}', ".
			quote($session{form}{alignImage}).", ".
			"'$session{form}{allowDiscussion}', ".
			"'$session{form}{groupToPost}', ".
			"'$session{form}{groupToModerate}', ".
			"'$session{form}{editTimeout}' ".
			")");
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
sub www_deleteAttachment {
        if (WebGUI::Privilege::canEditPage()) {
		WebGUI::SQL->write("update Article set attachment='' where widgetId=$session{form}{wid}");
		return www_edit();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteImage {
        if (WebGUI::Privilege::canEditPage()) {
                WebGUI::SQL->write("update Article set image='' where widgetId=$session{form}{wid}");
                return www_edit();
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
        my ($output, %data, %hash, @array);
	tie %hash, 'Tie::IxHash';
	tie %data, 'Tie::CPHash';
        if (WebGUI::Privilege::canEditPage()) {
		%data = getProperties($namespace,$session{form}{wid});
                $output = helpLink(1,$namespace);
		$output .= '<h1>'.WebGUI::International::get(12,$namespace).'</h1>';
		$output .= formHeader();
                $output .= WebGUI::Form::hidden("wid",$session{form}{wid});
                $output .= WebGUI::Form::hidden("func","editSave");
                $output .= '<table>';
                $output .= tableFormRow(WebGUI::International::get(99),
			WebGUI::Form::text("title",20,128,$data{title}));
                $output .= tableFormRow(WebGUI::International::get(174),
			WebGUI::Form::checkbox("displayTitle","1",$data{displayTitle}));
                $output .= tableFormRow(WebGUI::International::get(175),
			WebGUI::Form::checkbox("processMacros","1",$data{processMacros}));
		%hash = WebGUI::Widget::getPositions();
		$array[0] = $data{templatePosition};
                $output .= tableFormRow(WebGUI::International::get(363),
			WebGUI::Form::selectList("templatePosition",\%hash,\@array));
                $output .= tableFormRow(WebGUI::International::get(3,$namespace),
			WebGUI::Form::text("startDate",20,30,epochToSet($data{startDate}),1));
                $output .= tableFormRow(WebGUI::International::get(4,$namespace),
			WebGUI::Form::text("endDate",20,30,epochToSet($data{endDate}),1));
                $output .= tableFormRow(WebGUI::International::get(5,$namespace),
			WebGUI::Form::textArea("body",$data{body},50,10,1));
		if ($data{image} ne "") {
                	$output .= tableFormRow(WebGUI::International::get(6,$namespace),'<a href="'.
				WebGUI::URL::page('func=deleteImage&wid='.$session{form}{wid})
				.'">'.WebGUI::International::get(13,$namespace).'</a>');
		} else {
                	$output .= tableFormRow(WebGUI::International::get(6,$namespace),WebGUI::Form::file("image"));
		}
                %hash = (
                        right => WebGUI::International::get(15,$namespace),
                        left => WebGUI::International::get(16,$namespace),
                        center => WebGUI::International::get(17,$namespace)
                        );
                $array[0] = $data{alignImage};
                $output .= tableFormRow(WebGUI::International::get(14,$namespace),
                        WebGUI::Form::selectList("alignImage",\%hash,\@array));
                $output .= tableFormRow(WebGUI::International::get(7,$namespace),
			WebGUI::Form::text("linkTitle",20,128,$data{linkTitle}));
                $output .= tableFormRow(WebGUI::International::get(8,$namespace),
			WebGUI::Form::text("linkURL",20,2048,$data{linkURL}));
		if ($data{attachment} ne "") {
                	$output .= tableFormRow(WebGUI::International::get(9,$namespace),'<a href="'.
				WebGUI::URL::page('func=deleteAttachment&wid='.$session{form}{wid})
				.'">'.WebGUI::International::get(13,$namespace).'</a>');
		} else {
                	$output .= tableFormRow(WebGUI::International::get(9,$namespace),
				WebGUI::Form::file("attachment"));
		}
		$output .= tableFormRow(WebGUI::International::get(10,$namespace),
			WebGUI::Form::checkbox("convertCarriageReturns",1,$data{convertCarriageReturns}).
			' <span style="font-size: 8pt;">'.WebGUI::International::get(11,$namespace).'</span>');
                $output .= tableFormRow(WebGUI::International::get(18,$namespace),
                        WebGUI::Form::checkbox("allowDiscussion","1",$data{allowDiscussion}));
                $output .= tableFormRow(WebGUI::International::get(19,$namespace),
                        WebGUI::Form::groupList("groupToPost",$data{groupToPost}));
                $output .= tableFormRow(WebGUI::International::get(20,$namespace),
                        WebGUI::Form::groupList("groupToModerate",$data{groupToModerate}));
                $output .= tableFormRow(WebGUI::International::get(22,$namespace),
                        WebGUI::Form::text("editTimeout",20,2,$data{editTimeout}));
                $output .= formSave();
                $output .= '</table></form>';
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_editSave {
        my ($sqlAdd, $image, $attachment);
        if (WebGUI::Privilege::canEditPage()) {
		update();
                $image = WebGUI::Attachment->new("",$session{form}{wid});
		$image->save("image");
		if ($image->getFilename ne "") {
			$sqlAdd = ', image='.quote($image->getFilename);
		}
                $attachment = WebGUI::Attachment->new("",$session{form}{wid});
		$attachment->save("attachment");
		if ($attachment->getFilename ne "") {
                        $sqlAdd .= ', attachment='.quote($attachment->getFilename);
                }
                WebGUI::SQL->write("update Article set alignImage=".quote($session{form}{alignImage}).
			", startDate='".setToEpoch($session{form}{startDate}).
			"', endDate='".setToEpoch($session{form}{endDate}).
			"', convertCarriageReturns='$session{form}{convertCarriageReturns}', body=".
			quote($session{form}{body}).", linkTitle=".
			quote($session{form}{linkTitle}).", linkURL=".
			quote($session{form}{linkURL}).", allowDiscussion='$session{form}{allowDiscussion}',".
			"groupToModerate='$session{form}{groupToModerate}', groupToPost='$session{form}{groupToPost}'".
			", editTimeout='$session{form}{editTimeout}'".
			$sqlAdd.
			" where widgetId=$session{form}{wid}");
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
        my (@data, $html, %board, %message, $defaultMid);
        tie %message, 'Tie::CPHash';
        tie %board, 'Tie::CPHash';
	($defaultMid) = WebGUI::SQL->quickArray("select min(messageId) from discussion where widgetId=$session{form}{wid}");
	$session{form}{mid} = $defaultMid if ($session{form}{mid} eq "");
        %message = WebGUI::Discussion::getMessage($session{form}{mid});
        %board = getProperties($namespace,$session{form}{wid});
        if ($message{messageId}) {
                $html .= '<h1>'.$message{subject}.'</h1>';
                $html .= '<table width="100%" cellpadding=3 cellspacing=1 border=0><tr><td class="tableHeader">';
                $html .= '<b>'.WebGUI::International::get(22,$namespace).'</b> <a href="'.
                        WebGUI::URL::page('op=viewProfile&uid='.$message{userId}).'">'.$message{username}.'</a><br>';
                $html .= "<b>".WebGUI::International::get(23,$namespace)."</b> ".
                        epochToHuman($message{dateOfPost},"%w, %c %D, %y at %H:%n%p")."<br>";
                $html .= '</td>';
                $html .= '<td rowspan=2 valign="top" class="tableMenu" nowrap>';
                $html .= '<a href="'.WebGUI::URL::page('func=postReply&mid='.$session{form}{mid}.
                        '&wid='.$session{form}{wid})
                        .'">'.WebGUI::International::get(24,$namespace).'</a><br>';
                if ((time()-$message{dateOfPost}) < 3600*$board{editTimeout} &&
                        $message{userId} eq $session{user}{userId} ||
                        WebGUI::Privilege::isInGroup($board{groupToModerate})) {
                        $html .= '<a href="'.WebGUI::URL::page('func=editMessage&mid='.$session{form}{mid}.
                                '&wid='.$session{form}{wid}).'">'.WebGUI::International::get(25,$namespace).'</a><br>';
                        $html .= '<a href="'.WebGUI::URL::page('func=deleteMessage&mid='.$session{form}{mid}.
                                '&wid='.$session{form}{wid}).'">'.WebGUI::International::get(26,$namespace).'</a><br>';
                }
                $html .= '<a href="'.WebGUI::URL::page().'">'.WebGUI::International::get(27,$namespace).'</a><br>';
                $html .= '</tr><tr><td class="tableData">';
                $html .= $message{message};
                $html .= '</td></tr></table>';
		$html .= _showReplies();
        } else {
                $html = WebGUI::International::get(402);
        }
        return $html;
}

#-------------------------------------------------------------------
sub www_view {
	my (%data, @test, $output, $image, $replies);
	tie %data, 'Tie::CPHash';
	%data = getProperties($namespace,$_[0]);
	if ($data{startDate}<time() && $data{endDate}>time()) {
		$output = "";
		if ($data{image} ne "") { # Images collide on successive articles if there is little text - prevent this.
			$output .= '<table width="100%" border="0" cellpadding="0" cellspacing="0"><tr><td>';
		}
		if ($data{displayTitle} == 1) {
			$output .= "<h1>".$data{title}."</h1>";
		}
		if ($data{image} ne "") {
			$image = WebGUI::Attachment->new($data{image},$_[0]);
			$image = '<img src="'.$image->getURL.'"';
			if ($data{alignImage} ne "center") {
				$image .= ' align="'.$data{alignImage}.'"';
			}
			$image .= ' border="0">';
			if ($data{alignImage} eq "center") {
				$output .= '<div align="center">'.$image.'</div>';
			} else {
				$output .= $image;
			}
		}
		if ($data{convertCarriageReturns}) {
			$data{body} =~ s/\n/\<br\>/g;
		}
		$output .= $data{body};
                if ($data{linkURL} ne "" && $data{linkTitle} ne "") {
                        $output .= '<p><a href="'.$data{linkURL}.'">'.$data{linkTitle}.'</a>';
                }
		if ($data{attachment} ne "") {
			$output .= attachmentBox($data{attachment},$_[0]);
		}
		if ($data{image} ne "") {
			$output .= "</td></tr></table>";
		}
	}
	if ($data{processMacros}) {
		$output = WebGUI::Macro::process($output);
	}
	if ($data{allowDiscussion}) {
		($replies) = WebGUI::SQL->quickArray("select count(*) from discussion where widgetId=$_[0]");
		$output .= '<p><table width="100%" cellspacing="2" cellpadding="1" border="0">';
		$output .= '<tr><td align="center" width="50%" class="tableMenu"><a href="'.
			WebGUI::URL::page('func=showMessage&wid='.$_[0]).'">'.
			WebGUI::International::get(28,$namespace).' ('.$replies.')</a></td>';
		$output .= '<td align="center" width="50%" class="tableMenu"><a href="'.
                	WebGUI::URL::page('func=postNewMessage&wid='.$_[0]).'">'.
                	WebGUI::International::get(24,$namespace).'</a></td></tr>';
		$output .= '</table>';
	}
	return $output;
}

1;

