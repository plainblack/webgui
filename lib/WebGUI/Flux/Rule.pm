package WebGUI::Flux::Rule;

use strict;
use Class::InsideOut qw{ :std };
use WebGUI::Exception::Flux;
use WebGUI::Flux::Expression;
use Readonly;
use WebGUI::DateTime;
use English qw( -no_match_vars );
use WebGUI::Workflow::Instance;
use List::MoreUtils qw(all);
use Params::Validate qw(:all);
Params::Validate::validation_options( on_fail => sub { WebGUI::Error::InvalidParam->throw( error => shift ) } );

my $recursiveDepthCounter = 0;    # Used as an extra (hopefully never needed) guard against infinite loops

=head1 NAME
Package WebGUI::Flux::Rule;
=head1 DESCRIPTION

Rule to be used as part of Flux rule-based authorisation layer for WebGUI 

Flux Rules are comprised of one or more Boolean Expressions. Rules and Expressions are
manipulated by content managers through a simple graphical interface. The power of Flux
lies in the fact that Rules can be based on user-specific, date-specific and/or Wobject-
specific information. Rules can also depend on other Rules, meaning that we end up with a
Flux Graph of interconnected Rules. Workflow triggers are built-in, and Flux is designed to
be modular with many plug-in points, making the system truly extensible.


As per the standard WebGUI API:

=over 4

=item * use create() to instantiate a new object and immediately persist it to the database

=item * use new() to instantiate an existing object (retrieved from the db by id)

=item * use $obj->get('field') to retrieve properties

=item * use $obj->update() to update properties (immediately persisted to db)

=item * use delete() to remove the object from persistent storage

=back

=head1 SYNOPSIS

 use WebGUI::Flux::Rule;

 # create new Rule
 my $rule = WebGUI::Flux::Rule->create($session, 
    {   name => 'My Rule',
        sticky => 1,
        # other properties..
    }
 );
 
 # instantiate an existing Rule
 my $rule2 = WebGUI::Flux::Rule->new($session, $rule->getId());
 
=head1 METHODS

These subroutines are available from this package:

=cut

# InsideOut object properties
readonly session              => my %session;                 # WebGUI::Session object
private property              => my %property;                # Hash of object properties
private expressionCache       => my %expressionCache;         # (hash) cache of WebGUI::Flux::Expression objects
readonly evaluatingForUser    => my %evaluatingForUser;       # Set to a WebGUI::User when Rule is being evaluated
readonly evaluatingForAssetId => my %evaluatingForAssetId;    # Set to an assetId when Rule is being evaluated
readonly evaluationInfo       => my %evaluationInfo;          # Evaluation info
readonly resolvedRuleCache    => my %resolvedRuleCache;       # (hash) cache of resolved WebGUI::Rules
readonly unresolvedRuleCache  => my %unresolvedRuleCache;     # (hash) cache of currently unresolved WebGUI::Rules

# Default values used in create() method
Readonly my %FIELD_DEFAULTS => (
    name   => 'Undefined',
    sticky => 0,
);

# Properties/db fields that can be updated via update() method
Readonly my @MUTABLE_FIELDS => qw(
    name                        sticky
    onRuleFirstTrueWorkflowId   onRuleFirstFalseWorkflowId
    onAccessFirstTrueWorkflowId onAccessFirstFalseWorkflowId
    onAccessTrueWorkflowId      onAccessFalseWorkflowId
    combinedExpression          sequenceNumber
);

# Regex used to 'whitelist' combined expression tokens
Readonly my $TOKEN_WHITELIST => qr{
        \( |        # left parens, or 
        \) |        # right parens, or
        \b          # word boundary followed by..
         (?:       
            and |   # AND token
            or |   # OR token
            not |   # NOT token
            e(\d+)  # expression token (capture the number)
         )
        \b          # ..followed by word boundary
  }ix;

#-------------------------------------------------------------------

=head2 addExpression ( properties )

Adds an expression to the Flux Rule.  Returns a reference to the WebGUI::Flux::Expression
object that was created.  It does not trap exceptions, so any problems with creating
the object will be passed to the caller.

=head2 properties

