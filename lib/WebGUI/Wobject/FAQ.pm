package WebGUI::Wobject::FAQ;

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
sub duplicate {
        my ($w, %data, $newQuestionId, $sth);
	tie %data, 'Tie::CPHash';
        $w = $_[0]->SUPER::duplicate($_[1]);
	$w = WebGUI::Wobject::FAQ->new({wobjectId=>$w,namespace=>$namespace});
	$w->set({
		topOn=>$_[0]->get("topOn"),
		tocOn=>$_[0]->get("tocOn"),
		qaOn=>$_[0]->get("qaOn")
		});
        $sth = WebGUI::SQL->read("select * from FAQ_question where wobjectId=".$_[0]->get("wobjectId"));
        while (%data = $sth->hash) {
                $newQuestionId = getNextId("FAQ_questionId");
                WebGUI::SQL->write("insert into FAQ_question values (".$w->get("wobjectId").", $newQuestionId, "
			.quote($data{question}).", ".quote($data{answer}).", $data{sequenceNumber})");
        }
        $sth->finish;
}

#-------------------------------------------------------------------
sub purge {
        WebGUI::SQL->write("delete from FAQ_question where wobjectId=".$_[0]->get("wobjectId"));
	$_[0]->SUPER::purge();
}

#-------------------------------------------------------------------
sub set {
        $_[0]->SUPER::set($_[1],[qw(templateId)]);
}

#-------------------------------------------------------------------
sub www_deleteQuestion {
        return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
	return $_[0]->confirm(WebGUI::International::get(7,$namespace),
		WebGUI::URL::page('func=deleteQuestionConfirm&wid='.$_[0]->get("wobjectId").'&qid='.$session{form}{qid}));
}

#-------------------------------------------------------------------
sub www_deleteQuestionConfirm {
        return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
	$_[0]->deleteCollateral("FAQ_question","FAQ_questionId",$session{form}{qid});
	$_[0]->reorderCollateral("FAQ_question","FAQ_questionId");
        return "";
}

#-------------------------------------------------------------------
sub www_edit {
        my ($f, $output, $template);
        return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
	$template = $_[0]->get("templateId") || 1;
	$output = helpIcon(1,$namespace);
        $output .= '<h1>'.WebGUI::International::get(8,$namespace).'</h1>';
	$f = WebGUI::HTMLForm->new;
	$f->template(
              	-name=>"templateId",
               	-value=>$template,
               	-namespace=>$namespace,
               	-label=>WebGUI::International::get(74,$namespace),
               	-afterEdit=>'func=edit&wid='.$_[0]->get("wobjectId")
               	);
	if ($_[0]->get("wobjectId") eq "new") {
		$f->whatNext(
                       	-options=>{
                               	addQuestion=>WebGUI::International::get(75,$namespace),
                               	backToPage=>WebGUI::International::get(745)
                               	},
                       	-value=>"addQuestion"
                       	);
	}
	$output .= $_[0]->SUPER::www_edit($f->printRowsOnly);
        return $output;
}

#-------------------------------------------------------------------
sub www_editSave {
        return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
	$_[0]->SUPER::www_editSave({
        	templateId=>$session{form}{templateId}
		});
	if ($session{form}{proceed} eq "addQuestion") {
		$session{form}{qid} = "new";
		return $_[0]->www_editQuestion();
	}
	return "";
}

#-------------------------------------------------------------------
sub www_editQuestion {
        my ($output, $question, $f);
        return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
        $question = $_[0]->getCollateral("FAQ_question","FAQ_questionId",$session{form}{qid});
	$output = helpIcon(2,$namespace);
        $output .= '<h1>'.WebGUI::International::get(10,$namespace).'</h1>';
	$f = WebGUI::HTMLForm->new;
	$f->hidden("wid",$_[0]->get("wobjectId"));
        $f->hidden("qid",$question->{FAQ_questionId});
        $f->hidden("func","editQuestionSave");
        $f->textarea(
		-name=>"question",
		-label=>WebGUI::International::get(5,$namespace),
		-value=>$question->{question}
		);
        $f->HTMLArea(
		-name=>"answer",
		-label=>WebGUI::International::get(6,$namespace),
		-value=>$question->{answer}
		);
	if ($question->{FAQ_questionId} eq "new") {
                $f->whatNext(
                	-options=>{
                        	addQuestion=>WebGUI::International::get(75,$namespace),
                                backToPage=>WebGUI::International::get(745)
                                },
                        -value=>"addQuestion"
                        );
        }
	$f->submit;
        $output .= $f->print;
        return $output;
}

#-------------------------------------------------------------------
sub www_editQuestionSave {
        return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
	$_[0]->setCollateral("FAQ_question", "FAQ_questionId", {
        	FAQ_questionId => $session{form}{qid},
                question => $session{form}{question},
                answer => $session{form}{answer}
                });
	if ($session{form}{proceed} eq "addQuestion") {
		$session{form}{qid} = "new";
		return $_[0]->www_editQuestion();
	}
        return "";
}

#-------------------------------------------------------------------
sub www_moveQuestionDown {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
	$_[0]->moveCollateralDown("FAQ_question","FAQ_questionId",$session{form}{qid});
	return "";
}

#-------------------------------------------------------------------
sub www_moveQuestionUp {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
	$_[0]->moveCollateralUp("FAQ_question","FAQ_questionId",$session{form}{qid});
	return "";
}

#-------------------------------------------------------------------
sub www_view {
	my (%question, $output, $controls, $sth, %var, @qa, @toc);
	tie %question,'Tie::CPHash';
	$output = $_[0]->displayTitle;
	if ($session{var}{adminOn}) {
		$var{addquestion} .= '<a href="'.WebGUI::URL::page('func=editQuestion&wid='.$_[0]->get("wobjectId")).'">'
			.WebGUI::International::get(9,$namespace).'</a>';
	}
	$sth = WebGUI::SQL->read("select * from FAQ_question where wobjectId=".$_[0]->get("wobjectId")." order by sequenceNumber");
	while (%question = $sth->hash) {
		push(@toc,{
			questionId=>$question{FAQ_questionId},
			question=>$question{question}
			});
		if ($session{var}{adminOn}) {
			$controls = deleteIcon('func=deleteQuestion&wid='.$_[0]->get("wobjectId").'&qid='.$question{FAQ_questionId})
				.editIcon('func=editQuestion&wid='.$_[0]->get("wobjectId").'&qid='.$question{FAQ_questionId})
				.moveUpIcon('func=moveQuestionUp&wid='.$_[0]->get("wobjectId").'&qid='.$question{FAQ_questionId})
				.moveDownIcon('func=moveQuestionDown&wid='.$_[0]->get("wobjectId").'&qid='.$question{FAQ_questionId})
				.' ';
		}
                push(@qa,{
                        questionId=>$question{FAQ_questionId},
                        answer=>$question{answer},
			question=>$question{question},
			controls=>$controls
                        });
	}
	$sth->finish;
	$var{toc_loop} = \@toc;
	$var{qa_loop} = \@qa;
	return $_[0]->processMacros($output.$_[0]->processTemplate($_[0]->get("templateId"),\%var));
}


1;
