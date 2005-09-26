package WebGUI::Group;

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
use Tie::CPHash;
use WebGUI::DateTime;
use WebGUI::Id;
use WebGUI::Grouping;
use WebGUI::Session;
use WebGUI::SQL;

=head1 NAME

Package WebGUI::Group

=head1 DESCRIPTION

This package provides an object-oriented way of managing WebGUI groups and groupings.

=head1 SYNOPSIS

 use WebGUI::Group;
 $g = WebGUI::Group->new(3); or  $g = WebGUI::User->new("new");
 $g = WebGUI::Group->find("Registered Users");

 $boolean =    	$g->autoAdd(1);
 $boolean =    	$g->autoDelete(1);
 $epoch =     	$g->dateCreated;
 $integer =	$g->deleteOffset(14);
 $text =       	$g->description("Those really smart dudes.");
 $integer =	$g->expireNotify(1);
 $integer = 	$g->expireNotifyMessage("You're outta here!");
 $integer =	$g->expireNotifyOffset(-14);
 $integer =    	$g->expireOffset(360000);
 $integer =    	$g->groupId;
 $boolean = 	$g->isEditable(1);
 $integer =   	$g->karmaThreshold(5000);
 $string =     	$g->ipFilter("10.;192.168.1.");
 $epoch =     	$g->lastUpdated;
 $string =     	$g->name("Nerds");
 $string =     	$g->scratchFilter("www_location=International;somesetting=1");
 $boolean = 	$g->showInForms(1);
 

 $g->addGroups(\@arr);
 $g->addUsers(\@arr);
 $g->deleteGroups(\@arr);
 $g->deleteUsers(\@arr);
 $g->delete;

=head1 METHODS

These methods are available from this class:

=cut


