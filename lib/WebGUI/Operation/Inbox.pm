package WebGUI::Operation::Inbox;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2007 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict qw(vars subs);
use URI;
use WebGUI::Inbox;
use WebGUI::International;
use WebGUI::Paginator;
use WebGUI::SQL;
use WebGUI::Asset::Template;
use WebGUI::User;
use WebGUI::Utility;
use WebGUI::Operation::Shared;

=head1 NAME

Package WebGUI::Operation::Inbox

=head1 DESCRIPTION

Operations for viewing message logs and individual messages.

=cut

#-------------------------------------------------------------------

=head2 _appendPrivateMessageForm ( vars, userTo, subject )

appends the form variables for the private message form

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
    $vars->{ message_to         } .= WebGUI::Form::hidden($session, {
        name=>"uid",
        value=>$userTo->userId
    });
    
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
    
    $vars->{ form_header       }  = WebGUI::Form::formHeader($session);
    $vars->{ form_header       } .= WebGUI::Form::hidden($session, {
        name => "op", 
        value => "sendPrivateMessageSave"
    });
    $vars->{ form_header       } .= WebGUI::Form::hidden($session, {
        name => "messageId", 
        value => $form->get("messageId") || "",
    });
    
    $vars->{ submit_button     }  = WebGUI::Form::submit($session,{});
    $vars->{ submit_label      }  = $i18n->get("private message submit label");
    $vars->{ form_footer       }  = WebGUI::Form::formFooter($session, {});
    
    
}

#-------------------------------------------------------------------

=head2 _status ( )

returns a hashref with internationalized values for message status.

=cut

sub _status {
	my $session = shift;
	my $i18n = WebGUI::International->new($session);
	return {
        "pending"   =>$i18n->get(552),
        "completed" =>$i18n->get(350),
        "unread"    =>$i18n->get("private message status unread"),
        "read"      =>$i18n->get("private message status read"),
        "replied"   =>$i18n->get("private message status replied"),
    };
}

#-------------------------------------------------------------------

=head2 www_sendPrivateMessage ( )

Form for sending private messages

=cut

sub www_sendPrivateMessage {
	my $session = shift;
	return $session->privilege->insufficient() unless ($session->user->isInGroup(2));   
	
    my $i18n     = WebGUI::International->new($session);
	my $form     = $session->form;
    my $user     = $session->user;
    my $style    = $session->style;
    my $settings = $session->setting;
    
    my $templateId = $settings->get("sendPrivateMessageTemplateId"); 
    my $uid        = $form->get("uid");
    my $userTo     = WebGUI::User->new($session,$uid);
    
    my $vars       = {};
    $vars->{title} = $i18n->get('private message title');
    
    if($uid eq "") {
        $vars->{'error_msg'} = $i18n->get('private message no user');
        return $style->userStyle(WebGUI::Asset::Template->new($session,$templateId)->process($vars));
        
    } 
    elsif($uid eq $user->userId) {
        $vars->{'error_msg'} = $i18n->get('private message no self error');
        return $style->userStyle(WebGUI::Asset::Template->new($session,$templateId)->process($vars));
    }
    
    unless($userTo->profileField("allowPrivateMessages")) {
        $vars->{'error_msg'} = $i18n->get('private message blocked error');
        return $style->userStyle(WebGUI::Asset::Template->new($session,$templateId)->process($vars));
    }
    
    _appendPrivateMessageForm($session,$vars,$userTo);
    
    $vars->{ accountOptions    }  = WebGUI::Operation::Shared::accountOptions($session);
    
   	return $style->userStyle(WebGUI::Asset::Template->new($session,$templateId)->process($vars));
}

#-------------------------------------------------------------------

=head2 www_sendPrivateMessageSave ( )

Post process the form, check for required fields, handle inviting users who are already
members (determined by email address) and send the email.

=cut

