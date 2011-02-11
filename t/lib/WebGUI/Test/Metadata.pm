package WebGUI::Test::Metadata;

use warnings;
use strict;

=head1 NAME

WebGUI::Test::Metadata

=head1 SYNOPSIS

    use WebGUI::Test::Metadata;

    my $meta = WebGUI::Test::Metadata->new( $asset, fieldName => 'Foobar' );
    my $type = $meta->fieldType;
    undef $meta; # or just let it go out of scope, whatever suits you

=head1 METHODS

=cut

#----------------------------------------------------------------------------

=head1 DESTROY

When this object goes out of scope, the metadata field will be cleaned up.

=cut

sub DESTROY {
    my $self = shift;
    $self->{asset}->deleteMetaDataField($self->fieldId)
}

#----------------------------------------------------------------------------

=head1 get ([ $asset ])

Gets the value of this metadata field for the asset you passed in (or the one
you passed to new).

=cut

sub get {
    my ($self, $asset) = @_;
    $asset ||= $self->{asset};
    return $asset->getMetaDataFields($self->fieldId)->{value};
}
#----------------------------------------------------------------------------

=head1 new ($asset, %args)

Needs some kind of asset (any old asset will do), and if you want to override
any of the arguments to addMetaDataField, name them in the args hash.

=cut

sub new {
    my $class = shift;
    my $asset = shift;
    my $args  = @_ == 1 ? $_[0] : { @_ };
    my $id = $asset->addMetaDataField(
        $args->{fieldId},
        $args->{fieldName},
        $args->{defaultValue}   || '',
        $args->{description}    || '',
        $args->{fieldType}      || 'text',
        $args->{possibleValues} || '',
        $args->{classes},
    );

    bless {
        asset => $asset,
        info  => $asset->getMetaDataFields($id),
    }, $class;
}

#----------------------------------------------------------------------------

=head1 update ($value, [ $asset ])

Sets the value of this metadata field for the asset you passed in (or the one
you passed to new).

=cut

sub update {
    my ($self, $value, $asset) = @_;
    $asset ||= $self->{asset};
    $asset->updateMetaData($self->fieldId => $value);
}

=head1 OTHER METHDOS

fieldId, fieldName, description, defaultvalue, fieldType and possibleValues
are all available as methods. They'll get you what getMetaDataFields would
return you.

=cut

BEGIN {
    for my $key (
        qw(
            fieldId
            fieldName
            description
            defaultValue
            fieldType
            possibleValues
        )
    )
    {
        my $accessor = sub { $_[0]->{info}->{$key} };
        no strict 'refs';
        *{__PACKAGE__ . "::$key"} = $accessor;
    }
}

1;
