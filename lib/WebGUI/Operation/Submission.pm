package WebGUI::Operation::Submission;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001 Plain Black Software.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use Exporter;
use strict;
use WebGUI::DateTime;
use WebGUI::International;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Utility;

our @ISA = qw(Exporter);
our @EXPORT = qw(&www_viewPendingSubmissions &www_approveSubmission &www_denySubmission);

#-------------------------------------------------------------------
sub www_approveSubmission {
	if (WebGUI::Privilege::isInGroup(4,$session{user}{userId}) || WebGUI::Privilege::isInGroup(3,$session{user}{userId})) {
		WebGUI::SQL->write("update UserSubmission_submission set status='Approved' where submissionId=$session{form}{sid}",$session{dbh});
		return www_viewPendingSubmissions();
	} else {
		return WebGUI::Privilege::insufficient();
	}
}

#-------------------------------------------------------------------
sub www_denySubmission {
        if (WebGUI::Privilege::isInGroup(4,$session{user}{userId}) || WebGUI::Privilege::isInGroup(3,$session{user}{userId})) {
                WebGUI::SQL->write("update UserSubmission_submission set status='Denied' where submissionId=$session{form}{sid}",$session{dbh}
);
                return www_viewPendingSubmissions();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_viewPendingSubmissions {
        my (@submission, $output, $sth, @row, $i, $pn);
	if (WebGUI::Privilege::isInGroup(4,$session{user}{userId}) || WebGUI::Privilege::isInGroup(3,$session{user}{userId})) {
		$output = '<h1>'.WebGUI::International::get(159).'</h1>';
        	$sth = WebGUI::SQL->read("select title,submissionId,dateSubmitted,username,userId,widgetId from UserSubmission_submission where status='Pending' order by dateSubmitted",$session{dbh});
        	while (@submission = $sth->array) {
                	$row[$i] = '<tr><td class="tableData"><a href="'.$session{page}{url}.'?wid='.$submission[5].'&func=viewSubmission&sid='.$submission[1].'">'.$submission[0].'</a></td><td class="tableData">'.epochToHuman($submission[2],"%m/%d/%Y").'</td><td class="tableData">'.$submission[3].'</td></tr>';
                	$i++;
        	}
        	$sth->finish;
        	$output .= '<table width="100%" cellspacing=1 cellpadding=2 border=0>';
        	$output .= '<tr><td class="tableHeader">'.WebGUI::International::get(99).'</td><td class="tableHeader">'.WebGUI::International::get(160).'</td><td class="tableHeader">'.WebGUI::International::get(161).'</td></tr>';
        	if ($session{form}{pn} < 1) {
                	$pn = 0;
        	} else {
                	$pn = $session{form}{pn};
        	}
        	for ($i=(50*$pn); $i<(50*($pn+1));$i++) {
                	$output .= $row[$i];
        	}
        	$output .= '</table>';
        	$output .= '<div class="pagination">';
        	if ($pn > 0) {
                	$output .= '<a href="'.$session{page}{url}.'?pn='.($pn-1).'&op=viewPendingSubmissions">&laquo;'.WebGUI::International::get(91).'</a>';
        	} else {
                	$output .= '&laquo;'.WebGUI::International::get(91);
        	}
        	$output .= ' &middot; ';
        	if ($pn < round($#row/50)) {
                	$output .= '<a href="'.$session{page}{url}.'?pn='.($pn+1).'&op=viewPendingSubmissions">'.WebGUI::International::get(92).'&raquo;</a>';
        	} else {
                	$output .= WebGUI::International::get(92).'&raquo;';
        	}
            	$output .= '</div>';
	} else {
		$output = WebGUI::Privilege::insufficient();
	}
        return $output;
}


1;
