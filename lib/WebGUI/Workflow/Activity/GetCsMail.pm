package WebGUI::Workflow::Activity::GetCsMail;


=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2006 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use base 'WebGUI::Workflow::Activity';
use WebGUI::Mail::Get;
use WebGUI::Mail::Send;
use WebGUI::Asset;
use WebGUI::International;
use WebGUI::User;

=head1 NAME

Package WebGUI::Workflow::Activity::GetCsMail

=head1 DESCRIPTION

Retrieve the incoming mail messages for a Collaboration System.

=head1 SYNOPSIS

See WebGUI::Workflow::Activity for details on how to use any activity.

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 addPost ( parent, class, message, user, prefix ) 

Adds a post to this collaboration system.

=head3 parent

Either a collaboration system object reference, or a thread/post object reference.

=head3 message

The message retrieved from WebGUI::Mail::Get.

=head3 user

The user doing the posting.

=head3 prefix

The mail prefix for this collaboration system.

=cut

sub addPost {
	my $self = shift;
	my $parent = shift;
	my $message = shift;
	my $user = shift;
	my $prefix = shift;
	my @attachments = ();
	my $content = "";
	my $class = (ref $parent eq "WebGUI::Asset::Wobject::Collaboration") ? "WebGUI::Asset::Post::Thread" : "WebGUI::Asset::Post";
	foreach my $part (@{$message->{parts}}) {
		if (($part->{type} eq "text/plain" || $part->{type} eq "text/html") && $part->{filename} eq "") {
			my $text = $part->{content};
			if ($part->{type} eq "text/plain") {
				$text =~ s/\n/\<br \/\>/g;
			}
			$content .= $text;
		} else {
			push(@attachments, $part);
		}
	}
	$prefix =~ s/\\/\\\\/g;
	$prefix =~ s/\[/\\[/g;
	$prefix =~ s/\]/\\]/g;
	$prefix =~ s/\(/\\(/g;
	$prefix =~ s/\)/\\)/g;
	$prefix =~ s/\}/\\}/g;
	$prefix =~ s/\{/\\{/g;
	$prefix =~ s/\?/\\?/g;
	$prefix =~ s/\./\\./g;
	$prefix =~ s/\*/\\*/g;
	$prefix =~ s/\+/\\+/g;
	$prefix =~ s/\|/\\|/g;
	$prefix =~ s/\//\\\//g;
	my $title = $message->{subject};
	$title =~ s/$prefix//;
	my $post = $parent->addChild({
		className=>$class,
		title=>$title,
		menuTitle =>$title,
		url=>$title,
		content=>$content,
		ownerUserId=>$user->userId,
		username=>$user->profileField("alias") || $user->username,
		});
	if (scalar(@attachments)) {
		my $storage = $post->getStorageLocation;
		foreach my $file (@attachments) {
			my $filename = $file->{filename};
			unless ($filename) {
				$file->{type} =~ m/\/(.*)/;
				my $type = $1;
				$filename = $self->session->id->generate.".".$type;
			}	
			$storage->addFileFromScalar($filename, $file->{content});
		}
	}
	$post->postProcess;
	$post->requestCommit;
}

#-------------------------------------------------------------------

=head2 definition ( session, definition )

See WebGUI::Workflow::Activity::defintion() for details.

=cut 

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift;
	my $i18n = WebGUI::International->new($session, "Asset_Collaboration");
	push(@{$definition}, {
		name=>$i18n->get("get cs mail"),
		properties=> { }
		});
	return $class->SUPER::definition($session,$definition);
}


#-------------------------------------------------------------------

=head2 execute (  )

See WebGUI::Workflow::Activity::execute() for details.

=cut

sub execute {
	my $self = shift;
	my $cs = shift;
	return $self->COMPLETE unless ($cs->get("getMail"));
	my $start = time();
	my $mail = WebGUI::Mail::Get->connect($self->session,{
		server=>$cs->get("mailServer"),
		account=>$cs->get("mailAccount"),
		password=>$cs->get("mailPassword")
		});
	return $self->COMPLETE unless (defined $mail);
	my $i18n = WebGUI::International->new($self->session, "Asset_Collaboration");
	while (my $message = $mail->getNextMessage) {
		next unless (scalar(@{$message->{parts}})); # no content, skip it
		my $from = $message->{from};
		$from =~ /<(\S+\@\S+)>/;
		$from = $1 || $from;
		$from =~ /(\S+\@\S+)/;	
		my $user = WebGUI::User->newByEmail($self->session, $from);
		unless (defined $user) {
			my $send = WebGUI::Mail::Send->create($self->session, {
				to=>$message->{from},
				inReplyTo=>$message->{messageId},
				subject=>$cs->get("mailPrefix").$i18n->get("rejected")." ".$self->{subject},
				from=>$cs->get("mailAddress")
				});
			$send->addText($i18n->get("rejected because no user account"));
			$send->send;
			next;
		}
		my $post = undef;
		if ($message->{inReplyTo}) {
			$message->{inReplyTo} =~ m/cs\-([\w_-]{22})/;
			my $id = $1;	
			$post = WebGUI::Asset->newByDynamicClass($self->session, $id);
		}
		if (defined $post && $cs->get("allowReplies") && $user->isInGroup($cs->get("postGroupId")) && ($user->isInGroup($cs->get("subscriptionGroupId")) || $user->isInGroup($post->get("subscriptionGroupId")))) {
			$self->addPost($post, $message, $user, $cs->get("mailPrefix"));
		} elsif ($user->isInGroup($cs->get("postGroupId")) && $user->isInGroup($cs->get("subscriptionGroupId"))) {
			$self->addPost($cs, $message, $user, $cs->get("mailPrefix"));
		} else {
			my $send = WebGUI::Mail::Send->create($self->session, {
				to=>$message->{from},
				inReplyTo=>$message->{messageId},
				subject=>$cs->get("mailPrefix").$i18n->get("rejected")." ".$self->{subject},
				from=>$cs->get("mailAddress")
				});
			$send->addText($i18n->get("rejected because not allowed"));
			$send->send;
		}
		# just in case there are a lot of messages, we should release after a minutes worth of retrieving
		last if (time() > $start + 60);
	}
	$mail->disconnect;
	return $self->COMPLETE;
}



1;