sub www_sendPrivateMessageSave {
	my $session = shift;
	return $session->privilege->insufficient() unless ($session->user->isInGroup(2));
    
    my $i18n     = WebGUI::International->new($session);
	my $form     = $session->form;
    my $user     = $session->user;
    my $style    = $session->style;
     
    my $uid        = $form->get("uid");
    my $userTo     = WebGUI::User->new($session,$uid);
    
    if($uid eq "") {
        my $output = sprintf qq|<h1>%s</h1>\n<p>%s</p><a href="%s">%s</a>|,
            $i18n->get('private message error'),
            $i18n->get('private message no user'),
            $session->url->getBackToSiteURL(),
            $i18n->get('493', 'WebGUI');
        return $style->userStyle($output);
    } elsif($uid eq $user->userId) {
        my $output = sprintf qq|<h1>%s</h1>\n<p>%s</p><a href="%s">%s</a>|,
            $i18n->get('private message error'),
            $i18n->get('private message no self error'),
            $session->url->getBackToSiteURL(),
            $i18n->get('493', 'WebGUI');
        return $style->userStyle($output);
    }
    
    my $isReply = 0;
    if($form->get("messageId")) {
        my $message = WebGUI::Inbox->new($session)->getMessage($form->get("messageId"));
        # Ensure that the user sending the message was sent by the user being replied to 
        # and that the user reponding is the user the message was sent to
        if($message->get("sentBy") eq $uid && $message->get("userId") eq $user->userId) {
            $isReply = 1;
            $message->setStatus("replied");
        }
    }
    
    unless($isReply || $userTo->profileField("allowPrivateMessages")) {
        my $output = sprintf qq|<h1>%s</h1>\n<p>%s</p><a href="%s">%s</a>|,
            $i18n->get('private message error'),
            $i18n->get('private message blocked error'),
            $session->url->getBackToSiteURL(),
            $i18n->get('493', 'WebGUI');
        return $style->userStyle($output);
    }
    
    
    WebGUI::Inbox->new($session)->addMessage({
	   message => $form->get("message"),
       subject => $form->get("subject"),
       userId  => $uid,
       status  => 'unread',
       sentBy  => $user->userId
    });
    

    my $output = sprintf qq!<p>%s</p><a href="%s">%s</a>!,
        $i18n->get('private message sent'),
        $session->url->getBackToSiteURL(),
        $i18n->get('493', 'WebGUI');
    return $session->style->userStyle($output);

}


#-------------------------------------------------------------------

=head2 www_viewInbox ( )

Templated display all messages for the current user.

=cut

sub www_viewInbox {
	my $session = shift;
	return $session->privilege->insufficient() unless ($session->user->isInGroup(2));
	
    my $i18n     = WebGUI::International->new($session);
	my $vars     = {};
	my @msg      = ();
    my $rpp      = 50;
    
    #Deal with page number
    my $pn       = $session->form->get("pn") || 1;
    my $pn_url   = "";
    $pn_url      = ";pn=$pn";
   	
    #Deal with sort order
    my $sortBy   = $session->form->get("sortBy");
    my $sort_url = "";
    $sort_url    = ";sortBy=$sortBy" if($sortBy);
     
    #Cache the base url
    my $inboxUrl =  $session->url->page('op=viewInbox');
     
    $vars->{ title           } = $i18n->get(159);
   	$vars->{'subject_label'  } = $i18n->get(351);
    $vars->{'subject_url'    } = $inboxUrl.$pn_url.";sortBy=subject";
   	
    $vars->{'status_label'   } = $i18n->get(553);
    $vars->{'status_url'     } = $inboxUrl.$pn_url.";sortBy=status";
    
    $vars->{'from_label'     } = $i18n->get("private message from label");
   	$vars->{'from_url'       } = $inboxUrl.$pn_url.";sortBy=sentBy";
    
    $vars->{'dateStamp_label'} = $i18n->get(352);
    $vars->{'dateStamp_url'  } = $inboxUrl.$pn_url.";sortBy=dateStamp";
    
    my $adminUser = WebGUI::User->new($session,3)->username;
  	my $messages  = WebGUI::Inbox->new($session)->getMessagesForUser($session->user,$rpp,$pn,$sortBy); 
   	foreach my $message (@$messages) {   
        my $hash = {};
        $hash->{ message_url  } = $session->url->page('op=viewInboxMessage;messageId='.$message->getId);
        $hash->{ subject      } = $message->get("subject");
        $hash->{ status_class } = $message->get("status");
        $hash->{ status       } = _status($session)->{$hash->{ status_class }};
        
        #Get the username of the person who sent the message
        my $sentBy = $message->get("sentBy");
        #Assume it's the admin user for speed purposes - admin user is cached above the loop
        my $from = $adminUser;
        #If it wasn't the admin user, get the username of the person who sent it
        if($sentBy ne "3") {
            my $u = WebGUI::User->new($session,$sentBy);
            #If the user that sent the message is valid, get the username 
            #This case would happen if the user was deleted after sending a private message
            if($u->userId ne "1") {
                $from = $u->username;    
            }
        } 
             
        $hash->{ from         } = $from;
	  	$hash->{ dateStamp    } = $session->datetime->epochToHuman($message->get("dateStamp"));
	  	push(@msg,$hash);
   	}
    my $msgCount = scalar(@{$messages});
    
    #Pagination has to exist on every page regardless if there are more messages or not.
    if($pn > 1 ) {
       $vars->{'prev_url'    } = $inboxUrl.';pn='.($pn-1).$sort_url;
       $vars->{'prev_label'  } = $i18n->get("private message prev label");
    }
    $vars->{'next_url'       } = $inboxUrl.';pn='.($pn+1).$sort_url;
    $vars->{'next_label'     } = $i18n->get("private message next label");
    
   	$vars->{'messages'      } = \@msg;
   	$vars->{'noresults'     } = $i18n->get(353) unless ($msgCount > 0);
   	$vars->{'accountOptions'} = WebGUI::Operation::Shared::accountOptions($session);
    my $templateId = $session->setting->get("viewInboxTemplateId");
   	return $session->style->userStyle(WebGUI::Asset::Template->new($session,$templateId)->process($vars));
}

