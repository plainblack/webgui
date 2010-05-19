package WebGUI::Upgrade::File::sql;
use Moose;
with 'WebGUI::Upgrade::File';

sub run {
    my $class = shift;
    my ($upgrade, $configFile, $version, $file) = @_;

    my @command_line = (
        $upgrade->mysql,
        $upgrade->mysqlCommandLine($configFile),
        '--batch',
        '--execute=source ' . $file,
    );

    system { $command_line[0] } @command_line
        and die "$!";
    return 1;
}

__PACKAGE__->meta->make_immutable;
1;

