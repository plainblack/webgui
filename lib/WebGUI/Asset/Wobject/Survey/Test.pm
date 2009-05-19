package WebGUI::Asset::Wobject::Survey::Test;

use strict;
use base qw/WebGUI::Crud/;
use WebGUI::International;
use Test::Deep::NoTest;
use JSON::PP;
use Params::Validate qw(:all);
Params::Validate::validation_options( on_fail => sub { WebGUI::Error::InvalidParam->throw( error => shift ) } );

=head1 NAME

Package WebGUI::Asset::Wobject::Survey::Test;

=head1 DESCRIPTION

Base class for Survey tests

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 crud_definition ( )

WebGUI::Crud definition for this class.

=head3 tableName

Survey_test

=head3 tableKey

testId

=head3 sequenceKey

assetId, e.g. each Survey instance has its own sequence of tests.

=head3 properties

=head4 assetId

Identifies the Survey instance.

=head4 name

A name for the test

=head4 test

The test spec

=cut

sub crud_definition {
    my ( $class, $session ) = @_;
    my $definition = $class->SUPER::crud_definition($session);
    $definition->{tableName}   = 'Survey_test';
    $definition->{tableKey}    = 'testId';
    $definition->{sequenceKey} = 'assetId';
    my $properties = $definition->{properties};
    my $i18n       = WebGUI::International->new($session);
    $properties->{assetId} = {
        fieldType    => 'hidden',
        defaultValue => undef,
    };
    $properties->{name} = {
        fieldType    => 'text',
        label        => $i18n->get( 'test name', 'Asset_Survey' ),
        hoverHelp    => $i18n->get( 'test name help', 'Asset_Survey' ),
        defaultValue => '',
    };
    $properties->{test} = {
        fieldType    => 'codearea',
        label        => $i18n->get( 'test spec', 'Asset_Survey' ),
        hoverHelp    => $i18n->get( 'test spec help', 'Asset_Survey' ),
        syntax       => 'js',
        defaultValue => <<END_SPEC,
[
{
    "name": "My Test",
    "test": {
        "variable1": "yes",
        "next": "section2",
    },
},
]
END_SPEC
    };
    return $definition;
}

=head2 run

Run this test. Returns TAP in a hashref.

=cut

sub run {
    my $self = shift;
    my $session = $self->session;
    
    if ( !$session->config->get('enableSurveyExpressionEngine') ) {
        return { tap => 'Bail Out! enableSurveyExpressionEngine config option disabled' };
    }
    
    my $spec = $self->get('test') 
        or return { tap => "Bail Out! Test spec undefined" };
    
    # Use JSON::PP rather than JSON::XS so that we can use things like allow_barekey
    my $json = JSON::PP->new->relaxed->allow_barekey->allow_singlequote;
    eval {
        $spec = $json->decode($spec); # N.B. This will change to from_json when JSON upgraded to >=2.14
    };
    
    if ($@) {
        my $error = $@;
#        $error =~ s/(.*?) at .*/$1/s;    # don't reveal too much
        return { tap => "Bail Out! Invalid test spec: $error" };
    }
    
    my $assetId = $self->get('assetId');
    my $survey = WebGUI::Asset::Wobject::Survey->new($session, $assetId);
    if (!$survey || !$survey->isa('WebGUI::Asset::Wobject::Survey') ) {
        return { tap => "Bail Out! Unable to instantiate Survey using assetId: $assetId" };
    }
    
    # Remove existing responses for current user
    $self->session->db->write( 'delete from Survey_response where assetId = ? and userId = ?',
        [ $self->getId, $self->session->user->userId() ] );
    
    # disable cookies so that test code doesn't die
    $survey->responseIdCookies(0); 
    
    # Start a response as current user
    my $responseId = $survey->responseId($self->session->user->userId)
        or return { tap => "Bail Out! Unable to start survey response" };
    
    # Prepare the ingredients..
    my $rJSON = $survey->responseJSON 
        or return { tap => "Bail Out! Unable to get responseJSON" };
        
    my %validTargets = map { $_ => 1 } @{$survey->surveyJSON->getGotoTargets};
    my $surveyOrder = $rJSON->surveyOrder;
    my $surveyOrderIndexByVariableName = $rJSON->surveyOrderIndexByVariableName;
    
    # Run the tests
    my $testCount = 0;
    my @tap;
    for my $item (@$spec) {
        $self->_resetResponses($rJSON);
        $rJSON->lastResponse(-1);
        my $name = $item->{name};
        if (my $args = $item->{test} ) {
            push @tap, $self->_test( { 
                responseJSON => $rJSON, 
                surveyOrder =>  $surveyOrder,
                surveyOrderIndexByVariableName => $surveyOrderIndexByVariableName,
                args => $args,
                testCount_ref => \$testCount,
                name => $name,
            } );
        } 
        elsif (my $args = $item->{test_mc} ) {
            push @tap, $self->_test_mc( { 
                responseJSON => $rJSON, 
                surveyOrder =>  $surveyOrder,
                surveyOrderIndexByVariableName => $surveyOrderIndexByVariableName,
                args => $args,
                testCount_ref => \$testCount,
                name => $name,
            } );
        } 
        elsif (my $args = $item->{sequence} ) {
            push @tap, $self->_sequence( { 
                responseJSON => $rJSON, 
                surveyOrder =>  $surveyOrder,
                surveyOrderIndexByVariableName => $surveyOrderIndexByVariableName,
                args => $args,
                testCount_ref => \$testCount,
                name => $name,
            } );
        } 
        else {
            push @tap, "Bail Out! Invalid test definition";
        }
    }
    
    my $tap = "1..$testCount\n";
    $tap .= join "\n", @tap;
    return { tap => "$tap" };
}

