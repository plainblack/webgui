package WebGUI::VersionTag;

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
use WebGUI::Asset;
use WebGUI::Workflow::Instance;
use WebGUI::DateTime;
use WebGUI::Session;

=head1 NAME

Package WebGUI::VersionTag

=head1 DESCRIPTION

This package provides an API to create and modify version tags used by the asset sysetm.

=head1 SYNOPSIS

 use WebGUI::VersionTag;

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 autoCommitUrl ( $base )

Returns the url autoCommitWorkingIfEnabled would redirect to if it were going
to.

=cut

sub autoCommitUrl {
    my $self    = shift;
    my $session = $self->session;
    my $url     = $session->url;
    my $base    = shift || $url->page;
    my $id      = $self->getId;
    return $url->append($base, "op=commitVersionTag;tagId=$id");
}

#-------------------------------------------------------------------

=head2 autoCommitWorkingIfEnabled ( $session, $options )

A class method that automatically commits the working version tag if auto commit is
enabled.  Returns 'commit' if the tag was committed, 'redirect' if a redirect for
comments was set (only possible with allowComments), or false if no action was taken.

=head3 $options

Hashref with options for how to do auto commit

=head4 override

Do autocommit even if not enabled for the site

=head4 allowComments

Whether to allow comments to be added.  If enabled, instead of
committing directly, will set a redirect for the user to enter
a comment.

=head4 returnUrl

If allowComments is enabled, the URL to return to after committing

=cut

sub autoCommitWorkingIfEnabled {
    my $class = shift;
    my $session = shift;
    my $options = shift || {};
    # need a version tag to do any auto commit
    my $versionTag = $class->getWorking($session, "nocreate");
    return undef
        unless $versionTag;

    if ($options->{override} || $versionTag->canAutoCommit) {
        if ($session->setting->get("skipCommitComments") || !$options->{allowComments}) {
            $versionTag->requestCommit;
            return 'commit';
        }
        else {
            my $url = $versionTag->autoCommitUrl($options->{returnUrl});
            $session->http->setRedirect($url);
            return 'redirect';
        }
    }
    return undef;
}

#-------------------------------------------------------------------

=head2 canAutoCommit

Returns true if we would autocommit this tag without an override.

=cut

sub canAutoCommit {
    my $self    = shift;
    my $session = $self->session;
    my $class   = ref $self;
    my $mode    = $class->getVersionTagMode($session);
    return $mode eq 'autoCommit'
        && !$self->get('isSiteWide')
        && $self->get('createdBy') eq $session->user->userId;
}

#-------------------------------------------------------------------

=head2 clearWorking ( )

Makes it so this tag is no longer the working tag for any user.

=cut

sub clearWorking {
	my $self = shift;
	$self->session->scratch->deleteNameByValue('versionTag',$self->getId);
	$self->session->stow->delete("versionTag");
}

#-------------------------------------------------------------------

=head2 create ( session, properties ) 

A class method. Creates a version tag. Returns the version tag object.

=head3 session

A reference of the current session.

=head3 properties

A hash reference of properties to set. See the set() method for details.

=cut

sub create {
	my $class = shift;
	my $session = shift;
	my $properties = shift;
	my $tagId = $session->db->setRow("assetVersionTag","tagId",{
		tagId=>"new",
		creationDate=>time(),
		createdBy=>$session->user->userId
		});
	my $tag = $class->new($session, $tagId);
	$tag->set($properties);
	return $tag;
} 


#-------------------------------------------------------------------

=head2 commit ( [ options ] )

Commits all assets edited under a version tag, and then sets the version tag to committed. Returns 1 if successful.

=head3 options

A hash reference with options for this asset.

=head4 timeout

Commit assets until we've reached this timeout. If we're not able to commit them all in this amount of time, then we'll return 2 rather than 1. We defaultly timeout after 999 seconds.

=cut

sub commit {
	my $self = shift;
	my $options = shift;
	my $timeout = $options->{timeout} || 999;
	my $now = time;
	my $finished = 1;
	foreach my $asset (@{$self->getAssets({"byLineage"=>1, onlyPending=>1})}) {
		$asset->commit;
		if ($now + $timeout < time) {
			$finished = 0;	
			last;
		}
	}
	if ($finished) {
		$self->{_data}{isCommitted} = 1;
		$self->{_data}{committedBy} = $self->session->user->userId unless ($self->{_data}{committedBy});
		$self->{_data}{commitDate} = time();
		$self->session->db->setRow("assetVersionTag", "tagId", $self->{_data});
		$self->clearWorking;
		return 1;
	}
	return 2;
}

