package WebGUI::Group;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2009 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use Tie::CPHash;
use WebGUI::LDAPLink;
use WebGUI::Macro;
use WebGUI::Utility;
use WebGUI::Pluggable;
use WebGUI::International;


=head1 NAME

Package WebGUI::Group

=head1 DESCRIPTION

This package provides an object-oriented way of managing WebGUI groups and groupings.

=head1 SYNOPSIS

 use WebGUI::Group;
 $g = WebGUI::Group->new($session,3); or  $g = WebGUI::Group->new($session,"new");
 $g = WebGUI::Group->find($session,"Registered Users");

 $boolean =    	$g->autoAdd(1);
 $boolean =    	$g->autoDelete(1);
 $epoch =     	$g->dateCreated;
 $integer =	$g->deleteOffset(14);
 $text =       	$g->description("Those really smart dudes.");
 $integer =	$g->expireNotify(1);
 $text =        $g->expireNotifyMessage("You're outta here!");
 $integer =	$g->expireNotifyOffset(-14);
 $integer =    	$g->expireOffset(360000);
 $integer =    	$g->getId;
 $boolean = 	$g->isEditable(1);
 $integer =   	$g->karmaThreshold(5000);
 $string =     	$g->ipFilter("10.;192.168.1.");
 $epoch =     	$g->lastUpdated;
 $string =     	$g->name("Nerds");
 $string =     	$g->scratchFilter("www_location=International;somesetting=1");
 $boolean = 	$g->showInForms(1);

 $g->addGroups(\@arr);
 $g->addUsers(\@arr, $expireOffset);
 $g->deleteGroups(\@arr);
 $g->deleteUsers(\@arr);
 $g->delete;

 $arrayRef = $group->getGroupsFor();
 $arrayRef = $self->session->user->getGroups($userId);
 $arrayRef = $group->getGroupsIn($recursive);
 $arrayRef = $group->getUsers();   ##WebGUI defined groups only
 $arrayRef = $group->getAllUsers();  ##All users in all groups in this group
 $boolean = $self->session->user->isInGroup($groupId);
 $boolean = $group->userIsAdmin($userId,$groupId);
 $epoch = $group->userGroupExpireDate($userId,$date);

=head1 METHODS

These methods are available from this class:

=cut


#-------------------------------------------------------------------
sub _create {
	my $self          = shift;
	my $override      = shift;
    my $noAdmin       = shift;
	$self->{_groupId} = $self->session->db->setRow("groups","groupId", $self->_defaults, $override);
	$self->addGroups([3]) unless ($noAdmin);
}


#-------------------------------------------------------------------
sub _defaults {
	my $self = shift;
	return {
		groupId=>"new",
		dateCreated=>time(),
		expireOffset=>314496000,
		karmaThreshold=>1000000000,
		groupName=>"New Group",
		expireNotifyOffset=>-14,
		deleteOffset=>14,
		expireNotify=>0,
		databaseLinkId=>0,
		groupCacheTimeout=>3600,
		lastUpdated=>time(),
		autoAdd=>0,
		autoDelete=>0,
		isEditable=>1,
		showInForms=>1,
        isAdHocMailGroup=>0,
		};
}


#-------------------------------------------------------------------

=head2 addGroups ( groups )

Adds groups to this group.

=head3 groups

An array reference containing the list of group ids to add.  Group Visitor may
not be added to any group.  Groups may not be added to themselves.

=cut

sub addGroups {
	my $self = shift;
	my $groups = shift;
	WebGUI::Cache->new($self->session, $self->getId)->delete;
	GROUP: foreach my $gid (@{$groups}) {
		next if ($gid eq '1');
		next if ($gid eq $self->getId);
		my ($isIn) = $self->session->db->quickArray("select count(*) from groupGroupings where groupId=? and inGroup=?", [$gid, $self->getId]);
        next GROUP if $isIn;
		my $group = WebGUI::Group->new($self->session, $gid);
		my $recursive = isIn($self->getId, @{$group->getGroupsIn(1)});
        next GROUP if $recursive;
        $self->session->db->write("insert into groupGroupings (groupId,inGroup) values (?,?)",[$gid, $self->getId]);
	}
	$self->clearCaches();
	return 1;
}


#-------------------------------------------------------------------

=head2 addUsers ( users [, expireOffset ] )

Adds users to this group.  If a user is already a member of a group, their expiration date
is updated.

=head3 users 

An array reference containing a list of userIds.

=head3 expireOffset

An override for the default offset of the grouping. Specified in seconds.

=cut

sub addUsers {
	my $self = shift;
	my $users = shift;
	$self->clearCaches();
	my $expireOffset = shift || $self->get("expireOffset");
	foreach my $uid (@{$users}) {
		my ($isIn) = $self->session->db->quickArray("select count(*) from groupings where groupId=? and userId=?", [$self->getId, $uid]);
		unless ($isIn) {
			$self->session->db->write("insert into groupings (groupId,userId,expireDate) values (?,?,?)", [$self->getId, $uid, (time()+$expireOffset)]);
			$self->session->stow->delete("gotGroupsForUser");
		} else {
			$self->userGroupExpireDate($uid,(time()+$expireOffset));
		}
	}
}