=head2 _resetResponses

Private convenience sub to carry out the task of resetting a response between tests

=cut

sub _resetResponses {
    my ($self, $rJSON) = @_;
    $rJSON->responses( {} );
    $rJSON->lastResponse(-1);
}

=head2 _test

Private sub. Triggered when a test spec requests "test".

In the test spec, keys without special meaning are assumed to be question/section vars.
The "next" key is special, indicating what section/question you expect the survey to
end up at after responses have been submitted.

=cut

sub _test {
    my $self = shift;
    my %opts = validate(@_, { 
        responseJSON => { isa => 'WebGUI::Asset::Wobject::Survey::ResponseJSON' },
        surveyOrder => { type => ARRAYREF },
        surveyOrderIndexByVariableName => { type => HASHREF },
        testCount_ref => { type => SCALARREF },
        args => { type => HASHREF },
        name => 0,
    });
    
    # assemble the top-level ingredients..
    my $rJSON = $opts{responseJSON};
    my $surveyOrder = $opts{surveyOrder};
    my $surveyOrderIndexByVariableName = $opts{surveyOrderIndexByVariableName};
    my $args = $opts{args};
    my $name = $opts{name};
    my $testCount = ++${$opts{testCount_ref}};
    
    # ..and the test-specific arguments
    my ($next, $tagged, $score, $page, $setup ) = @{$args}{qw(next tagged score page setup)};
    delete $args->{next};
    delete $args->{tagged};
    delete $args->{score};
    delete $args->{page};
    delete $args->{setup};
    # n.b. everything left in %args assumed to be variable => answer_spec
    
    if (!$next && !$tagged && !$score && !$page && !$setup && scalar(%$args) == 0 ) {
        return fail($testCount, "Nothing to do");
    }
    
    if ($page) {
        # Recursively call ourselves (ignoring the returned TAP), so that rJSON gets
        # updated with responses, simulating the page spec happening in the past
        my $fakeTestCount = 0;
        $self->_test( { 
            responseJSON => $rJSON, 
            surveyOrder => $surveyOrder, 
            surveyOrderIndexByVariableName => $surveyOrderIndexByVariableName,
            testCount_ref => \$fakeTestCount,
            args => $page,
        } );
    }
    
    # Setup any fake data the user wants prior to the test
    if ($setup && ref $setup eq 'HASH') {
        my %existingTags = %{$rJSON->tags};
        
        # Process tags
        # N.B. Make sure we add to existing tags instead of overwriting
        if (ref $setup->{tag} eq 'HASH') {
             # already a hash, so store it right away
            $rJSON->tags( {%existingTags, %{$setup->{tag}} });
        } elsif (ref $setup->{tag} eq 'ARRAY') {
            # turn array into hash before storing it
            my $tags;
            for my $tag (@{$setup->{tag}}) {
                if (ref $tag eq 'HASH') {
                    # Individual item is a single key/value hash
                    my ($key, $value) = %$tag;
                    $tags->{$key} = $value;
                } else {
                    # Individual item is a string, default to boolean truth flag
                    $tags->{$tag} = 1; # default to 1
                }
            }
            $rJSON->tags( {%existingTags, %$tags });
        }
    }
    
    # Record responses
    my $responses = {};
    my $lowestIndex;
    
    while ( my ( $variable, $spec ) = each %$args ) {
        my $index = $surveyOrderIndexByVariableName->{$variable};
        my $address = $surveyOrder->[$index];
        my $question = $rJSON->survey->question($address);
        my $questionType = $question->{questionType};
        
        # Keep track of lowest index (to work out what survey page we should test on)
        $lowestIndex = $index if (!defined $lowestIndex || $index < $lowestIndex); 
        
        # Goal now is to figure out what answer(s) we are supposed to record
        if (!defined $spec) {
            $self->session->log->debug("Spec undefined, assuming that means ignore answer value");
        } 
        elsif ( $questionType eq 'Text' || $questionType eq 'Number' ) {
            # Assume spec is raw value to record in the single answer
            $responses->{"$address->[0]-$address->[1]-0"} = $spec;
        } elsif ( $questionType eq 'Year Month' ) {
            if ($spec !~ m/\d{4} \w+/) {
                return fail($testCount, "Invalid input for Year Month question type", "Got: $spec\nExpected: YYYY Month");
            }
            $self->session->log->debug("Recording Year Month value: $spec");
            $responses->{"$address->[0]-$address->[1]-0"} = $spec;
        }
        else {
            # Assume spec is the raw text of the answer we want
            my $answer;
            my $aIndex = 0;
            my $answerAddress;
            # Iterate over all answers to find the matching
            for my $a (@{$question->{answers}}) {
                if ($a->{text} =~ m/\Q$spec\E/i) {
                    $answerAddress = "$address->[0]-$address->[1]-$aIndex";
                    $answer = $a;
                    last;
                }
                $aIndex++;
            }
            if (!$answer) {
                return fail($testCount, "determine answer for $variable", "No answers matched text: '$spec'");
            }
            $self->session->log->debug("Recording $variable ($answerAddress) => $answer->{recordedAnswer}");
            $responses->{$answerAddress} = $answer->{recordedAnswer};
        }
    }
    
    my ($pageSection, $pageQuestion);
    if (defined $lowestIndex) {
        $rJSON->nextResponse($lowestIndex);
        $pageSection = $rJSON->survey->section($surveyOrder->[$lowestIndex]);
        $pageQuestion = $rJSON->survey->question($surveyOrder->[$lowestIndex]);
    }
    
    if (!$name) {
        $name = "Checking ";
        my %what = ( next => $next, tagged => $tagged, score => $score );
        $name .= join ' and ', (grep {$what{$_}} qw(next tagged score));
        $name .= " on page containing Section $pageSection->{variable}" if $pageSection;
        $name .= " Question $pageQuestion->{variable}" if $pageQuestion;
    }
    
    return $self->_recordResponses( { 
        responseJSON => $rJSON, 
        responses => $responses,
        surveyOrder => $surveyOrder,
        surveyOrderIndexByVariableName => $surveyOrderIndexByVariableName, 
        next => $next,
        tagged => $tagged,
        score => $score,
        testCount => $testCount,
        name => $name,
    });
}

