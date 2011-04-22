package WebGUI::Asset;

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
use WebGUI::Paginator;
use WebGUI::VersionTag;
use WebGUI::Search::Index;

=head1 NAME

Package WebGUI::Asset (AssetVersioning)

=head1 DESCRIPTION

This is a mixin package for WebGUI::Asset that contains all versioning related functions.

=head1 SYNOPSIS

 use WebGUI::Asset;

 my $newAsset   = $asset->addRevision(\%properties);
 my $newAsset   = $asset->addRevision(\%properties, $revisionDate, \%options);

 # TODO: Add usage for all methods available from this class


=head1 METHODS

These methods are available from this class:

=cut


#----------------------------------------------------------------------------

=head2 addRevision ( properties [ , revisionDate, options ] )

Creates a new revision of an existing asset. Returns the new revision of
the asset.

Programmers should almost never call this method directly, but 
rather use the update() method instead.

When using this method, take care that an asset doesn't try to add two
revisions of the same asset within the same second. It will cause things to 
fail. This is not a bug

=head3 properties

A hash reference containing a list of properties to associate with the child.

=head3 revisionDate

An epoch date representing the date/time stamp that this revision was 
created. Defaults to time().

=head3 options

A hash reference of options that change the behavior of this method.

=head4 skipAutoCommitWorkflows

If this is set to 1 then assets that would normally autocommit their 
workflow (like CS Posts) will instead add themselves to the normal working 
version tag.

=head4 skipNotification

If this is set to 1 then assets that normally send notifications will (like CS
Posts) will know not to send them under certain conditions.

=cut

sub addRevision {
    my $self             = shift;
    my $properties       = shift || {};
    my $now              = shift     || time();
    my $options          = shift;

    my $autoCommitId     = $self->getAutoCommitWorkflowId() unless ($options->{skipAutoCommitWorkflows});

    my ($workingTag, $oldWorking);
    if ( $autoCommitId ) {
        $workingTag  
            = WebGUI::VersionTag->create( $self->session, { 
                groupToUse  => '12',            # Turn Admin On (for lack of something better)
                workflowId  => $autoCommitId,
            } ); 
    }
    else {
        my $parentAsset;
        if ( not defined( $parentAsset = $self->getParent ) ) {
            $parentAsset = WebGUI::Asset->newPending( $self->session, $self->get('parentId') );
        }
        if ( $parentAsset->hasBeenCommitted ) {
            $workingTag = WebGUI::VersionTag->getWorking( $self->session );
        }
        else {
            $oldWorking = WebGUI::VersionTag->getWorking($self->session, 'noCreate');
            $workingTag = WebGUI::VersionTag->new( $self->session, $parentAsset->get('tagId') );
            $workingTag->setWorking();
        }
    }
    
    #Create a dummy revision to be updated with real data later
    $self->session->db->beginTransaction;
	
    my $sql = "insert into assetData"
            . " (assetId, revisionDate, revisedBy, tagId, status, url, ownerUserId, groupIdEdit, groupIdView)"
            . " values (?, ?, ?, ?, 'pending', ?, '3','3','7')"
            ;
                  
    $self->session->db->write($sql,[
        $self->getId, 
        $now, 
        $self->session->user->userId, 
        $workingTag->getId, 
        $self->getId,
    ]);
    
	my %defaults = ();
    foreach my $definition (@{$self->definition($self->session)}) {
		
		# get the default values of each property
		foreach my $property (keys %{$definition->{properties}}) {
			$defaults{$property} = $definition->{properties}{$property}{defaultValue};
            if (ref($defaults{$property}) eq 'ARRAY' && !$definition->{properties}{$property}{serialize}) {
                $defaults{$property} = $defaults{$property}->[0];
            }
		}
		
		# prime the tables
        unless ($definition->{tableName} eq "assetData") {
            $self->session->db->write(
                "insert into ".$definition->{tableName}." (assetId,revisionDate) values (?,?)", 
                [$self->getId, $now]
            );
        }
    }

    # Copy metadata values
    my $db    = $self->session->db;
    my $id    = $self->getId;
    my $then  = $self->get('revisionDate');
    my $mdget = q{
        select fieldId, value from metaData_values
        where assetId = ? and revisionDate = ?
    };
    my $mdset = q{
        insert into metaData_values (fieldId, value, assetId, revisionDate)
        values (?, ?, ?, ?)
    };
    for my $row (@{ $db->buildArrayRefOfHashRefs($mdget, [ $id, $then ]) }) {
        $db->write($mdset, [ $row->{fieldId}, $row->{value}, $id, $now ]);
    }

    $self->session->db->commit;
	
	# merge the defaults, current values, and the user set properties
	my %mergedProperties = (%defaults, %{$self->get}, %{$properties}, (status => 'pending'));
    
    # Force the packed head block to be regenerated
    delete $mergedProperties{extraHeadTagsPacked};

    #Instantiate new revision and fill with real data
    my $newVersion = WebGUI::Asset->new($self->session,$self->getId, $self->get("className"), $now);
    $newVersion->setSkipNotification if ($options->{skipNotification});
    $newVersion->updateHistory("created revision");
    $newVersion->setVersionLock;
    $newVersion->update(\%mergedProperties);
    $newVersion->setAutoCommitTag($workingTag) if (defined $autoCommitId);
    $oldWorking->setWorking if $oldWorking;
    
    return $newVersion;
}