A hash reference containing properties that you would pass to C<WebGUI::Flux::Expression->create()>

=cut

sub addExpression {
    return WebGUI::Flux::Expression->create(@_);
}

#-------------------------------------------------------------------

=head2 create ( session, $properties_ref )

Constructor. Creates a new Flux Rule and returns it.
Refer to C<new()> if instead you want To instantiate an existing rule.

=head3 session

A reference to the current session.

=head3 $properties_ref

A hash reference containing the properties to set on the Rule.

=cut

sub create {
    my $class = shift;
    my ( $session, $properties_ref )
        = validate_pos( @_, { isa => 'WebGUI::Session' }, { type => HASHREF, default => {} } );

    # Work out the next highest sequence number
    my $sequenceNumber = $session->db->quickScalar('select max(sequenceNumber) from fluxRule');
    $sequenceNumber = $sequenceNumber ? $sequenceNumber + 1 : 1;
    
    my @expressions = $properties_ref->{expressions} ? @{delete $properties_ref->{expressions}} : ();

    # Create a bare-minimum entry in the db..
    my $id = $session->db->setRow(
        'fluxRule', 'fluxRuleId',
        { %FIELD_DEFAULTS, fluxRuleId => 'new', sequenceNumber => $sequenceNumber },
        $properties_ref->{fluxRuleId},    # specified fluxRuleID will be used if provided
    );

    delete $properties_ref->{fluxRuleId};    # doesn't need to be passed to update (below)

    # (re-)retrieve entry
    my $rule = $class->new( $session, $id );
    
    # add any supplied Expressions (do this before calling update so that the user can
    # specify combinedExpressions in the same call and not have an exception thrown)
    for my $expression (@expressions) {
        $rule->addExpression($expression);
    }
    
    # and finally, update with any user-supplied options
    $rule->update($properties_ref);

    return $rule;
}

#-------------------------------------------------------------------

=head2 resetCombinedExpression ( )

Any change to a Rule's expressions should result in a call to this method
to reset the combined expression. This might be improved at a later date to
make it handle expression changes intelligently.

=cut

sub resetCombinedExpression {
    my $self = shift;
    $self->update( { combinedExpression => undef } );
    return;
}

#-------------------------------------------------------------------

=head2 delete ()

Deletes this Flux Rule and all expressions contained in it.

=cut

sub delete {
    my $self = shift;
    foreach my $expression ( @{ $self->getExpressions } ) {
        $expression->delete;
    }
    $self->session->db->write( 'delete from fluxRuleUserData where fluxRuleId = ?', [ $self->getId() ] );
    $self->session->db->deleteRow( 'fluxRule', 'fluxRuleId', $self->getId() );
    undef $self;
    return undef;
}

#-------------------------------------------------------------------

=head2 get ( [ property ] )

Returns a duplicated hash reference of this object’s data.

=head3 property

Any field − returns the value of a field rather than the hash reference.  See the 
L<update> method.

=cut

sub get {
    my $self = shift;
    my ($name) = validate_pos( @_, 0 );
    if ( defined $name ) {
        return $property{ id $self}{$name};
    }
    my %copyOfHashRef = %{ $property{ id $self} };
    return \%copyOfHashRef;
}

#-------------------------------------------------------------------

=head2 getMutableFields ( )

Returns the list of mutable fields

=cut

sub getMutableFields {
    return @MUTABLE_FIELDS;
}

#-------------------------------------------------------------------

=head2 getFieldDefaults ( )

Returns the hash of field default values

=cut

sub getFieldDefaults {
    return %FIELD_DEFAULTS;
}

#-------------------------------------------------------------------

=head2 getExpression ( id )

Returns an expression object.

=head3 id

An expression object's unique id.

=cut

sub getExpression {
    my $self = shift;
    my ($expressionId) = validate_pos( @_, 1 );
    my $id = id $self;

    if ( !exists $expressionCache{$id}{$expressionId} ) {
        $expressionCache{$id}{$expressionId} = WebGUI::Flux::Expression->new( $self, $expressionId );
    }

    return $expressionCache{$id}{$expressionId};
}

#-------------------------------------------------------------------

=head2 getExpressionCount ( )

