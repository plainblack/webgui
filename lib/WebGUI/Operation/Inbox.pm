package WebGUI::Operation::Inbox;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict qw(vars subs);
use URI;
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

=head2 _status ( )

returns a hashref with internationalized values for message status.

=cut

sub _status {
	my $session = shift;
	my $i18n = WebGUI::International->new($session);
	return {"pending"=>$i18n->get(552),"completed"=>$i18n->get(350)};
}

#-------------------------------------------------------------------

=head2 www_viewInbox ( )

Templated display all messages for the current user.

=cut

sub www_viewInbox {
	my $session = shift;
	return $session->privilege->insufficient() unless ($session->user->isInGroup(2));
	my $i18n = WebGUI::International->new($session);
   	$vars->{title} = $i18n->get(159);
   	$vars->{'subject.label'} = $i18n->get(351);
   	$vars->{'status.label'} = $i18n->get(553);
   	$vars->{'dateStamp.label'} = $i18n->get(352);
  	my $messages = WebGUI::Inbox->getMessagesForUser($session, $session->user); 
   	foreach my $message (@$messages) {   
      		my $hash;
      		$hash->{'subject'} =  '<a href="'.$session->url->page('op=viewInboxMessage;messageId='.$message->getId).'">'.$message->get("subject").'</a>';
      		$hash->{status} = _status($session)->{$message->get("status")};
	  	$hash->{'dateStamp'} =$session->datetime->epochToHuman($message->get("dateStamp"));
	  	push(@msg,$hash);
   	}
   	$vars->{'messages'} = \@msg;
   	$vars->{'noresults'} = $i18n->get(353) unless (scalar(@$messages) > 0);
   	$vars->{'accountOptions'} = WebGUI::Operation::Shared::accountOptions($session);
   	return $session->style->userStyle(WebGUI::Asset::Template->new($session,"PBtmpl0000000000000206")->process($vars));
}

#-------------------------------------------------------------------

=head2 www_viewInboxMessage ( )

Templated display of a single message for the user.

=cut

sub www_viewInboxMessage {
	my $session = shift;
	my ($data, $vars);
	return $session->privilege->insufficient() unless ($session->user->isInGroup(2));
	my $i18n = WebGUI::International->new($session);
   	$vars->{title} = $i18n->get(159);
	my $message = WebGUI::Inbox->getMessage($session, $session->form->param("messageId"));
	if (defined $message) {
	   	$vars->{'subject'} = $data->{subject};
	   	$vars->{'dateStamp'} =$session->datetime->epochToHuman($data->{dateStamp});
   		$vars->{'status'} = _status($session)->{$data->{status}}; 
   		unless ($data->{message} =~ /\<div/ig || $data->{message} =~ /\<br/ig || $data->{message} =~ /\<p/ig) {
      			$data->{message} =~ s/\n/\<br\>/g;
   		}
   		unless ($data->{message} =~ /\<a/ig) {
      			$data->{message} =~ s/(http\S*)\s/\<a href=\"$1\"\>$1\<\/a\>/g;
   		}
   		$vars->{'message'} = $data->{message};
	}
   	$vars->{'accountOptions'} = WebGUI::Operation::Shared::accountOptions($session);
   	return $session->style->userStyle(WebGUI::Asset::Template->new($session,"PBtmpl0000000000000205")->process($vars));
}

1;