#-------------------------------------------------------------------

=head2 canEditIfLocked ( )

Returns 1 if it's not locked. Returns 1 if is locked, and the user is using the tag it was edited under. Otherwise returns 0.

=cut

sub canEditIfLocked {
	my $self = shift;
	return 1 unless ($self->isLocked);
	my $ver_tag = $self->session->scratch->get("versionTag");
	my ($count) = $self->session->db->quickArray("select count(*) from assetData where assetId=? and tagId=?",[$self->getId, $ver_tag]);
	return $count > 0;
}


#-------------------------------------------------------------------

=head2 commit ( )

Unlock's the asset and sets it to approved.

=cut

sub commit {
	my $self = shift;
	$self->unsetVersionLock;
	$self->update({status=>'approved'});
	$self->purgeCache;
	$self->indexContent;
}

#-------------------------------------------------------------------

=head2 getAutoCommitWorkflowId  ( )

Override this method in your asset if you want your asset to automatically run its commit workflow. When this method is specified you addRevision() will instanciate the version tag, set this as the workflow for that version tag, and then call setAutoCommitTag(). Then sometime later in your code before the asset is destroyed you need to call requestAutoCommit() to trigger the workflow.

=cut

sub getAutoCommitWorkflowId {
	return undef;
}

#-------------------------------------------------------------------

=head2 getCurrentRevisionDate ( session, assetId )

This is a class method. Returns the revision date for the revision of the specified asset that is the currently
published revision for the version tag that we're currently operating under. If no version tag, then the revision
that will be displayed publicly is the one returned.

=head3 session

A session object.

=head3 assetId

The unique identifier for an asset.

=cut

sub getCurrentRevisionDate  {
    my $class = shift;
    my $session = shift;
    my $assetId = shift;
	my $assetRevision = $session->stow->get("assetRevision",{noclone=>1});
	my $revisionDate = $assetRevision->{$assetId}{$session->scratch->get("versionTag")||'_'};
	unless ($revisionDate) {
		($revisionDate) = $session->db->quickArray("select max(revisionDate) from assetData where assetId=? and
			(status='approved' or status='archived' or tagId=?) order by assetData.revisionDate",
			[$assetId, $session->scratch->get("versionTag")]);
		$assetRevision->{$assetId}{$session->scratch->get("versionTag")||'_'} = $revisionDate;
		$session->stow->set("assetRevision",$assetRevision);
	}
    return $revisionDate;
}

#-------------------------------------------------------------------

=head2 getRevisionCount ( [ status ] )

Returns the number of revisions available for this asset.

=head3 status

Optionally specify to get the count based upon the status of the revisions. Options are "approved", "archived", or "pending". Defaults to any status.

=cut

