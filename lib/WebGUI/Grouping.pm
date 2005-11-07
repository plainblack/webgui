package WebGUI::Grouping;

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
use WebGUI::Auth;
use WebGUI::Cache;
use WebGUI::DateTime;
use WebGUI::ErrorHandler;
use WebGUI::LDAPLink;
use WebGUI::Macro;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Utility;

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
 $boolean = WebGUI::Grouping::isInGroup($groupId, $userId);
 $boolean = WebGUI::Grouping::userGroupAdmin($userId,$groupId);
 $epoch = WebGUI::Grouping::userGroupExpireDate($userId,$groupId);

=head1 METHODS

These functions are available from this package:

=cut



#-------------------------------------------------------------------

=head2 addGroupsToGroups ( groups, toGroups )

Adds groups to a group.

=head3 groups

An array reference containing the list of group ids to add.

=head3 toGroups

An array reference containing the list of group ids to add the first list to.

=cut

sub addGroupsToGroups {
	delete $session{isInGroup};
	foreach my $gid (@{$_[0]}) {
		next if ($gid eq '1');
		foreach my $toGid (@{$_[1]}) {
			my ($isIn) = WebGUI::SQL->quickArray("select count(*) from groupGroupings 
				where groupId=".quote($gid)." and inGroup=".quote($toGid));
			my $recursive = isIn($toGid, @{getGroupsInGroup($gid,1)});
			unless ($isIn || $recursive) {
				WebGUI::SQL->write("insert into groupGroupings (groupId,inGroup) values (".quote($gid).",".quote($toGid).")");
				my $cache = WebGUI::Cache->new("groups_in_group_".$gid);
				$cache->delete if (defined $cache);
				$cache = WebGUI::Cache->new("groups_in_group_".$toGid);
				$cache->delete if (defined $cache);
			}
		}
	}
}


#-------------------------------------------------------------------

=head2 addUsersToGroups ( users, groups [, expireOffset ] )

Adds users to the specified groups.

=head3 users 

An array reference containing a list of users.

=head3 groups

An array reference containing a list of groups.

=head3 expireOffset

An override for the default offset of the grouping. Specified in seconds.

=cut

sub addUsersToGroups {
	delete $session{isInGroup};
        foreach my $gid (@{$_[1]}) {
		my $expireOffset;
		if ($_[2]) {
			$expireOffset = $_[2];
		} else { 
        		($expireOffset) = WebGUI::SQL->quickArray("select expireOffset from groups where groupId=".quote($gid));
		}
		foreach my $uid (@{$_[0]}) {
			next if ($uid eq '1');
			my ($isIn) = WebGUI::SQL->quickArray("select count(*) from groupings where groupId=".quote($gid)." and userId=".quote($uid));
			unless ($isIn) {
                		WebGUI::SQL->write("insert into groupings (groupId,userId,expireDate) 
					values (".quote($gid).", ".quote($uid).", ".(WebGUI::DateTime::time()+$expireOffset).")");
			} else {
                        	if ($_[2]) {
                                	userGroupExpireDate($uid,$gid,(WebGUI::DateTime::time()+$expireOffset));
                        	}
			}
                }
        }
}

#-------------------------------------------------------------------

=head2 deleteGroupsFromGroups ( groups, fromGroups )

Deletes groups from these groups.

=head3 groups

An array reference containing the list of group ids to delete.

=head3 fromGroups 

An array reference containing the list of group ids to delete from.

=cut

sub deleteGroupsFromGroups {
	delete $session{isInGroup};
        foreach my $gid (@{$_[0]}) {
		foreach my $fromGid (@{$_[1]}) {
			WebGUI::Cache->new("groups_in_group_".$fromGid)->delete;
        		WebGUI::SQL->write("delete from groupGroupings where groupId=".quote($gid)." and inGroup=".quote($fromGid));
		}
        }
}


#-------------------------------------------------------------------

=head2 deleteUsersFromGroups ( users, groups )

Deletes a list of users from the specified groups.

=head3 users

An array reference containing a list of users.

=head3 groups

An array reference containing a list of groups.

=cut

sub deleteUsersFromGroups {
	delete $session{isInGroup};
        foreach my $gid (@{$_[1]}) {
		foreach my $uid (@{$_[0]}) {
                	WebGUI::SQL->write("delete from groupings where groupId=".quote($gid)." and userId=".quote($uid));
		}
        }
}


#-------------------------------------------------------------------

=head2 getGroupsForGroup ( groupId )

Returns an array reference containing a list of groups the specified group is in.

=head3 groupId

A unique identifier for the group.

=cut

sub getGroupsForGroup {
	return WebGUI::SQL->buildArrayRef("select inGroup from groupGroupings where groupId=".quote($_[0]));
}


#-------------------------------------------------------------------

=head2 getGroupsForUser ( userId [ , withoutExpired ] )

Returns an array reference containing a list of groups the specified user is in.

=head3 userId

A unique identifier for the user.

=head3 withoutExpired

If set to "1" then the listing will not include expired groupings. Defaults to "0".

=cut

sub getGroupsForUser {
	my $userId = shift;
	my $withoutExpired = shift;
	my $clause = "and expireDate>".time() if ($withoutExpired);
	if ($userId eq "") {
                return [];
        } elsif (exists $session{gotGroupsForUser}{$userId}) {
		return $session{gotGroupsForUser}{$userId};
        } else {
                my @groups = WebGUI::SQL->buildArray("select groupId from groupings where userId=".quote($userId)." $clause");
		foreach my $gid (@groups) {
			$session{isInGroup}{$userId}{$gid} = 1;
		}
		$session{gotGroupsForUser}{$userId} = \@groups unless ($session{config}{disableCache});
		return \@groups;
        }
}


#-------------------------------------------------------------------

=head2 getGroupsInGroup ( groupId [, recursive ] )

Returns an array reference containing a list of groups that belong to the specified group.

=head3 groupId

A unique identifier for the group.

=head3 recursive

A boolean value to determine whether the method should return the groups directly in the group, or to follow the entire groups of groups hierarchy. Defaults to "0".

=cut


sub getGroupsInGroup {
        my $groupId = shift;
        my $isRecursive = shift;
        my $loopCount = shift;
	if ($isRecursive && exists $session{gotGroupsInGroup}{recursive}{$groupId}) {
		return $session{gotGroupsInGroup}{recursive}{$groupId};
	} elsif (exists $session{gotGroupsInGroup}{recursive}{$groupId}) {
		return $session{gotGroupsInGroup}{direct}{$groupId};
	}
	my $groups = WebGUI::Cache->new("groups_in_group_".$groupId)->get;
	unless (defined $groups) {
        	$groups = WebGUI::SQL->buildArrayRef("select groupId from groupGroupings where inGroup=".quote($groupId));
		WebGUI::Cache->new("groups_in_group_".$groupId)->set($groups);
	}
        if ($isRecursive) {
                $loopCount++;
                if ($loopCount > 99) {
                        WebGUI::ErrorHandler::fatal("Endless recursive loop detected while determining".
                                " groups in group.\nRequested groupId: ".$groupId."\nGroups in that group: ".join(",",@$groups));
                }
                my @groupsOfGroups = @$groups;
                foreach my $group (@$groups) {
                        my $gog = getGroupsInGroup($group,1,$loopCount);
                        push(@groupsOfGroups, @$gog);
                }
		$session{gotGroupsInGroup}{recursive}{$groupId} = \@groupsOfGroups  unless ($session{config}{disableCache});
                return \@groupsOfGroups;
	}
	$session{gotGroupsInGroup}{direct}{$groupId} = $groups;
        return $groups;
}


#-------------------------------------------------------------------

=head2 getUsersInGroup ( groupId [, recursive, withoutExpired ] )

Returns an array reference containing a list of users that belong to the specified group.

=head3 groupId

A unique identifier for the group.

=head3 recursive

A boolean value to determine whether the method should return the users directly in the group or to follow the entire groups of groups hierarchy. Defaults to "0".

=head3 withoutExpired

A boolean that if set true will return the users list minus the expired groupings.

=cut

sub getUsersInGroup {
	my $groupId = shift;
	my $recursive = shift;
	my $withoutExpired = shift;
	my $clause;
	if ($withoutExpired) {
		$clause = "expireDate > ".time()." and ";
	}
	$clause .= "(groupId=".quote($groupId);
	if ($recursive) {
		my $groups = getGroupsInGroup($groupId,1);
		if ($#$groups >= 0) {
			$clause .= " or groupId in (".quoteAndJoin($groups).")";
		}
	}
	$clause .= ")";
       	return WebGUI::SQL->buildArrayRef("select userId from groupings where $clause");
}


#-------------------------------------------------------------------

=head2 isInGroup ( [ groupId , userId ] )

Returns a boolean (0|1) value signifying that the user has the required privileges. Always returns true for Admins.

=head3 groupId

The group that you wish to verify against the user. Defaults to group with Id 3 (the Admin group).

=head3 userId

The user that you wish to verify against the group. Defaults to the currently logged in user.

=cut

sub isInGroup {
        my (@data, %group, $groupId);
        my ($gid, $uid, $secondRun) = @_;
        $gid = 3 unless (defined $gid);
        $uid = $session{user}{userId} if ($uid eq "");
        ### The following several checks are to increase performance. If this section were removed, everything would continue to work as normal. 
        return 1 if ($gid eq '7');		# everyone is in the everyone group
        return 1 if ($gid eq '1' && $uid eq '1'); 	# visitors are in the visitors group
        return 0 if ($uid eq '1');  #Visitor is in no other groups
        return 1 if ($uid eq '3');  #Admin is in every group
        return 1 if ($gid eq '2' && $uid ne '1'); 	# if you're not a visitor, then you're a registered user
        ### Look to see if we've already looked up this group. 
        if ($session{isInGroup}{$uid}{$gid} eq '1') {
                return 1;
        } elsif ($session{isInGroup}{$uid}{$gid} eq "0") {
                return 0;
        }
        ### Lookup the actual groupings.
	unless ($secondRun) {			# don't look up user groups if we've already done it once.
	        my $groups = WebGUI::Grouping::getGroupsForUser($uid,1);
	        foreach (@{$groups}) {
	                $session{isInGroup}{$uid}{$_} = 1 unless ($session{config}{disableCache});
        	}
        	if ($session{isInGroup}{$uid}{$gid} eq '1') {
                	return 1;
        	}
	}
        ### Get data for auxillary checks.
        tie %group, 'Tie::CPHash';
        %group = WebGUI::SQL->quickHash("select karmaThreshold,ipFilter,scratchFilter,databaseLinkId,dbQuery,dbCacheTimeout,ldapGroup,ldapGroupProperty,ldapRecursiveProperty from groups where groupId=".quote($gid));
        ### Check IP Address
        if ($group{ipFilter} ne "") {
                $group{ipFilter} =~ s/\t//g;
                $group{ipFilter} =~ s/\r//g;
                $group{ipFilter} =~ s/\n//g;
                $group{ipFilter} =~ s/\s//g;
                $group{ipFilter} =~ s/\./\\\./g;
                my @ips = split(";",$group{ipFilter});
                foreach my $ip (@ips) {
                        if ($session{env}{REMOTE_ADDR} =~ /^$ip/) {
                                $session{isInGroup}{$uid}{$gid} = 1 unless ($session{config}{disableCache});
                                return 1;
                        }
                }
        }
        ### Check Scratch Variables 
        if ($group{scratchFilter} ne "") {
                $group{scratchFilter} =~ s/\t//g;
                $group{scratchFilter} =~ s/\r//g;
                $group{scratchFilter} =~ s/\n//g;
                $group{scratchFilter} =~ s/\s//g;
                my @vars = split(";",$group{scratchFilter});
                foreach my $var (@vars) {
                        my ($name, $value) = split(/\=/,$var);
                        if ($session{scratch}{$name} eq $value) {
                                $session{isInGroup}{$uid}{$gid} = 1 unless ($session{config}{disableCache});
                                return 1;
                        }
                }
        }
        ### Check karma levels.
        if ($session{setting}{useKarma}) {
                my $karma;
                if ($uid eq $session{user}{userId}) {
                        $karma = $session{user}{karma};
                } else {
                        ($karma) = WebGUI::SQL->quickHash("select karma from users where userId=".quote($uid));
                }
                if ($karma >= $group{karmaThreshold}) {
                        $session{isInGroup}{$uid}{$gid} = 1 unless ($session{config}{disableCache});
                        return 1;
                }
        }
        ### Check external database
        if ($group{dbQuery} ne "" && $group{databaseLinkId}) {
                # skip if not logged in and query contains a User macro
                unless ($group{dbQuery} =~ /\^User/i && $uid eq '1') {
                        my $dbLink = WebGUI::DatabaseLink->new($group{databaseLinkId});
                        my $dbh = $dbLink->dbh;
                        if (defined $dbh) {
                                if ($group{dbQuery} =~ /select 1/i) {
					my $query = $group{dbQuery};
					WebGUI::Macro::process(\$query);
                                        $group{dbQuery} = $query;
                                        my $sth = WebGUI::SQL->unconditionalRead($group{dbQuery},$dbh);
                                        unless ($sth->errorCode < 1) {
                                                WebGUI::ErrorHandler::warn("There was a problem with the database query for group ID $gid.");
                                        } else {
                                                my ($result) = $sth->array;
                                                if ($result == 1) {
                                                        $session{isInGroup}{$uid}{$gid} = 1 unless ($session{config}{disableCache});
                                                        if ($group{dbCacheTimeout} > 0) {
                                                                WebGUI::Grouping::deleteUsersFromGroups([$uid],[$gid]);
                                                                WebGUI::Grouping::addUsersToGroups([$uid],[$gid],$group{dbCacheTimeout});
                                                        }
                                                } else {
                                                        $session{isInGroup}{$uid}{$gid} = 0 unless ($session{config}{disableCache});
                                                        WebGUI::Grouping::deleteUsersFromGroups([$uid],[$gid]) if ($group{dbCacheTimeout} > 0);
                                                }
                                        }
                                        $sth->finish;
                                } else {
                                        WebGUI::ErrorHandler::warn("Database query for group ID $gid must use 'select 1'");
                                }
                                $dbLink->disconnect;
                                return 1 if ($session{isInGroup}{$uid}{$gid});
                        }
                }
        }
		
		 ### Check external database
        if ($group{ldapGroup} ne "" && $group{ldapGroupProperty} ne "") {
		   # skip if not logged in
		   unless($uid eq '1') {
		      my $u = WebGUI::User->new($uid);
			  # skip if user is not set to LDAP
			  if($u->authMethod eq "LDAP") {
			     my $auth = WebGUI::Auth->new("LDAP",$uid);
				 my $params = $auth->getParams();
				 my $ldapLink = WebGUI::LDAPLink->new($params->{ldapConnection});
				 if($ldapLink ne "") {
					my $people = [];
					if($group{ldapRecursiveProperty}) {
					   $ldapLink->recurseProperty($group{ldapGroup},$people,$group{ldapGroupProperty},$group{ldapRecursiveProperty});
					}else {
					   $people = $ldapLink->getProperty($group{ldapGroup},$group{ldapGroupProperty});
					}
					 
				    if(isIn($params->{connectDN},@{$people})) {
					   $session{isInGroup}{$uid}{$gid} = 1 unless ($session{config}{disableCache});
                       if ($group{dbCacheTimeout} > 10) {
                          WebGUI::Grouping::deleteUsersFromGroups([$uid],[$gid]);
                          WebGUI::Grouping::addUsersToGroups([$uid],[$gid],$group{dbCacheTimeout});
                       }
					} else {
					   $session{isInGroup}{$uid}{$gid} = 0 unless ($session{config}{disableCache});
                       WebGUI::Grouping::deleteUsersFromGroups([$uid],[$gid]) if ($group{dbCacheTimeout} > 10);
					}
					$ldapLink->unbind;
				    return 1 if ($session{isInGroup}{$uid}{$gid});
				 }
			  }
		   }
		}
		
        ### Check for groups of groups.
        my $groups = WebGUI::Grouping::getGroupsInGroup($gid,1);
        foreach (@{$groups}) {
                $session{isInGroup}{$uid}{$_} = isInGroup($_, $uid, 1);
                if ($session{isInGroup}{$uid}{$_}) {
                        $session{isInGroup}{$uid}{$gid} = 1 unless ($session{config}{disableCache}); # cache current group also so we don't have to do the group in group check again
                        return 1;
                }
        }
        $session{isInGroup}{$uid}{$gid} = 0 unless ($session{config}{disableCache});
        return 0;
}





#-------------------------------------------------------------------

=head2 userGroupAdmin ( userId, groupId [, value ] )

Returns a 1 or 0 depending upon whether the user is a sub-admin for this group.

=head3 userId

An integer that is the unique identifier for a user.

=head3 groupId

An integer that is the unique identifier for a group.

=head3 value

If specified the admin flag will be set to this value.

=cut

sub userGroupAdmin {
	if ($_[2] ne "") {
		WebGUI::SQL->write("update groupings set groupAdmin=".quote($_[2])." where groupId=".quote($_[1])." and userId=".quote($_[0]));
		return $_[2];
	} else {
		my ($admin) = WebGUI::SQL->quickArray("select groupAdmin from groupings where groupId=".quote($_[1])." and userId=".quote($_[0]));
		return $admin;
	}
}	

#-------------------------------------------------------------------

=head2 userGroupExpireDate ( userId, groupId [, epoch ] )

Returns the epoch date that this grouping will expire.

=head3 userId

An integer that is the unique identifier for a user.

=head3 groupId

An integer that is the unique identifier for a group.

=head3 epoch

If specified the expire date will be set to this value.

=cut

sub userGroupExpireDate {
	if ($_[2]) {
		WebGUI::SQL->write("update groupings set expireDate=".quote($_[2])." where groupId=".quote($_[1])." and userId=".quote($_[0]));
		return $_[2];
	} else {
		my ($expireDate) = WebGUI::SQL->quickArray("select expireDate from groupings where groupId=".quote($_[1])." and userId=".quote($_[0]));
		return $expireDate;
	}
}	



1;

