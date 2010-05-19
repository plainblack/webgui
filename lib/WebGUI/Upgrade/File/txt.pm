package WebGUI::Upgrade::File::txt;
use Moose;
with 'WebGUI::Upgrade::File';

sub once { 1 }

sub run {
    my $class = shift;
    my ($upgrade, $configFile, $version, $file) = @_;
    if ( ! $upgrade->quiet ) {
        open my $fh, '<', $file;
        while ( my $line = <$fh> ) {
            print $line;
        }
        close $fh;
        if (-t STDIN) {
            print "\nPress ENTER to continue... ";
            my $nothing = <>;
        }
    }

    return 1;
}

__PACKAGE__->meta->make_immutable;
1;

