package WebGUI::Widget::UserSubmission;

our $namespace = "UserSubmission";

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black Software.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use Tie::CPHash;
use WebGUI::Attachment;
use WebGUI::DateTime;
use WebGUI::International;
use WebGUI::Macro;
use WebGUI::MessageLog;
use WebGUI::Operation;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::Shortcut;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::Utility;
use WebGUI::Widget;

#-------------------------------------------------------------------
sub duplicate {
        my ($sth, %data, $newWidgetId, @row, $newSubmissionId, $pageId);
        tie %data, 'Tie::CPHash';
        %data = getProperties($namespace,$_[0]);
	$pageId = $_[1] || $data{pageId};
        $newWidgetId = create($pageId,$namespace,$data{title},$data{displayTitle},$data{description},$data{processMacros},$data{templatePosition});
	WebGUI::SQL->write("insert into UserSubmission values ($newWidgetId, $data{groupToContribute}, '$data{submissionsPerPage}', '$data{defaultStatus}', $data{groupToApprove})");
        $sth = WebGUI::SQL->read("select * from UserSubmission_submission where widgetId=$_[0]");
        while (@row = $sth->array) {
                $newSubmissionId = getNextId("submissionId");
		WebGUI::Attachment::copy($row[8],$_[0],$newWidgetId,$row[1],$newSubmissionId);
                WebGUI::SQL->write("insert into UserSubmission_submission values ($newWidgetId, $newSubmissionId, ".quote($row[2]).", $row[3], ".quote($row[4]).", '$row[5]', ".quote($row[6]).", ".quote($row[7]).", ".quote($row[8]).", '$row[9]', '$row[10]')");
        }
        $sth->finish;
}

#-------------------------------------------------------------------
sub purge {
        WebGUI::SQL->write("delete from UserSubmission_submission where widgetId=$_[0]",$_[1]);
        purgeWidget($_[0],$_[1],$namespace);
}

#-------------------------------------------------------------------
sub widgetName {
	return WebGUI::International::get(29,$namespace);
}

#-------------------------------------------------------------------
sub www_add {
        my ($output, %hash, @array);
	tie %hash, "Tie::IxHash";
      	if (WebGUI::Privilege::canEditPage()) {
                $output = helpLink(1,$namespace);
		$output .= '<h1>'.WebGUI::International::get(30,$namespace).'</h1>';
		$output .= formHeader();
                $output .= WebGUI::Form::hidden("widget",$namespace);
                $output .= WebGUI::Form::hidden("func","addSave");
                $output .= '<table>';
                $output .= tableFormRow(WebGUI::International::get(99),WebGUI::Form::text("title",20,128,'User Submission System'));
                $output .= tableFormRow(WebGUI::International::get(174),WebGUI::Form::checkbox("displayTitle",1,1));
                $output .= tableFormRow(WebGUI::International::get(175),WebGUI::Form::checkbox("processMacros",1));
		%hash = WebGUI::Widget::getPositions();
                $output .= tableFormRow(WebGUI::International::get(363),WebGUI::Form::selectList("templatePosition",\%hash));
                $output .= tableFormRow(WebGUI::International::get(85),WebGUI::Form::textArea("description",'',50,5,1));
                $output .= tableFormRow(WebGUI::International::get(1,$namespace),
			WebGUI::Form::groupList("groupToApprove",4));
                $output .= tableFormRow(WebGUI::International::get(2,$namespace),
			WebGUI::Form::groupList("groupToContribute",2));
                $output .= tableFormRow(WebGUI::International::get(6,$namespace),WebGUI::Form::text("submissionsPerPage",20,2,50));
                %hash = ("Approved"=>WebGUI::International::get(7,$namespace),"Denied"=>WebGUI::International::get(8,$namespace),"Pending"=>WebGUI::International::get(9,$namespace));
                $output .= tableFormRow(WebGUI::International::get(10,$namespace),WebGUI::Form::selectList("defaultStatus",\%hash,'',1));
                $output .= formSave();
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
		$widgetId = create($session{page}{pageId},$session{form}{widget},$session{form}{title},$session{form}{displayTitle},$session{form}{description},$session{form}{processMacros},$session{form}{templatePosition});
		WebGUI::SQL->write("insert into UserSubmission values ($widgetId, $session{form}{groupToContribute}, '$session{form}{submissionsPerPage}', '$session{form}{defaultStatus}', $session{form}{groupToApprove})");
		return "";
	} else {
		return WebGUI::Privilege::insufficient();
	}
}