Returns the number of Expressions in this Rule.

=cut

sub getExpressionCount {
    my $self              = shift;
    my @expressionObjects = ();
    my $count = $self->session->db->quickScalar( 'select count(*) from fluxExpression where fluxRuleId=?',
        [ $self->getId ] );
    return $count;
}

#-------------------------------------------------------------------

=head2 getExpressions ( )

Returns an array reference of expression objects that are in this Rule.

=cut

sub getExpressions {
    my $self              = shift;
    my @expressionObjects = ();
    my $expressions
        = $self->session->db->read(
        'select fluxExpressionId from fluxExpression where fluxRuleId=? order by sequenceNumber',
        [ $self->getId ] );
    while ( my ($expressionId) = $expressions->array ) {
        push @expressionObjects, $self->getExpression($expressionId);
    }
    return \@expressionObjects;
}

#-------------------------------------------------------------------

=head2 getId ()

Returns the unique id for this Rule.

=cut

sub getId {
    my $self = shift;
    return $self->get('fluxRuleId');
}

#-------------------------------------------------------------------

=head2 new ( session, id )

Constructor.  Instantiates an existing Rule based upon a fluxRuleId and returns it.
Refer to C<create> if you want to create a new Rule.  

=head3 session

A reference to the current session.

=head3 id

The unique id of a Flux Rule to instantiate.

=cut

sub new {
    my $class = shift;
    my ( $session, $ruleId ) = validate_pos( @_, { isa => 'WebGUI::Session' }, 1 );

    # Retreive row from db..
    my $rule = $session->db->quickHashRef( 'select * from fluxRule where fluxRuleId=?', [$ruleId] );
    if ( !exists $rule->{fluxRuleId} || $rule->{fluxRuleId} eq q{} ) {
        WebGUI::Error::ObjectNotFound->throw( error => "No such Flux Rule: $ruleId", id => $ruleId );
    }

    # Register Class::InsideOut object..
    my $self = register $class;

    # Initialise object properties..
    my $id = id $self;
    $session{$id}             = $session;
    $property{$id}            = $rule;
    $resolvedRuleCache{$id}   = {};                        # cache initially empty
    $unresolvedRuleCache{$id} = { $ruleId => $ruleId };    # this rule initially unresolved
    $evaluationInfo{$id}      = {};

    return $self;
}

#-------------------------------------------------------------------

=head2 update ( properties )

Sets properties in the Rule

=head3 properties

A hash reference that contains one of the following:

=head4 name

The name of the Rule

=head4 sticky

Whether authorisation on the Rule is sticky

=head4 onRuleFirstTrueWorkflowId   

Workflow to run when Rule first False

=head4 onRuleFirstFalseWorkflowId

Workflow to run when Rule first False

=head4 onAccessFirstTrueWorkflowId 

Workflow to run when Access first False

=head4 onAccessFirstFalseWorkflowId

Workflow to run when Access first False

=head4 onAccessTrueWorkflowId      

Workflow to run when Access True

=head4 onAccessFalseWorkflowId

Workflow to run when Access False

=head4 sequenceNumber

The Rule's order (defines its 'E' number)
    
=head4 combinedExpression

The combined expression

=cut

sub update {
    my $self            = shift;
    my %validation_spec = map { $_ => 0 } @MUTABLE_FIELDS;
    my %args            = validate( @_, \%validation_spec );  # only allows MUTABLE_FIELDS as optional named params

    # Special filtering for combinedExpression..
    if ( defined $args{combinedExpression} ) {

        # Check for validity (throws an exception if not)
        checkCombinedExpression( $args{combinedExpression}, $self->getExpressionCount() );

        # Convert to lower-case
        $args{combinedExpression} = lc $args{combinedExpression};
    }

    my $id = id $self;
    foreach my $field (@MUTABLE_FIELDS) {
        $property{$id}{$field} = ( exists $args{$field} ) ? $args{$field} : $property{$id}{$field};
    }
    return $self->session->db->setRow( 'fluxRule', 'fluxRuleId', $property{$id} );
}

#-------------------------------------------------------------------

=head2 evaluateFor ( options )

Evaluates the Flux Rule for the given user

