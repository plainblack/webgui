package WebGUI::User;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2004 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use WebGUI::DateTime;
use WebGUI::Grouping;
use WebGUI::HTMLForm;
use WebGUI::Id;
use WebGUI::International;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::Operation::Auth;

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
	my ($userId);
	$userId = WebGUI::Id::generate();
	WebGUI::SQL->write("insert into users (userId,dateCreated) values (".quote($userId).",".time().")");
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
	WebGUI::Grouping::addUsersToGroups([$_[0]->{_userId}],$_[1],$_[2]);
}

#-------------------------------------------------------------------

=head2 authMethod ( [ value ] )

Returns the authentication method for this user.

=head3 value

If specified, the authMethod is set to this value. The only valid values are "WebGUI" and "LDAP". When a new account is created, authMethod is defaulted to "WebGUI".

=cut

sub authMethod {
        my ($class, $value);
        $class = shift;
        $value = shift;
        if (defined $value) {
                $class->{_user}{"authMethod"} = $value;
                WebGUI::SQL->write("update users set authMethod=".quote($value).",
			lastUpdated=".time()." where userId=".quote($class->{_userId}));
        }
        return $class->{_user}{"authMethod"};
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
        my $class = shift;
        WebGUI::SQL->write("delete from users where userId=".quote($class->{_userId}));
        WebGUI::SQL->write("delete from userProfileData where userId=".quote($class->{_userId}));
	WebGUI::Grouping::deleteUsersFromGroups([$class->{_userId}],WebGUI::Grouping::getGroupsForUser($class->{_userId}));
	WebGUI::SQL->write("delete from messageLog where userId=".quote($class->{_userId}));

	my $authMethod = WebGUI::Operation::Auth::getInstance($class->authMethod,$class->{_userId});
	$authMethod->deleteParams($class->{_userId});
    my $sth = WebGUI::SQL->read("select sessionId from userSession where userId=".quote($class->{_userId}));
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
	WebGUI::Grouping::deleteUsersFromGroups([$_[0]->{_userId}],$_[1]);
}

#-------------------------------------------------------------------
# This method is depricated and is provided only for reverse compatibility. See WebGUI::Auth instead.
sub identifier {
        my ($class, $value);
        $class = shift;
        $value = shift;
        if (defined $value) {
                $class->{_user}{"identifier"} = $value;
                WebGUI::SQL->write("update authentication set fieldData=".quote($value)."
                        where userId=".quote($class->{_userId})." and authMethod='WebGUI' and fieldName='identifier'");
        }
        return $class->{_user}{"identifier"};
}

#-------------------------------------------------------------------

=head2 karma ( amount, source, description )

Returns the current level of karma this user has earned. 

=head3 amount

An integer to modify this user's karma by. Note that this number can be positive or negative.

=head3 source

A descriptive source for this karma. Typically it would be something like "MessageBoard (49)" or "Admin (3)". Source is used to track where a karma modification came from.

=head3 description

A description of why this user's karma was modified. For instance it could be "Message Board Post" or "He was a good boy!".

=cut

sub karma {
	if (defined $_[1] && defined $_[2] && defined $_[3]) {
		WebGUI::SQL->write("update users set karma=karma+".quote($_[1])." where userId=".quote($_[0]->userId));
        	WebGUI::SQL->write("insert into karmaLog values (".quote($_[0]->userId).",$_[1],".quote($_[2]).",".quote($_[3]).",".time().")");
	}
        return $_[0]->{_user}{karma};
}

#-------------------------------------------------------------------

=head2 lastUpdated ( )

Returns the epoch for when this user was last modified.

=cut

sub lastUpdated {
        return $_[0]->{_user}{lastUpdated};
}

#-------------------------------------------------------------------

=head2 new ( userId )

Constructor.

=head3 userId 

The userId of the user you're creating an object reference for. If left blank it will default to "1" (Visitor). If specified as "new" then a new user account will be created and assigned the next available userId.

=cut

sub new {
        my ($class, $userId, %default, $value, $key, %user, %profile);
	tie %user, 'Tie::CPHash';
        $class = shift;
        $userId = shift || 1;
	$userId = _create() if ($userId eq "new");
	%user = WebGUI::SQL->quickHash("select * from users where userId=".quote($userId));
	%profile = WebGUI::SQL->buildHash("select userProfileField.fieldName, userProfileData.fieldData 
		from userProfileField, userProfileData where userProfileField.fieldName=userProfileData.fieldName and 
		userProfileData.userId=".quote($user{userId}));
        %default = WebGUI::SQL->buildHash("select fieldName, dataDefault from userProfileField where profileCategoryId=4");
        foreach $key (keys %default) {
        	if ($profile{$key} eq "") {
                	$value = eval($default{$key});
                        if (ref $value eq "ARRAY") {
                        	$profile{$key} = $$value[0];
                        } else {
                        	$profile{$key} = $value;
                        }
                }
        }
        bless {_userId => $userId, _user => \%user, _profile =>\%profile }, $class;
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
        my ($class, $fieldName, $value);
	$class = shift;
        $fieldName = shift;
        $value = shift;
	$value = WebGUI::Macro::negate($value);	
	if (defined $value) {
		$class->{_profile}{$fieldName} = $value;
		WebGUI::SQL->write("delete from userProfileData where userId=".quote($class->{_userId})." and fieldName=".quote($fieldName));
		WebGUI::SQL->write("insert into userProfileData values (".quote($class->{_userId}).", ".quote($fieldName).", ".quote($value).")");
        	WebGUI::SQL->write("update users set lastUpdated=".time()." where userId=".quote($class->{_userId}));
	}
	return $class->{_profile}{$fieldName};
}

#-------------------------------------------------------------------

=head2 referringAffiliate ( [ value ] )

Returns the unique identifier of the affiliate that referred this user to the site. 

=head3 value

An integer containing the unique identifier of the affiliate.

=cut

sub referringAffiliate {
        my ($class, $value);
        $class = shift;
        $value = shift;
        if (defined $value) {
                $class->{_user}{"referringAffiliate"} = $value;
                WebGUI::SQL->write("update users set referringAffiliate=".quote($value).",
                        lastUpdated=".time()." where userId=".quote($class->{_userId}));
        }
        return $class->{_user}{"referringAffiliate"};
}

#-------------------------------------------------------------------

=head2 status ( [ value ] )

Returns the status of the user. 

=head3 value

If specified, the status is set to this value.  Possible values are 'Active', 'Selfdestructed' and 'Deactivated'.

=cut

sub status {
        my ($class, $value);
        $class = shift;
        $value = shift;
        if (defined $value) {
                $class->{_user}{"status"} = $value;
                WebGUI::SQL->write("update users set status=".quote($value).",
                        lastUpdated=".time()." where userId=".quote($class->{_userId}));
        }
        return $class->{_user}{"status"};
}

#-------------------------------------------------------------------

=head2 username ( [ value ] )

Returns the username. 

=head3 value

If specified, the username is set to this value. 

=cut

sub username {
        my ($class, $value);
        $class = shift;
        $value = shift;
        if (defined $value) {
                $class->{_user}{"username"} = $value;
                WebGUI::SQL->write("update users set username=".quote($value).",
                        lastUpdated=".time()." where userId=".quote($class->{_userId}));
        }
        return $class->{_user}{"username"};
}

#-------------------------------------------------------------------

=head2 userId ( )

Returns the userId for this user.

=cut

sub userId {
        return $_[0]->{_userId};
}

1;
