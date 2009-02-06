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

Helper class for WebGUI::Asset::Wobject::Survey. "Reponse" in the context of
this Wobject refers to a Survey response (not a single Question response).
ie, this class represents the complete state of a user's response to a Survey instance.

Instances of this class contain a response property that can be serialized
as JSON to the database to allow for storage and retrieval of the complete state
of a survey response.
 
Survey instances that allow users to record multiple responses will persist multiple
instances of this class to the database (one per distinct user response).

Data stored in this object includes the order in which questions and answers are
presented to the user (surveyOrder), a snapshot of all completed questions   
from the user (responses), the most recently answered question (lastResponse), the 
number of questions answered (questionsAnswered) and the Survey start time (startTime).

This package is not intended to be used by any other Asset in WebGUI.

=head2 surveyOrder

Many methods in this class operate on the surveyOrder property.
 
This data strucutre is a deep set of arrays, similar in structure to 
L<WebGUI::Asset::Wobject::Survey::SurveyJSON/Address Parameter>.

In general, the surveyOrder data structure looks like:

    [ $sectionIndex, $questionIndex, [ $answerIndex1, $answerIndex2, ....]

There is one array element for every section and address in the survey. If there are 
no questions, or no addresses, those array elements will not be present.

=cut

use strict;
use JSON;
use Params::Validate qw(:all);
use List::Util qw(shuffle);
Params::Validate::validation_options( on_fail => sub { WebGUI::Error::InvalidParam->throw( error => shift ) } );

#-------------------------------------------------------------------

=head2 new ( $survey, $json )

Object constructor.

=head3 $survey

A L<WebGUI::Asset::Wobject::Survey::SurveyJSON> object that represents the current
survey.

=head3 $json

A JSON string used to construct a new Perl object. The string should represent 
a JSON hash made up of "startTime", "surveyOrder", "responses", "lastReponse"
and "questionsAnswered" keys, with appropriate values.

=cut

sub new {
    my $class  = shift;
    my ($survey, $json)   = validate_pos(@_, {isa => 'WebGUI::Asset::Wobject::Survey::SurveyJSON' }, { type => SCALAR | UNDEF, optional => 1});

    # Load json object if given..
    my $jsonData = $json ? from_json($json) : {};

    # Create skeleton object..
    my $self = {
        # First define core members..
        _survey => $survey,
        _session => $survey->session,

        # Store all properties that are (de)serialized to/from JSON in a private variable
        _response => {

            # Response hash defaults..
            responses => {},
            lastResponse => -1,
            questionsAnswered => 0,
            startTime => time(),
            surveyOrder => [],

            # And then allow jsonData to override defaults and/or add other members
            %{$jsonData},
        },
    };
    
    return bless $self, $class;
}

#----------------------------------------------------------------------------

=head2 createSurveyOrder

Computers and stores the order of Sections, Questions and Aswers for this Survey. 
The order is represented as an array of addresses 
(see L<WebGUI::Asset::Wobject::Survey::SurveyJSON/Address Parameter>), 
and is stored in the surveyOrder property. See also the L<"surveyOrder"> accessor).

Questions and Answers that are set to be randomized are shuffled into a random order.
The surveyOrder property is useful for keeping a record of what the user was presented with.

=cut

sub createSurveyOrder {
    my $self = shift;

    # Order Questions in each Section
    my @surveyOrder;
    for my $sIndex ( 0 .. $self->survey->lastSectionIndex ) {

        #  Randomize Questions if required..
        my @qOrder;
        if ( $self->survey->section( [$sIndex] )->{randomizeQuestions} ) {
            @qOrder = shuffle 0 .. $self->survey->lastQuestionIndex( [$sIndex] );
        }
        else {
            @qOrder = ( 0 .. $self->survey->lastQuestionIndex( [$sIndex] ) );
        }

        # Order Answers in each Question
        for my $q (@qOrder) {

            # Randomize Answers if required..
            my @aOrder;
            if ( $self->survey->question( [ $sIndex, $q ] )->{randomizeAnswers} ) {
                @aOrder = shuffle 0 .. $self->survey->lastAnswerIndex( [ $sIndex, $q ] );
            }
            else {
                @aOrder = ( 0 .. $self->survey->lastAnswerIndex( [ $sIndex, $q ] ) );
            }
            push @surveyOrder, [ $sIndex, $q, \@aOrder ];
        }

        # If Section had no Questions, make sure it is still added to @surveyOrder
        if ( !@qOrder ) {
            push @surveyOrder, [$sIndex];
        }
    }
    $self->response->{surveyOrder} = \@surveyOrder;
    
    return;
}

