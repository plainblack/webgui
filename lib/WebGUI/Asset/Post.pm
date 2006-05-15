package WebGUI::Asset::Post;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
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
use WebGUI::Cache;
use WebGUI::Group;
use WebGUI::HTML;
use WebGUI::HTMLForm;
use WebGUI::International;
use WebGUI::Inbox;
use WebGUI::Mail::Send;
use WebGUI::Operation;
use WebGUI::Paginator;
use WebGUI::SQL;
use WebGUI::Storage::Image;
use WebGUI::User;
use WebGUI::Utility;
use WebGUI::VersionTag;
our @ISA = qw(WebGUI::Asset);



#-------------------------------------------------------------------

=head2 addChild 

Overriding to limit the types of children allowed.

=cut

sub addChild {
	my $self = shift;
	my $properties = shift;
	my @other = @_;
	if ($properties->{className} ne "WebGUI::Asset::Post") {
		$self->session->errorHandler->security("tried to add a ".$properties->{className}." to a ".$self->get("className"));
		return undef;
	}
	return $self->SUPER::addChild($properties, @other);
}

#-------------------------------------------------------------------
                
=head2 addRevision
        
Override the default method in order to deal with attachments.

=cut

sub addRevision {
        my $self = shift;
        my $newSelf = $self->SUPER::addRevision(@_);
        if ($self->get("storageId")) {
                my $newStorage = WebGUI::Storage->get($self->session,$self->get("storageId"))->copy;
                $newSelf->update({storageId=>$newStorage->getId});
        }
	my $threadId = $newSelf->get("threadId");
	my $now = time();
	if ($threadId eq "") { # new post
		if ($newSelf->getParent->get("className") eq "WebGUI::Asset::Wobject::Collaboration") {
			$newSelf->update({threadId=>$newSelf->getId, dateSubmitted=>$now});
		} else {
			$newSelf->update({threadId=>$newSelf->getParent->get("threadId"), dateSubmitted=>$now});
		}
		delete $newSelf->{_thread};
	}
	$newSelf->update({
		isHidden => 1,
		dateUpdated=>$now,
		groupIdView=>$newSelf->getThread->getParent->get("groupIdView"),
		groupIdEdit=>$newSelf->getThread->getParent->get("groupIdEdit"),
		});
	$newSelf->getThread->unmarkRead;
        return $newSelf;
}  

#-------------------------------------------------------------------
sub canAdd {
	my $class = shift;
	my $session = shift;
	$class->SUPER::canAdd($session, undef, '7');
}

#-------------------------------------------------------------------
sub canEdit {
	my $self = shift;
	return (($self->session->form->process("func") eq "add" || ($self->session->form->process("assetId") eq "new" && $self->session->form->process("func") eq "editSave" && $self->session->form->process("class","className") eq "WebGUI::Asset::Post")) && $self->getThread->getParent->canPost) || # account for new posts

		($self->isPoster && $self->getThread->getParent->get("editTimeout") > ($self->session->datetime->time() - $self->get("dateUpdated"))) ||
		$self->getThread->getParent->canEdit;

}

#-------------------------------------------------------------------

=head2 canView ( )

Returns a boolean indicating whether the user can view the current post.

=cut

