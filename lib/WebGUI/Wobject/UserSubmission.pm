package WebGUI::Wobject::UserSubmission;

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
use WebGUI::User;
use WebGUI::Utility;
use WebGUI::Wobject;

our @ISA = qw(WebGUI::Wobject);
our $namespace = "UserSubmission";
our $name = WebGUI::International::get(29,$namespace);

our %submissionStatus =("Approved"=>WebGUI::International::get(560),
	"Denied"=>WebGUI::International::get(561),
	"Pending"=>WebGUI::International::get(562));

#-------------------------------------------------------------------
sub _photogalleryView {
        my (@row, $i, $y, $image, $output, $p, $sth, %submission);
        tie %submission, 'Tie::CPHash';
        $sth = WebGUI::SQL->read("select title, image, submissionId, status, userId from UserSubmission_submission
                where wobjectId=".$_[0]->get("wobjectId")." and (status='Approved' or userId=$session{user}{userId}) 
		order by dateSubmitted desc");
        while (%submission = $sth->hash) {
                $submission{title} = WebGUI::HTML::filter($submission{title},'all');
		if ($y == 0) {
			$row[$i] .= '<td>';
		}
                $row[$i] .= '<td align="center" class="tableData">';
                if ($_[0]->get("displayThumbnails")) {
                        $image = WebGUI::Attachment->new($submission{image},$_[0]->get("wobjectId"),$submission{submissionId});
                        $row[$i] .= '<a href="'.WebGUI::URL::page('wid='.$_[0]->get("wobjectId").'&func=viewSubmission&sid='
                        	.$submission{submissionId}).'"><img src="'.$image->getThumbnail.'" border="0"/></a><br/>';
                }
		$row[$i] .= '<a href="'.WebGUI::URL::page('wid='.$_[0]->get("wobjectId").'&func=viewSubmission&sid='
                                .$submission{submissionId}).'">'.$submission{title}.'</a>';
                if ($submission{userId} == $session{user}{userId}) {
                        $row[$i] .= ' ('.$submissionStatus{$submission{status}}.')';
                }
                $row[$i] .= '</td>';
                if ($y == 2) {
                        $row[$i] .= '</tr>';
			$y = -1;
                }
                $i++;
		$y++;
        }
        $sth->finish;
        if (WebGUI::Privilege::isInGroup($_[0]->get("groupToContribute"))) {
                $output .= '<a href="'.WebGUI::URL::page('func=editSubmission&sid=new&wid='.$_[0]->get("wobjectId")).'">'
                        .WebGUI::International::get(20,$namespace).'</a> &middot; ';
        }
	$output .= '<a href="'.WebGUI::URL::page('func=search&wid='.$_[0]->get("wobjectId")).'">'.WebGUI::International::get(364).'</a><p/>';
        $output .= '<table width="100%" cellpadding=2 cellspacing=1 border=0>';
        $p = WebGUI::Paginator->new(WebGUI::URL::page(),\@row,$_[0]->get("submissionsPerPage"));
        $output .= $p->getPage($session{form}{pn});
        $output .= '</table>';
        $output .= $p->getBarTraditional($session{form}{pn});
        return $output;
}

#-------------------------------------------------------------------
sub _traditionalView {
	my (@row, $i, $image, $output, $p, $sth, %submission);
	tie %submission, 'Tie::CPHash';
        $sth = WebGUI::SQL->read("select submissionId, title, userId, status, image, dateSubmitted, username from UserSubmission_submission
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
                '<td align="right" class="tableMenu">';
	if (WebGUI::Privilege::isInGroup($_[0]->get("groupToContribute"))) {
		$output .= '<a href="'.WebGUI::URL::page('func=editSubmission&sid=new&wid='.
                $_[0]->get("wobjectId")).'">'.WebGUI::International::get(20,$namespace).'</a> &middot; ';
	}
	$output .= '<a href="'
		.WebGUI::URL::page('func=search&wid='.$_[0]->get("wobjectId")).'">'
		.WebGUI::International::get(364).'</a></td></tr></table>';
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
sub _weblogView {
        my (@row, $i, $image, $output, $p, $sth, %submission, $responses);
        tie %submission, 'Tie::CPHash';
        $sth = WebGUI::SQL->read("select * from UserSubmission_submission
                where wobjectId=".$_[0]->get("wobjectId")." and (status='Approved' or userId=$session{user}{userId}) order by dateSubmitted desc");
        while (%submission = $sth->hash) {
                $submission{title} = WebGUI::HTML::filter($submission{title},'all');
		$submission{content} = WebGUI::HTML::filter($submission{content});
		($submission{content}) = split(/\^\-\;/,$submission{content});
		($responses) = WebGUI::SQL->quickArray("select count(*) from discussion 
			where wobjectId=".$_[0]->get("wobjectId")." and subId=$submission{submissionId}");
		$row[$i] = '<tr><td class="tableHeader">'.$submission{title};
                if ($submission{userId} == $session{user}{userId}) {
                        $row[$i] .= ' ('.$submissionStatus{$submission{status}}.')';
                }
		$row[$i] .= '</td></tr><tr><td class="tableData"><b>';
                if ($_[0]->get("displayThumbnails")) {
                        if ($submission{image} ne "") {
                                $image = WebGUI::Attachment->new($submission{image},$_[0]->get("wobjectId"),$submission{submissionId});
                                $row[$i] .= '<a href="'.WebGUI::URL::page('wid='.$_[0]->get("wobjectId").'&func=viewSubmission&sid='
                                        .$submission{submissionId}).'"><img src="'.$image->getThumbnail.'" border="0" align="right"/></a>';
                        }
                }
		$row[$i] .= WebGUI::International::get(40,$namespace)
                        .' <a href="'.WebGUI::URL::page('op=viewProfile&uid='.$submission{userId}).'">'.$submission{username}.'</a>'
			.' - '.epochToHuman($submission{dateSubmitted},"%z \@ %Z").'</b><br/>'
			.$submission{content}.'<p/> (<a href="'.WebGUI::URL::page('func=viewSubmission&wid='
			.$_[0]->get("wobjectId").'&sid='.$submission{submissionId}).'">'.WebGUI::International::get(46,$namespace)
			.'</a>';
		if ($_[0]->get("allowDiscussion")) {
			$row[$i] .= ' | '.$responses.' '.WebGUI::International::get(57,$namespace)
		}
		$row[$i] .= ')<p/></td></tr>';
                $i++;
        }
        $sth->finish;
	if (WebGUI::Privilege::isInGroup($_[0]->get("groupToContribute"))) {
        	$output .= '<a href="'.WebGUI::URL::page('func=editSubmission&sid=new&wid='.$_[0]->get("wobjectId")).'">'
			.WebGUI::International::get(20,$namespace).'</a> &middot; ';
	}
	$output .= '<a href="'.WebGUI::URL::page('func=search&wid='.$_[0]->get("wobjectId")).'">'.WebGUI::International::get(364).'</a><p/>';
        $output .= '<table width="100%" cellpadding=2 cellspacing=1 border=0>';
        $p = WebGUI::Paginator->new(WebGUI::URL::page(),\@row,$_[0]->get("submissionsPerPage"));
        $output .= $p->getPage($session{form}{pn});
        $output .= '</table>';
        $output .= $p->getBarSimple($session{form}{pn});
        return $output;
}

#-------------------------------------------------------------------
sub duplicate {
        my ($sth, $file, %row, $newSubmissionId, $w);
	tie %row, 'Tie::CPHash';
	$w = $_[0]->SUPER::duplicate($_[1]);
        $w = WebGUI::Wobject::UserSubmission->new({wobjectId=>$w,namespace=>$namespace});
        $w->set({
		groupToContribute=>$_[0]->get("groupToContribute"),
		submissionsPerPage=>$_[0]->get("submissionsPerPage"),
		defaultStatus=>$_[0]->get("defaultStatus"),
		groupToApprove=>$_[0]->get("groupToApprove"),
		allowDiscussion=>$_[0]->get("allowDiscussion"),
		karmaPerSubmission=>$_[0]->get("karmaPerSubmission"),
		layout=>$_[0]->get("layout"),
		displayThumbnails=>$_[0]->get("displayThumbnails")
		});
        $sth = WebGUI::SQL->read("select * from UserSubmission_submission where wobjectId=".$_[0]->get("wobjectId"));
        while (%row = $sth->hash) {
                $newSubmissionId = getNextId("submissionId");
		$file = WebGUI::Attachment->new($row{image},$_[0]->get("wobjectId"),$row{submissionId});
		$file->copy($w->get("wobjectId"),$newSubmissionId);
		$file = WebGUI::Attachment->new($row{attachment},$_[0]->get("wobjectId"),$row{submissionId});
		$file->copy($w->get("wobjectId"),$newSubmissionId);
                WebGUI::SQL->write("insert into UserSubmission_submission values (".$w->get("wobjectId").", $newSubmissionId, ".
			quote($row{title}).", $row{dateSubmitted}, ".quote($row{username}).", '$row{userId}', ".quote($row{content}).", ".
			quote($row{image}).", ".quote($row{attachment}).", '$row{status}', '$row{convertCarriageReturns}', 
			'$row{views}')");
		WebGUI::Discussion::duplicate($_[0]->get("wobjectId"),$w->get("wobjectId"),$row{submissionId},$newSubmissionId);
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
	WebGUI::Discussion::purge($_[0]->get("wobjectId"));
	$_[0]->SUPER::purge();
}

#-------------------------------------------------------------------
sub set {
        $_[0]->SUPER::set($_[1],[qw(submissionsPerPage groupToContribute groupToApprove defaultStatus  
		displayThumbnails karmaPerSubmission layout allowDiscussion)]);
}

#-------------------------------------------------------------------
sub www_approvePost {
        if (WebGUI::Privilege::isInGroup($_[0]->get("groupToModerate"))) {
                return WebGUI::Discussion::approvePost();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_approveSubmission {
	my (%submission);
	tie %submission, 'Tie::CPHash';
        if (WebGUI::Privilege::isInGroup(4,$session{user}{userId}) || WebGUI::Privilege::isInGroup(3,$session{user}{userId})) {
		%submission = WebGUI::SQL->quickHash("select * from UserSubmission_submission where submissionId=$session{form}{sid}");
                WebGUI::SQL->write("update UserSubmission_submission set status='Approved' where submissionId=$session{form}{sid}");
		WebGUI::MessageLog::addInternationalizedEntry($submission{userId},'',WebGUI::URL::page('func=viewSubmission&wid='.
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
        if (WebGUI::Discussion::canEditMessage($_[0],$session{form}{mid})) {
                return WebGUI::Discussion::deleteMessage();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteMessageConfirm {
        if (WebGUI::Discussion::canEditMessage($_[0],$session{form}{mid})) {
                return WebGUI::Discussion::deleteMessageConfirm();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteSubmission {
	my ($output, $owner);
	($owner) = WebGUI::SQL->quickArray("select userId from UserSubmission_submission where submissionId=$session{form}{sid}");
        if ($owner == $session{user}{userId} || WebGUI::Privilege::isInGroup($_[0]->get("groupToApprove"))) {
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
        if ($owner == $session{user}{userId} || WebGUI::Privilege::isInGroup($_[0]->get("groupToApprove"))) {
		WebGUI::SQL->write("delete from UserSubmission_submission where submissionId=$session{form}{sid}");
		$file = WebGUI::Attachment->new("",$session{form}{wid},$session{form}{sid});
		$file->deleteNode;
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_denyPost {
        if (WebGUI::Privilege::isInGroup($_[0]->get("groupToModerate"))) {
                return WebGUI::Discussion::denyPost();
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
                WebGUI::MessageLog::addInternationalizedEntry($submission{userId},'',WebGUI::URL::page('func=viewSubmission&wid='.
			$session{form}{wid}.'&sid='.$session{form}{sid}),5,$namespace);
                WebGUI::MessageLog::completeEntry($session{form}{mlog});
                return WebGUI::Operation::www_viewMessageLog();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_edit {
        my (%layout, $layout, $output, $f, $defaultStatus, $submissionsPerPage, $groupToApprove);
	%layout = (traditional=>WebGUI::International::get(55,$namespace),
		weblog=>WebGUI::International::get(54,$namespace),
		photogallery=>WebGUI::International::get(56,$namespace));
	$layout = $_[0]->get("layout") || "traditional";
	$groupToApprove = $_[0]->get("groupToApprove") || 4;
	$submissionsPerPage = $_[0]->get("submissionsPerPage") || 50;
	$defaultStatus = $_[0]->get("defaultStatus") || "Approved";
        if (WebGUI::Privilege::canEditPage()) {
                $output = helpIcon(1,$namespace);
		$output .= '<h1>'.WebGUI::International::get(18,$namespace).'</h1>';
		$f = WebGUI::HTMLForm->new;
                $f->select("layout",\%layout,WebGUI::International::get(53,$namespace),[$layout]);
                $f->group("groupToApprove",WebGUI::International::get(1,$namespace),[$groupToApprove]);
                $f->group("groupToContribute",WebGUI::International::get(2,$namespace),[$_[0]->get("groupToContribute")]);
                $f->integer("submissionsPerPage",WebGUI::International::get(6,$namespace),$submissionsPerPage);
                $f->select("defaultStatus",\%submissionStatus,WebGUI::International::get(563),[$defaultStatus]);
                if ($session{setting}{useKarma}) {
                        $f->integer("karmaPerSubmission",WebGUI::International::get(30,$namespace),$_[0]->get("karmaPerSubmission"));
                } else {
                        $f->hidden("karmaPerSubmission",$_[0]->get("karmaPerSubmission"));
                }
		$f->yesNo("displayThumbnails",WebGUI::International::get(51,$namespace),$_[0]->get("displayThumbnails"));
		$f->yesNo("allowDiscussion",WebGUI::International::get(48,$namespace),$_[0]->get("allowDiscussion"));
		$f->raw($_[0]->SUPER::discussionProperties);
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
			karmaPerSubmission=>$session{form}{karmaPerSubmission},
			allowDiscussion=>$session{form}{allowDiscussion},
			layout=>$session{form}{layout},
			displayThumbnails=>$session{form}{displayThumbnails}
			});
                return "";
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
        if (WebGUI::Privilege::isInGroup($_[0]->get("groupToContribute")) 
	 || $submission{userId} == $session{user}{userId} 
	 || WebGUI::Privilege::isInGroup($_[0]->get("groupToApprove"))) {
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
	my ($sqlAdd,$owner,$image,$attachment,$title,$u);
	($owner) = WebGUI::SQL->quickArray("select userId from UserSubmission_submission where submissionId='$session{form}{sid}'");
        if ($owner == $session{user}{userId} 
	 || ($session{form}{sid} eq "new" && WebGUI::Privilege::isInGroup($_[0]->get("groupToContribute"))) 
	 || WebGUI::Privilege::isInGroup($_[0]->get("groupToApprove"))) {
		if ($session{form}{sid} eq "new") {
			$session{form}{sid} = getNextId("submissionId");
			WebGUI::SQL->write("insert into UserSubmission_submission (wobjectId,submissionId,userId,username) 
				values (".$_[0]->get("wobjectId").",$session{form}{sid},$session{user}{userId},".quote($session{user}{username}).")");
			if ($session{setting}{useKarma}) {
				$u = WebGUI::User->new($session{user}{userId});
				$u->karma($_[0]->get("karmaPerSubmission"),$namespace." (".$_[0]->get("wobjectId")."/".$session{form}{sid}.")","User submission.");
			}
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
			WebGUI::MessageLog::addInternationalizedEntry('',$_[0]->get("groupToApprove"),
				WebGUI::URL::page('func=viewSubmission&wid='.$_[0]->get("wobjectId").'&sid='.
				$session{form}{sid}),3,$namespace,'pending');
		}
                return $_[0]->www_viewSubmission();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_lockThread {
        if (WebGUI::Privilege::isInGroup($_[0]->get("groupToModerate"))) {
                WebGUI::Discussion::lockThread();
		return $_[0]->www_showMessage;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_post {
        if (WebGUI::Privilege::isInGroup($_[0]->get("groupToPost"))) {
                return WebGUI::Discussion::post();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_postSave {
        if (WebGUI::Privilege::isInGroup($_[0]->get("groupToPost"))) {
                WebGUI::Discussion::postSave($_[0]);
                return $_[0]->www_showMessage();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_search {
	if ($session{form}{sid} ne "") {
		return WebGUI::Discussion::search();
	} else {
        	my ($p, $i, $output, $constraints, $image, $sql, $sth, %submission, @row, $url);
        	$output = WebGUI::Search::form({wid=>"$session{form}{wid}",func=>'search'});
        	$constraints = WebGUI::Search::buildConstraints([qw(username title content)]);
        	if ($constraints ne "") {
                	tie %submission, 'Tie::CPHash';
                	$url = WebGUI::URL::page('func=search&wid='.$session{form}{wid}
                        	.'&all='.WebGUI::URL::escape($session{form}{all})
                        	.'&exactPhrase='.WebGUI::URL::escape($session{form}{exactPhrase}).'&atLeastOne='
                        	.WebGUI::URL::escape($session{form}{atLeastOne}).'&numResults='.$session{form}{numResults}
                        	.'&without='.WebGUI::URL::escape($session{form}{without}));
                	$output .= '<table border=0 cellpadding=2 cellspacing=1 width="100%">';
			$output .= '<tr><td class="tableHeader">'.WebGUI::International::get(99);
        		if ($_[0]->get("displayThumbnails")) {
                		$output .= '<td class="tableHeader">'.WebGUI::International::get(52,$namespace).'</td>';
        		}
        		$output .= '</td><td class="tableHeader">'.WebGUI::International::get(13,$namespace).
                		'</td><td class="tableHeader">'.WebGUI::International::get(21,$namespace).'</td></tr>';
                	$sql = "select * from UserSubmission_submission where wobjectId=$session{form}{wid} ";
                	$sql .= " and (status='Approved' or userId=$session{user}{userId}) and ".$constraints." order by dateSubmitted desc";
                	$sth = WebGUI::SQL->read($sql);
                	while (%submission = $sth->hash) {
				$submission{title} = WebGUI::HTML::filter($submission{title},'all');
                		$row[$i] = '<tr><td class="tableData">
                        		<a href="'.WebGUI::URL::page('wid='.$_[0]->get("wobjectId").'&func=viewSubmission&sid='
					.$submission{submissionId}).'">'.$submission{title}.'</a>';
                		if ($submission{userId} == $session{user}{userId}) {
                        		$row[$i] .= ' ('.$submissionStatus{$submission{status}}.')';
                		}
                		$row[$i] .= '</td>';
                		if ($_[0]->get("displayThumbnails")) {
                        		if ($submission{image} ne "") {
                                		$image = WebGUI::Attachment->new($submission{image},$_[0]->get("wobjectId"),$submission{submissionId});
                                		$row[$i] .= '<td class="tableData"><a href="'.WebGUI::URL::page('wid='.$_[0]->get("wobjectId")
						.'&func=viewSubmission&sid='
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
                	$p = WebGUI::Paginator->new($url,\@row,$session{form}{numResults});
                	$output .= $p->getPage($session{form}{pn});
                	$output .= '</table>';
                	$output .= $p->getBarTraditional($session{form}{pn});
        	}
        	return $output;
	}
}

#-------------------------------------------------------------------
sub www_showMessage {
        my ($submenu, $output);
        $submenu .= '<a href="'.WebGUI::URL::page('func=viewSubmission&wid='.$session{form}{wid}.
		'&sid='.$session{form}{sid}).'">'.WebGUI::International::get(45,$namespace).'</a><br>';
        $submenu .= '<a href="'.WebGUI::URL::page().'">'.WebGUI::International::get(28,$namespace).'</a><br>';
	$output = WebGUI::Discussion::showMessage($submenu,$_[0]);
        $output .= WebGUI::Discussion::showThreads();
        return $output;
}

#-------------------------------------------------------------------
sub www_unlockThread {
        if (WebGUI::Privilege::isInGroup($_[0]->get("groupToModerate"))) {
                WebGUI::Discussion::unlockThread();
		return $_[0]->www_showMessage;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_view {
	my ($output);
	$output = $_[0]->displayTitle;
        $output .= $_[0]->description;
	$output = $_[0]->processMacros($output);
	if ($_[0]->get("layout") eq "weblog") {
		$output .= $_[0]->_weblogView;
	} elsif ($_[0]->get("layout") eq "photogallery") {
		$output .= $_[0]->_photogalleryView;
	} else {
		$output .= $_[0]->_traditionalView;
	}
	return $output;
}

#-------------------------------------------------------------------
sub www_viewSubmission {
	my ($output, %submission, $file, @data, $replies);
	tie %submission, 'Tie::CPHash';
	WebGUI::SQL->write("update UserSubmission_submission set views=views+1 where submissionId=$session{form}{sid}");
	%submission = WebGUI::SQL->quickHash("select * from UserSubmission_submission where submissionId=$session{form}{sid}");
	$submission{title} = WebGUI::HTML::filter($submission{title},'all');
	$submission{content} = WebGUI::HTML::filter($submission{content},$session{setting}{filterContributedHTML});
	$submission{content} =~ s/\^\-\;//g;
       	$output = "<h1>".$submission{title}."</h1>";
	$output .= '<table width="100%" cellpadding=2 cellspacing=1 border=0>';
	$output .= '<tr><td valign="top" class="tableHeader" width="100%">';
  #---header
	$output .= '<b>'.WebGUI::International::get(22,$namespace).'</b> <a href="'.
		WebGUI::URL::page('op=viewProfile&uid='.$submission{userId}).'">'.$submission{username}.'</a><br>';
	$output .= '<b>'.WebGUI::International::get(23,$namespace).'</b> '.epochToHuman($submission{dateSubmitted},"%z %Z")."<br>";
	$output .= '<b>'.WebGUI::International::get(14,$namespace).':</b> '.$submissionStatus{$submission{status}}.'<br>';
	$output .= '<b>'.WebGUI::International::get(514).':</b> '.$submission{views}.'<br>';
	$output .= '</td><td rowspan="2" class="tableMenu" nowrap="1" valign="top">';
  #---menu
	@data = WebGUI::SQL->quickArray("select max(submissionId) from UserSubmission_submission 
        	where wobjectId=$submission{wobjectId} and submissionId<$submission{submissionId}
		and (userId=$submission{userId} or status='Approved')");
        if ($data[0] ne "") {
        	$output .= '<a href="'.WebGUI::URL::page('func=viewSubmission&sid='.$data[0].'&wid='.
                	$session{form}{wid}).'">&laquo; '.WebGUI::International::get(58,$namespace).'</a><br>';
        }
        @data = WebGUI::SQL->quickArray("select min(submissionId) from UserSubmission_submission 
                where wobjectId=$submission{wobjectId} and submissionId>$submission{submissionId}
		and (userId=$submission{userId} or status='Approved')");
        if ($data[0] ne "") {
                $output .= '<a href="'.WebGUI::URL::page('func=viewSubmission&sid='.$data[0].'&wid='.
                        $session{form}{wid}).'">'.WebGUI::International::get(59,$namespace).' &raquo;</a><br>';
        }
        if ($submission{userId} == $session{user}{userId} || WebGUI::Privilege::isInGroup($_[0]->get("groupToApprove"))) {
                $output .= '<a href="'.WebGUI::URL::page('func=deleteSubmission&wid='.$session{form}{wid}.'&sid='.
			$session{form}{sid}).'">'.WebGUI::International::get(37,$namespace).'</a><br>';
                $output .= '<a href="'.WebGUI::URL::page('func=editSubmission&wid='.$session{form}{wid}.'&sid='.
			$session{form}{sid}).'">'.WebGUI::International::get(27,$namespace).'</a><br>';
        }
        if ($submission{status} ne "Approved" && WebGUI::Privilege::isInGroup($_[0]->get("groupToApprove"),$session{user}{userId})) {
                $output .= '<a href="'.WebGUI::URL::page('func=approveSubmission&wid='.$session{form}{wid}.
			'&sid='.$session{form}{sid}.'&mlog='.$session{form}{mlog}).'">'.
			WebGUI::International::get(572).'</a><br>';
                $output .= '<a href="'.WebGUI::URL::page('op=viewMessageLog').'">'.
			WebGUI::International::get(573).'</a><br>';
                $output .= '<a href="'.WebGUI::URL::page('func=denySubmission&wid='.$session{form}{wid}.
			'&sid='.$session{form}{sid}.'&mlog='.$session{form}{mlog}).'">'.
			WebGUI::International::get(574).'</a><br>';
        }
	if ($_[0]->get("allowDiscussion")) {
		$output .= '<a href="'.WebGUI::URL::page('func=post&mid=new&wid='.$_[0]->get("wobjectId")
			.'&sid='.$session{form}{sid}).'">'.WebGUI::International::get(47,$namespace).'</a><br>';
	}
	$output .= '<a href="'.WebGUI::URL::page('func=search&wid='.$_[0]->get("wobjectId")).'">'.WebGUI::International::get(364).'</a><br>';
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
	$output .= '</td></tr></table>';
        if ($_[0]->get("allowDiscussion")) {
		$output .= WebGUI::Discussion::showThreads();
        }
	return $output;
}



1;

