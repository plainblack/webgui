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
		messagesPerPage=>$_[0]->get("messagesPerPage")
		});
}

#-------------------------------------------------------------------
sub set {
        $_[0]->SUPER::set($_[1],[qw(messagesPerPage)]);
}

#-------------------------------------------------------------------
sub www_edit {
        my ($output, $f, $messagesPerPage);
        if (WebGUI::Privilege::canEditPage()) {
		$messagesPerPage = $_[0]->get("messagesPerPage") || 50;
                $output = helpIcon(1,$namespace);
		$output .= '<h1>'.WebGUI::International::get(6,$namespace).'</h1>';
		$f = WebGUI::HTMLForm->new;
                $f->integer("messagesPerPage",WebGUI::International::get(4,$namespace),$messagesPerPage);
		$f->raw($_[0]->SUPER::discussionProperties);
		$output .= $_[0]->SUPER::www_edit($f->printRowsOnly);
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_editSave {
        if (WebGUI::Privilege::canEditPage()) {	
		$_[0]->SUPER::www_editSave();
                $_[0]->set({
			messagesPerPage=>$session{form}{messagesPerPage}
			});
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_showMessage {
        return $_[0]->SUPER::www_showMessage('<a href="'.WebGUI::URL::page().'">'.WebGUI::International::get(11,$namespace).'</a><br>');
}

#-------------------------------------------------------------------
sub www_view {
	my ($sth, %data, $html, $i, $pn, $lastId, @last, $replies);
	tie %data, 'Tie::CPHash';
        if ($session{form}{pn} < 1) {
                $pn = 0;
        } else {
                $pn = $session{form}{pn};
        }
	$html = $_[0]->displayTitle;
        $html .= $_[0]->description;
	$html = $_[0]->processMacros($html);
	$html .= '<table width="100%" cellpadding=2 cellspacing=1 border=0><tr>'.
		'<td align="right" valign="bottom" class="tableMenu">';
	if (WebGUI::Privilege::isInGroup($_[0]->get("groupToPost"))) {
		$html .= '<a href="'.
		WebGUI::URL::page('func=post&mid=new&wid='.$_[0]->get("wobjectId")).'">'.
		WebGUI::International::get(17,$namespace).'</a> &middot; ';
	}
	$html .= '<a href="'.WebGUI::URL::page('func=search&wid='.$_[0]->get("wobjectId")).'">'
			.WebGUI::International::get(364).'</a></td></tr></table>';
	$html .= '<table border=0 cellpadding=2 cellspacing=1 width="100%">';
	$html .= '<tr><td class="tableHeader">'.WebGUI::International::get(229).'</td>
		<td class="tableHeader">'.WebGUI::International::get(15,$namespace).'</td>
		<td class="tableHeader">'.WebGUI::International::get(18,$namespace).'</td>
		<td class="tableHeader">'.WebGUI::International::get(514).'</td>
		<td class="tableHeader">'.WebGUI::International::get(19,$namespace).'</td>
		<td class="tableHeader">'.WebGUI::International::get(20,$namespace).'</td></tr>';
	$sth = WebGUI::SQL->read("select messageId,subject,username,dateOfPost,userId,views,status
		from discussion where wobjectId=".$_[0]->get("wobjectId")." and pid=0 
		and (status='Approved' or userId=$session{user}{userId}) order by messageId desc");
	while (%data = $sth->hash) {
		$data{subject} = WebGUI::Discussion::formatSubject($data{subject});
		if ($i >= ($_[0]->get("messagesPerPage")*$pn) && $i < ($_[0]->get("messagesPerPage")*($pn+1))) {
			@last = WebGUI::SQL->quickArray("select messageId,dateOfPost,username,subject,userId 
				from discussion where wobjectId=".$_[0]->get("wobjectId")." and rid=$data{messageId} 
				and status='Approved' order by dateOfPost desc");
			$last[3] = WebGUI::HTML::filter($last[3],'all');
			($replies) = WebGUI::SQL->quickArray("select count(*) from discussion 
				where rid=$data{messageId} and status='Approved'");
			$replies--;
			$html .= '<tr><td class="tableData"><a 
				href="'.WebGUI::URL::page('func=showMessage&mid='.$data{messageId}.'&wid='.$_[0]->get("wobjectId"))
				.'">'.substr($data{subject},0,30).'</a>';
			if ($data{userId} == $session{user}{userId}) {
				$html .= ' ('.$status{$data{status}}.')';
			}
			$html .= '</td>
				<td class="tableData"><a href="'.WebGUI::URL::page('op=viewProfile&uid='.$data{userId}).'">'
				.$data{username}.'</a></td>
				<td class="tableData">'.epochToHuman($data{dateOfPost},"%z %Z").'</td>
				<td class="tableData">'.$data{views}.'</td>
				<td class="tableData">'.$replies.'</td>
				<td class="tableData"><span style="font-size: 8pt;"><a 
				href="'.WebGUI::URL::page('func=showMessage&mid='.$last[0].'&wid='.$_[0]->get("wobjectId")).'">'
				.substr($last[3],0,30).'</a> 
				@ '.epochToHuman($last[1],"%z %Z").' by <a href="'
				.WebGUI::URL::page('op=viewProfile&uid='.$last[4]).'">'.$last[2].'</a>
				</span></td></tr>';
		}
       		$i++;
        }
        $html .= '</table>';
	if ($i > $_[0]->get("messagesPerPage")) {
        	$html .= '<div class="pagination">';
        	if ($pn > 0) {
                	$html .= '<a href="'.WebGUI::URL::page('pn='.($pn-1)).'">&laquo;'.
				WebGUI::International::get(91).'</a>';
        	} else {
                	$html .= '&laquo;'.WebGUI::International::get(91);
        	}
        	$html .= ' &middot; ';
        	if (($pn+1) < round(($i/$_[0]->get("messagesPerPage")))) {
        		$html .= '<a href="'.WebGUI::URL::page('pn='.($pn+1)).'">'.
				WebGUI::International::get(92).'&raquo;</a>';
        	} else {
        		$html .= WebGUI::International::get(92).'&raquo;';
        	}
        	$html .= '</div>';
	}
	return $html;
}

1;

