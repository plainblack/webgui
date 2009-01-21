package WebGUI::Asset::Wobject::Survey::SurveyJSON;

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

=cut

=head1 NAME

Package WebGUI::Asset::Wobject::Survey::SurveyJSON

=head1 DESCRIPTION

Helper class for WebGUI::Asset::Wobject::Survey.  It handles
serializing and deserializing JSON data, and manages the data for
the Survey.  This package is not intended to be used by any other
Asset in WebGUI.

=head2 Address Parameter

Most subroutines in this module accept an $address param. This param is an array ref that 
serves as a multidimensional index into the section/question/answer structure.

In general, the first element of the array is the section index, the second element is 
the question index, and the third element is the answer index. E.g. in its most general
form the array looks like:

 [section index, question index, answer index]

Most subroutines will not expect or require all three elements to be present. Often, the
subroutine will alter its behaviour based on how many elements you provide. Typically,
the subroutine will operate on the most specific element it can based on the amount of
information you provide. For example if you provide two elements, the subroutine will most
likely operate on the question indexed by:

 [section index, question index]

=cut

use strict;
use JSON;

# N.B. We're currently using Storable::dclone instead of Clone::clone
# because Colin uncovered some Clone bugs in Perl 5.10
#use Clone qw/clone/;
use Storable qw/dclone/;

# The maximum value of questionsPerPage is currently hardcoded here
my $MAX_QUESTIONS_PER_PAGE = 20;

=head2 new ( $json, $log )

Object constructor.

=head3 $json

A JSON string used to construct a new Perl object. The JSON string should
contain a hash made up of "survey" and "sections" keys.

=head3 $log

The session logger, from $session->log.  The class needs nothing else from the
session object.

=cut

sub new {
    my $class = shift;
    my $json  = shift;
    my $log   = shift;

    # Create skeleton object..
    my $self = {
        log      => $log,
        sections => [],
        survey   => {},
    };

    # Load json object if given..
    if ($json) {
        my $decoded_json = decode_json($json);
        $self->{sections} = $decoded_json->{sections} if defined $decoded_json->{sections};
        $self->{survey}   = $decoded_json->{survey}   if defined $decoded_json->{survey};
    }

    bless( $self, $class );

    # Initialise the survey data structure if empty..
    if ( $self->totalSections == 0 ) {
        $self->newObject( [] );
    }
    return $self;
}

=head2 freeze

Serialize this Perl object into a JSON string. The serialized object is made up of the survey and sections 
components of this object.

=cut

sub freeze {
    my $self = shift;
    return encode_json(
        {   sections => $self->{sections},
            survey   => $self->{survey},
        }
    );
}

=head2 newObject ( $address )

Add a new, empty Section, Question or Answer to the survey data structure.

Updates $address to point at the newly added object. Returns $address.

=head3 $address

See L<"Address Parameter">. New objects are always added (pushed) onto the end of the list of similar objects at the
given address. 

The number of elements in $address determines the behaviour:

=over 4

=item * 0 elements

Add a new section.

=item * 1 element

Add a new question to the indexed section.

=item * 2 elements

Add a new answer to the indexed question inside the indexed section.

=back

=cut

sub newObject {
    my $self    = shift;
    my $address = shift;
    
    # Figure out what to do by counting the number of elements in the $address array ref
    my $count = @$address;
    
    if ( $count == 0 ) { 
        # Add a new section to the end of the list of sections..
        push( @{ $self->sections }, $self->newSection() );
        
        # Update $address with the index of the newly created section
        $address->[0] = $self->totalSections - 1;
    }
    elsif ( $count == 1 ) {
        # Add a new question to the end of the list of questions in section located at $address
        push( @{ $self->questions($address) }, $self->newQuestion($address) );
        
        # Update $address with the index of the newly created question
        $address->[1] = $self->totalQuestions($address) - 1;
    }
    elsif ( $count == 2 ) {
        # Add a new answer to the end of the list of answers in section/question located at $address
        push( @{ $self->answers($address) }, $self->newAnswer($address) );
        
        # Update $address with the index of the newly created answer
        $address->[2] = $self->totalAnswers($address) - 1;
    }
    return $address;
}

