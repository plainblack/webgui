package WebGUI::Wobject::FAQ;

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
use WebGUI::HTMLForm;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::Wobject;

our @ISA = qw(WebGUI::Wobject);
our $namespace = "FAQ";
our $name = WebGUI::International::get(2,$namespace);


#-------------------------------------------------------------------
sub _reorderQuestions {
        my ($sth, $i, $qid);
        $sth = WebGUI::SQL->read("select questionId from FAQ_question where wobjectId=$_[0] order by sequenceNumber");
        while (($qid) = $sth->array) {
                WebGUI::SQL->write("update FAQ_question set sequenceNumber='$i' where questionId=$qid");
                $i++;
        }
        $sth->finish;
}

#-------------------------------------------------------------------
sub duplicate {
        my ($w, %data, $newQuestionId, $sth);
	tie %data, 'Tie::CPHash';
        $w = $_[0]->SUPER::duplicate($_[1]);
        $sth = WebGUI::SQL->read("select * from FAQ_question where wobjectId=".$_[0]->get("wobjectId"));
        while (%data = $sth->hash) {
                $newQuestionId = getNextId("questionId");
                WebGUI::SQL->write("insert into FAQ_question values ($w, $newQuestionId, "
			.quote($data{question}).", ".quote($data{answer}).", $data{sequenceNumber})");
        }
        $sth->finish;}

#-------------------------------------------------------------------
sub new {
        my ($self, $class, $property);
        $class = shift;
        $property = shift;
        $self = WebGUI::Wobject->new($property);
        bless $self, $class;
}

#-------------------------------------------------------------------
sub purge {
        WebGUI::SQL->write("delete from FAQ_question where wobjectId=".$_[0]->get("wobjectId"));
	$_[0]->SUPER::purge();
}

