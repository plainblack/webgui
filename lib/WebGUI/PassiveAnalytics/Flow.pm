package WebGUI::PassiveAnalytics::Flow;

use strict;
use Tie::IxHash;
use WebGUI::AdminConsole;
use WebGUI::HTMLForm;
use WebGUI::International;
use WebGUI::Pluggable;
use WebGUI::PassiveAnalytics::Rule;
use WebGUI::Utility;
use WebGUI::HTMLForm;
use WebGUI::Workflow;
use WebGUI::Workflow::Instance;

=head1 NAME

Package WebGUI::PassiveAnalytics::Flow

=head1 DESCRIPTION

Web interface for making sets of rules for doing passive analytics, and
running them.

=cut

#----------------------------------------------------------------------------

=head2 canView ( session [, user] )

Returns true if the user can administrate this operation. user defaults to 
the current user.

=cut

sub canView {
    my $session     = shift;
    my $user        = shift || $session->user;
    return $user->isInGroup( 3 );
}

#-------------------------------------------------------------------

=head2 www_deleteRule ( )

Deletes an activity from a workflow.

=cut

sub www_deleteRule {
    my $session = shift;
    return $session->privilege->insufficient() unless canView($session);
    my $rule = WebGUI::PassiveAnalytics::Rule->new($session, $session->form->get("ruleId"));
    if (defined $rule) {
        $rule->delete;
    }
    return www_editRuleflow($session);
}

#------------------------------------------------------------------

=head2 www_demoteRule ( session )

Moves a Rule down one position in the execution order.

=head3 session

A reference to the current session.

=cut

sub www_demoteRule {
	my $session = shift;
	return $session->privilege->insufficient() unless canView($session);
    my $rule = WebGUI::PassiveAnalytics::Rule->new($session, $session->form->get("ruleId"));
    if (defined $rule) {
        $rule->demote;
    }
	return www_editRuleflow($session);
}

#-------------------------------------------------------------------

=head2 www_editRuleflow ( session )

Configure a set of analyses to run on the passive logs.  The analysis is destructive.

=cut

sub www_editRuleflow {
    my $session = shift;
    my $error   = shift;
    return $session->privilege->insufficient() unless canView($session);
    if ($error) {
        $error = qq|<div class="error">$error</div>\n|;
    }
    my $i18n = WebGUI::International->new($session, "PassiveAnalytics");
    my $addmenu = '<div style="float: left; width: 200px; font-size: 11px;">';
    $addmenu .= sprintf '<a href="%s">%s</a>',
        $session->url->page('op=passiveAnalytics;func=editRule'),
        $i18n->get('Add a bucket');
    $addmenu .= '</div>';
    my $f = WebGUI::HTMLForm->new($session);
    $f->hidden(
        name=>'op',
        value=>'passiveAnalytics'
    );
    $f->hidden(
        name=>'func',
        value=>'editRuleflowSave'
    );
    $f->integer(
        name      => 'pauseInterval',
        value     => $session->form->get('pauseInterval') || 300,
        label     => $i18n->get('pause interval'),
        hoverHelp => $i18n->get('pause interval help'),
    );
    $f->submit(value => $i18n->get('Begin analysis'));
    my $steps = '<table class="content"><tbody>';
    my $getARule = WebGUI::PassiveAnalytics::Rule->getAllIterator($session);
    my $icon = $session->icon;
    while (my $rule = $getARule->()) {
        my $id     = $rule->getId;
        my $bucket = $rule->get('bucketName');
        $steps .= '<tr><td>'
               .  $icon->delete(  'op=passiveAnalytics;func=deleteRule;ruleId='.$id, undef, $i18n->get('confirm delete rule'))
               .  $icon->edit(    'op=passiveAnalytics;func=editRule;ruleId='.$id)
               .  $icon->moveDown('op=passiveAnalytics;func=demoteRule;ruleId='.$id)
               .  $icon->moveUp(  'op=passiveAnalytics;func=promoteRule;ruleId='.$id)
               .  '</td><td>'.$bucket.'</td></tr>';
               
    }
    $steps .= '<tr><td>&nbsp;</td><td>Other</td></tbody></table><div style="clear: both;"></div>';
    my $ac = WebGUI::AdminConsole->new($session,'passiveAnalytics');
    return $ac->render($error.$f->print.$addmenu.$steps, 'Passive Analytics');
}

