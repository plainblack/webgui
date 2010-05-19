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
use File::Basename ();
use File::Spec;

my $webguiRoot;
BEGIN {
    $webguiRoot = File::Spec->rel2abs(File::Spec->catdir(File::Basename::dirname(__FILE__), File::Spec->updir));
    unshift @INC, File::Spec->catdir($webguiRoot, 'lib');
}

use Pod::Usage;
use warnings;
use Getopt::Long;
use POE::Component::IKC::ClientLite;
use Spectre::Admin;
use WebGUI::Config;
use JSON;

$|=1; # disable output buffering
my $help;
my $shutdown;
my $ping;
my $daemon;
my $run;
my $debug;
my $test;
my $status;

GetOptions(
	'help'=>\$help,
	'ping'=>\$ping,
	'shutdown'=>\$shutdown,
	'stop'=>\$shutdown,
	'daemon'=>\$daemon,
	'start'=>\$daemon,
	'debug' =>\$debug,
	'status' => \$status,
	'run' => \$run,
	'test' => \$test
	);

pod2usage( verbose => 2 ) if $help;
pod2usage() unless ($ping||$shutdown||$daemon||$run||$test||$status);

require File::Spec;
# Convert to absolute since we'll be changing directory
my $config = WebGUI::Config->new(File::Spec->rel2abs($webguiRoot),"spectre.conf",1);
unless (defined $config) {
	print <<STOP;


Cannot open the Spectre config file.
Check that spectre.conf exists, and that it has the proper
privileges to be read by the Spectre server.


STOP
	exit;
}

if ($shutdown) {
    local $/;
    my $pidFileName = $config->get('pidFile');
    if (! $pidFileName) {
        warn "No pidFile specified in spectre.conf;  please add one.  Trying /var/run/spectre.pid instead.\n";
        $pidFileName = '/var/run/spectre.pid';
    }
    open my $pidFile, '<', $pidFileName or
        die "Unable to open pidFile ($pidFileName) for reading: $!\n";
    my $spectrePid = <$pidFile>;
    close $pidFile or
        die "Unable to close pidFile ($pidFileName) after reading: $!\n";
    chomp $spectrePid;
    kill 15, $spectrePid;
    sleep 1;
    kill 9, $spectrePid;
    unlink $pidFileName or
        die "Unable to remove PID file\n";
}
elsif ($ping) {
	my $res = ping();
	print "Spectre is Alive!\n" unless $res;
	print "Spectre is not responding.\n".$res if $res;
}
elsif ($status) {
	print getStatusReport();
}
elsif ($test) {
	Spectre::Admin->runTests($config);
}
elsif ($run) {
	Spectre::Admin->new($config, $debug);
}
elsif ($daemon) {
    my $pidFileName = $config->get('pidFile');
    ##Write the PID file
    if (! $pidFileName) {
        warn "No pidFile specified in spectre.conf;  please add one.  Trying /var/run/spectre.pid instead.\n";
        $pidFileName = '/var/run/spectre.pid';
    }
    if (!ping()) {
        die "Spectre is already running.\n";
    }
    elsif (-e $pidFileName){
        # oh, ffs ... die "pidFile $pidFileName already exists\n";
        open my $pidFile, '<', $pidFileName or die "$pidFileName: $!";
        (my $pid) = readline $pidFile;
        chomp $pid;
        if(defined $pid and $pid =~ m/^(\d+)$/) {
            if(kill 0, $1) {
                die "$0: already running as PID $1";
            } else { 
                warn "pidfile contains $pid but that process seems to have terminated" 
            }
        }
        close $pidFile;
    }
    # XXXX warn if we can't open the log file before forking or else make it not fatal or else close STDOUT/STDERR afterwards; don't fail silently -- sdw
    #fork and exit(sleep(1) and print((ping())?"Spectre failed to start!\n":"Spectre started successfully!\n"));  #Can't have right now.
    require POSIX;
    fork and exit;
    POSIX::setsid();
    open my $pidFile, '>', $pidFileName or
        die "Unable to open pidFile ($pidFileName) for writing: $!\n";
    chdir "/";
    open STDIN, "+>", File::Spec->devnull;
    open STDOUT, "+>&STDIN";
    open STDERR, "+>&STDIN";
    fork and exit;
    print $pidFile $$."\n";
    close $pidFile or
        die "Unable to close pidFile ($pidFileName) after writing: $!\n";
    Spectre::Admin->new($config, $debug);
}

