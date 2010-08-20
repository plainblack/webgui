package WebGUI::Account::Inbox;

use strict;

use WebGUI::Form;
use WebGUI::Exception;
use WebGUI::International;
use WebGUI::Pluggable;
use WebGUI::Utility;
use Tie::IxHash;
use Email::Valid;
use base qw/WebGUI::Account/;

=head1 NAME

Package WebGUI::Account::Inbox

=head1 DESCRIPTION

This is the class which is used to display a users's inbox

=head1 SYNOPSIS

 use WebGUI::Account::Inbox;

=head1 METHODS

These subroutines are available from this package:

=cut


#-------------------------------------------------------------------

=head2 appendCommonVars ( var, inbox )

Appends common template variables that all inbox templates use

=head3 var

The hash reference to append template variables to

=head3 inbox

The instance of the inbox currently being worked with.

=cut

sub appendCommonVars {
    my $self    = shift;
    my $session = $self->session;
    my $var     = shift;
    my $inbox   = shift || WebGUI::Inbox->new($session);
    my $user    = $self->getUser;
    my $method  = $self->method;

    $self->SUPER::appendCommonVars($var);

    $var->{'view_inbox_url'          } = $self->getUrl("module=inbox;do=view", 'useUid');
    $var->{'view_invitations_url'    } = $self->getUrl("module=inbox;do=manageInvitations");
    $var->{'unread_message_count'    } = $inbox->getUnreadMessageCount($user->userId);
    $var->{'invitation_count'        } = $self->getInvitationCount;
    $var->{'invitations_enabled'     } = $user->profileField('ableToBeFriend');
    $var->{'user_invitations_enabled'} = $session->setting->get("inboxInviteUserEnabled");
    $var->{'invite_friend_url'       } = $self->getUrl("module=inbox;do=inviteUser");

    my $tab = $self->store->{tab};
    $var->{'is_tab_'.$tab} = "true";

}

#-------------------------------------------------------------------

=head2 canView ( )

Returns whether or not the user can view the inbox tab

=cut

sub canView {
    my $self    = shift;
    my $session = $self->session;
    return $self->uid eq ""
        || $self->uid ne "" && $session->user->isInGroup($session->setting->get('groupIdAdminUser'));
}

#-------------------------------------------------------------------

=head2 editSettingsForm ( )

Creates form elements for user settings page custom to this account module

=cut

sub editSettingsForm {
    my $self    = shift;
    my $session = $self->session;
    my $setting = $session->setting;
    my $i18n    = WebGUI::International->new($session,'Account_Inbox');
    my $f       = WebGUI::HTMLForm->new($session);

    $f->template(
		name      => "inboxStyleTemplateId",
		value     => $self->getStyleTemplateId,
		namespace => "style",
		label     => $i18n->get("inbox style template label"),
        hoverHelp => $i18n->get("inbox style template hoverHelp")
	);
	$f->template(
		name      => "inboxLayoutTemplateId",
		value     => $self->getLayoutTemplateId,
		namespace => "Account/Layout",
		label     => $i18n->get("inbox layout template label"),
        hoverHelp => $i18n->get("inbox layout template hoverHelp")
	);
	$f->template(
        name      => "inboxViewTemplateId",
        value     => $self->getViewTemplateId,
        namespace => "Account/Inbox/View",
        label     => $i18n->get("inbox view template label"),
        hoverHelp => $i18n->get("inbox view template hoverHelp")
	);
    $f->template(
        name      => "inboxViewMessageTemplateId",
        value     => $self->getViewMessageTemplateId,
        namespace => "Account/Inbox/ViewMessage",
        label     => $i18n->get("inbox view message template label"),
        hoverHelp => $i18n->get("inbox view message template hoverHelp")
	);
    $f->template(
        name      => "inboxSendMessageTemplateId",
        value     => $self->getSendMessageTemplateId,
        namespace => "Account/Inbox/SendMessage",
        label     => $i18n->get("inbox send message template label"),
        hoverHelp => $i18n->get("inbox send message template hoverHelp")
	);
    $f->template(
        name      => "inboxMessageConfirmationTemplateId",
        value     => $self->getMessageConfirmTemplateId,
        namespace => "Account/Inbox/Confirm",
        label     => $i18n->get("inbox message confirm template label"),
        hoverHelp => $i18n->get("inbox message confirm template hoverHelp")
	);
    $f->template(
        name      => "inboxErrorTemplateId",
        value     => $self->getInboxErrorTemplateId,
        namespace => "Account/Inbox/Error",
        label     => $i18n->get("inbox error message template label"),
        hoverHelp => $i18n->get("inbox error message template hoverHelp")
	);
    $f->template(
        name      => "inboxManageInvitationsTemplateId",
        value     => $self->getManageInvitationsTemplateId,
        namespace => "Account/Inbox/ManageInvitations",
        label     => $i18n->get("inbox manage invitations template label"),
        hoverHelp => $i18n->get("inbox manage invitations template hoverHelp")
	);
    $f->template(
        name      => "inboxViewInvitationTemplateId",
        value     => $self->getViewInvitationTemplateId,
        namespace => "Account/Inbox/ViewInvitation",
        label     => $i18n->get("inbox view invitation template label"),
        hoverHelp => $i18n->get("inbox view invitation template hoverHelp")
	);
    $f->template(
        name      => "inboxInvitationConfirmTemplateId",
        value     => $self->getInvitationConfirmTemplateId,
        namespace => "Account/Inbox/Confirm",
        label     => $i18n->get("invitation confirm message template label"),
        hoverHelp => $i18n->get("invitation confirm message template hoverHelp")
	);
    $f->yesNo(
		name      => "inboxInviteUserEnabled",
		value     => $setting->get("inboxInviteUserEnabled"),
		label     => $i18n->get("invite user enabled template label"),
        hoverHelp => $i18n->get("invite user enabled template hoverHelp")
	);
    $f->yesNo(
		name      => "inboxInviteUserRestrictSubject",
		value     => $setting->get("inboxInviteUserRestrictSubject"),
		label     => $i18n->get("invite user restrict subject template label"),
        hoverHelp => $i18n->get("invite user restrict subject template hoverHelp")
	);
    $f->text(
		name      => "inboxInviteUserSubject",
		value     => $setting->get("inboxInviteUserSubject"),
		label     => $i18n->get("invite user subject template label"),
        hoverHelp => $i18n->get("invite user subject template hoverHelp")
	);
    $f->yesNo(
		name      => "inboxInviteUserRestrictMessage",
		value     => $setting->get("inboxInviteUserRestrictMessage"),
		label     => $i18n->get("invite user restrict message template label"),
        hoverHelp => $i18n->get("invite user restrict message template hoverHelp")
	);
    $f->textarea(
		name      => "inboxInviteUserMessage",
		value     => $setting->get("inboxInviteUserMessage"),
        height    => 300,
		label     => $i18n->get("invite user message label"),
        hoverHelp => $i18n->get("invite user message hoverHelp")
	);
    $f->template(
		name      => "inboxInviteUserMessageTemplateId",
		value     => $self->getInviteUserMessageTemplateId,
        namespace => "Account/Inbox/InviteUserMessage",
		label     => $i18n->get("invite user message template label"),
        hoverHelp => $i18n->get("invite user message template hoverHelp")
	);
    $f->template(
		name      => "inboxInviteUserTemplateId",
		value     => $self->getInviteUserTemplateId,
		namespace => "Account/Inbox/InviteUser",
		label     => $i18n->get("invite user template label"),
        hoverHelp => $i18n->get("invite user template hoverHelp")
	);
    $f->template(
		name      => "inboxInviteUserConfirmTemplateId",
		value     => $self->getInviteUserConfirmTemplateId,
		namespace => "Account/Inbox/InviteUserConfirm",
		label     => $i18n->get("invite user confirm template label"),
        hoverHelp => $i18n->get("invite user confirm template hoverHelp")
	);
    $f->selectRichEditor(
        name        => "inboxRichEditId",
        value       => $self->getRichEditorId,
        label       => $i18n->get("inbox rich editor label"),
        hoverHelp   => $i18n->get("inbox rich editor description"),
    );
    $f->yesNo(
        name      => "inboxCopySender",
        value     => $setting->get("inboxCopySender"),
        label     => $i18n->get("inbox copy sender label"),
        hoverHelp => $i18n->get("inbox copy sender hoverHelp")
    );
    $f->yesNo(
        name         => 'sendInboxNotificationsOnly',
        label        => $i18n->get('send inbox notifications only'),
        hoverHelp    => $i18n->get('send inbox notifications only help'),
        defaultValue => $setting->get('sendInboxNotificationsOnly'),
    );
    $f->yesNo(
        name         => 'sendRejectNotice',
        label        => $i18n->get('send reject notice'),
        hoverHelp    => $i18n->get('send reject notice help'),
        defaultValue => $setting->get('sendRejectNotice'),
    );
    $f->text(
        name         => 'inboxNotificationsSubject',
        label        => $i18n->get('inbox notifications subject'),
        hoverHelp    => $i18n->get('inbox notifications subject help'),
        defaultValue => $setting->get('inboxNotificationsSubject'),
    );
    $f->template(
        name         => 'inboxNotificationTemplateId',
        label        => $i18n->get('inbox notification template'),
        hoverHelp    => $i18n->get('inbox notification template help'),
        defaultValue => $self->getInboxNotificationTemplateId,
        namespace    => 'Account/Inbox/Notification',
    );
    $f->template(
        name         => 'inboxSmsNotificationTemplateId',
        label        => $i18n->get('inbox sms notification template'),
        hoverHelp    => $i18n->get('inbox sms notification template help'),
        defaultValue => $self->getInboxSmsNotificationTemplateId,
        namespace    => 'Account/Inbox/Notification',
    );

    return $f->printRowsOnly;
}

