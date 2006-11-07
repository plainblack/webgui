package WebGUI::Asset::Wobject::Survey;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
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
use WebGUI::International;
use WebGUI::SQL;
use WebGUI::Utility;
use WebGUI::Asset::Wobject;
use Digest::MD5 qw(md5_hex);

our @ISA = qw(WebGUI::Asset::Wobject);

#-------------------------------------------------------------------
sub addAnswer {
	my $self = shift;
	my $answer = shift;
	my $qid = shift;
	my $i18n = WebGUI::International->new($self->session,'Asset_Survey');
	$self->setCollateral("Survey_answer","Survey_answerId",{
		Survey_id=>$self->get("Survey_id"),
		Survey_questionId=>$qid,
		Survey_answerId=>"new",
		answer=>$i18n->get($answer)
		},1,0,"Survey_id");
}

#-------------------------------------------------------------------
sub addSection {
	my $self = shift;
	my $sectionName = shift;
	my $sectionId = $self->setCollateral("Survey_section","Survey_sectionId",{
		Survey_id=>$self->get("Survey_id"),
		Survey_sectionId=>"new",
		sectionName=>$sectionName
		},1,0,"Survey_id");
	
	return $sectionId;
}

#-------------------------------------------------------------------
sub completeResponse {
	my $self = shift;
	my $responseId = shift;
	$self->session->db->setRow("Survey_response","Survey_responseId",{
		'Survey_responseId'=>$responseId,
		isComplete=>1
		});
	$self->session->scratch->delete($self->getResponseIdString);
}

