package WebGUI::Group;

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
use WebGUI::DateTime;
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

 $dateCreated =     	$g->dateCreated;
 $description =        	$g->description("Those really smart dudes.");
 $expireAfter =        	$g->expireAfter(360000);
 $groupId =     	$g->groupId;
 $karmaThreshold =     	$g->karmaThreshold(5000);
 $ipFilter =        	$g->ipFilter("10.;192.168.1.");
 $lastUpdated =     	$g->lastUpdated;
 $name =            	$g->name("Nerds");

 $g->addGroups(\@arr);
 $g->deleteGroups(\@arr);
 $g->delete;

=head1 METHODS

These methods are available from this class:

=cut


#-------------------------------------------------------------------
sub _create {
        my $groupId = getNextId("groupId");
        WebGUI::SQL->write("insert into groups (groupId,dateCreated,expireAfter,karmaThreshold) values 
		($groupId,".time().",314496000,1000000000)");
        return $groupId;
}

#-------------------------------------------------------------------

=head2 addGroups ( groups )

Adds groups to this group.

=over

=item groups

An array reference containing the list of group ids to add to this group.

=back

=cut

sub addGroups {
	WebGUI::Grouping::addGroupsToGroups($_[1],[$_[0]->{_groupId}]);
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
        WebGUI::SQL->write("delete from groups where groupId=".$_[0]->{_groupId});
        WebGUI::SQL->write("delete from groupings where groupId=".$_[0]->{_groupId});
        WebGUI::SQL->write("delete from groupGroupings where inGroup=".$_[0]->{_groupId}." or groupId=".$_[0]->{_groupId});
}

#-------------------------------------------------------------------

=head2 deleteGroups ( groups )

Deletes groups from this group.

=over

=item groups

An array reference containing the list of group ids to delete from this group.

=back

=cut

sub deleteGroups {
	WebGUI::Grouping::deleteGroupsFromGroups($_[1],[$_[0]->{_groupId}]);
}


#-------------------------------------------------------------------

=head2 description ( [ value ] )

Returns the description of this group.

=over

=item value

If specified, the description is set to this value.

=back

=cut

sub description {
        my ($class, $value);
        $class = shift;
        $value = shift;
        if (defined $value) {
                $class->{_group}{"description"} = $value;
                WebGUI::SQL->write("update groups set description=".quote($value).",
                        lastUpdated=".time()." where groupId=$class->{_groupId}");
        }
        return $class->{_group}{"description"};
}


#-------------------------------------------------------------------

=head2 expireAfter ( [ value ] )

Returns the number of seconds any grouping with this group should expire after.

=over

=item value

If specified, expireAfter is set to this value.

=back

=cut

sub expireAfter {
        my ($class, $value);
        $class = shift;
        $value = shift;
        if (defined $value) {
                $class->{_group}{"expireAfter"} = $value;
                WebGUI::SQL->write("update groups set expireAfter=".quote($value).",
                        lastUpdated=".time()." where groupId=$class->{_groupId}");
        }
        return $class->{_group}{"expireAfter"};
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

=over

=item value

If specified, the karma threshold is set to this value.

=back

=cut

sub karmaThreshold {
        my ($class, $value);
        $class = shift;
        $value = shift;
        if (defined $value) {
                $class->{_group}{"karmaThreshold"} = $value;
                WebGUI::SQL->write("update groups set karmaThreshold=".quote($value).",
                        lastUpdated=".time()." where groupId=$class->{_groupId}");
        }
        return $class->{_group}{"karamThreshold"};
}


#-------------------------------------------------------------------

=head2 ipFilter ( [ value ] )

Returns the ip address range(s) the user must be a part of to belong to this group.

=over

=item value

If specified, the ipFilter is set to this value.

=back

=cut

sub ipFilter {
        my ($class, $value);
        $class = shift;
        $value = shift;
        if (defined $value) {
                $class->{_group}{"ipFilter"} = $value;
                WebGUI::SQL->write("update groups set ipFilter=".quote($value).",
                        lastUpdated=".time()." where groupId=$class->{_groupId}");
        }
        return $class->{_group}{"ipFilter"};
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

=over

=item value

If specified, the name is set to this value.

=back

=cut

sub name {
        my ($class, $value);
        $class = shift;
        $value = shift;
        if (defined $value) {
                $class->{_group}{"groupName"} = $value;
                WebGUI::SQL->write("update groups set groupName=".quote($value).",
                        lastUpdated=".time()." where groupId=$class->{_groupId}");
        }
        return $class->{_group}{"groupName"};
}


#-------------------------------------------------------------------

=head2 new ( groupId )

Constructor.

=over

=item groupId

The groupId of the group you're creating an object reference for. If specified as "new" then a new group will be created and assigned the next available groupId. If left blank then the object methods will just return default values for everything.

=back

=cut

sub new {
        my ($class, $groupId, %default, $value, $key, %group, %profile);
        tie %group, 'Tie::CPHash';
        $class = shift;
	$groupId = shift;
        $groupId = _create() if ($groupId eq "new");
	if ($groupId eq "") {
		$group{expireAfter} = 314496000;
		$group{karmaThreshold} = 1000000000;
		$group{groupName} = "New Group";
	} else {
        	%group = WebGUI::SQL->quickHash("select * from groups where groupId='$groupId'");
	}
        bless {_groupId => $groupId, _group => \%group }, $class;
}



1;
