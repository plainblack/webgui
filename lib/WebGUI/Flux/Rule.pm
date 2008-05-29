package WebGUI::Flux::Rule;

use strict;
use warnings;

use Class::InsideOut qw{ :std };

#use JSON;
#use WebGUI::Asset::Template;
#use WebGUI::Form;
#use WebGUI::International;
use WebGUI::Flux::Expression;
use Readonly;

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
readonly session        => my %session;            # WebGUI::Session object
private property        => my %property;           # Hash of object properties
private expressionCache => my %expressionCache;    # (hash) cache of WebGUI::Flux::Expression objects

# Default values used in create() method
Readonly my %RULE_DEFAULTS => (
    name => 'Undefined',
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

#-------------------------------------------------------------------

=head2 addExpression ( expression )

Adds an expression to the Flux Rule.  Returns a reference to the WebGUI::Flux::Expression
object that was created.  It does not trap exceptions, so any problems with creating
the object will be passed to the caller.

=head2 expression

A hash reference containing expression information.

=cut

sub addExpression {
    my ( $self, $expression ) = @_;
    my $expressionObj = WebGUI::Flux::Expression->create( $self, $expression );
    return $expressionObj;
}

#-------------------------------------------------------------------

=head2 create ( session, rule )

Constructor. Creates a new Flux Rule and returns it.
Refer to C<new> if instead you want To instantiate an existing rule.

=head3 session

A reference to the current session.

=head3 rule

A hash reference containing the properties to set on the Rule.

=cut

sub create {
    my ( $class, $session, $rule_ref ) = @_;

    # Check arguments..
    if ( !defined $session || !$session->isa("WebGUI::Session") ) {
        WebGUI::Error::InvalidObject->throw(
            expected => "WebGUI::Session",
            got      => ( ref $session ),
            error    => "Need a session."
        );
    }
    if ( defined $rule_ref && ref $rule_ref ne "HASH" ) {
        WebGUI::Error::InvalidParam->throw( param => $rule_ref, error => "Invalid hash reference." );
    }

    # Ok for $rule_ref to be missing
    $rule_ref = defined $rule_ref ? $rule_ref : {};

    # Create a bare-minimum entry in the db..
    my $id = $session->db->setRow( "fluxRule", "fluxRuleId", { fluxRuleId => "new", %RULE_DEFAULTS } );

    # (re-)retrieve entry and apply user-supplied properties..
    my $rule = $class->new( $session, $id );
    $rule->update($rule_ref);

    return $rule;
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
    $self->session->db->deleteRow( "fluxRule", "fluxRuleId", $self->getId );
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
C<update> method.

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
    unless ( exists $expressionCache{$id}{$expressionId} ) {
        $expressionCache{$id}{$expressionId} = WebGUI::Flux::Expression->new( $self, $expressionId );
    }
    return $expressionCache{$id}{$expressionId};
}

#-------------------------------------------------------------------

=head2 getExpressions ( )

Returns an array reference of expression objects that are in this Rule.

=cut

sub getExpressions {
    my ($self) = @_;
    my @expressionObjects = ();
    my $expressions = $self->session->db->read( "select fluxExpressionId from fluxExpression where fluxRuleId=?",
        [ $self->getId ] );
    while ( my ($expressionId) = $expressions->array ) {
        push( @expressionObjects, $self->getExpression($expressionId) );
    }
    return \@expressionObjects;
}

#-------------------------------------------------------------------

=head2 getId ()

Returns the unique id for this Rule.

=cut

sub getId {
    my ($self) = @_;
    return $self->get("fluxRuleId");
}

#-------------------------------------------------------------------

=head2 new ( session, id )

Constructor.  Instantiates an existing Rule based upon a fluxRuleId and returns it.
Refer to C<create> if you want to create a new Rule.  

=head3 session

A reference to the current session.

=head3 id

The unique id of an Flux Rule to instantiate.

=cut

sub new {
    my ( $class, $session, $ruleId ) = @_;

    # Check arguments..
    if ( !defined $session || !$session->isa("WebGUI::Session") ) {
        WebGUI::Error::InvalidObject->throw(
            expected => "WebGUI::Session",
            got      => ( ref $session ),
            error    => "Need a session."
        );
    }
    if ( !defined $ruleId ) {
        WebGUI::Error::InvalidParam->throw( error => "Need a fluxRuleId." );
    }
    my $rule = $session->db->quickHashRef( 'select * from fluxRule where fluxRuleId=?', [$ruleId] );
    if ( !exists $rule->{fluxRuleId} || $rule->{fluxRuleId} eq "" ) {
        WebGUI::Error::ObjectNotFound->throw( error => "No such Flux Rule.", id => $ruleId );
    }

    # Register Class::InsideOut object..
    my $self = register $class;

    # Initialise object properties..
    my $id = id $self;
    $session{$id}  = $session;
    $property{$id} = $rule;

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

sub update {
    my ( $self, $newProp_ref ) = @_;
    my $id = id $self;
    foreach my $field (@MUTABLE_PROPERTIES) {
        $property{$id}{$field}
            = ( exists $newProp_ref->{$field} ) ? $newProp_ref->{$field} : $property{$id}{$field};
    }
    return $self->session->db->setRow( "fluxRule", "fluxRuleId", $property{$id} );
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

1;

