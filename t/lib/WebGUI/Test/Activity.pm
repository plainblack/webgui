package WebGUI::Test::Activity;

use WebGUI::Workflow;
use WebGUI::Test;

=head Name

package WebGUI::Test::Activity;

=head Description

 This package encapsulates the code required to run
 an activity.

=head Usage

use WebGUI::Test::Activity;

my $instance = WebGUI::Test::Activity->create( $session, 'WebGUI::Workflow::Activity::RemoveOldCarts', {
		cartTimeout => 3600,
} );

is( $instance->run, 'complete', 'activity complete' );
is( $instance->run, 'done', 'activity done' );
$instance->reset;
is( $instance->run, 'complete', 'activity complete' );
is( $instance->run, 'done', 'activity done' );
$instance->delete;

=head methods

=head2 create

=params

session -- the session variable

class -- the class for the activity to run

params -- params to set in the workflow

=cut

sub create {
    my $myClass = shift;
    my $session = shift;
    my $activityClass = shift;
    my $activityParams;
    if( exists $_[0] and ref $_[0] eq 'HASH' ) {
        $activityParams = shift ;
    } else {
        $activityParams = { @_ };
    }
	my $workflow  = WebGUI::Workflow->create($session,
	    {
		enabled    => 1,
		objectType => 'None',
		mode       => 'realtime',
	    },
	);
	my $activity = $workflow->addActivity($activityClass);
    if( scalar( keys %$activityParams ) > 0 ) {
	$activity->set(%$activityParams);
    }

	my $instance = WebGUI::Workflow::Instance->create($session,
	    {
		workflowId              => $workflow->getId,
		skipSpectreNotification => 1,
	    }
	);

	addToCleanup($workflow);

    return bless { instance => $instance,
		   session => $session,
                   workflow => $workflow }, __PACKAGE__;
}

=head2 run

calls run on the instance of the workflow

=cut

sub run {
    return $_[0]{instance}->run;
}

=head2 reset

creates a new instance of the workflow so that it can be re-run

=cut

sub reset {
    my $self = shift;
    my $session = $self->{session};
    $self->{instance} = WebGUI::Workflow::Instance->create($session,
	{
	    workflowId              => $self->{workflow}->getId,
	    skipSpectreNotification => 1,
	}
    );
}

1;

