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
use DateTime;
use DateTime::Cron::Simple;
use Getopt::Long;
use POE qw(Session);
use POE::Component::IKC::ClientLite;
use POE::Component::IKC::Server;
use POE::Component::IKC::Specifier;
use POE::Component::JobQueue;
use WebGUI::Session;
use WebGUI::Workflow;

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
	my $result = $remote->post('scheduler/shutdown');
	die $POE::Component::IKC::ClientLite::error unless defined $result;
	undef $remote;
	exit;
}

fork and exit;


create_ikc_server(
    	port => 32133,
    	name => 'Spectre',
	);

POE::Session->create(
    	inline_states => {
        	_start => \&initializeScheduler,
        	_stop => \&shutdown,
		"shutdown" => \&shutdown,
		loadSchedule => \&loadSchedule,
		checkSchedule => \&checkSchedule,
		checkEvent => \&checkEvent,
      		}
	);

POE::Session->create(
    	inline_states => {
        	_start => \&initializeJobQueue,
        	_stop => \&shutdown,
      		}
	);

POE::Component::JobQueue->spawn ( 
	Alias => 'queuer',
      	WorkerLimit => 10, 
      	Worker => \&spawnWorker, 
      	Passive => { 
		Prioritizer => \&prioritizeJobs, 
      		},
   	);

POE::Kernel->run();
exit 0;


#-------------------------------------------------------------------
sub checkEvent {
	my ($kernel, $schedule, $workflowId, $time) = @_[KERNEL, ARG0, ARG1, ARG2];
	my $cron = DateTime::Cron::Simple->new($schedule);
	if ($cron->validate_time(DateTime->from_epoch(epoch=>$time))) {
		print "Supposed to run task ".$workflowId." now!!\n";
	}
}

#-------------------------------------------------------------------
sub checkSchedule {
	my ($kernel, $heap) = @_[KERNEL, HEAP];
	my $now = time();
	foreach my $config (keys %{$heap->{workflowSchedules}}) {
		foreach my $event (@{$heap->{workflowSchedules}{$config}}) {
			$kernel->yield("checkEvent",$event->{schedule},$event->{workflowId},$now);
		}
	}
	$kernel->delay_set("checkSchedule",60);
}

#-------------------------------------------------------------------
sub initializeJobQueue {
	print "Starting WebGUI Spectre Job Queue...";
    	my  $kernel = $_[KERNEL];
    	my $serviceName = "queue";
    	$kernel->alias_set($serviceName);
    	$kernel->call( IKC => publish => $serviceName, ["shutdown"] );
	print "OK\n";
	foreach my $config (keys %{WebGUI::Config::readAllConfigs("..")}) {
		$kernel->yield("loadJobs", $config);
	}
}

#-------------------------------------------------------------------
sub initializeScheduler {
	print "Starting WebGUI Spectre Scheduler...";
    	my ( $kernel, $heap) = @_[ KERNEL, HEAP ];
    	my $serviceName = "scheduler";
    	$kernel->alias_set($serviceName);
    	$kernel->call( IKC => publish => $serviceName, ["shutdown", "loadSchedule"] );
	foreach my $config (keys %{WebGUI::Config::readAllConfigs("..")}) {
		$kernel->yield("loadSchedule", $config);
	}
	print "OK\n";
	$kernel->yield("checkSchedule");
}

#-------------------------------------------------------------------
sub loadJobs {
	my ($heap, $config) = @_[HEAP, ARG0];
	sessionOpen($config);
}

#-------------------------------------------------------------------
sub loadSchedule {
	my ($heap, $config) = @_[HEAP, ARG0];
	sessionOpen($config);
	$heap->{workflowSchedules}{$config} = WebGUI::Workflow::getSchedules();
	sessionClose();	
}

#-------------------------------------------------------------------
sub performJob {
	
}

#-------------------------------------------------------------------
sub prioritizeJobs {
	return 1; # FIFO queue, but let's add priorities at some point
}

#-------------------------------------------------------------------
sub sessionOpen {
	WebGUI::Session::open("..",shift);
	WebGUI::Session::refreshUserInfo("pbuser_________spectre");
}

#-------------------------------------------------------------------
sub sessionClose {
	WebGUI::Session::end();
	WebGUI::Session::close();
}

#-------------------------------------------------------------------
sub shutdown {
	my $kernel = $_[KERNEL];
	print "Stopping WebGUI Spectre...";
	if ($session{var}{userId}) {
		sessionClose();
	}
	print "OK\n";
	$kernel->stop;
}

#-------------------------------------------------------------------
sub spawnWorker {
 	my ($postback, @jobParams) = @_; 
    	POE::Session->create ( 
		inline_states => {
			_start => \&startWorker,
			_stop => \&stopWorker,
			performJob => \&performJob
			},
        	args => [ 
			$postback,   
                        @jobParams, 
                        ],
      		);
}

#-------------------------------------------------------------------
sub startWorker {

}

#-------------------------------------------------------------------
sub stopWorker {

}





