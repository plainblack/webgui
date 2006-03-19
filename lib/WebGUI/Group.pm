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
 $arrayRef = $group->getUsers($groupId);
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
		dbCacheTimeout=>3600,
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
	$self->session->stow->delete("isInGroup");
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
	$self->session->stow->delete("gotGroupsInGroup");
	return 1;
}


#-------------------------------------------------------------------

=head2 addUsers ( users [, expireOffset ] )

Adds users to this group.

=head3 users 

An array reference containing a list of users.

=head3 expireOffset

An override for the default offset of the grouping. Specified in seconds.

=cut

sub addUsers {
	my $self = shift;
	my $users = shift;
	$self->session->stow->delete("isInGroup");
	my $expireOffset = shift || $self->get("expireOffset");
	foreach my $uid (@{$users}) {
		next if ($uid eq '1' and !isIn($self->getId, 1, 7));
		my ($isIn) = $self->session->db->quickArray("select count(*) from groupings where groupId=? and userId=?", [$self->getId, $uid]);
		unless ($isIn) {
			$self->session->db->write("insert into groupings (groupId,userId,expireDate) values (?,?,?)", [$self->getId, $uid, ($self->session->datetime->time()+$expireOffset)]);
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
	$self->session->stow->delete("isInGroup");
        foreach my $gid (@{$groups}) {
        	$self->session->db->write("delete from groupGroupings where groupId=? and inGroup=?",[$gid, $self->getId]);
        }
	$self->session->stow->delete("gotGroupsInGroup");
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
	$self->session->stow->delete("isInGroup");
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
        my $groups = $self->session->db->buildArrayRef("select groupId from groupGroupings where inGroup=?",[$self->getId]);
        if ($isRecursive) {
                $loopCount++;
                if ($loopCount > 99) {
                        $self->session->errorHandler->fatal("Endless recursive loop detected while determining".  " groups in group.\nRequested groupId: ".$self->getId."\nGroups in that group: ".join(",",@$groups));
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

=head2 getUsers ( [ recursive, withoutExpired ] )

Returns an array reference containing a list of users that belong to this group.

=head3 recursive

A boolean value to determine whether the method should return the users directly in the group or to follow the entire groups of groups hierarchy. Defaults to "0".

=head3 withoutExpired

A boolean that if set true will return the users list minus the expired groupings.

=cut

sub getUsers {
	my $self = shift;
	my $recursive = shift;
	my $withoutExpired = shift;
	my $clause;
	if ($withoutExpired) {
		$clause = "expireDate > ".$self->session->datetime->time()." and ";
	}
	$clause .= "(groupId=".$self->session->db->quote($self->getId);
 	if ($recursive) {
		my $groups = $self->getGroupsIn(1);
		if ($#$groups >= 0) {
			if ($withoutExpired) {
				foreach my $groupId (@$groups) {
					$clause .= " OR (groupId = ".$self->session->db->quote($groupId)." AND expireDate > ".$self->session->datetime->time().") ";
				}
			} else {
				$clause .= " OR groupId IN (".$self->session->db->quoteAndJoin($groups).")";
			}
		}
	}
	$clause .= ")";
       	return $self->session->db->buildArrayRef("select userId from groupings where $clause");
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
        my ($class, $groupId, %default, $value, $key, %group, %profile);
        tie %group, 'Tie::CPHash';
        $class = shift;
	my $self = {};
	$self->{_session} = shift;
	$self->{_groupId} = shift;
	my $override = shift;
	bless $self, $class;
        $self->_create($override) if ($self->{_groupId} eq "new");
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

If specified, the databaseLinkId is set to this value.

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

=head2 dbCacheTimeout ( [ value ] )

Returns the dbCacheTimeout for this group.

=head3 value

If specified, the dbCacheTimeout is set to this value.

=cut

sub dbCacheTimeout {
        my $self = shift;
        my $value = shift;
        if (defined $value) {
                $self->set("dbCacheTimeout",$value);
        }
        return $self->get("dbCacheTimeout");
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

THe value of a property to set.

=cut

sub set {
	my $self = shift;
	my $name = shift;
	my $value = shift;
	$self->get("groupId") unless ($self->{_group}); # precache group stuff
	$self->{_group}{$name} = $value;
	$self->session->db->setRow("groups","groupId",{groupId=>$self->getId, $name=>$value, lastUpdated=>$self->session->datetime->time()});
}

#-------------------------------------------------------------------

=head2 userIsAdmin ( [ userId, value ] )

Returns a 1 or 0 depending upon whether the user is a sub-admin for this group.

=head3 userId

A guid that is the unique identifier for a user. Defaults to the currently logged in user.

=head3 value

If specified the admin flag will be set to this value.

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
		return $admin;
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
