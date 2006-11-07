package WebGUI::Subscription;

use strict;
use WebGUI::Macro;
use WebGUI::Utility;
use WebGUI::Commerce::Payment;

=head1 NAME

Package WebGUI::Subscription

=head1 DESCRIPTION

Base class for subscriptions

=head2 _getDuration ( $duration )

Internal utility function for calculating when a subscription expires.
Returns the date in epoch format when it expires.

=head3 $duration

Text description of how long the subscription lasts.

=cut

sub _getDuration {
	my $self = shift;
	my $duration = shift;
	return $self->session->datetime->addToDate(0,0,0,7) if $duration eq 'Weekly';
	return $self->session->datetime->addToDate(0,0,0,14) if $duration eq 'BiWeekly';
	return $self->session->datetime->addToDate(0,0,0,28) if $duration eq 'FourWeekly';
	return $self->session->datetime->addToDate(0,0,1,0) if $duration eq 'Monthly';
	return $self->session->datetime->addToDate(0,0,3,0) if $duration eq 'Quarterly';
	return $self->session->datetime->addToDate(0,0,6,0) if $duration eq 'HalfYearly';
	return $self->session->datetime->addToDate(0,1,0,0) if $duration eq 'Yearly';
}

#-------------------------------------------------------------------

=head2 apply ( [ $userId ] )

Method for subscribing a user.  Adds user to the proper group and sets the expiration date,
adds karma to the user for purchasing a subscription, and then runs any external commands
as specified by the executeOnSubscription property.  Macros in executeOnSubscription are
expanded before the command is executed.

=head3 userId

ID of the user purchasing the subscription.  If omitted, uses the current user as
specified by the session variable.

=cut

sub apply {
	my ($self, $userId, $groupId);
	$self = shift;
	$userId = shift || $self->session->user->userId;
	$groupId = $self->{_properties}{subscriptionGroup};
	my $group = WebGUI::Group->new($self->session,$groupId);
	# Make user part of the right group
	$group->addUsers([$userId], $self->_getDuration($self->{_properties}{duration}));

	# Add karma
	WebGUI::User->new($self->session,$userId)->karma($self->{_properties}{karma}, 'Subscription', 'Added for purchasing subscription '.$self->{_properties}{name});

	# Process executeOnPurchase field
	my $command = $self->{_properties}{executeOnSubscription};
	WebGUI::Macro::process($self->session,\$command);
	system($command) if ($self->{_properties}{executeOnSubscription} ne "");
}

#-------------------------------------------------------------------

=head2 delete 

Method for deleting a subscription.  Marks the subscription as deleted in the database
but does not remove it from the database.

=cut

sub delete {
	my ($self);
	$self = shift;
	
	$self->session->db->write("update subscription set deleted=1 where subscriptionId=".$self->session->db->quote($self->{_subscriptionId}));
	$self->{_properties}{deleted} = 1;
}
	
#-------------------------------------------------------------------

=head2 get ( $key )

Generic assessor method for Subscription objects.

=head3 key

Returns only the requested property.  Returns undef if the key does not exist
in the object properties.  Returns the entire property hash if the key is
false (0, undef, '');

=cut

sub get {
	my ($self, $key) = @_;
	return $self->{_properties}{$key} if ($key);
	return $self->{_properties};
}

#-------------------------------------------------------------------

=head2 new ( session, subscriptionId )

Object creation method.

=head3 session

A reference to the current session.

=head3 subscriptionId

ID of the subscription to create.  If this subscriptionId exists in the
database, the object created will be fully populated with properties
from the database.

=cut

sub new {
	my ($class, $subscriptionId, %properties);
	$class = shift;
	my $session = shift;
	$subscriptionId = shift;

	if ($subscriptionId eq 'new') {
		$subscriptionId = $session->id->generate;
		$session->db->write("insert into subscription (subscriptionId) values (".$session->db->quote($subscriptionId).")");
	}
	
	%properties = $session->db->quickHash("select * from subscription where subscriptionId=".$session->db->quote($subscriptionId));
	
	bless {_session=>$session, _subscriptionId => $subscriptionId, _properties => \%properties}, $class;
}

#-------------------------------------------------------------------

=head2 session ( )

Returns a reference to the current session.

=cut

sub session {
	my $self = shift;
	return $self->{_session};
}

#-------------------------------------------------------------------

=head2 set ( $properties )

Returns the date in epoch format when it expires.

=head3 $properties

A hashref containing properties to set in the object.  Only valid properties will be
set.  Also updates the subscription record in the database with properties that have
been set.

=head3 Valid Object properties

name price description subscriptionGroup duration executeOnSubscription karma

=cut

sub set {
	my ($self, $properties, @fieldsToUpdate);
	$self = shift;
	$properties = shift;

	foreach (keys(%{$properties})) {
		if (isIn($_, qw(name price useSalesTax description subscriptionGroup duration executeOnSubscription karma))) {
			$self->{_properties}{$_} = $properties->{$_};
			push(@fieldsToUpdate, $_);
		}
	}

	$self->session->db->write("update subscription set ".
		join(',', map {"$_=".$self->session->db->quote($properties->{$_})} @fieldsToUpdate).
		" where subscriptionId=".$self->session->db->quote($self->{_subscriptionId}));
}

1;

