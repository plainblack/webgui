package WebGUI::Wobject::MessageBoard;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use Tie::CPHash;
use WebGUI::DateTime;
use WebGUI::Discussion;
use WebGUI::HTML;
use WebGUI::HTMLForm;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::Utility;
use WebGUI::Wobject;

our @ISA = qw(WebGUI::Wobject);
our $namespace = "MessageBoard";
our $name = WebGUI::International::get(2,$namespace);

our %status =("Approved"=>WebGUI::International::get(560),
        "Denied"=>WebGUI::International::get(561),
        "Pending"=>WebGUI::International::get(562));



#-------------------------------------------------------------------
sub duplicate {
        my ($w);
	$w = $_[0]->SUPER::duplicate($_[1]);
        $w = WebGUI::Wobject::MessageBoard->new({wobjectId=>$w,namespace=>$namespace});
        $w->set({
		messagesPerPage=>$_[0]->get("messagesPerPage"),
		templateId=>$_[0]->get("templateId")
		});
}

#-------------------------------------------------------------------
sub set {
        $_[0]->SUPER::set($_[1],[qw(templateId messagesPerPage)]);
}

#-------------------------------------------------------------------
sub www_edit {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
        my ($output, $f, $messagesPerPage);
	$messagesPerPage = $_[0]->get("messagesPerPage") || 50;
        $output = helpIcon(1,$namespace);
	$output .= '<h1>'.WebGUI::International::get(6,$namespace).'</h1>';
	$f = WebGUI::HTMLForm->new;
        $f->integer("messagesPerPage",WebGUI::International::get(4,$namespace),$messagesPerPage);
	$f->template(
                -name=>"templateId",
                -value=>$_[0]->get("templateId"),
                -namespace=>$namespace,
                -label=>WebGUI::International::get(72,$namespace),
                -afterEdit=>'func=edit&wid='.$_[0]->get("wobjectId")
                );
	$f->raw($_[0]->SUPER::discussionProperties);
	$output .= $_[0]->SUPER::www_edit($f->printRowsOnly);
        return $output;
}

#-------------------------------------------------------------------
sub www_editSave {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
	$_[0]->SUPER::www_editSave({
		messagesPerPage=>$session{form}{messagesPerPage},
		templateId=>$session{form}{templateId}
		});
        return "";
}

#-------------------------------------------------------------------
sub www_showMessage {
        return $_[0]->SUPER::www_showMessage('<a href="'.WebGUI::URL::page().'">'.WebGUI::International::get(11,$namespace).'</a><br>');
}

#-------------------------------------------------------------------
sub www_view {
	my ($data, $html, %var, @message_loop, $rows, $lastId, @last, $replies);
	$var{title} = $_[0]->processMacros($_[0]->get("title"));
	$var{description} = $_[0]->processMacros($_[0]->get("description"));
	$var{canPost} = WebGUI::Privilege::isInGroup($_[0]->get("groupToPost"));
	$var{"post.url"} = WebGUI::URL::page('func=post&mid=new&wid='.$_[0]->get("wobjectId"));
	$var{"post.label"} = WebGUI::International::get(17,$namespace);
	$var{"search.url"} = WebGUI::URL::page('func=search&wid='.$_[0]->get("wobjectId"));
	$var{"search.label"} = WebGUI::International::get(364);
	$var{"subject.label"} = WebGUI::International::get(229);
	$var{"user.label"} = WebGUI::International::get(15,$namespace);
	$var{"date.label"} = WebGUI::International::get(18,$namespace);
	$var{"views.label"} = WebGUI::International::get(514);
	$var{"replies.label"} = WebGUI::International::get(19,$namespace);
	$var{"last.label"} = WebGUI::International::get(20,$namespace);
	$p = WebGUI::Paginator->new('wid='.$_[0]->get("wobjectId").'&func=view');
	$p->setDataByQuery("select messageId,subject,username,dateOfPost,userId,views,status
		from discussion where wobjectId=".$_[0]->get("wobjectId")." and pid=0 
		and (status='Approved' or userId=$session{user}{userId}) order by dateOfPost desc");
	$rows = $p->getPageData;
	foreach $data (@$rows) {
		@last = WebGUI::SQL->quickArray("select messageId,dateOfPost,username,subject,userId 
			from discussion where wobjectId=".$_[0]->get("wobjectId")." and rid=$data->{messageId} 
			and status='Approved' order by dateOfPost desc");
		($replies) = WebGUI::SQL->quickArray("select count(*) from discussion 
			where rid=$data->{messageId} and status='Approved'");
		$replies--;
		push(@message_loop,{
			"last.url" => WebGUI::URL::page('func=showMessage&mid='.$last[0].'&wid='.$_[0]->get("wobjectId")),
			"last.subject" => substr(WebGUI::HTML::filter($last[3],'all'),0,30),
			"last.date" => epochToHuman($last[1]),
			"last.userProfile" => WebGUI::URL::page('op=viewProfile&uid='.$last[4]),
			"last.username" => $last[2],
			"message.replies" => $replies,
			"message.url" => WebGUI::URL::page('func=showMessage&mid='.$data->{messageId}.'&wid='.$_[0]->get("wobjectId")),
			"message.subject" => substr($data{subject},0,30),
			"message.currentUser" => ($data{userId} == $session{user}{userId}),
			"message.status" => $status{$data{status}},
			"message.userProfile" => WebGUI::URL::page('op=viewProfile&uid='.$data{userId}),
			"message.username" => $data{username},
			"message.date" => epochToHuman($data{dateOfPost}),
			"message.views" => $data{views}
			});
        }
	$var{message_loop} = \@message_loop;
        $var{firstPage} = $p->getFirstPageLink;
        $var{lastPage} = $p->getLastPageLink;
        $var{nextPage} = $p->getNextPageLink;
        $var{pageList} = $p->getPageLinks;
        $var{previousPage} = $p->getPreviousPageLink;
        $var{multiplePages} = ($p->getNumberOfPages > 1);
        return $_[0]->processTemplate($_[0]->get("templateId"),\%var);
}

1;

