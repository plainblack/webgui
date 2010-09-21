=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2009 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=head1 NAME

WebGUI::Upgrade - Perform upgrades on WebGUI sites

=head1 SYNOPSIS

    use WebGUI::Upgrade;
    my $upgrade = WebGUI::Upgrade->new;
    $upgrade->upgradeSites;

=head1 DESCRIPTION

This package calculates upgrade paths and performs upgrades for WebGUI sites.

=head1 Differences from WebGUI 7's upgrade system

In WebGUI 7 and prior, a single upgrade for each version was created
as F<docs/upgrades/upgrade_X.X.X-X.X.X.pl>.  This script would be
run with a command line parameter of --configFile=F<site.conf>.
This script contained all of the code to set up a session and do
any other work that was needed.

To cut down on the amount of boilerplate code and allow for more
flexible upgrades, this has been changed.  Multiple upgrade files
are placed in the directory F<share/upgrades/X.X.X-X.X.X/>, and are
processed in alphabetical order, with the file extension determining
how to process the file.

=head1 Supported File Types

The file extension determines the class that will be used to process them.  The class is determined by appending it to C<WebGUI::Upgrade::File::>.

=head2 Perl Scripts - F<.pl>

Perl scripts are processed by L<WebGUI::Upgrade::File::pl>, which
runs them after setting the environment variables C<WEBGUI_CONFIG>
and C<WEBGUI_UPGRADE_VERSION>.  Usually, these scripts should use
the module L<WebGUI::Upgrade::Script> to load a number of subs to
greatly simplify how they are written.

=head2 SQL Scripts - F<.sql>

SQL scripts are processed by L<WebGUI::Upgrade::File::sql>, which
runs them with the F<mysql> command line client.

=head2 WebGUI Packages - F<.wgpkg>

WebGUI packages are processed by L<WebGUI::Upgrade::File::wgpkg>,
which imports them into the WebGUI site.

=head2 Text and POD Documents - F<.txt>/F<.pod>

Text and POD documents are processed by L<WebGUI::Upgrade::File::txt>
and L<WebGUI::Upgrade::File::pod> respectively.  The files will be
shown to the user running the upgrade, and will wait for user
confirmation before continuing.  This will only be done once per
upgrade process.

=cut

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

=head1 ATTRIBUTES

These attributes can be set when creating a WebGUI::Upgrade instance:

=cut

=head2 quiet

Whether information about the upgrade progress will be output.  Defaults to false.

=cut

has quiet => (
    is => 'rw',
    default => undef,
);

=head2 mysql

The path to the mysql command line client.  Defaults to 'mysql'.

=cut

has mysql => (
    is => 'rw',
    default => 'mysql',
);

=head2 mysqldump

The path to the mysqldump command line client.  Defaults to 'mysqldump'.

=cut

has mysqldump => (
    is => 'rw',
    default => 'mysqldump',
);

=head2 clearCache

If true, the cache will be cleared for each site before running
any upgrade scripts.  Defaults to true.

=cut

has clearCache => (
    is      => 'rw',
    default => 1,
);

=head2 backupPath

The path where backups will be stored.  Defaults to 'backups' inside the temp directory.

=cut

has backupPath => (
    is      => 'rw',
    default => File::Spec->catdir(File::Spec->tmpdir, 'backups'),
);

=head2 createBackups

If true, backups will be created before each version upgrade for
each site.  The backup files will be named
C<{config file}_{version}_{timestamp}.sql>.

=cut

has createBackups => (
    is      => 'rw',
    default => 1,
);

=head2 useMaintenanceMode

If set, sites will be put into maintenance mode before any upgrades
are run on them.  Defaults to true.

=cut

has useMaintenanceMode => (
    is      => 'rw',
    default => 1,
);

# this is used to store if a given upgrade file has been run yet.
# Some upgrade files should only be processed once per upgrade.
has _files_run => (
    is      => 'rw',
    default => sub { { } },
);

=head1 METHODS

=head2 upgradeSites

Upgrades all available sites to match the current WebGUI codebase.

=cut

sub upgradeSites {
    my $self = shift;
        require Carp;
    my @configs = WebGUI::Paths->siteConfigs;
    my $i = 0;
    for my $configFile (@configs) {
        $i++;
        my $bareFilename = $configFile;
        $bareFilename =~ s{.*/}{};
        print "Upgrading $bareFilename (site $i/@{[ scalar @configs ]}):\n"
            if ! $self->quiet;
        try {
            $self->upgradeSite($configFile);
        }
        catch {
            warn "Error upgrading $bareFilename: $_\n";
        };
    }
    return 1;
}

=head2 getCodeVersion

Returns the current version of the codebase.

=cut

sub getCodeVersion {
    require WebGUI;
    return WebGUI->VERSION;
}

=head2 upgradeSite ( $config )

Upgrades the given config file to the current codebase.

=head3 $config

The path to a WebGUI config file or a WebGUI::Config instance

=cut

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
        print "No upgrades needed.\n"
            if ! $self->quiet;
    }
    my $i = 0;
    for my $step ( @steps ) {
        $i++;
        print "Running upgrades for $step (step $i/@{[ scalar @steps ]}):\n"
            if ! $self->quiet;
        if ($self->createBackups) {
            $self->createBackup($configFile);
        }
        $self->runUpgradeStep($configFile, $step);
    }
}

=head1 calcUpgradePath ( $fromVerson , $toVersion )