=head3 options

A hash ref of options.

=head4 user

A WebGUI::User object corresponding to the user who the Rule is being evaluated against (required)

=head4 assetId (optional)

The assetId of the asset/wobject for which the Rule is being evaluated for 

=head4 access (optional)

Indicates that this Rule is being evaluated as a result of the user trying to
directly perform a wobject action, as opposed to non-access such as a general 
sweep of the Rules to generate the Flux Graph or a scheduled workflow. 
This field determines which fluxRuleUserData datetime fields are updated.

Defaults to true.

=head4 recursive (optional)

Indicates that this Rule is being evaluated as part of a recursive call
by another Rule.

Defaults to false.
 
=cut

sub evaluateFor {
    my $self = shift;
    my %args = validate(
        @_,
        {   user      => { isa     => 'WebGUI::User' },
            assetId   => 0,
            access    => { default => 1 },
            recursive => { default => 0 }
        }
    );

    # Cache $id for speed
    my $id = id $self;

    if ( $args{recursive} ) {

        # Should not be possible for $recursiveDepthCounter to exceed 1, but check anyway
        # as a double-guard against infinite loops..
        if ( $recursiveDepthCounter++ > 1 ) {
            WebGUI::Error::Flux::CircularRuleLoopDetected->throw(
                error            => 'MAX_DEPTH exceeded. Do you have a circular Rule loop?',
                sourceFluxRuleId => $self->getId(),
            );
        }
    }

    # Take note of which user we're evaluating the Rule for..
    my $user = $args{user};
    $evaluatingForUser{$id} = $user;

    # Take note of which asset we're evaluating the Rule for (if set)..
    $evaluatingForAssetId{$id} = $args{assetId};

    # Take note of whether this is a recursive call or not..
    $evaluationInfo{$id}{is_recursive} = $args{recursive};

    # Take note of whether this is wobject access or not..
    $evaluationInfo{$id}{is_access} = $args{access};

    # Rule with no expressions defaults to true
    if ( $self->getExpressionCount() == 0 ) {
        $self->session->log->info('Rule has no expressions, defaulting to true');
        return $self->_finishEvaluating(1);
    }

    # Check if we can apply the sticky optimisation..
    if ( $property{$id}{sticky} ) {
        my $dateRuleFirstTrue
            = $self->session->db->quickScalar(
            'select dateRuleFirstTrue from fluxRuleUserData where fluxRuleId=? and userId=?',
            [ $self->getId(), $user->userId() ] );

        if ($dateRuleFirstTrue) {
            $self->session->log->debug('Sticky and previously true, no need to evaluate');
            return $self->_finishEvaluating(1);
        }
    }

    # Shucks, looks like we need to actually evaluate the Rule..
    my $was_successful;
    my $combined_expression = $property{$id}{combinedExpression};
    if ( !$combined_expression ) {

        # No combined expression defined so just AND them all together

=for Workaround
The most elegant way to do it would be:
 $was_successful = all { $_->evaluate() } @{ $self->getExpressions() };
However in some weird cases (covered by test suite) we get an exception
thrown: "Not a subroutine reference". No idea why.. works if you turn off 
the XS version of List::MoreUtils by setting the environment 
variable: LIST_MOREUTILS_PP

=cut 

        $was_successful = 1;
    EVALUATE:
        foreach my $exp ( @{ $self->getExpressions() } ) {
            if ( !$exp->evaluate() ) {
                $was_successful = 0;
                last EVALUATE;
            }
        }
    }
    else {

        # Combined expression in use, so first parse it..
        my $parsed_combined_expression = _parseCombinedExpression($combined_expression);

        # ..and also create a lexical array of expressions (1-indexed, used by eval string)
        my @expressions = @{ $self->getExpressions() };
        unshift @expressions, 'dummy entry';    # add a dummy entry to the front to make it 1-indexed

        # ..and finally eval the parsed combined expression and rely on Perl for error-catching
        {
            no warnings 'all';                  # silence perl
            $was_successful = eval("($parsed_combined_expression)");
        }
        my $error = $EVAL_ERROR; # Make a copy of the error before we proceed..
        if ( my $e = Exception::Class->caught() ) {
            $self->resetEvaluationInfo();
            $e->rethrow() if ref $e;            # Re-throw Exception::Class errors for other code to catch
        }
        if ($error) {
            WebGUI::Error::Flux::InvalidCombinedExpression->throw(
                error                    => $error,
                combinedExpression       => $combined_expression,
                parsedCombinedExpression => $parsed_combined_expression,
            );
        }
    }

    # We've finished evaluating now
    return $self->_finishEvaluating($was_successful);
}