#-------------------------------------------------------------------

=head2 autoAdd ( [ value ] )

Returns an boolean stating whether users can add themselves to this group.

=head3 value

If specified, the autoAdd is set to this value.

=cut

sub autoAdd {
        my $self = shift;
        my $value = shift;
        if (defined $value) {
		$self->set("autoAdd",$value);
        }
        return $self->get("autoAdd");
}


#-------------------------------------------------------------------

=head2 autoDelete ( [ value ] )

Returns an boolean stating whether users can delete themselves from this group.

=head3 value

If specified, the autoDelete is set to this value.

=cut

sub autoDelete {
        my $self = shift;
        my $value = shift;
        if (defined $value) {
		$self->set("autoDelete",$value);
        }
        return $self->get("autoDelete");
}


#-------------------------------------------------------------------

=head2 clearCaches ( )

Clears all caches for this group and any ancestor groups of the group.

=cut

sub clearCaches {
	my $self = shift;
	##Clear my cache and the cache of all groups above me.
	my $groups = $self->getAllGroupsFor();
	foreach my $group ( $self->getId, @{ $groups } ) {
		WebGUI::Cache->new($self->session, $group)->delete;
	}
	$self->session->stow->delete("groupObj");
	$self->session->stow->delete("isInGroup");
	$self->session->stow->delete("gotGroupsInGroup");
}

#-------------------------------------------------------------------

=head2 dateCreated ( )

Returns the epoch for when this group was created.

=cut

sub dateCreated {
	my $self = shift;
        return $self->get("dateCreated");
}


#-------------------------------------------------------------------

=head2 delete ( )

Deletes this group from the group related tables in the database and calls clearCaches.

=cut

sub delete {
    my $self = shift;
    $self->resetGroupFields;
    $self->clearCaches;
    $self->session->db->write("delete from groups where groupId=?", [$self->getId]);
    $self->session->db->write("delete from groupings where groupId=?", [$self->getId]);
    $self->session->db->write("delete from groupGroupings where inGroup=? or groupId=?", [$self->getId, $self->getId]);
    undef $self;
}

#-------------------------------------------------------------------

=head2 deleteGroups ( groups )

Deletes groups from this group.

=head3 groups

An array reference containing the list of group ids to delete.

=head3 fromGroups 

An array reference containing the list of group ids to delete from.

=cut

sub deleteGroups {
	my $self = shift;
	my $groups = shift;
	$self->clearCaches;
        foreach my $gid (@{$groups}) {
        	$self->session->db->write("delete from groupGroupings where groupId=? and inGroup=?",[$gid, $self->getId]);
        }
}


#-------------------------------------------------------------------

=head2 deleteUsers ( users )

Deletes a list of users from the specified groups.

=head3 users

An array reference containing a list of users.

=cut

sub deleteUsers {
	my $self = shift;
	my $users = shift;
	$self->clearCaches;
	foreach my $uid (@{$users}) {
               	$self->session->db->write("delete from groupings where groupId=? and userId=?",[$self->getId, $uid]);
	}
}

#-------------------------------------------------------------------

=head2 deleteOffset ( [ value ] )

Returns the number of seconds after the expiration to delete the grouping.

=head3 value

If specified, deleteOffset is set to this value. Defaults to "-14".

=cut

sub deleteOffset {
        my $self = shift;
        my $value = shift;
        if (defined $value) {
                $self->set("deleteOffset",$value);
        }
        return $self->get("deleteOffset");
}


#-------------------------------------------------------------------

=head2 description ( [ value ] )

Returns the description of this group.

=head3 value

If specified, the description is set to this value.

=cut

sub description {
        my $self = shift;
        my $value = shift;
        if (defined $value) {
		$self->set("description",$value);
        }
        return $self->get("description");
}


#-------------------------------------------------------------------

=head2 DESTROY

Desconstructor

=cut

sub DESTROY {
        my $self = shift;
        undef $self;
}


#-------------------------------------------------------------------

=head2 expireNotify ( [ value ] )

Returns a boolean value whether or not to notify the user of the group expiry.

=head3 value

If specified, expireNotify is set to this value.

=cut

sub expireNotify {
        my $self = shift;
        my $value = shift;
        if (defined $value) {
                $self->set("expireNotify", $value);
        }
        return $self->get("expireNotify");
}


#-------------------------------------------------------------------

=head2 expireNotifyMessage ( [ value ] )

Returns the message to send to the user about expiration.

=head3 value

If specified, expireNotifyMessage is set to this value.

=cut

sub expireNotifyMessage {
        my $self = shift;
        my $value = shift;
        if (defined $value) {
		$self->set("expireNotifyMessage",$value);
        }
        return $self->get("expireNotifyMessage");
}



#-------------------------------------------------------------------

=head2 expireNotifyOffset ( [ value ] )

Returns the number of seconds after the expiration to notify the user.

=head3 value