=head2 getDragDropList ( $address )

Get a subset of the entire data structure.  It will be a list of all sections, along with
one question from a section with all its answers.

Returns an array reference.  Each element of the array will have a subset of section information as
a hashref.  This will contain two keys:

    {
        type => 'section',
        text => the section's title
    }, 

The questions for the referenced section will be included, like this:

    {
        type => 'question',
        text => the question's text
    }, 

All answers for the referenced question will also be in the array reference:

    {
        type => 'answer',
        text => the answer's text
    }, 

The sections, question and answer will be in depth-first order:

 section, section, section, question, answer, answer, answer, section, section

=head3 $address

See L<"Address Parameter">. Determines which question from a section will be listed, along with all
its answers.  Should ALWAYS have two elements since we want to address a question.

=cut

sub getDragDropList {
    my $self    = shift;
    my $address = shift;
    my @data;
    for ( my $sIndex = 0; $sIndex < $self->totalSections; $sIndex++ ) {
        push( @data, { text => $self->section( [$sIndex] )->{title}, type => 'section' } );
        if ( sIndex($address) == $sIndex ) {

            for ( my $qIndex = 0; $qIndex < $self->totalQuestions($address); $qIndex++ ) {
                push(
                    @data,
                    {   text => $self->question( [ $sIndex, $qIndex ] )->{text},
                        type => 'question'
                    }
                );
                if ( qIndex($address) == $qIndex ) {
                    for ( my $aIndex = 0; $aIndex < $self->totalAnswers($address); $aIndex++ ) {
                        push(
                            @data,
                            {   text => $self->answer( [ $sIndex, $qIndex, $aIndex ] )->{text},
                                type => 'answer'
                            }
                        );
                    }
                }
            }
        }
    }
    return \@data;
}

=head2 getObject ( $address )

Retrieve objects from the sections data structure by address.

=head3 $address

See L<"Address Parameter">. 

The number of elements in $address determines the behaviour:

=over 4

=item * 0 elements

Do Nothing

=item * 1 element

One element is enough to reference a section. Returns that section.

=item * 2 elements

Two elements are enough to reference a question inside a section. Returns that question.

=item * 3 elements

Three elements are enough to reference an answer, inside of a particular question in a section. 
Returns that answer.

=back

=cut

sub getObject {
    my ( $self, $address ) = @_;
    
    # Figure out what to do by counting the number of elements in the $address array ref
    my $count = @$address;
    
    return unless $count;
    
    if ( $count == 1 ) {
        return dclone $self->{sections}->[ sIndex($address) ];
    }
    elsif ( $count == 2 ) {
        return dclone $self->{sections}->[ sIndex($address) ]->{questions}->[ qIndex($address) ];
    }
    else {
        return dclone $self->{sections}->[ sIndex($address) ]->{questions}->[ qIndex($address) ]->{answers}
            ->[ aIndex($address) ];
    }
}

=head2 getSectionEditVars ( $address )

A dispatcher for getSectionEditVars, getQuestionEditVars and getAnswerEditVars.  Uses $address
to figure out what has been requested, then invokes that method and returns the results
from it.

=head3 $address

See L<"Address Parameter">. The number of elements determines whether edit vars are fetched for
sections, questions, or answers.

=cut

sub getEditVars {
    my ( $self, $address ) = @_;

    # Figure out what to do by counting the number of elements in the $address array ref
    my $count = @$address;
    
    if ( $count == 1 ) {
        return $self->getSectionEditVars($address);
    }
    elsif ( $count == 2 ) {
        return $self->getQuestionEditVars($address);
    }
    elsif ( $count == 3 ) {
        return $self->getAnswerEditVars($address);
    }
}

=head2 getGotoTargets

Generates the list of valid goto targets

=cut

