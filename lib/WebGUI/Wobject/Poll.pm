package WebGUI::Wobject::Poll;


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
use WebGUI::User;
use WebGUI::Utility;
use WebGUI::Wobject;

our @ISA = qw(WebGUI::Wobject);


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
				defaultValue=>1
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
			}
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
        my ($i, $active, $voteGroup, $graphWidth, $answers, $randomizeAnswers);
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
		-value=>$randomizeAnswers
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
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
	$_[0]->deleteCollateral("Poll_answer","wobjectId",$_[0]->get("wobjectId"));
	return "";
}

#-------------------------------------------------------------------
sub www_view {
	my ($hasVoted, $answer, $output, @answers, $showPoll, $f, $i, $totalResponses, @data);
        $output = $_[0]->displayTitle;
        $output .= $_[0]->description;
	if ($_[0]->get("active") eq "0") {
		$showPoll = 0;
	} elsif (WebGUI::Privilege::isInGroup($_[0]->get("voteGroup"),$session{user}{userId})) {
		($hasVoted) = WebGUI::SQL->quickArray("select count(*) from Poll_answer where wobjectId=".$_[0]->get("wobjectId")." 
			and ((userId=$session{user}{userId} and userId<>1) or (userId=1 and ipAddress='$session{env}{REMOTE_ADDR}'))");
		if ($hasVoted) {
			$showPoll = 0;
		} else {
			$showPoll = 1;
		}
	} else {
		$showPoll = 0;
	}
        $output .= '<span class="pollQuestion">'.$_[0]->get("question").'</span><br>';
	if ($showPoll) {
		$f = WebGUI::HTMLForm->new(1);
                $f->hidden('wid',$_[0]->get("wobjectId"));
                $f->hidden('func','vote');
                for ($i=1; $i<=20; $i++) {
                        if ($_[0]->get('a'.$i) =~ /\C/) {
                                $answers[($i-1)] = '<input type="radio" name="answer" value="a'.$i.'"> <span class="pollAnswer">'.$_[0]->get('a'.$i).'</span><br>';
                        }
                }
		if ($_[0]->get("randomizeAnswers")) {
			randomizeArray(\@answers);
		}
		foreach $answer (@answers) {
			$f->raw($answer);
		}
                $f->raw('<br>');
		$f->submit(WebGUI::International::get(11,$_[0]->get("namespace")));
		$output .= $f->print;
	} else {
                ($totalResponses) = WebGUI::SQL->quickArray("select count(*) from Poll_answer where wobjectId=".$_[0]->get("wobjectId"));
                if ($totalResponses < 1) {
                        $totalResponses = 1;
                }
                for ($i=1; $i<=20; $i++) {
                        if ($_[0]->get('a'.$i) =~ /\C/) {
                                $output .= '<span class="pollAnswer"><hr size="1">'.$_[0]->get('a'.$i).'<br></span>';
                                @data = WebGUI::SQL->quickArray("select count(*), answer from Poll_answer where answer='a$i' and wobjectId="
					.$_[0]->get("wobjectId")." group by answer");
                                $output .= '<table cellpadding=0 cellspacing=0 border=0><tr><td width="'.
					round($_[0]->get("graphWidth")*$data[0]/$totalResponses).'" class="pollColor"><img src="'.
					$session{config}{extrasURL}.'/spacer.gif" height="1" width="1"></td><td class="pollAnswer">&nbsp;&nbsp;'.
					round(100*$data[0]/$totalResponses).'% ('.($data[0]+0).')</td></tr></table>';
                        }
                }
                $output .= '<span class="pollAnswer"><hr size="1"><b>'.WebGUI::International::get(12,$_[0]->get("namespace")).'</b> '.$totalResponses.'</span>';
	}
	return $output;
}

#-------------------------------------------------------------------
sub www_vote {
	my ($hasVoted, $u);
	($hasVoted) = WebGUI::SQL->quickArray("select count(*) from Poll_answer where wobjectId=".$_[0]->get("wobjectId")." and ((userId=$session{user}{userId} and userId<>1) or (userId=1 and ipAddress='$session{env}{REMOTE_ADDR}'))");
        if ($session{form}{answer} ne "" && WebGUI::Privilege::isInGroup($_[0]->get("voteGroup"),$session{user}{userId}) && !($hasVoted)) {
        	WebGUI::SQL->write("insert into Poll_answer values (".$_[0]->get("wobjectId").", 
			'$session{form}{answer}', $session{user}{userId}, '$session{env}{REMOTE_ADDR}')");
		if ($session{setting}{useKarma}) {
			$u = WebGUI::User->new($session{user}{userId});
			$u->karma($_[0]->get("karmaPerVote"),$_[0]->get("namespace")." (".$_[0]->get("wobjectId").")","Voted on this poll.");
		}
	}
	return "";
}



1;

