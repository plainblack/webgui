package WebGUI::Wobject::Poll;


#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2004 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use Tie::CPHash;
use WebGUI::Form;
use WebGUI::Grouping;
use WebGUI::HTMLForm;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::User;
use WebGUI::Utility;
use WebGUI::Wobject;

our @ISA = qw(WebGUI::Wobject);

#-------------------------------------------------------------------
sub _hasVoted {
	my ($hasVoted) = WebGUI::SQL->quickArray("select count(*) from Poll_answer 
		where wobjectId=".$_[0]->get("wobjectId")." and ((userId=$session{user}{userId} 
		and userId<>1) or (userId=1 and ipAddress='$session{env}{REMOTE_ADDR}'))");
	return $hasVoted;
}

#-------------------------------------------------------------------
sub duplicate {
        my ($w, $f, $sth, @row);
        $w = $_[0]->SUPER::duplicate($_[1]);
        $sth = WebGUI::SQL->read("select * from Poll_answer where wobjectId=".$_[0]->get("wobjectId"));
        while (@row = $sth->array) {
        	WebGUI::SQL->write("insert into Poll_answer values (".$w.", '$row[1]', $row[2], '$row[3]')");
        }
        $sth->finish;
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
                        headerShortcut => 'select question from Poll where wobjectId = $data{wid}',
                        bodyShortcut => 'select a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20
                                         from Poll where wobjectId = $data{wid}',
                }
	};
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
			active=>{
				defaultValue=>1
				},
			karmaPerVote=>{
				defaultValue=>0
				}, 
			graphWidth=>{
				defaultValue=>150
				}, 
			voteGroup=>{
				defaultValue=>7
				}, 
			question=>{}, 
			randomizeAnswers=>{
				defaultValue=>1,
				fieldType=>"yesNo"
				},
			a1=>{}, 
			a2=>{}, 
			a3=>{}, 
			a4=>{}, 
			a5=>{}, 
			a6=>{}, 
			a7=>{}, 
			a8=>{}, 
			a9=>{}, 
			a10=>{}, 
			a11=>{}, 
			a12=>{}, 
			a13=>{}, 
			a14=>{}, 
			a15=>{}, 
			a16=>{}, 
			a17=>{}, 
			a18=>{}, 
			a19=>{}, 
			a20=>{}
			},
		-useTemplate=>1
                );
        bless $self, $class;
}

#-------------------------------------------------------------------
sub purge {
        WebGUI::SQL->write("delete from Poll_answer where wobjectId=".$_[0]->get("wobjectId"));
	$_[0]->SUPER::purge();
}

#-------------------------------------------------------------------
sub www_edit {
        my ($i, $answers);
	for ($i=1; $i<=20; $i++) {
                if ($_[0]->get('a'.$i) =~ /\C/) {
                        $answers .= $_[0]->getValue("a".$i)."\n";
                }
        }
	my $privileges = WebGUI::HTMLForm->new;
	my $layout = WebGUI::HTMLForm->new;
	my $properties = WebGUI::HTMLForm->new;
	$privileges->yesNo(
		-name=>"active",
		-label=>WebGUI::International::get(3,$_[0]->get("namespace")),
		-value=>$_[0]->getValue("active")
		);
        $privileges->group(
		-name=>"voteGroup",
		-label=>WebGUI::International::get(4,$_[0]->get("namespace")),
		-value=>[$_[0]->getValue("voteGroup")]
		);
	if ($session{setting}{useKarma}) {
		$properties->integer(
			-name=>"karmaPerVote",
			-label=>WebGUI::International::get(20,$_[0]->get("namespace")),
			-value=>$_[0]->getValue("karmaPerVote")
			);
	} else {
		$properties->hidden("karmaPerVote",$_[0]->getValue("karmaPerVote"));
	}
	$layout->integer(
		-name=>"graphWidth",
		-label=>WebGUI::International::get(5,$_[0]->get("namespace")),
		-value=>$_[0]->getValue("graphWidth")
		);
	$properties->text(
		-name=>"question",
		-label=>WebGUI::International::get(6,$_[0]->get("namespace")),
		-value=>$_[0]->getValue("question")
		);
        $properties->textarea(
		-name=>"answers",
		-label=>WebGUI::International::get(7,$_[0]->get("namespace")),
		-subtext=>('<span class="formSubtext"><br>'.WebGUI::International::get(8,$_[0]->get("namespace")).'</span>'),
		-value=>$answers
		);
	$layout->yesNo(
		-name=>"randomizeAnswers",
		-label=>WebGUI::International::get(72,$_[0]->get("namespace")),
		-value=>$_[0]->getValue("randomizeAnswers")
		);
	my $output = $_[0]->SUPER::www_edit(
		-layout=>$layout->printRowsOnly,
		-properties=>$properties->printRowsOnly,
		-privileges=>$privileges->printRowsOnly,
		-headingId=>9,
		-helpId=>1
		);
	if ($_[0]->get("wobjectId") ne "new") {
		$output .= '<p>';
		$output .= '<a href="'.WebGUI::URL::page('func=resetVotes&wid='.$_[0]->get("wobjectId")).'">'
			.WebGUI::International::get(10,$_[0]->get("namespace")).'</a>';
	}
        return $output;
}

