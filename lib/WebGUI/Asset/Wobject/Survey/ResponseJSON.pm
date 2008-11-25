package WebGUI::Asset::Wobject::Survey::ResponseJSON;

use strict;
use JSON;
use Data::Dumper;

sub new {
    my $class  = shift;
    my $json   = shift;
    my $log    = shift;
    my $survey = shift;
    my $temp = decode_json($json) if defined $json;
    my $self   = defined $temp ? $temp : {};
    $self->{survey} = $survey;
    $self->{log}    = $log;
    $self->{surveyOrder}
        = defined $temp->{surveyOrder}
        ? $temp->{surveyOrder}
        : [];    #an array of question addresses, with the third member being an array of answers
    $self->{responses}    = defined $temp->{responses}    ? $temp->{responses}    : {};
    $self->{lastResponse} = defined $temp->{lastResponse} ? $temp->{lastResponse} : -1;
    $self->{questionsAnswered} = defined $temp->{questionsAnswered} ? $temp->{questionsAnswered} : 0;
    bless( $self, $class );
    return $self;
} ## end sub new

#----------------------------------------------------------------------------

=head2 createSurveyOrder ( SurveyJSON, [address,address] )

This creates the order for the survey which will change after every fork.  
The survey order is to precreate random questions and answers, which also leaves a record or what the user was presented with.
Forks are passed in to show where to branch the new order.

=cut

