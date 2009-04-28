package WebGUI::PassiveAnalytics::Rule;

use base qw/WebGUI::Crud/;
use WebGUI::International;

=head1 NAME

Package WebGUI::PassiveAnalytics::Rule;

=head1 DESCRIPTION

Base class for rules that are used to analyze the Passive Analytics log.

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 crud_definition ( )

WebGUI::Crud definition for this class.

=head3 tableName

analyticRule.

=head3 tableKey

ruleId

=head3 sequenceKey

None.  There is only 1 sequence of rules for a site.

=head3 properties

=head4 bucketName

The name of a bucket to hold results for this rule.

=head4 regular expression.

A regular expression to match against log entries.

=cut

sub crud_definition {
    my ($class, $session) = @_;
    my $definition = $class->SUPER::crud_definition($session);
    $definition->{tableName}   = 'analyticRule';
    $definition->{tableKey}    = 'ruleId';
    $definition->{sequenceKey} = '';
    my $properties = $definition->{properties};
    my $i18n = WebGUI::International->new($session);
    $properties->{bucketName} = {
        fieldType    => 'text',
        label        => $i18n->get('Bucket Name','PassiveAnalytics'),
        hoverHelp    => $i18n->get('Bucket Name help','PassiveAnalytics'),
        defaultValue => '',
    };
    $properties->{regexp} = {
        fieldType    => 'text',
        label        => $i18n->get('regexp','PassiveAnalytics'),
        hoverHelp    => $i18n->get('regexp help','PassiveAnalytics'),
        defaultValue => '.+',
    };
    return $definition;
}

#-------------------------------------------------------------------

=head2 matchesBucket ( $logLine )

Executes the rule to determine if a log file entry matches the rule.

=head3 $logLine

A hashref of information from 1 line of the logs.

=cut

sub matchesBucket {
    my ($self, $logLine) = @_;
    my $regexp = $self->get('regexp');
    return $logLine->{url} =~ m/$regexp/;
}

1;
#vim:ft=perl