#-------------------------------------------------------------------

=head2 session

Accessor method for the WebGUI::Session reference

=cut

sub session {
    my $self = shift;
    return $self->{_session};
}

#-------------------------------------------------------------------

=head2 freeze

Serializes the internal perl hash representing the Response to a JSON string

=cut

sub freeze {
    my $self = shift;
    return to_json($self->response);
}

#-------------------------------------------------------------------

=head2 hasTimedOut ( $limit )

Checks to see whether this survey has timed out, based on the internally stored starting
time, and the suppied $limit value.

=head3 $limit

How long the user has to take the survey, in minutes.

=cut

sub hasTimedOut{
    my $self = shift;
    my ($limit) = validate_pos(@_, {type => SCALAR});
    return $limit > 0 && $self->startTime + $limit * 60 < time;
}

#-------------------------------------------------------------------

=head2 lastResponse ([ $responseIndex ])

Mutator. The lastResponse property represents the index of the most recent surveyOrder entry shown. 

This method returns (and optionally sets) the value of lastResponse.

=head3 $responseIndex (optional)

If defined, lastResponse is set to $responseIndex.

=cut

sub lastResponse {
    my $self = shift;
    my ($responseIndex) = validate_pos(@_, {type => SCALAR, optional => 1});
    
    if ( defined $responseIndex ) {
        $self->response->{lastResponse} = $responseIndex;
    }
    
    return $self->response->{lastResponse};
}

#-------------------------------------------------------------------

=head2 questionsAnswered ([ $questionsAnswered ])

Mutator for the number of questions answered.  
Returns (and optionally sets) the value of questionsAnswered.

=head3 $questionsAnswered (optional)

If defined, increments the number of questions by $questionsAnswered

=cut

sub questionsAnswered {
    my $self = shift;
    my ($questionsAnswered) = validate_pos(@_, {type => SCALAR, optional => 1});
    
    if ( defined $questionsAnswered ) {
        $self->response->{questionsAnswered} += $questionsAnswered;
    }
    
    return $self->response->{questionsAnswered};
}

#-------------------------------------------------------------------

=head2 startTime ([ $startTime ])

Mutator for the time the user began the survey. 
Returns (and optionally sets) the value of startTime.

=head3 $startTime (optional)

If defined, sets the starting time to $startTime.

=cut

sub startTime {
    my $self     = shift;
    my ($startTime) = validate_pos(@_, {type => SCALAR, optional => 1});

    if ( defined $startTime ) {
        $self->response->{startTime} = $startTime;
    }

    return $self->response->{startTime};
}

#-------------------------------------------------------------------

=head2 surveyOrder

Accessor for surveyOrder (see L<"surveyOrder">). 
N.B. Use L<"createSurveyOrder"> to modify surveyOrder.

=cut

sub surveyOrder {
    my $self = shift;
    return $self->response->{surveyOrder};
}

#-------------------------------------------------------------------

=head2 nextResponse

Returns the index of the next item that should be shown to the user, 
that is, the index of the next item in the L<"surveyOrder"> array,
e.g. L<"lastResponse"> + 1.

=cut

sub nextResponse {
    my $self = shift;
    return $self->lastResponse + 1;
}

#-------------------------------------------------------------------

=head2 nextResponseSectionIndex

Returns the Section index of the next item that should be
shown to the user, that is, the next item in the L<"surveyOrder"> array
relative to L<"lastResponse">.

We go to the effort of calling this property "nextResponseSectionIndex"
rather than just "nextSectionIndex" to emphasize that this property is 
distinct from the "next" section index in the Survey. For example, in
a Section with multiple Questions, the value of nextResponseSectionIndex
will be the same value (the current section index) for all Questions
except the last Question.

=cut