#-------------------------------------------------------------------

=head2 commitAsUser ( userId , options )

Commits the working tab.  If userId is passed in, commit will be done as that user

=head3 userId

User to commit tag as

=head3 options

hash ref of options to pass in

=head4 comments

optional comments to set in the version tag

=head4 commitNow

optional boolean which, if set, will perform an immediate.

=cut

sub commitAsUser {
    my $self        = shift;
    my $session     = $self->session;
    my $config      = $session->config;
    my $userId      = shift;
    my $options     = shift;
    my $commitNow   = $options->{commitNow};
    my $comments    = $options->{comments};

    return 0 unless (defined $userId);

    #Open a new session
    my $new_session = WebGUI::Session->open( $config );
    #Set the userId in the new session
    $new_session->user( { userId => $userId } );

    #Clone the tag into a new version tag in the new session
    my $new_tag = __PACKAGE__->new( $new_session, $self->getId );
    
    if ( defined $new_tag ) {
        $new_tag->set( { comments => $comments } );
        if ($commitNow) {
            $new_tag->commit;
        }
        else {
            $new_tag->requestCommit;
        }
    }
    #End the new session
    $new_session->var->end;
    $new_session->close;
    return 1;
}


#-------------------------------------------------------------------

=head2 get ( [ name ] ) 

Returns the value for a given property. If C<name> is not specified, returns
all the properties.

An incomplete list of properties is below:

=head3 name

The name of the tag.

=head4 createdBy

The ID of the user who originally created the tag.

=head4 committedBy

The ID of the user who committed the tag.

=head4 lockedBy

If the version tag is locked, the ID of the user who has it locked.

=head4 isLocked

An integer that indicates whether the version tag is locked.  A 1 indicates that the tag
is locked.  Note that this is different from edit locking an Asset.  Locked Version Tags may
not be edited.

=head3 groupToUse

The ID of the group that's allowed to use this tag. Defaults to the turn admin on group.

=head4 commitDate

The epoch date the tag was committed.

=head4 startTime

The time that this version tag should be committed

=head4 endTime

The time that this version tag should no longer be available.

=head3 creationDate

The epoch date the tag was created.

=head3 comments

Some text about this version tag, what it's for, why it was committed, why it was denied, why it was approved, etc.

=cut

sub get {
    my $self    = shift;
    my $name    = shift;

    if ( $name ) {
        return $self->{_data}{$name};
    }
    else {
        return { %{ $self->{_data} } },
    }
}

#-------------------------------------------------------------------

=head2 getAssetCount ( )

Returns the number of assets that are under this tag.

=cut

sub getAssetCount {
	my $self = shift;
	my ($count) = $self->session->db->quickArray("select count(distinct(assetId)) from assetData where tagId=?", [$self->getId]);
	return $count;
}

#-------------------------------------------------------------------

=head2 getAssets ( [options] )

Returns a list of asset objects that are part of this version tag.

=head3 options

A hash reference containing options to change the output.

=head4 reverse

A boolean that will reverse the order of the assets. The default is to return the assets in descending order.

=head4 byLineage

A boolean that will return the asset list ordered by lineage, ascending. Cannot be used in conjunction with "reverse".

=head4 onlyPending

Return only assets pending a commit, not assets that have already been committed.

=cut

sub getAssets {
	my $self = shift;
	my $options = shift;
	my @assets = ();
	my $direction = $options->{reverse} ? "asc" : "desc";
	my $sort = "revisionDate";
	my $pending = "";
	if ($options->{byLineage}) {
		$sort = "lineage";
		$direction = "asc";
	}
	if ($options->{onlyPending}) {
		$pending = " and assetData.status='pending' ";
	}
	my $sth = $self->session->db->read("select asset.assetId,assetData.revisionDate from assetData left join asset on asset.assetId=assetData.assetId where assetData.tagId=? ".$pending." order by ".$sort." ".$direction, [$self->getId]);
	ASSETID: while (my ($id,$version) = $sth->array) {
		my $asset = eval { WebGUI::Asset->newById($self->session,$id,$version); };
            unless (defined $asset) {
                $self->session->log->error("Asset $id $version could not be instanciated by version tag ".$self->getId.". Perhaps it is corrupt.");
                next ASSETID;
            }
            push(@assets, $asset);
	}
	return \@assets;
}