#-------------------------------------------------------------------

=head2 editSettingsFormSave ( )

Creates form elements for user settings page custom to this account module

=cut

sub editSettingsFormSave {
    my $self    = shift;
    my $session = $self->session;
    my $setting = $session->setting;
    my $form    = $session->form;

    #Messages Settings
    $setting->set("inboxStyleTemplateId",              $form->process("inboxStyleTemplateId",              "template"));
    $setting->set("inboxLayoutTemplateId",             $form->process("inboxLayoutTemplateId",             "template"));
    $setting->set("inboxViewTemplateId",               $form->process("inboxViewTemplateId",               "template"));
    $setting->set("inboxViewMessageTemplateId",        $form->process("inboxViewMessageTemplateId",        "template"));
    $setting->set("inboxSendMessageTemplateId",        $form->process("inboxSendMessageTemplateId",        "template"));
    $setting->set("inboxMessageConfirmationTemplateId",$form->process("inboxMessageConfirmationTemplateId","template"));
    $setting->set("inboxErrorTemplateId",              $form->process("inboxErrorTemplateId",              "template"));
    #Friends Invitations Settings
    $setting->set("inboxManageInvitationsTemplateId",  $form->process("inboxManageInvitationsTemplateId",  "template"));
    $setting->set("inboxViewInvitationTemplateId",     $form->process("inboxViewInvitationTemplateId",     "template"));
    $setting->set("inboxInvitationConfirmTemplateId",  $form->process("inboxInvitationConfirmTemplateId",  "template"));
    #User Invitation Settings
    $setting->set("inboxInviteUserEnabled",            $form->process("inboxInviteUserEnabled",            "yesNo"));
    $setting->set("inboxInviteUserRestrictSubject",    $form->process("inboxInviteUserRestrictSubject",    "yesNo"));
    $setting->set("inboxInviteUserSubject",            $form->process("inboxInviteUserSubject",            "text"));
    $setting->set("inboxInviteUserRestrictMessage",    $form->process("inboxInviteUserRestrictMessage",    "yesNo"));
    $setting->set("inboxInviteUserMessage",            $form->process("inboxInviteUserMessage",            "HTMLArea"));    
    $setting->set("inboxInviteUserMessageTemplateId",  $form->process("inboxInviteUserMessageTemplateId",  "template"));
    $setting->set("inboxInviteUserTemplateId",         $form->process("inboxInviteUserTemplateId",         "template"));
    $setting->set("inboxInviteUserConfirmTemplateId",  $form->process("inboxInviteUserConfirmTemplateId",  "template"));
    #General Inbox Settings
    $setting->set("inboxRichEditId",                   $form->process("inboxRichEditId",                 "selectRichEditor") );
    $setting->set("inboxCopySender",                   $form->process("inboxCopySender",                   "yesNo"));

    #Inbox Notification Settings
    $setting->set("sendInboxNotificationsOnly",        $form->process("sendInboxNotificationsOnly", "yesNo"));
    $setting->set("inboxNotificationsSubject",         $form->process("inboxNotificationsSubject", "text"));
    $setting->set("inboxNotificationTemplateId",       $form->process("inboxNotificationTemplateId","template"));
    $setting->set("inboxSmsNotificationTemplateId",    $form->process("inboxSmsNotificationTemplateId","template"));
    $setting->set("sendRejectNotice",                  $form->process("sendRejectNotice","yesNo"));
}


#-------------------------------------------------------------------

=head2 getInboxErrorTemplateId ( )

This method returns the template ID for inbox errors.

=cut

sub getInboxErrorTemplateId {
    my $self = shift;
    return $self->session->setting->get("inboxErrorTemplateId") || "ErEzulFiEKDkaCDVmxUavw";
}

#-------------------------------------------------------------------

=head2 getInboxNotificationTemplateId ( )

This method returns the template ID for inbox notifications.

=cut

sub getInboxNotificationTemplateId {
    my $self = shift;
    return $self->session->setting->get("inboxNotificationTemplateId") || "b1316COmd9xRv4fCI3LLGA";
}

#-------------------------------------------------------------------

=head2 getInboxSmsNotificationTemplateId ( )

This method returns the template ID for inbox SMS notifications.

=cut

sub getInboxSmsNotificationTemplateId {
    my $self = shift;
    return $self->session->setting->get("inboxSmsNotificationTemplateId") || "i9-G00ALhJOr0gMh-vHbKA";
}

#-------------------------------------------------------------------

=head2 getInvitationCount ( )

This method returns the total number of invitations in the invitation box.

=cut

sub getInvitationCount {
    my $self    = shift;
    my $session = $self->session;
    return $session->db->quickScalar(
        q{select count(*) from friendInvitations where friendId=?},
        [$session->user->userId]
    );
}

#-------------------------------------------------------------------

=head2 getInvitationConfirmTemplateId ( )

This method returns the template ID for invitation errors.

=cut

sub getInvitationConfirmTemplateId {
    my $self = shift;
    return $self->session->setting->get("inboxInvitationConfirmTemplateId") || "5A8Hd9zXvByTDy4x-H28qw";
}

#-------------------------------------------------------------------

=head2 getInviteUserMessageTemplateId ( )

This method returns the template ID for the user email message

=cut

sub getInviteUserMessageTemplateId {
    my $self = shift;
    return $self->session->setting->get("inboxInviteUserMessageTemplateId") || "XgcsoDrbC0duVla7N7JAdw";
}

#-------------------------------------------------------------------

