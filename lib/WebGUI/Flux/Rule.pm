package WebGUI::Flux::Rule;

use strict;
use warnings;

use Class::InsideOut qw{ :std };
use WebGUI::Exception::Flux;
use WebGUI::Flux::Expression;
use Readonly;
use List::MoreUtils qw(any);
use WebGUI::DateTime;
use English qw( -no_match_vars );
use Regexp::Common;    # not bundled in WRE

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
readonly session           => my %session;                # WebGUI::Session object
private property           => my %property;               # Hash of object properties
private expressionCache    => my %expressionCache;        # (hash) cache of WebGUI::Flux::Expression objects
readonly evaluatingFor     => my %evaluatingFor;          # Set to a WebGUI::User when Rule is being evaluated
public resolvedRuleCache   => my %resolvedRuleCache;      # (hash) cache of resolved WebGUI::Rules
public unresolvedRuleCache => my %unresolvedRuleCache;    # (hash) cache of currently unresolved WebGUI::Rules

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
    combinedExpression
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

    # Create a bare-minimum entry in the db..
    my $id = $session->db->setRow( 'fluxRule', 'fluxRuleId', { fluxRuleId => 'new', %RULE_DEFAULTS } );

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
    $self->session->db->deleteRow( 'fluxRule', 'fluxRuleId', $self->getId );
    undef $self;
    return undef;
}

#-------------------------------------------------------------------

=head2 formatCallbackForm ( callback )

Returns an HTML hidden form field with the callback JSON block properly escaped.

=head3 callback

A JSON string that holds the callback information.

=cut

