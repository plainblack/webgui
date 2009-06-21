package WebGUI::History;

use strict;
use JSON;
use Params::Validate qw(:all);
use Test::Deep::NoTest;
use base 'WebGUI::Crud';
use Class::InsideOut qw( public readonly private register id );
Params::Validate::validation_options( on_fail => sub { WebGUI::Error::InvalidParam->throw( error => shift ) } );

private event => my %event;
private asset => my %asset;
private user  => my %user;

=head2 crud_definition

Overrides WebGUI::Crud::crud_definition

=cut

sub crud_definition {
    my $class = shift;
    my ($session) = validate_pos( @_, { isa => 'WebGUI::Session' } );
    my $definition = $class->SUPER::crud_definition($session);
    $definition->{tableName} = 'history';
    $definition->{tableKey}  = 'historyId';
    my $properties = $definition->{properties};

    # History events are commonly bound to a userId..
    $properties->{userId} = { fieldType => 'User', };

    # ..and often to an assetId..
    $properties->{assetId} = { fieldType => 'Asset', };

    # ..and they can be bound to registered History Event types
    $properties->{historyEventId} = { fieldType => 'Guid', };

    # ..and anything else goes in 'data'
    $properties->{data} = {
        fieldType    => 'Textarea',
        defaultValue => {},
        serialize    => 1,
    };

    return $definition;
}

#-------------------------------------------------------------------

=head2 event

Returns the associated L<WebGUI::History::Event> object

=cut

sub event {
    my $self = shift;

    $event{ id $self}
        or $event{ id $self} = do {
        WebGUI::History::Event->new( $self->session, $self->get('historyEventId') );
        }
}

#-------------------------------------------------------------------

=head2 asset

Returns the associated L<WebGUI::Asset> object

=cut

sub asset {
    my $self = shift;

    $asset{ id $self}
        or $asset{ id $self} = do {
        WebGUI::Asset->new( $self->session, $self->get('assetId') );
        }
}

#-------------------------------------------------------------------

=head2 user

Returns the associated L<WebGUI::User> object

=cut

sub user {
    my $self = shift;

    $user{ id $self}
        or $user{ id $self} = do {
        WebGUI::User->new( $self->session, $self->get('userId') );
        }
}

#-------------------------------------------------------------------

sub label {
    my $self = shift;
    $self->event && $self->event->get('label');
}

#no warnings;
#
#=head2 all ($session, $options)
#
#=head3 options
#
#=over 4
#
#=item constraints
#
#=item historyEventId
#
#=item afterAllHistoryEventId
#
#=item userId
#
#=item dataSuperHashOf
#
#=item returnObjects
#
#=back
#
#=cut
#
#sub all {
#    my $class = shift;
#    my ( $session, $options )
#        = validate_pos( @_, { isa => 'WebGUI::Session' }, { type => HASHREF, default => {} } );
#
#    my @constraints = @{ $options->{constraints} || [] };
#
#    if ( my $userId = $options->{userId} ) {
#        push @constraints, { 'userId = ?' => $userId };
#    }
#
#    if ( my $historyEventId = $options->{historyEventId} ) {
#        push @constraints, { 'historyEventId = ?' => $historyEventId };
#    }
#
#    if ( my $afterAllHistoryEventId = $options->{afterAllHistoryEventId} ) {
#        my $table = $class->crud_getTableName($session);
#        my $sql   = "select max(dateCreated) from $table where historyEventId = "
#            . $session->db->quote($afterAllHistoryEventId);
#
#        if ( my $userId = $options->{userId} ) {
#            $sql .= " and userId = " . $session->db->quote($userId);
#        }
#
#        my $latest = $session->db->quickScalar($sql);
#        push @constraints, { 'dateCreated > ?' => $latest } if $latest;
#    }
#
#    my $orderBy = $options->{orderBy} || 'dateCreated';
#
#    my @ids = @{
#        $class->getAllIds(
#            $session,
#            {   constraints => \@constraints,
#                orderBy     => $orderBy,
#            }
#        )
#        };
#
#    if ( $options->{dataSuperHashOf} ) {
#        @ids = grep { $class->new( $session, $_ )->dataSuperHashOf( $options->{dataSuperHashOf} ) } @ids;
#    }
#
#    if ( $options->{returnObjects} ) {
#        return map { $class->new( $session, $_ ) } @ids;
#    }
#    else {
#        return @ids;
#    }
#}
#use warnings;

=head2 mostRecent ($session, $options)

Returns the most recent History object for the user. 

Has the same signature as L<WebGUI::Crud::getAllSql>, plus the following extra options

=over 4

=item userId

=item historyEventId

=item assetId

=back

=cut

sub mostRecent {
    my $class = shift;
    my ( $session, $options )
        = validate_pos( @_, { isa => 'WebGUI::Session' }, { type => HASHREF, default => {} } );

    $options->{limit}   = 1;
    $options->{orderBy} = 'dateCreated desc';

    for my $opt qw(userId assetId historyEventId) {
        next unless defined $options->{$opt};
        push @{ $options->{constraints} }, { "$opt = ?" => $options->{$opt} };
        delete $options->{$opt};
    }
    my $mostRecent = __PACKAGE__->getAllIterator( $session, $options )->();
    return unless $mostRecent;
    return $mostRecent;
}

#sub dataSuperHashOf {
#    my $self = shift;
#    my ($spec) = validate_pos( @_, { type => HASHREF } );
#
#    return eq_deeply( $self->get('data'), superhashof($spec) );
#}
#
#sub add {
#    my $class = shift;
#    my ( $session, $userId, $historyEventId, $options )
#        = validate_pos( @_, { isa => 'WebGUI::Session' }, 1, 1, { type => HASHREF, default => {} } );
#
#    $options->{userId}         = $userId;
#    $options->{historyEventId} = $historyEventId;
#
#    if ( $options->{singular} && WebGUI::History->all( $session, $options ) ) {
#        $session->log->warn("Singleton event $historyEventId already exists, not adding for user: $userId");
#        return;
#    }
#
#    my $new = WebGUI::History->create( $session,
#        { historyEventId => $historyEventId, userId => $userId, data => $options->{data} } );
#    $session->log->debug("Added event $historyEventId for user: $userId");
#
#    return $new;
#}

1;
