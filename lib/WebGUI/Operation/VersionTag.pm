package WebGUI::Operation::VersionTag;

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
use WebGUI::AdminConsole;
use WebGUI::International;

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

=head2 www_addVersionTag ()

Displays the add version tag form.

=cut

sub www_addVersionTag {
	my $self = shift;
	my $ac = WebGUI::AdminConsole->new($self->session,"versions");
        return $self->session->privilege->insufficient() unless ($self->session->user->isInGroup(12));
	my $i18n = WebGUI::International->new($self->session,"Asset");
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

sub www_commitVersionTag {
	my $session = shift;
	return $session->privilege->adminOnly() unless $session->user->isInGroup(3);
	my $tagId = $session->form->process("tagId");
	if ($tagId) {
		my $tag = WebGUI::VersionTag->new($session, $tagId);
		$tag->commit if (defined $tag);
	}
	if ($session->form->get("backToSite")) {
		return "";
	}
	return www_manageVersions($session);
}

#-------------------------------------------------------------------

=head2 www_manageVersionTags ()

Shows a list of the currently available asset version tags.

=cut

sub www_manageCommittedVersions {
        my $self = shift;
        my $ac = WebGUI::AdminConsole->new($self->session,"versions");
        return $self->session->privilege->insufficient() unless ($self->session->user->isInGroup(3));
        my $i18n = WebGUI::International->new($self->session,"Asset");
	my $rollback = $i18n->get('rollback');
	my $rollbackPrompt = $i18n->get('rollback version tag confirm');
        $ac->addSubmenuItem($self->getUrl('func=addVersionTag'), $i18n->get("add a version tag"));
        $ac->addSubmenuItem($self->getUrl('func=manageVersions'), $i18n->get("manage versions"));
        my $output = '<table width=100% class="content">
        <tr><th>Tag Name</th><th>Committed On</th><th>Committed By</th><th></th></tr> ';
        my $sth = $self->session->db->read("select tagId,name,commitDate,committedBy from assetVersionTag where isCommitted=1");
        while (my ($id,$name,$date,$by) = $sth->array) {
                my $u = WebGUI::User->new($self->session,$by);
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

=head2 www_manageVersionTags ()

Shows a list of the currently available asset version tags.

=cut

sub www_manageVersions {
	my $self = shift;
        my $ac = WebGUI::AdminConsole->new($self->session,"versions");
        return $self->session->privilege->insufficient() unless ($self->session->user->isInGroup(3));
	my $i18n = WebGUI::International->new($self->session,"Asset");
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
		my $u = WebGUI::User->new($self->session,$by);
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
	my $ac = WebGUI::AdminConsole->new($self->session,"versions");
        return $self->session->privilege->insufficient() unless ($self->session->user->isInGroup(3));
        my $i18n = WebGUI::International->new($self->session,"Asset");
	$ac->addSubmenuItem($self->getUrl('func=addVersionTag'), $i18n->get("add a version tag"));
	$ac->addSubmenuItem($self->getUrl('func=manageCommittedVersions'), $i18n->get("manage committed versions"));
        $ac->addSubmenuItem($self->getUrl('func=manageVersions'), $i18n->get("manage versions"));
        my $output = '<table width=100% class="content">
        <tr><th></th><th>Title</th><th>Type</th><th>Revision Date</th><th>Revised By</th></tr> ';
	my $p = WebGUI::Paginator->new($self->session,$self->getUrl("func=manageRevisionsInTag;tagId=".$self->session->form->process("tagId")));
	$p->setDataByQuery("select assetData.revisionDate, users.username, asset.assetId, asset.className from assetData 
		left join asset on assetData.assetId=asset.assetId left join users on assetData.revisedBy=users.userId
		where assetData.tagId=".$self->session->db->quote($self->session->form->process("tagId")));
	foreach my $row (@{$p->getPageData}) {
        	my ($date,$by,$id, $class) = ($row->{revisionDate}, $row->{username}, $row->{assetId}, $row->{className});
		my $asset = WebGUI::Asset->new($self->session,$id,$class,$date);
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



1;

