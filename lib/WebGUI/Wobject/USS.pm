package WebGUI::Wobject::USS;

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
use WebGUI::HTML;
use WebGUI::HTMLForm;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::MessageLog;
use WebGUI::Operation;
use WebGUI::Paginator;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::Template;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::User;
use WebGUI::Utility;
use WebGUI::Wobject;

our @ISA = qw(WebGUI::Wobject);
our $namespace = "USS";
our $name = WebGUI::International::get(29,$namespace);

our %submissionStatus =("Approved"=>WebGUI::International::get(560),
	"Denied"=>WebGUI::International::get(561),
	"Pending"=>WebGUI::International::get(562));

#-------------------------------------------------------------------
sub duplicate {
        my ($sth, $file, %row, $newSubmissionId, $w);
	tie %row, 'Tie::CPHash';
	$w = $_[0]->SUPER::duplicate($_[1],1);
        $w = WebGUI::Wobject::USS->new({wobjectId=>$w,namespace=>$namespace});
        $w->set({
		groupToContribute=>$_[0]->get("groupToContribute"),
		submissionsPerPage=>$_[0]->get("submissionsPerPage"),
		defaultStatus=>$_[0]->get("defaultStatus"),
		groupToApprove=>$_[0]->get("groupToApprove"),
		allowDiscussion=>$_[0]->get("allowDiscussion"),
		karmaPerSubmission=>$_[0]->get("karmaPerSubmission"),
		templateId=>$_[0]->get("templateId"),
		submissionTemplateId=>$_[0]->get("submissionTemplateId")
		});
        $sth = WebGUI::SQL->read("select * from USS_submission where wobjectId=".$_[0]->get("wobjectId"));
        while (%row = $sth->hash) {
                $newSubmissionId = getNextId("USS_submissionId");
		$file = WebGUI::Attachment->new($row{image},$_[0]->get("wobjectId"),$row{USS_submissionId});
		$file->copy($w->get("wobjectId"),$newSubmissionId);
		$file = WebGUI::Attachment->new($row{attachment},$_[0]->get("wobjectId"),$row{USS_submissionId});
		$file->copy($w->get("wobjectId"),$newSubmissionId);
                WebGUI::SQL->write("insert into USS_submission values (".$w->get("wobjectId").", $newSubmissionId, ".
			quote($row{title}).", $row{dateSubmitted}, ".quote($row{username}).", '$row{userId}', ".quote($row{content}).", ".
			quote($row{image}).", ".quote($row{attachment}).", '$row{status}', '$row{convertCarriageReturns}', 
			'$row{views}')");
		WebGUI::Discussion::duplicate($_[0]->get("wobjectId"),$w->get("wobjectId"),$row{USS_submissionId},$newSubmissionId);
        }
        $sth->finish;
}

#-------------------------------------------------------------------
sub purge {
        WebGUI::SQL->write("delete from USS_submission where wobjectId=".$_[0]->get("wobjectId"));
	$_[0]->SUPER::purge();
}

#-------------------------------------------------------------------
sub set {
        $_[0]->SUPER::set($_[1],[qw(submissionsPerPage groupToContribute groupToApprove defaultStatus  
		submissionTemplateId templateId karmaPerSubmission allowDiscussion)]);
}

