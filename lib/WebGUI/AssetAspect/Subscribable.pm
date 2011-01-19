package WebGUI::AssetAspect::Subscribable;

use strict;
use Class::C3;
use WebGUI::Mail::Send;
use WebGUI::International;

=head1 NAME

WebGUI::AssetAspect::Subscribable - Let users subscribe to your asset

=head1 SYNOPSIS


=head1 DESCRIPTION


=head1 METHODS

#----------------------------------------------------------------------------

=head2 definition ( session [, definition ] )

=cut

sub definition {
    my $class       = shift;
    my $session     = shift;
    my $definition  = shift;
    my $i18n        = WebGUI::International->new($session, 'AssetAspect_Subscribable');

    tie my %properties, 'Tie::IxHash', (
        subscriptionGroupId => {
            tab             => "security",
            fieldType       => "subscriptionGroup",
            label           => $i18n->get("Subscription Group"),
            hoverHelp       => $i18n->get("Subscription Group help"),
            defaultValue    => undef,
            noFormPost      => 1,
        },
        subscriptionTemplateId => {
            tab             => "display",
            fieldType       => "template",
            namespace       => $class->getSubscriptionTemplateNamespace,
            label           => $i18n->get("Email Template"),
            hoverHelp       => $i18n->get("Email Template help"),
            defaultValue    => 'limMkk80fMB3fqNZVf162w',
        },
    );

    push @{ $definition }, {
        autoGenerateForms       => 1,
        tableName               => "assetAspect_Subscribable",
        properties              => \%properties,
    };

    return $class->maybe::next::method( $session, $definition ); 
}

#----------------------------------------------------------------------------

=head2 duplicate ( [ options ] )

Subclass the method to create a new group for subscribers for the new asset.

=cut

sub duplicate {
    my $self        = shift;
    my $properties  = shift;
    my $newSelf     = $self->next::method( $properties );
    $newSelf->update({ subscriptionGroupId => '' });
    $newSelf->createSubscriptionGroup;
    return $newSelf;
}

#----------------------------------------------------------------------------

=head2 addRevision ( properties [, revisionDate, options ] )

Override addRevision to set skipNotification to 0 for each new revision.  This preserves whether or
not a notification was sent for the previous revision.

=cut

sub addRevision {
    my $self        = shift;
    my $properties  = shift || {};
    
    $properties->{ skipNotification     } = 0;

    return $self->maybe::next::method( $properties, @_ );
}

#----------------------------------------------------------------------------

=head2 canSubscribe ( [userId ] )

Returns true if the user is allowed to subscribe to this asset. C<userId> is
a userId to check, defaults to the current user.

By default, Visitors are not allowed to subscribe. Anyone else who canView,
canSubscribe.

=cut

sub canSubscribe {
    my $self    = shift;
    my $userId  = shift || $self->session->user->userId;

    return 0 if $userId eq "1";
    return $self->canView( $userId );
}

#----------------------------------------------------------------------------

=head2 commit ( ) 

By default, send the notification out when the asset is committed. Override
this if you don't want this asset to send out notifications (but you still
want to be able to subscribe to children)

=cut

sub commit { 
    my ( $self, @args ) = @_;
    $self->maybe::next::method( @args );
    if ( !$self->shouldSkipNotification ) {
        $self->notifySubscribers;
    }
    return;
}

#----------------------------------------------------------------------------

=head2 createSubscriptionGroup ( )

Create a group to hold subscribers to this asset, if there is not one already.

=cut

sub createSubscriptionGroup {
    my $self    = shift;

    if ( my $groupId = $self->get('subscriptionGroupId') ) {
        return WebGUI::Group->new( $self->session, $groupId );
    }
    else {
        my $group   = WebGUI::Group->new($self->session, "new");
        $group->name( "Subscription " . $self->getTitle );
        $group->description( "Subscription Group for " . $self->getTitle . "(" . $self->getId . ")" );
        $group->isEditable( 0 );
        $group->showInForms( 0 );
        $group->deleteGroups( [ "3" ] ); # admins don't want to be auto subscribed to this thing
        $self->update({
            subscriptionGroupId => $group->getId
        });

        return $group;
    }
}

#----------------------------------------------------------------------------

=head2 DOES ( role )

Returns true if the asset does the specified role. This mixin does the 
"Subscribable" role.

=cut

sub DOES {
    my $self    = shift;
    my $role    = shift;
    
    return 1 if ( lc $role eq "subscribable" );
    return $self->maybe::next::method( $role );
}

#----------------------------------------------------------------------------

=head2 getSubscriptionContent ( )

Get the content to send to subscribers. By default, will process the template
from C<getSubscriptionTemplate> with the variables from C<getTemplateVars> or
C<get>.

=cut

