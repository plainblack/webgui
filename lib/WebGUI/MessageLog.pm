package WebGUI::MessageLog;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2002 Plain Black LLC.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut


use strict;
use Tie::CPHash;
use WebGUI::International;
use WebGUI::Macro;
use WebGUI::Mail;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::User;
use WebGUI::Utility;


=head1 NAME

 Package WebGUI::MessageLog

=head1 SYNOPSIS

 use WebGUI::MessageLog;
 WebGUI::MessageLog::addEntry($userId, $groupId,$subject,$message);
 WebGUI::MessageLog::addInternationalizedEntry($userId,$groupId,$url,$internationalId);
 WebGUI::MessageLog::completeEntry($messageLogId);

=head1 DESCRIPTION

 This package is WebGUI's notification system.

=head1 METHODS

 These functions are available from this package:

=cut


#-------------------------------------------------------------------
sub _notify {
	my ($u, $message, $subject);
	$u = $_[0];
	$subject = $_[1];
	$message = $_[2];
        if ($u->profileField("INBOXNotifications") eq "email") {
        	if ($u->profileField("email") ne "") {
                	WebGUI::Mail::send($u->profileField("email"),$subject,$message);
                }
        } elsif ($u->profileField("INBOXNotifications") eq "emailToPager") {
                if ($u->profileField("emailToPagerGateway") ne "") {
                        WebGUI::Mail::send($u->profileField("emailToPagerGateway"),$subject,$message);
                }
        } elsif ($u->profileField("INBOXNotifications") eq "icq") {
                if ($u->profileField("icq")) {
                        WebGUI::Mail::send($u->profileField("icq").'@pager.icq.com',$subject,$message);
                }
        }
}

#-------------------------------------------------------------------

=head2 addEntry ( userId, groupId, subject, message [ , url, status ] )

 Adds an entry to the message log and sends out notification to users.

=item userId

 The id of the user that should receive this notification.

 NOTE: This can be left blank if you're specifying a groupId.

=item groupId

 The id of the group that should receive this notification.

 NOTE: This can be left blank if you're specifying a userId.

=item subject

 The subject of the notification.

=item message

 The content of the notification.

=item url

 The URL of any action that should be taken based upon this
 notification (if any).

=item status

 Defaults to 'notice'. Can be 'pending', 'notice', or 'completed'.

=cut

sub addEntry {
        my ($u, @users, $messageLogId, $sth, $userId, $groupId, $subject, $message, $url, $status, $user);
	$messageLogId = getNextId("messageLogId");
	$userId = $_[0];
	$groupId = $_[1];
	$subject = $_[2];
	$message = $_[3];
	$url = $_[4];
	$status = $_[5];
	if ($groupId ne "") {
		@users = WebGUI::SQL->buildArray("select userId from groupings where groupId=$groupId");
	}
	@users = ($userId,@users) if ($userId ne "" && !isIn($userId, @users));
	foreach $user (@users) {
		$u = WebGUI::User->new($user);
		if ($u->userId ne "") {
			WebGUI::SQL->write("insert into messageLog values ($messageLogId,".$u->userId.",
				".quote($message).",".quote($url).",".time().",".quote($subject).", ".quote($status).")");
			if ($url ne "") {
				$message .= "\n".WebGUI::URL::append('http://'.$session{env}{HTTP_HOST}.$url,'mlog='.$messageLogId);
			}
			_notify($u,$subject,$message);
		}
	}
}

#-------------------------------------------------------------------

=head2 addInternationalizedEntry ( userId, groupId, url, internationalId [ , namespace, status ] )

 Adds an entry to the message log using a translated message from
 the internationalization system and sends out notifications to users.

=item userId

 The id of the user that should receive this notification.

 NOTE: This can be left blank if you're specifying a groupId.

=item groupId

 The id of the group that should receive this notification.

 NOTE: This can be left blank if you're specifying a userId.

=item url

 The URL of any action that should be taken based upon this
 notification (if any).

=item internationalId

 The unique identifier from the internationalization system of the message to send.

=item namespace

 The namespace from the internationalization system of the message to send. Defaults to "WebGUI";

=item status

 Defaults to 'notice'. Can be 'pending', 'notice', or 'completed'.

=cut

sub addInternationalizedEntry {
        my ($u, $userId, $url, $groupId, $internationalId, @users, $messageLogId,$sth, $user, %message, %subject, $message, $subject, $namespace, $status);
        $messageLogId = getNextId("messageLogId");
	$userId = $_[0];
	$groupId = $_[1];
	$url = $_[2];
	$internationalId = $_[3];
        $namespace = $_[4] || "WebGUI";
	$status = $_[5] || 'notice';
        %message = WebGUI::SQL->buildHash("select languageId,message from international where internationalId=$internationalId and namespace='$namespace'");
        %subject = WebGUI::SQL->buildHash("select languageId,message from international where internationalId=523 and namespace='WebGUI'");
        if ($groupId ne "") {
                @users = WebGUI::SQL->buildArray("select userId from groupings where groupId=$groupId");
        }
	@users = ($userId,@users) if ($userId ne "" && !isIn($userId, @users));
        foreach $user (@users) {
                $u = WebGUI::User->new($user);
                if ($u->userId ne "") {
                        $subject{$u->profileField("language")} = $subject{1} if ($subject{$u->profileField("language")} eq "");
                        $subject = $subject{$u->profileField("language")};
                        $message{$u->profileField("language")} = $message{1} if ($message{$u->profileField("language")} eq "");
                        $message = WebGUI::Macro::process($message{$u->profileField("language")});
                        WebGUI::SQL->write("insert into messageLog values ($messageLogId,".$u->userId.",
                                ".quote($message).",".quote($url).",".time().",".quote($message).",".quote($status).")");
                        if ($url ne "") {
                                $message .= "\n".WebGUI::URL::append('http://'.$session{env}{HTTP_HOST}.$url,'mlog='.$messageLogId);
                        }
			_notify($u,$subject,$message);
                }
        }
}

#-------------------------------------------------------------------

=head2 completeEntry ( messageLogId )

 Set a message log entry to complete.

=item messageLogId

 The id of the message to complete.

=cut

sub completeEntry {
	WebGUI::SQL->write("update messageLog set status='completed', dateOfEntry=".time()." where messageLogId='$_[0]'");
}


1;