If specified, expireNotifyOffset is set to this value. 

=cut

sub expireNotifyOffset {
        my $self = shift;
        my $value = shift;
        if (defined $value) {
		$self->set("expireNotifyOffset",$value);
        }
        return $self->get("expireNotifyOffset");
}


#-------------------------------------------------------------------

=head2 expireOffset ( [ value ] )

Returns the number of seconds any grouping with this group should expire after.

=head3 value

If specified, expireOffset is set to this value.

=cut

sub expireOffset {
        my $self = shift;
        my $value = shift;
        if (defined $value) {
		$self->set("expireOffset",$value);
        }
        return $self->get("expireOffset");
}


#-------------------------------------------------------------------

=head2 find ( session, name )

An alternative to the constructor "new", use find as a constructor by name rather than id.
Returns the first group with that name found.  There is no guaranteed order of the search
to be sure not to create groups with the same name!

If the name of the group cannot be found, a new group will not be created.  This is
due to how the constructor new handles the null id.

=head3 session

A reference to the current session.

=head3 name

The name of the group you wish to instantiate.

=cut

sub find {
	my $class = shift;
	my $session = shift;
	my $name = shift;
	my ($groupId) = $session->db->quickArray("select groupId from groups where groupName=?",[$name]);
	return WebGUI::Group->new($session,$groupId);
}


#-------------------------------------------------------------------

=head2 get ( name ) 

Returns the value the specified property.

=head3 name

The name of the property to retrieve.

=cut

sub get {
	my $self = shift;	
	my $name = shift;
	unless ($self->{_group}) {
		$self->{_group} = $self->session->db->getRow("groups","groupId",$self->getId);
	}
	return $self->{_group}{$name};
}



#-------------------------------------------------------------------

=head2 getAllGroupsFor ( )

Returns an array reference containing a list of all groups this group is in, recursively.

=cut

sub getAllGroupsFor {
	my $self = shift;
	my $groups = $self->getGroupsFor();
	foreach my $gid (@{ $groups }) {
        my $group = WebGUI::Group->new($self->session, $gid);
        if ($group) {
		    push @{ $groups }, @{ $group->getAllGroupsFor() };
        }
    }
	my %unique = map { $_ => 1 } @{ $groups };
	$groups = [ keys %unique ];
	return $groups;
}

#-------------------------------------------------------------------

=head2 getAllUsers ( [ withoutExpired ] )

Returns an array reference containing a list of users that belong to this group
and in any group that belongs to this group.  The list is unique, so that each
userId is only in it one time.

=head3 withoutExpired

A boolean that if set true will return the users list minus the expired groupings.

=cut

sub getAllUsers {
	my $self = shift;
	my $withoutExpired = shift;
	my $loopCount = shift;
	my $expireTime = 0;
	my $cache = WebGUI::Cache->new($self->session, $self->getId);
	my $value = $cache->get;
	return $value if defined $value;
	my @users = ();
	push @users,
		@{ $self->getUsers($withoutExpired) },
		@{ $self->getDatabaseUsers() },
		@{ $self->getLDAPUsers() },
		@{ $self->getKarmaUsers() },
		@{ $self->getScratchUsers() },
		@{ $self->getIpUsers() },
	;
	++$loopCount;
	if ($loopCount > 99) {
		$self->session->errorHandler->fatal("Endless recursive loop detected while determining groups in group.\nRequested groupId: ".$self->getId);
	}
	my $groups = $self->getGroupsIn();
	foreach my $groupId (@{ $groups }) {
		my $subGroup = WebGUI::Group->new($self->session, $groupId);
        next
            if !$subGroup;
        push @users, @{ $subGroup->getAllUsers($withoutExpired, $loopCount) };
	}
	my %users = map { $_ => 1 } @users;
	@users = keys %users;
	$cache->set(\@users, $self->groupCacheTimeout);
	return \@users;
}


#-------------------------------------------------------------------

=head2 getDatabaseUsers ( )

Get the set of users allowed to be in this group via a database query.  Returns an array ref
of WebGUI userIds.

=cut

sub getDatabaseUsers {
	my $self = shift;
	my @dbUsers = ();
	my $gid = $self->getId;
        ### Check db database
        if ($self->get("dbQuery") && defined $self->get("databaseLinkId")) {
		my $dbLink = WebGUI::DatabaseLink->new($self->session,$self->get("databaseLinkId"));
		if (defined $dbLink) {
			my $dbh = $dbLink->db ;
			if (defined $dbh) {
				my $query = $self->get("dbQuery");
				WebGUI::Macro::process($self->session,\$query);
				my $sth = $dbh->unconditionalRead($query);
				if (defined $sth) {
					unless ($sth->errorCode < 1) {
						$self->session->errorHandler->warn("There was a problem with the database query for group ID $gid.");
					} else {
						while(my ($userId)=$sth->array) {
							push @dbUsers, $userId;
						}
					}
					$sth->finish;
				} else {
					$self->session->errorHandler->error("Couldn't process unconditional read for database group with group id $gid.");
				}
				$dbLink->disconnect;
       	 	        }
		} else {
			$self->session->errorHandler->warn("The database link ".$self->get("databaseLinkId")." no longer exists even though group ".$gid." references it.");
		}
        }
	return \@dbUsers;
}