sub getSubscriptionContent {
    my $self        = shift;
    my $template    = $self->getSubscriptionTemplate;
    my $var;
    if ( $self->can("getTemplateVars") ) {
        # Rely on getTemplateVars sub judgement
        $var = $self->getTemplateVars;
    }
    else {
        # Try to make sense of the asset properties
        $var = { 
            %{ $self->get }, 
            url => $self->session->url->getSiteURL . $self->getUrl, 
        }
    }

    return $template->process( $var );
}

#----------------------------------------------------------------------------

=head2 getSubscriptionGroup ( )

Gets the WebGUI::Group for the subscribers group. 

=cut

sub getSubscriptionGroup {
    my $self        = shift;
    my $groupId     = $self->get( "subscriptionGroupId" );
    my $group       = $groupId ? WebGUI::Group->new( $self->session, $groupId ) : $self->createSubscriptionGroup;
    return $group;
}

#----------------------------------------------------------------------------

=head2 getSubscriptionTemplate ( )

Get a WebGUI::Asset::Template object for the subscription template.

=cut

sub getSubscriptionTemplate {
    my $self        = shift;
    my $templateId  = $self->get( "subscriptionTemplateId" );
    my $template    = WebGUI::Asset::Template->new( $self->session, $templateId ); # This should throw if we don't
    return $template;
}

#----------------------------------------------------------------------------

=head2 getSubscriptionTemplateNamespace ( )

Get the namespace for the subscription template.

=cut

sub getSubscriptionTemplateNamespace {
    return "AssetAspect/Subscribable";
}

#----------------------------------------------------------------------------

=head2 getSubscribeUrl ( )

Get the URL to subscribe to this asset.

=cut

sub getSubscribeUrl {
    my $self    = shift;
    return $self->getUrl( 'func=subscribe' );
}

#----------------------------------------------------------------------------

=head2 getUnsubscribeUrl ( )

Get the URL to unsubscribe from this asset.

=cut

sub getUnsubscribeUrl {
    my $self    = shift;
    return $self->getUrl( 'func=unsubscribe' );
}

#----------------------------------------------------------------------------

=head2 isSubscribed ( [userId] )

Returns true if the user is subscribed to the asset. C<userId> is a userId to
check, defaults to the current user.

=cut

sub isSubscribed {
    my $self        = shift;
    my $userId      = shift;
    my $user        = $userId 
                    ? WebGUI::User->new( $self->session, $userId ) 
                    : $self->session->user
                    ;
    my $group       = $self->getSubscriptionGroup;
    # TODO: Make WebGUI::Group throw error if group not found
    if ( !$group ) {
        return 0;
    }
    else {
        return $user->isInGroup( $group->getId );
    }
}

#----------------------------------------------------------------------------

=head2 _makeMessageId ( string )

Make the message ID following proper RFC2822. C<string> is a unique identifier
for the message.

=cut

sub _makeMessageId {
    my $self        = shift;
    my $string      = shift;
    my $domain      = $self->session->config->get( "sitename" )->[ 0 ]; 
    return "wg-" . $string . "@" . $domain;
}

#----------------------------------------------------------------------------

=head2 notifySubscribers ( [options] )

Notify all the subscribers of this asset. C<options> is a hash reference of 
options with the following keys:

 content        -> Content to send to the subscribers. Defaults to getSubscriptionContent
 subject        -> E-mail subject. Defaults to the asset title.
 from           -> E-mail address this message is from. Defaults to the e-mail address of
                   the owner of this asset, or the Company E-Mail from settings
 replyTo        -> E-mail address to reply to. Defaults to the listAddress, the Mail
                   Return Path from settings, or the Company E-Mail from settings
 inReplyTo      -> Asset ID of the asset this subscription message is replying to
 listAddress    -> The address of the mailing list this is being sent from, if necessary

=cut

