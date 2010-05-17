package WebGUI::Upgrade;

use Moose;
use WebGUI::Paths;
use WebGUI::Pluggable;
use WebGUI::Config;
use WebGUI::SQL;
use Try::Tiny;
use File::Spec;
use File::Path qw(make_path);
use namespace::autoclean;

has quiet => (
    is => 'rw',
    default => undef,
);
has mysql => (
    is => 'rw',
    default => 'mysql',
);
has mysqldump => (
    is => 'rw',
    default => 'mysqldump',
);
has clearCache => (
    is      => 'rw',
    default => 1,
);
has createBackups => (
    is      => 'rw',
    default => 1,
);
has useMaintenanceMode => (
    is      => 'rw',
    default => 1,
);
has backupPath => (
    is      => 'rw',
    default => File::Spec->catdir(File::Spec->tmpdir, 'backups'),
);

sub upgradeSites {
    my $self = shift;
    my @configs = WebGUI::Paths->siteConfigs;
    for my $configFile (@configs) {
        my $bareFilename = $configFile;
        $bareFilename =~ s{.*/}{};
        print "Upgrading $bareFilename:\n";
        try {
            $self->upgradeSite($configFile);
        }
        catch {
            print "Error upgrading $bareFilename: $_\n";
        };
    }
    return 1;
}

sub getCodeVersion {
    require WebGUI;
    return WebGUI->VERSION;
}

sub upgradeSite {
    my $self = shift;
    my ($configFile) = @_;
    my $fromVersion = $self->getCurrentVersion($configFile);
    my $toVersion = $self->getCodeVersion;
    my @steps = $self->calcUpgradePath($fromVersion, $toVersion);
    if ( $self->useMaintenanceMode ) {
        my $dbh = $self->dbhForConfig( $configFile );
        $dbh->do('REPLACE INTO settings (name, value) VALUES (?, ?)', {}, 'upgradeState', 'started');
    }
    for my $step ( @steps ) {
        $self->runUpgradeStep($configFile, $step);
    }
}

sub calcUpgradePath {
    my $class = shift;
    my ($fromVersionStr, $toVersionStr) = @_;
    my $fromVersion = $class->numericVersion($fromVersionStr);
    my $toVersion = $class->numericVersion($toVersionStr);

    my %upgrades;
    opendir my $dh, WebGUI::Paths->upgrades
        or die "Upgrades directory doesn't exist.\n";
    while ( my $dir = readdir $dh ) {
        next
            if $dir =~ /^\./;
        next
            unless -d File::Spec->catdir(WebGUI::Paths->upgrades, $dir);
        if ($dir =~ /^((\d+\.\d+\.\d+)-(\d+\.\d+\.\d+))$/) {
            $upgrades{ $class->numericVersion($2) }{ $class->numericVersion($3) } = $1;
        }
    }
    closedir $dh;

    my @steps;
    while ( 1 ) {
        my $atVersion = @steps ? $steps[-1][0] : $fromVersion;
        last
            if $atVersion eq $toVersion;

        # find the available steps for the version we are at
        my $stepsAvail = $upgrades{ $atVersion };
        if ( $stepsAvail && %{ $stepsAvail } ) {
            # take the lowest destination version, and remove it so it isn't considered again
            my ($nextStep) = sort { $a <=> $b } keys %{ $stepsAvail };
            my $dir = delete $stepsAvail->{$nextStep};
            # add a step for that 
            push @steps, [$nextStep, $dir];
        }
        # if we don't have any steps available, the last step we tried won't work so remove it
        elsif ( @steps ) {
            pop @steps;
        }
        # if there is no way forward and we can't backtrack, bail out
        else {
            die "Can't find upgrade path from $fromVersionStr to $toVersionStr.\n";
        }
    }
    return map { $_->[1] } @steps;
}

