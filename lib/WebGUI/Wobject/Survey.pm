package WebGUI::Wobject::Survey;

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
use WebGUI::DateTime;
use WebGUI::HTMLForm;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::Utility;
use WebGUI::Wobject;

our @ISA = qw(WebGUI::Wobject);
our $namespace = "Survey";
our $name = WebGUI::International::get(1,$namespace);


#-------------------------------------------------------------------
sub _addAnswer {
	$_[0]->setCollateral("Survey_answer","Survey_answerId",{
		Survey_id=>$_[0]->get("Survey_id"),
		Survey_questionId=>$_[2],
		Survey_answerId=>"new",
		answer=>WebGUI::International::get($_[1],$namespace)
		},1,0,"Survey_id");
}

#-------------------------------------------------------------------
sub _setAnswerType {
	$_[0]->setCollateral("Survey_question","Survey_questionId",{
		Survey_questionId=>$_[2],
		Survey_id=>$_[0]->get("Survey_id"),
		answerFieldType=>$_[1]
		},1,0,"Survey_id");
}

#-------------------------------------------------------------------
sub _submenu {
        my ($output, $key);
	return $_[1] if ($session{form}{makePrintable});
        $output = '<table width="100%" border="0" cellpadding="5" cellspacing="0">
                <tr><td width="70%" class="tableData" valign="top">';
        $output .= $_[1];
        $output .= '</td><td width="30%" class="tableMenu" valign="top">';
	$output .= '<li><a href="'.WebGUI::URL::page('func=exportAnswers&wid='.$_[0]->get("wobjectId")).'">'.WebGUI::International::get(62,$namespace).'</a>';
	$output .= '<li><a href="'.WebGUI::URL::page('func=exportQuestions&wid='.$_[0]->get("wobjectId")).'">'.WebGUI::International::get(63,$namespace).'</a>';
	$output .= '<li><a href="'.WebGUI::URL::page('func=exportResponses&wid='.$_[0]->get("wobjectId")).'">'.WebGUI::International::get(64,$namespace).'</a>';
	$output .= '<li><a href="'.WebGUI::URL::page('func=exportComposite&wid='.$_[0]->get("wobjectId")).'">'.WebGUI::International::get(65,$namespace).'</a>';
	$output .= '<li><a href="'.WebGUI::URL::page('func=viewGradebook&wid='.$_[0]->get("wobjectId")).'">'.WebGUI::International::get(61,$namespace).'</a>';
	$output .= '<li><a href="'.WebGUI::URL::page('func=viewStatisticalOverview&wid='.$_[0]->get("wobjectId")).'">'.WebGUI::International::get(59,$namespace).'</a>';
        $output .= '<li><a href="'.WebGUI::URL::page().'">'.WebGUI::International::get(60,$namespace).'</a>';
        $output .= '</td></tr></table>';
        return $output;
}

#-------------------------------------------------------------------
sub duplicate {
	my ($w, $newSurveyId, $qdata, $adata, $rdata, $a, $b, $c);
	$w = $_[0]->SUPER::duplicate($_[1]);
        $w = WebGUI::Wobject::Survey->new({wobjectId=>$w,namespace=>$namespace});
	$newSurveyId = getNextId("Survey_id");
	$w->set({
		questionOrder=>$_[0]->get("questionOrder"),
		groupToTakeSurvey=>$_[0]->get("groupToTakeSurvey"),
		Survey_id=>$newSurveyId,
		groupToViewReports=>$_[0]->get("groupToViewReports"),
		mode=>$_[0]->get("mode")
		});
	$a = WebGUI::SQL->read("select * from Survey_question where Survey_id=".$_[0]->get("Survey_id")
		." order by sequenceNumber");
	while ($qdata = $a->hashRef) {
		$b = WebGUI::SQL->read("select * from Survey_answer where Survey_questionId=".$qdata->{Survey_questionId}
			." order by sequenceNumber");
		$qdata->{Survey_questionId} = "new";
		$qdata->{Survey_id} = $newSurveyId;
		$qdata->{Survey_questionId} = $w->setCollateral("Survey_question","Survey_questionId",$qdata,1,0,"Survey_id");
		while ($adata = $b->hashRef) {
			$c = WebGUI::SQL->read("select * from Survey_response where Survey_answerId=".$adata->{Survey_answerId});
			$adata->{Survey_answerId} = "new";
			$adata->{Survey_questionId} = $qdata->{Survey_questionId};
			$adata->{Survey_id} = $newSurveyId;
			$adata->{Survey_answerId} = $w->setCollateral("Survey_answer", "Survey_answerId", $adata, 
				1, 0, "Survey_Id");
			while ($rdata = $c->hashRef) {
				$rdata->{Survey_responseId} = "new";
				$rdata->{Survey_answerId} = $adata->{Survey_answerId};
				$rdata->{Survey_id} = $newSurveyId;
				$rdata->{Survey_questionId} = $qdata->{Survey_questionId};
				$w->setCollateral("Survey_response","Survey_responseId",$rdata,0,0);
			}
			$c->finish;
		}
		$b->finish;
	}
	$a->finish;
}

