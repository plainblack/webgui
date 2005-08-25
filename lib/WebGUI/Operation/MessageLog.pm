package WebGUI::Operation::MessageLog;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict qw(vars subs);
use URI;
use WebGUI::DateTime;
use WebGUI::Grouping;
use WebGUI::International;
use WebGUI::Paginator;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Asset::Template;
use WebGUI::URL;
use WebGUI::User;
use WebGUI::Utility;
use WebGUI::Operation::Shared;

#-------------------------------------------------------------------
sub _status {
   return {"notice"=>WebGUI::International::get(551),"pending"=>WebGUI::International::get(552),"completed"=>WebGUI::International::get(350)};
}

#-------------------------------------------------------------------
sub www_viewMessageLog {
   my (@msg, $vars);
   return WebGUI::Privilege::insufficient() unless (WebGUI::Grouping::isInGroup(2,$session{user}{userId}));
   $vars->{displayTitle} = '<h1>'.WebGUI::International::get(159).'</h1>';
   my $p = WebGUI::Paginator->new(WebGUI::URL::page('op=viewMessageLog'));
   my $query = "select messageLogId,subject,url,dateOfEntry,status from messageLog where userId=".quote($session{user}{userId})." order by dateOfEntry desc";
   $p->setDataByQuery($query);
   
   $vars->{'message.subject.label'} = WebGUI::International::get(351);
   $vars->{'message.status.label'} = WebGUI::International::get(553);
   $vars->{'message.dateOfEntry.label'} = WebGUI::International::get(352);
   
   my $messages = $p->getPageData;
   foreach my $message (@$messages) {   
      my $hash;
      $hash->{'message.subject'} =  '<a href="'.WebGUI::URL::page('op=viewMessageLogMessage;mlog='.$message->{messageLogId}).'">'.$message->{subject}.'</a>';
      my $status = _status->{$message->{status}};
      $status = '<a href="'.WebGUI::URL::append($message->{url},'mlog='.$message->{messageLogId}).'">'.$status.'</a>' if ($message->{url} ne "");
      $hash->{'message.status'} = $status;
	  $hash->{'message.dateOfEntry'} = epochToHuman($message->{dateOfEntry});
	  push(@msg,$hash);
   }
   $vars->{'message.loop'} = \@msg;
   $vars->{'message.noresults'} = WebGUI::International::get(353) unless (scalar(@$messages) > 0);
   
   $vars->{'message.firstPage'} = $p->getFirstPageLink;
   $vars->{'message.lastPage'} = $p->getLastPageLink;
   $vars->{'message.nextPage'} = $p->getNextPageLink;
   $vars->{'message.pageList'} = $p->getPageLinks;
   $vars->{'message.previousPage'} = $p->getPreviousPageLink;
   $vars->{'message.multiplePages'} = ($p->getNumberOfPages > 1);
   $vars->{'message.accountOptions'} = WebGUI::Operation::Shared::accountOptions();

   return WebGUI::Operation::Shared::userStyle(WebGUI::Asset::Template->new("PBtmpl0000000000000050")->process($vars));
}

#-------------------------------------------------------------------
sub www_viewMessageLogMessage {
   my ($data, $vars);
   return WebGUI::Privilege::insufficient() unless (WebGUI::Grouping::isInGroup(2,$session{user}{userId}));
   $vars->{displayTitle} = '<h1>'.WebGUI::International::get(159).'</h1>';
   
   $data = WebGUI::SQL->quickHashRef("select * from messageLog where messageLogId=".quote($session{form}{mlog})." and userId=".quote($session{user}{userId}));
   
   $vars->{'message.subject'} = $data->{subject};
   $vars->{'message.dateOfEntry'} = epochToHuman($data->{dateOfEntry});
   
   my $status = _status->{$data->{status}}; 
   if ($data->{url} ne "" && $data->{status} eq 'pending'){
      $status = '<a href="'.WebGUI::URL::append($data->{url},'mlog='.$data->{messageLogId}).'">'.$status.'</a>';
      $vars->{'message.takeAction'} = '<a href="'.WebGUI::URL::append($data->{url},'mlog='.$data->{messageLogId}).'">'.WebGUI::International::get(554).'</a>'
   }
   $vars->{'message.status'} = $status;
   
   unless ($data->{message} =~ /\<div\>/ig || $data->{message} =~ /\<br\>/ig || $data->{message} =~ /\<p\>/ig) {
      $data->{message} =~ s/\n/\<br\>/g;
   }
   
   $vars->{'message.text'} = $data->{message};
   $vars->{'message.accountOptions'} = WebGUI::Operation::Shared::accountOptions();
   return WebGUI::Operation::Shared::userStyle(WebGUI::Asset::Template->new("PBtmpl0000000000000049")->process($vars));
}

1;
