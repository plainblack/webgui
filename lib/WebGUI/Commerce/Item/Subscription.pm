package WebGUI::Commerce::Item::Subscription;

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

=head1 NAME

Package WebGUI::Commerce::Item::Subscription

=head1 DESCRIPTION

Item plugin for subscriptions.

=cut

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

=head2 new ( $session , $subscriptionId, $type )

Overload default constructor to glue in a WebGUI::Subscription object.

=cut

sub new {
	my ($class, $session, $subscriptionId, $type, $subscription);
	$class = shift;
	$session = shift;
	$subscriptionId = shift;
	$type = shift;
	
	$subscription = WebGUI::Subscription->new($session,$subscriptionId);
	bless {_session => $session, _subscription => $subscription, _subscriptionId => $subscriptionId}, $class;
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

