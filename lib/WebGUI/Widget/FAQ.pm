package WebGUI::Widget::FAQ;

our $namespace = "FAQ";

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
use WebGUI::International;
use WebGUI::Macro;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::Shortcut;
use WebGUI::SQL;
use WebGUI::Widget;

#-------------------------------------------------------------------
sub _reorderQuestions {
        my ($sth, $i, $qid);
        $sth = WebGUI::SQL->read("select questionId from FAQ_question where widgetId=$_[0] order by sequenceNumber");
        while (($qid) = $sth->array) {
                WebGUI::SQL->write("update FAQ_question set sequenceNumber='$i' where questionId=$qid");
                $i++;
        }
        $sth->finish;
}

#-------------------------------------------------------------------
sub duplicate {
        my ($sth, %data, $newWidgetId, $pageId, @row, $newQuestionId);
        tie %data, 'Tie::CPHash';
        %data = getProperties($namespace,$_[0]);
	$pageId = $_[1] || $data{pageId};
        $newWidgetId = create($pageId,$namespace,$data{title},$data{displayTitle},$data{description},$data{processMacros},$data{templatePosition});
	WebGUI::SQL->write("insert into FAQ values ($newWidgetId)");
        $sth = WebGUI::SQL->read("select * from FAQ_question where widgetId=$_[0]");
        while (@row = $sth->array) {
                $newQuestionId = getNextId("questionId");
        	WebGUI::SQL->write("insert into FAQ_question values ($newWidgetId, $newQuestionId, ".quote($row[2]).", ".quote($row[3]).", '$row[4]')");
        }
        $sth->finish;
}

#-------------------------------------------------------------------
sub purge {
        WebGUI::SQL->write("delete from FAQ_question where widgetId=$_[0]",$_[1]);
        purgeWidget($_[0],$_[1],$namespace);
}

#-------------------------------------------------------------------
sub widgetName {
	return WebGUI::International::get(2,$namespace);
}

#-------------------------------------------------------------------
sub www_add {
        my ($output, %hash);
	tie %hash, 'Tie::IxHash';
      	if (WebGUI::Privilege::canEditPage()) {
		$output = helpLink(1,$namespace);
                $output .= '<h1>'.WebGUI::International::get(3,$namespace).'</h1>';
		$output .= formHeader();
                $output .= WebGUI::Form::hidden("widget",$namespace);
                $output .= WebGUI::Form::hidden("func","addSave");
                $output .= '<table>';
                $output .= tableFormRow(WebGUI::International::get(99),WebGUI::Form::text("title",20,128,'F.A.Q.'));
                $output .= tableFormRow(WebGUI::International::get(174),WebGUI::Form::checkbox("displayTitle",1,1));
                $output .= tableFormRow(WebGUI::International::get(175),WebGUI::Form::checkbox("processMacros",1));
		%hash = WebGUI::Widget::getPositions();
                $output .= tableFormRow(WebGUI::International::get(363),WebGUI::Form::selectList("templatePosition",\%hash));
                $output .= tableFormRow(WebGUI::International::get(85),WebGUI::Form::textArea("description",'','','',1));
                $output .= tableFormRow(WebGUI::International::get(1,$namespace),WebGUI::Form::checkbox("proceed",1,1));
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
		WebGUI::SQL->write("insert into FAQ values ($widgetId)");
		if ($session{form}{proceed} == 1) {
			$session{form}{wid} = $widgetId;
			return www_addQuestion();
		} else {
			return "";
		}
	} else {
		return WebGUI::Privilege::insufficient();
	}
}

