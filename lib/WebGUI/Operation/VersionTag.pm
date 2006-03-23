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
use WebGUI::VersionTag;
use WebGUI::HTMLForm;

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

=head2 www_editVersionTag ( session ) 

Sets an approval for a version tag.

=cut

sub www_approveVersionTag {
	my $session = shift;
	my $tag = WebGUI::VersionTag->new($session, $session->form->param("tagId"));
	my $instance = $tag->getWorkflowInstance;
	my $activity = $instance->getNextActivity;
	return $session->privilege->insufficient() unless ($session->user->isInGroup($activity->get("groupToApprove")));
	if ($session->form->process("status", "selectBox") eq "approve") {
		$activity->setApproved($instance);
	} else {
		$activity->setDenied($instance);
	}
	$tag->set({comments=>$session->form->process("comments", "textarea")});
	return www_manageVersions($session);
}

#-------------------------------------------------------------------

=head2 www_editVersionTag ( session, [ tagId ] )

Displays the edit version tag form.

=head3 session

A reference to the current session.

=head3 tagId

An open tag id. This is optional as it normally grabs this value from a form post.

=cut

sub www_editVersionTag {
	my $session = shift;
        return $session->privilege->insufficient() unless ($session->user->isInGroup(12));
	my $tagId = shift || $session->form->param("tagId");
	my $ac = WebGUI::AdminConsole->new($session,"versions");
	my $i18n = WebGUI::International->new($session,"VersionTag");
        $ac->addSubmenuItem($session->url->page('op=manageVersions'), $i18n->get("manage versions"));
	my $f = WebGUI::HTMLForm->new($session);
	my $tag = WebGUI::VersionTag->new($session, $tagId);
	$f->hidden(
		-name=>"op",
		-value=>"editVersionTagSave"
		);
	my $value = $tag->getId if defined $tag;
	$f->hidden(
		-name=>"tagId",
		-value=>$value,
		-defaultValue=>"new"
		);
	$value = $tag->get("name") if defined $tag;
	$f->text(
		-name=>"name",
		-label=>$i18n->get("version tag name"),
		-hoverHelp=>$i18n->get("version tag name description"),
		-value=>$value,
		);
	my $workflowId = (defined $tag) ? $tag->get("workflowId") : $session->setting->get("defaultVersionTagWorkflow");
	my $groupId = (defined $tag) ? $tag->get("groupToUse") : "12";
	if ($session->user->isInGroup("pbgroup000000000000016")) {
		$f->workflow(
			value=>$workflowId,
			type=>"WebGUI::VersionTag"
			);
		$f->group(
			value=>[$groupId],
			name=>"groupToUse",
			label=>$i18n->get("group to use"),
			hoverHelp=>$i18n->get("group to use help")
			);
	} else {
		$f->hidden(
			value=>$workflowId,
			name=>"workflowId"
			);
		$f->hidden(
			value=>$groupId,
			name=>"groupToUse"
			);
	}
	$f->submit;
        return $ac->render($f->print,$i18n->get("edit version tag"));	
}


#-------------------------------------------------------------------

=head2 www_editVersionTagSave ( session )

Adds a version tag and sets the user's default version tag to that.

=head3 session

A reference to the current session.

=cut

sub www_editVersionTagSave {
	my $session = shift;
        return $session->session->privilege->insufficient() unless ($session->user->isInGroup(12));
	if ($session->form->param("tagId") eq "new") {
		my $tag = WebGUI::VersionTag->create($session, {
			name=>$session->form->process("name","text", "Untitled"),
			groupToUse=>$session->form->process("groupToUse","group","12"),
			workflowId=>$session->form->process("workflowId","workflow", $session->setting->get("defaultVersionTagWorkflow"))
			});
		$tag->setWorking;
	} else {
		my $tag = WebGUI::VersionTag->new($session, $session->form->param("tagId"));
		$tag->set({
			name=>$session->form->process("name","text", "Untitled"),
			groupToUse=>$session->form->process("groupToUse","group","12"),
			workflowId=>$session->form->process("workflowId","workflow", $session->setting->get("defaultVersionTagWorkflow"))
			});
	}
	return www_manageVersions($session);
}


