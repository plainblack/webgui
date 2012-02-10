package WebGUI::Asset::Wobject::Survey::Test;

use strict;
use Test::Deep::NoTest qw/eq_deeply/;
use Moose;
use WebGUI::Definition::Crud;
extends qw/WebGUI::Crud/;
define tableName   => 'Survey_test';
define tableKey    => 'testId';
define sequenceKey => 'assetId';
has testId => (
    required => 1,
    is       => 'ro',
);
property assetId => (
        label        => 'assetId', 
        fieldType    => 'hidden',
        default      => undef,
         );
property name => (
        fieldType    => 'text',
        label        => [ 'test name', 'Asset_Survey' ],
        hoverHelp    => [ 'test name help', 'Asset_Survey' ],
        default      => '',
         );
property test => (
        fieldType    => 'codearea',
        label        => [ 'test spec', 'Asset_Survey' ],
        hoverHelp    => [ 'test spec help', 'Asset_Survey' ],
        syntax       => 'js',
        default      => <<END_SPEC,
[
{
    "name": "My Test",
    "test": {
        "variable1": "yes",
        "next": "section2",
         }
},
]
END_SPEC
         );



use WebGUI::International;
use JSON::PP;
use Data::Dumper;
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

=head2 run

Run this test. Returns TAP in a hashref.

=cut

sub run {
    my $self = shift;
    my %opts = validate(@_, { responseId => 0 });
    my $session = $self->session;
    
    if ( !$session->config->get('enableSurveyExpressionEngine') ) {
        return { tap => 'Bail Out! enableSurveyExpressionEngine config option disabled' };
    }
    
    my $spec = $self->test 
        or return { tap => "Bail Out! Test spec undefined" };
    
    # Use JSON::PP rather than JSON::XS so that we can use things like allow_barekey
    my $json = JSON::PP->new->relaxed->allow_barekey->allow_singlequote;
    eval {
        $spec = $json->decode($spec); # N.B. This will change to from_json when JSON upgraded to >=2.14
#        $spec = from_json($spec, { relaxed => 1} );
    };
    
    if ($@) {
        my $error = $@;
#        $error =~ s/(.*?) at .*/$1/s;    # don't reveal too much
        return { tap => "Bail Out! Invalid test spec: $error" };
    }
    
    my $assetId = $self->assetId;
    my $survey = WebGUI::Asset::Wobject::Survey->newById($session, $assetId);
    if (!$survey || !$survey->isa('WebGUI::Asset::Wobject::Survey') ) {
        return { tap => "Bail Out! Unable to instantiate Survey using assetId: $assetId" };
    }
    
    my $responseId = $opts{responseId};
    
    # Remove existing responses for current user
    if (!$responseId) {
        $self->session->db->write( 'delete from Survey_response where assetId = ? and userId = ?',
            [ $self->getId, $self->session->user->userId() ] );
        
        # Start a response as current user
        $responseId = $survey->responseId( { userId => $self->session->user->userId } )
            or return { tap => "Bail Out! Unable to start survey response" };
    }
    
    # Prepare the ingredients..
    my $rJSON = $survey->responseJSON 
        or return { tap => "Bail Out! Unable to get responseJSON" };
    
    # Run the tests
    my $testCount = 0;
    my @tap;
    for my $item (@$spec) {
        $rJSON->reset( {preserveSurveyOrder => 1});
        my $name = $item->{name};
        my $setup = $item->{setup};
        
        # N.B. we pass setup to individual test rather than running it for test, because 
        # some test subs reset rJSON between sub-tests
        
        my $args;
        if ($args = $item->{test} ) {
            push @tap, $self->_test( { 
                responseJSON => $rJSON, 
                args => $args,
                testCount_ref => \$testCount,
                name => $name,
                setup => $setup,
            } );
        } 
        elsif ($args = $item->{test_mc} ) {
            push @tap, $self->_test_mc( { 
                responseJSON => $rJSON, 
                args => $args,
                testCount_ref => \$testCount,
                name => $name,
                setup => $setup,
            } );
        } 
        elsif ($args = $item->{sequence} ) {
            push @tap, $self->_sequence( { 
                responseJSON => $rJSON, 
                args => $args,
                testCount_ref => \$testCount,
                name => $name,
            } );
        } 
        elsif ($args = $item->{defined} ) {
            push @tap, $self->_defined( { 
                responseJSON => $rJSON, 
                args => $args,
                testCount_ref => \$testCount,
                name => $name,
            } );
        } 
        else {
            push @tap, "Bail Out! Invalid test definition";
        }
    }
    
    $survey->persistResponseJSON;
    
    my $tap = "1..$testCount\n";
    $tap .= join "\n", @tap;
    return { tap => "$tap" };
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
        testCount_ref => { type => SCALARREF },
        args => { type => HASHREF },
        name => 0,
        setup => 1,
    });
    
    # assemble the top-level ingredients..
    my $rJSON = $opts{responseJSON};
    my $args = $opts{args};
    my $name = $opts{name};
    my $setup = $opts{setup} || $args->{setup}; # Setup option can also appear inside of test definition
    my $testCount = ++${$opts{testCount_ref}};
    
    # ..and the test-specific arguments
    my ($next, $tagged, $score, $page) = @{$args}{qw(next tagged score page)};
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
            testCount_ref => \$fakeTestCount,
            args => $page,
            setup => $setup,
        } );
    }
    
    # Run setup
    $self->_setup( { responseJSON => $rJSON, setup => $setup } );
    
    # Record responses
    my $responses = {};
    my $lowestIndex;
    my $surveyOrder = $rJSON->surveyOrder;
    my $multipleChoiceTypes = $rJSON->survey->multipleChoiceTypes;
    delete $multipleChoiceTypes->{Tagged}; # Don't treat Tagged as mc question type
    while ( my ( $variable, $spec ) = each %$args ) {
        my $index = $rJSON->surveyOrderIndex($variable);
        return fail($testCount, "Invalid question variable (1): $variable") if !defined $index;
        my $address = $surveyOrder->[$index];
        my $question = $rJSON->survey->question($address);
        return fail($testCount, "Invalid question variable (2): $variable") if !defined $question;
        my $questionType = $question->{questionType};
        
        # Keep track of lowest index (to work out what survey page we should test on)
        $lowestIndex = $index if (!defined $lowestIndex || $index < $lowestIndex); 
        
        # Goal now is to figure out what answer(s) we are supposed to record
        if (!defined $spec) {
            $self->session->log->debug("Spec undefined, assuming that means ignore answer value");
        } elsif (exists $multipleChoiceTypes->{$questionType}) {
            # Multi-choice question, so spec is the raw text of the answer we want
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
            $responses->{$answerAddress} = 1;
        } elsif ( $questionType eq 'Year Month' ) {
            # Handle YearMonth delicately
            if ($spec !~ m/\d{4} \w+/) {
                return fail($testCount, "Invalid input for Year Month question type", "got: $spec\nExpected: YYYY Month");
            }
            $responses->{"$address->[0]-$address->[1]-0"} = $spec;
        } else {
            # Assume spec is raw value to record in the 0th answer
            $responses->{"$address->[0]-$address->[1]-0"} = $spec;
        }
    }
    
    my ($pageSection, $pageQuestion);
    if (defined $lowestIndex) {
        my $address = $surveyOrder->[$lowestIndex] or return fail($testCount, "Unable to determine address from lowest index: $lowestIndex");
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
        next => $next,
        tagged => $tagged,
        score => $score,
        testCount => $testCount,
        name => $name,
    });
}