#-------------------------------------------------------------------
sub www_approveSubmission {
	my (%submission);
	tie %submission, 'Tie::CPHash';
        if (WebGUI::Privilege::isInGroup(4,$session{user}{userId}) || WebGUI::Privilege::isInGroup(3,$session{user}{userId})) {
		%submission = WebGUI::SQL->quickHash("select * from USS_submission where USS_submissionId=$session{form}{sid}");
                WebGUI::SQL->write("update USS_submission set status='Approved' where USS_submissionId=$session{form}{sid}");
		WebGUI::MessageLog::addInternationalizedEntry($submission{userId},'',WebGUI::URL::page('func=viewSubmission&wid='.
			$session{form}{wid}.'&sid='.$session{form}{sid}),4,$namespace);
		WebGUI::MessageLog::completeEntry($session{form}{mlog});
                return WebGUI::Operation::www_viewMessageLog();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteFile {
	my ($owner) = WebGUI::SQL->quickArray("select userId from USS_submission where USS_submissionId=$session{form}{sid}");
        if ($owner == $session{user}{userId} || WebGUI::Privilege::isInGroup($_[0]->get("groupToApprove"))) {
		$_[0]->setCollateral("USS_submission","USS_submissionId",{
			$session{form}{file}=>'',
		 	USS_submissionId=>$session{form}{sid}
			},0,0);
                return $_[0]->www_editSubmission();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteSubmission {
	my ($owner);
	($owner) = WebGUI::SQL->quickArray("select userId from USS_submission where USS_submissionId=$session{form}{sid}");
        if ($owner == $session{user}{userId} || WebGUI::Privilege::isInGroup($_[0]->get("groupToApprove"))) {
		return $_[0]->confirm(WebGUI::International::get(17,$namespace),
			WebGUI::URL::page('func=deleteSubmissionConfirm&wid='.$session{form}{wid}.'&sid='.$session{form}{sid}));
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteSubmissionConfirm {
        my ($output, $owner, $file);
	($owner) = WebGUI::SQL->quickArray("select userId from USS_submission where USS_submissionId=$session{form}{sid}");
        if ($owner == $session{user}{userId} || WebGUI::Privilege::isInGroup($_[0]->get("groupToApprove"))) {
		$_[0]->deleteCollateral("USS_submission","USS_submissionId",$session{form}{sid});
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
		%submission = WebGUI::SQL->quickHash("select * from USS_submission where USS_submissionId=$session{form}{sid}");
                WebGUI::SQL->write("update USS_submission set status='Denied' where USS_submissionId=$session{form}{sid}");
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
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
        my ($output, $f, $defaultStatus, $submissionsPerPage, $groupToApprove);
	$groupToApprove = $_[0]->get("groupToApprove") || 4;
	$submissionsPerPage = $_[0]->get("submissionsPerPage") || 50;
	$defaultStatus = $_[0]->get("defaultStatus") || "Approved";
        $output = helpIcon(1,$namespace);
	$output .= '<h1>'.WebGUI::International::get(18,$namespace).'</h1>';
	$f = WebGUI::HTMLForm->new;
	$f->template(
                -name=>"templateId",
                -value=>$_[0]->get("templateId"),
                -namespace=>$namespace,
                -label=>WebGUI::International::get(72,$namespace),
                -afterEdit=>'func=edit&wid='.$_[0]->get("wobjectId")
                );
        $f->template(
                -name=>"submissionTemplateId",
                -value=>$_[0]->get("submissionTemplateId"),
                -namespace=>$namespace."/Submission",
                -label=>WebGUI::International::get(73,$namespace),
                -afterEdit=>'func=edit&wid='.$_[0]->get("wobjectId")
                );
        $f->group("groupToApprove",WebGUI::International::get(1,$namespace),[$groupToApprove]);
        $f->group("groupToContribute",WebGUI::International::get(2,$namespace),[$_[0]->get("groupToContribute")]);
        $f->integer("submissionsPerPage",WebGUI::International::get(6,$namespace),$submissionsPerPage);
        $f->select("defaultStatus",\%submissionStatus,WebGUI::International::get(563),[$defaultStatus]);
        if ($session{setting}{useKarma}) {
                $f->integer("karmaPerSubmission",WebGUI::International::get(30,$namespace),$_[0]->get("karmaPerSubmission"));
        } else {
                $f->hidden("karmaPerSubmission",$_[0]->get("karmaPerSubmission"));
        }
	$f->yesNo("allowDiscussion",WebGUI::International::get(48,$namespace),$_[0]->get("allowDiscussion"));
	$f->raw($_[0]->SUPER::discussionProperties);
	$output .= $_[0]->SUPER::www_edit($f->printRowsOnly);
        return $output;
}

#-------------------------------------------------------------------
sub www_editSave {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
	$_[0]->SUPER::www_editSave({
		submissionsPerPage=>$session{form}{submissionsPerPage},
		groupToContribute=>$session{form}{groupToContribute},
		groupToApprove=>$session{form}{groupToApprove},
		defaultStatus=>$session{form}{defaultStatus},
		karmaPerSubmission=>$session{form}{karmaPerSubmission},
		allowDiscussion=>$session{form}{allowDiscussion},
		templateId=>$session{form}{templateId},
		submissionTemplateId=>$session{form}{submissionTemplateId}
		});
        return "";
}

#-------------------------------------------------------------------
sub www_editSubmission {
        my ($output, $submission, $f, @submission, $sth);
        $submission = $_[0]->getCollateral("USS_submission","USS_submissionId",$session{form}{sid});
	if ($submission->{USS_submissionId} eq "new") {
		$submission->{convertCarriageReturns} = 1;
		$submission->{userId} = $session{user}{userId};
	}
        if (WebGUI::Privilege::isInGroup($_[0]->get("groupToContribute")) || $submission->{userId} == $session{user}{userId} || WebGUI::Privilege::isInGroup($_[0]->get("groupToApprove"))) {
                $output = '<h1>'.WebGUI::International::get(19,$namespace).'</h1>';
		$f = WebGUI::HTMLForm->new;
		if ($session{user}{userId} == 1 && $submission->{USS_submissionId} eq "new") {
                        $f->text("visitorName",WebGUI::International::get(438));
                }
                $f->hidden("wid",$session{form}{wid});
                $f->hidden("sid",$submission->{USS_submissionId});
                $f->hidden("func","editSubmissionSave");
                $f->text("title",WebGUI::International::get(35,$namespace),$submission->{title});
                $f->HTMLArea("content",WebGUI::International::get(31,$namespace),$submission->{content});
                if ($submission->{image} ne "") {
			$f->readOnly('<a href="'.WebGUI::URL::page('func=deleteFile&file=image&wid='.$session{form}{wid}.'&sid='.$submission->{USS_submissionId}).'">'
				.WebGUI::International::get(391).'</a>',WebGUI::International::get(32,$namespace));
                } else {
			$f->file("image",WebGUI::International::get(32,$namespace));
                }
                if ($submission->{attachment} ne "") {
			$f->readOnly('<a href="'.WebGUI::URL::page('func=deleteFile&file=attachment&wid='.$session{form}{wid}
				.'&sid='.$submission->{USS_submissionId}).'">'
				.WebGUI::International::get(391).'</a>',WebGUI::International::get(33,$namespace));
                } else {
			$f->file("attachment",WebGUI::International::get(33,$namespace));
                }
		$f->yesNo("convertCarriageReturns",WebGUI::International::get(34,$namespace),$submission->{convertCarriageReturns},
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
	my ($submission, %hash, $file, $u);
	$submission = $_[0]->getCollateral("USS_submission","USS_submissionId",$session{form}{sid});
        if ($submission->{userId} == $session{user}{userId} 
		|| ($submission->{USS_submissionId} eq "new" 
		&& WebGUI::Privilege::isInGroup($_[0]->get("groupToContribute"))) 
		|| WebGUI::Privilege::isInGroup($_[0]->get("groupToApprove"))) {
                if ($session{form}{sid} eq "new") {
			$hash{username} = $session{form}{visitorName} || $session{user}{username};
			$hash{userId} = $session{user}{userId};
			$hash{USS_submissionId} = "new";
			if ($session{setting}{useKarma}) {
                        	$u = WebGUI::User->new($session{user}{userId});
                        	$u->karma($_[0]->get("karmaPerSubmission"),$namespace." (".$_[0]->get("wobjectId")
                                	."/".$session{form}{sid}.")","User submission.");
			}
			$session{form}{sid} = $_[0]->setCollateral("USS_submission","USS_submissionId",\%hash,0);
			%hash = ();
                }
                $hash{title} = WebGUI::HTML::filter($session{form}{title},'all') || WebGUI::International::get(16,$namespace);
		$hash{USS_submissionId} = $session{form}{sid};
		$hash{dateSubmitted} = time();
		$hash{content} = $session{form}{content};
		$hash{convertCarriageReturns} = $session{form}{convertCarriageReturns};
		$hash{status} = $_[0]->get("defaultStatus");
                $file = WebGUI::Attachment->new("",$session{form}{wid},$session{form}{sid});
		$file->save("image");
		$hash{image} = $file->getFilename if ($file->getFilename ne "");
                $file = WebGUI::Attachment->new("",$session{form}{wid},$session{form}{sid});
		$file->save("attachment");
		$hash{attachment} = $file->getFilename if ($file->getFilename ne "");
		$_[0]->setCollateral("USS_submission", "USS_submissionId", \%hash, 0);
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
sub www_showMessage {
	return $_[0]->SUPER::www_showMessage('<a href="'.WebGUI::URL::page('func=viewSubmission&wid='.$session{form}{wid}
		.'&sid='.$session{form}{sid}).'">'.WebGUI::International::get(45,$namespace).'</a><br>'
        	.'<a href="'.WebGUI::URL::page().'">'.WebGUI::International::get(28,$namespace).'</a><br>');
}

#-------------------------------------------------------------------
sub www_view {
	my (%var, $row, $page, $p, $constraints, @submission, @content, $image, $i, $url, $thumbnail, $responses);
	$var{"label.readmore"} = WebGUI::International::get(46,$namespace);
	$var{"label.responses"} = WebGUI::International::get(57,$namespace);
        $var{description} = $_[0]->processMacros($_[0]->get("description"));
	if (WebGUI::Privilege::isInGroup($_[0]->get("groupToContribute"))) {
                $var{post} = '<a href="'.WebGUI::URL::page('func=editSubmission&sid=new&wid='
			.$_[0]->get("wobjectId")).'">'.WebGUI::International::get(20,$namespace).'</a>';
        }
	unless ($session{form}{search}) {
		$url = 'func=view&search=1&wid='.$_[0]->get("wobjectId");
	}
        $var{search} = '<a href="'.WebGUI::URL::page($url).'">'.WebGUI::International::get(364).'</a>';
	if ($session{form}{search}) {
		$var{searchForm} = WebGUI::Search::form({wid=>"$session{form}{wid}",func=>'view',search=>1});
	}
       	$constraints = WebGUI::Search::buildConstraints([qw(username title content)]);
	if ($constraints ne "") {
        	$constraints = "status='Approved' and ".$constraints;
	} else {
		$constraints = "(status='Approved' or userId=$session{user}{userId})";
	}
	$var{"label.title"} = WebGUI::International::get(99);
	$var{"label.thumbnail"} = WebGUI::International::get(52,$namespace);
	$var{"label.date"} = WebGUI::International::get(13,$namespace);
	$var{"label.by"} = WebGUI::International::get(21,$namespace);
	$url = WebGUI::URL::page('func=view&search='.$session{form}{search}.'&wid='.$_[0]->get("wobjectId")
        	.'&all='.WebGUI::URL::escape($session{form}{all})
                .'&exactPhrase='.WebGUI::URL::escape($session{form}{exactPhrase}).'&atLeastOne='
                .WebGUI::URL::escape($session{form}{atLeastOne}).'&numResults='.$session{form}{numResults}
                .'&without='.WebGUI::URL::escape($session{form}{without}));
	$p = WebGUI::Paginator->new($url, [], $_[0]->get("submissionsPerPage"));
	$p->setDataByQuery("select USS_submissionId, content, title, userId, status, image, dateSubmitted, username
		from USS_submission where wobjectId=".$_[0]->get("wobjectId")." and $constraints order by dateSubmitted desc");
	$page = $p->getPageData;
	$i = 0;
	foreach $row (@$page) {
		$page->[$i]->{content} = WebGUI::HTML::filter($page->[$i]->{content},$session{setting}{filterContributedHTML});
                $page->[$i]->{content} =~ s/\n/\^\-\;/ unless ($page->[$i]->{content} =~ m/\^\-\;/);
                @content = split(/\^\-\;/,$page->[$i]->{content});
                if ($page->[$i]->{image} ne "") {
                        $image = WebGUI::Attachment->new($page->[$i]->{image},$_[0]->get("wobjectId"),$page->[$i]->{USS_submissionId});
                        $thumbnail = $image->getThumbnail;
                } else {
                        $thumbnail = "";
                }
		($responses) = WebGUI::SQL->quickArray("select count(*) from discussion 
			where wobjectId=".$_[0]->get("wobjectId")." and subId=".$row->{USS_submissionId});
                push (@submission,{
                        "submission.id"=>$page->[$i]->{USS_submissionId},
                        "submission.url"=>WebGUI::URL::page('wid='.$_[0]->get("wobjectId").'&func=viewSubmission&sid='.$page->[$i]->{USS_submissionId}),
                        "submission.content"=>$content[0],
			"submission.responses"=>$responses,
                        "submission.title"=>$page->[$i]->{title},
                        "submission.userId"=>$page->[$i]->{userId},
                        "submission.status"=>$page->[$i]->{status},
                        "submission.thumbnail"=>$thumbnail,
                        "submission.date"=>epochToHuman($page->[$i]->{dateSubmitted}),
                        "submission.currentUser"=>($session{user}{userId} == $page->[$i]->{userId}),
                        "submission.username"=>$page->[$i]->{username},
                        "submission.userProfile"=>WebGUI::URL::page('op=viewProfile&uid='.$page->[$i]->{userId}),
                        "submission.secondColumn"=>($i%2==0),
                        "submission.thirdColumn"=>($i%3==0),
                        "submission.fourthColumn"=>($i%4==0),
                        "submission.fifthColumn"=>($i%5==0),
                        });
		$i++;
	}
	$var{submissions_loop} = \@submission;
	$var{firstPage} = $p->getFirstPageLink;
	$var{lastPage} = $p->getLastPageLink;
	$var{nextPage} = $p->getNextPageLink;
	$var{pageList} = $p->getPageLinks;
	$var{previousPage} = $p->getPreviousPageLink;
	$var{multiplePages} = ($p->getNumberOfPages > 1);
	return $_[0]->processMacros($_[0]->displayTitle).$_[0]->processTemplate($_[0]->get("templateId"),\%var);
}

#-------------------------------------------------------------------
sub www_viewSubmission {
	my ($output, $submission, $file, @data, %var, $replies);
	WebGUI::SQL->write("update USS_submission set views=views+1 where USS_submissionId=$session{form}{sid}");
	$submission = $_[0]->getCollateral("USS_submission","USS_submissionId",$session{form}{sid});
	$var{title} = $submission->{title};
	$var{content} = WebGUI::HTML::filter($submission->{content},$session{setting}{filterContributedHTML});
	$var{content} =~ s/\^\-\;//g;
	$var{content} =~ s/\n/\<br\>/g if ($submission->{convertCarriageReturns});
        $var{"label.by"} = WebGUI::International::get(21,$namespace);
	$var{userProfile} = WebGUI::URL::page('op=viewProfile&uid='.$submission->{userId});
	$var{userId} = $submission->{userId};
	$var{username} = $submission->{username};
	$var{"label.date"} = WebGUI::International::get(13,$namespace);
	$var{date} = epochToHuman($submission->{dateSubmitted});
	$var{"label.status"} = WebGUI::International::get(14,$namespace);
	$var{status} = $submissionStatus{$submission->{status}};
	$var{"label.views"} = WebGUI::International::get(514);
	$var{views} = $submission->{views};
	@data = WebGUI::SQL->quickArray("select max(USS_submissionId) from USS_submission 
        	where wobjectId=$submission->{wobjectId} and USS_submissionId<$submission->{USS_submissionId}
		and (userId=$submission->{userId} or status='Approved')");
        if ($data[0] ne "") {
        	$var{previousSubmission} = '<a href="'.WebGUI::URL::page('func=viewSubmission&sid='.$data[0].'&wid='.
                	$session{form}{wid}).'">&laquo; '.WebGUI::International::get(58,$namespace).'</a>';
        }
        @data = WebGUI::SQL->quickArray("select min(USS_submissionId) from USS_submission 
                where wobjectId=$submission->{wobjectId} and USS_submissionId>$submission->{USS_submissionId}
		and (userId=$submission->{userId} or status='Approved')");
        if ($data[0] ne "") {
                $var{nextSubmission} = '<a href="'.WebGUI::URL::page('func=viewSubmission&sid='.$data[0].'&wid='.
                        $session{form}{wid}).'">'.WebGUI::International::get(59,$namespace).' &raquo;</a>';
        }
        if ($submission->{userId} == $session{user}{userId} || WebGUI::Privilege::isInGroup($_[0]->get("groupToApprove"))) {
                $var{deleteSubmission} = '<a href="'.WebGUI::URL::page('func=deleteSubmission&wid='.$session{form}{wid}.'&sid='.
			$session{form}{sid}).'">'.WebGUI::International::get(37,$namespace).'</a>';
                $var{editSubmission} = '<a href="'.WebGUI::URL::page('func=editSubmission&wid='.$session{form}{wid}.'&sid='.
			$session{form}{sid}).'">'.WebGUI::International::get(27,$namespace).'</a>';
        }
        if ($submission->{status} ne "Approved" && WebGUI::Privilege::isInGroup($_[0]->get("groupToApprove"),$session{user}{userId})) {
                $var{approveSubmission} = '<a href="'.WebGUI::URL::page('func=approveSubmission&wid='.$session{form}{wid}.
			'&sid='.$session{form}{sid}.'&mlog='.$session{form}{mlog}).'">'.
			WebGUI::International::get(572).'</a>';
                $var{leaveSubmission} = '<a href="'.WebGUI::URL::page('op=viewMessageLog').'">'.
			WebGUI::International::get(573).'</a>';
                $var{denySubmission} = '<a href="'.WebGUI::URL::page('func=denySubmission&wid='.$session{form}{wid}.
			'&sid='.$session{form}{sid}.'&mlog='.$session{form}{mlog}).'">'.
			WebGUI::International::get(574).'</a>';
        }
	if ($_[0]->get("allowDiscussion")) {
		$var{postReply} = '<a href="'.WebGUI::URL::page('func=post&mid=new&wid='.$_[0]->get("wobjectId")
			.'&sid='.$session{form}{sid}).'">'.WebGUI::International::get(47,$namespace).'</a>';
	}
	$var{search} = '<a href="'.WebGUI::URL::page('search=1&func=view&wid='.$_[0]->get("wobjectId")).'">'
		.WebGUI::International::get(364).'</a>';
        $var{backToList} = '<a href="'.WebGUI::URL::page().'">'.WebGUI::International::get(28,$namespace).'</a>';
	if ($submission->{image} ne "") {
		$file = WebGUI::Attachment->new($submission->{image},$session{form}{wid},$session{form}{sid});
		$var{image} = $file->getURL;
		$var{thumbnail} = $file->getThumbnail;
	}
	if ($submission->{attachment} ne "") {
		$file = WebGUI::Attachment->new($submission->{attachment},$session{form}{wid},$session{form}{sid});
		$var{attachment} = $file->box;
        }		
	$output = WebGUI::Template::process(WebGUI::Template::get($_[0]->get("submissionTemplateId"),"USS/Submission"), \%var);
        if ($_[0]->get("allowDiscussion")) {
		$output .= WebGUI::Discussion::showThreads();
        }
	return $output;
}



1;

