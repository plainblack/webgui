package WebGUI::Asset::Post;

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
use WebGUI::Asset::Thread;
use WebGUI::Asset::Wobject::Collaborate;
use WebGUI::DateTime;
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
sub canEdit {
	my $self = shift;
	return ($session{form}{func} eq "add" && $self->getThread->getParent->canPost) || 
		($self->isPoster && $self->getThread->getParent->get("editTimeout") > (WebGUI::DateTime::time() - $self->get("dateUpdated"))) ||
		$self->getThread->getParent->canModerate;

}

#-------------------------------------------------------------------

=head2 canView ( )

Returns a boolean indicating whether the user can view the current post.

=cut

sub canView {
        my $self = shift;
	if ($self->get("status") eq "approved" || $self->get("status") eq "archived") {
		return 1;
	} elsif ($self->get("status") eq "denied" && $self->canEdit) {
		return 1;
	} else {
		return $self->SUPER::canView;
	}
}

#-------------------------------------------------------------------

=head2 chopSubject ( )

Cuts a subject string off at 30 characters.

=cut

sub chopSubject {
	my $self = shift;
        return substr($self->get("title"),0,30);
}

#-------------------------------------------------------------------
sub definition {
	my $class = shift;
        my $definition = shift;
        push(@{$definition}, {
                tableName=>'Post',
                className=>'WebGUI::Asset::Post',
                properties=>{
			threadId => {
				fieldType=>"hidden",
				defaultValue=>undef
				},
			dateSubmitted => {
				fieldType=>"hidden",
				defaultValue=>undef
				},
			dateUpdated => {
				fieldType=>"hidden",
				defaultValue=>time()
				},
			username => {
				fieldType=>"hidden",
				defaultValue=>$session{user}{alias} || $session{user}{username}
				},
			status => {
				fieldType=>"hidden",
				defaultValue=>undef
				},
			rating => {
				fieldType=>"hidden",
				defaultValue=>undef
				},
			views => {
				fieldType=>"hidden",
				defaultValue=>undef
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
sub DESTROY {
	my $self = shift;
	$self->{_thread}->DESTROY if (exists $self->{_thread});
}


#-------------------------------------------------------------------

=head2 formatContent ( )

Formats post content for display.

=cut

sub formatContent {
	my $self = shift;
        my $msg = WebGUI::HTML::filter($self->get("content"),$self->getThread->getParent->get("filterCode"));
        $msg = WebGUI::HTML::format($msg, $self->get("contentType"));
        if ($self->getThread->getParent->get("useContentFilter")) {
                $msg = WebGUI::HTML::processReplacements($msg);
        }
        return $msg;
}

#-------------------------------------------------------------------

=head2 getApproveUrl (  )

Formats the URL to approve a post.

=cut

sub getApproveUrl {
	my $self = shift;
	return $self->getUrl("func=approve&mlog=".$session{form}{mlog});
}

#-------------------------------------------------------------------

=head2 getDeleteUrl (  )

Formats the url to delete a post.

=cut

sub getDeleteUrl {
	my $self = shift;
	return $self->getUrl("func=delete");
}

#-------------------------------------------------------------------

=head2 getDenyUrl (  )

Formats the url to deny a post.

=cut

sub getDenyUrl {
	my $self = shift;
	return $self->getUrl("func=deny&mlog=".$session{form}{mlog});
}

#-------------------------------------------------------------------

=head2 getEditUrl ( )

Formats the url to edit a post.

=cut

sub getEditUrl {
	my $self = shift;
	return $self->getUrl("func=edit");
}

#-------------------------------------------------------------------
sub getIcon {
	my $self = shift;
	my $small = shift;
	return $session{config}{extrasURL}.'/assets/small/post.gif' if ($small);
	return $session{config}{extrasURL}.'/assets/post.gif';
}

#-------------------------------------------------------------------
sub getName {
        return "Post";
}

#-------------------------------------------------------------------

=head2 getPosterProfileUrl (  )

Formats the url to view a users profile.

=cut

sub getPosterProfileUrl {
	my $self = shift;
	return $self->getUrl("op=viewProfile&uid=".$self->get("ownerUserId"));
}

#-------------------------------------------------------------------

=head2 getRateUrl ( rating )

Formats the url to rate a post.

=head3 rating

An integer between 1 and 5 (5 = best).

=cut

sub getRateUrl {
	my $self = shift;
	my $rating = shift;
	return $self->getUrl("func=rate&rating=".$rating."#".$self->getId);
}

#-------------------------------------------------------------------

=head2 getReplyUrl ( [ withQuote ] )

Formats the url to reply to a post.

=head3 withQuote

If specified the reply with automatically quote the parent post.

=cut

sub getReplyUrl {
	my $self = shift;
	my $withQuote = shift || 0;
	return $self->getUrl("func=add&class=WebGUI::Asset::Post&withQuote=".$withQuote);
}

#-------------------------------------------------------------------
sub getTemplateVars {
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
	$var{"userProfile.url"} = $self->getUrl('op=viewProfile&uid='.$self->get("ownerUserId"));
	$var{"userId"} = $self->get("ownerUserId");
	$var{"username"} = $self->get("username");
	$var{"dateSubmitted.label"} = WebGUI::International::get(13,"USS");
	$var{"dateSubmitted.human"} = epochToHuman($self->get("dateSubmitted"));
	$var{"dateUpdated.label"} = WebGUI::International::get(78,"USS");
	$var{"dateUpdated.human"} = epochToHuman($self->get("dateUpdated"));
	$var{"status.label"} = WebGUI::International::get(14,"USS");
	$var{"status.status"} = $self->getParent->status($self->get("status"));
	$var{"views.label"} = WebGUI::International::get(514);
        $var{canPost} = $self->canContribute;
        $var{"post.url"} = $self->getUrl("func=edit");
        $var{"post.label"} = WebGUI::International::get(20,"USS");
	my $previous = WebGUI::Asset::Post->newByPropertyHashRef(
		WebGUI::SQL->quickHashRef("
			select asset.*,Post.* 
			from Thread
			left join asset on asset.parentId=Thread.assetId 
			left join Post on Post.assetId=asset.assetId 
			where Thread.parentId=".quote($self->get("parentId"))." 
				and asset.state='published' 
				and ".$self->getParent->getValue("sortBy")."<".quote($self->get($self->getParent->getValue("sortBy")))." 
				and (userId=".quote($self->get("ownerUserId"))." or Post.status='approved') 
			order by ".$self->getParent->getValue("sortBy")." desc
			",WebGUI::SQL->getSlave)
		);
	$var{"previous.more"} = defined $previous;
	$var{"previous.url"} = $previous->getUrl if ($var{"previous.more"});
	$var{"previous.label"} = WebGUI::International::get(58,"USS");
	my $next = WebGUI::Asset::Post->newByPropertyHashRef(
		WebGUI::SQL->quickHashRef("
			select asset.*,Post.* 
			from Thread
			left join asset on asset.parentId=Thread.assetId 
			left join Post on Post.assetId=asset.assetId 
			where Thread.parentId=".quote($self->get("parentId"))." 
				and asset.state='published' 
				and ".$self->getParent->getValue("sortBy").">".quote($self->get($self->getParent->getValue("sortBy")))." 
				and (userId=".quote($self->get("ownerUserId"))." or Post.status='approved') 
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
}

#-------------------------------------------------------------------
sub getThread {
	my $self = shift;
	unless (exists $self->{_thread}) {
		$self->{_thread} = WebGUI::Asset::Thread->new($self->get("threadId"));
	}
	return $self->{_thread};	
}


#-------------------------------------------------------------------

=head2 hasRated (  )

Returns a boolean indicating whether this user has already rated this post.

=cut

sub hasRated {	
	my $self = shift;
        return 1 if $self->isPoster;
        my ($flag) = WebGUI::SQL->quickArray("select count(*) from Post_rating where assetId="
                .quote($self->getId)." and ((userId=".quote($session{user}{userId})." and userId<>'1') or (userId='1' and
                ipAddress=".quote($session{env}{REMOTE_ADDR})."))");
        return $flag;
}

#-------------------------------------------------------------------

=head2 incrementViews ( )

Increments the views counter for this post.

=cut

sub incrementViews {
	my ($self) = @_;
        $self->update({views=>$self->get("views")+1});
        $self->getThread->incrementViews;
}

#-------------------------------------------------------------------

=head2 isMarkedRead ( )

Returns a boolean indicating whether this post is marked read for the user.

=cut

sub isMarkedRead {
        my $self = shift;
	return 1 if $self->isPoster;
        my ($isRead) = WebGUI::SQL->quickArray("select count(*) from Post_read where userId=".quote($session{user}{userId})." and postId=".quote($self->getId));
        return $isRead;
}

#-------------------------------------------------------------------

=head2 isPoster ( )

Returns a boolean that is true if the current user created this post and is not a visitor.

=cut

sub isPoster {
	my $self = shift;
	return ($session{user}{userId} ne "1" && $session{user}{userId} eq $self->get("ownerUserId"));
}


#-------------------------------------------------------------------

=head2 isReply ( )

Returns a boolean indicating whether this post is a reply. This is the opposite of isRootPost().

=cut

sub isReply {
	my $self = shift;
	return !$self->isRootPost;
}


#-------------------------------------------------------------------

=head2 isRootPost ( )

Returns a boolean indicating that this post is the root post in the thread. This is the opposite of isReply().

=cut

sub isReply {
	my $self = shift;
	return $self->get("parentId") eq $self->get("threadId");
}


#-------------------------------------------------------------------

=head2 markRead ( )

Marks this post read for this user.

=cut

sub markRead {
	my $self = shift;
        unless ($self->isMarkedRead) {
                WebGUI::SQL->write("insert into Post_read (userId, postId, threadId, readDate) values (".quote($session{user}{userId}).",
                        ".quote($self->getId).", ".quote($self->get("threadId")).", ".WebGUI::DateTime::time().")");
        }
}

#-------------------------------------------------------------------

=head2 notifySubscribers ( )

Send notifications to the thread and forum subscribers that a new post has been made.

=cut

sub notifySubscribers {
	my $self = shift;
        my %subscribers;
	foreach my $userId (@{WebGUI::Grouping::getUsersInGroup($self->getThread->get("subscriptionGroupId"))}) {
		$subscribers{$userId} = $userId unless ($userId eq $self->get("ownerUserId"));
	}
	foreach my $userId (@{WebGUI::Grouping::getUsersInGroup($self->getThread->getParent->get("subscriptionGroupId"))}) {
		$subscribers{$userId} = $userId unless ($userId eq $self->get("ownerUserId"));
	}
        my %lang;
        foreach my $userId (keys %subscribers) {
                my $u = WebGUI::User->new($userId);
                if ($lang{$u->profileField("language")}{message} eq "") {
                        $lang{$u->profileField("language")}{var} = {
                                'notify.subscription.message' => WebGUI::International::get(875,"WebGUI",$u->profileField("language"))
                                };
                        $lang{$u->profileField("language")}{var} = $self->getTemplateVars($lang{$u->profileField("language")}{var});
                        $lang{$u->profileField("language")}{subject} = WebGUI::International::get(523,"WebGUI",$u->profileField("language"));
                        $lang{$u->profileField("language")}{message} = $self->processTemplate($lang{$u->profileField("language")}{var}, $self->getThread->getParent->get("notificationTemplateId"));,
                }
                WebGUI::MessageLog::addEntry($userId,"",$lang{$u->profileField("language")}{subject},$lang{$u->profileField("language")}{message});
        }
}


#-------------------------------------------------------------------
sub processPropertiesFromFormPost {
	my $self = shift;
	$self->SUPER::processPropertiesFromFormPost;
	my %data = (
		ownerUserId => $session{user}{userId},
		groupIdView => $self->getThread->get("groupIdView"),
		groupIdEdit => $self->getThread->get("groupIdEdit")
		);
	$data{startDate} = $self->getThread->get("startDate") unless ($session{form}{startDate});
	$data{endDate} = $self->getThread->get("endDate") unless ($session{form}{endDate});
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

=head2 rate ( rating )

Stores a rating against this post.

=head3 rating

An integer between 1 and 5 (5 being best) to rate this post with.

=cut

sub rate {
	my $self = shift;
	my $rating = shift;
	unless ($self->hasRated) {
        	WebGUI::SQL->write("insert into Post_rating (assetId,userId,ipAddress,dateOfRating,rating) values ("
                	.quote($self->getId).", ".quote($session{user}{userId}).", ".quote($session{env}{REMOTE_ADDR}).", 
			".WebGUI::DateTime::time().", $rating)");
        	$self->recalculateRating;
	}
}

#-------------------------------------------------------------------

=head2 recalculateRating ( )

Recalculates the average rating of the post from all the ratings and stores the result to the database.

=cut

sub recalculateRating {
        my ($self) = @_;
        my ($count) = WebGUI::SQL->quickArray("select count(*) from Post_rating where postId=".quote($self->getId));
        $count = $count || 1;
        my ($sum) = WebGUI::SQL->quickArray("select sum(rating) from Post_rating where postId=".quote($self->getId));
        my $average = round($sum/$count);
        $self->update({rating=>$average});
        $self->getThread->recalculateRating;
}


#-------------------------------------------------------------------

=head2 setDefaultStatus ( )

Sets a new post's status based upon forum settings.

=cut

sub setDefaultStatus {
	my $self = shift;
        if ($self->getThread->getParent->get("moderatePosts")) {
                $self->setStatusPending;
        } else {
                $self->setStatusApproved;
        }
}


#-------------------------------------------------------------------

=head2 setStatusApproved ( )

Sets the post to approved and sends any necessary notifications.

=cut

sub setStatusApproved {
	my $self
        $self->update({status=>'approved'});
        $self->getThread->setStatusApproved if $self->isRootPost;
        $self->getThread->incrementReplies($self->get("dateUpdated"),$self->getId) if $self->isReply;
        unless ($self->isPoster) {
                WebGUI::MessageLog::addInternationalizedEntry($self->get("ownerUserId"),'',$self->getUrl,579);
        }
        $self->notifySubscribers;
}



#-------------------------------------------------------------------

=head2 setStatusArchived ( )

Sets the status of this post to archived.

=cut


sub setStatusArchived {
        my ($self) = @_;
        $self->update({status=>'archived'});
        $self->getThread->setStatusArchived if $self->isRootPost;
}


#-------------------------------------------------------------------

=head2 setStatusDenied ( )

Sets the status of this post to denied.

=cut

sub setStatusDenied {
        my ($self) = @_;
        $self->update({status=>'denied'});
        $self->getThread->setStatusDenied if $self->isRootPost;
        WebGUI::MessageLog::addInternationalizedEntry($self->get("ownerUserId"),'',$self->getUrl,580);
}

#-------------------------------------------------------------------

=head2 setStatusPending ( )

Sets the status of this post to pending.

=cut

sub setStatusPending {
        my ($self) = @_;
        $self->update({status=>'pending'});
        $self->getThread->setStatusPending if $self->isRootPost;
        WebGUI::MessageLog::addInternationalizedEntry('',$self->getThread->getParent->get("moderateGroupId"),
                $self->getUrl,578,'WebGUI','pending');
}


#-------------------------------------------------------------------

=head2 unmarkRead ( )

Negates the markRead method.

=cut

sub unmarkRead {
	my $self = shift;
        WebGUI::SQL->write("delete from forumRead where userId=".quote($session{user}{userId})." and postId=".quote($self->getId));
}

#-------------------------------------------------------------------

=head2 www_approve ( )

The web method to approve a post.

=cut

sub www_approve {
	my $self = shift;
	$self->setStatusApproved if $self->getThread->getParent->canModerate;
	return $self->www_view;
}

#-------------------------------------------------------------------

=head2 www_deny ( )

The web method to deny a post.

=cut

sub www_deny {
	my $self = shift;
	$self->setStatusDenied if $self->getThread->getParent->canModerate;
	return $self->www_view;
}

#-------------------------------------------------------------------
sub www_edit {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless ($self->canEdit);
	my %var;
	if ($session{form}{func} eq "add") {
		$self->{_properties}{contentType} = "mixed";
		$var{'isNew'} = 1;
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
        $var{'body.label'} = WebGUI::International::get(31,"USS");
	$var{'answer.label'} = WebGUI::International::get(86,"USS");
        $var{'description.label'} = WebGUI::International::get(85);
	$var{'contet.form'} = WebGUI::Form::HTMLArea({
		name=>"content",
		value=>$self->get("content")
		});
	$var{'content.form.textarea'} = WebGUI::Form::textarea({
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

=head2 www_post ( caller )

The web method to display the post form.

=head3 caller

A hash reference containing information passed from the calling object.

=cut

sub www_post {
        my ($caller) = @_;
        my ($subject, $message, $forum);
        my $var;
        $var->{'newpost.header'} = WebGUI::International::get(1064);
        $var->{'newpost.isReply'} = ($session{form}{parentId} ne "");
        $var->{'newpost.isEdit'} = ($session{form}{forumPostId} ne "");
        $var->{'newpost.isNewThread'} = ($session{form}{parentId} eq "" && !$var->{'newpost.isEdit'});
        $var->{'user.isVisitor'} = ($session{user}{userId} eq '1');
        $var->{'newpost.isNewMessage'} = ($var->{'newpost.isNewThread'} || $var->{'newpost.isReply'});
        $var->{'form.begin'} = WebGUI::Form::formHeader({
                action=>$caller->{callback}
                });
        my $defaultSubscribeValue = 0;
        my $contentType = "mixed";
        if ($var->{'newpost.isReply'}) {
                my $reply = WebGUI::Forum::Post->new($session{form}{parentId});
                return WebGUI::Privilege::insufficient() unless ($reply->getThread->getForum->canPost);
                $var->{'form.begin'} .= WebGUI::Form::hidden({
                        name=>'parentId',
                        value=>$reply->get("forumPostId")
                        });
                $forum = $reply->getThread->getForum;
                $var->{'form.begin'} .= WebGUI::Form::hidden({
                        name=>'forumId',
                        value=>$forum->get("forumId")
                        });
                $message = "[quote]".$reply->get("message")."[/quote]" if ($session{form}{withQuote});
                $var = getPostTemplateVars($reply, $reply->getThread, $forum, $caller, $var);

                $subject = $reply->get("subject");
                $subject = "Re: ".$subject unless ($subject =~ /^Re:/);
        }
        if ($var->{'newpost.isNewThread'}) {
                $var->{'form.begin'} .= WebGUI::Form::hidden({
                        name=>'forumId',
                        value=>$session{form}{forumId}
                        });
                $forum = WebGUI::Forum->new($session{form}{forumId});
                if ($forum->isModerator) {
                        $var->{'sticky.label'} = WebGUI::International::get(1013);
                        $var->{'sticky.form'} = WebGUI::Form::yesNo({
                                name=>'isSticky',
                                value=>0
                                });
                }
                $defaultSubscribeValue = 1 unless ($forum->isSubscribed);
        }
        if ($var->{'newpost.isNewMessage'}) {
                $var->{'subscribe.label'} = WebGUI::International::get(873);
                return WebGUI::Privilege::insufficient() unless ($forum->canPost);
                my $u = WebGUI::User->new($session{user}{userId});
                $u->karma($forum->get("karmaPerPost"),"Forum (".$forum->get("forumId").")","Forum Post") if ($session{setting}{useKarma});
                if ($forum->isModerator) {
                        $var->{'lock.label'} = WebGUI::International::get(1012);
                        $var->{'lock.form'} = WebGUI::Form::yesNo({
                                name=>'isLocked',
                                value=>0
                                });
                }
                $var->{'subscribe.form'} = WebGUI::Form::yesNo({
                        name=>'subscribe',
                        value=>$defaultSubscribeValue
                        });
                $message .= "\n\n".$session{user}{signature} if ($session{user}{signature});
        }
        if ($var->{'newpost.isEdit'}) {
                my $post = WebGUI::Forum::Post->new($session{form}{forumPostId});
                return WebGUI::Privilege::insufficient() unless ($post->getThread->getForum->canPost);
                $subject = $post->get("subject");
                $message = $post->get("message");
                $forum = $post->getThread->getForum;
                $var->{'form.begin'} .= WebGUI::Form::hidden({
                        name=>"forumPostId",
                        value=>$post->get("forumPostId")
                        });
                $contentType = $post->get("contentType");
        }
        $var->{'contentType.label'} = WebGUI::International::get(1007);
        $var->{'contentType.form'} = WebGUI::Form::contentType({
                name=>'contentType',
                value=>[$contentType]
                });
        $var->{'user.isModerator'} = $forum->isModerator;
        $var->{allowReplacements} = $forum->get("allowReplacements");
        if ($forum->get("allowRichEdit")) {
                $var->{'message.form'} = WebGUI::Form::HTMLArea({
                        name=>'message',
                        value=>$message
                        });
        } else {
                $var->{'message.form'} = WebGUI::Form::textarea({
                        name=>'message',
                        value=>$message
                        });
        }
        $var->{'message.label'} = WebGUI::International::get(230);
        if ($var->{'user.isVisitor'}) {
                $var->{'visitorName.label'} = WebGUI::International::get(438);
                $var->{'visitorName.form'} = WebGUI::Form::text({
                        name=>'visitorName'
                        });
        }
        my $forumOp = ($forum->get("usePreview"))? "postPreview" : "postSave";
        $var->{'form.begin'} .= WebGUI::Form::hidden({
                 name=>'forumOp',
                value=>$forumOp
                });
        $var->{'form.submit'} = WebGUI::Form::submit();
        $var->{'subject.label'} = WebGUI::International::get(229);
        $var->{'subject.form'} = WebGUI::Form::text({
                name=>'subject',
                value=>$subject
                });
        $var->{'form.end'} = WebGUI::Form::formFooter();
        return WebGUI::Template::process($forum->get("postformTemplateId"),"Forum/PostForm", $var);
}

#-------------------------------------------------------------------

=head2 www_postPreview ( caller )

The web method to generate a preview of a posting.

=head3 caller

A hash reference containing information passed from the calling object.

=cut

sub www_postPreview {
        my ($caller) = @_;


        my $forumId = $session{form}{forumId};
        my $threadId = $session{form}{forumThreadId};
        my $postId = $session{form}{forumPostId};
        my $subject = $session{form}{subject};
        $subject = WebGUI::International::get(232) if ($subject eq "");
        $subject .= ' '.WebGUI::International::get(233) if ($session{form}{message} eq "");
        if ( $subject ne "") { # subjects could never contain anything other than text
                $subject = WebGUI::HTML::filter(WebGUI::HTML::processReplacements($subject),"all");
        }
        my $newPost = WebGUI::Forum::Post->new();

        $newPost->{_properties}->{message} = $session{form}{message};
        $newPost->{_properties}->{subject} = $subject;
        $newPost->{_properties}->{contentType} = $session{form}{contentType};
        $newPost->{_properties}->{userId} = $session{user}{userId};
        $newPost->{_properties}->{username} = ($session{form}{visitorName} || $session{user}{alias});
        $newPost->{_properties}->{dateUpdated} = WebGUI::DateTime::time();
        my $forum = WebGUI::Forum->new($forumId);

        my $var = getPostTemplateVars($newPost, WebGUI::Forum::Thread->new($threadId), WebGUI::Forum->new($forumId), $caller);
        $var->{'newpost.header'} = WebGUI::International::get('Forum, Preview Heading');

        $var->{'form.begin'} = WebGUI::Form::formHeader({
                action=>$caller->{callback}
                });
        $var->{'form.begin'} .= WebGUI::Form::hidden({name=>'forumId', value=>$forumId});
        $var->{'form.begin'} .= WebGUI::Form::hidden({name=>'forumThreadId', value=>$threadId});
        $var->{'form.begin'} .= WebGUI::Form::hidden({name=>'forumPostId', value=>$postId});
        $var->{'form.begin'} .= WebGUI::Form::hidden({name=>'parentId', value=>$session{form}{parentId}});
        $var->{'form.begin'} .= WebGUI::Form::hidden({name=>'subject', value=>$subject});
        $var->{'form.begin'} .= WebGUI::Form::hidden({name=>'message', value=>$session{form}{message}});
        $var->{'form.begin'} .= WebGUI::Form::hidden({name=>'contentType', value=>$session{form}{contentType}});
        $var->{'form.begin'} .= WebGUI::Form::hidden({name=>'visitorName', value=>$session{form}{visitorName}});
        $var->{'form.begin'} .= WebGUI::Form::hidden({name=>'subscribe', value=>$session{form}{subscribe}});
        $var->{'form.begin'} .= WebGUI::Form::hidden({name=>'isLocked', value=>$session{form}{isLocked}});
        $var->{'form.begin'} .= WebGUI::Form::hidden({name=>'isSticky', value=>$session{form}{isSticky}});
        $var->{'form.begin'} .= WebGUI::Form::hidden({name=>'forumOp', value=>"postSave"});
        $var->{'form.submit'} = WebGUI::Form::submit();
        $var->{'form.end'} = WebGUI::Form::formFooter();
        return WebGUI::Template::process($forum->get("postPreviewTemplateId"),"Forum/PostPreview", $var);
}
 

#-------------------------------------------------------------------

=head2 www_postSave ( caller )

The web method to save the data from the post form.

=head3 caller

A hash reference containing information passed from the calling object.

=cut

sub www_postSave {
        my ($caller) = @_;
        my $forumId = $session{form}{forumId};
        my $threadId = $session{form}{forumThreadId};
        my $postId = $session{form}{forumPostId};
        my $subject = $session{form}{subject};
        $subject = WebGUI::International::get(232) if ($subject eq "");
        $subject .= ' '.WebGUI::International::get(233) if ($session{form}{message} eq "");
        if ( $subject ne "") { # subjects could never contain anything other than text
                $subject = WebGUI::HTML::filter(WebGUI::HTML::processReplacements($subject),"all");
        }
        my %postData = (
                message=>$session{form}{message},
                subject=>$subject,
                contentType=>$session{form}{contentType}
                );
        my %postDataNew = (
                userId=>$session{user}{userId},
                username=>($session{form}{visitorName} || $session{user}{alias})
                );
        if ($session{form}{parentId} ne '') { # reply
                %postData = (%postData, %postDataNew);
                my $parentPost = WebGUI::Forum::Post->new($session{form}{parentId});
                return WebGUI::Privilege::insufficient() unless ($parentPost->getThread->getForum->canPost);
                $parentPost->getThread->subscribe($session{user}{userId}) if ($session{form}{subscribe});
                $parentPost->getThread->lock if ($session{form}{isLocked});
                $postData{forumThreadId} = $parentPost->getThread->get("forumThreadId");
                $postData{parentId} = $session{form}{parentId};
                my $post = WebGUI::Forum::Post->create(\%postData);
                setPostStatus($caller,$post);
                WebGUI::HTTP::setRedirect(formatThreadURL($caller->{callback}, $post->get("forumPostId")));

                return "Redirecting...";
                #return www_viewThread($caller,$post->get("forumPostId"));
        }
        if ($session{form}{forumPostId} ne '') { # edit
                my $post = WebGUI::Forum::Post->new($session{form}{forumPostId});
                return WebGUI::Privilege::insufficient() unless ($post->canEdit);
                if ($post->getThread->getForum->get("addEditStampToPosts")) {
                        $postData{message} .= "\n\n --- (".WebGUI::International::get(1029)." "
                        .WebGUI::DateTime::epochToHuman(WebGUI::DateTime::time())." ".WebGUI::International::get(1030)
                        ." $session{user}{username}) --- \n";
                }
                $post->set(\%postData);
                WebGUI::HTTP::setRedirect(formatThreadURL($caller->{callback}, $post->get("forumPostId")));
                return "Redirecting...";
                #return www_viewThread($caller,$post->get("forumPostId"));
        }
        if ($forumId) { # new post
                %postData = (%postData, %postDataNew);
                my $forum = WebGUI::Forum->new($forumId);
                return WebGUI::Privilege::insufficient() unless ($forum->canPost);
                my $thread = WebGUI::Forum::Thread->create({
                        forumId=>$forumId,
                        isSticky=>$session{form}{isSticky},
                        isLocked=>$session{form}{isLocked}
                        }, \%postData);
                $thread->subscribe($session{user}{userId}) if ($session{form}{subscribe});
                setPostStatus($caller,$thread->getPost($thread->get("rootPostId")));
                WebGUI::HTTP::setRedirect(formatForumURL($caller->{callback}, $forumId));
                return "Redirecting...";
                #return www_viewForum($caller,$forumId);
        }
}

#-------------------------------------------------------------------

=head2 www_ratePost ( )

The web method to rate a post.

=cut

sub www_rate {	
	my $self = shift;
	$self->rate($session{form}{rating}) if ($self->canView && !$self->hasRated);
	$self->www_view;
}


#-------------------------------------------------------------------
sub www_view {
	my $self = shift;
	return $self->getParent->processStyle(WebGUI::Privilege::noAccess()) unless $self->canView;
	return $self->getParent->processStyle($self->view);
}


1;