sub getGotoTargets {
    my $self = shift;

    # Valid goto targets are all of the section variable names..
    my @section_vars = map {$_->{variable}} @{$self->sections};
    
    # ..and all of the question variable names..
    my @question_vars = map {$_->{variable}} @{$self->questions};
    
    # ..excluding the ones that are empty
    return grep {$_ ne ''} (@section_vars, @question_vars);
}

=head2 getSectionEditVars ( $address )

Get a safe copy of the variables for this section, to use for editing
purposes.  

Adds two variables:

=over 4

=item * id

the index of this section

=item * displayed_id

this question's index in a 1-based array (versus the default, perl style, 0-based array)

=back

It removes the questions array ref, and changes questionsPerPage from a single element, into
an array of hashrefs, which list the available questions per page and which one is currently
selected for this section.

=head3 $address

See L<"Address Parameter">. Specifies which question to fetch variables for.

=cut

sub getSectionEditVars {
    my $self    = shift;
    my $address = shift;
    my $section  = $self->section($address);
    my %var     = %{$section};
    
    # Add the extra fields..
    $var{id}           = sIndex($address);
    $var{displayed_id} = sIndex($address) + 1;
    
    # Remove the fields we don't want..
    delete $var{questions};
    delete $var{questionsPerPage};

    # Change questionsPerPage from a single element, into an array of hashrefs, which list the 
    # available questions per page and which one is currently selected for this section..
    for my $index ( 1 .. $MAX_QUESTIONS_PER_PAGE ) {
        if ( $index == $section->{questionsPerPage} ) {
            push( @{ $var{questionsPerPage} }, { index => $index, selected => 1 } );
        }
        else {
            push( @{ $var{questionsPerPage} }, { index => $index, selected => 0 } );
        }
    }
    return \%var;
}

=head2 getQuestionEditVars ( $address )

Get a safe copy of the variables for this question, to use for editing purposes.  

Adds two variables:

=over 4

=item * id 

the index of the question's position in its parent's section array joined by dashes '-'

=item * displayed_id

this question's index in a 1-based array (versus the default, perl style, 0-based array).

=back

It removes the answers array ref, and changes questionType from a single element, into
an array of hashrefs, which list the available question types and which one is currently
selected for this question.

=head3 $address

See L<"Address Parameter">. Specifies which question to fetch variables for.

=cut

sub getQuestionEditVars {
    my $self    = shift;
    my $address = shift;
    my $question  = $self->question($address);
    my %var       = %{$question};
    
    # Add the extra fields..
    $var{id}           = sIndex($address) . "-" . qIndex($address);
    $var{displayed_id} = qIndex($address) + 1;
    
    # Remove the fields we don't want
    delete $var{answers};
    delete $var{questionType};

    # Change questionType from a single element into an array of hashrefs which list the available 
    # question types and which one is currently selected for this question..
    for ($self->getValidQuestionTypes) {
        if ( $_ eq $question->{questionType} ) {
            push( @{ $var{questionType} }, { text => $_, selected => 1 } );
        }
        else {
            push( @{ $var{questionType} }, { text => $_, selected => 0 } );
        }
    }
    return \%var;
}

=head2 getValidQuestionTypes

A convenience method.  Returns a list of question types.  If you add a question
type to the Survey, you must handle it here, and also in updateQuestionAnswers

=cut

sub getValidQuestionTypes {
    return (
        'Agree/Disagree', 'Certainty',               'Concern',         'Confidence',
        'Currency',       'Date',                    'Date Range',      'Dual Slider - Range',
        'Education',      'Effectiveness',           'Email',           'File Upload',
        'Gender',         'Hidden',                  'Ideology',        'Importance',
        'Likelihood',     'Multi Slider - Allocate', 'Multiple Choice', 'Oppose/Support',
        'Party',          'Phone Number',            'Race',            'Risk',
        'Satisfaction',   'Scale',                   'Security',        'Slider',
        'Text',           'TextArea',                'Text Date',       'Threat',          
        'True/False',     'Yes/No'
    );
}

