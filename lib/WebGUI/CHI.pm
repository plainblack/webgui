package WebGUI::CHI;

# WebGUI cache for CHI

use base 'WebGUI::Cache';
use CHI;

sub delete {
    my ( $self, $name ) = @_;
    my $key = $self->parseKey( $name );
    return $self->{chi}->remove( $key );
}

sub flush {
    return $_[0]->{chi}->clear;
}

sub get {
    my ( $self, $name ) = @_;
    my $key = $self->parseKey( $name );
    return $self->{chi}->get( $key );
}

sub mget { 
    my ( $self, $names ) = @_;
    my @keys = map { $self->parseKey($_) } @{ $names };
    return $self->{chi}->get_multi_arrayref(\@keys);
}

sub new {
    my ( $class, $session, %config ) = @_;
    my $self    = bless { _session => $session, chi => undef, }, $class;

    # Build CHI object
    $self->{chi} = CHI->new( %config );

    return $self;
}

sub set {
    my ( $self, $name, $value, $ttl ) = @_;
    $ttl ||= 60;
    my $key = $self->parseKey( $name );
    return $self->{chi}->set( $key, $value, $ttl );
}

1;
