package WebGUI::Asset::Wobject::Survey::SurveyJSON;

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
use Params::Validate qw(:all);
Params::Validate::validation_options( on_fail => sub { WebGUI::Error::InvalidParam->throw( error => shift ) } );
use Clone qw/clone/;
use WebGUI::Asset::Wobject::Survey::ExpressionEngine;

# The maximum value of questionsPerPage is currently hardcoded here
my $MAX_QUESTIONS_PER_PAGE = 20;

=head2 new ( $session, json )

Object constructor.

=head3 $session

WebGUI::Session object

=head3 $json (optional)

A json-encoded serialized surveyJSON object. Typically this will have just been retrieved from the 
database, have been previously generated from another surveyJSON object using L<freeze>.

See L<freeze> for more information on what the serialized object should look like.

=cut

sub new {
    my $class = shift;
    my ($session, $json)   = validate_pos(@_, {isa => 'WebGUI::Session' }, { type => SCALAR | UNDEF, optional => 1});

    # Load json object if given..
    my $jsonData = $json ? from_json($json) : {};
    
    # When the a new empty surveyJSON object is created (as opposed to being re-initialised from existing json), 
    # we create a snapshot of the *current* default values for new Sections, Questions and Answers. 
    # This snapshot (the mold) is used by L<compress> and L<uncompress> to reduce redundancy in the json-encoded 
    # surveyJSON object that gets serialized to the database. This compression is mostly transparent since it
    # happens only at serialisation/instantiation time.
    my $sections = $jsonData->{sections} || [];
    my $self = {
        _session  => $session,
        _mold    => $jsonData->{mold}
            || {
            answer   => $class->newAnswer,
            question => $class->newQuestion,
            section  => $class->newSection,
            },
    };

    bless $self, $class;

    # Uncompress the survey configuration and store it in the new object
    $self->{_sections} = $self->uncompress($sections);

    #Load question types
    $self->loadTypes();

    # Initialise the survey data structure if empty..
    if ( $self->totalSections == 0 ) {
        $self->newObject( [] );
    }
    return $self;
}

=head2 loadTypes

Loads the Multiple Choice and Special Question types

=cut

sub loadTypes {
    my $self = shift;

    @{$self->{specialQuestionTypes}} = ( 
        'Dual Slider - Range',
        'Multi Slider - Allocate',
        'Slider',
        'Currency',
        'Email',
        'Number',
        'Phone Number',
        'Text',
        'Text Date',
        'TextArea',
        'File Upload',
        'Date',
        'Date Range',
        'Year Month',
        'Country',
        'Hidden',
    ) if(! defined $self->{specialQuestionTypes});
    if(! defined $self->{multipleChoiceTypes}){
        my $refs = $self->session->db->buildArrayRefOfHashRefs("SELECT questionType, answers FROM Survey_questionTypes"); 
        map($self->{multipleChoiceTypes}->{$_->{questionType}} = $_->{answers} ? from_json($_->{answers}) : {}, @$refs);
        
        # Also add 'Tagged' question type to multipleChoiceTypes hash, since it is treated like the other mc types
        $self->{multipleChoiceTypes}->{Tagged} = {};
    }
}

=head2 addType ( questionType, address )

Adds a new multiple-choice question type. If a bundle of the same name already exists, 
the definition for that bundle is updated.

=head3 questionType

The questionType of the multiple-choice question bundle

=head3 address

The address of a question to use as the basis for the new multiple-choice question bundle definition.
After creating the new bundle, the question is updated so that its questionType is set to the name
of the new bundle.

=cut

sub addType { 
    my $self = shift;
    my $questionType = shift;
    my $address = shift;
    my $question = $self->question($address);
    my $ansString = $question->{answers} ? to_json $question->{answers} : {};
    $self->session->db->write("INSERT INTO Survey_questionTypes VALUES(?,?) ON DUPLICATE KEY UPDATE answers = ?",[$questionType,$ansString,$ansString]);
    $question->{questionType} = $questionType;
}

=head2 removeType ( address )

Removes a multiple-choice bundle.

=head3 address

The address of the question whose questionType corresponds to a bundle that should be removed. 
After removing the bundle, the question is updated so that its questionType reverts back to
the generic "Multiple Choice" questionType.

=cut

sub removeType {
    my $self = shift;
    my $address = shift;
    my $question = $self->question($address);
    $self->session->db->write("DELETE FROM Survey_questionTypes WHERE questionType = ?",[$question->{questionType}]);
    $question->{questionType} = 'Multiple Choice';
}

=head2 specialQuestionTypes

Returns the arrayref to the special question types

=cut 

sub specialQuestionTypes {
    my $self = shift;
    return $self->{specialQuestionTypes};
}

=head2 multipleChoiceTypes

Returns the hashref to the multiple choice types