=head2 getInviteUserTemplateId ( )

This method returns the template ID for the main invite user screen.

=cut

sub getInviteUserTemplateId {
    my $self = shift;
    return $self->session->setting->get("inboxInviteUserTemplateId") || "cR0UFm7I1qUI2Wbpj--08Q";
}

#-------------------------------------------------------------------

=head2 getInviteUserConfirmTemplateId ( )

This method returns the template ID for invitation errors.

=cut

sub getInviteUserConfirmTemplateId {
    my $self = shift;
    return $self->session->setting->get("inboxInviteUserConfirmTemplateId") || "SVIhz68689hwUGgcDM-gWw";
}

#-------------------------------------------------------------------

=head2 getLayoutTemplateId ( )

This method returns the template ID for the account layout.

=cut

sub getLayoutTemplateId {
    my $self = shift;
    return $self->session->setting->get("inboxLayoutTemplateId") || "gfZOwaTWYjbSoVaQtHBBEw";
}


#-------------------------------------------------------------------

=head2 getManageInvitationsTemplateId ( )

This method returns the template ID for the invitations manage screen.

=cut

sub getManageInvitationsTemplateId {
    my $self = shift;
    return $self->session->setting->get("inboxManageInvitationsTemplateId") || "1Q4Je3hKCJzeo0ZBB5YB8g";
}

#-------------------------------------------------------------------

=head2 getMessageConfirmTemplateId ( )

This method returns the template ID for message confirmations.

=cut

sub getMessageConfirmTemplateId {
    my $self = shift;
    return $self->session->setting->get("inboxMessageConfirmationTemplateId") || "DUoxlTBXhVS-Zl3CFDpt9g";
}

#-------------------------------------------------------------------

=head2 getRichEditorId

This method returns the rich editor ID users compose messages with.

=cut

sub getRichEditorId {
    my $self    = shift;
    return $self->session->setting->get("inboxRichEditId") || "PBrichedit000000000001";
}

#-------------------------------------------------------------------

=head2 getSendMessageTemplateId ( )

This method returns the template ID for the send message view.

=cut

sub getSendMessageTemplateId {
    my $self = shift;
    return $self->session->setting->get("inboxSendMessageTemplateId") || "6uQEULvXFgCYlRWnYzZsuA";
}

#-------------------------------------------------------------------

=head2 getStyleTemplateId ( )

This method returns the template ID for the main style.

=cut

sub getStyleTemplateId {
    my $self = shift;
    return $self->session->setting->get("inboxStyleTemplateId") || $self->SUPER::getStyleTemplateId;
}

#-------------------------------------------------------------------

=head2 getUserProfileUrl ( userId )

This method stores a reference of user profile URLs to prevent us from having to instantiate
the same users over and over as the nature of an inbox is to have multiple messages from the same user.

=cut

sub getUserProfileUrl {
    my $self   = shift;
    my $userId = shift;


    unless ($self->store->{$userId}) {
        $self->store->{$userId} = WebGUI::User->new($self->session,$userId)->getProfileUrl;
    }
    return $self->store->{$userId};
}

#-------------------------------------------------------------------

=head2 getViewInvitationTemplateId ( )

This method returns the id for the view message template.

=cut

sub getViewInvitationTemplateId {
    my $self = shift;
    return $self->session->setting->get("inboxViewInvitationTemplateId") || "VBkY05f-E3WJS50WpdKd1Q";
}

#-------------------------------------------------------------------

=head2 getViewInvitationUrl ( session )

Class method which returns the base url for viewing invitations

=head3 session

session object

=cut

sub getViewInvitationUrl {
    my $class   = shift;
    my $session = shift;
    my $url     = $session->url;

    return $url->append($url->getSiteURL,"op=account;module=inbox;do=viewInvitation");
}


#-------------------------------------------------------------------

=head2 getViewMessageTemplateId ( )

This method returns the id for the view message template.

=cut

sub getViewMessageTemplateId {
    my $self = shift;
    return $self->session->setting->get("inboxViewMessageTemplateId") || "0n4HtbXaWa_XJHkFjetnLQs";
}

#-------------------------------------------------------------------

=head2 getViewTemplateId ( )

This method returns the template ID for the main view.

=cut

sub getViewTemplateId {
    my $self = shift;
    return $self->session->setting->get("inboxViewTemplateId") || "c8xrwVuu5QE0XtF9DiVzLw";
}

#-------------------------------------------------------------------

=head2 www_approveDenyInvitations ( )

Approves or denies invitations passed in.

=cut

sub www_approveDenyInvitations {
    my $self    = shift;
    my $session = $self->session;
    my $form    = $session->form;

    my @messages = $form->process("inviteId","checkList");
    my $approve  = $form->get("accept");
    my $deny     = $form->get("deny");

    $self->store->{tab} = "invitations";

    my $friends = WebGUI::Friends->new($session);

    my @users   = ();

    foreach my $inviteId (@messages) {
        my $invite  = $friends->getAddRequest($inviteId);
        my $inviter = WebGUI::User->new($session, $invite->{inviterId});
        next unless ($invite->{inviterId}); #Not sure how this could ever happen, but check for it
        next unless ($session->user->userId eq $invite->{friendId});  #Protect against malicious stuff
        if($deny) {
            $friends->rejectAddRequest($inviteId,$session->setting->get("sendRejectNotice"));
        }
        elsif($approve) {
            $friends->approveAddRequest($inviteId);
        }
        push (@users, {
            'friend_name'  => $inviter->getWholeName,
            'is_denied'    => ($deny ne ""),
            'is_approved'  => ($approve ne ""),
        });
    }
    my $var = {};
    $var->{'friends_loop'} = \@users;

    #Append common vars
    $self->appendCommonVars($var,WebGUI::Inbox->new($session));

    #Return a confirm message
    return $self->processTemplate($var,$self->getInvitationConfirmTemplateId);
}

#-------------------------------------------------------------------

=head2 www_deleteMessage ( )

Deletes a single messages passed in

=cut

sub www_deleteMessage {
    my $self    = shift;
    my $session = $self->session;

    my $messageId = $session->form->get("messageId");
    my $inbox     = WebGUI::Inbox->new($session);
    my $message   = $inbox->getMessage($messageId);

    $self->store->{tab} = "inbox";

    if (!(defined $message) || !$inbox->canRead($message)) {
        #View will handle displaying these errors
        return $self->www_viewMessage;
    }

    #Get the next message to display
    my $displayMessage = $inbox->getNextMessage($message);
    unless (defined $displayMessage) {
        #No more messages - try to get the previous message
        $displayMessage = $inbox->getPreviousMessage($message);
        unless (defined $displayMessage) {
            #This is the last message in the inbox - delete it and return to inbox
            $message->delete;
            return $self->www_view();
        }
    }
    $message->delete;

    return $self->www_viewMessage($displayMessage->getId);
}

#-------------------------------------------------------------------

=head2 www_deleteMessages ( )

Deletes a list of messages selected for the current user

=cut

sub www_deleteMessages {
    my $self    = shift;
    my $session = $self->session;

    $self->store->{tab} = "inbox";

    my @messages = $session->form->process("message","checkList");

    foreach my $messageId (@messages) {
        my $message = WebGUI::Inbox::Message->new($session, $messageId);
        $message->delete;
    }

    return $self->www_view();
}

#-------------------------------------------------------------------

=head2 www_actOnMessages ( )

Acts on a list of messages selected for the current user

=cut

