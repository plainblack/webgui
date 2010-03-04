package WebGUI::Account::Friends;

use strict;

use WebGUI::Exception;
use WebGUI::International;
use WebGUI::Pluggable;
use Tie::IxHash;
use base qw/WebGUI::Account/;

=head1 NAME

Package WebGUI::Account::Friends

=head1 DESCRIPTION

This is the class which is used to display a users's friends

=head1 SYNOPSIS

 use WebGUI::Account::Friends;

=head1 METHODS

These subroutines are available from this package:

=cut

#-------------------------------------------------------------------

=head2 appendCommonVars ( var )

Appends common template variables that all inbox templates use

=head3 var

The hash reference to append template variables to

=cut

sub appendCommonVars {
    my $self    = shift;
    my $var     = shift;
    my $session = $self->session;
    my $user    = $session->user;
    my $pageUrl = $session->url->page;

    $self->SUPER::appendCommonVars($var);

    $var->{'is_edit'         } = $self->uid eq "";
    $var->{'can_edit_friends'} = ($self->uid eq "" || $self->uid eq $session->user->userId);
    $var->{'edit_friends_url'} = $self->getUrl("module=friends;do=view");
    $var->{'view_friends_url'} = $self->getUrl("module=friends;do=view;uid=".$session->user->userId);
}

#-------------------------------------------------------------------

=head2 canView ( )

Whether or not the current user can view this user's friends

=cut

sub canView {
    my $self    = shift;
    my $session = $self->session;
    my $uid     = $self->uid;

    return 1 if (($session->user->userId eq $uid || $uid eq "") && $session->user->profileField('ableToBeFriend'));
    
    my $user    = WebGUI::User->new($session,$uid);
    return 0 if($user->isVisitor); #This should never happen but let's make sure
    return 0 unless ($user->profileField('ableToBeFriend'));  #User doesn't have friends enabled
    return WebGUI::User->new($session,$uid)->profileIsViewable($session->user);  #User's profile isn't viewable by this user
}

#-------------------------------------------------------------------

=head2 editSettingsForm ( )

Creates form elements for user settings page custom to this account module

=cut