Class method to calculate the upgrade path between two versions.
Tries to find the best path between the versions by looking in
F<var/upgrades/> for directories that make a path between the versions.
Returns either a list of directories to use, or throws an error if
no path can be found.

=cut

sub calcUpgradePath {
    my $class = shift;
    my ($fromVersionStr, $toVersionStr) = @_;
    my $fromVersion = $class->_numericVersion($fromVersionStr);
    my $toVersion = $class->_numericVersion($toVersionStr);

    my %upgrades;
    opendir my $dh, WebGUI::Paths->upgrades
        or die "Upgrades directory doesn't exist.\n";
    while ( my $dir = readdir $dh ) {
        next
            if $dir =~ /^\./;
        next
            unless -d File::Spec->catdir(WebGUI::Paths->upgrades, $dir);
        if ($dir =~ /^((\d+\.\d+\.\d+)-(\d+\.\d+\.\d+))$/) {
            $upgrades{ $class->_numericVersion($2) }{ $class->_numericVersion($3) } = $1;
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

=head2 runUpgradeStep ( $config , $step )

Runs the given upgrade step against the WebGUI config file.

=cut

sub runUpgradeStep {
    my $self = shift;
    my ($configFile, $step) = @_;

    my ($version) = $step =~ /-(\d+\.\d+\.\d+)$/;
    my $upgradesDir = File::Spec->catdir(WebGUI::Paths->upgrades, $step);
    my @files;
    opendir my($dh), $upgradesDir or die "Can't get upgrades for $step: $!\n";
    while ( my $upgradeFile = readdir $dh ) {
        next
            if $upgradeFile =~ /^\./;
        my $filename = File::Spec->catfile($upgradesDir, $upgradeFile);
        next
            unless -f $filename;
        push @files, $filename;
    }
    closedir $dh;
    for my $filename ( sort @files ) {
        $self->runUpgradeFile($configFile, $version, $filename);
    }
    $self->markVersionUpgrade($configFile, $version);
}

=head2 runUpgradeFile ( $config , $version , $filename )

Runs the given upgrade file against a WebGUI config file.

=head3 $version

The destination version for the step this upgrade file is part of.

=cut

sub runUpgradeFile {
    my $self = shift;
    my ($configFile, $version, $filename) = @_;
    my $has_run = $self->_files_run->{ Cwd::realpath($filename) } ++;

    return try {
        my $upgrade_class = $self->classForFile($filename);
        my $upgrade_file = $upgrade_class->new(
            version     => $version,
            file        => $filename,
            upgrade     => $self,
        );
        if ($has_run && $upgrade_file->once) {
            return;
        }
        $upgrade_file->run($configFile);
    }
    catch {
        when (/^No upgrade package/) {
            warn $_;
            return;
        }
        default {
            die $_;
        }
    };
}

=head2 classForFile ( $file )

Class method to find the class to use to run the upgrade file.
Given a filename, it will either load and return a class name to
use, or throw an error if no appropriate class is available.

=cut

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

=head2 markVersionUpgrade ( $config , $version )

Marks that a given version upgrade has been completed for a config file.

=cut

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

=head2 createBackup ( $config )

Creates a database backup file for a given config file.

=cut

sub createBackup {
    my $self = shift;
    my $config = shift;
    if (! ref $config) {
        $config = WebGUI::Config->new($config);
    }

    make_path($self->backupPath);
    my $configFile = ( File::Spec->splitpath($config->pathToFile) )[2];
    my $resultFile = File::Spec->catfile(
        $self->backupPath,
        $configFile . '_' . $self->getCurrentVersion($config) . '_' . time . '.sql',
    );
    print "Backing up to $resultFile\n"
        if ! $self->quiet;
    my @command_line = (
        $self->mysqldump,
        $self->mysqlCommandLine($config),
        '--add-drop-table',
        '--result-file=' . $resultFile,
    );
    system { $command_line[0] } @command_line
        and die "$!";
}

=head2 reportHistory ( $config )

Class method to return the upgrade history for a given config file.

=cut

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

=head2 getCurrentVersion ( $config )

Class method that returns the current version of a WebGUI database.

=cut

sub getCurrentVersion {
    my $class = shift;
    my $configFile = shift;
    my $dbh = $class->dbhForConfig($configFile);

    my $sth = $dbh->prepare('SELECT webguiVersion FROM webguiVersion');
    $sth->execute;
    my ($version) = map { $_->[0] }
        sort { $b->[1] <=> $a->[1] }
        map { [ $_->[0], $class->_numericVersion($_->[0]) ] }
        @{ $sth->fetchall_arrayref( [0] ) };
    $sth->finish;
    return $version;
}

=head2 dbhForConfig ( $config )

Class method that creates a new WebGUI::SQL object given a config file.

=cut

sub dbhForConfig {
    my $class = shift;
    my $config = shift;
    if (! ref $config) {
        $config = WebGUI::Config->new($config);
    }
    return WebGUI::SQL->connect($config);
}

=head2 mysqlCommandLine ( $config )

Class method to return a list of options to pass to the mysql or
mysqldump command line client to connect to the given config file's
database.

=cut

sub mysqlCommandLine {
    my $class = shift;
    my $config = shift;
    if (! ref $config) {
        $config = WebGUI::Config->new($config);
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

# converts a period separated version number into a form that can
# be compared numerically.
sub _numericVersion {
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

