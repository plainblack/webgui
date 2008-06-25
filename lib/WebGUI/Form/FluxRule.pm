package WebGUI::Form::FluxRule;

use strict;
use base 'WebGUI::Form::SelectList';
use WebGUI::International;
use WebGUI::SQL;
use WebGUI::Flux;

=head1 NAME

Package WebGUI::Form::FluxRule

=head1 DESCRIPTION

Creates a FluxRule chooser field.

=head1 SEE ALSO

This is a subclass of WebGUI::Form::SelectList.

=head1 METHODS 

The following methods are specifically available from this class. Check the superclass for additional methods.

=cut

#-------------------------------------------------------------------

=head2 areOptionsSettable ( )

Returns 0.

=cut

sub areOptionsSettable {
    return 0;
}

#-------------------------------------------------------------------

=head2 definition ( [ additionalTerms ] )

See the super class for additional details.

=head3 additionalTerms

The following additional parameters have been added via this sub class.

=head4 size

How many rows should be displayed at once? Defaults to 1.

=head4 multiple

Set to "1" if multiple FluxRules should be selectable. Defaults to 0.

=head4 excludeFluxRules

An array reference containing a list of FluxRules to exclude from the list. Defaults to an empty array reference.

=head4 defaultValue

This will be used if no value is specified. Should be passed as an array reference. Defaults to an empty array reference.

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift || [];
	push(@{$definition}, {
		size=>{
			defaultValue=>1
			},
		multiple=>{
			defaultValue=>0
			},
		defaultValue=>{
			defaultValue=>[]
			},
		excludeFluxRules=>{
			defaultValue=>[]
			},
        });
        return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2  getDatabaseFieldType ( )

Returns "VARCHAR(22) BINARY".

=cut 

sub getDatabaseFieldType {
    return "VARCHAR(22) BINARY";
}

#-------------------------------------------------------------------

=head2 getName ( session )

Returns the human readable name of this control.

=cut

sub getName {
    my ($self, $session) = @_;
#    return WebGUI::International->new($session, 'WebGUI')->get('FluxRule');
    return 'Flux Rule';
}

#-------------------------------------------------------------------

=head2 getValueAsHtml ( )

Formats as a name.

=cut

sub getValueAsHtml {
    my $self = shift;
    my $FluxRule = WebGUI::FluxRule->new($self->session, $self->getDefaultValue);
    if (defined $FluxRule) {
        return $FluxRule->name;
    }
    return undef;
}


#-------------------------------------------------------------------

=head2 isDynamicCompatible ( )

A class method that returns a boolean indicating whether this control is compatible with the DynamicField control.

=cut

sub isDynamicCompatible {
    return 1;
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Returns a FluxRule pull-down field. A FluxRule pull down provides a select list that provides name value pairs for all the FluxRules in the WebGUI system.  

=cut

sub toHtml {
	my $self = shift;
	my $where = '';
	if (($self->get('excludeFluxRules')->[0]||'') ne "") {
		$where = "and fluxRuleId not in (".$self->session->db->quoteAndJoin($self->get("excludeFluxRules")).")";
	}
	$self->set('options', $self->session->db->buildHashRef("select fluxRuleId,name from fluxRule where 1 $where order by name"));
	return $self->SUPER::toHtml();
}

#-------------------------------------------------------------------

=head2 toHtmlAsHidden ( )

Creates a series of hidden fields representing the data in the list.

=cut

sub toHtmlAsHidden {
        my $self = shift;
	$self->set("options", $self->session->db->buildHashRef("select fluxRuleId,name from fluxRule"));
        return $self->SUPER::toHtmlAsHidden();
}

#-------------------------------------------------------------------

=head2 toHtmlWithWrapper ( )

Renders the form field to HTML as a table row complete with labels, subtext, hoverhelp, etc. Also adds a manage icon next to the field if the current user is in the admins FluxRule.

=cut

sub toHtmlWithWrapper {
        my $self = shift;
        if ($self->session->user->isInGroup(3)) {
                my $subtext = $self->session->icon->manage("op=listFluxRules");
                $self->set("subtext",$subtext . $self->get("subtext"));
        }
        return $self->SUPER::toHtmlWithWrapper;
}


1;