sub www_actOnMessages {
    my $self    = shift;
    my $session = $self->session;
    my $action  = $session->form->process( 'action' );
    my $i18n    = WebGUI::International->new( $session, 'Account_Inbox' );

    my %handler = (
        $i18n->get( 'delete label' )         => \&www_deleteMessages,
        $i18n->get( 'mark as read label' )   => \&www_markAsReadMessages,
        $i18n->get( 'mark as unread label' ) => \&www_markAsUnreadMessages,
    );
    if ( defined $action && length $action && defined $handler{$action} ) {
        return $handler{$action}->( $self, @_ );
    }
    return $self->www_view();
}

#-------------------------------------------------------------------

=head2 www_markAsReadMessages ( )

Marks a list of messages selected for the current user as read

=cut

sub www_markAsReadMessages {
    my $self    = shift;
    my $session = $self->session;

    $self->store->{tab} = 'inbox';

    my @messages = $session->form->process( 'message', 'checkList' );

    foreach my $messageId ( @messages ) {
        my $message = WebGUI::Inbox::Message->new( $session, $messageId );
        $message->setRead;
    }

    return $self->www_view();
}

#-------------------------------------------------------------------

=head2 www_markAsUnreadMessages ( )

Marks a list of messages selected for the current user as unread

=cut

sub www_markAsUnreadMessages {
    my $self    = shift;
    my $session = $self->session;

    $self->store->{tab} = 'inbox';

    my @messages = $session->form->process( 'message', 'checkList' );

    foreach my $messageId ( @messages ) {
        my $message = WebGUI::Inbox::Message->new( $session, $messageId );
        $message->setUnread;
    }

    return $self->www_view();
}

#-------------------------------------------------------------------

=head2 www_inviteUser ( )

Form for inviting a user to join the site.

=cut

sub www_inviteUser {
    my $self         = shift;
    my $session      = $self->session;
    my $form         = $session->form;
    my $setting      = $session->setting;
    my $user         = $session->user;

    my $displayError = shift;
    my $var          = {};

    #Let the tab display that they are currently on
    $self->store->{tab} = "invitations";

    #Add any error passed in to be displayed if the form reloads
    $var->{'message_display_error'}  = $displayError;

    #Message From
    $var->{'message_from'     }  = $user->getWholeName;
    $var->{'message_from_id'  }  = $user->userId;

    #Message To
    $var->{'form_to'          } = WebGUI::Form::email($session, {
        name  => "to",
        value => $session->form->get('to'),
    });

    #Message Subject
    my $defaultSubject        = $setting->get("inboxInviteUserSubject");
    WebGUI::Macro::process($session,\$defaultSubject);
    my $subject               = $form->get('subject') || $defaultSubject;
    $var->{'subject_allowed'} = !($setting->get("inboxInviteUserRestrictSubject"));
    if($var->{'subject_allowed'}) {
        $var->{'form_subject' }  = WebGUI::Form::text($session, {
            name   => "subject",
            value  => $subject,
            extras => q{ class="invite_subject" }
        });
    }
    else {
        $var->{'form_subject' } = $subject;
    }   

    #Message Body
    my $defaultMessage          = $setting->get("inboxInviteUserMessage");
    WebGUI::Macro::process($session,\$defaultMessage);
    my $message                 = $form->get('message') || $defaultMessage;
    $var->{'message_allowed'  } = !($setting->get("inboxInviteUserRestrictMessage"));
    if($var->{'message_allowed'}) {
        $var->{'form_message_text'}  = WebGUI::Form::textarea($session, {
            name   =>"message",
            value  =>$message,
            width  =>600,
            height =>200
        });
        $var->{'form_message_rich'}  = WebGUI::Form::HTMLArea($session, {
            name  => "message",
            value => $message,
            width => "600",
            richEditId => $self->getRichEditorId,
        });
    }
    else {
        $var->{'form_message_text'} = $message;
        $var->{'form_message_rich'} = $message;
    }

    $var->{'form_header'      }  = WebGUI::Form::formHeader($session,{
        action => $self->getUrl("module=inbox;do=inviteUserSave"),
        extras => q{name="inviteForm"}
    });

    $var->{'submit_button'    }  = WebGUI::Form::submit($session,{});
    $var->{'form_footer'      }  = WebGUI::Form::formFooter($session, {});
    $var->{'back_url'         }  = $session->request->referer || $var->{'view_inbox_url'};

    #Add common template variable for displaying the inbox
    $self->appendCommonVars($var);

    return $self->processTemplate($var,$self->getInviteUserTemplateId);
}

#-------------------------------------------------------------------

=head2 www_inviteUserSave ( )

Post process the form, check for required fields, handle inviting users who are already
members (determined by email address) and send the email.

=cut

sub www_inviteUserSave {
    my $self         = shift;
    my $session      = $self->session;
    my $form         = $session->form;
    my $setting      = $session->setting;
    my $user         = $session->user;
    my $i18n         = WebGUI::International->new($session,"Account_Inbox");

    #Must have a subject
    my $defaultSubject = $setting->get("inboxInviteUserSubject");
    WebGUI::Macro::process($session,\$defaultSubject);
    my $subject        = ($setting->get("inboxInviteUserRestrictSubject"))
                       ? $defaultSubject
                       : $form->get('subject')
                       ;
    return $self->www_inviteUser($i18n->get('missing subject')) unless $subject;

    #Must have a message
    my $defaultMessage = $setting->get("inboxInviteUserMessage");
    WebGUI::Macro::process($session,\$defaultMessage);
    my $message        = ($setting->get("inboxInviteUserRestrictMessage"))
                       ? $defaultMessage
                       : $form->get("message")
                       ;    
    return $self->www_inviteUser($i18n->get('missing message')) unless $message;

    #Profile Email address check
    my $email = $session->user->profileField('email');
    unless ($email) {
        return $self->www_inviteUser($i18n->get('no email'));
    }

    #Must have a person to send email to
    my $to = $form->get('to');
    $to =~ s/\s+//g;
    return $self->www_inviteUser($i18n->get('missing email')) unless $to;

    # Test all email addresses before sending any
    my $db     = $session->db;
    my @toList = split /[;,]/, $to;
    for my $inviteeEmail (@toList) {
        unless ( Email::Valid->address($inviteeEmail) ) {
            return $self->www_inviteUser( sprintf $i18n->get('invalid email'), $inviteeEmail );
        }

        # User existance check.
        my $existingUser = WebGUI::User->newByEmail( $session, $inviteeEmail );
        if ( defined $existingUser ) {
            my $existingProfile = $existingUser->getProfileUrl;
            my $existingUser    = $existingUser->username;
            my $errorMsg        = sprintf( $i18n->get('already a member'), $existingProfile, $existingUser );
            return $self->www_inviteUser($errorMsg);
        }

        # Outstanding Invitation check
        my $sth = $db->read( "SELECT email FROM userInvitations WHERE email=?", [$inviteeEmail] );
        my ($emailStored) = $sth->array;
        if ($emailStored) {
            my $errorMsg = sprintf( $i18n->get('currently invited'), $inviteeEmail );
            return $self->www_inviteUser($errorMsg);
        }
    } ## end for my $inviteeEmail (@toList)

    # We think the email addresses are good now.
    # Create a separate record for each invitee
    #
    for my $inviteeEmail (@toList) {
        my $var = {};

        ##Create the invitation url for each individual invitation
        my $inviteId = $session->id->generate();
        $var->{'url'}
            = $session->url->append( $session->url->getSiteURL, 'op=auth;method=createAccount;code=' . $inviteId );

        ##Create the invitation record.
        my $now = WebGUI::DateTime->new( $session, DateTime->now->set_time_zone('UTC')->epoch )->toMysqlDate;
        my $hash = {
            userId      => $user->userId,
            dateSent    => $now,
            email       => $inviteeEmail,
            dateCreated => $now,
        };
        $session->db->setRow( 'userInvitations', 'inviteId', $hash, $inviteId );

        my $invitation = WebGUI::Mail::Send->create(
            $session, {
                to      => $to,
                from    => $session->setting->get('companyEmail'),
                replyTo => $email,
                subject => $subject,
            }
        );

        ## No sneaky attack paths...
        $var->{'message'} = WebGUI::HTML::format(WebGUI::HTML::filter($message));

        my $emailBody = $self->processTemplate( $var, $self->getInviteUserMessageTemplateId );

        $invitation->addHtml($emailBody);

        $invitation->queue;

    } ## end for my $inviteeEmail (@toList)

    my $var = {};
    $self->appendCommonVars($var);
    return $self->processTemplate($var,$self->getInviteUserConfirmTemplateId);
}

