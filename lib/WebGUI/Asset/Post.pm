package WebGUI::Asset::Post;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use Moose;
use WebGUI::Definition::Asset;
extends 'WebGUI::Asset';
define assetName => ['assetName', 'Asset_Post'];
define icon      => 'post.gif';
define tableName => 'Post';
property storageId => (
            fieldType         => "image",
            default           => '',
            enforceSizeLimits => 0,
            label             => ['attachement', 'Asset_Collaboration'],
         );
property threadId => (
            noFormPost  => 1,
            fieldType   => "hidden",
            default     => '',
         );
property originalEmail => (
            noFormPost  => 1,
            fieldType   => "hidden",
            default     => undef,
         );
property username => (
            noFormPost  => 1,
            fieldType   => "hidden",
            builder     => '_username_builder',
            lazy        => 1,
         );
sub _username_builder {
    my $session = shift->session;
    return $session->form->process("visitorUsername")
        || $session->user->profileField("alias")
        || $session->user->username;
}
property rating => (
            noFormPost  => 1,
            fieldType   => "hidden",
            default     => undef,
         );
property views => ( 
            noFormPost  => 1,
            fieldType   => "hidden",
            default     => undef,
         );
property contentType => (
            label       => ['contentType', 'Asset_Collaboration'],
            fieldType   => "contentType",
            default     => "mixed",
         );
for my $i ( 1 .. 5 ) {
    property 'userDefined'.$i => (
        default     => undef,
        label       => '',
        fieldType   => 'HTMLArea',
    );
}
property content => (
            label       => ['message', 'Asset_Collaboration'],
            fieldType   => "HTMLArea",
            default     => undef,
         );

with 'WebGUI::Role::Asset::AlwaysHidden';

with 'WebGUI::Role::Asset::SetStoragePermissions';

use WebGUI::Group;
use WebGUI::HTML;
use WebGUI::HTMLForm;
use WebGUI::Form::DynamicField;
use WebGUI::International;
use WebGUI::Inbox;
use WebGUI::Macro;
use WebGUI::Mail::Send;
use WebGUI::Operation;
use WebGUI::Paginator;
use WebGUI::SQL;
use WebGUI::Storage;
use WebGUI::User;
use WebGUI::VersionTag;

#-------------------------------------------------------------------

=head2 _fixReplyCount ( asset )

Fixes the mismatch in number of replies and lastPost in a thread and/or a CS that occurs after a cut or paste
action.

Note: if invoked on a thread the CS containing it will very likely be changed as well, but likely in an incorrect
manner. Therfore, after running this method on a Thread you probably also want to run it on the container CS.

=head3 asset

The instanciated asset to fix. This may only be either a WebGUI::Asset::Post::Thread or a
WebGUI::Asset::Wobject::Collaboration.

=cut

sub _fixReplyCount {
    my $self    = shift;
    my $asset   = shift;

    my $lastPost = $asset->getLineage( [ qw{ self descendants } ], {
        returnObjects   => 1,
        isa             => 'WebGUI::Asset::Post',
        orderByClause   => 'assetData.revisionDate desc',
        limit           => 1,
    } )->[0];

    if ($lastPost) {
        $asset->incrementReplies( $lastPost->revisionDate, $lastPost->getId );
    }
    else {
        $asset->incrementReplies( undef, undef );
    }
}

#-------------------------------------------------------------------

=head2 addRevision ( )

Override the default method in order to deal with attachments.

=cut

override addRevision => sub {
    my $self    = shift;
    my $newSelf = super();
    if ( $newSelf->storageId && $newSelf->storageId eq $self->storageId ) {
        my $newStorage = WebGUI::Storage->get( $self->session, $self->storageId )->copy;
        $newSelf->update( { storageId => $newStorage->getId } );
    }
    my $threadId = $newSelf->threadId;
    my $now      = time();
    if ( $threadId eq "" ) {    # new post
        if ( $newSelf->getParent->isa("WebGUI::Asset::Wobject::Collaboration") ) {
            $newSelf->update( { threadId => $newSelf->getId } );
        }
        else {
            $newSelf->update( { threadId => $newSelf->getParent->threadId } );
        }
        delete $newSelf->{_thread};
    }
    $newSelf->getThread->unmarkRead;

    return $newSelf;
};

#-------------------------------------------------------------------

=head2 canAdd 

Extend the master class to make the default group 7.

=cut

sub canAdd {
	my $class = shift;
	my $session = shift;
	$class->SUPER::canAdd($session, undef, '7');
}

#-------------------------------------------------------------------

=head2 canEdit ($userId)

If adding new posts, the check the parent's canPost method.

If the user made this post, then check the editTimeout.

Anyone in groupToEditPost is allowed to edit any post.

Otherwise, anyone who canEdit the parent collaboration system can edit a post.

=head3 $userId

The userId of the user to check for permissions.  If not passed, then it will
use the session user instead.

=cut

sub canEdit {
    my $self    = shift;
    my $userId  = shift || $self->session->user->userId;
    my $session = $self->session;
    my $form    = $self->session->form;
    my $user    = WebGUI::User->new( $session, $userId );

    # Handle adding new posts
    if (  
        ( $form->get("func") eq "add" 
            || ( $form->get("func") eq "editSave" && $form->get("assetId") eq "new" )
        )
        && $form->get("class") eq "WebGUI::Asset::Post"
    ) {
        return $self->getThread->getParent->canPost;
    }

    # User who posted can edit their own post
    if ( $self->isPoster( $userId ) ) {
        my $editTimeout = $self->getThread->getParent->editTimeout;
        if ( $editTimeout > time - $self->revisionDate ) {
            return 1;
        }
    }

    # Users in groupToEditPost of the Collab can edit any post
    if ( $user->isInGroup( $self->getThread->getParent->groupToEditPost ) ) {
        return 1;
    }

    return $self->getThread->getParent->canEdit( $userId );
}

#-------------------------------------------------------------------

=head2 canView ( )