#-------------------------------------------------------------------

=head2 _finishEvaluating ( result )

Clean up after evaluating (update fluxRuleUserData table and
reset caches).

=head3 result

The boolean status of the Rule evaluation
 
=cut

sub _finishEvaluating {
    my $self = shift;
    my ($result) = validate_pos( @_, 1 );

    # Update the fluxRuleUserData table
    $self->_updateDataAndTriggerWorkflows($result);

    # Clear evaluation-data
    $self->resetEvaluationInfo();

    return $result;
}

#-------------------------------------------------------------------

=head2 resetEvaluationInfo ( )

Clean up
 
=cut

sub resetEvaluationInfo {
    my $self = shift;
    my $id   = id $self;

    delete $evaluatingForUser{$id};
    delete $evaluatingForAssetId{$id};

    # We clean up a lot more if this is a non-recursive evaluation so
    # that Rule is returned to a pristine state
    # N.B. This is bad for performance if people want to evaluate the same
    # rule twice, but that shouldn't really happen in a single request, and it
    # leads to weird behaviour of rules if they are modified between
    # evaluations (caches get stale).
    my $is_recursive = $evaluationInfo{$id}{is_recursive};
    if ( !$is_recursive ) {

        # Reset the resolved/unresolved Rule Caches too..
        my $rule_id = $self->getId();
        $resolvedRuleCache{$id}   = {};
        $unresolvedRuleCache{$id} = { $rule_id => $rule_id };
        $recursiveDepthCounter    = 0;
    }
    $evaluationInfo{$id} = {};
}

#-------------------------------------------------------------------

=head2 checkCombinedExpression ( )

Do some basic sanity checking and whitelisting on the combined expression. 
All we really care is that the expression is not dangerous (since it is passed to eval).
We don't go to any great lengths to check validity since it is easier to let perl do it and 
just catch any errors from eval. 

=cut

sub checkCombinedExpression {
    my ( $combined_expression, $expression_count ) = validate_pos( @_, 1, 1 );

    # Undefined combined expression is valid
    return 1 if !defined $combined_expression;

    # Trim whitespace
    $combined_expression =~ s/^\s+|\s+$//g;

    # Split combined expression up at whitespace and check tokens
    foreach my $token ( split /\s+/, $combined_expression ) {

        # Check that the combined expression passes our whitelist
        if ( $token !~ m/$TOKEN_WHITELIST/ ) {
            WebGUI::Error::Flux::InvalidCombinedExpression->throw(
                error              => "Invalid token in Combined Expression: $token",
                combinedExpression => $combined_expression,
            );
        }

        # Furthermore, check the expression number (captured via regexp) is valid..
        if ( defined $1 && ( $1 == 0 || $1 > $expression_count ) ) {
            WebGUI::Error::Flux::InvalidCombinedExpression->throw(
                error              => "Token does not refer to valid Expression in Combined Expression: $token",
                combinedExpression => $combined_expression,
            );
        }
    }
    return 1;
}

#-------------------------------------------------------------------

=head2 _parseCombinedExpression ( )

Parses a combined expression into a form that can be passed to eval.
The parsed string is very tightly coupled to our internal code. In particular,
we assume the existence of an array called @expressions that contains the result
of @{$self->getExpressions()} (first element at index 1 for convenience). 
The parsed string indexes this array and calls evaluate() on each element .

An expression of the form: 'e1 and e2' gets converted into:
'$expressions[1]->evaluate() and $expressions[2]->evaluate()'

The reason this regexp is separated out into a subroutine of its own at all is
so that we can test it.

=cut