#-------------------------------------------------------------------

=head2 getGroupsFor ( )

Returns an array reference containing a list of groups this group is in.  This method
does not check recursively backwards up the list of groups.

=cut

sub getGroupsFor {
	my $self = shift;
	return $self->session->db->buildArrayRef("select inGroup from groupGroupings where groupId=?",[$self->getId]);
}


#-------------------------------------------------------------------

=head2 getGroupsIn ( [ recursive , loopCount ] )

Returns an array reference containing a list of groups that belong to this group.

=head3 recursive

A boolean value to determine whether the method should return the groups directly in the group, or to follow the entire groups of groups hierarchy. Defaults to "0".

=head3 loopCount

This is the loop counter for recursive group checks.  You probably should
not ever manually set this.

=cut

sub getGroupsIn {
	my $self = shift;
        my $isRecursive = shift;
        my $loopCount = shift;
	my $gotGroupsInGroup = $self->session->stow->get("gotGroupsInGroup");
	if ($isRecursive && exists($gotGroupsInGroup->{recursive}{$self->getId})) {
		return $gotGroupsInGroup->{recursive}{$self->getId};
	}
	elsif (!$isRecursive and exists($gotGroupsInGroup->{direct}{$self->getId})) {
		return $gotGroupsInGroup->{direct}{$self->getId};
	}
	##We call updateUsers here because we get a free trip with recursion and many other User and Group
	##methods call getGroupsIn.
        my $groups = $self->session->db->buildArrayRef("select groupId from groupGroupings where inGroup=?",[$self->getId]);
        if ($isRecursive) {
                $loopCount++;
                if ($loopCount > 99) {
                        $self->session->errorHandler->fatal("Endless recursive loop detected while determining groups in group.\nRequested groupId: ".$self->getId."\nGroups in that group: ".join(",",@$groups));
                }
                my @groupsOfGroups = @$groups;
                foreach my $group (@$groups) {
                        my $gog = WebGUI::Group->new($self->session,$group)->getGroupsIn(1,$loopCount);
                        push(@groupsOfGroups, @$gog);
                }
		my %unique = map { $_ => 1 } @groupsOfGroups;
		@groupsOfGroups = keys %unique;
		$gotGroupsInGroup->{recursive}{$self->getId} = \@groupsOfGroups;
		$self->session->stow->set("gotGroupsInGroup", $gotGroupsInGroup);
                return \@groupsOfGroups;
	}
	$gotGroupsInGroup->{direct}{$self->getId} = $groups;
	$self->session->stow->set("gotGroupsInGroup",$gotGroupsInGroup);
        return $groups;
}


#-------------------------------------------------------------------

=head2 getId ( )

Returns the groupId for this group.

=cut

sub getId {
	my $self = shift;
        return $self->{_groupId};
}


#-------------------------------------------------------------------

=head2 getIpUsers ( )

Get the set of users allowed to be in this group via the lastIP recorded in
the user's session and this group's IpFilter.  The set is returned as an array ref.

If no IpFilter has been set for this group, returns an empty array ref.

=cut

sub getIpUsers {
	my $self = shift;
	my $IpFilter;
	return [] unless $IpFilter = $self->ipFilter();

	my $time = time();

	$IpFilter =~ s/\s//g;
	my @filters = split /;/, $IpFilter;

	my $query = "select userId,lastIP from userSession where expires > ?";

	my $sth = $self->session->db->read($query, [ time() ]);
	my %localCache = ();
	my @ipUsers = ();
	while (my ($userId, $lastIP) = $sth->array() ) {
		if (!exists $localCache{$lastIP}) {
			$localCache{$lastIP} = isInSubnet($lastIP, \@filters);	
		}
		push @ipUsers, $userId if $localCache{$lastIP};
	}
	return \@ipUsers;
}	


#-------------------------------------------------------------------

=head2 getKarmaUsers ( )

Get the set of users allowed to be in this group via their current karma setting
and this group's karmaThreshold.  The set is returned as an array ref.

If karma is not enabled for this site, it will return a empty array ref.

=cut

sub getKarmaUsers {
	my $self = shift;
	return [] unless $self->session->setting->get('useKarma');
	return $self->session->db->buildArrayRef('select userId from users where karma >= ?', [$self->karmaThreshold]);
}

#-------------------------------------------------------------------

=head2 getLDAPUsers ( )

Get the set of users allowed to be in this group via an LDAP connection.

=cut

