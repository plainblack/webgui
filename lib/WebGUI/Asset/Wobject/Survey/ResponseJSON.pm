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
from the user (L<"responses">), the most recently answered question (L<"lastResponse">) and the 
number of questions answered (L<"questionsAnswered">).

This package is not intended to be used by any other Asset in WebGUI.

=cut

use strict;
use JSON;
use Params::Validate qw(:all);
use List::Util qw(shuffle);
use Clone qw/clone/;
use Safe;
use WebGUI::Asset::Wobject::Survey::ExpressionEngine;
Params::Validate::validation_options( on_fail => sub { WebGUI::Error::InvalidParam->throw( error => shift ) } );

#-------------------------------------------------------------------

=head2 new ( $survey, $json )

Object constructor.

=head3 $survey

A L<WebGUI::Asset::Wobject::Survey::SurveyJSON> object that represents the current
survey.

=head3 $json

A JSON string used to construct a new Perl object. The string should represent 
a JSON hash made up of L<"surveyOrder">, L<"responses">, L<"lastResponse">
and L<"questionsAnswered"> keys, with appropriate values.

=cut

sub new {
    my $class  = shift;
    my ($survey, $json)   = validate_pos(@_, {isa => 'WebGUI::Asset::Wobject::Survey::SurveyJSON' }, { type => SCALAR | UNDEF, optional => 1});

    # Load json object if given..
    my $jsonData = $json ? from_json($json) : {};

    # Create skeleton object..
    my $self = {
        _survey => $survey,
        _session => $survey->session,
        # _response property set by call to reset()
    };
    
    bless $self, $class;
    $self->reset({ data => $jsonData });
}

=head2 reset

Reset all response data in this object (e.g. re-init the _response property)

=cut

sub reset {
    my $self = shift;
    my (%opts) = validate(@_, { data => { type => HASHREF, default => {} }, preserveSurveyOrder => 0 } );
    
    my $data = $opts{data};
    
    # Access these via the private hash var so that we don't inadvertantly trigger initSurveyOrder
    my $oldSurveyOrder = $self->{_response}{surveyOrder};
    my $oldSurveyOrderLookup = $self->{_response}{surveyOrderLookup};
    
    $self->{_response} = {
        # Response hash defaults..
        responses => {},
        lastResponse => -1,
        questionsAnswered => 0,
        surveyOrder => undef,
        tags => {},
    };
    
    # And then data overrides (via a hash slice)
    @{$self->{_response}}{keys %{$data}} = values %{$data};
    
    if ($opts{preserveSurveyOrder}) {
        $self->{_response}{surveyOrder} = $oldSurveyOrder;
        $self->{_response}{surveyOrderLookup} = $oldSurveyOrderLookup;
    }
    
    # If first section is logical, process it immediately
    $self->checkForLogicalSection;
    
    return $self;
}

#----------------------------------------------------------------------------

=head2 initSurveyOrder

Computes and stores the order of Sections, Questions and Aswers for this Survey. 
See L<"surveyOrder">. You normally don't need to call this, as L<"surveyOrder"> will
call it for you the first time it is used.

Also builds a lookup table for surveyOrder index, for performance reasons.

Questions and Answers that are set to be randomized are shuffled into a random order.

=cut

