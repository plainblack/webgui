package WebGUI::Flux::Rule;

use strict;
use warnings;

use Class::InsideOut qw{ :std };
use WebGUI::Exception::Flux;
use WebGUI::Flux::Expression;
use Readonly;
use WebGUI::DateTime;
use English qw( -no_match_vars );
use WebGUI::Workflow::Instance;

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
public resolvedRuleCache      => my %resolvedRuleCache;       # (hash) cache of resolved WebGUI::Rules
public unresolvedRuleCache    => my %unresolvedRuleCache;     # (hash) cache of currently unresolved WebGUI::Rules

# Default values used in create() method
Readonly my %RULE_DEFAULTS => (
    name   => 'Undefined',
    sticky => 0,
);

# Properties/db fields that can be updated via update() method
Readonly my @MUTABLE_PROPERTIES => qw(
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
    my ( $self, $properties_ref ) = @_;
    return WebGUI::Flux::Expression->create( $self, $properties_ref );
}

#-------------------------------------------------------------------

=head2 create ( session, rule )

Constructor. Creates a new Flux Rule and returns it.
Refer to C<new()> if instead you want To instantiate an existing rule.

=head3 session

A reference to the current session.

=head3 rule

A hash reference containing the properties to set on the Rule.

=cut

sub create {
    my ( $class, $session, $properties_ref ) = @_;

    # Check arguments..
    if ( !defined $session || !$session->isa('WebGUI::Session') ) {
        WebGUI::Error::InvalidObject->throw(
            expected => 'WebGUI::Session',
            got      => ( ref $session ),
            error    => 'Need a session.'
        );
    }
    if ( defined $properties_ref && ref $properties_ref ne 'HASH' ) {
        WebGUI::Error::InvalidNamedParamHashRef->throw(
            param => $properties_ref,
            error => 'invalid properties hash ref.'
        );
    }

    # Ok for $properties_ref to be missing
    $properties_ref = defined $properties_ref ? $properties_ref : {};

    # Work out the next highest sequence number
    my $sequenceNumber = $session->db->quickScalar('select max(sequenceNumber) from fluxRule');
    $sequenceNumber = $sequenceNumber ? $sequenceNumber + 1 : 1;

    # Create a bare-minimum entry in the db..
    my $id = $session->db->setRow( 'fluxRule', 'fluxRuleId',
        { %RULE_DEFAULTS, fluxRuleId => 'new', sequenceNumber => $sequenceNumber } );

    # (re-)retrieve entry and apply user-supplied properties..
    my $rule = $class->new( $session, $id );
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
    my ($self) = @_;
    $self->update( { combinedExpression => undef } );
    return;
}

#-------------------------------------------------------------------

=head2 delete ()

Deletes this Flux Rule and all expressions contained in it.

=cut

sub delete {
    my ($self) = @_;
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
    my ( $self, $name ) = @_;
    if ( defined $name ) {
        return $property{ id $self}{$name};
    }
    my %copyOfHashRef = %{ $property{ id $self} };
    return \%copyOfHashRef;
}

#-------------------------------------------------------------------

=head2 getExpression ( id )

Returns an expression object.

=head3 id

An expression object's unique id.

=cut

sub getExpression {
    my ( $self, $expressionId ) = @_;
    my $id = id $self;

    if ( !exists $expressionCache{$id}{$expressionId} ) {
        $expressionCache{$id}{$expressionId} = WebGUI::Flux::Expression->new( $self, $expressionId );
    }

    #    return WebGUI::Flux::Expression->new( $self, $expressionId );
    return $expressionCache{$id}{$expressionId};
}

#-------------------------------------------------------------------

=head2 getExpressionCount ( )

Returns the number of Expressions in this Rule.

=cut

