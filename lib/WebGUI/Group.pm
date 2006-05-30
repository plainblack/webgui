package WebGUI::Group;

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
use Tie::CPHash;
use WebGUI::Auth;
use WebGUI::LDAPLink;
use WebGUI::Macro;
use WebGUI::Utility;


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
 $integer = 	$g->expireNotifyMessage("You're outta here!");
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
 $epoch = $group->userGroupExpireDate($userId,$groupId);

=head1 METHODS

These methods are available from this class:

=cut


#-------------------------------------------------------------------
sub _create {
	my $self = shift;
	my $override = shift;
	$self->{_groupId} = $self->session->db->setRow("groups","groupId",{
		groupId=>"new",
		dateCreated=>$self->session->datetime->time(),
		expireOffset=>314496000,
		karmaThreshold=>1000000000,
		groupName=>"New Group",
		expireNotifyOffset=>-14,
		deleteOffset=>14,
		expireNotify=>0,
		databaseLinkId=>0,
		groupCacheTimeout=>3600,
		lastUpdated=>$self->session->datetime->time()
		}, $override);
	$self->addGroups([3]);
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
	foreach my $gid (@{$groups}) {
		next if ($gid eq '1');
		next if ($gid eq $self->getId);
		my ($isIn) = $self->session->db->quickArray("select count(*) from groupGroupings where groupId=? and inGroup=?", [$gid, $self->getId]);
		my $group = WebGUI::Group->new($self->session, $gid);
		my $recursive = isIn($self->getId, @{$group->getGroupsIn(1)});
		unless ($isIn || $recursive) {
			$self->session->db->write("insert into groupGroupings (groupId,inGroup) values (?,?)",[$gid, $self->getId]);
		}
	}
	$self->clearCaches();
	return 1;
}


#-------------------------------------------------------------------

=head2 addUsers ( users [, expireOffset ] )

Adds users to this group.  If a user is already a member of a group, their expiration date
is updated.

=head3 users 

An array reference containing a list of users.

=head3 expireOffset

An override for the default offset of the grouping. Specified in seconds.

=cut