sub _parseCombinedExpression {
    my ($combined_expression) = validate_pos( @_, 1 );

    # Apply the magic regex
    $combined_expression =~ s/e(\d+)/\$expressions[$1]->evaluate()/gx;

    return $combined_expression;
}

#-------------------------------------------------------------------

=head2 _updateDataAndTriggerWorkflows ( $success )

Updates the rule/user row in the fluxRuleUserData table after a Rule is
evaluated. Uses the boolean outcome of the Rule ($success) to
determine which fields need to be updated (dateRuleFirstTrue, 
dateAccessFirstTrue, etc..).

Also triggers any related Workflows.

=head3 $success

The boolean status of the Rule evaluation

=cut

sub _updateDataAndTriggerWorkflows {
    my $self = shift;
    my ($success) = validate_pos( @_, 1 );
    my $id = id $self;

    my $is_access = $evaluationInfo{$id}{is_access};

    # Check for entry in fluxRuleUserData table
    my $user     = $evaluatingForUser{$id};
    my %userData = %{
        $self->session->db->quickHashRef( 'select * from fluxRuleUserData where fluxRuleId=? and userId=?',
            [ $self->getId(), $user->userId() ] )
        };

    # Most updates will involve setting datetime fields to now()
    my $dt = WebGUI::DateTime->new(time)->toDatabase();

    # Along the way, keep track of..
    my $db_write_required;    # whether we need to write to the db
    my %trigger_workflow;     # what workflows need to be triggered

    my %field_updates = (
        fluxRuleUserDataId => $userData{fluxRuleUserDataId},    # may not exist
        fluxRuleId         => $self->getId(),
        userId             => $user->userId(),
    );

    # Has rule ever been checked for this user?
    if ( !exists $userData{fluxRuleUserDataId} ) {
        $db_write_required                   = 1;
        $field_updates{fluxRuleUserDataId}   = 'new';
        $field_updates{dateRuleFirstChecked} = $dt;
        $self->session->log->debug('Updating dateRuleFirstChecked');
    }

    # True for the first time?
    if ( $success && !$userData{dateRuleFirstTrue} ) {
        $db_write_required                = 1;
        $field_updates{dateRuleFirstTrue} = $dt;
        $trigger_workflow{RuleFirstTrue}  = 1;
        $self->session->log->debug('Updating dateRuleFirstTrue');
    }

    # False for the first time?
    if ( !$success && !$userData{dateRuleFirstFalse} ) {
        $db_write_required                 = 1;
        $field_updates{dateRuleFirstFalse} = $dt;
        $trigger_workflow{RuleFirstFalse}  = 1;
        $self->session->log->debug('Updating dateRuleFirstFalse');
    }

    # Direct access?
    if ($is_access) {
        $db_write_required = 1;

        # N.B. dateAccessMostRecentlyTrue/False currently disabled
        # - may not be needed by anyone and causes extra db writes
        if ($success) {
#            $field_updates{dateAccessMostRecentlyTrue} = $dt;
#            $self->session->log->debug('Updating dateAccessMostRecentlyTrue');
            $trigger_workflow{AccessTrue}              = 1;
        }
        else {
#            $field_updates{dateAccessMostRecentlyFalse} = $dt;
#            $self->session->log->debug('Updating dateAccessMostRecentlyFalse');
            $trigger_workflow{AccessFalse}              = 1;
        }

        # First direct access attempt?
        if ( !$userData{dateAccessFirstAttempted} ) {
            $field_updates{dateAccessFirstAttempted} = $dt;
            $self->session->log->debug('Updating dateAccessFirstAttempted');
        }

        # True for the first time?
        if ( $success && !$userData{dateAccessFirstTrue} ) {
            $field_updates{dateAccessFirstTrue} = $dt;
            $trigger_workflow{AccessFirstTrue}  = 1;
            $self->session->log->debug('Updating dateAccessFirstTrue');
        }
        if ( !$success && !exists $userData{dateAccessFirstFalse} ) {
            $field_updates{dateAccessFirstFalse} = $dt;
            $trigger_workflow{AccessFirstFalse}  = 1;
            $self->session->log->debug('Updating dateAccessFirstFalse');
        }
    }

    # Only write to the db if we have updates to make..
    if ($db_write_required) {
        $self->session->db->setRow( 'fluxRuleUserData', 'fluxRuleUserDataId', \%field_updates );
    }

    # Trigger any workflows that are needed..
    foreach my $w ( keys %trigger_workflow ) {
        my $full_workflow_name = 'on' . $w . 'WorkflowId';
        if ( my $workflowId = $self->get($full_workflow_name) ) {
            $self->session->log->debug("Triggering $full_workflow_name ($workflowId)");
            my $user_id = $evaluatingForUser{$id}->userId();
            WebGUI::Workflow::Instance->create(
                $self->session,
                {   workflowId => $workflowId,
                    methodName => "new",
                    className  => "WebGUI::Workflow::Instance::GenericObject",
                    parameters => { userId => $user_id, fluxRuleId => $self->getId() },
                }
                )->start( !$ENV{FLUX_REALTIME_WORKFLOWS} );

=for Workaround

By default we start workflow instances with the skipRealtime flag preset, because
there is a segfault bug that rears its head when a workflow triggers itself recursively 
in realtime mode under load. The ENV flag is used here because it's handy to be able to run 
in realtime mode for tests, just for speed reasons.

=cut

        }
    }
}

