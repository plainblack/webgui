package WebGUI::Test::Fork;

sub simple {
    my ( $self, $arr ) = @_;
    $self->update( $arr->[0] );
}

sub error {
    my ( $self, $arr ) = @_;
    die "$arr->[0]\n";
}

sub complex {
    my $self = shift;
    $self->update( sub {'foo'} );
    $self->update( sub {'bar'} );
    $self->update( sub {'baz'} );
}

1;