sub canView {
        my $self = shift;
        if (($self->get("status") eq "approved" || $self->get("status") eq "archived") && $self->getThread->getParent->canView) {
                return 1;
        } elsif ($self->canEdit) {
                return 1;
        } else {
                $self->getThread->getParent->canEdit;
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

sub commit {
	my $self = shift;
	$self->SUPER::commit;
	$self->getThread->unarchive if ($self->getThread->get("status") eq "archived");
        $self->notifySubscribers;
	if ($self->isNew) {
		if ($self->session->setting->get("enableKarma") && $self->getThread->getParent->get("karmaPerPost")) {
			my $u = WebGUI::User->new($self->session, $self->get("ownerUserId"));
			$u->addKarma($self->getThread->getParent->get("karmaPerPost"), $self->getId, "Collaboration post");
		}
        	$self->getThread->incrementReplies($self->get("dateUpdated"),$self->getId) if ($self->isReply);
	}
}

#-------------------------------------------------------------------
sub definition {
	my $class = shift;
	my $session = shift;
        my $definition = shift;
	my $i18n = WebGUI::International->new($session,"Asset_Post");
        push(@{$definition}, {
		assetName=>$i18n->get('assetName'),
		icon=>'post.gif',
                tableName=>'Post',
                className=>'WebGUI::Asset::Post',
                properties=>{
			storageId => {
				fieldType=>"image",
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
				defaultValue=>$session->datetime->time()
				},
			dateUpdated => {
				fieldType=>"hidden",
				defaultValue=>$session->datetime->time()
				},
			username => {
				fieldType=>"hidden",
				defaultValue=>$session->form->process("visitorUsername") || $session->user->profileField("alias") || $session->user->username
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
        return $class->SUPER::definition($session,$definition);
}


#-------------------------------------------------------------------
sub DESTROY {
	my $self = shift;
	$self->{_thread}->DESTROY if (exists $self->{_thread} && ref $self->{_thread} =~ /Thread/);
	$self->SUPER::DESTROY;
}


#-------------------------------------------------------------------

=head2 exportAssetData() ( )

See WebGUI::AssetPackage::exportAssetData() for details.

=cut

sub exportAssetData {
	my $self = shift;
	my $data = $self->SUPER::exportAssetData;
	push(@{$data->{storage}}, $self->get("storageId")) if ($self->get("storageId") ne "");
	return $data;
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
                $msg = WebGUI::HTML::processReplacements($self->session,$msg);
        }
        return $msg;
}

#-------------------------------------------------------------------

=head2 getAvatarUrl (  )

Returns a URL to the owner's avatar.

=cut

sub getAvatarUrl {
	my $self = shift;
	my $avatarUrl;
	return $avatarUrl unless
		$self->getThread->getParent->getValue("avatarsEnabled");
	my $user = WebGUI::User->new($self->session, $self->get('ownerUserId'));
	#Get avatar field, storage Id.
	my $storageId = $user->profileField("avatar");
	my $avatar = WebGUI::Storage::Image->get($self->session,$storageId);
	if ($avatar) {
		#Get url from storage object.
		foreach my $imageName (@{$avatar->getFiles}) {
			if ($avatar->isImage($imageName)) {
				$avatarUrl = $avatar->getUrl($imageName);
				last;
			}
		}
	}
	return $avatarUrl;
}

#-------------------------------------------------------------------

=head2 getDeleteUrl (  )

Formats the url to delete a post.

=cut

sub getDeleteUrl {
	my $self = shift;
	return $self->getUrl("func=delete;revision=".$self->get("revisionDate"));
}

#-------------------------------------------------------------------

=head2 getEditUrl ( )

Formats the url to edit a post.

=cut

sub getEditUrl {
	my $self = shift;
	return $self->getUrl("func=edit;revision=".$self->get("revisionDate"));
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

=head2 getPosterProfileUrl (  )

Formats the url to view a users profile.

=cut

sub getPosterProfileUrl {
	my $self = shift;
	return $self->getUrl("op=viewProfile;uid=".$self->get("ownerUserId"));
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
	return $self->getUrl("func=rate;rating=".$rating."#id".$self->getId);
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
	return $self->getUrl("func=add;class=WebGUI::Asset::Post;withQuote=".$withQuote);
}

#-------------------------------------------------------------------
sub getStatus {
	my $self = shift;
	my $status = $self->get("status");
	my $i18n = WebGUI::International->new($self->session,"Asset_Post");
        if ($status eq "approved") {
                return $i18n->get('approved');
        } elsif ($status eq "pending") {
                return $i18n->get('pending');
        } elsif ($status eq "archived") {
                return $i18n->get('archived');
        }
}

#-------------------------------------------------------------------
sub getStorageLocation {
	my $self = shift;
	unless (exists $self->{_storageLocation}) {
		if ($self->get("storageId") eq "") {
			$self->{_storageLocation} = WebGUI::Storage::Image->create($self->session);
			$self->update({storageId=>$self->{_storageLocation}->getId});
		} else {
			$self->{_storageLocation} = WebGUI::Storage::Image->get($self->session,$self->get("storageId"));
		}
	}
	return $self->{_storageLocation};
}

#-------------------------------------------------------------------
sub getSynopsisAndContent {
	my $self = shift;
	my $synopsis = shift;
	my $body = shift;
	unless ($synopsis) {
        	$body =~ s/\n/\^\-\;/ unless ($body =~ m/\^\-\;/);
       	 	my @content = split(/\^\-\;/,$body);
		$synopsis = WebGUI::HTML::filter($content[0],"all");
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
	$var{"avatar.url"} = $self->getAvatarUrl;
	$var{"userProfile.url"} = $self->getUrl("op=viewProfile;uid=".$self->get("ownerUserId"));
	$var{"dateSubmitted.human"} =$self->session->datetime->epochToHuman($self->get("dateSubmitted"));
	$var{"dateUpdated.human"} =$self->session->datetime->epochToHuman($self->get("dateUpdated"));
	$var{'title.short'} = $self->chopTitle;
	$var{content} = $self->formatContent if ($self->getThread);
	$var{'user.canEdit'} = $self->canEdit if ($self->getThread);
	$var{"delete.url"} = $self->getDeleteUrl;
	$var{"edit.url"} = $self->getEditUrl;
	$var{"status"} = $self->getStatus;
	$var{"reply.url"} = $self->getReplyUrl;
	$var{'reply.withquote.url'} = $self->getReplyUrl(1);
	$var{'url'} = $self->getUrl.'#id'.$self->getId;
	$var{'rating.value'} = $self->get("rating")+0;
	$var{'rate.url.thumbsUp'} = $self->getRateUrl(1);
	$var{'rate.url.thumbsDown'} = $self->getRateUrl(-1);
	$var{'hasRated'} = $self->hasRated;
	my $gotImage;
	my $gotAttachment;
	@{$var{'attachment_loop'}} = ();
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
				$gotAttachment = 1;
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
		$self->{_thread} = WebGUI::Asset::Post::Thread->new($self->session, $self->get("threadId"));
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

=head2 hasRated (  )

Returns a boolean indicating whether this user has already rated this post.

=cut

sub hasRated {	
	my $self = shift;
        return 1 if $self->isPoster;
	my $flag = 0;
	if ($self->session->user->userId eq "1") {
        	($flag) = $self->session->db->quickArray("select count(*) from Post_rating where assetId=? and ipAddress=?",[$self->getId, $self->session->env->get("REMOTE_ADDR")]);
	} else {
        	($flag) = $self->session->db->quickArray("select count(*) from Post_rating where assetId=? and userId=?",[$self->getId, $self->session->user->userId]);
	}
        return $flag;
}

#-------------------------------------------------------------------

=head2 indexContent ( )

Indexing the content of attachments and user defined fields. See WebGUI::Asset::indexContent() for additonal details. 

=cut

sub indexContent {
	my $self = shift;
	my $indexer = $self->SUPER::indexContent;
	$indexer->addKeywords($self->get("content"));
	$indexer->addKeywords($self->get("userDefined1"));
	$indexer->addKeywords($self->get("userDefined2"));
	$indexer->addKeywords($self->get("userDefined3"));
	$indexer->addKeywords($self->get("userDefined4"));
	$indexer->addKeywords($self->get("userDefined5"));
	$indexer->addKeywords($self->get("username"));
	my $storage = $self->getStorageLocation;
	foreach my $file (@{$storage->getFiles}) {
               $indexer->addFile($storage->getPath($file));
	}
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

=head2 isNew ( )

Returns a boolean indicating whether this post is new (not an edit).

=cut

sub isNew {
	my $self = shift;
	return $self->get("dateSubmitted") eq $self->get("dateUpdated");
}

#-------------------------------------------------------------------

=head2 isPoster ( )

Returns a boolean that is true if the current user created this post and is not a visitor.

=cut

sub isPoster {
	my $self = shift;
	return ($self->session->user->userId ne "1" && $self->session->user->userId eq $self->get("ownerUserId"));
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

=head2 notifySubscribers ( )

Send notifications to the thread and forum subscribers that a new post has been made.

=cut

sub notifySubscribers {
	my $self = shift;
	my $i18n = WebGUI::International->new($self->session);
	my $var = $self->getTemplateVars();
	$self->getThread->getParent->appendTemplateLabels($var);
	$var->{url} = $self->session->url->getSiteURL().$self->getUrl;
	$var->{'notify.subscription.message'} = $i18n->get(875,"Asset_Post");
	my $message = $self->processTemplate($var, $self->getThread->getParent->get("notificationTemplateId"));
	my $from = $self->getThread->getParent->get("mailAddress");
	my $subject = $self->getThread->getParent->get("mailPrefix").$self->get("title");
	my $mail = WebGUI::Mail::Send->create($self->session, {
		from=>$from,
		toGroup=>$self->getThread->getParent->get("subscriptionGroupId"),
		subject=>$subject,
		messageId=>"cs-".$self->getId
		});
	$mail->addHtml($message);
	$mail->addFooter;
	$mail->queue;
	my $mail = WebGUI::Mail::Send->create($self->session, {
		from=>$from,
		toGroup=>$self->getThread->get("subscriptionGroupId"),
		subject=>$subject,
		messageId=>"cs-".$self->getId
		});
	$mail->addHtml($message);
	$mail->addFooter;
	$mail->queue;
}


#-------------------------------------------------------------------
sub processPropertiesFromFormPost {
	my $self = shift;
	$self->SUPER::processPropertiesFromFormPost;	
	my $i18n = WebGUI::International->new($self->session);
	if ($self->session->form->process("assetId") eq "new") {
		my %data = (
			ownerUserId => $self->session->user->userId,
			username => $self->session->form->process("visitorName") || $self->session->user->profileField("alias") || $self->session->user->username,
			);
		$self->update(\%data);
		if ($self->getThread->getParent->canEdit) {
			$self->getThread->lock if ($self->session->form->process('lock'));
			$self->getThread->stick if ($self->session->form->process("stick"));
		}
	}
        $self->getThread->subscribe if ($self->session->form->process("subscribe"));
	$self->postProcess;
	$self->requestCommit;
}


#-------------------------------------------------------------------

sub postProcess {
	my $self = shift;
	my %data = ();
	($data{synopsis}, $data{content}) = $self->getSynopsisAndContent($self->get("synopsis"), $self->get("content"));
	my $user = WebGUI::User->new($self->session, $self->get("ownerUserId"));
	my $i18n = WebGUI::International->new($self->session, "Asset_Post");
	if ($self->getThread->getParent->get("addEditStampToPosts")) {
		$data{content} .= "<p>\n\n --- (".$i18n->get('Edited_on')." ".$self->session->datetime->epochToHuman(undef,"%z %Z [GMT%O]")." ".$i18n->get('By')." ".$user->profileField("alias").") --- \n</p>";
	}
	$data{url} = $self->fixUrl($self->getThread->get("url")."/1") if ($self->isReply && $self->isNew);
	$self->update(\%data);
	my $size = 0;
	my $storage = $self->getStorageLocation;
	foreach my $file (@{$storage->getFiles}) {
		if ($storage->isImage($file)) {
			$storage->generateThumbnail($file,$self->session->setting->get("maxImageSize"));
			$storage->deleteFile($file);
			$storage->renameFile('thumb-'.$file,$file);
			$storage->generateThumbnail($file);
		}
		$size += $storage->getFileSize($file);
	}
	$self->setSize($size);
}

#-------------------------------------------------------------------

sub purge {
        my $self = shift;
        my $sth = $self->session->db->read("select storageId from Post where assetId=".$self->session->db->quote($self->getId));
        while (my ($storageId) = $sth->array) {
		my $storage = WebGUI::Storage->get($self->session, $storageId);
                $storage->delete if defined $storage;
        }
        $sth->finish;
        return $self->SUPER::purge;
}

#-------------------------------------------------------------------

=head2 purgeCache ()

See WebGUI::Asset::purgeCache() for details.

=cut

sub purgeCache {
	my $self = shift;
	WebGUI::Cache->new($self->session,"view_".$self->getThread->getId)->delete if ($self->getThread);
	$self->SUPER::purgeCache;
}

#-------------------------------------------------------------------

sub purgeRevision {
        my $self = shift;
        $self->getStorageLocation->delete;
        return $self->SUPER::purgeRevision;
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
	return undef unless ($rating == -1 || $rating == 1);
	unless ($self->hasRated) {
        	$self->session->db->write("insert into Post_rating (assetId,userId,ipAddress,dateOfRating,rating) values ("
                	.$self->session->db->quote($self->getId).", ".$self->session->db->quote($self->session->user->userId).", ".$self->session->db->quote($self->session->env->get("REMOTE_ADDR")).", 
			".$self->session->datetime->time().", ".$self->session->db->quote($rating).")");
        	my ($sum) = $self->session->db->quickArray("select sum(rating) from Post_rating where assetId=".$self->session->db->quote($self->getId));
        	$self->update({rating=>$sum});
		$self->getThread->rate($rating);
	}
}

#-------------------------------------------------------------------
# allows us to let the cs post use it's own workflow approval process
sub requestCommit {
	my $self = shift;
	my $currentTag = WebGUI::VersionTag->getWorking($self->session);
	if ($currentTag->getAssetCount < 2) {
		$currentTag->set({workflowId=>$self->getThread->getParent->get("approvalWorkflow")});
		$currentTag->requestCommit;
	} else {
		my $newTag = WebGUI::VersionTag->create($self->session, {
			name=>$self->getTitle." / ".$self->session->user->username,
			workflowId=>$self->getThread->getParent->get("approvalWorkflow")
			});
		$self->session->db->write("update assetData set tagId=? where assetId=? and tagId=?",[$newTag->getId, $self->getId, $currentTag->getId]);
		$self->purgeCache;
		$newTag->requestCommit;
	}
}

#-------------------------------------------------------------------

=head2 setParent ( newParent ) 

We're overloading the setParent in Asset because we don't want posts to be able to be posted to anything other than other posts or threads.

=head3 newParent

An asset object to make the parent of this asset.

=cut

sub setParent {
        my $self = shift;
        my $newParent = shift;
        return 0 unless ($newParent->get("className") eq "WebGUI::Asset::Post" || $newParent->get("className") eq "WebGUI::Asset::Post::Thread");
        return $self->SUPER::setParent($newParent);
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

=head2 setStatusUnarchived ( )

Sets the status of this post to approved, but does so without any of the normal notifications and other stuff.

=cut


sub setStatusUnarchived {
        my ($self) = @_;
        $self->update({status=>'approved'}) if ($self->get("status") eq "archived");
}

#-------------------------------------------------------------------

=head2 trash

Moves post to the trash and decrements reply counter on thread.

=cut

sub trash {
        my $self = shift;
        $self->SUPER::trash;
        $self->getThread->decrementReplies if ($self->isReply);
        if ($self->getThread->get("lastPostId") eq $self->getId) {
                my $threadLineage = $self->getThread->get("lineage");
                my ($id, $date) = $self->session->db->quickArray("select Post.assetId, Post.dateSubmitted from Post, asset where asset.lineage like ".$self->session->db->quote($threadLineage.'%')." and Post.assetId<>".$self->session->db->quote($self->getId)." and asset.assetId=Post.assetId and asset.state='published' order by Post.dateSubmitted desc");
                $self->getThread->update({lastPostId=>$id, lastPostDate=>$date});
        }
        if ($self->getThread->getParent->get("lastPostId") eq $self->getId) {
                my $forumLineage = $self->getThread->getParent->get("lineage");
                my ($id, $date) = $self->session->db->quickArray("select Post.assetId, Post.dateSubmitted from Post, asset where asset.lineage like ".$self->session->db->quote($forumLineage.'%')." and Post.assetId<>".$self->session->db->quote($self->getId)." and asset.assetId=Post.assetId and asset.state='published' order by Post.dateSubmitted desc");
                $self->getThread->getParent->update({lastPostId=>$id, lastPostDate=>$date});
        }
}

#-------------------------------------------------------------------

=head2 update

We overload the update method from WebGUI::Asset in order to handle file system privileges.

=cut

sub update {
        my $self = shift;
        my %before = (
               	owner => $self->get("ownerUserId"),
                view => $self->get("groupIdView"),
                edit => $self->get("groupIdEdit")
                );
        $self->SUPER::update(@_);
        if ($self->get("ownerUserId") ne $before{owner} || $self->get("groupIdEdit") ne $before{edit} || $self->get("groupIdView") ne $before{view}) {
               	$self->getStorageLocation->setPrivileges($self->get("ownerUserId"),$self->get("groupIdView"),$self->get("groupIdEdit"));
        }
}

#-------------------------------------------------------------------
sub view {
	my $self = shift;
	$self->incrementViews;
	return $self->getThread->view;
}


#-------------------------------------------------------------------
sub www_deleteFile {
	my $self = shift;
	$self->getStorageLocation->deleteFile($self->session->form->process("filename")) if $self->canEdit;
	return $self->www_edit;
}


#-------------------------------------------------------------------
sub www_edit {
	my $self = shift;
	my %var;
	my $content;
	my $title;
	my $i18n = WebGUI::International->new($self->session);
	if ($self->session->form->process("func") eq "add") { # new post
        	$var{'form.header'} = WebGUI::Form::formHeader($self->session,{action=>$self->getParent->getUrl})
			.WebGUI::Form::hidden($self->session, {
                		name=>"func",
				value=>"add"
				})
			.WebGUI::Form::hidden($self->session, {
				name=>"assetId",
				value=>"new"
				})
			.WebGUI::Form::hidden($self->session, {
				name=>"class",
				value=>$self->session->form->process("class","className")
				});
        	$var{'isNewPost'} = 1;
		$content = $self->session->form->process("content");
		$title = $self->session->form->process("title");
		if ($self->session->form->process("class","className") eq "WebGUI::Asset::Post") { # new reply
			$self->{_thread} = $self->getParent->getThread;
			return $self->session->privilege->insufficient() unless ($self->getThread->canReply);
			$var{isReply} = 1;
			$var{'reply.title'} = $self->getParent->get("title");
			$var{'reply.synopsis'} = $self->getParent->get("synopsis");
			$var{'reply.content'} = $self->getParent->formatContent;
			for my $i (1..5) {	
				$var{'reply.userDefined'.$i} = WebGUI::HTML::filter($self->getParent->get('userDefined'.$i),"macros");
			}
			unless ($self->session->form->process("content") || $self->session->form->process("title")) {
                		$content = "[quote]".$self->getParent->get("content")."[/quote]" if ($self->session->form->process("withQuote"));
                		$title = $self->getParent->get("title");
                		$title = "Re: ".$title unless ($title =~ /^Re:/);
			}
			$var{'subscribe.form'} = WebGUI::Form::yesNo($self->session, {
				name=>"subscribe",
				value=>$self->session->form->process("subscribe")
				});
		} elsif ($self->session->form->process("class","className") eq "WebGUI::Asset::Post::Thread") { # new thread
			return $self->session->privilege->insufficient() unless ($self->getThread->getParent->canPost);
			$var{isNewThread} = 1;
                	if ($self->getThread->getParent->canEdit) {
                        	$var{'sticky.form'} = WebGUI::Form::yesNo($self->session, {
                                	name=>'stick',
                                	value=>$self->session->form->process("stick")
                                	});
                        	$var{'lock.form'} = WebGUI::Form::yesNo($self->session, {
                       	         	name=>'lock',
                                	value=>$self->session->form->process('lock')
                                	});
			}
			$var{'subscribe.form'} = WebGUI::Form::yesNo($self->session, {
				name=>"subscribe",
				value=>$self->session->form->process("subscribe") || 1
				});
		}
                $content .= "\n\n".$self->session->user->profileField("signature") if ($self->session->user->profileField("signature") && !$self->session->form->process("content"));
	} else { # edit
		return $self->session->privilege->insufficient() unless ($self->canEdit);
		$var{isThread} = !$self->isReply;
        	$var{'form.header'} = WebGUI::Form::formHeader($self->session,{action=>$self->getUrl})
			.WebGUI::Form::hidden($self->session, {
                		name=>"func",
				value=>"edit"
				})
			.WebGUI::Form::hidden($self->session, {
				name=>"revision",
				value=>$self->session->form->param("revision")
				})
			.WebGUI::Form::hidden($self->session, {
				name=>"ownerUserId",
				value=>$self->getValue("ownerUserId")
				})
			.WebGUI::Form::hidden($self->session, {
				name=>"username",
				value=>$self->getValue("username")
				});
		$var{isEdit} = 1;
		$content = $self->getValue("content");
		$title = $self->getValue("title");
	}
	$var{'form.header'} .= WebGUI::Form::hidden($self->session, {name=>"proceed", value=>"showConfirmation"});
	if ($self->session->form->process("title") || $self->session->form->process("content") || $self->session->form->process("synopsis")) {
		$var{'preview.title'} = WebGUI::HTML::filter($self->session->form->process("title"),"all");
		($var{'preview.synopsis'}, $var{'preview.content'}) = $self->getSynopsisAndContent($self->session->form->process("synopsis","textarea"), $self->session->form->process("content","HTMLArea")); 
		$var{'preview.content'} = $self->formatContent($var{'preview.content'},$self->session->form->process("contentType"));
		for my $i (1..5) {	
			$var{'preview.userDefined'.$i} = WebGUI::HTML::filter($self->session->form->process('userDefined'.$i),"macros");
		}
	}
	$var{'form.footer'} = WebGUI::Form::formFooter($self->session,);
	$var{usePreview} = $self->getThread->getParent->get("usePreview");
	$var{'user.isModerator'} = $self->getThread->getParent->canEdit;
	$var{'user.isVisitor'} = ($self->session->user->userId eq '1');
	$var{'visitorName.form'} = WebGUI::Form::text($self->session, {
		name=>"visitorName",
		value=>$self->getValue("visitorName")
		});
	for my $x (1..5) {
		$var{'userDefined'.$x.'.form'} = WebGUI::Form::text($self->session, {
			name=>"userDefined".$x,
			value=>$self->getValue("userDefined".$x)
			});
		$var{'userDefined'.$x.'.form.yesNo'} = WebGUI::Form::yesNo($self->session, {
			name=>"userDefined".$x,
			value=>$self->getValue("userDefined".$x)
			});
		$var{'userDefined'.$x.'.form.textarea'} = WebGUI::Form::textarea($self->session, {
			name=>"userDefined".$x,
			value=>$self->getValue("userDefined".$x)
			});
		$var{'userDefined'.$x.'.form.htmlarea'} = WebGUI::Form::HTMLArea($self->session, {
			name=>"userDefined".$x,
			value=>$self->getValue("userDefined".$x)
			});
		$var{'userDefined'.$x.'.form.float'} = WebGUI::Form::Float($self->session, {
			name=>"userDefined".$x,
			value=>$self->getValue("userDefined".$x)
			});
	}
	$title = WebGUI::HTML::filter($title,"all");
	$content = WebGUI::HTML::filter($content,"macros");
	$var{'title.form'} = WebGUI::Form::text($self->session, {
		name=>"title",
		value=>$title
		});
	$var{'title.form.textarea'} = WebGUI::Form::textarea($self->session, {
		name=>"title",
		value=>$title
		});
	$var{'synopsis.form'} = WebGUI::Form::textarea($self->session, {
		name=>"synopsis",
		value=>WebGUI::HTML::filter($self->getValue("synopsis"),"all")
		});
	$var{'content.form'} = WebGUI::Form::HTMLArea($self->session, {
		name=>"content",
		value=>$content,
		richEditId=>$self->getThread->getParent->get("richEditor")
		});
	$var{'form.submit'} = WebGUI::Form::submit($self->session, {
		extras=>"onclick=\"this.value='".$i18n->get(452)."'; this.form.func.value='editSave'; this.form.submit();return false;\""
		});
	$var{'karmaScale.form'} = WebGUI::Form::integer($self->session, {
		name=>"karmaScale",
		defaultValue=>$self->getThread->getParent->get("defaultKarmaScale"),
		value=>$self->getValue("karmaScale"),
		});
	$var{karmaIsEnabled} = $self->session->setting->get("useKarma");
	$var{'form.preview'} = WebGUI::Form::submit($self->session, {
		value=>$i18n->get("preview","Asset_Collaboration")
		});
	$var{'attachment.form'} = WebGUI::Form::image($self->session, {
		value=>$self->get("storageId"),
		maxAttachments=>$self->getThread->getParent->getValue("attachmentsPerPost"),
		deleteFileUrl=>$self->getUrl("func=deleteFile;filename=")
		});
        $var{'contentType.form'} = WebGUI::Form::contentType($self->session, {
                name=>'contentType',
                value=>$self->getValue("contentType") || "mixed"
                });
	$self->getThread->getParent->appendTemplateLabels(\%var);
	return $self->getThread->getParent->processStyle($self->processTemplate(\%var,$self->getThread->getParent->get("postFormTemplateId")));
}


#-------------------------------------------------------------------

=head2 www_editSave ()

We're extending www_editSave() here to deal with editing a post that has been denied by the approval process.  Our change will reassign the old working tag of this post to the user so that they can edit it.

=cut

sub www_editSave {
	my $self = shift;
	return $self->session->privilege->insufficient() unless $self->canEdit;
	if ($self->session->config("maximumAssets")) {
		my ($count) = $self->session->db->quickArray("select count(*) from asset");
		my $i18n = WebGUI::International->new($self->session, "Asset");
		return $self->session->style->userStyle($i18n->get("over max assets")) if ($self->session->config("maximumAssets") <= $count);
	}
	if ($self->session->form->param("assetId") ne "new" && $self->get("status") eq "pending") { 
		my $currentTag = WebGUI::VersionTag->getWorking($self->session, 1);
		if (defined $currentTag && $currentTag->getAssetCount > 0) {
			# play a little working tag switcheroo
			$self->session->stow("temporaryWorkingTagHolder",$currentTag);
		}
		my $tag = WebGUI::VersionTag->new($self->session, $self->get("tagId"));
		$tag->setWorking if defined $tag;
	}
	my $output = $self->SUPER::www_editSave();
	if ($self->session->stow->get("temporaryWorkingTagHolder")) {
		# undo switcharoo
		my $tag = $self->session->stow->get("temporaryWorkingTagHolder");
		$tag->setWorking if defined $tag;
		$self->session->stow->delete("temporaryWorkingTagHolder");
	}	
	return $output;
}

#-------------------------------------------------------------------

=head2 www_ratePost ( )

The web method to rate a post.

=cut

sub www_rate {	
	my $self = shift;
	$self->WebGUI::Asset::Post::rate($self->session->form->process("rating")) if ($self->canView && !$self->hasRated);
	$self->www_view;
}


#-------------------------------------------------------------------

=head2 www_showConfirmation ( )

Shows a confirmation message letting the user know their post has been submitted.

=cut 

sub www_showConfirmation {
	my $self = shift;
	my $i18n = WebGUI::International->new($self->session, "Asset_Post");
	return $self->getThread->getParent->processStyle('<p>'.$i18n->get("post received").'</p><p><a href="'.$self->getThread->getParent->getUrl.'">'.$i18n->get("493","WebGUI").'</a></p>');
}



#-------------------------------------------------------------------
sub www_view {
	my $self = shift;
	$self->incrementViews;
	return $self->getThread->www_view;
}


1;