sub formatCallbackForm {
    my ( $self, $callback ) = @_;
    $callback =~ s/"/'/g;
    return '<input type="hidden" name="callback" value="' . $callback . '" />';
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
    my $id = ref $self;
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

=head4 combinedExpression

The combined expression

=cut

# TODO: Add Workflows to POD documentation above

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

##-------------------------------------------------------------------
#
#=head2 www_deleteExpression ( )
#
#Deletes an expression from the Rule.
#
#=cut
#
#sub www_deleteExpression {
#    my $self = shift;
#    $self->getExpression($self->session->form->get("fluxExpressionId"))->delete;
#    return $self->www_view;
#}
#
##-------------------------------------------------------------------
#
#=head2 www_editExpression ()
#
#Allows a user to edit an expression in their Flux Rule.
#
#=cut
#
#sub www_editExpression {
#    my ($self, $error) = @_;
#    my $session = $self->session;
#    my $form = $session->form;
#    my $expression = eval{$self->getExpression($form->get("fluxExpressionId"))};
#    if (WebGUI::Error->caught) {
#        $expression = undef;
#    }
#    my %base = ();
#    if (defined $expression) {
#        %base = %{$expression->get};
#    }
#    my %var = (
#        %base,
#        error               => $error,
#        formHeader          => WebGUI::Form::formHeader($session)
#                                .WebGUI::Form::hidden($session, {name=>"flux", value=>"expression"})
#                                .$self->formatCallbackForm($form->get('callback'))
#                                .WebGUI::Form::hidden($session, {name=>"method", value=>"editExpressionSave"})
#                                .WebGUI::Form::hidden($session, {name=>"fluxExpressionId", value=>$form->get("fluxExpressionId")}),
#        saveButton          => WebGUI::Form::submit($session),
#        formFooter          => WebGUI::Form::formFooter($session),
#        expression1Field       => WebGUI::Form::text($session, {name=>"expression1", maxlength=>35, defaultValue=>($form->get("expression1") || ((defined $expression) ? $expression->get('expression1') : undef))}),
#        expression2Field       => WebGUI::Form::text($session, {name=>"expression2", maxlength=>35, defaultValue=>($form->get("expression2") || ((defined $expression) ? $expression->get('expression2') : undef))}),
#        expression3Field       => WebGUI::Form::text($session, {name=>"expression3", maxlength=>35, defaultValue=>($form->get("expression3") || ((defined $expression) ? $expression->get('expression3') : undef))}),
#        labelField          => WebGUI::Form::text($session, {name=>"label", maxlength=>35, defaultValue=>($form->get("label") || ((defined $expression) ? $expression->get('label') : undef))}),
#        nameField           => WebGUI::Form::text($session, {name=>"name", maxlength=>35, defaultValue=>($form->get("name") || ((defined $expression) ? $expression->get('name') : undef))}),
#        cityField           => WebGUI::Form::text($session, {name=>"city", maxlength=>35, defaultValue=>($form->get("city") || ((defined $expression) ? $expression->get('city') : undef))}),
#        stateField          => WebGUI::Form::text($session, {name=>"state", maxlength=>35, defaultValue=>($form->get("state") || ((defined $expression) ? $expression->get('state') : undef))}),
#        countryField        => WebGUI::Form::country($session, {name=>"country", defaultValue=>($form->get("country") || ((defined $expression) ? $expression->get('country') : undef))}),
#        codeField           => WebGUI::Form::zipcode($session, {name=>"code", defaultValue=>($form->get("code") || ((defined $expression) ? $expression->get('code') : undef))}),
#        phoneNumberField    => WebGUI::Form::phone($session, {name=>"phoneNumber", defaultValue=>($form->get("phoneNumber") || ((defined $expression) ? $expression->get('phoneNumber') : undef))}),
#    );
#    my $template = WebGUI::Asset::Template->new($session, $session->setting->get("fluxExpressionTemplateId"));
#    $template->prepare;
#    return $session->style->userStyle($template->process(\%var));
#}
#
#
#
##-------------------------------------------------------------------
#
#=head2 www_editExpressionSave ()
#
#Saves the expression. If there is a problem generates www_editExpression() with an error message. Otherwise returns www_view().
#
#=cut
#
#sub www_editExpressionSave {
#    my $self = shift;
#    my $form = $self->session->form;
#    my $i18n = WebGUI::International->new($self->session,"Flux");
#    if ($form->get("label") eq "") {
#        return $self->www_editExpression(sprintf($i18n->get('is a required field'), $i18n->get('label')));
#    }
#    if ($form->get("name") eq "") {
#        return $self->www_editExpression(sprintf($i18n->get('is a required field'), $i18n->get('name')));
#    }
#    if ($form->get("expression1") eq "") {
#        return $self->www_editExpression(sprintf($i18n->get('is a required field'), $i18n->get('expression')));
#    }
#    if ($form->get("city") eq "") {
#        return $self->www_editExpression(sprintf($i18n->get('is a required field'), $i18n->get('city')));
#    }
#    if ($form->get("code") eq "") {
#        return $self->www_editExpression(sprintf($i18n->get('is a required field'), $i18n->get('code')));
#    }
#    if ($form->get("country") eq "") {
#        return $self->www_editExpression(sprintf($i18n->get('is a required field'), $i18n->get('country')));
#    }
#    if ($form->get("phoneNumber") eq "") {
#        return $self->www_editExpression(sprintf($i18n->get('is a required field'), $i18n->get('phone number')));
#    }
#    my %expressionData = (
#        label           => $form->get("label"),
#        name            => $form->get("name"),
#        expression1        => $form->get("expression1"),
#        expression2        => $form->get("expression2"),
#        expression3        => $form->get("expression3"),
#        city            => $form->get("city"),
#        state           => $form->get("state"),
#        code            => $form->get("code","zipcode"),
#        country         => $form->get("country","country"),
#        phoneNumber     => $form->get("phoneNumber","phone"),
#        );
#    if ($form->get('fluxExpressionId') eq '') {
#        $self->addExpression(\%expressionData);
#    }
#    else {
#        $self->getExpression($form->get('fluxExpressionId'))->update(\%expressionData);
#    }
#    return $self->www_view;
#}
#
#
##-------------------------------------------------------------------
#
#=head2 www_view
#
#Displays the current user's Flux Rule.
#
#=cut
#
#sub www_view {
#    my $self = shift;
#    my $session = $self->session;
#    my $form = $session->form;
#    my $callback = $form->get('callback');
#    $callback =~ s/'/"/g;
#    $callback = JSON->new->utf8->decode($callback);
#    my $callbackForm = '';
#    foreach my $param (@{$callback->{params}}) {
#        $callbackForm .= WebGUI::Form::hidden($session, {name=>$param->{name}, value=>$param->{value}});
#    }
#    my $i18n = WebGUI::International->new($session, "Flux");
#    my @expressions = ();
#    foreach my $expression (@{$self->getExpressions}) {
#        push(@expressions, {
#            %{$expression->get},
#            expression         => $expression->getHtmlFormatted,
#            deleteButton    => WebGUI::Form::formHeader($session)
#                                .WebGUI::Form::hidden($session, {name=>"flux", value=>"expression"})
#                                .WebGUI::Form::hidden($session, {name=>"method", value=>"deleteExpression"})
#                                .WebGUI::Form::hidden($session, {name=>"fluxExpressionId", value=>$expression->getId})
#                                .$self->formatCallbackForm($form->get('callback'))
#                                .WebGUI::Form::submit($session, {value=>$i18n->get("delete")})
#                                .WebGUI::Form::formFooter($session),
#            editButton      => WebGUI::Form::formHeader($session)
#                                .WebGUI::Form::hidden($session, {name=>"flux", value=>"expression"})
#                                .WebGUI::Form::hidden($session, {name=>"method", value=>"editExpression"})
#                                .WebGUI::Form::hidden($session, {name=>"fluxExpressionId", value=>$expression->getId})
#                                .$self->formatCallbackForm($form->get('callback'))
#                                .WebGUI::Form::submit($session, {value=>$i18n->get("edit")})
#                                .WebGUI::Form::formFooter($session),
#            useButton       => WebGUI::Form::formHeader($session,{action=>$callback->{url}})
#                                .$callbackForm
#                                .WebGUI::Form::hidden($session, {name=>"fluxExpressionId", value=>$expression->getId})
#                                .WebGUI::Form::submit($session, {value=>$i18n->get("use this expression")})
#                                .WebGUI::Form::formFooter($session),
#            });
#    }
#    my %var = (
#        expressions => \@expressions,
#        addButton => WebGUI::Form::formHeader($session)
#                    .WebGUI::Form::hidden($session, {name=>"flux", value=>"expression"})
#                    .WebGUI::Form::hidden($session, {name=>"method", value=>"editExpression"})
#                    .$self->formatCallbackForm($form->get('callback'))
#                    .WebGUI::Form::submit($session, {value=>$i18n->get("add a new expression")})
#                    .WebGUI::Form::formFooter($session),
#        );
#    my $template = WebGUI::Asset::Template->new($session, $session->setting->get("fluxRuleTemplateId"));
#    $template->prepare;
#    return $session->style->userStyle($template->process(\%var));
#}

#-------------------------------------------------------------------

=head2 evaluate ( user )

Evaluates the Flux Rule for the given user

=head3 user

The user who the Rule is being evaluated against
 
=cut

sub evaluateFor {
    my ( $self, $user, $options_ref ) = @_;

    my $id = id $self;

    # Check arguments..
    if ( @_ < 2 || @_ > 3 ) {
        WebGUI::Error::InvalidParamCount->throw(
            got      => scalar(@_),
            expected => '2 or 3',
            error    => 'invalid param count.' . scalar(@_) . Dumper(@_),
        );
    }
    if ( !defined $self || ref $self ne 'WebGUI::Flux::Rule' ) {
        WebGUI::Error::InvalidObject->throw(
            expected => 'WebGUI::Flux::Rule',
            got      => $self,
            error    => 'need a flux rule.'
        );
    }
    if ( !defined $user || ref $user ne 'WebGUI::User' ) {
        WebGUI::Error::InvalidObject->throw(
            expected => 'WebGUI::User',
            got      => $user,
            error    => 'need a user.'
        );
    }

    # TODO: fix this
    my $access = 1;
    if ( defined $options_ref && $options_ref->{indirect} ) {
        $access = 0;
    }
    my $clear_cache_afterwards = $access;

    # Take note that we are now evaluating for a user
    $evaluatingFor{$id} = $user;

    # Check for entry in fluxRuleUserData table
    my %userData = %{
        $self->session->db->quickHashRef( 'select * from fluxRuleUserData where fluxRuleId=? and userId=?',
            [ $self->getId(), $user->userId() ] )
        };

    # Check if we can apply the sticky optimisation
    my $is_sticky = $property{$id}{sticky};
    if ( $is_sticky && defined $userData{dateRuleFirstTrue} ) {
        WebGUI::Error::NotImplemented->throw( error => 'STICKY NOT IMPLEMENTED YET.' );

        delete $evaluatingFor{$id};
        return 1;
    }

    # Now we need to see if the Rule passes or not..
    my $was_successful;
    my $combined_expression = $property{$id}{combinedExpression};
    if ( !$combined_expression ) {

        # No combined expression defined so just AND them all together
        $was_successful = 1;
        EVALUATE:
        foreach my $exp ( @{ $self->getExpressions() } ) {
            if ( !$exp->evaluate() ) {
                $was_successful = 0;
                last EVALUATE;
            }
        }

        # TODO: Figure out why the following code breaks in FluxRule.t
#        if ( any { !$_->evaluate() } @{ $self->getExpressions() } ) {
#            $was_successful = 0;
#        }
#        else {
#            $was_successful = 1;
#        }
    }
    else {

        # Combined expression in use, so first parse it..
        my $parsed_combined_expression = _parseCombinedExpression($combined_expression);

        # ..and also create a lexical array of expressions (1-indexed, used by eval string)
        my @expressions = @{ $self->getExpressions() };
        unshift @expressions, 'dummy entry';    # add a dummy entry to the front to make it 1-indexed

        # eval the parsed combined expression and rely on Perl for error-catching
        {
            no warnings 'all';                  # silence perl
            $was_successful = eval("($parsed_combined_expression)");
        }
        if ( my $e = Exception::Class->caught() ) {
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

    # Finally, update the fluxRuleUserData table
    {
        my $dt = WebGUI::DateTime->new(time)->toDatabase();
        my %rowUpdates;
        $rowUpdates{fluxRuleUserDataId}
            = exists $userData{fluxRuleUserDataId} ? $userData{fluxRuleUserDataId} : 'new';
        $rowUpdates{dateRuleFirstChecked}
            = exists $userData{dateRuleFirstChecked} ? $userData{dateRuleFirstChecked} : $dt;
        if ($was_successful) {
            $rowUpdates{dateRuleFirstTrue}
                = exists $userData{dateRuleFirstTrue} ? $userData{dateRuleFirstTrue} : $dt;
        }
        else {
            $rowUpdates{dateRuleFirstFalse}
                = exists $userData{dateRuleFirstFalse} ? $userData{dateRuleFirstFalse} : $dt;
        }
        if ($access) {
            $rowUpdates{dateAccessFirstAttempted}
                = exists $userData{dateAccessFirstAttempted} ? $userData{dateAccessFirstAttempted} : $dt;

            if ($was_successful) {
                $rowUpdates{dateAccessMostRecentlyTrue} = $dt;
                $rowUpdates{dateAccessFirstTrue}
                    = exists $userData{dateAccessFirstTrue} ? $userData{dateAccessFirstTrue} : $dt;
            }
            else {
                $rowUpdates{dateAccessMostRecentlyFalse} = $dt;
                $rowUpdates{dateAccessFirstFalse}
                    = exists $userData{dateAccessFirstFalse} ? $userData{dateAccessFirstFalse} : $dt;
            }
        }

        # If this is a new row, also need to set fluxRuleId and userId
        if ( $rowUpdates{fluxRuleUserDataId} eq 'new' ) {
            $rowUpdates{fluxRuleId} = $self->getId();
            $rowUpdates{userId}     = $user->userId();
        }

        if ( scalar keys %rowUpdates > 0 ) {
            $self->session->db->setRow( 'fluxRuleUserData', 'fluxRuleUserDataId', \%rowUpdates );
        }
    }

    # We've finished evaluating now
    delete $evaluatingFor{$id};
    if ($clear_cache_afterwards) {
        $resolvedRuleCache{$id} = {};
        $unresolvedRuleCache{$id} = { $self->getId() => $self->getId() };
    }

    return $was_successful;
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
