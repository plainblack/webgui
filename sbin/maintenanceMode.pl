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
use Getopt::Long;
use Pod::Usage;
use WebGUI::Paths -inc;
use WebGUI::Session;

my $help;
my $start = 1;
my $stop = 0;
my $configFile;

GetOptions(
        'help'=>\$help,
        'start'=>\$start,
        'stop'=>\$stop,
    'configFile=s'=>\$configFile
  );

pod2usage( verbose => 2 ) if $help;
pod2usage() if $configFile eq "";


my $session = WebGUI::Session->open($configFile);
$session->setting->remove('specialState');
$session->setting->add('specialState','upgrading') unless $stop;
$session->end;
$session->close;

__END__

=head1 NAME

maintenanceMode - Set WebGUI site into maintenance mode.

=head1 SYNOPSIS

maintenanceMode --configFile config.conf [--start|--stop]

maintenanceMode --help

=head1 DESCRIPTION

This utility script will set or unset WebGUI's B<specialState>
setting to signal the beginning or end of Maintenance Mode.

=over

=item B<--configFile config.conf>

The WebGUI config file to use. Only the file name needs to be specified,
since it will be looked up inside WebGUI's configuration directory.
This parameter is required.

=item B<--start>

Set B<specialState> to signal the beginning of maintenance mode.
This is the default behaviour.

=item B<--stop>

Unset B<specialState> to signal the end of maintenance mode.

=item B<--help>

Shows this documentation, then exits.

=back

=head1 AUTHOR

Copyright 2001-2009 Plain Black Corporation.

=cut
