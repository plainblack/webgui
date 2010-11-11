package WebGUI::PassiveAnalytics::Rule;

use Moose;
use WebGUI::Definition::Crud;
extends qw/WebGUI::Crud/;
define tableName   => 'analyticRule';
define tableKey    => 'ruleId';
has ruleId => (
    required => 1,
    is       => 'ro',
);
property bucketName => (
    fieldType    => 'text',
    label        => ['Bucket Name','PassiveAnalytics'],
    hoverHelp    => ['Bucket Name help','PassiveAnalytics'],
    default      => '',
);
property regexp => (
    fieldType    => 'text',
    label        => ['regexp','PassiveAnalytics'],
    hoverHelp    => ['regexp help','PassiveAnalytics'],
    default      => '.+',
);
use WebGUI::International;

=head1 NAME

Package WebGUI::PassiveAnalytics::Rule;

=head1 DESCRIPTION

Base class for rules that are used to analyze the Passive Analytics log.

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 matchesBucket ( $logLine )

Executes the rule to determine if a log file entry matches the rule.

=head3 $logLine

A hashref of information from 1 line of the logs.

=cut

sub matchesBucket {
    my ($self, $logLine) = @_;
    my $regexp = $self->regexp;
    return $logLine->{url} =~ m/$regexp/;
}

1;
#vim:ft=perl
