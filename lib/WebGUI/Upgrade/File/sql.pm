package WebGUI::Upgrade::File::sql;
use strict;
use warnings;

use WebGUI::Config;

sub run {
    my ($class, $configFile, $version, $file, $quiet) = @_;

    my $config = WebGUI::Config->new($configFile, 1);
    my $dsn = $config->get('dsn');
    my $username = $config->get('dbuser');
    my $password = $config->get('dbpass');
    my $database = ( split /[:;]/msx, $dsn )[2];
    my $hostname = 'localhost';
    my $port = '3306';
    while ( $dsn =~ /([^=;:]+)=([^;:]+)/msxg ) {
        if ( $1 eq 'host' || $1 eq 'hostname' ) {
            $hostname = $2;
        }
        elsif ( $1 eq 'db' || $1 eq 'database' || $1 eq 'dbname' ) {
            $database = $2;
        }
        elsif ( $1 eq 'port' ) {
            $port = $2;
        }
    }

    my @command_line = (
        'mysql',
        '-h' . $hostname,
        '-P' . $port,
        $database,
        '-u' . $username,
        ( $password ? '-p' . $password : () ),
        '--default-character-set=utf8',
        '--batch',
        '--execute=source ' . $file,
    );
    system { $command_line[0] } @command_line
        and die "$!";
    return 1;
}

1;