#-------------------------------------------------------------------

=head2 www_commitVersionTag ( session ) 

Prompts a user to apply some comments before they commit their tag.

=head3 session

A reference to the current session.

=cut

sub www_commitVersionTag {
	my $session = shift;
	my $tagId = $session->form->param("tagId");
	if ($tagId) {
		my $tag = WebGUI::VersionTag->new($session, $tagId);
		if (defined $tag && $session->user->isInGroup($tag->get("groupToUse"))) {
			my $i18n = WebGUI::International->new($session, "VersionTag");
			my $f = WebGUI::HTMLForm->new($session);
			$f->readOnly(
				label=>$i18n->get("version tag name"),
				value=>$tag->get("name")
				);
			$f->hidden(
				name=>"tagId",
				value=>$session->form->param("tagId")
				);
			$f->hidden(
				name=>"op",
				value=>"commitVersionTagConfirm"
				);
			$f->textarea(
				name=>"comments",
				label=>$i18n->get("comments")
				);
			$f->submit;
        		my $ac = WebGUI::AdminConsole->new($session,"versions");
			return $ac->render($f->print);
		}
	}
	return www_manageVersions($session);
}

#-------------------------------------------------------------------

=head2 www_commitVersionTagConfirm ( session )

Commits a version tag.

=head3 session

A reference to the current session.

=cut

sub www_commitVersionTagConfirm {
	my $session = shift;
	my $tagId = $session->form->param("tagId");
	if ($tagId) {
		my $tag = WebGUI::VersionTag->new($session, $tagId);
		if (defined $tag && $session->user->isInGroup($tag->get("groupToUse"))) {
			$tag->set({comments=>$session->form->process("comments", "textarea")});
			$tag->requestCommit;
			my $i18n = WebGUI::International->new($session, "VersionTag");
        		my $ac = WebGUI::AdminConsole->new($session,"versions");
			return $ac->render(
				'<p>'.$i18n->get("commit accepted").'</p>'
				.'<ul>
				<li><a href="'.$session->url->page.'">'.$i18n->get("493","WebGUI").'</a></li>
				<li><a href="'.$session->url->page("op=manageVersions").'">'.$i18n->get("manage versions").'</a></li>
				</ul>'	
				);
		}
	}
	return www_manageVersions($session);	
}

#-------------------------------------------------------------------

=head2 www_manageCommittedVersions ( session )

Shows a list of the currently available asset version tags.

=head3 session

A reference to the current session.

=cut

sub www_manageCommittedVersions {
        my $session = shift;
        return $session->privilege->adminOnly() unless ($session->user->isInGroup(3));
        my $ac = WebGUI::AdminConsole->new($session,"versions");
        my $i18n = WebGUI::International->new($session,"VersionTag");
	my $rollback = $i18n->get('rollback');
	my $rollbackPrompt = $i18n->get('rollback version tag confirm');
        $ac->addSubmenuItem($session->url->page('op=editVersionTag'), $i18n->get("add a version tag"));
        $ac->addSubmenuItem($session->url->page('op=manageVersions'), $i18n->get("manage versions"));
        my $output = '<table width=100% class="content">
        <tr><th>'.$i18n->get("version tag name").'</th><th>'.$i18n->get("committed on").'</th><th>'.$i18n->get("committed by").'</th><th></th></tr> ';
        my $sth = $session->db->read("select tagId,name,commitDate,committedBy from assetVersionTag where isCommitted=1");
        while (my ($id,$name,$date,$by) = $sth->array) {
                my $u = WebGUI::User->new($session,$by);
                $output .= '<tr>
			<td><a href="'.$session->url->page("op=manageRevisionsInTag;tagId=".$id).'">'.$name.'</a></td>
			<td>'.$session->datetime->epochToHuman($date).'</td>
			<td>'.$u->username.'</td>
			<td><a href="'.$session->url->page("proceed=manageCommittedVersions;op=rollbackVersionTag;tagId=".$id).'" onclick="return confirm(\''.$rollbackPrompt.'\');">'.$rollback.'</a></td></tr>';
        }
        $sth->finish;
        $output .= '</table>';
        return $ac->render($output,$i18n->get("committed versions"));
}