sub notifySubscribers {
    my $self            = shift;
    my $opt             = shift;
    my $session         = $self->session;
    my $setting         = $self->session->setting;
    my $companyEmail    = $setting->get( "companyEmail" );
    my $mailReturnPath  = $setting->get( "mailReturnPath" );

    $opt->{ subject         } ||= $self->getTitle;
    $opt->{ content         } ||= $self->getSubscriptionContent;
    WebGUI::Macro::process( $self->session, \$opt->{content} );
    
    if ( !$opt->{ from } ) {
        my $owner   = WebGUI::User->new( $self->session, $self->get( "ownerUserId" ) );
        $opt->{ from } = $owner->profileField( "email" ) || $opt->{ listAddress } || $companyEmail;
    }
    
    if ( !$opt->{ replyTo } ) {
        $opt->{ replyTo } = $opt->{listAddress} || $mailReturnPath || $companyEmail;        
    }
    
    $opt->{ returnPath    } = $mailReturnPath || $opt->{listAddress} || $companyEmail || $opt->{ from };

    my $messageId       = $self->_makeMessageId( $self->getId );

    ### Get all the people we need to send to
    # Any parent asset that does subscribable
    # First asset in this list is the topmost parent, and is the list ID
    my @assets          = ( $self );
    my $parentAsset     = $self->getParent;
    while ( $parentAsset ) {
        last if !$parentAsset->DOES( "subscribable" );
        unshift @assets, $parentAsset;
        $parentAsset    = $parentAsset->getParent;
    }
    
    ### Prepare the actual sender address (the address of the process sending, 
    # not the address of the user who initiated the sending)
    my $sender      = $opt->{listAddress} || $companyEmail || $opt->{from};
    my $siteurl     = $session->url->getSiteURL;
    # XXX This doesnt seem right...
    my $listId      = $sender;
    $listId =~ s/\@/\./;

    for my $asset ( @assets ) {
        my $group  = $asset->getSubscriptionGroup;
        my $mail    
            = WebGUI::Mail::Send->create( $self->session, {
                from        => '<' . $opt->{ from } . '>',
                returnPath  => '<' . $opt->{ returnPath } . '>',
                replyTo     => '<' . $opt->{ replyTo } . '>',
                toGroup     => $group->getId,
                subject     => $opt->{ subject },
                messageId   => '<' . $messageId . '>',
            } );
        
        # Add threading headers
        if ( $opt->{ inReplyTo } ) {
            $mail->addHeaderField( "In-Reply-To", '<' . $opt->{inReplyTo} . '>' );
            $mail->addHeaderField( "References", '<' . $opt->{inReplyTo} . '>' );
        }
        
        $mail->addHeaderField("List-ID", $assets[0]->getTitle." <".$listId.">");
        $mail->addHeaderField("List-Help", "<mailto:".$companyEmail.">, <".$setting->get("companyURL").">");
        $mail->addHeaderField("List-Owner", "<mailto:".$companyEmail.">, <".$setting->get("companyURL")."> (".$setting->get("companyName").")");
        $mail->addHeaderField("Sender", "<".$sender.">");
        $mail->addHeaderField("List-Unsubscribe", "<".$siteurl.$asset->getUnsubscribeUrl.">");
        $mail->addHeaderField("X-Unsubscribe-Web", "<".$siteurl.$asset->getUnsubscribeUrl.">");
        $mail->addHeaderField("List-Subscribe", "<".$siteurl.$asset->getSubscribeUrl.">");
        $mail->addHeaderField("X-Subscribe-Web", "<".$siteurl.$asset->getSubscribeUrl.">");
        $mail->addHeaderField("List-Archive", "<".$siteurl.$assets[0]->getUrl.">");
        $mail->addHeaderField("X-Archives", "<".$siteurl.$assets[0]->getUrl.">");
        if ( $opt->{listAddress} ) {
            $mail->addHeaderField("List-Post", "<mailto:".$opt->{listAddress}.">");
        } 
        else {
            $mail->addHeaderField("List-Post", "No");
        }
        $mail->addHtml($opt->{content});
        $mail->addFooter;
        $mail->queue;
    }
}

#----------------------------------------------------------------------------

=head2 purge ( )

Subclass the method to remove the subscription group.

=cut

sub purge {
    my $self    = shift;
    my $options = shift;

    my $group   = $self->getSubscriptionGroup();
    $group->delete if $group;
    my $success = $self->next::method($options);

    return $success;
}

#----------------------------------------------------------------------------

=head2 shouldSkipNotification ( )

Returns true if the asset should skip notifications.

=cut

sub shouldSkipNotification {
    my $self    = shift;
    return $self->get( "skipNotification" ) ? 1 : 0;
}

#----------------------------------------------------------------------------

=head2 subscribe ( [userId] )

Subscribe a user to this asset. C<userId> is a userId to subscribe, defaults
to the current user.

=cut

sub subscribe {
    my $self    = shift;
    my $userId  = shift || $self->session->user->userId;
    $self->getSubscriptionGroup->addUsers( [$userId] );
    return;
}

#----------------------------------------------------------------------------

=head2 unsubscribe ( [userId] )

Unsubscribe a user from this asset. C<userId> is a userId to unsubscribe, 
defaults to the current user.

=cut

sub unsubscribe {
    my $self    = shift;
    my $userId  = shift || $self->session->user->userId;
    $self->getSubscriptionGroup->deleteUsers( [$userId] );
    return;
}

#----------------------------------------------------------------------------

=head2 www_subscribe ( )

Subscribe the current user to this asset.

=cut

sub www_subscribe {
	my $self = shift;
	$self->subscribe if $self->canSubscribe;
	return $self->www_view;
}

#----------------------------------------------------------------------------

=head2 www_unsubscribe ( )

Unsubscribe the current user from this asset. 

=cut

sub www_unsubscribe {
	my $self = shift;
	$self->unsubscribe;
	return $self->www_view;
}

1; # You can't handle the truth