sub getLDAPUsers {
	my $self = shift;
	my @ldapUsers = ();
	my $gid = $self->getId;
	### Check LDAP
	my $ldapLinkId = $self->get("ldapLinkId");
	my $ldapGroup = $self->get("ldapGroup");
	my $ldapGroupProperty = $self->get("ldapGroupProperty");
    my $ldapRecursiveProperty = $self->get("ldapRecursiveProperty");
	my $ldapRecurseFilter = $self->get("ldapRecursiveFilter");
	
	return [] unless ($ldapLinkId && $ldapGroup && $ldapGroupProperty);
	
	my $ldapLink = WebGUI::LDAPLink->new($self->session,$ldapLinkId);
	unless ($ldapLink && $ldapLink->bind) {
	   $self->session->errorHandler->warn("There was a problem connecting to LDAP link $ldapLinkId for group ID $gid.");
	   return [];
	}
	
	my $people = [];
	if($ldapRecursiveProperty) {
	   $ldapLink->recurseProperty($ldapGroup,$people,$ldapGroupProperty,$ldapRecursiveProperty,$ldapRecurseFilter);
	} else {
	   $people = $ldapLink->getProperty($ldapGroup,$ldapGroupProperty);
	}
	$ldapLink->unbind;
    
	foreach my $person (@{$people}) {
	   $person =~ s/\s*,\s*/,/g;
	   $person = lc($person);
	   my $personRegExp = "^uid=$person,";
	   
	   my ($userId) = $self->session->db->quickArray("select userId from authentication where authMethod='LDAP' and fieldName='connectDN' and lower(fieldData) = ? OR lower(fieldData) REGEXP ?",[$person,$personRegExp]);
	   
	   if($userId) {
	      push(@ldapUsers,$userId);
	   } else {
	      $self->session->errorHandler->warn("Could not find matching userId for dn/uid $person in WebGUI for group $gid");
	   }
	}
	
	return \@ldapUsers;
}	

#-------------------------------------------------------------------

=head2 getScratchUsers ( )

Get the set of users allowed to be in this group via session scratch variable settings
and this group's scratchFilter.  The set is returned as an array ref.

If no scratchFilter has been set for this group, returns an empty array ref.

=cut

sub getScratchUsers {
	my $self = shift;
	my $scratchFilter;
	return [] unless $scratchFilter = $self->scratchFilter();

	my $time = time();

	$scratchFilter =~ s/\s//g;
	my @filters = split /;/, $scratchFilter;

	my @scratchClauses = ();
	my @scratchPlaceholders = ();
	foreach my $filter (@filters) {
		my ($name, $value) = split /=/, $filter;
		push @scratchClauses, "(s.name=? AND s.value=?)";
		push @scratchPlaceholders, $name, $value;
	}
	my $scratchClause = join ' OR ', @scratchClauses;

	my $query = <<EOQ;
select u.userId from userSession u, userSessionScratch s where
u.sessionId=s.sessionId AND
u.expires > $time AND
	( $scratchClause )
EOQ
	return $self->session->db->buildArrayRef($query, [ @scratchPlaceholders ]);
}

#-------------------------------------------------------------------

=head2 getUserList ( [ withoutExpired ] )

Returns a hash reference with key of userId and value of username for users in the group, sorted by username.

=head3 withoutExpired

A boolean that if set to true will return only the groups that the user is in where
their membership hasn't expired.

=cut

sub getUserList {
	my $self = shift;
	my $withoutExpired = shift;
	my $expireTime = 0;
	if ($withoutExpired) {
		$expireTime = time();
	}
	return $self->session->db->buildHashRef("select users.userId, users.username from users join groupings using(userId) where expireDate > ? and groupId = ? order by username asc", [$expireTime, $self->getId]);
}

#-------------------------------------------------------------------

=head2 getUsers ( [ withoutExpired ] )

Returns an array reference containing a list of users that have been added
to this WebGUI group directly, rather than by other methods of group membership
like IP address, LDAP, dbQuery or scratchFilter.

=head3 withoutExpired

A boolean that if set to true will return only the groups that the user is in where
their membership hasn't expired.

=cut

sub getUsers {
	my $self = shift;
	my $withoutExpired = shift;
	my $expireTime = 0;
	if ($withoutExpired) {
		$expireTime = time();
	}
	my @users = $self->session->db->buildArray("select userId from groupings where expireDate > ? and groupId = ?", [$expireTime, $self->getId]);
	return \@users;
}

#-------------------------------------------------------------------

=head2 getUsersNotIn ( group [,withoutExpired])

Returns an array reference containing a list of all of the users that are in this group
and are not in the group passed in

=head3 groupId

groupId to check the users in this group against.

=head3 withoutExpired

A boolean that if set to true will return only the groups that the user is in where
their membership hasn't expired.

=cut

sub getUsersNotIn {
	my $self           = shift;
    my $groupId        = shift;
	my $withoutExpired = shift;

    if($groupId eq "") {
        return $self->getUsers($withoutExpired);
    }
	
    my $expireTime = 0;
	if ($withoutExpired) {
		$expireTime = time();
	}

    my $sql = q{
        select
            userId
        from
            groupings
        where
            expireDate > ?
            and groupId=?
            and userId not in (select userId from groupings where expireDate > ? and groupId=?)
    };

	my @users = $self->session->db->buildArray($sql, [$expireTime,$self->getId,$expireTime,$groupId]);
	return \@users;

}



