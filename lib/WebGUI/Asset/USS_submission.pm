package WebGUI::Asset::USS_submission;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use Tie::CPHash;
use WebGUI::Asset;
use WebGUI::Asset::Template;
use WebGUI::Asset::Wobject::USS;
use WebGUI::DateTime;
#use WebGUI::Forum;
#use WebGUI::Forum::UI;
use WebGUI::Grouping;
use WebGUI::HTML;
use WebGUI::HTMLForm;
use WebGUI::HTTP;
use WebGUI::Icon;
use WebGUI::Id;
use WebGUI::International;
use WebGUI::MessageLog;
use WebGUI::Operation;
use WebGUI::Paginator;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Style;
use WebGUI::URL;
use WebGUI::User;
use WebGUI::Utility;

our @ISA = qw(WebGUI::Asset);



#-------------------------------------------------------------------
sub canContribute {
	my $self = shift;
	return WebGUI::Grouping::isInGroup($self->getParent->get("groupToContribute"));
}


#-------------------------------------------------------------------
sub canEdit {
	my $self = shift;
	return 	( ($session{form}{func} eq "add" && $self->canContribute) || $self->canModerate || $self->canEdit);

}


#-------------------------------------------------------------------
sub canModerate {
	my $self = shift;
        return WebGUI::Grouping::isInGroup($self->getParent->get("groupToApprove"));
}

#-------------------------------------------------------------------
sub definition {
	my $class = shift;
        my $definition = shift;
        push(@{$definition}, {
                tableName=>'USS_submission',
                className=>'WebGUI::Asset::Wobject::USS_submission',
                properties=>{
			dateSubmitted => {
				fieldType=>"hidden",
				defaultValue=>time()
				},
			dateUpdated => {
				fieldType=>"hidden",
				defaultValue=>time()
				},
			username => {
				fieldType=>"hidden",
				defaultValue=>$session{user}{username}
				},
			status => {
				fieldType=>"hidden",
				defaultValue=>'Approved'
				},
			views => {
				fieldType=>"hidden",
				defaultValue=>0
				},
			contentType => {
				fieldType=>"contentType",
				defaultValue=>"mixed"
				},
			userDefined1 => {
				fieldType=>"text",
				defaultValue=>undef
				},
			userDefined2 => {
				fieldType=>"text",
				defaultValue=>undef
				},
			userDefined3 => {
				fieldType=>"text",
				defaultValue=>undef
				},
			userDefined4 => {
				fieldType=>"text",
				defaultValue=>undef
				},
			userDefined5 => {
				fieldType=>"text",
				defaultValue=>undef
				}
			}
		});
        return $class->SUPER::definition($definition);
}


#-------------------------------------------------------------------
sub getIcon {
	my $self = shift;
	my $small = shift;
	return $session{config}{extrasURL}.'/assets/small/userSubmissionSystem.gif' if ($small);
	return $session{config}{extrasURL}.'/assets/userSubmissionSystem.gif';
}

#-------------------------------------------------------------------
sub getImageUrl {
	return '/image.jpg';
}

#-------------------------------------------------------------------
sub getName {
        return "USS Submission";
}

#-------------------------------------------------------------------
sub getResponseCount {
	return 0;
}

#-------------------------------------------------------------------
sub getStatus {
	return 'Approved';
}

#-------------------------------------------------------------------
sub getThumbnailUrl {
	return '/thumbnail.jpg';
}

#-------------------------------------------------------------------
sub processPropertiesFromFormPost {
	my $self = shift;
	$self->SUPER::processPropertiesFromFormPost;
	my %data = (
		ownerUserId => $session{user}{userId},
		groupIdView => $self->getParent->get("groupIdView"),
		groupIdEdit => $self->getParent->get("groupIdEdit")
		);
	$data{startDate} = $self->getParent->get("startDate") unless ($session{form}{startDate});
	$data{endDate} = $self->getParent->get("endDate") unless ($session{form}{endDate});
	unless ($session{form}{synopsis}) {
		my $body = $session{form}{content};
                $body =~ s/\n/\^\-\;/ unless ($body =~ m/\^\-\;/);
                my @content = split(/\^\-\;/,$body);
		$content[0] = WebGUI::HTML::filter($content[0],"none");
		$data{synopsis} = $content[0];
		$body =~ s/\^\-\;/\n/;
		$data{content} = $body;
	}
	$self->update(\%data);
}
                                                                                                                                                       
