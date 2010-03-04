package WebGUI::Operation::Inbox;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict qw(vars subs);
use WebGUI::Content::Account;
use WebGUI::Inbox::Message;
use WebGUI::International;
use WebGUI::User;

=head1 NAME

Package WebGUI::Operation::Inbox

=head1 DESCRIPTION

Operations for viewing message logs and individual messages.

=cut

#-------------------------------------------------------------------

=head2 _appendPrivateMessageForm ( vars, userTo, subject )

appends the form variables for the private message form

DEPRECATED: Do not use this method in new code.  It is here for API
compatibility only

=cut

sub _appendPrivateMessageForm {
	my $session        = shift;
	my $vars           = shift;
    my $userTo         = shift;
    my $message        = shift;
    
    my $i18n = WebGUI::International->new($session);
	
    my $form     = $session->form;
    my $user     = $session->user;
    
    $vars->{ message_from_label }  = $i18n->get("private message from label"); 
    $vars->{ message_from       }  = $user->username;
    
    $vars->{ message_to_label   }  = $i18n->get("private message to label"); 
    $vars->{ message_to         }  = $userTo->username;
    
    my $subject = $form->get("subject") || "";
    if($subject eq "" && defined $message) {
        $subject = "Re: ".$message->get("subject");
    }
    
    $vars->{ subject_label      }  = $i18n->get("private message subject label"); 
	$vars->{ subject            }  = WebGUI::Form::text($session, {
        name=>"subject",
        value=>$subject,
    });
    
    $vars->{ message_label      }  = $i18n->get("private message message label"); 
    $vars->{ message_text       }  = WebGUI::Form::textarea($session, {
        name=>"message",
        value=>$form->get("message") || "",
    });
    $vars->{ message_rich       }  = WebGUI::Form::HTMLArea($session, {
        name=>"message",
        value=>$form->get("message") || "",
    });

    my $messageId                 = "";
    if($form->get("messageId")) {
        $messageId = $form->get("messageId");
    }
    elsif(defined $message) {
        $messageId = $message->getId;
    }

    $vars->{'form_header'      }  = WebGUI::Form::formHeader($session,{
        action => $session->url->page("op=account;module=inbox;do=sendMessageSave;messageId=$messageId;userId=".$userTo->userId),
        extras => q{name="messageForm"}
    });
    
    $vars->{ submit_button     }  = WebGUI::Form::submit($session,{});
    $vars->{ submit_label      }  = $i18n->get("private message submit label");
    $vars->{ form_footer       }  = WebGUI::Form::formFooter($session, {});
}

#-------------------------------------------------------------------

=head2 _status ( )

returns a hashref with internationalized values for message status.

DEPRECATED: Do not use this method in new code. Use WebGUI::Inbox::Message->statusCodes

=cut

sub _status {
	my $session = shift;
	return WebGUI::Inbox::Message->statusCodes($session);
}

#-------------------------------------------------------------------

=head2 www_sendPrivateMessage ( )

DEPRECATED: See WebGUI::Account::Inbox::sendMessage

=cut

sub www_sendPrivateMessage {
	my $session  = shift;
    my $uid      = $session->form->get("uid");
    my $instance = WebGUI::Content::Account->createInstance($session,"inbox");
    return $instance->displayContent($instance->callMethod("sendMessage",[],$uid));
}

#-------------------------------------------------------------------

=head2 www_viewInbox ( )

DEPRECATED: See WebGUI::Account::Inbox::view

=cut

sub www_viewInbox {
	my $session = shift;
    my $instance = WebGUI::Content::Account->createInstance($session,"inbox");
    return $instance->displayContent($instance->callMethod("view"));
}

#-------------------------------------------------------------------

=head2 www_viewInboxMessage ( )

DEPRECATED:  Use WebGUI::Account::Inbox

Templated display of a single message for the user.

=cut

sub www_viewInboxMessage {
	my $session = shift;
    my $instance = WebGUI::Content::Account->createInstance($session,"inbox");
    return $instance->displayContent($instance->callMethod("viewMessage"));
}

1;
