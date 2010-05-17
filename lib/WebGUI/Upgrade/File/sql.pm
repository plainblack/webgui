package WebGUI::Upgrade::File::sql;
use strict;
use warnings;

use WebGUI::Config;
use WebGUI::Upgrade;

sub run {
    my ($class, $configFile, $version, $file, $quiet) = @_;

    my $config = WebGUI::Config->new($configFile, 1);
    my @command_line = (
        'mysql',
        WebGUI::Upgrade->mysqlCommandLine($config),
        '--execute=source ' . $file,
    );

    system { $command_line[0] } @command_line
        and die "$!";
    return 1;
}

1;