Returns a boolean indicating whether the user can view the current post.

=cut

sub canView {
        my $self = shift;
        if (($self->status eq "approved" || $self->status eq "archived") && $self->getThread->getParent->canView) {
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
    return substr($self->title,0,30);
}

#-------------------------------------------------------------------

=head2 commit 

Extends the master class to notify subscribers, handle karmaPerPost, and 
increment replies for the parent thread.

=cut

override commit => sub {
    my $self = shift;
    super();

    $self->notifySubscribers unless ( $self->shouldSkipNotification );

    if ( $self->isNew ) {
        if ( $self->session->setting->get("useKarma") && $self->getThread->getParent->karmaPerPost ) {
            my $u = WebGUI::User->new( $self->session, $self->ownerUserId );
            $u->karma( $self->getThread->getParent->karmaPerPost, $self->getId, "Collaboration post" );
        }
        $self->getThread->incrementReplies( $self->revisionDate, $self->getId );    # if ($self->isReply);
    }
};

#-------------------------------------------------------------------

=head2 cut 

Extend the master method to handle changing adjusting the number of replies to
the parent thread.

=cut

sub cut {
    my $self = shift;

    # Fetch the Thread and CS before cutting the asset.
    my $thread  = $self->getThread;
    my $cs      = $thread->getParent;

    # Cut the asset
    my $result = $self->SUPER::cut;

    # If a post is being cut update the thread reply count first
    if ($thread->getId ne $self->getId) {
        $self->_fixReplyCount( $thread );
    }

    # Update the CS reply count. This step is also necessary when a Post is cut since the Thread's incrementReplies
    # also calls the CS's incrementReplies, possibly with the wrong last post Id.
    $self->_fixReplyCount( $cs );

    return $result;
}

#-------------------------------------------------------------------

=head2 DESTROY 

Extend the base method to delete the locally cached thread object.

=cut

sub DESTROY {
	my $self = shift;
	$self->{_thread}->DESTROY if (exists $self->{_thread} && ref $self->{_thread} =~ /Thread/);
	$self->SUPER::DESTROY;
}


#-------------------------------------------------------------------

=head2 exportAssetData ( )

Extend the base class to handle storage locations.

=cut

sub exportAssetData {
	my $self = shift;
	my $data = $self->SUPER::exportAssetData;
	push(@{$data->{storage}}, $self->storageId) if ($self->storageId ne "");
	return $data;
}

#-------------------------------------------------------------------

=head2 fixUrl ( url ) 

Extends superclass method to remove periods from post urls

=head3 url

The url of the post

=cut

sub fixUrl {
	my $self = shift;
	my $url = shift;
	$url =~ s/\./_/g;

	$self->SUPER::fixUrl($url);
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
	my $content = shift || $self->content;
	my $contentType = shift || $self->contentType;	
        my $msg = undef ;
	if (!$self->isa("WebGUI::Asset::Post::Thread")) { # apply appropriate content filter
		$msg = WebGUI::HTML::filter($content,$self->getThread->getParent->replyFilterCode);
	} else {
		$msg = WebGUI::HTML::filter($content,$self->getThread->getParent->filterCode);
	}
        $msg = WebGUI::HTML::format($msg, $contentType);
        if ($self->getThread->getParent->useContentFilter) {
                $msg = WebGUI::HTML::processReplacements($self->session,$msg);
        }
        return $msg;
}

#-------------------------------------------------------------------

=head2 getAutoCommitWorkflowId 

Overide the master method to return the workflow stored in the parent collaboration system.

=cut

sub getAutoCommitWorkflowId {
    my $self = shift;
    my $cs = $self->getThread->getParent;
    if ($cs->hasBeenCommitted) {
        return $cs->approvalWorkflow
            || $self->session->setting->get('defaultVersionTagWorkflow');
    }
    return undef;
}

#-------------------------------------------------------------------

=head2 getAvatarUrl ( )

Returns a URL to the owner's avatar.

=cut

sub getAvatarUrl {
	my $self = shift;
	my $parent = $self->getThread->getParent;
	return '' unless $parent and $parent->avatarsEnabled;
	my $user = WebGUI::User->new($self->session, $self->ownerUserId);
	#Get avatar field, storage Id.
	my $storageId = $user->profileField("avatar");
	return '' unless $storageId;
	my $avatar = WebGUI::Storage->get($self->session,$storageId);
	my $avatarUrl = '';
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

=head2 getDeleteUrl ( )

Formats the url to delete a post.

=cut

sub getDeleteUrl {
	my $self = shift;
	return $self->getUrl("func=delete;revision=".$self->revisionDate);
}

#-------------------------------------------------------------------

=head2 getEditUrl ( )

Formats the url to edit a post.

=cut

sub getEditUrl {
	my $self = shift;
	return $self->getUrl("func=edit;revision=".$self->revisionDate);
}


#-------------------------------------------------------------------

=head2 getImageUrl 

Returns a URL to the first image stored in the storage location for this Post.  If there
are not stored files, it returns undef.

=cut

sub getImageUrl {
	my $self = shift;
	return undef if ($self->storageId eq "");
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

=head2 getPosterProfileUrl ( )

Formats the url to view a users profile.

=cut

sub getPosterProfileUrl {
	my $self = shift;
	return WebGUI::User->new($self->session,$self->ownerUserId)->getProfileUrl;
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

=head2 getStatus 

Returns the status of this Post, 'approved', 'pending', or 'archived'.

=cut

sub getStatus {
	my $self = shift;
	my $status = $self->status;
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

=head2 getStorageLocation 

Returns a storage location for this Post.  If one does not exist, it
creates one.

=cut

sub getStorageLocation {
	my $self = shift;
	unless (exists $self->{_storageLocation}) {
		if ($self->storageId eq "") {
			$self->{_storageLocation} = WebGUI::Storage->create($self->session);
			$self->update({storageId=>$self->{_storageLocation}->getId});
		} else {
			$self->{_storageLocation} = WebGUI::Storage->get($self->session,$self->storageId);
		}
	}
	return $self->{_storageLocation};
}

#-------------------------------------------------------------------

=head2 getSynopsisAndContent ($synopsis, $body)

Returns a synopsis taken from the body of the Post, based on either the separator
macro, the first html paragraph, or the first physical line of text as defined by
newlines.

Returns both the synopsis, and the original body content.

=head3 $synopsis

If passed in, it returns that instead of the calculated synopsis.

=head3 $body

Body of the Post to use a source for the synopsis.

=cut

sub getSynopsisAndContent {
	my $self = shift;
	my $synopsis = shift;
	my $body = shift;
	unless ($synopsis) {
           my @content;
           if( $body =~ /\^\-\;/ ) {
               my @pieces = WebGUI::HTML::splitSeparator($body);
               $content[0] = shift @pieces;
               $content[1] = join '', @pieces;
           }
           elsif( $body =~ /<p>/ ) {
               @content = WebGUI::HTML::splitTag($body);
           }
           else {
       	       @content = split("\n",$body);
           }
           shift @content if $content[0] =~ /^\s*$/;
           $synopsis = WebGUI::HTML::filter($content[0],"all");
	}
	return ($synopsis,$body);
}

#-------------------------------------------------------------------

=head2 getTemplateMetadataVars ( $var )

Append metadata as template variables.

=head3 $var

A hash reference.  The template variables will be added to that hash ref.

=cut

sub getTemplateMetadataVars {
	my $self = shift;
    my $var  = shift;
    if ($self->session->setting->get("metaDataEnabled")
     && $self->getThread->getParent->enablePostMetaData) {
        my $meta = $self->getMetaDataFields();
        my @meta_loop = ();
        foreach my $field (keys %{ $meta }) {
            push @meta_loop, {
                value => $meta->{$field}{value},
                name  => $meta->{$field}{fieldName},
            };
            my $fieldName = $meta->{$field}{fieldName};
            $fieldName =~ tr/ /_/;
            $fieldName = lc $fieldName;
            $var->{'meta_'.$fieldName.'_value'} = $meta->{$field}{value};  ##By name interface
        }
        $var->{meta_loop} = \@meta_loop;
    }
}

#-------------------------------------------------------------------

=head2 getTemplateVars 

Returns a hash reference of template variables for this Post.

=cut

sub getTemplateVars {
	my $self    = shift;
    my $session = $self->session;
	my %var     = %{$self->get};
    my $postUser   = WebGUI::User->new($session, $self->ownerUserId);
	$var{"userId"} = $self->ownerUserId;
	$var{"user.isPoster"} = $self->isPoster;
	$var{"avatar.url"}    = $self->getAvatarUrl;
	$var{"userProfile.url"} = $postUser->getProfileUrl($self->getUrl());
	$var{"dateSubmitted.human"} =$self->session->datetime->epochToHuman($self->creationDate);
	$var{"dateUpdated.human"} =$self->session->datetime->epochToHuman($self->revisionDate);
	$var{'title.short'} = $self->chopTitle;
	$var{content} = $self->formatContent if ($self->getThread);
	$var{'user.canEdit'} = $self->canEdit if ($self->getThread);
	$var{"delete.url"} = $self->getDeleteUrl;
	$var{"edit.url"} = $self->getEditUrl;
	$var{"status"} = $self->getStatus;
	$var{"reply.url"} = $self->getReplyUrl;
	$var{'reply.withquote.url'} = $self->getReplyUrl(1);
	$var{'url'} = $self->getUrl.'#id'.$self->getId;
        $var{'url.raw'} = $self->getUrl;
	$var{'rating.value'} = $self->rating+0;
	$var{'rate.url.thumbsUp'} = $self->getRateUrl(1);
	$var{'rate.url.thumbsDown'} = $self->getRateUrl(-1);
	$var{'hasRated'} = $self->hasRated;
	my $gotImage;
	my $gotAttachment;
	@{$var{'attachment_loop'}} = ();
	unless ($self->storageId eq "") {
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
    $self->getTemplateMetadataVars(\%var);
	return \%var;
}

#-------------------------------------------------------------------

=head2 getThread

Returns the Thread that this Post belongs to.  The method caches the result of the Asset creation.

=cut

sub getThread {
	my $self = shift;
	unless (defined $self->{_thread}) {
		my $threadId = $self->threadId;
                if ($threadId eq "") { # new post
                        if ($self->getParent->isa("WebGUI::Asset::Wobject::Collaboration")) {
                                $threadId=$self->getId;
                        } else {
                                $threadId=$self->getParent->threadId;
                        }
                }
                $self->{_thread} = WebGUI::Asset::Post::Thread->newById($self->session, $threadId);
	}
	return $self->{_thread};	
}

#-------------------------------------------------------------------

=head2 getThumbnailUrl 

If this Post has a storage location, returns a URL to the thumbnail of the first image that
is stored in it.  Otherwise, it returns undef.

=cut

sub getThumbnailUrl {
	my $self = shift;
	return undef if ($self->storageId eq "");
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

=head2 hasRated ( )

Returns a boolean indicating whether this user has already rated this post.

=cut

sub hasRated {	
	my $self = shift;
        return 1 if $self->isPoster;
	my $flag = 0;
	if ($self->session->user->isVisitor) {
        	($flag) = $self->session->db->quickArray("select count(*) from Post_rating where assetId=? and ipAddress=?",[$self->getId, $self->session->env->getIp]);
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
	$indexer->addKeywords($self->content);
	$indexer->addKeywords($self->userDefined1);
	$indexer->addKeywords($self->userDefined2);
	$indexer->addKeywords($self->userDefined3);
	$indexer->addKeywords($self->userDefined4);
	$indexer->addKeywords($self->userDefined5);
	$indexer->addKeywords($self->username);
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
        $self->update({views=>$self->views+1});
}

#-------------------------------------------------------------------

=head2 insertUserPostRating ( rating )

Register the user's rating against this post.

=head3 rating

An integer indicating either thumbss up (+1) or thumbs down (-1)

=cut

sub insertUserPostRating {
	my $self = shift;
	my $rating = shift;
	return undef unless ($rating == -1 || $rating == 1);
	return undef if $self->hasRated;
	$self->session->db->write("insert into Post_rating (assetId,userId,ipAddress,dateOfRating,rating) values (?,?,?,?,?)",
		[$self->getId,
		 $self->session->user->userId,
		 $self->session->env->getIp,
		 $self->session->datetime->time(),
		 $rating,]
	);
}

#-------------------------------------------------------------------

=head2 isNew ( )

Returns a boolean indicating whether this post is new (not an edit).

=cut

sub isNew {
	my $self = shift;
	return $self->creationDate == $self->revisionDate;
}

#-------------------------------------------------------------------

=head2 isPoster ( userId )

Returns a boolean that is true if the current user created this post and is not a visitor.

=cut

sub isPoster {
    my $self    = shift;
    my $userId  = shift     || $self->session->user->userId;
    return ( $userId ne "1" && $userId eq $self->ownerUserId );
}


#-------------------------------------------------------------------

=head2 isReply ( )

Returns a boolean indicating whether this post is a reply.

=cut

sub isReply {
	my $self = shift;
	return $self->getId ne $self->threadId;
}


#-------------------------------------------------------------------

=head2 notifySubscribers ( )

Send notifications to the thread and forum subscribers that a new post has been made.

=cut

sub notifySubscribers {
    my $self = shift;
    my $i18n = WebGUI::International->new($self->session);
    my $var = $self->getTemplateVars();
    my $thread = $self->getThread;
    my $cs = $thread->getParent;
    $cs->appendTemplateLabels($var);
    $var->{relativeUrl} = $var->{url};
    my $siteurl = $self->session->url->getSiteURL();
    $var->{url} = $siteurl.$self->getUrl;
    $var->{'notify.subscription.message'} = $i18n->get(875,"Asset_Post");
    my $user = WebGUI::User->new($self->session, $self->ownerUserId);
    my $setting = $self->session->setting;
    my $returnAddress = $setting->get("mailReturnPath");
    my $companyAddress = $setting->get("companyEmail");
    my $listAddress = $cs->mailAddress;
    my $posterAddress = $user->getProfileFieldPrivacySetting('email') eq "all"
                      ? $user->profileField('email')
                      : '';
    my $from = $posterAddress || $listAddress || $companyAddress;
    my $replyTo = $listAddress || $returnAddress || $companyAddress;
    my $sender = $listAddress || $companyAddress || $posterAddress;
    my $returnPath = $returnAddress || $sender;
    my $listId = $sender;
    $listId =~ s/\@/\./;
    my $domain = $cs->mailAddress;
    $domain =~ s/.*\@(.*)/$1/;
    my $messageId = "cs-".$self->getId.'@'.$domain;
    my $replyId = "";
    if ($self->isReply) {
        $replyId = "cs-".$self->getParent->getId.'@'.$domain;
    }
    my $subject = $cs->mailPrefix.$self->title;
    
    foreach my $subscriptionAsset ($cs, $thread) {
        $var->{unsubscribeUrl} = $siteurl.$subscriptionAsset->getUnsubscribeUrl;
        $var->{unsubscribeLinkText} = $i18n->get("unsubscribe","Asset_Collaboration");
        my $message = $self->processTemplate($var, $cs->notificationTemplateId);
        WebGUI::Macro::process($self->session, \$message);
        my $groupId = $subscriptionAsset->subscriptionGroupId;
        my $mail = WebGUI::Mail::Send->create($self->session, {
			from=>"<".$from.">",
			returnPath => "<".$returnPath.">",
			replyTo=>"<".$replyTo.">",
			toGroup=>$groupId,
			subject=>$subject,
			messageId=>'<'.$messageId.'>'
			});
        if ($self->isReply) {
            $mail->addHeaderField("In-Reply-To", "<".$replyId.">");
            $mail->addHeaderField("References", "<".$replyId.">");
        }
        $mail->addHeaderField("List-ID", $cs->getTitle." <".$listId.">");
        $mail->addHeaderField("List-Help", "<mailto:".$companyAddress.">, <".$setting->get("companyURL").">");
        $mail->addHeaderField("List-Unsubscribe", "<".$siteurl.$subscriptionAsset->getUnsubscribeUrl.">");
        $mail->addHeaderField("List-Subscribe", "<".$siteurl.$subscriptionAsset->getSubscribeUrl.">");
        $mail->addHeaderField("List-Owner", "<mailto:".$companyAddress.">, <".$setting->get("companyURL")."> (".$setting->get("companyName").")");
        $mail->addHeaderField("Sender", "<".$sender.">");
        if ($listAddress eq "") {
            $mail->addHeaderField("List-Post", "No");
        } else {
            $mail->addHeaderField("List-Post", "<mailto:".$listAddress.">");
        }
        $mail->addHeaderField("List-Archive", "<".$siteurl.$cs->getUrl.">");
        $mail->addHeaderField("X-Unsubscribe-Web", "<".$siteurl.$subscriptionAsset->getUnsubscribeUrl.">");
        $mail->addHeaderField("X-Subscribe-Web", "<".$siteurl.$subscriptionAsset->getSubscribeUrl.">");
        $mail->addHeaderField("X-Archives", "<".$siteurl.$cs->getUrl.">");
        $mail->addHtml($message);
        $mail->addFooter;
        $mail->queue;
    }
}

#-------------------------------------------------------------------

=head2 paste 

Extends the master method to handle incrementing replies.

=cut

sub paste {
    my $self = shift;

    $self->SUPER::paste(@_);

    # First, figure out what Thread we're under
    my $thread = $self->getLineage( [ qw{ self ancestors } ], {
        returnObjects   => 1,
        isa             => 'WebGUI::Asset::Post::Thread',
    } )->[0];

    # If the pasted asset is not a thread we'll have to update the threadId of it and all posts below it.
    if ( $self->threadId ne $self->getId ) {
        # Check if we're actually pasting under a thread.
        if ($thread) {
            # If so, get the threadId from the thread and fetch all posts that must be updated.
            my $threadId   = $thread->getId;
            my $childPosts = $self->getLineage( [ qw{ self descendants } ], {
                returnObjects   => 1,
                isa             => 'WebGUI::Asset::Post',
            } );

            # Finally update all these Posts
            foreach my $asset ( @{ $childPosts } ) {
                $asset->update( { threadId => $threadId } );
            }
        }
        else {
            # We're putting Posts in a place they don't belong, so issue a warning.
            $self->session->log->warn('Posts pasted under an asset that is not a Thread');
        }
    }

    # Recount the replies under the thread.
    $thread->sumReplies;
}

#-------------------------------------------------------------------

=head2 processPropertiesFromFormPost 

Extend the base method to handle archiving and unarchiving, making sticky and
non-sticky, locking and unlocking posts.  Calls postProcess when it is done.

=cut

sub processPropertiesFromFormPost {
	my $self = shift;
	$self->SUPER::processPropertiesFromFormPost;	
    my $session = $self->session;
    my $form    = $session->form;
	my $i18n = WebGUI::International->new($session);
	if ($form->process("assetId") eq "new") {
		my %data = (
			ownerUserId => $session->user->userId,
			username => $form->process("visitorName") || $session->user->profileField("alias") || $session->user->username,
			);
		$self->update(\%data);
	}
    # force the value to be empty so it gets updated properly by content
    $self->update({synopsis => ($form->process("synopsis") || "")});
	if ($form->process("archive") && $self->getThread->getParent->canModerate) {
		$self->getThread->archive;
	} elsif ($self->getThread->status eq "archived") {
		$self->getThread->unarchive;
	}
    if ($form->process("subscribe")) {
        $self->getThread->subscribe;
    }
    else {
        $self->getThread->unsubscribe;
    }
    if ($self->getThread->getParent->canEdit) {
        $form->process('isLocked') ?  $self->getThread->lock  : $self->getThread->unlock;
        $form->process('isSticky') ?  $self->getThread->stick : $self->getThread->unstick;
    }
	delete $self->{_storageLocation};
	$self->postProcess;
}


#-------------------------------------------------------------------

=head2 postProcess 

Catchall method for spam processing, adjusting thumbnail sizes, setting the synopsis,
adding edit stamp to posts and setting the size.

=cut

sub postProcess {
	my $self = shift;
	my %data = ();
	($data{synopsis}, $data{content}) = $self->getSynopsisAndContent($self->synopsis, $self->content);
    my $spamStopWords = $self->session->config->get('spamStopWords');
    if (ref $spamStopWords eq 'ARRAY') {
        my $spamRegex = join('|',@{$spamStopWords});
        $spamRegex =~ s/\s/\\ /g;
        if ($data{content} =~ m/$spamRegex/xmsi) {
            $data{skipNotification} = 1;
            $self->trash;
        }
    }
	my $user = WebGUI::User->new($self->session, $self->ownerUserId);
	my $i18n = WebGUI::International->new($self->session, "Asset_Post");
	if ($self->getThread->getParent->addEditStampToPosts) {
		$data{content} .= "<p>\n\n --- (".$i18n->get('Edited_on')." ".$self->session->datetime->epochToHuman(undef,"%z %Z [GMT%O]")." ".$i18n->get('By')." ".$user->profileField("alias").") --- \n</p>";
	}
	$data{url} = $self->fixUrl($self->getThread->url."/1") if ($self->isReply && $self->isNew);
	$data{groupIdView} = $self->getThread->getParent->groupIdView;
	$data{groupIdEdit} = $self->getThread->getParent->groupIdEdit;
	$self->update(\%data);
	my $size = 0;
	my $storage = $self->getStorageLocation;
	foreach my $file (@{$storage->getFiles}) {
		if ($storage->isImage($file)) {
            $storage->adjustMaxImageSize($file, $self->getThread->getParent->maxImageSize);
			$storage->generateThumbnail($file, $self->getThread->getParent->thumbnailSize);
		}
		$size += $storage->getFileSize($file);
	}
	$self->setSize($size);
}

#-------------------------------------------------------------------

#sub publish {
#	my $self = shift;
#	$self->SUPER::publish(@_);
#
#	$self->getThread->sumReplies;
#}

#-------------------------------------------------------------------

=head2 purge 

Extend the base method to handle cleaning up storage locations.

=cut

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

=head2 purgeCache ( )

Extend the base class to handle caching.

=cut

sub purgeCache {
	my $self = shift;
	eval{$self->session->cache->delete("view_".$self->getThread->getId)} if ($self->getThread);
	$self->SUPER::purgeCache;
}

#-------------------------------------------------------------------

=head2 purgeRevision 

Extend the base method to handle deleting the storage location.

=cut

sub purgeRevision {
    my $self = shift;
    $self->getStorageLocation->delete;
    return $self->SUPER::purgeRevision;
}



#-------------------------------------------------------------------

=head2 rate ( rating )

Stores a rating against this post.

=head3 rating

An integer indicating either thumbss up (+1) or thumbs down (-1)

=cut

sub rate {
	my $self = shift;
	my $rating = shift;
	return undef unless ($rating == -1 || $rating == 1);
	return undef if $self->hasRated;
	$self->insertUserPostRating($rating);
	$self->recalculatePostRating();
    my $thread = $self->getThread;
	$thread->updateThreadRating();
	if ($self->session->setting->get("useKarma")
        && $self->session->user->karma > $thread->getParent->karmaSpentToRate) {
		$self->session->user->karma(-$self->getThread->getParent->karmaSpentToRate, "Rated Post ".$self->getId, "Rated a CS Post.");
		my $u = WebGUI::User->new($self->session, $self->ownerUserId);
		$u->karma($self->getThread->getParent->karmaRatingMultiplier, "Post ".$self->getId." Rated by ".$self->session->user->userId, "Had post rated.");
	}
}

#-------------------------------------------------------------------

=head2 recalculatePostRating ( )

Sum all the entries for this post from the ratings table and update its composite rating.

=cut

sub recalculatePostRating {
	my $self = shift;
	my ($sum) = $self->session->db->quickArray("select sum(rating) from Post_rating where assetId=?", [$self->getId]);
	$self->update({rating=>$sum});
}

#-------------------------------------------------------------------

=head2 restore

Extend the base class to also make the thread containing this post to recalculate its replies and
the thread rating.

=cut

sub restore {
    my $self = shift;
    $self->SUPER::restore(@_);
    $self->getThread->sumReplies;
    $self->getThread->updateThreadRating;
}


#-------------------------------------------------------------------

=head2 rethreadUnder ($thread)

Update the Post's threadId property with a new thread.

=head3 $thread

The new thread.

=cut

sub rethreadUnder {
	my $self = shift;
	my $thread = shift;
	$self->update({threadId => $thread->getId});
	delete $self->{_thread};
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
    return 0 unless ($newParent->isa('WebGUI::Asset::Post'));
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
        $self->update({status=>'approved'}) if ($self->status eq "archived");
}

#-------------------------------------------------------------------

=head2 trash ( )

Moves post to the trash, updates reply counter on thread and recalculates the thread rating.

=cut

sub trash {
    my $self = shift;
    $self->SUPER::trash;
    $self->getThread->sumReplies if ($self->isReply);
    $self->getThread->updateThreadRating;
    if ($self->getThread->lastPostId eq $self->getId) {
        my $threadLineage = $self->getThread->lineage;
        my ($id, $date) = $self->session->db->quickArray("select assetId, creationDate from asset where 
            lineage like ? and assetId<>? and asset.state='published' and className like 'WebGUI::Asset::Post%' 
            order by creationDate desc",[$threadLineage.'%', $self->getId]);
        $self->getThread->update({lastPostId=>$id, lastPostDate=>$date});
    }
    if ($self->getThread->getParent->lastPostId eq $self->getId) {
        my $forumLineage = $self->getThread->getParent->lineage;
        my ($id, $date) = $self->session->db->quickArray("select assetId, creationDate from asset where 
            lineage like ? and assetId<>? and asset.state='published' and className like 'WebGUI::Asset::Post%' 
            order by creationDate desc",[$forumLineage.'%', $self->getId]);
        $self->getThread->getParent->update({lastPostId=>$id, lastPostDate=>$date});
    }
}

#-------------------------------------------------------------------

=head2 prepareView 

Extend the base method to also prepare the Thread containing this Post.

=cut

sub prepareView {
	my $self = shift;
	$self->SUPER::prepareView;
	unless ($self->getThread->getId eq $self->getId) {
		# Need the unless to avoid infinite recursion.
		$self->getThread->prepareView;
	}
}

#-------------------------------------------------------------------

=head2 valid_parent_classes

Make sure that the current session asset is a Thread or Post for pasting and adding checks.

Technically, we really only need WebGUI::Asset::Post, but it drives some testing code crazy
so we explicitly list Thread, too.

=cut

sub valid_parent_classes {
    my $class   = shift;
    my $session = shift;
    return [qw/WebGUI::Asset::Post::Thread WebGUI::Asset::Post/];
}

#-------------------------------------------------------------------

=head2 view 

Increment the number of views for this Post, and then display the Thread containing
this Post.

=cut

sub view {
	my $self = shift;
	$self->incrementViews;
	return $self->getThread->view($self);
}


#-------------------------------------------------------------------

=head2 www_deleteFile 

Deletes the file given by the form variable C<filename> from this asset's storage location.

=cut

sub www_deleteFile {
	my $self = shift;
	$self->getStorageLocation->deleteFile($self->session->form->process("filename")) if $self->canEdit;
	return $self->www_edit;
}


#-------------------------------------------------------------------

=head2 www_edit 

Renders a template form for adding and editing posts.

=cut

sub www_edit {
	my $self      = shift;
    my $session   = $self->session;
    my $form      = $session->form;
    my $privilege = $session->privilege;
    my $user      = $session->user;
    my $func      = $form->process("func");
    
	my (%var, $content, $title, $synopsis);
	my $i18n = WebGUI::International->new($session);


    my $className = $form->process("class","className") || $self->className;
	if ($func eq "add" || ($func eq "editSave" && $form->process("assetId") eq "new")) { # new post
        #Post to the parent if this is a new request
        my $action    = $self->getParent->getUrl;
        #Post to self if there was an error Posting to a Thread (not a Collaboration)
        $action       = $self->getUrl if($func eq "editSave" && $className ne "WebGUI::Asset::Post::Thread");
        
        #Add Form Header for all new posts
        $var{'form.header'} = WebGUI::Form::formHeader($session,{
            action=>$action
        });
        $var{'form.header'} .= WebGUI::Form::hidden($session, {
            name=>"func",
            value=>"add"
		});
        $var{'form.header'} .= WebGUI::Form::hidden($session, {
            name=>"assetId",
            value=>"new"
		});
		$var{'form.header'} .= WebGUI::Form::hidden($session, {
            name=>"class",
            value=>$form->process("class","className")
        });
        
        if($self->getThread->getParent->useCaptcha) {
            $var{'useCaptcha'   } = "true";
            
            use WebGUI::Form::Captcha;
            my $captcha = WebGUI::Form::Captcha->new($self->session,{
                "name"=>"captcha"
            });
            $var{'captcha_form' } 
                = $captcha->toHtml. '<span class="formSubtext">'.$captcha->get('subtext').'</span>';
   		}
        
        $var{'isNewPost'  } = 1;
		
        $content            = $form->process("content");
		$title              = $form->process("title");
		$synopsis           = $form->process("synopsis");
        
        if ($className eq "WebGUI::Asset::Post") { # new reply
            #If editSave comes back on a reply to a new thread, you wind up with a post who's parent is a collaboration system.
            my $parent = $self->getParent;
            if(ref $self->getParent eq "WebGUI::Asset::Wobject::Collaboration") {
                $self->{_thread} = $self->getThread;
                $parent = $self;
            } else {
			    $self->{_thread} = $self->getParent->getThread;
            }
            
            return $privilege->insufficient() unless ($self->getThread->canReply);
			
            $var{'isReply'       } = 1;
			$var{'reply.title'   } = $title || $parent->title;
			$var{'reply.synopsis'} = $synopsis || $parent->synopsis;
			$var{'reply.content' } = $content || $parent->formatContent;
			for my $i (1..5) {	
				$var{'reply.userDefined'.$i} = WebGUI::HTML::filter($parent->get('userDefined'.$i),"macros");
			}
			unless ($content || $title) {
                $content = "[quote]".$parent->content."[/quote]" if ($form->process("withQuote"));
                $title = $parent->title;
                $title = "Re: ".$title unless ($title =~ /^Re:/i);
			}
			my $subscribe = $form->process("subscribe");
            $var{'subscribe.form'} = WebGUI::Form::yesNo($session, {
				name=>"subscribe",
				value => defined $subscribe ? $subscribe : $self->getThread->isSubscribed,
            });
		}
        elsif ($className eq "WebGUI::Asset::Post::Thread") { # new thread
			return $privilege->insufficient() unless ($self->getThread->getParent->canPost);
			$var{'isThread'    } = 1;
			$var{'isNewThread' } = 1;
            my $subscribe = $form->process("subscribe");
			$var{'subscribe.form'} = WebGUI::Form::yesNo($session, {
				name=>"subscribe",
				value => defined $subscribe ? $subscribe : 1,
            });
		}
        $content .= "\n\n".$user->profileField("signature") if ($user->profileField("signature") && !$form->process("content"));
	}
    else { # edit
		return $privilege->insufficient() unless ($self->canEdit);
		$var{'isThread'   } = !$self->isReply;
        $var{'form.header'} = WebGUI::Form::formHeader($session,{
            action=>$self->getUrl
        });
        $var{'form.header'} .= WebGUI::Form::hidden($session, {
            name=>"func",
            value=>"edit"
        });
        $var{'form.header'} .= WebGUI::Form::hidden($session, {
            name=>"revision",
            value=>$form->param("revision")
        });
	    $var{'form.header'} .= WebGUI::Form::hidden($session, {
            name=>"ownerUserId",
            value=>$self->ownerUserId
        });
        $var{'form.header'} .= WebGUI::Form::hidden($session, {
            name=>"username",
            value=>$self->username
        });
		$var{isEdit} = 1;
		$content     = $form->process('content')  || $self->content;
		$title       = $form->process('title')    || $self->title;
		$synopsis    = $form->process('synopsis') || $self->synopsis;
	}
    
    $var{'archive.form'} = WebGUI::Form::yesNo($session, {
        name=>"archive"
    });
	$var{'form.header'} .= WebGUI::Form::hidden($session, {
        name=>"proceed", 
        value=>"showConfirmation"
    });
	
    if ($form->process("title") || $form->process("content") || $form->process("synopsis")) {
		$var{'preview.title'} = WebGUI::HTML::filter($form->process("title"),"all");
		($var{'preview.synopsis'}, $var{'preview.content'}) = $self->getSynopsisAndContent($form->process("synopsis","textarea"), $form->process("content","HTMLArea"));
		$var{'preview.content'} = $self->formatContent($var{'preview.content'},$form->process("contentType"));
		for my $i (1..5) {	
			$var{'preview.userDefined'.$i} = WebGUI::HTML::filter($form->process('userDefined'.$i),"macros");
		}
	}
	$var{'form.footer'     } = WebGUI::Form::formFooter($session);
	$var{'usePreview'      } = $self->getThread->getParent->usePreview;
	$var{'user.isModerator'} = $self->getThread->getParent->canModerate;
	$var{'user.isVisitor'  } = ($user->isVisitor);
	$var{'visitorName.form'} = WebGUI::Form::text($session, {
		name => "visitorName",
		value => $form->process('visitorName') || $self->visitorName
    });
    
	for my $x (1..5) {
		my $userDefinedValue 
            = $form->process("userDefined".$x) 
            || $self->get("userDefined".$x)
            ;
		$var{'userDefined'.$x}  = $userDefinedValue;
        $var{'userDefined'.$x.'.form'} 
            = WebGUI::Form::text($session, {
			    name    => "userDefined".$x,
			    value   => $userDefinedValue,
			});
		$var{'userDefined'.$x.'.form.yesNo'} 
            = WebGUI::Form::yesNo($session, {
			    name    => "userDefined".$x,
			    value   => $userDefinedValue,
			});
		$var{'userDefined'.$x.'.form.textarea'} 
            = WebGUI::Form::textarea($session, {
			    name    => "userDefined".$x,
			    value   => $userDefinedValue,
			});
		$var{'userDefined'.$x.'.form.htmlarea'} 
            = WebGUI::Form::HTMLArea($session, {
			    name    => "userDefined".$x,
			    value   => $userDefinedValue,
			});
		$var{'userDefined'.$x.'.form.float'} 
            = WebGUI::Form::Float($session, {
			    name    => "userDefined".$x,
			    value   => $userDefinedValue,
			});
	}

	$title    = WebGUI::HTML::filter($title,"all");
	$content  = WebGUI::HTML::filter($content,"macros");
	$synopsis = WebGUI::HTML::filter($synopsis,"all");

	$var{'title.form'         } = WebGUI::Form::text($session, {
        name=>"title",
        value=>$title
    });
	$var{'title.form.textarea'} = WebGUI::Form::textarea($session, {
        name=>"title",
        value=>$title
    });
	$var{'synopsis.form'} = WebGUI::Form::textarea($session, {
        name=>"synopsis",
        value=>$synopsis,
    });
	$var{'content.form'} = WebGUI::Form::HTMLArea($session, {
        name=>"content",
        value=>$content,
        richEditId=>($self->isa("WebGUI::Asset::Post::Thread") ? 
	  $self->getThread->getParent->richEditor :
 	  $self->getThread->getParent->replyRichEditor),
    });
    ##Edit variables just for Threads
    if ($className eq 'WebGUI::Asset::Post::Thread' && $self->getThread->getParent->canEdit) {
        $var{'sticky.form'} = WebGUI::Form::yesNo($session, {
            name=>'isSticky',
            value=>$form->process('isSticky') || $self->isSticky,
        });
        $var{'lock.form'  } = WebGUI::Form::yesNo($session, {
            name=>'isLocked',
            value=>$form->process('isLocked') || $self->isLocked,
        });
    }
	$var{'form.submit'} = WebGUI::Form::submit($session, {
        extras=>"onclick=\"this.value='".$i18n->get(452)."'; this.form.func.value='editSave';return true;\""
	});
	$var{'karmaScale.form'} = WebGUI::Form::integer($session, {
        name=>"karmaScale",
        defaultValue=>$self->getThread->getParent->defaultKarmaScale,
        value=>$self->karmaScale,
    });
	$var{karmaIsEnabled} = $session->setting->useKarma;
	$var{'form.preview'} = WebGUI::Form::submit($session, {
        value=>$i18n->get("preview","Asset_Collaboration")
    });
	my $numberOfAttachments = $self->getThread->getParent->attachmentsPerPost;
	$var{'attachment.form'} = WebGUI::Form::image($session, {
        name=>"storageId",
        value=>$self->storageId,
        maxAttachments=>$numberOfAttachments,
        ##Removed deleteFileUrl, since it will go around the revision control system.
    }) if ($numberOfAttachments);
    
    $var{'contentType.form'} = WebGUI::Form::contentType($session, {
        name=>'contentType',
        value=>$self->contentType || "mixed",
    });
    if ($session->setting->get("metaDataEnabled")
     && $self->getThread->getParent->enablePostMetaData) {
        my $meta = $self->getMetaDataFields();
        my $formGen = $form;
        my @meta_loop = ();
        foreach my $field (keys %{ $meta }) {
            my $fieldType = $meta->{$field}{fieldType} || "Text";
            my $options = $meta->{$field}{possibleValues};
            # Add a "Select..." option on top of a select list to prevent from
            # saving the value on top of the list when no choice is made.
            if("\l$fieldType" eq "selectBox") {
                $options = "|" . $i18n->get("select") . "\n" . $options;
            }
            my $form = WebGUI::Form::DynamicField->new($session,
                name      => "metadata_".$meta->{$field}{fieldId},
                uiLevel   => 5,
                value     => $meta->{$field}{value},
                extras    => qq/title="$meta->{$field}{description}"/,
                options   => $options,
                fieldType => $fieldType,
            )->toHtml;
            push @meta_loop, {
                field => $form,
                name  => $meta->{$field}{fieldName},
            };
            my $fieldName = $meta->{$field}{fieldName};
            $fieldName =~ tr/ /_/;
            $fieldName = lc $fieldName;
            $var{'meta_'.$fieldName.'_form'} = $form;  ##By name interface
        }
        $var{meta_loop} = \@meta_loop;
    }
	#keywords field
    $var{'keywords.form'} = WebGUI::Form::text($session,{
	    name        => 'keywords',
        value       => $self->keywords,
    });

	$self->getThread->getParent->appendTemplateLabels(\%var);
	return $self->getThread->getParent->processStyle($self->processTemplate(\%var,$self->getThread->getParent->postFormTemplateId));
}


#-------------------------------------------------------------------

=head2 www_editSave ( )

We're extending www_editSave() here to deal with editing a post that has been denied by the approval process.  Our change will reassign the old working tag of this post to the user so that they can edit it.

=cut

sub www_editSave {
    my $self = shift;
    my $assetId = $self->session->form->param("assetId");
    if($assetId eq "new" && $self->getThread->getParent->useCaptcha) {
        my $captcha = $self->session->form->process("captcha","Captcha");
        unless ($captcha) {
            return $self->www_edit;
        }
    }
    my $currentTag;
    if ($assetId ne "new" && $self->status eq "pending") {
        # When editting posts pending approval, temporarily switch to their version tag so
        # we don't get denied because it is locked
        $currentTag = WebGUI::VersionTag->getWorking($self->session, 1);
        my $tag = WebGUI::VersionTag->new($self->session, $self->tagId);
        if ($tag) {
            if ($tag->getId eq $currentTag->getId) {
                undef $currentTag;  # don't restore tag afterward if we are already using it
            }
            else {
                $tag->setWorking;
            }
        }
    }
    my $output = $self->SUPER::www_editSave();
    if ($currentTag) { # Go back to our original tag
        $currentTag->setWorking;
    }
    return $output;
}

#-------------------------------------------------------------------

=head2 www_rate ( )

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
	my $url = undef;
	if ($self->isReply) {
		$url = $self->getThread->getUrl;
	} else {
		$url = $self->getThread->getParent->getUrl;
	}
    my $parent = $self->getThread;
    my $collabSystem;
    if($parent->isa('WebGUI::Asset::Wobject::Collaboration')) {
        $collabSystem = $parent;
    }
    else {
        $collabSystem = $parent->getParent;
    }
    my $templateId = $collabSystem->postReceivedTemplateId;
    my $template = WebGUI::Asset->newById($self->session, $templateId);
    my %var = (
        url     => $url,
    );
    return $self->getThread->getParent->processStyle($template->process(\%var));
}



#-------------------------------------------------------------------

=head2 www_view 

Increment the views on this Post, then display the Thread containing this Post.

=cut

sub www_view {
	my $self = shift;
	$self->incrementViews;
	return $self->getThread->www_view($self);
}


1;

