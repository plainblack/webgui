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
	$self->session->db->write("insert into assetData (assetId, revisionDate, revisedBy, tagId, status, url, startDate, endDate, 
		ownerUserId, groupIdEdit, groupIdView) values (".$self->session->db->quote($self->getId).",".$now.", ".$self->session->db->quote($self->session->user->profileField("userId")).", 
		".$self->session->db->quote($versionTag).", ".$self->session->db->quote($status).", ".$self->session->db->quote($self->getId).", 997995720, 32472169200,'3','3','7')");
        foreach my $definition (@{$self->definition}) {
                unless ($definition->{tableName} eq "assetData") {
                        $self->session->db->write("insert into ".$definition->{tableName}." (assetId,revisionDate) values (".$self->session->db->quote($self->getId).",".$now.")");
                }
        }               
        my $newVersion = WebGUI::Asset->new($self->getId, $self->get("className"), $now);
        $newVersion->updateHistory("created revision");
	$newVersion->update($self->get);
	$newVersion->setVersionLock unless ($self->session->setting->get("autoCommit"));
        $newVersion->update($properties) if (defined $properties);
        return $newVersion;
}

#-------------------------------------------------------------------

=head2 addVersionTag ( [ name ] ) 

A class method. Creates a version tag and assigns the tag to the current user's version tag. Returns the id of the tag created.

=head3 name

The name of the version tag. If not specified, one will be generated using the current user's name along with the date.

=cut

sub addVersionTag {
	my $class = shift;
	my $name = shift || "Autotag created ".$self->session->datetime->epochToHuman()." by ".$self->session->user->profileField("username");
	my $tagId = $self->session->db->setRow("assetVersionTag","tagId",{
		tagId=>"new",
		name=>$name,
		creationDate=$self->session->datetime->time(),
		createdBy=>$self->session->user->profileField("userId")
		});
	$self->session->scratch->set("versionTag",$tagId);
	return $tagId;
} 


#-------------------------------------------------------------------

=head2 canEditIfLocked ( )

Returns a boolean indicating whether this asset is locked and if the current user can edit it in that state.

=cut

sub canEditIfLocked {
	my $self = shift;
	return 0 unless ($self->isLocked);
	return ($self->get("isLockedBy") eq $self->session->user->profileField("userId"));
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
}

#-------------------------------------------------------------------

=head2 commitVersionTag ( tagId )

Commits all assets edited under a version tag, and then sets the version tag to committed.

=head3 tagId

The unique id of the tag to be committed.

=cut

sub commitVersionTag {
	my $class = shift;
	my $tagId = shift;
	my $sth = $self->session->db->read("select asset.assetId,asset.className,assetData.revisionDate from assetData left join asset on asset.assetId=assetData.assetId where assetData.tagId=".$self->session->db->quote($tagId));
	while (my ($id,$class,$version) = $sth->array) {
		WebGUI::Asset->new($id,$class,$version)->commit;
	}
	$sth->finish;
	$self->session->db->write("update assetVersionTag set isCommitted=1, commitDate="$self->session->datetime->time().", committedBy=".$self->session->db->quote($self->session->user->profileField("userId"))." where tagId=".$self->session->db->quote($tagId));
	$self->session->db->write("delete from userSessionScratch where name='versionTag' and value=".$self->session->db->quote($tagId));
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
        	foreach my $definition (@{$self->definition}) {                
			$self->session->db->write("delete from ".$definition->{tableName}." where assetId=".$self->session->db->quote($self->getId)." and revisionDate=".$self->session->db->quote($self->get("revisionDate")));
        	}       
        	$self->session->db->commit;
		$self->purgeCache;
		$self->updateHistory("purged revision ".$self->get("revisionDate"));
	} else {
		$self->purgeBranch;
	}
}


#-------------------------------------------------------------------

=head2 rollbackSiteToTime ( time ) 