#-------------------------------------------------------------------

=head2 www_manageVersions ( session )

Shows a list of the currently available asset version tags.

=head3 session

A reference to the current session.

=cut

sub www_manageVersions {
	my $session = shift;
        return $session->privilege->insufficient() unless ($session->user->isInGroup(12));
        my $ac = WebGUI::AdminConsole->new($session,"versions");
	my $i18n = WebGUI::International->new($session,"VersionTag");
	$ac->setHelp("versions manage");
	$ac->addSubmenuItem($session->url->page('op=editVersionTag'), $i18n->get("add a version tag"));
	$ac->addSubmenuItem($session->url->page('op=manageCommittedVersions'), $i18n->get("manage committed versions")) if ($session->user->isInGroup(3));
	my ($tag,$workingTagId) = $session->db->quickArray("select name,tagId from assetVersionTag where tagId=?",[$session->scratch->get("versionTag")]);
	$tag ||= "None";
	my $rollback = $i18n->get("rollback");
	my $commit = $i18n->get("commit");
	my $setTag = $i18n->get("set tag");
	my $rollbackPrompt = $i18n->get("rollback version tag confirm");
	my $commitPrompt = $i18n->get("commit version tag confirm");
	my $output = '<p>'.$i18n->get("current tag is called").': <b>'.$tag.'</b>.</p><table width=100% class="content">
	<tr><th></th><th>'.$i18n->get("version tag name").'</th><th>'.$i18n->get("created on").'</th><th>'.$i18n->get("created by").'</th><th></th></tr> ';
	my $sth = $session->db->read("select tagId,name,creationDate,createdBy,groupToUse from assetVersionTag where isCommitted=0 and isLocked=0");
	while (my ($id,$name,$date,$by,$group) = $sth->array) {
		next unless ($session->user->isInGroup($group));
		my $u = WebGUI::User->new($session,$by);
		$output .= '<tr>
			<td>'
				.$session->icon->delete("op=rollbackVersionTag;tagId=".$id,undef,$rollbackPrompt)
				.$session->icon->edit("op=editVersionTag;tagId=".$id)
			.'</td>
			<td><a href="'.$session->url->page("op=manageRevisionsInTag;tagId=".$id).'">'.$name.'</a></td>
			<td>'.$session->datetime->epochToHuman($date).'</td>
			<td>'.$u->username.'</td>
			<td>';
		unless ($workingTagId eq $id) {
			$output .= '<a href="'.$session->url->page("op=setWorkingVersionTag;tagId=".$id).'">'.$setTag.'</a> | ';
		}
		$output .='
			<a href="'.$session->url->page("op=commitVersionTag;tagId=".$id).'" onclick="return confirm(\''.$commitPrompt.'\');">'.$commit.'</a></td></tr>';
	}
	$sth->finish;	
	$output .= '</table>';
	return $ac->render($output);
}


#-------------------------------------------------------------------

=head2 www_manageRevisionsInTag ( session )

Displays a list of the revsions associated with this tag.

=head3 session

A reference to the current session.

=cut