#-------------------------------------------------------------------
sub status {
        if ($_[0] eq "Approved") {
                return WebGUI::International::get(560);
        } elsif ($_[0] eq "Denied") {
                return WebGUI::International::get(561);
        } elsif ($_[0] eq "Pending") {
                return WebGUI::International::get(562);
        }
}


#-------------------------------------------------------------------
sub view {
	my $self = shift;
	my $submissionId = shift || $session{form}{sid};
	$self->logView() if ($session{setting}{passiveProfilingEnabled});
	return "" unless ($submissionId);
	my ($file, @data, %var, $replies);
	my $submission = $self->getCollateral("USS_submission","USS_submissionId",$submissionId);
	return "" unless ($submission->{USS_submissionId});
        return "" unless ($submission->{status} eq 'Approved' ||
                ($submission->{userId} eq $session{user}{userId} && $session{user}{userId} != 1) ||
                WebGUI::Grouping::isInGroup($self->getValue("groupToApprove")));
	my $parentsPage = WebGUI::Page->new($self->get("pageId"));
	my $callback = WebGUI::URL::gateway($parentsPage->get("urlizedTitle"),"func=viewSubmission&amp;wid=".$self->wid."&amp;sid=".$submission->{USS_submissionId});
	if ($session{form}{forumOp} ne "" && $session{form}{forumOp} ne "viewForum") {	
		return WebGUI::Forum::UI::forumOp({
			callback=>$callback,
			title=>$submission->{title},
			forumId=>$submission->{forumId}
			});
	}
	WebGUI::SQL->write("update USS_submission set views=views+1 where USS_submissionId=".quote($submissionId));
	$var{title} = $submission->{title};
	$var{content} = WebGUI::HTML::filter($submission->{content},$self->get("filterContent"));
	$var{content} =~ s/\^\-\;//g;
	$var{content} = WebGUI::HTML::format($var{content},$submission->{contentType});
        $var{"user.label"} = WebGUI::International::get(21,$self->get("namespace"));
	$var{"user.Profile"} = WebGUI::URL::page('op=viewProfile&uid='.$submission->{userId});
	$var{"user.Id"} = $submission->{userId};
	$var{"user.username"} = $submission->{username};
	$var{"date.label"} = WebGUI::International::get(13,$self->get("namespace"));
	$var{"date.epoch"} = $submission->{dateSubmitted};
	$var{"date.human"} = epochToHuman($submission->{dateSubmitted});
	$var{"date.updated.label"} = WebGUI::International::get(78,$self->get("namespace"));
	$var{"date.updated.human"} = epochToHuman($submission->{dateUpdated});
	$var{"date.updated.epoch"} = $submission->{dateUpdated};
	$var{"status.label"} = WebGUI::International::get(14,$self->get("namespace"));
	$var{"status.status"} = status($submission->{status});
	$var{"views.label"} = WebGUI::International::get(514);
	$var{"views.count"} = $submission->{views};
        $var{canPost} = WebGUI::Grouping::isInGroup($self->get("groupToContribute"));
        $var{"post.url"} = WebGUI::URL::gateway($parentsPage->get("urlizedTitle"),'func=editSubmission&sid=new&wid='.$self->wid);
        $var{"post.label"} = WebGUI::International::get(20,$self->get("namespace"));
	@data = WebGUI::SQL->quickArray("select USS_submissionId from USS_submission 
        	where USS_id=".quote($self->get("USS_id"))." and dateSubmitted<".quote($submission->{dateSubmitted})."
		and (userId=".quote($submission->{userId})." or status='Approved') order by dateSubmitted desc",WebGUI::SQL->getSlave);
        $var{"previous.more"} = ($data[0] ne "");
	if ($var{"previous.more"}) {
		my $previousSubmission = $self->getCollateral("USS_submission","USS_submissionId",$data[0]);
		my $previousPage = WebGUI::Page->new($previousSubmission->{pageId});
       		$var{"previous.url"} = WebGUI::URL::gateway($previousPage->get("urlizedTitle"));
	}
	$var{"previous.label"} = WebGUI::International::get(58,$self->get("namespace"));
        @data = WebGUI::SQL->quickArray("select USS_submissionId from USS_submission 
                where USS_id=".quote($submission->{USS_id})." and dateSubmitted>".quote($submission->{dateSubmitted})."
		and (userId=".quote($submission->{userId})." or status='Approved') order by dateSubmitted asc",WebGUI::SQL->getSlave);
        $var{"next.more"} = ($data[0] ne "");
	if ($var{"next.more"}) {
		my $nextSubmission = $self->getCollateral("USS_submission","USS_submissionId",$data[0]);
		my $nextPage = WebGUI::Page->new($nextSubmission->{pageId});
	        $var{"next.url"} = WebGUI::URL::gateway($nextPage->get("urlizedTitle"));
	}
	$var{"next.label"} = WebGUI::International::get(59,$self->get("namespace"));
        $var{canEdit} = (($submission->{userId} eq $session{user}{userId} || WebGUI::Grouping::isInGroup($self->get("groupToApprove"))) && $session{user}{userId} != 1);
        $var{"delete.url"} = WebGUI::URL::gateway($parentsPage->get("urlizedTitle"),'func=deleteSubmissionConfirm&wid='.$self->wid.'&sid='.$submissionId);
	$var{"delete.label"} = WebGUI::International::get(37,$self->get("namespace"));
        $var{"edit.url"} = WebGUI::URL::gateway($parentsPage->get("urlizedTitle"),'func=editSubmission&wid='.$self->wid.'&sid='.$submissionId);
	$var{"edit.label"} = WebGUI::International::get(27,$self->get("namespace"));
        $var{canChangeStatus} = WebGUI::Grouping::isInGroup($self->get("groupToApprove"),$session{user}{userId});
        $var{"approve.url"} = WebGUI::URL::gateway($parentsPage->get("urlizedTitle"),'func=approveSubmission&wid='.$self->wid.'&sid='.$submissionId.'&mlog='.$session{form}{mlog});
	$var{"approve.label"} = WebGUI::International::get(572);
        $var{"leave.url"} = WebGUI::URL::page('op=viewMessageLog');
	$var{"leave.label"} = WebGUI::International::get(573);
        $var{"deny.url"} = WebGUI::URL::gateway($parentsPage->get("urlizedTitle"),'func=denySubmission&wid='.$self->wid.'&sid='.$submissionId.'&mlog='.$session{form}{mlog});
	$var{"deny.label"} = WebGUI::International::get(574);
	$var{"canReply"} = ($self->get("allowDiscussion"));
	$var{"reply.url"} = WebGUI::Forum::UI::formatNewThreadURL($callback,$submission->{forumId});
	$var{"reply.label"} = WebGUI::International::get(47,$self->get("namespace"));
	$var{"search.url"} = WebGUI::Search::toggleURL("",$parentsPage->get("urlizedTitle"));
	$var{"search.label"} = WebGUI::International::get(364);
        $var{"back.url"} = WebGUI::URL::gateway($parentsPage->get("urlizedTitle"));
	$var{"back.label"} = WebGUI::International::get(28,$self->get("namespace"));
	$var{'userDefined1.value'} = $submission->{userDefined1};
	$var{'userDefined2.value'} = $submission->{userDefined2};
	$var{'userDefined3.value'} = $submission->{userDefined3};
	$var{'userDefined4.value'} = $submission->{userDefined4};
	$var{'userDefined5.value'} = $submission->{userDefined5};
	if ($submission->{image} ne "") {
		$file = WebGUI::Attachment->new($submission->{image},$self->wid,$submissionId);
		$var{"image.url"} = $file->getURL;
		$var{"image.thumbnail"} = $file->getThumbnail;
	}
	if ($submission->{attachment} ne "") {
		$file = WebGUI::Attachment->new($submission->{attachment},$self->wid,$submissionId);
		$var{"attachment.box"} = $file->box;
		$var{"attachment.url"} = $file->getURL;
		$var{"attachment.icon"} = $file->getIcon;
		$var{"attachment.name"} = $file->getFilename;
        }	
	if ($self->get("allowDiscussion")) {
		$var{"replies"} = WebGUI::Forum::UI::www_viewForum(
			{callback=>$callback,title=>$submission->{title},forumId=>$submission->{forumId}},
			$submission->{forumId});
	}
	return $self->processTemplate(\%var,$self->get("submissionTemplateId"));
}

#-------------------------------------------------------------------
sub www_approve {
	my $self = shift;
        return WebGUI::Privilege::insufficient() unless ($self->canModerate);
	$self->update({"status"=>'Approved'});
	WebGUI::MessageLog::addInternationalizedEntry($self->get("ownerUserId"),'',$self->getUrl,4,"USS");
	if ($session{form}{mlog}) {
		WebGUI::MessageLog::completeEntry($session{form}{mlog});
        	return WebGUI::Operation::www_viewMessageLog();
	}
	return $self->www_view;
}


#-------------------------------------------------------------------
sub www_deny {
	my $self = shift;
        return WebGUI::Privilege::insufficient() unless ($self->canModerate);
	$self->update({status=>'Denied'});
	WebGUI::MessageLog::addInternationalizedEntry($self->get("ownerUserId"),'',$self->getUrl,5,"USS");
	if ($session{form}{mlog}) {
		WebGUI::MessageLog::completeEntry($session{form}{mlog});
        	return WebGUI::Operation::www_viewMessageLog();
	}
	return $self->www_view;
}


#-------------------------------------------------------------------
sub www_edit {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless ($self->canEdit);
	my %var;
	if ($session{form}{func} eq "add") {
		$self->{_properties}{contentType} = "mixed";
		$var{'submission.isNew'} = 1;
	}
	$var{'link.header.label'} = WebGUI::International::get(90,"USS");
	$var{'question.header.label'} = WebGUI::International::get(84,"USS");
        $var{'submission.header.label'} = WebGUI::International::get(19,"USS");
	$var{'user.isVisitor'} = ($session{user}{userId} eq '1');
        $var{'visitorName.label'} = WebGUI::International::get(438);
	$var{'visitorName.form'} = WebGUI::Form::text({
		name=>"visitorName"
		});
        $var{'form.header'} = WebGUI::Form::formHeader()
		.WebGUI::Form::hidden({
                	name=>"func",
			value=>"editSave"
			});
	if ($self->getId eq "new") {
		$var{'form.header'} = WebGUI::Form::hidden({
			name=>"assetId",
			value=>"new"
			}).WebGUI::Form::hidden({
			name=>"class",
			value=>$session{form}{class}
			});
	}
        $var{'url.label'} = WebGUI::International::get(91,"USS");
        $var{'newWindow.label'} = WebGUI::International::get(92,"USS");
	for my $x (1..5) {
		$var{'userDefined'.$x.'.form'} = WebGUI::Form::text({
			name=>"userDefined".$x,
			value=>$self->get("userDefined".$x)
			});
		$var{'userDefined'.$x.'.form.yesNo'} = WebGUI::Form::yesNo({
			name=>"userDefined".$x,
			value=>$self->get("userDefined".$x)
			});
		$var{'userDefined'.$x.'.form.textarea'} = WebGUI::Form::textarea({
			name=>"userDefined".$x,
			value=>$self->get("userDefined".$x)
			});
		$var{'userDefined'.$x.'.form.textarea'} = WebGUI::Form::HTMLArea({
			name=>"userDefined".$x,
			value=>$self->get("userDefined".$x)
			});
		$var{'userDefined'.$x.'.value'} = $self->get('userDefined'.$x);
	}
	$var{'question.label'} = WebGUI::International::get(85,"USS");
	$var{'title.label'} = WebGUI::International::get(35,"USS");
	$var{'title.form'} = WebGUI::Form::text({
		name=>"title",
		value=>$self->get("title")
		});
	$var{'title.form.textarea'} = WebGUI::Form::textarea({
		name=>"title",
		value=>$self->get("title")
		});
	$var{'title.value'} = $self->get("title"); 
        $var{'body.label'} = WebGUI::International::get(31,"USS");
	$var{'answer.label'} = WebGUI::International::get(86,"USS");
        $var{'description.label'} = WebGUI::International::get(85);
	$var{'body.value'} = $self->get("content"); 
	$var{'body.form'} = WebGUI::Form::HTMLArea({
		name=>"body",
		value=>$self->get("content")
		});
	$var{'body.form.textarea'} = WebGUI::Form::textarea({
		name=>"body",
		value=>$self->get("content")
		});
#	$var{'image.label'} = WebGUI::International::get(32,"USS");
 #       if ($submission->{image} ne "") {
#		$var{'image.form'} = '<a href="'.WebGUI::URL::page('func=deleteFile&amp;file=image&amp;wid='.$session{form}{wid}
#			.'&amp;sid='.$submission->{USS_submissionId}).'">'.WebGUI::International::get(391).'</a>';
 #       } else {
#		$var{'image.form'} = WebGUI::Form::file({
#			name=>"image"
#			});
 #       }
#	$var{'attachment.label'} = WebGUI::International::get(33,"USS");
 #       if ($submission->{attachment} ne "") {
#		$var{'attachment.form'} = '<a href="'.WebGUI::URL::page('func=deleteFile&amp;file=attachment&amp;wid='
#			.$session{form}{wid}.'&amp;sid='.$submission->{USS_submissionId}).'">'.WebGUI::International::get(391).'</a>';
 #       } else {
#		$var{'attachment.form'} = WebGUI::Form::file({
#			name=>"attachment"
#			});
 #       }
	$var{'contentType.label'} = WebGUI::International::get(1007);
        $var{'contentType.form'} = WebGUI::Form::contentType({
                name=>'contentType',
                value=>[$self->get("contentType")] || ["mixed"]
                });
	$var{'startDate.label'} = WebGUI::International::get(497);
	$var{'endDate.label'} = WebGUI::International::get(498);
	$var{'startDate.form'} = WebGUI::Form::dateTime({
		name  => 'startDate',
		value => $self->get("startDate")
		});
	$var{'endDate.form'} = WebGUI::Form::dateTime({
		name  => 'endDate',
		value => $self->get("startDate")
		});
	$var{'form.submit'} = WebGUI::Form::submit();
	$var{'form.footer'} = WebGUI::Form::formFooter();
	return $self->getParent->processStyle($self->processTemplate(\%var,$self->getParent->get("submissionFormTemplate")));
}

#-------------------------------------------------------------------
sub www_editSave2 {
	my ($submission, %hash, $file, $u);
	$submission = $_[0]->getCollateral("USS_submission","USS_submissionId",$session{form}{sid});
        if ($submission->{userId} eq $session{user}{userId} 
		|| ($submission->{USS_submissionId} eq "new" 
		&& WebGUI::Grouping::isInGroup($_[0]->get("groupToContribute"))) 
		|| WebGUI::Grouping::isInGroup($_[0]->get("groupToApprove"))) {
                if ($session{form}{sid} eq "new") {
			my $parentPage = WebGUI::Page->new($_[0]->get("pageId"));
                	my $newPage = $parentPage->add;
			$hash{pageId} = $submission->{pageId} = $newPage->get("pageId");
			my $forum = WebGUI::Forum->create({
				masterForumId=>$_[0]->get("forumId"),
				forumId=>"new"
				});
			$hash{forumId} = $forum->get("forumId");
			$hash{USS_id} = $_[0]->get("USS_id");
			$hash{username} = $session{form}{visitorName} || $session{user}{alias};
			$hash{userId} = $session{user}{userId};
			$hash{dateSubmitted} = WebGUI::DateTime::time();
			$hash{USS_submissionId} = "new";
			if ($session{setting}{useKarma}) {
                        	$u = WebGUI::User->new($session{user}{userId});
                        	$u->karma($_[0]->get("karmaPerSubmission"),$_[0]->get("namespace")." (".$_[0]->get("wobjectId")
                                	."/".$session{form}{sid}.")","User submission.");
			}
			$session{form}{sid} = $_[0]->setCollateral("USS_submission","USS_submissionId",\%hash,1,0,"USS_id",$_[0]->get("USS_id"));
        	        my %pageVars = %{$parentPage->get};
                	delete $pageVars{pageId};
	                delete $pageVars{nestedSetLeft};
        	        delete $pageVars{nestedSetRight};
               	 	delete $pageVars{depth};
                	delete $pageVars{parentId};
	                delete $pageVars{sequenceNumber};
        	        $pageVars{hideFromNavigation} = 1;
			$pageVars{isSystem} = 1;
                	$pageVars{subroutine} = "viewSubmissionAsPage";
                	$pageVars{subroutinePackage} = "WebGUI::Wobject::USS";
                	$pageVars{subroutineParams} = "{wobjectId=>'".$_[0]->wid."',submissionId=>'".$session{form}{sid}."'}";
                	$pageVars{urlizedTitle} .= "/".$_[0]->get("title")."/".$session{form}{title};
 			$pageVars{urlizedTitle} .= ".".$session{setting}{urlExtension} unless ($pageVars{urlizedTitle} =~ /\./ && $session{setting}{urlExtension} ne "");
                	$pageVars{urlizedTitle} = WebGUI::Page::makeUnique(WebGUI::URL::urlize($pageVars{urlizedTitle},-999));
                	$newPage->set(\%pageVars);
			%hash = ();
                }
                $hash{title} = WebGUI::HTML::filter($session{form}{title},'all') || WebGUI::International::get(16,$_[0]->get("namespace"));
		$hash{USS_submissionId} = $session{form}{sid};
		$hash{dateUpdated} = WebGUI::DateTime::time();
		$hash{content} = $session{form}{body};
		$hash{userDefined1} = $session{form}{userDefined1};
		$hash{userDefined2} = $session{form}{userDefined2};
		$hash{userDefined3} = $session{form}{userDefined3};
		$hash{userDefined4} = $session{form}{userDefined4};
		$hash{userDefined5} = $session{form}{userDefined5};
		$hash{startDate} = WebGUI::DateTime::humanToEpoch($session{form}{startDate});
		$hash{endDate} = WebGUI::DateTime::humanToEpoch($session{form}{endDate}); 
		$hash{contentType} = $session{form}{contentType};
                $file = WebGUI::Attachment->new("",$session{form}{wid},$session{form}{sid});
		$file->save("image");
		$hash{image} = $file->getFilename if ($file->getFilename ne "");
                $file = WebGUI::Attachment->new("",$session{form}{wid},$session{form}{sid});
		$file->save("attachment");
		$hash{attachment} = $file->getFilename if ($file->getFilename ne "");
		unless ($_[0]->get("defaultStatus") eq "Approved") {
			unless (WebGUI::Grouping::isInGroup($_[0]->get("groupToApprove")) ) {
				$hash{status} = $_[0]->get("defaultStatus");
				WebGUI::MessageLog::addInternationalizedEntry('',$_[0]->get("groupToApprove"),
					WebGUI::URL::page('func=viewSubmission&wid='.$_[0]->get("wobjectId").'&sid='.
					$session{form}{sid},1),3,$_[0]->get("namespace"),'pending');
			} else {
				$hash{status} = "Approved";
			}
		}
		my %pageVars;
                $pageVars{title} = $pageVars{menuTitle} = $hash{title};
		my $page = WebGUI::Page->new($submission->{pageId});
               	$page->set(\%pageVars);
		$_[0]->setCollateral("USS_submission", "USS_submissionId", \%hash, 1, 0, "USS_id", $_[0]->get("USS_id"));
		$_[0]->deleteCachedSubmission($hash{USS_submissionId});
                return $_[0]->www_viewSubmission();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}


#-------------------------------------------------------------------
sub www_view {
	my $self = shift;
	return WebGUI::Privilege::noAccess() unless $self->canView;
	return $self->getParent->processStyle($self->view);
}


1;

