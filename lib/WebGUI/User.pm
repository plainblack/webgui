package WebGUI::User;

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
use WebGUI::Group;
use WebGUI::Workflow::Instance;
use JSON ();
use WebGUI::Exception;
use WebGUI::ProfileField;
use WebGUI::Inbox;
use Scalar::Util qw( weaken );
use Net::CIDR::Lite;

=head1 NAME

Package WebGUI::User

=head1 DESCRIPTION

This package provides an object-oriented way of managing WebGUI users as well as getting/setting a users's profile data.

=head1 SYNOPSIS

 use WebGUI::User;
 $u = WebGUI::User->new($session,3);
 $u = WebGUI::User->new($session,"new");
 $u = WebGUI::User->newByEmail($session, $email);
 $u = WebGUI::User->newByUsername($session, $username);

 # Get data
 $authMethod            = $u->get("authMethod");
 $dateCreated           = $u->get("dateCreated");
 $karma                 = $u->karma;
 $lastUpdated           = $u->get("lastUpdated");
 $languagePreference    = $u->get("language");
 $referringAffiliate    = $u->get("referringAffiliate");
 $status                = $u->get("status");
 $username              = $u->get("username");
 $arrayRef              = $u->getGroups;
 $isMember              = $u->isInGroup($groupId);

 # Update data
 $u->update({
     username       => "m_bolton",
     firstName      => "Mike",
     likesSoftPop   => 1,
 });
 $u->addToGroups(\@arr);
 $u->deleteFromGroups(\@arr);
 $u->delete;
 $u->enable;
 $u->disable;

 WebGUI::User->validUserId($session, $userId);

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------
# TODO This stays like this until we can break API, just in case somebody
# doesn't realize that _ means private.
# After API unfreeze, put this in the WebGUI::User->create routine
sub _create {
    my $session = shift;
    my $userId = shift || $session->id->generate();
    $session->db->write("insert into users (userId,dateCreated) values (?,?)",[$userId, time()]);
    $session->db->write("INSERT INTO userProfileData (userId) VALUES (?)",[$userId]);

    # Set wg_privacySettings
    my @fields     = @{WebGUI::ProfileField->getFields($session)};
    my $privacy  = {};
    foreach my $field (@fields) {
        #$session->log->warn('getting privacy setting for field: '.$fieldName);
        my $privacySetting = $field->get('defaultPrivacySetting');
        next unless $privacySetting ~~ [qw(all none friends)];
        $privacy->{$field->get('fieldName')} = $privacySetting;
    }
    my $json = JSON->new->encode($privacy);
    $session->db->write("update userProfileData set wg_privacySettings=? where userId=?",[$json,$userId]);

    WebGUI::Group->new($session,2)->addUsers([$userId]);
    WebGUI::Group->new($session,7)->addUsers([$userId]);
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
	foreach my $groupId (@{$groups}) {
		WebGUI::Group->new($self->session,$groupId)->addUsers([$self->userId],$expireOffset);
	}
	$self->session->stow->delete("gotGroupsForUser");
}

#-------------------------------------------------------------------

=head2 acceptsPrivateMessages ( userId )

Returns a boolean of whether or not the user can receive private messages from the user passed in

=head3 userId

userId to determine if the user accepts private messages from

=cut

sub acceptsPrivateMessages {
    my $self      = shift;
    my $userId    = shift;

    return 0 if ($self->isVisitor);  #Visitor can't get private messages
    return 0 if ($userId eq "1");    # Visitor can't send private messages
    return 0 if ($self->userId eq $userId);  #Can't send private messages to yourself

    my $pmSetting = $self->profileField('allowPrivateMessages');

    return 0 if ($pmSetting eq "none");
    return 1 if ($pmSetting eq "all");

    if($pmSetting eq "friends") {
        my $friendsGroup = $self->friends;
        my $sentBy       = WebGUI::User->new($self->session,$userId);
        #$self->session->log->warn($self->isInGroup($friendsGroup->getId));
        return $sentBy->isInGroup($friendsGroup->getId);
    }

    return 0;
}

#-------------------------------------------------------------------

=head2 acceptsFriendsRequests ( user )

Returns whether or this user will accept friends requests from the user passed in

=head3 user

WebGUI::User object to check to see if user will accept requests from.

=cut

sub acceptsFriendsRequests {
    my $self    = shift;
    my $session = $self->session;
    my $user    = shift;

    return 0 unless ($user && ref $user eq "WebGUI::User"); #Sanity checks
    return 0 if($self->isVisitor);  #Visitors can't have friends
    return 0 if($user->isVisitor);  #Visitor can't be your friend either
    return 0 if($self->userId eq $user->userId);  #Can't be your own friend (why would you want to be?)

    my $me     = WebGUI::Friends->new($session,$self);
    return 0 if ($me->isFriend($user->userId));  #Already a friend

    my $friend = WebGUI::Friends->new($session,$user);
    return 0 if ($me->isInvited($user->userId) || $friend->isInvited($self->userId)); #Invitation sent by one or the other

    return $self->profileField('ableToBeFriend'); #Return profile setting
}

