package WebGUI::User;

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
use WebGUI::Cache;
use WebGUI::Id;
use WebGUI::Session;
use WebGUI::SQL;


=head1 NAME

Package WebGUI::User

=head1 DESCRIPTION

This package provides an object-oriented way of managing WebGUI users as well as getting/setting a users's profile data.

=head1 SYNOPSIS

 use WebGUI::User;
 $u = WebGUI::User->new(3); or  $f = WebGUI::User->new("new");

 $authMethod =		$u->authMethod("WebGUI");
 $dateCreated = 	$u->dateCreated;
 $karma = 		    $u->karma;
 $lastUpdated = 	$u->lastUpdated;
 $languagePreference = 	$u->profileField("language",1);
 $referringAffiliate =	$u->referringAffiliate;
 $status =		$u->status("somestatus");
 $username = 		$u->username("jonboy");

 $u->addToGroups(\@arr);
 $u->deleteFromGroups(\@arr);
 $u->delete;

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------
sub _create {
	my $userId = shift || WebGUI::Id::generate();
	WebGUI::SQL->write("insert into users (userId,dateCreated) values (".quote($userId).",".time().")");
	require WebGUI::Grouping;
	WebGUI::Grouping::addUsersToGroups([$userId],[2,7]);
        return $userId;
}

#-------------------------------------------------------------------

=head2 addToGroups ( groups [, expireOffset ] )

Adds this user to the specified groups.

=head3 groups

An array reference containing a list of groups.

=head3 expireOffset

An override for the default offset of the grouping. Specified in seconds.

=cut

sub addToGroups {
	my $self = shift;
	my $groups = shift;
	my $expireOffset = shift;
	$self->uncache;
	require WebGUI::Grouping;
	WebGUI::Grouping::addUsersToGroups([$self->userId],$groups,$expireOffset);
}

#-------------------------------------------------------------------

=head2 authMethod ( [ value ] )

Returns the authentication method for this user.

=head3 value

If specified, the authMethod is set to this value. The only valid values are "WebGUI" and "LDAP". When a new account is created, authMethod is defaulted to "WebGUI".

=cut

