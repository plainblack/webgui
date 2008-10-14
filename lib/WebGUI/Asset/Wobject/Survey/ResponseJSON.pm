package WebGUI::Asset::Wobject::Survey::ResponseJSON;

use strict;
use JSON;
use Data::Dumper;

sub new{
    my $class = shift;
    my $json = shift;
    my $log = shift;
    my $rId = shift;
    my $survey = shift;
    my $self = {};
    $self->{survey} = $survey;
    $self->{log} = $log;
    $self->{responseId} = $rId;
    my $temp = decode_json($json) if defined $json;
    $self->{goto} = defined $temp->{goto} ? $temp->{goto} : [];
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
#    my $fork = shift || [];
    my $order;
    my $qstarting = 0;
eval{
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
#            if(@$fork == 2){
#                if($$fork[0][0] == $s and $$fork[0][1] == $_){
#                    $s = $$fork[1][0]-1;
#                    $qstarting = $$fork[1][1];
#                    last;
#                }
#            }
        }
    }
};
$self->log($@) if($@);
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
    my $section = $self->survey->section([$questions->[0]->{sid}]);
    if($section->{terminal}){
        $terminal = 1;
        $terminalUrl = $section->{terminalUrl};
    }
    for my $question(@$questions){
        my $aAnswered = 0;
        if($question->{terminal}){
            $terminal = 1;
            $terminalUrl = $question->{terminalUrl};
        }
        for my $answer(@{$question->{answers}}){

            if(defined($responses->{$answer->{id}}) and $responses->{$answer->{id}} =~ /\S/){

                $aAnswered = 1;
                if($mcTypes{$question->{questionType}}){
                    $self->responses->{$answer->{id}}->{value} = $answer->{recordedAnswer};
                }
                else{
                    $self->responses->{$answer->{id}}->{value} = $responses->{$answer->{id}};
                }

                $self->responses->{$answer->{id}}->{comment} = $responses->{$answer->{id}."comment"};

                if($answer->{terminal}){
                    $terminal = 1;
                    $terminalUrl = $answer->{terminalUrl};
                }
                elsif($answer->{goto} =~ /\S/){
                    $goto = $answer->{goto};     
                }
            }
        }
        $qAnswered = 0 if(!$aAnswered and $question->{required});
    }
    
    #if all responses completed, move the lastResponse index to the last question shown
    if($qAnswered){
        $self->lastResponse($self->lastResponse + @$questions);
        $self->goto($goto);
    }else{
        $terminal = 0;
    }
    return [$terminal,$terminalUrl];
}
sub goto{
    my $self = shift;
    my $goto = shift;


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
#    $section->{'text'} =~ s/(\[\[\%.*?\]\])/$self->getRandomText($responseId,$1)/eg;

$self->log("qperpage $qPerPage");

    my $questions;
    for(my $i = 1; $i <= $qPerPage; $i++){
        my $qAddy= $self->surveyOrder->[$self->lastResponse + $i];

$self->log("qAddy was $$qAddy[0]-$$qAddy[1]");

        if($$qAddy[0] != $nextSectionId){
            last;
        }
        my %question = %{$self->survey->question([$$qAddy[0],$$qAddy[1]])};
        $question->{'text'} =~ s/\[\[([^\%]*?)\]\]/$self->getPreviousAnswer($1)/eg;
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
    return $questions
}
sub surveyEnd{
    my $self = shift;
    return 1 if($self->lastResponse > $#{$self->surveyOrder});
    return 0;
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
