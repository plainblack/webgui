package WebGUI::Wobject::Poll;


#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black Software.
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
our $namespace = "Poll";
our $name = WebGUI::International::get(1,$namespace);


#-------------------------------------------------------------------
sub duplicate {
        my ($w, $f, $sth, @row);
        $w = $_[0]->SUPER::duplicate($_[1]);
        $w = WebGUI::Wobject::Poll->new({wobjectId=>$w,namespace=>$namespace});
        $w->set({
                active=>$_[0]->get("active"),
                graphWidth=>$_[0]->get("graphWidth"),
                voteGroup=>$_[0]->get("voteGroup"),
                question=>$_[0]->get("question"),
                karmaPerVote=>$_[0]->get("karmaPerVote"),
                a1=>$_[0]->get("a1"),
                a2=>$_[0]->get("a2"),
                a3=>$_[0]->get("a3"),
                a4=>$_[0]->get("a4"),
                a5=>$_[0]->get("a5"),
                a6=>$_[0]->get("a6"),
                a7=>$_[0]->get("a7"),
                a8=>$_[0]->get("a8"),
                a9=>$_[0]->get("a9"),
                a10=>$_[0]->get("a10"),
                a11=>$_[0]->get("a11"),
                a12=>$_[0]->get("a12"),
                a13=>$_[0]->get("a13"),
                a14=>$_[0]->get("a14"),
                a15=>$_[0]->get("a15"),
                a16=>$_[0]->get("a16"),
                a17=>$_[0]->get("a17"),
                a18=>$_[0]->get("a18"),
                a19=>$_[0]->get("a19"),
                a20=>$_[0]->get("a20")
                });
        $sth = WebGUI::SQL->read("select * from Poll_answer where wobjectId=".$_[0]->get("wobjectId"));
        while (@row = $sth->array) {
        	WebGUI::SQL->write("insert into Poll_answer values (".$w->get("wobjectId").", '$row[1]', $row[2], '$row[3]')");
        }
        $sth->finish;
}

#-------------------------------------------------------------------
sub new {
        my ($self, $class, $property);
        $class = shift;
        $property = shift;
        $self = WebGUI::Wobject->new($property);
        bless $self, $class;
}

#-------------------------------------------------------------------
sub purge {
        WebGUI::SQL->write("delete from Poll_answer where wobjectId=".$_[0]->get("wobjectId"));
	$_[0]->SUPER::purge();
}

#-------------------------------------------------------------------
sub set {
        $_[0]->SUPER::set($_[1],[qw(active karmaPerVote graphWidth voteGroup question a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 a13 a14 a15 a16 a17 a18 a19 a20)]);
}

#-------------------------------------------------------------------
sub www_copy {
        if (WebGUI::Privilege::canEditPage()) {
		$_[0]->duplicate;
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_edit {
        my ($f, $i, $output, $active, $voteGroup, $graphWidth, $answers);
        if (WebGUI::Privilege::canEditPage()) {
		if ($_[0]->get("wobjectId") eq "new") {
			$active = 1;
		} else {
			$active = $_[0]->get("active");
		}
		$voteGroup = $_[0]->get("voteGroup") || 7;
		$graphWidth = $_[0]->get("graphWidth") || 150;
		for ($i=1; $i<=20; $i++) {
                        if ($_[0]->get('a'.$i) =~ /\w/) {
                                $answers .= $_[0]->get("a".$i)."\n";
                        }
                }
                $output = helpIcon(1,$namespace);
		$output .= '<h1>'.WebGUI::International::get(9,$namespace).'</h1>';
		$f = WebGUI::HTMLForm->new;
		$f->yesNo("active",WebGUI::International::get(3,$namespace),$active);
                $f->group("voteGroup",WebGUI::International::get(4,$namespace),[$voteGroup]);
		if ($session{setting}{useKarma}) {
			$f->integer("karmaPerVote",WebGUI::International::get(20,$namespace),$_[0]->get("karmaPerVote"));
		} else {
			$f->hidden("karmaPerVote",$_[0]->get("karmaPerVote"));
		}
		$f->integer("graphWidth",WebGUI::International::get(5,$namespace),$graphWidth);
		$f->text("question",WebGUI::International::get(6,$namespace),$_[0]->get("question"));
                $f->textarea("answers",WebGUI::International::get(7,$namespace).'<span class="formSubtext"><br>'.WebGUI::International::get(8,$namespace).'</span>',$answers);
		$output .= $_[0]->SUPER::www_edit($f->printRowsOnly);
		if ($_[0]->get("wobjectId") ne "new") {
			$output .= '<p>';
			$output .= '<a href="'.WebGUI::URL::page('func=resetVotes&wid='.$_[0]->get("wobjectId").'">')
				.WebGUI::International::get(10,$namespace).'</a>';
		}
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_editSave {
	my (@answer, $i, $property);
        if (WebGUI::Privilege::canEditPage()) {
		$_[0]->SUPER::www_editSave();
		@answer = split("\n",$session{form}{answers});
                for ($i=1; $i<=20; $i++) {
                	$property->{'a'.$i} = $answer[($i-1)];
                }
		$property->{karmaPerVote} = $session{form}{karmaPerVote};
		$property->{voteGroup} = $session{form}{voteGroup};
		$property->{graphWidth} = $session{form}{graphWidth};
		$property->{active} = $session{form}{active};
		$property->{question} = $session{form}{question};
		$_[0]->set($property);
		return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_resetVotes {
	if (WebGUI::Privilege::canEditPage()) {
		WebGUI::SQL->write("delete from Poll_answer where wobjectId=".$_[0]->get("wobjectId"));
	}
	return "";
}

#-------------------------------------------------------------------
sub www_view {
	my ($hasVoted, $output, $showPoll, $f, $i, $totalResponses, @data);
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
                        if ($_[0]->get('a'.$i) =~ /\w/) {
                                $f->raw('<input type="radio" name="answer" value="a'.$i.'"> <span class="pollAnswer">'.$_[0]->get('a'.$i).'</span><br>');
                        }
                }
                $f->raw('<br>');
		$f->submit(WebGUI::International::get(11,$namespace));
		$output .= $f->print;
	} else {
                ($totalResponses) = WebGUI::SQL->quickArray("select count(*) from Poll_answer where wobjectId=".$_[0]->get("wobjectId"));
                if ($totalResponses < 1) {
                        $totalResponses = 1;
                }
                for ($i=1; $i<=20; $i++) {
                        if ($_[0]->get('a'.$i) =~ /\w/) {
                                $output .= '<span class="pollAnswer"><hr size="1">'.$_[0]->get('a'.$i).'<br></span>';
                                @data = WebGUI::SQL->quickArray("select count(*), answer from Poll_answer where answer='a$i' and wobjectId="
					.$_[0]->get("wobjectId")." group by answer");
                                $output .= '<table cellpadding=0 cellspacing=0 border=0><tr><td width="'.
					round($_[0]->get("graphWidth")*$data[0]/$totalResponses).'" class="pollColor"><img src="'.
					$session{config}{extras}.'/spacer.gif" height="1" width="1"></td><td class="pollAnswer">&nbsp;&nbsp;'.
					round(100*$data[0]/$totalResponses).'% ('.($data[0]+0).')</td></tr></table>';
                        }
                }
                $output .= '<span class="pollAnswer"><hr size="1"><b>Total Votes:</b> '.$totalResponses.'</span>';
	}
	return $_[0]->processMacros($output);
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
			$u->karma($_[0]->get("karmaPerVote"),$namespace." (".$_[0]->get("wobjectId").")","Voted on this poll.");
		}
	}
	return "";
}



1;