sub getRevisionCount {
	my $self = shift;
	my $status = shift;
	my $statusClause = "";
	if ($status) {
		$statusClause = " and status=".$self->session->db->quote($status);
	}
	my ($count) = $self->session->db->quickArray("select count(*) from assetData where assetId=".$self->session->db->quote($self->getId).$statusClause);
	return $count;
}

#-------------------------------------------------------------------

=head2 getRevisions ( [ status ] )

Returns an array reference of the revision objects of this asset, sorted by revision date in descending
order.  The most recent version will always be first.

=head3 status

Optionally specify to get the revisions based upon the status of the revisions. Options are "approved", "archived", or "pending". Defaults to any status.

=cut

sub getRevisions {
	my $self = shift;
	my $status = shift;
	my $statusClause = "";
	if ($status) {
		$statusClause = " and status=".$self->session->db->quote($status);
	}
	my @revisions = ();
	my $rs = $self->session->db->read("select revisionDate from assetData where assetId=".$self->session->db->quote($self->getId).$statusClause. " order by revisionDate desc");
	while (my ($version) = $rs->array) {
		push(@revisions, WebGUI::Asset->new($self->session, $self->getId, $self->get("className"), $version));
	}
	return \@revisions;
}

#-------------------------------------------------------------------

=head2 getTagCount ( )

Returns the number of tags that have been attached to this asset. Think of it sort of like an absolute revision count, rather than counting the number of actual edits, we're counting the number of tags opened against this asset to be edited.

=cut

sub getTagCount {
	my $self = shift;
	my ($count) = $self->session->db->quickArray("select count(distinct(tagId)) from assetData where assetId=?", [$self->getId]);
	return $count;
}

#-------------------------------------------------------------------

=head2 hasBeenCommitted ( )

Returns whether or not this asset has been committed

=cut

sub hasBeenCommitted {
	my $self = shift; 
	return $self->getTagCount > 1  || $self->get('status') ne "pending";
}

#-------------------------------------------------------------------

=head2 isLocked ( )

Returns a boolean indicating whether the asset is locked for editing by the versioning system.

=cut

sub isLocked {
	my $self = shift;
	return $self->get("isLockedBy") ? 1 : 0;
}


#-------------------------------------------------------------------

=head2 lockedBy ( )

Returns the user who locked this asset, or undef if the asset is unlocked.

=cut

sub lockedBy {
	my $self = shift;
	my $userId = $self->get("isLockedBy");
	return undef unless defined $userId;
	return WebGUI::User->new($self->session, $userId);
}


#-------------------------------------------------------------------

=head2 purgeRevision ( )

Deletes a revision of an asset. If it's the last revision, it purges the asset all together.

=cut

sub purgeRevision {
	my $self = shift;
	if ($self->getRevisionCount > 1) {
		$self->session->db->beginTransaction;
        	foreach my $definition (@{$self->definition($self->session)}) {
			$self->session->db->write("delete from ".$self->session->db->dbh->quote_identifier($definition->{tableName})." where assetId=? and revisionDate=?",[$self->getId, $self->get("revisionDate")]);
        	}
		my ($count) = $self->session->db->quickArray("select count(*) from assetData where assetId=? and status='pending'",[$self->getId]);
		if ($count < 1) {
			$self->session->db->write("update asset set isLockedBy=null where assetId=?",[$self->getId]);
		}
		$self->session->db->write(
			'delete from metaData_values where assetId=?  and revisionDate=?',
			[ $self->getId, $self->get('revisionDate') ]
		);
        	$self->session->db->commit;
		$self->purgeCache;
		$self->updateHistory("purged revision ".$self->get("revisionDate"));
	} else {
		$self->purge;
	}
}


#-------------------------------------------------------------------

=head2 moveAssetToVersionTag ( tag )

=head3 moveToTag

Migrate the current asset to the designated version tag

=cut

