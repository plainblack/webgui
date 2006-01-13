package WebGUI::Commerce::Item::Subscription;

use strict;
#use WebGUI::SQL;
use WebGUI::Subscription;

our @ISA = qw(WebGUI::Commerce::Item);

#-------------------------------------------------------------------
sub description {
	return $_[0]->{_subscription}->get('description');
}

#-------------------------------------------------------------------
sub duration {
	$_[0]->{_subscription}->get('duration');
}

#-------------------------------------------------------------------
sub handler {
	$_[0]->{_subscription}->apply($_[1]);
}

#-------------------------------------------------------------------
sub id {
	return $_[0]->{_subscription}->get('subscriptionId');
}

#-------------------------------------------------------------------
sub isRecurring {
	return 1;
}

#-------------------------------------------------------------------
sub name {
	return $_[0]->{_subscription}->get('name');
}

#-------------------------------------------------------------------
sub new {
	my ($class, $session, $subscriptionId, $type, $subscription);
	$class = shift;
	$session = shift;
	$subscriptionId = shift;
	$type = shift;
	
	$subscription = WebGUI::Subscription->new($session,$subscriptionId);
	bless {_subscription => $subscription, _subscriptionId => $subscriptionId}, $class;
}

#-------------------------------------------------------------------
sub price {
	return $_[0]->{_subscription}->get('price');
}

#-------------------------------------------------------------------
sub type {
	return 'Subscription';
}

1;

