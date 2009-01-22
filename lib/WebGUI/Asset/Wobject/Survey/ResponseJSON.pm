package WebGUI::Asset::Wobject::Survey::ResponseJSON;

=head1 LEGAL

-------------------------------------------------------------------
WebGUI is Copyright 2001-2008 Plain Black Corporation.
-------------------------------------------------------------------
Please read the legal notices (docs/legal.txt) and the license
(docs/license.txt) that came with this distribution before using
this software.
-------------------------------------------------------------------
http://www.plainblack.com                     info@plainblack.com
-------------------------------------------------------------------

=head1 NAME

Package WebGUI::Asset::Wobject::Survey::ResponseJSON

=head1 DESCRIPTION

Helper class for WebGUI::Asset::Wobject::Survey.  It manages data
from the user, sets the order of questions and answers in the survey,
based on forks, and gotos, and also handles expiring the survey
due to time limits.

This package is not intended to be used by any other Asset in WebGUI.

=cut


use strict;
use JSON;
use Data::Dumper;

#-------------------------------------------------------------------

=head2 new ( $json, $log, $survey )

Object constructor.

=head3 $json

Pass in some JSON to be serialized into a data structure.  Useful JSON would
contain a hash with "startTime", "surveyOrder", "responses", "lastReponse"
and "questionsAnswered" keys, with appropriate values.

=head3 $log

The session logger, from $session->log.  The class needs nothing else from the
session object.

=head3 $survey

A WebGUI::Asset::Wobject::Survey::SurveyJSON object that represents the current
survey.

=cut

sub new {
    my $class  = shift;
    my $json   = shift;
    my $log    = shift;
    my $survey = shift;
    my $temp = from_json($json) if defined $json;
    my $self   = defined $temp ? $temp : {};
    $self->{survey} = $survey;
    $self->{log}    = $log;
    $self->{responses}         = defined $temp->{responses}         ? $temp->{responses}         : {};
    $self->{lastResponse}      = defined $temp->{lastResponse}      ? $temp->{lastResponse}      : -1;
    $self->{questionsAnswered} = defined $temp->{questionsAnswered} ? $temp->{questionsAnswered} : 0;
    $self->{startTime}         = defined $temp->{startTime}         ? $temp->{startTime}         : time();
    #an array of question addresses, with the third member being an array of answers
    $self->{surveyOrder}       = defined $temp->{surveyOrder}       ? $temp->{surveyOrder}       : [];
    bless( $self, $class );
    return $self;
} ## end sub new

#----------------------------------------------------------------------------

=head2 createSurveyOrder ( SurveyJSON, [address,address] )

This creates the order for the survey which will change after every fork.  The survey
order is to precreate random questions and answers, which also leaves a record or what
the user was presented with.  Forks are passed in to show where to branch the new order.

If questions and/or answers were set to be randomized, it is handled in here.

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

#-------------------------------------------------------------------

=head2 shuffle ( @array )

Returns the contents of @array in a random order.

=cut

sub shuffle {
    my @a = splice @_;
    for my $i ( 0 .. $#a ) {
        my $j = int rand @a;
        @a[ $i, $j ] = @a[ $j, $i ];
    }
    return @a;
}

#-------------------------------------------------------------------

=head2 freeze

Serializes the object to JSON, after deleting the log and survey objects stored in it.

=cut

sub freeze {
    my $self = shift;
    my %temp = %{$self};
    delete $temp{log};
    delete $temp{survey};
    return to_json( \%temp );
}

#-------------------------------------------------------------------

#Has the survey timed out?

=head2 hasTimedOut ( $limit )

Checks to see whether this survey has timed out, based on the internally stored starting
time, and $limit.

=head3 $limit

How long the user has to take the survey, in minutes.

=cut

sub hasTimedOut{
    my $self=shift;
    my $limit = shift;
    return 1 if($self->startTime() + ($limit * 60) < time() and $limit > 0);
    return 0;
}

#-------------------------------------------------------------------

#the index of the last surveyOrder entry shown

=head2 lastResponse ([ $responseIndex ])

Mutator for the index of the last surveyOrder entry shown.  With no arguments,
returns the lastResponse index.

=head3 $responseIndex

If defined, sets the lastResponse to $responseIndex.

=cut

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

