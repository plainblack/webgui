package WebGUI::Grouping;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2003 Plain Black LLC.
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
use WebGUI::Session;
use WebGUI::SQL;

=head1 NAME

Package WebGUI::Grouping

=head1 DESCRIPTION

This package provides an interface for managing WebGUI user and group groupings.

=head1 SYNOPSIS

 use WebGUI::Grouping;
 WebGUI::Grouping::addGroupsToGroups(\@groups, \@toGroups);
 WebGUI::Grouping::addUsersToGroups(\@users, \@toGroups);
 WebGUI::Grouping::deleteGroupsFromGroups(\@groups, \@fromGroups);
 WebGUI::Grouping::deleteUsersFromGroups(\@users, \@fromGroups);
 $arrayRef = WebGUI::Grouping::getGroupsForGroup($groupId);
 $arrayRef = WebGUI::Grouping::getGroupsForUser($userId);
 $arrayRef = WebGUI::Grouping::getGroupsInGroup($groupId);
 $arrayRef = WebGUI::Grouping::getUsersInGroup($groupId);
 $yesNo = WebGUI::Grouping::userGroupAdmin($userId,$groupId);
 $epoch = WebGUI::Grouping::userGroupExpireDate($userId,$groupId);

=head1 METHODS

These functions are available from this package:

=cut



#-------------------------------------------------------------------

=head2 addGroupsToGroups ( groups, toGroups )

Adds groups to a group.

=over

=item groups

An array reference containing the list of group ids to add.

=item toGroups

An array reference containing the list of group ids to add the first list to.

=back

=cut

