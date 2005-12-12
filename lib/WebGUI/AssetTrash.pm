package WebGUI::Asset;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2005 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use WebGUI::Session;

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
	my $userId = shift || $session{user}{userId};
	my @assets;
	my $limit;
	if ($limitToUser) {
		$limit = "and asset.stateChangedBy=".quote($userId);
	}
	my $sth = WebGUI::SQL->read("
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
	return undef if ($self->getId eq $session{setting}{defaultPage} || $self->getId eq $session{setting}{notFoundPage});
	WebGUI::SQL->beginTransaction;
	foreach my $definition (@{$self->definition}) {
		WebGUI::SQL->write("delete from ".$definition->{tableName}." where assetId=".quote($self->getId));
	}
	WebGUI::SQL->write("delete from metaData_values where assetId = ".quote($self->getId));
	WebGUI::SQL->write("delete from asset where assetId=".quote($self->getId));
	WebGUI::SQL->commit;
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
	return undef if ($self->getId eq $session{setting}{defaultPage} || $self->getId eq $session{setting}{notFoundPage});
	WebGUI::SQL->beginTransaction;
	WebGUI::SQL->write("update asset set state='trash-limbo' where lineage like ".quote($self->get("lineage").'%'));
	WebGUI::SQL->write("update asset set state='trash', stateChangedBy=".quote($session{user}{userId}).", stateChanged=".time()." where assetId=".quote($self->getId));
	WebGUI::SQL->commit;
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
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
	return WebGUI::Privilege::vitalComponent() if (isIn($self->getId, $session{setting}{defaultPage}, $session{setting}{notFoundPage}));
	$self->trash;
	$session{asset} = $self->getParent;
	return $self->getParent->www_view;
}

#-------------------------------------------------------------------

=head2 www_deleteList

Moves list of assets to trash, returns www_manageAssets() method of self if canEdit. Otherwise returns AdminConsole rendered insufficient privilege.

=cut

sub www_deleteList {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
	foreach my $assetId ($session{req}->param("assetId")) {
		my $asset = WebGUI::Asset->newByDynamicClass($assetId);
		if ($asset->canEdit) {
			$asset->trash;
		}
	}
	if ($session{form}{proceed} ne "") {
                my $method = "www_".$session{form}{proceed};
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
	my $ac = WebGUI::AdminConsole->new("trash");
	return WebGUI::Privilege::insufficient() unless (WebGUI::Grouping::isInGroup(12));
	my ($header, $limit);
        $ac->setHelp("trash manage");
	if ($session{form}{systemTrash} && WebGUI::Grouping::isInGroup(3)) {
		$header = WebGUI::International::get(965,"Asset");
		$ac->addSubmenuItem($self->getUrl('func=manageTrash'), WebGUI::International::get(10));
	} else {
		$ac->addSubmenuItem($self->getUrl('func=manageTrash;systemTrash=1'), WebGUI::International::get(964,"Asset"));
		$limit = 1;
	}
  	WebGUI::Style::setLink($session{config}{extrasURL}.'/assetManager/assetManager.css', {rel=>"stylesheet",type=>"text/css"});
        WebGUI::Style::setScript($session{config}{extrasURL}.'/assetManager/assetManager.js', {type=>"text/javascript"});
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
        return WebGUI::Privilege::insufficient() unless $self->canEdit;
        foreach my $id ($session{req}->param("assetId")) {
                my $asset = WebGUI::Asset->newByDynamicClass($id);
                $asset->publish;
        }
        if ($session{form}{proceed} ne "") {
                my $method = "www_".$session{form}{proceed};
                return $self->$method();
        }
        return $self->www_manageTrash();
}


1;

