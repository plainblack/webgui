package WebGUI::Asset;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2007 Plain Black Corporation.
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

Package WebGUI::AssetClipboard

=head1 DESCRIPTION

This is a mixin package for WebGUI::Asset that contains all clipboard related functions.

=head1 SYNOPSIS

 use WebGUI::Asset;


=head1 METHODS

These methods are available from this class:

=cut




#-------------------------------------------------------------------

=head2 cut ( )

Removes asset from lineage, places it in clipboard state. The "gap" in the lineage is changed in state to clipboard-limbo.

=cut

sub cut {
	my $self = shift;
	return undef if ($self->getId eq $self->session->setting->get("defaultPage") || $self->getId eq $self->session->setting->get("notFoundPage"));
	$self->session->db->beginTransaction;
	$self->session->db->write("update asset set state='clipboard-limbo' where lineage like ? and state='published'",[$self->get("lineage").'%']);
	$self->session->db->write("update asset set state='clipboard', stateChangedBy=?, stateChanged=? where assetId=?", [$self->session->user->userId, $self->session->datetime->time(), $self->getId]);
	$self->session->db->commit;
	$self->updateHistory("cut");
	$self->{_properties}{state} = "clipboard";
	$self->purgeCache;
}
 

#-------------------------------------------------------------------

=head2 duplicate ( [ options ] )

Duplicates this asset, returning the new asset.

=head3 options

A hash reference of options that can modify how this method works.

=head4 skipAutoCommitWorkflows

Assets that normally autocommit their workflows (like CS Posts, and Wiki Pages) won't if this is true.

=cut

sub duplicate {
        my $self = shift;
	my $options = shift;
        my $newAsset = $self->getParent->addChild($self->get, undef, undef, {skipAutoCommitWorkflows=>$options->{skipAutoCommitWorkflows}});
        my $sth = $self->session->db->read("select * from metaData_values where assetId = ?", [$self->getId]);
        while (my $h = $sth->hashRef) {
                $self->session->db->write("insert into metaData_values (fieldId, assetId, value) values (?, ?, ?)", [$h->{fieldId}, $newAsset->getId, $h->{value}]);
        }
        return $newAsset;
}


#-------------------------------------------------------------------

=head2 getAssetsInClipboard ( [limitToUser,userId,expireTime] )

Returns an array reference of assets that are in the clipboard.  Only assets that are committed
or that are under the current user's version tag are returned.

=head3 limitToUser

If True, only return assets last updated by userId, specified below.

=head3 userId

If not specified, uses current user.

=head3 expireTime

If defined, then uses expireTime to limit returned assets to only include those
before expireTime.

=cut

sub getAssetsInClipboard {
	my $self = shift;
    my $session = $self->session;
	my $limitToUser = shift;
	my $userId = shift || $session->user->userId;
    my $expireTime = shift;

    my @limits = ();
	if ($limitToUser) {
		push @limits,  "asset.stateChangedBy=".$session->db->quote($userId);
	}
    if (defined $expireTime) {
		push @limits,  "stateChanged < ".$expireTime;
    }

    my $limit = join ' and ', @limits;

    my $root = WebGUI::Asset->getRoot($self->session);
    return $root->getLineage(
       ["descendants", ],
       {
           statesToInclude => ["clipboard"],
           returnObjects   => 1,
           whereClause     => $limit,
       }
    );
}

#-------------------------------------------------------------------

=head2 paste ( assetId )

Returns 1 if can paste an asset to a Parent. Sets the Asset to published. Otherwise returns 0.

=head3 assetId

Alphanumeric ID tag of Asset.

=cut

sub paste {
	my $self = shift;
	my $assetId = shift;
	my $pastedAsset = WebGUI::Asset->newByDynamicClass($self->session,$assetId);
	return 0 unless ($self->get("state") eq "published");

    # Don't allow a shortcut to create an endless loop
	return 0 if ($pastedAsset->get("className") eq "WebGUI::Asset::Shortcut" && $pastedAsset->get("shortcutToAssetId") eq $self->getId);
	if ($self->getId eq $pastedAsset->get("parentId") || $pastedAsset->setParent($self)) {
		$pastedAsset->publish(['clipboard','clipboard-limbo']); # Paste only clipboard items
		$pastedAsset->updateHistory("pasted to parent ".$self->getId);
        
        # Update lineage in search index.
        my $updateAssets = $pastedAsset->getLineage(['self', 'descendants'], {returnObjects => 1});
 
        foreach (@{$updateAssets}) {
            $_->indexContent();
        }

		return 1;
	}
        
    return 0;
}

#-------------------------------------------------------------------

=head2 www_copy ( )

Duplicates self, cuts duplicate, returns self->getContainer->www_view if canEdit. Otherwise returns an AdminConsole rendered as insufficient privilege.

=cut

