package WebGUI::Asset::Wobject::Survey::ResponseJSON;

=head1 LEGAL

-------------------------------------------------------------------
WebGUI is Copyright 2001-2009 Plain Black Corporation.
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

Helper class for WebGUI::Asset::Wobject::Survey. The class deals with both a 
"reponse" in the sense of an overall Survey response, and also "response" in 
the sense of a single Question response (which is closely related to an Answer but
not quite the same).

As a whole, this class represents the complete state of a user's response to a Survey instance.

At the heart of this class is a perl hash that can be serialized
as JSON to the database to allow for storage and retrieval of the complete state
of a survey response.

Survey instances that allow users to record multiple responses will persist multiple
instances of this class to the database (one per distinct user response).

Data stored in this object include the order in which questions and answers are
presented to the user (L<"surveyOrder">), a snapshot of all completed questions   
from the user (L<"responses">), the most recently answered question (L<"lastResponse">), the 
number of questions answered (L<"questionsAnswered">) and the Survey start time (L<"startTime">).

This package is not intended to be used by any other Asset in WebGUI.

=head2 surveyOrder

This data strucutre is an array (reference) of Survey addresses (see  
L<WebGUI::Asset::Wobject::Survey::SurveyJSON/Address Parameter>), stored in the order
in which items are presented to the user.

By making use of L<WebGUI::Asset::Wobject::Survey::SurveyJSON> methods which expect address params as
arguments, you can access Section/Question/Answer items in order by iterating over surveyOrder.

For example:

 # Access sections in order..
 for my $address (@{ $self->surveyOrder }) {
        my $section  = $self->survey->section( $address );
        # etc..
 }

In general, the surveyOrder data structure looks like:

    [ $sectionIndex, $questionIndex, [ $answerIndex1, $answerIndex2, ....]

There is one array element for every section and address in the survey. If there are 
no questions, or no addresses, those array elements will not be present.

=head2 responses

This data structure stores a snapshot of all question responses. Both question data and answer data
is stored in this hash reference.

Questions keys are constructed by hypenating the relevant L<"sIndex"> and L<"qIndex">.
Answer keys are constructed by hypenating the relevant L<"sIndex">, L<"qIndex"> and L<aIndex|"aIndexes">.

Question entries only contain a comment field:
 {
     ...
     questionId => {
         comment => "question comment",
     }
     ...
 }

Answers entries contain: value (the recorded value), time and comment fields.

 {
     ...
     answerId => {
         value   => "answer value",
         time    => time(),
         comment => "answer comment",
    },
     ...
 }

=cut

use strict;
use JSON;
use Params::Validate qw(:all);
use List::Util qw(shuffle);
use Safe;
Params::Validate::validation_options( on_fail => sub { WebGUI::Error::InvalidParam->throw( error => shift ) } );

#-------------------------------------------------------------------

=head2 new ( $survey, $json )

Object constructor.

=head3 $survey

A L<WebGUI::Asset::Wobject::Survey::SurveyJSON> object that represents the current
survey.

=head3 $json

A JSON string used to construct a new Perl object. The string should represent 
a JSON hash made up of L<"startTime">, L<"surveyOrder">, L<"responses">, L<"lastResponse">
and L<"questionsAnswered"> keys, with appropriate values.

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
            surveyOrder => undef,

            # And then allow jsonData to override defaults and/or add other members
            %{$jsonData},
        },
    };
    
    return bless $self, $class;
}

#----------------------------------------------------------------------------

=head2 initSurveyOrder

Computes and stores the order of Sections, Questions and Aswers for this Survey. 
See L<"surveyOrder">. You normally don't need to call this, as L<"surveyOrder"> will
call it for you the first time it is used.

Questions and Answers that are set to be randomized are shuffled into a random order.

=cut