#-------------------------------------------------------------------
sub definition {
        my $class = shift;
	my $session = shift;
        my $definition = shift;
	my $i18n = WebGUI::International->new($session,'Asset_Survey');
        push(@{$definition}, {
		assetName=>$i18n->get('assetName'),
		uiLevel => 5,
		icon=>'survey.gif',
		tableName	=> 'Survey',
		className	=> 'WebGUI::Asset::Wobject::Survey',
                properties	=> {
			templateId => {
				fieldType	=> 'template',
				defaultValue	=> 'PBtmpl0000000000000061'
				},
			Survey_id => {
				fieldType	=> 'text',
				defaultValue	=> undef
				}, 
			questionOrder => {
				fieldType	=> 'text',
				defaultValue	=> 'sequential'
				}, 
			groupToTakeSurvey => {
				fieldType	=> 'group',
				defaultValue	=> 2
				}, 
			groupToViewReports => {
				fieldType	=> 'group',
				defaultValue	=> 4
				},
			mode => {
				fieldType 	=> 'text',
				defaultValue	=> 'survey'
				},
			anonymous=>{
				fieldType	=> 'yesNo',
				defaultValue	=> 0
				},
			maxResponsesPerUser=>{
				fieldType	=> 'integer',
				defaultValue	=> 1
				},
			questionsPerResponse=>{
				fieldType	=> 'integer',
				defaultValue	=>99999
				},
			questionsPerPage=>{
				fieldType	=> 'integer',
				defaultValue	=> 1
				},
			overviewTemplateId=>{
				fieldType	=> 'template',
				defaultValue	=> 'PBtmpl0000000000000063'
				},
			gradebookTemplateId => {
				fieldType	=> 'template',
				defaultValue	=> 'PBtmpl0000000000000062'
				},
			responseTemplateId => {
				fieldType	=> 'template',
				defaultValue	=> 'PBtmpl0000000000000064'
				},
			defaultSectionId => {
				fieldType	=> 'text',
				defaultValue	=> 'undef'
				},
			}
		});
        return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------
sub duplicate {
	my $self = shift;
	my $newAsset = $self->SUPER::duplicate(@_);
	my $newSurveyId = $self->session->id->generate();
	$newAsset->update({
		Survey_id=>$newSurveyId
		});
		
	my $sections = $self->session->db->read("select * from Survey_section where Survey_id=? order by sequenceNumber",[$self->get("Survey_id")]);
	while (my $sdata = $sections->hashRef) {
		my $oldSectionId = $sdata->{Survey_sectionId};
		$sdata->{Survey_sectionId} = "new";
		$sdata->{Survey_id} = $newSurveyId;
		$sdata->{Survey_sectionId} = $newAsset->setCollateral("Survey_section", "Survey_sectionId",$sdata,1,0, "Survey_id");
	
		my $questions = $self->session->db->read("select * from Survey_question where Survey_id=? and Survey_sectionId=?",[$self->get("Survey_id"), $oldSectionId]);
		while (my $qdata = $questions->hashRef) {
			my $oldQuestionId = $qdata->{Survey_questionId};
			$qdata->{Survey_questionId} = "new";
			$qdata->{Survey_id} = $newSurveyId;
			$qdata->{Survey_sectionId} = $sdata->{Survey_sectionId};
			$qdata->{Survey_questionId} = $newAsset->setCollateral("Survey_question","Survey_questionId",$qdata,1,0,"Survey_id");
			my $answers = $self->session->db->read("select * from Survey_answer where Survey_questionId=? order by sequenceNumber",[$oldQuestionId]);
			while (my $adata = $answers->hashRef) {
				my $oldAnswerId = $adata->{Survey_answerId};
				$adata->{Survey_answerId} = "new";
				$adata->{Survey_questionId} = $qdata->{Survey_questionId};
				$adata->{Survey_id} = $newSurveyId;
				$adata->{Survey_answerId} = $newAsset->setCollateral("Survey_answer", "Survey_answerId", $adata, 1, 0, "Survey_Id");
				my $responses = $self->session->db->read("select * from Survey_questionResponse where Survey_answerId=?",[$oldAnswerId]);
				while (my $rdata = $responses->hashRef) {
					$rdata->{Survey_responseId} = "new";
					$rdata->{Survey_answerId} = $adata->{Survey_answerId};
					$rdata->{Survey_id} = $newSurveyId;
					$rdata->{Survey_questionId} = $qdata->{Survey_questionId};
					$newAsset->setCollateral("Survey_questionResponse","Survey_responseId",$rdata,0,0);
				}
			}
		}
	}

	return $newAsset;
}

#-------------------------------------------------------------------
sub generateResponseId {
	my $self = shift;
	my $varname = $self->getResponseIdString;
	if ($self->session->scratch->get($varname)) {
		$self->completeResponse;
	}
	my $ipAddress = $self->getIp; 
	my $userId = $self->getUserId; 
	my $responseId = $self->session->db->setRow("Survey_response","Survey_responseId",{
		'Survey_responseId'=>"new",
		userId=>$userId,
		ipAddress=>$ipAddress,
		username=>$self->session->user->username,
		startDate=>$self->session->datetime->time(),
		'Survey_id'=>$self->get("Survey_id")
		});
	$self->session->scratch->set($varname,$responseId);
	return $responseId;
}

#-------------------------------------------------------------------
sub getEditForm {
	my $self = shift;
	my $tabform = $self->SUPER::getEditForm;

	my $i18n = WebGUI::International->new($self->session, 'Asset_Survey');
	$tabform->getTab('properties')->hidden(
		-name => "Survey_id",
		-value => ($self->get("Survey_id") || $self->session->id->generate())
	);
	$tabform->getTab('display')->template(
		-name		=> 'templateId',
		-label		=> $i18n->get('view template'),
		-hoverHelp	=> $i18n->get('view template description'),
		-value		=> $self->getValue('templateId'),
		-namespace	=> 'Survey',
		-afterEdit	=> 'func=edit'
		);
	$tabform->getTab('display')->template(
		-name		=> 'responseTemplateId',
		-label		=> $i18n->get('response template'),
		-hoverHelp	=> $i18n->get('response template description'),
		-value		=> $self->getValue('responseTemplateId'),
		-namespace	=> 'Survey/Response',
		-afterEdit	=> 'func=edit'
		);
	$tabform->getTab('display')->template(
		-name		=> 'gradebookTemplateId',
		-label		=> $i18n->get('gradebook template'),
		-hoverHelp	=> $i18n->get('gradebook template description'),
		-value		=> $self->getValue('gradebookTemplateId'),
		-namespace	=> 'Survey/Gradebook',
		-afterEdit	=> 'func=edit'
		);
	$tabform->getTab('display')->template(
		-name		=> 'overviewTemplateId',
		-label		=> $i18n->get('overview template'),
		-hoverHelp	=> $i18n->get('overview template description'),
		-value		=> $self->getValue('overviewTemplateId'),
		-namespace	=> 'Survey/Overview',
		-afterEdit	=> 'func=edit'
		);

	$tabform->getTab('display')->selectBox(
		-name		=> "questionOrder",
		-options	=> {
			sequential => $i18n->get(5),
                	random => $i18n->get(6),
                	response => $i18n->get(7),
                	section => $i18n->get(106)
			},
		-label		=> $i18n->get(8),
		-hoverHelp	=> $i18n->get('8 description'),
		-value		=> [$self->getValue("questionOrder")]
		);
	$tabform->getTab('display')->integer(
		-name		=> "questionsPerPage",
		-value		=> $self->getValue("questionsPerPage"),
		-label		=> $i18n->get(83),
		-hoverHelp	=> $i18n->get('83 description')
		);
        $tabform->getTab('properties')->selectBox(
                -name	=> "mode",
                -options	=> {
			survey => $i18n->get(9),
                	quiz => $i18n->get(10)
			},
                -label		=> $i18n->get(11),
                -hoverHelp	=> $i18n->get('11 description'),
                -value		=> [$self->getValue("mode")]
                );
	$tabform->getTab('properties')->yesNo(
		-name		=> "anonymous",
               	-value		=> $self->getValue("anonymous"),
               	-label		=> $i18n->get(81),
               	-hoverHelp	=> $i18n->get('81 description')
               	);
	$tabform->getTab('properties')->integer(
		-name		=> "maxResponsesPerUser",
		-value		=> $self->getValue("maxResponsesPerUser"),
		-label		=> $i18n->get(84),
		-hoverHelp	=> $i18n->get('84 description')
		);
	$tabform->getTab('properties')->integer(
		-name		=> "questionsPerResponse",
		-value		=> $self->getValue("questionsPerResponse"),
		-label		=> $i18n->get(85),
		-hoverHelp	=> $i18n->get('85 description')
		);	
	$tabform->getTab('security')->group(
		-name		=> "groupToTakeSurvey",
		-value		=> [$self->getValue("groupToTakeSurvey")],
		-label		=> $i18n->get(12),
		-hoverHelp	=> $i18n->get('12 description')
		);
        $tabform->getTab('security')->group(
                -name		=> "groupToViewReports",
                -label		=> $i18n->get(13),
                -hoverHelp	=> $i18n->get('13 description'),
                -value		=> [$self->getValue("groupToViewReports")]
                );
	if ($self->get("assetId") eq "new") {
		$tabform->getTab('properties')->whatNext(
			-options=>{
				editQuestion=>$i18n->get(28),
				viewParent=>$i18n->get(745)
				},
			-value=>"editQuestion",
                        -hoverHelp	=> $i18n->get('what next description'),
			);
	}

	return $tabform;
}

#-------------------------------------------------------------------
sub getIp {
	my $self = shift;
	my $ip = ($self->get("anonymous")) ? substr(md5_hex($self->session->env->getIp),0,8) : $self->session->env->getIp;
	return $ip;
}

#-------------------------------------------------------------------
sub getMenuVars {
	my $self = shift;
	my %var;
	my $i18n = WebGUI::International->new($self->session,'Asset_Survey');
	$var{'user.canViewReports'} = ($self->session->user->isInGroup($self->get("groupToViewReports")));
	$var{'delete.all.responses.url'} = $self->getUrl('func=deleteAllResponses');
	$var{'delete.all.responses.label'} = $i18n->get(73);
	$var{'export.answers.url'} = $self->getUrl('func=exportAnswers');
	$var{'export.answers.label'} = $i18n->get(62);
	$var{'export.questions.url'} = $self->getUrl('func=exportQuestions');
	$var{'export.questions.label'} = $i18n->get(63);
	$var{'export.responses.url'} = $self->getUrl('func=exportResponses');
	$var{'export.responses.label'} = $i18n->get(64);
	$var{'export.composite.url'} = $self->getUrl('func=exportComposite');
	$var{'export.composite.label'} = $i18n->get(65);
	$var{'report.gradebook.url'} = $self->getUrl('func=viewGradebook');
	$var{'report.gradebook.label'} = $i18n->get(61);
	$var{'report.overview.url'} = $self->getUrl('func=viewStatisticalOverview');
	$var{'report.overview.label'} = $i18n->get(59);
        $var{'survey.url'} = $self->getUrl;
	$var{'survey.label'} = $i18n->get(60);
	return \%var;
}

#-------------------------------------------------------------------
sub getQuestionCount {
	my $self = shift;
	my ($count) = $self->session->db->quickArray("select count(*) from Survey_question where Survey_id=".$self->session->db->quote($self->get("Survey_id")));
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
	} elsif ($self->get("questionOrder") eq "section") {
		@ids = $self->getSectionDrivenQuestionIds($responseId);
	} else {
		@ids = $self->getRandomQuestionIds($responseId);
	}
	my $length = scalar(@ids);
	my $i = 1;
	my @loop;
	
	#Ignore questions per page when using sections, return all questions for current section
	if ($self->get("questionOrder") eq "section") {
	  while ($i <= $length) {
	  	push(@loop,$self->getQuestionVars($ids[($i-1)]));
	  	$i++;
	  }
	  return \@loop;
	}
	
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
	my ($count) = $self->session->db->quickArray("select count(*) from Survey_questionResponse where Survey_responseId=".$self->session->db->quote($responseId));
	return $count;
}

