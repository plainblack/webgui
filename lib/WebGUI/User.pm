package WebGUI::User;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2002 Plain Black LLC.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use WebGUI::HTMLForm;
use WebGUI::International;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;

=head1 NAME

 Package WebGUI::User

=head1 SYNOPSIS

 use WebGUI::User;
 $u = WebGUI::User->new(3); or  $f = WebGUI::User->new("new");

 $authMethod =		$u->authMethod("WebGUI");
 $connectDN = 		$u->authMethod("cn=Jon Doe");
 $dateCreated = 	$u->dateCreated;
 $identifier = 		$u->identifier("somepassword");
 $karma = 		$u->karma;
 $lastUpdated = 	$u->lastUpdated;
 $ldapURL = 		$u->ldapURL("ldap://ldap.mycompany.com:389/o=MyCompany");
 $languagePreference = 	$u->profileField("language",1);
 $username = 		$u->username("jonboy");

 $u->addToGroups(\@arr);
 $u->deleteFromGroups(\@arr);
 $u->delete;

=head1 DESCRIPTION

 This package provides an object-oriented way of managing WebGUI
 users as well as getting/setting a users's profile data.

=head1 METHODS

 These methods are available from this class:

=cut

#-------------------------------------------------------------------
sub _create {
	my ($userId);
	$userId = getNextId("userId");
	WebGUI::SQL->write("insert into users (userId,dateCreated) values ($userId,".time().")");
        return $userId;
}

#-------------------------------------------------------------------

=head2 addToGroups ( groups )

 Adds this user to the specified groups.

=item groups

 An array reference containing a list of groups.

=cut

sub addToGroups {
	my ($class, $groups, $gid, $expireAfter);
	$class = shift;
	$groups = shift;
	foreach $gid (@$groups) {
        	($expireAfter) = WebGUI::SQL->quickArray("select expireAfter from groups where groupId=$gid");
                WebGUI::SQL->write("insert into groupings values ($gid, $class->{_userId}, ".(time()+$expireAfter).")");
        }
        WebGUI::SQL->write("update users set lastUpdated=".time()." where userId=".$class->{_userId});
}

#-------------------------------------------------------------------

=head2 authMethod ( [ value ] )

 Returns the authentication method for this user.

=item value

 If specified, the authMethod is set to this value. The only valid
 values are "WebGUI" and "LDAP". When a new account is created,
 authMethod is defaulted to "WebGUI".

=cut

