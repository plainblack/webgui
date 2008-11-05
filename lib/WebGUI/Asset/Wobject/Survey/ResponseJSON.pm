package WebGUI::Asset::Wobject::Survey::ResponseJSON;

use strict;
use JSON;
use Data::Dumper;

sub new{
    my $class = shift;
    my $json = shift;
    my $log = shift;
    my $survey = shift;
    my $self = {};
    $self->{survey} = $survey;
    $self->{log} = $log;
    my $temp = decode_json($json) if defined $json;
    $self->{surveyOrder} = defined $temp->{surveyOrder} ? $temp->{surveyOrder} : [];#an array of question addresses, with the third member being an array of answers
    $self->{responses} = defined $temp->{responses} ? $temp->{responses} : {};
    $self->{lastResponse} = defined $temp->{lastResponse} ? $temp->{lastResponse} : -1;
    bless($self,$class);
    return $self;
}

#----------------------------------------------------------------------------

=head2 createSurveyOrder ( SurveyJSON, [address,address] )

This creates the order for the survey which will change after every fork.  
The survey order is to precreate random questions and answers, which also leaves a record or what the user was presented with.
Forks are passed in to show where to branch the new order.

=cut

sub createSurveyOrder{
    my $self = shift;
    my $order;
    my $qstarting = 0;
    
    for(my $s = 0; $s <= $#{$self->survey->sections()}; $s++){
        #create question order for section
        my @qorder;
        if($self->survey->section([$s])->{randomizeQuestions}){
            @qorder = shuffle(($qstarting .. $#{$self->survey->questions([$s])}));
        }else{
            @qorder = (($qstarting .. $#{$self->survey->questions([$s])}));
        }

        #if this is an empty section, make sure it is still on the list to be seen
        if(@qorder == 0){
            push(@$order,[$s]);
        }
        $qstarting = 0;
        #create answer order for question
        for (@qorder){
            my @aorder;
            if($self->survey->question([$s,$_])->{randomizeAnswers}){
                @aorder = shuffle(($qstarting .. $#{$self->survey->question([$s,$_])->{answers}}));
            }else{
                @aorder = (($qstarting .. $#{$self->survey->question([$s,$_])->{answers}}));
            }
            push(@$order,[$s,$_,\@aorder]);
        }
    }
    $self->{surveyOrder} = $order;
}
sub shuffle {
    my @a = splice @_;
    for my $i (0 .. $#a) {
        my $j = int rand @a;
        @a[$i, $j] = @a[$j, $i];
    }
    return @a;
}

sub freeze{
    my $self = shift;
    my %temp = %{$self};
    delete $temp{log};
    delete $temp{survey};
    return encode_json(\%temp);
}

#the index of the last surveyOrder entry shown
sub lastResponse{
    my $self = shift;
    my $res = shift;
    if(defined $res){
        $self->{lastResponse} = $res;
    }else{
        return $self->{lastResponse};
    }
}
#array of addresses in which the survey should be presented
sub surveyOrder{
    my $self = shift;
    return $self->{surveyOrder};
}


sub nextSectionId{
    my $self = shift;
    return $self->surveyOrder->[$self->lastResponse + 1]->[0];     
}


sub nextSection{
    my $self = shift;
    return $self->survey->section([$self->surveyOrder->[$self->lastResponse + 1]->[0]]);
}
sub currentSection{
    my $self = shift;
    return $self->survey->section([$self->surveyOrder->[$self->lastResponse]->[0]]);
}

sub recordResponses{
    my $self = shift;
    my $responses = shift;
    my $session = shift;

    my %mcTypes = ('Agree/Disagree',1,'Certainty',1,'Concern',1,'Confidence',1,'Education',1,'Effectiveness',1,'Gender',1,'Ideology',1,'Importance',1,
        'Likelihood',1,'Party',1,'Multiple Choice',1,'Oppose/Support',1,'Race',1,'Risk',1,'Satisfaction',1,'Scale',1,'Security',1,
        'Threat',1,'True/False',1,'Yes/No',1);
    my %sliderTypes = ('Dual Slider - Range',1,'Multi Slider - Allocate',1,'Slider',1);
    my %textTypes = ('Currency','Email',1,'Phone Number',1,'Text',1,'Text Date',1);
    my %fileTypes = ('File Upload',1);
    my %dateTypes = ('Date','Date Range',1);
    my %hiddenTypes = ('Hidden',1);
    #These were just submitted from the user, so we need to see what and how they were (un)answered.
    my $questions = $self->nextQuestions();
    my $qAnswered = 1;
    my $terminal = 0;
    my $terminalUrl;
    my $goto;
    #my $section = $self->survey->section([$questions->[0]->{sid}]);
    my $section = $self->currentSection();
    if($section->{terminal}){
        $terminal = 1;
        $terminalUrl = $section->{terminalUrl};
    }
    
    #There were no questions in the section just displayed, so increment the lastResponse by one
    if(ref $questions ne 'ARRAY'){
        $self->lastResponse($self->lastResponse + 1);
        $self->log("Incrementing last response by one");
        return [$terminal,$terminalUrl];
    }
$self->log("There are questions to be submitted in this section");

    for my $question(@$questions){
        my $aAnswered = 0;
        if($question->{terminal}){
            $terminal = 1;
            $terminalUrl = $question->{terminalUrl};
        }
        $self->responses->{$question->{id}}->{comment} = $responses->{$question->{id}."comment"};
        for my $answer(@{$question->{answers}}){

            if(defined($responses->{$answer->{id}}) and $responses->{$answer->{id}} =~ /\S/){

                $aAnswered = 1;
                if($mcTypes{$question->{questionType}}){
                    $self->responses->{$answer->{id}}->{value} = $answer->{recordedAnswer};
$self->log("Recorded Answer ".$answer->{recordedAnswer});
                }
                else{
$self->log("Returned Answer ".$responses->{$answer->{id}});
                    $self->responses->{$answer->{id}}->{value} = $responses->{$answer->{id}};
                }
                $self->responses->{$answer->{id}}->{'time'} = time();
                $self->responses->{$answer->{id}}->{comment} = $responses->{$answer->{id}."comment"};

                if($answer->{terminal}){
                    $terminal = 1;
                    $terminalUrl = $answer->{terminalUrl};
                }
                elsif($answer->{goto} =~ /\w/){
                    $goto = $answer->{goto};     
                }
            }
        }
        $qAnswered = 0 if(!$aAnswered and $question->{required});
    }
    
    #if all responses completed, move the lastResponse index to the last question shown
    if($qAnswered){
        $self->lastResponse($self->lastResponse + @$questions);
        $self->goto($goto) if(defined $goto);
    }else{
        $terminal = 0;
    }
    return [$terminal,$terminalUrl];
}
sub goto{
    my $self = shift;
    my $goto = shift;
$self->log("In goto for '$goto'");
    for(my $i = 0; $i <= $#{$self->surveyOrder()}; $i++){
        my $section = $self->survey->section($self->surveyOrder()->[$i]);
        my $question = $self->survey->question($self->surveyOrder()->[$i]);
        if(ref $section eq 'HASH' and $section->{variable} eq $goto){
$self->log("setting lastResponse to section ".($i-1));
            $self->lastResponse($i - 1);
            last;
        }
        if(ref $question eq 'HASH' and $question->{variable} eq $goto){
$self->log("setting lastResponse to question ".($i-1));
            $self->lastResponse($i - 1);
            last;
        }
    } 
}
sub getPreviousAnswer{
    my $self = shift;
    my $questionParam = shift;
    for my $q (@{$self->surveyOrder}){
        my $question = $self->survey->question([$$q[0],$$q[1]]);
        if($question->{variable} eq $questionParam){
            for (0 .. @{$self->survey->answers([$$q[0],$$q[1]])}){
                if(exists $self->responses->{$$q[0]."-".$$q[1]."-".$_}){
                    return $self->responses->{$$q[0]."-".$$q[1]."-".$_}->{value};
                }
            }
        }
    }
}

sub nextQuestions{
    my $self = shift;
$self->log("In nextQuestions");

    if($self->lastResponse >= $#{$self->surveyOrder}){
        return [];
    }

    my $nextSectionId = $self->nextSectionId;

$self->log("next sectionid is $nextSectionId");
    
    my $qPerPage = $self->survey->section([$self->nextSectionId])->{questionsPerPage};


    #load Previous answer text
    my $section = $self->nextSection(); 
$self->log("Section text is ".$section->{text});
    $section->{'text'} =~ s/\[\[([^\%]*?)\]\]/$self->getPreviousAnswer($1)/eg;

$self->log("qperpage $qPerPage");

    my $questions;
    for(my $i = 1; $i <= $qPerPage; $i++){
        my $qAddy = $self->surveyOrder->[$self->lastResponse + $i];
$self->log("qAddy was $$qAddy[0]-$$qAddy[1]");
        next if(! exists $$qAddy[1]);#skip this if it doesn't have a question (for sections with no questions)

        if($$qAddy[0] != $nextSectionId){
$self->log("Next question section did not match current section");
            last;
        }
$self->log("wtf");
        my %question = %{$self->survey->question([$$qAddy[0],$$qAddy[1]])};
        $question{'text'} =~ s/\[\[([^\%]*?)\]\]/$self->getPreviousAnswer($1)/eg;
        delete $question{answers};
        $question{id} = "$$qAddy[0]-$$qAddy[1]";
        $question{sid} = "$$qAddy[0]";
        for (@{$$qAddy[2]}){
            my $ans = $self->survey->answer([$$qAddy[0],$$qAddy[1],$_]);
            $ans->{'text'} =~ s/\[\[([^\%]*?)\]\]/$self->getPreviousAnswer($1)/eg;
            $ans->{id} = "$$qAddy[0]-$$qAddy[1]-$_";
            push(@{$question{answers}},$ans);
        }
        push(@$questions,\%question);
    }
$self->log("Next Questions returning with ");
    return $questions
}

sub surveyEnd{
    my $self = shift;
$self->log("LR is ".$self->lastResponse." and order is ".$#{$self->surveyOrder});
$self->log("ENDING THE SURVEY\n\n\n") if($self->lastResponse > $#{$self->surveyOrder});
    return 1 if($self->lastResponse >= $#{$self->surveyOrder});
    return 0;
}

sub returnResponseForReporting{
    my $self = shift;
    my @responses = ();
    for my $entry(@{$self->surveyOrder}){
        if(@$entry == 1){
            next;
        }
        my @answers;
        for (@{$$entry[2]}){
            if(defined $self->responses->{"$$entry[0]-$$entry[1]-$_"}){
                $self->responses->{"$$entry[0]-$$entry[1]-$_"}->{id} = $_;
                if($self->survey->answer([$$entry[0],$$entry[1],$_])->{isCorrect}){
                    my $value;                
                    if($self->survey->answer([$$entry[0],$$entry[1],$_])->{value} =~ /\w/){
                        $value = $self->survey->answer([$$entry[0],$$entry[1],$_])->{value};
                    }else{
                        $value = $self->survey->question([$$entry[0],$$entry[1]])->{value};
                    }
                    $self->responses->{"$$entry[0]-$$entry[1]-$_"}->{value} = $value;
                    $self->responses->{"$$entry[0]-$$entry[1]-$_"}->{isCorrect} = 1;
                }else{
                    $self->responses->{"$$entry[0]-$$entry[1]-$_"}->{isCorrect} = 0;
                }
                push(@answers,($self->responses->{"$$entry[0]-$$entry[1]-$_"}));
            }
        }
        push(@responses,({'section',$$entry[0],'question',$$entry[1],
            'sectionName',$self->survey->section([$$entry[0]])->{variable},
            'questionName',$self->survey->question([$$entry[0],$$entry[1]])->{variable},
            'questionComment',$self->responses->{"$$entry[0]-$$entry[1]"}->{comment},
            'answers',\@answers}));
    }
$self->log(Dumper @responses);
    return \@responses;
}

#the actual responses to the survey.  A response is for a question and is accessed by the exact same address as a survey member.
#Questions only contain the comment and an array of answer Responses. 
#Answers only contain, entered text, entered verbatim, their index in the Survey Question Answer array, and the assetId to the uploaded file.
sub responses{
    my $self = shift;
    return $self->{responses};
}

sub survey{
    my $self = shift;
    return $self->{survey};
}
sub log{
    my ($self,$message) = @_;
    if(defined $self->{log}){
        $self->{log}->error($message);
    }
}
1;
