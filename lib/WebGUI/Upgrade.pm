package WebGUI::Upgrade;

use strict;
use warnings;
use WebGUI::Paths;
use WebGUI;
use Try::Tiny;
use WebGUI::Pluggable;
use DBI;
use WebGUI::Config;

sub upgradeSites {
    my $class = shift;
    my $quiet = shift;
    my @configs = WebGUI::Paths->siteConfigs;
    for my $configFile (@configs) {
        my $bareFilename = $configFile;
        $bareFilename =~ s{.*/}{};
        print "Upgrading $bareFilename:\n";
        try {
            $class->upgradeSite($configFile, $quiet);
        }
        catch {
            print "Error upgrading $bareFilename: $@\n";
        }
    }
}

sub upgradeSite {
    my $class = shift;
    my ($configFile, $quiet) = @_;
    my $fromVersion = $class->getCurrentVersion($configFile);
    my @steps = $class->calcUpgradePath($fromVersion, $WebGUI::Version);
    for my $step ( @steps ) {
        $class->runUpgradeStep($configFile, $step, $quiet);
    }
}

sub calcUpgradePath {
    my $class = shift;
    my ($fromVersionStr, $toVersionStr) = @_;
    my $fromVersion = $class->numericVersion($fromVersionStr);
    my $toVersion = $class->numericVersion($toVersionStr);

    my %upgrades;
    opendir my $dh, WebGUI::Paths->upgrades;
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
    my $class = shift;
    my ($configFile, $step, $quiet) = @_;

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
        my ($extension) = $filename =~ /\.([^.]+)$/;
        next
            unless $extension;

        my $package = 'WebGUI::Upgrade::File::' . $extension;
        if ( try { WebGUI::Pluggable::load($package) } && $package->can('run') ) {
            $package->run($configFile, $version, $filename, $quiet);
        }
        else {
            warn "Don't know how to use $extension upgrade file\n";
        }
    }
    closedir $dh;
    $class->markVersionUpgrade($configFile, $version);
}

sub markVersionUpgrade {
    my $class = shift;
    my $configFile = shift;
    my $version = shift;

    my $dbh = $class->dbhForConfig($configFile);

    $dbh->do(
        'INSERT INTO webguiVersion (webguiVersion, versionType, dateApplied) VALUES (?,?,?)', {},
        $version, 'upgrade', time,
    );
}

sub getCurrentVersion {
    my $class = shift;
    my $configFile = shift;
    my $config = WebGUI::Config->new($configFile, 1);
    my $dbh = $class->dbhForConfig($config);

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

    my $dsn = $config->get('dsn');
    my $user = $config->get('dbuser');
    my $pass = $config->get('dbpass');

    my (undef, $driver) = DBI->parse_dsn($dsn);
    my $dbh = DBI->connect($dsn, $user, $pass, {
        RaiseError => 1,
        AutoCommit => 1,
        PrintError => 0,
        $driver eq 'mysql' ? (mysql_enable_utf8 => 1) : (),
    });
    return $dbh;
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

1;