#-------------------------------------------------------------------

=head2 hasResolvedRuleCached ( $fluxRuleId )

Returns true/false depending on whether this Rule has
the given fluxRuleId stored in its resolved rule cache
 
=cut

sub hasResolvedRuleCached {
    my $self = shift;
    my ($fluxRuleId) = validate_pos( @_, 1 );
    return exists $resolvedRuleCache{ id $self}{$fluxRuleId};
}

#-------------------------------------------------------------------

=head2 hasUnresolvedRuleCached ( $fluxRuleId )

Returns true/false depending on whether this Rule has
the given fluxRuleId stored in its unresolved rule cache
 
=cut

sub hasUnresolvedRuleCached {
    my $self = shift;
    my ($fluxRuleId) = validate_pos( @_, 1 );
    return exists $unresolvedRuleCache{ id $self}{$fluxRuleId};
}

#-------------------------------------------------------------------

=head2 getResolvedRuleResult ( $fluxRuleId )

Returns the cached rule result for $fluxRuleId stored in this
Rule's resolved rule cache
 
=cut

sub getResolvedRuleResult {
    my $self = shift;
    my ($fluxRuleId) = validate_pos( @_, 1 );
    return $resolvedRuleCache{ id $self}{$fluxRuleId};
}

#-------------------------------------------------------------------

=head2 cacheRuleAsResolved ( $fluxRuleId, $result )

Stores the given rule and result in this Rule's resolved rule cache
 
=cut

sub cacheRuleAsResolved {
    my $self = shift;
    my ( $fluxRuleId, $result ) = validate_pos( @_, 1, 1 );
    delete $unresolvedRuleCache{ id $self}{$fluxRuleId};
    $resolvedRuleCache{ id $self}{$fluxRuleId} = $result;
}

#-------------------------------------------------------------------

=head2 cacheRuleAsUnresolved ( $fluxRuleId )

Stores the given rule in this Rule's unresolved rule cache
 
=cut

sub cacheRuleAsUnresolved {
    my $self = shift;
    my ($fluxRuleId) = validate_pos( @_, 1 );
    delete $resolvedRuleCache{ id $self}{$fluxRuleId};    # generally won't exist anyway
    $unresolvedRuleCache{ id $self}{$fluxRuleId} = $fluxRuleId;
}

#-------------------------------------------------------------------

=head2 initCachesFrom ( $fluxRule )

Sets this Rule's resolved and unresolved rule caches to a shallow copy taken from
the provided rule. 
 
=cut

sub initCachesFrom {
    my $self = shift;
    my ($that) = validate_pos( @_, { isa => 'WebGUI::Flux::Rule' } );

    my %rrc_copy = %{ $that->resolvedRuleCache() };
    my %urc_copy = %{ $that->unresolvedRuleCache() };
    $resolvedRuleCache{ id $self}   = \%rrc_copy;
    $unresolvedRuleCache{ id $self} = \%urc_copy;
}

1;