sub www_copy {
	my $self = shift;
	return $self->session->privilege->insufficient() unless $self->canEdit;

        # with: 'children' || 'descendants' || ''
        my $with = $self->session->form->get('with') || '';

        if ($with) {
            my $childrenOnly = $with eq 'children';
            my $newAsset = $self->duplicateBranch($childrenOnly);
            $newAsset->update({ title=>$self->getTitle.' (copy)'});
            $newAsset->cut;
            return $self->session->asset($self->getContainer)->www_view;
        }
        else {
            my $newAsset = $self->duplicate({skipAutoCommitWorkflows => 1});
            $newAsset->update({ title=>$self->getTitle.' (copy)'});
            $newAsset->cut;
            return $self->session->asset($self->getContainer)->www_view;
        }
}

#-------------------------------------------------------------------

=head2 www_copyList ( )

Copies to clipboard assets in a list, then returns self calling method www_manageAssets(), if canEdit. Otherwise returns AdminConsole rendered insufficient privilege.

=cut

sub www_copyList {
	my $self = shift;
	return $self->session->privilege->insufficient() unless $self->canEdit;
	foreach my $assetId ($self->session->form->param("assetId")) {
		my $asset = WebGUI::Asset->newByDynamicClass($self->session,$assetId);
		if ($asset->canEdit) {
			my $newAsset = $asset->duplicate({skipAutoCommitWorkflows => 1});
			$newAsset->update({ title=>$newAsset->getTitle.' (copy)'});
			$newAsset->cut;
		}
	}
	if ($self->session->form->process("proceed") ne "") {
                my $method = "www_".$self->session->form->process("proceed");
                return $self->$method();
        }
	return $self->www_manageAssets();
}

#-------------------------------------------------------------------

=head2 www_createShortcut ( )

=cut

sub www_createShortcut {
	my $self = shift;
	return $self->session->privilege->insufficient() unless ($self->session->user->isInGroup(4));	
	my $isOnDashboard = $self->getParent->isa('WebGUI::Asset::Wobject::Dashboard');

	my $shortcutParent = $isOnDashboard? $self->getParent : WebGUI::Asset->getImportNode($self->session);
	my $child = $shortcutParent->addChild({
		className=>'WebGUI::Asset::Shortcut',
		shortcutToAssetId=>$self->getId,
		title=>$self->getTitle,
		menuTitle=>$self->getMenuTitle,
		isHidden=>$self->get("isHidden"),
		newWindow=>$self->get("newWindow"),
		ownerUserId=>$self->get("ownerUserId"),
		groupIdEdit=>$self->get("groupIdEdit"),
		groupIdView=>$self->get("groupIdView"),
		url=>$self->get("title"),
		templateId=>'PBtmpl0000000000000140'
	});

	if ($isOnDashboard) {
		return $self->getParent->www_view;
	} else {
		$child->cut;
		$self->session->asset($self->getContainer);
		return $self->session->asset->www_manageAssets if ($self->session->form->process("proceed") eq "manageAssets");
		return $self->session->asset->www_view;
	}
}

#-------------------------------------------------------------------

=head2 www_cut ( )

Cuts (removes to clipboard) self, returns the www_view of the Parent if canEdit. Otherwise returns AdminConsole rendered insufficient privilege.

=cut

sub www_cut {
	my $self = shift;
	return $self->session->privilege->insufficient() unless $self->canEdit;
	$self->cut;
	$self->session->asset($self->getParent);
	return $self->getParent->www_view;
}

#-------------------------------------------------------------------

=head2 www_cutList ( )

Cuts assets in a list (removes to clipboard), then returns self calling method www_manageAssets(), if canEdit. Otherwise returns AdminConsole rendered insufficient privilege.

=cut

sub www_cutList {
	my $self = shift;
	return $self->session->privilege->insufficient() unless $self->canEdit;
	foreach my $assetId ($self->session->form->param("assetId")) {
		my $asset = WebGUI::Asset->newByDynamicClass($self->session,$assetId);
		if ($asset->canEdit) {
			$asset->cut;
		}
	}
	if ($self->session->form->process("proceed") ne "") {
                my $method = "www_".$self->session->form->process("proceed");
                return $self->$method();
        }
	return $self->www_manageAssets();
}

#-------------------------------------------------------------------

=head2 www_duplicateList ( )

Creates a bunch of duplicate assets under the same parent.

=cut

sub www_duplicateList {
	my $self = shift;
	return $self->session->privilege->insufficient() unless $self->canEdit;
	foreach my $assetId ($self->session->form->param("assetId")) {
		my $asset = WebGUI::Asset->newByDynamicClass($self->session,$assetId);
		if ($asset->canEdit) {
			my $newAsset = $asset->duplicate;
			$newAsset->update({ title=>$newAsset->getTitle.' (copy)'});
		}
	}
	if ($self->session->form->process("proceed") ne "") {
                my $method = "www_".$self->session->form->process("proceed");
                return $self->$method();
        }
	return $self->www_manageAssets();
}

#-------------------------------------------------------------------