sub addUsers {
	my $self = shift;
	my $users = shift;
	$self->clearCaches();
	my $expireOffset = shift || $self->get("expireOffset");
	foreach my $uid (@{$users}) {
		next if ($uid eq '1' and !isIn($self->getId, 1, 7));
		my ($isIn) = $self->session->db->quickArray("select count(*) from groupings where groupId=? and userId=?", [$self->getId, $uid]);
		unless ($isIn) {
			$self->session->db->write("insert into groupings (groupId,userId,expireDate) values (?,?,?)", [$self->getId, $uid, ($self->session->datetime->time()+$expireOffset)]);
			$self->session->stow->delete("gotGroupsForUser");
		} else {
			$self->userGroupExpireDate($uid,($self->session->datetime->time()+$expireOffset));
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

Deletes this group and all references to it.

=cut

sub delete {
	my $self = shift;
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

Returns the number of days after the expiration to delete the grouping.

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

Returns the number of days after the expiration to notify the user.

=head3 value

If specified, expireNotifyOffset is set to this value. 

=cut

sub expireNotifyOffset {
        my $self = shift;
        my $value = shift;
        if (defined $value) {
		$self->get("expireNotifyOffset",$value);
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
		push @{ $groups }, @{ WebGUI::Group->new($self->session, $gid)->getAllGroupsFor() };
	}
	my %unique = map { $_ => 1 } @{ $groups };
	$groups = [ keys %unique ];
	return $groups;
}

#-------------------------------------------------------------------

=head2 getAllUsers ( [ withoutExpired ] )

Returns an array reference containing a list of users that belong to this group
and in any group that belongs to this group.

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
		@{ $self->getKarmaUsers() },
		@{ $self->getScratchUsers() },
		@{ $self->getIpUsers() },
	;
	++$loopCount;
	if ($loopCount > 99) {
		$self->session->errorHandler->fatal("Endless recursive loop detected while determining groups in group.\nRequested groupId: ".$self->getId);
	}
	my $groups = $self->getGroupsIn();
	##Have to iterate twice due to the withoutExpired clause.
	foreach my $groupId (@{ $groups }) {
		my $subGroup = WebGUI::Group->new($self->session, $groupId);
		push @users, @{ $subGroup->getAllUsers(1, $withoutExpired, $loopCount) };
	}
	my %users = map { $_ => 1 } @users;
	@users = keys %users;
	$cache->set(\@users, $self->groupCacheTimeout);
	return \@users;
}


#-------------------------------------------------------------------

=head2 getDatabaseUsers ( )

Get the set of users allowed to be in this group via a database query.

=cut

sub getDatabaseUsers {
	my $self = shift;
	my @dbUsers = ();
	my $gid = $self->getId;
        ### Check db database
        if ($self->get("dbQuery") && defined $self->get("databaseLinkId")) {
		my $dbLink = WebGUI::DatabaseLink->new($self->session,$self->get("databaseLinkId"));
		my $dbh = $dbLink->db;
		if (defined $dbh) {
			my $query = $self->get("dbQuery");
			WebGUI::Macro::process($self->session,\$query);
			my $sth = $dbh->unconditionalRead($query);
			unless ($sth->errorCode < 1) {
				$self->session->errorHandler->warn("There was a problem with the database query for group ID $gid.");
			}
			else {
				while(my ($userId)=$sth->array) {
					push @dbUsers, $userId;
				}
			}
			$sth->finish;
			$dbLink->disconnect;
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

	my $time = $self->session->datetime->time();

	$IpFilter =~ s/\s//g;
	my @filters = split /;/, $IpFilter;

	my $query = "select userId,lastIP from userSession where expires > ?";

	my $sth = $self->session->db->read($query, [ $self->session->datetime->time() ]);
	my %localCache = ();
	my @ipUsers = ();
	$self->session->errorHandler->warn("Fetching IP users");
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

=head2 getScratchUsers ( )

Get the set of users allowed to be in this group via session scratch variable settings
and this group's scratchFilter.  The set is returned as an array ref.

If no scratchFilter has been set for this group, returns an empty array ref.

=cut

sub getScratchUsers {
	my $self = shift;
	my $scratchFilter;
	return [] unless $scratchFilter = $self->scratchFilter();

	my $time = $self->session->datetime->time();

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

=head2 getUsers ( [ withoutExpired ] )

Returns an array reference containing a list of users that have been added
to this WebGUI group directly, rather than by other methods of group membership
like IP address, LDAP, dbQuery or scratchFilter.

=head3 withoutExpired

A boolean that if set true will return the users list minus the expired groupings.

=cut

sub getUsers {
	my $self = shift;
	my $withoutExpired = shift;
	my $expireTime = 0;
	if ($withoutExpired) {
		$expireTime = $self->session->datetime->time();
	}
	my @users = $self->session->db->buildArray("select userId from groupings where expireDate > ? and groupId = ?", [$expireTime, $self->getId]);
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

=head2 new ( session, groupId [, overrideId ] )

Constructor.

=head3 session

A reference to the current session.

=head3 groupId

The groupId of the group you're creating an object reference for. If specified as "new" then a new group will be created and assigned a new random groupId. If left blank then the object methods will just return default values for everything.

=head3 overrideId

If you specified "new" for groupId, you can use this property to specify an id you wish to create, rather than having the system generate one for you.

=cut

sub new {
        my ($class, %group);
        tie %group, 'Tie::CPHash';
        $class = shift;
	my $self = {};
	$self->{_session} = shift;
	$self->{_groupId} = shift;
	my $override = shift;
	my $cached = $self->{_session}->stow->get("groupObj");
	return $cached->{$self->{_groupId}} if ($cached->{$self->{_groupId}});
	bless $self, $class;
        $self->_create($override) if ($self->{_groupId} eq "new");
	$cached->{$self->{_groupId}} = $self;
	$self->{_session}->stow->set("groupObj", $cached);
	return $self;
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
	$self->session->db->setRow("groups","groupId",{groupId=>$self->getId, $name=>$value, lastUpdated=>$self->session->datetime->time()});
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

1;