sub createSurveyOrder {
    my $self = shift;
    my $order;
    my $qstarting = 0;
    for ( my $s = 0; $s <= $#{ $self->survey->sections() }; $s++ ) {

        #create question order for section
        my @qorder;
        if ( $self->survey->section( [$s] )->{randomizeQuestions} ) {
            @qorder = shuffle( ( $qstarting .. $#{ $self->survey->questions( [$s] ) } ) );
        }
        else {
            @qorder = ( ( $qstarting .. $#{ $self->survey->questions( [$s] ) } ) );
        }

        #if this is an empty section, make sure it is still on the list to be seen
        if ( @qorder == 0 ) {
            push( @$order, [$s] );
        }
        $qstarting = 0;

        #create answer order for question
        for (@qorder) {
            my @aorder;
            if ( $self->survey->question( [ $s, $_ ] )->{randomizeAnswers} ) {
                @aorder = shuffle( ( $qstarting .. $#{ $self->survey->question( [ $s, $_ ] )->{answers} } ) );
            }
            else {
                @aorder = ( ( $qstarting .. $#{ $self->survey->question( [ $s, $_ ] )->{answers} } ) );
            }
            push( @$order, [ $s, $_, \@aorder ] );
        }
    } ## end for ( my $s = 0; $s <= ...
    $self->{surveyOrder} = $order;
} ## end sub createSurveyOrder

sub shuffle {
    my @a = splice @_;
    for my $i ( 0 .. $#a ) {
        my $j = int rand @a;
        @a[ $i, $j ] = @a[ $j, $i ];
    }
    return @a;
}

sub freeze {
    my $self = shift;
    my %temp = %{$self};
    delete $temp{log};
    delete $temp{survey};
    return encode_json( \%temp );
}

#Hash the survey timed out?

sub hasTimedOut{
    my $self=shift;
    return 1 if($self->{startTime} + ($self->{timeLimit} * 60) < time() and $self->{timeLimit} > 0);
    return 0;
}

#the index of the last surveyOrder entry shown
sub lastResponse {
    my $self = shift;
    my $res  = shift;
    if ( defined $res ) {
        $self->{lastResponse} = $res;
    }
    else {
        return $self->{lastResponse};
    }
}

#array of addresses in which the survey should be presented
sub surveyOrder {
    my $self = shift;
    return $self->{surveyOrder};
}

sub nextSectionId {
    my $self = shift;
    return $self->surveyOrder->[ $self->lastResponse + 1 ]->[0];
}

sub nextSection {
    my $self = shift;
    return $self->survey->section( [ $self->surveyOrder->[ $self->lastResponse + 1 ]->[0] ] );
}

sub currentSection {
    my $self = shift;
    return $self->survey->section( [ $self->surveyOrder->[ $self->lastResponse ]->[0] ] );
}

sub recordResponses {
    my $self      = shift;
    my $session   = shift;
    my $responses = shift;
    
    my %mcTypes = (
        'Agree/Disagree', 1, 'Certainty',       1, 'Concern',        1, 'Confidence', 1, 'Education',  1,
        'Effectiveness',  1, 'Gender',          1, 'Ideology',       1, 'Importance', 1, 'Likelihood', 1,
        'Party',          1, 'Multiple Choice', 1, 'Oppose/Support', 1, 'Race',       1, 'Risk',       1,
        'Satisfaction',   1, 'Scale',           1, 'Security',       1, 'Threat',     1, 'True/False', 1,
        'Yes/No',         1
    );
    my %sliderTypes = ( 'Dual Slider - Range', 1, 'Multi Slider - Allocate', 1, 'Slider', 1 );
    my %textTypes   = ( 'Currency',    'Email', 1, 'Phone Number', 1, 'Text', 1, 'Text Date', 1 );
    my %fileTypes   = ( 'File Upload', 1 );
    my %dateTypes   = ( 'Date',        'Date Range', 1 );
    my %hiddenTypes = ( 'Hidden',      1 );

    #These were just submitted from the user, so we need to see what and how they were (un)answered.
    my $questions = $self->nextQuestions();
    my $qAnswered = 1;
    my $terminal  = 0;
    my $terminalUrl;
    my $goto;

    #my $section = $self->survey->section([$questions->[0]->{sid}]);
    my $section = $self->currentSection();
    if ( $section->{terminal} ) {
        $terminal    = 1;
        $terminalUrl = $section->{terminalUrl};
    }

    #There were no questions in the section just displayed, so increment the lastResponse by one
    if ( ref $questions ne 'ARRAY' ) {
        $self->lastResponse( $self->lastResponse + 1 );
        return [ $terminal, $terminalUrl ];
    }

    for my $question (@$questions) {
        my $aAnswered = 0;
        if ( $question->{terminal} ) {
            $terminal    = 1;
            $terminalUrl = $question->{terminalUrl};
        }
        $self->responses->{ $question->{id} }->{comment} = $responses->{ $question->{id} . "comment" };
        for my $answer ( @{ $question->{answers} } ) {

            if ( defined( $responses->{ $answer->{id} } )
                and $responses->{ $answer->{id} } =~ /\S/ )
            {

                $aAnswered = 1;
                if ( $mcTypes{ $question->{questionType} } ) {
                    $self->responses->{ $answer->{id} }->{value} = $answer->{recordedAnswer};
                }
                else {
                    $self->responses->{ $answer->{id} }->{value} = $responses->{ $answer->{id} };
                }
                $self->responses->{ $answer->{id} }->{'time'} = time();
                $self->responses->{ $answer->{id} }->{comment} = $responses->{ $answer->{id} . "comment" };

                if ( $answer->{terminal} ) {
                    $terminal    = 1;
                    $terminalUrl = $answer->{terminalUrl};
                }
                elsif ( $answer->{goto} =~ /\w/ ) {
                    $goto = $answer->{goto};
                }
            } ## end if ( defined( $responses...
        } ## end for my $answer ( @{ $question...
        $qAnswered = 0 if ( !$aAnswered and $question->{required} );
        $self->{questionsAnswered}++ if($aAnswered);
    } ## end for my $question (@$questions)

    #if all responses completed, move the lastResponse index to the last question shown
    if ($qAnswered) {
        $self->lastResponse( $self->lastResponse + @$questions );
        $self->goto($goto) if ( defined $goto );
    }
    else {
        $terminal = 0;
    }
    return [ $terminal, $terminalUrl ];
} ## end sub recordResponses

sub goto {
    my $self = shift;
    my $goto = shift;
    for ( my $i = 0; $i <= $#{ $self->surveyOrder() }; $i++ ) {
        my $section  = $self->survey->section( $self->surveyOrder()->[$i] );
        my $question = $self->survey->question( $self->surveyOrder()->[$i] );
        if ( ref $section eq 'HASH' and $section->{variable} eq $goto ) {
            $self->lastResponse( $i - 1 );
            last;
        }
        if ( ref $question eq 'HASH' and $question->{variable} eq $goto ) {
            $self->lastResponse( $i - 1 );
            last;
        }
    }
} ## end sub goto

sub getPreviousAnswer {
    my $self          = shift;
    my $questionParam = shift;
    for my $q ( @{ $self->surveyOrder } ) {
        my $question = $self->survey->question( [ $$q[0], $$q[1] ] );
        if ( $question->{variable} eq $questionParam ) {
            for ( 0 .. @{ $self->survey->answers( [ $$q[0], $$q[1] ] ) } ) {
                if ( exists $self->responses->{ $$q[0] . "-" . $$q[1] . "-" . $_ } ) {
                    return $self->responses->{ $$q[0] . "-" . $$q[1] . "-" . $_ }->{value};
                }
            }
        }
    }
}

sub nextQuestions {
    my $self = shift;

    if ( $self->lastResponse >= $#{ $self->surveyOrder } ) {
        return [];
    }

    my $nextSectionId = $self->nextSectionId;

    my $qPerPage = $self->survey->section( [ $self->nextSectionId ] )->{questionsPerPage};

    #load Previous answer text
    my $section = $self->nextSection();
    $section->{'text'} =~ s/\[\[([^\%]*?)\]\]/$self->getPreviousAnswer($1)/eg;

    my $questions;
    for ( my $i = 1; $i <= $qPerPage; $i++ ) {
        my $qAddy = $self->surveyOrder->[ $self->lastResponse + $i ];
        next
            if ( !exists $$qAddy[1] );    #skip this if it doesn't have a question (for sections with no questions)

        if ( $$qAddy[0] != $nextSectionId ) {
            last;
        }
        my %question = %{ $self->survey->question( [ $$qAddy[0], $$qAddy[1] ] ) };
        $question{'text'} =~ s/\[\[([^\%]*?)\]\]/$self->getPreviousAnswer($1)/eg;
        delete $question{answers};
        $question{id}  = "$$qAddy[0]-$$qAddy[1]";
        $question{sid} = "$$qAddy[0]";
        for ( @{ $$qAddy[2] } ) {
            my $ans = $self->survey->answer( [ $$qAddy[0], $$qAddy[1], $_ ] );
            $ans->{'text'} =~ s/\[\[([^\%]*?)\]\]/$self->getPreviousAnswer($1)/eg;
            $ans->{id} = "$$qAddy[0]-$$qAddy[1]-$_";
            push( @{ $question{answers} }, $ans );
        }
        push( @$questions, \%question );
    } ## end for ( my $i = 1; $i <= ...
    return $questions;
} ## end sub nextQuestions

sub surveyEnd {
    my $self = shift;
    return 1 if ( $self->lastResponse >= $#{ $self->surveyOrder } );
    return 0;
}

sub returnResponseForReporting {
    my $self      = shift;
    my @responses = ();
    for my $entry ( @{ $self->surveyOrder } ) {
        if ( @$entry == 1 ) {
            next;
        }
        my @answers;
        for ( @{ $$entry[2] } ) {
            if ( defined $self->responses->{"$$entry[0]-$$entry[1]-$_"} ) {
                $self->responses->{"$$entry[0]-$$entry[1]-$_"}->{id} = $_;
                if ( $self->survey->answer( [ $$entry[0], $$entry[1], $_ ] )->{isCorrect} ) {
                    my $value;
                    if ( $self->survey->answer( [ $$entry[0], $$entry[1], $_ ] )->{value} =~ /\w/ ) {
                        $value = $self->survey->answer( [ $$entry[0], $$entry[1], $_ ] )->{value};
                    }
                    else {
                        $value = $self->survey->question( [ $$entry[0], $$entry[1] ] )->{value};
                    }
                    $self->responses->{"$$entry[0]-$$entry[1]-$_"}->{value}     = $value;
                    $self->responses->{"$$entry[0]-$$entry[1]-$_"}->{isCorrect} = 1;
                }
                else {
                    $self->responses->{"$$entry[0]-$$entry[1]-$_"}->{isCorrect} = 0;
                }
                push( @answers, ( $self->responses->{"$$entry[0]-$$entry[1]-$_"} ) );
            } ## end if ( defined $self->responses...
        } ## end for ( @{ $$entry[2] } )
        push(
            @responses, ( {
                    'section',         $$entry[0],
                    'question',        $$entry[1],
                    'sectionName',     $self->survey->section( [ $$entry[0] ] )->{variable},
                    'questionName',    $self->survey->question( [ $$entry[0], $$entry[1] ] )->{variable},
                    'questionComment', $self->responses->{"$$entry[0]-$$entry[1]"}->{comment},
                    'answers',         \@answers
                }
            )
        );
    } ## end for my $entry ( @{ $self...
    return \@responses;
} ## end sub returnResponseForReporting

#the actual responses to the survey.  A response is for a question and is accessed by the exact same address as a survey member.
#Questions only contain the comment and an array of answer Responses.
#Answers only contain, entered text, entered verbatim, their index in the Survey Question Answer array, and the assetId to the uploaded file.
sub responses {
    my $self = shift;
    return $self->{responses};
}

sub survey {
    my $self = shift;
    return $self->{survey};
}

sub log {
    my ( $self, $message ) = @_;
    if ( defined $self->{log} ) {
        $self->{log}->error($message);
    }
}
1;