sub authMethod {
        my ($class, $value);
        $class = shift;
        $value = shift;
        if (defined $value) {
                $class->{_user}{"authMethod"} = $value;
                WebGUI::SQL->write("update users set authMethod=".quote($value).",
			lastUpdated=".time()." where userId=$class->{_userId}");
        }
        return $class->{_user}{"authMethod"};
}

#-------------------------------------------------------------------

=head2 connectDN ( [ value ] )

 Returns the connection distinguished name for this user.

=item value

 If specified, the connectDN is set to this value.

=cut

sub connectDN {
        my ($class, $value);
        $class = shift;
        $value = shift;
        if (defined $value) {
                $class->{_user}{"connectDN"} = $value;
                WebGUI::SQL->write("update users set connectDN=".quote($value).",
                        lastUpdated=".time()." where userId=$class->{_userId}");
        }
        return $class->{_user}{"connectDN"};
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
        my ($class);
        $class = shift;
        WebGUI::SQL->write("delete from users where userId=".$class->{_userId});
        WebGUI::SQL->write("delete from userProfileData where userId=".$class->{_userId});
	WebGUI::SQL->write("delete from groupings where userId=".$class->{_userId});
	WebGUI::SQL->write("delete from messageLog where userId=".$class->{_userId});
	WebGUI::SQL->write("delete from userSession where userId=".$class->{_userId});
}

#-------------------------------------------------------------------

=head2 deleteFromGroups ( groups )

 Deletes this user from the specified groups.

=item groups

 An array reference containing a list of groups.

=cut

sub deleteFromGroups {
        my ($class, $groups, $gid);
        $class = shift;
        $groups = shift;
        foreach $gid (@$groups) {
                WebGUI::SQL->write("delete from groupings where groupId=$gid and userId=$class->{_userId}");
        }
        WebGUI::SQL->write("update users set lastUpdated=".time()." where userId=".$class->{_userId});
}

#-------------------------------------------------------------------

=head2 identifier ( [ value ] )

 Returns the password for this user.

=item value

 If specified, the identifier is set to this value. 

=cut

sub identifier {
        my ($class, $value);
        $class = shift;
        $value = shift;
        if (defined $value) {
                $class->{_user}{"identifier"} = $value;
                WebGUI::SQL->write("update users set identifier=".quote($value).",
                        lastUpdated=".time()." where userId=$class->{_userId}");
        }
        return $class->{_user}{"identifier"};
}

#-------------------------------------------------------------------

=head2 karma ( amount, source, description )

 Returns the current level of karma this user has earned. 

=item amount

 An integer to modify this user's karma by. Note that this number can
 be positive or negative.

=item source

 A descriptive source for this karma. Typically it would be something
 like "MessageBoard (49)" or "Admin (3)". Source is used to track
 where a karma modification came from.

=item description

 A description of why this user's karma was modified. For instance it
 could be "Message Board Post" or "He was a good boy!".

=cut

sub karma {
	if (defined $_[1] && defined $_[2] && defined $_[3]) {
		WebGUI::SQL->write("update users set karma=karma+$_[1] where userId=".$_[0]->userId);
        	WebGUI::SQL->write("insert into karmaLog values (".$_[0]->userId.",$_[1],".quote($_[2]).",".quote($_[3]).",".time().")");
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

=head2 ldapURL ( [ value ] )

 Returns the LDAP URL for this user.

=item value

 If specified, the ldapURL is set to this value.

=cut

sub ldapURL {
        my ($class, $value);
        $class = shift;
        $value = shift;
        if (defined $value) {
                $class->{_user}{"ldapURL"} = $value;
                WebGUI::SQL->write("update users set ldapURL=".quote($value).", lastUpdated=".time()." where userId=$class->{_userId}");
        }
        return $class->{_user}{"ldapURL"};
}

#-------------------------------------------------------------------

=head2 new ( userId )

 Constructor.

=item userId 

 The userId of the user you're creating an object reference for. If
 left blank it will default to "1" (Visitor). If specified as "new"
 then a new user account will be created and assigned the next
 available userId.

=cut

sub new {
        my ($class, $userId, %default, $value, $key, %user, %profile);
	tie %user, 'Tie::CPHash';
        $class = shift;
        $userId = shift || 1;
	$userId = _create() if ($userId eq "new");
	%user = WebGUI::SQL->quickHash("select * from users where userId='$userId'");
	%profile = WebGUI::SQL->buildHash("select userProfileField.fieldName, userProfileData.fieldData 
		from userProfileField, userProfileData where userProfileField.fieldName=userProfileData.fieldName and 
		userProfileData.userId='$user{userId}'");
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

 Returns a profile field's value. If "value" is specified, it also
 sets the field to that value. 

=item fieldName 

 The profile field name such as "language" or "email" or 
 "cellPhone".

=item value

 The value to set the profile field name to.

=cut

sub profileField {
        my ($class, $fieldName, $value);
	$class = shift;
        $fieldName = shift;
        $value = shift;
	if (defined $value) {
		$class->{_profile}{$fieldName} = $value;
		WebGUI::SQL->write("delete from userProfileData where userId=$class->{_userId} and fieldName=".quote($fieldName));
		WebGUI::SQL->write("insert into userProfileData values ($class->{_userId}, ".quote($fieldName).", ".quote($value).")");
        	WebGUI::SQL->write("update users set lastUpdated=".time()." where userId=".$class->{_userId});
	}
	return $class->{_profile}{$fieldName};
}

#-------------------------------------------------------------------

=head2 username ( [ value ] )

 Returns the username. 

=item value

 If specified, the username is set to this value. 

=cut

sub username {
        my ($class, $value);
        $class = shift;
        $value = shift;
        if (defined $value) {
                $class->{_user}{"username"} = $value;
                WebGUI::SQL->write("update users set username=".quote($value).",
                        lastUpdated=".time()." where userId=$class->{_userId}");
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