A class method. Rollback the entire site to a specific point in time. Returns 1 if successful.

=head3 time

The epoch time to rollback to. Anything after this time will be permanently deleted.

=cut

sub rollbackToTime {
	my $class = shift;
	my $toTime = shift;
 	unless ($toTime) {	
		return 0;
		$self->session->errorHandler->warn("You must specify a time when you call rollbackSiteToTime().");
	}
	my $sth = $self->session->db->read("select asset.className, asset.assetId, assetData.revisionDate from assetData left join asset on asset.assetId=assetData.assetId where assetData.revisionDate > ".$toTime." order by assetData.revisionDate desc");
	while (my ($class, $id, $revisionDate) = $sth->array) {
		my $revision = WebGUI::Asset->new($id, $class, $revisionDate);
		$revision->purgeRevision;
	}
	$sth->finish;
	return 1;
}

#-------------------------------------------------------------------

=head2 rollbackVersionTag ( tagId )

A class method. Eliminates all revisions of all assets created under a specific version tag. Also removes the version tag.

=head3 tagId

The unique identifier of the version tag to be purged.

=cut

sub rollbackVersionTag {
	my $class = shift;
	my $tagId = shift;
 	unless ($tagId) {	
		return 0;
		$self->session->errorHandler->warn("You must specify a tag ID when you call rollbackVersionTag().");
	}
	if ($tagId eq "pbversion0000000000001" || $tagId eq "pbversion0000000000002") {
		return 0;
		$self->session->errorHandler->warn("You cannot rollback a tag that is required for the system to operate.");	
	}
	my $sth = $self->session->db->read("select asset.className, asset.assetId, assetData.revisionDate from assetData left join asset on asset.assetId=assetData.assetId where assetData.tagId = ".$self->session->db->quote($tagId)." order by assetData.revisionDate desc");
	while (my ($class, $id, $revisionDate) = $sth->array) {
		my $revision = WebGUI::Asset->new($id, $class, $revisionDate);
		$revision->purgeRevision;
	}
	$sth->finish;
	$self->session->db->write("delete from assetVersionTag where tagId=".$self->session->db->quote($tagId));
	$self->session->db->write("delete from userSessionScratch where name='versionTag' and value=".$self->session->db->quote($tagId));
	return 1;
}


#-------------------------------------------------------------------

=head2 setVersionLock ( ) 

Sets the versioning lock to "on" so that this piece of content may not be edited by anyone else now that it has been edited.

=cut

sub setVersionLock {
	my $self = shift;
	$self->session->db->write("update asset set isLockedBy=".$self->session->db->quote($self->session->user->profileField("userId"))." where assetId=".$self->session->db->quote($self->getId));
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
	my $userId = shift || $self->session->user->profileField("userId") || '3';
	my $dateStamp =$self->session->datetime->time();
	$self->session->db->write("insert into assetHistory (assetId, userId, actionTaken, dateStamp) values (".$self->session->db->quote($self->getId).", ".$self->session->db->quote($userId).", ".$self->session->db->quote($action).", ".$dateStamp.")");
}


#-------------------------------------------------------------------

=head2 www_addVersionTag ()

Displays the add version tag form.

=cut

sub www_addVersionTag {
	my $self = shift;
	my $ac = WebGUI::AdminConsole->new($self->session,"versions");
        return $self->session->privilege->insufficient() unless ($self->session->user->isInGroup(12));
	my $i18n = WebGUI::International->new("Asset");
        $ac->addSubmenuItem($self->getUrl('func=manageVersions'), $i18n->get("manage versions"));
	my $f = WebGUI::HTMLForm->new($self->session,-action=>$self->getUrl);
	my $tag = $self->session->db->getRow("assetVersionTag","tagId",$self->session->form->process("tagId"));
	$f->hidden(
		-name=>"func",
		-value=>"addVersionTagSave"
		);
	$f->text(
		-name=>"name",
		-label=>$i18n->get("version tag name"),
		-hoverHelp=>$i18n->get("version tag name description"),
		-value=>$tag->{name},
		);
	$f->submit;
        return $ac->render($f->print,$i18n->get("add version tag"));	
}