sub authMethod {
        my ($self, $value);
        $self = shift;
        $value = shift;
        if (defined $value) {
		$self->uncache;
                $self->{_user}{"authMethod"} = $value;
                $self->{_user}{"lastUpdated"} = time();
                WebGUI::SQL->write("update users set authMethod=".quote($value).",
			lastUpdated=".time()." where userId=".quote($self->{_userId}));
        }
        return $self->{_user}{"authMethod"};
}

#-------------------------------------------------------------------

=head2 dateCreated ( )

Returns the epoch for when this user was created.

=cut

sub dateCreated {
        return $_[0]->{_user}{dateCreated};
}

#-------------------------------------------------------------------

=head2 delete ( )

Deletes this user.

=cut

sub delete {
        my $self = shift;
		$self->uncache;
	require WebGUI::Operation::Auth;
        WebGUI::SQL->write("delete from users where userId=".quote($self->{_userId}));
        WebGUI::SQL->write("delete from userProfileData where userId=".quote($self->{_userId}));
	require WebGUI::Grouping;
	WebGUI::Grouping::deleteUsersFromGroups([$self->{_userId}],WebGUI::Grouping::getGroupsForUser($self->{_userId}));
	WebGUI::SQL->write("delete from messageLog where userId=".quote($self->{_userId}));

	my $authMethod = WebGUI::Operation::Auth::getInstance($self->authMethod,$self->{_userId});
	$authMethod->deleteParams($self->{_userId});
    my $sth = WebGUI::SQL->read("select sessionId from userSession where userId=".quote($self->{_userId}));
    while (my ($sid) = $sth->array) {
       WebGUI::Session::end($sid);
    }
    $sth->finish;
}

#-------------------------------------------------------------------

=head2 deleteFromGroups ( groups )

Deletes this user from the specified groups.

=head3 groups

An array reference containing a list of groups.

=cut

sub deleteFromGroups {
	my $self = shift;
	my $groups = shift;
	$self->uncache;
	require WebGUI::Grouping;
	WebGUI::Grouping::deleteUsersFromGroups([$self->userId],$groups);
}

#-------------------------------------------------------------------
# This method is depricated and is provided only for reverse compatibility. See WebGUI::Auth instead.
sub identifier {
        my ($self, $value);
        $self = shift;
        $value = shift;
        if (defined $value) {
		$self->uncache;
                $self->{_user}{"identifier"} = $value;
                WebGUI::SQL->write("update authentication set fieldData=".quote($value)."
                        where userId=".quote($self->{_userId})." and authMethod='WebGUI' and fieldName='identifier'");
        }
        return $self->{_user}{"identifier"};
}

#-------------------------------------------------------------------

=head2 karma ( [ amount, source, description ] )

Returns the current level of karma this user has earned. 

=head3 amount

An integer to modify this user's karma by. Note that this number can be positive or negative.

=head3 source

A descriptive source for this karma. Typically it would be something like "MessageBoard (49)" or "Admin (3)". Source is used to track where a karma modification came from.

=head3 description

A description of why this user's karma was modified. For instance it could be "Message Board Post" or "He was a good boy!".

=cut

sub karma {
	my $self = shift;
	my $amount = shift;
	my $source = shift;
	my $description = shift;
	if (defined $amount && defined $source && defined $description) {
		$self->uncache;
		$self->{_user}{karma} += $amount;
		WebGUI::SQL->write("update users set karma=karma+".quote($amount)." where userId=".quote($self->userId));
        	WebGUI::SQL->write("insert into karmaLog values (".quote($self->userId).",$amount,".quote($source).",".quote($description).",".time().")");
	}
        return $self->{_user}{karma};
}

#-------------------------------------------------------------------

=head2 lastUpdated ( )

Returns the epoch for when this user was last modified.

=cut

sub lastUpdated {
        return $_[0]->{_user}{lastUpdated};
}

#-------------------------------------------------------------------

=head2 new ( userId [, overrideId ] )

Constructor.

=head3 userId 

The userId of the user you're creating an object reference for. If left blank it will default to "1" (Visitor). If specified as "new" then a new user account will be created and assigned the next available userId. 

=head3 overrideId

A unique ID to use instead of the ID that WebGUI will generate for you. It must be absolutely unique and can be up to 22 alpha numeric characters long.

=cut

sub new {
        my $class = shift;
        my $userId = shift || 1;
	my $overrideId = shift;
        $userId = _create($overrideId) if ($userId eq "new");
	my $cache = WebGUI::Cache->new(["user",$userId]);
	my $userData = $cache->get;
	unless ($userData->{_userId} && $userData->{_user}{username}) {
		my %user;
		tie %user, 'Tie::CPHash';
		%user = WebGUI::SQL->quickHash("select * from users where userId=".quote($userId));
		my %profile = WebGUI::SQL->buildHash("select userProfileField.fieldName, userProfileData.fieldData 
			from userProfileField, userProfileData where userProfileField.fieldName=userProfileData.fieldName and 
			userProfileData.userId=".quote($user{userId}));
        	my %default = WebGUI::SQL->buildHash("select fieldName, dataDefault from userProfileField");
        	foreach my $key (keys %default) {
			my $value;
        		if ($profile{$key} eq "" && $default{$key}) {
                		$value = eval($default{$key});
                        	if (ref $value eq "ARRAY") {
                        		$profile{$key} = $$value[0];
                        	} else {
                        		$profile{$key} = $value;
                        	}
                	}
		}
		$userData = {
			_userId => $userId,
			_user => \%user,
			_profile => \%profile
			};
		$cache->set($userData, 60*60*24);
        }
        bless $userData, $class;
}

#-------------------------------------------------------------------

=head2 profileField ( fieldName [ value ] )

Returns a profile field's value. If "value" is specified, it also sets the field to that value. 

=head3 fieldName 

The profile field name such as "language" or "email" or "cellPhone".

=head3 value

The value to set the profile field name to.

=cut

sub profileField {
        my ($self, $fieldName, $value);
	$self = shift;
        $fieldName = shift;
        $value = shift;
	if (defined $value) {
		$self->uncache;
		$self->{_profile}{$fieldName} = $value;
		WebGUI::SQL->write("delete from userProfileData where userId=".quote($self->{_userId})." and fieldName=".quote($fieldName));
		WebGUI::SQL->write("insert into userProfileData values (".quote($self->{_userId}).", ".quote($fieldName).", ".quote($value).")");
		$self->{_user}{"lastUpdated"} = time();
        	WebGUI::SQL->write("update users set lastUpdated=".time()." where userId=".quote($self->{_userId}));
	}
	return $self->{_profile}{$fieldName};
}

#-------------------------------------------------------------------

=head2 referringAffiliate ( [ value ] )

Returns the unique identifier of the affiliate that referred this user to the site. 

=head3 value

An integer containing the unique identifier of the affiliate.

=cut

sub referringAffiliate {
        my $self = shift;
        my $value = shift;
        if (defined $value) {
		$self->uncache;
                $self->{_user}{"referringAffiliate"} = $value;
                $self->{_user}{"lastUpdated"} = time();
                WebGUI::SQL->write("update users set referringAffiliate=".quote($value).",
                        lastUpdated=".time()." where userId=".quote($self->userId));
        }
        return $self->{_user}{"referringAffiliate"};
}

#-------------------------------------------------------------------

=head2 status ( [ value ] )

Returns the status of the user. 

=head3 value

If specified, the status is set to this value.  Possible values are 'Active', 'Selfdestructed' and 'Deactivated'.

=cut

sub status {
        my $self = shift;
        my $value = shift;
        if (defined $value) {
		$self->uncache;
                $self->{_user}{"status"} = $value;
                $self->{_user}{"lastUpdated"} = time();
                WebGUI::SQL->write("update users set status=".quote($value).",
                        lastUpdated=".time()." where userId=".quote($self->userId));
        }
        return $self->{_user}{"status"};
}

#-------------------------------------------------------------------

=head2 uncache ( )

Deletes this user object out of the cache.

=cut

sub uncache {
	my $self = shift;
	my $cache = WebGUI::Cache->new(["user",$self->userId]);
	$cache->delete;	
}

#-------------------------------------------------------------------

=head2 username ( [ value ] )

Returns the username. 

=head3 value

If specified, the username is set to this value. 

=cut

sub username {
        my $self = shift;
        my $value = shift;
        if (defined $value) {
		$self->uncache;
                $self->{_user}{"username"} = $value;
                $self->{_user}{"lastUpdated"} = time();
                WebGUI::SQL->write("update users set username=".quote($value).",
                        lastUpdated=".time()." where userId=".quote($self->userId));
        }
        return $self->{_user}{"username"};
}

#-------------------------------------------------------------------

=head2 userId ( )

Returns the userId for this user.

=cut

sub userId {
        return $_[0]->{_userId};
}

1;