=head2 www_emptyClipboard ( )

Moves assets in clipboard to trash. Returns www_manageClipboard() when finished. If isInGroup(4) returns False, insufficient privilege is rendered.

=cut

sub www_emptyClipboard {
	my $self = shift;
	my $ac = WebGUI::AdminConsole->new($self->session,"clipboard");
	return $self->session->privilege->insufficient() unless ($self->session->user->isInGroup(4));
	foreach my $asset (@{$self->getAssetsInClipboard(!($self->session->form->process("systemClipboard") && $self->session->user->isInGroup(3)))}) {
		$asset->trash;
	}
	return $self->www_manageClipboard();
}


#-------------------------------------------------------------------

=head2 www_manageClipboard ( )

Returns an AdminConsole to deal with assets in the Clipboard. If isInGroup(12) is False, renders an insufficient privilege page.

=cut

sub www_manageClipboard {
	my $self = shift;
	my $ac = WebGUI::AdminConsole->new($self->session,"clipboard");
	return $self->session->privilege->insufficient() unless ($self->session->user->isInGroup(12));
	my $i18n = WebGUI::International->new($self->session, "Asset");
	my ($header,$limit);
        $ac->setHelp("clipboard manage");
	if ($self->session->form->process("systemClipboard") && $self->session->user->isInGroup(3)) {
		$header = $i18n->get(966);
		$ac->addSubmenuItem($self->getUrl('func=manageClipboard'), $i18n->get(949));
		$ac->addSubmenuItem($self->getUrl('func=emptyClipboard;systemClipboard=1'), $i18n->get(959), 
			'onclick="return window.confirm(\''.$i18n->get(951,"WebGUI").'\')"',"Asset");
	} else {
		$ac->addSubmenuItem($self->getUrl('func=manageClipboard;systemClipboard=1'), $i18n->get(954));
		$ac->addSubmenuItem($self->getUrl('func=emptyClipboard'), $i18n->get(950),
			'onclick="return window.confirm(\''.$i18n->get(951,"WebGUI").'\')"',"Asset");
		$limit = 1;
	}
$self->session->style->setLink($self->session->url->extras('assetManager/assetManager.css'), {rel=>"stylesheet",type=>"text/css"});
        $self->session->style->setScript($self->session->url->extras('assetManager/assetManager.js'), {type=>"text/javascript"});
        my $output = "
   <script type=\"text/javascript\">
   //<![CDATA[
     var assetManager = new AssetManager();
         assetManager.AddColumn('".WebGUI::Form::checkbox($self->session,{name=>"checkAllAssetIds", extras=>'onclick="toggleAssetListSelectAll(this.form);"'})."','','center','form');
         assetManager.AddColumn('".$i18n->get("99")."','','left','');
         assetManager.AddColumn('".$i18n->get("type")."','','left','');
         assetManager.AddColumn('".$i18n->get("last updated")."','','center','');
         assetManager.AddColumn('".$i18n->get("size")."','','right','');
         \n";
        foreach my $child (@{$self->getAssetsInClipboard($limit)}) {
		my $title = $child->getTitle;
                $title =~ s/\'/\\\'/g;
                $output .= "assetManager.AddLine('"
                        .WebGUI::Form::checkbox($self->session,{
                                name=>'assetId',
                                value=>$child->getId
                                })
                        ."','<a href=\"".$child->getUrl("func=manageAssets")."\">".$title
                        ."</a>','<p style=\"display:inline;vertical-align:middle;\"><img src=\"".$child->getIcon(1)."\" style=\"border-style:none;vertical-align:middle;\" alt=\"".$child->getName."\" /></p> ".$child->getName
                        ."','".$self->session->datetime->epochToHuman($child->get("revisionDate"))
                        ."','".formatBytes($child->get("assetSize"))."');\n";
                $output .= "assetManager.AddLineSortData('','".$title."','".$child->getName
                        ."','".$child->get("revisionDate")."','".$child->get("assetSize")."');\n";
        }
        $output .= 'assetManager.AddButton("'.$i18n->get("delete").'","deleteList","manageClipboard");
		assetManager.AddButton("'.$i18n->get("restore").'","restoreList","manageClipboard");
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

=head2 www_paste ( )

Returns "". Pastes an asset. If canEdit is False, returns an insufficient privileges page.

=cut

sub www_paste {
	my $self = shift;
	return $self->session->privilege->insufficient() unless $self->canEdit;
	$self->paste($self->session->form->process("assetId"));
	return "";
}

#-------------------------------------------------------------------

=head2 www_pasteList ( )

Returns a www_manageAssets() method. Pastes a selection of assets. If canEdit is False, returns an insufficient privileges page.

=cut

sub www_pasteList {
	my $self = shift;
	return $self->session->privilege->insufficient() unless $self->canEdit;
	foreach my $clipId ($self->session->form->param("assetId")) {
		$self->paste($clipId);
	}
	return $self->www_manageAssets();
}


1;