sub ping {
	my $remote = create_ikc_client(
	        port=>$config->get("port"),
	        ip=>$config->get("ip"),
	        name=>rand(100000),
        	timeout=>10
        	);
	return $POE::Component::IKC::ClientLite::error unless $remote;
	my $result = $remote->post_respond('admin/ping');
	return $POE::Component::IKC::ClientLite::error unless defined $result;
	$remote->disconnect;
	undef $remote;
	return 0 if ($result eq "pong");
	return 1;
}

sub getStatusReport {
	my $remote = create_ikc_client(
	        port=>$config->get("port"),
	        ip=>$config->get("ip"),
	        name=>rand(100000),
        	timeout=>10
        	);
	return $POE::Component::IKC::ClientLite::error unless $remote;
	my $result = $remote->post_respond('workflow/getStatus');
	return $POE::Component::IKC::ClientLite::error unless defined $result;
	$remote->disconnect;
	undef $remote;
	my $pattern = "%8.8s  %-9.9s  %-30.30s  %-22.22s  %-15.15s %-20.20s\n";
	my $total = 0;
	my $output = sprintf $pattern, "Priority", "Status", "Sitename", "Instance Id", "Last Run", "Last Run Time";
    foreach my $instance (@{JSON->new->decode($result)}) {
		my $originalPriority = ($instance->{priority} - 1) * 10;
        my $priority = $instance->{workingPriority}."/".$originalPriority;
		$output .= sprintf $pattern, $priority, $instance->{status}, $instance->{sitename}, $instance->{instanceId}, $instance->{lastState}, $instance->{lastRunTime};
        $total++;
    }
    $output .= sprintf "\n%19.19s %4d\n", "Total Workflows", $total;
	return $output;
}

__END__

=head1 NAME

spectre - WebGUI's workflow and scheduling.

=head1 SYNOPSIS

 spectre {--daemon | --start | --run} [--debug]

 spectre --shutdown | --stop

 spectre --ping

 spectre --status

 spectre --test

 spectre --help

=head1 DESCRIPTION

S.P.E.C.T.R.E. is the Supervisor of Perplexing Event-handling
Contraptions for Triggering Relentless Executions. It triggers
WebGUI's workflow and scheduling functions.

Spectre's configuration file, B<spectre.conf>, is located under
the WebGUI filesystem hierarchy.

=over

=item B<--daemon>

Starts the Spectre server forking as a background daemon. This
can be done by hand, but it is usually handled by a startup
script.

=item B<--run>

Starts Spectre in the foreground without forking as a daemon.

=item B<--debug>

If this option is specified at startup either in B<--daemon>
or B<--run> mode, Spectre will provide verbose debug to standard
output so that you can see exactly what it's doing.

=item B<--shutdown>

Stops the running Spectre server.

=item B<--ping>

Pings Spectre to see if it is alive. If Spectre is alive, you'll get
confirmation with a message like

    Spectre is alive!

If Spectre doesn't seem to be alive, you'll get a message like

    Spectre is not responding.
    Unable to connect to <IP-address>:<Port>

where B<IP-address> is the IP address and B<Port> is the port number
where Spectre should be listening for connections on according to
B<spectre.conf>.

=item B<--start>

Alias for --daemon.

=item B<--status>

Shows a summary of Spectre's internal status. The summary contains
a tally of suspended, waiting and running WebGUI Workflows.

=item B<--stop>

Alias for --shutdown.

=item B<--test>

Tests whether Spectre can connect to WebGUI. Both Spectre
and the Apache server running WebGUI must be running for this
option to work. It will test the connection between every site
and Spectre, by looking for configuration files in WebGUI's
configuration directory, showing success or failure in each case.

=item B<--help>

Shows this documentation, then exits.

=back

=head1 AUTHOR

Copyright 2001-2009 Plain Black Corporation.

=cut
