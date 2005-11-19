package WebGUI::Workflow;


=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2005 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use WebGUI::Session;

=head1 NAME

Package WebGUI::Workflow

=head1 DESCRIPTION

This package provides global utility functions for workflows.

=head1 SYNOPSIS

 use WebGUI::Workflow;

 $arrayRef = getSchedules();

=head1 FUNCTIONS

These subroutines are available from this package:

=cut

#-------------------------------------------------------------------

=head2 getSchedules

Returns an array reference of hashes containing the workflow schedule data for this site.

=cut

sub getSchedules {
	my @schedules;
	my $sth = WebGUI::SQL->read("select * from WorkflowSchedule where enabled=1");
	while (my $event = $sth->hashRef) {
		my $schedule = join(" ",$event->{minuteOfHour},$event->{hourOfDay},$event->{dayOfMonth},$event->{monthOfYear},$event->{dayOfWeek});
		push(@schedules,{
			schedule=>$schedule,
			workflowId=>$event->{workflowId}
			});
	}
	return \@schedules;
}

1;