sub www_manageRevisionsInTag {
	my $session = shift;
	my $tagId = $session->form->get("tagId");
	my $tag = WebGUI::VersionTag->new($session, $tagId);
        return $session->privilege->insufficient() unless ($session->user->isInGroup($tag->get("groupToUse")));
	my $ac = WebGUI::AdminConsole->new($session,"versions");
        my $i18n = WebGUI::International->new($session,"VersionTag");
	$ac->addSubmenuItem($session->url->page('op=editVersionTag'), $i18n->get("add a version tag"));
	$ac->addSubmenuItem($session->url->page('op=manageCommittedVersions'), $i18n->get("manage committed versions")) if ($session->user->isInGroup(3));
        $ac->addSubmenuItem($session->url->page('op=manageVersions'), $i18n->get("manage versions"));
        my $output = "";
	if ($session->form->param("workflowInstanceId")) {
		my $instance = WebGUI::Workflow::Instance->new($session, $session->form->param("workflowInstanceId"));
		if (defined $instance) {
			my $form = WebGUI::HTMLForm->new($session);
			$form->hidden(
				name=>"tagId",
				value=>$tagId
				);
			$form->hidden(
				name=>"op",
				value=>"approveVersionTag"
				);
			$form->selectBox(
				name=>"status",
				defaultValue=>"approve",
				label=>$i18n->get("approve/deny"),
				hoverHelp=>$i18n->get("approve/deny help"),
				options=>{
					approve=>$i18n->get("approve"),
					deny=>$i18n->get("deny")
					},
				);
			$form->textarea(
				name=>"comments",
				label=>$i18n->get("comments"),
				hoverHelp=>$i18n->get("comments help")
				);
			$form->submit;
			$output .= $form->print;
		}
	}
	if ($tag->get("comments")) {
		my $comments = $tag->get("comments");
		$comments =~ s/\n/<br \/>/g;
		$output .= $comments;
	}
	$output .= '<table width=100% class="content">
        <tr><th></th><th>'.$i18n->get(99,"Asset").'</th><th>'.$i18n->get("type","Asset").'</th><th>'.$i18n->get("revision date","Asset").'</th><th>'.$i18n->get("revised by","Asset").'</th></tr> ';
	my $p = WebGUI::Paginator->new($session,$session->url->page("op=manageRevisionsInTag;tagId=".$tag->getId));
	$p->setDataByQuery("select assetData.revisionDate, users.username, asset.assetId, asset.className from assetData 
		left join asset on assetData.assetId=asset.assetId left join users on assetData.revisedBy=users.userId
		where assetData.tagId=?",undef, undef, [$tag->getId]);
	foreach my $row (@{$p->getPageData}) {
        	my ($date,$by,$id, $class) = ($row->{revisionDate}, $row->{username}, $row->{assetId}, $row->{className});
		my $asset = WebGUI::Asset->new($session,$id,$class,$date);
                $output .= '<tr><td>'
			.$session->icon->delete("func=purgeRevision;proceed=manageRevisionsInTag;tagId=".$tag->getId.";revisionDate=".$date,$asset->get("url"),$i18n->get("purge revision prompt"))
			.$session->icon->view("func=viewRevision;revisionDate=".$date, $asset->get("url"))
			.'</td>
			<td>'.$asset->getTitle.'</td>
			<td><img src="'.$asset->getIcon(1).'" alt="'.$asset->getName.'" />'.$asset->getName.'</td>
			<td>'.$session->datetime->epochToHuman($date).'</td>
			<td>'.$by.'</td></tr>';
        }
        $output .= '</table>'.$p->getBarSimple;
	$tag = $session->db->getRow("assetVersionTag","tagId",$tag->getId);
        return $ac->render($output,$i18n->get("revisions in tag").": ".$tag->{name});
}


#-------------------------------------------------------------------

=head2 www_rollbackVersionTag ( session )

Deletes a version tag and all asset revisions attached to it.

=head2 session

A reference to the current session.

=cut

sub www_rollbackVersionTag {
	my $session = shift;
	return $session->privilege->adminOnly() unless $session->user->isInGroup(3);
	my $tagId = $session->form->process("tagId");
	return $session->privilege->vitalComponent() if ($tagId eq "pbversion0000000000001");
	if ($tagId) {
		my $tag = WebGUI::VersionTag->new($session, $tagId);
		$tag->rollback if defined $tag;
	}
	if ($session->form->process("proceed") eq "manageCommittedVersions") {
		return www_manageCommittedVersions($session);
	}
	return www_manageVersions($session);
}



#-------------------------------------------------------------------

=head2 www_setWorkingVersionTag ( session )

Sets the current user's working version tag.

=head3 session

A reference to the current session.

=cut

sub www_setWorkingVersionTag () {
	my $session = shift;
	my $tag = WebGUI::VersionTag->new($session, $session->form->process("tagId"));
	if (defined $tag && $session->user->isInGroup($tag->get("groupToUse"))) {
		$tag->setWorking();
	}
	if ($session->form->param("backToSite")) {
		return undef;
	}
	return www_manageVersions($session);
}



1;