sub runUpgradeStep {
    my $self = shift;
    my ($configFile, $step) = @_;

    my ($version) = $step =~ /-(\d+\.\d+\.\d+)$/;
    print "Running upgrades for $step.\n";
    my $upgradesDir = File::Spec->catdir(WebGUI::Paths->upgrades, $step);
    opendir my($dh), $upgradesDir or die "Can't get upgrades for $step: $!\n";
    while ( my $upgradeFile = readdir $dh ) {
        next
            if $upgradeFile =~ /^\./;
        my $filename = File::Spec->catfile($upgradesDir, $upgradeFile);
        next
            unless -f $filename;
        $self->runUpgradeFile($configFile, $version, $filename);
    }
    closedir $dh;
    $self->markVersionUpgrade($configFile, $version);
}

sub runUpgradeFile {
    my $self = shift;
    my ($configFile, $version, $filename, $quiet) = @_;

    my ($extension) = $filename =~ /\.([^.]+)$/;
    return
        unless $extension;

    my $package = 'WebGUI::Upgrade::File::' . $extension;
    if ( try { WebGUI::Pluggable::load($package) } && $package->can('run') ) {
        return $package->run($configFile, $version, $filename, $self->quiet);
    }
    warn "Don't know how to use $extension upgrade file\n";
    return;
}

sub markVersionUpgrade {
    my $self = shift;
    my $configFile = shift;
    my $version = shift;

    my $dbh = $self->dbhForConfig($configFile);

    $dbh->do(
        'INSERT INTO webguiVersion (webguiVersion, versionType, dateApplied) VALUES (?,?,?)', {},
        $version, 'upgrade', time,
    );
    if ( $self->useMaintenanceMode ) {
        $dbh->do('REPLACE INTO settings (name, value) VALUES (?, ?)', {}, 'upgradeState', $version);
    }
}

sub createBackup {
    my $self = shift;
    my $config = shift;

    make_path($self->backupPath);
    my $configFile = ( File::Spec->splitpath($config->pathToFile) )[2];
    my $resultFile = File::Spec->catfile(
        $self->backupPath,
        $configFile . '_' . $self->getCurrentVersion($config) . '_' . time . '.sql',
    );
    my @command_line = (
        $self->mysql,
        $self->mysqlCommandLine($config),
        '--add-drop-table',
        '--result-file=' . $resultFile,
    );
    system { $command_line[0] } @command_line
        and die "$!";
}

sub siteHistory {
    my $class = shift;
    my $config = shift;
    my $dbh = $class->dbhForConfig($config);
    my $sth = $dbh->prepare('SELECT webguiVersion, dateApplies, versionType FROM webguiVersion ORDER BY dateApplied ASC, webguiVersion ASC');
    $sth->execute;
    while ( my @data = $sth->fetchrow_array ) {
        printf "\t%-8s  %-15s  %-15s\n", $data[0], POSIX::strftime('%D %T', $data[1]), $data[2];
    }
    $sth->finish;
}

sub getCurrentVersion {
    my $class = shift;
    my $configFile = shift;
    my $dbh = $class->dbhForConfig($configFile);

    my $sth = $dbh->prepare('SELECT webguiVersion FROM webguiVersion');
    $sth->execute;
    my ($version) = map { $_->[0] }
        sort { $a->[1] <=> $b->[1] }
        map { [ $_->[0], $class->numericVersion($_->[0]) ] }
        @{ $sth->fetchall_arrayref( [0] ) };
    $sth->finish;
    return $version;
}

sub dbhForConfig {
    my $class = shift;
    my $config = shift;
    if (! ref $config) {
        $config = WebGUI::Config->new($config, 1);
    }
    return WebGUI::SQL->connect($config);
}

sub mysqlCommandLine {
    my $class = shift;
    my $config = shift;

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
        '-h' . $hostname,
        '-P' . $port,
        $database,
        '-u' . $username,
        ( $password ? '-p' . $password : () ),
        '--default-character-set=utf8',
        '--batch',
    );
    return @command_line;
}

sub numericVersion {
    my $class = shift;
    my $version = shift;
    my @parts = split /\./, $version;
    my $decVersion = 0;
    for my $i (0..$#parts) {
        $decVersion += $parts[$i] / (1000**$i);
    }
    return $decVersion;
}

__PACKAGE__->meta->make_immutable;
1;