=head2 _test_mc

Private sub. Triggered when a test spec requests "test_mc".

In the test spec, the first item is a section/question, and all remaining items are definitions
of what you expect to happen next.

=cut

sub _test_mc {
    my $self = shift;
        my %opts = validate(@_, { 
        responseJSON => { isa => 'WebGUI::Asset::Wobject::Survey::ResponseJSON' },
        surveyOrder => { type => ARRAYREF },
        surveyOrderIndexByVariableName => { type => HASHREF },
        testCount_ref => { type => SCALARREF },
        args => { type => ARRAYREF },
        name => 0,
    });
    
    # assemble the top-level ingredients..
    my $rJSON = $opts{responseJSON};
    my $surveyOrder = $opts{surveyOrder};
    my $surveyOrderIndexByVariableName = $opts{surveyOrderIndexByVariableName};
    my $args = $opts{args};
    
    # the first item is the section/question
    my $variable = shift @$args;
    # ..and all remaining items are the specs
    my @specs = @$args;
    
    my $index = $surveyOrderIndexByVariableName->{$variable};
    my $address = $surveyOrder->[$index];
    my $question = $rJSON->survey->question($address);
    my $answers = $question->{answers};
    
    # Each spec is a sub-test, one per answer in the question
    my @tap;
    my $aIndex = 0;
    for my $spec (@specs) {
        
        # Reset responses between sub-tests
        $self->_resetResponses($rJSON);
        
        # Test runs from $variable
        $rJSON->nextResponse($index);
        
        my $responses = {};
        my $testCount = ++${$opts{testCount_ref}};
        
        my ($next, $tagged, $score);
        if (ref $spec eq 'HASH') {
            ($next, $tagged, $score) = @{$spec}{qw(next tagged score)};
        } else {
            $next = $spec;
        }
        
        my $answerAddress = "$address->[0]-$address->[1]-$aIndex";
        my $answer = $answers->[$aIndex];
        my $recordedAnswer = $answer->{recordedAnswer};
        $responses->{$answerAddress} = $recordedAnswer;

        my $name = $opts{name}; # get this fresh for every subtest
        if ($name) {
            # Add some extra diagnostic text since single test_mc generates multiple sub-tests
            $name .= " mc answer "  . ($aIndex + 1);
        } else {
            $name = "Checking ";
            my %what = ( next => $next, tagged => $tagged, score => $score );
            $name .= join ' and ', (grep {$what{$_}} qw(next tagged score));
            $name .= " for $variable mc answer " . ($aIndex + 1);
        }
        
        $self->session->log->debug("Recording answer for mc question $variable at index $aIndex ($answerAddress) => $recordedAnswer");
        push @tap, $self->_recordResponses( { 
            responseJSON => $rJSON, 
            responses => $responses, 
            surveyOrder => $surveyOrder,
            surveyOrderIndexByVariableName => $surveyOrderIndexByVariableName, 
            next => $next,
            testCount => $testCount,
            name => $name,
            tagged => $tagged,
            score => $score,
        });
        
        $aIndex++;
    }
    return @tap;
}

