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
use Tie::CPHash;
use WebGUI::International;
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
sub purge {
        WebGUI::SQL->write("delete from faqQuestion where widgetId=$_[0]",$_[1]);
        purgeWidget($_[0],$_[1]);
}

#-------------------------------------------------------------------
sub widgetName {
	return WebGUI::International::get(205);
}

#-------------------------------------------------------------------
sub www_add {
        my ($output);
      	if (WebGUI::Privilege::canEditPage()) {
		$output = '<a href="'.$session{page}{url}.'?op=viewHelp&hid=40"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a>';
                $output = '<h1>'.WebGUI::International::get(206).'</h1>';
		$output .= '<form method="post" enctype="multipart/form-data" action="'.$session{page}{url}.'">';
                $output .= WebGUI::Form::hidden("widget","FAQ");
                $output .= WebGUI::Form::hidden("func","addSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(99).'</td><td>'.WebGUI::Form::text("title",20,30,'F.A.Q.').'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(174).'</td><td>'.WebGUI::Form::checkbox("displayTitle",1,1).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(175).'</td><td>'.WebGUI::Form::checkbox("processMacros",1,1).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(85).'</td><td>'.WebGUI::Form::textArea("description").'</td></tr>';
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
		return "";
	} else {
		return WebGUI::Privilege::insufficient();
	}
}

#-------------------------------------------------------------------
sub www_addQuestion {
        my ($output);
        if (WebGUI::Privilege::canEditPage()) {
                $output = '<h1>'.WebGUI::International::get(207).'</h1>';
		$output .= '<form method="post" enctype="multipart/form-data" action="'.$session{page}{url}.'">';
                $output .= WebGUI::Form::hidden("wid",$session{form}{wid});
                $output .= WebGUI::Form::hidden("func","addQuestionSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(208).'</td><td>'.WebGUI::Form::textArea("question",'',50,3).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(209).'</td><td>'.WebGUI::Form::textArea("answer").'</td></tr>';
                $output .= '<tr><td></td><td>'.WebGUI::Form::submit(WebGUI::International::get(62)).'</td></tr>';
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
                WebGUI::SQL->write("insert into faqQuestion values ($session{form}{wid}, $questionId, ".quote($session{form}{question}).", ".quote($session{form}{answer}).", '$nextSeq')",$session{dbh});
                return www_edit();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteQuestion {
	my ($output);
        if (WebGUI::Privilege::canEditPage()) {
		$output = '<h1>'.WebGUI::International::get(42).'</h1>';
		$output .= WebGUI::International::get(210).'<p>';
		$output .= '<div align="center"><a href="'.$session{page}{url}.'?func=deleteQuestionConfirm&wid='.$session{form}{wid}.'&qid='.$session{form}{qid}.'">'.WebGUI::International::get(44).'</a>';
		$output .= ' &nbsp; <a href="'.$session{page}{url}.'?func=edit&wid='.$session{form}{wid}.'">'.WebGUI::International::get(45).'</a></div>';
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteQuestionConfirm {
        my ($output);
        if (WebGUI::Privilege::canEditPage()) {
		WebGUI::SQL->write("delete from faqQuestion where questionId=$session{form}{qid}",$session{dbh});
		_reorderQuestions($session{form}{wid});
                return www_edit();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_edit {
        my ($output, %data, @question, $sth);
	tie %data, 'Tie::CPHash';
        if (WebGUI::Privilege::canEditPage()) {
		%data = WebGUI::SQL->quickHash("select * from widget where widget.widgetId=$session{form}{wid}",$session{dbh});
		$output = '<a href="'.$session{page}{url}.'?op=viewHelp&hid=41"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a>';
                $output = '<h1>'.WebGUI::International::get(211).'</h1>';
		$output .= '<form method="post" enctype="multipart/form-data" action="'.$session{page}{url}.'">';
                $output .= WebGUI::Form::hidden("wid",$session{form}{wid});
                $output .= WebGUI::Form::hidden("func","editSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(99).'</td><td>'.WebGUI::Form::text("title",20,30,$data{title}).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(174).'</td><td>'.WebGUI::Form::checkbox("displayTitle","1",$data{displayTitle}).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(175).'</td><td>'.WebGUI::Form::checkbox("processMacros","1",$data{processMacros}).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(85).'</td><td>'.WebGUI::Form::textArea("description",$data{description}).'</td></tr>';
                $output .= '<tr><td></td><td>'.WebGUI::Form::submit(WebGUI::International::get(62)).'</td></tr>';
                $output .= '</table></form>';
                $output .= '<p><a href="'.$session{page}{url}.'?func=addQuestion&wid='.$session{form}{wid}.'">'.WebGUI::International::get(212).'</a><p>';
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
	tie %question, 'Tie::CPHash';
        if (WebGUI::Privilege::canEditPage()) {
                %question = WebGUI::SQL->quickHash("select * from faqQuestion where questionId='$session{form}{qid}'",$session{dbh});
                $output = '<h1>'.WebGUI::International::get(213).'</h1>';
		$output .= '<form method="post" enctype="multipart/form-data" action="'.$session{page}{url}.'">';
                $output .= WebGUI::Form::hidden("wid",$session{form}{wid});
                $output .= WebGUI::Form::hidden("qid",$session{form}{qid});
                $output .= WebGUI::Form::hidden("func","editQuestionSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(208).'</td><td>'.WebGUI::Form::textArea("question",$question{question},50,3).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(209).'</td><td>'.WebGUI::Form::textArea("answer",$question{answer}).'</td></tr>';
                $output .= '<tr><td></td><td>'.WebGUI::Form::submit(WebGUI::International::get(62)).'</td></tr>';
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
                return www_edit();
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
	tie %data, 'Tie::CPHash';
	$widgetId = shift;
	%data = WebGUI::SQL->quickHash("select * from widget where widget.widgetId='$widgetId'",$session{dbh});
	if (defined %data) {
		if ($data{displayTitle} == 1) {
			$output = "<h1>".$data{title}."</h1>";
		}
		if ($data{description} ne "") {
			$output .= $data{description};
		}
		$output .= '<ul>';
		$sth = WebGUI::SQL->read("select questionId,question,answer from faqQuestion where widgetId='$widgetId' order by sequenceNumber",$session{dbh});
		while (@question = $sth->array) {
			$output .= '<li><a href="#'.$question[0].'">'.$question[1].'</a>';
			$qNa .= '<a name="'.$question[0].'"><span class="faqQuestion">'.$question[1].'</span></a><br>'.$question[2].'<p>';
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
