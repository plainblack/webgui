package WebGUI::Flux::Admin;

use strict;
use Class::InsideOut qw{ :std };
use WebGUI::Flux;
use Readonly;
use WebGUI::AdminConsole;
use WebGUI::HTMLForm;
use WebGUI::International;
use WebGUI::Flux;
use WebGUI::Flux::Rule;
use WebGUI::Flux::Expression;
use Exception::Class;
use Params::Validate qw(:all);
Params::Validate::validation_options( on_fail => sub { WebGUI::Error::InvalidParam->throw( error => shift ) } );

=head1 NAME

Package WebGUI::Flux::Admin

=head1 DESCRIPTION

All the admin stuff that didn't fit elsewhere.
This module will remain mostly empty until the Flux GUI is implemented. 

=head1 SYNOPSIS

 use WebGUI::Flux::Admin;

 my $admin = WebGUI::Flux::Admin->new($session);

=head1 METHODS

These subroutines are available from this package:

=cut

readonly session => my %session;

Readonly my $EXPRESSION_INSTRUCTIONS => <<"END_INSTRUCTIONS";

<H2>Instructions</H2>
<p>The Flux API is finished but I haven't built the intuitive ajax-driven GUI yet. 
That means that you need to hand-craft Expressions.<br/>
Operands, Operators and Modifiers are specified by name. Args are JSON-encoded. Details and examples follow. 
You can consult the test files for each Operand/Operator/Modifier in t/Flux/ for more examples. 
</p>

<H2>Operands</H2>
<p>The following Operands are available (these correspond to modules in the WebGUI::Flux::Operand namespace): </p>

<H3>TextValue</H3>
<p>Returns a simple text value. Use Args in the form of:
<code>
{"value":  "some value"}
</code>
</p>

<H3>NumericValue</H3>
<p>Returns a numeric value. Use Args in the form of:
<code>
{"value":  "123"}
</code>
</p>

<H3>TruthValue</H3>
<p>Returns a 0/1 truth value. Use Args in the form of:
<code>
{"value":  "1"}
</code>
</p>

<H3>Group</H3>
<p>Returns true/false depending on Group membership for the user being tested against. Use Args in the form of:
<code>
{"groupId":  "3"}
</code>
</p>

<H3>UserProfileField</H3>
<p>Returns the value of the specified User Profile Field for the user being tested against. Use Args in the form of:
<code>
{"field":  "firstName"}
</code>
</p>

