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
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Utility;
use WebGUI::Widget;

#-------------------------------------------------------------------
sub widgetName {
	return "User Submission System";
}

#-------------------------------------------------------------------
sub www_add {
        my ($output, %hash);
	tie %hash, "Tie::IxHash";
      	if (WebGUI::Privilege::canEditPage()) {
                $output = '<h1>Add User Submission System</h1><form method="post" enctype="multipart/form-data" action="'.$session{page}{url}.'">';
                $output .= WebGUI::Form::hidden("widget","UserSubmission");
                $output .= WebGUI::Form::hidden("func","addSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">Title</td><td>'.WebGUI::Form::text("title",20,30,'User Submission System').'</td></tr>';
                $output .= '<tr><td class="formDescription">Display the title?</td><td>'.WebGUI::Form::checkbox("displayTitle","1").'</td></tr>';
                $output .= '<tr><td class="formDescription">Description</td><td>'.WebGUI::Form::textArea("description",'',50,5,1).'</td></tr>';
                %hash = WebGUI::SQL->buildHash("select groupId,groupName from groups where groupName<>'Reserved' order by groupName",$session{dbh});
                $output .= '<tr><td class="formDescription" valign="top">Who can contribute?</td><td>'.WebGUI::Form::selectList("groupToContribute",\%hash,'',1).'</td></tr>';
                $output .= '<tr><td class="formDescription">Submissions Per Page</td><td>'.WebGUI::Form::text("submissionsPerPage",20,2,50).'</td></tr>';
                %hash = ("Approved"=>"Approved","Denied"=>"Denied","Pending"=>"Pending");
                $output .= '<tr><td class="formDescription" valign="top">Default Status</td><td>'.WebGUI::Form::selectList("defaultStatus",\%hash,'',1).'</td></tr>';
                $output .= '<tr><td></td><td>'.WebGUI::Form::submit("save").'</td></tr>';
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
		WebGUI::SQL->write("insert into UserSubmission set widgetId=$widgetId, groupToContribute=$session{form}{groupToContribute}, submissionsPerPage=$session{form}{submissionsPerPage}, defaultStatus='$session{form}{defaultStatus}'",$session{dbh});
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
                $output = '<h1>Add Submission</h1><form method="post" enctype="multipart/form-data" action="'.$session{page}{url}.'">';
                $output .= WebGUI::Form::hidden("wid",$session{form}{wid});
                $output .= WebGUI::Form::hidden("func","addSubmissionSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">Title</td><td>'.WebGUI::Form::text("title",20,30).'</td></tr>';
                $output .= '<tr><td class="formDescription">Content</td><td>'.WebGUI::Form::textArea("content",'',50,10,1).'</td></tr>';
                $output .= '<tr><td class="formDescription">Image</td><td>'.WebGUI::Form::file("image").'</td></tr>';
                $output .= '<tr><td class="formDescription">Attachment</td><td>'.WebGUI::Form::file("attachment").'</td></tr>';
                $output .= '<tr><td></td><td>'.WebGUI::Form::submit("save").'</td></tr>';
                $output .= '</table></form>';
                $output .= '<table width="100%" cellspacing=1 cellpadding=2 border=0>';
                $output .= '<tr><td class="tableHeader">Edit/Delete</td><td class="tableHeader">Title</td><td class="tableHeader">Date Submitted</td><td class="tableHeader">Status</td></tr>';
                $sth = WebGUI::SQL->read("select title,submissionId,date_format(dateSubmitted,'%c/%e %l:%i%p'),status from submission where widgetId='$session{form}{wid}' and userId=$session{user}{userId} order by dateSubmitted desc",$session{dbh});
                while (@submission = $sth->array) {
                        $output .= '<tr><td class="tableData"><a href="'.$session{page}{url}.'?func=editSubmission&wid='.$session{form}{wid}.'&sid='.$submission[1].'"><img src="'.$session{setting}{lib}.'/edit.gif" border=0></a><a href="'.$session{page}{url}.'?wid='.$session{form}{wid}.'&sid='.$submission[1].'&func=deleteSubmission"><img src="'.$session{setting}{lib}.'/delete.gif" border=0></a></td><td class="tableData"><a href="'.$session{page}{url}.'?wid='.$session{form}{wid}.'&func=viewSubmission&sid='.$submission[1].'">'.$submission[0].'</a></td><td class="tableData">'.$submission[2].'</td><td class="tableData">'.$submission[3].'</td></tr>';
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
        my ($submissionId, $image, $attachment, $status, $groupToContribute);
	($status, $groupToContribute) = WebGUI::SQL->quickArray("select defaultStatus,groupToContribute from UserSubmission where widgetId=$session{form}{wid}",$session{dbh});
        if (WebGUI::Privilege::isInGroup($groupToContribute,$session{user}{userId})) {
                $submissionId = getNextId("submissionId");
                $image = saveAttachment("image",$session{form}{wid},$submissionId);
                $attachment = saveAttachment("attachment",$session{form}{wid},$submissionId);
                WebGUI::SQL->write("insert into submission set widgetId=$session{form}{wid}, submissionId=$submissionId, title=".quote($session{form}{title}).", username=".quote($session{user}{username}).", status='$status', dateSubmitted=now(), userId='$session{user}{userId}', content=".quote($session{form}{content}).", image=".quote($image).", attachment=".quote($attachment),$session{dbh});
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
		$output = '<h1>Please Confirm</h1>';
		$output .= 'Are you certain that you want to delete this submission?<p><div align="center"><a href="'.$session{page}{url}.'?func=deleteSubmissionConfirm&wid='.$session{form}{wid}.'&sid='.$session{form}{sid}.'">Yes, I\'m sure.</a> &nbsp; <a href="'.$session{page}{url}.'">No, I made a mistake.</a></div>';
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
        if (WebGUI::Privilege::canEditPage()) {
		%data = WebGUI::SQL->quickHash("select * from widget,UserSubmission where widget.widgetId=$session{form}{wid} and widget.widgetId=UserSubmission.widgetId",$session{dbh});
                $output = '<h1>Edit User Submission System</h1><form method="post" enctype="multipart/form-data" action="'.$session{page}{url}.'">';
                $output .= WebGUI::Form::hidden("wid",$session{form}{wid});
                $output .= WebGUI::Form::hidden("func","editSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">Title</td><td>'.WebGUI::Form::text("title",20,30,$data{title}).'</td></tr>';
                $output .= '<tr><td class="formDescription">Display the title?</td><td>'.WebGUI::Form::checkbox("displayTitle","1",$data{displayTitle}).'</td></tr>';
                $output .= '<tr><td class="formDescription">Description</td><td>'.WebGUI::Form::textArea("description",$data{description}).'</td></tr>';
		$array[0] = $data{groupToContribute};
		%hash = WebGUI::SQL->buildHash("select groupId,groupName from groups where groupName<>'Reserved' order by groupName",$session{dbh});
                $output .= '<tr><td class="formDescription" valign="top">Who can contribute?</td><td>'.WebGUI::Form::selectList("groupToContribute",\%hash,\@array,1).'</td></tr>';
                $output .= '<tr><td class="formDescription">Submissions Per Page</td><td>'.WebGUI::Form::text("submissionsPerPage",20,2,$data{submissionsPerPage}).'</td></tr>';
                %hash = ("Approved"=>"Approved","Denied"=>"Denied","Pending"=>"Pending");
		$array[0] = $data{defaultStatus};
                $output .= '<tr><td class="formDescription" valign="top">Default Status</td><td>'.WebGUI::Form::selectList("defaultStatus",\%hash,\@array,1).'</td></tr>';
                $output .= '<tr><td></td><td>'.WebGUI::Form::submit("save").'</td></tr>';
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
	($owner) = WebGUI::SQL->quickArray("select userId from submission where submissionId=$session{form}{sid}",$session{dbh});
        if ($owner == $session{user}{userId}) {
                %submission = WebGUI::SQL->quickHash("select * from submission where submissionId='$session{form}{sid}'",$session{dbh});
                $output = '<h1>Edit Submission</h1><form method="post" enctype="multipart/form-data" action="'.$session{page}{url}.'">';
                $output .= WebGUI::Form::hidden("wid",$session{form}{wid});
                $output .= WebGUI::Form::hidden("sid",$session{form}{sid});
                $output .= WebGUI::Form::hidden("func","editSubmissionSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">Title</td><td>'.WebGUI::Form::text("title",20,30,$submission{title}).'</td></tr>';
                $output .= '<tr><td class="formDescription">Content</td><td>'.WebGUI::Form::textArea("content",$submission{content},50,10).'</td></tr>';
                if ($submission{image} ne "") {
                        $output .= '<tr><td class="formDescription">Image</td><td><a href="'.$session{page}{url}.'?func=deleteImage&wid='.$session{form}{wid}.'&sid='.$session{form}{sid}.'">Delete Image</a></td></tr>';
                } else {
                        $output .= '<tr><td class="formDescription">Image</td><td>'.WebGUI::Form::file("image").'</td></tr>';
                }
                if ($submission{attachment} ne "") {
                        $output .= '<tr><td class="formDescription">Attachment</td><td><a href="'.$session{page}{url}.'?func=deleteAttachment&wid='.$session{form}{wid}.'&sid='.$session{form}{sid}.'">Delete Attachment</a></td></tr>';
                } else {
                        $output .= '<tr><td class="formDescription">Attachment</td><td>'.WebGUI::Form::file("attachment").'</td></tr>';
                }
                $output .= '<tr><td></td><td>'.WebGUI::Form::submit("save").'</td></tr>';
                $output .= '</table></form>';
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_editSubmissionSave {
	my ($owner,$status,$image,$attachment);
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
                WebGUI::SQL->write("update submission set title=".quote($session{form}{title}).", content=".quote($session{form}{content}).", ".$image.$attachment." status='$status' where submissionId=$session{form}{sid}",$session{dbh});
                return www_viewSubmission();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_view {
	my (%data, @submission, $output, $widgetId, $sth, @row, $i, $pn);
	$widgetId = shift;
	%data = WebGUI::SQL->quickHash("select * from widget,UserSubmission where widget.widgetId=$widgetId and widget.widgetId=UserSubmission.widgetId",$session{dbh});
	if (%data) {
		if ($data{displayTitle} == 1) {
			$output = "<h2>".$data{title}."</h2>";
		}
		if ($data{description} ne "") {
			$output .= $data{description}.'<p>';
		}
		$sth = WebGUI::SQL->read("select title,submissionId,date_format(dateSubmitted,'%c/%e %l:%i%p'),username,userId from submission where widgetId='$widgetId' and status='Approved' order by dateSubmitted desc",$session{dbh});
		while (@submission = $sth->array) {
			$row[$i] = '<tr><td class="tableData"><a href="'.$session{page}{url}.'?wid='.$widgetId.'&func=viewSubmission&sid='.$submission[1].'">'.$submission[0].'</a></td><td class="tableData">'.$submission[2].'</td><td class="tableData">'.$submission[3].'</td></tr>';
			$i++;
		}
		$sth->finish;
		$output .= '<table width="100%"><tr><td align="right"><a href="'.$session{page}{url}.'?func=addSubmission&wid='.$widgetId.'">Post New Submission</a></td></tr></table>';
		$output .= '<table width="100%" cellspacing=1 cellpadding=2 border=0>';
		$output .= '<tr><td class="tableHeader">Title</td><td class="tableHeader">Date Submitted</td><td class="tableHeader">Submitted By</td></tr>';
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
                	$output .= '<a href="'.$session{page}{url}.'?pn='.($pn-1).'&wid='.$widgetId.'">&laquo;Previous Page</a>';
        	} else {
                	$output .= '&laquo;Previous Page';
        	}
        	$output .= ' &middot; ';
        	if ($pn < round($#row/$data{submissionsPerPage})) {
                	$output .= '<a href="'.$session{page}{url}.'?pn='.($pn+1).'&wid='.$widgetId.'">Next Page&raquo;</a>';
        	} else {
                	$output .= 'Next Page&raquo;';
        	}
        	$output .= '</div>';
	}
	return $output;
}

#-------------------------------------------------------------------
sub www_viewSubmission {
	my ($output, %submission);
	%submission = WebGUI::SQL->quickHash("select * from submission where submissionId=$session{form}{sid}",$session{dbh});
       	$output = "<h2>".$submission{title}."</h2>";
	$output .= '<b>Submitted By:</b> '.$submission{username}.'<br>';
	$output .= '<b>Date Submitted:</b> '.$submission{dateSubmitted}.'<p>';
	if ($submission{image} ne "") {
		$output .= '<img src="'.$session{setting}{attachmentDirectoryWeb}.'/'.$session{form}{wid}.'/'.$session{form}{sid}.'/'.$submission{image}.'" hspace=3 align="right">';
	}
	if ($submission{status} eq "Pending" && (WebGUI::Privilege::isInGroup(3,$session{user}{userId}) || WebGUI::Privilege::isInGroup(4,$session{user}{userId}))) {
		$output .= '<div align="center">';
                $output .= '<a href="'.$session{page}{url}.'?op=approveSubmission&sid='.$session{form}{sid}.'">Approve</a> &middot; ';
                $output .= '<a href="'.$session{page}{url}.'?op=viewPendingSubmissions">Leave Pending</a> &middot; ';
                $output .= '<a href="'.$session{page}{url}.'?op=denySubmission&sid='.$session{form}{sid}.'">Deny</a> ';
		$output .= '</div>';
        }	
	$output .= $submission{content}.'<p>';
	if ($submission{attachment} ne "") {
               	$output .= '<p><a href="'.$session{setting}{attachmentDirectoryWeb}.'/'.$session{form}{wid}.'/'.$session{form}{sid}.'/'.$submission{attachment}.'"><img src="'.$session{setting}{lib}.'/attachment.gif" border=0 alt="Download Attachment"></a><p>';
        }		
	$output .= '<div align="center">';
	if ($submission{userId} == $session{user}{userId}) {
		$output .= '<a href="'.$session{page}{url}.'?func=deleteSubmission&wid='.$session{form}{wid}.'&sid='.$session{form}{sid}.'">Delete</a> &middot; ';
		$output .= '<a href="'.$session{page}{url}.'?func=editSubmission&wid='.$session{form}{wid}.'&sid='.$session{form}{sid}.'">Edit</a> &middot; ';
	}
	$output .= '<a href="'.$session{page}{url}.'">Return To Submissions List</a>';
	$output .= '</div>';
	return $output;
}






1;