=head2 _test

Private sub. Triggered when a test spec requests "sequence".

=cut

sub _sequence {
    my $self = shift;
    my %opts = validate(@_, { 
        responseJSON => { isa => 'WebGUI::Asset::Wobject::Survey::ResponseJSON' },
        surveyOrder => { type => ARRAYREF },
        surveyOrderIndexByVariableName => { type => HASHREF },
        testCount_ref => { type => SCALARREF },
        args => { type => HASHREF },
        name => 0,
    });
    
    # assemble the top-level ingredients..
    my $rJSON = $opts{responseJSON};
    my $surveyOrder = $opts{surveyOrder};
    my $surveyOrderIndexByVariableName = $opts{surveyOrderIndexByVariableName};
    my $args = $opts{args};
    my $name = $opts{name};
    my $testCount = ++${$opts{testCount_ref}};
    
    # n.b. everything in %args assumed to be variable => spec
    
    while ( my ( $variable, $spec ) = each %$args ) {
        my $index = $surveyOrderIndexByVariableName->{$variable};
        my $address = $surveyOrder->[$index];
        my $question = $rJSON->survey->question($address);
        my $questionType = $question->{questionType};
        
        # Iterate over all answers
        my ($recordedAnswer, $score);
        my $recordedAnswerDelta 
            = $spec->{recordedAnswer} =~ m/desc/  ? -1 
            : $spec->{recordedAnswer} =~ m/asc/   ?  1 
            : $spec->{recordedAnswer} =~ m/cons/  ?  0
            : undef;
        
        my $scoreDelta 
            = $spec->{score} =~ m/desc/          ? -1 
            : $spec->{score} =~ m/asc/           ?  1 
            : $spec->{score} =~ m/cons/          ?  0
            : undef;
        
        my $aNum = 0;
        for my $a (@{$question->{answers}}) {
            $aNum++;
            
            if (defined $recordedAnswerDelta && defined $recordedAnswer) {
                my $expect = $recordedAnswer + $recordedAnswerDelta;
                if ( $expect != $a->{recordedAnswer}) {
                    return fail($testCount, "$variable answer index $aNum recordedAnswer not in sequence", "Got: $a->{recordedAnswer}\nExpected: $expect");
                }
            }
            
            if (defined $scoreDelta && defined $score) {
                my $expect = $score + $scoreDelta;
                if ( $expect != $a->{value}) {
                    return fail($testCount, "$variable answer index $aNum score not in sequence",  "Got: $a->{value}\nExpected: $expect");
                }
            }
            
            $recordedAnswer = $a->{recordedAnswer};
            $score = $a->{value};
        }
    }
    
    return pass($testCount, "Valid sequences");
}

=head2 _recordResponses

Private sub. Records responses and checks that you end up where you expect

=cut

