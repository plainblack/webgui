package WebGUI::Asset::Wobject::Poll;


#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
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
	my ($hasVoted) = WebGUI::SQL->quickArray("select count(*) from Poll_answer 
		where assetId=".quote($self->getId)." and ((userId=".quote($session{user}{userId})."
		and userId<>'1') or (userId=".quote($session{user}{userId})." and ipAddress='$session{env}{REMOTE_ADDR}'))");
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
	my $sth = WebGUI::SQL->read("select * from Poll_answer where assetId=".quote($self->getId));
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
	if ($session{setting}{useKarma}) {
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
		) if $session{form}{func} eq 'add';
	return $tabform;
}

#-------------------------------------------------------------------
sub getIndexerParams {
	my $self = shift;        
	my $now = shift;
	return {
                Poll => {
                        sql => "select Poll.assetId,
                                        Poll.question,
                                        Poll.a1 as a1,   Poll.a2 as a2,   Poll.a3 as a3,   Poll.a4 as a4,   Poll.a5 as a5,
                                        Poll.a6 as a6,   Poll.a7 as a7,   Poll.a8 as a8,   Poll.a9 as a9,   Poll.a10 as a10,
                                        Poll.a11 as a11, Poll.a12 as a12, Poll.a13 as a13, Poll.a14 as a14, Poll.a15 as a15,
                                        Poll.a16 as a16, Poll.a17 as a17, Poll.a18 as a18, Poll.a19 as a19, Poll.a20 as a20,
                                        asset.ownerUserId as ownerId,
                                        asset.url,
                                        asset.groupIdView
                                        from Poll, asset
                                        where Poll.assetId = asset.assetId
                                        and asset.startDate < $now
                                        and asset.endDate > $now",
                        fieldsToIndex => ["question", "a1", "a2", "a3", "a4", "a5", "a6", "a7", "a8", "a9", "a10",
                                        "a11", "a12", "a13", "a14", "a15", "a16", "a17", "a18", "a19", "a20"],
                        contentType => 'assetDetail',
                        url => 'WebGUI::URL::gateway($data{url})',
                        headerShortcut => 'select question from Poll where assetId = \'$data{assetId}\'',
                        bodyShortcut => 'select a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20
                                         from Poll where assetId = \'$data{assetId}\'',
                }

	};
}


#-------------------------------------------------------------------
sub processPropertiesFromFormPost {
	my $self = shift;
	$self->SUPER::processPropertiesFromFormPost;
	my (@answer, $i, $property);
	@answer = split("\n",$session{form}{answers});
        for ($i=1; $i<=20; $i++) {
             	$property->{'a'.$i} = $answer[($i-1)];
        }
	$self->update($property);
	WebGUI::SQL->write("delete from Poll_answer where assetId=".quote($self->getId)) if ($session{form}{resetVotes});
}


#-------------------------------------------------------------------
sub purge {
	my $self = shift;
	WebGUI::SQL->write("delete from Poll_answer where assetId=".quote($self->getId));
	$self->SUPER::purge();
}	

#-------------------------------------------------------------------
sub setVote {
	my $self = shift;
	my $answer = shift;
	my $userId = shift;
	my $ip = shift;
       	WebGUI::SQL->write("insert into Poll_answer (assetId, answer, userId, ipAddress) values (".quote($self->getId).", 
		".quote($answer).", ".quote($userId).", '$ip')");
}

#-------------------------------------------------------------------
sub view {
	my $self = shift;
	my (%var, $answer, @answers, $showPoll, $f);
        $var{question} = $self->get("question");
	if ($self->get("active") eq "0") {
		$showPoll = 0;
	} elsif (WebGUI::Grouping::isInGroup($self->get("voteGroup"),$session{user}{userId})) {
		if ($self->_hasVoted()) {
			$showPoll = 0;
		} else {
			$showPoll = 1;
		}
	} else {
		$showPoll = 0;
	}
	$var{canVote} = $showPoll;
        my ($totalResponses) = WebGUI::SQL->quickArray("select count(*) from Poll_answer where assetId=".quote($self->getId));
	$var{"responses.label"} = WebGUI::International::get(12,"Asset_Poll");
	$var{"responses.total"} = $totalResponses;
	$var{"form.start"} = WebGUI::Form::formHeader({action=>$self->getUrl});
        $var{"form.start"} .= WebGUI::Form::hidden({name=>'func',value=>'vote'});
	$var{"form.submit"} = WebGUI::Form::submit({value=>WebGUI::International::get(11,"Asset_Poll")});
	$var{"form.end"} = WebGUI::Form::formFooter();
	$totalResponses = 1 if ($totalResponses < 1);
        for (my $i=1; $i<=20; $i++) {
        	if ($self->get('a'.$i) =~ /\C/) {
                        my ($tally) = WebGUI::SQL->quickArray("select count(*) from Poll_answer where answer='a"
				.$i."' and assetId=".quote($self->getId)." group by answer");
                	push(@answers,{
				"answer.form"=>WebGUI::Form::radio({name=>"answer",value=>"a".$i}),
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
#	return WebGUI::Privilege::insufficient() unless $self->canEdit;
#	$self->getAdminConsole->setHelp("poll add/edit","Asset_Poll");
#        return $self->getAdminConsole->render($self->getEditForm->print,WebGUI::International::get("9","Asset_Poll"));
#}

#-------------------------------------------------------------------
sub www_vote {
	my $self = shift;
	my $u;
        if ($session{form}{answer} ne "" && WebGUI::Grouping::isInGroup($self->get("voteGroup")) && !($self->_hasVoted())) {
        	$self->setVote($session{form}{answer},$session{user}{userId},$session{env}{REMOTE_ADDR});
		if ($session{setting}{useKarma}) {
			$u = WebGUI::User->new($session{user}{userId});
			$u->karma($self->get("karmaPerVote"),"Poll (".$self->getId.")","Voted on this poll.");
		}
		$self->deletePageCache;
	}
	return $self->getContainer->www_view;
}



1;