=head2 getAnswerEditVars ( $address )

Get a safe copy of the variables for this answer, to use for editing purposes. 

Adds two variables:

=over 4

=item * id 

The index of the answer's position in its parent's question  and section arrays joined by dashes '-'

=item * displayed_id

This answer's index in a 1-based array (versus the default, perl style, 0-based array).

=back

=head3 $address

See L<"Address Parameter">. Specifies which answer to fetch variables for.

=cut

sub getAnswerEditVars {
    my $self    = shift;
    my $address = shift;
    my $object  = $self->answer($address);
    my %var     = %{$object};
    
    # Add the extra fields..
    $var{id}           = sIndex($address) . "-" . qIndex($address) . "-" . aIndex($address);
    $var{displayed_id} = aIndex($address) + 1;
    
    return \%var;
}

=head2 update ( $address, $properties )

Update a section/question/answer with $properties, or add new ones.  
Does not return anything significant.

=head3 $address

See L<"Address Parameter">. 

The number of elements in $address determines the behaviour:

=over 4

=item * 0 elements

Do Nothing

=item * 1 element

Update the addressed section with $properties. If the section does not exist, such
as by using an out of bounds array index, then a new section is appended
to the list of sections.

=item * 2 elements

Update the addressed question with $properties. 

=item * 3 elements

Update the addressed answer with $properties. 

=back

=head3 $properties

A perl data structure.  Note, that it is not checked for type, so it is
possible to add a "question" object into the list of sections.
$properties should never be a partial object, but contain all properties.

=cut

sub update {
    my ( $self, $address, $properties ) = @_;
    my $object;
    
    # Keep track of whether a new question is created along the way..
    my $newQuestion = 0;
    
    # Figure out what to do by counting the number of elements in the $address array ref
    my $count = @$address;
    
    # First retrieve the addressed object, or, if necessary, create it
    if ( $count == 1 ) {
        $object = $self->section($address);
        if ( !defined $object ) {
            $object = $self->newSection();
            push( @{ $self->sections }, $object );
        }
    }
    elsif ( $count == 2 ) {
        $object = $self->question($address);
        if ( !defined $object ) {
            $object = $self->newQuestion();
            $newQuestion = 1; # make note that a new question was created
            push( @{ $self->questions($address) }, $object );
        }
    }
    elsif ( $count == 3 ) {
        $object = $self->answer($address);
        if ( !defined $object ) {
            $object = $self->newAnswer();
            push( @{ $self->answers($address) }, $object );
        }
    }
    
    # $object and $address now refer to the section/question/answer to be updated
    
    # In the case where we are updating an existing question..
    if ( $count == 2 and !$newQuestion ) {
        # We need to update all of the answers to reflect the new questionType
        if ( $properties->{questionType} ne $self->question($address)->{questionType} ) {
            $self->updateQuestionAnswers( $address, $properties->{questionType} );
        }
    }
    
    # Update $object with all of the data in $properties 
    for my $key ( keys %$properties ) {
        $object->{$key} = $properties->{$key} if defined $properties->{$key};
    }
}

=head2 insertObject ( $object, $address )

Used to move existing objects in the current data structure.  It does not
return anything significant.

=head3 $object

A perl data structure.  Note, that it is not checked for homegeneity,
so it is possible to add a "question" object into the list of section
objects.

=head3 $address

See L<"Address Parameter">. The number of elements array set what is added, and
where.

=over 4

=item empty

If the array ref is empty, nothing is done.

=item 1 element

If there's just 1 element, then that element is used as an index into
the array of sections, and $object is spliced into place right after
that index.

=item 2 elements

If there are 2 elements, then the first element is an index into
section array, and the second element is an index into the questions
in that section.  $object is added right after that question.

=item 3 elements

Three elements are enough to reference an answer, inside of a particular
question in a section.  $object is spliced in right after that answer.

=back

=cut