sub addGroupsToGroups {
	foreach my $gid (@{$_[0]}) {
		foreach my $toGid (@{$_[1]}) {
			my ($isIn) = WebGUI::SQL->quickArray("select count(*) from groupGroupings 
				where groupId=$gid and inGroup=$toGid");
			unless ($isIn) {
				WebGUI::SQL->write("insert into groupGroupings (groupId,inGroup) values ($gid,$toGid)");
			}
		}
	}
}


#-------------------------------------------------------------------

=head2 addUsersToGroups ( users, groups [, expireOffset ] )

Adds users to the specified groups.

=over

=item users 

An array reference containing a list of users.

=item groups

An array reference containing a list of groups.

=item expireOffset

An override for the default offset of the grouping. Specified in seconds.

=back

=cut

sub addUsersToGroups {
        foreach my $gid (@{$_[1]}) {
		my $expireOffset;
		if ($_[2]) {
			$expireOffset = $_[2];
		} else { 
        		($expireOffset) = WebGUI::SQL->quickArray("select expireOffset from groups where groupId=$gid");
		}
		foreach my $uid (@{$_[0]}) {
			my ($isIn) = WebGUI::SQL->quickArray("select count(*) from groupings where groupId=$gid and userId=$uid");
			unless ($isIn) {
                		WebGUI::SQL->write("insert into groupings (groupId,userId,expireDate) 
					values ($gid, $uid, ".(WebGUI::DateTime::time()+$expireOffset).")");
			}
		}
        }
}

#-------------------------------------------------------------------

=head2 deleteGroupsFromGroups ( groups, fromGroups )

Deletes groups from these groups.

=over

=item groups

An array reference containing the list of group ids to delete.

=item fromGroups 

An array reference containing the list of group ids to delete from.

=back

=cut

sub deleteGroupsFromGroups {
        foreach my $gid (@{$_[0]}) {
		foreach my $fromGid (@{$_[1]}) {
        		WebGUI::SQL->write("delete from groupGroupings where groupId=$gid and inGroup=".$fromGid);
		}
        }
}


#-------------------------------------------------------------------

=head2 deleteUsersFromGroups ( users, groups )

Deletes a list of users from the specified groups.

=over

=item users

An array reference containing a list of users.

=item groups

An array reference containing a list of groups.

=back

=cut

sub deleteUsersFromGroups {
        foreach my $gid (@{$_[1]}) {
		foreach my $uid (@{$_[0]}) {
                	WebGUI::SQL->write("delete from groupings where groupId=$gid and userId=$uid");
		}
        }
}


#-------------------------------------------------------------------

=head2 getGroupsForGroup ( groupId )

Returns an array reference containing a list of groups the specified group is in.

=over

=item groupId

A unique identifier for the group.

=back

=cut

sub getGroupsForGroup {
	return WebGUI::SQL->buildArrayRef("select inGroup from groupGroupings where groupId=$_[0]");
}


#-------------------------------------------------------------------

=head2 getGroupsForUser ( userId [ , withoutExpired ] )

Returns an array reference containing a list of groups the specified user is in.

=over

=item userId

A unique identifier for the user.

=item withoutExpired

If set to "1" then the listing will not include expired groupings. Defaults to "0".

=back

=cut

sub getGroupsForUser {
	my $clause = "and expireDate>".time() if ($_[1]);
        return WebGUI::SQL->buildArrayRef("select groupId from groupings where userId=$_[0] $clause");
}


#-------------------------------------------------------------------

=head2 getGroupsInGroup ( groupId [, recursive ] )

Returns an array reference containing a list of groups that belong to the specified group.

=over

=item groupId

A unique identifier for the group.

=item recursive

A boolean value to determine whether the method should return the groups directly in the group, or to follow the entire groups of groups hierarchy. Defaults to "0".

=back

=cut

sub getGroupsInGroup {
       	my $groups = WebGUI::SQL->buildArrayRef("select groupId from groupGroupings where inGroup=$_[0]");
	if ($_[1]) {
		my @groupsOfGroups = @$groups;
		foreach my $group (@$groups) {
			my $gog = getGroupsInGroup($group,1);
			push(@groupsOfGroups, @$gog);
		}
		return \@groupsOfGroups;
	}
	return $groups;
}


#-------------------------------------------------------------------

=head2 getUsersInGroup ( groupId [, recursive ] )

Returns an array reference containing a list of users that belong to the specified group.

=over

=item groupId

A unique identifier for the group.

=item recursive

A boolean value to determine whether the method should return the users directly in the group or to follow the entire groups of groups hierarchy. Defaults to "0".

=back

=cut

sub getUsersInGroup {
	my $clause = "groupId=$_[0]";
	if ($_[1]) {
		my $groups = getGroupsInGroup($_[0],1);
		if ($#$groups >= 0) {
			$clause .= " or groupId in (".join(",",@$groups).")";
		}
	}
       	return WebGUI::SQL->buildArrayRef("select userId from groupings where $clause");
}



#-------------------------------------------------------------------

=head2 userGroupAdmin ( userId, groupId [, value ] )

Returns a 1 or 0 depending upon whether the user is a sub-admin for this group.

=over

=item userId

An integer that is the unique identifier for a user.

=item groupId

An integer that is the unique identifier for a group.

=item value

If specified the admin flag will be set to this value.

=back

=cut

sub userGroupAdmin {
	if ($_[2]) {
		WebGUI::SQL->write("update groupings set groupAdmin=$_[2] where groupId=$_[1] and userId=$_[0]");
		return $_[2];
	} else {
		my ($admin) = WebGUI::SQL->quickArray("select groupAdmin from groupings where groupId=$_[1] and userId=$_[0]");
		return $admin;
	}
}	

#-------------------------------------------------------------------

=head2 userGroupExpireDate ( userId, groupId [, epoch ] )

Returns the epoch date that this grouping will expire.

=over

=item userId

An integer that is the unique identifier for a user.

=item groupId

An integer that is the unique identifier for a group.

=item epoch

If specified the expire date will be set to this value.

=back

=cut

sub userGroupExpireDate {
	if ($_[2]) {
		WebGUI::SQL->write("update groupings set expireDate=$_[2] where groupId=$_[1] and userId=$_[0]");
		return $_[2];
	} else {
		my ($expireDate) = WebGUI::SQL->quickArray("select expireDate from groupings 
			where groupId=$_[1] and userId=$_[0]");
		return $expireDate;
	}
}	



1;

