package WebGUI::Upgrade;
use 5.010;
use Moose;
use WebGUI::Paths;
use WebGUI::Pluggable;
use WebGUI::Config;
use WebGUI::SQL;
use Try::Tiny;
use File::Spec;
use File::Path qw(make_path);
use POSIX qw(strftime);
use Cwd ();
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
has _files_run => (
    is      => 'rw',
    default => sub { { } },
);

sub upgradeSites {
    my $self = shift;
        require Carp;
    my @configs = WebGUI::Paths->siteConfigs;
    my $i = 0;
    for my $configFile (@configs) {
        $i++;
        my $bareFilename = $configFile;
        $bareFilename =~ s{.*/}{};
        print "Upgrading $bareFilename (site $i/@{[ scalar @configs ]}):\n";
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
    if (! @steps) {
        print "No upgrades needed.\n";
    }
    my $i = 0;
    for my $step ( @steps ) {
        $i++;
        print "Running upgrades for $step (step $i/@{[ scalar @steps ]}):\n";
        $self->createBackup($configFile);
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
    my ($configFile, $version, $filename) = @_;
    my $has_run = $self->_files_run->{ Cwd::realpath($filename) } ++;

    try {
        my $upgrade_class = $self->classForFile($filename);
        my $upgrade_file = $upgrade_class->new(
            version     => $version,
            file        => $filename,
            upgrade     => $self,
            configFile  => $configFile,
        );
        if ($has_run && $upgrade_file->once) {
            return;
        }
        $upgrade_file->run;
    }
    catch {
        when (/^No upgrade package/) {
            warn $_;
        }
        default {
            die $_;
        }
    };
    return;
}

sub classForFile {
    my $class = shift;
    my $file = shift;
    my ($extension) = $file =~ /\.([^.]+)$/;
    if ($extension) {
        my $package = 'WebGUI::Upgrade::File::' . $extension;
        WebGUI::Pluggable::load($package);
        return $package
            if $package->DOES('WebGUI::Upgrade::File');
    }
    no warnings 'uninitialized';
    die "No upgrade package for extension: $extension";
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
    if (! ref $config) {
        $config = WebGUI::Config->new($config, 1);
    }

    make_path($self->backupPath);
    my $configFile = ( File::Spec->splitpath($config->pathToFile) )[2];
    my $resultFile = File::Spec->catfile(
        $self->backupPath,
        $configFile . '_' . $self->getCurrentVersion($config) . '_' . time . '.sql',
    );
    print "Backing up to $resultFile\n";
    my @command_line = (
        $self->mysqldump,
        $self->mysqlCommandLine($config),
        '--add-drop-table',
        '--result-file=' . $resultFile,
    );
    system { $command_line[0] } @command_line
        and die "$!";
}

sub reportHistory {
    my $class = shift;
    my $config = shift;
    my $dbh = $class->dbhForConfig($config);
    my $sth = $dbh->prepare('SELECT webguiVersion, dateApplied, versionType FROM webguiVersion ORDER BY dateApplied ASC, webguiVersion ASC');
    $sth->execute;
    while ( my @data = $sth->fetchrow_array ) {
        printf "\t%-8s  %-15s  %-15s\n", $data[0], strftime('%D %T', localtime $data[1]), $data[2];
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
        sort { $b->[1] <=> $a->[1] }
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
    if (! ref $config) {
        $config = WebGUI::Config->new($config, 1);
    }

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

