package WebGUI::Widget::FAQ;

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
use WebGUI::Macro;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Utility;
use WebGUI::Widget;

#-------------------------------------------------------------------
sub _reorderQuestions {
        my ($sth, $i, $qid);
        $sth = WebGUI::SQL->read("select questionId from faqQuestion where widgetId=$_[0] order by sequenceNumber",$session{dbh});
        while (($qid) = $sth->array) {
                WebGUI::SQL->write("update faqQuestion set sequenceNumber='$i' where questionId=$qid",$session{dbh});
                $i++;
        }
        $sth->finish;
}

#-------------------------------------------------------------------
sub widgetName {
	return "F.A.Q.";
}

#-------------------------------------------------------------------
sub www_add {
        my ($output);
      	if (WebGUI::Privilege::canEditPage()) {
                $output = '<h1>Add F.A.Q.</h1><form method="post" enctype="multipart/form-data" action="'.$session{page}{url}.'">';
                $output .= WebGUI::Form::hidden("widget","FAQ");
                $output .= WebGUI::Form::hidden("func","addSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">Title</td><td>'.WebGUI::Form::text("title",20,30).'</td></tr>';
                $output .= '<tr><td class="formDescription">Display the title?</td><td>'.WebGUI::Form::checkbox("displayTitle",1,1).'</td></tr>';
                $output .= '<tr><td class="formDescription">Process Macros?</td><td>'.WebGUI::Form::checkbox("processMacros",1,1).'</td></tr>';
                $output .= '<tr><td class="formDescription">Description</td><td>'.WebGUI::Form::textArea("description").'</td></tr>';
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
		return "";
	} else {
		return WebGUI::Privilege::insufficient();
	}
}

#-------------------------------------------------------------------
sub www_addQuestion {
        my ($output);
        if (WebGUI::Privilege::canEditPage()) {
                $output = '<h1>Add Question</h1><form method="post" enctype="multipart/form-data" action="'.$session{page}{url}.'">';
                $output .= WebGUI::Form::hidden("wid",$session{form}{wid});
                $output .= WebGUI::Form::hidden("func","addQuestionSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">Question</td><td>'.WebGUI::Form::textArea("question",'',50,3).'</td></tr>';
                $output .= '<tr><td class="formDescription">Answer</td><td>'.WebGUI::Form::textArea("answer").'</td></tr>';
                $output .= '<tr><td></td><td>'.WebGUI::Form::submit("save").'</td></tr>';
                $output .= '</table></form>';
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_addQuestionSave {
        my ($questionId, $nextSeq);
        if (WebGUI::Privilege::canEditPage()) {
		($nextSeq) = WebGUI::SQL->quickArray("select max(sequenceNumber)+1 from faqQuestion where widgetId=$session{form}{wid}",$session{dbh});
                $questionId = getNextId("questionId");
                WebGUI::SQL->write("insert into faqQuestion set widgetId=$session{form}{wid}, questionId=$questionId, sequenceNumber='$nextSeq', question=".quote($session{form}{question}).", answer=".quote($session{form}{answer}),$session{dbh});
                return www_edit();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteQuestion {
	my ($output);
        if (WebGUI::Privilege::canEditPage()) {
		$output = '<h1>Please Confirm</h1>';
		$output = 'Are you certain that you want to delete this question?<p><div align="center"><a href="'.$session{page}{url}.'?func=deleteQuestionConfirm&wid='.$session{form}{wid}.'&lid='.$session{form}{lid}.'">Yes, I\'m sure.</a> &nbsp; <a href="'.$session{page}{url}.'?func=edit&wid='.$session{form}{wid}.'">No, I made a mistake.</a></div>';
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteQuestionConfirm {
        my ($output);
        if (WebGUI::Privilege::canEditPage()) {
		WebGUI::SQL->write("delete from faqQuestions where questionId=$session{form}{qid}",$session{dbh});
		_reorderQuestions($session{form}{wid});
                return www_edit();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_edit {
        my ($output, %data, @question, $sth);
        if (WebGUI::Privilege::canEditPage()) {
		%data = WebGUI::SQL->quickHash("select * from widget where widget.widgetId=$session{form}{wid}",$session{dbh});
                $output = '<h1>Edit Link List</h1><form method="post" enctype="multipart/form-data" action="'.$session{page}{url}.'">';
                $output .= WebGUI::Form::hidden("wid",$session{form}{wid});
                $output .= WebGUI::Form::hidden("func","editSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">Title</td><td>'.WebGUI::Form::text("title",20,30,$data{title}).'</td></tr>';
                $output .= '<tr><td class="formDescription">Display the title?</td><td>'.WebGUI::Form::checkbox("displayTitle","1",$data{displayTitle}).'</td></tr>';
                $output .= '<tr><td class="formDescription">Process macros?</td><td>'.WebGUI::Form::checkbox("processMacros","1",$data{processMacros}).'</td></tr>';
                $output .= '<tr><td class="formDescription">Description</td><td>'.WebGUI::Form::textArea("description",$data{description}).'</td></tr>';
                $output .= '<tr><td></td><td>'.WebGUI::Form::submit("save").'</td></tr>';
                $output .= '</table></form>';
                $output .= '<p><a href="'.$session{page}{url}.'?func=addQuestion&wid='.$session{form}{wid}.'">Add New Question</a><p>';
                $output .= '<table border=1 cellpadding=3 cellspacing=0>';
		$sth = WebGUI::SQL->read("select questionId,question from faqQuestion where widgetId='$session{form}{wid}' order by sequenceNumber",$session{dbh});
		while (@question = $sth->array) {
                	$output .= '<tr><td><a href="'.$session{page}{url}.'?func=editQuestion&wid='.$session{form}{wid}.'&qid='.$question[0].'"><img src="'.$session{setting}{lib}.'/edit.gif" border=0></a><a href="'.$session{page}{url}.'?func=deleteQuestion&wid='.$session{form}{wid}.'&qid='.$question[0].'"><img src="'.$session{setting}{lib}.'/delete.gif" border=0></a><a href="'.$session{page}{url}.'?func=moveQuestionUp&wid='.$session{form}{wid}.'&qid='.$question[0].'"><img src="'.$session{setting}{lib}.'/upArrow.gif" border=0></a><a href="'.$session{page}{url}.'?func=moveQuestionDown&wid='.$session{form}{wid}.'&qid='.$question[0].'"><img src="'.$session{setting}{lib}.'/downArrow.gif" border=0></a></td><td>'.$question[1].'</td></tr>';
		}
		$sth->finish;
                $output .= '</table>';
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_editSave {
        if (WebGUI::Privilege::canEditPage()) {
		update();
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_editQuestion {
        my ($output, %question);
        if (WebGUI::Privilege::canEditPage()) {
                %question = WebGUI::SQL->quickHash("select * from faqQuestion where questionId='$session{form}{qid}'",$session{dbh});
                $output = '<h1>Edit Question</h1><form method="post" enctype="multipart/form-data" action="'.$session{page}{url}.'">';
                $output .= WebGUI::Form::hidden("wid",$session{form}{wid});
                $output .= WebGUI::Form::hidden("qid",$session{form}{qid});
                $output .= WebGUI::Form::hidden("func","editQuestionSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">Question</td><td>'.WebGUI::Form::textArea("question",$question{question},50,3).'</td></tr>';
                $output .= '<tr><td class="formDescription">Answer</td><td>'.WebGUI::Form::textArea("answer",$question{answer}).'</td></tr>';
                $output .= '<tr><td></td><td>'.WebGUI::Form::submit("save").'</td></tr>';
                $output .= '</table></form>';
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_editQuestionSave {
        if (WebGUI::Privilege::canEditPage()) {
                WebGUI::SQL->write("update faqQuestion set question=".quote($session{form}{question}).", answer=".quote($session{form}{answer})." where questionId=$session{form}{qid}",$session{dbh});
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_moveQuestionDown {
        my (@data, $thisSeq);
        if (WebGUI::Privilege::canEditPage()) {
                ($thisSeq) = WebGUI::SQL->quickArray("select sequenceNumber from faqQuestion where questionId=$session{form}{qid}",$session{dbh});
                @data = WebGUI::SQL->quickArray("select questionId from faqQuestion where widgetId=$session{form}{wid} and sequenceNumber=$thisSeq+1 group by widgetId",$session{dbh});
                if ($data[0] ne "") {
                        WebGUI::SQL->write("update faqQuestion set sequenceNumber=sequenceNumber+1 where questionId=$session{form}{qid}",$session{dbh});
                        WebGUI::SQL->write("update faqQuestion set sequenceNumber=sequenceNumber-1 where questionId=$data[0]",$session{dbh});
                }
                return www_edit();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_moveQuestionUp {
        my (@data, $thisSeq);
        if (WebGUI::Privilege::canEditPage()) {
                ($thisSeq) = WebGUI::SQL->quickArray("select sequenceNumber from faqQuestion where questionId=$session{form}{qid}",$session{dbh});
                @data = WebGUI::SQL->quickArray("select questionId from faqQuestion where widgetId=$session{form}{wid} and sequenceNumber=$thisSeq-1 group by widgetId",$session{dbh});
                if ($data[0] ne "") {
                        WebGUI::SQL->write("update faqQuestion set sequenceNumber=sequenceNumber-1 where questionId=$session{form}{qid}",$session{dbh});
                        WebGUI::SQL->write("update faqQuestion set sequenceNumber=sequenceNumber+1 where questionId=$data[0]",$session{dbh});
                }
                return www_edit();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_view {
	my (%data, @question, $output, $widgetId, $sth, $qNa);
	$widgetId = shift;
	%data = WebGUI::SQL->quickHash("select * from widget where widget.widgetId='$widgetId'",$session{dbh});
	if (defined %data) {
		if ($data{displayTitle} == 1) {
			$output = "<h2>".$data{title}."</h2>";
		}
		if ($data{description} ne "") {
			$output .= $data{description};
		}
		$output .= '<ul>';
		$sth = WebGUI::SQL->read("select questionId,question,answer from faqQuestion where widgetId='$widgetId' order by sequenceNumber",$session{dbh});
		while (@question = $sth->array) {
			$output .= '<li><a href="#'.$question[0].'">'.$question[1].'</a>';
			$qNa .= '<span class="faqQuestion"><a name="'.$question[0].'">'.$question[1].'</a></span><br>'.$question[2].'<p>';
		}
		$sth->finish;
		$output .= '</ul>'.$qNa;
	}
	if ($data{processMacros} == 1) {
		$output = WebGUI::Macro::process($output);
	}
	return $output;
}





1;
