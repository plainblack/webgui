package WebGUI::Asset;

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
use WebGUI::Paginator;
use WebGUI::VersionTag;
use WebGUI::Search::Index;

=head1 NAME

Package WebGUI::AssetVersioning

=head1 DESCRIPTION

This is a mixin package for WebGUI::Asset that contains all versioning related functions.

=head1 SYNOPSIS

 use WebGUI::Asset;

=head1 METHODS

These methods are available from this class:

=cut


#-------------------------------------------------------------------

=head2 addRevision ( properties [ , revisionDate, options ] )

Adds a revision of an existing asset. Note that programmers should almost never call this method directly, but rather use the update() method instead.

=head3 properties

A hash reference containing a list of properties to associate with the child.

=head3 revisionDate

An epoch date representing the date/time stamp that this revision was created. Defaults to$self->session->datetime->time().

=head3 options

A hash reference of options that change the behavior of this method.

=head4 skipAutoCommitWorkflows

If this is set to 1 then assets that would normally autocommit their workflow (like CS Posts) will instead add themselves to the normal working version tag.

=cut

sub addRevision {
        my $self = shift;
        my $properties = shift;
	my $now = shift ||$self->session->datetime->time();
	my $options = shift;
	my $autoCommitId = $self->getAutoCommitWorkflowId() unless ($options->{skipAutoCommitWorkflows});
	my $workingTag = ($autoCommitId) ? WebGUI::VersionTag->create($self->session, {groupToUse=>'12', workflowId=>$autoCommitId}) : WebGUI::VersionTag->getWorking($self->session);
	$self->session->db->beginTransaction;
	$self->session->db->write("insert into assetData (assetId, revisionDate, revisedBy, tagId, status, url,
		ownerUserId, groupIdEdit, groupIdView) values (?, ?, ?, ?, 'pending', ?, '3','3','7')",
		[$self->getId, $now, $self->session->user->userId, $workingTag->getId, $self->getId] );
        foreach my $definition (@{$self->definition($self->session)}) {
                unless ($definition->{tableName} eq "assetData") {
                        $self->session->db->write("insert into ".$definition->{tableName}." (assetId,revisionDate) values (?,?)", [$self->getId, $now]);
                }
        }
	$self->session->db->commit;
        my $newVersion = WebGUI::Asset->new($self->session,$self->getId, $self->get("className"), $now);
        $newVersion->updateHistory("created revision");
	$newVersion->update($self->get);
	$newVersion->setVersionLock;
	$properties->{status} = 'pending';
        $newVersion->update($properties);
	$workingTag->requestCommit if ($autoCommitId);
        return $newVersion;
}


#-------------------------------------------------------------------

=head2 canEditIfLocked ( )

Returns 1 if it's not locked. Returns 1 if is locked, and the user is using the tag it was edited under. Otherwise returns 0.

=cut

sub canEditIfLocked {
	my $self = shift;
	return 1 unless ($self->isLocked);
	return ($self->session->scratch->get("versionTag") eq $self->get("tagId"));
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

Override this method in your asset if you want your asset to auto-commit its workflow each time addRevision() is called on it. Your overridden method must return the workflow Id of the workflow to run on autocommit.

=cut

sub getAutoCommitWorkflowId {
	return undef;
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

Returns an array reference of the revision objects of this asset.

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
	my $rs = $self->session->db->read("select revisionDate from assetData where assetId=".$self->session->db->quote($self->getId).$statusClause);
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
	return unless defined $userId;
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
			$self->session->db->write("delete from ".$definition->{tableName}." where assetId=? and revisionDate=?",[$self->getId, $self->get("revisionDate")]);
        	}
		my ($count) = $self->session->db->quickArray("select count(*) from assetData where assetId=? and status='pending'",[$self->getId]);
		if ($count < 1) {
			$self->session->db->write("update asset set isLockedBy=null where assetId=?",[$self->getId]);
		}
        	$self->session->db->commit;
		$self->purgeCache;
		$self->updateHistory("purged revision ".$self->get("revisionDate"));
	} else {
		$self->purge;
	}
}


#-------------------------------------------------------------------

=head2 setVersionLock ( )

Sets the versioning lock to "on" so that this piece of content may not be edited by anyone else now that it has been edited.

=cut

sub setVersionLock {
	my $self = shift;
	$self->session->db->write("update asset set isLockedBy=".$self->session->db->quote($self->session->user->userId)." where assetId=".$self->session->db->quote($self->getId));
	$self->updateHistory("locked");
	$self->purgeCache;
}


#-------------------------------------------------------------------

=head2 unsetVersionLock ( )

Sets the versioning lock to "off" so that this piece of content may be edited once again.

=cut

sub unsetVersionLock {
	my $self = shift;
	$self->session->db->write("update asset set isLockedBy=NULL where assetId=".$self->session->db->quote($self->getId));
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
	my $action = shift;
	my $userId = shift || $self->session->user->userId || '3';
	my $dateStamp =$self->session->datetime->time();
	$self->session->db->write("insert into assetHistory (assetId, userId, actionTaken, dateStamp) values (".$self->session->db->quote($self->getId).", ".$self->session->db->quote($userId).", ".$self->session->db->quote($action).", ".$dateStamp.")");
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
		where assetData.assetId=".$self->session->db->quote($self->getId));
        while (my ($date,$by,$tag,$tagId) = $sth->array) {
                $output .= '<tr><td>'
			.$self->session->icon->delete("func=purgeRevision;revisionDate=".$date,$self->get("url"),$i18n->get("purge revision prompt"))
			.$self->session->icon->view("func=view;revision=".$date)
			.'</td>
			<td>'.$self->session->datetime->epochToHuman($date).'</td>
			<td>'.$by.'</td>
			<td><a href="'.$self->getUrl("op=manageRevisionsInTag;tagId=".$tagId).'">'.$tag.'</a></td>
			</tr>';
        }
        $sth->finish;
        $output .= '</table>';
	$ac->setHelp('manage versions','Asset');
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
		return "";
	}
	unless (defined $self) {
		return $parent->www_view;
	}
	return $self->www_manageRevisions;
}

1;