sub getExpressionCount {
    my ($self) = @_;
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
    my ($self) = @_;
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
    my ($self) = @_;
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
    my ( $class, $session, $ruleId ) = @_;

    # Check arguments..
    if ( !defined $session || !$session->isa('WebGUI::Session') ) {
        WebGUI::Error::InvalidObject->throw(
            expected => 'WebGUI::Session',
            got      => ( ref $session ),
            error    => 'Need a session.'
        );
    }
    if ( !defined $ruleId ) {
        WebGUI::Error::InvalidParam->throw( error => 'Need a fluxRuleId.' );
    }

    # Retreive row from db..
    my $rule = $session->db->quickHashRef( 'select * from fluxRule where fluxRuleId=?', [$ruleId] );
    if ( !exists $rule->{fluxRuleId} || $rule->{fluxRuleId} eq q{} ) {
        WebGUI::Error::ObjectNotFound->throw( error => 'No such Flux Rule.', id => $ruleId );
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
    my ( $self, $newProp_ref ) = @_;

    # Check arguments..
    if ( !defined $newProp_ref || ref $newProp_ref ne 'HASH' ) {
        WebGUI::Error::InvalidParam->throw( param => $newProp_ref, error => 'Invalid hash reference.' );
    }

    # Special filtering for combinedExpression..
    if ( defined $newProp_ref->{combinedExpression} ) {

        # Check for validity (throws an exception if not)
        checkCombinedExpression( $newProp_ref->{combinedExpression}, $self->getExpressionCount() );

        # Convert to lower-case
        $newProp_ref->{combinedExpression} = lc $newProp_ref->{combinedExpression};
    }

    my $id = id $self;
    foreach my $field (@MUTABLE_PROPERTIES) {
        $property{$id}{$field}
            = ( exists $newProp_ref->{$field} ) ? $newProp_ref->{$field} : $property{$id}{$field};
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

=head4 assetId

The assetId of the asset/wobject for which the Rule is being evaluated for (optional) 

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
    my ( $self, $arg_ref ) = @_;

    # Check args..
    if ( !defined $arg_ref || ref $arg_ref ne 'HASH' ) {
        WebGUI::Error::InvalidNamedParamHashRef->throw(
            param => $arg_ref,
            error => 'invalid named param hash ref.'
        );
    }

    # check compulsory fields..
    foreach my $field qw(user) {
        if ( !exists $arg_ref->{$field} ) {
            WebGUI::Error::NamedParamMissing->throw( param => $field, error => 'named param missing.' );
        }
    }
    if ( ref $arg_ref->{user} ne 'WebGUI::User' ) {
        WebGUI::Error::InvalidObject->throw(
            param    => $arg_ref->{user},
            error    => 'need a user.',
            expected => 'WebGUI::User',
            got      => ref $arg_ref->{user},
        );
    }

    # Cache $id for speed
    my $id = id $self;

    # Take note of which user we're evaluating the Rule for..
    my $user = $arg_ref->{user};
    $evaluatingForUser{$id} = $user;

    # Take note of which asset we're evaluating the Rule for (if set)..
    if ( exists $arg_ref->{assetId} ) {
        $evaluatingForAssetId{$id} = $arg_ref->{assetId};
    }

    # Take note of whether this is a recursive call or not..
    $evaluationInfo{$id}{is_recursive}
        = ( exists $arg_ref->{recursive} )
        ? $arg_ref->{recursive}
        : 0;    # defaults to false

    # Take note of whether this is wobject access or not..
    $evaluationInfo{$id}{is_access}
        = ( exists $arg_ref->{access} )
        ? $arg_ref->{access}
        : 1;    # defaults to true

    # Rule with no expressions defaults to true
    if ( $self->getExpressionCount() == 0 ) {
        return $self->_finishEvaluating( 1, $id );
    }

    # Check if we can apply the sticky optimisation..
    if ( $property{$id}{sticky} ) {
        my $dateRuleFirstTrue
            = $self->session->db->quickScalar(
            'select dateRuleFirstTrue from fluxRuleUserData where fluxRuleId=? and userId=?',
            [ $self->getId(), $user->userId() ] );

        if ($dateRuleFirstTrue) {
            WebGUI::Error::NotImplemented->throw( error => 'STICKY OPTIMISATION NOT TESTED YET.' );

            return $self->_finishEvaluating( 1, $id );
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
However in some weird cases (covered by test suite) it's seg faulting.
You can still use it if you turn off the XS version of List::MoreUtils
by setting the environment variable: LIST_MOREUTILS_PP

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
        if ( my $e = Exception::Class->caught() ) {
            $self->resetEvaluationInfo($id);
            $e->rethrow() if ref $e;            # Re-throw Exception::Class errors for other code to catch
        }
        if ($EVAL_ERROR) {
            WebGUI::Error::Flux::InvalidCombinedExpression->throw(
                error                    => $EVAL_ERROR,
                combinedExpression       => $combined_expression,
                parsedCombinedExpression => $parsed_combined_expression,
            );
        }
    }

    # We've finished evaluating now
    return $self->_finishEvaluating( $was_successful, $id );
}

#-------------------------------------------------------------------

=head2 _finishEvaluating ( result id )

Clean up after evaluating (update fluxRuleUserData table and
reset caches).

=head3 result

The boolean status of the Rule evaluation

head3 id

value of "id $self" (optimisation)
 
=cut

sub _finishEvaluating {
    my ( $self, $result, $id ) = @_;

    # Check arguments..
    if ( @_ != 3 ) {
        WebGUI::Error::InvalidParamCount->throw(
            got      => scalar(@_),
            expected => 3,
            error    => 'invalid param count',
        );
    }

    # Update the fluxRuleUserData table
    $self->_updateDataAndTriggerWorkflows( $result, $id );

    # Clear evaluation-data
    $self->resetEvaluationInfo($id);

    return $result;
}

sub resetEvaluationInfo {
    my ( $self, $id ) = @_;

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
        $resolvedRuleCache{$id} = {};
        $unresolvedRuleCache{$id} = { $rule_id => $rule_id };

        # And reset the depth counter..
        use WebGUI::Flux::Operand::FluxRule;
        WebGUI::Flux::Operand::FluxRule->resetDepthCounter();
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
    my ( $combined_expression, $expression_count ) = @_;

    # Check arguments..
    if ( @_ != 2 ) {
        WebGUI::Error::InvalidParamCount->throw(
            got      => scalar(@_),
            expected => 2,
            error    => 'invalid param count',
        );
    }

    # Undefined combined expression is valid
    return 1 if !defined $combined_expression;

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
    my ($combined_expression) = @_;

    # Check arguments..
    if ( @_ != 1 ) {
        WebGUI::Error::InvalidParamCount->throw(
            got      => scalar(@_),
            expected => 1,
            error    => 'invalid param count',
        );
    }

    # Apply the magic regex
    $combined_expression =~ s/e(\d+)/\$expressions[$1]->evaluate()/gx;
    return $combined_expression;
}
1;

#-------------------------------------------------------------------

=head2 _updateDataAndTriggerWorkflows ( result, id )

Updates the rule/user row in the fluxRuleUserData table after a Rule is
evaluated. Uses the boolean outcome of the Rule (was_successful) and a
flag indicating whether the Rule was directly/indirectly evaluated to
determine which fields need to be updated (dateRuleFirstTrue, 
dateAccessFirstTrue, etc..).

Also triggers any related Workflows.

=head3 result

The boolean status of the Rule evaluation

=head3 id

value of "id $self" (optimisation)

=cut

sub _updateDataAndTriggerWorkflows {
    my ( $self, $result, $id ) = @_;

    # Check arguments..
    if ( @_ != 3 ) {
        WebGUI::Error::InvalidParamCount->throw(
            got      => scalar(@_),
            expected => 3,
            error    => 'invalid param count',
        );
    }

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
    my $db_write_required = 0;                 # whether we need to write to the db
    my %field_updates;                         # what fields need to be updated
    my %trigger_workflow;                      # what workflows need to be triggered

    # Has rule ever been checked for this user?
    if ( !exists $userData{fluxRuleUserDataId} ) {
        $db_write_required = 1;

        # Create the basis of our new fluxRuleUserData row..
        $field_updates{fluxRuleUserDataId}   = 'new';
        $field_updates{fluxRuleId}           = $self->getId();
        $field_updates{userId}               = $user->userId();
        $field_updates{dateRuleFirstChecked} = $dt;
    }

    # First time Rule true or false?
    if ( !exists $userData{dateRuleFirstTrue} && $result ) {
        $db_write_required                = 1;
        $field_updates{dateRuleFirstTrue} = $dt;
        $trigger_workflow{RuleFirstTrue}  = 1;
    }
    if ( !exists $userData{dateRuleFirstFalse} && !$result ) {
        $db_write_required                 = 1;
        $field_updates{dateRuleFirstFalse} = $dt;
        $trigger_workflow{RuleFirstFalse}  = 1;
    }

    # Direct access attempt?
    if ( $is_access && $result ) {
        $db_write_required                         = 1;
        $field_updates{dateAccessMostRecentlyTrue} = $dt;
        $trigger_workflow{AccessTrue}              = 1;
    }
    if ( $is_access && !$result ) {
        $db_write_required                          = 1;
        $field_updates{dateAccessMostRecentlyFalse} = $dt;
        $trigger_workflow{AccessFalse}              = 1;
    }

    # First direct access attempt?
    if ( !exists $userData{dateAccessFirstAttempted} && $is_access ) {
        $db_write_required = 1;
        $field_updates{dateAccessFirstAttempted} = $dt;
    }

    # First time direct access true/false?
    if ($is_access) {
        if ( !exists $userData{dateAccessFirstTrue} && $result ) {
            $db_write_required                  = 1;
            $field_updates{dateAccessFirstTrue} = $dt;
            $trigger_workflow{AccessFirstTrue}  = 1;
        }
        if ( !exists $userData{dateAccessFirstFalse} && !$result ) {
            $db_write_required                   = 1;
            $field_updates{dateAccessFirstFalse} = $dt;
            $trigger_workflow{AccessFirstFalse}  = 1;
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
            my $workflow = WebGUI::Workflow::Instance->create(
                $self->session,
                {   workflowId => $workflowId,
                    className  => "WebGUI::User",
                    methodName => "new",
                    parameters => $evaluatingForUser{$id}->userId(),
                }
            );
            $workflow->start();
        }
    }
}
