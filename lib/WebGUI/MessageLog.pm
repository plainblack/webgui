package WebGUI::MessageLog;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2005 Plain Black Corporation.
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
use WebGUI::DateTime;
use WebGUI::Id;
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

=head1 DESCRIPTION

This package is WebGUI's notification system.

=head1 SYNOPSIS

 use WebGUI::MessageLog;
 WebGUI::MessageLog::addEntry($userId, $groupId,$subject,$message);
 WebGUI::MessageLog::addInternationalizedEntry($userId,$groupId,$url,$internationalId);
 WebGUI::MessageLog::completeEntry($messageLogId);

=head1 METHODS

These functions are available from this package:

=cut


#-------------------------------------------------------------------
sub _notify {
	my ($u, $message, $subject, $from);
	$u = $_[0];
	$subject = $_[1];
	$message = $_[2];
	$from = $_[3];
        if ($u->profileField("INBOXNotifications") eq "email") {
        	if ($u->profileField("email") ne "") {
                	WebGUI::Mail::send($u->profileField("email"),$subject,$message, "", $from);
                }
        } elsif ($u->profileField("INBOXNotifications") eq "emailToPager") {
                if ($u->profileField("emailToPagerGateway") ne "") {
                        WebGUI::Mail::send($u->profileField("emailToPagerGateway"),$subject,$message, "", $from);
                }
        } elsif ($u->profileField("INBOXNotifications") eq "icq") {
                if ($u->profileField("icq")) {
                        WebGUI::Mail::send($u->profileField("icq").'@pager.icq.com',$subject,$message, "", $from);
                }
        }
}

#-------------------------------------------------------------------

=head2 addEntry ( userId, groupId, subject, message [ , url, status, from ] )

Adds an entry to the message log and sends out notification to users.

=head3 userId

The id of the user that should receive this notification.

B<NOTE:> This can be left blank if you're specifying a groupId.

=head3 groupId

The id of the group that should receive this notification.

B<NOTE:> This can be left blank if you're specifying a userId.

=head3 subject

The subject of the notification.

=head3 message

The content of the notification.

=head3 url

The URL of any action that should be taken based upon this notification (if any).

=head3 status

Defaults to 'notice'. Can be 'pending', 'notice', or 'completed'.

=head3 from

The addressee email address. Defaults to company email.

=cut

sub addEntry {
        my ($u, @users, $messageLogId, $sth, $userId, $groupId, $subject, $message, $url, $status, $user, $from);
	$messageLogId = WebGUI::Id::generate();
	$userId = $_[0];
	$groupId = $_[1];
	$subject = $_[2];
	$message = $_[3];
	$url = $_[4];
	if ($url  && !$url =~ /^http/) {
		$url = WebGUI::URL::getSiteURL().$url;
	}
	if ($url && !($url =~ /func=/ || $url =~ /op=/)) {
                $url = WebGUI::URL::append($url, "op=viewMessageLogMessage");
        }
	$status = $_[5];
	$from = $_[6];
	if ($groupId ne "") {
		@users = WebGUI::SQL->buildArray("select userId from groupings where groupId=".quote($groupId));
	}
	@users = ($userId,@users) if ($userId ne "" && !isIn($userId, @users));
	foreach $user (@users) {
		$u = WebGUI::User->new($user);
		if ($u->userId ne "") {
			WebGUI::SQL->write("insert into messageLog (messageLogId, userId, message, url, dateOfEntry,
				subject, status) values (".quote($messageLogId).",".quote($u->userId).",
				".quote($message).",".quote($url).",".time().",".quote($subject).", ".quote($status).")");
			if ($url ne "") {
				$message .= "\n".WebGUI::URL::append($url,'mlog='.$messageLogId);
			}
			_notify($u,$subject,$message,$from);
		}
	}
}

#-------------------------------------------------------------------

=head2 addInternationalizedEntry ( userId, groupId, url, internationalId [ , namespace, status ] )

Adds an entry to the message log using a translated message from the internationalization system and sends out notifications to users.

=head3 userId

The id of the user that should receive this notification.

B<NOTE:> This can be left blank if you're specifying a groupId.

=head3 groupId

The id of the group that should receive this notification.

B<NOTE:> This can be left blank if you're specifying a userId.

=head3 url

The URL of any action that should be taken based upon this notification (if any).

=head3 internationalId

The unique identifier from the internationalization system of the message to send.

=head3 namespace

The namespace from the internationalization system of the message to send. Defaults to "WebGUI";

=head3 status

Defaults to 'notice'. Can be 'pending', 'notice', or 'completed'.

=cut

sub addInternationalizedEntry {
        my ($u, $userId, $url, $groupId, $internationalId, @users, $messageLogId,$sth, $user, %message, %subject, $message, $subject, $namespace, $status);
        $messageLogId = WebGUI::Id::generate();
	$userId = $_[0];
	$groupId = $_[1];
	$url = $_[2];
	if ($url  && !$url =~ /^http/) {
		$url = WebGUI::URL::getSiteURL().$url;
	}
	if  ($url && !($url =~ /func=/ || $url =~ /op=/)) {
                $url = WebGUI::URL::append($url, "op=viewMessageLogMessage");
        }
	$internationalId = $_[3];
        $namespace = $_[4] || "WebGUI";
	$status = $_[5] || 'notice';
	my $languages = WebGUI::International::getLanguages();
	foreach my $language (keys %{$languages}) {
		$message{$language} = WebGUI::International::get($internationalId,$namespace,$language);
		$subject{$language} = WebGUI::International::get(523,"WebGUI",$language);
	}
        if ($groupId ne "") {
                @users = WebGUI::SQL->buildArray("select userId from groupings where groupId=".quote($groupId));
        }
	@users = ($userId,@users) if ($userId ne "" && !isIn($userId, @users));
        foreach $user (@users) {
                $u = WebGUI::User->new($user);
                if ($u->userId ne "") {
                        $subject{$u->profileField("language")} = $subject{1} if ($subject{$u->profileField("language")} eq "");
                        $subject = $subject{$u->profileField("language")};
                        $message{$u->profileField("language")} = $message{1} if ($message{$u->profileField("language")} eq "");
			$message = $message{$u->profileField("language")};
                        WebGUI::Macro::process(\$message);
                        WebGUI::SQL->write("insert into messageLog values (".quote($messageLogId).",".quote($u->userId).",
                                ".quote($message).",".quote($url).",".time().",".quote($message).",".quote($status).")");
                        if ($url ne "") {
                                $message .= "\n".WebGUI::URL::append($url,'mlog='.$messageLogId);
                        }
			_notify($u,$subject,$message);
                }
        }
}

#-------------------------------------------------------------------

=head2 completeEntry ( messageLogId )

Set a message log entry to complete.

=head3 messageLogId

The id of the message to complete.

=cut

sub completeEntry {
	WebGUI::SQL->write("update messageLog set status='completed', dateOfEntry=".time()." where messageLogId=".quote($_[0]));
}


1;