sub moveAssetToVersionTag {
    my ( $self, $moveToTag ) = @_;

    # Determine if we were passed a version tagId or a VersionTag Class and act appropriately
    #
    my $moveToTagId = $moveToTag;
    if ( ref($moveToTag) eq "WebGUI::VersionTag" ) {
        $moveToTagId = $moveToTag->get('tagId');
    }
    else {
        $moveToTag = WebGUI::VersionTag->new( $self->session, $moveToTagId );
    }

    my $tag = WebGUI::VersionTag->new( $self->session, $self->get('tagId') );

    $self->setVersionTag($moveToTagId);

    my $versionTag = $self->session->db->quickScalar("SELECT tagId FROM assetData WHERE assetId=? AND revisionDate=?",[$self->getId,$self->get('revisionDate')]);
    
    # If no revisions remain, delete the version tag
    if ( $tag->getRevisionCount <= 0 ) {
        $tag->rollback;
    }
} ## end sub moveAssetToVersionTag

#-------------------------------------------------------------------

=head2 requestAutoCommit ( )

Requests an autocommit tag be commited. See also getAutoCommitWorkflowId() and setAutoCommitTag().

=cut

sub requestAutoCommit {
    my $self = shift;

    my $parentAsset;
    if ( not defined( $parentAsset = $self->getParent ) ) {
        $parentAsset = WebGUI::Asset->newPending( $self->session, $self->get('parentId') );
    }
    unless ( $parentAsset->hasBeenCommitted ) {
        my $tagId = $parentAsset->get('tagId');

        if ($tagId) {
            if ( $tagId ne $self->get('tagId') ) {
                $self->moveAssetToVersionTag($tagId);
                return;
            }
        }
    }

    my $tag = $self->{_autoCommitTag};
    if ( defined $tag ) {
        $tag->requestCommit;
        delete $self->{_autoCommitTag};
    }
} ## end sub requestAutoCommit


#-------------------------------------------------------------------

=head2 setAutoCommitTag ( tag )

Stores the current working auto commit tag temporarily in the live asset object. See also requestAutoCommit() and getAutoCommitWorkflowId().

=head3 tag

A WebGUI::VersionTag object.

=cut 

sub setAutoCommitTag {
	my $self = shift;
	my $tag = shift;
	$self->{_autoCommitTag} = $tag;
}

#-------------------------------------------------------------------

=head2 setSkipNotification ( )

Sets a flag so that developers know whether to send notifications out on certain types of edits.

=cut

sub setSkipNotification {
	my $self = shift;
	$self->session->db->write("update assetData set skipNotification=1 where assetId=? and revisionDate=?", [$self->getId, $self->get("revisionDate")]);
    $self->{_properties}->{skipNotification} = 1;
}

#-------------------------------------------------------------------

=head2 setVersionLock ( )

Sets the versioning lock to "on" so that this piece of content may not be edited by anyone else now that it has been edited.

=cut

sub setVersionLock {
    my $self = shift;
    $self->session->db->write("update asset set isLockedBy=? where assetId=?", [$self->session->user->userId, $self->getId]);
    $self->{_properties}{isLockedBy} = $self->session->user->userId;
    $self->updateHistory("locked");
    $self->purgeCache;
}

#-------------------------------------------------------------------

=head2 setVersionTag ( tagId )

Changes the version tag associated with this revision to something new.

=head3 tagId

A new version tag id.

=cut

sub setVersionTag {
	my $self = shift;
    my $tagId = shift;
    $self->session->db->write("update assetData set tagId=? where assetId=? and tagId = ?", [$tagId, $self->getId,$self->get('tagId')]);
        $self->{_properties}{tagId} = $tagId;
	$self->updateHistory("changed version tag to $tagId");
	$self->purgeCache;
}



#-------------------------------------------------------------------

=head2 shouldSkipNotification ( )

Returns true if the asset should disable whatever notifications it does for this edit.

=cut

sub shouldSkipNotification {
	my $self = shift;
	return $self->get("skipNotification");
}


#-------------------------------------------------------------------

=head2 unsetVersionLock ( )

Sets the versioning lock to "off" so that this piece of content may be edited once again.

=cut

