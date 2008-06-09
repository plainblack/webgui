#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2008 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

our ($webguiRoot);

BEGIN {
    $webguiRoot = "..";
    unshift (@INC, $webguiRoot."/lib");
}

use Pod::Usage;
use strict;
use warnings;
use Getopt::Long;
use POE::Component::IKC::ClientLite;
use Spectre::Admin;
use WebGUI::Config;

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
	'daemon'=>\$daemon,
	'debug' =>\$debug,
	'status' => \$status,
	'run' => \$run,
	'test' => \$test
	);

pod2usage( verbose => 2 ) if $help;
pod2usage() unless ($ping||$shutdown||$daemon||$run||$test||$status);

require File::Spec;
my $config = WebGUI::Config->new($webguiRoot,"spectre.conf",1);
unless (defined $config) {
	print <<STOP;


Cannot open the Spectre config file.
Check that spectre.conf exists, and that it has the proper
privileges to be read by the Spectre server.


STOP
	exit;
}

if ($shutdown) {
	my $remote = create_ikc_client(
	        port=>$config->get("port"),
	        ip=>$config->get("ip"),
	        name=>rand(100000),
        	timeout=>10
        	);
	die $POE::Component::IKC::ClientLite::error unless $remote;
	my $result = $remote->post('admin/shutdown');
	die $POE::Component::IKC::ClientLite::error unless defined $result;
	$remote->disconnect;
	undef $remote;
} elsif ($ping) {
	my $res = ping();
	print "Spectre is Alive!\n" unless $res;
	print "Spectre is not responding.\n".$res if $res;
} elsif ($status) {
	print getStatusReport();
} elsif ($test) {
	Spectre::Admin->runTests($config);
} elsif ($run) {
	Spectre::Admin->new($config, $debug);
} elsif ($daemon) {
    if (!ping()) {
        die "Spectre is already running.\n";
    }
    #fork and exit(sleep(1) and print((ping())?"Spectre failed to start!\n":"Spectre started successfully!\n"));  #Can't have right now.
    require POSIX;
    fork and exit;
    POSIX::setsid();
    chdir "/";
    open STDIN, "+>", File::Spec->devnull;
    open STDOUT, "+>&STDIN";
    open STDERR, "+>&STDIN";
    fork and exit;
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
	return $result;
}

__END__

=head1 NAME

spectre - WebGUI's workflow and scheduling.

=head1 SYNOPSIS

 spectre {--daemon|--run} [--debug]

 spectre --shutdown

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

=item B<--status>

Shows a summary of Spectre's internal status. The summary contains
a tally of suspended, waiting and running WebGUI Workflows.

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

Copyright 2001-2008 Plain Black Corporation.

=cut