#-------------------------------------------------------------------
sub www_addQuestion {
        my ($output);
        if (WebGUI::Privilege::canEditPage()) {
                $output = '<h1>'.WebGUI::International::get(4,$namespace).'</h1>';
		$output .= formHeader();
                $output .= WebGUI::Form::hidden("wid",$session{form}{wid});
                $output .= WebGUI::Form::hidden("func","addQuestionSave");
                $output .= '<table>';
                $output .= tableFormRow(WebGUI::International::get(5,$namespace),WebGUI::Form::textArea("question",'',50,3));
                $output .= tableFormRow(WebGUI::International::get(6,$namespace),WebGUI::Form::textArea("answer",'',50,10,1));
                $output .= formSave();
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
		($nextSeq) = WebGUI::SQL->quickArray("select max(sequenceNumber)+1 from FAQ_question where widgetId=$session{form}{wid}");
                $questionId = getNextId("questionId");
                WebGUI::SQL->write("insert into FAQ_question values ($session{form}{wid}, $questionId, ".quote($session{form}{question}).", ".quote($session{form}{answer}).", '$nextSeq')");
                return www_edit();
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
sub www_deleteQuestion {
	my ($output);
        if (WebGUI::Privilege::canEditPage()) {
		$output = '<h1>'.WebGUI::International::get(42).'</h1>';
		$output .= WebGUI::International::get(7,$namespace).'<p>';
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
		WebGUI::SQL->write("delete from FAQ_question where questionId=$session{form}{qid}");
		_reorderQuestions($session{form}{wid});
                return www_edit();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_edit {
        my ($output, %hash, @array, %data, @question, $sth);
	tie %data, 'Tie::CPHash';
	tie %hash, 'Tie::IxHash';
        if (WebGUI::Privilege::canEditPage()) {
		%data = getProperties($namespace,$session{form}{wid});
		$output = helpLink(1,$namespace);
                $output = '<h1>'.WebGUI::International::get(8,$namespace).'</h1>';
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
                $output .= tableFormRow(WebGUI::International::get(85),WebGUI::Form::textArea("description",$data{description},'','',1));
                $output .= formSave();
                $output .= '</table></form>';
                $output .= '<p><a href="'.$session{page}{url}.'?func=addQuestion&wid='.$session{form}{wid}.'">'.WebGUI::International::get(9,$namespace).'</a><p>';
                $output .= '<table border=1 cellpadding=3 cellspacing=0>';
		$sth = WebGUI::SQL->read("select questionId,question from FAQ_question where widgetId='$session{form}{wid}' order by sequenceNumber");
		while (@question = $sth->array) {
                	$output .= '<tr><td><a href="'.$session{page}{url}.'?func=editQuestion&wid='.$session{form}{wid}.'&qid='.$question[0].'"><img src="'.$session{setting}{lib}.'/edit.gif" border=0></a><a href="'.$session{page}{url}.'?func=deleteQuestion&wid='.$session{form}{wid}.'&qid='.$question[0].'"><img src="'.$session{setting}{lib}.'/delete.gif" border=0></a><a href="'.$session{page}{url}.'?func=moveQuestionUp&wid='.$session{form}{wid}.'&qid='.$question[0].'"><img src="'.$session{setting}{lib}.'/upArrow.gif" border=0></a><a href="'.$session{page}{url}.'?func=moveQuestionDown&wid='.$session{form}{wid}.'&qid='.$question[0].'"><img src="'.$session{setting}{lib}.'/downArrow.gif" border=0></a></td><td>'.$question[1].'</td><tr>';
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
                %question = WebGUI::SQL->quickHash("select * from FAQ_question where questionId='$session{form}{qid}'");
                $output = '<h1>'.WebGUI::International::get(10,$namespace).'</h1>';
		$output .= formHeader();
                $output .= WebGUI::Form::hidden("wid",$session{form}{wid});
                $output .= WebGUI::Form::hidden("qid",$session{form}{qid});
                $output .= WebGUI::Form::hidden("func","editQuestionSave");
                $output .= '<table>';
                $output .= tableFormRow(WebGUI::International::get(5,$namespace),WebGUI::Form::textArea("question",$question{question},50,3));
                $output .= tableFormRow(WebGUI::International::get(6,$namespace),WebGUI::Form::textArea("answer",$question{answer},50,10,1));
                $output .= formSave();
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
                WebGUI::SQL->write("update FAQ_question set question=".quote($session{form}{question}).", answer=".quote($session{form}{answer})." where questionId=$session{form}{qid}");
                return www_edit();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_moveQuestionDown {
        my (@data, $thisSeq);
        if (WebGUI::Privilege::canEditPage()) {
                ($thisSeq) = WebGUI::SQL->quickArray("select sequenceNumber from FAQ_question where questionId=$session{form}{qid}");
                @data = WebGUI::SQL->quickArray("select questionId from FAQ_question where widgetId=$session{form}{wid} and sequenceNumber=$thisSeq+1 group by widgetId");
                if ($data[0] ne "") {
                        WebGUI::SQL->write("update FAQ_question set sequenceNumber=sequenceNumber+1 where questionId=$session{form}{qid}");
                        WebGUI::SQL->write("update FAQ_question set sequenceNumber=sequenceNumber-1 where questionId=$data[0]");
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
                ($thisSeq) = WebGUI::SQL->quickArray("select sequenceNumber from FAQ_question where questionId=$session{form}{qid}");
                @data = WebGUI::SQL->quickArray("select questionId from FAQ_question where widgetId=$session{form}{wid} and sequenceNumber=$thisSeq-1 group by widgetId");
                if ($data[0] ne "") {
                        WebGUI::SQL->write("update FAQ_question set sequenceNumber=sequenceNumber-1 where questionId=$session{form}{qid}");
                        WebGUI::SQL->write("update FAQ_question set sequenceNumber=sequenceNumber+1 where questionId=$data[0]");
                }
                return www_edit();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_view {
	my (%data, @question, $output, $sth, $qNa);
	tie %data, 'Tie::CPHash';
	%data = getProperties($namespace,$_[0]);
	if (defined %data) {
		if ($data{displayTitle} == 1) {
			$output = "<h1>".$data{title}."</h1>";
		}
		if ($data{description} ne "") {
			$output .= $data{description};
		}
		$output .= '<ul>';
		$sth = WebGUI::SQL->read("select questionId,question,answer from FAQ_question where widgetId='$_[0]' order by sequenceNumber");
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
