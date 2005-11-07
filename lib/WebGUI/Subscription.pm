package WebGUI::Subscription;

use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Grouping;
use WebGUI::Macro;
use WebGUI::Utility;
use WebGUI::Commerce::Payment;
use WebGUI::DateTime;

sub _getDuration {
	my $duration = shift;
	
	return addToDate(0,0,0,7) if $duration eq 'Weekly';
	return addToDate(0,0,0,14) if $duration eq 'BiWeekly';
	return addToDate(0,0,0,28) if $duration eq 'FourWeekly';
	return addToDate(0,0,1,0) if $duration eq 'Monthly';
	return addToDate(0,0,3,0) if $duration eq 'Quarterly';
	return addToDate(0,0,6,0) if $duration eq 'HalfYearly';
	return addToDate(0,1,0,0) if $duration eq 'Yearly';
}

#-------------------------------------------------------------------
sub apply {
	my ($self, $userId, $groupId, $expirationDate);
	$self = shift;
	$userId = shift || $session{user}{userId};
	$groupId = $self->{_properties}{subscriptionGroup};

	# Make user part of the right group
	WebGUI::Grouping::addUsersToGroups([$userId], [$groupId], _getDuration($self->{_properties}{duration}));

	# Add karma
	WebGUI::User->new($userId)->karma($self->{_properties}{karma}, 'Subscription', 'Added for purchasing subscription '.$self->{_properties}{name});

	# Process executeOnPurchase field
	my $command = $self->{_properties}{executeOnSubscription};
	WebGUI::Macro::process(\$command);
	system($command) if ($self->{_properties}{executeOnSubscription} ne "");
}

#-------------------------------------------------------------------
sub delete {
	my ($self);
	$self = shift;
	
	WebGUI::SQL->write("update subscription set deleted=1 where subscriptionId=".quote($self->{_subscriptionId}));
	$self->{_properties}{deleted} = 1;
}
	
#-------------------------------------------------------------------
sub get {
	my ($self, $key) = @_;
	return $self->{_properties}{$key} if ($key);
	return $self->{_properties};
}

#-------------------------------------------------------------------
sub new {
	my ($class, $subscriptionId, %properties);
	$class = shift;
	$subscriptionId = shift;

	if ($subscriptionId eq 'new') {
		$subscriptionId = WebGUI::Id::generate;
		WebGUI::SQL->write("insert into subscription (subscriptionId) values (".quote($subscriptionId).")");
	}
	
	%properties = WebGUI::SQL->quickHash("select * from subscription where subscriptionId=".quote($subscriptionId));
	
	bless {_subscriptionId => $subscriptionId, _properties => \%properties}, $class;
}

#-------------------------------------------------------------------
sub set {
	my ($self, $properties, @fieldsToUpdate);
	$self = shift;
	$properties = shift;

	foreach (keys(%{$properties})) {
		if (isIn($_, qw(name price description subscriptionGroup duration executeOnSubscribe karma))) {
			$self->{_properties}{$_} = $value;
			push(@fieldsToUpdate, $_);
		}
	}

	WebGUI::SQL->write("update subscription set ".
		join(',', map {"$_=".quote($properties->{$_})} @fieldsToUpdate).
		" where subscriptionId=".quote($self->{_subscriptionId}));
}

1;

