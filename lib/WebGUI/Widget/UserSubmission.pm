package WebGUI::Widget::UserSubmission;

our $namespace = "UserSubmission";

#-------------------------------------------------------------------
# WebGUI is Copyright 2001 Plain Black Software.
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
use WebGUI::International;
use WebGUI::Macro;
use WebGUI::MessageLog;
use WebGUI::Operation;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Utility;
use WebGUI::Widget;

#-------------------------------------------------------------------
sub purge {
        WebGUI::SQL->write("delete from UserSubmission_submission where widgetId=$_[0]",$_[1]);
        WebGUI::SQL->write("delete from UserSubmission where widgetId=$_[0]",$_[1]);
        purgeWidget($_[0],$_[1]);
}

#-------------------------------------------------------------------
sub widgetName {
	return WebGUI::International::get(277);
}

#-------------------------------------------------------------------
sub www_add {
        my ($output, %hash, @array);
	tie %hash, "Tie::IxHash";
      	if (WebGUI::Privilege::canEditPage()) {
                $output = '<a href="'.$session{page}{url}.'?op=viewHelp&hid=1&namespace='.$namespace.'"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a>';
		$output .= '<h1>'.WebGUI::International::get(278).'</h1>';
		$output .= '<form method="post" enctype="multipart/form-data" action="'.$session{page}{url}.'">';
                $output .= WebGUI::Form::hidden("widget",$namespace);
                $output .= WebGUI::Form::hidden("func","addSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(99).'</td><td>'.WebGUI::Form::text("title",20,128,'User Submission System').'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(174).'</td><td>'.WebGUI::Form::checkbox("displayTitle",1,1).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(175).'</td><td>'.WebGUI::Form::checkbox("processMacros",1).'</td></tr>';
		%hash = WebGUI::Widget::getPositions();
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(363).'</td><td>'.WebGUI::Form::selectList("position",\%hash).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(85).'</td><td>'.WebGUI::Form::textArea("description",'',50,5,1).'</td></tr>';
                %hash = WebGUI::SQL->buildHash("select groupId,groupName from groups where groupName<>'Reserved' order by groupName",$session{dbh});
		$array[0] = 4;
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(1,$namespace).'</td><td>'.WebGUI::Form::selectList("groupToApprove",\%hash,\@array).'</td></tr>';
		$array[0] = 2;
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(2,$namespace).'</td><td>'.WebGUI::Form::selectList("groupToContribute",\%hash,\@array).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(280).'</td><td>'.WebGUI::Form::text("submissionsPerPage",20,2,50).'</td></tr>';
                %hash = ("Approved"=>WebGUI::International::get(281),"Denied"=>WebGUI::International::get(282),"Pending"=>WebGUI::International::get(283));
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(284).'</td><td>'.WebGUI::Form::selectList("defaultStatus",\%hash,'',1).'</td></tr>';
                $output .= '<tr><td></td><td>'.WebGUI::Form::submit(WebGUI::International::get(62)).'</td></tr>';
                $output .= '</table></form>';
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
	return $output;
}

#-------------------------------------------------------------------
sub www_addSave {
	my ($widgetId);
	if (WebGUI::Privilege::canEditPage()) {
		$widgetId = create();
		WebGUI::SQL->write("insert into UserSubmission values ($widgetId, $session{form}{groupToContribute}, '$session{form}{submissionsPerPage}', '$session{form}{defaultStatus}', $session{form}{groupToApprove})",$session{dbh});
		return "";
	} else {
		return WebGUI::Privilege::insufficient();
	}
}

#-------------------------------------------------------------------
sub www_addSubmission {
        my ($output, $groupToContribute, @submission, $sth);
	($groupToContribute) = WebGUI::SQL->quickArray("select groupToContribute from UserSubmission where widgetId=$session{form}{wid}",$session{dbh});
        if (WebGUI::Privilege::isInGroup($groupToContribute,$session{user}{userId})) {
                $output = '<h1>'.WebGUI::International::get(285).'</h1>';
		$output .= '<form method="post" enctype="multipart/form-data" action="'.$session{page}{url}.'">';
                $output .= WebGUI::Form::hidden("wid",$session{form}{wid});
                $output .= WebGUI::Form::hidden("func","addSubmissionSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(99).'</td><td>'.WebGUI::Form::text("title",20,128).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(178).'</td><td>'.WebGUI::Form::textArea("content",'',50,10,1).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(179).'</td><td>'.WebGUI::Form::file("image").'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(182).'</td><td>'.WebGUI::Form::file("attachment").'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(183).'</td><td>'.WebGUI::Form::checkbox("convertCarriageReturns",1,1).' <span style="font-size: 8pt;">'.WebGUI::International::get(286).'</span></td></tr>';
                $output .= '<tr><td></td><td>'.WebGUI::Form::submit(WebGUI::International::get(62)).'</td></tr>';
                $output .= '</table></form>';
                $output .= '<table width="100%" cellspacing=1 cellpadding=2 border=0>';
                $output .= '<tr><td class="tableHeader">'.WebGUI::International::get(289).'</td><td class="tableHeader">'.WebGUI::International::get(99).'</td><td class="tableHeader">'.WebGUI::International::get(287).'</td><td class="tableHeader">'.WebGUI::International::get(288).'</td></tr>';
                $sth = WebGUI::SQL->read("select title,submissionId,dateSubmitted,status from UserSubmission_submission where widgetId='$session{form}{wid}' and userId=$session{user}{userId} order by dateSubmitted desc",$session{dbh});
                while (@submission = $sth->array) {
                        $output .= '<tr><td class="tableData"><a href="'.$session{page}{url}.'?func=editSubmission&wid='.$session{form}{wid}.'&sid='.$submission[1].'"><img src="'.$session{setting}{lib}.'/edit.gif" border=0></a><a href="'.$session{page}{url}.'?wid='.$session{form}{wid}.'&sid='.$submission[1].'&func=deleteSubmission"><img src="'.$session{setting}{lib}.'/delete.gif" border=0></a></td><td class="tableData"><a href="'.$session{page}{url}.'?wid='.$session{form}{wid}.'&func=viewSubmission&sid='.$submission[1].'">'.$submission[0].'</a></td><td class="tableData">'.epochToHuman($submission[2],"%M/%D/%y").'</td><td class="tableData">'.$submission[3].'</td></tr>';
                }
                $sth->finish;
                $output .= '</table>';
        } else {
                $output = WebGUI::Privilege::insufficient();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_addSubmissionSave {
        my ($title, $submissionId, $image, $attachment, %userSubmission);
	%userSubmission = WebGUI::SQL->quickHash("select * from UserSubmission where widgetId=$session{form}{wid}",$session{dbh});
        if (WebGUI::Privilege::isInGroup($userSubmission{groupToContribute},$session{user}{userId})) {
                $submissionId = getNextId("submissionId");
                $image = saveAttachment("image",$session{form}{wid},$submissionId);
                $attachment = saveAttachment("attachment",$session{form}{wid},$submissionId);
		if ($session{form}{title} ne "") {
			$title = $session{form}{title};
		} else {
			$title = WebGUI::International::get(290);
		}
                WebGUI::SQL->write("insert into UserSubmission_submission values ($session{form}{wid}, $submissionId, ".quote($title).", ".time().", ".quote($session{user}{username}).", '$session{user}{userId}', ".quote($session{form}{content}).", ".quote($image).", ".quote($attachment).", '$userSubmission{defaultStatus}', '$session{form}{convertCarriageReturns}')",$session{dbh});
		if ($userSubmission{defaultStatus} ne "Approved") {
			WebGUI::MessageLog::addEntry('',$userSubmission{groupToApprove},$session{page}{url}.'?func=viewSubmission&wid='.$session{form}{wid}.'&sid='.$submissionId,3,$namespace);
		}
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_approveSubmission {
	my (%userSubmission, %submission);
        if (WebGUI::Privilege::isInGroup(4,$session{user}{userId}) || WebGUI::Privilege::isInGroup(3,$session{user}{userId})) {
		%submission = WebGUI::SQL->quickHash("select * from UserSubmission_submission where submissionId=$session{form}{sid}",$session{dbh});
		%userSubmission = WebGUI::SQL->quickHash("select * from UserSubmission where widgetId=$session{form}{wid}",$session{dbh});
                WebGUI::SQL->write("update UserSubmission_submission set status='Approved' where submissionId=$session{form}{sid}",$session{dbh});
		WebGUI::MessageLog::addEntry($submission{userId},'',$session{page}{url}.'?func=viewSubmission&wid='.$session{form}{wid}.'&sid='.$session{form}{sid},4,$namespace);
		WebGUI::MessageLog::completeEntry($session{form}{mlog});
                return WebGUI::Operation::www_viewMessageLog();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteAttachment {
	my ($owner);
	($owner) = WebGUI::SQL->quickArray("select userId from UserSubmission_submission where submissionId=$session{form}{sid}",$session{dbh});
        if ($owner == $session{user}{userId}) {
                WebGUI::SQL->write("update UserSubmission_submission set attachment='' where submissionId=$session{form}{sid}",$session{dbh});
                return www_editSubmission();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteImage {
	my ($owner);
	($owner) = WebGUI::SQL->quickArray("select userId from UserSubmission_submission where submissionId=$session{form}{sid}",$session{dbh});
        if ($owner == $session{user}{userId}) {
                WebGUI::SQL->write("update UserSubmission_submission set image='' where submissionId=$session{form}{sid}",$session{dbh});
                return www_editSubmission();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteSubmission {
	my ($output, $owner);
	($owner) = WebGUI::SQL->quickArray("select userId from UserSubmission_submission where submissionId=$session{form}{sid}",$session{dbh});
        if ($owner == $session{user}{userId}) {
		$output = '<h1>'.WebGUI::International::get(42).'</h1>';
		$output .= WebGUI::International::get(291).'<p>';
		$output .= '<div align="center"><a href="'.$session{page}{url}.'?func=deleteSubmissionConfirm&wid='.$session{form}{wid}.'&sid='.$session{form}{sid}.'">'.WebGUI::International::get(44).'</a>';
		$output .= ' &nbsp; <a href="'.$session{page}{url}.'">'.WebGUI::International::get(45).'</a></div>';
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteSubmissionConfirm {
        my ($output, $owner);
	($owner) = WebGUI::SQL->quickArray("select userId from UserSubmission_submission where submissionId=$session{form}{sid}",$session{dbh});
        if ($owner == $session{user}{userId}) {
		WebGUI::SQL->write("delete from UserSubmission_submission where submissionId=$session{form}{sid}",$session{dbh});
                return www_addSubmission();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_denySubmission {
	my (%submission, %userSubmission);
        if (WebGUI::Privilege::isInGroup(4,$session{user}{userId}) || WebGUI::Privilege::isInGroup(3,$session{user}{userId})) {
		%submission = WebGUI::SQL->quickHash("select * from UserSubmission_submission where submissionId=$session{form}{sid}",$session{dbh});
                %userSubmission = WebGUI::SQL->quickHash("select * from UserSubmission where widgetId=$session{form}{wid}",$session{dbh});
                WebGUI::SQL->write("update UserSubmission_submission set status='Denied' where submissionId=$session{form}{sid}",$session{dbh}
);
                WebGUI::MessageLog::addEntry($submission{userId},'',$session{page}{url}.'?func=viewSubmission&wid='.$session{form}{wid}.'&sid='.$session{form}{sid},5,$namespace);
                WebGUI::MessageLog::completeEntry($session{form}{mlog});
                return WebGUI::Operation::www_viewMessageLog();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_edit {
        my ($output, %data, @array, $sth, %hash);
	tie %data, 'Tie::CPHash';
	tie %hash, 'Tie::IxHash';
        if (WebGUI::Privilege::canEditPage()) {
		%data = WebGUI::SQL->quickHash("select * from widget,UserSubmission where widget.widgetId=$session{form}{wid} and widget.widgetId=UserSubmission.widgetId",$session{dbh});
                $output = '<a href="'.$session{page}{url}.'?op=viewHelp&hid=1&namespace='.$namespace.'"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a>';
		$output .= '<h1>'.WebGUI::International::get(292).'</h1>';
		$output .= '<form method="post" enctype="multipart/form-data" action="'.$session{page}{url}.'">';
                $output .= WebGUI::Form::hidden("wid",$session{form}{wid});
                $output .= WebGUI::Form::hidden("func","editSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(99).'</td><td>'.WebGUI::Form::text("title",20,128,$data{title}).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(174).'</td><td>'.WebGUI::Form::checkbox("displayTitle","1",$data{displayTitle}).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(175).'</td><td>'.WebGUI::Form::checkbox("processMacros","1",$data{processMacros}).'</td></tr>';
		%hash = WebGUI::Widget::getPositions();
                $array[0] = $data{position};
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(363).'</td><td>'.WebGUI::Form::selectList("position",\%hash,\@array).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(85).'</td><td>'.WebGUI::Form::textArea("description",$data{description}).'</td></tr>';
		$array[0] = $data{groupToApprove};
		%hash = WebGUI::SQL->buildHash("select groupId,groupName from groups where groupName<>'Reserved' order by groupName",$session{dbh});
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(1,$namespace).'</td><td>'.WebGUI::Form::selectList("groupToApprove",\%hash,\@array,1).'</td></tr>';
		$array[0] = $data{groupToContribute};
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(2,$namespace).'</td><td>'.WebGUI::Form::selectList("groupToContribute",\%hash,\@array,1).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(280).'</td><td>'.WebGUI::Form::text("submissionsPerPage",20,2,$data{submissionsPerPage}).'</td></tr>';
                %hash = ("Approved"=>WebGUI::International::get(281),"Denied"=>WebGUI::International::get(282),"Pending"=>WebGUI::International::get(283));
		$array[0] = $data{defaultStatus};
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(284).'</td><td>'.WebGUI::Form::selectList("defaultStatus",\%hash,\@array,1).'</td></tr>';
                $output .= '<tr><td></td><td>'.WebGUI::Form::submit(WebGUI::International::get(62)).'</td></tr>';
                $output .= '</table></form>';
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_editSave {
        if (WebGUI::Privilege::canEditPage()) {
		update();
		WebGUI::SQL->write("update UserSubmission set groupToContribute=$session{form}{groupToContribute}, groupToApprove=$session{form}{groupToApprove}, submissionsPerPage=$session{form}{submissionsPerPage}, defaultStatus='$session{form}{defaultStatus}' where widgetId=$session{form}{wid}",$session{dbh});
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_editSubmission {
        my ($output, %submission, $owner);
	tie %submission, 'Tie::CPHash';
	($owner) = WebGUI::SQL->quickArray("select userId from UserSubmission_submission where submissionId=$session{form}{sid}",$session{dbh});
        if ($owner == $session{user}{userId}) {
                %submission = WebGUI::SQL->quickHash("select * from UserSubmission_submission where submissionId='$session{form}{sid}'",$session{dbh});
                $output = '<h1>'.WebGUI::International::get(293).'</h1>';
		$output .= '<form method="post" enctype="multipart/form-data" action="'.$session{page}{url}.'">';
                $output .= WebGUI::Form::hidden("wid",$session{form}{wid});
                $output .= WebGUI::Form::hidden("sid",$session{form}{sid});
                $output .= WebGUI::Form::hidden("func","editSubmissionSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(99).'</td><td>'.WebGUI::Form::text("title",20,128,$submission{title}).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(178).'</td><td>'.WebGUI::Form::textArea("content",$submission{content},50,10).'</td></tr>';
                if ($submission{image} ne "") {
                        $output .= '<tr><td class="formDescription">'.WebGUI::International::get(179).'</td><td><a href="'.$session{page}{url}.'?func=deleteImage&wid='.$session{form}{wid}.'&sid='.$session{form}{sid}.'">'.WebGUI::International::get(186).'</a></td></tr>';
                } else {
                        $output .= '<tr><td class="formDescription">'.WebGUI::International::get(179).'</td><td>'.WebGUI::Form::file("image").'</td></tr>';
                }
                if ($submission{attachment} ne "") {
                        $output .= '<tr><td class="formDescription">'.WebGUI::International::get(182).'</td><td><a href="'.$session{page}{url}.'?func=deleteAttachment&wid='.$session{form}{wid}.'&sid='.$session{form}{sid}.'">'.WebGUI::International::get(186).'</a></td></tr>';
                } else {
                        $output .= '<tr><td class="formDescription">'.WebGUI::International::get(182).'</td><td>'.WebGUI::Form::file("attachment").'</td></tr>';
                }
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(183).'</td><td>'.WebGUI::Form::checkbox("convertCarriageReturns",1,$submission{convertCarriageReturns}).' <span style="font-size: 8pt;">(uncheck if you\'re writing an HTML submission)</span></td></tr>';
                $output .= '<tr><td></td><td>'.WebGUI::Form::submit(WebGUI::International::get(62)).'</td></tr>';
                $output .= '</table></form>';
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_editSubmissionSave {
	my ($owner,%userSubmission,$image,$attachment,$title);
	($owner) = WebGUI::SQL->quickArray("select userId from UserSubmission_submission where submissionId=$session{form}{sid}",$session{dbh});
        if ($owner == $session{user}{userId}) {
		%userSubmission = WebGUI::SQL->quickHash("select * from UserSubmission where widgetId=$session{form}{wid}",$session{dbh});
                $image = saveAttachment("image",$session{form}{wid},$session{form}{sid});
		if ($image ne "") {
			$image = 'image='.quote($image).', ';
		}
                $attachment = saveAttachment("attachment",$session{form}{wid},$session{form}{sid});
                if ($attachment ne "") {
                        $attachment = 'attachment='.quote($attachment).', ';
                }
                if ($session{form}{title} ne "") {
                        $title = $session{form}{title};
                } else {
                        $title = WebGUI::International::get(290);
                }
                WebGUI::SQL->write("update UserSubmission_submission set dateSubmitted=".time().", convertCarriageReturns='$session{form}{convertCarriageReturns}', title=".quote($title).", content=".quote($session{form}{content}).", ".$image.$attachment." status='$userSubmission{defaultStatus}' where submissionId=$session{form}{sid}",$session{dbh});
		if ($userSubmission{defaultStatus} ne "Approved") {
			WebGUI::MessageLog::addEntry('',$userSubmission{groupToApprove},$session{page}{url}.'?func=viewSubmission&wid='.$session{form}{wid}.'&sid='.$session{form}{sid},3,$namespace);
		}
                return www_viewSubmission();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_view {
	my (%data, @submission, $output, $widgetId, $sth, @row, $i, $dataRows, $prevNextBar);
	tie %data, 'Tie::CPHash';
	$widgetId = shift;
	%data = WebGUI::SQL->quickHash("select * from widget,UserSubmission where widget.widgetId=$widgetId and widget.widgetId=UserSubmission.widgetId",$session{dbh});
	if (%data) {
		if ($data{displayTitle} == 1) {
			$output = "<h1>".$data{title}."</h1>";
		}
		if ($data{description} ne "") {
			$output .= $data{description}.'<p>';
		}
		if ($data{processMacros}) {
			$output = WebGUI::Macro::process($output);
		}
		$sth = WebGUI::SQL->read("select title,submissionId,dateSubmitted,username,userId from UserSubmission_submission where widgetId='$widgetId' and status='Approved' order by dateSubmitted desc",$session{dbh});
		while (@submission = $sth->array) {
			$row[$i] = '<tr><td class="tableData"><a href="'.$session{page}{url}.'?wid='.$widgetId.'&func=viewSubmission&sid='.$submission[1].'">'.$submission[0].'</a></td><td class="tableData">'.epochToHuman($submission[2],"%M/%D/%y").'</td><td class="tableData"><a href="'.$session{page}{url}.'?op=viewProfile&uid='.$submission[4].'">'.$submission[3].'</a></td></tr>';
			$i++;
		}
		$sth->finish;
		$output .= '<table width="100%" cellpadding=3 cellspacing=0 border=0><tr><td align="right" class="tableMenu"><a href="'.$session{page}{url}.'?func=addSubmission&wid='.$widgetId.'">'.WebGUI::International::get(294).'</a></td></tr></table>';
                ($dataRows, $prevNextBar) = paginate($data{submissionsPerPage},$session{page}{url},\@row);
		$output .= '<table width="100%" cellspacing=1 cellpadding=2 border=0>';
		$output .= '<tr><td class="tableHeader">'.WebGUI::International::get(99).'</td><td class="tableHeader">'.WebGUI::International::get(287).'</td><td class="tableHeader">'.WebGUI::International::get(296).'</td></tr>';
                $output .= $dataRows;
                $output .= '</table>';
                $output .= $prevNextBar;
	}
	return $output;
}

#-------------------------------------------------------------------
sub www_viewSubmission {
	my ($output, %submission);
	tie %submission, 'Tie::CPHash';
	%submission = WebGUI::SQL->quickHash("select * from UserSubmission_submission where submissionId=$session{form}{sid}",$session{dbh});
       	$output = "<h1>".$submission{title}."</h1>";
	$output .= '<table width="100%" cellpadding=2 cellspacing=1 border=0>';
	$output .= '<tr><td class="tableHeader">';
  #---header
	$output .= '<b>'.WebGUI::International::get(297).'</b> <a href="'.$session{page}{url}.'?op=viewProfile&uid='.$submission{userId}.'">'.$submission{username}.'</a><br>';
	$output .= '<b>'.WebGUI::International::get(298).'</b> '.epochToHuman($submission{dateSubmitted},"%w, %c %D, %y at %H:%n%p");
	$output .= '</td><td rowspan="2" class="tableMenu" nowrap valign="top">';
  #---menu
        $output .= '<a href="'.$session{page}{url}.'">'.WebGUI::International::get(303).'</a><br>';
        if ($submission{userId} == $session{user}{userId}) {
                $output .= '<a href="'.$session{page}{url}.'?func=deleteSubmission&wid='.$session{form}{wid}.'&sid='.$session{form}{sid}.'">'.WebGUI::International::get(186).'</a><br>';
                $output .= '<a href="'.$session{page}{url}.'?func=editSubmission&wid='.$session{form}{wid}.'&sid='.$session{form}{sid}.'">'.WebGUI::International::get(302).'</a><br>';
        }
        if ($submission{status} eq "Pending" && (WebGUI::Privilege::isInGroup(3,$session{user}{userId}) || WebGUI::Privilege::isInGroup(4,$session{user}{userId}))) {
                $output .= '<a href="'.$session{page}{url}.'?func=approveSubmission&wid='.$session{form}{wid}.'&sid='.$session{form}{sid}.'&mlog='.$session{form}{mlog}.'">'.WebGUI::International::get(299).'</a><br>';
                $output .= '<a href="'.$session{page}{url}.'?op=viewMessageLog">'.WebGUI::International::get(300).'</a><br>';
                $output .= '<a href="'.$session{page}{url}.'?func=denySubmission&wid='.$session{form}{wid}.'&sid='.$session{form}{sid}.'&mlog='.$session{form}{mlog}.'">'.WebGUI::International::get(301).'</a><br>';
        }
	$output .= '</td</tr><tr><td class="tableData">';
  #---content
	if ($submission{image} ne "") {
		$output .= '<img src="'.$session{setting}{attachmentDirectoryWeb}.'/'.$session{form}{wid}.'/'.$session{form}{sid}.'/'.$submission{image}.'" hspace=3 align="right">';
	}
	if ($submission{convertCarriageReturns}) {
		$submission{content} =~ s/\n/\<br\>/g;
	}	
	$output .= $submission{content}.'<p>';
	if ($submission{attachment} ne "") {
               	$output .= '<p><a href="'.$session{setting}{attachmentDirectoryWeb}.'/'.$session{form}{wid}.'/'.$session{form}{sid}.'/'.$submission{attachment}.'"><img src="'.$session{setting}{lib}.'/attachment.gif" border=0 alt="Download Attachment"></a><p>';
        }		
	$output .= '</td></tr></table>';
	return $output;
}



1;