#-------------------------------------------------------------------
sub purge {
	my ($count) = WebGUI::SQL->quickArray("select count(*) from Survey where Survey_id=".$_[0]->get("Survey_id"));
	if ($count < 2) { ### Check for other wobjects using this survey.
        	WebGUI::SQL->write("delete from Survey_question where Survey_id=".$_[0]->get("Survey_id"));
        	WebGUI::SQL->write("delete from Survey_answer where Survey_id=".$_[0]->get("Survey_id"));
        	WebGUI::SQL->write("delete from Survey_response where Survey_id=".$_[0]->get("Survey_id"));
	}
        $_[0]->SUPER::purge();
}

#-------------------------------------------------------------------
sub set {
        $_[0]->SUPER::set($_[1],[qw(Survey_id questionOrder groupToTakeSurvey groupToViewReports mode)]);
}

#-------------------------------------------------------------------
sub uiLevel {
	return 5;
}

#-------------------------------------------------------------------
sub www_deleteAnswer {
        return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
        return $_[0]->confirm(WebGUI::International::get(45,$namespace),
                WebGUI::URL::page('func=deleteAnswerConfirm&wid='.$_[0]->get("wobjectId").'&aid='
		.$session{form}{aid}.'&qid='.$session{form}{qid}));
}

#-------------------------------------------------------------------
sub www_deleteAnswerConfirm {
        return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
        WebGUI::SQL->write("delete from Survey_response where Survey_answerId=$session{form}{aid}");
        $_[0]->deleteCollateral("Survey_answer","Survey_answerId",$session{form}{aid});
        $_[0]->reorderCollateral("Survey_answer","Survey_answerId","Survey_id");
        return $_[0]->www_editQuestion;
}

#-------------------------------------------------------------------
sub www_deleteQuestion {
        return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
        return $_[0]->confirm(WebGUI::International::get(44,$namespace),
        	WebGUI::URL::page('func=deleteQuestionConfirm&wid='.$_[0]->get("wobjectId").'&qid='.$session{form}{qid}));
}

#-------------------------------------------------------------------
sub www_deleteQuestionConfirm {
        return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
	WebGUI::SQL->write("delete from Survey_answer where Survey_questionId=$session{form}{qid}");
	WebGUI::SQL->write("delete from Survey_response where Survey_questionId=$session{form}{qid}");
        $_[0]->deleteCollateral("Survey_question","Survey_questionId",$session{form}{qid});
        $_[0]->reorderCollateral("Survey_question","Survey_questionId","Survey_id");
        return $_[0]->www_edit;
}

#-------------------------------------------------------------------
sub www_deleteResponses {
	return "" unless (WebGUI::Privilege::isInGroup($_[0]->get("groupToViewReports")));
        return $_[0]->_submenu($_[0]->confirm(WebGUI::International::get(72,$namespace),
                WebGUI::URL::page('func=deleteResponsesConfirm&wid='.$_[0]->get("wobjectId").'&uid='
                .$session{form}{uid}.'&ip='.$session{form}{ip})));
}

#-------------------------------------------------------------------
sub www_deleteResponsesConfirm {
	return "" unless (WebGUI::Privilege::isInGroup($_[0]->get("groupToViewReports")));
        WebGUI::SQL->write("delete from Survey_response where ((userId=$session{form}{uid}
        	and userId<>1) or (userId=1 and ipAddress='$session{form}{ip}')) and Survey_id=".$_[0]->get("Survey_id"));
        return $_[0]->www_viewGradebook;
}

#-------------------------------------------------------------------
sub www_deleteAllResponses {
	return "" unless (WebGUI::Privilege::isInGroup($_[0]->get("groupToViewReports")));
        return $_[0]->_submenu($_[0]->confirm(WebGUI::International::get(74,$namespace),
                WebGUI::URL::page('func=deleteAllResponsesConfirm&wid='.$_[0]->get("wobjectId"))));
}

#-------------------------------------------------------------------
sub www_deleteAllResponsesConfirm {
	return "" unless (WebGUI::Privilege::isInGroup($_[0]->get("groupToViewReports")));
        WebGUI::SQL->write("delete from Survey_response where Survey_id=".$_[0]->get("Survey_id")); 
        return "";
}

