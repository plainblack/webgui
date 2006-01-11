package WebGUI::Asset::Wobject::Poll;


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
use WebGUI::Form;
use WebGUI::Grouping;
use WebGUI::International;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::User;
use WebGUI::Utility;
use WebGUI::Asset::Wobject;

our @ISA = qw(WebGUI::Asset::Wobject);

#-------------------------------------------------------------------
sub _hasVoted {
	my $self = shift;
	my ($hasVoted) = $self->session->db->quickArray("select count(*) from Poll_answer 
		where assetId=".$self->session->db->quote($self->getId)." and ((userId=".$self->session->db->quote($self->session->user->profileField("userId"))."
		and userId<>'1') or (userId=".$self->session->db->quote($self->session->user->profileField("userId"))." and ipAddress='$self->session->env->get("REMOTE_ADDR")'))");
	return $hasVoted;
}

#-------------------------------------------------------------------
sub definition {
	my $class = shift;
	my $definition = shift;
	push(@{$definition}, {
		assetName=>WebGUI::International::get('assetName',"Asset_Poll"),
		tableName=>'Poll',
		icon=>'poll.gif',
		className=>'WebGUI::Asset::Wobject::Poll',
		properties=>{
			templateId =>{
				fieldType=>"template",
				defaultValue=>'PBtmpl0000000000000055'
				},
			active=>{
				fieldType=>"yesNo",
				defaultValue=>1
				},
			karmaPerVote=>{
				fieldType=>"integer",
				defaultValue=>0
				}, 
			graphWidth=>{
				fieldType=>"integer",
				defaultValue=>150
				}, 
			voteGroup=>{
				fieldType=>"group",
				defaultValue=>7
				}, 
			question=>{
				fieldType=>"text",
				defaultValue=>undef
				}, 
			randomizeAnswers=>{
				defaultValue=>1,
				fieldType=>"yesNo"
				},
			a1=>{
				fieldType=>"hidden",
				defaultValue=>undef
				}, 
			a2=>{
                                fieldType=>"hidden",
                                defaultValue=>undef
                                }, 
			a3=>{
                                fieldType=>"hidden",
                                defaultValue=>undef
                                }, 
			a4=>{
                                fieldType=>"hidden",
                                defaultValue=>undef
                                }, 
			a5=>{
                                fieldType=>"hidden",
                                defaultValue=>undef
                                }, 
			a6=>{
                                fieldType=>"hidden",
                                defaultValue=>undef
                                }, 
			a7=>{
                                fieldType=>"hidden",
                                defaultValue=>undef
                                }, 
			a8=>{
                                fieldType=>"hidden",
                                defaultValue=>undef
                                }, 
			a9=>{
                                fieldType=>"hidden",
                                defaultValue=>undef
                                }, 
			a10=>{
                                fieldType=>"hidden",
                                defaultValue=>undef
                                }, 
			a11=>{
                                fieldType=>"hidden",
                                defaultValue=>undef
                                }, 
			a12=>{
                                fieldType=>"hidden",
                                defaultValue=>undef
                                }, 
			a13=>{
                                fieldType=>"hidden",
                                defaultValue=>undef
                                }, 
			a14=>{
                                fieldType=>"hidden",
                                defaultValue=>undef
                                }, 
			a15=>{
                                fieldType=>"hidden",
                                defaultValue=>undef
                                }, 
			a16=>{
                                fieldType=>"hidden",
                                defaultValue=>undef
                                }, 
			a17=>{
                                fieldType=>"hidden",
                                defaultValue=>undef
                                }, 
			a18=>{
                                fieldType=>"hidden",
                                defaultValue=>undef
                                }, 
			a19=>{
                                fieldType=>"hidden",
                                defaultValue=>undef
                                }, 
			a20=>{
                                fieldType=>"hidden",
                                defaultValue=>undef
                                } 
			}
		});
        return $class->SUPER::definition($definition);
}

#-------------------------------------------------------------------
sub duplicate {
	my $self = shift;
	my $newAsset = $self->SUPER::duplicate(shift);
	my $sth = $self->session->db->read("select * from Poll_answer where assetId=".$self->session->db->quote($self->getId));
	while (my $data = $sth->hashRef) {
		$newAsset->setVote($data->{answer}, $data->{userId}, $data->{ipAddress});
	}
	$sth->finish;
	return $newAsset;
}

#-------------------------------------------------------------------
sub getEditForm {
	my $self = shift;
	my $tabform = $self->SUPER::getEditForm; 
   	$tabform->getTab("display")->template(
      		-value=>$self->getValue('templateId'),
      		-namespace=>"Poll",
		-label=>WebGUI::International::get(73,"Asset_Poll"),
		-hoverHelp=>WebGUI::International::get('73 description',"Asset_Poll"),
   		);
        my ($i, $answers);
	for ($i=1; $i<=20; $i++) {
                if ($self->get('a'.$i) =~ /\C/) {
                        $answers .= $self->getValue("a".$i)."\n";
                }
        }
	$tabform->getTab("security")->yesNo(
		-name=>"active",
		-label=>WebGUI::International::get(3,"Asset_Poll"),
		-hoverHelp=>WebGUI::International::get('3 description',"Asset_Poll"),
		-value=>$self->getValue("active")
		);
        $tabform->getTab("security")->group(
		-name=>"voteGroup",
		-label=>WebGUI::International::get(4,"Asset_Poll"),
		-hoverHelp=>WebGUI::International::get('4 description',"Asset_Poll"),
		-value=>[$self->getValue("voteGroup")]
		);
	if ($self->session->setting->get("useKarma")) {
		$tabform->getTab("properties")->integer(
			-name=>"karmaPerVote",
			-label=>WebGUI::International::get(20,"Asset_Poll"),
			-hoverHelp=>WebGUI::International::get('20 description',"Asset_Poll"),
			-value=>$self->getValue("karmaPerVote")
			);
	} else {
		$tabform->getTab("properties")->hidden(
			-name=>"karmaPerVote",
			-value=>$self->getValue("karmaPerVote")
			);
	}
	$tabform->getTab("display")->integer(
		-name=>"graphWidth",
		-label=>WebGUI::International::get(5,"Asset_Poll"),
		-hoverHelp=>WebGUI::International::get('5 description',"Asset_Poll"),
		-value=>$self->getValue("graphWidth")
		);
	$tabform->getTab("properties")->text(
		-name=>"question",
		-label=>WebGUI::International::get(6,"Asset_Poll"),
		-hoverHelp=>WebGUI::International::get('6 description',"Asset_Poll"),
		-value=>$self->getValue("question")
		);
        $tabform->getTab("properties")->textarea(
		-name=>"answers",
		-label=>WebGUI::International::get(7,"Asset_Poll"),
		-hoverHelp=>WebGUI::International::get('7 description',"Asset_Poll"),
		-subtext=>('<span class="formSubtext"><br />'.WebGUI::International::get(8,"Asset_Poll").'</span>'),
		-value=>$answers
		);
	$tabform->getTab("display")->yesNo(
		-name=>"randomizeAnswers",
		-label=>WebGUI::International::get(72,"Asset_Poll"),
		-hoverHelp=>WebGUI::International::get('72 description',"Asset_Poll"),
		-value=>$self->getValue("randomizeAnswers")
		);
	$tabform->getTab("properties")->yesNo(
		-name=>"resetVotes",
		-label=>WebGUI::International::get(10,"Asset_Poll"),
		-hoverHelp=>WebGUI::International::get('10 description',"Asset_Poll")
		) if $self->session->form->process("func") ne 'add';
	return $tabform;
}

#-------------------------------------------------------------------
sub processPropertiesFromFormPost {
	my $self = shift;
	$self->SUPER::processPropertiesFromFormPost;
	my (@answer, $i, $property);
	@answer = split("\n",$self->session->form->process("answers"));
        for ($i=1; $i<=20; $i++) {
             	$property->{'a'.$i} = $answer[($i-1)];
        }
	$self->update($property);
	$self->session->db->write("delete from Poll_answer where assetId=".$self->session->db->quote($self->getId)) if ($self->session->form->process("resetVotes"));
}


#-------------------------------------------------------------------
sub purge {
	my $self = shift;
	$self->session->db->write("delete from Poll_answer where assetId=".$self->session->db->quote($self->getId));
	$self->SUPER::purge();
}	

#-------------------------------------------------------------------
sub setVote {
	my $self = shift;
	my $answer = shift;
	my $userId = shift;
	my $ip = shift;
       	$self->session->db->write("insert into Poll_answer (assetId, answer, userId, ipAddress) values (".$self->session->db->quote($self->getId).", 
		".$self->session->db->quote($answer).", ".$self->session->db->quote($userId).", '$ip')");
}

#-------------------------------------------------------------------
sub view {
	my $self = shift;
	my (%var, $answer, @answers, $showPoll, $f);
        $var{question} = $self->get("question");
	if ($self->get("active") eq "0") {
		$showPoll = 0;
	} elsif ($self->session->user->isInGroup($self->get("voteGroup"),$self->session->user->profileField("userId"))) {
		if ($self->_hasVoted()) {
			$showPoll = 0;
		} else {
			$showPoll = 1;
		}
	} else {
		$showPoll = 0;
	}
	$var{canVote} = $showPoll;
        my ($totalResponses) = $self->session->db->quickArray("select count(*) from Poll_answer where assetId=".$self->session->db->quote($self->getId));
	$var{"responses.label"} = WebGUI::International::get(12,"Asset_Poll");
	$var{"responses.total"} = $totalResponses;
	$var{"form.start"} = WebGUI::Form::formHeader($self->session,{action=>$self->getUrl});
        $var{"form.start"} .= WebGUI::Form::hidden($self->session,{name=>'func',value=>'vote'});
	$var{"form.submit"} = WebGUI::Form::submit($self->session,{value=>WebGUI::International::get(11,"Asset_Poll")});
	$var{"form.end"} = WebGUI::Form::formFooter($self->session,);
	$totalResponses = 1 if ($totalResponses < 1);
        for (my $i=1; $i<=20; $i++) {
        	if ($self->get('a'.$i) =~ /\C/) {
                        my ($tally) = $self->session->db->quickArray("select count(*) from Poll_answer where answer='a"
				.$i."' and assetId=".$self->session->db->quote($self->getId)." group by answer");
                	push(@answers,{
				"answer.form"=>WebGUI::Form::radio($self->session,{name=>"answer",value=>"a".$i}),
				"answer.text"=>$self->get('a'.$i),
				"answer.graphWidth"=>round($self->get("graphWidth")*$tally/$totalResponses),
				"answer.number"=>$i,
				"answer.percent"=>round(100*$tally/$totalResponses),
				"answer.total"=>($tally+0)
                        	});
		
                }
	}
	randomizeArray(\@answers) if ($self->get("randomizeAnswers"));
	$var{answer_loop} = \@answers;
	return $self->processTemplate(\%var,$self->get("templateId"));
}

#-------------------------------------------------------------------
#sub www_edit {
#        my $self = shift;
#	return $self->session->privilege->insufficient() unless $self->canEdit;
#	$self->getAdminConsole->setHelp("poll add/edit","Asset_Poll");
#        return $self->getAdminConsole->render($self->getEditForm->print,WebGUI::International::get("9","Asset_Poll"));
#}

#-------------------------------------------------------------------
sub www_vote {
	my $self = shift;
	my $u;
        if ($self->session->form->process("answer") ne "" && $self->session->user->isInGroup($self->get("voteGroup")) && !($self->_hasVoted())) {
        	$self->setVote($self->session->form->process("answer"),$self->session->user->profileField("userId"),$self->session->env->get("REMOTE_ADDR"));
		if ($self->session->setting->get("useKarma")) {
			$u = WebGUI::User->new($self->session->user->profileField("userId"));
			$u->karma($self->get("karmaPerVote"),"Poll (".$self->getId.")","Voted on this poll.");
		}
		$self->deletePageCache;
	}
	return $self->getContainer->www_view;
}



1;

