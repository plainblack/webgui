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
            tags => {},

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

Mutator. The lastResponse property represents the surveyOrder index of the most recent item shown. 

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

=head2 tags ([ $tags ])

Mutator for the tags that have been applied to the response.
Returns (and optionally sets) the value of tags.

=head3 $tags (optional)

If defined, sets $tags to the supplied hashref.

=cut

sub tags {
    my $self     = shift;
    my ($tags) = validate_pos(@_, {type => HASHREF, optional => 1});

    if ( $tags ) {
        $self->response->{tags} = $tags;
    }

    return $self->response->{tags};
}

#-------------------------------------------------------------------

=head2 surveyOrder

Accessor. Initialized on first access via L<"initSurveyOrder">.

This data strucutre represents the list of items that are shown to the user, in the order
that they will be shown (ignoring jumps and jump expressions).

Typically each item will correspond to a question, and contains enough information to look
up both the corresponding section and all contained answers (if any).

Empty sections also appear in the list.

Each element of the array is an address, similar in structure to 
L<WebGUI::Asset::Wobject::Survey::SurveyJSON/Address Parameter>,
except that instead of an answerIndex in the third slot, we have a sub-array of all contained answer indicies.

    [ $sectionIndex, $questionIndex, [ $answerIndex1, $answerIndex2, ....]

By making use of L<WebGUI::Asset::Wobject::Survey::SurveyJSON> methods which expect address params as
arguments, you can access Section/Question/Answer items in order by iterating over surveyOrder.

For example:

 # Access sections in order..
 for my $address (@{ $self->surveyOrder }) {
        my $section  = $self->survey->section( $address );
        # etc..
 }

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

=head3 $submittedResponses

A hash ref of submitted form param data. Each element should look like:

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

gotos are handled similarly as with terminalUrls. The last goto in the set of questions wins.

In contrast, all gotoExpressions are passed to the Expression Engine (in order of: Answer, Question, Section). 
Expressions are not guaranteed to trigger a jump, and thus we give every expression in turn a change to run.
The first expression to trigger a jump will cause any remaining expressions to be skipped.

=cut

sub recordResponses {
    my $self = shift;
    my ($submittedResponses) = validate_pos( @_, { type => HASHREF } );

    # Build a lookup table of non-multiple choice question types
    my %knownTypes = map {$_ => 1} @{$self->survey->specialQuestionTypes};
    
    # We want to record responses against the "next" response section and questions, since these are
    # the items that have just been displayed to the user.
    my $section   = $self->nextResponseSection();
    
    my @questions = $self->nextQuestions();

    #GOTO jumps in the Survey.  Order of precedence is Answer, Question, then Section.
    my ($goto, $sectionExpression, $questionExpression, $answerExpression);

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
        $sectionExpression = $section->{gotoExpression};
    }

    # Handle empty Section..
    if ( !@questions and !$section->{logical}) {
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
            $questionExpression = $question->{gotoExpression};
        }

        # Record Question comment
        $self->responses->{ $question->{id} }->{comment} = $submittedResponses->{ $question->{id} . 'comment' };

        # Process Answers in Question..
        for my $answer ( @{ $question->{answers} } ) {

            # Pluck the values out of the responses hash that we want to record..
            my $submittedAnswerResponse = $submittedResponses->{ $answer->{id} };
            my $submittedAnswerComment  = $submittedResponses->{ $answer->{id} . 'comment' };
            my $submittedAnswerVerbatim = $submittedResponses->{ $answer->{id} . 'verbatim' };

            # Server-side Validation and storing of extra data for special q types goes here
            
            if($question->{questionType} eq 'Number'){
                if($answer->{max} =~ /\d/ and $submittedAnswerResponse > $answer->{max}){
                    next;
                }elsif($answer->{min} =~ /\d/ and $submittedAnswerResponse < $answer->{min}){
                    next;
                }elsif($answer->{step} =~ /\d/ and $submittedAnswerResponse % $answer->{step} != 0){
                    next;
                }
            } elsif ($question->{questionType} eq 'Year Month'){
                # store year and month as "YYYY Month"
                $submittedAnswerResponse = $submittedResponses->{ $answer->{id} . '-year' } . " " . $submittedResponses->{ $answer->{id} . '-month' };
            } else {
                if ( !defined $submittedAnswerResponse || $submittedAnswerResponse !~ /\S/ ) {
                    $self->session->log->debug("Skipping invalid submitted answer response: $submittedAnswerResponse");
                    next;
                }
            }
            
            # If we reach here, answer validated ok
            $aAnswered = 1;

            # Now, decide what to record. For multi-choice questions, use recordedAnswer.
            # Otherwise, we use the (raw) submitted response (e.g. text input, date input etc..)
            $self->responses->{ $answer->{id} }->{value}
                = $knownTypes{ $question->{questionType} }
                ? $submittedAnswerResponse
                : $answer->{recordedAnswer};
            
            $self->responses->{ $answer->{id} }->{verbatim} = $answer->{verbatim} ? $submittedAnswerVerbatim : undef;
            $self->responses->{ $answer->{id} }->{time}     = time;
            $self->responses->{ $answer->{id} }->{comment}  = $submittedAnswerComment;

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
                $answerExpression = $answer->{gotoExpression};
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
        $self->processGoto($goto)                     if ( defined $goto );                  ## no critic
        $self->processExpression($answerExpression)   if ( defined $answerExpression );      ## no critic
        $self->processExpression($questionExpression) if ( defined $questionExpression );    ## no critic
        $self->processExpression($sectionExpression)  if ( defined $sectionExpression );     ## no critic

        # Handle next logic Section..
        my $section = $self->nextResponseSection();
        if ( $section and $section->{logical} ) {
            return $self->recordResponses( {} );
        }
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
    
    if ($goto eq 'NEXT_SECTION') {
        $self->session->log->debug("NEXT_SECTION jump target encountered");
        my $lastResponseSectionIndex = $self->lastResponseSectionIndex;
        
        # Increment lastRepsonse until nextResponseSectionIndex moves
        while ($self->nextResponseSectionIndex == $lastResponseSectionIndex) {
            $self->lastResponse( $self->lastResponse + 1);
        }
        return;
    }
    
    if ($goto eq 'END_SURVEY') {
        $self->session->log->debug("END_SURVEY jump target encountered");
        $self->lastResponse( scalar( @{ $self->surveyOrder} ) - 1 );
        return;
    }

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

=head2 processExpression ( $expression )

Processes a Survey expression using the Survey Expression Engine. 

If the expression returns tag data, this data is stored in the response (see L<tags>).

If the expression returns a jump target, triggers a call to L<"processGoto">.

=head3 $expression

The expression. See  L<WebGUI::Asset::Wobject::Survey::ExpressionEngine> for more info.

=cut
    
sub processExpression {
    my $self = shift;
    my ($expression) = validate_pos(@_, {type => SCALAR});
    
    # Prepare the ingredients..
    my $values = $self->responseValuesByVariableName;
    my $scores = $self->responseScoresByVariableName;
    my $tags   = $self->tags;
    my %validTargets = map { $_ => 1 } @{$self->survey->getGotoTargets};
    
    use WebGUI::Asset::Wobject::Survey::ExpressionEngine;
    my $engine = "WebGUI::Asset::Wobject::Survey::ExpressionEngine";
    if (my $result = $engine->run($self->session, $expression, { values => $values, scores => $scores, tags => $tags, validTargets => \%validTargets} ) ) {
        # Update tags
        if (my $tags = $result->{tags} ) {
            $self->tags( $tags );
        }
        
        if (my $jump = $result->{jump}) {
            $self->session->log->debug("Jumping to [$jump]");
            $self->processGoto($jump);
        } else {
            $self->session->log->debug("No hits, falling through");
        }
    }    
    return;
}

#-------------------------------------------------------------------

=head2 recordedResponses

Returns an array or response information in this response's survey order.

=cut

sub recordedResponses{
    my $self = shift;
    my $responses= [
        # {answer info hash}
    ];
    # Populate @$responses with the user's data..
    for my $address ( @{ $self->surveyOrder } ) {
        my $question = $self->survey->question( $address );
        my ($sIndex, $qIndex) = (sIndex($address), qIndex($address));
        for my $aIndex (aIndexes($address)) {
            my $question = $self->survey->question([$sIndex,$qIndex]);
            my $answerId = $self->answerId($sIndex, $qIndex, $aIndex);
            if ( defined $self->responses->{$answerId} ) {
                my $answer = $self->survey->answer( [ $sIndex, $qIndex, $aIndex ] );
                push(@$responses, {
                    value => $answer->{value} =~ /\w/  ? $answer->{value} : $question->{value},
                    recordedAnswer => $answer->{recordedAnswer},
                    isCorrect => $answer->{isCorrect},
                    answerText => $answer->{text},
                    address => [$sIndex,$qIndex,$aIndex],
                    questionText => $question->{text},
                    questionValue => $question->{value},
                    questionType => $question->{questionType}
                    }
                );
            }
        }
    }
    return $responses;
}


#-------------------------------------------------------------------

=head2 responseValuesByVariableName ( $options )

Returns a lookup table to question variable names and recorded response values.

Only questions with a defined variable name set are included. Values come from
the L<responses> hash.

=head3 options

The following options are supported:

=over 3

=item * useText

For multiple choice questions, use the answer text instead of the recorded value
(useful for doing [[var]] text substitution

=back

=cut

sub responseValuesByVariableName {
    my $self = shift;
    my %options = validate(@_, { useText => 0 });
    
    my %lookup;
    while (my ($address, $response) = each %{$self->responses}) {
        next if (!$response || !$address);
        
        # Turn responses s-q-a string into an address array
        my @address = split /-/, $address;
        
        # Filter out the non-answer entries
        next unless @address == 3;
        
        # Grab the corresponding question
        my $question = $self->survey->question([@address]);

        # Filter out questions without defined variable names
        next if !$question || !defined $question->{variable};
        
        my $value = $response->{value};
        if ($options{useText}) {
            # Test if question is a multiple choice type so we can use the answer text instead
            if($self->survey->getMultiChoiceBundle($question->{questionType})){
                my $answer = $self->survey->answer([@address]);
                my $answerText = $answer->{text};
                
                # For verbatim mc answers, combine answer text and recorded value
                if ($answer->{verbatim}) {
                    $answerText = "$answerText - \"$response->{verbatim}\"";
                }
                $value = $answerText ? $answerText : $value;
            }
        }
        
        # Add variable => value to our hash
        $lookup{$question->{variable}} = $value;
    }
    return \%lookup;
}

#-------------------------------------------------------------------

=head2 responseScoresByVariableName

Returns a lookup table to question variable names and recorded response values.

Only questions with a defined variable name set are included. Scores come from
the L<responses> hash.

=cut

sub responseScoresByVariableName {
    my $self = shift;
    
    my %lookup;
    while (my ($address, $response) = each %{$self->responses}) {
        next if (!$response || !$address);
        
        # Turn responses s-q-a string into an address array
        my @address = split /-/, $address;
        
        # Filter out the non-answer entries
        next unless @address == 3;
        
        # Grab the corresponding question
        my $question = $self->survey->question([@address]);
        
        # Filter out questions without defined variable names
        next if !$question || !defined $question->{variable};
        
        # Grab the corresponding answer
        my $answer = $self->survey->answer([@address]);
        
        # Use question score if answer score undefined
        my $score = (exists $answer->{value} && length $answer->{value} > 0) ? $answer->{value} : $question->{value};
        
        # Add variable => score to our hash
        $lookup{$question->{variable}} = $score;
    }
    
    # Add section score totals
    for my $s (@{$self->survey->sections}) {
        next unless $s->{variable};
        
        my $score = 0;
        for my $q (@{$s->{questions}}) {
            next unless $q->{variable};
            next unless exists $lookup{$q->{variable}};
            
            $lookup{$s->{variable}} += $lookup{$q->{variable}};
        }
    }
    
    return \%lookup;
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
    my $responseValuesByVariableName = $self->responseValuesByVariableName( { useText => 1 } );
    my $tags = $self->tags;
    
    # Merge values and tags hashes for processing [[var]] templated text
    my %templateValues = (%$responseValuesByVariableName, %$tags);

    # Do text replacement
    $section->{text} = $self->getTemplatedText($section->{text}, \%templateValues);

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
        $questionCopy{text} = $self->getTemplatedText($questionCopy{text}, \%templateValues);

        # Add any extra fields we want..
        $questionCopy{id}  = $self->questionId($sIndex, $qIndex);
        $questionCopy{sid} = $self->sectionId($sIndex);

        # Rebuild the list of anwers with a safe copy
        delete $questionCopy{answers};
        for my $aIndex ( aIndexes($address) ) {
            my %answerCopy = %{ $self->survey->answer( [ $sIndex, $qIndex, $aIndex ] ) };

            # Do text replacement
            $answerCopy{text} = $self->getTemplatedText($answerCopy{text}, \%templateValues);

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

=head2 showSummary ( [$sectionAddresses] )

showSummary returns the current responses summary for the entire response, if 
no address is passed in, or just the sections addressed by $sectionAddresses.

For each section, the total correct, wrong, time taken, and points are returned.  And each 
question is listed with the text, given score, user response, and if it was correct.
This list is meant for a template and only what is needed should be shown.

A summary of the entire suvey, 

=cut

sub showSummary{
    my $self = shift;
    my $sectionAddies = shift;#array of section addresses

    my $all = 0;
    $all = 1 if(! $sectionAddies);

    my ($summaries);

    my $responses = $self->recordedResponses();
    my %goodSection;
    map{$goodSection{$_} = 1} @$sectionAddies;
    
    return if(! $responses);

    my ($sectionIndex, $responseIndex) = (-1, 1);
    my ($currentSection,$currentQuestion) = (-1,-1); 
    ($summaries->{totalCorrect},$summaries->{totalIncorrect}) = (0,0);

    for my $response (@$responses){
        if(! $all and ! $goodSection{$response->{address}->[0]}){next;}
        if($response->{isCorrect}){
            $summaries->{totalCorrect}++;
        }else{
            $summaries->{totalIncorrect}++;
        }
        $summaries->{totalAnswers}++;
        if($currentSection != $response->{address}->[0]){
            $summaries->{totalSections}++;
            $sectionIndex++;
            $responseIndex = -1;
            $currentSection = $response->{address}->[0];
        }
        if($currentQuestion != $response->{address}->[1]){
            $summaries->{totalQuestions}++;
        }
        _loadSectionIntoSummary(\%{$summaries->{sections}->[$sectionIndex]}, $response);
        $responseIndex++;
        _loadResponseIntoSummary(\%{$summaries->{sections}->[$sectionIndex]->{responses}->[$responseIndex]},
            $response,
            $self->survey->{multipleChoiceTypes});
    }
    return $summaries;
}
sub _loadResponseIntoSummary{
    my $node = shift;
    my $response = shift;
    my $types = shift;

    $node->{"Question ID"} = $response->{address}->[1] + 1;
    $node->{"Question Text"} = $response->{questionText};
    $node->{"Answer ID"} = $response->{address}->[2] + 1;
    if($response->{isCorrect}){
        $node->{Correct} = "Y";
        $node->{Score} = $response->{value};
    }else{   
        $node->{Correct} = "N";
        $node->{Score} = 0;
    }
    $node->{"Answer Text"} = $response->{answerText};

    #test if it is a multiple choide type
    if($types->{$response->{questionType}}){
        $node->{Value} = $response->{value};
    }else{
        $node->{Value} = $response->{recordedValue};
    }
}
sub _loadSectionIntoSummary{
    my $node = shift; 
    my $response = shift;
    $node->{id} = $response->{address}->[0] + 1;
    $node->{inCorrect} = 0 if(!defined $node->{inCorrect});
    $node->{score} = 0 if(!defined $node->{score});
    $node->{correct} = 0 if(!defined $node->{correct});
    $node->{total} = 0 if(!defined $node->{total});
    $node->{total}++;
    if($response->{isCorrect} == 1){
        $node->{score} += $response->{value};
        $node->{correct}++;
    }else{
        $node->{inCorrect}++;
    }

}
#-------------------------------------------------------------------

=head2 returnResponseForReporting

Used to extract JSON responses for use in reporting results.

Returns an array ref containing the current responses to the survey.  The array ref contains a list of hashes with the section, question,
sectionName, questionName, questionComment, and an answer array ref.  The answer array ref contains a list of hashes, with isCorrect (1 true, 0 false),
recorded value, and the id of the answer. 

=cut

# TODO: This sub should make use of responseValuesByVariableName

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

#-------------------------------------------------------------------

=head2 responses

Mutator. Note, this is an unsafe reference.

This data structure stores a snapshot of all question responses. Both question data and answer data
is stored in this hash reference.

Questions keys are constructed by hypenating the relevant L<"sIndex"> and L<"qIndex">.
Answer keys are constructed by hypenating the relevant L<"sIndex">, L<"qIndex"> and L<aIndex|"aIndexes">.

 {
     # Question entries only contain a comment field, e.g.
     '0-0' => {
         comment => "question comment",
     },
     # ...
     # Answers entries contain: value (the recorded value), time and comment fields.
     '0-0-0' => {
         value   => "recorded answer value",
         time    => time(),
         comment => "answer comment",
    },
    # ...
 }

=cut

sub responses {
    my $self = shift;
    my $responses = shift;
    if ( defined $responses ) {
        $self->response->{responses} = $responses;
    }
    return $self->response->{responses};
}

=head2 pop

=cut

sub pop {
    my $self      = shift;
    my %responses = %{ $self->responses };
    
    # Iterate over responses first time to determine time of most recent response(s)
    my $lastResponseTime;
    for my $r ( values %responses ) {
        if ( $r->{time} ) {
            $lastResponseTime 
                = !$lastResponseTime || $r->{time} > $lastResponseTime  
                ? $r->{time} 
                : $lastResponseTime
                ;
        }
    }
    
    return unless $lastResponseTime;
    
    my $popped;
    my $poppedQuestions;
    # Iterate again, removing most recent responses
    while (my ($address, $r) = each %responses ) {
        if ( $r->{time} == $lastResponseTime) {
            $popped->{$address} = $r;
            delete $self->responses->{$address};
            
            # Remove associated question/comment entry
            my ($sIndex, $qIndex, $aIndex) = split /-/, $address;
            my $qAddress = "$sIndex-$qIndex";
            $popped->{$qAddress} = $responses{$qAddress};
            delete $self->responses->{$qAddress};
            
            # while we're here, build lookup table of popped question ids
            $poppedQuestions->{$qAddress} = 1;
        }
    }
    
    # Now, nextResponse should be set to index of the first popped question we can find in surveyOrder
    my $nextResponse = 0;
    for my $address (@{ $self->surveyOrder }) {
        my $questionId = "$address->[0]-$address->[1]";
        if ($poppedQuestions->{$questionId} ) {
            $self->session->log->debug("setting nextResponse to $nextResponse");
            $self->nextResponse($nextResponse);
            last;
        }
        $nextResponse++;
    }
    
    return $popped;
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
