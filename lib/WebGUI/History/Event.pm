package WebGUI::History::Event;

use strict;
use Params::Validate qw(:all);
use base 'WebGUI::Crud';

Params::Validate::validation_options( on_fail => sub { WebGUI::Error::InvalidParam->throw( error => shift ) } );

=head2 crud_definition

Overrides WebGUI::Crud::crud_definition

=cut

sub crud_definition {
    my $class = shift;
    my ($session) = validate_pos( @_, { isa => 'WebGUI::Session' } );
    my $definition = $class->SUPER::crud_definition($session);
    $definition->{tableName} = 'historyEvent';
    $definition->{tableKey}  = 'historyEventId';
    $definition->{properties}{label}  = { fieldType => 'Text', };
    return $definition;
}

1;