sub insertObject {
    my ( $self, $object, $address ) = @_;
    if ( @$address == 1 ) {
        splice( @{ $self->sections($address) }, $$address[0] + 1, 0, $object );
    }
    elsif ( @$address == 2 ) {
        splice( @{ $self->questions($address) }, $$address[1] + 1, 0, $object );
    }
    elsif ( @$address == 3 ) {
        splice( @{ $self->answers($address) }, $$address[2] + 1, 0, $object );
    }

}

=head2 copy ( $address )

Duplicate the structure pointed to by $address, and add it to the end of the list of
similar structures.  copy returns $address with the last element changed to the highest
index in that array.

=head3 $address

See L<"Address Parameter">. The number of elements array set what is added, and
where.

This method modifies $address.

=over 4

=item 1 element

If there's just 1 element, then the section with that index is duplicated
at the end of the array of sections.

=item 2 elements

If there are 2 elements, the question in the section that is indexed
will be duplicated and added to the end of the array of questions
in that section.

=item 3 elements, or more

Nothing happens.  It is not allowed to duplicate answers.

=back

=cut

sub copy {
    my ( $self, $address ) = @_;
    if ( @$address == 1 ) {
        my $newSection = dclone $self->section($address);
        push( @{ $self->sections }, $newSection );
        $address->[0] = $#{ $self->sections };
        return $address;
    }
    elsif ( @$address == 2 ) {
        my $newQuestion = dclone $self->question($address);
        push( @{ $self->questions($address) }, $newQuestion );
        $address->[1] = $#{ $self->questions($address) };
        return $address;
    }
}

=head2 remove ( $address, $movingOverride )

Delete the structure pointed to by $address.

=head3 $address

See L<"Address Parameter">. The number of elements array set what is added, and
where.

This method modifies $address if it has 1 or more elements.

=over 4

=item 1 element

If there's just 1 element, then the section with that index is removed.  Normally,
the first section, index 0, cannot be removed.  See $movingOverride below.

=item 2 elements

If there are 2 elements, the question in the section is removed.
in that section.

=item 3 elements

Removes the answer in the specified question and section.

=back

=head3 $movingOverride

If $movingOverride is defined (meaning including 0 and ''), then the first section
is allowed to be removed.

=cut

sub remove {
    my ( $self, $address, $movingOverride ) = @_;
    if ( @$address == 1 ) {
        splice( @{ $self->{sections} }, $$address[0], 1 )
            if ( $$address[0] != 0 or defined $movingOverride );    #can't delete the first section
    }
    elsif ( @$address == 2 ) {
        splice( @{ $self->questions($address) }, $$address[1], 1 );
    }
    elsif ( @$address == 3 ) {
        splice( @{ $self->answers($address) }, $$address[2], 1 );
    }
}

=head2 newSection

Returns a reference to a new, empty section.

=cut

sub newSection {
    return {
        text                   => '',
        title                  => 'NEW SECTION',    ##i18n
        variable               => '',
        questionsPerPage       => 5,
        questionsOnSectionPage => 1,
        randomizeQuestions     => 0,
        everyPageTitle         => 1,
        everyPageText          => 1,
        terminal               => 0,
        terminalUrl            => '',
        goto                   => '',
        timeLimit              => 0,
        type                   => 'section',
        questions              => [],
    };
}

=head2 newQuestion

Returns a reference to a new, empty question.

=cut

sub newQuestion {
    return {
        text             => '',
        variable         => '',
        allowComment     => 0,
        commentCols      => 10,
        commentRows      => 5,
        randomizeAnswers => 0,
        questionType     => 'Multiple Choice',
        randomWords      => '',
        verticalDisplay  => 0,
        required         => 0,
        maxAnswers       => 1,
        value            => 1,
        textInButton     => 0,
#       terminal         => 0,
#       terminalUrl      => '',
        type             => 'question',
        answers          => [],
    };
}

=head2 newAnswer

Returns a reference to a new, empty answer.

=cut