sub unsetVersionLock {
    my $self = shift;
    $self->session->db->write("update asset set isLockedBy=NULL where assetId=?",[$self->getId]);
    $self->{_properties}{isLockedBy} = undef;
    $self->updateHistory("unlocked");
    $self->purgeCache;
}


#-------------------------------------------------------------------

=head2 updateHistory ( action [,userId] )

Updates the assetHistory table with the asset, user, action, and timestamp.

=head3 action

String representing type of action taken on an Asset.

=head3 userId

If not specified, current user is used.

=cut

sub updateHistory {
	my $self = shift;
    my $session = $self->session;
	my $action = shift;
	my $userId = shift || $session->user->userId || '3';
	my $dateStamp =time();
	$session->db->write("insert into assetHistory (assetId, userId, actionTaken, dateStamp, url) values (?,?,?,?,?)", [$self->getId, $userId, $action, $dateStamp, $self->get('url')]);
}


#-------------------------------------------------------------------

=head2 www_lock ( )

This is the same as doing an www_editSave without changing anything. It's here so that users can lock assets if they're planning on working on them, or they're working on some of the content offline.

=cut

sub www_lock {
	my $self = shift;
	if (!$self->isLocked && $self->canEdit) {
		$self = $self->addRevision;
	}
	if ($self->session->form->process("proceed") eq "manageAssets") {
                $self->session->asset($self->getParent);
                return $self->session->asset->www_manageAssets;
        }
        $self->session->asset($self->getContainer);
        return $self->session->asset->www_view;	
}

#-------------------------------------------------------------------

=head2 www_manageRevisions ( )

Shows a list of the revisions for this asset.

=cut

sub www_manageRevisions {
        my $self = shift;
        my $ac = WebGUI::AdminConsole->new($self->session,"versions");
        return $self->session->privilege->insufficient() unless ($self->canEdit);
        my $i18n = WebGUI::International->new($self->session,"Asset");
        my $output = sprintf '<table style="width: 100%;" class="content">
        <tr><th></th><th>%s</th><th>%s</th><th>%s</th></tr> ',
	$i18n->get('revision date'), $i18n->get('revised by'), $i18n->get('tag name');
        my $sth = $self->session->db->read("select assetData.revisionDate, users.username, assetVersionTag.name,assetData.tagId from assetData
		left join assetVersionTag on assetData.tagId=assetVersionTag.tagId left join users on assetData.revisedBy=users.userId
		where assetData.assetId=? order by revisionDate desc", [$self->getId]);
        while (my ($date,$by,$tag,$tagId) = $sth->array) {
                $output .= '<tr><td>'
			.$self->session->icon->delete("func=purgeRevision;revisionDate=".$date,$self->get("url"),$i18n->get("purge revision prompt"))
			.$self->session->icon->view( "func=view;revision=" . $date )
            .$self->session->icon->edit( "func=edit;revision=" . $date )
			.'</td>
			<td>'.$self->session->datetime->epochToHuman($date).'</td>
			<td>'.$by.'</td>
			<td><a href="'.$self->getUrl("op=manageRevisionsInTag;tagId=".$tagId).'">'.$tag.'</a></td>
			</tr>';
        }
        $sth->finish;
        $output .= '</table>';
        return $ac->render($output,$i18n->get("committed versions", "VersionTag").": ".$self->getTitle);
}


#-------------------------------------------------------------------

sub www_purgeRevision {
	my $self = shift;
	my $session = $self->session;
	return $session->privilege->insufficient() unless $self->canEdit;
	my $revisionDate = $session->form->process("revisionDate");
	return undef unless $revisionDate;
	my $asset = WebGUI::Asset->new($session,$self->getId,$self->get("className"),$revisionDate);
	return undef if ($asset->get('revisionDate') != $revisionDate);
	my $parent = $asset->getParent;
	$asset->purgeRevision;
	if ($session->form->process("proceed") eq "manageRevisionsInTag") {
		my $working = (defined $self) ? $self : $parent;
		$session->http->setRedirect($working->getUrl("op=manageRevisionsInTag"));
		return undef;
	}
	unless (defined $self) {
		return $parent->www_view;
	}
	return $self->www_manageRevisions;
}

1;