#-------------------------------------------------------------------

=head2 getCommitUrl ( )

Get the URL to commit this version tag. Will check settings to see
if commit comments are on or off

=cut

sub getCommitUrl {
    my ( $self ) = @_;
    my $session = $self->session;
    my ( $url ) = $session->quick(qw( url ));

    if ($session->setting->get("skipCommitComments")) {
        return $url->page("op=commitVersionTagConfirm;tagId=".$self->getId);
    }
    else {
        return $url->page("op=commitVersionTag;tagId=".$self->getId);
    }
}

#-------------------------------------------------------------------

=head2 getEditUrl ( )

Get the URL to edit this version tag

=cut

sub getEditUrl {
    my ( $self ) = @_;
    return $self->session->url->page( "op=editVersionTag;tagId=".$self->getId );
}

#-------------------------------------------------------------------

=head2 getId ( )

Returns the ID of this version tag.

=cut

sub getId {
	my $self = shift;
	return $self->{_id};
}

#-------------------------------------------------------------------

=head2 getJoinUrl ( )

Get the URL to join this version tag

=cut

sub getJoinUrl {
    my ( $self ) = @_;
    return $self->session->url->page( "op=setWorkingVersionTag;tagId=".$self->getId );
}

#-------------------------------------------------------------------

=head2 getOpenTags ( session ) 

Returns an array reference containing all the open version tag objects. This is a class method.

=cut

sub getOpenTags {
	my $class = shift;
	my $session = shift;
	my @tags = ();
	my $sth = $session->db->read("select * from assetVersionTag where isCommitted=0 and isLocked=0 order by name");
	while (my $data = $sth->hashRef) {
        	push(@tags, bless {_session=>$session, _id=>$data->{tagId}, _data=>$data}, $class);
	}
	return \@tags;
}

#-------------------------------------------------------------------

=head2 getRevisionCount ( )

Returns the number of revisions for this tag.

=cut

sub getRevisionCount {
	my $self = shift;
	my ($count) = $self->session->db->quickArray("select count(*) from assetData where tagId=?", [$self->getId]);
	return $count;
}


#-------------------------------------------------------------------

=head2 getVersionTagMode ( session )

Return version tag mode for current session

=cut

sub getVersionTagMode {
    my $class   = shift;
    my $session = shift;

    my $mode = q{};

    $mode = $session->user()->profileField(q{versionTagMode});

    #verify mode.
    if (!(defined $mode && $mode ~~ [qw{autoCommit siteWide singlePerUser multiPerUser}])) {
        $mode = q{};
    }

    #Get mode from settings
    if ($mode eq q{}) {
        $mode = $session->setting()->get(q{versionTagMode});
    }

    return $mode;
} #getVersionTagMode

#-------------------------------------------------------------------

=head2 getWorkflowInstance ( )

Returns a reference to the workflow instance attached to this version tag if any.

=cut

sub getWorkflowInstance {
	my $self = shift;
	return WebGUI::Workflow::Instance->new($self->session, $self->get("workflowInstanceId"));
}

#-------------------------------------------------------------------

=head2 getWorking ( session, noCreate )

This is a class method. Returns the current working version tag for this user as set by setWorking(). If there is no current working tag an autotag will be created and assigned as the working tag for this user.

=head3 session

A reference to the current session.

=head3 noCreate

A boolean that if set to true, will prevent this method from creating an autotag.

=cut

