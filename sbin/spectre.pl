#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
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
use DateTime::Cron::Simple;
use Getopt::Long;
use POE qw(Session);
use POE::Component::IKC::ClientLite;
use POE::Component::IKC::Server;
use POE::Component::IKC::Specifier;
use WebGUI::Session;

$|=1; # disable output buffering
my $help;
my $shutdown;

GetOptions(
	'help'=>\$help,
	'shutdown'=>\$shutdown
	);

if ($help) {
	print <<STOP;
	S.P.E.C.T.R.E. is the Supervisor of Perplexing Event-handling Contraptions for 
	Triggering Relentless Executions. It handles WebGUI's workflow, mail sending,
	search engine indexing, and other background processes.

	Usage:

	perl spectre.pl


	Options:

	--shutdown	Stops the running Spectre server.

STOP
	exit;
}

if ($shutdown) {
	my $remote = create_ikc_client(
	        port=>32133,
	        ip=>'127.0.0.1',
	        name=>rand(100000),
        	timeout=>10
        	);
	die $POE::Component::IKC::ClientLite::error unless $remote;
	my $result = $remote->post('Spectre/shutdown');
	die $POE::Component::IKC::ClientLite::error unless defined $result;
	undef $remote;
	exit;
}

fork and exit;


POE::Component::IKC::Server->spawn(
    port => 32133,
    name => 'Spectre',
);

POE::Session->create(
    inline_states => {
        _start        	=> \&serviceStart,
        _stop         	=> \&serviceStop,
	"shutdown"	=> \&serviceStop
      }
);

POE::Kernel->run();
exit 0;


#-------------------------------------------------------------------
sub serviceShutdown {
	my $kernel = $_[KERNEL];
	$kernel->yield("_stop");
}

#-------------------------------------------------------------------
sub serviceStart {
	print "Starting WebGUI Spectre...";
    	my ( $kernel, $heap ) = @_[ KERNEL, HEAP ];
    	my $serviceName = "Spectre";
    	$kernel->alias_set($serviceName);
    	$kernel->call( IKC => publish => $serviceName, ["shutdown"] );
	print "OK\n";
}

#-------------------------------------------------------------------
sub serviceStop {
	my $kernel = $_[KERNEL];
	print "Stopping WebGUI Spectre...";
	if ($session{var}{userId}) {
		sessionClose();
	}
	print "OK\n";
	$kernel->stop;
}

#-------------------------------------------------------------------
sub sessionOpen {
	WebGUI::Session::open("..",shift);
	WebGUI::Session::refreshUserInfo("pbuser_________spectre");
}

#-------------------------------------------------------------------
sub sessionClose {
	WebGUI::Session::close();
}