#-------------------------------------------------------------------
sub www_edit {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
        my ($f, $output, $surveyId, $questionOrder, $mode, $groupToViewReports, $sth, %data, $groupToTakeSurvey);
        $mode = $_[0]->get("mode") || "survey";
        $questionOrder = $_[0]->get("questionOrder") || "sequential";
	$groupToViewReports = $_[0]->get("groupToViewReports") || 4;
	$groupToTakeSurvey = $_[0]->get("groupToTakeSurvey") || 2;
	$surveyId = $_[0]->get("Survey_id") || getNextId("Survey_id");
        $output = helpIcon(1,$namespace);
	$output .= '<h1>'.WebGUI::International::get(2,$namespace).'</h1>';
	$f = WebGUI::HTMLForm->new;
	$f->hidden("Survey_id",$surveyId);
	$f->select(
		-name=>"questionOrder",
		-options=>{
			sequential => WebGUI::International::get(5,$namespace),
                	random => WebGUI::International::get(6,$namespace),
                	response => WebGUI::International::get(7,$namespace)
			},
		-label=>WebGUI::International::get(8,$namespace),
		-value=>[$questionOrder]
		);
        $f->select(
                -name=>"mode",
                -options=>{
			survey => WebGUI::International::get(9,$namespace),
                	quiz => WebGUI::International::get(10,$namespace)
			},
                -label=>WebGUI::International::get(11,$namespace),
                -value=>[$mode]
                );
	$f->group(
		-name=>"groupToTakeSurvey",
		-value=>[$groupToTakeSurvey],
		-label=>WebGUI::International::get(12,$namespace)
		);
        $f->group(
                -name=>"groupToViewReports",
                -label=>WebGUI::International::get(13,$namespace),
                -value=>[$groupToViewReports]
                );
	if ($_[0]->get("wobjectId") eq "new") {
		$f->whatNext(
			-options=>{
				addQuestion=>WebGUI::International::get(28,$namespace),
				backToPage=>WebGUI::International::get(745)
				},
			-value=>"addQuestion"
			);
	}
	$output .= $_[0]->SUPER::www_edit($f->printRowsOnly);
	if ($_[0]->get("wobjectId") ne "new") {
		$output .= '<a href="'.WebGUI::URL::page('wid='.$_[0]->get("wobjectId").'&func=editQuestion&qid=new')
                        .'">'.WebGUI::International::get(30,$namespace).'</a><p>';
		$sth = WebGUI::SQL->read("select Survey_questionId,question from Survey_question where Survey_id="
			.$_[0]->get("Survey_id")." order by sequenceNumber");
		while (%data = $sth->hash) {
			$output .= deleteIcon('func=deleteQuestion&wid='.$_[0]->get("wobjectId").'&qid='.$data{Survey_questionId})
				.editIcon('func=editQuestion&wid='.$_[0]->get("wobjectId").'&qid='.$data{Survey_questionId})	
				.moveUpIcon('func=moveQuestionUp&wid='.$_[0]->get("wobjectId").'&qid='.$data{Survey_questionId})	
				.moveDownIcon('func=moveQuestionDown&wid='.$_[0]->get("wobjectId").'&qid='.$data{Survey_questionId})	
				.' '.$data{question}.'<br>';
		}
		$sth->finish;
	}
        return $output;
}

#-------------------------------------------------------------------
sub www_editSave {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
	$_[0]->SUPER::www_editSave({
		groupToTakeSurvey=>$session{form}{groupToTakeSurvey},
		groupToViewReports=>$session{form}{groupToViewReports},
		mode=>$session{form}{mode},
		Survey_id=>$session{form}{Survey_id},
		questionOrder=>$session{form}{questionOrder}
		});
	if ($session{form}{proceed} eq "addQuestion") {
		$session{form}{qid} = "new";
		return $_[0]->www_editQuestion;
	}
        return "";
}