#-------------------------------------------------------------------

=head2 questionsAnswered ([ $questionsAnswered ])

Mutator for the number of questions answered.  With no arguments,
does a set.

=head3 $questionsAnswered.

If defined, increments the number of questions by $questionsAnswered

=cut

sub questionsAnswered {
    my $self      = shift;
    my $answered  = shift;
    if ( defined $answered ) {
        $self->{questionsAnswered} += $answered;
    }
    else {
        return $self->{questionsAnswered};
    }
}

#-------------------------------------------------------------------

=head2 startTime ([ $newStartTime ])

Mutator for the time the user began the survey.  With no arguments,
returns the startTime.

=head3 $newStarttime

If defined, sets the starting time to $newStartTime.

=cut

sub startTime {
    my $self     = shift;
    my $newTime  = shift;
    if ( defined $newTime ) {
        $self->{startTime} = $newTime;
    }
    else {
        return $self->{startTime};
    }
}

#-------------------------------------------------------------------

#array of addresses in which the survey should be presented

=head2 surveyOrder

Accessor for the survey order data structure.  It is a deep set of arrays, similar in
structure to a WebGUI::Asset::Wobject::Survey::SurveyJSON address.

    [ $sectionIndex, $questionIndex, [ $answerIndex1, $answerIndex2, ....]

There is one array element for every section and address in the survey.

If there are no questions, or no addresses, those array elements will not be present.

=cut

sub surveyOrder {
    my $self = shift;
    return $self->{surveyOrder};
}

#-------------------------------------------------------------------

=head2 nextSectionId

Relative to the surveyOrder and the lastResponse index, get the index of the
next section.  Note, based on the number of questions in an section, this can
be the same as the current section index.

=cut

sub nextSectionId {
    my $self = shift;
    return undef if $self->surveyEnd();
    return $self->surveyOrder->[ $self->lastResponse + 1 ]->[0];
}

#-------------------------------------------------------------------

=head2 nextSection

Relative to the surveyOrder and the lastResponse index, gets the next section.
Note, based on the number of questions in a section, this can be the same as
the current section.

=cut

sub nextSection {
    my $self = shift;
    return {} if $self->surveyEnd();
    return $self->survey->section( [ $self->surveyOrder->[ $self->lastResponse + 1 ]->[0] ] );
}

#-------------------------------------------------------------------

=head2 currentSection

Relative to the surveyOrder and the lastResponse index, get the current section.

=cut

sub currentSection {
    my $self = shift;
    return $self->survey->section( [ $self->surveyOrder->[ $self->lastResponse ]->[0] ] );
}

#-------------------------------------------------------------------

=head2 recordResponses ($session, $responses)

Takes survey responses and puts them into the response hash of this object.  Does terminal
handling for sections and questions, and goto processing.  Advances the survey page if
all required questions have been answered.

=head3 $session

A WebGUI session object

=head3 $responses

A hash ref of form param data.  Each element will look like:

    {
        "__qid__comment" => "question comment",
        "__aid__"        => "answer",
        "__aid__comment" => "answer comment",
    }

where __qid__ is a question id, as described in L<nextQuestions>, and __aid__ is an
answer id, also described there.

=head3 terminal processing

Terminal processing for a section and its questions and answers are handled in
order.  The terminalUrl setting in a question overrides the terminalUrl setting
for its section.  Similarly, with questions and answers, the last terminalUrl
setting of the set of questions is what is returned for the page, with the questions
and answers being answered in surveyOrder.

=head3 goto processing

gotos are handled similarly as with terminalUrls.  The last goto in the set of questions
wins.

=head3 responses data structure

This method also builds an internal data structure with the users' responses.  It
is set up like this:

    responses => {
        __qid__ => {
            comment => "question comment",
        },
        __aid__ => {
            time    => time(),
            comment => "answer comment",
            value   => "answer value",
        },
    }

=cut

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
    my $sterminal  = 0;
    my $terminal  = 0;
    my $terminalUrl;
    my $goto;

    my $section = $self->nextSection();#which gets the current section for the just submitted questions.  IE, current response pointer has not moved forward for these questions

    if ( $section->{terminal} ) {
        $sterminal    = 1;
        $terminalUrl = $section->{terminalUrl};
    }

    #There were no questions in the section just displayed, so increment the lastResponse by one
    if ( ref $questions ne 'ARRAY' ) {
        $self->lastResponse( $self->lastResponse + 1 );
        return [ $sterminal, $terminalUrl ];
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
                if ( exists $mcTypes{ $question->{questionType} } ) {
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
        if ($aAnswered) {
            $self->questionsAnswered( +1 );
        }
    } ## end for my $question (@$questions)

    #if all responses completed, move the lastResponse index to the last question shown
    if ($qAnswered) {
        $self->lastResponse( $self->lastResponse + @$questions );
        $self->goto($goto) if ( defined $goto );
    }
    else {
        $terminal = 0;
    }
    
    if($sterminal and $self->nextSection != $self->currentSection){
        $terminal = 1;
    }     

    return [ $terminal, $terminalUrl ];
} ## end sub recordResponses

#-------------------------------------------------------------------

=head2 goto ( $variable )

Looks through all sections and questions for their variable key, in order.  If the requested
$variable matches a variable, then the lastResponse is set so that that section or question
is the next displayed.  If more than one section or question matches, then the first is used.

=head3 $variable

The variable to look for in all sections and questions.

=cut

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

#-------------------------------------------------------------------

=head2 getPreviousAnswer

=cut

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

#-------------------------------------------------------------------

=head2 nextQuestions

Returns an array ref of the next questions in the survey.  The number of questions
returned is set by the questionsPerPage property of the next section, as determined
by nextSectionId rather than logical section ordering.

If no questions are available, then it returns an empty array ref.  

Each element of the array ref is a question data structure, from the
WebGUI::Asset::Wobject::Survey::SurveyJSON class, with a section sid field (index of
the containing section) and question id (section and question id concatenated with a
'-') added.  The answers array of the question contains answer data structures, also
from WebGUI::Asset::Wobject::Survey::SurveyJSON, with an id field which is the section,
question and answer indexes concatentated together with dashes.

Section and question [[var]] replacements in text fields.

All questions and answers are safe copies of the survey data.

=cut

sub nextQuestions {
    my $self = shift;

    return [] if $self->surveyEnd;

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
            my %ans = %{ $self->survey->answer( [ $$qAddy[0], $$qAddy[1], $_ ] ) };
            $ans{'text'} =~ s/\[\[([^\%]*?)\]\]/$self->getPreviousAnswer($1)/eg;
            $ans{id} = "$$qAddy[0]-$$qAddy[1]-$_";
            push( @{ $question{answers} }, \%ans );
        }
        push( @$questions, \%question );
    } ## end for ( my $i = 1; $i <= ...
    return $questions;
} ## end sub nextQuestions

