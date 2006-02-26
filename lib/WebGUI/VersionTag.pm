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
	return $tagId;
} 


#-------------------------------------------------------------------

=head2 commit (  )

Commits all assets edited under a version tag, and then sets the version tag to committed.

=cut

sub commit {
	my $self = shift;
	my $tagId = $self->getId;
	my $sth = $self->session->db->read("select asset.assetId,asset.className,assetData.revisionDate from assetData left join asset on asset.assetId=assetData.assetId where assetData.tagId=?", [$tagId]);
	while (my ($id,$class,$version) = $sth->array) {
		WebGUI::Asset->new($self->session,$id,$class,$version)->commit;
	}
	$self->{_data}{isCommited} = 1;
	$self->{_data}{commitedBy} = $self->session->user->userId;
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

=head2 getId ( )

Returns the ID of this version tag.

=cut

sub getId {
	my $self = shift;
	return $self->{_id};
}

#-------------------------------------------------------------------

=head2 getWorking ( )

This is a class method. Returns the current working version tag for this user as set by setWorking(). If there is no current working tag an autotag will be created and assigned as the working tag for this user.

=cut

sub getWorking {
	my $class = shift;
	my $session = shift;
	if ($session->stow->get("versionTag")) {
		return $session->stow->get("versionTag");
	} else {
		my $tagId = $session->scratch->get("versionTag");
		if ($tagId) {
			my $tag = $class->new($session, $tagId);
			$session->stow->set("versionTag",$tag);
			return $tag;
		} else {
			my $tag = $class->create($session);
			$tag->setAsWorking;
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

=head2 rollback ( )

A class method. Eliminates all revisions of all assets created under a specific version tag. Also removes the version tag.

=head3 tagId

The unique identifier of the version tag to be purged.

=cut

sub rollback {
	my $self = shift;
	my $tagId = $self->getId;
	if ($tagId eq "pbversion0000000000001") {
		return 0;
		$self->session->errorHandler->warn("You cannot rollback a tag that is required for the system to operate.");	
	}
	my $sth = $self->session->db->read("select asset.className, asset.assetId, assetData.revisionDate from assetData left join asset on asset.assetId=assetData.assetId where assetData.tagId = ? order by assetData.revisionDate desc", [ $tagId ]);
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

The ID of the workflow that will be triggered when this workflow is committed.

=cut

sub set {
	my $self = shift;
	my $properties = shift;
	$self->{_data}{name} = $properties->{name} || $self->{_data}{name} || "Autotag created ".$self->session->datetime->epochToHuman()." by ".$self->session->user->username;
	$self->{_data}{workflowId} = $properties->{workflowId} || $self->{_data}{workflowId};
	$self->session->db->setRow("Workflow","workflowId",$self->{_data});
}

#-------------------------------------------------------------------

=head2 setWorking ( )

Sets this tag as the working tag for the current user.

=cut

sub setWorking {
	my $self = shift;
	$self->session->scratch->set("versionTag",$self->getId);
	$self->session->stow("versionTag", $self);
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