sub editSettingsForm {
    my $self    = shift;
    my $session = $self->session;
    my $i18n    = WebGUI::International->new($session,'Account_Friends');
    my $f       = WebGUI::HTMLForm->new($session);

    $f->template(
		name      => "friendsStyleTemplateId",
		value     => $self->getStyleTemplateId,
		namespace => "style",
		label     => $i18n->get("friends style template label"),
        hoverHelp => $i18n->get("friends style template hoverHelp")
	);
	$f->template(
		name      => "friendsLayoutTemplateId",
		value     => $self->getLayoutTemplateId,
		namespace => "Account/Layout",
		label     => $i18n->get("friends layout template label"),
        hoverHelp => $i18n->get("friends layout template hoverHelp")
	);
	$f->template(
        name      => "friendsViewTemplateId",
        value     => $self->getViewTemplateId,
        namespace => "Account/Friends/View",
        label     => $i18n->get("friends view template label"),
        hoverHelp => $i18n->get("friends view template hoverHelp")
	);
    $f->template(
        name      => "friendsEditTemplateId",
        value     => $self->getEditTemplateId,
        namespace => "Account/Friends/Edit",
        label     => $i18n->get("friends edit template label"),
        hoverHelp => $i18n->get("friends edit template hoverHelp")
	);
    $f->template(
        name      => "friendsSendRequestTemplateId",
        value     => $self->getSendRequestTemplateId,
        namespace => "Account/Friends/SendRequest",
        label     => $i18n->get("friends send request template label"),
        hoverHelp => $i18n->get("friends send request template hoverHelp")
	);

    $f->template(
        name      => "friendsErrorTemplateId",
        value     => $self->getErrorTemplateId,
        namespace => "Account/Friends/Error",
        label     => $i18n->get("friends error template label"),
        hoverHelp => $i18n->get("friends error template hoverHelp")
	);

    $f->template(
        name      => "friendsConfirmTemplateId",
        value     => $self->getConfirmTemplateId,
        namespace => "Account/Friends/Confirm",
        label     => $i18n->get("friends confirm template label"),
        hoverHelp => $i18n->get("friends confirm template hoverHelp")
	);

    $f->template(
        name      => "friendsRemoveConfirmTemplateId",
        value     => $self->getRemoveConfirmTemplateId,
        namespace => "Account/Friends/Confirm",
        label     => $i18n->get("friends remove confirm template label"),
        hoverHelp => $i18n->get("friends remove confirm template hoverHelp")
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

    $setting->set("friendsStyleTemplateId", $form->process("friendsStyleTemplateId","template"));
    $setting->set("friendsLayoutTemplateId", $form->process("friendsLayoutTemplateId","template"));
    $setting->set("friendsViewTemplateId", $form->process("friendsViewTemplateId","template"));
    $setting->set("friendsEditTemplateId",$form->process("friendsEditTemplateId","template"));
    $setting->set("friendsSendRequestTemplateId",$form->process("friendsSendRequestTemplateId","template"));
    $setting->set("friendsErrorTemplateId",$form->process("friendsErrorTemplateId","template"));
    $setting->set("friendsConfirmTemplateId",$form->process("friendsConfirmTemplateId","template"));
    $setting->set("friendsRemoveConfirmTemplateId",$form->process("friendsRemoveConfirmTemplateId","template"));

}

#-------------------------------------------------------------------

=head2 getConfirmTemplateId ( )

This method returns the template ID for the confirmation screen.

=cut

sub getConfirmTemplateId {
    my $self = shift;
    return $self->session->setting->get("friendsConfirmTemplateId") || "K8F0j_cq_jgo8dvWY_26Ag";
}


#-------------------------------------------------------------------

=head2 getEditTemplateId ( )

This method returns the template ID for editing friends.

=cut

sub getEditTemplateId {
    my $self = shift;
    return $self->session->setting->get("friendsEditTemplateId") || "AZFU33p0jpPJ-E6qLSWZng";
}

#-------------------------------------------------------------------

=head2 getErrorTemplateId ( )

This method returns the template ID for displaying errors.

=cut

sub getErrorTemplateId {
    my $self = shift;
    return $self->session->setting->get("friendsErrorTemplateId") || "7Ijdd8SW32lVgg2H8R-Aqw";
}

#-------------------------------------------------------------------

=head2 getLayoutTemplateId ( )

This method returns the template ID for the account layout.

=cut

sub getLayoutTemplateId {
    my $self = shift;
    return $self->session->setting->get("friendsLayoutTemplateId") || "zrNpGbT3odfIkg6nFSUy8Q";
}


#-------------------------------------------------------------------

=head2 getRemoveConfirmTemplateId ( )

This method returns the template ID for the confirmation screen.

=cut

sub getRemoveConfirmTemplateId {
    my $self = shift;
    return $self->session->setting->get("friendsRemoveConfirmTemplateId") || "G5V6neXIDiFXN05oL-U3AQ";
}


#-------------------------------------------------------------------

=head2 getSendRequestTemplateId ( )

This method returns the template ID for the send request page.

=cut

sub getSendRequestTemplateId {
    my $self = shift;
    return $self->session->setting->get("friendsSendRequestTemplateId") || "AGJBGviWGAwjnwziiPjvDg";
}

#-------------------------------------------------------------------

=head2 getStyleTemplateId ( )

This method returns the template ID for the main style.

=cut

sub getStyleTemplateId {
    my $self = shift;
    return $self->session->setting->get("friendsStyleTemplateId") || $self->SUPER::getStyleTemplateId;
}

#-------------------------------------------------------------------

=head2 getViewTemplateId ( )

This method returns the template ID for the main view.

=cut

sub getViewTemplateId {
    my $self = shift;
    return $self->session->setting->get("friendsViewTemplateId") || "1Yn_zE_dSiNuaBGNLPbxtw";
}


#-------------------------------------------------------------------

=head2 www_removeFriend ( )

This is a confirmation page of whether or not the user wishes to remove the selected user from friend 

=cut

sub www_removeFriend {
    my $self     = shift;
    my $session  = $self->session;
    my $friendId = $session->form->get("friendId");
    my $var      = {};

    $self->appendCommonVars($var);
    my $friend   = WebGUI::Friends->new($session);

    my $errorMsg = "";
    if (!$friendId) {
        my $i18n = WebGUI::International->new($session,"Account_Friends");
        $errorMsg = $i18n->get("no friend selected");
    }
    elsif(!$friend->isFriend($friendId)){
        my $i18n = WebGUI::International->new($session,"Account_Friends");
        $errorMsg = $i18n->get("not a friend error");
    }
    
    if($errorMsg ne "") {
        my $backUrl = $self->getUrl("module=friends");
        return $self->showError($var,$errorMsg,$backUrl,$self->getErrorTemplateId);
    }

    my $user = WebGUI::User->new($session,$friendId);
    $var->{'user_full_name'} = $user->getWholeName;

    $var->{'yes_url'       } = $self->getUrl("module=friends;do=removeFriendConfirm;friendId=".$friendId);
    $var->{'no_url'        } = $self->getUrl("module=friends");

    return $self->processTemplate($var,$self->getRemoveConfirmTemplateId);
}


#-------------------------------------------------------------------

=head2 www_removeFriendConfirm ( )

This is a confirmation page of whether or not the user wishes to remove the selected user from friend 

=cut

sub www_removeFriendConfirm {
    my $self     = shift;
    my $session  = $self->session;
    my $friendId = $session->form->get("friendId");
    my $var      = {};
    my $i18n     = WebGUI::International->new($session,"Account_Friends");


    $self->appendCommonVars($var);
    my $friend   = WebGUI::Friends->new($session);

    my $errorMsg = "";
    if (!$friendId) {
        $errorMsg = $i18n->get("no friend selected");
    }
    elsif(!$friend->isFriend($friendId)){
        $errorMsg = $i18n->get("not a friend error");
    }
    
    if($errorMsg ne "") {
        my $backUrl = $self->getUrl("module=friends");
        return $self->showError($var,$errorMsg,$backUrl,$self->getErrorTemplateId);
    }

    my $user = WebGUI::User->new($session,$friendId);
    my $msg  = sprintf($i18n->get("friend removed"),$user->getWholeName);

    $friend->delete([$friendId]);

    return $self->www_view($msg);

}

#-------------------------------------------------------------------

=head2 www_sendFriendsRequest ( )

The page which allows users to submit friends requests.

=cut

sub www_sendFriendsRequest {
    my $self     = shift;
    my $session  = $self->session;
    my $var      = {};
    my $uid      = $self->uid;

    my $user     = WebGUI::User->new($session,$uid);
    my $i18n     = WebGUI::International->new($session,'Account_Friends');

    unless ($user->acceptsFriendsRequests($session->user)) {
        my $errorMsg = $i18n->get('does not want to be a friend');
        my $friend   = WebGUI::Friends->new($session);
        if($friend->isFriend($uid)) {
            $errorMsg = $i18n->get("error user is already friend");
        }
        elsif($friend->isInvited($uid)) {
            $errorMsg = $i18n->get("error user is already invited");
        }
        return $self->showError($var,$errorMsg,$session->user->getProfileUrl,$self->getErrorTemplateId);
    }

    $self->appendCommonVars($var);

    #Overwrite these
    $var->{'user_full_name'    } = $user->getWholeName;
    $var->{'user_member_since' } = $user->dateCreated;
    
    my $defaultComment = sprintf(
        $i18n->get('default friend comments'),
        $user->getFirstName,
        $session->user->getFirstName
    );
    $var->{'form_message_text'}  = WebGUI::Form::textarea($session, {
        name   =>"message",
        value  =>$defaultComment,
        width  =>600,
        height =>200
    });

    $var->{'form_message_rich'}  = WebGUI::Form::HTMLArea($session, {
        name  => "message",
        value => $defaultComment,
        width => "600",
    });
    
    $var->{'form_header'      }  = WebGUI::Form::formHeader($session,{
        action => $self->getUrl("module=friends;do=sendFriendsRequestSave;uid=$uid"),
        extras => q{name="messageForm"}
    });
    
    $var->{'submit_button'    }  = WebGUI::Form::submit($session,{});
    $var->{'form_footer'      }  = WebGUI::Form::formFooter($session, {});

    $var->{'cancel_url'       }  = $user->getProfileUrl;

    return $self->processTemplate($var,$self->getSendRequestTemplateId);
}


#-------------------------------------------------------------------

=head2 www_sendFriendsRequestSave ( )

This method allows users to save friends requests

=cut

sub www_sendFriendsRequestSave {
    my $self     = shift;
    my $session  = $self->session;
    my $var      = {};
    my $uid      = $self->uid;

    my $user     = WebGUI::User->new($session,$uid);

    #Errors fall through to the view page.
    unless ($user->acceptsFriendsRequests($session->user)) {
        return $self->www_sendFriendsRequest;
    }

    my $inboxUrl = WebGUI::Account::Inbox->getViewInvitationUrl($session);
    my $friends  = WebGUI::Friends->new($session);
    $friends->sendAddRequest($uid, $session->form->get('message'),$inboxUrl);

    $self->appendCommonVars($var);

    #Overwrite this
    $var->{'user_full_name'    } = $user->getWholeName;
    $var->{'user_profile_url'  } = $user->getProfileUrl;

    return $self->processTemplate($var,$self->getConfirmTemplateId);

}

#-------------------------------------------------------------------

=head2 www_view ( )

The main view page for editing your friends.

=cut

sub www_view {
    my $self     = shift;
    my $msg      = shift;
    my $session  = $self->session;
    my $var      = {};

    my $uid      = $self->uid;
    my $user     = $self->getUser;

    $self->appendCommonVars($var);
    
    my $displayView           = $uid ne "";
    $var->{'display_message'} = $msg;

    unless ($user->profileField('ableToBeFriend') && $user->profileIsViewable($session->user)) {
        my $i18n = WebGUI::International->new($session,"Account_Friends");
        my $errorMsg = "";
        if($var->{'can_edit'}) {
            $errorMsg = $i18n->get("friends is off");
        }
        else {
            $errorMsg = $i18n->get("no access");
        }
        my $backUrl = $self->getUrl("op=account");
        return $self->showError($var,$errorMsg,$backUrl,$self->getErrorTemplateId);
    }

    #Deal with rows per page
    my $rpp          = $session->form->get("rpp") || 25;
    my $rpp_url      = ";rpp=$rpp";
    
    #Cache the base url
    my $friendsUrl     =  $self->getUrl("op=account;module=friends;do=view");

    #Note for anyone who attempts to sort this list by the user's whole name:
    #You can do this, but the only way to do it efficiently is to join
    #the users, userProfileData, and groupings table.  This will break if the groups API
    #changes in WebGUI 8, so we decided to leave it sorted by username only.

    #Create the paginator
    my $friends   = $user->friends->getUserList(1);
    my @friendIds = keys %{$friends};
    my $p       = WebGUI::Paginator->new(
        $session,
        $friendsUrl.$rpp_url,
        $rpp
    );
    $p->setDataByArrayRef(\@friendIds);
    
    #Export page to template
    my @friends            = ();
    foreach my $friendId ( @{$p->getPageData} ) {
        my $friend   = WebGUI::User->new($session,$friendId);
        next if($friend->isVisitor);
        #If you have friends turned off you shouldn't show up when other people view your friends friends
        next if($displayView && !$friend->profileField('ableToBeFriend'));
        
        my $hash     = {};
        # TODO Move this into a sub that can be more easily overridden
        $hash->{'friend_full_name'         } = $friend->getWholeName;
        $hash->{'isViewable'               } = $friend->profileIsViewable;
        $hash->{'friend_id'                } = $friendId;
        $hash->{'friend_member_since'      } = $friend->dateCreated;
        $hash->{'friend_member_since_human'} = $session->datetime->epochToHuman($friend->dateCreated);
        $hash->{'friend_isOnline'          } = $friend->isOnline;
        if($hash->{'isViewable'}) {
            $hash->{'friend_profile_url'} = $friend->getProfileUrl;
            if($friend->profileField("photo")) {
                my $store = WebGUI::Storage->get($session,$friend->profileField("photo"));
                my $file  = $store->getFiles->[0];
                $hash->{'friend_photo_url'      } = $store->getUrl($file);
                $hash->{'friend_photo_url_thumb'} = $store->getThumbnailUrl($file);
            }
        }

        $hash->{'acceptsPrivateMessages'} = $friend->acceptsPrivateMessages($session->user->userId);
        if ($displayView) {
            if($friend->acceptsFriendsRequests($session->user)) {
                $hash->{'friend_request_url'} = $self->getUrl("module=friends;do=sendFriendsRequest;uid=".$friend->userId);
            }
        }
        else {
            $hash->{'remove_url'} = $self->getUrl("module=friends;do=removeFriend;friendId=".$friend->userId);
        }
        push(@friends,$hash);
   	}
    my $friendCount  = $p->getRowCount;
         
   	$var->{'friends_loop'  } = \@friends;
    $var->{'has_friends'   } = $friendCount > 0;
    $var->{'friends_total' } = $friendCount;

    tie my %rpps, "Tie::IxHash";
    %rpps = (25 => "25", 50 => "50", 100=>"100");
    $var->{'message_rpp'  } = WebGUI::Form::selectBox($session,{
        name    =>"rpp",
        options => \%rpps,
        value   => $session->form->get("rpp") || 25,
        extras  => q{onchange="location.href='}.$friendsUrl.q{;rpp='+this.options[this.selectedIndex].value"}
    });

    my $templateId = ($displayView) ? $self->getViewTemplateId : $self->getEditTemplateId;
    return $self->processTemplate($var,$templateId);
}

1;
