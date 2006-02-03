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
my $daemon;

GetOptions(
	'help'=>\$help,
	'shutdown'=>\$shutdown,
	'daemon'=>\$daemon
	);

if ($help || !($shutdown||$daemon)) {
	print <<STOP;

	S.P.E.C.T.R.E. is the Supervisor of Perplexing Event-handling Contraptions for 
	Triggering Relentless Executions. It handles WebGUI's workflow, mail sending,
	search engine indexing, and other background processes.

	Usage: perl spectre.pl [ options ]


	Options:

	--daemon	Starts the Spectre server.

	--shutdown	Stops the running Spectre server.

STOP
	exit;
}

my $config = WebGUI::Config->new("..","spectre.conf",1);

if ($shutdown) {
	my $remote = create_ikc_client(
	        port=>$config->get("port"),
	        ip=>'127.0.0.1',
	        name=>rand(100000),
        	timeout=>10
        	);
	die $POE::Component::IKC::ClientLite::error unless $remote;
	my $result = $remote->post('admin/shutdown');
	die $POE::Component::IKC::ClientLite::error unless defined $result;
	undef $remote;
} elsif ($daemon) {
	fork and exit;
	Spectre::Admin->new($config);
}