#-------------------------------------------------------------------

=head2 www_addVersionTagSave ()

Adds a version tag and sets the user's default version tag to that.

=cut

sub www_addVersionTagSave {
	my $self = shift;
        return $self->session->privilege->insufficient() unless ($self->session->user->isInGroup(12));
	$self->addVersionTag($self->session->form->process("name"));
	return $self->www_manageVersions();
}


#-------------------------------------------------------------------

sub www_commitRevision {
	my $self = shift;
	return $self->session->privilege->adminOnly() unless $self->canEdit;
	$self->commit;
	return $self->getContainer->www_manageAssets if ($self->session->form->process("proceed") eq "manageAssets");
	return $self->getContainer->www_view;
}
#-------------------------------------------------------------------

sub www_commitVersionTag {
	my $self = shift;
	return $self->session->privilege->adminOnly() unless $self->session->user->isInGroup(3);
	my $tagId = $self->session->form->process("tagId");
	if ($tagId) {
		$self->commitVersionTag($tagId);
	}
	return $self->www_manageVersions;
}

#-------------------------------------------------------------------

=head2 www_manageVersionTags ()

Shows a list of the currently available asset version tags.

=cut

sub www_manageCommittedVersions {
        my $self = shift;
        my $ac = WebGUI::AdminConsole->new($self->session,"versions");
        return $self->session->privilege->insufficient() unless ($self->session->user->isInGroup(3));
        my $i18n = WebGUI::International->new("Asset");
	my $rollback = $i18n->get('rollback');
	my $rollbackPrompt = $i18n->get('rollback version tag confirm');
        $ac->addSubmenuItem($self->getUrl('func=addVersionTag'), $i18n->get("add a version tag"));
        $ac->addSubmenuItem($self->getUrl('func=manageVersions'), $i18n->get("manage versions"));
        my $output = '<table width=100% class="content">
        <tr><th>Tag Name</th><th>Committed On</th><th>Committed By</th><th></th></tr> ';
        my $sth = $self->session->db->read("select tagId,name,commitDate,committedBy from assetVersionTag where isCommitted=1");
        while (my ($id,$name,$date,$by) = $sth->array) {
                my $u = WebGUI::User->new($by);
                $output .= '<tr>
			<td><a href="'.$self->getUrl("func=manageRevisionsInTag;tagId=".$id).'">'.$name.'</a></td>
			<td>'.$self->session->datetime->epochToHuman($date).'</td>
			<td>'.$u->username.'</td>
			<td><a href="'.$self->getUrl("proceed=manageCommittedVersions;func=rollbackVersionTag;tagId=".$id).'" onclick="return confirm(\''.$rollbackPrompt.'\');">'.$rollback.'</a></td></tr>';
        }
        $sth->finish;
        $output .= '</table>';
        return $ac->render($output,$i18n->get("committed versions"));
}


#-------------------------------------------------------------------

=head2 www_manageRevisions ()

Shows a list of the revisions for this asset.

=cut

