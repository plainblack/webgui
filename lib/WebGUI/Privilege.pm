package WebGUI::Privilege;

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
use Tie::CPHash;
use WebGUI::DatabaseLink;
use WebGUI::DateTime;
use WebGUI::Group;
use WebGUI::Grouping;
use WebGUI::International;
use WebGUI::Macro;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;

=head1 NAME

Package WebGUI::Privilege

=head1 DESCRIPTION

This package provides access to the WebGUI security system and security messages.

=head1 SYNOPSIS

 use WebGUI::Privilege;
 $html =	WebGUI::Privilege::adminOnly();
 $boolean =	WebGUI::Privilege::canEditPage();
 $boolean =	WebGUI::Privilege::canViewPage();
 $html =	WebGUI::Privilege::insufficient();
 $boolean =	WebGUI::Privilege::isInGroup($groupId);
 $html =	WebGUI::Privilege::noAccess();
 $html =	WebGUI::Privilege::notMember();
 $html =	WebGUI::Privilege::vitalComponent();

=head1 METHODS 

These functions are available from this package:

=cut

#-------------------------------------------------------------------

=head2 adminOnly ( )

Returns a message stating that this functionality can only be used by administrators. This method also sets the HTTP header status to 401.

=cut

sub adminOnly {
	if($session{env}{MOD_PERL}) {
        	my $r = Apache->request;
                if(defined($r)) {
                	$r->custom_response(401, '<!--Admin Only-->' );
                        $r->status(401);
                }
        } else {
		$session{header}{status} = 401;
	}
	my ($output, $sth, @data);
        $output = '<h1>'.WebGUI::International::get(35).'</h1>';
	$output .= WebGUI::International::get(36);
	return $output;
}

#-------------------------------------------------------------------

=head2 canEditPage ( [ pageId ] )

Returns a boolean (0|1) value signifying that the user has the required privileges.

=over

=item pageId

The unique identifier for the page that you wish to check the privileges on. Defaults to the current page id.

=back

=cut

sub canEditPage {
	my (%page);
	tie %page, 'Tie::CPHash';
	if ($_[0] ne "") {
		%page = WebGUI::SQL->quickHash("select ownerId,groupIdEdit from page where pageId=$_[0]");
	} else {
		%page = %{$session{page}};
	}
	if ($session{user}{userId} == $page{ownerId}) {
		return 1;
	} elsif (isInGroup($page{groupIdEdit})) {
		return 1;
	} else {
		return 0;
	}
}

#-------------------------------------------------------------------

=head2 canEditWobject ( wobjectId )

Returns a boolean (0|1) value signifying that the user has the required privileges.

=over

=item wobjectId

The unique identifier for the wobject that you wish to check the privileges on.

=back

=cut

sub canEditWobject {
	my (%wobject);
	tie %wobject, 'Tie::CPHash';
	return canEditPage() if ($session{page}{wobjectPrivileges} != 1 || $_[0] eq "new");
	%wobject = WebGUI::SQL->quickHash("select ownerId,groupIdEdit from wobject where wobjectId=".quote($_[0]));
	if ($session{user}{userId} == $wobject{ownerId}) {
		return 1;
	} elsif (isInGroup($wobject{groupIdEdit})) {
		return 1;
	} else {
		return 0;
	}
}

#-------------------------------------------------------------------

=head2 canViewPage ( [ pageId ] )

Returns a boolean (0|1) value signifying that the user has the required privileges. Always returns true for Admins and users that have the rights to edit this page.

=over

=item pageId

The unique identifier for the page that you wish to check the privileges on. Defaults to the current page id.

=back

=cut

sub canViewPage {
	my (%page, $inDateRange);
	tie %page, 'Tie::CPHash';
	if ($_[0] eq "") {
		%page = %{$session{page}};
	} else {
		%page = WebGUI::SQL->quickHash("select ownerId,groupIdView,startDate,endDate from page where pageId=$_[0]");
	}
	if ($page{startDate} < time() && $page{endDate} > time()) {
		$inDateRange = 1;
	}
        if ($session{user}{userId} == $page{ownerId}) {
                return 1;
        } elsif (isInGroup($page{groupIdView}) && $inDateRange) {
                return 1;
        } elsif (canEditPage($_[0])) { 
		return 1;
        } else {
                return 0;
        }
}

