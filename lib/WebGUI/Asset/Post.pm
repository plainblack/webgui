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
use WebGUI::Asset::Post::Thread;
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
use WebGUI::Storage::Image;
use WebGUI::URL;
use WebGUI::User;
use WebGUI::Utility;

our @ISA = qw(WebGUI::Asset);



#-------------------------------------------------------------------
sub canEdit {
	my $self = shift;
	return (($session{form}{func} eq "add" || ($session{form}{assetId} eq "new" && $session{form}{func} eq "editSave" && $session{form}{class} eq "WebGUI::Asset::Post")) && $self->getThread->getParent->canPost) || # account for new posts

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

=head2 chopTitle ( )

Cuts a title string off at 30 characters.

=cut

sub chopTitle {
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
			storageId => {
				noFormPost=>1,
				fieldType=>"hidden",
				defaultValue=>undef
				},
			threadId => {
				noFormPost=>1,
				fieldType=>"hidden",
				defaultValue=>undef
				},
			dateSubmitted => {
				noFormPost=>1,
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
				noFormPost=>1,
				fieldType=>"hidden",
				defaultValue=>undef
				},
			rating => {
				noFormPost=>1,
				fieldType=>"hidden",
				defaultValue=>undef
				},
			views => {
				noFormPost=>1,
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
	$self->{_thread}->DESTROY if (exists $self->{_thread} && ref $self->{_thread} =~ /Thread/);
	$self->SUPER::DESTROY;
}


#-------------------------------------------------------------------

=head2 formatContent ( [ content, contentType ])

Formats post content for display.

=head3 content

The content to format. Defaults to the content in this post.

=head3 contentType

The content type to use for formatting. Defaults to the content type specified in this post.

=cut

sub formatContent {
	my $self = shift;
	my $content = shift || $self->get("content");
	my $contentType = shift || $self->get("contentType");	
        my $msg = WebGUI::HTML::filter($content,$self->getThread->getParent->get("filterCode"));
        $msg = WebGUI::HTML::format($msg, $contentType);
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
sub getImageUrl {
	my $self = shift;
	return undef if ($self->get("storageId") eq "");
	my $storage = $self->getStorageLocation;
	my $url;
	foreach my $filename (@{$storage->getFiles}) {
		if ($storage->isImage($filename)) {
			$url = $storage->getUrl($filename);
			last;
		}
	}
	return $url;
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
sub getStatus {
	my $self = shift;
	my $status = $self->get("status");
        if ($status eq "approved") {
                return "Approved";
        } elsif ($status eq "denied") {
                return "Denied";
        } elsif ($status eq "pending") {
                return "Pending";
        }
}

#-------------------------------------------------------------------
sub getStorageLocation {
	my $self = shift;
	unless (exists $self->{_storageLocation}) {
		if ($self->get("storageId") eq "") {
			$self->{_storageLocation} = WebGUI::Storage::Image->create;
			$self->update({storageId=>$self->{_storageLocation}->getId});
		} else {
			$self->{_storageLocation} = WebGUI::Storage::Image->get($self->get("storageId"));
		}
	}
	return $self->{_storageLocation};
}

#-------------------------------------------------------------------
sub getSynopsisAndContentFromFormPost {
	my $self = shift;
	my $synopsis = $session{form}{synopsis};
	my $body = $session{form}{content};
	unless ($synopsis) {
        	$body =~ s/\n/\^\-\;/ unless ($body =~ m/\^\-\;/);
       	 	my @content = split(/\^\-\;/,$body);
		$synopsis = WebGUI::HTML::filter($content[0],"none");
	}
	$body =~ s/\^\-\;/\n/;
	return ($synopsis,$body);
}

#-------------------------------------------------------------------
sub getTemplateVars {
	my $self = shift;
	my %var = %{$self->get};
	$var{"userId"} = $self->get("ownerUserId");
	$var{"user.isPoster"} = $self->isPoster;
	$var{"userProfile.url"} = $self->getUrl("op=viewProfile&uid=".$self->get("ownerUserId"));

	$var{"dateSubmitted.human"} = epochToHuman($self->get("dateSubmitted"));
	$var{"dateUpdated.human"} = epochToHuman($self->get("dateUpdated"));

	$var{'title.short'} = $self->chopTitle;
	$var{content} = $self->formatContent if ($self->getThread);

        $var{'user.canEdit'} = $self->canEdit if ($self->getThread);
        $var{"delete.url"} = $self->getDeleteUrl;
        $var{"edit.url"} = $self->getEditUrl;

	$var{"status"} = $self->getStatus;
        $var{"approve.url"} = $self->getApproveUrl;
        $var{"deny.url"} = $self->getDenyUrl;

	$var{"reply.url"} = $self->getReplyUrl;
        $var{'reply.withquote.url'} = $self->getReplyUrl(1);

        $var{'url'} = $self->getUrl.'#'.$self->getId;

        $var{'rating.value'} = $self->get("rating")+0;
        $var{'rate.url.1'} = $self->getRateUrl(1);
        $var{'rate.url.2'} = $self->getRateUrl(2);
        $var{'rate.url.3'} = $self->getRateUrl(3);
        $var{'rate.url.4'} = $self->getRateUrl(4);
        $var{'rate.url.5'} = $self->getRateUrl(5);
        $var{'hasRated'} = $self->hasRated;
	my $gotImage;
	my $gotAttachment;
	unless ($self->get("storageId") eq "") {
		my $storage = $self->getStorageLocation;
		foreach my $filename (@{$storage->getFiles}) {
			if (!$gotImage && $storage->isImage($filename)) {
				$var{"image.url"} = $storage->getUrl($filename);
				$var{"image.thumbnail"} = $storage->getThumbnailUrl($filename);
				$gotImage = 1;
			}
			if (!$gotAttachment && !$storage->isImage($filename)) {
				$var{"attachment.url"} = $storage->getUrl($filename);
				$var{"attachment.icon"} = $storage->getFileIconUrl($filename);
				$var{"attachment.name"} = $filename;
       			}	
			push(@{$var{"attachment_loop"}}, {
				url=>$storage->getUrl($filename),
				icon=>$storage->getFileIconUrl($filename),
				filename=>$filename,
				thumbnail=>$storage->getThumbnailUrl($filename),
				isImage=>$storage->isImage($filename)
				});
		}
	}
	return \%var;
}

#-------------------------------------------------------------------
sub getThread {
	my $self = shift;
	unless (exists $self->{_thread}) {
		$self->{_thread} = WebGUI::Asset::Post::Thread->new($self->get("threadId"));
	}
	return $self->{_thread};	
}

#-------------------------------------------------------------------
sub getThumbnailUrl {
	my $self = shift;
	return undef if ($self->get("storageId") eq "");
	my $storage = $self->getStorageLocation;
	my $url;
	foreach my $filename (@{$storage->getFiles}) {
		if ($storage->isImage($filename)) {
			$url = $storage->getThumbnailUrl($filename);
			last;
		}
	}
	return $url;
}


#-------------------------------------------------------------------
sub getUploadControl {
	my $self = shift;
	my $maxAttachments = $self->getThread->getParent->getValue("attachmentsPerPost");
	my $uploadControl;
	return undef unless ($maxAttachments);
	if ($self->get("storageId")) {
		my $i;
		foreach my $filename (@{$self->getStorageLocation->getFiles}) {
			$uploadControl .= '<a href="'.$self->getStorageLocation->getUrl($filename).'">'.$filename.'</a><br />';	
			$i++;
		}
		return $uploadControl unless ($i < $maxAttachments);
	}
	WebGUI::Style::setScript($session{config}{extrasURL}.'/FileUploadControl.js',{type=>"text/javascript"});
	$uploadControl .= '<div id="fileUploadControl"> </div>
		<script>
		var images = new Array();
		var fileLimit = '.$maxAttachments.';
		';
	opendir(DIR,$session{config}{extrasPath}.'/fileIcons');
	my @files = readdir(DIR);
	closedir(DIR);
	foreach my $file (@files) {
		unless ($file eq "." || $file eq "..") {
			my $ext = $file;
			$ext =~ s/(.*?)\.gif/$1/;
			$uploadControl .= 'images["'.$ext.'"] = "'.$session{config}{extrasURL}.'/fileIcons/'.$file.'";'."\n";
		}
	}
	$uploadControl .= 'var uploader = new FileUploadControl("fileUploadControl", images);
	uploader.addRow();
	</script>';
	return $uploadControl;
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

Returns a boolean indicating whether this post is a reply. 

=cut

sub isReply {
	my $self = shift;
	return $self->getId ne $self->get("threadId");
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
			$lang{$u->profileField("language")}{var}{url} = WebGUI::URL::getSiteURL().$self->getUrl;
                        $lang{$u->profileField("language")}{subject} = WebGUI::International::get(523,"WebGUI",$u->profileField("language"));
                        $lang{$u->profileField("language")}{message} = $self->processTemplate($lang{$u->profileField("language")}{var}, $self->getThread->getParent->get("notificationTemplateId"));
                }
                WebGUI::MessageLog::addEntry($userId,"",$lang{$u->profileField("language")}{subject},$lang{$u->profileField("language")}{message});
        }
}


#-------------------------------------------------------------------
sub processPropertiesFromFormPost {
	my $self = shift;
	$self->SUPER::processPropertiesFromFormPost;	
	my %data;
	if ($session{form}{assetId} eq "new") {
		if ($self->getParent->get("className") eq "WebGUI::Asset::Wobject::Collaboration") {
			$self->update({threadId=>$self->getId});
		} else {
			$self->update({threadId=>$self->getParent->get("threadId")});
		}
		if ($session{setting}{enableKarma} && $self->getThread->getParent->get("karmaPerPost")) {
			my $u = WebGUI::User->new($session{user}{userId});
			$u->addKarma($self->getThread->getParent->get("karmaPerPost"), $self->getId, "Collaboration post");
		}
		%data = (
			ownerUserId => $session{user}{userId},
			groupIdView => $self->getThread->getParent->get("groupIdView"),
			groupIdEdit => $self->getThread->getParent->get("groupIdEdit"),
			isHidden => 1,
			dateSubmitted=>time()
			);
		if ($self->getThread->getParent->canModerate) {
        		$self->getThread->lock if ($session{form}{'lock'});
        		$self->getThread->stick if ($session{form}{stick});
		}
	}
	$data{startDate} = $self->getThread->getParent->get("startDate") unless ($session{form}{startDate});
	$data{endDate} = $self->getThread->getParent->get("endDate") unless ($session{form}{endDate});
	($data{synopsis}, $data{content}) = $self->getSynopsisAndContentFromFormPost;
        if ($self->getThread->getParent->get("addEditStampToPosts")) {
        	$data{content} .= "<p>\n\n --- (Edited on ".WebGUI::DateTime::epochToHuman()." by ".$session{user}{alias}.") --- \n</p>";
        }
	$self->update(\%data);
        $self->getThread->subscribe if ($session{form}{subscribe});
        if ($self->getThread->getParent->get("moderatePosts")) {
                $self->setStatusPending;
        } else {
                $self->setStatusApproved;
        }
	my $storage = $self->getStorageLocation;
	my $filename = $storage->addFileFromFormPost("file");
	if (defined $filename) {
		$self->setSize($storage->getFileSize($filename));
		$storage->setPrivileges($self->get("ownerUserId"), $self->get("groupIdView"), $self->get("groupIdEdit"));
		$storage->generateThumbnail($filename);
	}
	$session{form}{proceed} = "redirectToParent";
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
        	my ($count) = WebGUI::SQL->quickArray("select count(*) from Post_rating where assetId=".quote($self->getId));
        	$count = $count || 1;
        	my ($sum) = WebGUI::SQL->quickArray("select sum(rating) from Post_rating where assetId=".quote($self->getId));
        	my $average = WebGUI::Utility::round($sum/$count);
        	$self->update({rating=>$average});
		$self->getThread->rate;
	}
}


#-------------------------------------------------------------------

=head2 setStatusApproved ( )

Sets the post to approved and sends any necessary notifications.

=cut

sub setStatusApproved {
	my $self = shift;
        $self->update({status=>'approved'});
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
}


#-------------------------------------------------------------------

=head2 setStatusDenied ( )

Sets the status of this post to denied.

=cut

sub setStatusDenied {
        my ($self) = @_;
        $self->update({status=>'denied'});
        WebGUI::MessageLog::addInternationalizedEntry($self->get("ownerUserId"),'',$self->getUrl,580);
}

#-------------------------------------------------------------------

=head2 setStatusPending ( )

Sets the status of this post to pending.

=cut

sub setStatusPending {
        my ($self) = @_;
        $self->update({status=>'pending'});
        WebGUI::MessageLog::addInternationalizedEntry('',$self->getThread->getParent->get("moderateGroupId"),
                $self->getUrl("func=view"),578,'WebGUI','pending');
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
sub view {
	my $self = shift;
	$self->markRead;
	$self->incrementViews;
	return $self->getThread->view;
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
	my %var = %{$self->getTemplateVars};
	my $content;
	my $title;
	if ($session{form}{func} eq "add") { # new post
        	$var{'form.header'} = WebGUI::Form::formHeader({action=>$self->getParent->getUrl})
			.WebGUI::Form::hidden({
                		name=>"func",
				value=>"add"
				})
			.WebGUI::Form::hidden({
				name=>"assetId",
				value=>"new"
				})
			.WebGUI::Form::hidden({
				name=>"class",
				value=>$session{form}{class}
				});
        	$var{'isNewPost'} = 1;
		if ($session{form}{class} eq "WebGUI::Asset::Post") { # new reply
			$self->{_thread} = $self->getParent->getThread;
			return WebGUI::Privilege::insufficient() unless ($self->getThread->canReply);
			$var{isReply} = 1;
			if ($session{form}{content} || $session{form}{title}) {
				$content = $session{form}{content};
				$title = $session{form}{title};
			} else {
                		$content = "[quote]".$self->getParent->get("content")."[/quote]" if ($session{form}{withQuote});
                		$title = $self->getParent->get("title");
                		$title = "Re: ".$title unless ($title =~ /^Re:/);
			}
			$var{'subscribe.form'} = WebGUI::Form::yesNo({
				name=>"subscribe",
				value=>$session{form}{subscribe}
				});
		} elsif ($session{form}{class} eq "WebGUI::Asset::Post::Thread") { # new thread
			return WebGUI::Privilege::insufficient() unless ($self->getThread->getParent->canPost);
			$var{isNewThread} = 1;
                	if ($self->getThread->getParent->canModerate) {
                        	$var{'sticky.form'} = WebGUI::Form::yesNo({
                                	name=>'stick',
                                	value=>$session{form}{stick}
                                	});
                        	$var{'lock.form'} = WebGUI::Form::yesNo({
                       	         	name=>'lock',
                                	value=>$session{form}{'lock'}
                                	});
			}
			$var{'subscribe.form'} = WebGUI::Form::yesNo({
				name=>"subscribe",
				value=>$session{form}{subscribe} || 1
				});
		}
                $content .= "\n\n".$session{user}{signature} if ($session{user}{signature});
	} else { # edit
		return WebGUI::Privilege::insufficient() unless ($self->canEdit);
        	$var{'form.header'} = WebGUI::Form::formHeader({action=>$self->getUrl})
			.WebGUI::Form::hidden({
                		name=>"func",
				value=>"edit"
				});
		$var{isEdit} = 1;
		$content = $self->getValue("content");
		$title = $self->getValue("title");
	}
	if ($session{form}{title} || $session{form}{content} || $session{form}{synopsis}) {
		$var{'preview.title'} = WebGUI::HTML::filter($session{form}{title},"none");
		($var{'preview.synopsis'}, $var{'preview.content'}) = $self->getSynopsisAndContentFromFormPost;
		$var{'preview.content'} = $self->formatContent($var{'preview.content'},$session{form}{contentType});
	}
	$var{'form.preview'} = WebGUI::Form::submit({value=>"Preview"});
	$var{'form.submit'} = WebGUI::Form::button({
		value=>"Save",
		extras=>"onclick=\"this.value='Please wait...'; this.form.func.value='editSave'; this.form.submit();\""
		});
	$var{'form.footer'} = WebGUI::Form::formFooter();
	$var{usePreview} = $self->getThread->getParent->get("usePreview");
	$var{'user.isVisitor'} = ($session{user}{userId} eq '1');
	$var{'visitorName.form'} = WebGUI::Form::text({
		name=>"visitorName",
		value=>$self->getValue("visitorName")
		});
	for my $x (1..5) {
		$var{'userDefined'.$x.'.form'} = WebGUI::Form::text({
			name=>"userDefined".$x,
			value=>$self->getValue("userDefined".$x)
			});
		$var{'userDefined'.$x.'.form.yesNo'} = WebGUI::Form::yesNo({
			name=>"userDefined".$x,
			value=>$self->getValue("userDefined".$x)
			});
		$var{'userDefined'.$x.'.form.textarea'} = WebGUI::Form::textarea({
			name=>"userDefined".$x,
			value=>$self->getValue("userDefined".$x)
			});
		$var{'userDefined'.$x.'.form.textarea'} = WebGUI::Form::HTMLArea({
			name=>"userDefined".$x,
			value=>$self->getValue("userDefined".$x)
			});
	}
	$var{'title.form'} = WebGUI::Form::text({
		name=>"title",
		value=>$title
		});
	$var{'title.form.textarea'} = WebGUI::Form::textarea({
		name=>"title",
		value=>$title
		});
	if ($self->getThread->getParent->get("allowRichEdit")) {
		$var{'content.form'} = WebGUI::Form::HTMLArea({
			name=>"content",
			value=>$content
			});
	} else {
		$var{'content.form'} = WebGUI::Form::textarea({
			name=>"content",
			value=>$content
			});
	}
	$var{'attachment.form'} = $self->getUploadControl;
        $var{'contentType.form'} = WebGUI::Form::contentType({
                name=>'contentType',
                value=>$self->getValue("contentType") || "mixed"
                });
	$var{'startDate.form'} = WebGUI::Form::dateTime({
		name  => 'startDate',
		value => $self->getValue("startDate")
		});
	$var{'endDate.form'} = WebGUI::Form::dateTime({
		name  => 'endDate',
		value => $self->getValue("endDate")
		});
	$self->getThread->getParent->appendTemplateLabels(\%var);
	return $self->getThread->getParent->processStyle($self->processTemplate(\%var,$self->getThread->getParent->get("postFormTemplateId")));
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

=head2 www_redirectToParent ( )

This is here to stop people from duplicating posts by hitting refresh in their browser.

=cut 

sub www_redirectToParent {
	my $self = shift;
	WebGUI::HTTP::setRedirect($self->getParent->getUrl);
}



#-------------------------------------------------------------------
sub www_view {
	my $self = shift;
	$self->markRead;
	$self->incrementViews;
	return $self->getThread->www_view;
}


1;