#-------------------------------------------------------------------

=head2 karmaThreshold ( [ value ] )

Returns the amount of karma required to be in this group.

=head3 value

If specified, the karma threshold is set to this value.

=cut

sub karmaThreshold {
        my $self = shift;
        my $value = shift;
        if (defined $value) {
		$self->set("karmaThreshold",$value);	
        }
        return $self->get("karmaThreshold");
}

#-------------------------------------------------------------------

=head2 isAdHocMailGroup ( [ value ] )

Returns a boolean value indicating whether the group is flagged as an AdHoc Mail Group or not.
AdHoc Mail Groups are automatically deleted once the mail they are associated to has been sent.

=head3 value

If specified, isAdHocMailGroup is set to this value.

=cut

sub isAdHocMailGroup {
    my $self  = shift;
    my $value = shift;
    if (defined $value) {
        $self->set("isAdHocMailGroup",$value);
    }
    return $self->get("isAdHocMailGroup");
}

#-------------------------------------------------------------------

=head2 ipFilter ( [ value ] )

Returns the ip address range(s) the user must be a part of to belong to this group.

=head3 value

If specified, the ipFilter is set to this value.

=cut

sub ipFilter {
        my $self = shift;
        my $value = shift;
        if (defined $value) {
		$self->set("ipFilter",$value);
        }
        return $self->get("ipFilter");
}


#-------------------------------------------------------------------

=head2 isEditable ( [ value ] )

Returns a boolean value indicating whether the group should be managable from the group manager. System level groups and groups autocreated by wobjects would use this parameter.

=head3 value

If specified, isEditable is set to this value.

=cut

sub isEditable {
        my $self = shift;
        my $value = shift;
        if (defined $value) {
                $self->set("isEditable",$value);
        }
        return $self->get("isEditable");
}


#-------------------------------------------------------------------

=head2 lastUpdated ( )

Returns the epoch for when this group was last modified.

=cut

sub lastUpdated {
	my $self = shift;
        return $self->get("lastUpdated");
}


#-------------------------------------------------------------------

=head2 name ( [ value ] )

Returns the name of this group.

=head3 value

If specified, the name is set to this value.

=cut

sub name {
        my $self = shift;
        my $value = shift;
        if (defined $value) {
                $self->set("groupName",$value);
        }
        return $self->get("groupName");
}

#-------------------------------------------------------------------

=head2 new ( session, groupId [, overrideId, noAdmin ] )

Constructor.

=head3 session

A reference to the current session.

=head3 groupId

The groupId of the group you're creating an object reference for. If specified as "new" then a new group will be created and assigned a new random groupId. If left blank then the object methods will just return default values for everything.

=head3 overrideId

If you specified "new" for groupId, you can use this property to specify an id you wish to create, rather than having the system generate one for you.

=head3 noAdmin

If you specified "new" for groupId, you can use this property to specify that you do not wish the admin user or group to be added to the group

=cut

sub new {
   	my $self = {};
    
    my $class           = shift;
    $self->{_session}   = shift;
	$self->{_groupId}   = shift;
	my $override        = shift;
    my $noAdmin         = shift;
    my $session         = $self->{_session};

    my $cached = $session->stow->get("groupObj", { noclone => 1});
	return $cached->{$self->{_groupId}} if ($cached->{$self->{_groupId}});

	bless $self, $class;
        if ($self->{_groupId} eq "new") {
		$self->_create($override,$noAdmin);
	}
	elsif ($self->{_groupId} eq "") {
		$self->{_group} = $self->_defaults();
	}
    else {
        # Check if the groupId is valid. If not return undef
        my ($groupExists) = $session->db->quickArray('select groupId from groups where groupId=?', [
            $self->{_groupId},
        ]);
        unless ($groupExists) {
            $session->errorHandler->warn('WebGUI::Group->new called with a non-existant groupId:'
                .'['.$self->{_groupId}.']');
            return undef;
        }
    }

	$cached->{$self->{_groupId}} = $self;
	$session->stow->set("groupObj", $cached);
	return $self;
}


#-------------------------------------------------------------------

=head2 resetGroupFields (  )

Looks through WebGUI and resets any group field that it can find, that uses this group,
to the admin group, 3.  Called internally by delete.

Currently handes these areas:

=over 4

=item *

Anything in an Asset definition that is labeled as type group.  JSON data is not handled.

=item *

Everything in Operation/Settings, from its definition subroutine.

=item *

Settings fields hand picked from Shop/Admin and Account/FriendManager.

=item *

Any Workflow Activity data from the definition that is labeled as type group.

=back

=cut

