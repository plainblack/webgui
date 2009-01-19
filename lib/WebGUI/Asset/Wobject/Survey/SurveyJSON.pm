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

=cut

use strict;
use JSON;

#use Clone qw/clone/;
use Storable qw/dclone/;

=head2 new ( $json, $log )

Object constructor.

=head3 $json

Pass in some JSON to be serialized into a data structure.  Useful JSON would
be a hash with "survey" and "sections" keys with appropriate values.

=head3 $log

The session logger, from $session->log.  The class needs nothing else from the
session object.

=cut

sub new {
    my $class = shift;
    my $json  = shift;
    my $log   = shift;
    my $self  = {};
    $self->{log} = $log;
    my $temp = decode_json($json) if defined $json;
    $self->{sections} = defined $temp->{sections} ? $temp->{sections} : [];
    $self->{survey}   = defined $temp->{survey}   ? $temp->{survey}   : {};
    bless( $self, $class );

    if ( @{ $self->sections } == 0 ) {
        $self->newObject( [] );
    }
    return $self;
} ## end sub new

=head2 freeze

Serializes the survey and sections data into JSON and returns the JSON.

=cut

sub freeze {
    my $self = shift;
    my %temp;
    $temp{sections} = $self->{sections};
    $temp{survey}   = $self->{survey};
    return encode_json( \%temp );
}

=head2 newObject ( $address )

Add new, empty elements to the survey data structure.  It returns $address,
modified to show what was added.

=head3 $address

An array ref.  The number of elements array set what is added, and
where.

This method modifies $address.  It also returns $address.

=over 4

=item empty

If the array ref is empty, a new section is added.

=item 1 element

If there's just 1 element, then that element is used as an index into
the array of sections, and a new question is added to that section.

=item 2 elements

If there are 2 elements, then the first element is an index into
section array, and the second element is an index into the questions
in that section.  A new answer is added to the specified question in
the specified section.

=back

=cut

sub newObject {
    my $self    = shift;
    my $address = shift;
    if ( @$address == 0 ) {
        push( @{ $self->sections }, $self->newSection() );
        $address->[0] = $#{ $self->sections };
    }
    elsif ( @$address == 1 ) {
        push( @{ $self->questions($address) }, $self->newQuestion($address) );
        $$address[1] = $#{ $self->questions($address) };
    }
    elsif ( @$address == 2 ) {
        push( @{ $self->answers($address) }, $self->newAnswer($address) );
        $$address[2] = $#{ $self->answers($address) };
    }
    return $address;
} ## end sub newObject

#address is the array of objects currently selected in the edit screen
#data is the array of hash items for displaying

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

An array ref.  Sets which question from a section will be listed, along with all
its answers.  $address should ALWAYS have two elements.

=cut

sub getDragDropList {
    my $self    = shift;
    my $address = shift;
    my @data;
    for ( my $i = 0; $i <= $#{ $self->sections }; $i++ ) {
        push( @data, { text => $self->section( [$i] )->{title}, type => 'section' } );
        if ( $address->[0] == $i ) {

            for ( my $x = 0; $x <= $#{ $self->questions($address) }; $x++ ) {
                push(
                    @data,
                    {   text => $self->question( [ $i, $x ] )->{text},
                        type => 'question'
                    }
                );
                if ( $address->[1] == $x ) {
                    for ( my $y = 0; $y <= $#{ $self->answers($address) }; $y++ ) {
                        push(
                            @data,
                            {   text => $self->answer( [ $i, $x, $y ] )->{text},
                                type => 'answer'
                            }
                        );
                    }
                }
            } ## end for ( my $x = 0; $x <= ...
        } ## end if ( $address->[0] == ...
    } ## end for ( my $i = 0; $i <= ...
    return \@data;
} ## end sub getDragDropList

=head2 getObject ( $address )

Retrieve objects from the sections data structure by address.

=head3 $address

An array ref.  The number of elements array set what is fetched.

=over 4

=item empty

If the array ref is empty, nothing is done.

=item 1 element

If there's just 1 element, returns the section with that index.

=item 2 elements

If there are 2 elements, then the first element is an index into
section array, and the second element is an index into the questions
in that section.  Returns that question.

=item 3 elements

Three elements are enough to reference an answer, inside of a particular
question in a section.  Returns that answer.

=back

=cut

