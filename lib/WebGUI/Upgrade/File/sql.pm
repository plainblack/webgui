package WebGUI::Upgrade::File::sql;
use Moose;
with 'WebGUI::Upgrade::File';

sub run {
    my $self = shift;

    my @command_line = (
        $self->upgrade->mysql,
        $self->upgrade->mysqlCommandLine($self->configFile),
        '--batch',
        '--execute=source ' . $self->file,
    );

    system { $command_line[0] } @command_line
        and die "$!";
    return 1;
}

__PACKAGE__->meta->make_immutable;
1;