#-------------------------------------------------------------------

=head2 www_manageInvitations ( )

The page on which users can manage their friends requests

=cut

sub www_manageInvitations {
    my $self    = shift;
    my $session = $self->session;
    my $user    = $session->user;
    my $var     = {};
    my $i18n    = WebGUI::International->new($session,'Account_Inbox');

    $self->store->{tab} = "invitations";

    #Deal with rows per page
    my $rpp          = $session->form->get("rpp") || 25;
    my $rpp_url      = ";rpp=$rpp";

    #Cache the base url
    my $inboxUrl     =  $self->getUrl("op=account;module=inbox;do=manageInvitations");

    #Create the paginator
    my $sql    = q{ select * from friendInvitations where friendId=? order by dateSent desc };
    my $p      = WebGUI::Paginator->new(
        $session,
        $inboxUrl.$rpp_url,
        $rpp
    );
    $p->setDataByQuery($sql,undef,undef,[$user->userId]);

    #Export page to template
    my @msg    = ();
    foreach my $row ( @{$p->getPageData} ) {
        my $inviter   = WebGUI::User->new($session,$row->{inviterId});
        next if($inviter->isVisitor); # Inviter account got deleted

        my $epoch = WebGUI::DateTime->new(mysql => $row->{dateSent} )->epoch;

        my $hash                       = {};
        $hash->{'invite_id'          } = $row->{inviteId};
        $hash->{'message_url'        } = $self->getUrl("module=inbox;do=viewInvitation;inviteId=".$row->{inviteId});
        $hash->{'from_id'            } = $row->{inviterId};
        $hash->{'from_url'           } = $inviter->getProfileUrl;  #Get the profile url of this user which may be cached.
        $hash->{'from'               } = $inviter->getWholeName;
        $hash->{'dateStamp'          } = $epoch;
	  	$hash->{'dateStamp_formatted'} = $session->datetime->epochToHuman($epoch);
        $hash->{'form_checkbox'      } = WebGUI::Form::checkbox($session,{
            name  => "inviteId",
            value => $row->{inviteId}
        });
	  	push(@msg,$hash);
   	}
    my $msgCount  = $p->getRowCount;

   	$var->{'message_loop'  } = \@msg;
    $var->{'has_messages'  } = $msgCount > 0;
    $var->{'message_total' } = $msgCount;

    $var->{'form_header'   } = WebGUI::Form::formHeader($session,{
        action => $self->getUrl("module=inbox;do=approveDenyInvitations")
    });
    $var->{'form_footer'   } = WebGUI::Form::formFooter($session);

    $var->{'form_accept'   } = WebGUI::Form::submit($session,{
        name  =>"accept",
        value =>$i18n->get("accept button label")
    });

    $var->{'form_deny'     } = WebGUI::Form::submit($session,{
        name  =>"deny",
        value =>$i18n->get("deny button label")
    });

    tie my %rpps, "Tie::IxHash";
    %rpps = (25 => "25", 50 => "50", 100=>"100");
    $var->{'message_rpp'  } = WebGUI::Form::selectBox($session,{
        name    =>"rpp",
        options => \%rpps,
        value   => $session->form->get("rpp") || 25,
        extras  => q{onchange="location.href='}.$inboxUrl.q{;rpp='+this.options[this.selectedIndex].value"}
    });

    #Append common vars
    $self->appendCommonVars($var,WebGUI::Inbox->new($session));
    #Append pagination vars
    $p->appendTemplateVars($var);

    return $self->processTemplate($var,$self->getManageInvitationsTemplateId);
}

#-------------------------------------------------------------------

=head2 www_sendMessage ( )

The page on which users send or reply to messages

=cut

