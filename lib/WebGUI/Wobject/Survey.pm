package WebGUI::Wobject::Survey;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2004 Plain Black Corporation.
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
use WebGUI::Grouping;
use WebGUI::HTMLForm;
use WebGUI::HTTP;
use WebGUI::Icon;
use WebGUI::Id;
use WebGUI::International;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::Utility;
use WebGUI::Wobject;
use Digest::MD5 qw(md5_hex);

our @ISA = qw(WebGUI::Wobject);


#-------------------------------------------------------------------
sub addAnswer {
	$_[0]->setCollateral("Survey_answer","Survey_answerId",{
		Survey_id=>$_[0]->get("Survey_id"),
		Survey_questionId=>$_[2],
		Survey_answerId=>"new",
		answer=>WebGUI::International::get($_[1],$_[0]->get("namespace"))
		},1,0,"Survey_id");
}

#-------------------------------------------------------------------
sub completeResponse {
	my $self = shift;
	my $responseId = shift;
	WebGUI::SQL->setRow("Survey_response","Survey_responseId",{
		'Survey_responseId'=>$responseId,
		isComplete=>1
		});
	WebGUI::Session::deleteScratch($self->getResponseIdString);
}


#-------------------------------------------------------------------
sub duplicate {
	my ($w, $newSurveyId, $qdata, $adata, $rdata, $a, $b, $c);
	$w = $_[0]->SUPER::duplicate($_[1]);
        $w = WebGUI::Wobject::Survey->new({wobjectId=>$w,namespace=>$_[0]->get("namespace")});
	$newSurveyId = WebGUI::Id::generate();
	$w->set({
		Survey_id=>$newSurveyId
		});
	$a = WebGUI::SQL->read("select * from Survey_question where Survey_id=".quote($_[0]->get("Survey_id"))
		." order by sequenceNumber");
	while ($qdata = $a->hashRef) {
		$b = WebGUI::SQL->read("select * from Survey_answer where Survey_questionId=".quote($qdata->{Survey_questionId})
			." order by sequenceNumber");
		$qdata->{Survey_questionId} = "new";
		$qdata->{Survey_id} = $newSurveyId;
		$qdata->{Survey_questionId} = $w->setCollateral("Survey_question","Survey_questionId",$qdata,1,0,"Survey_id");
		while ($adata = $b->hashRef) {
			$c = WebGUI::SQL->read("select * from Survey_response where Survey_answerId=".quote($adata->{Survey_answerId}));
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
sub generateResponseId {
	my $self = shift;
	my $varname = $self->getResponseIdString;
	if ($session{scratch}{$varname}) {
		$self->completeResponse;
	}
	my $ipAddress = $self->getIp; 
	my $userId = $self->getUserId; 
	my $responseId = WebGUI::SQL->setRow("Survey_response","Survey_responseId",{
		'Survey_responseId'=>"new",
		userId=>$userId,
		ipAddress=>$ipAddress,
		username=>$session{user}{username},
		startDate=>WebGUI::DateTime::time(),
		'Survey_id'=>$self->get("Survey_id")
		});
	WebGUI::Session::setScratch($varname,$responseId);
	return $responseId;
}

#-------------------------------------------------------------------
sub getIndexerParams {
	my $self = shift;        
	my $now = shift;
	return {
		Survey => {
                        sql => "select Survey_question.question as question,
                                        Survey_question.Survey_questionId as Survey_questionId,
                                        Survey.wobjectId as wid,
                                        wobject.namespace as namespace,
                                        wobject.addedBy as ownerId,
                                        page.urlizedTitle as urlizedTitle,
                                        page.languageId as languageId,
                                        page.pageId as pageId,
                                        page.groupIdView as page_groupIdView,
                                        wobject.groupIdView as wobject_groupIdView,
                                        Survey.groupToTakeSurvey as wobject_special_groupIdView
                                        from wobject, page, Survey
                                        left join Survey_question on Survey_question.Survey_id=Survey.Survey_id
                                        where Survey.wobjectId = wobject.wobjectId
                                        and wobject.pageId = page.pageId
                                        and wobject.startDate < $now 
                                        and wobject.endDate > $now
                                        and page.startDate < $now
                                        and page.endDate > $now",
                        fieldsToIndex => ["question",
                                          'select answer from Survey_answer where Survey_questionId = \'$data{Survey_questionId}\'' ],
                        contentType => 'wobjectDetail',
                        url => 'WebGUI::URL::append($data{urlizedTitle}, "func=view&wid=$data{wid}")',
                        headerShortcut => 'select title from wobject where wobjectId = \'$data{wid}\'',
                        bodyShortcut => 'select description from wobject where wobjectId = \'$data{wid}\'',

                }
	};
}


#-------------------------------------------------------------------
sub getIp {
	my $self = shift;
	my $ip = ($self->get("anonymous")) ? substr(md5_hex($session{env}{REMOTE_ADDR}),0,8) : $session{env}{REMOTE_ADDR};
	return $ip;
}



#-------------------------------------------------------------------
sub getMenuVars {
	my $self = shift;
	my %var;
	$var{'user.canViewReports'} = (WebGUI::Grouping::isInGroup($self->get("groupToViewReports")));
	$var{'delete.all.responses.url'} = WebGUI::URL::page('func=deleteAllResponses&wid='.$self->get("wobjectId"));
	$var{'delete.all.responses.label'} = WebGUI::International::get(73,$self->get("namespace"));
	$var{'export.answers.url'} = WebGUI::URL::page('func=exportAnswers&wid='.$self->get("wobjectId"));
	$var{'export.answers.label'} = WebGUI::International::get(62,$self->get("namespace"));
	$var{'export.questions.url'} = WebGUI::URL::page('func=exportQuestions&wid='.$self->get("wobjectId"));
	$var{'export.questions.label'} = WebGUI::International::get(63,$self->get("namespace"));
	$var{'export.responses.url'} = WebGUI::URL::page('func=exportResponses&wid='.$self->get("wobjectId"));
	$var{'export.responses.label'} = WebGUI::International::get(64,$self->get("namespace"));
	$var{'export.composite.url'} = WebGUI::URL::page('func=exportComposite&wid='.$self->get("wobjectId"));
	$var{'export.composite.label'} = WebGUI::International::get(65,$self->get("namespace"));
	$var{'report.gradebook.url'} = WebGUI::URL::page('func=viewGradebook&wid='.$self->get("wobjectId"));
	$var{'report.gradebook.label'} = WebGUI::International::get(61,$self->get("namespace"));
	$var{'report.overview.url'} = WebGUI::URL::page('func=viewStatisticalOverview&wid='.$self->get("wobjectId"));
	$var{'report.overview.label'} = WebGUI::International::get(59,$self->get("namespace"));
        $var{'survey.url'} = WebGUI::URL::page();
	$var{'survey.label'} = WebGUI::International::get(60,$self->get("namespace"));
	return \%var;
}

#-------------------------------------------------------------------
sub getQuestionCount {
	my $self = shift;
	my ($count) = WebGUI::SQL->quickArray("select count(*) from Survey_question where Survey_id=".quote($self->get("Survey_id")));
	return ($count < $self->getValue("questionsPerResponse")) ? $count : $self->getValue("questionsPerResponse");
}

#-------------------------------------------------------------------
sub getQuestionsLoop {
	my $self = shift;
	my $responseId = shift;
	my @ids;
	if ($self->get("questionOrder") eq "sequential") {
		@ids = $self->getSequentialQuestionIds($responseId);
	} elsif ($self->get("questionOrder") eq "response") {
		@ids = $self->getResponseDrivenQuestionIds($responseId);
	} else {
		@ids = $self->getRandomQuestionIds($responseId);
	}
	my $length = scalar(@ids);
	my $i = 1;
	my @loop;
	my $questionResponseCount = $self->getQuestionResponseCount($responseId);
	while ($i <= $length && $i<= $self->get("questionsPerPage") && ($questionResponseCount + $i) <= $self->getValue("questionsPerResponse")) {
		push(@loop,$self->getQuestionVars($ids[($i-1)]));
		$i++;
	}
	return \@loop;
}


#-------------------------------------------------------------------
sub getQuestionResponseCount {
	my $self = shift;
	my $responseId = shift;
	my ($count) = WebGUI::SQL->quickArray("select count(*) from Survey_questionResponse where Survey_responseId=".quote($responseId));
	return $count;
}

#-------------------------------------------------------------------
sub getQuestionVars {
	my $self = shift;
	my $questionId = shift;
	my %var;
	my $question = WebGUI::SQL->getRow("Survey_question","Survey_questionId",$questionId);
	$var{'question.question'} = $question->{question};
	$var{'question.allowComment'} = $question->{allowComment};
	$var{'question.id'} = $question->{Survey_questionId};
	$var{'question.comment.field'} = WebGUI::Form::textarea({
		name=>'comment_'.$questionId
		});
	$var{'question.comment.label'} = WebGUI::International::get(51,$self->get("namespace"));
	if ($question->{answerFieldType} eq "text") {
		my ($answer) = WebGUI::SQL->quickArray("select Survey_answerId from Survey_answer where Survey_questionId=".quote($question->{Survey_questionId})); 
		$var{'question.answer.field'} = WebGUI::Form::hidden({
			name=>'answerId_'.$questionId,
			value=>$answer
			});
		$var{'question.answer.field'} .= WebGUI::Form::text({
			name=>'textResponse_'.$questionId
			});
	} else {
		my $answer = WebGUI::SQL->buildHashRef("select Survey_answerId,answer from Survey_answer where Survey_questionId=".quote($question->{Survey_questionId})." order by sequenceNumber");
		if ($question->{randomizeAnswers}) {
			$answer = randomizeHash($answer);
		}
		$var{'question.answer.field'} = WebGUI::Form::radioList({
			options=>$answer,
			name=>"answerId_".$questionId,
			vertical=>1
			});
	}
	return \%var;
}

#-------------------------------------------------------------------
sub getRandomQuestionIds {
	my $self = shift;
	my $responseId = shift;
	my @usedQuestionIds = WebGUI::SQL->buildArray("select Survey_questionId from Survey_questionResponse where Survey_responseId=".quote($responseId));
	my $where = " where Survey_id=".quote($self->get("Survey_id"));
	if ($#usedQuestionIds+1 > 0) {
		$where .= " and Survey_questionId not in (".quoteAndJoin(\@usedQuestionIds).")";
	}
	my @questions = WebGUI::SQL->buildArray("select Survey_questionId from Survey_question".$where);
	randomizeArray(\@questions);
	return @questions;
}

#-------------------------------------------------------------------
sub getResponseCount {
	my $self = shift;
	my $ipAddress = $self->getIp;
	my $userId = $self->getUserId;
	my ($count) = WebGUI::SQL->quickArray("select count(*) from Survey_response where Survey_id=".quote($self->get("Survey_id"))." and 
		((userId<>1 and userId=".quote($userId).") or ( userId=1 and ipAddress=".quote($ipAddress)."))");
	return $count;
}


#-------------------------------------------------------------------
sub getResponseDrivenQuestionIds {
	my $self = shift;
	my $responseId = shift;
        my $previousResponse = WebGUI::SQL->quickHashRef("select Survey_questionId, Survey_answerId from Survey_questionResponse 
		where Survey_responseId=".quote($responseId)." order by dateOfResponse desc");
	my $questionId;
	my @questions;
	if ($previousResponse->{Survey_answerId}) {
	        ($questionId) = WebGUI::SQL->quickArray("select gotoQuestion from Survey_answer where 
			Survey_answerId=".quote($previousResponse->{Survey_answerId}));
	        unless ($questionId > 0) { 
			($questionId) = WebGUI::SQL->quickArray("select gotoQuestion from Survey_question where 
				Survey_questionId=".quote($previousResponse->{Survey_questionId}));
		}
		unless ($questionId > 0) { # terminate survey
			$self->completeResponse($responseId);	
			return ();
		}
	} else {
		($questionId) = WebGUI::SQL->quickArray("select Survey_questionId from Survey_question where Survey_id=".quote($self->getValue("Survey_id"))."
			order by sequenceNumber");
	}
	push(@questions,$questionId);
	return @questions;
}

#-------------------------------------------------------------------
sub getResponseId {
	my $self = shift;
	return $session{scratch}{$self->getResponseIdString};
}

#-------------------------------------------------------------------
sub getResponseIdString {
	my $self = shift;
	return "Survey-".$self->get("Survey_id")."-ResponseId";
}


#-------------------------------------------------------------------
sub getSequentialQuestionIds {
	my $self = shift;
	my $responseId = shift;
	my @usedQuestionIds = WebGUI::SQL->buildArray("select Survey_questionId from Survey_questionResponse where Survey_responseId=".quote($responseId));
	my $where = " where Survey_id=".quote($self->get("Survey_id"));
	if ($#usedQuestionIds+1 > 0) {
		$where .= " and Survey_questionId not in (".quoteAndJoin(\@usedQuestionIds).")";
	}
	my @questions = WebGUI::SQL->buildArray("select Survey_questionId from Survey_question $where order by sequenceNumber");
	return @questions;
}

#-------------------------------------------------------------------
sub getUserId {
	my $self = shift;
	my $userId = ($self->get("anonymous") && $session{user}{userId} != 1) ? substr(md5_hex($session{user}{userId}),0,8) : $session{user}{userId};
	return $userId;
}

#-------------------------------------------------------------------
sub name {
        return WebGUI::International::get(1,$_[0]->get("namespace"));
}

#-------------------------------------------------------------------
sub new {
        my $class = shift;
        my $property = shift;
        my $self = WebGUI::Wobject->new(
                -properties=>$property,
                -extendedProperties=>{
			Survey_id=>{}, 
			questionOrder=>{
				defaultValue=>"sequential"
				}, 
			groupToTakeSurvey=>{
				defaultValue=>2
				}, 
			groupToViewReports=>{
				defaultValue=>4
				},
			mode=>{
				defaultValue=>"survey"
				},
			anonymous=>{
				defaultValue=>0
				},
			maxResponsesPerUser=>{
				defaultValue=>1,
				fieldType=>"integer"
				},
			questionsPerResponse=>{
				defaultValue=>99999,
				fieldType=>"integer"
				},
			questionsPerPage=>{
				defaultValue=>1,
				fieldType=>"integer"
				},
			reportcardTemplateId=>{
				defaultValue=>1
				},
			overviewTemplateId=>{
				defaultValue=>1
				}
			},
		-useTemplate=>1,
		-useMetaData=>1
                );
        bless $self, $class;
}

#-------------------------------------------------------------------
sub purge {
	my ($count) = WebGUI::SQL->quickArray("select count(*) from Survey where Survey_id=".quote($_[0]->get("Survey_id")));
	if ($count < 2) { ### Check for other wobjects using this survey.
        	WebGUI::SQL->write("delete from Survey_question where Survey_id=".quote($_[0]->get("Survey_id")));
        	WebGUI::SQL->write("delete from Survey_answer where Survey_id=".quote($_[0]->get("Survey_id")));
        	WebGUI::SQL->write("delete from Survey_response where Survey_id=".quote($_[0]->get("Survey_id")));
	}
        $_[0]->SUPER::purge();
}


#-------------------------------------------------------------------
sub responseIsComplete {
	my $self = shift;
	my $responseId = shift;
	my $response = WebGUI::SQL->getRow("Survey_response","Survey_responseId",$responseId);
	return $response->{isComplete};
}


#-------------------------------------------------------------------
sub setAnswerType {
	$_[0]->setCollateral("Survey_question","Survey_questionId",{
		Survey_questionId=>$_[2],
		Survey_id=>$_[0]->get("Survey_id"),
		answerFieldType=>$_[1]
		},1,0,"Survey_id");
}

#-------------------------------------------------------------------
sub uiLevel {
	return 5;
}

#-------------------------------------------------------------------
sub www_deleteAnswer {
	my $self = shift;
        return WebGUI::Privilege::insufficient() unless ($self->canEdit);
	my ($answerCount) = WebGUI::SQL->quickArray("select count(*) from Survey_answer where Survey_questionId=".quote($session{form}{qid}));
	if ($answerCount > 1) {
        	return $self->confirm(
			$self->i18n(45),
                	WebGUI::URL::page('func=deleteAnswerConfirm&wid='.$self->wid.'&aid='.$session{form}{aid}.'&qid='.$session{form}{qid})
			);
	} else {
		return $self->i18n("cannot delete the last answer");
	}
}

#-------------------------------------------------------------------
sub www_deleteAnswerConfirm {
        return WebGUI::Privilege::insufficient() unless ($_[0]->canEdit);
        WebGUI::SQL->write("delete from Survey_questionResponse where Survey_answerId=".quote($session{form}{aid}));
        $_[0]->deleteCollateral("Survey_answer","Survey_answerId",$session{form}{aid});
        $_[0]->reorderCollateral("Survey_answer","Survey_answerId","Survey_id");
        return $_[0]->www_editQuestion;
}

#-------------------------------------------------------------------
sub www_deleteQuestion {
        return WebGUI::Privilege::insufficient() unless ($_[0]->canEdit);
        return $_[0]->confirm(WebGUI::International::get(44,$_[0]->get("namespace")),
        	WebGUI::URL::page('func=deleteQuestionConfirm&wid='.$_[0]->get("wobjectId").'&qid='.$session{form}{qid}));
}

#-------------------------------------------------------------------
sub www_deleteQuestionConfirm {
        return WebGUI::Privilege::insufficient() unless ($_[0]->canEdit);
	WebGUI::SQL->write("delete from Survey_answer where Survey_questionId=".quote($session{form}{qid}));
	WebGUI::SQL->write("delete from Survey_questionResponse where Survey_questionId=".quote($session{form}{qid}));
        $_[0]->deleteCollateral("Survey_question","Survey_questionId",$session{form}{qid});
        $_[0]->reorderCollateral("Survey_question","Survey_questionId","Survey_id");
        return "";
}

#-------------------------------------------------------------------
sub www_deleteResponse {
	return "" unless (WebGUI::Grouping::isInGroup($_[0]->get("groupToViewReports")));
        return $_[0]->confirm(WebGUI::International::get(72,$_[0]->get("namespace")),
                WebGUI::URL::page('func=deleteResponseConfirm&amp;wid='.$_[0]->get("wobjectId").'&responseId='.$session{form}{responseId}));
}

#-------------------------------------------------------------------
sub www_deleteResponseConfirm {
	return "" unless (WebGUI::Grouping::isInGroup($_[0]->get("groupToViewReports")));
        WebGUI::SQL->write("delete from Survey_response where Survey_responseId=".quote($session{form}{responseId}));
        WebGUI::SQL->write("delete from Survey_questionResponse where Survey_responseId=".quote($session{form}{responseId}));
        return $_[0]->www_viewGradebook;
}

#-------------------------------------------------------------------
sub www_deleteAllResponses {
	return "" unless (WebGUI::Grouping::isInGroup($_[0]->get("groupToViewReports")));
        return $_[0]->confirm(WebGUI::International::get(74,$_[0]->get("namespace")),
                WebGUI::URL::page('func=deleteAllResponsesConfirm&wid='.$_[0]->get("wobjectId")));
}

#-------------------------------------------------------------------
sub www_deleteAllResponsesConfirm {
	return "" unless (WebGUI::Grouping::isInGroup($_[0]->get("groupToViewReports")));
        WebGUI::SQL->write("delete from Survey_response where Survey_id=".quote($_[0]->get("Survey_id"))); 
        WebGUI::SQL->write("delete from Survey_questionResponse where Survey_id=".quote($_[0]->get("Survey_id"))); 
        return "";
}

#-------------------------------------------------------------------
sub www_edit {
        my ($output, $sth, %data);
	tie %data, 'Tie::CPHash';
	my $properties = WebGUI::HTMLForm->new;
	my $layout = WebGUI::HTMLForm->new;
	my $privileges = WebGUI::HTMLForm->new;
	$properties->hidden("Survey_id",($_[0]->get("Survey_id") || WebGUI::Id::generate()));
	$layout->selectList(
		-name=>"questionOrder",
		-options=>{
			sequential => WebGUI::International::get(5,$_[0]->get("namespace")),
                	random => WebGUI::International::get(6,$_[0]->get("namespace")),
                	response => WebGUI::International::get(7,$_[0]->get("namespace"))
			},
		-label=>WebGUI::International::get(8,$_[0]->get("namespace")),
		-value=>[$_[0]->getValue("questionOrder")]
		);
	$layout->integer(
		-name=>"questionsPerPage",
		-value=>$_[0]->getValue("questionsPerPage"),
		-label=>WebGUI::International::get(83,$_[0]->get("namespace"))
		);
        $properties->selectList(
                -name=>"mode",
                -options=>{
			survey => WebGUI::International::get(9,$_[0]->get("namespace")),
                	quiz => WebGUI::International::get(10,$_[0]->get("namespace"))
			},
                -label=>WebGUI::International::get(11,$_[0]->get("namespace")),
                -value=>[$_[0]->getValue("mode")]
                );
	$properties->yesNo(
		-name=>"anonymous",
               	-value=>$_[0]->getValue("anonymous"),
               	-label=>WebGUI::International::get(81,$_[0]->get("namespace"))
               	);
	$properties->integer(
		-name=>"maxResponsesPerUser",
		-value=>$_[0]->getValue("maxResponsesPerUser"),
		-label=>WebGUI::International::get(84,$_[0]->get("namespace"))
		);
	$properties->integer(
		-name=>"questionsPerResponse",
		-value=>$_[0]->getValue("questionsPerResponse"),
		-label=>WebGUI::International::get(85,$_[0]->get("namespace"))
		);
	$privileges->group(
		-name=>"groupToTakeSurvey",
		-value=>[$_[0]->getValue("groupToTakeSurvey")],
		-label=>WebGUI::International::get(12,$_[0]->get("namespace"))
		);
        $privileges->group(
                -name=>"groupToViewReports",
                -label=>WebGUI::International::get(13,$_[0]->get("namespace")),
                -value=>[$_[0]->getValue("groupToViewReports")]
                );
	if ($_[0]->get("wobjectId") eq "new") {
		$properties->whatNext(
			-options=>{
				addQuestion=>WebGUI::International::get(28,$_[0]->get("namespace")),
				backToPage=>WebGUI::International::get(745)
				},
			-value=>"addQuestion"
			);
	}
	$output = $_[0]->SUPER::www_edit(
		-properties=>$properties->printRowsOnly,
		-layout=>$layout->printRowsOnly,
		-privileges=>$privileges->printRowsOnly,
		-headingId=>2,
		-helpId=>"survey add/edit"
		);
        return $output;
}

#-------------------------------------------------------------------
sub www_editSave {
	return WebGUI::Privilege::insufficient() unless ($_[0]->canEdit);
	$_[0]->SUPER::www_editSave(); 
	if ($session{form}{proceed} eq "addQuestion") {
		$session{form}{qid} = "new";
		return $_[0]->www_editQuestion;
	}
        return "";
}

#-------------------------------------------------------------------
sub www_editAnswer {
        return WebGUI::Privilege::insufficient() unless ($_[0]->canEdit);
        $session{page}{useAdminStyle} = 1;
        my ($question, $output, $f, $answer);
        $answer = $_[0]->getCollateral("Survey_answer","Survey_answerId",$session{form}{aid});
        $output = '<h1>'.WebGUI::International::get(18,$_[0]->get("namespace")).'</h1>';
        $f = WebGUI::HTMLForm->new;
        $f->hidden("wid",$session{form}{wid});
        $f->hidden("func","editAnswerSave");
        $f->hidden("qid",$session{form}{qid});
        $f->hidden("aid",$answer->{Survey_answerId});
        $f->text(
                -name=>"answer",
                -value=>$answer->{answer},
                -label=>WebGUI::International::get(19,$_[0]->get("namespace"))
                );
	if ($_[0]->get("mode") eq "quiz") {
        	$f->yesNo(
                	-name=>"isCorrect",
                	-value=>$answer->{isCorrect},
                	-label=>WebGUI::International::get(20,$_[0]->get("namespace"))
                	);
	} else {
		$f->hidden("isCorrect",0);
	}
	if ($_[0]->get("questionOrder") eq "response") {
		$question = WebGUI::SQL->buildHashRef("select Survey_questionId,question 
			from Survey_question where Survey_id=".quote($_[0]->get("Survey_id"))." order by sequenceNumber");
		$question = { ('-1' => WebGUI::International::get(82,$_[0]->get("namespace")),%$question) };
		$f->select(
			-name=>"gotoQuestion",
			-options=>$question,
			-value=>[$answer->{gotoQuestion}],
			-label=>WebGUI::International::get(21,$_[0]->get("namespace"))
			);
	}
	if ($answer->{Survey_answerId} eq "new") {
                my %options;
                tie %options, 'Tie::IxHash';
                %options = (
                        "addAnswer"=>WebGUI::International::get(24,$_[0]->get("namespace")),
                        "addQuestion"=>WebGUI::International::get(28,$_[0]->get("namespace")),
                        "editQuestion"=>WebGUI::International::get(75,$_[0]->get("namespace")),
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
        return WebGUI::Privilege::insufficient() unless ($_[0]->canEdit);
        $_[0]->setCollateral("Survey_answer", "Survey_answerId", {
                Survey_answerId => $session{form}{aid},
                Survey_questionId => $session{form}{qid},
                answer => $session{form}{answer},
                isCorrect => $session{form}{isCorrect},
		Survey_id=>$_[0]->get("Survey_id"),
                gotoQuestion => $session{form}{gotoQuestion}
                },1,0,"Survey_Id");
	if ($session{form}{proceed} eq "addQuestion") {
                $session{form}{qid} = "new";
	} elsif ($session{form}{proceed} eq "addAnswer") {
		$session{form}{aid} = "new";
		return $_[0]->www_editAnswer();
	} elsif ($session{form}{proceed} eq "backToPage") {
		return "";
        }
        return $_[0]->www_editQuestion();
}

#-------------------------------------------------------------------
sub www_editQuestion {
	return WebGUI::Privilege::insufficient() unless ($_[0]->canEdit);
        $session{page}{useAdminStyle} = 1;
	my ($output, $f, $question, $answerFieldType, $sth, %data);
	tie %data, 'Tie::CPHash';
	$question = $_[0]->getCollateral("Survey_question","Survey_questionId",$session{form}{qid});
	$output = '<h1>'.WebGUI::International::get(17,$_[0]->get("namespace")).'</h1>';
	$answerFieldType = $question->{answerFieldType} || "radioList";
	$f = WebGUI::HTMLForm->new;
	$f->hidden("wid",$_[0]->get("wobjectId"));
	$f->hidden("func","editQuestionSave");
	$f->hidden("qid",$question->{Survey_questionId});
	$f->hidden("answerFieldType",$answerFieldType);
	$f->HTMLArea(
		-name=>"question",
		-value=>$question->{question},
		-label=>WebGUI::International::get(14,$_[0]->get("namespace"))
		);
	$f->yesNo(
		-name=>"allowComment",
		-value=>$question->{allowComment},
		-label=>WebGUI::International::get(15,$_[0]->get("namespace"))
		);
	$f->yesNo(
		-name=>"randomizeAnswers",
		-value=>$question->{randomizeAnswers},
		-label=>WebGUI::International::get(16,$_[0]->get("namespace"))
		);
	if ($_[0]->get("questionOrder") eq "response") {
		my $ql = WebGUI::SQL->buildHashRef("select Survey_questionId,question 
			from Survey_question where Survey_id=".quote($_[0]->get("Survey_id"))." order by sequenceNumber");
		$ql = { ('-1' => WebGUI::International::get(82,$_[0]->get("namespace")),%$ql) };
		$f->select(
			-name=>"gotoQuestion",
			-options=>$ql,
			-value=>[$question->{gotoQuestion}],
			-label=>WebGUI::International::get(21,$_[0]->get("namespace"))
			);
	}
	if ($question->{Survey_questionId} eq "new") {
		my %options;
		tie %options, 'Tie::IxHash';
		%options = (
			"addMultipleChoiceAnswer"=>WebGUI::International::get(24,$_[0]->get("namespace")),
                        "addTextAnswer"=>WebGUI::International::get(29,$_[0]->get("namespace")),
                        "addBooleanAnswer"=>WebGUI::International::get(25,$_[0]->get("namespace")),
                        "addFrequencyAnswer"=>WebGUI::International::get(26,$_[0]->get("namespace")),
                        "addOpinionAnswer"=>WebGUI::International::get(27,$_[0]->get("namespace")),
			#"addQuestion"=>WebGUI::International::get(28,$_[0]->get("namespace")),
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
			.$question->{Survey_questionId}).'">'.WebGUI::International::get(23,$_[0]->get("namespace")).'</a><p>';
		$sth = WebGUI::SQL->read("select Survey_answerId,answer from Survey_answer 
			where Survey_questionId=".quote($question->{Survey_questionId})." order by sequenceNumber");
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
	return WebGUI::Privilege::insufficient() unless ($_[0]->canEdit);
	$session{form}{qid} = $_[0]->setCollateral("Survey_question", "Survey_questionId", {
                question=>$session{form}{question},
        	Survey_questionId=>$session{form}{qid},
		Survey_id=>$_[0]->get("Survey_id"),
                allowComment=>$session{form}{allowComment},
		gotoQuestion=>$session{form}{gotoQuestion},
		answerFieldType=>$session{form}{answerFieldType},
                randomizeAnswers=>$session{form}{randomizeAnswers}
                },1,0,"Survey_id");
        if ($session{form}{proceed} eq "addMultipleChoiceAnswer") {
        	$session{form}{aid} = "new";
                return $_[0]->www_editAnswer();
	} elsif ($session{form}{proceed} eq "addTextAnswer") {
                $_[0]->setAnswerType("text",$session{form}{qid});
        	$_[0]->addAnswer(0,$session{form}{qid});
	} elsif ($session{form}{proceed} eq "addBooleanAnswer") {
        	$_[0]->addAnswer(31,$session{form}{qid});
        	$_[0]->addAnswer(32,$session{form}{qid});
	} elsif ($session{form}{proceed} eq "addOpinionAnswer") {
                $_[0]->addAnswer(33,$session{form}{qid});
                $_[0]->addAnswer(34,$session{form}{qid});
                $_[0]->addAnswer(35,$session{form}{qid});
                $_[0]->addAnswer(36,$session{form}{qid});
                $_[0]->addAnswer(37,$session{form}{qid});
                $_[0]->addAnswer(38,$session{form}{qid});
                $_[0]->addAnswer(39,$session{form}{qid});
	} elsif ($session{form}{proceed} eq "addFrequencyAnswer") {
                $_[0]->addAnswer(40,$session{form}{qid});
                $_[0]->addAnswer(41,$session{form}{qid});
                $_[0]->addAnswer(42,$session{form}{qid});
                $_[0]->addAnswer(43,$session{form}{qid});
                $_[0]->addAnswer(39,$session{form}{qid});
	} elsif ($session{form}{proceed} eq "addQuestion") {
		$session{form}{qid} eq "new";
                return $_[0]->www_editQuestion();
	}
        return "";
}

#-------------------------------------------------------------------
sub www_exportAnswers {
        return "" unless (WebGUI::Grouping::isInGroup($_[0]->get("groupToViewReports")));
	WebGUI::HTTP::setFilename(WebGUI::URL::escape($_[0]->get("title")."_answers.tab"),"text/tab");
        return WebGUI::SQL->quickTab("select * from Survey_answer where Survey_id=".quote($_[0]->get("Survey_id")));
}

#-------------------------------------------------------------------
sub www_exportComposite {
	return "" unless (WebGUI::Grouping::isInGroup($_[0]->get("groupToViewReports")));
	WebGUI::HTTP::setFilename(WebGUI::URL::escape($_[0]->get("title")."_composite.tab"),"text/tab");
	return WebGUI::SQL->quickTab("select b.question, c.response, a.userId, a.username, a.ipAddress, c.comment, c.dateOfResponse from Survey_response a 
		left join Survey_questionResponse c on a.Survey_responseId=c.Survey_responseId 
		left join Survey_question b on c.Survey_questionId=b.Survey_questionId 
		where a.Survey_id=".quote($_[0]->get("Survey_id"))." order by a.userId, a.ipAddress, b.sequenceNumber");
}

#-------------------------------------------------------------------
sub www_exportQuestions {
        return "" unless (WebGUI::Grouping::isInGroup($_[0]->get("groupToViewReports")));
	WebGUI::HTTP::setFilename(WebGUI::URL::escape($_[0]->get("title")."_questions.tab"),"text/tab");
        return WebGUI::SQL->quickTab("select * from Survey_question where Survey_id=".quote($_[0]->get("Survey_id")));
}

#-------------------------------------------------------------------
sub www_exportResponses {
        return "" unless (WebGUI::Grouping::isInGroup($_[0]->get("groupToViewReports")));
	WebGUI::HTTP::setFilename(WebGUI::URL::escape($_[0]->get("title")."_responses.tab"),"text/tab");
        return WebGUI::SQL->quickTab("select * from Survey_response where Survey_id=".quote($_[0]->get("Survey_id")));
}

#-------------------------------------------------------------------
sub www_moveAnswerDown {
        return WebGUI::Privilege::insufficient() unless ($_[0]->canEdit);
        $_[0]->moveCollateralDown("Survey_answer","Survey_answerId",$session{form}{aid},"Survey_id");
        return $_[0]->www_editQuestion;
}

#-------------------------------------------------------------------
sub www_moveAnswerUp {
        return WebGUI::Privilege::insufficient() unless ($_[0]->canEdit);
        $_[0]->moveCollateralUp("Survey_answer","Survey_answerId",$session{form}{aid},"Survey_id");
        return $_[0]->www_editQuestion;
}

#-------------------------------------------------------------------
sub www_moveQuestionDown {
        return WebGUI::Privilege::insufficient() unless ($_[0]->canEdit);
        $_[0]->moveCollateralDown("Survey_question","Survey_questionId",$session{form}{qid},"Survey_id");
        return "";
}

#-------------------------------------------------------------------
sub www_moveQuestionUp {
        return WebGUI::Privilege::insufficient() unless ($_[0]->canEdit);
        $_[0]->moveCollateralUp("Survey_question","Survey_questionId",$session{form}{qid},"Survey_id");
        return ""; 
}

#-------------------------------------------------------------------
sub www_respond {
	my $self = shift;
	return "" unless (WebGUI::Grouping::isInGroup($self->get("groupToTakeSurvey")));
	my $varname = $self->getResponseIdString;
	return "" unless ($session{scratch}{$varname});
	my $userId = ($self->get("anonymous")) ? substr(md5_hex($session{user}{userId}),0,8) : $session{user}{userId};
	foreach my $key (keys %{$session{form}}) {
		if ($key =~ /answerId_(\d+)/) {
			my $id = $1;
			my ($previousResponse) = WebGUI::SQL->quickArray("select count(*) from Survey_questionResponse
				where Survey_answerId=".quote($session{form}{"answerId_".$id})." and Survey_responseId=".quote($session{scratch}{$varname}));
			next if ($previousResponse);
			my $answer = $self->getCollateral("Survey_answer","Survey_answerId",quote($session{form}{"answerId_".$id}));
			my $response = $session{form}{"textResponse_".$id} || $answer->{answer};
			WebGUI::SQL->write("insert into Survey_questionResponse (Survey_answerId,Survey_questionId,Survey_responseId,Survey_id,comment,response,dateOfResponse) values (
				".quote($answer->{Survey_answerId}).", ".quote($answer->{Survey_questionId}).", ".quote($session{scratch}{$varname}).", ".quote($answer->{Survey_id}).",
				".quote($session{form}{"comment_".$id}).", ".quote($response).", ".WebGUI::DateTime::time().")");
		}
	}
	my $responseCount = $self->getQuestionResponseCount($session{scratch}{$varname}); 
	if ($responseCount >= $self->getValue("questionsPerResponse") || $responseCount >= $self->getQuestionCount) {
		WebGUI::SQL->setRow("Survey_response","Survey_responseId",{
			isComplete=>1,
			endDate=>WebGUI::DateTime::time(),
			Survey_responseId=>$session{scratch}{$varname}
			});
	}
	$self->logView() if ($session{setting}{passiveProfilingEnabled});
	return "";
}

#-------------------------------------------------------------------
sub www_view {
	my $self = shift;
	$self->logView() if ($session{setting}{passiveProfilingEnabled});
	my $var = $self->getMenuVars;
	$var->{'question.add.url'} = WebGUI::URL::page('wid='.$self->get("wobjectId").'&func=editQuestion&qid=new');
	$var->{'question.add.label'} = WebGUI::International::get(30,$self->get("namespace"));
	my @edit;
	my $sth = WebGUI::SQL->read("select Survey_questionId,question from Survey_question where Survey_id=".quote($self->get("Survey_id"))." order by sequenceNumber");
	while (my %data = $sth->hash) {
		push(@edit,{
			'question.edit.controls'=>deleteIcon('func=deleteQuestion&wid='.$self->get("wobjectId").'&qid='.$data{Survey_questionId})
				.editIcon('func=editQuestion&wid='.$self->get("wobjectId").'&qid='.$data{Survey_questionId})	
				.moveUpIcon('func=moveQuestionUp&wid='.$self->get("wobjectId").'&qid='.$data{Survey_questionId})	
				.moveDownIcon('func=moveQuestionDown&wid='.$self->get("wobjectId").'&qid='.$data{Survey_questionId}),
			'question.edit.question'=>$data{question},
			'question.edit.id'=>$data{Survey_questionId}
			});
		$var->{'question.edit_loop'} = \@edit;
	}
	$sth->finish;
	$var->{'user.canTakeSurvey'} = WebGUI::Grouping::isInGroup($self->get("groupToTakeSurvey"));
	if ($var->{'user.canTakeSurvey'}) {
		$var->{'response.Id'} = $self->getResponseId();
		$var->{'response.Count'} = $self->getResponseCount;
		$var->{'user.isFirstResponse'} = ($var->{'response.Count'} == 0 && !(exists $var->{'response.id'}));
		$var->{'user.canRespondAgain'} = ($var->{'response.Count'} < $self->get("maxResponsesPerUser"));
		if (($var->{'user.isFirstResponse'}) || ($session{form}{startNew} && $var->{'user.canRespondAgain'})) {
			$var->{'response.Id'} = $self->generateResponseId;
		}
		if ($var->{'response.Id'}) {
			$var->{'questions.soFar.count'} = $self->getQuestionResponseCount($var->{'response.Id'});
			($var->{'questions.correct.count'}) = WebGUI::SQL->quickArray("select count(*) from Survey_questionResponse a, Survey_answer b where a.Survey_responseId="
				.quote($var->{'response.Id'})." and a.Survey_answerId=b.Survey_answerId and b.isCorrect=1");
			if ($var->{'questions.soFar.count'} > 0) {
				$var->{'questions.correct.percent'} = round(($var->{'questions.correct.count'}/$var->{'questions.soFar.count'})*100)
			}
			$var->{'response.isComplete'} = $self->responseIsComplete($var->{'response.Id'});
			$var->{question_loop} = $self->getQuestionsLoop($var->{'response.Id'});
		}
	}
	$var->{'form.header'} = WebGUI::Form::formHeader()
		.WebGUI::Form::hidden({
			name=>'wid',
			value=>$self->get("wobjectId"),
			})
		.WebGUI::Form::hidden({
			name=>'func',
			value=>'respond'
			});
	$var->{'form.footer'} = WebGUI::Form::formFooter();
	$var->{'form.submit'} = WebGUI::Form::submit({
			value=>WebGUI::International::get(50,$self->get("namespace"))
			});
	$var->{'questions.sofar.label'} = WebGUI::International::get(86,$self->get("namespace"));
	$var->{'start.newResponse.label'} = WebGUI::International::get(87,$self->get("namespace"));
	$var->{'start.newResponse.url'} = WebGUI::URL::page("wid=".$self->get("wobjectId")."&amp;func=view&amp;startNew=1"); 
	$var->{'thanks.survey.label'} = WebGUI::International::get(46,$self->get("namespace"));
	$var->{'thanks.quiz.label'} = WebGUI::International::get(47,$self->get("namespace"));
	$var->{'questions.total'} = $self->getQuestionCount;
	$var->{'questions.correct.count.label'} = WebGUI::International::get(52,$self->get("namespace"));
	$var->{'questions.correct.percent.label'} = WebGUI::International::get(54,$self->get("namespace"));
	$var->{'mode.isSurvey'} = ($self->get("mode") eq "survey");
	$var->{'survey.noprivs.label'} = WebGUI::International::get(48,$self->get("namespace"));
	$var->{'quiz.noprivs.label'} = WebGUI::International::get(49,$self->get("namespace"));
	return $self->processTemplate($self->getValue("templateId"),$var);
}

#-------------------------------------------------------------------
sub www_viewGradebook {
	my $self = shift;
        return "" unless (WebGUI::Grouping::isInGroup($self->get("groupToViewReports")));
	$self->logView() if ($session{setting}{passiveProfilingEnabled});
	my $var = $self->getMenuVars;
	$var->{title} = WebGUI::International::get(71,$self->get("namespace"));
	my $p = WebGUI::Paginator->new(WebGUI::URL::page('func=viewGradebook&wid='.$self->get("wobjectId")));
	$p->setDataByQuery("select userId,username,ipAddress,Survey_responseId,startDate,endDate from Survey_response 
		where isComplete=1 and Survey_id=".$self->get("Survey_id")." order by username,ipAddress,startDate");
	my $users = $p->getPageData;
	($var->{'question.count'}) = WebGUI::SQL->quickArray("select count(*) from Survey_question where Survey_id=".quote($self->get("Survey_id")));
	if ($var->{'question.count'} > $self->get("questionsPerResponse")) {
		$var->{'question.count'} = $self->get("questionsPerResponse");
	}
	$var->{'response.user.label'} = WebGUI::International::get(67,$self->get("namespace"));
	$var->{'response.count.label'} = WebGUI::International::get(52,$self->get("namespace"));
	$var->{'response.percent.label'} = WebGUI::International::get(54,$self->get("namespace"));
	my @responseloop;
	foreach my $user (@$users) {
		my ($correctCount) = WebGUI::SQL->quickArray("select count(*) from Survey_questionResponse a left join
                	Survey_answer b on a.Survey_answerId=b.Survey_answerId where a.Survey_responseId=".quote($user->{Survey_responseId})
			." and b.isCorrect=1");
		push(@responseloop, {
			'response.url'=>WebGUI::URL::page('func=viewIndividualSurvey&amp;wid='.$self->get("wobjectId")
					.'&amp;responseId='.$user->{Survey_responseId}),
			'response.user.name'=>($user->{userId} == 1) ? $user->{ipAddress} : $user->{username},
			'response.count.correct' => $correctCount,
			'response.percent' => round(($correctCount/$var->{'question.count'})*100)
			});
	}
	$var->{response_loop} = \@responseloop;
	$p->appendTemplateVars($var);
	return $self->processTemplate($self->getValue("gradebookTemplateId"),$var,"Survey/Gradebook");
}


#-------------------------------------------------------------------
sub www_viewIndividualSurvey {
	my $self = shift;
        return "" unless (WebGUI::Grouping::isInGroup($self->get("groupToViewReports")));
	$self->logView() if ($session{setting}{passiveProfilingEnabled});
	my $var = $self->getMenuVars;
	$var->{'title'} = WebGUI::International::get(70,$self->get("namespace"));
	$var->{'delete.url'} = WebGUI::URL::page('func=deleteResponse&amp;wid='.$self->get("wobjectId").'&amp;responseId='.$session{form}{responseId});
	$var->{'delete.label'} = WebGUI::International::get(69,$self->get("namespace"));
	my $response = WebGUI::SQL->getRow("Survey_response","Survey_responseId",$session{form}{responseId});
	$var->{'start.date.label'} = WebGUI::International::get(76,$self->get("namespace"));
	$var->{'start.date.epoch'} = $response->{startDate};
	$var->{'start.date.human'} = epochToHuman($response->{startDate},"%z");
	$var->{'start.time.human'} = epochToHuman($response->{startDate},"%Z");
	$var->{'end.date.label'} = WebGUI::International::get(77,$self->get("namespace"));
	$var->{'end.date.epoch'} = $response->{endDate};
	$var->{'end.date.human'} = epochToHuman($response->{endDate},"%z");
	$var->{'end.time.human'} = epochToHuman($response->{endDate},"%Z");
	$var->{'duration.label'} = WebGUI::International::get(78,$self->get("namespace"));
	$var->{'duration.minutes'} = int(($response->{end} - $response->{start})/60);
	$var->{'duration.minutes.label'} = WebGUI::International::get(79,$self->get("namespace"));
	$var->{'duration.seconds'} = (($response->{endDate} - $response->{start})%60);
	$var->{'duration.seconds.label'} = WebGUI::International::get(80,$self->get("namespace"));
	$var->{'answer.label'} = WebGUI::International::get(19,$self->get("namespace"));
	$var->{'response.label'} = WebGUI::International::get(66,$self->get("namespace"));
	$var->{'comment.label'} = WebGUI::International::get(57,$self->get("namespace"));
	my $a = WebGUI::SQL->read("select Survey_questionId,question,answerFieldType from Survey_question 
		where Survey_id=".quote($self->get("Survey_id"))." order by sequenceNumber");
	my @questionloop;
	while (my $qdata = $a->hashRef) {
		my @aid;
		my @answer;
		if ($qdata->{answerFieldType} eq "radioList") {
			my $sth = WebGUI::SQL->read("select Survey_answerId,answer from Survey_answer 
				where Survey_questionId=".quote($qdata->{Survey_questionId})." and isCorrect=1 order by sequenceNumber");
			while (my $adata = $sth->hashRef) {
				push(@aid,$adata->{Survey_answerId});
				push(@answer,$adata->{answer});
			}
			$sth->finish;
		}
		my $rdata = WebGUI::SQL->quickHashRef("select Survey_answerId,response,comment from Survey_questionResponse 
			where Survey_questionId=".quote($qdata->{Survey_questionId})." and Survey_responseId=".quote($session{form}{responseId}));
		push(@questionloop,{
			question => $qdata->{question},
			'question.id'=>$qdata->{Survey_questionId},
			'question.isRadioList' => ($qdata->{answerFieldType} eq "radioList"),
			'question.response' => $rdata->{response},
			'question.comment' => $rdata->{comment},
			'question.isCorrect' => isIn($rdata->{Survey_answerId}, @aid),
			'question.answer' => join(", ",@answer),
			});
	}
	$a->finish;
	$var->{question_loop} = \@questionloop;
	return $self->processTemplate($self->getValue("responseTemplateId"),$var,"Survey/Response");
}

#-------------------------------------------------------------------
sub www_viewStatisticalOverview {
	my $self = shift;
        return "" unless (WebGUI::Grouping::isInGroup($self->get("groupToViewReports")));
	$self->logView() if ($session{setting}{passiveProfilingEnabled});
	my $var = $self->getMenuVars;
	$var->{title} = WebGUI::International::get(58,$self->get("namespace"));
	my $p = WebGUI::Paginator->new(WebGUI::URL::page('func=viewStatisticalOverview&wid='.$self->get("wobjectId")));
	$p->setDataByQuery("select Survey_questionId,question,answerFieldType,allowComment from Survey_question 
		where Survey_id=".$self->get("Survey_id")." order by sequenceNumber");
	my $questions = $p->getPageData;
	my @questionloop;
	$var->{'answer.label'} = WebGUI::International::get(19,$self->get("namespace"));
	$var->{'response.count.label'} = WebGUI::International::get(53,$self->get("namespace"));
	$var->{'response.percent.label'} = WebGUI::International::get(54,$self->get("namespace"));
	$var->{'show.responses.label'} = WebGUI::International::get(55,$self->get("namespace"));
	$var->{'show.comments.label'} = WebGUI::International::get(56,$self->get("namespace"));
	foreach my $question (@$questions) {
		my @answerloop;
		my ($totalResponses) = WebGUI::SQL->quickArray("select count(*) from Survey_questionResponse where Survey_questionId=".quote($question->{Survey_questionId}));
		if ($question->{answerFieldType} eq "radioList") {
			my $sth = WebGUI::SQL->read("select Survey_answerId,answer,isCorrect from Survey_answer where
				Survey_questionId=".quote($question->{Survey_questionId})." order by sequenceNumber");
			while (my $answer = $sth->hashRef) {
				my ($numResponses) = WebGUI::SQL->quickArray("select count(*) from Survey_questionResponse where Survey_answerId=".quote($answer->{Survey_answerId}));
				my $responsePercent;
				if ($totalResponses) {
					$responsePercent = round(($numResponses/$totalResponses)*100);
				} else {
					$responsePercent = 0;
				}
				my @commentloop;
				my $sth2 = WebGUI::SQL->read("select comment from Survey_questionResponse where Survey_answerId=".quote($answer->{Survey_answerId}));
				while (my ($comment) = $sth2->array) {
					push(@commentloop,{
						'answer.comment'=>$comment
						});
				}
				$sth2->finish;
				push(@answerloop,{
					'answer.isCorrect'=>$answer->{isCorrect},
					'answer' => $answer->{answer},
					'answer.response.count' =>$numResponses,
					'answer.response.percent' =>$responsePercent,
					'comment_loop'=>\@commentloop
					});
			}
			$sth->finish;
		} else {
			my $sth = WebGUI::SQL->read("select response,comment from Survey_questionResponse where Survey_questionId=".quote($question->{Survey_questionId}));
			while (my $response = $sth->hashRef) {
				push(@answerloop,{
					'answer.response'=>$response->{response},
					'answer.comment'=>$response->{comment}
					});
			}
			$sth->finish;
		}
		push(@questionloop,{
			question=>$question->{question},
			'question.id'=>$question->{Survey_questionId},
			'question.isRadioList' => ($question->{answerFieldType} eq "radioList"),
			'question.response.total' => $totalResponses,
			'answer_loop'=>\@answerloop,
			'question.allowComment'=>$question->{allowComment}
			});
	}
	$var->{question_loop} = \@questionloop;
	$p->appendTemplateVars($var);
	return $self->processTemplate($self->getValue("overviewTemplateId"),$var,"Survey/Overview");
}

1;

