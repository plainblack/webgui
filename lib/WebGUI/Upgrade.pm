package WebGUI::Upgrade;

use strict;
use warnings;
use WebGUI::Paths;
use WebGUI;

sub upgradeSite {
    my $class = shift;
    my ($configFile) = @_;
    my $fromVersion = '7.8.1';
    my $steps = $class->calcUpgradePath($fromVersion);
    for my $step ( @$steps ) {
        $class->runUpgradeStep($configFile, $step);
    }
}

sub upgradeSites {
    my $class = shift;
    my @configs = WebGUI::Paths->siteConfigs;
    for my $configFile (@configs) {
        $class->upgradeSite($configFile);
    }
}

sub calcUpgradePath {
    my $class = shift;
    my $fromVersion = $class->decimalize_version(shift);
    my $toVersion = $class->decimalize_version('7.9.3'); #$WebGUI::VERSION);

    my %from;
    opendir my $dh, WebGUI::Paths->upgrades;
    while ( my $dir = readdir $dh ) {
        next
            if $dir =~ /^\./;
        next
            unless -d File::Spec->catdir(WebGUI::Paths->upgrades, $dir);
        if ($dir =~ /^(\d+\.\d+\.\d+)-(\d+\.\d+\.\d+)$/) {
            $from{ $class->decimalize_version($1) }{ $class->decimalize_version($2) } = "$1-$2";
        }
    }
    closedir $dh;

    my $findSteps;
    $findSteps = sub {
        my ($found, $steps) = @_;
        if ($found eq $toVersion) {
            return $steps;
        }
        my $stepsAvail = $from{$found};
        for my $nextStep ( sort { $a <=> $b } keys %{ $stepsAvail } ) {
            my $doneSteps = $findSteps->($nextStep, [@$steps, $stepsAvail->{$nextStep}]);
            return $doneSteps
                if $doneSteps;
        }
        return;
    };
    my $steps = $findSteps->($fromVersion, []);
    return $steps;
}

sub runUpgradeStep {
    my $class = shift;
    my ($configFile, $step) = @_;
    print "Running upgrade $step\n";
    my $upgradesDir = File::Spec->catdir(WebGUI::Paths->upgrades, $step);
    opendir my($dh), $upgradesDir;
    while ( my $upgradeFile = readdir $dh ) {
        next
            if $upgradeFile =~ /^\./;
        my $filename = File::Spec->catfile($upgradesDir, $upgradeFile);
        next
            unless -f $filename;
        my ($extension) = $filename =~ /\.([^.]+)$/;
        next
            unless $extension;
        my $sub = __PACKAGE__->can('upgrade_file_' . $extension);
        if ($sub) {
            $class->$sub($configFile, $filename);
        }
        else {
            warn "Don't know how to use $extension upgrade file\n";
        }
    }
    closedir $dh;
}

sub decimalize_version {
    my $class = shift;
    my $version = shift;
    my @parts = split /\./, $version;
    my $decVersion = 0;
    for my $i (0..$#parts) {
        $decVersion += $parts[$i] / (1000**$i);
    }
    return $decVersion;
}

sub upgrade_file_pl {
    my $class = shift;
    my ($configFile, $file) = @_;
    open my $fh, '<', $file;
    my $contents = do { local $/; <$fh> };
    close $fh;
    my $code = sprintf <<'END_CODE', $file, $contents;
package WebGUI::Upgrade::Script;
use strict;
use warnings;
# line 1 "%s"
%s
END_CODE
    my $pid = fork;
    if (!$pid) {
        $WebGUI::Upgrade::Script::configFile = $configFile;
        $WebGUI::Upgrade::Script::quiet = 0;
        eval $code;
        die $@ if $@;
        exit;
    }
    waitpid $pid, 0;
}

sub upgrade_file_sql {
    my $class = shift;
    my ($configFile, $file) = @_;
    warn "running sql script: $file\n";
}

package WebGUI::Upgrade::Script;

our $configFile;
our $config;
our $session;
our $quiet;

sub report {
    print @_ unless $quiet;
}

sub done {
    print "Done.\n" unless $quiet;
}

sub session () {
    require WebGUI::Session;
    $session ||= WebGUI::Session->open(config());
    return $session;
}

sub config () {
    require WebGUI::Config;
    $config ||= WebGUI::Config->new($configFile, 1);
    return $config;
}

1;

