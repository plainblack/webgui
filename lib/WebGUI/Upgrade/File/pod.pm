package WebGUI::Upgrade::File::pod;
use Moose;
with 'WebGUI::Upgrade::File';

sub once { 1 }

sub run {
    my $self = shift;
    if ( ! $self->quiet ) {
        system { $^X } $^X, '-MPod::Perldoc', '-ePod::Perldoc->run', $self->file;
    }

    return 1;
}

__PACKAGE__->meta->make_immutable;
1;