#-------------------------------------------------------------------
sub www_editAnswer {
        return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
        my ($question, $output, $f, $answer);
        $answer = $_[0]->getCollateral("Survey_answer","Survey_answerId",$session{form}{aid});
        $output = '<h1>'.WebGUI::International::get(18,$namespace).'</h1>';
        $f = WebGUI::HTMLForm->new;
        $f->hidden("wid",$session{form}{wid});
        $f->hidden("func","editAnswerSave");
        $f->hidden("qid",$session{form}{qid});
        $f->hidden("aid",$answer->{Survey_answerId});
        $f->text(
                -name=>"answer",
                -value=>$answer->{answer},
                -label=>WebGUI::International::get(19,$namespace)
                );
	if ($_[0]->get("mode") eq "quiz") {
        	$f->yesNo(
                	-name=>"isCorrect",
                	-value=>$answer->{isCorrect},
                	-label=>WebGUI::International::get(20,$namespace)
                	);
	} else {
		$f->hidden("isCorrect",0);
	}
	if ($_[0]->get("questionOrder") eq "response") {
		$question = WebGUI::SQL->buildHashRef("select Survey_questionId,question 
			from Survey_question where Survey_id=".$_[0]->get("Survey_id")." order by sequenceNumber");
		$f->select(
			-name=>"goto",
			-options=>$question,
			-value=>[$answer->{goto}],
			-label=>WebGUI::International::get(21,$namespace)
			);
	}
	if ($answer->{Survey_answerId} eq "new") {
                my %options;
                tie %options, 'Tie::IxHash';
                %options = (
                        "addAnswer"=>WebGUI::International::get(24,$namespace),
                        "addQuestion"=>WebGUI::International::get(28,$namespace),
                        "editQuestion"=>WebGUI::International::get(75,$namespace),
                        "backToPage"=>WebGUI::International::get(745)
                        );
                $f->whatNext(
                        -options=>\%options,
                        -value=>"addAnswer"
                        );
        }
        $f->submit;
        $output .= $f->print;
        return $output;
}

#-------------------------------------------------------------------
sub www_editAnswerSave {
        return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
        $_[0]->setCollateral("Survey_answer", "Survey_answerId", {
                Survey_answerId => $session{form}{aid},
                Survey_questionId => $session{form}{qid},
                answer => $session{form}{answer},
                isCorrect => $session{form}{isCorrect},
		Survey_id=>$_[0]->get("Survey_id"),
                goto => $session{form}{goto}
                },1,0,"Survey_Id");
	if ($session{form}{proceed} eq "addQuestion") {
                $session{form}{qid} = "new";
	} elsif ($session{form}{proceed} eq "addAnswer") {
		$session{form}{aid} = "new";
		$_[0]->www_editAnswer();
	} elsif ($session{form}{proceed} eq "backToPage") {
		return "";
        }
        return $_[0]->www_editQuestion();
}

#-------------------------------------------------------------------
sub www_editQuestion {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
	my ($output, $f, $question, $answerFieldType, $sth, %data);
	$question = $_[0]->getCollateral("Survey_question","Survey_questionId",$session{form}{qid});
	$output = '<h1>'.WebGUI::International::get(17,$namespace).'</h1>';
	$answerFieldType = $question->{answerFieldType} || "radioList";
	$f = WebGUI::HTMLForm->new;
	$f->hidden("wid",$_[0]->get("wobjectId"));
	$f->hidden("func","editQuestionSave");
	$f->hidden("qid",$question->{Survey_questionId});
	$f->hidden("answerFieldType",$answerFieldType);
	$f->HTMLArea(
		-name=>"question",
		-value=>$question->{question},
		-label=>WebGUI::International::get(14,$namespace)
		);
	$f->yesNo(
		-name=>"allowComment",
		-value=>$question->{allowComment},
		-label=>WebGUI::International::get(15,$namespace)
		);
	$f->yesNo(
		-name=>"randomizeAnswers",
		-value=>$question->{randomizeAnswers},
		-label=>WebGUI::International::get(16,$namespace)
		);
	if ($question->{Survey_questionId} eq "new") {
		my %options;
		tie %options, 'Tie::IxHash';
		%options = (
			"addMultipleChoiceAnswer"=>WebGUI::International::get(24,$namespace),
                        "addTextAnswer"=>WebGUI::International::get(29,$namespace),
                        "addBooleanAnswer"=>WebGUI::International::get(25,$namespace),
                        "addFrequencyAnswer"=>WebGUI::International::get(26,$namespace),
                        "addOpinionAnswer"=>WebGUI::International::get(27,$namespace),
			#"addQuestion"=>WebGUI::International::get(28,$namespace),
                        "backToPage"=>WebGUI::International::get(745)
			);
        	$f->whatNext(
                	-options=>\%options,
                	-value=>"addMultipleChoiceAnswer"
                	);
	}
	$f->submit;
	$output .= $f->print;
	if ($question->{Survey_questionId} ne "new" && $question->{answerFieldType} ne "text") {
		$output .= '<a href="'.WebGUI::URL::page('wid='.$_[0]->get("wobjectId").'&func=editAnswer&aid=new&qid='
			.$question->{Survey_questionId}).'">'.WebGUI::International::get(23,$namespace).'</a><p>';
		$sth = WebGUI::SQL->read("select Survey_answerId,answer from Survey_answer 
			where Survey_questionId=".$question->{Survey_questionId}." order by sequenceNumber");
		while (%data = $sth->hash) {
			$output .= deleteIcon('func=deleteAnswer&wid='.$_[0]->get("wobjectId")
					.'&qid='.$question->{Survey_questionId}.'&aid='.$data{Survey_answerId})
                                .editIcon('func=editAnswer&wid='.$_[0]->get("wobjectId").'&qid='.$question->{Survey_questionId}
					.'&aid='.$data{Survey_answerId})
                                .moveUpIcon('func=moveAnswerUp&wid='.$_[0]->get("wobjectId")
					.'&qid='.$question->{Survey_questionId}.'&aid='.$data{Survey_answerId})
                                .moveDownIcon('func=moveAnswerDown&wid='.$_[0]->get("wobjectId").'&qid='
					.$question->{Survey_questionId}.'&aid='.$data{Survey_answerId})
                                .' '.$data{answer}.'<br>';
		}
		$sth->finish;
	}
	return $output;
}

#-------------------------------------------------------------------
sub www_editQuestionSave {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
	$session{form}{qid} = $_[0]->setCollateral("Survey_question", "Survey_questionId", {
                question=>$session{form}{question},
        	Survey_questionId=>$session{form}{qid},
		Survey_id=>$_[0]->get("Survey_id"),
                allowComment=>$session{form}{allowComment},
		answerFieldType=>$session{form}{answerFieldType},
                randomizeAnswers=>$session{form}{randomizeAnswers}
                },1,0,"Survey_id");
        if ($session{form}{proceed} eq "addMultipleChoiceAnswer") {
        	$session{form}{aid} = "new";
                return $_[0]->www_editAnswer();
	} elsif ($session{form}{proceed} eq "addTextAnswer") {
                $_[0]->_setAnswerType("text",$session{form}{qid});
        	$_[0]->_addAnswer(0,$session{form}{qid});
	} elsif ($session{form}{proceed} eq "addBooleanAnswer") {
        	$_[0]->_addAnswer(31,$session{form}{qid});
        	$_[0]->_addAnswer(32,$session{form}{qid});
                return $_[0]->www_editQuestion();
	} elsif ($session{form}{proceed} eq "addOpinionAnswer") {
                $_[0]->_addAnswer(33,$session{form}{qid});
                $_[0]->_addAnswer(34,$session{form}{qid});
                $_[0]->_addAnswer(35,$session{form}{qid});
                $_[0]->_addAnswer(36,$session{form}{qid});
                $_[0]->_addAnswer(37,$session{form}{qid});
                $_[0]->_addAnswer(38,$session{form}{qid});
                $_[0]->_addAnswer(39,$session{form}{qid});
                return $_[0]->www_editQuestion();
	} elsif ($session{form}{proceed} eq "addFrequencyAnswer") {
                $_[0]->_addAnswer(40,$session{form}{qid});
                $_[0]->_addAnswer(41,$session{form}{qid});
                $_[0]->_addAnswer(42,$session{form}{qid});
                $_[0]->_addAnswer(43,$session{form}{qid});
                $_[0]->_addAnswer(39,$session{form}{qid});
                return $_[0]->www_editQuestion();
	} elsif ($session{form}{proceed} eq "addQuestion") {
		$session{form}{qid} eq "new";
                return $_[0]->www_editQuestion();
	} elsif ($session{form}{proceed} eq "backToPage") {
		return ""	
	}
        return $_[0]->www_edit;
}

#-------------------------------------------------------------------
sub www_exportAnswers {
        return "" unless (WebGUI::Privilege::isInGroup($_[0]->get("groupToViewReports")));
        $session{header}{filename} = WebGUI::URL::escape($_[0]->get("title")."_answers.tab");
        $session{header}{mimetype} = "text/tab";
        return WebGUI::SQL->quickTab("select * from Survey_answer where Survey_id=".$_[0]->get("Survey_id"));
}

#-------------------------------------------------------------------
sub www_exportComposite {
	return "" unless (WebGUI::Privilege::isInGroup($_[0]->get("groupToViewReports")));
	$session{header}{filename} = WebGUI::URL::escape($_[0]->get("title")."_composite.tab");
	$session{header}{mimetype} = "text/tab";
	return WebGUI::SQL->quickTab("select b.question, a.response, a.userId, a.username, a.ipAddress, a.comment, 
		a.dateOfResponse from Survey_response a left join Survey_question b on a.Survey_questionId=b.Survey_questionId 
		where a.Survey_id=".$_[0]->get("Survey_id")." order by a.userId, a.ipAddress, b.sequenceNumber");
}

#-------------------------------------------------------------------
sub www_exportQuestions {
        return "" unless (WebGUI::Privilege::isInGroup($_[0]->get("groupToViewReports")));
        $session{header}{filename} = WebGUI::URL::escape($_[0]->get("title")."_questions.tab");
        $session{header}{mimetype} = "text/tab";
        return WebGUI::SQL->quickTab("select * from Survey_question where Survey_id=".$_[0]->get("Survey_id"));
}

#-------------------------------------------------------------------
sub www_exportResponses {
        return "" unless (WebGUI::Privilege::isInGroup($_[0]->get("groupToViewReports")));
        $session{header}{filename} = WebGUI::URL::escape($_[0]->get("title")."_responses.tab");
        $session{header}{mimetype} = "text/tab";
        return WebGUI::SQL->quickTab("select * from Survey_response where Survey_id=".$_[0]->get("Survey_id"));
}

#-------------------------------------------------------------------
sub www_moveAnswerDown {
        return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
        $_[0]->moveCollateralDown("Survey_answer","Survey_answerId",$session{form}{aid},"Survey_id");
        return $_[0]->www_editQuestion;
}

#-------------------------------------------------------------------
sub www_moveAnswerUp {
        return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
        $_[0]->moveCollateralUp("Survey_answer","Survey_answerId",$session{form}{aid},"Survey_id");
        return $_[0]->www_editQuestion;
}

#-------------------------------------------------------------------
sub www_moveQuestionDown {
        return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
        $_[0]->moveCollateralDown("Survey_question","Survey_questionId",$session{form}{qid},"Survey_id");
        return $_[0]->www_edit;
}

#-------------------------------------------------------------------
sub www_moveQuestionUp {
        return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
        $_[0]->moveCollateralUp("Survey_question","Survey_questionId",$session{form}{qid},"Survey_id");
        return $_[0]->www_edit;
}

#-------------------------------------------------------------------
sub www_respond {
	return "" unless (WebGUI::Privilege::isInGroup($_[0]->get("groupToTakeSurvey")));
	return "" unless ($session{form}{Survey_answerId} ne "");
	my ($previousResponse) = WebGUI::SQL->quickArray("select count(*) from Survey_response
		where Survey_answerId=$session{form}{Survey_answerId} and ((userId=".$session{user}{userId}." and userId<>1)
                        or (userId=1 and ipAddress='".$session{form}{ip}."'))");
	return "" if ($previousResponse);
	my $answer = $_[0]->getCollateral("Survey_answer","Survey_answerId",$session{form}{Survey_answerId});
	my $response = $session{form}{response} || $answer->{answer};
	$_[0]->setCollateral("Survey_response","Survey_responseId",{
		Survey_responseId=>"new",
		Survey_answerId=>$session{form}{Survey_answerId},
		Survey_questionId=>$answer->{Survey_questionId},
		Survey_id=>$answer->{Survey_id},
		comment=>$session{form}{comment},
		response=>$response,
		userId=>$session{user}{userId},
		username=>$session{user}{username},
		dateOfResponse=>time(),
		ipAddress=>$session{env}{REMOTE_ADDR}
		},0,0);
	return "";
}

#-------------------------------------------------------------------
sub www_view {
	my ($output, $f, $previous, $questionOrder, $previousResponse, $question);
	$output = $_[0]->displayTitle;
	$output .= $_[0]->description;
        if (WebGUI::Privilege::isInGroup($_[0]->get("groupToViewReports"))) {
                $output .= '<a href="'.WebGUI::URL::page('func=viewStatisticalOverview&wid='.$_[0]->get("wobjectId")).'">'
                        .WebGUI::International::get(68,$namespace).'</a><p/>';
        }
	if (WebGUI::Privilege::isInGroup($_[0]->get("groupToTakeSurvey"))) {
        	$previousResponse = WebGUI::SQL->quickHashRef("select Survey_questionId, Survey_answerId from Survey_response 
			where Survey_id=".$_[0]->get("Survey_id")
			." and ((userId=$session{user}{userId} and userId<>1) or (userId=1 and 
			ipAddress='$session{env}{REMOTE_ADDR}')) order by dateOfResponse desc");
		$questionOrder = $_[0]->get("questionOrder");
		unless ($previousResponse) {
			if ($questionOrder eq "random") {
				my @questions = WebGUI::SQL->buildArray("select Survey_questionId from Survey_question
					where Survey_id=".$_[0]->get("Survey_id"));
				$question = $_[0]->getCollateral("Survey_question","Survey_questionId",
					$questions[rand($#questions+1)]);
			} else {
				$question = WebGUI::SQL->quickHashRef("select * from Survey_question
					where Survey_id=".$_[0]->get("Survey_id")." order by sequenceNumber");
			}
		} else {
			if ($questionOrder eq "random") {
				my @questions = WebGUI::SQL->buildArray("select Survey_questionId from Survey_response
					where Survey_id=".$_[0]->get("Survey_id")." and ((userId=$session{user}{userId} 
					and userId<>1) or (userId=1 and ipAddress='$session{env}{REMOTE_ADDR}'))");
				@questions = WebGUI::SQL->buildArray("select Survey_questionId from Survey_question 
					where Survey_id=".$_[0]->get("Survey_id")
					." and Survey_questionId not in (".join(",",@questions).")");
				if ($#questions >= 0) {
					$question = $_[0]->getCollateral("Survey_question","Survey_questionId",
						$questions[rand($#questions+1)]);
				}
			}
			if ($questionOrder eq "response") {
				my ($responseDriver) = WebGUI::SQL->quickArray("select goto from Survey_answer where
					Survey_answerId=".$previousResponse->{Survey_answerId});
				if ($responseDriver) {
					$question = $_[0]->getCollateral("Survey_question","Survey_questionId",$responseDriver);
				} else {
					$questionOrder = "sequential";
				}
			} 
			if ($questionOrder eq "sequential") {
				my $previousQuestion = $_[0]->getCollateral("Survey_question","Survey_questionId",
					$previousResponse->{Survey_questionId});
				$previousQuestion->{sequenceNumber} = 0 unless($previousQuestion->{sequenceNumber});
				$question = WebGUI::SQL->quickHashRef("select * from Survey_question where Survey_id="
					.$_[0]->get("Survey_id")." and sequenceNumber>".$previousQuestion->{sequenceNumber}
					." order by sequenceNumber");
			}
		}
		if ($question->{Survey_questionId}) {
			$output .= $question->{question};
			$f = WebGUI::HTMLForm->new;
			$f->hidden("func","respond");
			$f->hidden("wid",$_[0]->get("wobjectId"));
			if ($question->{answerFieldType} eq "text") {
				my ($answer) = WebGUI::SQL->quickArray("select Survey_answerId from Survey_answer where
					Survey_questionId=".$question->{Survey_questionId});
				$f->hidden("Survey_answerId",$answer);
				$f->text(
					-name=>"response"
					);
			} else {
				my $answer = WebGUI::SQL->buildHashRef("select Survey_answerId,answer from Survey_answer
					where Survey_questionId=".$question->{Survey_questionId}." order by sequenceNumber");
				if ($question->{randomizeAnswers}) {
					$answer = randomizeHash($answer);
				}
				$f->radioList(
					-options=>$answer,
					-name=>"Survey_answerId",
					-vertical=>1
					);
			}
			if ($question->{allowComment}) {
				$f->textarea(
					-name=>"comment",
					-label=>WebGUI::International::get(51,$namespace)
					);
			}
			$f->submit(WebGUI::International::get(50,$namespace));
			$output .= $f->print;
		} else {
			if ($_[0]->get("mode") eq "survey") {
				$output .= WebGUI::International::get(46,$namespace);
			} else {
				$output .= WebGUI::International::get(47,$namespace);
				my ($questionCount) = WebGUI::SQL->quickArray("select count(*) from Survey_question
					where Survey_id=".$_[0]->get("Survey_id"));
				my ($correctCount) = WebGUI::SQL->quickArray("select count(*) from Survey_response a,
					Survey_answer b where a.Survey_id=".$_[0]->get("Survey_id")." 
					and ((userId=$session{user}{userId} and userId<>1) or 
					(userId=1 and ipAddress='$session{env}{REMOTE_ADDR}'))
					and a.Survey_answerId=b.Survey_answerId and b.isCorrect=1");
				$output .= "<h1>".WebGUI::International::get(52,$namespace).": ".$correctCount."/".$questionCount
					."<br/>".WebGUI::International::get(54,$namespace).": "
					.round(($correctCount/$questionCount)*100)."%</h1>";
			}
		}
	} else {
		if ($_[0]->get("mode") eq "survey") {
                        $output .= WebGUI::International::get(48,$namespace);
                } else {
                        $output .= WebGUI::International::get(49,$namespace);
                }
	}
	return $_[0]->processMacros($output);
}

#-------------------------------------------------------------------
sub www_viewComments {
        return "" unless (WebGUI::Privilege::isInGroup($_[0]->get("groupToViewReports")));
	my ($output, $sth, $comment);
	$output = '<h1>'.WebGUI::International::get(57,$namespace).'</h1>';
	$sth = WebGUI::SQL->read("select comment from Survey_response where Survey_questionId=".$session{form}{qid});
	while (($comment) = $sth->array) {
		$output .= $comment."<p/>\n";
	}
	$sth->finish;
	return $_[0]->_submenu($output);
}

#-------------------------------------------------------------------
sub www_viewGradebook {
        return "" unless (WebGUI::Privilege::isInGroup($_[0]->get("groupToViewReports")));
	my ($output, $p, $users, $user);
	$output = '<h1>'.WebGUI::International::get(71,$namespace).'</h1>';
	$p = WebGUI::Paginator->new('func=viewGradebook&wid='.$_[0]->get("wobjectId"));
	$p->setDataByQuery("select userId,username,ipAddress from Survey_response 
		group by userId,username,ipAddress order by username,ipAddress");
	$users = $p->getPageData;
	my ($questionCount) = WebGUI::SQL->quickArray("select count(*) from Survey_question
        	where Survey_id=".$_[0]->get("Survey_id"));
	$output .= '<table class="tableData">';
	$output .= '<tr class="tableHeader"><td width="60%">'.WebGUI::International::get(67,$namespace).'</td>
		<td width="20%">'.WebGUI::International::get(52,$namespace).'</td>
		<td width="20%">'.WebGUI::International::get(54,$namespace).'</td></tr>';
	foreach $user (@$users) {
		$output .= '<tr>';
		$output .= '<td><a href="'.WebGUI::URL::page('func=viewIndividualSurvey&wid='.$_[0]->get("wobjectId")
			.'&uid='.$user->{userId}.'&ip='.$user->{ipAddress}).'">';
		if ($user->{userId} == 1) {
			$output .= $user->{ipAddress};
		} else {
			$output .= $user->{username};
		}
		$output .= '</a></td>';
		my ($correctCount) = WebGUI::SQL->quickArray("select count(*) from Survey_response a,
                	Survey_answer b where a.Survey_id=".$_[0]->get("Survey_id")."
                        and ((userId=".$user->{userId}." and userId<>1) or
                        (userId=1 and ipAddress='".$user->{ipAddress}."'))
                        and a.Survey_answerId=b.Survey_answerId and b.isCorrect=1");
		$output .= '<td>'.$correctCount.'/'.$questionCount.'</td>';
		$output .= '<td>'.round(($correctCount/$questionCount)*100).'</td>';
		$output .= '</tr>';
	}
	$output .= '</table>';
	$output .= $p->getBarTraditional;
	return $_[0]->_submenu($output);
}


#-------------------------------------------------------------------
sub www_viewIndividualSurvey {
        return "" unless (WebGUI::Privilege::isInGroup($_[0]->get("groupToViewReports")));
	my ($output, $questions, $sth, $qdata, $rdata, $adata, $p);
	$output = '<h1>'.WebGUI::International::get(70,$namespace).'</h1>';
	$output .= '<a href="'.WebGUI::URL::page('func=deleteResponses&wid='.$_[0]->get("wobjectId")
                .'&uid='.$session{form}{uid}.'&ip='.$session{form}{ip}).'">'.WebGUI::International::get(69,$namespace).'</a><p/>';
	my ($start) = WebGUI::SQL->quickArray("select min(dateOfResponse) from Survey_response 
		where Survey_id=".$_[0]->get("Survey_id")." and ((userId=".$session{form}{uid}." and userId<>1)
                or (userId=1 and ipAddress='".$session{form}{ip}."'))");
        my ($end) = WebGUI::SQL->quickArray("select max(dateOfResponse) from Survey_response
                where Survey_id=".$_[0]->get("Survey_id")." and ((userId=".$session{form}{uid}." and userId<>1)
                or (userId=1 and ipAddress='".$session{form}{ip}."'))");
	$output .= '<b>'.WebGUI::International::get(76,$namespace).':</b> '.epochToHuman($start).'<br/>';
	$output .= '<b>'.WebGUI::International::get(77,$namespace).':</b> '.epochToHuman($end).'<br/>';
	$output .= '<b>'.WebGUI::International::get(78,$namespace).':</b> '.int(($end-$start)/60).' '
		.WebGUI::International::get(79,$namespace).', '.(($end-$start)%60).' '
		.WebGUI::International::get(80,$namespace).'<p/>';
	$p = WebGUI::Paginator->new(WebGUI::URL::page('func=viewIndividualSurvey&wid='.$_[0]->get("wobjectId")
		.'&uid='.$session{form}{uid}.'&ip='.$session{form}{ip}));
	$p->setDataByQuery("select Survey_questionId,question,answerFieldType from Survey_question 
		where Survey_id=".$_[0]->get("Survey_id")." order by sequenceNumber");
	$questions = $p->getPageData;
	foreach $qdata (@$questions) {
		$output .= '<b>'.$qdata->{question}.'</b><br/>'
			.'<table class="tableData" width="100%">';
		if ($qdata->{answerFieldType} eq "radioList") {
			$output .= '<tr><td valign="top" class="tableHeader" width="25%">'
				.WebGUI::International::get(19,$namespace).'</td><td width="75%">';
			$sth = WebGUI::SQL->read("select Survey_answerId,answer from Survey_answer 
				where Survey_questionId=".$qdata->{Survey_questionId}." and isCorrect=1 order by sequenceNumber");
			while ($adata = $sth->hashRef) {
				$output .= $adata->{answer}.'<br/>';
			}
			$sth->finish;
			$output .= '</td></tr>';
		}
		$output .= '<tr><td width="25%" valign="top" class="tableHeader">'
			.WebGUI::International::get(66,$namespace).'</td>';
		$rdata = WebGUI::SQL->quickHashRef("select Survey_answerId,response,comment from Survey_response 
			where Survey_questionId=".$qdata->{Survey_questionId}." 
			and ((userId=".$session{form}{uid}." and userId<>1) 
			or (userId=1 and ipAddress='".$session{form}{ip}."'))");
		$output .= '<td width="75%">'.$rdata->{response}.'</td></tr>';
		if ($rdata->{comment} ne "") {
			$output .= '<tr><td valign="top" class="tableHeader">'
				.WebGUI::International::get(57,$namespace).'</td>'
				.'<td>'.$rdata->{comment}.'</td></tr>';
		}
		$output .= "</table><p/>\n";
	}
	return $_[0]->_submenu($output);
}

#-------------------------------------------------------------------
sub www_viewResponses {
        return "" unless (WebGUI::Privilege::isInGroup($_[0]->get("groupToViewReports")));
        my ($output, $sth, $response);
        $output = '<h1>'.WebGUI::International::get(66,$namespace).'</h1>';
        $sth = WebGUI::SQL->read("select response from Survey_response where Survey_questionId=".$session{form}{qid});
        while (($response) = $sth->array) {
                $output .= $response."<p/>\n";
        }
        $sth->finish;
        return $_[0]->_submenu($output);
}

#-------------------------------------------------------------------
sub www_viewStatisticalOverview {
        return "" unless (WebGUI::Privilege::isInGroup($_[0]->get("groupToViewReports")));
	my ($output, $p, $questions, $question, $sth, $answer, $totalResponses, $data);
	$output = '<h1>'.WebGUI::International::get(58,$namespace).'</h1>';
	$output .= '<a href="'.WebGUI::URL::page('func=deleteAllResponses&wid='.$_[0]->get("wobjectId"))
                .'">'.WebGUI::International::get(73,$namespace).'</a><p/>';
	$p = WebGUI::Paginator->new(WebGUI::URL::page('op=viewStatisticalOverview'));
	$p->setDataByQuery("select Survey_questionId,question,answerFieldType,allowComment from Survey_question 
		where Survey_id=".$_[0]->get("Survey_id")." order by sequenceNumber");
	$questions = $p->getPageData;
	foreach $question (@$questions) {
		$output .= '<b>'.$question->{question}.'</b>';
		if ($question->{answerFieldType} eq "radioList") {
			$output .= '<table class="tableData">';
			$output .= '<tr class="tableHeader"><td width="60%">'.WebGUI::International::get(19,$namespace).'</td>
				<td width="20%">'.WebGUI::International::get(53,$namespace).'</td>
				<td width="20%">'.WebGUI::International::get(54,$namespace).'</td></tr>';
			($totalResponses) = WebGUI::SQL->quickArray("select count(*) from Survey_response
				where Survey_questionId=".$question->{Survey_questionId});
			$sth = WebGUI::SQL->read("select Survey_answerId,answer,isCorrect from Survey_answer where
				Survey_questionId=".$question->{Survey_questionId}." order by sequenceNumber");
			while ($answer = $sth->hashRef) {
				if ($answer->{isCorrect}) {
					$output .= '<tr class="highlight">';
				} else {
					$output .= '<tr>';
				}
				$output .= '<td>'.$answer->{answer}.'</td>';
				($data) = WebGUI::SQL->quickArray("select count(*) from Survey_response
                                        where Survey_answerId=".$answer->{Survey_answerId});
				$output .= '<td>'.$data.'</td>';
				$output .= '<td>';
				if ($totalResponses) {
					$output .= round(($data/$totalResponses)*100);
				} else {
					$output .= '0';
				}
				$output .= '</td>';
				$output .= '</tr>';
			}
			$sth->finish;
			$output .= "</table>";
		} else {
			$output .= '<br/><a href="'.WebGUI::URL::page('func=viewResponses&wid='.$_[0]->get("wobjectId")
				.'&qid='.$question->{Survey_questionId}).'">'.WebGUI::International::get(55,$namespace)
				.'</a><br/>';
		}
		if ($question->{allowComment}) {
			$output .= '<a href="'.WebGUI::URL::page('func=viewComments&wid='.$_[0]->get("wobjectId")
				.'&qid='.$question->{Survey_questionId}).'">'.WebGUI::International::get(56,$namespace).'</a>';
		}
		$output .= '<br/><br/><br/>';
	}
	$output .= $p->getBarTraditional;
	return $_[0]->_submenu($output);
}

1;