sub resetGroupFields {
    my $self    = shift;
    my $gid     = $self->getId;
    my $session = $self->session;
    my $db      = $session->db;
    my $config  = $session->config;
    my $assets  = $config->get('assets');
    my $tableCache = {};

    ##Note, I did assets in SQL instead of using the API because you would have to
    ##instanciate every version of the asset that used the group.  This should be much quicker
    ASSET: foreach my $asset (keys %{ $assets }) {
        my $definition = WebGUI::Pluggable::instanciate($asset, 'definition', [$session]);
        SUBDEF: foreach my $subdef (@{ $definition }) {
            next SUBDEF if exists $tableCache->{$subdef->{tableName}}; 
            PROP: while (my ($fieldName, $properties) = each %{ $subdef->{properties} }) {
                next PROP unless $properties->{fieldType} eq 'group';
                push @{ $tableCache->{$subdef->{tableName}} }, $fieldName;
            }
        }
    }
    ##VersionTags
    $tableCache->{assetVersionTag} = ['groupToUse'];
    foreach my $tableName (keys %{ $tableCache }) {
        foreach my $fieldName (@{ $tableCache->{$tableName} }) {
            my $sql = sprintf 'UPDATE %s SET %s=3 where %s=?',
                $db->dbh->quote_identifier($tableName),
                (($db->dbh->quote_identifier($fieldName)) x 2);
            $db->write($sql, [ $gid ]);
        }
    }

    SETTINGS: {
        my $setting = $session->setting;
        my $i18n = WebGUI::International->new($session);
        my $definition = WebGUI::Pluggable::run('WebGUI::Operation::Settings', 'definition', [$session, $i18n]);
        FIELD: foreach my $field (@{ $definition }) {
            next FIELD unless $field->{fieldType} eq 'group'
                          and $setting->get($field->{name}) eq $gid;
            $setting->set($field->{name}, 3);
        }
    }
    ##Settings in the settings table not from Operation/Settings.  These should all
    ##be moved to definition style subroutines for future auto-probing.
    AUX_SETTINGS: {
        ##These are extra fields 
        my $setting = $session->setting;
        my @extraFields = qw/groupIdCashier groupIdAdminCommerce/;  ##Shop/Admin
        push @extraFields, qw/groupIdAdminFriends groupsToManageFriends/; ##Account/FriendManager
        FIELD: foreach my $field (@extraFields) {
            next FIELD unless $setting->get($field) eq $gid;
            $setting->set($field, 3);
        }
    }
    ACTIVITY: {
        my $workflowActivities = $config->get('workflowActivities');
        my @activities;
        foreach my $wfActivities (values %{ $workflowActivities} ) {
            push @activities, @{ $wfActivities };
        }
        foreach my $activity (@activities) {
            my $definition = WebGUI::Pluggable::instanciate($activity, 'definition', [$session]);
            my $sth = $db->prepare('UPDATE WorkflowActivityData set value=3 where name=? and value=?');
            SUBDEF: foreach my $subdef (@{ $definition }) {
                PROP: while (my ($fieldName, $properties) = each %{ $subdef->{properties} }) {
                    next PROP unless $properties->{fieldType} eq 'group';
                    $sth->execute([$fieldName, $gid]);
                }
            }
        }
    }
    ##Inbox messages, inbox table
    return 1;
}

#-------------------------------------------------------------------

=head2 scratchFilter ( [ value ] )

Returns the scratch value that should be set to automatically add this user
to a group.

=head3 value

If specified, the scratchFilter is set to this value.

=cut

sub scratchFilter {
        my $self = shift;
        my $value = shift;
        if (defined $value) {
                $self->set("scratchFilter",$value);
        }
        return $self->get("scratchFilter");
}

#-------------------------------------------------------------------

=head2 showInForms ( [ value ] )

Returns a boolean value indicating whether the group should show in forms that display a list of groups. System level groups and groups autocreated by wobjects would use this parameter.

=head3 value

If specified, showInForms is set to this value.

=cut

sub showInForms {
        my $self = shift;
        my $value = shift;
        if (defined $value) {
                $self->set("showInForms",$value);
        }
        return $self->get("showInForms");
}


#-------------------------------------------------------------------

=head2 dbQuery ( [ value ] )

Returns the dbQuery for this group.

=head3 value

If specified, the dbQuery is set to this value.

=cut

sub dbQuery {
        my $self = shift;
        my $value = shift;
        if (defined $value) {
                $self->set("dbQuery",$value);
        }
        return $self->get("dbQuery");
}

#-------------------------------------------------------------------

=head2 databaseLinkId ( [ value ] )

Returns the databaseLinkId for this group.

=head3 value

If specified, the databaseLinkId is set to this value and in-memory cached user and group data is cleared.

=cut

sub databaseLinkId {
        my $self = shift;
        my $value = shift;
        if (defined $value) {
                $self->set("databaseLinkId",$value);
        }
        return $self->get("databaseLinkId");
}

#-------------------------------------------------------------------

=head2 groupCacheTimeout ( [ value ] )

Returns the groupCacheTimeout for this group.

=head3 value

If specified, the groupCacheTimeout is set to this value.

=cut

sub groupCacheTimeout {
        my $self = shift;
        my $value = shift;
        if (defined $value) {
                $self->set("groupCacheTimeout",$value);
        }
        return $self->get("groupCacheTimeout");
}

#-------------------------------------------------------------------

=head2 ldapGroup ( [ value ] )