#-------------------------------------------------------------------

=head2 surveyEnd

Returns true if the current index stored in lastResponse is greater than or
equal to the number of sections in the survey order.

=cut

sub surveyEnd {
    my $self = shift;
    return 1 if ( $self->lastResponse >= $#{ $self->surveyOrder } );
    return 0;
}

#-------------------------------------------------------------------

=head2 returnResponsesForReporting

=cut

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

#-------------------------------------------------------------------

#the actual responses to the survey.  A response is for a question and is accessed by the exact same address as a survey member.
#Questions only contain the comment and an array of answer Responses.
#Answers only contain, entered text, entered verbatim, their index in the Survey Question Answer array, and the assetId to the uploaded file.

=head2 responses

Returns a reference to the actual responses to the survey.  A response is for a question and
is accessed by the exact same address as a survey member.  Questions only contain the comment
and an array of answer Responses.  Answers only contain, entered text, entered verbatim,
their index in the Survey Question Answer array, and the assetId to the uploaded file.

Note, this is an unsafe reference.

=cut

sub responses {
    my $self = shift;
    return $self->{responses};
}

#-------------------------------------------------------------------

=head2 responses

Returns a referece to the SurveyJSON object that this object was created with.

Note, this is an unsafe reference.

=cut

sub survey {
    my $self = shift;
    return $self->{survey};
}

#-------------------------------------------------------------------

=head2 log

Logs an error to the webgui log file, using the session logger.

=cut

sub log {
    my ( $self, $message ) = @_;
    if ( defined $self->{log} ) {
        $self->{log}->debug($message);
    }
}
1;
