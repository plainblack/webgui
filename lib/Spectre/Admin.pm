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
	my $self = {_debug=>$debug, _config=>$config};
	bless $self, $class;
	create_ikc_server(
        	port => $config->get("port"),
       	 	name => 'Spectre',
        	);
	POE::Session->create(
		object_states => [ $self => {_start=>"_start", _stop=>"_stop", "shutdown"=>"_stop"} ],
		args=>[["shutdown"]]
        	);
	$self->{_workflow} = Spectre::Workflow->new($config, $debug);
	$self->{_cron} = Spectre::Cron->new($config, $self->{_workflow}, $debug);
	POE::Kernel->run();
}
	


1;

