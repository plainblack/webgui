package WebGUI::Wobject::UserSubmission;

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
use WebGUI::HTMLForm;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::MessageLog;
use WebGUI::Operation;
use WebGUI::Paginator;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::Utility;
use WebGUI::Wobject;

our @ISA = qw(WebGUI::Wobject);
our $namespace = "UserSubmission";
our $name = WebGUI::International::get(29,$namespace);

our %submissionStatus =("Approved"=>WebGUI::International::get(7,$namespace),
	"Denied"=>WebGUI::International::get(8,$namespace),
	"Pending"=>WebGUI::International::get(9,$namespace));

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
sub _showReplies {
        my ($sth, @data, $html);
        $html .= '<table border=0 cellpadding=2 cellspacing=1 width="100%">';
        $html .= '<tr><td class="tableHeader">'.WebGUI::International::get(229).'</td>
		<td class="tableHeader">'.WebGUI::International::get(40,$namespace).'</td>
		<td class="tableHeader">'.WebGUI::International::get(41,$namespace).'</td></tr>';
        $sth = WebGUI::SQL->read("select messageId,subject,username,dateOfPost,userId from discussion 
		where wobjectId=$session{form}{wid} and subId=$session{form}{sid} and pid=0 order by messageId desc");
        while (@data = $sth->array) {
                $data[1] = WebGUI::HTML::filter($data[1],'all');
                $html .= '<tr';
                if ($data[0] == $session{form}{mid}) {
                        $html .= ' class="highlight"';
                }
                $html .= '><td class="tableData"><a href="'.WebGUI::URL::page('func=showMessage&mid='.
                                $data[0].'&wid='.$session{form}{wid}.'&sid='.$session{form}{sid}).'">'.substr($data[1],0,30).
                                '</a></td><td class="tableData"><a href="'.
                                WebGUI::URL::page('op=viewProfile&uid='.$data[4]).'">'.$data[2].
                                '</a></td><td class="tableData">'.epochToHuman($data[3],"%z %Z").
                                '</td></tr>';
                $html .= WebGUI::Discussion::traverseReplyTree($data[0],1);
        }
        $html .= '</table>';
        return $html;
}

#-------------------------------------------------------------------
sub duplicate {
        my ($sth, $file, @row, $newSubmissionId, $w);
	$w = $_[0]->SUPER::duplicate($_[1]);
        $w = WebGUI::Wobject::UserSubmission->new({wobjectId=>$w,namespace=>$namespace});
        $w->set({
		groupToContribute=>$_[0]->get("groupToContribute"),
		submissionsPerPage=>$_[0]->get("submissionsPerPage"),
		defaultStatus=>$_[0]->get("defaultStatus"),
		groupToApprove=>$_[0]->get("groupToApprove"),
		allowDiscussion=>$_[0]->get("allowDiscussion"),
		editTimeout=>$_[0]->get("editTimeout"),
		groupToPost=>$_[0]->get("groupToPost"),
		displayThumbnails=>$_[0]->get("displayThumbnails"),
		groupToModerate=>$_[0]->get("groupToModerate")
		});
        $sth = WebGUI::SQL->read("select * from UserSubmission_submission where wobjectId=".$_[0]->get("wobjectId"));
        while (@row = $sth->array) {
                $newSubmissionId = getNextId("submissionId");
		$file = WebGUI::Attachment->new($row[8],$_[0]->get("wobjectId"),$row[1]);
		$file->copy($w->get("wobjectId"),$newSubmissionId);
                WebGUI::SQL->write("insert into UserSubmission_submission values (".$w->get("wobjectId").", $newSubmissionId, ".
			quote($row[2]).", $row[3], ".quote($row[4]).", '$row[5]', ".quote($row[6]).", ".
			quote($row[7]).", ".quote($row[8]).", '$row[9]', '$row[10]')");
        }
        $sth->finish;
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
        WebGUI::SQL->write("delete from UserSubmission_submission where wobjectId=".$_[0]->get("wobjectId"));
	$_[0]->SUPER::purge();
}

#-------------------------------------------------------------------
sub set {
        $_[0]->SUPER::set($_[1],[qw(submissionsPerPage groupToContribute groupToApprove defaultStatus groupToModerate 
		groupToPost displayThumbnails editTimeout allowDiscussion)]);
}

#-------------------------------------------------------------------
sub www_approveSubmission {
	my (%submission);
	tie %submission, 'Tie::CPHash';
        if (WebGUI::Privilege::isInGroup(4,$session{user}{userId}) || WebGUI::Privilege::isInGroup(3,$session{user}{userId})) {
		%submission = WebGUI::SQL->quickHash("select * from UserSubmission_submission where submissionId=$session{form}{sid}");
                WebGUI::SQL->write("update UserSubmission_submission set status='Approved' where submissionId=$session{form}{sid}");
		WebGUI::MessageLog::addEntry($submission{userId},'',WebGUI::URL::page('func=viewSubmission&wid='.
			$session{form}{wid}.'&sid='.$session{form}{sid}),4,$namespace);
		WebGUI::MessageLog::completeEntry($session{form}{mlog});
                return WebGUI::Operation::www_viewMessageLog();
        } else {
                return WebGUI::Privilege::insufficient();
        }
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
sub www_deleteAttachment {
	my ($owner);
	($owner) = WebGUI::SQL->quickArray("select userId from UserSubmission_submission where submissionId=$session{form}{sid}");
        if ($owner == $session{user}{userId}) {
                WebGUI::SQL->write("update UserSubmission_submission set attachment='' where submissionId=$session{form}{sid}");
                return $_[0]->www_editSubmission();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteImage {
	my ($owner);
	($owner) = WebGUI::SQL->quickArray("select userId from UserSubmission_submission where submissionId=$session{form}{sid}");
        if ($owner == $session{user}{userId}) {
                WebGUI::SQL->write("update UserSubmission_submission set image='' where submissionId=$session{form}{sid}");
                return $_[0]->www_editSubmission();
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
sub www_deleteSubmission {
	my ($output, $owner);
	($owner) = WebGUI::SQL->quickArray("select userId from UserSubmission_submission where submissionId=$session{form}{sid}");
        if ($owner == $session{user}{userId}) {
		$output = '<h1>'.WebGUI::International::get(42).'</h1>';
		$output .= WebGUI::International::get(17,$namespace).'<p>';
		$output .= '<div align="center"><a href="'.WebGUI::URL::page('func=deleteSubmissionConfirm&wid='.
			$session{form}{wid}.'&sid='.$session{form}{sid}).'">'.WebGUI::International::get(44).'</a>';
		$output .= ' &nbsp; <a href="'.WebGUI::URL::page().'">'.WebGUI::International::get(45).'</a></div>';
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteSubmissionConfirm {
        my ($output, $owner, $file);
	($owner) = WebGUI::SQL->quickArray("select userId from UserSubmission_submission where submissionId=$session{form}{sid}");
        if ($owner == $session{user}{userId}) {
		WebGUI::SQL->write("delete from UserSubmission_submission where submissionId=$session{form}{sid}");
		$file = WebGUI::Attachment->new("",$session{form}{wid},$session{form}{sid});
		$file->deleteNode;
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_denySubmission {
	my (%submission);
	tie %submission, 'Tie::CPHash';
        if (WebGUI::Privilege::isInGroup(4,$session{user}{userId}) || WebGUI::Privilege::isInGroup(3,$session{user}{userId})) {
		%submission = WebGUI::SQL->quickHash("select * from UserSubmission_submission where submissionId=$session{form}{sid}");
                WebGUI::SQL->write("update UserSubmission_submission set status='Denied' where submissionId=$session{form}{sid}");
                WebGUI::MessageLog::addEntry($submission{userId},'',WebGUI::URL::page('func=viewSubmission&wid='.
			$session{form}{wid}.'&sid='.$session{form}{sid}),5,$namespace);
                WebGUI::MessageLog::completeEntry($session{form}{mlog});
                return WebGUI::Operation::www_viewMessageLog();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_edit {
        my ($output, $f, $defaultStatus, $submissionsPerPage, $groupToApprove, $groupToModerate);
	$groupToApprove = $_[0]->get("groupToApprove") || 4;
	$groupToModerate = $_[0]->get("groupToModerate") || 4;
	$submissionsPerPage = $_[0]->get("submissionsPerPage") || 50;
	$defaultStatus = $_[0]->get("defaultStatus") || "Approved";
        if (WebGUI::Privilege::canEditPage()) {
                $output = helpIcon(1,$namespace);
		$output .= '<h1>'.WebGUI::International::get(18,$namespace).'</h1>';
		$f = WebGUI::HTMLForm->new;
                $f->group("groupToApprove",WebGUI::International::get(1,$namespace),[$groupToApprove]);
                $f->group("groupToContribute",WebGUI::International::get(2,$namespace),[$_[0]->get("groupToContribute")]);
                $f->integer("submissionsPerPage",WebGUI::International::get(6,$namespace),$submissionsPerPage);
                $f->select("defaultStatus",\%submissionStatus,WebGUI::International::get(10,$namespace),[$defaultStatus]);
		$f->yesNo("displayThumbnails",WebGUI::International::get(51,$namespace),$_[0]->get("displayThumbnails"));
		$f->yesNo("allowDiscussion",WebGUI::International::get(48,$namespace),$_[0]->get("allowDiscussion"));
		$f->integer("editTimeout",WebGUI::International::get(49,$namespace),$_[0]->get("editTimeout"));
		$f->group("groupToPost",WebGUI::International::get(50,$namespace),[$_[0]->get("groupToPost")]);
		$f->group("groupToModerate",WebGUI::International::get(44,$namespace),[$groupToModerate]);
		$output .= $_[0]->SUPER::www_edit($f->printRowsOnly);
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_editSave {
        if (WebGUI::Privilege::canEditPage()) {
		$_[0]->SUPER::www_editSave();
                $_[0]->set({
			submissionsPerPage=>$session{form}{submissionsPerPage},
			groupToContribute=>$session{form}{groupToContribute},
			groupToApprove=>$session{form}{groupToApprove},
			defaultStatus=>$session{form}{defaultStatus},
			groupToModerate=>$session{form}{groupToModerate},
			groupToPost=>$session{form}{groupToPost},
			editTimeout=>$session{form}{editTimeout},
			allowDiscussion=>$session{form}{allowDiscussion},
			displayThumbnails=>$session{form}{displayThumbnails}
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
sub www_editSubmission {
        my ($output, %submission, $f, @submission, $sth);
	tie %submission, 'Tie::CPHash';
        %submission = WebGUI::SQL->quickHash("select * from UserSubmission_submission where submissionId='$session{form}{sid}'");
	if ($session{form}{sid} eq "new") {
		$submission{convertCarriageReturns} = 1;
		$submission{userId} = $session{user}{userId};
	}
        if ($submission{userId} == $session{user}{userId}) {
                $output = '<h1>'.WebGUI::International::get(19,$namespace).'</h1>';
		$f = WebGUI::HTMLForm->new;
                $f->hidden("wid",$session{form}{wid});
                $f->hidden("sid",$session{form}{sid});
                $f->hidden("func","editSubmissionSave");
                $f->text("title",WebGUI::International::get(35,$namespace),$submission{title});
                $f->HTMLArea("content",WebGUI::International::get(31,$namespace),$submission{content});
                if ($submission{image} ne "") {
			$f->readOnly('<a href="'.WebGUI::URL::page('func=deleteImage&wid='.$session{form}{wid}.'&sid='.$session{form}{sid}).'">'
				.WebGUI::International::get(391).'</a>',WebGUI::International::get(32,$namespace));
                } else {
			$f->file("image",WebGUI::International::get(32,$namespace));
                }
                if ($submission{attachment} ne "") {
			$f->readOnly('<a href="'.WebGUI::URL::page('func=deleteAttachment&wid='.$session{form}{wid}.'&sid='.$session{form}{sid}).'">'
				.WebGUI::International::get(391).'</a>',WebGUI::International::get(33,$namespace));
                } else {
			$f->file("attachment",WebGUI::International::get(33,$namespace));
                }
		$f->yesNo("convertCarriageReturns",WebGUI::International::get(34,$namespace),$submission{convertCarriageReturns},
			'',' &nbsp; '.WebGUI::International::get(38,$namespace));
		$f->submit;
		$output .= $f->print;
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_editSubmissionSave {
	my ($sqlAdd,$owner,$image,$attachment,$title);
	($owner) = WebGUI::SQL->quickArray("select userId from UserSubmission_submission where submissionId='$session{form}{sid}'");
        if ($owner == $session{user}{userId} || $session{form}{sid} eq "new") {
		if ($session{form}{sid} eq "new") {
			$session{form}{sid} = getNextId("submissionId");
			WebGUI::SQL->write("insert into UserSubmission_submission (wobjectId,submissionId,userId,username) 
				values (".$_[0]->get("wobjectId").",$session{form}{sid},$session{user}{userId},".quote($session{user}{username}).")");
		}
                $image = WebGUI::Attachment->new("",$session{form}{wid},$session{form}{sid});
		$image->save("image");
		if ($image->getFilename ne "") {
			$sqlAdd = 'image='.quote($image->getFilename).', ';
		}
                $attachment = WebGUI::Attachment->new("",$session{form}{wid},$session{form}{sid});
		$attachment->save("attachment");
                if ($attachment->getFilename ne "") {
                        $sqlAdd .= 'attachment='.quote($attachment->getFilename).', ';
                }
                if ($session{form}{title} ne "") {
                        $title = $session{form}{title};
                } else {
                        $title = WebGUI::International::get(16,$namespace);
                }
                WebGUI::SQL->write("update UserSubmission_submission set 
			dateSubmitted=".time().", 
			convertCarriageReturns=$session{form}{convertCarriageReturns}, 
			title=".quote($title).", 
			content=".quote($session{form}{content}).", 
			".$sqlAdd." 
			status='".$_[0]->get("defaultStatus")."'
			where submissionId=$session{form}{sid}");
		if ($_[0]->get("defaultStatus") ne "Approved") {
			WebGUI::MessageLog::addEntry('',$_[0]->get("groupToApprove"),
				WebGUI::URL::page('func=viewSubmission&wid='.$_[0]->get("wobjectId").'&sid='.
				$session{form}{sid}),3,$namespace);
		}
                return $_[0]->www_viewSubmission();
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
                WebGUI::Discussion::postNewMessageSave();
		return $_[0]->www_viewSubmission();
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
        my (@data, $html, %message, $defaultMid);
        tie %message, 'Tie::CPHash';
        ($defaultMid) = WebGUI::SQL->quickArray("select min(messageId) from discussion where wobjectId=$session{form}{wid} and subId=$session{form}{sid}");
        $session{form}{mid} = $defaultMid if ($session{form}{mid} eq "");
        %message = WebGUI::Discussion::getMessage($session{form}{mid});
        if ($message{messageId}) {
                $html .= '<h1>'.$message{subject}.'</h1>';
                $html .= '<table width="100%" cellpadding=3 cellspacing=1 border=0><tr><td class="tableHeader">';
                $html .= '<b>'.WebGUI::International::get(40,$namespace).'</b> <a href="'.
                        WebGUI::URL::page('op=viewProfile&uid='.$message{userId}).'">'.$message{username}.'</a><br>';
                $html .= "<b>".WebGUI::International::get(41,$namespace)."</b> ".
                        epochToHuman($message{dateOfPost},"%z %Z")."<br>";
                $html .= '</td>';
                $html .= '<td rowspan=2 valign="top" class="tableMenu" nowrap>';
                $html .= '<a href="'.WebGUI::URL::page('func=postReply&mid='.$session{form}{mid}.
                        '&wid='.$session{form}{wid}.'&sid='.$session{form}{sid})
                        .'">'.WebGUI::International::get(39,$namespace).'</a><br>';
                if (_canEditMessage($_[0],$session{form}{mid})) {
                        $html .= '<a href="'.WebGUI::URL::page('func=editMessage&mid='.$session{form}{mid}.
                                '&wid='.$session{form}{wid}.'&sid='.$session{form}{sid}).'">'.WebGUI::International::get(42,$namespace).'</a><br>';
                        $html .= '<a href="'.WebGUI::URL::page('func=deleteMessage&mid='.$session{form}{mid}.
                                '&wid='.$session{form}{wid}.'&sid='.$session{form}{sid}).'">'.WebGUI::International::get(43,$namespace).'</a><br>';
                }
                $html .= '<a href="'.WebGUI::URL::page('func=viewSubmission&wid='.$session{form}{wid}.
			'&sid='.$session{form}{sid}).'">'.WebGUI::International::get(45,$namespace).'</a><br>';
                $html .= '<a href="'.WebGUI::URL::page().'">'.WebGUI::International::get(28,$namespace).'</a><br>';
                $html .= '</tr><tr><td class="tableData">';
                $html .= $message{message}.'<p>';
                $html .= _showReplies();
                $html .= '</td></tr></table>';
        } else {
                $html = WebGUI::International::get(402);
        }
        return $html;
}

#-------------------------------------------------------------------
sub www_view {
	my (%submission, $image, $output, $sth, @row, $i, $p);
	$output = $_[0]->displayTitle;
        $output .= $_[0]->description;
	$output = $_[0]->processMacros($output);
	$sth = WebGUI::SQL->read("select * from UserSubmission_submission 
		where wobjectId=".$_[0]->get("wobjectId")." and (status='Approved' or userId=$session{user}{userId}) order by dateSubmitted desc");
	while (%submission = $sth->hash) {
		$submission{title} = WebGUI::HTML::filter($submission{title},'all');
		$row[$i] = '<tr><td class="tableData">
			<a href="'.WebGUI::URL::page('wid='.$_[0]->get("wobjectId").'&func=viewSubmission&sid='.$submission{submissionId}).'">
			'.$submission{title}.'</a>';
		if ($submission{userId} == $session{user}{userId}) {
			$row[$i] .= ' ('.$submissionStatus{$submission{status}}.')';
		}
		$row[$i] .= '</td>';
		if ($_[0]->get("displayThumbnails")) {
			if ($submission{image} ne "") {
				$image = WebGUI::Attachment->new($submission{image},$_[0]->get("wobjectId"),$submission{submissionId});
				$row[$i] .= '<td class="tableData"><a href="'.WebGUI::URL::page('wid='.$_[0]->get("wobjectId").'&func=viewSubmission&sid='
					.$submission{submissionId}).'"><img src="'.$image->getThumbnail.'" border="0"></a></td>';
			} else {
				$row[$i] .= '<td class="tableData"></td>';
			}
		}
		$row[$i] .= '<td class="tableData">'.epochToHuman($submission{dateSubmitted},"%z").
			'</td><td class="tableData"><a href="'.WebGUI::URL::page('op=viewProfile&uid='.
			$submission{userId}).'">'.$submission{username}.'</a></td></tr>';
		$i++;
	}
	$sth->finish;
	$output .= '<table width="100%" cellpadding=2 cellspacing=1 border=0><tr>'.
		'<td align="right" class="tableMenu"><a href="'.WebGUI::URL::page('func=editSubmission&sid=new&wid='.
		$_[0]->get("wobjectId")).'">'.WebGUI::International::get(20,$namespace).'</a></td></tr></table>';
        $p = WebGUI::Paginator->new(WebGUI::URL::page(),\@row,$_[0]->get("submissionsPerPage"));
	$output .= '<table width="100%" cellspacing=1 cellpadding=2 border=0>';
	$output .= '<tr><td class="tableHeader">'.WebGUI::International::get(99);
	if ($_[0]->get("displayThumbnails")) {
		$output .= '<td class="tableHeader">'.WebGUI::International::get(52,$namespace).'</td>';
	}
	$output .= '</td><td class="tableHeader">'.WebGUI::International::get(13,$namespace).
		'</td><td class="tableHeader">'.WebGUI::International::get(21,$namespace).'</td></tr>';
        $output .= $p->getPage($session{form}{pn});
        $output .= '</table>';
        $output .= $p->getBarTraditional($session{form}{pn});
	return $output;
}

#-------------------------------------------------------------------
sub www_viewSubmission {
	my ($output, %submission, $file, $replies);
	tie %submission, 'Tie::CPHash';
	%submission = WebGUI::SQL->quickHash("select * from UserSubmission_submission where submissionId=$session{form}{sid}");
	$submission{title} = WebGUI::HTML::filter($submission{title},'all');
	$submission{content} = WebGUI::HTML::filter($submission{content},$session{setting}{filterContributedHTML});
       	$output = "<h1>".$submission{title}."</h1>";
	$output .= '<table width="100%" cellpadding=2 cellspacing=1 border=0>';
	$output .= '<tr><td class="tableHeader">';
  #---header
	$output .= '<b>'.WebGUI::International::get(22,$namespace).'</b> <a href="'.
		WebGUI::URL::page('op=viewProfile&uid='.$submission{userId}).'">'.$submission{username}.'</a><br>';
	$output .= '<b>'.WebGUI::International::get(23,$namespace).'</b> '.epochToHuman($submission{dateSubmitted},"%z %Z")."<br>";
	$output .= '<b>'.WebGUI::International::get(14,$namespace).':</b> '.$submission{status};
	$output .= '</td><td rowspan="2" class="tableMenu" nowrap valign="top">';
  #---menu
        if ($submission{userId} == $session{user}{userId}) {
                $output .= '<a href="'.WebGUI::URL::page('func=deleteSubmission&wid='.$session{form}{wid}.'&sid='.
			$session{form}{sid}).'">'.WebGUI::International::get(37,$namespace).'</a><br>';
                $output .= '<a href="'.WebGUI::URL::page('func=editSubmission&wid='.$session{form}{wid}.'&sid='.
			$session{form}{sid}).'">'.WebGUI::International::get(27,$namespace).'</a><br>';
        }
        if ($submission{status} eq "Pending" && WebGUI::Privilege::isInGroup($_[0]->get("groupToApprove"),$session{user}{userId})) {
                $output .= '<a href="'.WebGUI::URL::page('func=approveSubmission&wid='.$session{form}{wid}.
			'&sid='.$session{form}{sid}.'&mlog='.$session{form}{mlog}).'">'.
			WebGUI::International::get(24,$namespace).'</a><br>';
                $output .= '<a href="'.WebGUI::URL::page('op=viewMessageLog').'">'.
			WebGUI::International::get(25,$namespace).'</a><br>';
                $output .= '<a href="'.WebGUI::URL::page('func=denySubmission&wid='.$session{form}{wid}.
			'&sid='.$session{form}{sid}.'&mlog='.$session{form}{mlog}).'">'.
			WebGUI::International::get(26,$namespace).'</a><br>';
        }
	if ($_[0]->get("allowDiscussion")) {
		$output .= '<a href="'.WebGUI::URL::page('func=postNewMessage&wid='.$_[0]->get("wobjectId")
			.'&sid='.$session{form}{sid}).'">'.WebGUI::International::get(47,$namespace).'</a><br>';
	}
        $output .= '<a href="'.WebGUI::URL::page().'">'.WebGUI::International::get(28,$namespace).'</a><br>';
	$output .= '</td</tr><tr><td class="tableData">';
  #---content
	if ($submission{image} ne "") {
		$file = WebGUI::Attachment->new($submission{image},$session{form}{wid},$session{form}{sid});
		$output .= '<img src="'.$file->getURL.'"><p>';
	}
	if ($submission{convertCarriageReturns}) {
		$submission{content} =~ s/\n/\<br\>/g;
	}	
	$output .= $submission{content}.'<p>';
	if ($submission{attachment} ne "") {
		$file = WebGUI::Attachment->new($submission{attachment},$session{form}{wid},$session{form}{sid});
		$output .= $file->box;
        }		
        if ($_[0]->get("allowDiscussion")) {
		$output .= _showReplies();
        }
	$output .= '</td></tr></table>';
	return $output;
}



1;

