package Spectre::ProcessManager;

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
use Proc::Background;

#-------------------------------------------------------------------

=head2 cleanUp ( )

Cleans up the process list by clearning out old processes that have completed.

=cut

sub cleanUp {
	my $self = shift;
	my @newList = ();
	foreach my $process (@{$self->{_processList}}) {
		push(@newList, $process) if ($process->alive);	
	}
	$self->{_processList} = \@newList;
}

#-------------------------------------------------------------------

=head2 createProcess ( command )

Spawns a new process.

=head3 command

The commandline to execute under the new process.

=cut

sub createProcess {
	my $self = shift;
	my $command = shift;
	my $process = Proc::Background->new({'die_upon_destroy' => 1}, $command);
	push(@{$self->{_processList}}, $process);
}

#-------------------------------------------------------------------

=head2 DESTROY ( )

Deconstructor.

=cut

sub DESTROY {
	my $self = shift;
	$self->killAllProcesses;
	undef $self;
}

#-------------------------------------------------------------------

=head2 getProcessCount ( ) 

Returns an integer representing the number of processes currently running. This runs cleanUp() before counting to ensure an accurate count.

=cut

sub getProcessCount {
	my $self = shift;
	$self->cleanUp;
	return scalar(@{$self->{_processList}});
}


#-------------------------------------------------------------------

=head2 killAllProcesses ( )

Kills all of the running processes.

=cut

sub killAllProcesses {
	my $self = shift;
	foreach my $process (@{$self->{_processList}}) {
		$process->die;
	}
	$self->{_processList} = ();
}


#-------------------------------------------------------------------

=head2 new ( )

Constructor.

=cut 

sub new {
	my $class = shift;
	bless {_processList} => ()}, $class;
}

1;