#-------------------------------------------------------------------
sub _create {
        my $groupId = WebGUI::Id::generate();
        WebGUI::SQL->write("insert into groups (groupId,dateCreated,expireOffset,karmaThreshold) values 
		(".quote($groupId).",".time().",314496000,1000000000)");
	WebGUI::Grouping::addGroupsToGroups([3],[$groupId]);
        return $groupId;
}

#-------------------------------------------------------------------

=head2 addGroups ( groups )

Adds groups to this group.

=head3 groups

An array reference containing the list of group ids to add to this group.

=cut

sub addGroups {
	WebGUI::Grouping::addGroupsToGroups($_[1],[$_[0]->{_groupId}]);
}

#-------------------------------------------------------------------

=head2 addUsers ( users )

Adds users to this group.

=head3 users

An array reference containing the list of user ids to add to this group.

=cut

sub addUsers {
	WebGUI::Grouping::addUsersToGroups($_[1],[$_[0]->{_groupId}]);
}

#-------------------------------------------------------------------

=head2 autoAdd ( [ value ] )

Returns an boolean stating whether users can add themselves to this group.

=head3 value

If specified, the autoAdd is set to this value.

=cut

sub autoAdd {
        my ($class, $value);
        $class = shift;
        $value = shift;
        if (defined $value) {
                $class->{_group}{"autoAdd"} = $value;
                WebGUI::SQL->write("update groups set autoAdd=".quote($value).",
                        lastUpdated=".time()." where groupId=".quote($class->{_groupId}));
        }
        return $class->{_group}{"autoAdd"};
}


#-------------------------------------------------------------------

=head2 autoDelete ( [ value ] )

Returns an boolean stating whether users can delete themselves from this group.

=head3 value

If specified, the autoDelete is set to this value.

=cut

sub autoDelete {
        my ($class, $value);
        $class = shift;
        $value = shift;
        if (defined $value) {
                $class->{_group}{"autoDelete"} = $value;
                WebGUI::SQL->write("update groups set autoDelete=".quote($value).",
                        lastUpdated=".time()." where groupId=".quote($class->{_groupId}));
        }
        return $class->{_group}{"autoDelete"};
}


#-------------------------------------------------------------------

=head2 dateCreated ( )

Returns the epoch for when this group was created.

=cut

sub dateCreated {
        return $_[0]->{_group}{dateCreated};
}


#-------------------------------------------------------------------

=head2 delete ( )

Deletes this group and all references to it.

=cut

sub delete {
        WebGUI::SQL->write("delete from groups where groupId=".quote($_[0]->{_groupId}));
        WebGUI::SQL->write("delete from groupings where groupId=".quote($_[0]->{_groupId}));
        WebGUI::SQL->write("delete from groupGroupings where inGroup=".quote($_[0]->{_groupId})." or groupId=".quote($_[0]->{_groupId}));
}

#-------------------------------------------------------------------

=head2 deleteGroups ( groups )

Deletes groups from this group.

=head3 groups

An array reference containing the list of group ids to delete from this group.

=cut

sub deleteGroups {
	WebGUI::Grouping::deleteGroupsFromGroups($_[1],[$_[0]->{_groupId}]);
}

#-------------------------------------------------------------------

=head2 deleteUsers ( users )

Deletes users from this group.

=head3 users

An array reference containing the list of user ids to delete from this group.

=cut

sub deleteUsers {
	WebGUI::Grouping::deleteUsersFromGroups($_[1],[$_[0]->{_groupId}]);
}


#-------------------------------------------------------------------

=head2 deleteOffset ( [ value ] )

Returns the number of days after the expiration to delete the grouping.

=head3 value

If specified, deleteOffset is set to this value. Defaults to "-14".

=cut

sub deleteOffset {
        my ($class, $value);
        $class = shift;
        $value = shift;
        if (defined $value) {
                $class->{_group}{"deleteOffset"} = $value;
                WebGUI::SQL->write("update groups set deleteOffset=$value,
                        lastUpdated=".time()." where groupId=".quote($class->{_groupId}));
        }
        return $class->{_group}{"deleteOffset"};
}


#-------------------------------------------------------------------

=head2 description ( [ value ] )

Returns the description of this group.

=head3 value

If specified, the description is set to this value.

=cut

sub description {
        my ($class, $value);
        $class = shift;
        $value = shift;
        if (defined $value) {
                $class->{_group}{"description"} = $value;
                WebGUI::SQL->write("update groups set description=".quote($value).",
                        lastUpdated=".time()." where groupId=".quote($class->{_groupId}));
        }
        return $class->{_group}{"description"};
}


#-------------------------------------------------------------------

=head2 expireNotify ( [ value ] )

Returns a boolean value whether or not to notify the user of the group expiry.

=head3 value

If specified, expireNotify is set to this value.

=cut

sub expireNotify {
        my ($class, $value);
        $class = shift;
        $value = shift;
        if (defined $value) {
                $class->{_group}{"expireNotify"} = $value;
                WebGUI::SQL->write("update groups set expireNotify=$value,
                        lastUpdated=".time()." where groupId=".quote($class->{_groupId}));
        }
        return $class->{_group}{"expireNotify"};
}


#-------------------------------------------------------------------

=head2 expireNotifyMessage ( [ value ] )

Returns the message to send to the user about expiration.

=head3 value

If specified, expireNotifyMessage is set to this value.

=cut

sub expireNotifyMessage {
        my ($class, $value);
        $class = shift;
        $value = shift;
        if (defined $value) {
                $class->{_group}{"expireNotifyMessage"} = $value;
                WebGUI::SQL->write("update groups set expireNotifyMessage=".quote($value).",
                        lastUpdated=".time()." where groupId=".quote($class->{_groupId}));
        }
        return $class->{_group}{"expireNotifyMessage"};
}



#-------------------------------------------------------------------

=head2 expireNotifyOffset ( [ value ] )

Returns the number of days after the expiration to notify the user.

=head3 value

If specified, expireNotifyOffset is set to this value. 

=cut

sub expireNotifyOffset {
        my ($class, $value);
        $class = shift;
        $value = shift;
        if (defined $value) {
                $class->{_group}{"expireNotifyOffset"} = $value;
                WebGUI::SQL->write("update groups set expireNotifyOffset=$value,
                        lastUpdated=".time()." where groupId=".quote($class->{_groupId}));
        }
        return $class->{_group}{"expireNotifyOffset"};
}


#-------------------------------------------------------------------

=head2 expireOffset ( [ value ] )

Returns the number of seconds any grouping with this group should expire after.

=head3 value

If specified, expireOffset is set to this value.

=cut

sub expireOffset {
        my $class = shift;
        my $value = shift;
        if (defined $value) {
                $class->{_group}{"expireOffset"} = $value;
                WebGUI::SQL->write("update groups set expireOffset=".quote($value).",
                        lastUpdated=".time()." where groupId=".quote($class->{_groupId}));
        }
        return $class->{_group}{"expireOffset"};
}


#-------------------------------------------------------------------

=head2 find ( name )

An alternative to the constructor "new", use find as a constructor by name rather than id.

=head3 name

The name of the group you wish to instantiate.

=cut

sub find {
	my $class = shift;
	my $name = shift;
	my ($groupId) = WebGUI::SQL->quickArray("select groupId from groups where groupName=".quote($name));
	return WebGUI::Group->new($groupId);
}


#-------------------------------------------------------------------

=head2 groupId ( )

Returns the groupId for this group.

=cut

sub groupId {
        return $_[0]->{_groupId};
}


#-------------------------------------------------------------------

=head2 karmaThreshold ( [ value ] )

Returns the amount of karma required to be in this group.

=head3 value

If specified, the karma threshold is set to this value.

=cut

sub karmaThreshold {
        my ($class, $value);
        $class = shift;
        $value = shift;
        if (defined $value) {
                $class->{_group}{"karmaThreshold"} = $value;
                WebGUI::SQL->write("update groups set karmaThreshold=".quote($value).",
                        lastUpdated=".time()." where groupId=".quote($class->{_groupId}));
        }
        return $class->{_group}{"karmaThreshold"};
}


#-------------------------------------------------------------------

=head2 ipFilter ( [ value ] )

Returns the ip address range(s) the user must be a part of to belong to this group.

=head3 value

If specified, the ipFilter is set to this value.

=cut

sub ipFilter {
        my ($class, $value);
        $class = shift;
        $value = shift;
        if (defined $value) {
                $class->{_group}{"ipFilter"} = $value;
                WebGUI::SQL->write("update groups set ipFilter=".quote($value).",
                        lastUpdated=".time()." where groupId=".quote($class->{_groupId}));
        }
        return $class->{_group}{"ipFilter"};
}


#-------------------------------------------------------------------

=head2 isEditable ( [ value ] )

Returns a boolean value indicating whether the group should be managable from the group manager. System level groups and groups autocreated by wobjects would use this parameter.

=head3 value

If specified, isEditable is set to this value.

=cut

sub isEditable {
        my ($class, $value);
        $class = shift;
        $value = shift;
        if (defined $value) {
                $class->{_group}{"isEditable"} = $value;
                WebGUI::SQL->write("update groups set isEditable=".quote($value).",
                        lastUpdated=".time()." where groupId=".quote($class->{_groupId}));
        }
        return $class->{_group}{"isEditable"};
}


#-------------------------------------------------------------------

=head2 lastUpdated ( )

Returns the epoch for when this group was last modified.

=cut

sub lastUpdated {
        return $_[0]->{_group}{lastUpdated};
}


#-------------------------------------------------------------------

=head2 name ( [ value ] )

Returns the name of this group.

=head3 value

If specified, the name is set to this value.

=cut

sub name {
        my ($class, $value);
        $class = shift;
        $value = shift;
        if (defined $value) {
                $class->{_group}{"groupName"} = $value;
                WebGUI::SQL->write("update groups set groupName=".quote($value).",
                        lastUpdated=".time()." where groupId=".quote($class->{_groupId}));
        }
        return $class->{_group}{"groupName"};
}


#-------------------------------------------------------------------

=head2 new ( groupId )

Constructor.

=head3 groupId

The groupId of the group you're creating an object reference for. If specified as "new" then a new group will be created and assigned the next available groupId. If left blank then the object methods will just return default values for everything.

=cut

sub new {
        my ($class, $groupId, %default, $value, $key, %group, %profile);
        tie %group, 'Tie::CPHash';
        $class = shift;
	$groupId = shift;
        $groupId = _create() if ($groupId eq "new");
	if ($groupId eq "") {
		$group{expireOffset} = 314496000;
		$group{karmaThreshold} = 1000000000;
		$group{groupName} = "New Group";
		$group{expireNotifyOffset} = -14;
		$group{deleteOffset} = 14;
		$group{expireNotify} = 0;
		$group{databaseLinkId} = 0;
		$group{dbCacheTimeout} = 3600;
	} else {
        	%group = WebGUI::SQL->quickHash("select * from groups where groupId=".quote($groupId));
	}
        bless {_groupId => $groupId, _group => \%group }, $class;
}

#-------------------------------------------------------------------

=head2 scratchFilter ( [ value ] )

Returns the name of this group.

=head3 value

If specified, the name is set to this value.

=cut

sub scratchFilter {
        my ($class, $value);
        $class = shift;
        $value = shift;
        if (defined $value) {
                $class->{_group}{"scratchFilter"} = $value;
                WebGUI::SQL->write("update groups set scratchFilter=".quote($value).",
                        lastUpdated=".time()." where groupId=".quote($class->{_groupId}));
        }
        return $class->{_group}{"scratchFilter"};
}

#-------------------------------------------------------------------

=head2 showInForms ( [ value ] )

Returns a boolean value indicating whether the group should show in forms that display a list of groups. System level groups and groups autocreated by wobjects would use this parameter.

=head3 value

If specified, showInForms is set to this value.

=cut

sub showInForms {
        my ($class, $value);
        $class = shift;
        $value = shift;
        if (defined $value) {
                $class->{_group}{"showInForms"} = $value;
                WebGUI::SQL->write("update groups set showInForms=".quote($value).",
                        lastUpdated=".time()." where groupId=".quote($class->{_groupId}));
        }
        return $class->{_group}{"showInForms"};
}


#-------------------------------------------------------------------

=head2 dbQuery ( )

=head2 dbQuery ( [ value ] )

Returns the dbQuery for this group.

=head3 value

If specified, the dbQuery is set to this value.

=cut

sub dbQuery {
        my ($class, $value);
        $class = shift;
        $value = shift;
        if (defined $value) {
                $class->{_group}{"dbQuery"} = $value;
                WebGUI::SQL->write("update groups set dbQuery=".quote($value).",
                        lastUpdated=".time()." where groupId=".quote($class->{_groupId}));
        }
        return $class->{_group}{"dbQuery"};
}

#-------------------------------------------------------------------

=head2 databaseLinkId ( [ value ] )

Returns the databaseLinkId for this group.

=head3 value

If specified, the databaseLinkId is set to this value.

=cut

sub databaseLinkId {
        my ($class, $value);
        $class = shift;
        $value = shift;
        if (defined $value) {
                $class->{_group}{"databaseLinkId"} = $value;
                WebGUI::SQL->write("update groups set databaseLinkId=".quote($value).",
                        lastUpdated=".time()." where groupId=".quote($class->{_groupId}));
        }
        return $class->{_group}{"databaseLinkId"};
}

#-------------------------------------------------------------------

=head2 dbCacheTimeout ( [ value ] )

Returns the dbCacheTimeout for this group.

=head3 value

If specified, the dbCacheTimeout is set to this value.

=cut

sub dbCacheTimeout {
        my ($class, $value);
        $class = shift;
        $value = shift;
        if (defined $value) {
                $class->{_group}{"dbCacheTimeout"} = $value;
                WebGUI::SQL->write("update groups set dbCacheTimeout=".quote($value).",
                        lastUpdated=".time()." where groupId=".quote($class->{_groupId}));
        }
        return $class->{_group}{"dbCacheTimeout"};
}

#-------------------------------------------------------------------

=head2 ldapGroup ( [ value ] )

Returns the ldapGroup for this group.

=head3 value

If specified, the ldapGroup is set to this value.

=cut

sub ldapGroup {
        my ($class, $value);
        $class = shift;
        $value = shift;
        if (defined $value) {
           $class->{_group}{"ldapGroup"} = $value;
           WebGUI::SQL->write("update groups set ldapGroup=".quote($value).",
                        lastUpdated=".time()." where groupId=".quote($class->{_groupId}));
        }
        return $class->{_group}{"ldapGroup"};
}

#-------------------------------------------------------------------

=head2 ldapGroupProperty ( [ value ] )

Returns the ldap group property for this group.

=head3 value

If specified, the ldapGroupProperty is set to this value.

=cut

sub ldapGroupProperty {
        my ($class, $value);
        $class = shift;
        $value = shift;
        if (defined $value) {
           $class->{_group}{"ldapGroupProperty"} = $value;
           WebGUI::SQL->write("update groups set ldapGroupProperty=".quote($value).",
                        lastUpdated=".time()." where groupId=".quote($class->{_groupId}));
        }
        return $class->{_group}{"ldapGroupProperty"};
}

#-------------------------------------------------------------------

=head2 ldapRecursiveProperty ( [ value ] )

Returns the ldap group recursive property used to find groups of groups.

=head3 value

If specified, the ldapRecursiveProperty is set to this value.

=cut

sub ldapRecursiveProperty {
   my ($class, $value);
   $class = shift;
   $value = shift;
   if (defined $value) {
      $class->{_group}{"ldapRecursiveProperty"} = $value;
      WebGUI::SQL->write("update groups set ldapRecursiveProperty=".quote($value).", lastUpdated=".time()." where groupId=".quote($class->{_groupId}));
   }
   return $class->{_group}{"ldapRecursiveProperty"};
}

1;
