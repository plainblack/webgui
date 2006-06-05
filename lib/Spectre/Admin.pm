package Spectre::Admin;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2006 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use HTTP::Request;
use LWP::UserAgent;
use POE;
use POE::Component::IKC::Server;
use POE::Component::IKC::Specifier;
use Spectre::Cron;
use Spectre::Workflow;

#-------------------------------------------------------------------

=head2 _start ( )

Initializes the admin interface.

=cut

sub _start {
        my ( $kernel, $self, $publicEvents) = @_[ KERNEL, OBJECT, ARG0 ];
	$self->debug("Starting Spectre administrative manager.");
        my $serviceName = "admin";
        $kernel->alias_set($serviceName);
        $kernel->call( IKC => publish => $serviceName, $publicEvents );
}

#-------------------------------------------------------------------

=head2 _stop ( )

Gracefully shuts down the admin interface.

=cut

sub _stop {
	my ($kernel, $self) = @_[KERNEL, OBJECT];
	$self->debug("Stopping Spectre administrative manager.");
	undef $self;
	$kernel->stop;
}

#-------------------------------------------------------------------

=head2 config ()

Returns a reference to the config object.

=cut 

sub config {
	my $self = shift;
	return $self->{_config};
}

#-------------------------------------------------------------------

=head2 debug ( output )

Prints out debug information if debug is enabled.

=head3 

=cut 

sub debug {
	my $self = shift;
	my $output = shift;
	if ($self->{_debug}) {
		print "ADMIN: ".$output."\n";
	}
	$self->getLogger->debug("ADMIN: ".$output);
}

#-------------------------------------------------------------------

=head2 error ( output )

Prints out error information.

=head3 

=cut 

sub error {
	my $self = shift;
	my $output = shift;
	print "ADMIN: [Error] ".$output."\n";
	$self->getLogger->error("ADMIN: ".$output);
}

#-------------------------------------------------------------------

=head3 getLogger ( )

Returns a reference to the logger.

=cut

sub getLogger {
	my $self = shift;
	return $self->{_logger};
}

#-------------------------------------------------------------------

=head2 new ( config [ , debug ] )

Constructor.

=head3 config

A WebGUI::Config object that represents the spectre.conf file.

=head3 debug

A boolean indicating Spectre should spew forth debug as it runs.

=cut

sub new {
	my $class = shift;
	my $config = shift;
	my $debug = shift;
 	Log::Log4perl->init( $config->getWebguiRoot."/etc/log.conf" );   
	$Log::Log4perl::caller_depth = $Log::Log4perl::caller_depth+3;
	my $logger = Log::Log4perl->get_logger($config->getFilename);
	my $self = {_debug=>$debug, _config=>$config, _logger=>$logger};
	bless $self, $class;
	$self->runTests();
	$self->debug("Trying to bind to ".$config->get("ip").":".$config->get("port"));
	create_ikc_server(
		ip => $config->get("ip"),
        	port => $config->get("port"),
       	 	name => 'Spectre',
        	);
	POE::Session->create(
		object_states => [ $self => {_start=>"_start", _stop=>"_stop", "shutdown"=>"_stop", "ping"=>"ping"} ],
		args=>[["shutdown","ping"]]
        	);
	$self->{_workflow} = Spectre::Workflow->new($config, $logger, $debug);
	$self->{_cron} = Spectre::Cron->new($config, $logger, $self->{_workflow}, $debug);
	POE::Kernel->run();
}
	
#-------------------------------------------------------------------

=head2 ping ( )

Check to see if Spectre is alive. Returns "pong".

=cut

sub ping {
 	my ($kernel, $request) = @_[KERNEL,ARG0];
        my ($data, $rsvp) = @$request;
        $kernel->call(IKC=>post=>$rsvp,"pong");
}

#-------------------------------------------------------------------

=head2 runTests ( )

Executes a test to see if Spectre can establish a connection to WebGUI and get back a valid response.

=cut

sub runTests {
	my $self = shift;
	my $config = shift;
	$self->debug("Running connectivity tests.");
	my $configs = WebGUI::Config->readAllConfigs($self->config->getWebguiRoot);
	foreach my $config (keys %{$configs}) {
		next if $config =~ m/^demo/;
		$self->debug("Testing $config");
		 my $userAgent = new LWP::UserAgent;
        	$userAgent->agent("Spectre");
        	$userAgent->timeout(30);
		my $url = "http://".$configs->{$config}->get("sitename")->[0].":".$self->config->get("webguiPort").$configs->{$config}->get("gateway")."?op=spectreTest";
        	my $request = new HTTP::Request (GET => $url);
        	my $response = $userAgent->request($request);
        	if ($response->is_error) {
			$self->error("Couldn't connect to WebGUI site $config");
        	} else {
                	my $response = $response->content;
			if ($response eq "subnet") {
				$self->error("Spectre cannot communicate with WebGUI for $config, perhaps you need to adjust the spectreSubnets setting in this config file.");
			} elsif ($response eq "spectre") {
				$self->error("WebGUI connot communicate with Spectre for $config, perhaps you need to adjust the spectreIp or spectrePort setting the this config file.");
			} elsif ($response ne "success") {
				$self->error("Spectre received an invalid response from WebGUI while testing $config");
			}
        	}
	}	
	$self->debug("Tests completed.");	
}


1;