sub newAnswer {
    return {
        text           => '',
        verbatim       => 0,
        textCols       => 10,
        textRows       => 5,
        goto           => '',
        gotoExpression => '',
        recordedAnswer => '',
        isCorrect      => 1,
        min            => 1,
        max            => 10,
        step           => 1,
        value          => 1,
        terminal       => 0,
        terminalUrl    => '',
        type           => 'answer'
    };
}

=head2 updateQuestionAnswers ($address, $type);

Add answers to a question, based on the requested type.

=head3 $address

See L<"Address Parameter">. Which question to add answers to.

=head3 $type

The question type to use to determine how many and what kind of answers
to add to the question.

=cut

sub updateQuestionAnswers {
    my $self    = shift;
    my $address = shift;
    my $type    = shift;

    my @addy     = @{$address};
    my $question = $self->question($address);
    $question->{answers} = [];

    if (   $type eq 'Date Range'
        or $type eq 'Multi Slider - Allocate'
        or $type eq 'Dual Slider - Range' )
    {
        push( @{ $question->{answers} }, $self->newAnswer() );
        push( @{ $question->{answers} }, $self->newAnswer() );
    }
    elsif ( $type eq 'Currency' ) {
        push( @{ $question->{answers} }, $self->newAnswer() );
        $addy[2] = 0;
        $self->update( \@addy, { 'text', 'Currency Amount:' } );
    }
    elsif ( $type eq 'Text Date' ) {
        push( @{ $question->{answers} }, $self->newAnswer() );
        $addy[2] = 0;
        $self->update( \@addy, { 'text', 'Date:' } );
    }
    elsif ( $type eq 'Phone Number' ) {
        push( @{ $question->{answers} }, $self->newAnswer() );
        $addy[2] = 0;
        $self->update( \@addy, { 'text', 'Phone Number:' } );
    }
    elsif ( $type eq 'Email' ) {
        push( @{ $question->{answers} }, $self->newAnswer() );
        $addy[2] = 0;
        $self->update( \@addy, { 'text', 'Email:' } );
    }
    elsif ( $type eq 'Education' ) {
        my @ans = (
            'Elementary or some high school',
            'High school/GED',
            'Some college/vocational school',
            'College graduate',
            'Some graduate work',
            'Master\'s degree',
            'Doctorate (of any type)',
            'Other degree (verbatim)'
        );
        $self->addAnswersToQuestion( \@addy, \@ans, { 7, 1 } );
    }
    elsif ( $type eq 'Party' ) {
        my @ans
            = ( 'Democratic party', 'Republican party (or GOP)', 'Independant party', 'Other party (verbatim)' );
        $self->addAnswersToQuestion( \@addy, \@ans, { 3, 1 } );
    }
    elsif ( $type eq 'Race' ) {
        my @ans = ( 'American Indian', 'Asian', 'Black', 'Hispanic', 'White non-Hispanic',
            'Something else (verbatim)' );
        $self->addAnswersToQuestion( \@addy, \@ans, { 5, 1 } );
    }
    elsif ( $type eq 'Ideology' ) {
        my @ans = (
            'Strongly liberal',
            'Liberal',
            'Somewhat liberal',
            'Middle of the road',
            'Slightly conservative',
            'Conservative',
            'Strongly conservative'
        );
        $self->addAnswersToQuestion( \@addy, \@ans, {} );
    }
    elsif ( $type eq 'Security' ) {
        my @ans = ( 'Not at all secure', '', '', '', '', '', '', '', '', '', 'Extremely secure' );
        $self->addAnswersToQuestion( \@addy, \@ans, {} );
    }
    elsif ( $type eq 'Threat' ) {
        my @ans = ( 'No threat', '', '', '', '', '', '', '', '', '', 'Extreme threat' );
        $self->addAnswersToQuestion( \@addy, \@ans, {} );
    }
    elsif ( $type eq 'Risk' ) {
        my @ans = ( 'No risk', '', '', '', '', '', '', '', '', '', 'Extreme risk' );
        $self->addAnswersToQuestion( \@addy, \@ans, {} );
    }
    elsif ( $type eq 'Concern' ) {
        my @ans = ( 'Not at all concerned', '', '', '', '', '', '', '', '', '', 'Extremely concerned' );
        $self->addAnswersToQuestion( \@addy, \@ans, {} );
    }
    elsif ( $type eq 'Effectiveness' ) {
        my @ans = ( 'Not at all effective', '', '', '', '', '', '', '', '', '', 'Extremely effective' );
        $self->addAnswersToQuestion( \@addy, \@ans, {} );
    }
    elsif ( $type eq 'Confidence' ) {
        my @ans = ( 'Not at all confident', '', '', '', '', '', '', '', '', '', 'Extremely confident' );
        $self->addAnswersToQuestion( \@addy, \@ans, {} );
    }
    elsif ( $type eq 'Satisfaction' ) {
        my @ans = ( 'Not at all satisfied', '', '', '', '', '', '', '', '', '', 'Extremely satisfied' );
        $self->addAnswersToQuestion( \@addy, \@ans, {} );
    }
    elsif ( $type eq 'Certainty' ) {
        my @ans = ( 'Not at all certain', '', '', '', '', '', '', '', '', '', 'Extremely certain' );
        $self->addAnswersToQuestion( \@addy, \@ans, {} );
    }
    elsif ( $type eq 'Likelihood' ) {
        my @ans = ( 'Not at all likely', '', '', '', '', '', '', '', '', '', 'Extremely likely' );
        $self->addAnswersToQuestion( \@addy, \@ans, {} );
    }
    elsif ( $type eq 'Importance' ) {
        my @ans = ( 'Not at all important', '', '', '', '', '', '', '', '', '', 'Extremely important' );
        $self->addAnswersToQuestion( \@addy, \@ans, {} );
    }
    elsif ( $type eq 'Oppose/Support' ) {
        my @ans = ( 'Strongly oppose', '', '', '', '', '', 'Strongly support' );
        $self->addAnswersToQuestion( \@addy, \@ans, {} );
    }
    elsif ( $type eq 'Agree/Disagree' ) {
        my @ans = ( 'Strongly disagree', '', '', '', '', '', 'Strongly agree' );
        $self->addAnswersToQuestion( \@addy, \@ans, {} );
    }
    elsif ( $type eq 'True/False' ) {
        my @ans = ( 'True', 'False' );
        $self->addAnswersToQuestion( \@addy, \@ans, {} );
    }
    elsif ( $type eq 'Yes/No' ) {
        my @ans = ( 'Yes', 'No' );
        $self->addAnswersToQuestion( \@addy, \@ans, {} );
    }
    elsif ( $type eq 'Gender' ) {
        my @ans = ( 'Male', 'Female' );
        $self->addAnswersToQuestion( \@addy, \@ans, {} );
    }
    else {
        push( @{ $question->{answers} }, $self->newAnswer() );
    }
} ## end sub updateQuestionAnswers

