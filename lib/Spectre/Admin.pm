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
	my $configs = WebGUI::Config->readAllConfigs($self->{_webguiRoot});
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

=head2 new ( webguiRoot )

Constructor.

=head3 webguiRoot

The path to the root of the WebGUI installation.

=cut

sub new {
	my $class = shift;
	my $webguiRoot = shift;
	my $self = {_webguiRoot=>$webguiRoot};
	bless $self, $class;
	create_ikc_server(
        	port => 32133,
       	 	name => 'Spectre',
        	);
	POE::Session->create(
		object_states => [ $self => {_start=>"_start", _stop=>"_stop", "shutdown"=>"_stop"} ],
		args=>[["shutdown"]]
        	);
	$self->{_cron} = Spectre::Cron->new($webguiRoot);
	$self->{_workflow} = Spectre::Workflow->new($webguiRoot);
	POE::Kernel->run();
}



1;

