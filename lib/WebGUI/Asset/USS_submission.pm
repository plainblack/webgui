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
				fieldType=>"HTMLArea",
				defaultValue=>undef
				},
			userDefined2 => {
				fieldType=>"HTMLArea",
				defaultValue=>undef
				},
			userDefined3 => {
				fieldType=>"HTMLArea",
				defaultValue=>undef
				},
			userDefined4 => {
				fieldType=>"HTMLArea",
				defaultValue=>undef
				},
			userDefined5 => {
				fieldType=>"HTMLArea",
				defaultValue=>undef
				},
			content => {
				fieldType=>"HTMLArea",
				defaultValue=>undef
				}
			},
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
	$data{isHidden} = 1;
	$self->update(\%data);
}
                                                                                                                                                       

#-------------------------------------------------------------------
sub view {
	my $self = shift;
	my %var;
	#my $callback = WebGUI::URL::gateway($parentsPage->get("urlizedTitle"),"func=viewSubmission&amp;wid=".$self->wid."&amp;sid=".$submission->{USS_submissionId});
#	if ($session{form}{forumOp} ne "" && $session{form}{forumOp} ne "viewForum") {	
#		return WebGUI::Forum::UI::forumOp({
#			callback=>$callback,
#			title=>$submission->{title},
#			forumId=>$submission->{forumId}
#			});
#	}
	$self->update({views=>$self->get("views")+1});
	$var{content} = WebGUI::HTML::filter($self->get("content"),$self->get("filterContent"));
	$var{content} = WebGUI::HTML::format($var{content},"USS");
        $var{"user.label"} = WebGUI::International::get(21,"USS");
	$var{"user.Profile"} = $self->getUrl('op=viewProfile&uid='.$self->get("ownerUserId"));
	$var{"user.Id"} = $self->get("ownerUserId");
	$var{"user.username"} = $self->get("username");
	$var{"date.label"} = WebGUI::International::get(13,"USS");
	$var{"date.epoch"} = $self->get("dateSubmitted");
	$var{"date.human"} = epochToHuman($self->get("dateSubmitted"));
	$var{"date.updated.label"} = WebGUI::International::get(78,"USS");
	$var{"date.updated.human"} = epochToHuman($self->get("dateUpdated"));
	$var{"date.updated.epoch"} = $self->get("dateUpdated");
	$var{"status.label"} = WebGUI::International::get(14,"USS");
	$var{"status.status"} = $self->getParent->status($self->get("status"));
	$var{"views.label"} = WebGUI::International::get(514);
	$var{"views.count"} = $self->getResponseCount;
        $var{canPost} = $self->canContribute;
        $var{"post.url"} = $self->getUrl("func=edit");
        $var{"post.label"} = WebGUI::International::get(20,"USS");
	my $previous = WebGUI::Asset::USS_submission->newByPropertyHashRef(
		WebGUI::SQL->quickHashRef("
			select * 
			from USS_submission 
			left join asset on asset.assetId=USS_submission.assetId 
			where asset.parentId=".quote($self->get("parentId"))." 
				and asset.state='published' 
				and ".$self->getParent->getValue("sortBy")."<".quote($self->get($self->getParent->getValue("sortBy")))." 
				and (userId=".quote($self->get("ownerUserId"))." or status='Approved') 
			order by ".$self->getParent->getValue("sortBy")." desc
			",WebGUI::SQL->getSlave)
		);
	$var{"previous.more"} = defined $previous;
	$var{"previous.url"} = $previous->getUrl if ($var{"previous.more"});
	$var{"previous.label"} = WebGUI::International::get(58,"USS");
	my $next = WebGUI::Asset::USS_submission->newByPropertyHashRef(
		WebGUI::SQL->quickHashRef("
			select * 
			from USS_submission 
			left join asset on asset.assetId=USS_submission.assetId 
			where asset.parentId=".quote($self->get("parentId"))." 
				and asset.state='published' 
				and ".$self->getParent->getValue("sortBy").">".quote($self->get($self->getParent->getValue("sortBy")))." 
				and (userId=".quote($self->get("ownerUserId"))." or status='Approved') 
			order by ".$self->getParent->getValue("sortBy")." asc 
			",WebGUI::SQL->getSlave)
		);
	$var{"next.more"} = defined $next;
	$var{"next.url"} = $next->getUrl if ($var{"next.more"});
	$var{"next.label"} = WebGUI::International::get(59,"USS");
        $var{canEdit} = $self->canEdit;
        $var{"delete.url"} = $self->getUrl("func=delete");
	$var{"delete.label"} = WebGUI::International::get(37,"USS");
        $var{"edit.url"} = $self->getUrl("func=edit");
	$var{"edit.label"} = WebGUI::International::get(27,"USS");
        $var{canChangeStatus} = $self->canModerate;
        $var{"approve.url"} = $self->getUrl("func=approve&mlog=".$session{form}{mlog});
	$var{"approve.label"} = WebGUI::International::get(572);
        $var{"leave.url"} = $self->getUrl('op=viewMessageLog');
	$var{"leave.label"} = WebGUI::International::get(573);
        $var{"deny.url"} = $self->getUrl("func=deny&mlog=".$session{form}{mlog});
	$var{"deny.label"} = WebGUI::International::get(574);
	$var{"canReply"} = $self->get("allowDiscussion");
#	$var{"reply.url"} = WebGUI::Forum::UI::formatNewThreadURL($callback,$submission->{forumId});
#	$var{"reply.label"} = WebGUI::International::get(47,"USS");
	$var{"search.url"} = WebGUI::Search::toggleURL("",$self->getParent->get("url"));
	$var{"search.label"} = WebGUI::International::get(364);
        $var{"back.url"} = $self->getParent->getUrl;
	$var{"back.label"} = WebGUI::International::get(28,"USS");
	$var{'userDefined1.value'} = $self->get("userDefined1");
	$var{'userDefined2.value'} = $self->get("userDefined2");
	$var{'userDefined3.value'} = $self->get("userDefined3");
	$var{'userDefined4.value'} = $self->get("userDefined4");
	$var{'userDefined5.value'} = $self->get("userDefined5");
#	if ($submission->{image} ne "") {
#		$file = WebGUI::Attachment->new($submission->{image},$self->wid,$submissionId);
#		$var{"image.url"} = $file->getURL;
#		$var{"image.thumbnail"} = $file->getThumbnail;
#	}
#	if ($submission->{attachment} ne "") {
#		$file = WebGUI::Attachment->new($submission->{attachment},$self->wid,$submissionId);
#		$var{"attachment.box"} = $file->box;
#		$var{"attachment.url"} = $file->getURL;
#		$var{"attachment.icon"} = $file->getIcon;
#		$var{"attachment.name"} = $file->getFilename;
 #       }	
	if ($self->get("allowDiscussion")) {
#		$var{"replies"} = WebGUI::Forum::UI::www_viewForum(
#			{callback=>$callback,title=>$submission->{title},forumId=>$submission->{forumId}},
#			$submission->{forumId});
	}
	return $self->processTemplate(\%var,$self->getParent->get("submissionTemplateId"));
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
		$var{'form.header'} .= WebGUI::Form::hidden({
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
		name=>"content",
		value=>$self->get("content")
		});
	$var{'body.form.textarea'} = WebGUI::Form::textarea({
		name=>"content",
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
                value=>$self->get("contentType") || "mixed"
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
	return $self->getParent->processStyle($self->processTemplate(\%var,$self->getParent->get("submissionFormTemplateId")));
}


#-------------------------------------------------------------------
sub www_view {
	my $self = shift;
	return $self->getParent->processStyle(WebGUI::Privilege::noAccess()) unless $self->canView;
	return $self->getParent->processStyle($self->view);
}


1;