sub nextResponseSectionIndex {
    my $self = shift;
    return undef if $self->surveyEnd();
    return $self->surveyOrder->[ $self->nextResponse ]->[0];
}

#-------------------------------------------------------------------

=head2 nextResponseSection

Returns the Section corresponding to the next item that should be
shown to the user, that is, the next item in the L<"surveyOrder"> array
relative to L<"lastResponse">.

As with L<"nextResponseSectionIndex">, we go to the effort of calling this property "nextResponseSection"
rather than just "nextSection" to emphasize that this property is 
distinct from the "next" section in the Survey.

=cut

sub nextResponseSection {
    my $self = shift;
    
    return {} if $self->surveyEnd();
    return $self->survey->section( [ $self->nextResponseSectionIndex ] );
}

#-------------------------------------------------------------------

=head2 lastResponseSectionIndex

Returns the Section index of the last item that was shown to the user,
based on the L<"surveyOrder"> array and L<"lastResponse">.

=cut

sub lastResponseSectionIndex {
    my $self = shift;
    return $self->surveyOrder->[ $self->lastResponse ]->[0];
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

where __qid__ is a question id, as described in L<"nextQuestions">, and __aid__ is an
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
    my %textTypes   = ( 'Currency',    'Email', 1, 'Phone Number', 1, 'Text', 1, 'Text Date', 1 ,'TextArea', 1);
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
    my $gotoExpression;

    my $section = $self->nextResponseSection();#which gets the current section for the just submitted questions.  IE, current response pointer has not moved forward for these questions

    if ( $section->{terminal} ) {
        $sterminal    = 1;
        $terminalUrl = $section->{terminalUrl};
    }

    #There were no questions in the section just displayed, so increment the lastResponse by one
    if ( ref $questions ne 'ARRAY' ) {
        $self->lastResponse( $self->nextResponse );
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
                elsif ( $answer->{gotoExpression} =~ /\w/ ) {
                    $gotoExpression = $answer->{gotoExpression};
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
        $self->gotoExpression($gotoExpression) if ( defined $gotoExpression );
    }
    else {
        $terminal = 0;
    }
    
    if($sterminal and $self->nextResponseSectionIndex != $self->lastResponseSectionIndex){
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

=head2 gotoExpression ( $gotoExpression )

=head3 $gotoExpression

The gotoExpression (one expression per line)

=head3 Explanation

A gotoExpression is a list of expressions (one per line) of the form:
 target: expression
 target: expression

This subroutine iterates through the list, processing each line and, all things being
well, evaluates the expression. The first expression to evaluate to true triggers a
call to goto($target).

The expression is a simple subset of the formula language used in spreadsheet programs such as Excel, OpenOffice, Google Docs etc..

Here is an example using section variables S1 and S2 as jump targets and question variables Q1-3 in the expression.
It  jumps to S1 if the user's answer to Q1 has a value of 3, jumps to S2 if Q2 + Q3 < 10, and otherwise doesn't branch at all (the default).
S1: Q1 = 3
S2: Q2 + Q3 < 10

=head3 Arguments are evaluated as follows:

Numeric arguments evaluate as numbers
* No support for strings (and hence no string matching)
* Question variable names (e.g. Q1) evaluate to the numeric value associated with user's answer to that question, or undefined if the user has not answered that question

Binary comparisons operators: = != < <= >= >
* return boolean values based on perl's equivalent numeric comparison operators

Simple math operators: + - * /
* return numeric values

Later we may add Boolean operators: AND( x; y; z; ... ), OR( x; y; z; ... ), NOT( x )
* args separated by semicolons (presumably because spreadsheet formulas use commas to indicate cell ranges)

Later still you may be able to say AVG(section1) or SUM(section3) and have those functions automatically compute their result over the set of all questions in the given section.
But for now those things can be done manually using the limited subset defined.

=cut

sub gotoExpression {
    my $self = shift;
    my $expression = shift;

    my %responses = (
        # questionName => response answer value
    );

    # Populate %responses with the user's data..
    foreach my $q (@{ $self->returnResponseForReporting() }) {
        if ($q->{questionName} =~ /\w/) {
            my $value = $q->{answers}[0]{value};
            $responses{$q->{questionName}} = $value if defined $value;
        }
    }

    # Process gotoExpressions one after the other (first one that's true wins)
    foreach my $line (split '\n', $expression) {
        my $processed = $self->processGotoExpression($line, \%responses);

        next unless $processed;

        # (ab)use perl's eval to evaluate the processed expression
        my $result = eval "$processed->{expression}";
        $self->session->log->warn($@) if $@;

        if ($result) {
            $self->session->log->debug("Truthy, goto [$processed->{target}]");
             $self->goto($processed->{target});
             return $processed;
        } else {
            $self->session->log->debug("Falsy, not branching");
            next;
        }
    }
    return;
}

=head2 processGotoExpression ( $expression, $responses)

Parses a single gotoExpression. Returns undef if processing fails, or the following hashref
if things work out well:
 { target => $target, expression => $expression }

=head3 $expression

The expression to process

=head3 $responses

Hashref that maps questionNames to response values

=head3 Explanation:

Uses the following simple strategy:

First, parse the expression as:
 target: expression

Replace each questionName with its response value (from the $responses hashref)

Massage the expression into valid perl

Check that only valid tokens remain. This last step ensures that any invalid questionNames in
the expression generate an error because our list of valid tokens doesn't include a-z

=cut

sub processGotoExpression {
    my $self       = shift;
    my $expression = shift;
    my $responses      = shift;

    $self->session->log->debug("Processing gotoExpression: $expression");

    # Valid gotoExpression tokens are..
    my $tokens = qr{\s|[-0-9=!<>+*/.()]};

    my ( $target, $rest ) = $expression =~ /\s* ([^:]+?) \s* : \s* (.*)/x;

    $self->session->log->debug("Parsed as Target: [$target], Expression: [$rest]");

    if ( !defined $target ) {
        $self->session->log->warn('Target undefined');
        return;
    }

    if ( !defined $rest || $rest eq '' ) {
        $self->session->log->warn('Expression undefined');
        return;
    }

    # Replace each questionName with its response value
    while ( my ( $questionName, $response ) = each %$responses ) {
        $rest =~ s/$questionName/$response/g;
    }

    # convert '=' to '==' but don't touch '!=', '<=' or '>='
    $rest =~ s/(?<![!<>])=(?!=)/==/g;

    if ( $rest !~ /^$tokens+$/ ) {
        $self->session->log->warn("Contains invalid tokens: $rest");
        return;
    }

    $self->session->log->debug("Processed as: $rest");

    return {
        target => $target,
        expression => $rest,
    };
}

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
by nextResponseSectionIndex rather than logical section ordering.

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

    my $nextResponseSectionIndex = $self->nextResponseSectionIndex;

    my $qPerPage = $self->survey->section( [ $self->nextResponseSectionIndex ] )->{questionsPerPage};

    #load Previous answer text
    my $section = $self->nextResponseSection();
    $section->{'text'} =~ s/\[\[([^\%]*?)\]\]/$self->getPreviousAnswer($1)/eg;

    my $questions;
    for ( my $i = 1; $i <= $qPerPage; $i++ ) {
        my $qAddy = $self->surveyOrder->[ $self->lastResponse + $i ];
        next
            if ( !exists $$qAddy[1] );    #skip this if it doesn't have a question (for sections with no questions)

        if ( $$qAddy[0] != $nextResponseSectionIndex ) {
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

=head2 session

Accessor for the Perl hash containing Response data

=cut

sub response {
    my $self = shift;
    return $self->{_response};
}

=head2 responses

Returns a reference to the actual responses to the survey.  A response is for a question and
is accessed by the exact same address as a survey member.  Questions only contain the comment
and an array of answer Responses.  Answers only contain, entered text, entered verbatim,
their index in the Survey Question Answer array, and the assetId to the uploaded file.

Note, this is an unsafe reference.

=cut

sub responses {
    my $self = shift;
    my $responses = shift;
    if ( defined $responses ) {
        $self->response->{responses} = $responses;
    }
    else {
        return $self->response->{responses};
    }
}

#-------------------------------------------------------------------

=head2 responses

Returns a referece to the SurveyJSON object that this object was created with.

Note, this is an unsafe reference.

=cut

sub survey {
    my $self = shift;
    return $self->{_survey};
}

1;