sub www_manageRevisions {
        my $self = shift;
        my $ac = WebGUI::AdminConsole->new("versions");
        return $self->session->privilege->insufficient() unless ($self->session->user->isInGroup(3));
        my $i18n = WebGUI::International->new("Asset");
        my $output = '<table width=100% class="content">
        <tr><th></th><th>Revision Date</th><th>Revised By</th><th>Tag Name</th></tr> ';
        my $sth = $self->session->db->read("select assetData.revisionDate, users.username, assetVersionTag.name,assetData.tagId from assetData 
		left join assetVersionTag on assetData.tagId=assetVersionTag.tagId left join users on assetData.revisedBy=users.userId
		where assetData.assetId=".$self->session->db->quote($self->getId));
        while (my ($date,$by,$tag,$tagId) = $sth->array) {
                $output .= '<tr><td>'.$self->session->icon->delete("func=purgeRevision;revisionDate=".$date,$self->get("url"),$i18n->get("purge revision prompt")).'</td>
			<td><a href="'.$self->getUrl("func=viewRevision;revisionDate=".$date).'">'.$self->session->datetime->epochToHuman($date).'</a></td>
			<td>'.$by.'</td>
			<td><a href="'.$self->getUrl("func=manageRevisionsInTag;tagId=".$tagId).'">'.$tag.'</a></td>
			</tr>';
        }
        $sth->finish;
        $output .= '</table>';
        return $ac->render($output,$i18n->get("committed versions").": ".$self->getTitle);
}


#-------------------------------------------------------------------

=head2 www_manageVersionTags ()

Shows a list of the currently available asset version tags.

=cut

sub www_manageVersions {
	my $self = shift;
        my $ac = WebGUI::AdminConsole->new("versions");
        return $self->session->privilege->insufficient() unless ($self->session->user->isInGroup(3));
	my $i18n = WebGUI::International->new("Asset");
	$ac->setHelp("versions manage");
	$ac->addSubmenuItem($self->getUrl('func=addVersionTag'), $i18n->get("add a version tag"));
	$ac->addSubmenuItem($self->getUrl('func=manageCommittedVersions'), $i18n->get("manage committed versions"));
	my ($tag) = $self->session->db->quickArray("select name from assetVersionTag where tagId=".$self->session->db->quote($self->session->scratch->get("versionTag")));
	$tag ||= "None";
	my $rollback = $i18n->get("rollback");
	my $commit = $i18n->get("commit");
	my $setTag = $i18n->get("set tag");
	my $rollbackPrompt = $i18n->get("rollback version tag confirm");
	my $commitPrompt = $i18n->get("commit version tag confirm");
	my $output = '<p>You are currently working under a tag called: <b>'.$tag.'</b>.</p><table width=100% class="content">
	<tr><th></th><th>Tag Name</th><th>Created On</th><th>Created By</th><th></th></tr> ';
	my $sth = $self->session->db->read("select tagId,name,creationDate,createdBy from assetVersionTag where isCommitted=0");
	while (my ($id,$name,$date,$by) = $sth->array) {
		my $u = WebGUI::User->new($by);
		$output .= '<tr>
			<td>'.$self->session->icon->delete("func=rollbackVersionTag;tagId=".$id,$self->get("url"),$rollbackPrompt).'</td>
			<td><a href="'.$self->getUrl("func=manageRevisionsInTag;tagId=".$id).'">'.$name.'</a></td>
			<td>'.$self->session->datetime->epochToHuman($date).'</td>
			<td>'.$u->username.'</td>
			<td>
			<a href="'.$self->getUrl("func=setVersionTag;tagId=".$id).'">'.$setTag.'</a> |
			<a href="'.$self->getUrl("func=commitVersionTag;tagId=".$id).'" onclick="return confirm(\''.$commitPrompt.'\');">'.$commit.'</a></td></tr>';
	}
	$sth->finish;	
	$output .= '</table>';
	return $ac->render($output);
}


#-------------------------------------------------------------------

sub www_manageRevisionsInTag {
	my $self = shift;
	my $ac = WebGUI::AdminConsole->new("versions");
        return $self->session->privilege->insufficient() unless ($self->session->user->isInGroup(3));
        my $i18n = WebGUI::International->new("Asset");
	$ac->addSubmenuItem($self->getUrl('func=addVersionTag'), $i18n->get("add a version tag"));
	$ac->addSubmenuItem($self->getUrl('func=manageCommittedVersions'), $i18n->get("manage committed versions"));
        $ac->addSubmenuItem($self->getUrl('func=manageVersions'), $i18n->get("manage versions"));
        my $output = '<table width=100% class="content">
        <tr><th></th><th>Title</th><th>Type</th><th>Revision Date</th><th>Revised By</th></tr> ';
	my $p = WebGUI::Paginator->new($self->getUrl("func=manageRevisionsInTag;tagId=".$self->session->form->process("tagId")));
	$p->setDataByQuery("select assetData.revisionDate, users.username, asset.assetId, asset.className from assetData 
		left join asset on assetData.assetId=asset.assetId left join users on assetData.revisedBy=users.userId
		where assetData.tagId=".$self->session->db->quote($self->session->form->process("tagId")));
	foreach my $row (@{$p->getPageData}) {
        	my ($date,$by,$id, $class) = ($row->{revisionDate}, $row->{username}, $row->{assetId}, $row->{className});
		my $asset = WebGUI::Asset->new($id,$class,$date);
                $output .= '<tr><td>'.$self->session->icon->delete("func=purgeRevision;proceed=manageRevisionsInTag;tagId=".$self->session->form->process("tagId").";revisionDate=".$date,$asset->get("url"),$i18n->get("purge revision prompt")).'</td>
			<td>'.$asset->getTitle.'</td>
			<td><img src="'.$asset->getIcon(1).'" alt="'.$asset->getName.'" />'.$asset->getName.'</td>
			<td><a href="'.$asset->getUrl("func=viewRevision;revisionDate=".$date).'">'.$self->session->datetime->epochToHuman($date).'</a></td>
			<td>'.$by.'</td></tr>';
        }
        $output .= '</table>'.$p->getBarSimple;
	my $tag = $self->session->db->getRow("assetVersionTag","tagId",$self->session->form->process("tagId"));
        return $ac->render($output,$i18n->get("revisions in tag").": ".$tag->{name});
}


#-------------------------------------------------------------------

sub www_purgeRevision {
	my $self = shift;
	return $self->session->privilege->insufficient() unless $self->canEdit;
	my $revisionDate = $self->session->form->process("revisionDate");
	return undef unless $revisionDate;
	WebGUI::Asset->new($self->getId,$self->get("className"),$revisionDate)->purgeRevision;
	if ($self->session->form->process("proceed") eq "manageRevisionsInTag") {
		return $self->www_manageRevisionsInTag;
	}
	return $self->www_manageRevisions;
}


#-------------------------------------------------------------------A

sub www_rollbackVersionTag {
	my $self = shift;
	return $self->session->privilege->adminOnly() unless $self->session->user->isInGroup(3);
	return $self->session->privilege->vitalComponent() if ($self->session->form->process("tagId") eq "pbversion0000000000001" || $self->session->form->process("tagId") eq "pbversion0000000000002");
	my $tagId = $self->session->form->process("tagId");
	if ($tagId) {
		$self->rollbackVersionTag($tagId);
	}
	if ($self->session->form->process("proceed") eq "manageCommittedVersions") {
		return $self->www_manageCommittedVersions;
	}
	return $self->www_manageVersions;
}

#-------------------------------------------------------------------A

sub www_rollbackSiteToTime {
	my $self = shift;
	return $self->session->privilege->adminOnly() unless $self->session->user->isInGroup(3);

}


#-------------------------------------------------------------------

=head2 www_setVersionTag ()

Sets the current user's working version tag.

=cut

sub www_setVersionTag () {
	my $self = shift;
	return $self->session->privilege->insufficient() unless $self->session->user->isInGroup(12);
	$self->session->scratch->set("versionTag",$self->session->form->process("tagId"));
	return $self->www_manageVersions();
}


#-------------------------------------------------------------------

sub www_viewRevision {
	my $self = shift;
	my $otherSelf = WebGUI::Asset->new($self->getId,$self->get("className"),$self->session->form->process("revisionDate"));
	return (defined $otherSelf) ? $otherSelf->www_view : undef;
}

1;

