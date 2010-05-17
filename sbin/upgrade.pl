#!/usr/bin/env perl

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use warnings;
use WebGUI::Paths -inc;
use WebGUI::Upgrade;
use Getopt::Long ();
use Pod::Usage ();

Getopt::Long::GetOptions(
    'help'              => \( my $help ),
    'history'           => \( my $history ),
    'override'          => \( my $override ),
    'quiet'             => \( my $quiet ),
    'doit'              => \( my $doit ),
    'skipDelete'        => \( my $skipDelete ),
    'skipMaintenance'   => \( my $skipMaintenance ),
    'skipbackup'        => \( my $skipBackup ),
    'backupDir=s'       => \( my $backupDir ),
    'mysql=s'           => \( my $mysql ),
    'mysqldump=s'       => \( my $mysqldump ),
) or Pod::Usage::pod2usage(2);

if ($help) {
    Pod::Usage::pod2usage(
        -verbosity => 1,
        -exitval => 1,
    );
}
elsif ($history) {
    print "print site history\n";
    exit;
}
elsif ( ! $doit ) {
    my $message = <<'END_MESSAGE';

+--------------------------------------------------------------------+
|                                                                    |
|                         W  A  R  N  I  N  G                        |
|                                                                    |
| There are no guarantees of any kind provided with this software.   |
| This utility has been tested rigorously, and has performed without |
| error or consequence in our labs, and on our production servers    |
| for many years. However, there is no substitute for a good backup  |
| of your software and data before performing any kind of upgrade.   |
|                                                                    |
| BEFORE YOU UPGRADE you should definitely read docs/gotcha.txt to   |
| find out what things you should know about that will affect your   |
| upgrade.                                                           |
|                                                                    |
+--------------------------------------------------------------------+
|                                                                    |
| For more information about this utility type:                      |
|                                                                    |
| perl upgrade.pl --help                                             |
|                                                                    |
+--------------------------------------------------------------------+

END_MESSAGE
    Pod::Usage::pod2usage($message);
}

if ( $^O ne 'MSWin32' && $> != 0 && !$override ) {
    print "You must be the super user to use this utility.\n";
    exit;
}

## Globals

$| = 1;

my $upgrade = WebGUI::Upgrade->new(
    quiet               => $quiet,
    clearCache          => !$skipDelete,
    createBackups       => !$skipBackup,
    useMaintenanceMode  => !$skipMaintenance,
    $mysql ? (
        mysql               => $mysql,
    ) : (),
    $mysqldump ? (
        mysqldump           => $mysqldump,
    ) : (),
    $backupDir ? (
        backupPath          => $backupDir,
    ) : (),
);

$upgrade->upgradeSites;

print <<STOP;

UPGRADES COMPLETE
Please restart your web server and test your sites.

WARNING: If you saw any errors in the output during the upgrade, restore 
your install and databases from backup immediately. Do not continue using 
your site EVEN IF IT SEEMS TO WORK.

NOTE: If you have not already done so, please consult
docs/gotcha.txt for possible upgrade complications.

STOP

__END__

=head1 NAME

upgrade - Upgrade WebGUI database to the latest revision.

=head1 SYNOPSIS

    upgrade --doit
            [--backupDir path]
            [--mysql pathname]
            [--mysqldump pathname]
            [--override]
            [--skipBackup]
            [--skipDelete]
            [--skipMaintenance]
            [--quiet]
    upgrade --history

    upgrade --help

=head1 DESCRIPTION

This WebGUI utility script is able to upgrade B<any> WebGUI database
to the currently installed version. The WebGUI software distribution
includes a set of upgrade scripts that perform the necessary database
changes (schema and data) to bring the database up-to-date in order
to match the currently installed WebGUI libraries and programs.

This utility is designed to be run as a superuser on Linux systems,
since it needs to be able to access several system directories
and change ownership of files. If you want to run this utility without
superuser privileges, use the C<--override> option described below.

=head2 WARNING

There are B<NO> guarantees of any kind provided with this software.
This utility has been tested rigorously, and has performed without
error or consequences in our labs, and on our production servers
for many years. However, there is no substitute for a good backup
of your software and data before performing any kind of upgrade.

B<BEFORE YOU UPGRADE> you should definitely read docs/gotcha.txt to
find out what things you should know about that will affect your
upgrade.

=head1 OPTIONS

=over 4

=item C<--doit>

You B<MUST> include this flag in the command line or the script
will refuse to run. This is to force you to read this documentation
at least once and be sure that you B<REALLY> want to perform the
upgrade.

=item C<--backupDir path>

Specify a path where database backups should be created during the
upgrade procedure. If left unspecified, it defaults to C</tmp/backups>.

=item C<--history>

Displays the upgrade history for each of your sites. Running with this
flag will B<NOT> perform the upgrade.

=item C<--mysql pathname>

The full pathname to your mysql client executable. If left unspecified,
it defaults to C</usr/bin/mysql>.

=item C<--mysqldump pathname>

The full pathname to your mysqldump executable. If left unspecified,
it defaults to C</usr/bin/mysqldump>.

=item C<--override>

This flag will allow you to run this utility without being the super user,
but note that it may not work as intended.

=item C<--skipBackup>

Use this if you B<DO NOT> want database backups to be performed
during the upgrade procedure.

=item C<--skipDelete>

The upgrade procedure normally deletes WebGUI's cache and temporary files
created as part of the upgrade. This cleanup is very important during
large upgrades, but can make the procedure quite slow. This option
skips the deletion of these files.

=item C<--skipMaintenance>

The upgrade procedure normally puts up a simple maintenance page on all
the sites while running, but this option will skip that step.

=item C<--quiet>

Disable all output unless there's an error.

=item C<--help>

Shows this documentation, then exits.

=back

=head1 AUTHOR

Copyright 2001-2009 Plain Black Corporation.

=cut