#-------------------------------------------------------------------

=head2 authInstance

NOTE: This method is deprecated. Users may have any number of auth methods.
Instead, instantiate the desired auth method and give it the user's ID.

Returns an instance of the authentication object for this user.

=cut

# DEPRECATED. Remove in 9.0
sub authInstance {
    my $self    = shift;
    my $session = $self->session;

    my $authMethod;
    if ($self->isVisitor) {
        $authMethod = $session->setting->get("authMethod");
    }
    else {
        $authMethod = $self->authMethod || $session->setting->get("authMethod");
    }
    if ( ! $authMethod ~~ $session->config->get('authMethods') ) {
        $authMethod = $session->config->get('authMethods')->[0] || 'WebGUI';
    }
    my $authClass = 'WebGUI::Auth::' . $authMethod;
    WebGUI::Pluggable::load($authClass);
    my $auth = $authClass->new($session, $self->getId);
    return $auth;
}

#-------------------------------------------------------------------

=head2 authMethod ( [ value ] )

DEPRECATED! Use get("authMethod") and update({ authMethod => "value })

Returns the authentication method for this user.

=head3 value

If specified, the authMethod is set to this value. The only valid values are "WebGUI" and "LDAP". When a new account is created, authMethod is defaulted to "WebGUI".

=cut

sub authMethod {
        my ($self, $value);
        $self = shift;
        $value = shift;
        if (defined $value) {
            $self->update({ authMethod => $value });
        }
        return $self->get("authMethod");
}

#-------------------------------------------------------------------

=head2 create ( session, [userId] )

Create a new user. C<userId> is an option user ID to give the new user.
Returns the newly created WebGUI::User object.

=cut

sub create {
    my $class   = shift;
    my $session = shift;
    my $userId  = shift;

    if ( !ref $session || !$session->isa( 'WebGUI::Session' ) ) {
        WebGUI::Error::InvalidObject->throw(
            expected => "WebGUI::Session",
            got      => (ref $session),
            error    => q{Must provide a session variable},
        );
    }

    return WebGUI::User->new( $session, "new", $userId );
}

#-------------------------------------------------------------------

=head2 cache ( )

Saves the user object into the cache.

=cut

sub cache {
    my $self = shift;
    # copy user object
    my %userData;
    for my $k (qw(_userId _user _profile)) {
        $userData{$k} = $self->{$k};
    }
    $self->session->cache->set("user_" . $self->userId, \%userData, 60*60*24);
}

#-------------------------------------------------------------------

=head2 canUseAdminMode ( )

Returns a boolean indicating whether the user has the basic privileges needed to turn on admin mode and use basic admin functions. Note this isn't checking for any special privileges like whether the user can create new users, etc.

=cut

sub canUseAdminMode {
        my $self = shift;
	my $pass = 1;
	my $subnets = $self->session->config->get("adminModeSubnets") || [];
	if (scalar(@$subnets)) {
		$pass = Net::CIDR::Lite->new(@$subnets)->find($self->session->request->address);
	}

	return $pass && $self->isInGroup(12)
}

#-------------------------------------------------------------------

=head2 canViewField ( field, user)

Returns whether or not the user passed in can view the field value for the user.
This will only check the user level privileges.

=head3 field

Field to check privileges on

=head3 user

User to check field privileges for

=cut

sub canViewField {
    my $self      = shift;
    my $session   = $self->session;
    my $field     = shift;
    my $user      = shift;

    return 0 unless ($field && $user);
    #Always true for yourself
    return 1 if ($self->userId eq $user->userId);
    
    my $privacySetting = $self->getProfileFieldPrivacySetting($field);
    return 0 unless $privacySetting ~~ [qw(all none friends)];
    return 1 if ($privacySetting eq "all");
    return 0 if ($privacySetting eq "none");

    #It's friends so return whether or not user is a friend
    return WebGUI::Friends->new($session,$self)->isFriend($user->userId); 
}   

#-------------------------------------------------------------------

=head2 dateCreated ( )

DEPRECATED! Use get("dateCreated") instead

Returns the epoch for when this user was created.

=cut

sub dateCreated {
        my ( $self ) = @_;
        return $self->get("dateCreated");
}

#-------------------------------------------------------------------

=head2 delete ( )

Deletes this user, removes their user profile data, cleans up their
inbox, removes userSessionScratch data and authentication information,
removes them from any groups they belong to and deletes their
Friend's group.  Also deletes any address books and addresses that
belong to this user.

=cut

sub delete {
    my $self    = shift;
    my $userId  = $self->userId;
    my $session = $self->session;
    my $db      = $session->db;
    $self->uncache;

    foreach my $groupId ( @{ $self->getGroups } ) {
        my $group = WebGUI::Group->new($session, $groupId);
        $group->deleteUsers([$userId]) if $group;
    }

    # Delete all auth instances for this user
    $db->write( "DELETE FROM authentication WHERE userId=?", [ $userId ] );

    $self->friends->delete
        if ($self->{_user}{"friendsGroup"} ne "");

    # clean up any user workflows
    my $instances = WebGUI::Workflow::Instance->getInstancesForObject($session, {
        className       => ref $self,
        methodName      => 'new',
        parameters      => $self->getId,
        returnObjects   => 1,
    });
    for my $instance ( @{$instances} ) {
        $instance->delete;
    }

    # remove sessions
    $db->write(
        "DELETE FROM userSessionScratch WHERE sessionId IN (SELECT sessionId FROM userSession WHERE userId=?)",
        [$userId],
    );
    $db->write("DELETE FROM userSession WHERE userId=?",[$userId]);

    # remove inbox entries
    my $inbox = WebGUI::Inbox->new($session);
    $inbox->deleteMessagesForUser($self);

    # Shop cleanups
    my $sth = $session->db->prepare('select addressBookId from addressBook where userId=?');
    $sth->execute([$userId]);
    require WebGUI::Shop::AddressBook;
    BOOK: while (my $bookId = $sth->hashRef) {
        my $book;
        eval { $book =  WebGUI::Shop::AddressBook->new($session, $bookId->{addressBookId}); };
        next BOOK if (my $e = Exception::Class->caught);
        $book->delete;
    }

    require WebGUI::Shop::Credit;
    my $credit = WebGUI::Shop::Credit->new($session, $userId);
    $credit->purge;

    # remove user itself
    $db->write("DELETE FROM userProfileData WHERE userId=?",[$userId]);
    $db->write("DELETE FROM users WHERE userId=?",[$userId]);
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
	foreach my $groupId (@{$groups}) {
		WebGUI::Group->new($self->session,$groupId)->deleteUsers([$self->userId]);
	}
	$self->session->stow->delete("gotGroupsForUser");
}

#-------------------------------------------------------------------

=head2 DESTROY ( )

Deconstructor.

=cut

sub DESTROY {
        my $self = shift;
        if (exists $self->{_friendsGroup}) {
            $self->{_friendsGroup}->DESTROY;
        }
        undef $self;
}

#----------------------------------------------------------------------------

=head2 disable ( [options] )

Disable the user. C<options> is an optional hashref with the following keys:

 bySelf         - If true, the user is disabling themselves

=cut

sub disable {
    my ( $self, $options ) = @_;
    my $session     = $self->session;
    my $db          = $session->db;

    if ( $options->{bySelf} ) {
        $self->update({ status => "Selfdestructed" });
    }
    else {
        $self->update({ status => "Deactivated" });

        # Remove sessions
        my $rs = $db->read("select sessionId from userSession where userId=?",[$self->{_userId}]);
        while (my ($id) = $rs->array) {
            $db->write("delete from userSessionScratch where sessionId=?",[$id]);
        }
        $db->write("delete from userSession where userId=?",[$self->{_userId}]);
    }
}

#----------------------------------------------------------------------------

=head2 enable ( )

Enable the user.

=cut

sub enable {
    my ( $self ) = @_;
    $self->update({ status => "Active" });
}

#-------------------------------------------------------------------

=head2 friends ( )

Returns the WebGUI::Group for this user's Friend's Group.  

=cut

sub friends {
    my $self = shift;
    my $myFriends;

    # If the user already has a friend group fetch it.
    if ( $self->{_user}{"friendsGroup"} ne "" ) {
        if ( ! exists $self->{_friendsGroup} ) {
            # Friends group is not in cache, so instantiate and cache it.
            $myFriends = WebGUI::Group->new($self->session, $self->{_user}{"friendsGroup"});
            $self->{_friendsGroup} = $myFriends;
        }
        else {
            # Friends group is cached, so fetch it from cache.
            $myFriends = $self->{_friendsGroup};
        }
    }

    # If there's no instantiated friends group, either the user has none yet or the group has been deleted. 
    # Whatever the reason may be, we need to create a new friends group for this user.
    unless ( $myFriends ) {
        $myFriends = WebGUI::Group->new($self->session, "new",0,1);
        $myFriends->name($self->username." Friends");
        $myFriends->description("Friends of user ".$self->userId);
        $myFriends->expireOffset(60*60*24*365*60);
        $myFriends->showInForms(0);
        $myFriends->isEditable(0);
        $self->uncache;
        $self->{_user}{"friendsGroup"} = $myFriends->getId;
        $self->{_user}{"lastUpdated"} = time();
        $self->session->db->write("update users set friendsGroup=?, lastUpdated=? where userId=?",
            [$myFriends->getId, time(), $self->userId]);
        $self->{_friendsGroup} = $myFriends;
    }

    return $myFriends;
}

#----------------------------------------------------------------------------

=head2 get ( [field] )

Get properties for this user. If C<field> is defined, will return the value
of the field. Otherwise, returns a hash reference of all properties and profile
fields.

=cut

sub get {
    my ( $self, $field ) = @_;
    my $session     = $self->session;

    if ( $field ) {
        if ( exists $self->{_user}->{$field} ) {
            return $self->{_user}->{$field};
        }
        else {
            # XXX Should the defaults be set in new() ...
            if ( !exists $self->{_profile}->{$field} ) {
                if ( !WebGUI::ProfileField->exists( $session, $field ) ) {
                    $self->session->log->warn("No such profile field: $field");
                }

                my $default = $session->db->quickScalar("SELECT dataDefault FROM userProfileField WHERE fieldName=?", [$field]);
                $self->{_profile}{$field}
                    = WebGUI::Operation::Shared::secureEval($session, $default);
                $self->cache; # XXX ... Because we cache them here!
            }
            if (ref $self->{_profile}{$field} eq 'ARRAY') {
                ##Return a scalar, that is a string with all the defaults
                return join ',', @{ $self->{_profile}{$field} };
            }
            return $self->{_profile}->{$field};
        }
    }

    # Add any missing fields
    my %default     = $session->db->buildHash(
        "SELECT fieldName, dataDefault FROM userProfileField",
    );
    for my $key ( keys %default ) {
        if ( !exists $self->{_profile}{$key} ) {
            $self->{_profile}{$key}
                = WebGUI::Operation::Shared::secureEval($session, $default{$key});
        }
    }

    # Create a safe copy of everything to return
    my %properties  = (
        %{$self->{_user}},
        %{$self->{_profile}},
    );

    return \%properties;
}

#-------------------------------------------------------------------

=head2 getFirstName ( )

Returns first name, or alias, or username depeneding upon what exists.

=cut

sub getFirstName {
    my $self = shift;
    return $self->profileField('firstName') || $self->profileField('alias') || $self->username;
}   

#-------------------------------------------------------------------

=head2 getGroups ( [ withoutExpired ] )

Returns an array reference containing a list of groups this user is in.  Group lookups are cached.
If a cached lookup is returned, it will be a safe copy of the data in the cache.

=head3 withoutExpired

If set to "1" then the listing will not include expired groupings. Defaults to "0".

=cut

sub getGroups {
    my $self = shift;
    my $withoutExpired = shift;
    my $clause = "";
    if ($withoutExpired) {
        $clause = "and expireDate>".time();
    }
    my $gotGroupsForUser = $self->session->stow->get("gotGroupsForUser");
    if (exists $gotGroupsForUser->{$self->userId}) {
        my $cachedGroups = $gotGroupsForUser->{$self->userId};
        my @safeCopy = @{ $cachedGroups };
        return \@safeCopy;
    }
    else {
        my @groups = $self->session->db->buildArray("select groupId from groupings where userId=? $clause", [$self->userId]);
        my $isInGroup = $self->session->stow->get("isInGroup");
        foreach my $gid (@groups) {
            $isInGroup->{$self->userId}{$gid} = 1;
        }
        $self->session->stow->set("isInGroup",$isInGroup);
        $gotGroupsForUser->{$self->userId} = \@groups;
        $self->session->stow->set("gotGroupsForUser",$gotGroupsForUser);
        my @safeGroups = @groups;
        return \@safeGroups;
    }
}

#----------------------------------------------------------------------------

=head2 getGroupIdsRecursive ( )

Get the groups the user is in AND all the groups those groups are in, recursively.
Returns a flattened array reference of unique group IDs

=cut

sub getGroupIdsRecursive {
    my $self        = shift;
    my $groupingIds = $self->getGroups( "withoutExpired" );
    my %groupIds    = map { $_ => 1 } @{ $groupingIds };
    while ( my $groupingId = shift @{ $groupingIds } ) {
        my $group   = WebGUI::Group->new( $self->session, $groupingId );
        for my $groupGroupingId ( @{ $group->getGroupsFor } ) { 
            if ( !$groupIds{ $groupGroupingId } ) {
                push @{ $groupingIds }, $groupGroupingId;
            }
            $groupIds{ $groupGroupingId } = 1;
        }
    }

    return [ keys %groupIds ];
}

#----------------------------------------------------------------------------

=head2 getId ( )

Get the user's ID

=cut

sub getId {
    my ( $self ) = @_;
    return $self->{_userId};
}

#-------------------------------------------------------------------

=head2 getInboxNotificationAddresses ( )

Return a string with addresses that the user wants to receive Inbox
notifications.  If the user does not want Inbox notifications, then
the string will be empty.

This is called by L<WebGUI::Mail::Send>, and has the effect that if
the site C<sendInboxNotificationsOnly> setting is on and the user
has turned off C<receiveInboxEmailNotifications>, no email at all is
sent.

=cut

sub getInboxNotificationAddresses {
    my $self   = shift;
    my $emails = '';
    if ( $self->profileField('receiveInboxEmailNotifications')
      && $self->profileField('email')) {
        $emails = $self->profileField('email');
    }
    return $emails;
}

#-------------------------------------------------------------------

=head2 getInboxSmsNotificationAddress ( )

Return the email address that SMS notifications will be sent to for
this user, constructed as:

 cellPhone@smsGateway

Non digits, such as area code separators, are removed from the cell phone information.

=cut

sub getInboxSmsNotificationAddress {
    my $self   = shift;
    
    return unless $self->profileField('receiveInboxSmsNotifications');
    
    my $smsGateway = $self->session->setting->get('smsGateway');
    return unless $smsGateway;
    
    my $cellPhone = $self->profileField('cellPhone');
    return unless $cellPhone;
    
    # Remove non-numbers from cellPhone
    $cellPhone =~ tr/0-9//dc;
    
    return join q{}, $cellPhone, '@', $smsGateway;
}   

#-------------------------------------------------------------------

=head2 getProfileFieldPrivacySetting ( [field ])

Returns the privacy setting for the field passed in.  If no field is passed in the entire hash is returned

=head3 field

Field to get privacy setting for.

=cut

sub getProfileFieldPrivacySetting {
    my $self      = shift;
    my $session   = $self->session;
    my $field     = shift;

    unless ($self->{_privacySettings}) {
        #Look it up manually because we want to cache this separately.
        my $privacySettings        = $session->db->quickScalar(
            q{select wg_privacySettings from userProfileData where userId=?},
            [$self->userId]
        );
        $privacySettings          = "{}" unless $privacySettings;
        $self->{_privacySettings} = JSON->new->decode($privacySettings);
    }
    
    return $self->{_privacySettings} unless ($field);

    #No privacy settings returned the privacy setting field
    return "none" if($field eq "wg_privacySettings");

    return $self->{_privacySettings}->{$field};
}   


#-------------------------------------------------------------------

=head2 getProfileUrl ( [page] )

Returns a link to the user's profile

=head3 page

If page is passed in, the profile ops will be appended to the page, otherwise
the method will return the ops appended to the current page.

=cut

sub getProfileUrl {
    my $self      = shift;
    my $session   = $self->session;
    my $page      = shift || $session->url->page;

    my $identifier = $session->config->get("profileModuleIdentifier");

    return $session->url->append($page,qq{op=account;module=$identifier;do=view;uid=}.$self->userId);

}   

#-------------------------------------------------------------------

=head2 getWholeName ( )

Attempts to build the user's whole name from profile fields, and ultimately their alias and username if all else
fails.

=cut

sub getWholeName {
    my $self  = shift;
    if ($self->profileField('firstName') and $self->profileField('lastName')) {
        return join ' ', $self->profileField('firstName'), $self->profileField('lastName');
    }
    return $self->profileField("alias") || $self->username;
}

#-------------------------------------------------------------------

=head2 hasFriends ( )

Returns whether or not the user has any friends on the site.

=cut

sub hasFriends {
    my $self         = shift;
    my $users = $self->friends->getUsers(1);
    return scalar(@{$users}) > 0;
}

#-------------------------------------------------------------------

=head2 identifier

This method is depricated and is provided only for reverse compatibility. See WebGUI::Auth instead.

=cut

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

=head2 isAdmin ()

Returns 1 if the user is in the admins group.

=cut

sub isAdmin {
	my $self = shift;
	return $self->isInGroup(3);
}

#-------------------------------------------------------------------

=head2 isEnabled ()

Returns 1 if the user is enabled.

=cut

sub isEnabled {
    my $self = shift;
    return $self->get('status') eq 'Active';
}

#-------------------------------------------------------------------

=head2 isInGroup ( [groupId ] )

Returns a boolean (0|1) value signifying that the user has the required privileges. Always returns true for Admins.

=head3 groupId

The group that you wish to verify against the user. Defaults to group with Id 3 (the Admin group).

=cut

sub isInGroup {
    my ($self, $gid) = @_;
    my $session   = $self->session;
    my $uid       = $self->userId;
    $gid          = 3 unless $gid;

	### The following several checks are to increase performance. If this section were removed, everything would continue to work as normal.
    return 1 if ($gid eq '7');      # everyone is in the everyone group
    return 1 if ($gid eq '1' && $uid eq '1');   # visitors are in the visitors group
    return 1 if ($gid eq '2' && $uid ne '1');   # if you're not a visitor, then you're a registered user

	### Check stow before we check the cache.  Stow is in memory and much faster
	my $stow          = $session->stow->get("isInGroup", { noclone => 1 }) || {};
	return $stow->{$uid}->{$gid} if (exists $stow->{$uid}->{$gid});
	
	### Don't bother checking File Cache if we already have a stow for this group.
	### We can find what we need there and save ourselves a bunch of time
	my $cache        = undef;
	my $groupMembers = undef;
	unless ($stow->{$uid}->{$gid}) {
		$groupMembers  = $session->cache->get("groupMembers".$gid) || {};
		#If we have this user's membership cached, return what we have stored
		if (exists $groupMembers->{$uid}) {
			return $groupMembers->{$uid}->{isMember} if (!$self->isVisitor);
			return $groupMembers->{$uid}->{$session->getId}->{isMember} #Include the session check for visitors
		}
	}
	
 	### Instantiate the group
    my $group = WebGUI::Group->new($session,$gid);
	if ( !$group ) {
        #Group is not valid, check the admin group
        $group = WebGUI::Group->new($session,3);
    }

	#Check the group for membership
	my $isInGroup = $group->hasUser($self);
	
	#Write what we found to file cache
	$group->cacheGroupings( $self, $isInGroup, $groupMembers );
	return $isInGroup;
}

#-------------------------------------------------------------------

=head2 isOnline ()

Returns a boolean indicating whether this user is logged in and actively viewing pages in the site.

=cut

sub isOnline {
    my $self = shift;
    my ($flag) = $self->session->db->quickArray('select count(*) from userSession where userId=? and lastPageView>=?',
        [$self->userId, time() - 60*10]); 
    return $flag;
}

#-------------------------------------------------------------------

=head2 isRegistered ()

Returns 1 if the user is not a visitor.

=cut

sub isRegistered {
	my $self = shift;
	return $self->userId ne '1';
}

#-------------------------------------------------------------------

=head2 isVisitor ()

Returns 1 if the user is a visitor.

=cut

sub isVisitor {
	my $self = shift;
	return $self->userId eq '1';
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

# NOTE: Should this be called "addKarma" instead?

sub karma {
	my $self = shift;
	my $amount = shift;
	my $source = shift;
	my $description = shift;
	if (defined $amount && defined $source && defined $description) {
		$self->uncache;
		$self->{_user}{karma} += $amount;
		$self->session->db->write("update users set karma=karma+? where userId=?", [$amount, $self->userId]);
        	$self->session->db->write("insert into karmaLog values (?,?,?,?,?)",[$self->userId, $amount, $source, $description, time()]);
	}
        return $self->{_user}{karma};
}

#-------------------------------------------------------------------

=head2 lastUpdated ( )

DEPRECATED! Use get("lastUpdated")

Returns the epoch for when this user was last modified.

=cut

sub lastUpdated {
        my ( $self ) = @_;
        return $self->get('lastUpdated');
}

#-------------------------------------------------------------------

=head2 new ( session, userId [, overrideId ] )

Constructor.

=head3 session 

The session variable.

=head3 userId 

The userId of the user you're creating an object reference for. If left blank it will default to "1" (Visitor). If specified as "new" then a new user account will be created and assigned the next available userId. 

=head3 overrideId

A unique ID to use instead of the ID that WebGUI will generate for you. It must be absolutely unique and can be up to 22 alpha numeric characters long.

=cut

sub new {
    my $class       = shift;
    my $session     = shift;
    my $userId      = shift || 1;
    my $overrideId  = shift;
    $userId         = _create($session, $overrideId) if ($userId eq "new");
    my $self        = $session->cache->get("user_" . $userId) || {};
    bless $self, $class;
    $self->{_session} = $session;
    weaken( $self->{_session} );
    unless ($self->{_userId} && $self->{_user}{username}) {
        my %user;
        %user = $session->db->quickHash("select * from users where userId=?",[$userId]);
        my %profile 
            = $session->db->quickHash(
                "select * from userProfileData where userId=?",
                [$user{userId}]
            );
        delete $profile{userId};
        delete $profile{wg_privacySettings};

        # Fill in dataDefault
        my $default = $session->db->buildHashRef(
            "SELECT fieldName, dataDefault FROM userProfileField", [],
            { noOrder => 1 },
        );
        for my $key (keys %profile) {
            if (!defined $profile{$key} || $profile{$key} eq '') {
                delete $profile{$key}
            }
        }

        if (($profile{alias} =~ /^\W+$/ || $profile{alias} eq "") and $user{username}) {
            $profile{alias} = $user{username};
        }
        $self->{_userId}    = $userId;
        $self->{_user}      = \%user,
        $self->{_profile}   = \%profile,
        $self->cache;
    }
    return $self;
}


#-------------------------------------------------------------------

=head2 newByEmail ( session, email )

Instanciates a user by email address. Returns undef if the email address could not be found.
Visitor may not be looked up with this method.

=head3 session

A reference to the current session.

=head3 email

The email address to search for.

=cut

sub newByEmail {
	my $class = shift;
	my $session = shift;
	my $email = shift;
	my ($id) = $session->dbSlave->quickArray("select userId from userProfileData where email=?",[$email]);
	my $user = $class->new($session, $id);
	return undef if ($user->isVisitor); # visitor is never valid for this method
	return undef unless $user->username;
	return $user;
}


#-------------------------------------------------------------------

=head2 newByUsername ( session, username )

Instanciates a user by username. Returns undef if the username could not be found.
Visitor may not be looked up with this method.

=head3 session

A reference to the current session.

=head3 username

The username to search for.

=cut

sub newByUsername {
	my $class = shift;
	my $session = shift;
	my $username = shift;
	my ($id) = $session->dbSlave->quickArray("select userId from users where username=?",[$username]);
	my $user = $class->new($session, $id);
	return undef if ($user->isVisitor); # visitor is never valid for this method
	return undef unless $user->username;
	return $user;
}


#-------------------------------------------------------------------

=head2 profileField ( fieldName [, value ] )

DEPRECATED! Use get(fieldName) and update({ fieldName => "value" })

Returns a profile field's value. If "value" is specified, it also sets the field to that value. 

=head3 fieldName 

The profile field name such as "language" or "email" or "cellPhone".

=head3 value

The value to set the profile field name to.

=cut

sub profileField {
    my $self        = shift;
    my $fieldName   = shift;
    my $value       = shift;

    if (defined $value) {
        $self->update({ $fieldName => $value });
    }

	return $self->get($fieldName);
}

#-------------------------------------------------------------------

=head2 profileIsViewable ( user  )

Returns whether or not the user's profile is viewable by the user passed in

=head3 user

The user to test to see if the profile is viewable for.  If no user is passed in,
the current user in session will be tested

=cut

sub profileIsViewable {
    my $self     = shift;
    my $user     = shift || $self->session->user;
    my $userId   = $user->userId;

    return 0 if ($self->isVisitor);  #Can't view visitor's profile
    return 0 if ($user->isVisitor);  #User is not allowed to see anyone's profile, either
    return 1 if ($self->userId eq $userId);  #Users can always view their own profile

    my $profileSetting = $self->profileField('publicProfile');
    
    return 0 if ($profileSetting eq "none");
    return 1 if ($profileSetting eq "all");

    my $friendsGroup = $self->friends;
    return $user->isInGroup($friendsGroup->getId);
}

#-------------------------------------------------------------------

=head2 referringAffiliate ( [ value ] )

DEPRECATED! Use get("referringAffiliate") and update({ referringAffiliate => "value" })

Returns the unique identifier of the affiliate that referred this user to the site. 

=head3 value

An integer containing the unique identifier of the affiliate.

=cut

sub referringAffiliate {
        my $self = shift;
        my $value = shift;
        if (defined $value) {
            $self->update({ "referringAffiliate" => $value });
        }
        return $self->get("referringAffiliate");
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

=head2 setProfileFieldPrivacySetting ( settings ) 

Sets the profile field privacy settings.  This updates the the db and
the internally cached settings.  Valid settings are "all", "none" or "friends".

=head3 settings

Hash ref containing fields and their corresponding privacy settings

=cut

sub setProfileFieldPrivacySetting {
    my $self     = shift;
    my $session  = $self->session;
    my $settings = shift;
    
    return undef unless scalar(keys %{$settings});

    #Get the current settings
    my $currentSettings = $self->getProfileFieldPrivacySetting;
    
    foreach my $fieldId (keys %{$settings}) {
        my $privacySetting = $settings->{$fieldId};
        next unless $privacySetting ~~ [qw(all none friends)];
        $currentSettings->{$fieldId} = $settings->{$fieldId};
    }
    
    #Store the data in the database
    my $json = JSON->new->encode($currentSettings);
    $session->db->write("update userProfileData set wg_privacySettings=? where userId=?",[$json,$self->userId]);

    #Recache the current settings
    $self->{_privacySettings} = $currentSettings;
}


#-------------------------------------------------------------------

=head2 status ( [ value ] )

DEPRECATED! Use get("status") and enable() and disable() instead

Returns the status of the user. 

=head3 value

If specified, the status is set to this value.  Possible values are 'Active', 'Selfdestructed' and 'Deactivated'.
'Selfdestructed' means that the user deactivated their own account.  'Deactivated' means that either
their status has been changed by an Admin, or that this is a new account that is pending email
confirmation before activation.

=cut

sub status {
	my $self = shift;
	my $value = shift;
	if (defined $value) {
        if ( $value eq "Active" ) {
            $self->enable;
        }
        elsif ( $value eq "Selfdestructed" ) {
            $self->disable({ bySelf => 1 });
        }
        elsif ( $value eq "Deactivated" ) {
            $self->disable;
        }
	}
	return $self->get("status");
}

#-------------------------------------------------------------------

=head2 uncache ( )

Deletes this user object out of the cache.

=cut

sub uncache {
	my $self = shift;
	$self->session->cache->remove("user_" . $self->userId);
}

#----------------------------------------------------------------------------

=head2 update ( properties )

Update properties for the user. C<properties> is a hash reference of user properties
and/or profile fields.

Valid user properties:

 authMethod
 dateCreated
 friendsGroup
 karma              - NOTE: To add karma, use the karma() method
 lastUpdated
 referringAffiliate
 status             - One of "Activated", "Deactivated", or "Selfdestructed"
 username

Anything else is a profile field.

=cut

sub update {
    my ( $self, $properties ) = @_;
    my $session     = $self->session;
    my $db          = $session->db;
    
    # Make a safe copy of properties, we'll be deleting from it
    $properties = { %$properties };
    $self->uncache;
    $properties->{lastUpdated} ||= time;

    # No userId, bad!
    delete $properties->{userId};

    # This is an internal field with its own api to set it
    delete $properties->{wg_privacySettings};

    # $self->{_user} contains all fields in `users` table
    my @userFields  = ();
    my @userValues  = ();
    for my $key ( keys %{$self->{_user}} ) {
        if ( exists $properties->{$key} ) {
            # Delete the value because it's not a profile field
            my $value   = delete $properties->{$key};
            push @userFields, $db->quote_identifier( $key ) . " = ?";
            push @userValues, $value;
            $self->{_user}->{$key} = $value;
        }
    }
    # No matter what we update properties
    my $userFields  = join ", ", @userFields;
    $db->write(
        "UPDATE users SET $userFields WHERE userId=?",
        [@userValues, $self->{_userId}]
    );

    # Everything else must be a profile field
    my @profileFields   = ();
    my @profileValues   = ();
    for my $key ( keys %{$properties} ) {
        if (!exists $self->{_profile}{$key} && !WebGUI::ProfileField->exists($session,$key)) {
            $self->session->log->warn("No such profile field: $key");
            next;
        }
        push @profileFields, $db->quote_identifier( $key ) . " = ?";
        push @profileValues, $properties->{ $key };
        $self->{_profile}->{$key} = $properties->{ $key };
    }
    if ( @profileFields ) {
        my $profileFields  = join ", ", @profileFields;
        $db->write(
            "UPDATE userProfileData SET $profileFields WHERE userId=?",
            [@profileValues, $self->{_userId}]
        );
    }

    return;
}

#-------------------------------------------------------------------

=head2 updateProfileFields ( profile )

DEPRECATED! Use update(profile)

Saves profile data to a user's profile.  Does not validate any of the data.

=head3 profile

Hash ref of key/value pairs of data in the users's profile to update.

=cut

sub updateProfileFields {
    my $self    = shift;
    my $profile = shift;

    $self->update($profile);
}

#-------------------------------------------------------------------

=head2 username ( [ value ] )

DEPRECATED! Use get("username") and update({ username => "value" }) instead.
Returns the username. 

=head3 value

If specified, the username is set to this value. 

=cut

sub username {
    my $self = shift;
    my $value = shift;
    if (defined $value) {
        $self->update({ username => $value });
    }
    return $self->get("username");
}

#-------------------------------------------------------------------

=head2 userId ( )

DEPRECATED: Use getId() instead!

Returns the userId for this user.

=cut

sub userId {
        return $_[0]->getId;
}

#-------------------------------------------------------------------

=head2 validateProfileDataFromForm ( fields )

Validates profile data from the session form variables.  Returns an data structure which contains the following

{
    profile        => Hash reference containing all of the profile fields and their values
    errors         => Array reference of error messages to be displayed
    errorCategory  => Category in which the first error was thrown
    warnings       => Array reference of warnings to be displayed
    errorFields    => Array reference of the fieldIds that threw an error
    warningFields  => Array reference of the fieldIds that threw a warning
}

=head3 fields

An array reference of profile field Ids to validate.

=cut

sub validateProfileDataFromForm {
	my $self        = shift;
    my $session     = $self->session;
	my $fields      = shift;

    my $i18n        = WebGUI::International->new($session);

    my $data        = {};
    my $errors      = [];
    my $warnings    = [];
    my $errorCat    = undef;
    my $errorFields = [];
    my $warnFields  = [];
    
	FIELD: foreach my $field (@{$fields}) {
        my $fieldId       = $field->getId;
        my $fieldLabel    = $field->getLabel;
    	my $fieldValue    = $field->formProcess;
        my $isValid       = $field->isValid($fieldValue);

        if(!$isValid) {
            $errorCat = $field->get("profileCategoryId") unless (defined $errorCat);
            push (@{$errors}, sprintf($i18n->get("required error"),$fieldLabel));
            push(@{$errorFields},$fieldId);
        }
        #The language field is special and must be always be valid or WebGUI will croak
        elsif($fieldId eq "language" && !(exists $i18n->getLanguages()->{$fieldValue})) {
            $errorCat = $field->get("profileCategoryId") unless (defined $errorCat);
            push (@{$errors}, sprintf($i18n->get("language not available error"),$fieldValue));
            push(@{$errorFields},$fieldId);
        }
        #Duplicate emails throw warnings
        elsif($fieldId eq "email" && $field->isDuplicate($fieldValue,$self->userId)) {
            $errorCat = $field->get("profileCategoryId") unless (defined $errorCat);
            push (@{$warnings},$i18n->get(1072));
            push(@{$warnFields},$fieldId);
        }

        ##Do not return data unless the form field was actually in the posted data.
        next FIELD unless $field->isInRequest;
        $data->{$fieldId} = (ref $fieldValue eq "ARRAY") ? $fieldValue->[0] : $fieldValue;

    }

	return {
        profile       => $data,
        errors        => $errors,
        warnings      => $warnings,
        errorCategory => $errorCat,
        errorFields   => $errorFields,
        warningFields => $warnFields,
    };
}

#-------------------------------------------------------------------

=head2 validUserId ( userId )

Returns true if the userId exists in the users table. 

=cut

sub validUserId {
	my ($class, $session, $userId) = @_;
	my $sth = $session->db->read('select userId from users where userId=?',[$userId]);
	return ($sth->rows == 1);
}

1;