#-------------------------------------------------------------------

=head2 www_editRuleflowSave ( )

Saves the results of www_editRuleflow()

=cut

sub www_editRuleflowSave {
    my $session = shift;
    return $session->privilege->insufficient() unless canView($session);
    my $workflow = WebGUI::Workflow->new($session, 'PassiveAnalytics000001');
    return www_editRuleflow($session, "The Passive Analytics workflow has been deleted.  Please contact an Administrator immediately.") unless defined $workflow;
    my $delta = $session->form->process('pauseInterval','integer');
    my $activities = $workflow->getActivities();
    ##Note, they're in order, and the order is known.
    $activities->[0]->set('deltaInterval', $delta);
    $activities->[1]->set('userId', $session->user->userId);
    my $instance = WebGUI::Workflow::Instance->create($session, {
        workflowId => $workflow->getId,
        priority   => 1,
    });
    if (!defined $instance) {
        return www_editRuleflow($session, "A Passive Analytics analysis is currently running.") if $session->stow->get('singletonWorkflowClash');
        return www_editRuleflow($session, "Error creating the workflow instance.");
    }
    $instance->start('skipRealtime');
    return www_editRuleflow($session, "Passive Analytics session started");
}


#-------------------------------------------------------------------

=head2 www_editRule ( )

Displays a form to edit the properties rule.

=cut

sub www_editRule {
    my $session = shift;
    return $session->privilege->insufficient() unless canView($session);

    ##Make a PassiveAnalytics rule to use to populate the form.
    my $ruleId = $session->form->get('ruleId'); 
    my $rule;
    if ($ruleId) {
        $rule = WebGUI::PassiveAnalytics::Rule->new($session, $ruleId);
    }
    else {
        ##We need a temporary rule so that we can call dynamicForm, below
        $ruleId = 'new';
        $rule = WebGUI::PassiveAnalytics::Rule->create($session, {});
    }

    ##Build the form
	my $form = WebGUI::HTMLForm->new($session);
	$form->hidden( name=>"op",     value=>"passiveAnalytics");
	$form->hidden( name=>"func",   value=>"editRuleSave");
	$form->hidden( name=>"ruleId", value=>$ruleId);
    $form->dynamicForm([WebGUI::PassiveAnalytics::Rule->crud_definition($session)], 'properties', $rule);
	$form->submit;

	my $i18n = WebGUI::International->new($session, 'PassiveAnalytics');
	my $ac   = WebGUI::AdminConsole->new($session,'passiveAnalytics');
	$ac->addSubmenuItem($session->url->page("op=passiveAnalytics;func=editRuleflow"), $i18n->get("manage ruleset"));
    if ($ruleId eq 'new') {
        $rule->delete;
    }
	return $ac->render($form->print,$i18n->get('Edit Rule'));
}

#-------------------------------------------------------------------

=head2 www_editRuleSave ( )

Saves the results of www_editRule().

=cut

sub www_editRuleSave {
    my $session = shift;
    return $session->privilege->insufficient() unless canView($session);
    my $ruleId = $session->form->get('ruleId');
    my $rule;
    if ($ruleId eq 'new') {
        $rule = WebGUI::PassiveAnalytics::Rule->create($session, {});
    }
    else {
        $rule = WebGUI::PassiveAnalytics::Rule->new($session, $ruleId);
    }
    $rule->updateFromFormPost if $rule;
    return www_editRuleflow($session);
}

#------------------------------------------------------------------

=head2 www_promoteRule ( session )

Moves a rule up one position in the execution order.

=head3 session

A reference to the current session.

=cut

sub www_promoteRule {
	my $session = shift;
	return $session->privilege->insufficient() unless canView($session);
    my $rule = WebGUI::PassiveAnalytics::Rule->new($session, $session->form->get("ruleId"));
    if (defined $rule) {
        $rule->promote;
    }
	return www_editRuleflow($session);
}

1;
