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

Package WebGUI::AssetTrash

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
	my $userId = shift || $self->session->user->profileField("userId");
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
                push(@assets, WebGUI::Asset->new($id,$class,$date));
        }
	$sth->finish;
	return \@assets;
}


#-------------------------------------------------------------------

=head2 purge ( )

Deletes an asset from tables and removes anything bound to that asset.

=cut

sub purge {
	my $self = shift;
	return undef if ($self->getId eq $self->session->setting->get("defaultPage") || $self->getId eq $self->session->setting->get("notFoundPage"));
	$self->session->db->beginTransaction;
	foreach my $definition (@{$self->definition}) {
		$self->session->db->write("delete from ".$definition->{tableName}." where assetId=".$self->session->db->quote($self->getId));
	}
	$self->session->db->write("delete from metaData_values where assetId = ".$self->session->db->quote($self->getId));
	$self->session->db->write("delete from asset where assetId=".$self->session->db->quote($self->getId));
	$self->session->db->commit;
	$self->purgeCache;
	WebGUI::Cache->new->deleteChunk(["asset",$self->getId]);
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
	$self->session->db->beginTransaction;
	$self->session->db->write("update asset set state='trash-limbo' where lineage like ".$self->session->db->quote($self->get("lineage").'%'));
	$self->session->db->write("update asset set state='trash', stateChangedBy=".$self->session->db->quote($self->session->user->profileField("userId")).", stateChanged=".time()." where assetId=".$self->session->db->quote($self->getId));
	$self->session->db->commit;
	$self->{_properties}{state} = "trash";
	$self->updateHistory("trashed");
	$self->purgeCache;
}


#-------------------------------------------------------------------

=head2 www_delete

Moves self to trash, returns www_view() method of Parent if canEdit. Otherwise returns AdminConsole rendered insufficient privilege.

=cut

sub www_delete {
	my $self = shift;
	return $self->session->privilege->insufficient() unless $self->canEdit;
	return $self->session->privilege->vitalComponent() if (isIn($self->getId, $self->session->setting->get("defaultPage"), $self->session->setting->get("notFoundPage")));
	$self->trash;
	$self->session->asset = $self->getParent;
	return $self->getParent->www_view;
}

#-------------------------------------------------------------------

=head2 www_deleteList

Moves list of assets to trash, returns www_manageAssets() method of self if canEdit. Otherwise returns AdminConsole rendered insufficient privilege.

=cut

sub www_deleteList {
	my $self = shift;
	return $self->session->privilege->insufficient() unless $self->canEdit;
	foreach my $assetId ($self->session->request->param("assetId")) {
		my $asset = WebGUI::Asset->newByDynamicClass($assetId);
		if ($asset->canEdit) {
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

Returns an AdminConsole to deal with assets in the Trash. If isInGroup(4) is False, renders an insufficient privilege page.

=cut

sub www_manageTrash {
	my $self = shift;
	my $ac = WebGUI::AdminConsole->new($self->session,"trash");
	return $self->session->privilege->insufficient() unless (WebGUI::Grouping::isInGroup(12));
	my ($header, $limit);
        $ac->setHelp("trash manage");
	if ($self->session->form->process("systemTrash") && WebGUI::Grouping::isInGroup(3)) {
		$header = WebGUI::International::get(965,"Asset");
		$ac->addSubmenuItem($self->getUrl('func=manageTrash'), WebGUI::International::get(10));
	} else {
		$ac->addSubmenuItem($self->getUrl('func=manageTrash;systemTrash=1'), WebGUI::International::get(964,"Asset"));
		$limit = 1;
	}
  	$self->session->style->setLink($self->session->config->get("extrasURL").'/assetManager/assetManager.css', {rel=>"stylesheet",type=>"text/css"});
        $self->session->style->setScript($self->session->config->get("extrasURL").'/assetManager/assetManager.js', {type=>"text/javascript"});
        my $i18n = WebGUI::International->new("Asset");
	my $output = "
   <script type=\"text/javascript\">
     var assetManager = new AssetManager();
         assetManager.AddColumn('".WebGUI::Form::checkbox({extras=>'onchange="toggleAssetListSelectAll(this.form);"'})."','','center','form');
         assetManager.AddColumn('".$i18n->get("99")."','','left','');
         assetManager.AddColumn('".$i18n->get("type")."','','left','');
         assetManager.AddColumn('".$i18n->get("last updated")."','','center','');
         assetManager.AddColumn('".$i18n->get("size")."','','right','');
         \n";
	foreach my $child (@{$self->getAssetsInTrash($limit)}) {
		my $title = $child->getTitle;
                $title =~ s/\'/\\\'/g;
         	$output .= "assetManager.AddLine('"
			.WebGUI::Form::checkbox({
				name=>'assetId',
				value=>$child->getId
				})
			."','<a href=\"".$child->getUrl("func=manageAssets")."\">".$title
			."</a>','<img src=\"".$child->getIcon(1)."\" border=\"0\" alt=\"".$child->getName."\" /> ".$child->getName
			."','".WebGUI::DateTime::epochToHuman($child->get("revisionDate"))
			."','".formatBytes($child->get("assetSize"))."');\n";
         	$output .= "assetManager.AddLineSortData('','".$title."','".$child->getName
			."','".$child->get("revisionDate")."','".$child->get("assetSize")."');\n";
	}
	$output .= 'assetManager.AddButton("'.$i18n->get("restore").'","restoreList","manageTrash");
		assetManager.Write();        
                var assetListSelectAllToggle = false;
                function toggleAssetListSelectAll(form){
                        assetListSelectAllToggle = assetListSelectAllToggle ? false : true;
                        for(var i = 0; i < form.assetId.length; i++)
                        form.assetId[i].checked = assetListSelectAllToggle;
                 }
		</script> <div class="adminConsoleSpacer"> &nbsp;</div>';
	return $ac->render($output, $header);
}

#-------------------------------------------------------------------

=head2 www_restoreList ( )

Restores a piece of content from the trash back to it's original location.

=cut

sub www_restoreList {
        my $self = shift;
        return $self->session->privilege->insufficient() unless $self->canEdit;
        foreach my $id ($self->session->request->param("assetId")) {
                my $asset = WebGUI::Asset->newByDynamicClass($id);
                $asset->publish;
        }
        if ($self->session->form->process("proceed") ne "") {
                my $method = "www_".$self->session->form->process("proceed");
                return $self->$method();
        }
        return $self->www_manageTrash();
}


1;