sub www_sendMessage {
    my $self         = shift;
    my $session      = $self->session;
    my $form         = $session->form;
    my $fromUser     = $session->user;
    my $displayError = shift;
    my $toUser       = undef;
    my $var          = {};

    $self->store->{tab} = "inbox";

    #Add any error passed in to be displayed if the form reloads
    $var->{'message_display_error'}  = $displayError;

    my $inbox     = WebGUI::Inbox->new($session); 

    #Add common template variable for displaying the inbox
    $self->appendCommonVars($var,$inbox);

    my $messageId = $form->get("messageId");
    my $userId    = $form->get("userId");
    my $pageUrl   = $session->url->page;
    my $backUrl   = $session->request->referer || $var->{'view_inbox_url'};
    my $errorMsg  = "";

    if($messageId) {
        #This is a reply to a message - automate who the user is
        my $message = $inbox->getMessage($messageId);

        #Handle Errors
        if (!(defined $message)) {
            #Message doesn't exist
            my $i18n  = WebGUI::International->new($session,'Account_Inbox');
            $errorMsg = $i18n->get("message does not exist");        
        }
        elsif (!$inbox->canRead($message)) {
            #User trying to reply to message that they have not been sent.
            my $i18n  = WebGUI::International->new($session,'Account_Inbox');
            $errorMsg = $i18n->get("no reply error");
        }
        elsif($message->get("status") eq "completed" || $message->get("status") eq "pending") {
            #User trying to reply to system message
            my $i18n  = WebGUI::International->new($session,'Account_Inbox');
            $errorMsg = $i18n->get("system message error");
        }
        if($errorMsg) {
            $var->{'isInbox'} = "true";
            return $self->showError($var,$errorMsg,$backUrl,$self->getInboxErrorTemplateId);
        }

        #Otherwise you should be able to reply to anyone who sent you a message    
        $toUser = WebGUI::User->new($session,$message->get("sentBy"));
        $var->{'isReply'        } = "true";
        $var->{'message_to'     } = $toUser->getWholeName;
        $var->{'message_subject'} = $message->get("subject");
    }
    elsif($userId) {
        #This is a private message to a user - check user private message settings

        #Handle Errors
        $toUser = WebGUI::User->new($session,$userId);
        if($toUser->isVisitor || !$toUser->acceptsPrivateMessages($fromUser->userId)) {
            #Trying to send messages to the visitor or a user that doesn't exist
            my $i18n  = WebGUI::International->new($session,'Account_Inbox');
            $errorMsg = $i18n->get("blocked error");
        }
        elsif($toUser->userId eq $fromUser->userId) {
            #Trying to send a message to yourself
            my $i18n  = WebGUI::International->new($session,'Account_Inbox');
            $errorMsg = $i18n->get("no self error");
        }
        if($errorMsg) {
            $var->{'isInbox'} = "true";
            return $self->showError($var,$errorMsg,$backUrl,$self->getInboxErrorTemplateId);
        }

        $var->{'isPrivateMessage'} = "true";
        $var->{'message_to'      } = $toUser->getWholeName;
    }
    else {
        #This is a new message
        $var->{'isNew'     } = "true";

        my $friends           = $fromUser->friends->getUserList;
        my @checkedFriends    = ();
        my @friendsChecked    = $form->process("friend","checkList");
        my $activeFriendCount = 0;
        #Append this users friends to the template
        my @friendsLoop = ();
        my @friendIds = keys %{ $friends };
        foreach my $friendId (@friendIds) {
            my $friend     = WebGUI::User->new($session,$friendId);
            #This friend has private messages turned off
            my $disabled   = "disabled";
            if($friend->acceptsPrivateMessages($fromUser->userId)) {
                $disabled  = "";
                $activeFriendCount++;
            }

            my $isChecked  = WebGUI::Utility::isIn($friendId,@friendsChecked);            
            my $friendHash = {
                'friend_id'        => $friendId,
                'friend_name'      => $friends->{$friendId},
                'friend_wholeName' => $friend->getWholeName,
            };

            push(@checkedFriends,$friendHash) if($isChecked);

            $friendHash->{'friend_checkbox'} = WebGUI::Form::checkbox($session,{
                name    => "friend",
                value   => $friendId,
                checked => $isChecked,
                extras  => q{id="friend_}.$friendId.qq{_id" $disabled},
            });

            push (@friendsLoop, $friendHash);
        }

        #You can't send new messages if you don't have any friends to send to
        unless(@friendIds) {
            my $i18n  = WebGUI::International->new($session,'Account_Inbox');
            $errorMsg = $i18n->get("no friends error");
            $var->{'isInbox'} = "true";
            return $self->showError($var,$errorMsg,$backUrl,$self->getInboxErrorTemplateId);
        }

        #You can't send new messages if you don't have any friends to send to
        unless($activeFriendCount) {
            my $i18n  = WebGUI::International->new($session,'Account_Inbox');
            $errorMsg = $i18n->get("no messagable friends error");
            $var->{'isInbox'} = "true";
            return $self->showError($var,$errorMsg,$backUrl,$self->getInboxErrorTemplateId);
        }

        $var->{'friends_loop'       } = \@friendsLoop;
        $var->{'checked_fiends_loop'} = \@checkedFriends;
    }

    $var->{'message_from'         }  = $fromUser->getWholeName;

    my $subject = $form->get("subject");
    if($subject eq "" && $messageId) {
        $subject = "Re: ".$var->{'message_subject'};
    }

	$var->{'form_subject'     }  = WebGUI::Form::text($session, {
        name   => "subject",
        value  => $subject,
        extras => q{ class="inbox_subject" }
    });

    $var->{'message_body'     } = $form->get('message');

    $var->{'form_message_text'}  = WebGUI::Form::textarea($session, {
        name   =>"message",
        value  =>$var->{'message_body'} || "",
        width  =>600,
        height =>200
    });

    $var->{'form_message_rich'}  = WebGUI::Form::HTMLArea($session, {
        name  => "message",
        value => $var->{'message_body'} || "",
        width => "600",
        richEditId => $self->getRichEditorId,
    });

    $var->{'form_header'      }  = WebGUI::Form::formHeader($session,{
        action => $self->getUrl("module=inbox;do=sendMessageSave;messageId=$messageId;userId=$userId"),
        extras => q{name="messageForm"}
    });

    $var->{'submit_button'    }  = WebGUI::Form::submit($session,{});
    $var->{'form_footer'      }  = WebGUI::Form::formFooter($session, {});
    $var->{'back_url'         }  = $backUrl;

    return $self->processTemplate($var,$self->getSendMessageTemplateId);
}

#-------------------------------------------------------------------

=head2 www_sendMessageSave ( )

Sends the message created by the user

=cut

sub www_sendMessageSave {
    my $self      = shift;
    my $session   = $self->session;
    my $form      = $session->form;
    my $fromUser  = $session->user;
    my $var       = {};
    my $errorMsg  = "";
    my @toUsers   = ();

    $self->store->{tab} = "inbox";

    #Add common template variable for displaying the inbox
    my $inbox     = WebGUI::Inbox->new($session); 

    my $messageId = $form->get("messageId");
    my $userId    = $form->get("userId");
    my @friends   = $form->get("friend","checkList");    
    push (@friends, $userId) if ($userId);

    my $hasError  = 0;

    my $subject   = $form->get("subject");
    my $message   = $form->get("message");

    #Check for hacker errors / set who the message is going to
    if($messageId) {
        #This is a reply to a message - automate who the user is
        my $message = $inbox->getMessage($messageId);
        #Handle Errors
        if (!(defined $message)
                || !$inbox->canRead($message)
                || $message->get("status") eq "completed"
                || $message->get("status") eq "pending") {
            $hasError = 1;
        }
        push(@toUsers,$message->get("sentBy"));
        $message->setStatus("replied");
    }
    elsif(scalar(@friends)) {
        #This is a private message to a user - check user private message settings
        foreach my $userId (@friends) {
            my $toUser = WebGUI::User->new($session,$userId);
            if($toUser->isVisitor
                    || !$toUser->acceptsPrivateMessages($fromUser->userId)
                    || $toUser->userId eq $fromUser->userId) {
                $hasError = 1;
            }
            push(@toUsers,$userId);
        }
    }

    if($session->setting->get('inboxCopySender')) {
        push @toUsers, $session->user->userId;
    }

    #Check for client errors
    if($subject eq "") {
        my $i18n  = WebGUI::International->new($session,'Account_Inbox');
        $errorMsg = $i18n->get("no subject error");
        $hasError = 1;
    }
    elsif($message eq "") {
        my $i18n  = WebGUI::International->new($session,'Account_Inbox');
        $errorMsg = $i18n->get("no message error");
        $hasError = 1;
    }
    elsif(scalar(@toUsers) == 0) {
        my $i18n  = WebGUI::International->new($session,'Account_Inbox');
        $errorMsg = $i18n->get("no user error");
        $hasError = 1;
    }

    #Let sendMessage deal with displaying errors
    return $self->www_sendMessage($errorMsg) if $hasError;

    foreach my $uid (@toUsers) {
        my $messageProperties = {
            message => $message,
            subject => $subject,
            status  => 'unread',
            sentBy  => $fromUser->userId
        };
        my $messageOptions = {};
        
        # Handle Email/SMS Notifications
        my $user = WebGUI::User->new($session, $uid);
        
        # Sender only gets CCd on inbox message (not real email)
        my $isSender = $uid eq $session->user->userId;
        $messageOptions->{no_email} = 1 if $isSender;
        
        # Optionally set SMS notification details (excluding sender)
        my $smsAddress = $user->getInboxSmsNotificationAddress;
        if ( $smsAddress && !$isSender ) {
            my $smsNotificationTemplate
                = WebGUI::Asset::Template->newById($session, $self->getInboxSmsNotificationTemplateId);
            if (! Exception::Class->caught() ) {
                ##Create template variables
                my $var = {
                    fromUsername => $fromUser->username,
                    subject      => $messageProperties->{subject},
                    message      => $messageProperties->{message},
                    inboxLink    => $session->url->append($session->url->getSiteURL, 'op=account;module=inbox'),
                };
                ##Fill in template
                my $output = $smsNotificationTemplate->process($var);
                ##Evaluate macros by hand
                WebGUI::Macro::process($session, \$output);
                ##Assign template output to $messageProperties->{emailMessage}
                $messageProperties->{smsMessage} = $output;
                $messageProperties->{smsAddress} = $smsAddress;
                $messageProperties->{smsSubject} = $self->session->setting->get('smsGatewaySubject');
            }
            else {
                $session->log->warn(sprintf "Unable to instanciate notification template: ". $self->getInboxSmsNotificationTemplateId);
            }
        }
        
        # Optionally set email notification details (excluding sender)
        if ($session->setting->get('sendInboxNotificationsOnly') && !$isSender) {
            my $notificationAddresses = $user->getInboxNotificationAddresses;
            
            # If user has turned off email notifications and admin has turned on sendInboxNotificationsOnly,
            # user gets no email at all - because email and email notification are mutually exclusive.
            # Note that they can still possibly get SMS notification above
            if (!$notificationAddresses) {
                $messageOptions->{no_email} = 1;
            } else {
                my $template = eval { WebGUI::Asset::Template->newById($session, $self->getInboxNotificationTemplateId); };
                if (! Exception::Class->caught() ) {
                    ##Create template variables
                    my $var = {
                        fromUsername => $fromUser->username,
                        subject      => $messageProperties->{subject},
                        message      => $messageProperties->{message},
                        inboxLink    => $session->url->append($session->url->getSiteURL, 'op=account;module=inbox'),
                    };
                    ##Fill in template
                    my $output = $template->process($var);
                    ##Evaluate macros by hand
                    WebGUI::Macro::process($session, \$output);
                    ##Assign template output to $messageProperties->{emailMessage}
                    $messageProperties->{emailMessage} = $output;
                    $messageProperties->{emailSubject} = $session->setting->get('inboxNotificationsSubject');
                }
                else {
                    $session->log->warn(sprintf "Unable to instanciate notification template: ". $self->getInboxNotificationTemplateId);
                }
            }
        }
        
        $messageProperties->{userId} = $uid;
        my $thisMessage = $inbox->addMessage($messageProperties, $messageOptions);
        if ($uid eq $session->user->userId) {
            $thisMessage->setRead;
        }
    }

    $self->appendCommonVars($var,$inbox);

    return $self->processTemplate($var,$self->getMessageConfirmTemplateId);
}