=head2 _setup

Private sub. Used to setup tags etc.. on a ResponseJSON instance prior to tests being run.

=cut

sub _setup {
    my $self = shift;
    my %opts = validate(@_, { 
        responseJSON => { isa => 'WebGUI::Asset::Wobject::Survey::ResponseJSON' },
        setup => 1,
    });
    
    my ($rJSON, $setup) = @opts{'responseJSON', 'setup'};

    # Setup any fake data the user wants prior to the test
    if ($setup && ref $setup eq 'HASH') {
        # Process tags
        my %tags;
        if (ref $setup->{tag} eq 'HASH') {
            %tags = %{$setup->{tag}};
        } elsif (ref $setup->{tag} eq 'ARRAY') {
            for my $tag (@{$setup->{tag}}) {
                if (ref $tag eq 'HASH') {
                    # Individual item is a single key/value hash
                    my ($key, $value) = %$tag;
                    $tags{$key} = $value;
                } else {
                    # Individual item is a string, default to boolean truth flag
                    $tags{$tag} = 1; # default to 1
                }
            }
        }
        # N.B. Make sure we add to existing tags instead of overwriting
        @{$rJSON->tags}{keys %tags} = values %tags;
    }
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
        testCount_ref => { type => SCALARREF },
        args => { type => ARRAYREF },
        name => 0,
        setup => 1,
    });
    
    # assemble the top-level ingredients..
    my $rJSON = $opts{responseJSON};
    my $args = $opts{args};
    my $setup = $opts{setup};
    
    # the first item is the section/question
    my $variable = shift @$args;
    # ..and all remaining items are the specs
    my @specs = @$args;
    
    my $surveyOrder = $rJSON->surveyOrder;
    my $index = $rJSON->surveyOrderIndex($variable);
    return fail(-1, "Invalid question variable (3): $variable") if !defined $index;
    my $address = $surveyOrder->[$index];
    my $question = $rJSON->survey->question($address);
    return fail(-1, "Invalid question variable (4): $variable") if !defined $question;
    my $answers = $question->{answers};
    
    # Each spec is a sub-test, one per answer in the question
    my @tap;
    my $aIndex = 0;
    for my $spec (@specs) {
        
        # Reset responses between sub-tests
        $rJSON->reset( {preserveSurveyOrder => 1});
        
        # Run setup (per-sub-test)
        $self->_setup( { responseJSON => $rJSON, setup => $setup } );
        
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
        $responses->{$answerAddress} = 1;

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
        
        $self->session->log->debug("Choosing mc question $variable answer index $aIndex ($answerAddress)");
        push @tap, $self->_recordResponses( { 
            responseJSON => $rJSON, 
            responses => $responses, 
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
        testCount_ref => { type => SCALARREF },
        args => { type => HASHREF },
        name => 0,
    });
    
    # assemble the top-level ingredients..
    my $rJSON = $opts{responseJSON};
    my $args = $opts{args};
    my $name = $opts{name} || 'Valid sequences';
    my $testCount = ++${$opts{testCount_ref}};
    
    # n.b. everything in %args assumed to be variable => spec
    my $surveyOrder = $rJSON->surveyOrder;
    while ( my ( $variable, $spec ) = each %$args ) {
        my $index = $rJSON->surveyOrderIndex($variable);
        return fail($testCount, "Invalid question variable (5): $variable") if !defined $index;
        my $address = $surveyOrder->[$index];
        my $question = $rJSON->survey->question($address);
        return fail($testCount, "Invalid question variable (6): $variable") if !defined $question;
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
                    return fail($testCount, "$variable answer index $aNum recordedAnswer not in sequence", "got: $a->{recordedAnswer}\nExpected: $expect");
                }
            }
            
            if (defined $scoreDelta && defined $score) {
                my $expect = $score + $scoreDelta;
                if ( $expect != $a->{value}) {
                    return fail($testCount, "$variable answer index $aNum score not in sequence",  "got: $a->{value}\nExpected: $expect");
                }
            }
            
            $recordedAnswer = $a->{recordedAnswer};
            $score = $a->{value};
        }
    }
    
    return pass($testCount, $name);
}

