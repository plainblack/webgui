package WebGUI::VersionTag;

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
use WebGUI::Asset;
use WebGUI::Workflow::Instance;

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
		creationDate=>$session->datetime->time(),
		createdBy=>$session->user->userId
		});
	my $tag = $class->new($session, $tagId);
	$tag->set($properties);
	return $tag;
} 


#-------------------------------------------------------------------

=head2 commit (  )

Commits all assets edited under a version tag, and then sets the version tag to committed.

=cut

sub commit {
	my $self = shift;
	foreach my $asset (@{$self->getAssets}) {
		$asset->commit;
	}
	$self->{_data}{isCommitted} = 1;
	$self->{_data}{committedBy} = $self->session->user->userId unless ($self->{_data}{committedBy});
	$self->{_data}{commitDate} = $self->session->datetime->time();
	$self->session->db->setRow("assetVersionTag", "tagId", $self->{_data});
	$self->clearWorking;
}


#-------------------------------------------------------------------

=head2 get ( name ) 

Returns the value for a given property.

=cut

sub get {
	my $self = shift;
	my $name = shift;
	return $self->{_data}{$name};
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

=head2 getAssets ( )

Returns a list of asset objects that are part of this version tag.

=cut

sub getAssets {
	my $self = shift;
	my @assets = ();
	my $sth = $self->session->db->read("select asset.assetId,asset.className,assetData.revisionDate from assetData left join asset on asset.assetId=assetData.assetId where assetData.tagId=? order by revisionDate desc", [$self->getId]);
	while (my ($id,$class,$version) = $sth->array) {
		push(@assets, WebGUI::Asset->new($self->session,$id,$class,$version));
	}
	return \@assets;
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

Returns the number of revisions that are under this tag.

=cut

sub getRevisionCount {
	my $self = shift;
	my ($count) = $self->session->db->quickArray("select count(assetId) from assetData where tagId=?", [$self->getId]);
	return $count;
}

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
	my $class = shift;
	my $session = shift;
	my $noCreate = shift;
	if ($session->stow->get("versionTag")) {
		return $session->stow->get("versionTag");
	} else {
		my $tagId = $session->scratch->get("versionTag");
		if ($tagId) {
			my $tag = $class->new($session, $tagId);
			$session->stow->set("versionTag",$tag);
			return $tag;
		} elsif ($noCreate) {
			return undef;
		} else {
			my $tag = $class->create($session);
			$tag->setWorking;
			return $tag;	
		}
	}
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

Locks the version tag and then kicks off the approval/commit workflow for it.

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
}


#-------------------------------------------------------------------

=head2 rollback ( )

A class method. Eliminates all revisions of all assets created under a specific version tag. Also removes the version tag.

=head3 tagId

The unique identifier of the version tag to be purged.

=cut

sub rollback {
	my $self = shift;
	my $tagId = $self->getId;
	if ($tagId eq "pbversion0000000000001") {
		$self->session->errorHandler->warn("You cannot rollback a tag that is required for the system to operate.");	
		return 0;
	}
	my $sth = $self->session->db->read("select asset.className, asset.assetId, assetData.revisionDate from assetData left join asset on asset.assetId=assetData.assetId where assetData.tagId = ? order by assetData.revisionDate desc, asset.lineage desc", [ $tagId ]);
	while (my ($class, $id, $revisionDate) = $sth->array) {
		my $revision = WebGUI::Asset->new($self->session,$id, $class, $revisionDate);
		$revision->purgeRevision;
	}
	$self->session->db->write("delete from assetVersionTag where tagId=?", [$tagId]);
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

The ID of the workflow that will be triggered when this workflow is committed. Defaults to the default version tag workflow set in the settings.

=head4 groupToUse

The ID of the group that's allowed to use this tag. Defaults to the turn admin on group.

=head4 comments

Some text about this version tag, what it's for, why it was committed, why it was denied, why it was approved, etc.

=cut

sub set {
	my $self = shift;
	my $properties = shift;
	$self->{_data}{name} = $properties->{name} || $self->{_data}{name} || "(Autotag) ".$self->session->datetime->epochToHuman()." / ".$self->session->user->username;
	$self->{_data}{workflowId} = $properties->{workflowId} || $self->{_data}{workflowId} || $self->session->setting->get("defaultVersionTagWorkflow");
	$self->{_data}{groupToUse} = $properties->{groupToUse} || $self->{_data}{groupToUse} || "12";
	if (exists $properties->{comments}) {
		$self->{_data}{comments}=$self->session->datetime->epochToHuman.' - '.$self->session->user->username
                                ."\n"
                                .$properties->{comments}
                                ."\n\n"
				.$self->{_data}{comments};
	}
	$self->session->db->setRow("assetVersionTag","tagId",$self->{_data});
}

#-------------------------------------------------------------------

=head2 setWorking ( )

Sets this tag as the working tag for the current user.

=cut

sub setWorking {
	my $self = shift;
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