<H3>DateTime</H3>
<p>Returns a DateTime object. Specify using MySQL date format (see WebGUI::DateTime::toDatabase(). 
You will most likely want to use a Modifier with this Operand because the returned DateTime is an object not a string. 
Use Args in the form of:
<code>
{"field":  "2006-11-06 21:12:45"}
</code>
</p>

<H3>FluxRule</H3>
<p>Returns the true/false status of another Rule for the user being tested against. Until we have the nice GUI you
will need to look up the fluxRuleId manually (e.g. by hovering over the Edit button next to a Rule).  
Use Args in the form of:
<code>
{"fluxRuleId":  "some_flux_rule_id"}
</code>
</p>

<H2>Operators</H2>
<p>The following Operators are available (these correspond to modules in the WebGUI::Flux::Operator namespace):</p> 

<H3>IsEqualTo</H3>
<p>Computes equality.</p>

<H3>IsLessThan</H3>
<p>Computes &lt;.</p>

<H2>Modifiers</H2>
<p>The following Modifiers are available (these correspond to modules in the WebGUI::Flux::Modifier namespace): </p>

<H3>DateTimeCompareToNow</H3>
<p>Compares a DateTime Operand to now() and returns the duration in the specified units and time_zone. 
You can specify any valid time_zone, or "user" to dynamically user the user's time zone.
Use Args in the form of:
<code>
{ "units": "hours", "time_zone": "user" }
</code>
</p>

<H3>DateTimeFormat</H3>
<p>Formats a DateTime Operand using the specified strftime date formatters. 
You can specify any valid time_zone, or "user" to dynamically user the user's time zone.
Use Args in the form of:
<code>
{ "pattern": "%x %X", "time_zone": "user" }
</code>
</p>

END_INSTRUCTIONS

#-------------------------------------------------------------------

=head2 new ( session )

Constructor. 

=head3 session

A reference to the current session.

=cut

sub new {
    my $class = shift;
    my ($session ) = validate_pos(@_, {isa => 'WebGUI::Session' });
    my $self = register $class;
    my $id   = id $self;
    $session{$id} = $session;
    return $self;
}

#-------------------------------------------------------------------

=head2 session () 

Returns a reference to the current session.

=cut

#-------------------------------------------------------------------

=head2 canManage ( [ $user ] )

Determine whether or not a user can manage Flux functions

=head3 $user

An optional WebGUI::User object to check for permission to do Flux functions.  If
this is not used, it uses the current session user object.

=cut

sub canManage {
    my $self = shift;
    my $user = shift || $self->session->user;
    return $user->isInGroup( $self->session->setting->get('groupIdAdminFlux') );
}

#-------------------------------------------------------------------

=head2 getAdminConsole ()

Returns a reference to the admin console with all submenu items already added.

=cut

sub getAdminConsole {
    my $self = shift;
    my $ac   = WebGUI::AdminConsole->new( $self->session, 'flux' );
    my $i18n = WebGUI::International->new( $self->session, 'Flux' );
    my $url  = $self->session->url;
    $ac->addSubmenuItem( $url->page("flux=admin"), 'Flux Admin' );
    $ac->addSubmenuItem( $url->page("flux=graph"), 'View Flux Graph' );
    return $ac;
}

#-------------------------------------------------------------------

=head2 www_graph () 

Display a simple page showing the Flux Graph. This is currently just a proof-of-concept. 
You can view this at: http://dev.localhost.localdomain/?flux=admin&method=graph or by running
 > prove Flux.t
and then viewing /uploads/FluxGraph.png in an image viewer.

=cut

sub www_graph {
    my $self = shift;

    # Check permissions..
    return $self->session->privilege->insufficient
        if !$self->canManage();

    my $ac = $self->getAdminConsole();

    WebGUI::Flux->generateGraph( $self->session );

    # Return a simple hard-coded page displaying the Flux Graph.
    my $img = $self->session->url->gateway('uploads/FluxGraph.png');
    my $graph = qq{<img src="$img">};

    return $ac->render( $graph, 'Flux Graph' );
}

#-------------------------------------------------------------------

=head2 www_admin ()

Displays the general Flux settings.

=cut

sub www_admin {
    my $self = shift;

    # Check permissions..
    return $self->session->privilege->insufficient
        if !$self->canManage();

    my $i18n    = WebGUI::International->new( $self->session, 'Flux' );
    my $ac      = $self->getAdminConsole();
    my $setting = $self->session->setting();

    my $output = q{};

    if ( !$setting->get('fluxEnabled') ) {
        $output .= <<EOSM;
<div class="error">
Flux is currently disabled site-wide.
</div>
EOSM
    }

    # Build a TabForm..
    use Tie::IxHash;
    my %tabs;
    tie %tabs, 'Tie::IxHash';
    %tabs = (
        rules    => { label => 'Rules' },
        settings => { label => 'Settings' },
    );
    my $form = WebGUI::TabForm->new( $self->session, \%tabs );
    $form->hidden( { name => 'flux', value => 'adminSave' } );

    # Build the Settings tab..
    my $settings_tab = $form->getTab('settings');
    $settings_tab->yesNo(
        name  => 'fluxEnabled',
        value => $setting->get('fluxEnabled'),
        label => 'Flux Enabled',
        hoverHelp =>
            'Controls whether Flux is enabled site-wide. If you disable, per-wobject Flux settings will not be shown or used.',
    );
    $settings_tab->group(
        name      => 'groupIdAdminFlux',
        value     => $setting->get('groupIdAdminFlux'),
        label     => $i18n->get('who can manage'),
        hoverHelp => $i18n->get('who can manage help'),
    );

    # Build the Rules tab..
    my $rules_tab = $form->getTab('rules');
    my $add_icon  = $self->session->icon->delete("flux=addRule");
    $add_icon =~ s{toolbar/bullet/delete}{flux/add2};
    my $rule_output = <<"END_RULEHEADER";
<tr>
    <td class='formDescription' valign="top" style="width: 350px;">
        $add_icon Add Rule
    </td>
</tr>
END_RULEHEADER

    foreach my $rule ( @{ WebGUI::Flux->getRules( $self->session ) } ) {
        my $name        = $rule->get('name');
        my $id          = $rule->getId();
        my $edit_icon   = $self->session->icon->edit("flux=editRule&id=$id");
        my $manage_icon = $self->session->icon->manage("flux=manageRule&ruleId=$id");
        my $delete_icon = $self->session->icon->delete("flux=deleteRule&id=$id");

        $rule_output .= <<"END_RULEROW";
<tr>
    <td class='formDescription' valign="top" style="width: 350px;">
        $name
    </td>
    <td class='tableData' valign="top">
        $edit_icon
    </td>
    <td class='tableData' valign="top">
        $manage_icon
    </td>
    <td class='tableData' valign="top">
        $delete_icon
    </td>
 </tr>
END_RULEROW

    }
    $rules_tab->raw($rule_output);

    return $ac->render( $output . $form->print, 'Flux Admin' );
}

#-------------------------------------------------------------------

=head2 www_adminSave () 

Saves the general Flux settings.

=cut

sub www_adminSave {
    my $self = shift;
    return $self->session->privilege->adminOnly() unless ( $self->session->user->isInGroup("3") );
    my ( $setting, $form ) = $self->session->quick(qw(setting form));
    $setting->set( "fluxEnabled",      $form->get( "fluxEnabled",      "yesNo" ) );
    $setting->set( "groupIdAdminFlux", $form->get( "groupIdAdminFlux", "group" ) );
    return $self->www_admin();
}

#-------------------------------------------------------------------

=head2 www_addRule ()

Displays the edit Rule page.

=cut

sub www_addRule {
    my $self    = shift;
    my $error = shift;
    my $session = $self->session;

    # Check permissions..
    return $self->session->privilege->insufficient
        if !$self->canManage();

    my $i18n = WebGUI::International->new( $self->session, 'Flux' );
    my $ac = $self->getAdminConsole();

    my %fieldDefaults = WebGUI::Flux::Rule->getFieldDefaults();
    my %mutableFields = map { $_ => exists $fieldDefaults{$_} ? $fieldDefaults{$_} : undef }
        WebGUI::Flux::Rule->getMutableFields();
    my $form = $self->_buildRuleForm( { %mutableFields, hidden => { flux => 'addRuleSave', }, } );
    
    my $output = q{};

    if ($error) {
        $output .= <<"END_MESSAGE";
<div class="error">
    $error
</div>
END_MESSAGE
    }
    
    return $ac->render( $output . $form->print, 'Add Rule' );
}

#-------------------------------------------------------------------

=head2 www_addRuleSave () 

Creates a new Flux Rule.

=cut

sub www_addRuleSave {
    my $self    = shift;
    my $session = $self->session;
    return $session->privilege->adminOnly() unless ( $session->user->isInGroup("3") );

    my %updates = map { $_ => defined $session->form->get($_) ? $session->form->get($_) : undef } WebGUI::Flux::Rule->getMutableFields();

    eval { WebGUI::Flux::Rule->create( $session, \%updates ) };
    if ( my $e = Exception::Class->caught() ) {
        $session->log->warn( 'Error: ' . $e );
        return $self->www_addRule( 'Error: ' . $e );
    }

    return $self->www_admin();
}

#-------------------------------------------------------------------

=head2 www_deleteRule () 

Deletes a Flux Rule.

=cut

sub www_deleteRule {
    my $self    = shift;
    my $session = $self->session;
    return $session->privilege->adminOnly() unless ( $session->user->isInGroup("3") );

    my $rule_id = $session->form->get('id');
    return $self->www_admin()
        if !$rule_id;

    my $rule = WebGUI::Flux::Rule->new( $session, $rule_id );

    eval { $rule->delete(); };
    if ( my $e = Exception::Class->caught() ) {
        $session->log->warn( 'Error: ' . $e );
        return $self->www_admin( 'Error: ' . $e );
    }
    return $self->www_admin();
}

#-------------------------------------------------------------------

=head2 www_editRule ()

Displays the edit Rule page.

=cut

sub www_editRule {
    my $self    = shift;
    my $error   = shift;
    my $session = $self->session;

    # Check permissions..
    return $self->session->privilege->insufficient
        if !$self->canManage();

    my $i18n = WebGUI::International->new( $self->session, 'Flux' );
    my $ac = $self->getAdminConsole();

    my $rule_id = $session->form->get('id');

    my $rule
        = $rule_id
        ? WebGUI::Flux::Rule->new( $session, $rule_id )
        : undef;

    my %mutableFields = map { $_ => $rule->get($_) } WebGUI::Flux::Rule->getMutableFields();
    my $form = $self->_buildRuleForm(
        {   %mutableFields,
            hidden => {
                'flux' => 'editRuleSave',
                'id'   => $rule->getId(),
            },
        }
    );

    my $output = q{};

    if ($error) {
        $output .= <<"END_MESSAGE";
<div class="error">
    $error
</div>
END_MESSAGE
    }

    return $ac->render( $output . $form->print, 'Edit Rule' );
}

#-------------------------------------------------------------------

=head2 www_editRuleSave () 

Saves Flux Rule edits.

=cut

sub www_editRuleSave {
    my $self    = shift;
    my $session = $self->session;
    return $session->privilege->adminOnly() unless ( $session->user->isInGroup("3") );

    my $rule_id = $session->form->get('id');
    return undef
        if !$rule_id;

    my $rule = WebGUI::Flux::Rule->new( $session, $rule_id );
    my %updates = map { $_ => defined $session->form->get($_) ? $session->form->get($_) : undef } WebGUI::Flux::Rule->getMutableFields();
    eval { $rule->update( \%updates ) };
    if ( my $e = Exception::Class->caught() ) {
        $session->log->warn( 'Error: ' . $e );
        return $self->www_editRule( 'Error: ' . $e );
    }
    return $self->www_admin();
}

#-------------------------------------------------------------------
sub _buildRuleForm {
    my ( $self, $arg_ref ) = @_;

    # Build an HTMLForm..
    my $form = WebGUI::HTMLForm->new( $self->session );

    $form->submit;
    
    # Add hidden fields..
    if ( my $hidden = $arg_ref->{hidden} ) {
        while ( my ( $key, $val ) = each %{$hidden} ) {
            $form->hidden( name => $key, value => $val );
        }
    }

    $form->text(
        name      => 'name',
        value     => $arg_ref->{name},
        label     => 'Rule Name',
        hoverHelp => 'The name of this Flux Rule',
    );
    $form->yesNo(
        name      => 'sticky',
        value     => $arg_ref->{sticky},
        label     => 'Is Sticky',
        hoverHelp => 'Whether or not the Flux Rule is sticky',
    );
    $form->workflow(
        name      => 'onRuleFirstTrueWorkflowId',
        value     => $arg_ref->{onRuleFirstTrueWorkflowId},
        label     => 'Rule First True Workflow',
        hoverHelp => 'Workflow to run when Rule First True',
        none      => 1,                                        # allow empty selection
    );
    $form->workflow(
        name      => 'onRuleFirstFalseWorkflowId',
        value     => $arg_ref->{onRuleFirstFalseWorkflowId},
        label     => 'Rule First False Workflow',
        hoverHelp => 'Workflow to run when Rule First False',
        none      => 1,                                         # allow empty selection
    );
    $form->workflow(
        name      => 'onAccessFirstTrueWorkflowId',
        value     => $arg_ref->{onAccessFirstTrueWorkflowId},
        label     => 'Access First True Workflow',
        hoverHelp => 'Workflow to run when Access First True',
        none      => 1,                                          # allow empty selection
    );
    $form->workflow(
        name      => 'onAccessFirstFalseWorkflowId',
        value     => $arg_ref->{onAccessFirstFalseWorkflowId},
        label     => 'Access First False Workflow',
        hoverHelp => 'Workflow to run when Access First False',
        none      => 1,                                           # allow empty selection
    );
    $form->workflow(
        name      => 'onAccessTrueWorkflowId',
        value     => $arg_ref->{onAccessTrueWorkflowId},
        label     => 'Access True Workflow',
        hoverHelp => 'Workflow to run every time Access True',
        none      => 1,                                           # allow empty selection
    );
    $form->workflow(
        name      => 'onAccessFalseWorkflowId',
        value     => $arg_ref->{onAccessFalseWorkflowId},
        label     => 'Access False Workflow',
        hoverHelp => 'Workflow to run every time Access False',
        none      => 1,                                           # allow empty selection
    );
    $form->text(
        name      => 'combinedExpression',
        value     => $arg_ref->{combinedExpression},
        label     => 'Combined Expression',
        hoverHelp => 'The Combined Expression',
    );
    $form->hidden(
        name  => 'sequenceNumber',
        value => $arg_ref->{sequenceNumber},
    );

    $form->submit;

    return $form;
}

#-------------------------------------------------------------------

=head2 www_addExpression ()

Displays the add Expression page.

=cut

sub www_addExpression {
    my $self    = shift;
    my $error = shift;
    my $session = $self->session;

    # Check permissions..
    return $self->session->privilege->insufficient
        if !$self->canManage();

    my $i18n = WebGUI::International->new( $self->session, 'Flux' );
    my $ac = $self->getAdminConsole();

    # Get the associated Rule..
    my $rule_id = $session->form->get('ruleId');
    return undef
        if !$rule_id;
    my $rule = WebGUI::Flux::Rule->new( $session, $rule_id );

    my %fieldDefaults = WebGUI::Flux::Expression->getFieldDefaults();
    my %mutableFields = map { $_ => exists $fieldDefaults{$_} ? $fieldDefaults{$_} : undef }
        WebGUI::Flux::Expression->getMutableFields();
    my $form = $self->_buildExpressionForm(
        {   %mutableFields,
            hidden => {
                flux   => 'addExpressionSave',
                ruleId => $rule_id,
            },
        }
    );
    
    my $output = q{};

    if ($error) {
        $output .= <<"END_MESSAGE";
<div class="error">
    $error
</div>
END_MESSAGE
    }

    return $ac->render( $output . $EXPRESSION_INSTRUCTIONS . $form->print, 'Add Expression' );
}

#-------------------------------------------------------------------

=head2 www_addExpressionSave () 

Creates a new Flux Expression.

=cut

sub www_addExpressionSave {
    my $self    = shift;
    my $session = $self->session;
    return $session->privilege->adminOnly() unless ( $session->user->isInGroup("3") );

    # Get the associated Rule..
    my $rule_id = $session->form->get('ruleId');
    return undef
        if !$rule_id;
    my $rule = WebGUI::Flux::Rule->new( $session, $rule_id );
    
    use Data::Dumper;
    my @m = WebGUI::Flux::Expression->getMutableFields();

    my %updates = map { $_ => defined $session->form->get($_) ? $session->form->get($_) : undef } WebGUI::Flux::Expression->getMutableFields();
    
    eval { $rule->addExpression( \%updates ) };
    if ( my $e = Exception::Class->caught() ) {
        $session->log->warn( 'Error: ' . $e );
        return $self->www_addExpression( 'Error: ' . $e );
    }

    return $self->www_manageRule();
}

#-------------------------------------------------------------------

=head2 www_deleteExpression () 

Deletes a Flux Expression.

=cut

sub www_deleteExpression {
    my $self    = shift;
    my $session = $self->session;
    return $session->privilege->adminOnly() unless ( $session->user->isInGroup("3") );
    
    # Get the associated Rule..
    my $rule_id = $session->form->get('ruleId');
    return undef
        if !$rule_id;
    my $rule = WebGUI::Flux::Rule->new( $session, $rule_id );
    
    my $expression_id = $session->form->get('id');
    return $self->www_admin()
        if !$expression_id;

    my $expression = WebGUI::Flux::Expression->new( $rule, $expression_id );

    eval { $expression->delete(); };
    if ( my $e = Exception::Class->caught() ) {
        $session->log->warn( 'Error: ' . $e );
        return $self->www_admin( 'Error: ' . $e );
    }
    return $self->www_manageRule();
}

#-------------------------------------------------------------------

=head2 www_editExpression ()

Displays the edit Expression page.

=cut

sub www_editExpression {
    my $self    = shift;
    my $error   = shift;
    my $session = $self->session;

    # Check permissions..
    return $self->session->privilege->insufficient
        if !$self->canManage();

    my $i18n = WebGUI::International->new( $self->session, 'Flux' );
    my $ac = $self->getAdminConsole();
    
    # Get the associated Rule..
    my $rule_id = $session->form->get('ruleId');
    return undef
        if !$rule_id;
    my $rule = WebGUI::Flux::Rule->new( $session, $rule_id );

    my $expression_id = $session->form->get('id');

    my $expression
        = $expression_id
        ? WebGUI::Flux::Expression->new( $rule, $expression_id )
        : undef;

    my %mutableFields = map { $_ => $expression->get($_) } WebGUI::Flux::Expression->getMutableFields();
    my $form = $self->_buildExpressionForm(
        {   %mutableFields,
            hidden => {
                flux => 'editExpressionSave',
                ruleId => $rule_id,
                id   => $expression->getId(),
            },
        }
    );

    my $output = q{};

    if ($error) {
        $output .= <<"END_MESSAGE";
<div class="error">
    $error
</div>
END_MESSAGE
    }

    return $ac->render( $output . $EXPRESSION_INSTRUCTIONS . $form->print, 'Edit Expression' );
}

#-------------------------------------------------------------------

=head2 www_editExpressionSave () 

Saves Flux Expression edits.

=cut

sub www_editExpressionSave {
    my $self    = shift;
    my $session = $self->session;
    return $session->privilege->adminOnly() unless ( $session->user->isInGroup("3") );

    # Get the associated Rule..
    my $rule_id = $session->form->get('ruleId');
    return undef
        if !$rule_id;
    my $rule = WebGUI::Flux::Rule->new( $session, $rule_id );
    
    my $expression_id = $session->form->get('id');
    return undef
        if !$expression_id;

    my $expression = WebGUI::Flux::Expression->new( $rule, $expression_id );
    my %updates = map { $_ => defined $session->form->get($_) ? $session->form->get($_) : undef } WebGUI::Flux::Expression->getMutableFields();
    eval { $expression->update( \%updates ) };
    if ( my $e = Exception::Class->caught() ) {
        $session->log->warn( 'Error: ' . $e );
        return $self->www_editExpression( 'Error: ' . $e );
    }
    return $self->www_manageRule();
}

#-------------------------------------------------------------------
sub _buildExpressionForm {
    my ( $self, $arg_ref ) = @_;

    # Build an HTMLForm..
    my $form = WebGUI::HTMLForm->new( $self->session );

    $form->submit;
    
    # Add hidden fields..
    if ( my $hidden = $arg_ref->{hidden} ) {
        while ( my ( $key, $val ) = each %{$hidden} ) {
            $form->hidden( name => $key, value => $val );
        }
    }

    $form->text(
        name      => 'name',
        value     => $arg_ref->{name},
        label     => 'Rule Name',
        hoverHelp => 'The name of this Flux Rule',
    );
    $form->text(
        name      => 'operand1',
        value     => $arg_ref->{operand1},
        label     => 'First Operand',
        hoverHelp => 'The module name of the first Operand. Valid options are: TextValue, NumericValue, TruthValue, UserProfileField, Group, DateTime, FluxRule',
    );
    $form->textarea(
        name      => 'operand1Args',
        value     => $arg_ref->{operand1Args},
        label     => 'First Operand Arguments',
        hoverHelp => q[JSON-encoded arguments for the first Operand. \n] 
                   . q[TextValue, NumericValue and TruthValue expect: {"value":  "myvalue"} \n]
                   . q[DateTime expects: ],
    );
    $form->text(
        name  => 'operand1Modifier',
        value => $arg_ref->{operand1Modifier},
        label => 'First Operand Modifier',
        hoverHelp =>
            'The module name of the first Operand Modifier, e.g. DateTimeFormat, DateTimeCompareToNow, etc..',
    );
    $form->textarea(
        name      => 'operand1ModifierArgs',
        value     => $arg_ref->{operand1ModifierArgs},
        label     => 'First Operand Modifier Arguments',
        hoverHelp => 'JSON-encoded arguments for the first Operand Modifier',
    );
    $form->text(
        name      => 'operator',
        value     => $arg_ref->{operator},
        label     => 'Operator',
        hoverHelp => 'The module name of the Operator, e.g. IsEqualTo, IsLessThan, etc..',
    );
    $form->text(
        name      => 'operand2',
        value     => $arg_ref->{operand2},
        label     => 'Second Operand',
        hoverHelp => 'The module name of the second Operand, e.g. TextValue, UserProfileField, etc..',
    );
    $form->textarea(
        name      => 'operand2Args',
        value     => $arg_ref->{operand2Args},
        label     => 'Second Operand Arguments',
        hoverHelp => 'JSON-encoded arguments for the second Operand',
    );
    $form->text(
        name  => 'operand2Modifier',
        value => $arg_ref->{operand2Modifier},
        label => 'Second Operand Modifier',
        hoverHelp =>
            'The module name of the second Operand Modifier, e.g. DateTimeFormat, DateTimeCompareToNow, etc..',
    );
    $form->textarea(
        name      => 'operand2ModifierArgs',
        value     => $arg_ref->{operand2ModifierArgs},
        label     => 'Second Operand Modifier Arguments',
        hoverHelp => 'JSON-encoded arguments for the second Operand Modifier',
    );
    $form->hidden(
        name  => 'sequenceNumber',
        value => $arg_ref->{sequenceNumber},
    );

    $form->submit;

    return $form;
}

#-------------------------------------------------------------------

=head2 www_manageRule ()

Displays the Expressions in a Rule.

=cut

sub www_manageRule {
    my $self = shift;
    my $session = $self->session;

    # Check permissions..
    return $self->session->privilege->insufficient
        if !$self->canManage();

    my $i18n    = WebGUI::International->new( $self->session, 'Flux' );
    my $ac      = $self->getAdminConsole();

    # Get the associated Rule..
    my $rule_id = $session->form->get('ruleId');
    return undef
        if !$rule_id;
    my $rule = WebGUI::Flux::Rule->new( $session, $rule_id );
    
    my $output = q{<table><tbody>};

   my $add_icon  = $self->session->icon->delete("flux=addExpression&ruleId=$rule_id");
    $add_icon =~ s{toolbar/bullet/delete}{flux/add2};
    $output .= <<"END_RULEHEADER";
<tr>
    <td class='formDescription' valign="top" style="width: 350px;">
        $add_icon Add Expression
    </td>
</tr>
END_RULEHEADER

    foreach my $expression ( @{ $rule->getExpressions() } ) {
        my $name        = $expression->get('name');
        my $id          = $expression->getId();
        my $sequenceNumber = $expression->get('sequenceNumber');
        my $edit_icon   = $self->session->icon->edit("flux=editExpression&id=$id&ruleId=$rule_id");
        my $delete_icon = $self->session->icon->delete("flux=deleteExpression&id=$id&ruleId=$rule_id");

        $output .= <<"END_RULEROW";
<tr>
    <td class='formDescription' valign="top" style="width: 350px;">
        e$sequenceNumber: $name
    </td>
    <td class='tableData' valign="top">
        $edit_icon
    </td>
    <td class='tableData' valign="top">
        $delete_icon
    </td>
 </tr>
END_RULEROW

    }
    $output .= q{</tbody></table>};

    return $ac->render( $output, 'Manage Rule' );
}

1;