=head2 _defined

Private sub. Triggered when a test spec requests "defined".

=cut

sub _defined {
    my $self = shift;
    my %opts = validate(@_, { 
        responseJSON => { isa => 'WebGUI::Asset::Wobject::Survey::ResponseJSON' },
        testCount_ref => { type => SCALARREF },
        args => { type => HASHREF },
        name => 0,
    });
    
    # assemble the top-level ingredients..
    my $rJSON = $opts{responseJSON};
    my $args = $opts{args};
    my $name = $opts{name} || 'Defined';
    my $testCount = ++${$opts{testCount_ref}};
    
    # n.b. everything in %args assumed to be regex => spec
    
    while ( my ( $regex, $spec ) = each %$args ) {
        my $r = qr/$regex/;
        for my $question (@{$rJSON->survey->questions}) {
            my $variable = $question->{variable};
            if ($variable =~ $r) {
                # Currently only supports answer specs
                my $answerSpec = $spec->{answer};
                my $aNum = 0;
                for my $answer (@{$question->{answers}}) {
                    $aNum++;
                    for my $property (@$answerSpec) {
                        if (!defined $answer->{$property} || $answer->{$property} =~ m/^\s*$/) {
                            return fail($testCount, "$variable answer number $aNum property $property not defined",  "got: '$answer->{$property}'");
                        }
                    }
                }
            }
        }
    }
    
    return pass($testCount, $name);
}

=head2 _recordResponses

Private sub. Records responses and checks that you end up where you expect

=cut

