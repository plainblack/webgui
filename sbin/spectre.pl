#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use warnings;
use lib '../lib';
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

GetOptions(
	'help'=>\$help,
	'ping'=>\$ping,
	'shutdown'=>\$shutdown,
	'daemon'=>\$daemon,
	'debug' =>\$debug,
	'run' => \$run
	);

if ($help || !($ping||$shutdown||$daemon||$run)) {
	print <<STOP;

	S.P.E.C.T.R.E. is the Supervisor of Perplexing Event-handling Contraptions for 
	Triggering Relentless Executions. It triggers WebGUI's workflow and scheduling
	functions.

	Usage: perl spectre.pl [ options ]


	Options:

	--daemon	Starts the Spectre server.

	--debug		If specified at startup, Spectre will provide verbose
			debug to standard out so that you can see exactly what
			it's doing.

	--ping		Checks to see if Spectre is alive.

	--run		Starts Spectre without forking it as a daemon.

	--shutdown	Stops the running Spectre server.

STOP
	exit;
}

my $config = WebGUI::Config->new("..","spectre.conf",1);
unless (defined $config) {
	print <<STOP;


Cannot open  the Spectre config file. Check that ../etc/spectre.conf exists,
and that it has the proper privileges to be read by the Spectre server.


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
	undef $remote;
} elsif ($ping) {
	my $res = ping();
	print "Spectre is Alive!\n" unless $res;
	print "Spectre is not responding.\n".$res if $res;
} elsif ($run) {
	Spectre::Admin->new($config, $debug);
} elsif ($daemon) {
	my $res = ping();
	print "Spectre is already running.\n" unless $res;
	exit unless $res;
	#fork and exit(sleep(1) and print((ping())?"Spectre failed to start!\n":"Spectre started successfully!\n"));  #Can't have right now.
	fork and exit;
	Spectre::Admin->new($config, $debug);
}

sub ping {
	my $remote = create_ikc_client(
	        port=>$config->get("port"),
	        ip=>'127.0.0.1',
	        name=>rand(100000),
        	timeout=>10
        	);
	return $POE::Component::IKC::ClientLite::error unless $remote;
	my $result = $remote->post_respond('admin/ping');
	return $POE::Component::IKC::ClientLite::error unless defined $result;
	undef $remote;
	return 0 if ($result eq "pong");
	return 1;
}