#-------------------------------------------------------------------
sub www_addSubmission {
        my ($output, $groupToContribute, @submission, $sth);
	($groupToContribute) = WebGUI::SQL->quickArray("select groupToContribute from UserSubmission where widgetId=$session{form}{wid}");
        if (WebGUI::Privilege::isInGroup($groupToContribute,$session{user}{userId})) {
                $output = '<h1>'.WebGUI::International::get(11,$namespace).'</h1>';
		$output .= formHeader();
                $output .= WebGUI::Form::hidden("wid",$session{form}{wid});
                $output .= WebGUI::Form::hidden("func","addSubmissionSave");
                $output .= '<table>';
                $output .= tableFormRow(WebGUI::International::get(35,$namespace),WebGUI::Form::text("title",20,128));
                $output .= tableFormRow(WebGUI::International::get(31,$namespace),WebGUI::Form::textArea("content",'',50,10,1));
                $output .= tableFormRow(WebGUI::International::get(32,$namespace),WebGUI::Form::file("image"));
                $output .= tableFormRow(WebGUI::International::get(33,$namespace),WebGUI::Form::file("attachment"));
                $output .= tableFormRow(WebGUI::International::get(34,$namespace),WebGUI::Form::checkbox("convertCarriageReturns",1,1).' <span style="font-size: 8pt;">'.WebGUI::International::get(12,$namespace).'</span>');
                $output .= formSave();
                $output .= '</table></form>';
                $output .= '<table width="100%" cellspacing=1 cellpadding=2 border=0>';
                $output .= '<tr><td class="tableHeader">'.WebGUI::International::get(15,$namespace).'</td><td class="tableHeader">'.WebGUI::International::get(99).'</td><td class="tableHeader">'.WebGUI::International::get(13,$namespace).'</td><td class="tableHeader">'.WebGUI::International::get(14,$namespace).'</td></tr>';
                $sth = WebGUI::SQL->read("select title,submissionId,dateSubmitted,status from UserSubmission_submission where widgetId='$session{form}{wid}' and userId=$session{user}{userId} order by dateSubmitted desc");
                while (@submission = $sth->array) {
                        $output .= '<tr><td class="tableData"><a href="'.WebGUI::URL::page('func=editSubmission&wid='.
				$session{form}{wid}.'&sid='.$submission[1]).'"><img src="'.$session{setting}{lib}.
				'/edit.gif" border=0></a><a href="'.WebGUI::URL::page('wid='.$session{form}{wid}.
				'&sid='.$submission[1].'&func=deleteSubmission').'"><img src="'.$session{setting}{lib}
				.'/delete.gif" border=0></a></td><td class="tableData"><a href="'.
				WebGUI::URL::page('wid='.$session{form}{wid}.'&func=viewSubmission&sid='.
				$submission[1]).'">'.$submission[0].'</a></td><td class="tableData">'.
				epochToHuman($submission[2],"%M/%D/%y").'</td><td class="tableData">'.
				$submission[3].'</td></tr>';
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
	%userSubmission = getProperties($namespace,$session{form}{wid});
        if (WebGUI::Privilege::isInGroup($userSubmission{groupToContribute},$session{user}{userId})) {
                $submissionId = getNextId("submissionId");
                $image = WebGUI::Attachment::save("image",$session{form}{wid},$submissionId);
                $attachment = WebGUI::Attachment::save("attachment",$session{form}{wid},$submissionId);
		if ($session{form}{title} ne "") {
			$title = $session{form}{title};
		} else {
			$title = WebGUI::International::get(16,$namespace);
		}
                WebGUI::SQL->write("insert into UserSubmission_submission values ($session{form}{wid}, $submissionId, ".quote($title).", ".time().", ".quote($session{user}{username}).", '$session{user}{userId}', ".quote($session{form}{content}).", ".quote($image).", ".quote($attachment).", '$userSubmission{defaultStatus}', '$session{form}{convertCarriageReturns}')");
		if ($userSubmission{defaultStatus} ne "Approved") {
			WebGUI::MessageLog::addEntry('',$userSubmission{groupToApprove},
				WebGUI::URL::page('func=viewSubmission&wid='.$session{form}{wid}.
					'&sid='.$submissionId),3,$namespace);
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
		%submission = WebGUI::SQL->quickHash("select * from UserSubmission_submission where submissionId=$session{form}{sid}");
		%userSubmission = getProperties($namespace,$session{form}{wid});;
                WebGUI::SQL->write("update UserSubmission_submission set status='Approved' where submissionId=$session{form}{sid}");
		WebGUI::MessageLog::addEntry($submission{userId},'',WebGUI::URL::page('func=viewSubmission&wid='.
			$session{form}{wid}.'&sid='.$session{form}{sid}),4,$namespace);
		WebGUI::MessageLog::completeEntry($session{form}{mlog});
                return WebGUI::Operation::www_viewMessageLog();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_copy {
        if (WebGUI::Privilege::canEditPage()) {
                duplicate($session{form}{wid});
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteAttachment {
	my ($owner);
	($owner) = WebGUI::SQL->quickArray("select userId from UserSubmission_submission where submissionId=$session{form}{sid}");
        if ($owner == $session{user}{userId}) {
                WebGUI::SQL->write("update UserSubmission_submission set attachment='' where submissionId=$session{form}{sid}");
                return www_editSubmission();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteImage {
	my ($owner);
	($owner) = WebGUI::SQL->quickArray("select userId from UserSubmission_submission where submissionId=$session{form}{sid}");
        if ($owner == $session{user}{userId}) {
                WebGUI::SQL->write("update UserSubmission_submission set image='' where submissionId=$session{form}{sid}");
                return www_editSubmission();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteSubmission {
	my ($output, $owner);
	($owner) = WebGUI::SQL->quickArray("select userId from UserSubmission_submission where submissionId=$session{form}{sid}");
        if ($owner == $session{user}{userId}) {
		$output = '<h1>'.WebGUI::International::get(42).'</h1>';
		$output .= WebGUI::International::get(17,$namespace).'<p>';
		$output .= '<div align="center"><a href="'.WebGUI::URL::page('func=deleteSubmissionConfirm&wid='.
			$session{form}{wid}.'&sid='.$session{form}{sid}).'">'.WebGUI::International::get(44).'</a>';
		$output .= ' &nbsp; <a href="'.WebGUI::URL::page().'">'.WebGUI::International::get(45).'</a></div>';
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteSubmissionConfirm {
        my ($output, $owner);
	($owner) = WebGUI::SQL->quickArray("select userId from UserSubmission_submission where submissionId=$session{form}{sid}");
        if ($owner == $session{user}{userId}) {
		WebGUI::SQL->write("delete from UserSubmission_submission where submissionId=$session{form}{sid}");
                return www_addSubmission();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_denySubmission {
	my (%submission, %userSubmission);
        if (WebGUI::Privilege::isInGroup(4,$session{user}{userId}) || WebGUI::Privilege::isInGroup(3,$session{user}{userId})) {
		%submission = WebGUI::SQL->quickHash("select * from UserSubmission_submission where submissionId=$session{form}{sid}");
                %userSubmission = getProperties($namespace,$session{form}{wid});
                WebGUI::SQL->write("update UserSubmission_submission set status='Denied' where submissionId=$session{form}{sid}");
                WebGUI::MessageLog::addEntry($submission{userId},'',WebGUI::URL::page('func=viewSubmission&wid='.
			$session{form}{wid}.'&sid='.$session{form}{sid}),5,$namespace);
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
		%data = getProperties($namespace,$session{form}{wid});
                $output = helpLink(1,$namespace);
		$output .= '<h1>'.WebGUI::International::get(18,$namespace).'</h1>';
		$output .= formHeader();
                $output .= WebGUI::Form::hidden("wid",$session{form}{wid});
                $output .= WebGUI::Form::hidden("func","editSave");
                $output .= '<table>';
                $output .= tableFormRow(WebGUI::International::get(99),WebGUI::Form::text("title",20,128,$data{title}));
                $output .= tableFormRow(WebGUI::International::get(174),WebGUI::Form::checkbox("displayTitle","1",$data{displayTitle}));
                $output .= tableFormRow(WebGUI::International::get(175),WebGUI::Form::checkbox("processMacros","1",$data{processMacros}));
		%hash = WebGUI::Widget::getPositions();
                $array[0] = $data{templatePosition};
                $output .= tableFormRow(WebGUI::International::get(363),WebGUI::Form::selectList("templatePosition",\%hash,\@array));
                $output .= tableFormRow(WebGUI::International::get(85),WebGUI::Form::textArea("description",$data{description}));
                $output .= tableFormRow(WebGUI::International::get(1,$namespace),
			WebGUI::Form::groupList("groupToApprove",$data{groupToApprove}));
                $output .= tableFormRow(WebGUI::International::get(2,$namespace),
			WebGUI::Form::groupList("groupToContribute",$data{groupToContribute}));
                $output .= tableFormRow(WebGUI::International::get(6,$namespace),WebGUI::Form::text("submissionsPerPage",20,2,$data{submissionsPerPage}));
                %hash = ("Approved"=>WebGUI::International::get(7,$namespace),"Denied"=>WebGUI::International::get(8,$namespace),"Pending"=>WebGUI::International::get(9,$namespace));
		$array[0] = $data{defaultStatus};
                $output .= tableFormRow(WebGUI::International::get(10,$namespace),WebGUI::Form::selectList("defaultStatus",\%hash,\@array,1));
                $output .= formSave();
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
		WebGUI::SQL->write("update UserSubmission set groupToContribute=$session{form}{groupToContribute}, groupToApprove=$session{form}{groupToApprove}, submissionsPerPage=$session{form}{submissionsPerPage}, defaultStatus='$session{form}{defaultStatus}' where widgetId=$session{form}{wid}");
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_editSubmission {
        my ($output, %submission, $owner);
	tie %submission, 'Tie::CPHash';
	($owner) = WebGUI::SQL->quickArray("select userId from UserSubmission_submission where submissionId=$session{form}{sid}");
        if ($owner == $session{user}{userId}) {
                %submission = WebGUI::SQL->quickHash("select * from UserSubmission_submission where submissionId='$session{form}{sid}'");
                $output = '<h1>'.WebGUI::International::get(19,$namespace).'</h1>';
		$output .= formHeader();
                $output .= WebGUI::Form::hidden("wid",$session{form}{wid});
                $output .= WebGUI::Form::hidden("sid",$session{form}{sid});
                $output .= WebGUI::Form::hidden("func","editSubmissionSave");
                $output .= '<table>';
                $output .= tableFormRow(WebGUI::International::get(35,$namespace),WebGUI::Form::text("title",20,128,$submission{title}));
                $output .= tableFormRow(WebGUI::International::get(31,$namespace),WebGUI::Form::textArea("content",$submission{content},50,10));
                if ($submission{image} ne "") {
                        $output .= tableFormRow(WebGUI::International::get(32,$namespace),'<a href="'.
				WebGUI::URL::page('func=deleteImage&wid='.$session{form}{wid}.'&sid='.
					$session{form}{sid}).'">'.WebGUI::International::get(36,$namespace).'</a>');
                } else {
                        $output .= tableFormRow(WebGUI::International::get(32,$namespace),WebGUI::Form::file("image"));
                }
                if ($submission{attachment} ne "") {
                        $output .= tableFormRow(WebGUI::International::get(33,$namespace),'<a href="'.
				WebGUI::URL::page('func=deleteAttachment&wid='.$session{form}{wid}.'&sid='.
				$session{form}{sid}).'">'.WebGUI::International::get(36,$namespace).'</a>');
                } else {
                        $output .= tableFormRow(WebGUI::International::get(33,$namespace),WebGUI::Form::file("attachment"));
                }
                $output .= tableFormRow(WebGUI::International::get(34,$namespace),WebGUI::Form::checkbox("convertCarriageReturns",1,$submission{convertCarriageReturns}).' <span style="font-size: 8pt;">(uncheck if you\'re writing an HTML submission)</span>');
                $output .= formSave();
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
	($owner) = WebGUI::SQL->quickArray("select userId from UserSubmission_submission where submissionId=$session{form}{sid}");
        if ($owner == $session{user}{userId}) {
		%userSubmission = getProperties($namespace,$session{form}{wid});
                $image = WebGUI::Attachment::save("image",$session{form}{wid},$session{form}{sid});
		if ($image ne "") {
			$image = 'image='.quote($image).', ';
		}
                $attachment = WebGUI::Attachment::save("attachment",$session{form}{wid},$session{form}{sid});
                if ($attachment ne "") {
                        $attachment = 'attachment='.quote($attachment).', ';
                }
                if ($session{form}{title} ne "") {
                        $title = $session{form}{title};
                } else {
                        $title = WebGUI::International::get(16,$namespace);
                }
                WebGUI::SQL->write("update UserSubmission_submission set dateSubmitted=".time().", convertCarriageReturns='$session{form}{convertCarriageReturns}', title=".quote($title).", content=".quote($session{form}{content}).", ".$image.$attachment." status='$userSubmission{defaultStatus}' where submissionId=$session{form}{sid}");
		if ($userSubmission{defaultStatus} ne "Approved") {
			WebGUI::MessageLog::addEntry('',$userSubmission{groupToApprove},
				WebGUI::URL::page('func=viewSubmission&wid='.$session{form}{wid}.'&sid='.
				$session{form}{sid}),3,$namespace);
		}
                return www_viewSubmission();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_view {
	my (%data, @submission, $output, $sth, @row, $i, $dataRows, $prevNextBar);
	tie %data, 'Tie::CPHash';
	%data = getProperties($namespace,$_[0]);
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
		$sth = WebGUI::SQL->read("select title,submissionId,dateSubmitted,username,userId from UserSubmission_submission where widgetId='$_[0]' and status='Approved' order by dateSubmitted desc");
		while (@submission = $sth->array) {
			$row[$i] = '<tr><td class="tableData"><a href="'.WebGUI::URL::page('wid='.$_[0].
				'&func=viewSubmission&sid='.$submission[1]).'">'.$submission[0].
				'</a></td><td class="tableData">'.epochToHuman($submission[2],"%M/%D/%y").
				'</td><td class="tableData"><a href="'.WebGUI::URL::page('op=viewProfile&uid='.
				$submission[4]).'">'.$submission[3].'</a></td></tr>';
			$i++;
		}
		$sth->finish;
		$output .= '<table width="100%" cellpadding=2 cellspacing=1 border=0><tr>'.
			'<td align="right" class="tableMenu"><a href="'.WebGUI::URL::page('func=addSubmission&wid='.
			$_[0]).'">'.WebGUI::International::get(20,$namespace).'</a></td></tr></table>';
                ($dataRows, $prevNextBar) = paginate($data{submissionsPerPage},WebGUI::URL::page(),\@row);
		$output .= '<table width="100%" cellspacing=1 cellpadding=2 border=0>';
		$output .= '<tr><td class="tableHeader">'.WebGUI::International::get(99).'</td><td class="tableHeader">'.WebGUI::International::get(13,$namespace).'</td><td class="tableHeader">'.WebGUI::International::get(21,$namespace).'</td></tr>';
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
	%submission = WebGUI::SQL->quickHash("select * from UserSubmission_submission where submissionId=$session{form}{sid}");
       	$output = "<h1>".$submission{title}."</h1>";
	$output .= '<table width="100%" cellpadding=2 cellspacing=1 border=0>';
	$output .= '<tr><td class="tableHeader">';
  #---header
	$output .= '<b>'.WebGUI::International::get(22,$namespace).'</b> <a href="'.
		WebGUI::URL::page('op=viewProfile&uid='.$submission{userId}).'">'.$submission{username}.'</a><br>';
	$output .= '<b>'.WebGUI::International::get(23,$namespace).'</b> '.epochToHuman($submission{dateSubmitted},"%w, %c %D, %y at %H:%n%p");
	$output .= '</td><td rowspan="2" class="tableMenu" nowrap valign="top">';
  #---menu
        $output .= '<a href="'.WebGUI::URL::page().'">'.WebGUI::International::get(28,$namespace).'</a><br>';
        if ($submission{userId} == $session{user}{userId}) {
                $output .= '<a href="'.WebGUI::URL::page('func=deleteSubmission&wid='.$session{form}{wid}.'&sid='.
			$session{form}{sid}).'">'.WebGUI::International::get(37,$namespace).'</a><br>';
                $output .= '<a href="'.WebGUI::URL::page('func=editSubmission&wid='.$session{form}{wid}.'&sid='.
			$session{form}{sid}).'">'.WebGUI::International::get(27,$namespace).'</a><br>';
        }
        if ($submission{status} eq "Pending" && (WebGUI::Privilege::isInGroup(3,$session{user}{userId}) || WebGUI::Privilege::isInGroup(4,$session{user}{userId}))) {
                $output .= '<a href="'.WebGUI::URL::page('func=approveSubmission&wid='.$session{form}{wid}.
			'&sid='.$session{form}{sid}.'&mlog='.$session{form}{mlog}).'">'.
			WebGUI::International::get(24,$namespace).'</a><br>';
                $output .= '<a href="'.WebGUI::URL::page('op=viewMessageLog').'">'.
			WebGUI::International::get(25,$namespace).'</a><br>';
                $output .= '<a href="'.WebGUI::URL::page('func=denySubmission&wid='.$session{form}{wid}.
			'&sid='.$session{form}{sid}.'&mlog='.$session{form}{mlog}).'">'.
			WebGUI::International::get(26,$namespace).'</a><br>';
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
               	$output .= attachmentBox($submission{attachment},$session{form}{wid},$session{form}{sid});
        }		
	$output .= '</td></tr></table>';
	return $output;
}



1;