sub initSurveyOrder {
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
Initialized on first access via L<"initSurveyOrder">.

=cut

sub surveyOrder {
    my $self = shift;
    
    if (!defined $self->response->{surveyOrder}) {
        $self->initSurveyOrder();
    }
    
    return $self->response->{surveyOrder};
}

#-------------------------------------------------------------------

=head2 nextResponse ([ $responseIndex ])

Mutator. The index of the next item that should be shown to the user, 
that is, the index of the next item in the L<"surveyOrder"> array,
e.g. L<"lastResponse"> + 1.

=head3 $responseIndex (optional)

If defined, nextResponse is set to $responseIndex.

=cut

sub nextResponse {
    my $self = shift;
    my ($responseIndex) = validate_pos(@_, {type => SCALAR, optional => 1});
    
    if ( defined $responseIndex ) {
        $self->lastResponse($responseIndex - 1);
    }
    
    return $self->lastResponse() + 1
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

=head2 recordResponses ($responses)

Processes and records submitted survey responses in the L<"responses"> data structure. 
Does terminal handling, and branch processing, and advances the L<"lastResponse"> index 
if all required questions have been answered.

=head3 $responses

A hash ref of form param data. Each element should look like:

    {
        "questionId-comment"    => "question comment",
        "answerId"              => "answer",
        "answerId-comment"      => "answer comment",
    }

See L<"questionId"> and L<"answerId">.

=head3 Terminal processing

Terminal processing for a section and its questions and answers are handled in
order.  The terminalUrl setting in a question overrides the terminalUrl setting
for its section.  Similarly, with questions and answers, the last terminalUrl
setting of the set of questions is what is returned for the page, with the questions
and answers being answered in L<"surveyOrder">.

=head3 Branch processing

gotos and gotoExpressions are handled similarly as with terminalUrls. The last goto or 
gotoExpression in the set of questions wins.

=cut

sub recordResponses {
    my $self = shift;
    my ($responses) = validate_pos( @_, { type => HASHREF } );

    # Build a lookup table of non-multiple choice question types
    my %knownTypes = map {$_ => 1} @{$self->survey->specialQuestionTypes};
    
    # We want to record responses against the "next" response section and questions, since these are
    # the items that have just been displayed to the user.
    my $section   = $self->nextResponseSection();
    my @questions = $self->nextQuestions();

    #GOTO jumps in the Survey.  Order of precedence is Answer, Question, then Section.
    my ($goto, $gotoExpression);

    # Handle terminal Section..
    my $terminalUrl;
    my $sTerminal = 0;
    if ( $section->{terminal} ) {
        $sTerminal   = 1;
        $terminalUrl = $section->{terminalUrl};
    }
    # ..and also gotos..
    elsif ( $section->{goto} =~ /\w/ ) {
        $goto = $section->{goto};
    }
    # .. and also gotoExpressions..
    elsif ( $section->{gotoExpression} =~ /\w/ ) {
        $gotoExpression = $section->{gotoExpression};
    }


    # Handle empty Section..
    if ( !@questions ) {
        # No questions to process, so increment lastResponse and return
        $self->lastResponse( $self->nextResponse );
        return [ $sTerminal, $terminalUrl ];
    }

    # Process Questions in Section..
    my $terminal = 0;
    my $allRequiredQsAnswered = 1;
    for my $question (@questions) {
        my $aAnswered = 0;

        # Handle terminal Questions..
        if ( $question->{terminal} ) {
            $terminal    = 1;
            $terminalUrl = $question->{terminalUrl};
        }
        # ..and also gotos..
        elsif ( $question->{goto} =~ /\w/ ) {
            $goto = $question->{goto};
        }
        # .. and also gotoExpressions..
        elsif ( $question->{gotoExpression} =~ /\w/ ) {
            $gotoExpression = $question->{gotoExpression};
        }

        # Record Question comment
        $self->responses->{ $question->{id} }->{comment} = $responses->{ $question->{id} . 'comment' };

        # Process Answers in Question..
        for my $answer ( @{ $question->{answers} } ) {

            # Pluck the values out of the responses hash that we want to record..
            my $answerValue = $responses->{ $answer->{id} };
            my $answerComment = $responses->{ $answer->{id} . 'comment' };

            # Proceed if we're satisfied that response is valid..
            if ( defined $answerValue && $answerValue =~ /\S/ ) {
                $aAnswered = 1;
                if ($knownTypes{$question->{questionType}}) {
                    $self->responses->{ $answer->{id} }->{value} = $answerValue;
                } else {
                    # Unknown type, must be a multi-choice bundle
                    # For Multi-choice, use recordedAnswer instead of answerValue
                    $self->responses->{ $answer->{id} }->{value} = $answer->{recordedAnswer};
                }
                $self->responses->{ $answer->{id} }->{time} = time;
                $self->responses->{ $answer->{id} }->{comment} = $answerComment;

                # Handle terminal Answers..
                if ( $answer->{terminal} ) {
                    $terminal    = 1;
                    $terminalUrl = $answer->{terminalUrl};
                }
                # ..and also gotos..
                elsif ( $answer->{goto} =~ /\w/ ) {
                    $goto = $answer->{goto};
                }
                # .. and also gotoExpressions..
                elsif ( $answer->{gotoExpression} =~ /\w/ ) {
                    $gotoExpression = $answer->{gotoExpression};
                }
            }
        }

        # Check if a required Question was skipped 
        if ( $question->{required} && !$aAnswered  ) {
            $allRequiredQsAnswered = 0;
        }

        # If question was answered, increment the questionsAnswered count..
        if ($aAnswered) {
            $self->questionsAnswered(+1);
        }
    }

    # If all required responses were given, proceed onwards!
    if ($allRequiredQsAnswered) {

        #  Move the lastResponse index to the last question answered
        $self->lastResponse( $self->lastResponse + @questions );

        # Do any requested branching.. 
        $self->processGoto($goto)                     if ( defined $goto );           ## no critic
        $self->processGotoExpression($gotoExpression) if ( defined $gotoExpression ); ## no critic
    }
    else {
        # Required responses were missing, so we don't let the Survey terminate
        $terminal = 0;
    }

    if ( $sTerminal && $self->nextResponseSectionIndex != $self->lastResponseSectionIndex ) {
        $terminal = 1;
    }

    return [ $terminal, $terminalUrl ];
}

#-------------------------------------------------------------------

=head2 processGoto ( $variable )

Looks through all sections and questions for their variable key, in order. If the requested
$variable matches a variable, then the lastResponse is set so that that section or question
is the next displayed.  If more than one variable name matches, then the first is used.

=head3 $variable

A variable name to match against all section and question variable names.

=cut

sub processGoto {
    my $self = shift;
    my ($goto) = validate_pos(@_, {type => SCALAR});

    # Iterate over items in order..
    my $itemIndex = 0;
    for my $address (@{ $self->surveyOrder }) {

        # Retreive the section and question for this address..
        my $section  = $self->survey->section( $address );
        my $question = $self->survey->question( $address );

        # See if our goto variable matches the section variable..
        if ( ref $section eq 'HASH' && $section->{variable} eq $goto ) {

            # Fudge lastResponse so that the next response item will be our matching item 
            $self->lastResponse( $itemIndex - 1 );
            last;
        }

        # See if our goto variable matches the question variable..
        if ( ref $question eq 'HASH' && $question->{variable} eq $goto ) {

            # Fudge lastResponse so that the next response item will be our matching item
            $self->lastResponse( $itemIndex - 1 );
            last;
        }

        # Increment the item index counter
        $itemIndex++;
    }
    return;
}

#-------------------------------------------------------------------

=head2 processGotoExpression ( $gotoExpression )

Processes the given gotoExpression, and triggers a call to L<"processGoto"> if the expression
indicates that we should branch.

=head3 $gotoExpression

The gotoExpression.

A gotoExpression is a string representing a list of expressions (one per line) of the form:

 target: expression
 target: expression
 ...

This subroutine iterates through the list, processing each line and, all things being
well, evaluates the expression. The first expression to evaluate to true triggers a
call to L<"processGoto">.

The expression should be valid perl. Any section/question variables that you refer to
should be written as $var, as if your perl code had access to that variable. In reality,
those variables don't exist - they're substituted in via L<parseGotoExpression> and 
then the expression is evaluated in a safe compartment.

Here is an example using section variables S1 and S2 as jump targets and question 
variables Q1-3 in the expression. It jumps to S1 if the user's answer to Q1 has a value 
of 3, jumps to S2 if Q2 + Q3 < 10, and otherwise doesn't branch at all (the default).

 S1: $Q1 == 3
 S2: $Q2 + $Q3 < 10

You can do advanced branching by creating your own variables within the expression, for
example, to branch when the average of 3 questions is greater than 5: 
 S1: $avg = ($Q1 + $Q2 + $Q3) / 3; $avg > 5   

=cut

sub processGotoExpression {
    my $self = shift;
    my ($expression) = validate_pos(@_, {type => SCALAR});

    my $responses = $self->recordedResponses();

    # Parse gotoExpressions one after the other (first one that's true wins)
    foreach my $line (split /\n/, $expression) {
        my $processed = WebGUI::Asset::Wobject::Survey::ResponseJSON->parseGotoExpression($self->session, $line, $responses);

        next if !$processed;
        
        # Eval expression in a safe compartment
        # N.B. Expression does not need access to any variables
        my $compartment = Safe->new();
        my $result = $compartment->reval($processed->{expression});

        $self->session->log->warn($@) if $@;            ## no critic

        if ($result) {
            $self->session->log->debug("Truthy, goto [$processed->{target}]");
             $self->processGoto($processed->{target});
             return $processed;
        } else {
            $self->session->log->debug('Falsy, not branching');
            next;
        }
    }
    return;
}

#-------------------------------------------------------------------

=head2 recordedResponses

Returns a hash (reference) of question responses. The hash keys are
question variable names. The hash values are the corresponding answer
values selected by the user. 

=cut

sub recordedResponses {
    my $self = shift;
    
    my $responses= {
        # questionName => response answer value
    };

    # Populate %responses with the user's data..
    for my $address ( @{ $self->surveyOrder } ) {
        my $question = $self->survey->question( $address );
        my ($sIndex, $qIndex) = (sIndex($address), qIndex($address));
        for my $aIndex (aIndexes($address)) {
            my $answerId = $self->answerId($sIndex, $qIndex, $aIndex);
            if ( defined $self->responses->{$answerId} ) {
                my $answer = $self->survey->answer( [ $sIndex, $qIndex, $aIndex ] );
                $responses->{$question->{variable}}
                    = $answer->{value} =~ /\w/  ? $answer->{value}
                                                : $question->{value}
                    ;
            }
        }
    }
    return $responses;
}

#-------------------------------------------------------------------

=head2 parseGotoExpression( ( $expression, $responses)

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

Replace each "$questionName" with its response value (from the $responses hashref)

=cut

sub parseGotoExpression {
    my $class       = shift;
    my ($session, $expression, $responses) = validate_pos(@_, { isa => 'WebGUI::Session'}, { type => SCALAR }, { type => HASHREF, default => {} });

    $session->log->debug("Parsing gotoExpression: $expression");

    my ( $target, $rest ) = $expression =~ /\s* ([^:]+?) \s* : \s* (.*)/x;

    $session->log->debug("Parsed as Target: [$target], Expression: [$rest]");

    if ( !defined $target ) {
        $session->log->warn('Target undefined');
        return;
    }

    if ( !defined $rest || $rest eq q{} ) {
        $session->log->warn('Expression undefined');
        return;
    }
    
    # Replace each "$questionName" with its response value
    while ( my ( $questionName, $response ) = each %{$responses} ) {
        $rest =~ s/\$$questionName/$response/g;
    }

    $session->log->debug("Processed as: $rest");

    return {
        target => $target,
        expression => $rest,
    };
}

#-------------------------------------------------------------------

=head2 getTemplatedText ($text, $responses)

Scans a string of text for instances of "[[var]]". Looks up each match in the given hash reference
and replaces the string with the associated hash value.

This method is used to enable simple templating in Survey Section/Question/Answer text. $responses will 
usually be a hash of all of the users responses so that their previous responses can be displayed in
the text of later questions. 

=head3 text

A string of text. e.g.

 Your chose the value [[Q2]] in Question 2

=head3 params

A hash reference. Each matching key in the string will be replaced with its associated value. 

=cut

sub getTemplatedText {
    my $self = shift;
    my ($text, $params) = validate_pos(@_, { type => SCALAR }, { type => HASHREF });

    # Replace all instances of [[var]] with the value from the $params hash reference
    $text =~ s/\[\[([^\%]*?)\]\]/$params->{$1}/eg;

    return $text;
}

#-------------------------------------------------------------------

=head2 nextQuestions

Returns a list (array ref) of the Questions that should be shwon on the next page of the Survey.
Each Question also contains a list (array ref) of associated Answers.

N.B. These are safe copies of the Survey data.

The number of questions is determined by the questionsPerPage property of the 'next' section
in L<"surveyOrder">.

Each element of the array ref returned is a question data structure (see 
L<WebGUI::Asset::Wobject::Survey::SurveyJSON>), with some additional fields:

=over 4

=item sid Section Id field (see L<"sectionId">)

=item id Question id (see L<"questionId">.

=item answers An array of Answers (see L<WebGUI::Asset::Wobject::Survey::SurveyJSON>), with
each answer in the array containing an Answer Id (see L<"answerId">)

=back

Survey, Question and Answer template text is processed here (see L<"getTemplatedText">)

=cut

sub nextQuestions {
    my $self = shift;

    # See if we've reached the end of the Survey
    return if $self->surveyEnd;

    # Get some information about the Section that the next response belongs to..
    my $section = $self->nextResponseSection();
    my $sectionIndex = $self->nextResponseSectionIndex;
    my $questionsPerPage = $self->survey->section( [ $self->nextResponseSectionIndex ] )->{questionsPerPage};
    # Get all of the existing question responses (so that we can do Section and Question [[var]] replacements
    my $recordedResponses = $self->recordedResponses();

    # Do text replacement
    $section->{text} = $self->getTemplatedText($section->{text}, $recordedResponses);

    # Collect all the questions to be shown on the next page..
    my @questions;
    for my $i (1 .. $questionsPerPage ) {
        my $address = $self->surveyOrder->[ $self->lastResponse + $i ];
        last if(! defined $address);
        my ($sIndex, $qIndex) = (sIndex($address), qIndex($address));

        # Skip if this is a Section without a Question
        if ( !defined $qIndex ) {
            next;
        }

        # Stop if we have left the Section
        if ( $sIndex != $sectionIndex ) {
            last;
        }

        # Make a safe copy of the question
        my %questionCopy = %{$self->survey->question( $address )};

        # Do text replacement
        $questionCopy{text} = $self->getTemplatedText($questionCopy{text}, $recordedResponses);

        # Add any extra fields we want..
        $questionCopy{id}  = $self->questionId($sIndex, $qIndex);
        $questionCopy{sid} = $self->sectionId($sIndex);

        # Rebuild the list of anwers with a safe copy
        delete $questionCopy{answers};
        for my $aIndex ( aIndexes($address) ) {
            my %answerCopy = %{ $self->survey->answer( [ $sIndex, $qIndex, $aIndex ] ) };

            # Do text replacement
            $answerCopy{text} = $self->getTemplatedText($answerCopy{text}, $recordedResponses);

            # Add any extra fields we want..
            $answerCopy{id} = $self->answerId($sIndex, $qIndex, $aIndex);

            push @{ $questionCopy{answers} }, \%answerCopy;
        }
        push @questions, \%questionCopy;
    }
    return @questions;
}

=head2 sectionId

Convenience method to construct a Section Id from the given Section index.

A Section Id is identical to a Section index. This method is only present for consistency with questionId and answerId.

=cut

sub sectionId {
    my $self = shift;
    my ($sIndex) = validate_pos(@_, { type => SCALAR | UNDEF } );
    
    return if !defined $sIndex;
    
    return $sIndex;
}

=head2 questionId

Convenience method to construct a Question Id from the given Section index and Question index.

The id is constructed by hyphenating the Section index and Question index.

=cut

sub questionId {
    my $self = shift;
    my ($sIndex, $qIndex) = validate_pos(@_, { type => SCALAR | UNDEF }, { type => SCALAR | UNDEF } );
    
    return if !defined $sIndex || !defined $qIndex;
     
    return "$sIndex-$qIndex";
}

=head2 answerId

Convenience method to construct an Answer Id from the given Section index, Question index and Answer index.

The id is constructed by hyphenating all three indices.

=cut

sub answerId {
    my $self = shift;
    my ($sIndex, $qIndex, $aIndex) = validate_pos(@_, { type => SCALAR | UNDEF  }, { type => SCALAR | UNDEF  }, { type => SCALAR | UNDEF  } );
    
    return if !defined $sIndex || !defined $qIndex || !defined $aIndex;
    
    return "$sIndex-$qIndex-$aIndex";
}

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

=head2 sIndex ($address)

Convenience sub to extract the section index from an address in the L<"surveyOrder"> array.
This method exists purely to improve code readability.
This method is identical to L<WebGUI::Asset::Wobject::Survey::SurveyJSON/sIndex>.

=cut

sub sIndex {
    my ($address) = validate_pos(@_, { type => ARRAYREF});
    return $address->[0];
}

#-------------------------------------------------------------------

=head2 qIndex ($address)

Convenience sub to extract the question index from an address in the L<"surveyOrder"> array.
This method exists purely to improve code readability.
This method is identical to L<WebGUI::Asset::Wobject::Survey::SurveyJSON/qIndex>.

=cut

sub qIndex {
    my ($address) = validate_pos(@_, { type => ARRAYREF});
    return $address->[1];
}

#-------------------------------------------------------------------

=head2 aIndexes ($address)

Convenience sub to extract the array of answer indices from an address in the L<"surveyOrder"> array.
This method exists purely to improve code readability.
Unlike sIndex and qIndex, this method is different to L<WebGUI::Asset::Wobject::Survey::SurveyJSON/aIndex>.
This is because the third element of the L<"surveyOrder"> address array ref in is an array of answer indices.

=cut

sub aIndexes {
    my ($address) = validate_pos(@_, { type => ARRAYREF});
    
    if (my $indexes = $address->[2]) {
        return @{ $indexes };
    }

    return;
}

#-------------------------------------------------------------------

=head2 returnResponsesForReporting

Used to extract JSON responses for use in reporting results.

Returns an array ref containing the current responses to the survey.  The array ref contains a list of hashes with the section, question,
sectionName, questionName, questionComment, and an answer array ref.  The answer array ref contains a list of hashes, with isCorrect (1 true, 0 false),
recorded value, and the id of the answer. 

=cut

# TODO: This sub should make use of recordedResponses

sub returnResponseForReporting {
    my $self      = shift;
    my @report = ();
    for my $address ( @{ $self->surveyOrder } ) {
        my ($sIndex, $qIndex) = (sIndex($address), qIndex($address));
        my $section = $self->survey->section( $address );
        my $question = $self->survey->question( [ $sIndex, $qIndex ] );
        my $questionId = $self->questionId($sIndex, $qIndex);

        # Skip if this is a Section without a Question
        if ( !defined $qIndex ) {
            next;
        }
        
        my @responses;
        for my $aIndex (aIndexes($address)) {
            my $answerId = $self->answerId($sIndex, $qIndex, $aIndex);

            if ( $self->responses->{$answerId} ) {

                # Make a safe copy of the response
                my %response = %{$self->responses->{$answerId}};
                $response{id} = $aIndex;

                my $answer = $self->survey->answer( [ $sIndex, $qIndex, $aIndex ] );
                if ( $answer->{isCorrect} ) {
                    $response{value}
                        = $answer->{value} =~ /\w/ ? $answer->{value}
                                                   : $question->{value}
                        ;
                    $response{isCorrect} = 1;
                }
                else {
                    $response{isCorrect} = 0;
                }
                push @responses, \%response;
            }
        }
        push @report, {
                    section         => $sIndex,
                    question        => $qIndex,
                    sectionName     => $section->{variable},
                    questionName    => $question->{variable},
                    questionComment => $self->responses->{$questionId}->{comment},
                    answers         => \@responses
                };
    }
    return \@report;
}

#-------------------------------------------------------------------

=head2 response

Accessor for the Perl hash containing Response data

=cut

sub response {
    my $self = shift;
    return $self->{_response};
}

=head2 responses

Mutator for the L<"responses"> property. 

Note, this is an unsafe reference.

=cut

sub responses {
    my $self = shift;
    my $responses = shift;
    if ( defined $responses ) {
        $self->response->{responses} = $responses;
    }
    return $self->response->{responses};
}

#-------------------------------------------------------------------

=head2 survey

Returns a referece to the SurveyJSON object that this object was created with.

Note, this is an unsafe reference.

=cut

sub survey {
    my $self = shift;
    return $self->{_survey};
}

1;