sub _recordResponses {
    my $self = shift;
    my %opts = validate(@_, { 
        responseJSON => { isa => 'WebGUI::Asset::Wobject::Survey::ResponseJSON' },
        responses => { type => HASHREF },
        next => 0,
        testCount => 1,
        name => 0,
        tagged => 0,
        score => 0,
    });
    
    # assemble the top-level ingredients..
    my $rJSON = $opts{responseJSON};
    my $responses = $opts{responses};
    my $next = $opts{next};
    my $testCount = $opts{testCount};
    my $name = $opts{name};
    my $tagged = $opts{tagged};
    my $score = $opts{score};
    
    $rJSON->recordResponses($responses);
    my $surveyOrder = $rJSON->surveyOrder;
    
    # Check where we end up, if asked
    if ($next) {
        my $nextResponse = $rJSON->nextResponse;
        my $nextAddress = $surveyOrder->[$nextResponse];
        if ($next ne 'SURVEY_END' && !defined $nextAddress) {
            return fail($testCount, $name, <<END_WHY);
Compared next section/question
   got : Survey finished
expect : '$next'
END_WHY
        }
        if ($next eq 'SURVEY_END' && !defined $nextAddress) {
            $self->session->log->debug("SURVEY_END matched correctly");
        } else {
            my $nextSection = $rJSON->survey->section($nextAddress);
            my $nextQuestion = $rJSON->survey->question($nextAddress);
            # Get the lowest section surveyOrderIndex from lookup
            my $got;
            my $svar = $nextSection->{variable};
            my $qvar = $nextQuestion->{variable};
            if ($rJSON->surveyOrderIndex($svar) == $nextResponse) {
                $got = "'$svar' (<-- a section)";
                $got .= " and '$qvar' (<-- a question)" if $qvar;
            } elsif ($qvar) {
                $got = "'$qvar' (<-- a question)";
            } else {
                $got = 'Unknown!';
            }
            my $expectedNextResponse = $rJSON->surveyOrderIndex($next);
            if ($nextResponse != $expectedNextResponse) {
                return fail($testCount, $name, <<END_WHY);
Compared next section/question
   got : $got
expect : '$next'
END_WHY
            }
        }
    }
    
    # Check tagged, if asked
    local $Data::Dumper::Sortkeys = 1;
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
            
            if (!eq_deeply($currentTagValue, $tagValue)) {
                my $reason = "Compared tag: $tagKey\n" . get_differences($currentTagValue, $tagValue);
                $reason .= "\nIn..\ngot: " . Dumper($currentTagValue);
                $reason .= "\nexpect: " . Dumper($tagValue);
                $self->session->log->debug("Incorrect tag value: $reason");
                return fail($testCount, $name, $reason);
            }
        }
    }
    
    # Alternatively, tags can be a hash
    if ($tagged && ref $tagged eq 'HASH') {
        my $currentTags = $rJSON->tags;
        while (my ($tagKey, $tagValue) = each %$tagged) {
            my $currentTagValue = $currentTags->{$tagKey};
            if (!eq_deeply($currentTagValue, $tagValue)) {
                my $reason = "Compared tag: $tagKey\n" . get_differences($currentTagValue, $tagValue);
                $reason .= "\nIn..\ngot: " . Dumper($currentTagValue);
                $reason .= "\nexpect: " . Dumper($tagValue);
                $self->session->log->debug("Incorrect tag value: $reason");
                return fail($testCount, $name, $reason);
            }
        }
    }
    
    # Check score, if asked
    if ($score && ref $score eq 'HASH') {
        my $currentScores = $rJSON->responseScores( indexBy => 'variable' );
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

=head2 get_differences

Once L<Test::Deep::NoTest> > 0.1 is in the WRE, this sub can be replaced with
L<cmp_deeply> and L<deep_diag>.

=cut

sub get_differences {
    my ($a, $b) = @_;
    
    if (!ref $a && !ref $b) {
        return <<END_WHY;
   got : '$a'
expect : '$b'
END_WHY
    }
    if (ref $a ne ref $b) {
        return ref $a . ' does not match ' . ref $b;
    }
    if (ref $a eq 'ARRAY') {
        return "Array lengths differ" if @$a != @$b;
        for my $i (0 .. $#$a) {
            if (!eq_deeply($a->[$i], $b->[$i])) {
                return "Array item at index $i differs\n" . get_differences($a->[$i], $b->[$i]);
            }
        }
    }
    if (ref $a eq 'HASH') {
        for my $key (keys %$a, keys %$b) {
            if (!eq_deeply($a->{$key}, $b->{$key})) {
                return <<END_WHY
Hashes differ on element: $key
   got : '$a->{$key}'
expect : '$b->{$key}'
END_WHY
            }
        }
    }
    
}

#-------------------------------------------------------------------

=head2 pass 

Output TAP for a passing test.

=cut

sub pass {
    my ($testCount, $name, $extra) = @_;
    my $out = $name ? "ok $testCount - $name" : "ok $testCount";
    if ($extra) {
        $extra =~ s/^/# /gm;
        $out .= "\n$extra";
    }
    return $out;
}

#-------------------------------------------------------------------

=head2 fail 

Output TAP for a failing test, along with diagnostics.

=cut

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