#-------------------------------------------------------------------
sub getQuestionVars {
	my $self = shift;
	my $questionId = shift;
	my $i18n = WebGUI::International->new($self->session,'Asset_Survey');
	my %var;
	my $question = $self->session->db->getRow("Survey_question","Survey_questionId",$questionId);
	$var{'question.question'} = $question->{question};
	$var{'question.allowComment'} = $question->{allowComment};
	$var{'question.id'} = $question->{Survey_questionId};
	$var{'question.comment.field'} = WebGUI::Form::textarea($self->session,{
		name=>'comment_'.$questionId
		});
	$var{'question.comment.label'} = $i18n->get(51);

	my $answer;
	($answer) = $self->session->db->quickArray("select Survey_answerId from Survey_answer where Survey_questionId=".$self->session->db->quote($question->{Survey_questionId}));
	$var{'question.answer.field'} = WebGUI::Form::hidden($self->session,{
			name=>'answerId_'.$questionId,
			value=>$answer
			});
	if ($question->{answerFieldType} eq "text") {
		$var{'question.answer.field'} .= WebGUI::Form::text($self->session,{
			name=>'textResponse_'.$questionId
			});
	} elsif ($question->{answerFieldType} eq "HTMLArea") {
		$var{'question.answer.field'} .= WebGUI::Form::HTMLArea($self->session,{
			name=>'textResponse_'.$questionId
			});
	} elsif ($question->{answerFieldType} eq "textArea") {
		$var{'question.answer.field'} .= WebGUI::Form::textarea($self->session,{
			name=>'textResponse_'.$questionId
			});
	} else {
		my $answer = $self->session->db->buildHashRef("select Survey_answerId,answer from Survey_answer where Survey_questionId=? order by sequenceNumber", [$question->{Survey_questionId}]);
		if ($question->{randomizeAnswers}) {
			$answer = randomizeHash($answer);
		}
		$var{'question.answer.field'} = WebGUI::Form::radioList($self->session,{
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
	my @usedQuestionIds = $self->session->db->buildArray("select Survey_questionId from Survey_questionResponse where Survey_responseId=".$self->session->db->quote($responseId));
	my $where = " where Survey_id=".$self->session->db->quote($self->get("Survey_id"));
	if ($#usedQuestionIds+1 > 0) {
		$where .= " and Survey_questionId not in (".$self->session->db->quoteAndJoin(\@usedQuestionIds).")";
	}
	my @questions = $self->session->db->buildArray("select Survey_questionId from Survey_question".$where);
	randomizeArray(\@questions);
	return @questions;
}

#-------------------------------------------------------------------
sub getResponseCount {
	my $self = shift;
	my $ipAddress = $self->getIp;
	my $userId = $self->getUserId;
	my ($count) = $self->session->db->quickArray("select count(*) from Survey_response where Survey_id=".$self->session->db->quote($self->get("Survey_id"))." and 
		((userId<>'1' and userId=".$self->session->db->quote($userId).") or ( userId='1' and ipAddress=".$self->session->db->quote($ipAddress)."))");
	return $count;
}


#-------------------------------------------------------------------
sub getResponseDrivenQuestionIds {
	my $self = shift;
	my $responseId = shift;
        my $previousResponse = $self->session->db->quickHashRef("select Survey_questionId, Survey_answerId from Survey_questionResponse 
		where Survey_responseId=".$self->session->db->quote($responseId)." order by dateOfResponse desc");
	my $questionId;
	my @questions;
	if ($previousResponse->{Survey_answerId}) {
	        ($questionId) = $self->session->db->quickArray("select gotoQuestion from Survey_answer where 
			Survey_answerId=".$self->session->db->quote($previousResponse->{Survey_answerId}));
	        unless ($questionId) { 
			($questionId) = $self->session->db->quickArray("select gotoQuestion from Survey_question where 
				Survey_questionId=".$self->session->db->quote($previousResponse->{Survey_questionId}));
		}
		unless ($questionId) { # terminate survey
			$self->completeResponse($responseId);	
			return ();
		}
	} else {
		($questionId) = $self->session->db->quickArray("select Survey_questionId from Survey_question where Survey_id=".$self->session->db->quote($self->getValue("Survey_id"))."
			order by sequenceNumber");
	}
	push(@questions,$questionId);
	return @questions;
}

#-------------------------------------------------------------------
sub getSectionDrivenQuestionIds {
	my $self = shift;
	my $responseId = shift;
	my @usedQuestionIds = $self->session->db->buildArray("select Survey_questionId from Survey_questionResponse where Survey_responseId=".$self->session->db->quote($responseId));
	my @questions;
	my $where = " where Survey_question.Survey_id=".$self->session->db->quote($self->get("Survey_id"));
	$where .= " and Survey_question.Survey_sectionId=Survey_section.Survey_sectionId";	
	
	if ($#usedQuestionIds+1 > 0) {
		$where .= " and Survey_questionId not in (".$self->session->db->quoteAndJoin(\@usedQuestionIds).")";
	}
		
	my $sth = $self->session->db->read("select Survey_questionId, Survey_question.Survey_sectionId from Survey_question,
			Survey_section $where order by Survey_section.sequenceNumber, Survey_question.sequenceNumber");

	my $loopCount=0;
	my $currentSection;
	while (my $hashRef = $sth->hashRef) {
	  if ($loopCount == 0){ $currentSection = $hashRef->{Survey_sectionId}; }
	  if ($currentSection eq $hashRef->{Survey_sectionId}) {
	    push (@questions, $hashRef->{Survey_questionId});
	  }
	  $loopCount++;
	}
	$sth->finish;
	return @questions;
}



#-------------------------------------------------------------------
sub getResponseId {
	my $self = shift;
	return $self->session->scratch->get($self->getResponseIdString);
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
	my @usedQuestionIds = $self->session->db->buildArray("select Survey_questionId from Survey_questionResponse where Survey_responseId=".$self->session->db->quote($responseId));
	my $where = " where Survey_id=".$self->session->db->quote($self->get("Survey_id"));
	if ($#usedQuestionIds+1 > 0) {
		$where .= " and Survey_questionId not in (".$self->session->db->quoteAndJoin(\@usedQuestionIds).")";
	}
	my @questions = $self->session->db->buildArray("select Survey_questionId from Survey_question $where order by sequenceNumber");
	return @questions;
}

#-------------------------------------------------------------------
sub getUserId {
	my $self = shift;
	my $userId = ($self->get("anonymous") && $self->session->user->userId != 1) ? substr(md5_hex($self->session->user->userId),0,8) : $self->session->user->userId;
	return $userId;
}

#-------------------------------------------------------------------

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

sub prepareView {
	my $self = shift;
	$self->SUPER::prepareView();
	my $template = WebGUI::Asset::Template->new($self->session, $self->get("templateId"));
	$template->prepare;
	$self->{_viewTemplate} = $template;
}


#-------------------------------------------------------------------
sub processPropertiesFromFormPost {
	my $self = shift;
	$self->SUPER::processPropertiesFromFormPost;
	my $i18n = WebGUI::International->new($self->session,"Asset_Survey");
	if ($self->session->form->process("assetId") eq "new") {
	  my $defaultSectionId = $self->addSection($i18n->get(107));
	  $self->update({'defaultSectionId' => $defaultSectionId});
	  $self->session->errorHandler->warn($defaultSectionId);
	}
	
}
#-------------------------------------------------------------------
sub purge {
	my $self = shift;
	my ($count) = $self->session->db->quickArray("select count(*) from Survey where Survey_id=".$self->session->db->quote($self->get("Survey_id")));
	if ($count < 2) { ### Check for other wobjects using this survey.
        	$self->session->db->write("delete from Survey_question where Survey_id=".$self->session->db->quote($self->get("Survey_id")));
        	$self->session->db->write("delete from Survey_answer where Survey_id=".$self->session->db->quote($self->get("Survey_id")));
        	$self->session->db->write("delete from Survey_response where Survey_id=".$self->session->db->quote($self->get("Survey_id")));
        	$self->session->db->write("delete from Survey_section where Survey_id=".$self->session->db->quote($self->get("Survey_id")));
	}
        $self->SUPER::purge();
}


#-------------------------------------------------------------------
sub responseIsComplete {
	my $self = shift;
	my $responseId = shift;
	my $response = $self->session->db->getRow("Survey_response","Survey_responseId",$responseId);
	return $response->{isComplete};
}


#-------------------------------------------------------------------
sub setAnswerType {
	my $self = shift;
	my $answerFieldType = shift;
	my $qid = shift;
	$self->setCollateral("Survey_question","Survey_questionId",{
		Survey_questionId=>$qid,
		Survey_id=>$self->get("Survey_id"),
		answerFieldType=>$answerFieldType
		},1,0,"Survey_id");
}

#-------------------------------------------------------------------
sub view {
	my $self = shift;
	my $i18n = WebGUI::International->new($self->session, 'Asset_Survey');
	my $var = $self->getMenuVars;
	$var->{'question.add.url'} = $self->getUrl('func=editQuestion;qid=new');
	$var->{'question.add.label'} = $i18n->get(30);
	$var->{'section.add.url'} = $self->getUrl('func=editSection;sid=new');
	$var->{'section.add.label'} = $i18n->get(104);
	my @sectionEdit;
	
	# Get Sections
	my $sth = $self->session->db->read("select Survey_sectionId,sectionName from Survey_section where Survey_id=".$self->session->db->quote($self->get("Survey_id"))." order by sequenceNumber");
	while (my %sectionData = $sth->hash) {
		my @edit;
		
		# Get Questions for this section
		my $sth2 = $self->session->db->read("select Survey_questionId,question from Survey_question 
		   where Survey_id=".$self->session->db->quote($self->get("Survey_id"))."
		   and Survey_sectionId=".$self->session->db->quote($sectionData{Survey_sectionId})." order by sequenceNumber");
		while (my %data = $sth2->hash) {
		  push(@edit,{
			'question.edit.controls'=>
				$self->session->icon->delete('func=deleteQuestionConfirm;qid='.$data{Survey_questionId}, $self->get("url"), $i18n->get(44)).
				$self->session->icon->edit('func=editQuestion;qid='.$data{Survey_questionId}, $self->get("url")).
				$self->session->icon->moveUp('func=moveQuestionUp;qid='.$data{Survey_questionId}, $self->get("url")).
				$self->session->icon->moveDown('func=moveQuestionDown;qid='.$data{Survey_questionId}, $self->get("url")),
			'question.edit.question'=>$data{question},
			'question.edit.id'=>$data{Survey_questionId}
		  });
		}
		$sth2->finish;
	
		push(@sectionEdit,{
			'section.edit.controls'=>
				$self->session->icon->delete('func=deleteSectionConfirm;sid='.$sectionData{Survey_sectionId}, $self->get("url"), $i18n->get(105)).
				$self->session->icon->edit('func=editSection;sid='.$sectionData{Survey_sectionId}, $self->get("url")).
				$self->session->icon->moveUp('func=moveSectionUp;sid='.$sectionData{Survey_sectionId}, $self->get("url")).
				$self->session->icon->moveDown('func=moveSectionDown;sid='.$sectionData{Survey_sectionId}, $self->get("url")),
			'section.edit.sectionName'=>$sectionData{sectionName},
			'section.edit.id'=>$sectionData{Survey_sectionId},
			'section.questions_loop'=>\@edit
			});
		$var->{'section.edit_loop'} = \@sectionEdit;
		
	}
	$sth->finish;
		
	$var->{'user.canTakeSurvey'} = $self->session->user->isInGroup($self->get("groupToTakeSurvey"));
	if ($var->{'user.canTakeSurvey'}) {
		$var->{'response.Id'} = $self->getResponseId();
		$var->{'response.Count'} = $self->getResponseCount;
		$var->{'user.isFirstResponse'} = ($var->{'response.Count'} == 0 && !(exists $var->{'response.id'}));
		$var->{'user.canRespondAgain'} = ($var->{'response.Count'} < $self->get("maxResponsesPerUser"));
		if (($var->{'user.isFirstResponse'}) || ($self->session->form->process("startNew") && $var->{'user.canRespondAgain'})) {
			$var->{'response.Id'} = $self->generateResponseId;
		}
		if ($var->{'response.Id'}) {
			$var->{'questions.soFar.count'} = $self->getQuestionResponseCount($var->{'response.Id'});
			($var->{'questions.correct.count'}) = $self->session->db->quickArray("select count(*) from Survey_questionResponse a, Survey_answer b where a.Survey_responseId="
				.$self->session->db->quote($var->{'response.Id'})." and a.Survey_answerId=b.Survey_answerId and b.isCorrect=1");
			if ($var->{'questions.soFar.count'} > 0) {
				$var->{'questions.correct.percent'} = round(($var->{'questions.correct.count'}/$var->{'questions.soFar.count'})*100)
			}
			$var->{'response.isComplete'} = $self->responseIsComplete($var->{'response.Id'});
			$var->{question_loop} = $self->getQuestionsLoop($var->{'response.Id'});
		}
	}
	$var->{'form.header'} = WebGUI::Form::formHeader($self->session,{action=>$self->getUrl})
		.WebGUI::Form::hidden($self->session,{
			name=>'func',
			value=>'respond'
			});
	$var->{'form.footer'} = WebGUI::Form::formFooter($self->session,);
	$var->{'form.submit'} = WebGUI::Form::submit($self->session,{
			value=>$i18n->get(50)
			});
	$var->{'questions.sofar.label'} = $i18n->get(86);
	$var->{'start.newResponse.label'} = $i18n->get(87);
	$var->{'start.newResponse.url'} = $self->getUrl("func=view;startNew=1"); 
	$var->{'thanks.survey.label'} = $i18n->get(46);
	$var->{'thanks.quiz.label'} = $i18n->get(47);
	$var->{'questions.total'} = $self->getQuestionCount;
	$var->{'questions.correct.count.label'} = $i18n->get(52);
	$var->{'questions.correct.percent.label'} = $i18n->get(54);
	$var->{'mode.isSurvey'} = ($self->get("mode") eq "survey");
	$var->{'survey.noprivs.label'} = $i18n->get(48);
	$var->{'quiz.noprivs.label'} = $i18n->get(49);
	return $self->processTemplate($var, undef, $self->{_viewTemplate});
}

#-------------------------------------------------------------------
sub www_deleteAnswerConfirm {
	my $self = shift;
        return $self->session->privilege->insufficient() unless ($self->canEdit);
        my ($answerCount) = $self->session->db->quickArray("select count(*) from Survey_answer where Survey_questionId=".$self->session->db->quote($self->session->form->process("qid")));
	return $self->i18n("cannot delete the last answer") unless($answerCount);
        $self->session->db->write("delete from Survey_questionResponse where Survey_answerId=".$self->session->db->quote($self->session->form->process("aid")));
        $self->deleteCollateral("Survey_answer","Survey_answerId",$self->session->form->process("aid"));
        $self->reorderCollateral("Survey_answer","Survey_answerId","Survey_id");
        return $self->www_editQuestion;
}

#-------------------------------------------------------------------
sub www_deleteQuestionConfirm {
	my $self = shift;
        return $self->session->privilege->insufficient() unless ($self->canEdit);
	$self->session->db->write("delete from Survey_answer where Survey_questionId=".$self->session->db->quote($self->session->form->process("qid")));
	$self->session->db->write("delete from Survey_questionResponse where Survey_questionId=".$self->session->db->quote($self->session->form->process("qid")));
        $self->deleteCollateral("Survey_question","Survey_questionId",$self->session->form->process("qid"));
        $self->reorderCollateral("Survey_question","Survey_questionId","Survey_id");
        return "";
}

#-------------------------------------------------------------------
sub www_deleteSectionConfirm {
	my $self = shift;
        return $self->session->privilege->insufficient() unless ($self->canEdit);
	my $i18n = WebGUI::International->new($self->session,'Asset_Survey');
        my $section_id = $self->session->form->get("sid");
        if ($section_id eq $self->get("defaultSectionId")) {
	  return $self->session->privilege->vitalComponent();
	}
        
	$self->session->db->write("delete from Survey_section where Survey_sectionId=?",[$section_id]);
        $self->deleteCollateral("Survey_section","Survey_sectionId",$section_id);
        $self->reorderCollateral("Survey_section","Survey_sectionId","Survey_id");
        return "";
}

#-------------------------------------------------------------------
sub www_deleteResponse {
	my $self = shift;
	return "" unless ($self->session->user->isInGroup($self->get("groupToViewReports")));
	my $i18n = WebGUI::International->new($self->session, 'Asset_Survey');
        return $self->session->style->process($self->confirm($i18n->get(72),
                $self->getUrl('func=deleteResponseConfirm;responseId='.$self->session->form->process("responseId"))),$self->getValue("styleTemplateId"));
}

#-------------------------------------------------------------------
sub www_deleteResponseConfirm {
	my $self = shift;
	return "" unless ($self->session->user->isInGroup($self->get("groupToViewReports")));
        $self->session->db->write("delete from Survey_response where Survey_responseId=".$self->session->db->quote($self->session->form->process("responseId")));
        $self->session->db->write("delete from Survey_questionResponse where Survey_responseId=".$self->session->db->quote($self->session->form->process("responseId")));
        return $self->www_viewGradebook;
}

#-------------------------------------------------------------------
sub www_deleteAllResponses {
	my $self = shift;
	return "" unless ($self->session->user->isInGroup($self->get("groupToViewReports")));
	my $i18n = WebGUI::International->new($self->session,'Asset_Survey');
	return $self->session->style->process($self->confirm($i18n->get(74),$self->getUrl('func=deleteAllResponsesConfirm')),$self->getValue("styleTemplateId"));
}

#-------------------------------------------------------------------
sub www_deleteAllResponsesConfirm {
	my $self = shift;
	return "" unless ($self->session->user->isInGroup($self->get("groupToViewReports")));
        $self->session->db->write("delete from Survey_response where Survey_id=".$self->session->db->quote($self->get("Survey_id"))); 
        $self->session->db->write("delete from Survey_questionResponse where Survey_id=".$self->session->db->quote($self->get("Survey_id"))); 
        return "";
}

#-------------------------------------------------------------------
sub www_editSave {
	my $self = shift;
	return $self->session->privilege->insufficient() unless ($self->canEdit);
	my $output = $self->SUPER::www_editSave(); 
	if ($self->session->form->process("proceed") eq "addQuestion") {
		return $self->www_editQuestion('new');
	}
	return $output;
}

#-------------------------------------------------------------------
sub www_editAnswer {
	my $self = shift;
        my ($question, $f, $answer);	
        return $self->session->privilege->insufficient() unless ($self->canEdit);
	my $aid = shift || $self->session->form->process('aid');
	my $qid = shift || $self->session->form->process('qid');
	
	my $i18n = WebGUI::International->new($self->session,'Asset_Survey');
	$answer = $self->getCollateral("Survey_answer","Survey_answerId",$aid);
        $f = WebGUI::HTMLForm->new($self->session,-action=>$self->getUrl);
        $f->hidden(
		-name => "assetId",
		-value => $self->session->form->process("assetId")
	);
        $f->hidden(
		-name => "func",
		-value => "editAnswerSave"
	);
        $f->hidden(
		-name => "qid",
		-value => $qid
	);
        $f->hidden(
		-name => "aid",
		-value => $answer->{Survey_answerId}
	);
        $f->text(
                -name=>"answer",
                -value=>$answer->{answer},
                -label=>$i18n->get(19),
                -hoverHelp=>$i18n->get('19 description')
                );
	if ($self->get("mode") eq "quiz") {
        	$f->yesNo(
                	-name=>"isCorrect",
                	-value=>$answer->{isCorrect},
                	-label=>$i18n->get(20),
                	-hoverHelp=>$i18n->get('20 description')
                	);
	} else {
		$f->hidden(
			-name => "isCorrect",
			-value => 0
		);
	}
	if ($self->get("questionOrder") eq "response") {
		$question = $self->session->db->buildHashRef("select Survey_questionId,question 
			from Survey_question where Survey_id=".$self->session->db->quote($self->get("Survey_id"))." order by sequenceNumber");
		$question = { ('-1' => $i18n->get(82),%$question) };
		$f->selectBox(
			-name=>"gotoQuestion",
			-options=>$question,
			-value=>[$answer->{gotoQuestion}],
			-label=>$i18n->get(21),
			-hoverHelp=>$i18n->get('21 description')
			);
	}
	if ($answer->{Survey_answerId} eq "new") {
                my %options;
                tie %options, 'Tie::IxHash';
                %options = (
                        "addAnswer"=>$i18n->get(24),
                        "addQuestion"=>$i18n->get(28),
                        "editQuestion"=>$i18n->get(75),
                        "backToPage"=>$i18n->get(745)
                        );
                $f->whatNext(
                        -options=>\%options,
                        -value=>"addAnswer",
			-hoverHelp=>$i18n->get('what next answer description')
                        );
        }
        $f->submit;

#	$self->getAdminConsole->setHelp("answer add/edit","Asset_Survey");
	return $self->getAdminConsole->render($f->print, $i18n->get(18));

}

#-------------------------------------------------------------------
sub www_editAnswerSave {
	my $self = shift;
        return $self->session->privilege->insufficient() unless ($self->canEdit);
	my $qid = $self->session->form->process("qid");
        $self->setCollateral("Survey_answer", "Survey_answerId", {
                Survey_answerId => $self->session->form->process("aid"),
                Survey_questionId => $qid,
                answer => $self->session->form->process("answer"),
                isCorrect => $self->session->form->process("isCorrect"),
		Survey_id=>$self->get("Survey_id"),
                gotoQuestion => $self->session->form->process("gotoQuestion")
                },1,0,"Survey_questionId", $qid);
	if ($self->session->form->process("proceed") eq "addQuestion") {
		return $self->www_editQuestion('new');
	} elsif ($self->session->form->process("proceed") eq "addAnswer") {
		return $self->www_editAnswer('new');
	} elsif ($self->session->form->process("proceed") eq "backToPage") {
		return "";
        }
        return $self->www_editQuestion();
}

#-------------------------------------------------------------------
sub www_editQuestion {
	my $self = shift;
	my ($f, $question, $answerFieldType, $sth, %data);
	my $qid = shift || $self->session->form->process('qid');

	return $self->session->privilege->insufficient() unless ($self->canEdit);

	my $i18n = WebGUI::International->new($self->session,'Asset_Survey');
	tie %data, 'Tie::CPHash';
	$question = $self->getCollateral("Survey_question","Survey_questionId", $qid);
	$answerFieldType = $question->{answerFieldType} || "radioList";

	$f = WebGUI::HTMLForm->new($self->session,-action=>$self->getUrl);
	$f->hidden(
		-name => "assetId",
		-value => $self->get("assetId")
	);
	$f->hidden(
		-name => "func",
		-value => "editQuestionSave"
	);
	$f->hidden(
		-name => "qid",
		-value => $question->{Survey_questionId}
	);
	$f->hidden(
		-name => "answerFieldType",
		-value => $answerFieldType
	);
	$f->HTMLArea(
		-name	=> "question",
		-value	=> $question->{question},
		-label	=> $i18n->get(14),
		-hoverHelp	=> $i18n->get('14 description')
		);
	$f->yesNo(
		-name	=> "allowComment",
		-value	=> $question->{allowComment},
		-label	=> $i18n->get(15),
		-hoverHelp	=> $i18n->get('15 description')
		);
	$f->yesNo(
		-name	=> "randomizeAnswers",
		-value	=> $question->{randomizeAnswers},
		-label	=> $i18n->get(16),
		-hoverHelp	=> $i18n->get('16 description')
		);
	
	my $sectionList = $self->session->db->buildHashRef("select Survey_sectionId,sectionName
			  from Survey_section where Survey_id=".$self->session->db->quote($self->get("Survey_id"))." order by sequenceNumber");

	$f->selectBox(
			-name	=> "section",
			-options=> $sectionList,
			-value	=> [$question->{Survey_sectionId}],
			-label	=> $i18n->get(106),
			-hoverHelp	=> $i18n->get('106 description'),
		      );

	if ($self->get("questionOrder") eq "response") {
		my $ql = $self->session->db->buildHashRef("select Survey_questionId,question 
			from Survey_question where Survey_id=".$self->session->db->quote($self->get("Survey_id"))." order by sequenceNumber");
		$ql = { ('-1' => $i18n->get(82),%$ql) };
		$f->selectBox(
			-name	=> "gotoQuestion",
			-options=> $ql,
			-value	=> [$question->{gotoQuestion}],
			-label	=> $i18n->get(21),
			-hoverHelp	=> $i18n->get('21 description')
			);
	}

	if ($question->{Survey_questionId} eq "new") {
		my %options;
		tie %options, 'Tie::IxHash';
		%options = (
			"addMultipleChoiceAnswer"	=> $i18n->get(24),
                        "addTextAnswer"			=> $i18n->get(29),
                        "addBooleanAnswer"		=> $i18n->get(25),
                        "addFrequencyAnswer"		=> $i18n->get(26),
                        "addOpinionAnswer"		=> $i18n->get(27),
                        "addHTMLAreaAnswer"		=> $i18n->get(100),
                        "addTextAreaAnswer"		=> $i18n->get(101),
			#"addQuestion"			=> $i18n->get(28),
                        "backToPage"			=> $i18n->get(745)
			);
        	$f->whatNext(
                	-options=> \%options,
                	-value	=> "addMultipleChoiceAnswer",
			-hoverHelp	=> $i18n->get('what next question description')
                	);
	}
	$f->submit;
	my $output = $f->print;
	if ($question->{Survey_questionId} ne "new" 
	   && $question->{answerFieldType} ne "text" 
	   && $question->{answerFieldType} ne "HTMLArea"
	   && $question->{answerFieldType} ne "textArea"
	) {
		$output .= '<a href="'.$self->getUrl('func=editAnswer;aid=new;qid='
			.$question->{Survey_questionId}).'">'.$i18n->get(23).'</a><p />';
		$sth = $self->session->db->read("select Survey_answerId,answer from Survey_answer 
			where Survey_questionId=".$self->session->db->quote($question->{Survey_questionId})." order by sequenceNumber");
		while (%data = $sth->hash) {
			$output .= 
				$self->session->icon->delete('func=deleteAnswerConfirm;qid='.$question->{Survey_questionId}.';aid='.$data{Survey_answerId}, 
					$self->get("url"),$i18n->get(45)).
                                $self->session->icon->edit('func=editAnswer;qid='.$question->{Survey_questionId}.';aid='.$data{Survey_answerId}, $self->get("url")).
                                $self->session->icon->moveUp('func=moveAnswerUp'.';qid='.$question->{Survey_questionId}.';aid='.$data{Survey_answerId}, $self->get("url")).
                                $self->session->icon->moveDown('func=moveAnswerDown;qid='.$question->{Survey_questionId}.';aid='.$data{Survey_answerId}, $self->get("url")).
                                ' '.$data{answer}.'<br />';
		}
		$sth->finish;
	}
	$self->getAdminConsole->setHelp("question add/edit","Asset_Survey");
	return $self->getAdminConsole->render($output, $i18n->get(17));
}

#-------------------------------------------------------------------
sub www_editQuestionSave {
	my $self = shift;
	return $self->session->privilege->insufficient() unless ($self->canEdit);

	my $qid = $self->setCollateral("Survey_question", "Survey_questionId", {
		# XXX: In some cases not all form fields are present and then the SQL query failes
		# because the array is not complete
		# There has to be a better way to fix this problem, but adding "|| 1" works for now
                question=>$self->session->form->process("question", 'HTMLArea') || 1,
        	Survey_questionId=>$self->session->form->process("qid") || 1,
		Survey_id=>$self->get("Survey_id") || 1,
                allowComment=>$self->session->form->process("allowComment", 'yesNo'),
		gotoQuestion=>$self->session->form->process("gotoQuestion", 'selectBox') || 1,
		answerFieldType=>$self->session->form->process("answerFieldType") || 1,
                randomizeAnswers=>$self->session->form->process("randomizeAnswers", 'yesNo'),
                Survey_sectionId=>$self->session->form->process("section") || 1
                },1,0,"Survey_id");

        if ($self->session->form->process("proceed") eq "addMultipleChoiceAnswer") {
                return $self->www_editAnswer('new',$qid);
	} elsif ($self->session->form->process("proceed") eq "addTextAnswer") {
                $self->setAnswerType("text",$qid);
        	$self->addAnswer(0,$qid);
	} elsif ($self->session->form->process("proceed") eq "addBooleanAnswer") {
        	$self->addAnswer(31,$qid);
        	$self->addAnswer(32,$qid);
	} elsif ($self->session->form->process("proceed") eq "addOpinionAnswer") {
                $self->addAnswer(33,$qid);
                $self->addAnswer(34,$qid);
                $self->addAnswer(35,$qid);
                $self->addAnswer(36,$qid);
                $self->addAnswer(37,$qid);
                $self->addAnswer(38,$qid);
                $self->addAnswer(39,$qid);
	} elsif ($self->session->form->process("proceed") eq "addFrequencyAnswer") {
                $self->addAnswer(40,$qid);
                $self->addAnswer(41,$qid);
                $self->addAnswer(42,$qid);
                $self->addAnswer(43,$qid);
                $self->addAnswer(39,$qid);
	} elsif ($self->session->form->process("proceed") eq "addHTMLAreaAnswer") {
		$self->setAnswerType("HTMLArea",$qid);
		$self->addAnswer(0,$qid);
	} elsif ($self->session->form->process("proceed") eq "addTextAreaAnswer") {
		$self->setAnswerType("textArea",$qid);
		$self->addAnswer(0,$qid);
	} elsif ($self->session->form->process("proceed") eq "addQuestion") {
                return $self->www_editQuestion('new');
	}
        return "";
}

#-------------------------------------------------------------------
sub www_editSection {
	my $self = shift;
	my ($f, $section, $sectionName);
	my $i18n = WebGUI::International->new($self->session, 'Asset_Survey');
	return $self->session->privilege->insufficient() unless ($self->canEdit);
	$section = $self->getCollateral("Survey_section","Survey_sectionId",$self->session->form->process("sid"));
	
	if ($section->{Survey_sectionId} eq $self->get("defaultSectionId") && $section->{Survey_sectionId} ne "") {
		return $self->session->privilege->vitalComponent;
	}
	
	$f = WebGUI::HTMLForm->new($self->session,-action=>$self->getUrl);
	$f->hidden(
		-name => "assetId",
		-value => $self->get("assetId")
	);
	$f->hidden(
		-name => "func",
		-value => "editSectionSave"
	);
	$f->hidden(
		-name => "sid",
		-value => $section->{Survey_sectionId}
	);

	$f->text(
		-name	=> "sectionName",
		-value	=> $section->{sectionName},
		-label	=> $i18n->get(102)
	);
	$f->submit;
	my $output = $f->print;
	return $self->getAdminConsole->render($output, $i18n->get(103));
}

#-------------------------------------------------------------------
sub www_editSectionSave {
	my $self = shift;
	return $self->session->privilege->insufficient() unless ($self->canEdit);
	$self->setCollateral("Survey_section", "Survey_sectionId", {
                sectionName => $self->session->form->process("sectionName"),
        	Survey_sectionId=>$self->session->form->process("sid"),
		Survey_id=>$self->get("Survey_id"),
                },1,0,"Survey_id");
	return "";
}

#-------------------------------------------------------------------
sub www_exportAnswers {
	my $self = shift;
        return "" unless ($self->session->user->isInGroup($self->get("groupToViewReports")));
	$self->session->http->setFilename($self->session->url->escape($self->get("title")."_answers.tab"),"text/tab");
        return $self->session->db->quickTab("select * from Survey_answer where Survey_id=".$self->session->db->quote($self->get("Survey_id")));
}

#-------------------------------------------------------------------
sub www_exportComposite {
	my $self = shift;
	return "" unless ($self->session->user->isInGroup($self->get("groupToViewReports")));
	$self->session->http->setFilename($self->session->url->escape($self->get("title")."_composite.tab"),"text/tab");
	return $self->session->db->quickTab("select b.question, c.response, a.userId, a.username, a.ipAddress, c.comment, c.dateOfResponse from Survey_response a 
		left join Survey_questionResponse c on a.Survey_responseId=c.Survey_responseId 
		left join Survey_question b on c.Survey_questionId=b.Survey_questionId 
		where a.Survey_id=".$self->session->db->quote($self->get("Survey_id"))." order by a.userId, a.ipAddress, b.sequenceNumber");
}

#-------------------------------------------------------------------
sub www_exportQuestions {
	my $self = shift;
        return "" unless ($self->session->user->isInGroup($self->get("groupToViewReports")));
	$self->session->http->setFilename($self->session->url->escape($self->get("title")."_questions.tab"),"text/tab");
        return $self->session->db->quickTab("select * from Survey_question where Survey_id=".$self->session->db->quote($self->get("Survey_id")));
}

#-------------------------------------------------------------------
sub www_exportResponses {
	my $self = shift;
        return "" unless ($self->session->user->isInGroup($self->get("groupToViewReports")));
	$self->session->http->setFilename($self->session->url->escape($self->get("title")."_responses.tab"),"text/tab");
        return $self->session->db->quickTab("select * from Survey_response where Survey_id=".$self->session->db->quote($self->get("Survey_id")));
}

#-------------------------------------------------------------------
sub www_moveAnswerDown {
	my $self = shift;
        return $self->session->privilege->insufficient() unless ($self->canEdit);
        $self->moveCollateralDown("Survey_answer","Survey_answerId",$self->session->form->process("aid"),"Survey_id");
        return $self->www_editQuestion;
}

#-------------------------------------------------------------------
sub www_moveAnswerUp {
	my $self = shift;
        return $self->session->privilege->insufficient() unless ($self->canEdit);
        $self->moveCollateralUp("Survey_answer","Survey_answerId",$self->session->form->process("aid"),"Survey_id");
        return $self->www_editQuestion;
}

#-------------------------------------------------------------------
sub www_moveQuestionDown {
	my $self = shift;
        return $self->session->privilege->insufficient() unless ($self->canEdit);
        $self->moveCollateralDown("Survey_question","Survey_questionId",$self->session->form->process("qid"),"Survey_id");
        return "";
}

#-------------------------------------------------------------------
sub www_moveQuestionUp {
	my $self = shift;
        return $self->session->privilege->insufficient() unless ($self->canEdit);
        $self->moveCollateralUp("Survey_question","Survey_questionId",$self->session->form->process("qid"),"Survey_id");
        return ""; 
}

#-------------------------------------------------------------------
sub www_moveSectionDown {
	my $self = shift;
        return $self->session->privilege->insufficient() unless ($self->canEdit);
        $self->moveCollateralDown("Survey_section","Survey_sectionId",$self->session->form->process("sid"),"Survey_id");
        return "";
}

#-------------------------------------------------------------------
sub www_moveSectionUp {
	my $self = shift;
        return $self->session->privilege->insufficient() unless ($self->canEdit);
        $self->moveCollateralUp("Survey_section","Survey_sectionId",$self->session->form->process("sid"),"Survey_id");
        return ""; 
}

#-------------------------------------------------------------------
sub www_respond {
	my $self = shift;
	return "" unless ($self->session->user->isInGroup($self->get("groupToTakeSurvey")));
	my $varname = $self->getResponseIdString;
	return "" unless ($self->session->scratch->get($varname));
	my $userId = ($self->get("anonymous")) ? substr(md5_hex($self->session->user->userId),0,8) : $self->session->user->userId;
	my $terminate = 0;
	foreach my $key ($self->session->form->param) {
		if ($key =~ /^answerId_(.+)$/) {
			my $id = $1;
			my ($previousResponse) = $self->session->db->quickArray("select count(*) from Survey_questionResponse
				where Survey_answerId=".$self->session->db->quote($self->session->form->process("answerId_".$id))." and Survey_responseId=".$self->session->db->quote($self->session->scratch->get($varname)));
			next if ($previousResponse);
			my $answer = $self->getCollateral("Survey_answer","Survey_answerId",$self->session->form->process("answerId_".$id));
			if ($self->get("questionOrder") eq "response" && $answer->{gotoQuestion} eq "") {
				$terminate = 1;
			}
			my $response = $self->session->form->process("textResponse_".$id) || $answer->{answer};
			$self->session->db->write("insert into Survey_questionResponse (Survey_answerId,Survey_questionId,Survey_responseId,Survey_id,comment,response,dateOfResponse) values (
				".$self->session->db->quote($answer->{Survey_answerId}).", ".$self->session->db->quote($answer->{Survey_questionId}).", ".$self->session->db->quote($self->session->scratch->get($varname)).", ".$self->session->db->quote($answer->{Survey_id}).",
				".$self->session->db->quote($self->session->form->process("comment_".$id)).", ".$self->session->db->quote($response).", ".$self->session->datetime->time().")");
		}
	}
	my $responseCount = $self->getQuestionResponseCount($self->session->scratch->get($varname)); 
	if ($terminate || $responseCount >= $self->getValue("questionsPerResponse") || $responseCount >= $self->getQuestionCount) {
		$self->session->db->setRow("Survey_response","Survey_responseId",{
			isComplete=>1,
			endDate=>$self->session->datetime->time(),
			Survey_responseId=>$self->session->scratch->get($varname)
			});
	}
	$self->logView() if ($self->session->setting->get("passiveProfilingEnabled"));
	return "";
}


#-------------------------------------------------------------------
sub www_viewGradebook {
	my $self = shift;
        return "" unless ($self->session->user->isInGroup($self->get("groupToViewReports")));
	$self->logView() if ($self->session->setting->get("passiveProfilingEnabled"));
	my $i18n = WebGUI::International->new($self->session,'Asset_Survey');
	my $var = $self->getMenuVars;
	$var->{title} = $i18n->get(71);
	my $p = WebGUI::Paginator->new($self->session,$self->getUrl('func=viewGradebook'));
	$p->setDataByQuery("select userId,username,ipAddress,Survey_responseId,startDate,endDate from Survey_response 
		where Survey_id=".$self->session->db->quote($self->get("Survey_id"))." order by username,ipAddress,startDate");
	my $users = $p->getPageData;
	($var->{'question.count'}) = $self->session->db->quickArray("select count(*) from Survey_question where Survey_id=".$self->session->db->quote($self->get("Survey_id")));
	if ($var->{'question.count'} > $self->get("questionsPerResponse")) {
		$var->{'question.count'} = $self->get("questionsPerResponse");
	}
	$var->{'response.user.label'} = $i18n->get(67);
	$var->{'response.count.label'} = $i18n->get(52);
	$var->{'response.percent.label'} = $i18n->get(54);
	my @responseloop;
	foreach my $user (@$users) {
		my ($correctCount) = $self->session->db->quickArray("select count(*) from Survey_questionResponse a left join
                	Survey_answer b on a.Survey_answerId=b.Survey_answerId where a.Survey_responseId=".$self->session->db->quote($user->{Survey_responseId})
			." and b.isCorrect=1");
		push(@responseloop, {
			'response.url'=>$self->getUrl('func=viewIndividualSurvey;responseId='.$user->{Survey_responseId}),
			'response.user.name'=>($user->{userId} eq '1') ? $user->{ipAddress} : $user->{username},
			'response.count.correct' => $correctCount,
			'response.percent' => round(($correctCount/$var->{'question.count'})*100)
			});
	}
	$var->{response_loop} = \@responseloop;
	$p->appendTemplateVars($var);
	return $self->session->style->process($self->processTemplate($var,$self->getValue("gradebookTemplateId")),$self->getValue("styleTemplateId"));
#	return $self->processTemplate($self->getValue("gradebookTemplateId"),$var,"Survey/Gradebook");
}


#-------------------------------------------------------------------
sub www_viewIndividualSurvey {
	my $self = shift;
        return "" unless ($self->session->user->isInGroup($self->get("groupToViewReports")));
	$self->logView() if ($self->session->setting->get("passiveProfilingEnabled"));
	my $i18n = WebGUI::International->new($self->session,'Asset_Survey');
	my $var = $self->getMenuVars;
	$var->{'title'} = $i18n->get(70);
	$var->{'delete.url'} = $self->getUrl('func=deleteResponse;responseId='.$self->session->form->process("responseId"));
	$var->{'delete.label'} = $i18n->get(69);
	my $response = $self->session->db->getRow("Survey_response","Survey_responseId",$self->session->form->process("responseId"));
	$var->{'start.date.label'} = $i18n->get(76);
	$var->{'start.date.epoch'} = $response->{startDate};
	$var->{'start.date.human'} =$self->session->datetime->epochToHuman($response->{startDate},"%z");
	$var->{'start.time.human'} =$self->session->datetime->epochToHuman($response->{startDate},"%Z");
	$var->{'end.date.label'} = $i18n->get(77);
	$var->{'end.date.epoch'} = $response->{endDate};
	$var->{'end.date.human'} =$self->session->datetime->epochToHuman($response->{endDate},"%z");
	$var->{'end.time.human'} =$self->session->datetime->epochToHuman($response->{endDate},"%Z");
	$var->{'duration.label'} = $i18n->get(78);
	$var->{'duration.minutes'} = int(($response->{end} - $response->{start})/60);
	$var->{'duration.minutes.label'} = $i18n->get(79);
	$var->{'duration.seconds'} = (($response->{endDate} - $response->{start})%60);
	$var->{'duration.seconds.label'} = $i18n->get(80);
	$var->{'answer.label'} = $i18n->get(19) if ($self->get("mode") eq "quiz");
	$var->{'response.label'} = $i18n->get(66);
	$var->{'comment.label'} = $i18n->get(57);
	my $questions = $self->session->db->read("select Survey_questionId,question,answerFieldType from Survey_question 
		where Survey_id=".$self->session->db->quote($self->get("Survey_id"))." order by sequenceNumber");
	my @questionloop;
	while (my $qdata = $questions->hashRef) {
		my @aid;
		my @answer;
		if ($qdata->{answerFieldType} eq "radioList") {
			my $sth = $self->session->db->read("select Survey_answerId,answer from Survey_answer 
				where Survey_questionId=".$self->session->db->quote($qdata->{Survey_questionId})." and isCorrect=1 order by sequenceNumber");
			while (my $adata = $sth->hashRef) {
				push(@aid,$adata->{Survey_answerId});
				push(@answer,$adata->{answer});
			}
			$sth->finish;
		}
		my $rdata = $self->session->db->quickHashRef("select Survey_answerId,response,comment from Survey_questionResponse 
			where Survey_questionId=".$self->session->db->quote($qdata->{Survey_questionId})." and Survey_responseId=".$self->session->db->quote($self->session->form->process("responseId")));
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
	$questions->finish;
	$var->{question_loop} = \@questionloop;
	return $self->session->style->process($self->processTemplate($var, $self->getValue("responseTemplateId")),$self->getValue("styleTemplateId"));
#	return $self->processTemplate($self->getValue("responseTemplateId"),$var,"Survey/Response");
}

#-------------------------------------------------------------------
sub www_viewStatisticalOverview {
	my $self = shift;
        return "" unless ($self->session->user->isInGroup($self->get("groupToViewReports")));
	$self->logView() if ($self->session->setting->get("passiveProfilingEnabled"));
	my $var = $self->getMenuVars;
	my $i18n = WebGUI::International->new($self->session,'Asset_Survey');
	$var->{title} = $i18n->get(58);
	my $p = WebGUI::Paginator->new($self->session,$self->getUrl('func=viewStatisticalOverview'));
	$p->setDataByQuery("select Survey_questionId,question,answerFieldType,allowComment from Survey_question 
		where Survey_id=".$self->session->db->quote($self->get("Survey_id"))." order by sequenceNumber");
	my $questions = $p->getPageData;
	my @questionloop;
	$var->{'answer.label'} = $i18n->get(19);
	$var->{'response.count.label'} = $i18n->get(53);
	$var->{'response.percent.label'} = $i18n->get(54);
	$var->{'show.responses.label'} = $i18n->get(55);
	$var->{'show.comments.label'} = $i18n->get(56);
	foreach my $question (@$questions) {
		my @answerloop;
		my ($totalResponses) = $self->session->db->quickArray("select count(*) from Survey_questionResponse where Survey_questionId=".$self->session->db->quote($question->{Survey_questionId}));
		if ($question->{answerFieldType} eq "radioList") {
			my $sth = $self->session->db->read("select Survey_answerId,answer,isCorrect from Survey_answer where
				Survey_questionId=".$self->session->db->quote($question->{Survey_questionId})." order by sequenceNumber");
			while (my $answer = $sth->hashRef) {
				my ($numResponses) = $self->session->db->quickArray("select count(*) from Survey_questionResponse where Survey_answerId=".$self->session->db->quote($answer->{Survey_answerId}));
				my $responsePercent;
				if ($totalResponses) {
					$responsePercent = round(($numResponses/$totalResponses)*100);
				} else {
					$responsePercent = 0;
				}
				my @commentloop;
				my $sth2 = $self->session->db->read("select comment from Survey_questionResponse where Survey_answerId=".$self->session->db->quote($answer->{Survey_answerId}));
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
			my $sth = $self->session->db->read("select response,comment from Survey_questionResponse where Survey_questionId=".$self->session->db->quote($question->{Survey_questionId}));
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

	return $self->session->style->process($self->processTemplate($var, $self->getValue("overviewTemplateId")),$self->getValue("styleTemplateId"));
}

1;