Returns the ldapGroup for this group.

=head3 value

If specified, the ldapGroup is set to this value.

=cut

sub ldapGroup {
        my $self = shift;
        my $value = shift;
        if (defined $value) {
           $self->set("ldapGroup",$value);
        }
        return $self->get("ldapGroup");
}

#-------------------------------------------------------------------

=head2 ldapGroupProperty ( [ value ] )

Returns the ldap group property for this group.

=head3 value

If specified, the ldapGroupProperty is set to this value.

=cut

sub ldapGroupProperty {
        my $self = shift;
        my $value = shift;
        if (defined $value) {
           $self->set("ldapGroupProperty", $value);
        }
        return $self->get("ldapGroupProperty");
}

#-------------------------------------------------------------------

=head2 ldapLinkId ( [ value ] )

Returns the ldapLinkId for this group.

=head3 value

If specified, the ldapLinkId is set to this value and in-memory cached user and group data is cleared.

=cut

sub ldapLinkId {
   my $self = shift;
   my $value = shift;
   if (defined $value) {
      $self->set("ldapLinkId",$value);
   }
   return $self->get("ldapLinkId");
}

#-------------------------------------------------------------------

=head2 ldapRecursiveProperty ( [ value ] )

Returns the ldap group recursive property used to find groups of groups.

=head3 value

If specified, the ldapRecursiveProperty is set to this value.

=cut

sub ldapRecursiveProperty {
   	my $self = shift;
   	my $value = shift;
   	if (defined $value) {
      		$self->set("ldapRecursiveProperty",$value);
   	}
   	return $self->get("ldapRecursiveProperty");
}

#-------------------------------------------------------------------

=head2 ldapRecursiveFilter ( [ value ] )

Returns the ldap group recursive filter used to filter out entries that aren't groups from the groups of groups attribute.

=head3 value

If specified, the ldapRecursiveFilter is set to this value.

=cut

sub ldapRecursiveFilter {
   	my $self = shift;
   	my $value = shift;
   	if (defined $value) {
      		$self->set("ldapRecursiveFilter",$value);
   	}
   	return $self->get("ldapRecursiveFilter");
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

=head2 set ( name, value )

Sets a property of this group.

=head3 name

The name of a property to set.

=head3 value

The value of a property to set.

=cut

sub set {
	my $self = shift;
	my $name = shift;
	my $value = shift;
	$self->get("groupId") unless ($self->{_group}); # precache group stuff
	$self->{_group}{$name} = $value;
	$self->session->db->setRow("groups","groupId",{groupId=>$self->getId, $name=>$value, lastUpdated=>time()});
	$self->clearCaches;
}

#-------------------------------------------------------------------

=head2 userIsAdmin ( [ userId, value ] )

Sets or returns $userid's status as a group admin in this group.

=head3 userId

A guid that is the unique identifier for a user. Defaults to the currently logged in user.

=head3 value

If defined and not the empty string, the admin flag will be set to this value.  Otherwise,
returns 1 if the user has been set as a group admin and 0 if the user hasn't.

=cut

sub userIsAdmin {
	my $self = shift;
	my $userId = shift || $self->session->user->userId;
	my $value = shift;
	if ($value ne "") {
		$self->session->db->write("update groupings set groupAdmin=? where groupId=? and userId=?",[$value, $self->getId, $userId]);
		return $value;
	} else {
        my $user = WebGUI::User->new($self->session, $userId);
        return 1 if $user->isInGroup(3);
		my ($admin) = $self->session->db->quickArray("select groupAdmin from groupings where groupId=? and userId=?", [$self->getId, $userId]);
		return ($admin ? 1 : 0);
	}
}	

#-------------------------------------------------------------------

=head2 userGroupExpireDate ( userId [, epoch ] )

Returns the epoch date that this grouping will expire for a particular user.

=head3 userId

A guid that is the unique identifier for a user.

=head3 epoch

If specified the expire date will be set to this value.

=cut

sub userGroupExpireDate {
	my $self = shift;
	my $userId = shift;
	my $epoch = shift;
	if ($epoch) {
		$self->session->db->write("update groupings set expireDate=? where groupId=? and userId=?",[$epoch, $self->getId, $userId]);
		return $epoch;
	} else {
		my ($expireDate) = $self->session->db->quickArray("select expireDate from groupings where groupId=? and userId=?", [$self->getId, $userId]);
		return $expireDate;
	}
}	

#-------------------------------------------------------------------

=head2 vitalGroup ( [ $groupId ] )

Class or object method to check to see if a group is a reserved WebGUI group.
Returns true or false.  Placed in here because I found two different lists in two
different areas.

=head3 $groupId

A GUID of the group to check.  Optional if called on an object, and
will use the object's group ID instead

=cut

sub vitalGroup {
    my $class   = shift;
    my $groupId = shift;
    if (! $groupId && ref $class ) {
        $groupId = $class->getId;
    }
    return isIn ( $groupId, (1..17), qw/pbgroup000000000000015 pbgroup000000000000016 pbgroup000000000000017 / );
}

1;
