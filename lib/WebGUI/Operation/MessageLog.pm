package WebGUI::Operation::MessageLog;

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

Package WebGUI::Operation::MessageLog

=head1 DESCRIPTION

Operations for viewing message logs and individual messages.

=cut

#-------------------------------------------------------------------

=head2 _status ( )

returns a hashref with internationalized values for message status.

=cut

sub _status {
	my $session = shift; use WebGUI; WebGUI::dumpSession($session);
	my $i18n = WebGUI::International->new($session);
	return {"notice"=>$i18n->get(551),"pending"=>$i18n->get(552),"completed"=>$i18n->get(350)};
}

#-------------------------------------------------------------------

=head2 www_viewMessageLog ( )

Templated display all messages for the current user.

=cut

sub www_viewMessageLog {
	my $session = shift; use WebGUI; WebGUI::dumpSession($session);
   my (@msg, $vars);
   return $session->privilege->insufficient() unless ($session->user->isInGroup(2,$session->user->userId));
	my $i18n = WebGUI::International->new($session);
   $vars->{displayTitle} = '<h1>'.$i18n->get(159).'</h1>';
   my $p = WebGUI::Paginator->new($session,$session->url->page('op=viewMessageLog'));
   my $query = "select messageLogId,subject,url,dateOfEntry,status from messageLog where userId=".$session->db->quote($session->user->userId)." order by dateOfEntry desc";
   $p->setDataByQuery($query);
   
   $vars->{'message.subject.label'} = $i18n->get(351);
   $vars->{'message.status.label'} = $i18n->get(553);
   $vars->{'message.dateOfEntry.label'} = $i18n->get(352);
   
   my $messages = $p->getPageData;
   foreach my $message (@$messages) {   
      my $hash;
      $hash->{'message.subject'} =  '<a href="'.$session->url->page('op=viewMessageLogMessage;mlog='.$message->{messageLogId}).'">'.$message->{subject}.'</a>';
      my $status = _status->{$message->{status}};
      $status = '<a href="'.$session->url->append($message->{url},'mlog='.$message->{messageLogId}).'">'.$status.'</a>' if ($message->{url} ne "");
      $hash->{'message.status'} = $status;
	  $hash->{'message.dateOfEntry'} =$session->datetime->epochToHuman($message->{dateOfEntry});
	  push(@msg,$hash);
   }
   $vars->{'message.loop'} = \@msg;
   $vars->{'message.noresults'} = $i18n->get(353) unless (scalar(@$messages) > 0);
   
   $vars->{'message.firstPage'} = $p->getFirstPageLink;
   $vars->{'message.lastPage'} = $p->getLastPageLink;
   $vars->{'message.nextPage'} = $p->getNextPageLink;
   $vars->{'message.pageList'} = $p->getPageLinks;
   $vars->{'message.previousPage'} = $p->getPreviousPageLink;
   $vars->{'message.multiplePages'} = ($p->getNumberOfPages > 1);
   $vars->{'message.accountOptions'} = WebGUI::Operation::Shared::accountOptions();

   return $session->style->userStyle(WebGUI::Asset::Template->new("PBtmpl0000000000000050")->process($vars));
}

#-------------------------------------------------------------------

=head2 www_viewMessageLog ( )

Templated display of a single message for the user.

=cut

sub www_viewMessageLogMessage {
	my $session = shift; use WebGUI; WebGUI::dumpSession($session);
   my ($data, $vars);
   return $session->privilege->insufficient() unless ($session->user->isInGroup(2,$session->user->userId));
	my $i18n = WebGUI::International->new($session);
   $vars->{displayTitle} = '<h1>'.$i18n->get(159).'</h1>';
   
   $data = $session->db->quickHashRef("select * from messageLog where messageLogId=".$session->db->quote($session->form->process("mlog"))." and userId=".$session->db->quote($session->user->userId));
   
   $vars->{'message.subject'} = $data->{subject};
   $vars->{'message.dateOfEntry'} =$session->datetime->epochToHuman($data->{dateOfEntry});
   
   my $status = _status->{$data->{status}}; 
   if ($data->{url} ne "" && $data->{status} eq 'pending'){
      $status = '<a href="'.$session->url->append($data->{url},'mlog='.$data->{messageLogId}).'">'.$status.'</a>';
      $vars->{'message.takeAction'} = '<a href="'.$session->url->append($data->{url},'mlog='.$data->{messageLogId}).'">'.$i18n->get(554).'</a>'
   }
   $vars->{'message.status'} = $status;
   
   unless ($data->{message} =~ /\<div\>/ig || $data->{message} =~ /\<br\>/ig || $data->{message} =~ /\<p\>/ig) {
      $data->{message} =~ s/\n/\<br\>/g;
   }
   
   $vars->{'message.text'} = $data->{message};
   $vars->{'message.accountOptions'} = WebGUI::Operation::Shared::accountOptions();
   return $session->style->userStyle(WebGUI::Asset::Template->new("PBtmpl0000000000000049")->process($vars));
}

1;
