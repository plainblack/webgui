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

=head1 NAME

Package WebGUI::Asset

=head1 DESCRIPTION

This is a mixin package for WebGUI::Asset that contains all trash related functions.

=head1 SYNOPSIS

 use WebGUI::Asset;

=head1 METHODS

These methods are available from this class:

=cut


#-------------------------------------------------------------------

=head2 getAssetsInTrash ( [limitToUser,userId] )

Returns an array reference of title, assetId, and classname to the assets in the Trash.

=head3 limitToUser

If True, only return assets last updated by userId.

=head3 userId

If not specified, uses current user.

=cut

sub getAssetsInTrash {
	my $self = shift;
	my $limitToUser = shift;
	my $userId = shift || $self->session->user->userId;
	my @assets;
	my $limit;
	if ($limitToUser) {
		$limit = "and asset.stateChangedBy=".$self->session->db->quote($userId);
	}
	my $sth = $self->session->db->read("
                select 
                        asset.assetId, 
                        assetData.revisionDate,
                        asset.className
                from 
                        asset                 
                left join 
                        assetData on asset.assetId=assetData.assetId 
                where 
                        asset.state='trash'
                        and assetData.revisionDate=(SELECT max(revisionDate) from assetData where assetData.assetId=asset.assetId)
                        $limit
		group by
			assetData.assetId
                order by 
                        assetData.title desc
                        ");
        while (my ($id, $date, $class) = $sth->array) {
                push(@assets, WebGUI::Asset->new($self->session,$id,$class,$date));
        }
	$sth->finish;
	return \@assets;
}


#-------------------------------------------------------------------

=head2 purge ( )

Deletes an asset from tables and removes anything bound to that asset, including descendants.

=cut

sub purge {
	my $self = shift;
	return undef if ($self->getId eq $self->session->setting->get("defaultPage") || $self->getId eq $self->session->setting->get("notFoundPage") || $self->get("isSystem"));
	$self->_invokeWorkflowOnExportedFiles($self->session->setting->get('purgeWorkflow'), 1);

	my $kids = $self->getLineage(["children"],{returnObjects=>1, statesToInclude=>['published', 'clipboard', 'clipboard-limbo','trash','trash-limbo']});
	foreach my $kid (@{$kids}) {
		# Technically get lineage should never return an undefined object from getLineage when called like this, but it did so this saves the world from destruction.
		(defined $kid) ? $kid->purge :
			$self->session->errorHandler->warn("getLineage returned an undefined object in the AssetTrash->purge method.  Unable to purge asset.");
	}
	$self->session->db->beginTransaction;
	foreach my $definition (@{$self->definition($self->session)}) {
		$self->session->db->write("delete from ".$definition->{tableName}." where assetId=".$self->session->db->quote($self->getId));
	}
	$self->session->db->write("delete from metaData_values where assetId = ".$self->session->db->quote($self->getId));
	$self->session->db->write("delete from assetIndex where assetId=".$self->session->db->quote($self->getId));
	$self->session->db->write("delete from asset where assetId=".$self->session->db->quote($self->getId));
	$self->session->db->commit;
	$self->purgeCache;
	WebGUI::Cache->new($self->session)->deleteChunk(["asset",$self->getId]);
	$self->updateHistory("purged");
	$self = undef;
}


#-------------------------------------------------------------------

=head2 trash ( )

Removes asset from lineage, places it in trash state. The "gap" in the lineage is changed in state to trash-limbo.

=cut

sub trash {
	my $self = shift;
	return undef if ($self->getId eq $self->session->setting->get("defaultPage") || $self->getId eq $self->session->setting->get("notFoundPage"));
	foreach my $asset ($self, @{$self->getLineage(['descendants'], {returnObjects => 1})}) {
		$asset->_invokeWorkflowOnExportedFiles($self->session->setting->get('trashWorkflow'), 1);
	}

	my $db = $self->session->db;
	$db->beginTransaction;
	my $sth = $db->read("select assetId from asset where lineage like ?",[$self->get("lineage").'%']);
	while (my ($id) = $sth->array) {
		$db->write("delete from assetIndex where assetId=?",[$id]);
	}
	$db->write("update asset set state='trash-limbo' where lineage like ?",[$self->get("lineage").'%']);
	$db->write("update asset set state='trash', stateChangedBy=?, stateChanged=? where assetId=?",[$self->session->user->userId, $self->session->datetime->time(), $self->getId]);
	$db->commit;
	$self->{_properties}{state} = "trash";
	$self->updateHistory("trashed");
	$self->purgeCache;
}

require WebGUI::Workflow::Activity::DeleteExportedFiles;
sub _invokeWorkflowOnExportedFiles {
	my $self = shift;
	my $workflowId = shift;
	my $clearExportedAs = shift;

	my ($lastExportedAs) = $self->session->db->quickArray("SELECT lastExportedAs FROM asset WHERE assetId = ?", [$self->getId]);
	my $wfInstance = WebGUI::Workflow::Instance->create($self->session, { workflowId => $self->session->setting->get('trashWorkflow') });
	$wfInstance->setScratch(WebGUI::Workflow::Activity::DeleteExportedFiles::DELETE_FILES_SCRATCH(), Storable::freeze([defined($lastExportedAs)? ($lastExportedAs) : ()]));
	$clearExportedAs and $self->session->db->write("UPDATE asset SET lastExportedAs = NULL WHERE assetId = ?", [$self->getId]);
}

#-------------------------------------------------------------------

=head2 www_delete

Moves self to trash, returns www_view() method of Parent if canEdit. Otherwise returns AdminConsole rendered insufficient privilege.

=cut

sub www_delete {
	my $self = shift;
	return $self->session->privilege->insufficient() unless ($self->canEdit && $self->canEditIfLocked);
	return $self->session->privilege->vitalComponent() if (isIn($self->getId, $self->session->setting->get("defaultPage"), $self->session->setting->get("notFoundPage")));
	$self->trash;
	$self->session->asset($self->getParent);
	return $self->getParent->www_view;
}

#-------------------------------------------------------------------

=head2 www_deleteList

Moves list of assets to trash, returns www_manageAssets() method of self if canEdit. Otherwise returns AdminConsole rendered insufficient privilege.

=cut

sub www_deleteList {
	my $self = shift;
	foreach my $assetId ($self->session->form->param("assetId")) {
		my $asset = WebGUI::Asset->newByDynamicClass($self->session,$assetId);
		if ($asset->canEdit && $asset->canEditIfLocked) {
			$asset->trash;
		}
	}
	if ($self->session->form->process("proceed") ne "") {
                my $method = "www_".$self->session->form->process("proceed");
                return $self->$method();
        }
	return $self->www_manageAssets();
}


#-------------------------------------------------------------------

=head2 www_manageTrash ( )

Returns an AdminConsole to deal with assets in the Trash. If user isn't in the Turn On Admin group, renders an insufficient privilege page.

=cut

sub www_manageTrash {
	my $self = shift;
	my $ac = WebGUI::AdminConsole->new($self->session,"trash");
	my $i18n = WebGUI::International->new($self->session,"Asset");
	return $self->session->privilege->insufficient() unless ($self->session->user->isInGroup(12));
	my ($header, $limit);
        $ac->setHelp("trash manage");
	if ($self->session->form->process("systemTrash") && $self->session->user->isInGroup(3)) {
		$header = $i18n->get(965);
		$ac->addSubmenuItem($self->getUrl('func=manageTrash'), $i18n->get(10,"WebGUI"));
	} else {
		$ac->addSubmenuItem($self->getUrl('func=manageTrash;systemTrash=1'), $i18n->get(964));
		$limit = 1;
	}
  	$self->session->style->setLink($self->session->url->extras('assetManager/assetManager.css'), {rel=>"stylesheet",type=>"text/css"});
        $self->session->style->setScript($self->session->url->extras('assetManager/assetManager.js'), {type=>"text/javascript"});
	my $output = "
   <script type=\"text/javascript\">
   //<![CDATA[
     var assetManager = new AssetManager();
         assetManager.AddColumn('".WebGUI::Form::checkbox($self->session,{name=>"checkAllAssetIds", extras=>'onchange="toggleAssetListSelectAll(this.form);"'})."','','center','form');
         assetManager.AddColumn('".$i18n->get("99")."','','left','');
         assetManager.AddColumn('".$i18n->get("type")."','','left','');
         assetManager.AddColumn('".$i18n->get("last updated")."','','center','');
         assetManager.AddColumn('".$i18n->get("size")."','','right','');
         \n";
	foreach my $child (@{$self->getAssetsInTrash($limit)}) {
		my $title = $child->getTitle;
                $title =~ s/\'/\\\'/g;
         	$output .= "assetManager.AddLine('"
			.WebGUI::Form::checkbox($self->session, {
				name=>'assetId',
				value=>$child->getId
				})
			."','<a href=\"".$child->getUrl("func=manageAssets")."\">".$title
			."</a>','<p style=\"display:inline;vertical-align:middle;\"><img src=\"".$child->getIcon(1)."\" style=\"vertical-align:middle;border-style:none;\" alt=\"".$child->getName."\" /></p> ".$child->getName
			."','".$self->session->datetime->epochToHuman($child->get("revisionDate"))
			."','".formatBytes($child->get("assetSize"))."');\n";
         	$output .= "assetManager.AddLineSortData('','".$title."','".$child->getName
			."','".$child->get("revisionDate")."','".$child->get("assetSize")."');\n";
	}
	$output .= '
assetManager.AddButton("'.$i18n->get("restore").'","restoreList","manageTrash");
assetManager.AddButton("'.$i18n->get("purge").'","purgeList","manageTrash");
		assetManager.Write();        
                var assetListSelectAllToggle = false;
                function toggleAssetListSelectAll(form){
                        assetListSelectAllToggle = assetListSelectAllToggle ? false : true;
                        for(var i = 0; i < form.assetId.length; i++)
                        form.assetId[i].checked = assetListSelectAllToggle;
                 }
		 //]]>
		</script> <div class="adminConsoleSpacer"> &nbsp;</div>';
	return $ac->render($output, $header);
}

#-------------------------------------------------------------------

=head2 www_purgeList ( )

Purges a piece of content, including all it's revisions, from the system permanently.

=cut

sub www_purgeList {
        my $self = shift;
        foreach my $id ($self->session->form->param("assetId")) {
                my $asset = WebGUI::Asset->newByDynamicClass($self->session,$id);
                $asset->purge if $asset->canEdit;
        }
        if ($self->session->form->process("proceed") ne "") {
                my $method = "www_".$self->session->form->process("proceed");
                return $self->$method();
        }
        return $self->www_manageTrash();
}

#-------------------------------------------------------------------

=head2 www_restoreList ( )

Restores a piece of content from the trash back to it's original location.

=cut

sub www_restoreList {
        my $self = shift;
        foreach my $id ($self->session->form->param("assetId")) {
                my $asset = WebGUI::Asset->newByDynamicClass($self->session,$id);
                $asset->publish if $asset->canEdit;
        }
        if ($self->session->form->process("proceed") ne "") {
                my $method = "www_".$self->session->form->process("proceed");
                return $self->$method();
        }
        return $self->www_manageTrash();
}


1;

