package WebGUI::Upgrade::File::pod;
use Moose;
with 'WebGUI::Upgrade::File';

sub once { 1 }

sub run {
    my $class = shift;
    my ($upgrade, $configFile, $version, $file) = @_;
    if ( ! $upgrade->quiet ) {
        system { $^X } $^X, '-MPod::Perldoc', '-ePod::Perldoc->run', $file;
    }

    return 1;
}

__PACKAGE__->meta->make_immutable;
1;