#-------------------------------------------------------------------

=head2 canViewWobject ( wobjectId  )

Returns a boolean (0|1) value signifying that the user has the required privileges. Always returns true for Admins and users that have the rights to edit this wobject.

=over

=item wobjectId

The unique identifier for the wobject that you wish to check the privileges on.

=back

=cut

sub canViewWobject {
	my (%wobject);
	tie %wobject, 'Tie::CPHash';
	return canViewPage() unless ($session{page}{wobjectPrivileges} == 1);
	%wobject = WebGUI::SQL->quickHash("select ownerId,groupIdView,startDate,endDate from wobject where wobjectId=".quote($_[0]));
	if ($wobject{startDate} < time() && $wobject{endDate} > time()) {
	   if ($session{user}{userId} == $wobject{ownerId}) {
          return 1;
       } elsif (isInGroup($wobject{groupIdView})) {
          return 1;
       } elsif (canEditWobject($_[0])) { 
	      return 1;
       } else {
          return 0;
       }
	}else{
	   return 0;
	}
}

#-------------------------------------------------------------------

=head2 insufficient ( )

Returns a message stating that the user does not have the required privileges to perform the operation they requested. This method also sets the HTTP header status to 401. 

=cut

sub insufficient {
	if($session{env}{MOD_PERL}) {
                my $r = Apache->request;
                if(defined($r)) {
                        $r->custom_response(401, '<!--Insufficient Privileges-->' );
                        $r->status(401);
                }
        } else {
		$session{header}{status} = 401;
	}
	my ($output);
	$output = '<h1>'.WebGUI::International::get(37).'</h1>';
	$output .= WebGUI::International::get(38);
	$output .= '<p>';
	return $output;
}

#-------------------------------------------------------------------

=head2 isInGroup ( groupId [ , userId ] )

Returns a boolean (0|1) value signifying that the user has the required privileges. Always returns true for Admins.

=over

=item groupId

The group that you wish to verify against the user.

=item userId

The user that you wish to verify against the group. Defaults to the currently logged in user.

=back

=cut

