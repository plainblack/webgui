package WebGUI::Workflow::Activity::GetCsMail;


=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2012 Plain Black Corporation.
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
use WebGUI::HTML;
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
		if (($part->{type} =~ /^text\/plain/ || $part->{type} =~ /^text\/html/) && $part->{filename} eq "") {
			my $text = $part->{content};
			if ($part->{type} eq "text/plain") {
				$text = WebGUI::HTML::filter($text, "all");
				$text = WebGUI::HTML::format($text, "text");
			} 
            elsif ($part->{type} eq 'text/html') {
                $text = WebGUI::HTML::cleanSegment($text);
            }
			$content .= $text;
		} else {
			push(@attachments, $part);
		}
	}
	my $title = $message->{subject};
	$title =~ s/\Q$prefix//;
	if ($title =~ m/re:/i) {
		$title =~ s/re://ig;
		$title = "Re: ".$title;
		$title =~ s/\s+/ /g;
	}
	my $post = $parent->addChild({
		className=>$class,
		title=>$title,
		menuTitle =>$title,
		url=>$parent->get("url")."/".$title,
		content=>$content,
		ownerUserId=>$user->userId,
		username=>$user->get("alias") || $user->username,
        originalEmail=>join("",@{$message->{rawMessage}}),
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
    ##Modify, then save
	$post->postProcess;
    $post->requestAutoCommit;
	$post->getThread->unarchive if ($post->getThread->get("status") eq "archived");
	return $post;
}

#-------------------------------------------------------------------

=head2 definition ( session, definition )

See WebGUI::Workflow::Activity::definition() for details.

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
	my $postGroup = $cs->get("postGroupId"); #group that's allowed to post to the CS
    
    my $ttl = $self->getTTL;
	while (my $message = $mail->getNextMessage) {
		next unless (scalar(@{$message->{parts}})); # no content, skip it
		my $from = $message->{from};
        if ($from =~ /<(\S+\@\S+)>/) {
            $from = $1;
        }
        my $user = WebGUI::User->newByEmail($self->session, $from); #instantiate the user by email
		
		unless (defined $user) { #if no user
			unless ($postGroup eq 1 || $postGroup eq 7) { #reject mail if no registered email, unless post group is Visitors (1) or Everyone (7)
				if ($message->{from} eq "") {
					$self->session->log->error("For some reason the message ".$message->{subject}." (".$message->{messageId}.") has no from address.");
				}
				elsif ($message->{from} eq $cs->get("mailAddress")) {
					$self->session->log->error("For some reason the message ".$message->{subject}." (".$message->{messageId}.") has the same from address as the collaboration system's mail address.");
				} 
				else { 
					my $send = WebGUI::Mail::Send->create($self->session, {
						to=>$message->{from},
						inReplyTo=>$message->{messageId},
						subject=>$cs->get("mailPrefix").$i18n->get("rejected")." ".$message->{subject},
						from=>$cs->get("mailAddress")
						});
					$send->addText($i18n->get("rejected because no user account"));
					$send->queue;
				}
				next;
			}
			$user = WebGUI::User->new($self->session, undef); # instantiate the user as a visitor
		}

		my $post = undef;
		if ($message->{inReplyTo} && $message->{inReplyTo} =~ m/cs\-([\w_-]{22})\@/) {
			my $id = $1;
            my $repliedPost = eval { WebGUI::Asset->newById($self->session, $id); };
            if (! Exception::Class->caught()
                && $repliedPost->isa('WebGUI::Asset::Post')
                && $repliedPost->getThread->getParent->getId eq $cs->getId) {
                $post = $repliedPost;
            }
		}

		if (defined $post && $cs->get("allowReplies") && $user->isInGroup($cs->get("postGroupId")) && (!$cs->get("requireSubscriptionForEmailPosting") || $user->isInGroup($cs->get("subscriptionGroupId")) || $user->isInGroup($post->get("subscriptionGroupId")))) {
			$self->addPost($post, $message, $user, $cs->get("mailPrefix"));
			#subscribe poster to thread if set to autosubscribe, and they're not already
			if ($cs->get("autoSubscribeToThread") && !($user->isInGroup($cs->get("subscriptionGroupId")) || $user->isInGroup($post->get("subscriptionGroupId")))) {
				$user->addToGroups([$post->getThread->get("subscriptionGroupId")]);
			}
		} elsif ($user->isInGroup($cs->get("postGroupId")) && (!$cs->get("requireSubscriptionForEmailPosting") || $user->isInGroup($cs->get("subscriptionGroupId")))) {
			my $thread = $self->addPost($cs, $message, $user, $cs->get("mailPrefix"));
			#subscribe poster to thread if set to autosubscribe, and they're not already
			if ($cs->get("autoSubscribeToThread") && !$user->isInGroup($cs->get("subscriptionGroupId"))) {
				$user->addToGroups([$thread->get("subscriptionGroupId")]);
			}
		} else {
			my $send = WebGUI::Mail::Send->create($self->session, {
				to=>$message->{from},
				inReplyTo=>$message->{messageId},
				subject=>$cs->get("mailPrefix").$i18n->get("rejected")." ".$self->{subject},
				from=>$cs->get("mailAddress")
				});
			$send->addText($i18n->get("rejected because not allowed"));
			$send->queue;
		}
		# just in case there are a lot of messages, we should release after a minutes worth of retrieving
		last if (time() > $start + $ttl);
	}
	$mail->disconnect;
	return $self->COMPLETE;
}



1;