#-------------------------------------------------------------------

=head2 www_viewInboxMessage ( )

Templated display of a single message for the user.

=cut

sub www_viewInboxMessage {
	my $session = shift;
	return $session->privilege->insufficient() unless ($session->user->isInGroup(2));
    
    #Get the message
    my $message = WebGUI::Inbox->new($session)->getMessage($session->form->param("messageId"));
    
    #Make sure users can only read their own messages
    my $userId  = $message->get("userId");
	my $groupId = $message->get("groupId");
    return $session->privilege->insufficient() unless (
      $session->user->userId eq $userId 
      || (defined $groupId && $session->user->isInGroup($groupId))
    );
    
	my $i18n = WebGUI::International->new($session);
	my $vars = {};
   	$vars->{ title      } = $i18n->get("private message reply title");
	$vars->{ from_label } = $i18n->get("private message from label");
    $vars->{ date_label } = $i18n->get("private message date label");
    
          
    if (defined $message) {
	   	my $origStatus = $message->get("status");
        $message->setStatus("read") if($origStatus eq "unread");
        $vars->{'message_subject'  } = $message->get("subject");
	   	$vars->{'dateStamp'} =$session->datetime->epochToHuman($message->get("dateStamp"));
   		$vars->{'status'   } = _status($session)->{$message->get("status")}; 
		$vars->{ message   } = $message->get("message");
   		unless ($vars->{message} =~ /\<a/ig) {
      			$vars->{message} =~ s/(http\S*)/\<a href=\"$1\"\>$1\<\/a\>/g;
   		}
   		unless ($vars->{message} =~ /\<div/ig || $vars->{message} =~ /\<br/ig || $vars->{message} =~ /\<p/ig) {
      			$vars->{message} =~ s/\n/\<br \/\>\n/g;
   		}
        
        #Get the username of the person who sent the message
        my $sentBy = $message->get("sentBy");
        #Assume it's the admin user who sent the message
        my $from = WebGUI::User->new($session,3)->username;
        #If the user actually exists, get the username
        if($sentBy ne "1" && $sentBy ne "3") {
            $from = WebGUI::User->new($session,$sentBy)->username;
        }
        
        $vars->{ from } = $from;
        
        
        #If the person didn't send the message to themselves (for admin only) and the user still exsists (check visitor case)
        if($sentBy ne $session->user->userId && 
           $sentBy ne "1" &&
           $origStatus ne "pending" &&
           $origStatus ne "completed") {
            my $u = WebGUI::User->new($session,$sentBy);
            $vars->{'canReply'} = "true";
            _appendPrivateMessageForm($session,$vars,$u,$message);
        } 
        
	}
   	$vars->{'accountOptions'} = WebGUI::Operation::Shared::accountOptions($session);
   	my $templateId = $session->setting->get("viewInboxMessageTemplateId");
    return $session->style->userStyle(WebGUI::Asset::Template->new($session,$templateId)->process($vars));
}

1;