#-------------------------------------------------------------------

=head2 www_view ( )

The main view page for editing the user's profile.

=cut

sub www_view {
    my $self    = shift;
    my $session = $self->session;
    my $user    = $self->getUser;

    my $var     = {};

    $self->store->{tab} = "inbox";

    #Deal with sort order
    my $sortBy       = $session->form->get("sortBy") || undef;
    my $sort_url     = ($sortBy)?";sortBy=$sortBy":"";

    #Deal with sort direction
    my $sortDir      = $session->form->get("sortDir") || "desc";
    my $sortDir_url  = ";sortDir=".(($sortDir eq "desc")?"asc":"desc");

    #Deal with rows per page
    my $rpp          = $session->form->get("rpp") || 25;
    my $rpp_url      = ";rpp=$rpp";

    #Deal with user filtering
    my $userFilter      = $session->form->get("userFilter") || 'all';
    my $userFilter_url  = ";userFilter=$userFilter";

    #Cache the base url
    my $inboxUrl     =  $self->getUrl('', 'useUid');

    my $urlFrag = $sortDir_url . $rpp_url . $userFilter_url;

    #Create sortBy headers
    $var->{'subject_url'   } = $inboxUrl.";sortBy=subject"   . $urlFrag;
   	$var->{'status_url'    } = $inboxUrl.";sortBy=status"    . $urlFrag;
    $var->{'from_url'      } = $inboxUrl.";sortBy=sentBy"    . $urlFrag;
    $var->{'dateStamp_url' } = $inboxUrl.";sortBy=dateStamp" . $urlFrag;

    $var->{'rpp_url'       } = $inboxUrl.$sort_url.$sortDir_url.$userFilter_url;

    #Create the paginator
    my $inbox     = WebGUI::Inbox->new($session);
    my $messageOptions = {
        sortBy        => $sortBy,
        sortDir       => $sortDir,
        baseUrl       => $inboxUrl.$sort_url.$sortDir_url.$rpp_url.$userFilter_url,
        paginateAfter => $rpp,
    };
    if ($userFilter ne 'all') {
        $messageOptions->{whereClause} = sprintf 'ibox.sentBy=%s', $session->db->quote($session->form->get('userFilter'));
    }
    my $p         = $inbox->getMessagesPaginator($user, $messageOptions);

    #Export page to template
    my @msg       = ();
    foreach my $row ( @{$p->getPageData} ) {
        my $message = $inbox->getMessage( $row->{messageId} );
        #next if($message->get('status') eq 'deleted');

        my $hash                       = {};
        $hash->{'message_id'         } = $message->getId;
        $hash->{'message_url'        } = $self->getUrl("module=inbox;do=viewMessage;messageId=".$message->getId,'useUid');
        $hash->{'subject'            } = $message->get("subject");
        $hash->{'status_class'       } = $message->get("status");
        $hash->{'status'             } = $message->getStatus;
        $hash->{'isRead'             } = $message->isRead;
        $hash->{'isReplied'          } = $hash->{'status_class'} eq "replied";
        $hash->{'isPending'          } = $hash->{'status_class'} eq "pending";
        $hash->{'isCompleted'        } = $hash->{'status_class'} eq "completed";
        $hash->{'from_id'            } = $message->get("sentBy");
        $hash->{'from_url'           } = $self->getUserProfileUrl($hash->{'from_id'});  #Get the profile url of this user which may be cached.
        $hash->{'from'               } = $row->{'fullName'};
        $hash->{'dateStamp'          } = $message->get("dateStamp");
	  	$hash->{'dateStamp_formatted'} = $session->datetime->epochToHuman($hash->{'dateStamp'});
        $hash->{'inbox_form_delete'  } = WebGUI::Form::checkbox($session,{
            name  => "message",
            value => $message->getId
        });
	  	push(@msg,$hash);
   	}
    my $msgCount  = $p->getRowCount;

   	$var->{'message_loop'        } = \@msg;
    $var->{'has_messages'        } = $msgCount > 0;
    $var->{'message_total'       } = $msgCount;
    $var->{'new_message_url'     } = $self->getUrl("module=inbox;do=sendMessage");
    $var->{'canSendMessages'     } = $user->hasFriends;

    tie my %rpps, "Tie::IxHash";
    %rpps = (25 => "25", 50 => "50", 100=>"100");
    $var->{'message_rpp'  } = WebGUI::Form::selectBox($session,{
        name    =>"rpp",
        options => \%rpps,
        value   => $session->form->get("rpp") || 25,
        extras  => q{onchange="location.href='}.$var->{'rpp_url'}.q{;rpp='+this.options[this.selectedIndex].value"}
    });

    my $userSql = $inbox->getMessageSql(undef, { 'select' => <<EOSQL, });
ibox.sentBy,
(IF(userProfileData.firstName != '' and userProfileData.firstName is not null and userProfileData.lastName !='' and userProfileData.lastName is not null, concat(userProfileData.firstName,' ',userProfileData.lastName),users.username)) as fullName
EOSQL
    tie my %userHash, 'Tie::IxHash';
    my $i18n = WebGUI::International->new($session, 'Account_Inbox');
    %userHash = ( 'all' => $i18n->get('All users'), $session->db->buildHash($userSql) );
    $var->{'userFilter'} = WebGUI::Form::selectBox($session,{
        name    => 'userFilter',
        options => \%userHash,
        value   => $session->form->get('userFilter') || 'all',
        extras  => q{onchange="location.href='}.$inboxUrl.q{;userFilter='+this.options[this.selectedIndex].value"}
    });

    $var->{'form_header'} = WebGUI::Form::formHeader($session,{
        action => $self->getUrl("module=inbox;do=actOnMessages")
    });
    $var->{'form_footer'} = WebGUI::Form::formFooter($session);

    #Append common vars - form headers set in here 
    $self->appendCommonVars($var,$inbox);
    #Append pagination vars
    $p->appendTemplateVars($var);
    return $self->processTemplate($var,$self->getViewTemplateId);
}