sub isInGroup {
	my ($gid, $uid, @data, %group, $groupId);
	($gid, $uid) = @_;
	$uid = $session{user}{userId} if ($uid eq "");


	#The several checks are to increase performance. If this section were removed, everything would continue to work as normal. 
#        if ($gid == 7) {
#                return 1;
#        }
#	if ($gid == 1) {
#		if ($uid == 1) {
#			return 1;
#		} else {
#			return 0;
#		}
#	}
#	if ($gid==2 && $uid != 1) {
#		return 1;
#	}



	### Use session to cache multiple lookups of the same group.
	if ($session{isInGroup}{$gid}{$uid} == 1) {
		return 1;
	} elsif ($session{isInGroup}{$gid}{$uid} eq "0") {
		return 0;
	}
        ### Lookup the actual groupings.
	my $groups = WebGUI::Grouping::getGroupsForUser($uid,1);
	foreach (@{$groups}) {
		$session{isInGroup}{$_}{$uid} = 1;
	}
	if ($session{isInGroup}{$gid}{$uid} == 1) {
		return 1;
	}

        ### Get data for auxillary checks.
	tie %group, 'Tie::CPHash';
	%group = WebGUI::SQL->quickHash("select karmaThreshold,ipFilter,scratchFilter,databaseLinkId,dbQuery,dbCacheTimeout from groups where groupId='$gid'");
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
				$session{isInGroup}{$gid}{$uid} = 1;
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
				$session{isInGroup}{$gid}{$uid} = 1;
				return 1;
			}
		}
	}

        ### Check karma levels.
	if ($session{setting}{useKarma}) {
		my $karma;
		if ($uid == $session{user}{userId}) {
			$karma = $session{user}{karma};
		} else {
			($karma) = WebGUI::SQL->quickHash("select karma from users where userId='$uid'");
		}
		if ($karma >= $group{karmaThreshold}) {
			$session{isInGroup}{$gid}{$uid} = 1;
			return 1;
		}
	}
	
	### Check external database
	if ($group{dbQuery} ne "" && $group{databaseLinkId}) {
		# skip if not logged in and query contains a User macro
		unless ($group{dbQuery} =~ /\^User/i && $uid == 1) {
			my $dbLink = WebGUI::DatabaseLink->new($group{databaseLinkId});
			my $dbh = $dbLink->dbh;
			if (defined $dbh) {
				if ($group{dbQuery} =~ /select 1/i) {
					$group{dbQuery} = WebGUI::Macro::process($group{dbQuery});
					my $sth = WebGUI::SQL->unconditionalRead($group{dbQuery},$dbh);
					unless ($sth->errorCode < 1) {
						WebGUI::ErrorHandler::warn("There was a problem with the database query for group ID $gid.");
					} else {
						my ($result) = $sth->array;
						if ($result == 1) {
							$session{isInGroup}{$gid}{$uid} = 1;
							if ($group{dbCacheTimeout} > 0) {
								WebGUI::Grouping::deleteUsersFromGroups([$uid],[$gid]);
								WebGUI::Grouping::addUsersToGroups([$uid],[$gid],$group{dbCacheTimeout});
							}
						} else {
							$session{isInGroup}{$gid}{$uid} = 0;
							WebGUI::Grouping::deleteUsersFromGroups([$uid],[$gid]) if ($group{dbCacheTimeout} > 0);
						}
					}
					$sth->finish;
				} else {
					WebGUI::ErrorHandler::warn("Database query for group ID $gid must use 'select 1'");
				}
				$dbLink->disconnect;
				return 1 if ($session{isInGroup}{$gid}{$uid});
			}
		}
	}
				
	### Check for groups of groups.
	$groups = WebGUI::Grouping::getGroupsInGroup($gid,1);
	foreach (@{$groups}) {
		$session{isInGroup}{$_}{$uid} = isInGroup($_, $uid);
		if ($session{isInGroup}{$_}{$uid}) {
			$session{isInGroup}{$gid}{$uid} = 1; # cache current group also so we don't have to do the group in group check again
			return 1;
		}
	}
	$session{isInGroup}{$gid}{$uid} = 0;
	return 0;
}

#-------------------------------------------------------------------

=head2 noAccess ( )

Returns a message stating that the user does not have the privileges necessary to access this page. This method also sets the HTTP header status to 401.

=cut

sub noAccess {
   if($session{env}{MOD_PERL}) {
      my $r = Apache->request;
      if(defined($r)) {
         $r->custom_response(401, '<!--No Access-->' );
         $r->status(401);
      }
   } else {
      $session{header}{status} = 401;
   }
   my ($output);
   if ($session{user}{userId} <= 1) {
      $output = WebGUI::Operation::Auth::www_auth("init");
   } else {
      $output = '<h1>'.WebGUI::International::get(37).'</h1>';
      $output .= WebGUI::International::get(39);
      $output .= '<p>';
   }
   return $output;
}

#-------------------------------------------------------------------

=head2 notMember ( )

Returns a message stating that the user they requested information about is no longer active on this server. This method also sets the HTTP header status to 400.

=cut

sub notMember {
	if($session{env}{MOD_PERL}) {
                my $r = Apache->request;
                if(defined($r)) {
                        $r->custom_response(400, '<!--Not A Member-->' );
                        $r->status(400);
                }
        } else {
		$session{header}{status} = 400;
	}
	my ($output);
	$output = '<h1>'.WebGUI::International::get(345).'</h1>';
	$output .= WebGUI::International::get(346);
	$output .= '<p>';
	return $output;
}

#-------------------------------------------------------------------

=head2 vitalComponent ( )

Returns a message stating that the user made a request to delete something that should never delete. This method also sets the HTTP header status to 403. 

=cut

sub vitalComponent {
        if($session{env}{MOD_PERL}) {
                my $r = Apache->request;
                if(defined($r)) {
                        $r->custom_response(403, '<!--Vital Component-->' );
                        $r->status(403);
                }
        } else {
                $session{header}{status} = 403;
        }
	my ($output);
        $output = '<h1>'.WebGUI::International::get(40).'</h1>';
	$output .= WebGUI::International::get(41);
	$output .= '<p>';
	return $output;
}






1;