#-------------------------------------------------------------------
sub www_editSave {
	my (@answer, $i, $property);
	@answer = split("\n",$session{form}{answers});
        for ($i=1; $i<=20; $i++) {
             	$property->{'a'.$i} = $answer[($i-1)];
        }
	return $_[0]->SUPER::www_editSave($property);
}

#-------------------------------------------------------------------
sub www_resetVotes {
	return WebGUI::Privilege::insufficient() unless ($_[0]->canEdit);
	$_[0]->deleteCollateral("Poll_answer","wobjectId",$_[0]->get("wobjectId"));
	return "";
}

#-------------------------------------------------------------------
sub www_view {
	my (%var, $answer, @answers, $showPoll, $f);
        $var{question} = $_[0]->get("question");
	if ($_[0]->get("active") eq "0") {
		$showPoll = 0;
	} elsif (WebGUI::Grouping::isInGroup($_[0]->get("voteGroup"),$session{user}{userId})) {
		if ($_[0]->_hasVoted()) {
			$showPoll = 0;
		} else {
			$showPoll = 1;
		}
	} else {
		$showPoll = 0;
	}
	$var{canVote} = $showPoll;
        my ($totalResponses) = WebGUI::SQL->quickArray("select count(*) from Poll_answer where wobjectId="
		.$_[0]->get("wobjectId"));
	$var{"responses.label"} = WebGUI::International::get(12,$_[0]->get("namespace"));
	$var{"responses.total"} = $totalResponses;
	$var{"form.start"} = WebGUI::Form::formHeader();
        $var{"form.start"} .= WebGUI::Form::hidden({name=>'wid',value=>$_[0]->get("wobjectId")});
        $var{"form.start"} .= WebGUI::Form::hidden({name=>'func',value=>'vote'});
	$var{"form.submit"} = WebGUI::Form::submit({value=>WebGUI::International::get(11,$_[0]->get("namespace"))});
	$var{"form.end"} = "</form>";
	$totalResponses = 1 if ($totalResponses < 1);
        for (my $i=1; $i<=20; $i++) {
        	if ($_[0]->get('a'.$i) =~ /\C/) {
                        my ($tally) = WebGUI::SQL->quickArray("select count(*) from Poll_answer where answer='a"
				.$i."' and wobjectId=".$_[0]->get("wobjectId")." group by answer");
                	push(@answers,{
				"answer.form"=>WebGUI::Form::radio({name=>"answer",value=>"a".$i}),
				"answer.text"=>$_[0]->get('a'.$i),
				"answer.graphWidth"=>round($_[0]->get("graphWidth")*$tally/$totalResponses),
				"answer.number"=>$i,
				"answer.percent"=>round(100*$tally/$totalResponses),
				"answer.total"=>($tally+0)
                        	});
		
                }
	}
	randomizeArray(\@answers) if ($_[0]->get("randomizeAnswers"));
	$var{answer_loop} = \@answers;
	return $_[0]->processTemplate($_[0]->get("templateId"),\%var);
}

#-------------------------------------------------------------------
sub www_vote {
	my $u;
        if ($session{form}{answer} ne "" && WebGUI::Grouping::isInGroup($_[0]->get("voteGroup"),$session{user}{userId}) && !($_[0]->_hasVoted())) {
        	WebGUI::SQL->write("insert into Poll_answer values (".$_[0]->get("wobjectId").", 
			".quote($session{form}{answer}).", $session{user}{userId}, '$session{env}{REMOTE_ADDR}')");
		if ($session{setting}{useKarma}) {
			$u = WebGUI::User->new($session{user}{userId});
			$u->karma($_[0]->get("karmaPerVote"),$_[0]->get("namespace")." (".$_[0]->get("wobjectId").")","Voted on this poll.");
		}
	}
	return "";
}



1;