=cut

sub multipleChoiceTypes {
    my $self = shift;
    return $self->{multipleChoiceTypes};
}

=head2 freeze

Serialize this Perl object into a JSON string. The serialized object is made up of the survey and sections 
components of this object, as well as the "mold" which is used .

=cut

sub freeze {
    my $self = shift;
    return to_json(
        {   sections => $self->compress(),
            mold    => $self->{_mold},
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
    my $count = @{$address};

    if ( $count == 0 ) {
        # Add a new section to the end of the list of sections..
        push @{ $self->{_sections} }, $self->newSection();

        # Update $address with the index of the newly created section
        $address->[0] = $self->lastSectionIndex;
    }
    elsif ( $count == 1 ) {
        # Add a new question to the end of the list of questions in section located at $address
        push @{ $self->section($address)->{questions} }, $self->newQuestion($address);

        # Update $address with the index of the newly created question
        $address->[1] = $self->lastQuestionIndex($address);
    }
    elsif ( $count == 2 ) {
        # Add a new answer to the end of the list of answers in section/question located at $address
        push @{ $self->question($address)->{answers} }, $self->newAnswer($address);

        # Update $address with the index of the newly created answer
        $address->[2] = $self->lastAnswerIndex($address);
    }
    # Return the (modified) $address
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
    for my $sIndex (0 .. $self->lastSectionIndex) {
        push @data, { text => $self->section( [$sIndex] )->{title}, type => 'section' };
        if ( sIndex($address) == $sIndex ) {

            for my $qIndex (0 .. $self->lastQuestionIndex($address)) {
                push @data,
                    {   text => $self->question( [ $sIndex, $qIndex ] )->{text},
                        type => 'question'
                    }
                ;
                if ( qIndex($address) == $qIndex ) {
                    for my $aIndex (0 .. $self->lastAnswerIndex($address)) {
                        push @data,
                            {   text => $self->answer( [ $sIndex, $qIndex, $aIndex ] )->{text},
                                type => 'answer'
                            }
                        ;
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
    my $self    = shift;
    my $address = shift;

    # Figure out what to do by counting the number of elements in the $address array ref
    my $count = @{$address};

    return if !$count;

    if ( $count == 1 ) {
        return clone $self->sections->[ sIndex($address) ];
    }
    elsif ( $count == 2 ) {
        return clone $self->sections->[ sIndex($address) ]->{questions}->[ qIndex($address) ];
    }
    else {
        return clone $self->sections->[ sIndex($address) ]->{questions}->[ qIndex($address) ]->{answers}
            ->[ aIndex($address) ];
    }
}

=head2 getEditVars ( $address )

A dispatcher for getSectionEditVars, getQuestionEditVars and getAnswerEditVars.  Uses $address
to figure out what has been requested, then invokes that method and returns the results
from it.

=head3 $address

See L<"Address Parameter">. The number of elements determines whether edit vars are fetched for
sections, questions, or answers.

=cut

sub getEditVars {
    my $self    = shift;
    my $address = shift;
    # Figure out what to do by counting the number of elements in the $address array ref
    my $count = @{$address};

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

    # Valid goto targets are all of the non-empty section variable names..
    my @section_vars = grep { $_ ne q{} } map {$_->{variable}} @{$self->sections};

    # ..and all of the non-empty question variable names..
    my @question_vars = grep { $_ ne q{} } map {$_->{variable}} @{$self->questions};

    # ..plus some special vars
    my @special_vars = qw(NEXT_SECTION END_SURVEY);

    # ..all combined
    return [ @section_vars, @question_vars, @special_vars ];
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
        push @{ $var{questionsPerPage} }, {
            index => $index,
            selected => $index == $section->{questionsPerPage} ? 1 : 0
        };
    }
    return \%var;
}

=head2 getQuestionEditVars ( $address )

Get a safe copy of the variables for this question, to use for editing purposes.  

Adds two variables:

=over 4

=item * id 

the index of the question's position in its parent's section array joined by dashes '-'
See L<WebGUI::Asset::Wobject::Survey::ResponseJSON/questionIndex>.

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
    $var{id}           = sIndex($address) . q{-} . qIndex($address);
    $var{displayed_id} = qIndex($address) + 1;

    # Remove the fields we don't want
    delete $var{answers};
    delete $var{questionType};

    # Change questionType from a single element into an array of hashrefs which list the available 
    # question types and which one is currently selected for this question..
    for my $qType ($self->getValidQuestionTypes) {
        push @{ $var{questionType} }, {
            text => $qType,
            selected => $qType eq $question->{questionType} ? 1 : 0
        };
    }
    return \%var;
}

=head2 getValidQuestionTypes

A convenience method.  Returns a list of question types.

=cut

sub getValidQuestionTypes {
    my $self = shift;
    return sort (@{$self->{specialQuestionTypes}}, keys %{$self->{multipleChoiceTypes}});
}

=head2 getAnswerEditVars ( $address )

Get a safe copy of the variables for this answer, to use for editing purposes. 

Adds two variables:

=over 4

=item * id 

The index of the answer's position in its parent's question  and section arrays joined by dashes '-'
See L<WebGUI::Asset::Wobject::Survey::ResponseJSON/answerIndex>.

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
    $var{id}           = sIndex($address) . q{-} . qIndex($address) . q{-} . aIndex($address);
    $var{displayed_id} = aIndex($address) + 1;

    return \%var;
}

=head2 compress

Returns a copy of L<sections> with all redundancy (relative to L<mold>) removed.
That is, any section/question/answer property that matches the mold is removed from
the array object that is returned.

This is handy for shinking down the L<sections> hash as much as possible prior
to json-encoding and storing in the db (see L<freeze>).

=cut

sub compress {
    my $self = shift;
    
    # Get the Section, Question and Answer molds that will be used to remove redundancy
    my ($smold, $qmold, $amold) = @{$self->mold}{'section', 'question', 'answer'};
    
    # Iterate over all objects, only adding them to our new object if they differ from the mold
    # Properties are assumed to be simple scalars only (strings and numbers). The only except to
    # this is the 'questions' arrayref in sections and the 'answers' arrayref in questions.
    my @sections;
    for my $s (@{$self->sections}) {
        my $newS = {};
        for my $q (@{$s->{questions} || []}) {
            my $newQ = {};
            for my $a (@{$q->{answers} || []}) {
                my $newA = {};
                while (my($key, $value) = each %$a) {
                    next if ref $value;
                    $newA->{$key} = $value unless $value eq $amold->{$key};
                }
                push @{$newQ->{answers}}, $newA;
            }
            while (my($key, $value) = each %$q) {
                next if ref $value;
                $newQ->{$key} = $value unless $value eq $qmold->{$key};
            }
            push @{$newS->{questions}}, $newQ;
        }
        while (my($key, $value) = each %$s) {
            next if ref $value;
            $newS->{$key} = $value unless $value eq $smold->{$key};
        }
        push @sections, $newS;
    }
    return \@sections;
}

=head2 uncompress ($sections)

Modifies the supplied arrayref of sections, adding back in all redundancy that has been 
removed by a previous call to L<compress>. Typically this is done immediately after
retrieving serialised surveyJSON from the db (see L<db>).

Any L<mold> property missing from the supplied list of section/question/answers is added,
and then the modified arrayref is returned.

=head3 sections

An arrayref of sections that you want to uncompress. Typically retrieved from the database.

=cut

sub uncompress {
    my $self    = shift;
    my $sections = shift;
    
    return if !$sections;
    
    # Get the Section, Question and Answer molds
    my ($smold, $qmold, $amold) = @{$self->mold}{'section', 'question', 'answer'};
    
    # Iterate over all objects, adding back in the missing properties
    for my $s (@$sections) {
        for my $q (@{$s->{questions} || []}) {
            for my $a (@{$q->{answers} || []}) {
                while (my($key, $value) = each %$amold) {
                    next if ref $value;
                    $a->{$key} = $value unless exists $a->{$key};
                }
            }
            while (my($key, $value) = each %$qmold) {
                next if ref $value;
                $q->{$key} = $value unless exists $q->{$key};
            }
        }
        while (my($key, $value) = each %$smold) {
            next if ref $value;
            $s->{$key} = $value unless exists $s->{$key};
        }
    }
    
    # Return the modified arrayref
    return $sections;
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

A perl hash reference.  Note, that it is not checked for type, so it is
possible to add a "question" object into the list of sections.
$properties should never be a partial object, but contain all properties.

=cut

sub update {
    my $self    = shift;
    my ($address, $properties) = validate_pos(@_, { type => ARRAYREF }, {type => HASHREF});

    # Keep track of whether a new question is created along the way..
    my $newQuestion = 0;

    # Figure out what to do by counting the number of elements in the $address array ref
    my $count = @{$address};

    # First retrieve the addressed object, or, if necessary, create it
    my $object;
    if ( $count == 1 ) {
        $object = $self->section($address);
        if ( !defined $object ) {
            $object = $self->newSection();
            push @{ $self->{_sections} }, $object;
        }
    }
    elsif ( $count == 2 ) {
        $object = $self->question($address);
        if ( !defined $object ) {
            $object = $self->newQuestion();
            $newQuestion = 1; # make note that a new question was created
            push @{ $self->section($address)->{questions} }, $object;
        }
        # If questionType supplied, see if we need to update all of the answers to reflect the new questionType
        if ( $properties->{questionType} && $properties->{questionType} ne $object->{questionType} ) {
            $self->updateQuestionAnswers( $address, $properties->{questionType} );
        }
    }
    elsif ( $count == 3 ) {
        $object = $self->answer($address);
        if ( !defined $object ) {
            $object = $self->newAnswer();
            push @{ $self->question($address)->{answers} }, $object;
        }
    }

    $self->_handleSpecialAnswerUpdates($address,$properties); 

    my $validSectionProps = $self->newSection;
    my $validQuestionProps = $self->newQuestion;
    my $validAnswerProps = $self->newAnswer;
    
    # Update $object with all of the data in $properties
    while (my ($key, $value) = each %{$properties}) {
        if (defined $value) {
            $object->{$key} = $value;
        }
        
        # Only allow properties that we know about
        delete $object->{$key} if $count == 1 and !exists $validSectionProps->{$key};
        delete $object->{$key} if $count == 2 and !exists $validQuestionProps->{$key};
        delete $object->{$key} if $count == 3 and !exists $validAnswerProps->{$key};
    }

    return;
}

=head2 _handleSpecialAnswerUpdates

Private method. Handles special L<update> cases where answers need to be treated differently.

=cut

sub _handleSpecialAnswerUpdates {
    my $self = shift;
    my $address = shift;
    my $properties = shift;
    my $question = $self->question($address);
    if($question->{questionType} =~ /^Slider|Multi Slider - Allocate|Dual Slider - Range$/){
        for my $answer(@{$self->answers($address)}){
            $answer->{max} = $properties->{max};
            $answer->{min} = $properties->{min};
            $answer->{step} = $properties->{step};
        }
    }
}

=head2 insertObject ( $object, $address )

Rearrange existing objects in the current data structure. 
Does not return anything significant.

=head3 $object

A perl hash reference.  Note, that it is not checked for homegeneity,
so it is possible to add a "question" object into the list of section
objects.

=head3 $address

See L<"Address Parameter">. 

The number of elements in $address determines the behaviour:

=over 4

=item * 0 elements

Do Nothing

=item * 1 element

Reposition $object immediately after the indexed section

=item * 2 elements

Reposition $object immediately after the indexed question

=item * 3 elements

Reposition $object immediately after the indexed answer

=back

=cut

sub insertObject {
    my $self    = shift;
    my ($object, $address) = validate_pos(@_, {type => HASHREF}, { type => ARRAYREF });

    # Figure out what to do by counting the number of elements in the $address array ref
    my $count = @{$address};
    return if !$count;

    # Use splice to rearrange the relevant array of objects..
    if ( $count == 1 ) {
        splice @{ $self->{_sections} }, sIndex($address) +1, 0, $object;
        $address->[0]++;
    }
    elsif ( $count == 2 ) {
        splice @{ $self->section($address)->{questions} }, qIndex($address) + 1, 0, $object;
        $address->[1]++;
    }
    elsif ( $count == 3 ) {
        splice @{ $self->question($address)->{answers} }, aIndex($address) + 1, 0, $object;
        $address->[2]++;
    }

    return $address;
}

=head2 copy ( $address )

Duplicate the indexed section or question, and push the copy onto the end of the
list of existing items. Modifies $address. Returns $address with the last element changed 
to the highest index in that array.

=head3 $address

See L<"Address Parameter">. 

The number of elements in $address determines the behaviour:

=over 4

=item * 1 element

Duplice the indexed section onto the end of the array of sections.

=item * 2 elements

Duplice the indexed question onto the end of the array of questions.

=item * 3 elements, or more

Nothing happens. It is not allowed to duplicate answers.

=back

=cut

sub copy {
    my $self    = shift;
    my $address = shift;

    # Figure out what to do by counting the number of elements in the $address array ref
    my $count = @{$address};

    if ( $count == 1 ) {
        # Clone the indexed section onto the end of the list of sections..
        push @{ $self->{_sections} }, clone $self->section($address);

        # Update $address with the index of the newly created section
        $address->[0] = $self->lastSectionIndex;
    }
    elsif ( $count == 2 ) {
        # Clone the indexed question onto the end of the list of questions..
        push @{ $self->section($address)->{questions} }, clone $self->question($address);

        # Update $address with the index of the newly created question
        $address->[1] = $self->lastQuestionIndex($address);
    }
    elsif ( $count == 3 ) {
        # Clone the indexed answer onto the end of the list of answers..
        push @{ $self->question($address)->{answers} }, clone $self->answer($address);

        # Update $address with the index of the newly created answer
        $address->[2]++;
    }
    # Return the (modified) $address 
    return $address;
}

=head2 remove ( $address, $movingOverride )

Delete the section/question/answer indexed by $address. Modifies $address if it has 1 or more elements.

=head3 $address

See L<"Address Parameter">. 

The number of elements in $address determines the behaviour:

=over 4

=item * 1 element

Remove the indexed section. Normally, the first section, index 0, cannot be removed.  See $movingOverride below.

=item * 2 elements

Remove the indexed question

=item 3 elements

Remove the indexed answer

=back

=head3 $movingOverride

If $movingOverride is defined (meaning including 0 and ''), then the first section is allowed to be removed.

=cut

sub remove {
    my $self    = shift;
    my ($address, $movingOverride) = validate_pos(@_, { type => ARRAYREF }, 0);

    # Figure out what to do by counting the number of elements in the $address array ref
    my $count = @{$address};

    # Use splice to remove the indexed section/question/answer..
    if ( $count == 1 ) {
        # Make sure the first section isn't removed unless we REALLY want to
        if ( sIndex($address) != 0 || defined $movingOverride ) {
            splice @{ $self->{_sections} }, sIndex($address), 1;
        }
    }
    elsif ( $count == 2 ) {
        splice @{ $self->section($address)->{questions} }, qIndex($address), 1;
    }
    elsif ( $count == 3 ) {
        splice @{ $self->question($address)->{answers} }, aIndex($address), 1;
    }

    return;
}

=head2 newSection

Returns a reference to a new, empty section.

=cut

sub newSection {
    return {
        text                   => q{},
        title                  => 'NEW SECTION',    ##i18n
        variable               => q{},
        questionsPerPage       => 5,
        questionsOnSectionPage => 1,
        randomizeQuestions     => 0,
        logical                => 0,
        everyPageTitle         => 1,
        everyPageText          => 1,
        terminal               => 0,
        terminalUrl            => q{},
        goto                   => q{},
        gotoExpression         => q{},
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
        text             => q{},
        variable         => q{},
        allowComment     => 0,
        commentCols      => 10,
        commentRows      => 5,
        randomizeAnswers => 0,
        questionType     => 'Multiple Choice',
        randomWords      => q{},
        verticalDisplay  => 0,
        required         => 0,
        maxAnswers       => 1,
        value            => 1,
        textInButton     => 0,
        type             => 'question',
        answers          => [],
        goto             => q{},
        gotoExpression   => q{},
    };
}

=head2 newAnswer

Returns a reference to a new, empty answer.

=cut

sub newAnswer {
    return {
        text           => q{},
        verbatim       => 0,
        textCols       => 10,
        textRows       => 5,
        goto           => q{},
        gotoExpression => q{},
        recordedAnswer => q{},
        isCorrect      => 1,
        min            => 1,
        max            => 10,
        step           => 1,
        value          => 1,
        terminal       => 0,
        terminalUrl    => q{},
        type           => 'answer'
    };
}

=head2 updateQuestionAnswers ($address, $type);

Remove all existing answers and add a default set of answers to a question, based on question type.

=head3 $address

See L<"Address Parameter">. Determines question to add answers to.

=head3 $type

The question type determines how many answers to add and what answer text (if any) to use

=cut

sub updateQuestionAnswers {
    my $self    = shift;
    my ($address, $type) = validate_pos(@_, { type => ARRAYREF }, { type => SCALAR | UNDEF, optional => 1});

    # Make a private copy of the $address arrayref that we can use locally
    # when updating answer text without causing side-effects for the caller's $address
    my @address_copy     = @{$address};

    # Get the indexed question, and remove all of its existing answers
    my $question = $self->question($address);
    $question->{answers} = [];
    $question->{questionType} = $type;

    # Add the default set of answers. The question type determines both the number
    # of answers added and the answer text to use. When updating answer text
    # first update $address_copy to point to the answer

    if (   $type eq 'Date Range'
        or $type eq 'Multi Slider - Allocate'
        or $type eq 'Dual Slider - Range' )
    {
        push @{ $question->{answers} }, $self->newAnswer();
        push @{ $question->{answers} }, $self->newAnswer();
    }
    elsif ( $type eq 'Currency' ) {
        push @{ $question->{answers} }, $self->newAnswer();
        $address_copy[2] = 0;
        $self->update( \@address_copy, { 'text', 'Currency Amount:' } );
    }
    elsif ( $type eq 'Text Date' ) {
        push @{ $question->{answers} }, $self->newAnswer();
        $address_copy[2] = 0;
        $self->update( \@address_copy, { 'text', 'Date:' } );
    }
    elsif ( $type eq 'Phone Number' ) {
        push @{ $question->{answers} }, $self->newAnswer();
        $address_copy[2] = 0;
        $self->update( \@address_copy, { 'text', 'Phone Number:' } );
    }
    elsif ( $type eq 'Email' ) {
        push @{ $question->{answers} }, $self->newAnswer();
        $address_copy[2] = 0;
        $self->update( \@address_copy, { 'text', 'Email:' } );
    } 
    elsif ( $type eq 'Tagged' ) {
        # Tagged question should have no answers created for it
    } 
    elsif ( my $answerBundle = $self->getMultiChoiceBundle($type) ) {
        # We found a known multi-choice bundle. 
        # Add the bundle of multi-choice answers
        $self->addAnswersToQuestion( \@address_copy, $answerBundle );
    } else {
        # Default action is to add a single, default answer to the question
        push @{ $question->{answers} }, $self->newAnswer();
    }

    return;
}

=head2 getMultiChoiceBundle

Returns a list of answer objects for each multi-choice bundle.

=cut

sub getMultiChoiceBundle {
    my $self = shift;
    my ($type) = validate_pos( @_, { type => SCALAR | UNDEF } );

    # Return a cloned copy of the bundle structure
    return clone $self->{multipleChoiceTypes}->{$type};
}

=head2 addAnswersToQuestion ($address, $answers)

Helper routine for updateQuestionAnswers.  Adds an array of answers to a question.

=head3 $address

See L<"Address Parameter">. The address of the question to add answers to.

=head3 $answers

An array reference of answers to add.  Each element will be assigned to the text field of
the answer that is created.

=cut

sub addAnswersToQuestion {
    my $self = shift;
    my ( $address, $answers )
        = validate_pos( @_, { type => ARRAYREF }, { type => ARRAYREF } );

    # Make a private copy of the $address arrayref that we can use locally
    # when updating answer text without causing side-effects for the caller's $address
    my @address_copy = @{$address};

    for my $answer (@$answers) {
        # Add a new answer to question
        push @{ $self->question( \@address_copy )->{answers} }, $answer;
    }

    return;
}

=head2 sections

Returns a reference to all the sections in this object.

=cut

sub sections {
    my $self = shift;
    return $self->{_sections} || [];
}

=head2 mold

Accessor for the mold property. See L<compress> and L<uncompress> for more info on
what this property is used for.

=cut

sub mold {
    my $self = shift;
    return $self->{_mold};
}

=head2 lastSectionIndex

Convenience method to return the index of the last Section. Frequently used to 
iterate over all Sections. e.g. ( 0 .. lastSectionIndex )

=cut

sub lastSectionIndex {
    my $self = shift;
    return $self->totalSections(@_) - 1;
}

=head2 lastQuestionIndex

Convenience method to return the index of the last Question, overall, or in the 
given Section if $address given. Frequently used to  
iterate over all Questions. e.g. ( 0 .. lastQuestionIndex )

=head3 $address  (optional)

See L<"Address Parameter">.

=cut

sub lastQuestionIndex {
    my $self = shift;
    return $self->totalQuestions(@_) - 1;
}

=head2 lastAnswerIndex

Convenience method to return the index of the last Answer, overall, or in the 
given Question if $address given. Frequently used to  
iterate over all Answers. e.g. ( 0 .. lastAnswerIndex )

=head3 $address  (optional)

See L<"Address Parameter">.

=cut

sub lastAnswerIndex {
    my $self = shift;
    return $self->totalAnswers(@_) - 1;
}

=head2 totalSections

Returns the total number of Sections

=cut

sub totalSections {
    my $self = shift;
    return scalar @{ $self->sections };
}

=head2 totalQuestions ($address)

Returns the total number of Questions, overall, or in the given Section if $address given 

=head3 $address  (optional)

See L<"Address Parameter">.

=cut

sub totalQuestions {
    my $self    = shift;
    my $address = shift;

    if ($address) {
        return scalar @{ $self->questions($address) };
    } else {
        my $count = 0;
        for my $sIndex (0 .. $self->lastSectionIndex) {
            $count += $self->totalQuestions([$sIndex]);
        }
        return $count;
    }
}

=head2 totalAnswers ($address)

Returns the total number of Answers overall, or in the given Question if $address given

=head3 $address (optional)

See L<"Address Parameter">.

=cut

sub totalAnswers {
    my $self    = shift;
    my $address = shift;

    if ($address) {
        return scalar @{ $self->answers($address) };
    } else {
        my $count = 0;
        for my $sIndex (0 .. $self->lastSectionIndex) {
            for my $qIndex (0 .. $self->lastQuestionIndex([$sIndex])) {
                $count += $self->totalAnswers([$sIndex, $qIndex]);
            }
        }
        return $count;
    }
}

=head2 validateSurvey ()

Returns an array of messages to inform a user what is logically wrong with the Survey

=cut

sub validateSurvey{
    my $self = shift;

    my @messages;
    if (JSON->backend ne 'JSON::XS') {
        push @messages, "Your server is using @{[JSON->backend]} as its JSON backend. This may hurt performance on large Survey instances";
    }

    #set up valid goto targets 
    my $gotoTargets = $self->getGotoTargets();
    my $goodTargets = {};
    my $duplicateTargets;
    for my $g (@{$gotoTargets}) { 
        $goodTargets->{$g}++; 
        $duplicateTargets->{$g}++ if $goodTargets->{$g} > 1;
    }

    #step through each section validating it. 
    my $sections = $self->sections();

    for(my $s = 0; $s <= $#$sections; $s++){
        my $sNum = $s + 1;
        my $section = $self->section([$s]);
        if(! $self->validateGoto($section,$goodTargets)){
            push @messages,"Section $sNum has invalid Jump target: \"$section->{goto}\"";
        }
        if(! $self->validateGotoInfiniteLoop($section)){
            push @messages,"Section $sNum jumps to itself.";
        }
        if(my $error = $self->validateGotoExpression($section,$goodTargets)){
            push @messages,"Section $sNum has invalid Jump Expression: \"$section->{gotoExpression}\". Error: $error";
        }
        if(my @errors = $self->validateGotoPrecedenceRules($section, $section->{variable} || $sNum)){
            push @messages,@errors;
        }
        if (my $var = $section->{variable}) {
            if (my $count = $duplicateTargets->{$var}) {
                push @messages, "Section $sNum variable name $var is re-used in $count other place(s).";
            }
        }
        if($section->{logical} and @{$self->questions([$s])} > 0){
            push @messages, "Section $sNum is a logical section with questions.  Those questions will never be shown.";
        }

        #step through each question validating it. 
        my $questions = $self->questions([$s]);
        for(my $q = 0; $q <= $#$questions; $q++){
            my $qNum = $q + 1;
            my $question = $self->question([$s,$q]);
            if(! $self->validateGoto($question,$goodTargets)){
                push @messages,"Section $sNum Question $qNum has invalid Jump target: \"$question->{goto}\"";
            }
            if(! $self->validateGotoInfiniteLoop($question)){
                push @messages,"Section $sNum Question $qNum jumps to itself.";
            }
            if(my $error = $self->validateGotoExpression($question,$goodTargets)){
                push @messages,"Section $sNum Question $qNum has invalid Jump Expression: \"$question->{gotoExpression}\". Error: $error";
            }
            if($#{$question->{answers}} < 0 && $question->{questionType} ne 'Tagged'){
                push @messages,"Section $sNum Question $qNum does not have any answers.";
            }
            if(! $question->{text} =~ /\w/){
                push @messages,"Section $sNum Question $qNum does not have any text.";
            }
            if (my $var = $question->{variable}) {
                if (my $count = $duplicateTargets->{$var}) {
                    push @messages, "Section $sNum Question $qNum variable name $var is re-used in $count other place(s).";
                }
            }

            #step through each answer validating it. 
            my $answers = $self->answers([$s,$q]);
            for(my $a = 0; $a <= $#$answers; $a++){
                my $aNum = $a + 1;
                my $answer = $self->answer([$s,$q,$a]);
                if(! $self->validateGoto($answer,$goodTargets)){
                    push @messages,"Section $sNum Question $qNum Answer $aNum has invalid Jump target: \"$answer->{goto}\"";
                }
                if(! $self->validateGotoInfiniteLoop($answer)){
                    push @messages,"Section $sNum Question $qNum Answer $aNum jumps to itself.";
                }
                if(my $error = $self->validateGotoExpression($answer,$goodTargets)){
                    push @messages,"Section $sNum Question $qNum Answer $aNum has invalid Jump Expression: \"$answer->{gotoExpression}\". Error: $error";
                }
            }
        }
    }

   return \@messages; 
}

=head2 validateGoto

Performs validation on a goto target. See L<validateSurvey>.

Checks that the goto variable exists.

=cut

sub validateGoto{
    my $self = shift;
    my $object = shift;
    my $goodTargets = shift;
    return 0 if($object->{goto} =~ /\w/ && ! exists($goodTargets->{$object->{goto}}));
    return 1;
}

=head2 validateGotoInfiniteLoop

Performs validation on a goto target. See L<validateSurvey>.

Checks that the goto variable does not introduce an infinite loop.

=cut

sub validateGotoInfiniteLoop{
    my $self = shift;
    my $object = shift;
    return 0 if($object->{goto} =~ /\w/ and $object->{goto} eq $object->{variable});
    return 1;
}

=head2 validateGotoExpression

Performs validation on a goto expression. See L<validateSurvey>.

=cut

sub validateGotoExpression{
    my $self = shift;
    my $object = shift;
    my $goodTargets = shift;
    return unless $object->{gotoExpression};

    if (!$self->session->config->get('enableSurveyExpressionEngine')) {
        return 'enableSurveyExpressionEngine is disabled in your site config!';
    }

    my $engine = "WebGUI::Asset::Wobject::Survey::ExpressionEngine";
    return $engine->run($self->session, $object->{gotoExpression}, { validate => 1, validTargets => $goodTargets } );
}

=head2 validateGotoPrecedenceRules

Performs validation on a section. See L<validateSurvey>.

Emits a warning if a section (and nested questions/answers) contains more than one goto/gotoExpression,
which usually indicates an error.

=cut

sub validateGotoPrecedenceRules {
    my $self = shift;
    my $s = shift;
    my $sLabel = shift;
    my @errors;
    my $endMsg = 'Precedence rules will apply.';

    my $hasSection
        = $s->{goto}           =~ /\w/ ? 'Jump Target'
        : $s->{gotoExpression} =~ /\w/ ? 'Jump Expression'
        :                                '';
    my $qNum = 0;
    for my $q (@{$s->{questions}}) {
        $qNum++;
        my $qLabel = $q->{variable} || "Question $qNum";
        my $hasQuestion
            = $q->{goto}           =~ /\w/ ? 'Jump Target'
            : $q->{gotoExpression} =~ /\w/ ? 'jump Expression'
            :                                '';
        if ( $hasSection && $hasQuestion) {
            push @errors, "You have a $hasSection at $sLabel and a $hasQuestion at $qLabel. $endMsg";
        }
        my $aNum = 0;
        for my $a (@{$q->{answers}}) {
            $aNum++;
            my $aLabel = "Answer $aNum";
            my $hasAnswer
                = $a->{goto}           =~ /\w/ ? 'Jump Target'
                : $a->{gotoExpression} =~ /\w/ ? 'Jump Expression'
                :                                '';
            if ( $hasSection && $hasAnswer) {
                push @errors, "You have a $hasSection at $sLabel and a $hasAnswer at $aLabel. $endMsg";
            }
            if ( $hasQuestion && $hasAnswer) {
                push @errors, "You have a $hasQuestion at $qLabel and a $hasAnswer at $aLabel. $endMsg";
            }
        }
    }
    return @errors;
}

=head2 section ($address)

Returns a reference to one section.

=head3 $address

See L<"Address Parameter">.

=cut

sub section {
    my $self    = shift;
    my $address = shift;

    return $self->sections->[ $address->[0] ];
}

=head2 session

Accessor method for the local WebGUI::Session reference

=cut

sub session {
    my $self    = shift;
    return $self->{_session};
}

=head2 questions ($address)

Returns a reference to all the questions from a particular section.

=head3 $address (optional)

See L<"Address Parameter">. If not defined, returns all questions.

=cut

sub questions {
    my $self    = shift;
    my $address = shift;

    if ($address) {
        return $self->sections->[ $address->[0] ]->{questions} || [];
    } else {
        my $questions;
        push @$questions, @{$_->{questions} || []} for @{$self->sections};
        return $questions || [];
    }
}

=head2 question ($address)

Return a reference to one question from a particular section.

=head3 $address

See L<"Address Parameter">.

=cut

sub question {
    my $self    = shift;
    my $address = shift;

    return $self->sections->[ $address->[0] ]->{questions}->[ $address->[1] ];
}

#-------------------------------------------------------------------

=head2 questionCount (){

Return the total number of questions in this survey.

=cut

sub questionCount {
    my $self    = shift;
    my $count;
    for ( my $s = 0; $s <= $#{ $self->sections() }; $s++ ) {
        $count = $count + scalar @{$self->questions( [$s] )};
    }
    return $count;
}

#-------------------------------------------------------------------

=head2 answers ($address)

Return a reference to all answers from a particular question.

=head3 $address

See L<"Address Parameter">.

=cut

sub answers {
    my $self    = shift;
    my $address = shift;

    return $self->sections->[ $address->[0] ]->{questions}->[ $address->[1] ]->{answers} || [];
}

=head2 answer ($address)

Return a reference to one answer from a particular question and section.

=head3 $address

See L<"Address Parameter">.

=cut

sub answer {
    my $self    = shift;
    my $address = shift;

    return $self->sections->[ $address->[0] ]->{questions}->[ $address->[1] ]->{answers}->[ $address->[2] ];
}

=head2 sIndex ($address)

Convenience sub to extract the section index from a standard $address parameter. See L<"Address Parameter">.
This method exists purely to improve code readability.

=cut

sub sIndex { $_[0][0] }

=head2 qIndex ($address)

Convenience sub to extract the question index from a standard $address parameter. See L<"Address Parameter">.
This method exists purely to improve code readability.

=cut

sub qIndex { $_[0][1] }

=head2 aIndex ($address)

Convenience sub to extract the answer index from a standard $address parameter. See L<"Address Parameter">.
This method exists purely to improve code readability.

=cut

sub aIndex { $_[0][2] }

1;
