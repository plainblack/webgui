package WebGUI::User;

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
use WebGUI::Cache;
use WebGUI::Id;
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
 $arrayRef =  $u->getGroups;

 $u->addToGroups(\@arr);
 $u->deleteFromGroups(\@arr);
 $u->delete;

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------
sub _create {
	my $userId = shift || $self->session->id->generate();
	$self->session->db->write("insert into users (userId,dateCreated) values (".$self->session->db->quote($userId).","$self->session->datetime->time().")");
	require WebGUI::Grouping;
	$group->addUsers([$userId],[2,7]);
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
	$group->addUsers([$self->userId],$groups,$expireOffset);
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
                $self->{_user}{"lastUpdated"} =$self->session->datetime->time();
                $self->session->db->write("update users set authMethod=".$self->session->db->quote($value).",
			lastUpdated="$self->session->datetime->time()." where userId=".$self->session->db->quote($self->{_userId}));
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
        $self->session->db->write("delete from users where userId=".$self->session->db->quote($self->{_userId}));
        $self->session->db->write("delete from userProfileData where userId=".$self->session->db->quote($self->{_userId}));
	require WebGUI::Grouping;
	$group->deleteUsers([$self->{_userId}],$self->session->user->getGroups($self->{_userId}));
	$self->session->db->write("delete from messageLog where userId=".$self->session->db->quote($self->{_userId}));

	my $authMethod = WebGUI::Operation::Auth::getInstance($self->authMethod,$self->{_userId});
	$authMethod->deleteParams($self->{_userId});
    my $sth = $self->session->db->read("select sessionId from userSession where userId=".$self->session->db->quote($self->{_userId}));
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
	$group->deleteUsers([$self->userId],$groups);
}

#-------------------------------------------------------------------

=head2 getGroups ( [ withoutExpired ] )

Returns an array reference containing a list of groups this user is in.

=head3 withoutExpired

If set to "1" then the listing will not include expired groupings. Defaults to "0".

=cut

sub getGroups {
	my $self = shift;
        my $withoutExpired = shift;
        my $clause = "and expireDate>"$self->session->datetime->time() if ($withoutExpired);
	my $gotGroupsForUser = $self->session->stow->get("gotGroupsForUser");
        if (exists $gotGroupsForUser->{$self->userId}) {
                return $gotGroupsForUser->{$self->userId};
        } else {
                my @groups = $self->session->db->buildArray("select groupId from groupings where userId=".$self->session->db->quote($userId)." $clause");
		my $isInGroup = $self->session->stow("isInGroup");
                foreach my $gid (@groups) {	
                        $isInGroup->{$self->userId}{$gid} = 1;
                }
		$self->session->stow("isInGroup",$isInGroup);
                $gotGroupsForUser->{$userId} = \@groups;
		$self->session->stow("gotGroupsForUser",$gotGroupsForUser);
                return \@groups;
        }
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
                $self->session->db->write("update authentication set fieldData=".$self->session->db->quote($value)."
                        where userId=".$self->session->db->quote($self->{_userId})." and authMethod='WebGUI' and fieldName='identifier'");
        }
        return $self->{_user}{"identifier"};
}

#-------------------------------------------------------------------

=head2 isInGroup ( [ groupId ] )

Returns a boolean (0|1) value signifying that the user has the required privileges. Always returns true for Admins.

=head3 groupId

The group that you wish to verify against the user. Defaults to group with Id 3 (the Admin group).

=cut

sub isInGroup {
        my (@data, $groupId);
        my ($gid, $secondRun) = @_;
        $gid = 3 unless (defined $gid);
        $uid = $self->userId;
        ### The following several checks are to increase performance. If this section were removed, everything would continue to work as normal. 
        return 1 if ($gid eq '7');		# everyone is in the everyone group
        return 1 if ($gid eq '1' && $uid eq '1'); 	# visitors are in the visitors group
        return 0 if ($uid eq '1');  #Visitor is in no other groups
        return 1 if ($uid eq '3');  #Admin is in every group
        return 1 if ($gid eq '2' && $uid ne '1'); 	# if you're not a visitor, then you're a registered user
        ### Look to see if we've already looked up this group. 
	my $isInGroup = $self->session->stow->get("isInGroup");
        if ($isInGroup->{$uid}{$gid} eq '1') {
                return 1;
        } elsif ($isInGroup->{$uid}{$gid} eq "0") {
                return 0;
        }
        ### Lookup the actual groupings.
	unless ($secondRun) {			# don't look up user groups if we've already done it once.
	        my $groups = $self->getGroups(1);
	        foreach (@{$groups}) {
	                $isInGroup->{$uid}{$_} = 1;
        	}
        	if ($isInGroup->{$uid}{$gid} eq '1') {
			$self->session->stow->set("isInGroup",$isInGroup);
                	return 1;
        	}
	}
        ### Get data for auxillary checks.
	my $group = WebGUI::Group->new($gid);
        ### Check IP Address
        if ($group->get("ipFilter")) {
		my $ipFilter = $group->get("ipFilter");
                $ipFilter =~ s/\s//g;
                $ipFilter =~ s/\./\\\./g;
                my @ips = split(";",$ipFilter);
                foreach my $ip (@ips) {
                        if ($self->session->env->get("REMOTE_ADDR") =~ /^$ip/) {
                                $isInGroup->{$uid}{$gid} = 1;
				$self->session->stow->set("isInGroup",$isInGroup);
                                return 1;
                        }
                }
        }
        ### Check Scratch Variables 
        if ($group->get("scratchFilter")) {
		my $scratchFilter = $group->get("scratchFilter");
                $scratchFilter =~ s/\s//g;
                my @vars = split(";",$scratchFilter);
                foreach my $var (@vars) {
                        my ($name, $value) = split(/\=/,$var);
                        if ($self->session->scratch->get($name) eq $value) {
                                $isInGroup->{$uid}{$gid} = 1;
				$self->session->stow->set("isInGroup",$isInGroup);
                                return 1;
                        }
                }
        }
        ### Check karma levels.
        if ($self->session->setting->get("useKarma")) {
                if ($self->karma >= $group->get("karmaThreshold")) {
                        $isInGroup->{$uid}{$gid} = 1;
			$self->session->stow->set("isInGroup",$isInGroup);
                        return 1;
                }
        }
        ### Check external database
        if ($group->get("dbQuery") && $group->get("databaseLinkId")) {
                # skip if not logged in and query contains a User macro
                unless ($group->get("dbQuery") =~ /\^User/i && $uid eq '1') {
                        my $dbLink = WebGUI::DatabaseLink->new($self->session,$group->get("databaseLinkId"));
                        my $dbh = $dbLink->dbh;
                        if (defined $dbh) {
                                if ($group->get("dbQuery") =~ /select 1/i) {
					my $query = $group->group("dbQuery");
					WebGUI::Macro::process($self->session,\$query);
                                        my $sth = $dbh->unconditionalRead($query);
                                        unless ($sth->errorCode < 1) {
                                                $self->session->errorHandler->warn("There was a problem with the database query for group ID $gid.");
                                        } else {
                                                my ($result) = $sth->array;
                                                if ($result == 1) {
                                                        $isInGroup->{$uid}{$gid} = 1;
                                                        if ($group->get("dbCacheTimeout") > 0) {
                                                                $group->deleteUsers([$uid]);
                                                                $group->addUsers([$uid],$group->get("dbCacheTimeout"));
                                                        }
                                                } else {
                                                        $isInGroup->{$uid}{$gid} = 0;
                                                        $group->deleteUsers([$uid]) if ($group->get("dbCacheTimeout") > 0);
                                                }
                                        }
                                        $sth->finish;
                                } else {
                                        $self->session->errorHandler->warn("Database query for group ID $gid must use 'select 1'");
                                }
                                $dbLink->disconnect;
				$self->session->stow->set("isInGroup",$isInGroup);
                                return 1 if ($isInGroup->{$uid}{$gid});
                        }
                }
        }
	 ### Check ldap
        if ($group->get("ldapGroup") && $group->get("ldapGroupProperty")) {
		   # skip if not logged in
		   unless($uid eq '1') {
			  # skip if user is not set to LDAP
			  if($self->authMethod eq "LDAP") {
			     my $auth = WebGUI::Auth->new($session,"LDAP",$uid);
				 my $params = $auth->getParams();
				 my $ldapLink = WebGUI::LDAPLink->new($self->session,$session,$params->{ldapConnection});
				 if($ldapLink ne "") {
					my $people = [];
					if($group->get("ldapRecursiveProperty")) {
					   $ldapLink->recurseProperty($group->get("ldapGroup"),$people,$group->get("ldapGroupProperty"),$group->get("ldapRecursiveProperty"));
					} else {
					   $people = $ldapLink->getProperty($group->get("ldapGroup"),$group->get("ldapGroupProperty"));
					}
					 
				    if(isIn($params->{connectDN},@{$people})) {
					   $isInGroup->{$uid}{$gid} = 1;
                       if ($group{dbCacheTimeout} > 10) {
                          $group->deleteUsers([$uid]);
                          $group->addUsers([$uid],$group->get("dbCacheTimeout"));
                       }
					} else {
					   $isInGroup->{$uid}{$gid} = 0;
                       			   $group->deleteUsers([$uid]) if ($group->get("dbCacheTimeout") > 10);
					}
					$ldapLink->unbind;
					$self->session->stow->set("isInGroup",$isInGroup);
				    return 1 if ($isInGroup->{$uid}{$gid});
				 }
			  }
		   }
		}
		
        ### Check for groups of groups.
        my $groups = $group->getGroupsIn(1);
        foreach (@{$groups}) {
                $isInGroup->{$uid}{$_} = $self->isInGroup($_, 1);
                if ($isInGroup->{$uid}{$_}) {
                        $isInGroup->{$uid}{$gid} = 1; # cache current group also so we don't have to do the group in group check again
			$self->session->stow->set("isInGroup",$isInGroup);
                        return 1;
                }
        }
        $isInGroup->{$uid}{$gid} = 0;
	$self->session->stow->set("isInGroup",$isInGroup);
        return 0;
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
		$self->session->db->write("update users set karma=karma+".$self->session->db->quote($amount)." where userId=".$self->session->db->quote($self->userId));
        	$self->session->db->write("insert into karmaLog values (".$self->session->db->quote($self->userId).",$amount,".$self->session->db->quote($source).",".$self->session->db->quote($description).","$self->session->datetime->time().")");
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
	my $cache = WebGUI::Cache->new($self->session,["user",$userId]);
	my $userData = $cache->get;
	unless ($userData->{_userId} && $userData->{_user}{username}) {
		my %user;
		tie %user, 'Tie::CPHash';
		%user = $self->session->db->quickHash("select * from users where userId=".$self->session->db->quote($userId));
		my %profile = $self->session->db->buildHash("select userProfileField.fieldName, userProfileData.fieldData 
			from userProfileField, userProfileData where userProfileField.fieldName=userProfileData.fieldName and 
			userProfileData.userId=".$self->session->db->quote($user{userId}));
        	my %default = $self->session->db->buildHash("select fieldName, dataDefault from userProfileField");
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
		$profile{alias} = $user{username} if ($profile{alias} =~ /^\W+$/ || $profile{alias} eq "");
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
		$self->session->db->write("delete from userProfileData where userId=".$self->session->db->quote($self->{_userId})." and fieldName=".$self->session->db->quote($fieldName));
		$self->session->db->write("insert into userProfileData values (".$self->session->db->quote($self->{_userId}).", ".$self->session->db->quote($fieldName).", ".$self->session->db->quote($value).")");
		$self->{_user}{"lastUpdated"} =$self->session->datetime->time();
        	$self->session->db->write("update users set lastUpdated="$self->session->datetime->time()." where userId=".$self->session->db->quote($self->{_userId}));
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
                $self->{_user}{"lastUpdated"} =$self->session->datetime->time();
                $self->session->db->write("update users set referringAffiliate=".$self->session->db->quote($value).",
                        lastUpdated="$self->session->datetime->time()." where userId=".$self->session->db->quote($self->userId));
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
                $self->{_user}{"lastUpdated"} =$self->session->datetime->time();
                $self->session->db->write("update users set status=".$self->session->db->quote($value).",
                        lastUpdated="$self->session->datetime->time()." where userId=".$self->session->db->quote($self->userId));
        }
        return $self->{_user}{"status"};
}

#-------------------------------------------------------------------

=head2 uncache ( )

Deletes this user object out of the cache.

=cut

sub uncache {
	my $self = shift;
	my $cache = WebGUI::Cache->new($self->session,["user",$self->userId]);
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
                $self->{_user}{"lastUpdated"} =$self->session->datetime->time();
                $self->session->db->write("update users set username=".$self->session->db->quote($value).",
                        lastUpdated="$self->session->datetime->time()." where userId=".$self->session->db->quote($self->userId));
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