sub initSurveyOrder {
    my $self = shift;

    # Build a lookup table as we go
    my %lookup;
    
    # Order Questions in each Section
    my @surveyOrder;
    my $surveyOrderIndex = 0;
    for my $sIndex ( 0 .. $self->survey->lastSectionIndex ) {
        my $s = $self->survey->section( [$sIndex] );
        
        if (my $variable = $s->{variable}) {
            $lookup{$variable} = $surveyOrderIndex if !exists $lookup{$variable};
        }
        
        #  Randomize Questions if required..
        my @qOrder;
        if ( $s->{randomizeQuestions} ) {
            @qOrder = shuffle 0 .. $self->survey->lastQuestionIndex( [$sIndex] );
        }
        else {
            @qOrder = ( 0 .. $self->survey->lastQuestionIndex( [$sIndex] ) );
        }

        # Order Answers in each Question
        for my $qIndex (@qOrder) {
            
            my $question = $self->survey->question( [ $sIndex, $qIndex ] );
            if (my $variable = $question->{variable}) {
                $lookup{$variable} = $surveyOrderIndex if !exists $lookup{$variable};
            }
            
            # Randomize Answers if required..
            my @aOrder;
            if ( $question->{randomizeAnswers} ) {
                @aOrder = shuffle 0 .. $self->survey->lastAnswerIndex( [ $sIndex, $qIndex ] );
            }
            else {
                @aOrder = ( 0 .. $self->survey->lastAnswerIndex( [ $sIndex, $qIndex ] ) );
            }
            push @surveyOrder, [ $sIndex, $qIndex, \@aOrder ];
            $surveyOrderIndex++; # Increment each time an item is pushed onto @surveyOrder
        }

        # If Section had no Questions, make sure it is still added to @surveyOrder
        if ( !@qOrder ) {
            push @surveyOrder, [$sIndex];
            $surveyOrderIndex++; # Increment each time an item is pushed onto @surveyOrder
        }
    }
    $self->response->{surveyOrder} = \@surveyOrder;
    $self->response->{surveyOrderLookup} = \%lookup;
    
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

To reduce json serialization time and db bloat, we only serialize the bare essentials

=cut

sub freeze {
    my $self = shift;
    
    # These are the only properties of the response hash that we serialize:
    my @props = qw(responses lastResponse questionsAnswered tags);
    my %serialize;
    @serialize{@props} = @{$self->response}{@props};
    return to_json(\%serialize);
}

#-------------------------------------------------------------------

=head2 lastResponse ([ $responseIndex ])

Mutator. The lastResponse property represents the surveyOrder index of the most recent item shown. 

This method returns (and optionally sets) the value of lastResponse.

You may want to call L<checkForLogicalSection> after modifying this so that
any logical section you land in gets immediately processed.

=head3 $responseIndex (optional)

If defined, lastResponse is set to $responseIndex.

=cut

sub lastResponse {
    my $self = shift;
    my $responseIndex = shift;
    
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
    my $questionsAnswered = shift;
    
    if ( defined $questionsAnswered ) {
        $self->response->{questionsAnswered} += $questionsAnswered;
    }
    
    return $self->response->{questionsAnswered};
}

#-------------------------------------------------------------------

=head2 tags ([ $tags ])

Mutator for the tags that have been applied to the response.
Returns (and optionally sets) the value of tags.

=head3 $tags (optional)

If defined, sets $tags to the supplied hashref.

=cut

sub tags {
    my $self = shift;
    my $tags = shift;

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

=head2 surveyOrderIndex ($variable)

Looks up the surveyOrder index of Section/Question via variable name

Uses the surveyOrderLookup table, which gets lazily built if it doesn't exist

=cut

sub surveyOrderIndex {
    my $self = shift;
    my $variable = shift;
    
    if (!defined $self->response->{surveyOrderLookup}) {
        $self->initSurveyOrder();
    }
    
    if ($variable) {
        return $self->response->{surveyOrderLookup}{$variable};
    } else {
        return clone $self->response->{surveyOrderLookup};
    }
}

#-------------------------------------------------------------------

=head2 nextResponse ([ $responseIndex ])

Mutator. The index of the next item that should be shown to the user, 
that is, the index of the next item in the L<"surveyOrder"> array,
e.g. L<"lastResponse"> + 1.

You may want to call L<checkForLogicalSection> after modifying this so that
any logical section you land in gets immediately processed.

=head3 $responseIndex (optional)

If defined, nextResponse is set to $responseIndex.

=cut

sub nextResponse {
    my $self = shift;
    my $responseIndex = shift;
    
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

A hash ref of submitted form param data. Each element should look like:

    {
        "questionId-comment"    => "question comment",
        "answerId"              => "answer",
        "answerId-verbatim"     => "answer verbatim",
    }

See L<"questionId"> and L<"answerId">.

=head3 Terminal, goto and gotoExpression processing

Gotos are processed first, followed by gotoExpressions, and finally terminals.
On a page with the following items:
   Section 1
     Question 1.1
       Answer 1.1.1
       Answer 1.1.2
     Question 1.2
       Answer 1.2.1
     ..

the precedence order is inside-out, in order of questions displayed, e.g.

   Answer 1.1.1
   Answer 1.1.2
   Question 1.1
   Answer 1.2.1
   Question 1.2
   Section 1

The first to trigger a jump short-circuits the process, meaning that subsequent items are not attempted.

For Sections with questions spread out over several pages, Section-level actions are only performed on the final page of the Section.

=cut

sub recordResponses {
    my $self = shift;
    my ($responses) = validate_pos( @_, { type => HASHREF } );

    # Build a lookup table of non-multiple choice question types
    my %specialQTypes = map { $_ => 1 } @{ $self->survey->specialQuestionTypes };

    # We want to record responses against the "next" response section and questions, since these are
    # the items that have just been displayed to the user.
    my $section = $self->nextResponseSection();
    my $sId = $self->nextResponseSectionIndex(); # make note of the section id prior to recording any responses

    # Process responses by looping over expected questions in survey order
    my @questions  = $self->nextQuestions();
    my %newResponse;
    my $allQsValid = 1;
    my %validAnswers;
    for my $question (@questions) {
        my $aValid = 0;
        my $qId = $question->{id};

        my $comment = $responses->{ "${qId}comment" };
        if (defined $comment && length $comment) {
            $newResponse{ $qId }->{comment} = $comment;
        }
        
        for my $answer ( @{ $question->{answers} } ) {
            my $aId = $answer->{id};
            my $recordedAnswer = $responses->{ $aId };
            my $questionType = $question->{questionType};

            # Server-side Validation and storing of extra data for special q types goes here
            # Any answer that fails validation should be skipped with 'next'
            
            if ( $questionType eq 'Country' ) {
                # Must be a valid country
                if (!grep { $_ eq $recordedAnswer } WebGUI::Form::Country->getCountries) {
                    $self->session->log->debug("Invalid $questionType: $recordedAnswer");
                    next;
                }
            }
#            elsif ( $questionType eq 'Date' ) {
#                # Accept any date input until we get per-question validation options
#                if ($recordedAnswer !~ m|^\d{4}/\d{1,2}/\d{1,2}$|) {
#                    $self->session->log->debug("Invalid $questionType: $recordedAnswer");
#                    next;
#                }
#            } 
            elsif ( $questionType eq 'Number' || $questionType eq 'Slider' ) {
                if ( $answer->{max} =~ /\d/ and $recordedAnswer > $answer->{max} ) {
                    $self->session->log->debug("Invalid $questionType: $recordedAnswer");
                    next;
                }
                elsif ( $answer->{min} =~ /\d/ and $recordedAnswer < $answer->{min} ) {
                    $self->session->log->debug("Invalid $questionType: $recordedAnswer");
                    next;
                }
            } 
            elsif ( $questionType eq 'Year Month' ) {
                # store year and month as "YYYY Month"
                $recordedAnswer = $responses->{ "$aId-year" } . " " . $responses->{ "$aId-month" };
            }
            else {
                # In the case of a mc question, only selected answers will have a defined recordedAnswer
                # Thus we skip any answers where recordedAnswer is not defined
                if (!defined $recordedAnswer || $recordedAnswer !~ /\S/) {
                    $self->session->log->debug("Invalid $questionType: $recordedAnswer");
                    next;
                }
            } 

            # If we reach here, answer validated ok
            $aValid = 1;
            $validAnswers{$aId} = 1;

            # Now, decide what to record. For multi-choice questions, use recordedAnswer.
            # Otherwise, we use the (raw) submitted response (e.g. text input, date input etc..)
            $newResponse{ $aId } = {
                value       => $specialQTypes{ $questionType } ? $recordedAnswer : $answer->{recordedAnswer},
                time        => time,
            };
            
            # Only record verbatim if answer is marked verbatim
            my $verbatim = $responses->{ "${aId}verbatim" };
            if ($answer->{verbatim} && defined $verbatim && length $verbatim) {
                $newResponse{ $aId }{verbatim} = $verbatim;
            }
        }

        # Check if a required Question was skipped
        $allQsValid = 0 if $question->{required} && !$aValid;

        # If question was answered, increment the questionsAnswered count..
        $self->questionsAnswered(+1) if $aValid;
    }

    # Stop here on validation errors
    if ( !$allQsValid ) {
        $self->session->log->debug("One or more questions failed validation");
        return;
    }
    
    # Add newResponse to the overall response (via a hash slice)
    @{$self->responses}{keys %newResponse} = values %newResponse;
    
    # Now that the response has been recorded, increment nextResponse
    # N.B. This can be overwritten by goto and gotoExpressions, below.
    # (we give them a chance to run before processing logical sections)
    # Normally we move forward by the number of questions answered, but if
    # the section has no questions we still move forward by 1
    $self->nextResponse( $self->nextResponse + ( @questions || 1 ) );

    # Now that the response has been added, loop over the questions a second time
    # to process goto, gotoExpression, and terminalUrls. 
    #
    # We are only dealing with a single section. On a page with:
    #
    #   Section 1
    #     Question 1.1
    #       Answer 1.1.1
    #       Answer 1.1.2
    #     Question 1.2
    #       Answer 1.2.1
    #     ..
    #
    # the precedence order is inside-out, in order of questions displayed, e.g.
    #
    #   Answer 1.1.1
    #   Answer 1.1.2
    #   Question 1.1
    #   Answer 1.2.1
    #   Question 1.2
    #   Section 1
    #   ..
    for my $question (@questions) {
        
        # First Answers..
        
        for my $answer ( @{ $question->{answers} } ) {
            # Only process the chosen answer..
            my $aId = $answer->{id};
            next if !$validAnswers{$aId};
            
            # Answer goto
            if (my $action = $answer->{goto} && $self->processGoto($answer->{goto})) {
                $self->session->log->debug("Branching on Answer goto: $answer->{goto}");
                return $action;
            }
            # Then answer gotoExpression
            if (my $action = $answer->{gotoExpression} && $self->processExpression($answer->{gotoExpression})) {
                $self->session->log->debug("Branching on Answer gotoExpression: $answer->{gotoExpression}");
                return $action;
            }
            # Then answer terminal
            if ($answer->{terminal}) {
                $self->session->log->debug("Answer terminal: $answer->{terminalUrl}");
                return { terminal => $answer->{terminalUrl} };
            }
        }
        
        # Then Questions..
        
        # Question goto
        if (my $action = $question->{goto} && $self->processGoto($question->{goto})) {
            $self->session->log->debug("Branching on Question goto: $question->{goto}");
            return $action;
        }
        # Then question gotoExpression
        if (my $action = $question->{gotoExpression} && $self->processExpression($question->{gotoExpression})) {
            $self->session->log->debug("Branching on Question gotoExpression: $question->{gotoExpression}");
            return $action;
        }
        # N.B. Questions don't have terminalUrls
    }
    
    # Then Sections.. (but if this is the last page of the Section)
    my $newSectionIndex = $self->nextResponseSectionIndex;
    if ($newSectionIndex != $sId) {
        # Section goto
        if (my $action = $section->{goto} && $self->processGoto($section->{goto})) {
            $self->session->log->debug("Branching on Section goto: $section->{goto}");
            return $action;
        }
        # Then section gotoExpression
        if (my $action = $section->{gotoExpression} && $self->processExpression($section->{gotoExpression})) {
            $self->session->log->debug("Branching on Section gotoExpression: $section->{gotoExpression}");
            return $action;
        }
        # Then section terminal
        if ($section->{terminal} && $self->nextResponseSectionIndex != $self->lastResponseSectionIndex) {
            $self->session->log->debug("Section terminal: $section->{terminalUrl}");
            return { terminal => $section->{terminalUrl} };
        }
    }
    
    # The above goto and gotoExpression checks will have already called $self->checkForLogicalSection after
    # moving nextResponse, however we need to call it again here for the case where the survey fell
    # through naturally to a logical section
    $self->checkForLogicalSection;
    
    $self->session->log->debug("Falling through..");
    return;
}

=head2 checkForLogicalSection

Check if the next response section is marked as logical, and if so, immediately processed it.
Normally, this sub should be called every time lastResponse or nextResponse is modified, so
that logical sections "automatically" trigger.

=cut

sub checkForLogicalSection {
    my $self = shift;
    my $section = $self->nextResponseSection();
    if ($section && $section->{logical}) {
        $self->session->log->debug("Processing logical section $section->{variable}");
        $self->recordResponses({});
    }
    return;
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
    my $goto = shift;
    
    return if !$goto;
    
    if ($goto eq 'NEXT_SECTION') {
        $self->session->log->debug("NEXT_SECTION jump target encountered");
        my $lastResponseSectionIndex = $self->lastResponseSectionIndex;
        
        # Increment lastRepsonse until nextResponseSectionIndex moves
        while ($self->nextResponseSectionIndex == $lastResponseSectionIndex) {
            $self->lastResponse( $self->lastResponse + 1);
        }
        $self->checkForLogicalSection;
        return 1;
    }
    
    if ($goto eq 'END_SURVEY') {
        $self->session->log->debug("END_SURVEY jump target encountered");
        $self->lastResponse( scalar( @{ $self->surveyOrder} ) - 1 );
        $self->checkForLogicalSection;
        return 1;
    }
    
    if (defined(my $surveyOrderIndex = $self->surveyOrderIndex($goto))) {
        $self->nextResponse( $surveyOrderIndex );
        $self->checkForLogicalSection;
        return 1;
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
    my $expression = shift;
    
    return if !$expression;
    
    # Prepare the ingredients..
    my $values = $self->responseValues( indexBy => 'variable' );
    my $scores = $self->responseScores( indexBy => 'variable' );
    my $tags   = $self->tags;
    my %validTargets = map { $_ => 1 } @{$self->survey->getGotoTargets};
    
    my $engine = "WebGUI::Asset::Wobject::Survey::ExpressionEngine";
    if (my $result = $engine->run($self->session, $expression, { values => $values, scores => $scores, tags => $tags, validTargets => \%validTargets} ) ) {
        # Update tags
        if (my $tags = $result->{tags} ) {
            $self->tags( $tags );
        }
        
        if (my $jump = $result->{jump}) {
            $self->session->log->debug("Jumping to [$jump]");
            return $self->processGoto($jump);
        } elsif (exists $result->{exitUrl}) { # may be undefined
            my $exitUrl = $result->{exitUrl};
            $self->session->log->debug("exitUrl triggered [$exitUrl]");
            return { exitUrl => $exitUrl };
        } elsif (my $restart = $result->{restart}) {
            $self->session->log->debug("restart triggered");
            return { restart => $restart };
        } else {
            $self->session->log->debug("No hits, falling through");
            return;
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

=head2 responseValues ( $opts )

Returns a lookup table of recorded response values, keyed by either question variable
or question address. Values come from the L<responses> hash.

Accepts the following options:

=over 4

=item * useText

For multiple choice questions, use the answer text instead of the recorded value
(useful for doing [[var]] text substitution

=item * indexBy

The property to index responses by. Valid values are C<variable> (default) and C<address>.

When using C<variable>, only questions with a defined variable name are included in the set.

=back

=cut

sub responseValues {
    my $self = shift;
    my %opts = validate(@_, { useText => 0, indexBy => { default => 'variable' } });
    
    my %lookup;
    
    # Process responses in id order (so that questions with maxAnswers != 1 stringify according
    # to natural ordering of answers (e.g. answer 0, answer 1, etc..
    for my $address (sort keys %{$self->responses}) {
        next if !$address;
        my $response = $self->responses->{$address};
        next if !$response;
        
        # Turn responses s-q-a string into an address array
        my @address = split /-/, $address;
        
        # Filter out the non-answer entries
        next unless @address == 3;
        
        # Grab the corresponding question
        my $question = $self->survey->question([@address]);

        # Find out what we're indexing responses by
        my $identifier 
            = $opts{indexBy} eq 'variable' ? $question && $question->{variable} 
                                           : $self->questionId(@address);
        next unless $identifier;
        
        my $answer = $self->survey->answer([@address]);
        
        my $value = $response->{value};
        if ($opts{useText}) {
            # Test if question is a multiple choice type so we can use the answer text instead
            if($self->survey->getMultiChoiceBundle($question->{questionType})){
                my $answerText = $answer->{text};
                
                # For verbatim mc answers, combine answer text and recorded value
                if ($answer->{verbatim}) {
                    $answerText = "$answerText - \"$response->{verbatim}\"";
                }
                $value = $answerText ? $answerText : $value;
            }
        }
        
        # Add identifier => value to our hash
        if (!$question->{maxAnswers} || $question->{maxAnswers} > 1) {
            push @{$lookup{$identifier}}, $value;
        } else {
            $lookup{$identifier} = $value;
        }
        
        # For verbatims, also add verbatim value to lookup as identifier_verbatim
        if ($answer->{verbatim}) {
            my $verbatimKey = "${identifier}_verbatim";
            my $verbatimValue = $response->{verbatim};
            if (!$question->{maxAnswers} || $question->{maxAnswers} > 1) {
                push @{$lookup{$verbatimKey}}, $verbatimValue;
            } else {
                $lookup{$verbatimKey} = $verbatimValue;
            }
        }
    }
    return \%lookup;
}

#-------------------------------------------------------------------

=head2 responseScores ( $opts )

Returns a lookup table of recorded response scores, keyed by either question variable
or question address. Values come from the L<responses> hash.

Accepts the following options:

=over 4

=item * indexBy

The property to index responses by. Valid values are C<variable> (default) and C<address>.

When using C<variable>, only questions with a defined variable name are included in the set.

=back

=cut

sub responseScores {
    my $self = shift;
    my %opts = validate(@_, { indexBy => { default => 'variable' } });
    
    my %lookup;
    my $responses = $self->responses;
    # Process responses in id order, just to be consistent with L<responseValues>
    for my $address (sort keys %$responses) {
        next if !$address;
        my $response = $responses->{$address};
        next if !$response;
        
        # Turn responses s-q-a string into an address array
        my @address = split /-/, $address;
        
        # Filter out the non-answer entries
        next unless @address == 3;
        
        # Grab the corresponding question
        my $question = $self->survey->question([@address]);
        
        # Find out what we're indexing responses by
        my $identifier 
            = $opts{indexBy} eq 'variable' ? $question && $question->{variable} 
                                           : $self->questionId($address);
        next unless $identifier;
        
        # Grab the corresponding answer
        my $answer = $self->survey->answer([@address]);
        
        # Use question score if answer score undefined
        my $score = (exists $answer->{value} && length $answer->{value} > 0) ? $answer->{value} : $question->{value};
        
        # Add variable => score to our hash (or add to existing score for multi-answer questions, e.g. maxAnswers != 1)
        $lookup{$identifier} += $score;
    }
    
    # Add section score totals (currently only implemented when index is 'variable'
    if ($opts{indexBy} eq 'variable') {
        for my $s ( @{ $self->survey->sections } ) {
            my $sVar = $s->{variable};
            next unless $sVar;
            
            # N.B. Using map and grep here proved to be about twice as fast as looping over $s->{questions}
            map { $lookup{$sVar} += $lookup{ $_->{variable} } }
                grep { $_->{variable} and exists $lookup{ $_->{variable} } } @{ $s->{questions} };
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
    my ($text, $params) = validate_pos(@_, { type => SCALAR|UNDEF }, { type => HASHREF });
    $text = q{} if not defined $text;
    
    # Turn multi-valued answers into comma-separated text
    for my $value (values %$params) {
        $value = join(',', @$value) if ref $value eq 'ARRAY';
    }

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
    my $responseValues = $self->responseValues( { useText => 1, indexBy => 'variable' } );
    my $tags = $self->tags;
    
    # Merge values and tags hashes for processing [[var]] templated text
    my %templateValues = (%$responseValues, %$tags);

    # Do text replacement
    $section->{text} = $self->getTemplatedText($section->{text}, \%templateValues);

    # Collect all the questions to be shown on the next page..
    my @questions;
    QUESTION:
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

        # In rare cases where you change the structure of your survey after 
        # someone has already started a response, it's possible for this
        # to be triggered, in which case the easiest course of action is
        # to just skip over the question.
        if (!$self->survey->question( $address )) {
            $self->session->log->debug("Unable to retrieve question for address $sIndex-$qIndex");
            next;
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
        
        if ($questionCopy{questionType} eq 'Tagged') {
            if (!$questionCopy{variable}) {
                $self->session->log->warn("Unable to build Tagged question, question variable must be defined");
                next QUESTION;
            }
            
            my $tags = $self->tags;
            my $taggedAnswers = $tags->{"$questionCopy{variable}_TAGGED_ANSWERS"};
            if (!$taggedAnswers || ref $taggedAnswers ne 'ARRAY') {
                $self->session->log->warn("Unable to build Tagged question, $questionCopy{variable}_TAGGED_ANSWERS is invalid");
                next QUESTION;
            }
            
            my $aIndex = 0;
            for my $taggedAnswer (@$taggedAnswers) {
                
                if (!$taggedAnswer || ref $taggedAnswer ne 'HASH') {
                    $self->session->log->warn("Unable to build Tagged question, one or more answers definitions invalid");
                    next QUESTION;
                }
                
                # Tagged data overrides answer defaults
                my %answerCopy = (%{$self->survey->newAnswer()}, %$taggedAnswer);
                
                # Do text replacement
                $answerCopy{text} = $self->getTemplatedText($answerCopy{text}, \%templateValues);

                # Add any extra fields we want..
                $answerCopy{id} = $self->answerId($sIndex, $qIndex, $aIndex);
                
                push @{ $questionCopy{answers} }, \%answerCopy;
                
                $aIndex++;
            }
        } else {
            for my $aIndex ( aIndexes($address) ) {
                my %answerCopy 
                    = %{  $self->survey->answer( [ $sIndex, $qIndex, $aIndex ] ) 
                        || $self->survey->newAnswer # in case the lookup fails, use a default answer
                        };

                # Do text replacement
                $answerCopy{text} = $self->getTemplatedText($answerCopy{text}, \%templateValues);

                # Add any extra fields we want..
                $answerCopy{id} = $self->answerId($sIndex, $qIndex, $aIndex);

                push @{ $questionCopy{answers} }, \%answerCopy;
            }
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
    my $sIndex = shift;
    
    return if !defined $sIndex;
    
    return $sIndex;
}

=head2 questionId

Convenience method to construct a Question Id from the given Section index and Question index.

The id is constructed by hyphenating the Section index and Question index.

=cut

sub questionId {
    my $self = shift;
    my ($sIndex, $qIndex) = @_;
    
    return if !defined $sIndex || !defined $qIndex;
     
    return "$sIndex-$qIndex";
}

=head2 answerId

Convenience method to construct an Answer Id from the given Section index, Question index and Answer index.

The id is constructed by hyphenating all three indices.

=cut

sub answerId {
    my $self = shift;
    my ($sIndex, $qIndex, $aIndex) = @_;
    
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

sub sIndex { $_[0][0] }

#-------------------------------------------------------------------

=head2 qIndex ($address)

Convenience sub to extract the question index from an address in the L<"surveyOrder"> array.
This method exists purely to improve code readability.
This method is identical to L<WebGUI::Asset::Wobject::Survey::SurveyJSON/qIndex>.

=cut

sub qIndex { $_[0][1] }

#-------------------------------------------------------------------

=head2 aIndexes ($address)

Convenience sub to extract the array of answer indices from an address in the L<"surveyOrder"> array.
This method exists purely to improve code readability.
Unlike sIndex and qIndex, this method is different to L<WebGUI::Asset::Wobject::Survey::SurveyJSON/aIndex>.
This is because the third element of the L<"surveyOrder"> address array ref in is an array of answer indices.

=cut

sub aIndexes {
    my $address = shift;
    
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

=head2 responseReport

Returns an array ref containing the current responses to the survey in a
format that can be written to the temporary report table (see 
L<WebGUI::Asset::Wobject::Survey::loadTempReportTable>.

The array ref contains a list of hashes with the section, question,
sectionName, questionName, questionComment, and an answer array ref. 
The answer array ref contains a list of hashes, with isCorrect (1 true, 0 false),
recorded value, and the id of the answer. 

=cut

sub responseReport {
    my $self = shift;

    my @report;
    for my $address ( @{ $self->surveyOrder } ) {
        my ( $sIndex, $qIndex ) = ( sIndex($address), qIndex($address) );
        my $section    = $self->survey->section($address);
        my $question   = $self->survey->question( [ $sIndex, $qIndex ] );
        my $questionId = $self->questionId( $sIndex, $qIndex );

        # Skip if this is a Section without a Question
        next unless defined $qIndex;

        # Multi-choice answers can have multiple responses per-question,
        # so make sure we look over all answers
        my @answer_responses;
        for my $aIndex ( aIndexes($address) ) {
            my $answerId = $self->answerId( $sIndex, $qIndex, $aIndex );
            my $answer = $self->survey->answer( [ $sIndex, $qIndex, $aIndex ] );

            # Massage each answer response and push it onto the list
            if ( my $response = clone $self->responses->{$answerId} ) {
                $response->{isCorrect} = $answer->{isCorrect} ? 1 : 0;
                $response->{id} = $aIndex;
                $response->{score} = $answer->{value};    # N.B. answer score is consistently misnamed 'value'
                push @answer_responses, $response;
            }
        }

        push @report,
            {
            section         => $sIndex,
            question        => $qIndex,
            sectionName     => $section->{variable},
            questionName    => $question->{variable},
            questionComment => $self->responses->{$questionId}->{comment},
            answers         => \@answer_responses
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
     # Answers entries contain: value (the recorded value), time and verbatim field.
     '0-0-0' => {
         value   => "recorded answer value",
         time    => time(),
         verbatim => "answer verbatim",
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
