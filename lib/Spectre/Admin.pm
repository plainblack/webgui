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
        print "Starting WebGUI Spectre Admin...";
        my ( $kernel, $self, $publicEvents) = @_[ KERNEL, OBJECT, ARG0 ];
        my $serviceName = "admin";
        $kernel->alias_set($serviceName);
        $kernel->call( IKC => publish => $serviceName, $publicEvents );
        print "OK\n";
}

#-------------------------------------------------------------------

=head2 _stop ( )

Gracefully shuts down the admin interface.

=cut

sub _stop {
	my ($kernel, $self) = @_[KERNEL, OBJECT];
	print "Stopping WebGUI Admin...";
	undef $self;
	$kernel->stop;
	print "OK\n";
}

#-------------------------------------------------------------------

=head2 new ( config )

Constructor.

=head3 config

A WebGUI::Config object that represents the spectre.conf file.

=cut

sub new {
	my $class = shift;
	my $config = shift;
	my $self = {_config=>$config};
	bless $self, $class;
	create_ikc_server(
        	port => $config->get("port"),
       	 	name => 'Spectre',
        	);
	POE::Session->create(
		object_states => [ $self => {_start=>"_start", _stop=>"_stop", "shutdown"=>"_stop"} ],
		args=>[["shutdown"]]
        	);
	$self->{_cron} = Spectre::Cron->new($config);
	$self->{_workflow} = Spectre::Workflow->new($config);
	POE::Kernel->run();
}



1;