#-------------------------------------------------------------------

=head2 www_viewInvitation ( )

The page on which users view their messages

=cut

sub www_viewInvitation {
    my $self       = shift;
    my $session    = $self->session;
    my $user       = $session->user;

    my $var        = {};
    my $inviteId   = shift || $session->form->get("inviteId");
    my $errorMsg   = shift;
    my $i18n       = WebGUI::International->new($session,'Account_Inbox');

    $self->store->{tab} = "invitations";

    my $friends    = WebGUI::Friends->new($session);
    my $invitation = $friends->getAddRequest($inviteId);
    my $inviter    = WebGUI::User->new($session,$invitation->{inviterId});

    #Add common template variable for displaying the inbox
    $self->appendCommonVars($var,WebGUI::Inbox->new($session));

    #Handle Errors
    if (!($invitation->{inviteId})) { #Invitation is invalid
        $errorMsg = $i18n->get("invitation does not exist");        
    }
    elsif ($inviter->isVisitor) { #Inviter user account was deleted
        $errorMsg = $i18n->get("inviter no longer exists");
    }
    elsif ($session->user->userId ne $invitation->{friendId}) { #User trying to view someone else's invitation
        $errorMsg = $i18n->get("no access to invitation");
    }

    if($errorMsg) {
        my $backUrl = $var->{'view_invitations_url'};
        $var->{'isInvitation'} = "true";
        return $self->showError($var,$errorMsg,$backUrl,$self->getInboxErrorTemplateId);
    }

    my $epoch = WebGUI::DateTime->new(mysql => $invitation->{dateSent} )->epoch;

    $var->{'invite_id'              } = $inviteId;
    $var->{'message_from_id'        } = $inviter->userId; 
    $var->{'message_from'           } = $inviter->getWholeName;
    $var->{'message_from_url'       } = $inviter->getProfileUrl;
    $var->{'message_dateStamp'      } = $epoch;
    $var->{'message_dateStamp_human'} = $session->datetime->epochToHuman($epoch);
    $var->{'message_body'           } = $invitation->{comments};

    unless ($var->{'message_body'} =~ /\<a/ig) {
        $var->{'message_body'} =~ s/(http\S*)/\<a href=\"$1\"\>$1\<\/a\>/g;
    }
    unless ($var->{'message_body'} =~ /\<div/ig
                || $var->{'message_body'} =~ /\<br/ig
                || $var->{'message_body'} =~ /\<p/ig) {
        $var->{'message_body'} =~ s/\n/\<br \/\>\n/g;
    }

    #Build the action URLs
    my $nextInvitation = $friends->getPreviousInvitation($invitation);  #Messages sorted descending so next is actually previous
    if( $nextInvitation->{inviteId} ) {
        $var->{'hasNext'         } = "true";
        $var->{'next_message_url'} = $self->getUrl("module=inbox;do=viewInvitation;inviteId=".$nextInvitation->{inviteId});
    }

    my $prevInvitation = $friends->getNextInvitation($invitation);  #Messages sorted descending so previous is actually next
    if( $prevInvitation->{inviteId} ) {
        $var->{'hasPrevious'     } = "true";
        $var->{'prev_message_url'} = $self->getUrl("module=inbox;do=viewInvitation;inviteId=".$prevInvitation->{inviteId});
    }

    $var->{'form_header'  } = WebGUI::Form::formHeader($session,{
        action => $self->getUrl("module=inbox;do=approveDenyInvitations;inviteId=".$inviteId)
    });
    $var->{'form_footer'  } = WebGUI::Form::formFooter($session);

    $var->{'form_accept'  } = WebGUI::Form::submit($session,{
        name  =>"accept",
        value =>$i18n->get("accept button label")
    });

    $var->{'form_deny'   } = WebGUI::Form::submit($session,{
        name  =>"deny",
        value =>$i18n->get("deny button label")
    });

    return $self->processTemplate($var,$self->getViewInvitationTemplateId);
}

#-------------------------------------------------------------------

=head2 www_viewMessage ( )

The page on which users view their messages

=cut

sub www_viewMessage {
    my $self      = shift;
    my $session   = $self->session;
    my $user      = $self->getUser;

    my $var       = {};
    my $messageId = shift || $session->form->get("messageId");
    my $errorMsg  = shift;

    $self->store->{tab} = "inbox";

    my $inbox     = WebGUI::Inbox->new($session);    
    my $message   = $inbox->getMessage($messageId);

    #Add common template variable for displaying the inbox
    $self->appendCommonVars($var,$inbox);

    #Handler Errors
    if (!(defined $message)) {
        my $i18n  = WebGUI::International->new($session,'Account_Inbox');
        $errorMsg = $i18n->get("message does not exist");        
    }
    elsif (!$inbox->canRead($message)) { 
        my $i18n  = WebGUI::International->new($session,'Account_Inbox');
        $errorMsg = $i18n->get("no access");
    }

    if($errorMsg) {
        my $backUrl = $var->{'view_inbox_url'};
        $var->{'isInvitation'} = "true";
        return $self->showError($var,$errorMsg,$backUrl,$self->getInboxErrorTemplateId);
    }

    $message->setStatus("read") unless ($message->isRead);

    $var->{'message_id'             } = $messageId;
    $var->{'message_subject'        } = $message->get("subject");
    $var->{'message_dateStamp'      } = $message->get("dateStamp");
    $var->{'message_dateStamp_human'} = $session->datetime->epochToHuman($var->{'message_dateStamp'});
    $var->{'message_status'         } = $message->getStatus;
    $var->{'message_body'           } = $message->get("message");

    unless ($var->{'message_body'} =~ /\<a/ig) {
        $var->{'message_body'} =~ s/(http\S*)/\<a href=\"$1\"\>$1\<\/a\>/g;
    }
    unless ($var->{'message_body'} =~ /\<div/ig
                || $var->{'message_body'} =~ /\<br/ig
                || $var->{'message_body'} =~ /\<p/ig) {
        $var->{'message_body'} =~ s/\n/\<br \/\>\n/g;
    }

    #Get the user the message was sent by 
    my $sentBy        = $message->get("sentBy");
    my $from          = WebGUI::User->new($session,$sentBy);
    my $sentByVisitor = 0;
    if ($from->isVisitor) {
        $sentByVisitor = 1;
        $from = WebGUI::User->new($session,3);        
    }
    $var->{'message_from_id'        } = $from->userId; 
    $var->{'message_from'           } = $from->getWholeName;

    #Build the action URLs
    $var->{'delete_url'             } = $self->getUrl("module=inbox;do=deleteMessage;messageId=".$messageId);

    my $status = $message->get("status");
    if($sentBy ne $user->userId
                && !$sentByVisitor
                && $status ne "pending"
                && $status ne "completed" ) {
        $var->{'canReply' } = "true";
        $var->{'reply_url'} = $self->getUrl("module=inbox;do=sendMessage;messageId=".$messageId);
    }

    my $nextMessage = $inbox->getPreviousMessage($message);  #Message are displayed in descending order so next is actually previous
    if( defined $nextMessage ) {
        $var->{'hasNext'         } = "true";
        $var->{'next_message_url'} = $self->getUrl("module=inbox;do=viewMessage;messageId=".$nextMessage->getId);
    }

    my $prevMessage = $inbox->getNextMessage($message);  #Messages are displayed in descending order so previous is actually next
    if(defined $prevMessage) {
        $var->{'hasPrevious'     } = "true";
        $var->{'prev_message_url'} = $self->getUrl("module=inbox;do=viewMessage;messageId=".$prevMessage->getId);
    }

    return $self->processTemplate($var,$self->getViewMessageTemplateId);
}


1;
