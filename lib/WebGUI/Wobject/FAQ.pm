package WebGUI::Wobject::FAQ;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2003 Plain Black LLC.
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


#-------------------------------------------------------------------
sub duplicate {
        my ($w, %data, $newQuestionId, $sth);
	tie %data, 'Tie::CPHash';
        $w = $_[0]->SUPER::duplicate($_[1]);
        $sth = WebGUI::SQL->read("select * from FAQ_question where wobjectId=".$_[0]->get("wobjectId"));
        while (%data = $sth->hash) {
                $newQuestionId = getNextId("FAQ_questionId");
                WebGUI::SQL->write("insert into FAQ_question values (".$w.", $newQuestionId, "
			.quote($data{question}).", ".quote($data{answer}).", $data{sequenceNumber})");
        }
        $sth->finish;
}

#-------------------------------------------------------------------
sub name {
        return WebGUI::International::get(2,$_[0]->get("namespace"));
}

#-------------------------------------------------------------------
sub new {
        my $class = shift;
        my $property = shift;
        my $self = WebGUI::Wobject->new(
                -properties=>$property,
                -extendedProperties=>{},
		-useTemplate=>1
                );
        bless $self, $class;
}

#-------------------------------------------------------------------
sub purge {
        WebGUI::SQL->write("delete from FAQ_question where wobjectId=".$_[0]->get("wobjectId"));
	$_[0]->SUPER::purge();
}

#-------------------------------------------------------------------
sub www_deleteQuestion {
        return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
	return $_[0]->confirm(WebGUI::International::get(7,$_[0]->get("namespace")),
		WebGUI::URL::page('func=deleteQuestionConfirm&wid='.$_[0]->get("wobjectId").'&qid='.$session{form}{qid}));
}

#-------------------------------------------------------------------
sub www_deleteQuestionConfirm {
        return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
	$_[0]->deleteCollateral("FAQ_question","FAQ_questionId",$session{form}{qid});
	$_[0]->reorderCollateral("FAQ_question","FAQ_questionId");
        return "";
}

#-------------------------------------------------------------------
sub www_edit {
	my $properties = WebGUI::HTMLForm->new;
	if ($_[0]->get("wobjectId") eq "new") {
		$properties->whatNext(
                       	-options=>{
                               	addQuestion=>WebGUI::International::get(75,$_[0]->get("namespace")),
                               	backToPage=>WebGUI::International::get(745)
                               	},
                       	-value=>"addQuestion"
                       	);
	}
	return $_[0]->SUPER::www_edit(
		-properties=>$properties->printRowsOnly,
		-headingId=>8,
		-helpId=>1
		);
}

#-------------------------------------------------------------------
sub www_editSave {
	$_[0]->SUPER::www_editSave();
	if ($session{form}{proceed} eq "addQuestion") {
		$session{form}{qid} = "new";
		return $_[0]->www_editQuestion();
	}
}

#-------------------------------------------------------------------
sub www_editQuestion {
        my ($output, $question, $f);
        return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
        $question = $_[0]->getCollateral("FAQ_question","FAQ_questionId",$session{form}{qid});
	$output = helpIcon(2,$_[0]->get("namespace"));
        $output .= '<h1>'.WebGUI::International::get(10,$_[0]->get("namespace")).'</h1>';
	$f = WebGUI::HTMLForm->new;
	$f->hidden("wid",$_[0]->get("wobjectId"));
        $f->hidden("qid",$question->{FAQ_questionId});
        $f->hidden("func","editQuestionSave");
        $f->textarea(
		-name=>"question",
		-label=>WebGUI::International::get(5,$_[0]->get("namespace")),
		-value=>$question->{question}
		);
        $f->HTMLArea(
		-name=>"answer",
		-label=>WebGUI::International::get(6,$_[0]->get("namespace")),
		-value=>$question->{answer}
		);
	if ($question->{FAQ_questionId} eq "new") {
                $f->whatNext(
                	-options=>{
                        	addQuestion=>WebGUI::International::get(75,$_[0]->get("namespace")),
                                backToPage=>WebGUI::International::get(745)
                                },
                        -value=>"backToPage"
                        );
        }
	$f->submit;
        $output .= $f->print;
        return $output;
}

#-------------------------------------------------------------------
sub www_editQuestionSave {
        return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
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
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
	$_[0]->moveCollateralDown("FAQ_question","FAQ_questionId",$session{form}{qid});
	return "";
}

#-------------------------------------------------------------------
sub www_moveQuestionUp {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
	$_[0]->moveCollateralUp("FAQ_question","FAQ_questionId",$session{form}{qid});
	return "";
}

#-------------------------------------------------------------------
sub www_view {
	my (%question, $controls, $sth, %var, @qa);
	tie %question,'Tie::CPHash';
	$var{"addquestion.url"} = WebGUI::URL::page('func=editQuestion&wid='.$_[0]->get("wobjectId"));
	$var{"addquestion.label"} = WebGUI::International::get(9,$_[0]->get("namespace"));
	$sth = WebGUI::SQL->read("select * from FAQ_question where wobjectId=".$_[0]->get("wobjectId")." order by sequenceNumber");
	while (%question = $sth->hash) {
		$controls = deleteIcon('func=deleteQuestion&wid='.$_[0]->get("wobjectId").'&qid='.$question{FAQ_questionId})
			.editIcon('func=editQuestion&wid='.$_[0]->get("wobjectId").'&qid='.$question{FAQ_questionId})
			.moveUpIcon('func=moveQuestionUp&wid='.$_[0]->get("wobjectId").'&qid='.$question{FAQ_questionId})
			.moveDownIcon('func=moveQuestionDown&wid='.$_[0]->get("wobjectId").'&qid='.$question{FAQ_questionId});
                push(@qa,{
                        "qa.Id"=>$question{FAQ_questionId},
                        "qa.answer"=>$question{answer},
			"qa.question"=>$question{question},
			"qa.controls"=>$controls
                        });
	}
	$sth->finish;
	$var{qa_loop} = \@qa;
	return $_[0]->processTemplate($_[0]->get("templateId"),\%var);
}


1;