sub getObject {
    my ( $self, $address ) = @_;
    if ( @$address == 1 ) {
        return dclone $self->{sections}->[ $address->[0] ];
    }
    elsif ( @$address == 2 ) {
        return dclone $self->{sections}->[ $address->[0] ]->{questions}->[ $address->[1] ];
    }
    else {
        return dclone $self->{sections}->[ $address->[0] ]->{questions}->[ $address->[1] ]->{answers}
            ->[ $address->[2] ];
    }
}

=head2 getSectionEditVars ( $address )

A dispatcher for getSectionEditVars, getQuestionEditVars and getAnswerEditVars.  Uses $address
to figure out what has been requested, then invokes that method and returns the results
from it.

=head3 $address

An array ref.  The number of elements determines whether edit vars are fetched for
sections, questions, or answers.

=cut

sub getEditVars {
    my ( $self, $address ) = @_;

    if ( @$address == 1 ) {
        return $self->getSectionEditVars($address);
    }
    elsif ( @$address == 2 ) {
        return $self->getQuestionEditVars($address);
    }
    elsif ( @$address == 3 ) {
        return $self->getAnswerEditVars($address);
    }
}

=head2 getSectionEditVars ( $address )

Get a safe copy of the variables for this section, to use for editing
purposes.  Adds two variables, id, which is the index of this section,
and displayed_id, which is this question's index in a 1-based array
(versus the default, perl style, 0-based array).

It removes the questions array ref, and changes questionsPerPage from a single element, into
an array of hashrefs, which list the available questions per page and which one is currently
selected for this section.

=head3 $address

An array reference, specifying which question to fetch variables for.

=cut

sub getSectionEditVars {
    my $self    = shift;
    my $address = shift;
    my $object  = $self->section($address);
    my %var     = %{$object};
    $var{id}           = $address->[0];
    $var{displayed_id} = $address->[0] + 1;
    delete $var{questions};
    delete $var{questionsPerPage};

    for ( 1 .. 20 ) {

        #        if($_ == $self->section($address)->{questionsPerPage}){
        if ( $_ == $object->{questionsPerPage} ) {
            push( @{ $var{questionsPerPage} }, { 'index', $_, 'selected', 1 } );
        }
        else {
            push( @{ $var{questionsPerPage} }, { 'index', $_, 'selected', 0 } );
        }
    }
    return \%var;
} ## end sub getSectionEditVars

sub getGotoTargets {
    my $self = shift;

    my @section_vars = map {$_->{variable}} @{$self->sections};
    my @question_vars = map {$_->{variable}} @{$self->questions};
    return grep {$_ ne ''} (@section_vars, @question_vars);
}

=head2 getQuestionEditVars ( $address )

Get a safe copy of the variables for this question, to use for editing purposes.  Adds
two variables, id, which is the indeces of the question's position in its parent's 
section array joined by dashes '-', and displayed_id, which is this question's index
in a 1-based array (versus the default, perl style, 0-based array).

It removes the answers array ref, and changes questionType from a single element, into
an array of hashrefs, which list the available question types and which one is currently
selected for this question.

=head3 $address

An array reference, specifying which question to fetch variables for.

=cut

sub getQuestionEditVars {
    my $self    = shift;
    my $address = shift;
    my $object  = $self->question($address);
    my %var     = %{$object};
    $var{id}           = $address->[0] . "-" . $address->[1];
    $var{displayed_id} = $address->[1] + 1;
    delete $var{answers};
    delete $var{questionType};
    my @types = $self->getValidQuestionTypes();

    for (@types) {
        if ( $_ eq $object->{questionType} ) {
            push( @{ $var{questionType} }, { 'text', $_, 'selected', 1 } );
        }
        else {
            push( @{ $var{questionType} }, { 'text', $_, 'selected', 0 } );
        }
    }
    return \%var;
} ## end sub getQuestionEditVars

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

Get a safe copy of the variables for this answer, to use for editing purposes.  Adds
two variables, id, which is the indeces of the answer's position in its parent's question
and section arrays joined by dashes '-', and displayed_id, which is this answer's index
in a 1-based array (versus the default, perl style, 0-based array).

=head3 $address

An array reference, specifying which answer to fetch variables for.

=cut

sub getAnswerEditVars {
    my $self    = shift;
    my $address = shift;
    my $object  = $self->answer($address);
    my %var     = %{$object};
    $var{id}           = $address->[0] . "-" . $address->[1] . "-" . $address->[2];
    $var{displayed_id} = $address->[2] + 1;
    return \%var;
}