=head2 addAnswersToQuestion ($address, $answers, $verbatims)

Helper routine for updateQuestionAnswers.  Adds an array of answers to a question.

=head3 $address

See L<"Address Parameter">. The address of the question to add answers to.

=head3 $answers

An array reference of answers to add.  Each element will be assigned to the text field of
the answer that is created.

=head3 $verbatims

An hash reference.  Each key is an index into the answers array.  The value is a placeholder
for doing existance lookups.  For each requested index, the verbatim flag in the answer is
set to true.

=cut

sub addAnswersToQuestion {
    my $self  = shift;
    my $addy  = shift;
    my $ans   = shift;
    my $verbs = shift;
    for ( 0 .. $#$ans ) {
        push( @{ $self->question($addy)->{answers} }, $self->newAnswer() );
        $$addy[2] = $_;
        if ( exists $$verbs{$_} and $verbs->{$_} ) {
            $self->update( $addy, { 'text', $$ans[$_], 'recordedAnswer', $_ + 1, 'verbatim', 1 } );
        }
        else {
            $self->update( $addy, { 'text', $$ans[$_], 'recordedAnswer', $_ + 1 } );
        }
    }
} ## end sub addAnswersToQuestion

#------------------------------
#accessors and helpers
#------------------------------

=head2 sections

