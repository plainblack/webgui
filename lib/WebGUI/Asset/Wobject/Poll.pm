package WebGUI::Asset::Wobject::Poll;


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
		and userId<>1) or (userId=1 and ipAddress='$session{env}{REMOTE_ADDR}'))");
	return $hasVoted;
}

#-------------------------------------------------------------------
sub definition {
	my $class = shift;
	my $definition = shift;
	push(@{$definition}, {
		tableName=>'Poll',
		className=>'WebGUI::Asset::Wobject::Poll',
		properties=>{
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
sub getEditForm {
	my $self = shift;
	my $tabform = $self->SUPER::getEditForm; 
        my ($i, $answers);
	for ($i=1; $i<=20; $i++) {
                if ($self->get('a'.$i) =~ /\C/) {
                        $answers .= $self->getValue("a".$i)."\n";
                }
        }
	$tabform->getTab("security")->yesNo(
		-name=>"active",
		-label=>WebGUI::International::get(3,"Poll"),
		-value=>$self->getValue("active")
		);
        $tabform->getTab("security")->group(
		-name=>"voteGroup",
		-label=>WebGUI::International::get(4,"Poll"),
		-value=>[$self->getValue("voteGroup")]
		);
	if ($session{setting}{useKarma}) {
		$tabform->getTab("properties")->integer(
			-name=>"karmaPerVote",
			-label=>WebGUI::International::get(20,"Poll"),
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
		-label=>WebGUI::International::get(5,"Poll"),
		-value=>$self->getValue("graphWidth")
		);
	$tabform->getTab("properties")->text(
		-name=>"question",
		-label=>WebGUI::International::get(6,"Poll"),
		-value=>$self->getValue("question")
		);
        $tabform->getTab("properties")->textarea(
		-name=>"answers",
		-label=>WebGUI::International::get(7,"Poll"),
		-subtext=>('<span class="formSubtext"><br>'.WebGUI::International::get(8,"Poll").'</span>'),
		-value=>$answers
		);
	$tabform->getTab("display")->yesNo(
		-name=>"randomizeAnswers",
		-label=>WebGUI::International::get(72,"Poll"),
		-value=>$self->getValue("randomizeAnswers")
		);
	$tabform->getTab("properties")->yesNo(
		-name=>"resetVotes",
		-label=>WebGUI::International::get(10,"Poll")
		);
	return $tabform;
}

#-------------------------------------------------------------------
sub getIcon {
	my $self = shift;
	my $small = shift;
	return $session{config}{extrasURL}.'/assets/small/poll.gif' if ($small);
	return $session{config}{extrasURL}.'/assets/poll.gif';
}

#-------------------------------------------------------------------
sub getIndexerParams {
	my $self = shift;        
	my $now = shift;
	return {
		Poll => {
                        sql => "select Poll.wobjectId as wid,
                                        Poll.question as question,
                                        Poll.a1 as a1,   Poll.a2 as a2,   Poll.a3 as a3,   Poll.a4 as a4,   Poll.a5 as a5,
                                        Poll.a6 as a6,   Poll.a7 as a7,   Poll.a8 as a8,   Poll.a9 as a9,   Poll.a10 as a10,            
                                        Poll.a11 as a11, Poll.a12 as a12, Poll.a13 as a13, Poll.a14 as a14, Poll.a15 as a15,            
                                        Poll.a16 as a16, Poll.a17 as a17, Poll.a18 as a18, Poll.a19 as a19, Poll.a20 as a20,
                                        wobject.namespace as namespace,
                                        wobject.addedBy as ownerId,
                                        page.urlizedTitle as urlizedTitle,
                                        page.languageId as languageId,
                                        page.pageId as pageId,
                                        page.groupIdView as page_groupIdView,
                                        wobject.groupIdView as wobject_groupIdView,
                                        7 as wobject_special_groupIdView
                                        from Poll, wobject, page
                                        where Poll.wobjectId = wobject.wobjectId
                                        and wobject.pageId = page.pageId
                                        and wobject.startDate < $now 
                                        and wobject.endDate > $now
                                        and page.startDate < $now
                                        and page.endDate > $now",
                        fieldsToIndex => ["question", "a1", "a2", "a3", "a4", "a5", "a6", "a7", "a8", "a9", "a10",
                                        "a11", "a12", "a13", "a14", "a15", "a16", "a17", "a18", "a19", "a20"],
                        contentType => 'wobjectDetail',
                        url => 'WebGUI::URL::append($data{urlizedTitle}, "func=view&wid=$data{wid}")',
                        headerShortcut => 'select question from Poll where wobjectId = \'$data{wid}\'',
                        bodyShortcut => 'select a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20
                                         from Poll where wobjectId = \'$data{wid}\'',
                }
	};
}

#-------------------------------------------------------------------
sub getName {
        return WebGUI::International::get(1,"Poll");
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
	WebGUI::SQL->write("delete from Poll_answers where assetId=".quote($self->getId)) if ($session{form}{resetVotes});
}


#-------------------------------------------------------------------
sub purge {
	my $self = shift;
	WebGUI::SQL->write("delete from Poll_answers where assetId=".quote($self->getId));
	$self->SUPER::purge();
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
	$var{"responses.label"} = WebGUI::International::get(12,"Poll");
	$var{"responses.total"} = $totalResponses;
	$var{"form.start"} = WebGUI::Form::formHeader({action=>$self->getUrl});
        $var{"form.start"} .= WebGUI::Form::hidden({name=>'func',value=>'vote'});
	$var{"form.submit"} = WebGUI::Form::submit({value=>WebGUI::International::get(11,"Poll")});
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
	return $self->processTemplate(\%var,"Poll",$self->get("templateId"));
}

#-------------------------------------------------------------------
sub www_edit {
        my $self = shift;
        return WebGUI::Privilege::insufficient() unless $self->canEdit;
	$self->getAdminConsole->setHelp("poll add/edit");
        return $self->getAdminConsole->render($self->getEditForm->print,WebGUI::International::get("9","Poll"));
}

#-------------------------------------------------------------------
sub www_vote {
	my $self = shift;
	my $u;
        if ($session{form}{answer} ne "" && WebGUI::Grouping::isInGroup($self->get("voteGroup")) && !($self->_hasVoted())) {
        	WebGUI::SQL->write("insert into Poll_answer (assetId, answer, userId, ipAddress) values (".quote($self->getId).", 
			".quote($session{form}{answer}).", ".quote($session{user}{userId}).", '$session{env}{REMOTE_ADDR}')");
		if ($session{setting}{useKarma}) {
			$u = WebGUI::User->new($session{user}{userId});
			$u->karma($self->get("karmaPerVote"),"Poll (".$self->getId.")","Voted on this poll.");
		}
	}
	return "";
}



1;