sub _recordResponses {
    my $self = shift;
    my %opts = validate(@_, { 
        responseJSON => { isa => 'WebGUI::Asset::Wobject::Survey::ResponseJSON' },
        responses => { type => HASHREF },
        surveyOrder => { type => ARRAYREF },
        surveyOrderIndexByVariableName => { type => HASHREF },
        next => 0,
        testCount => 1,
        name => 0,
        tagged => 0,
        score => 0,
    });
    
    # assemble the top-level ingredients..
    my $rJSON = $opts{responseJSON};
    my $responses = $opts{responses};
    my $surveyOrder = $opts{surveyOrder};
    my $surveyOrderIndexByVariableName = $opts{surveyOrderIndexByVariableName};
    my $next = $opts{next};
    my $testCount = $opts{testCount};
    my $name = $opts{name};
    my $tagged = $opts{tagged};
    my $score = $opts{score};
    
    $rJSON->recordResponses($responses);

    # Check where we end up, if asked
    if ($next) {
        my $nextResponse = $rJSON->nextResponse;
        my $nextAddress = $surveyOrder->[$nextResponse];
        my $nextSection = $rJSON->survey->section($nextAddress);
        my $nextQuestion = $rJSON->survey->question($nextAddress);
        # Get the lowest section surveyOrderIndex from lookup
        my $got;
        my $svar = $nextSection->{variable};
        my $qvar = $nextQuestion->{variable};
        if ($surveyOrderIndexByVariableName->{$svar} == $nextResponse) {
            $got = "'$svar' (<-- a section)";
            $got .= " and '$qvar' (<-- a question)" if $qvar;
        } elsif ($qvar) {
            $got = "'$qvar' (<-- a question)";
        } else {
            $got = 'Unknown!';
        }
        my $expectedNextResponse = $surveyOrderIndexByVariableName->{$next};
        if ($nextResponse != $expectedNextResponse) {
            return fail($testCount, $name, <<END_WHY);
Compared next section/question
   got : $got
expect : '$next'
END_WHY
        }
    }
    
    # Check tagged, if asked
    
    # Since tags are often boolean flags, allow them to optionally be specified as an array
    if ($tagged && ref $tagged eq 'ARRAY') {
        my $currentTags = $rJSON->tags;
        for my $tag (@$tagged) {
            my ($tagKey, $tagValue);
            if (ref $tag eq 'HASH') {
                ($tagKey, $tagValue) = %$tag; # individual tag spec only has one key and one value
            } else {
                ($tagKey, $tagValue) = ($tag, 1); # defaults to 1 (boolean truth flag)
            }
            if (!exists $currentTags->{$tagKey}) {
                 $self->session->log->debug("Tag not found: $tagKey");
                return fail($testCount, $name, "Tag not found: $tagKey");
            }
            my $currentTagValue = $currentTags->{$tagKey};
            if ($currentTagValue != $tagValue) {
                $self->session->log->debug("Incorrect tag value: $currentTagValue != $tagValue");
                return fail($testCount, $name, <<END_WHY);
Compared tag '$tagKey'
   got : '$currentTagValue'
expect : '$tagValue'
END_WHY
            }
        }
    }
    
    # Alternatively, tags can be a hash
    if ($tagged && ref $tagged eq 'HASH') {
        my $currentTags = $rJSON->tags;
        while (my ($tagKey, $tagValue) = each %$tagged) {
            my $currentTagValue = $currentTags->{$tagKey};
            if ($currentTagValue != $tagValue) {
                $self->session->log->debug("Incorrect tag value: $currentTagValue != $tagValue");
                return fail($testCount, $name, <<END_WHY);
Compared tag '$tagKey'
   got : '$currentTagValue'
expect : '$tagValue'
END_WHY
            }
        }
    }
    
    # Check score, if asked
    if ($score && ref $score eq 'HASH') {
        my $currentScores = $rJSON->responseScoresByVariableName;
        while (my ($scoreKey, $scoreValue) = each %$score) {
            my $currentScore = $currentScores->{$scoreKey};
            if ($currentScore != $scoreValue) {
                $self->session->log->debug("Incorrect score: $currentScore != $scoreValue");
                return fail($testCount, $name, <<END_WHY);
Compared score '$scoreKey'
   got : '$currentScore'
expect : '$scoreValue'
END_WHY
            }
        }
    }
    
    return pass($testCount, $name);
}

sub pass {
    my ($testCount, $name, $extra) = @_;
    my $out = $name ? "ok $testCount - $name" : "ok $testCount";
    if ($extra) {
        $extra =~ s/^/# /gm;
        $out .= "\n$extra";
    }
    return $out;
}

sub fail {
    my ($testCount, $name, $extra) = @_;
    my $out = $name ? "not ok $testCount - $name" : "not ok $testCount";
    if ($extra) {
        chomp($extra);
        $extra =~ s/^/# /gm;
        $out .= "\n$extra";
    }
    return $out;
}

1;