sub getWorking {
    my $class    = shift;
    my $session  = shift;
    my $noCreate = shift;

    my $stow = $session->stow();
    my $mode = $class->getVersionTagMode($session);
    my $tag;
    my $tagId;

    #First see if there is already a version tag
    $tag = $stow->get(q{versionTag});

    return $tag if ($tag && !$tag->isLocked);

    $tagId = $session->scratch()->get(q{versionTag});
    if ($tagId) {
        $tag = $class->new($session, $tagId);
        unless ($tag->isLocked) {
            $stow->set(q{versionTag}, $tag);
            return $tag;
        }
    }

    #No tag found. Create or reclaim one?
    # multiPerUser / autoCommit: no reclaim, create if not noCreate
    # singlePerUser: try to reclaim previous if only 1 open tag
    # siteWide: try to claim site-wide version tag
    # autoCommit: 

    if ($mode eq q{singlePerUser}) {
        # Get all open tags for user. If only 1 tag open then reclaim
        # it.
        my @openTags = ();
        my $userId = $session->user()->userId();

      OPENTAG:
        foreach my $openTag (@{WebGUI::VersionTag->getOpenTags($session)}) {

            # Do not reclaim site wide tag in singlePerUser mode
            next OPENTAG if $openTag->get(q{isSiteWide});

            if ($openTag->get(q{createdBy}) eq $userId) {

                push @openTags, $openTag;
            }
        }
        # For now, we only reclaim if 1 tag open.
        if (scalar @openTags == 1) {
            $tag = $openTags[0];
            unless ($tag->isLocked) {
                $tag->setWorking();
                return $tag;
            }
        }
    }
    elsif ($mode eq q{siteWide}) {
        # Check for site wide version tag. Reclaim if available

      OPENTAG:
        foreach my $openTag (@{WebGUI::VersionTag->getOpenTags($session)}) {
            if ($openTag->get(q{isSiteWide}) && !$openTag->isLocked) {

                $tag = $openTag;

                $tag->setWorking();

                return $tag;
            }
        }
    }

    return undef if $noCreate;

    # Create new tag.
    my %properties = ();

    if ($mode eq q{siteWide}) {
        $properties{isSiteWide} = 1;
    }

    $tag = $class->create($session, \%properties);

    $tag->setWorking();

    return $tag;
} #getWorking

#-------------------------------------------------------------------

=head2 isLocked ( )

Returns boolean value indicating whether tag is locked

=cut

sub isLocked { $_[0]{_data}{isLocked} }

#-------------------------------------------------------------------

=head2 leaveTag ( )

Make the user leave their current tag.

=cut

sub leaveTag {
	my $self = shift;
	$self->session->scratch->delete('versionTag');
	$self->session->stow->delete("versionTag");
}

#-------------------------------------------------------------------

=head2 lock ( )

Sets this version tag up so no more revisions may be applied to it.

=cut

sub lock {
	my $self = shift;
	$self->{_data}{isLocked} = 1;
	$self->{_data}{lockedBy} = $self->session->user->userId;
	$self->session->db->setRow("assetVersionTag","tagId", $self->{_data});
	$self->clearWorking;
}


#-------------------------------------------------------------------

=head2 new ( session, tagId )

Constructor.

=head3 session

A reference to the current session.

=head3 workflowId

The unique id of the version tag you wish to load. 

=cut

sub new {
        my $class = shift;
        my $session = shift;
        my $tagId = shift;
        my $data = $session->db->getRow("assetVersionTag","tagId", $tagId);
        return undef unless $data->{tagId};
        bless {_session=>$session, _id=>$tagId, _data=>$data}, $class;
}

#-------------------------------------------------------------------

=head2 requestCommit ( )

Locks the version tag and then kicks off the approval/commit workflow for it.  Returns an error message if it
fails.

=cut

sub requestCommit {
	my $self = shift;
    
	$self->lock;
	my $instance = WebGUI::Workflow::Instance->create($self->session, {
		workflowId=>$self->get("workflowId"),
		className=>"WebGUI::VersionTag",
		methodName=>"new",
		parameters=>$self->getId
		});	
	$self->{_data}{committedBy} = $self->session->user->userId;
	$self->{_data}{workflowInstanceId} = $instance->getId;
	$self->session->db->setRow("assetVersionTag","tagId",$self->{_data});
    return $instance->start;
    return undef;
}


#-------------------------------------------------------------------

=head2 rollback ( [ $options ] )

Eliminates all revisions of all assets created under a specific version tag. Also removes the version tag.

=head3 options

A hashref of options for this method

=head4 outputSub

A subroutine for reporting the status of the rollback.  Typically used by WebGUI::ProgressBar

=cut

