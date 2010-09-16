package Spectre::Admin;

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

=cut

use strict;
use HTTP::Request;
use JSON;
use Log::Log4perl;
use LWP::UserAgent;
use POE;
use POE::Component::IKC::Server;
use POE::Component::IKC::Specifier;
use Spectre::Cron;
use Spectre::Workflow;
use WebGUI::Paths;
use WebGUI::Config;


#-------------------------------------------------------------------

=head2 _safe_shutdown ( )

Stops the kernel when TERM signal is received

=cut

sub _safe_shutdown {
    my ($obj) = $_[ OBJECT ];
    $obj->error('Spectre shut down');
    POE::Kernel->stop;
}


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
	$kernel->delay_set("loadSiteData",3);
    $kernel->sig( TERM => '_safe_shutdown' );
}


#-------------------------------------------------------------------

=head2 config ( )

Returns a reference to the config object.

=cut 

sub config {
	my $self = shift;
	return $self->{_config};
}

#-------------------------------------------------------------------

=head2 debug ( output )

Prints out debug information if debug is enabled.

=head3 output

The debug message to be printed if debug is enabled.

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

=head3 output

The error message to be printed if debug is enabled.

=cut 

sub error {
	my $self = shift;
	my $output = shift;
	print "ADMIN: [Error] ".$output."\n";
	$self->getLogger->error("ADMIN: ".$output);
}

#-------------------------------------------------------------------

=head2 getLogger ( )

Returns a reference to the logger.

=cut

sub getLogger {
	my $self = shift;
	return $self->{_logger};
}

#-------------------------------------------------------------------

=head2 loadSiteData ( )

Fetches the site from each defined site, and loads it into the Workflow and Cron governors.

=cut

sub loadSiteData {
        my ( $kernel, $self) = @_[ KERNEL, OBJECT ];
	my $configs = WebGUI::Config->readAllConfigs;
    $self->debug("Reading site configs.");
	foreach my $key (keys %{$configs}) {
		next if $key =~ m/^demo/;
		$self->debug("Fetching site data for $key");
		 my $userAgent = new LWP::UserAgent;
        if (!$self->config->get('ignoreEnvProxy')) {
            $userAgent->env_proxy;
        }
        	$userAgent->agent("Spectre");
        	$userAgent->timeout(30);
		my $url = "http://".$configs->{$key}->get("sitename")->[0].":".$self->{_config}->get("webguiPort").$configs->{$key}->get("gateway")."?op=spectreGetSiteData";
        	my $request = new HTTP::Request (GET => $url);
        	my $response = $userAgent->request($request);
        	if ($response->is_error) {
			$self->error( "Couldn't connect to WebGUI site $key at $url.  Response: " . $response->status_line );
        	} 
		else {
			my $siteData = {};
			eval { $siteData = JSON::decode_json($response->content); };
			if ($@) {
				$self->error("Couldn't fetch Spectre configuration data for $key : $@");
			}
			else {
				$self->debug("Loading workflow data for $key");
				foreach my $instance (@{$siteData->{workflow}}) {
					$kernel->post("workflow" ,"addInstance", $instance);
				}
				$self->debug("Loading scheduler data for $key");
				foreach my $task (@{$siteData->{cron}}) {
					$task->{config} = $key;
					$kernel->post("cron", "addJob", $task);
				}
			}
        	}
	}	
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
 	Log::Log4perl->init( WebGUI::Paths->logConfig );
	$Log::Log4perl::caller_depth = $Log::Log4perl::caller_depth+3;
	my $logger = Log::Log4perl->get_logger($config->getFilename);
	my $self = {_debug=>$debug, _config=>$config, _logger=>$logger};
	bless $self, $class;
	$self->debug("Trying to bind to ".$config->get("ip").":".$config->get("port"));
	create_ikc_server(
		ip => $config->get("ip"),
        	port => $config->get("port"),
       	 	name => 'Spectre'
        	);
	POE::Session->create(
		object_states => [ $self => {_start=>"_start", "ping"=>"ping", "loadSiteData"=>"loadSiteData", "_safe_shutdown" => "_safe_shutdown"} ],
		args=>[["ping"]]
        	);
	Spectre::Workflow->new($config, $logger, $debug);
	Spectre::Cron->new($config, $logger, $debug);
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

Executes a test to see if Spectre can establish a connection to WebGUI and get back a valid response. This is a class method.

=head3 config

A WebGUI::Config object that represents the spectre.conf file.

=cut

sub runTests {
	my $class = shift;
	my $config = shift;
	print "Running connectivity tests.\n";
	my $configs = WebGUI::Config->readAllConfigs;
	foreach my $key (keys %{$configs}) {
		next if $key =~ m/^demo/;
		print "Testing $key\n";
		 my $userAgent = new LWP::UserAgent;
        if (!$config->get('ignoreEnvProxy')) {
            $userAgent->env_proxy;
        }
        	$userAgent->agent("Spectre");
        	$userAgent->timeout(30);
		my $url = "http://".$configs->{$key}->get("sitename")->[0].":".$config->get("webguiPort").$configs->{$key}->get("gateway")."?op=spectreTest";
        	my $request = new HTTP::Request (GET => $url);
        	my $response = $userAgent->request($request);
        	if ($response->is_error) {
			print "ERROR: Couldn't connect to WebGUI site $key\n";
        	} else {
                	my $response = $response->content;
			if ($response eq "subnet") {
				print "ERROR: Spectre cannot communicate with WebGUI. Perhaps you need to adjust the spectreSubnets setting in this config file: $key.\n";
			} elsif ($response eq "spectre") {
				print "ERROR: WebGUI cannot communicate with Spectre. Perhaps you need to adjust the spectreIp or spectrePort setting the this config file: $key.";
			} elsif ($response ne "success") {
				print "ERROR: Spectre received an invalid response ($response) from WebGUI while testing $key\n";
			}
        	}
	}	
	print "Tests completed.\n";
}


1;
