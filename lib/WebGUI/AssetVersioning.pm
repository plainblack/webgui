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

=head2 addRevision ( properties [ , revisionDate ] )

Adds a revision of an existing asset. Note that programmers should almost never call this method directly, but rather use the update() method instead.

=head3 properties

A hash reference containing a list of properties to associate with the child. 
        
=head3 revisionDate

An epoch date representing the date/time stamp that this revision was created. Defaults to$self->session->datetime->time().
        
=cut    
        
sub addRevision {
        my $self = shift;
        my $properties = shift;
	my $now = shift ||$self->session->datetime->time();
	my $versionTag = $self->session->scratch->get("versionTag") || 'pbversion0000000000002';
	my $status = $self->session->setting->get("autoCommit") ? 'approved' : 'pending';
	$self->session->db->write("insert into assetData (assetId, revisionDate, revisedBy, tagId, status, url,  
		ownerUserId, groupIdEdit, groupIdView) values (".$self->session->db->quote($self->getId).",".$now.", ".$self->session->db->quote($self->session->user->userId).", 
		".$self->session->db->quote($versionTag).", ".$self->session->db->quote($status).", ".$self->session->db->quote($self->getId).", '3','3','7')");
        foreach my $definition (@{$self->definition($self->session)}) {
                unless ($definition->{tableName} eq "assetData") {
                        $self->session->db->write("insert into ".$definition->{tableName}." (assetId,revisionDate) values (".$self->session->db->quote($self->getId).",".$now.")");
                }
        }               
        my $newVersion = WebGUI::Asset->new($self->session,$self->getId, $self->get("className"), $now);
        $newVersion->updateHistory("created revision");
	$newVersion->update($self->get);
	$newVersion->setVersionLock unless ($self->session->setting->get("autoCommit"));
        $newVersion->update($properties) if (defined $properties);
        return $newVersion;
}


#-------------------------------------------------------------------

=head2 canEditIfLocked ( )

Returns a boolean indicating whether this asset is locked and if the current user can edit it in that state.

=cut

sub canEditIfLocked {
	my $self = shift;
	return 0 unless ($self->isLocked);
	return ($self->get("isLockedBy") eq $self->session->user->userId);
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

=head2 getRevisionCount ( [ status ] )

Returns the number of revisions available for this asset.

=head3 status

Optionally specify to get the count based upon the status of the revisions. Options are "approved", "archived", "pending", "denied". Defaults to any status.

=cut

sub getRevisionCount {
	my $self = shift;
	my $status = shift;
	my $statusClause = " and status=".$self->session->db->quote($status) if ($status);
	my ($count) = $self->session->db->quickArray("select count(*) from assetData where assetId=".$self->session->db->quote($self->getId).$statusClause);
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

=head2 purgeRevision ( )

Deletes a revision of an asset. If it's the last revision, it purges the asset all together.

=cut

sub purgeRevision {
	my $self = shift;
	if ($self->getRevisionCount > 1) {
		$self->session->db->beginTransaction;
        	foreach my $definition (@{$self->definition($self->session)}) {                
			$self->session->db->write("delete from ".$definition->{tableName}." where assetId=".$self->session->db->quote($self->getId)." and revisionDate=".$self->session->db->quote($self->get("revisionDate")));
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

=head2 www_manageRevisions ()

Shows a list of the revisions for this asset.

=cut

sub www_manageRevisions {
        my $self = shift;
        my $ac = WebGUI::AdminConsole->new($self->session,"versions");
        return $self->session->privilege->insufficient() unless ($self->session->user->isInGroup(3));
        my $i18n = WebGUI::International->new($self->session,"Asset");
        my $output = '<table width=100% class="content">
        <tr><th></th><th>Revision Date</th><th>Revised By</th><th>Tag Name</th></tr> ';
        my $sth = $self->session->db->read("select assetData.revisionDate, users.username, assetVersionTag.name,assetData.tagId from assetData 
		left join assetVersionTag on assetData.tagId=assetVersionTag.tagId left join users on assetData.revisedBy=users.userId
		where assetData.assetId=".$self->session->db->quote($self->getId));
        while (my ($date,$by,$tag,$tagId) = $sth->array) {
                $output .= '<tr><td>'.$self->session->icon->delete("func=purgeRevision;revisionDate=".$date,$self->get("url"),$i18n->get("purge revision prompt")).'</td>
			<td><a href="'.$self->getUrl("func=viewRevision;revisionDate=".$date).'">'.$self->session->datetime->epochToHuman($date).'</a></td>
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
	return $self->session->privilege->insufficient() unless $self->canEdit;
	my $revisionDate = $self->session->form->process("revisionDate");
	return undef unless $revisionDate;
	WebGUI::Asset->new($self->session,$self->getId,$self->get("className"),$revisionDate)->purgeRevision;
	if ($self->session->form->process("proceed") eq "manageRevisionsInTag") {
		$self->session->http->setRedirect($self->getUrl("op=manageRevisionsInTag"));
		return "";
	}
	return $self->www_manageRevisions;
}


#-------------------------------------------------------------------

sub www_viewRevision {
	my $self = shift;
	my $otherSelf = WebGUI::Asset->new($self->session,$self->getId,$self->get("className"),$self->session->form->process("revisionDate"));
	return (defined $otherSelf) ? $otherSelf->www_view : undef;
}

1;