Returns a reference to all the sections in this object.

=cut

sub sections {
    my $self = shift;
    return $self->{sections};
}

=head2 totalSections

Returns the total number of Sections

=cut

sub totalSections {
    my $self = shift;
    return scalar @{ $self->sections || [] };
}

=head2 totalQuestions ($address)

Returns the total number of Questions overall, or in the given Section if $address given 

=head3 $address

See L<"Address Parameter">.

=cut

sub totalQuestions {
    my $self = shift;
    my $address = shift;
    if ($address) {
        return scalar @{ $self->questions($address) || [] };
    } else {
        my $count = 0;
        for ( my $sIndex = 0; $sIndex < $self->totalSections; $sIndex++ ) {
            $count += $self->totalQuestions([$sIndex]);
        }
        return $count;
    }
}

=head2 totalAnswers ($address)

Returns the total number of Answers overall, or in the given Question if $address given

=head3 $address

See L<"Address Parameter">.

=cut

sub totalAnswers {
    my $self = shift;
    my $address = shift;
    if ($address) {
        return scalar @{ $self->answers($address) || [] };
    } else {
        my $count = 0;
        for ( my $sIndex = 0; $sIndex < $self->totalSections; $sIndex++ ) {
            for ( my $qIndex = 0; $qIndex < $self->totalQuestions([$sIndex]); $qIndex++ ) {
                $count += $self->totalAnswers([$sIndex, $qIndex]);
            }
        }
        return $count;
    }
}

=head2 section ($address)

Returns a reference to one section.

=head3 $address

See L<"Address Parameter">.

=cut

sub section {
    my $self    = shift;
    my $address = shift;
    return $self->{sections}->[ $address->[0] ];
}

=head2 questions ($address)

Returns a reference to all the questions from a particular section.

=head3 $address

See L<"Address Parameter">.

=cut

sub questions {
    my $self    = shift;
    my $address = shift;
    return $self->{sections}->[ $address->[0] ]->{questions};
}

=head2 question ($address)

Return a reference to one question from a particular section.

=head3 $address

See L<"Address Parameter">.

=cut

sub question {
    my $self    = shift;
    my $address = shift;
    return $self->{sections}->[ $address->[0] ]->{questions}->[ $address->[1] ];
}

=head2 answers ($address)

Return a reference to all answers from a particular question.

=head3 $address

See L<"Address Parameter">.

=cut

sub answers {
    my $self    = shift;
    my $address = shift;
    return $self->{sections}->[ $address->[0] ]->{questions}->[ $address->[1] ]->{answers};
}

=head2 answer ($address)

Return a reference to one answer from a particular question and section.

=head3 $address

See L<"Address Parameter">.

=cut

sub answer {
    my $self    = shift;
    my $address = shift;
    return $self->{sections}->[ $address->[0] ]->{questions}->[ $address->[1] ]->{answers}->[ $address->[2] ];
}

=head2 sIndex ($address)

Convenience sub to extract the section index from a standard $address parameter. See L<"Address Parameter">.

=cut
 
sub sIndex {
    my $address = shift;
    return $address->[0];
}

=head2 qIndex ($address)

Convenience sub to extract the question index from a standard $address parameter. See L<"Address Parameter">.

=cut

sub qIndex {
    my $address = shift;
    return $address->[1];
}

=head2 aIndex ($address)

Convenience sub to extract the answer index from a standard $address parameter. See L<"Address Parameter">.

=cut

sub aIndex {
    my $address = shift;
    return $address->[2];
}

=head2 log ($message)

Logs an error message using the session logger.

=head3 $message

The message to log.  It will be logged as type "error".

=cut

sub log {
    my ( $self, $message ) = @_;
    if ( defined $self->{log} ) {
        $self->{log}->error($message);
    }
}
1;
