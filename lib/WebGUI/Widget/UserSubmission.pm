package WebGUI::Widget::UserSubmission;

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
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Utility;
use WebGUI::Widget;

#-------------------------------------------------------------------
sub purge {
        WebGUI::SQL->write("delete from submission where widgetId=$_[0]",$_[1]);
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
                $output = '<a href="'.$session{page}{url}.'?op=viewHelp&hid=44"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a>';
		$output .= '<h1>'.WebGUI::International::get(278).'</h1>';
		$output .= '<form method="post" enctype="multipart/form-data" action="'.$session{page}{url}.'">';
                $output .= WebGUI::Form::hidden("widget","UserSubmission");
                $output .= WebGUI::Form::hidden("func","addSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(99).'</td><td>'.WebGUI::Form::text("title",20,30,'User Submission System').'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(174).'</td><td>'.WebGUI::Form::checkbox("displayTitle",1,1).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(175).'</td><td>'.WebGUI::Form::checkbox("processMacros",1).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(85).'</td><td>'.WebGUI::Form::textArea("description",'',50,5,1).'</td></tr>';
                %hash = WebGUI::SQL->buildHash("select groupId,groupName from groups where groupName<>'Reserved' order by groupName",$session{dbh});
		$array[0] = 2;
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(279).'</td><td>'.WebGUI::Form::selectList("groupToContribute",\%hash,\@array).'</td></tr>';
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
		WebGUI::SQL->write("insert into UserSubmission values ($widgetId, $session{form}{groupToContribute}, '$session{form}{submissionsPerPage}', '$session{form}{defaultStatus}')",$session{dbh});
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
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(99).'</td><td>'.WebGUI::Form::text("title",20,30).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(178).'</td><td>'.WebGUI::Form::textArea("content",'',50,10,1).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(179).'</td><td>'.WebGUI::Form::file("image").'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(182).'</td><td>'.WebGUI::Form::file("attachment").'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(183).'</td><td>'.WebGUI::Form::checkbox("convertCarriageReturns",1,1).' <span style="font-size: 8pt;">'.WebGUI::International::get(286).'</span></td></tr>';
                $output .= '<tr><td></td><td>'.WebGUI::Form::submit(WebGUI::International::get(62)).'</td></tr>';
                $output .= '</table></form>';
                $output .= '<table width="100%" cellspacing=1 cellpadding=2 border=0>';
                $output .= '<tr><td class="tableHeader">'.WebGUI::International::get(289).'</td><td class="tableHeader">'.WebGUI::International::get(99).'</td><td class="tableHeader">'.WebGUI::International::get(287).'</td><td class="tableHeader">'.WebGUI::International::get(288).'</td></tr>';
                $sth = WebGUI::SQL->read("select title,submissionId,dateSubmitted,status from submission where widgetId='$session{form}{wid}' and userId=$session{user}{userId} order by dateSubmitted desc",$session{dbh});
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
        my ($title, $submissionId, $image, $attachment, $status, $groupToContribute);
	($status, $groupToContribute) = WebGUI::SQL->quickArray("select defaultStatus,groupToContribute from UserSubmission where widgetId=$session{form}{wid}",$session{dbh});
        if (WebGUI::Privilege::isInGroup($groupToContribute,$session{user}{userId})) {
                $submissionId = getNextId("submissionId");
                $image = saveAttachment("image",$session{form}{wid},$submissionId);
                $attachment = saveAttachment("attachment",$session{form}{wid},$submissionId);
		if ($session{form}{title} ne "") {
			$title = $session{form}{title};
		} else {
			$title = WebGUI::International::get(290);
		}
                WebGUI::SQL->write("insert into submission values ($session{form}{wid}, $submissionId, ".quote($title).", ".time().", ".quote($session{user}{username}).", '$session{user}{userId}', ".quote($session{form}{content}).", ".quote($image).", ".quote($attachment).", '$status', '$session{form}{convertCarriageReturns}')",$session{dbh});
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteAttachment {
	my ($owner);
	($owner) = WebGUI::SQL->quickArray("select userId from submission where submissionId=$session{form}{sid}",$session{dbh});
        if ($owner == $session{user}{userId}) {
                WebGUI::SQL->write("update submission set attachment='' where widgetId=$session{form}{wid}",$session{dbh});
                return www_editSubmission();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteImage {
	my ($owner);
	($owner) = WebGUI::SQL->quickArray("select userId from submission where submissionId=$session{form}{sid}",$session{dbh});
        if ($owner == $session{user}{userId}) {
                WebGUI::SQL->write("update submission set image='' where widgetId=$session{form}{wid}",$session{dbh});
                return www_editSubmission();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteSubmission {
	my ($output, $owner);
	($owner) = WebGUI::SQL->quickArray("select userId from submission where submissionId=$session{form}{sid}",$session{dbh});
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
	($owner) = WebGUI::SQL->quickArray("select userId from submission where submissionId=$session{form}{sid}",$session{dbh});
        if ($owner == $session{user}{userId}) {
		WebGUI::SQL->write("delete from submission where submissionId=$session{form}{sid}",$session{dbh});
                return www_addSubmission();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_edit {
        my ($output, %data, @array, $sth, %hash);
	tie %data, 'Tie::CPHash';
        if (WebGUI::Privilege::canEditPage()) {
		%data = WebGUI::SQL->quickHash("select * from widget,UserSubmission where widget.widgetId=$session{form}{wid} and widget.widgetId=UserSubmission.widgetId",$session{dbh});
                $output = '<a href="'.$session{page}{url}.'?op=viewHelp&hid=44"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a>';
		$output .= '<h1>'.WebGUI::International::get(292).'</h1>';
		$output .= '<form method="post" enctype="multipart/form-data" action="'.$session{page}{url}.'">';
                $output .= WebGUI::Form::hidden("wid",$session{form}{wid});
                $output .= WebGUI::Form::hidden("func","editSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(99).'</td><td>'.WebGUI::Form::text("title",20,30,$data{title}).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(174).'</td><td>'.WebGUI::Form::checkbox("displayTitle","1",$data{displayTitle}).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(175).'</td><td>'.WebGUI::Form::checkbox("processMacros","1",$data{processMacros}).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(85).'</td><td>'.WebGUI::Form::textArea("description",$data{description}).'</td></tr>';
		$array[0] = $data{groupToContribute};
		%hash = WebGUI::SQL->buildHash("select groupId,groupName from groups where groupName<>'Reserved' order by groupName",$session{dbh});
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(279).'</td><td>'.WebGUI::Form::selectList("groupToContribute",\%hash,\@array,1).'</td></tr>';
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
		WebGUI::SQL->write("update UserSubmission set groupToContribute=$session{form}{groupToContribute}, submissionsPerPage=$session{form}{submissionsPerPage}, defaultStatus='$session{form}{defaultStatus}' where widgetId=$session{form}{wid}",$session{dbh});
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_editSubmission {
        my ($output, %submission, $owner);
	tie %submission, 'Tie::CPHash';
	($owner) = WebGUI::SQL->quickArray("select userId from submission where submissionId=$session{form}{sid}",$session{dbh});
        if ($owner == $session{user}{userId}) {
                %submission = WebGUI::SQL->quickHash("select * from submission where submissionId='$session{form}{sid}'",$session{dbh});
                $output = '<h1>'.WebGUI::International::get(293).'</h1>';
		$output .= '<form method="post" enctype="multipart/form-data" action="'.$session{page}{url}.'">';
                $output .= WebGUI::Form::hidden("wid",$session{form}{wid});
                $output .= WebGUI::Form::hidden("sid",$session{form}{sid});
                $output .= WebGUI::Form::hidden("func","editSubmissionSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(99).'</td><td>'.WebGUI::Form::text("title",20,30,$submission{title}).'</td></tr>';
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
	my ($owner,$status,$image,$attachment,$title);
	($owner) = WebGUI::SQL->quickArray("select userId from submission where submissionId=$session{form}{sid}",$session{dbh});
        if ($owner == $session{user}{userId}) {
		($status) = WebGUI::SQL->quickArray("select defaultStatus from UserSubmission where widgetId=$session{form}{wid}",$session{dbh});
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
                WebGUI::SQL->write("update submission set dateSubmitted=".time().", convertCarriageReturns='$session{form}{convertCarriageReturns}', title=".quote($title).", content=".quote($session{form}{content}).", ".$image.$attachment." status='$status' where submissionId=$session{form}{sid}",$session{dbh});
                return www_viewSubmission();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_view {
	my (%data, @submission, $output, $widgetId, $sth, @row, $i, $pn);
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
		$sth = WebGUI::SQL->read("select title,submissionId,dateSubmitted,username,userId from submission where widgetId='$widgetId' and status='Approved' order by dateSubmitted desc",$session{dbh});
		while (@submission = $sth->array) {
			$row[$i] = '<tr><td class="tableData"><a href="'.$session{page}{url}.'?wid='.$widgetId.'&func=viewSubmission&sid='.$submission[1].'">'.$submission[0].'</a></td><td class="tableData">'.epochToHuman($submission[2],"%M/%D/%y").'</td><td class="tableData">'.$submission[3].'</td></tr>';
			$i++;
		}
		$sth->finish;
		$output .= '<table width="100%"><tr><td align="right"><a href="'.$session{page}{url}.'?func=addSubmission&wid='.$widgetId.'">'.WebGUI::International::get(294).'</a></td></tr></table>';
		$output .= '<table width="100%" cellspacing=1 cellpadding=2 border=0>';
		$output .= '<tr><td class="tableHeader">'.WebGUI::International::get(99).'</td><td class="tableHeader">'.WebGUI::International::get(287).'</td><td class="tableHeader">'.WebGUI::International::get(295).'</td></tr>';
		if ($session{form}{pn} < 1) {
			$pn = 0;
		} else {
			$pn = $session{form}{pn}; 
		}
		for ($i=($data{submissionsPerPage}*$pn); $i<($data{submissionsPerPage}*($pn+1));$i++) {
			$output .= $row[$i];
		}
		$output .= '</table>';
        	$output .= '<div class="pagination">';
        	if ($pn > 0) {
                	$output .= '<a href="'.$session{page}{url}.'?pn='.($pn-1).'&wid='.$widgetId.'">&laquo;'.WebGUI::International::get(91).'</a>';
        	} else {
                	$output .= '&laquo;'.WebGUI::International::get(91);
        	}
        	$output .= ' &middot; ';
        	if ($pn < round($#row/$data{submissionsPerPage})) {
                	$output .= '<a href="'.$session{page}{url}.'?pn='.($pn+1).'&wid='.$widgetId.'">'.WebGUI::International::get(91).'&raquo;</a>';
        	} else {
                	$output .= WebGUI::International::get(92).'&raquo;';
        	}
        	$output .= '</div>';
	}
	return $output;
}

#-------------------------------------------------------------------
sub www_viewSubmission {
	my ($output, %submission);
	tie %submission, 'Tie::CPHash';
	%submission = WebGUI::SQL->quickHash("select * from submission where submissionId=$session{form}{sid}",$session{dbh});
       	$output = "<h1>".$submission{title}."</h1>";
	$output .= '<b>'.WebGUI::International::get(297).'</b> '.$submission{username}.'<br>';
	$output .= '<b>'.WebGUI::International::get(298).'</b> '.epochToHuman($submission{dateSubmitted},"%w, %c %D, %y at %H:%n%p").'<p>';
	if ($submission{image} ne "") {
		$output .= '<img src="'.$session{setting}{attachmentDirectoryWeb}.'/'.$session{form}{wid}.'/'.$session{form}{sid}.'/'.$submission{image}.'" hspace=3 align="right">';
	}
	if ($submission{status} eq "Pending" && (WebGUI::Privilege::isInGroup(3,$session{user}{userId}) || WebGUI::Privilege::isInGroup(4,$session{user}{userId}))) {
		$output .= '<div align="center">';
                $output .= '<a href="'.$session{page}{url}.'?op=approveSubmission&sid='.$session{form}{sid}.'">'.WebGUI::International::get(299).'</a> &middot; ';
                $output .= '<a href="'.$session{page}{url}.'?op=viewPendingSubmissions">'.WebGUI::International::get(300).'</a> &middot; ';
                $output .= '<a href="'.$session{page}{url}.'?op=denySubmission&sid='.$session{form}{sid}.'">'.WebGUI::International::get(301).'</a> ';
		$output .= '</div>';
        }
	if ($submission{convertCarriageReturns}) {
		$submission{content} =~ s/\n/\<br\>/g;
	}	
	$output .= $submission{content}.'<p>';
	if ($submission{attachment} ne "") {
               	$output .= '<p><a href="'.$session{setting}{attachmentDirectoryWeb}.'/'.$session{form}{wid}.'/'.$session{form}{sid}.'/'.$submission{attachment}.'"><img src="'.$session{setting}{lib}.'/attachment.gif" border=0 alt="Download Attachment"></a><p>';
        }		
	$output .= '<div align="center">';
	if ($submission{userId} == $session{user}{userId}) {
		$output .= '<a href="'.$session{page}{url}.'?func=deleteSubmission&wid='.$session{form}{wid}.'&sid='.$session{form}{sid}.'">'.WebGUI::International::get(186).'</a> &middot; ';
		$output .= '<a href="'.$session{page}{url}.'?func=editSubmission&wid='.$session{form}{wid}.'&sid='.$session{form}{sid}.'">'.WebGUI::International::get(302).'</a> &middot; ';
	}
	$output .= '<a href="'.$session{page}{url}.'">'.WebGUI::International::get(303).'</a>';
	$output .= '</div>';
	return $output;
}



1;

