package WebGUI::Asset::Wobject::Thingy::ThingRecord;


=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2009 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut


use strict;
use Class::InsideOut qw(readonly private id register);
use Tie::IxHash;
use base 'WebGUI::Crud';

private definition => my %definition;

=head1 NAME

Package WebGUI::Asset::Wobject::Thingy::ThingRecord

=head1 DESCRIPTION

=head1 SYNOPSIS


=head1 METHODS

These methods are available from this package:

=cut

#-------------------------------------------------------------------

=head2 create ( session, thingId, [ properties ], [ options ])

Constructor. Creates a new instance of this object. Returns a reference to the object.

=head3 session

A reference to a WebGUI::Session or an object that has a session method. If it's an object that has a session
method, then this object will be passed to new() instead of session as well. This is useful when you are creating
WebGUI::Crud subclasses that require another object to function.

=head3 thingId

The ID of the thing which fields will be used by crud_setDefinition

=head3 properties

The properties that you wish to create this object with. Note that if this object has a sequenceKey then that
sequence key must be specified in these properties or it will throw an execption. See crud_definition() for a list
of all the properties.

=head3 options

A hash reference of creation options.

=head4 id

A guid. Use this to force the row's table key to a specific ID.

=cut

sub create {
    my ($class, $session, $thingId, $properties, $options) = @_;

    unless (defined $session && $session->isa('WebGUI::Session')) {
        WebGUI::Error::InvalidObject->throw(expected=>'WebGUI::Session', got=>(ref $session), error=>'Need a session.');
    }
    unless (defined $thingId && $thingId =~ m/^[A-Za-z0-9_-]{22}$/) {
        WebGUI::Error::InvalidParam->throw(error=>'create needs a thingId');
    }

    $class->crud_setDefinition($session,$thingId);

    my $newThingRecord = $class->SUPER::create($session,$properties,$options);
    return $newThingRecord;
}

#-------------------------------------------------------------------

=head2 crud_definition

WebGUI::Crud definition for this class.

Returns a reference to the private definition hash of this class, which can be set using crud_setDefinition.

=cut

sub crud_definition {
    my ($class, $session) = @_;
    unless (defined $session && $session->isa('WebGUI::Session')) {
        WebGUI::Error::InvalidObject->throw(expected=>'WebGUI::Session', got=>(ref $session), error=>'Need a session.');
    }
    return \%definition;
}

#-------------------------------------------------------------------

=head2 crud_setDefinition ( session )

A management class method that sets the definition of this class

=head3 session

A reference to a WebGUI::Session.

=cut

sub crud_setDefinition {

    my ($class, $session, $thingId) = @_;
    unless (defined $session && $session->isa('WebGUI::Session')) {
        WebGUI::Error::InvalidObject->throw(expected=>'WebGUI::Session', got=>(ref $session), error=>'Need a session.');
    }
    unless (defined $thingId && $thingId =~ m/^[A-Za-z0-9_-]{22}$/) {
        WebGUI::Error::InvalidParam->throw(error=>'crud_setDefinition needs a thingId');
    }

    tie my %properties, 'Tie::IxHash';
    my $fields = $session->db->read('select * from Thingy_fields where thingId = ? order by sequenceNumber',[$thingId]);
    while (my $field = $fields->hashRef) {
        my $fieldName = 'field_'.$field->{fieldId};
        $properties{$fieldName} = $field;
    }
    $properties{updatedById} =  {
            fieldType       => 'guid',
            defaultValue    => $session->user->userId,
        };
    $properties{updatedByName} =  {
            fieldType       => 'text',
            defaultValue    => $session->user->username,
        };
=cut
    $properties{lastUpDated} =  {
            fieldType       => 'datetime',
            defaultValue    => WebGUI::DateTime->new($session, time())->toDatabase,
        };
=cut
    $properties{createdById} =  {
            fieldType       => 'guid',
            defaultValue    => $session->user->userId,
        };
    $properties{ipAddress} =  {
            fieldType       => 'text',
            defaultValue    => $session->env->getIp,
        };

    %definition = (
        tableName   => "Thingy_".$thingId,
        tableKey    => 'thingDataId',
        sequenceKey => '',
        properties  => \%properties,
    );
}

#-------------------------------------------------------------------

=head2 new ( session, id, thingId )

Constructor.

=head3 session

A reference to a WebGUI::Session.

=head3 id

A guid, the unique identifier for this object.

=head3 thingId

The ID of the thing which fields will be used by crud_setDefinition

=cut

sub new {
    my ($class, $session, $id, $thingId) = @_;

    unless (defined $session && $session->isa('WebGUI::Session')) {
        WebGUI::Error::InvalidObject->throw(expected=>'WebGUI::Session', got=>(ref $session), error=>'Need a session.');
    }
    # Set class definition unless new() is called by create() in which case definition is already set.
    unless (defined %definition){
        unless (defined $thingId && $thingId =~ m/^[A-Za-z0-9_-]{22}$/) {
            WebGUI::Error::InvalidParam->throw(error=>'need a thingId');
        }
        $class->crud_setDefinition($session,$thingId);
    }

    my $newThingRecord = $class->SUPER::new($session,$id);
    return $newThingRecord;
}

1;