sub rollback {
    my $self      = shift;
    my $session   = $self->session;
    my $options   = shift || {};
    my $outputSub = exists $options->{outputSub} ? $options->{outputSub} : sub {};
    my $tagId     = $self->getId;
    if ($tagId eq "pbversion0000000000001") {
        $session->log->warn("You cannot rollback a tag that is required for the system to operate.");	
        return 0;
    }
    my $sth = $session->db->read("select asset.assetId, assetData.revisionDate from assetData left join asset using(assetId) where assetData.tagId = ? order by asset.lineage desc, assetData.revisionDate desc", [ $tagId ]);
    my $i18n    = WebGUI::International->new($session, 'VersionTag');
    REVISION: while (my ($id, $revisionDate) = $sth->array) {
        my $revision = eval { WebGUI::Asset->newById($session, $id, $revisionDate); };
        unless (defined $revision) {
            $self->session->log->error("Asset $id $revisionDate could not be instanciated by version tag ".$self->getId.". Perhaps it is corrupt.");
            next REVISION;
        }
        $outputSub->(sprintf $i18n->get('Rolling back %s'), $revision->getTitle);
		$revision->purgeRevision;
	}
    my $instance = $self->getWorkflowInstance;
    if ($instance) {
        $instance->delete;
    }
	$session->db->write("delete from assetVersionTag where tagId=?", [$tagId]);
	$self->clearWorking;
	return 1;
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

=head2 set ( properties )

Sets properties of this workflow.

=head3 properties

A hash reference containing the properties to set.

=head4 name

A human readable name.

=head4 workflowId

The ID of the workflow that will be triggered when this version tag is committed. Defaults to the default version tag workflow set in the settings.

=head4 groupToUse

The ID of the group that's allowed to use this tag. Defaults to the turn admin on group.

=head4 comments

Some text about this version tag, what it's for, why it was committed, why it was denied, why it was approved, etc.

=head4 startTime

The time that a version tag should start displaying on the website

=head4 endTime

The time that a version tag shoudl stop displaying on the website.

=cut

sub set {
    my $self = shift;
    my $properties = shift;

    my $now        = time();
    my $startTime  = WebGUI::DateTime->new($self->session,$now)->toDatabase;
    my $endTime    = WebGUI::DateTime->new($self->session,'2036-01-01 00:00:00')->toDatabase;

    #In case of site wide version tag, mark it as Site wide autotag instead
    my $isSiteWide = $properties->{isSiteWide} || $self->{_data}{isSiteWide} || 0;

    $self->{_data}{'name'      } = $properties->{name} || $self->{_data}{name} || $self->session->user->username." / ".$self->session->datetime->epochToHuman().($isSiteWide ? q{ (Site wide autotag)} : q{ (Autotag)});
    $self->{_data}{'workflowId'} = $properties->{workflowId} || $self->{_data}{workflowId} || $self->session->setting->get("defaultVersionTagWorkflow");
    $self->{_data}{'groupToUse'} = $properties->{groupToUse} || $self->{_data}{groupToUse} || "12";

    #This is necessary for upgrade prior to 7.5.11 in order to ensure that this field exists.
    #The if() blocks should be removd once the next branch point is reached.
    my $assetVersionTagDesc = $self->session->db->buildHashRef('describe assetVersionTag');
    if(grep { $_ =~ /^startTime/ } keys %{$assetVersionTagDesc}) {
        #If startTime is there, so is endTime.  No need for the additional check.
        $self->{_data}{'startTime' } = $properties->{startTime} || $self->{_data}{startTime} || $startTime;
        $self->{_data}{'endTime'   } = $properties->{endTime} || $self->{_data}{endTime} || $endTime;
    }

    #New field isSiteWide is added. Check if field exists. This is needed to let upgrades work
    if (grep { $_ =~ /^isSiteWide/ } keys %{$assetVersionTagDesc}) {

        $self->{_data}{'isSiteWide'} = $isSiteWide;
    }

    if (exists $properties->{comments}) {
        $self->{_data}{comments}=$self->session->datetime->epochToHuman.' - '.$self->session->user->username
            ."\n"
            .$properties->{comments}
            ."\n\n"
            .$self->{_data}{comments};
    }
    $self->session->db->setRow("assetVersionTag","tagId",$self->{_data});
} #set

#-------------------------------------------------------------------

=head2 setWorking ( )

Sets this tag as the working tag for the current user.

=cut

sub setWorking {
	my $self = shift;
	return if $self->isLocked;
	$self->session->scratch->set("versionTag",$self->getId);
	$self->session->stow->set("versionTag", $self);
}

#-------------------------------------------------------------------

=head2 unlock ( )

Sets this version tag up so more revisions may be applied to it.

=cut

sub unlock {
	my $self = shift;
	$self->{_data}{isLocked} = 0;
	$self->{_data}{lockedBy} = "";
	$self->session->db->setRow("assetVersionTag","tagId", $self->{_data});
}

1;