=head2 update ( $address, $object )

Update new "objects" into the current data structure, or add new ones.  It does not
return anything significant.

=head3 $address

An array ref.  The number of elements array set what is updated.

=over 4

=item empty

If the array ref is empty, nothing is done.

=item 1 element

If there's just 1 element, then that element is used as an index into
the array of sections, and information from $object is used to replace
the properties of that section.  If the select section does not exist, such
as by using an out of bounds array index, then a new section is appended
to the list of sections.

=item 2 elements

If there are 2 elements, then the first element is an index into
section array, and the second element is an index into the questions
in that section.

=item 3 elements

Three elements are enough to reference an answer, for a particular
question in a section.

=back

=head3 $object

A perl data structure.  Note, that it is not checked for type, so it is
possible to add a "question" object into the list of section objects.
$object should never be a partial object, but contain all properties.

=cut

sub update {
    my ( $self, $address, $ref ) = @_;
    my $object;
    my $newQuestion = 0;
    if ( @$address == 1 ) {
        $object = $self->section($address);
        if ( !defined $object ) {
            $object = $self->newSection();
            push( @{ $self->sections }, $object );
        }
    }
    elsif ( @$address == 2 ) {
        $object = $self->question($address);
        if ( !defined $object ) {
            my $newQuestion = 1;
            $object = $self->newQuestion();
            push( @{ $self->questions($address) }, $object );
        }
    }
    elsif ( @$address == 3 ) {
        $object = $self->answer($address);
        if ( !defined $object ) {
            $object = $self->newAnswer();
            push( @{ $self->answers($address) }, $object );
        }
    }
    if ( @$address == 2 and !$newQuestion ) {
        if ( $ref->{questionType} ne $self->question($address)->{questionType} ) {
            $self->updateQuestionAnswers( $address, $ref->{questionType} );
        }
    }
    for my $key ( keys %$ref ) {
        $object->{$key} = $ref->{$key} if ( defined $$ref{$key} );
    }
} ## end sub update

#determine what to add and add it.
# ref should contain all the information for the new

=head2 insertObject ( $object, $address )

Used to move existing objects in the current data structure.  It does not
return anything significant.

=head3 $object

A perl data structure.  Note, that it is not checked for homegeneity,
so it is possible to add a "question" object into the list of section
objects.

=head3 $address

An array ref.  The number of elements array set what is added, and
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

An array ref.  The number of elements array set what is added, and
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

An array ref.  The number of elements array set what is added, and
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

Which question to add answers to.

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

The address of the question to add answers to.

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

=head2 section ($address)

Returns a reference to one section.

=head3 $address

An array ref.  The first element of the array ref is the index of
the section whose questions will be returned.

=cut

sub section {
    my $self    = shift;
    my $address = shift;
    return $self->{sections}->[ $$address[0] ];
}

=head2 questions ($address)

Returns a reference to all the questions from a particular section.

=head3 $address

An array ref.  The first element of the array ref is the index of
the section whose questions will be returned.

=cut

sub questions {
    my $self    = shift;
    my $address = shift;
    return $self->{sections}->[ $$address[0] ]->{questions};
}

=head2 question ($address)

Return a reference to one question from a particular section.

=head3 $address

An array ref.  The first element of the array ref is the index of
the section.  The second element is the index of the question in
that section.

=cut

sub question {
    my $self    = shift;
    my $address = shift;
    return $self->{sections}->[ $$address[0] ]->{questions}->[ $$address[1] ];
}

=head2 answers ($address)

Return a reference to all answers from a particular question.

=head3 $address

An array ref.  The first element of the array ref is the index of
the section.  The second element is the index of the question in
that section.  An array ref of anwers from that question will be
returned.

=cut

sub answers {
    my $self    = shift;
    my $address = shift;
    return $self->{sections}->[ $$address[0] ]->{questions}->[ $$address[1] ]->{answers};
}

=head2 answer ($address)

Return a reference to one answer from a particular question and section.

=head3 $address

An array ref.  The first element of the array ref is the index of
the section.  The second element is the index of the question in
that section.  The third element is the index of the answer.

=cut

sub answer {
    my $self    = shift;
    my $address = shift;
    return $self->{sections}->[ $$address[0] ]->{questions}->[ $$address[1] ]->{answers}->[ $$address[2] ];
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