#-------------------------------------------------------------------
sub www_copy {
        if (WebGUI::Privilege::canEditPage()) {
                $_[0]->duplicate;
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
		$output .= '<div align="center"><a href="'.
			WebGUI::URL::page('func=deleteQuestionConfirm&wid='.$_[0]->get("wobjectId").
			'&qid='.$session{form}{qid}).'">'.WebGUI::International::get(44).'</a>';
		$output .= ' &nbsp; <a href="'.WebGUI::URL::page('func=edit&wid='.$_[0]->get("wobjectId"))
			.'">'.WebGUI::International::get(45).'</a></div>';
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
		_reorderQuestions($_[0]->get("wobjectId"));
                return $_[0]->www_edit();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_edit {
        my ($f, $output, @question, $sth);
        if (WebGUI::Privilege::canEditPage()) {
		$output = helpIcon(1,$namespace);
                $output = '<h1>'.WebGUI::International::get(8,$namespace).'</h1>';
		$f = WebGUI::HTMLForm->new;
		$f->yesNo("proceed",WebGUI::International::get(1,$namespace),1);
		$output = $_[0]->SUPER::www_edit($f->printRowsOnly);
		unless ($_[0]->get("wobjectId") eq "new") {
                	$output .= '<p><a href="'.WebGUI::URL::page('func=editQuestion&wid='.$_[0]->get("wobjectId"))
				.'">'.WebGUI::International::get(9,$namespace).'</a><p>';
                	$output .= '<table border=1 cellpadding=3 cellspacing=0>';
			$sth = WebGUI::SQL->read("select questionId,question from FAQ_question where wobjectId="
				.$_[0]->get("wobjectId")." order by sequenceNumber");
			while (@question = $sth->array) {
                		$output .= '<tr><td>'
					.editIcon('func=editQuestion&wid='.$_[0]->get("wobjectId").'&qid='.$question[0])
					.deleteIcon('func=deleteQuestion&wid='.$_[0]->get("wobjectId").'&qid='.$question[0])
					.moveUpIcon('func=moveQuestionUp&wid='.$_[0]->get("wobjectId").'&qid='.$question[0])
					.moveDownIcon('func=moveQuestionDown&wid='.$_[0]->get("wobjectId").'&qid='.$question[0])
					.'</td><td>'.$question[1].'</td><tr>';
			}
			$sth->finish;
                	$output .= '</table>';
		}
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_editSave {
        if (WebGUI::Privilege::canEditPage()) {
		$_[0]->SUPER::www_editSave();
		if ($session{form}{proceed}) {
			$_[0]->www_editQuestion();
		} else {
			return "";
		}
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_editQuestion {
        my ($output, %question, $f);
	tie %question, 'Tie::CPHash';
        if (WebGUI::Privilege::canEditPage()) {
                %question = WebGUI::SQL->quickHash("select * from FAQ_question where questionId='$session{form}{qid}'");
                $output = '<h1>'.WebGUI::International::get(10,$namespace).'</h1>';
		$f = WebGUI::HTMLForm->new;
		$f->hidden("wid",$_[0]->get("wobjectId"));
		$session{form}{qid} = "new" if ($session{form}{qid} eq "");
                $f->hidden("qid",$session{form}{qid});
                $f->hidden("func","editQuestionSave");
                $f->textarea("question",WebGUI::International::get(5,$namespace),$question{question});
                $f->HTMLArea("answer",WebGUI::International::get(6,$namespace),$question{answer});
		$f->yesNo("proceed",WebGUI::International::get(1,$namespace),1);
		$f->submit;
                $output .= $f->print;
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_editQuestionSave {
	my ($seq);
        if (WebGUI::Privilege::canEditPage()) {
		if ($session{form}{qid} eq "new") {
                	($seq) = WebGUI::SQL->quickArray("select max(sequenceNumber) from FAQ_question where wobjectId=".$_[0]->get("wobjectId"));
			$session{form}{qid} = getNextId("questionId");
			WebGUI::SQL->write("insert into FAQ_question (wobjectId,questionId,sequenceNumber) values 
				(".$_[0]->get("wobjectId").",$session{form}{qid},".($seq+1).")");
		}
                WebGUI::SQL->write("update FAQ_question set question=".quote($session{form}{question}).", 
			answer=".quote($session{form}{answer})." where questionId=$session{form}{qid}");
		if ($session{form}{proceed}) {
			$session{form}{qid} = "new";
			return $_[0]->www_editQuestion();
		} else {
                	return $_[0]->www_edit();
		}
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_moveQuestionDown {
        my (@data, $thisSeq);
        if (WebGUI::Privilege::canEditPage()) {
                ($thisSeq) = WebGUI::SQL->quickArray("select sequenceNumber from FAQ_question where questionId=$session{form}{qid}");
                @data = WebGUI::SQL->quickArray("select questionId from FAQ_question where wobjectId=".$_[0]->get("wobjectId")." and sequenceNumber=$thisSeq+1 group by wobjectId");
                if ($data[0] ne "") {
                        WebGUI::SQL->write("update FAQ_question set sequenceNumber=sequenceNumber+1 where questionId=$session{form}{qid}");
                        WebGUI::SQL->write("update FAQ_question set sequenceNumber=sequenceNumber-1 where questionId=$data[0]");
                }
                return $_[0]->www_edit();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_moveQuestionUp {
        my (@data, $thisSeq);
        if (WebGUI::Privilege::canEditPage()) {
                ($thisSeq) = WebGUI::SQL->quickArray("select sequenceNumber from FAQ_question where questionId=$session{form}{qid}");
                @data = WebGUI::SQL->quickArray("select questionId from FAQ_question where wobjectId=".$_[0]->get("wobjectId")." and sequenceNumber=$thisSeq-1 group by wobjectId");
                if ($data[0] ne "") {
                        WebGUI::SQL->write("update FAQ_question set sequenceNumber=sequenceNumber-1 where questionId=$session{form}{qid}");
                        WebGUI::SQL->write("update FAQ_question set sequenceNumber=sequenceNumber+1 where questionId=$data[0]");
                }
                return $_[0]->www_edit();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_view {
	my (@question, $output, $sth, $qNa);
	$output = $_[0]->displayTitle;
	$output .= $_[0]->description;
	$output .= '<ul>';
	$sth = WebGUI::SQL->read("select questionId,question,answer from FAQ_question where wobjectId=".$_[0]->get("wobjectId")." order by sequenceNumber");
	while (@question = $sth->array) {
		$output .= '<li><a href="#'.$question[0].'"><span class="faqQuestion">'.$question[1].'</span></a>';
		$qNa .= '<a name="'.$question[0].'"><span class="faqQuestion">'.$question[1].'</span></a><br>'.$question[2].'<p>';
	}
	$sth->finish;
	$output .= '</ul>'.$qNa;
	return $_[0]->processMacros($output);
}


1;
