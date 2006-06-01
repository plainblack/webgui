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

Package WebGUI::AssetLineage

=head1 DESCRIPTION

This is a mixin package for WebGUI::Asset that contains all lineage related functions.

=head1 SYNOPSIS

 use WebGUI::Asset;

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 addChild ( properties [, id, revisionDate ] )

Adds a child asset to a parent. Creates a new AssetID for child. Makes the parent know that it has children. Adds a new asset to the asset table. Returns the newly created Asset.

=head3 properties

A hash reference containing a list of properties to associate with the child. The only required property value is "className"

=head3 id

A unique 22 character ID.  By default WebGUI will generate this and you should almost never specify it. This is mainly here for developers that want to include default templates in their plug-ins.

=head3 revisionDate

An epoch representing the time this asset was created.

=cut

sub addChild {
	my $self = shift;
	my $properties = shift;
	my $id = shift || $self->session->id->generate();
	my $now = shift || $self->session->datetime->time();
	# add a few things just in case the creator forgets
	$properties->{ownerUserId} ||= '3';
	$properties->{groupIdEdit} ||= '12';
	$properties->{groupIdView} ||= '7';
	$properties->{styleTemplateId} ||= 'PBtmpl0000000000000060';

	my $lineage = $self->get("lineage").$self->getNextChildRank;
	$self->{_hasChildren} = 1;
	$self->session->db->beginTransaction;
	$self->session->db->write("insert into asset (assetId, parentId, lineage, creationDate, createdBy, className, state) values (?,?,?,?,?,?,'published')",
		[$id,$self->getId,$lineage,$now,$self->session->user->userId,$properties->{className}]);
	my $temp = WebGUI::Asset->newByPropertyHashRef($self->session,{
		assetId=>$id,
		className=>$properties->{className}
		});
	my $newAsset = $temp->addRevision($properties,$now);
	$self->session->db->commit;
	$self->updateHistory("added child ".$id);
	$self->session->http->setStatus(201,"Asset Creation Successful");
	return $newAsset;
}


#-------------------------------------------------------------------

=head2 cascadeLineage ( newLineage [,oldLineage] )

Updates lineage when asset is moved. Prepends newLineage to the lineage "stack."

=head3 newLineage

An asset descriptor that indicates the direct tree branch containing the asset.

=head3 oldLineage

If not present, asset's existing lineage is used.

=cut

sub cascadeLineage {
        my $self = shift;
        my $newLineage = shift;
        my $oldLineage = shift || $self->get("lineage");
	my $now =$self->session->datetime->time();
        my $prepared = $self->session->db->prepare("update asset set lineage=? where assetId=?");
	my $descendants = $self->session->db->read("select assetId,lineage from asset where lineage like ".$self->session->db->quote($oldLineage.'%'));
	my $cache = WebGUI::Cache->new($self->session);
	while (my ($assetId, $lineage) = $descendants->array) {
		my $fixedLineage = $newLineage.substr($lineage,length($oldLineage));
		$prepared->execute([$fixedLineage,$assetId]);
                # we do the purge directly cuz it's a lot faster than instantiating all these assets
                $cache->deleteChunk(["asset",$assetId]);
	}
	$descendants->finish;
}

#-------------------------------------------------------------------

=head2 demote ( )

Swaps lineage with sister below. Returns 1 if there is a sister to swap. Otherwise returns 0.

=cut

sub demote {
	my $self = shift;
	my ($sisterLineage) = $self->session->db->quickArray("select min(lineage) from asset 
		where parentId=".$self->session->db->quote($self->get("parentId"))." 
		and state='published' and lineage>".$self->session->db->quote($self->get("lineage")));
	if (defined $sisterLineage) {
		$self->swapRank($sisterLineage);
		$self->{_properties}{lineage} = $sisterLineage;
	}
}


#-------------------------------------------------------------------

=head2 formatRank ( value )

Returns a rank as six digits with leading zeros.

=head3 value

An integer up to 6 digits. Would normally be one section (rank) of a lineage.

=cut

sub formatRank {
	my $self = shift;
	my $value = shift;
	return sprintf("%06d",$value);
}


#-------------------------------------------------------------------

=head2 getChildCount ( )

Returns the number of children this asset has. This excludes assets in the trash or clipbaord.

=cut

sub getChildCount {
	my $self = shift;
	my ($count) = $self->session->db->quickArray("select count(*) from asset where state in ('published','archived') and parentId=?", [$self->getId]);
	return $count;
}

#-------------------------------------------------------------------

=head2 getDescendantCount ( )

Returns the number of descendants this asset has. This excludes assets in the trash or clipboard.

=cut

sub getDescendantCount {
	my $self = shift;
	my ($count) = $self->session->db->quickArray("select count(*) from asset where state in ('published', 'archived') and lineage like ?", [$self->get("lineage")."%"]);
	$count--; # have to subtract self
	return $count;
}

#-------------------------------------------------------------------

=head2 getFirstChild ( )

Returns the highest rank, top of the highest rank Asset under current Asset.

=cut

sub getFirstChild {
	my $self = shift;
	unless (exists $self->{_firstChild}) {
		my $assetLineage = $self->session->stow->get("assetLineage");
		my $lineage = $assetLineage->{firstChild}{$self->getId};
		unless ($lineage) {
			($lineage) = $self->session->db->quickArray("select min(asset.lineage) from asset,assetData where asset.parentId=".$self->session->db->quote($self->getId)." and asset.assetId=assetData.assetId and asset.state='published'");
			unless ($self->session->config->get("disableCache")) {
				$assetLineage->{firstChild}{$self->getId} = $lineage;
				$self->session->stow->set("assetLineage", $assetLineage);
			}
		}
		$self->{_firstChild} = WebGUI::Asset->newByLineage($self->session,$lineage);
	}
	return $self->{_firstChild};
}


#-------------------------------------------------------------------

=head2 getLastChild ( )

Returns the lowest rank, bottom of the lowest rank Asset under current Asset.

=cut

sub getLastChild {
	my $self = shift;
	unless (exists $self->{_lastChild}) {
		my $assetLineage = $self->session->stow->get("assetLineage");
		my $lineage = $assetLineage->{lastChild}{$self->getId};
		unless ($lineage) {
			($lineage) = $self->session->db->quickArray("select max(asset.lineage) from asset,assetData where asset.parentId=".$self->session->db->quote($self->getId)." and asset.assetId=assetData.assetId and asset.state='published'");
			$assetLineage->{lastChild}{$self->getId} = $lineage;
			$self->session->stow->set("assetLineage", $assetLineage);
		}
		$self->{_lastChild} = WebGUI::Asset->newByLineage($self->session,$lineage);
	}
	return $self->{_lastChild};
}

#-------------------------------------------------------------------

=head2 getLineage ( relatives,rules )

Returns an array reference of relative asset ids based upon rules.

=head3 relatives

An array reference of relatives to retrieve. Valid parameters are "siblings", "children", "ancestors", "self", "descendants", "pedigree".  If you want to retrieve all assets in the tree, use getRoot->getLineage(["self","descendants"],{returnObjects=>1});

=head3 rules

A hash reference comprising modifiers to relative listing. Rules include:

=head4 statesToInclude

An array reference containing a list of states that should be returned. Defaults to 'published'. Options include 'published', 'trash', 'cliboard', 'clipboard-limbo' and 'trash-limbo'.

=head4 endingLineageLength

An integer limiting the length of the lineages of the assets to be returned. This can help limit levels of depth in the asset tree.

=head4 assetToPedigree

An asset object reference to draw a pedigree from. A pedigree includes ancestors, siblings, descendants and other information. It's specifically used in flexing navigations.

=head4 ancestorLimit

An integer describing how many levels of ancestry from the start point that should be retrieved.

=head4 excludeClasses

An array reference containing a list of asset classes to remove from the result set. The opposite of the includOnlyClasses rule.

=head4 returnObjects

A boolean indicating that we should return objects rather than asset ids.

=head4 invertTree

A boolean indicating whether the resulting asset tree should be returned in reverse order.

=head4 includeOnlyClasses

An array reference containing a list of asset classes to include in the result. If this is specified then no other classes except these will be returned. The opposite of the excludeClasses rule.

=head4 includeArchived

A boolean indicating that we should include archived assets in the result set.

=head4 joinClass

An array reference containing asset classes to join in. There is no real reason to use a joinClass without a whereClause, but it's trivial to use a whereClause if you don't use a joinClass.  You will only be able to filter on the asset table, however.

=head4 whereClause

A string containing extra where clause information for the query.

=head4 orderByClause 

A string containing an order by clause (without the "order by").

=cut

sub getLineage {
	my $self = shift;
	my $relatives = shift;
	my $rules = shift;
	my $lineage = $self->get("lineage");
	my @whereModifiers;
	# let's get those siblings
	if (isIn("siblings",@{$relatives})) {
		push(@whereModifiers, " (asset.parentId=".$self->session->db->quote($self->get("parentId"))." and asset.assetId<>".$self->session->db->quote($self->getId).")");
	}
	# ancestors too
	my @specificFamilyMembers = ();
	if (isIn("ancestors",@{$relatives})) {
		my $i = 1;
		my @familyTree = ($lineage =~ /(.{6})/g);
                while (pop(@familyTree)) {
                        push(@specificFamilyMembers,join("",@familyTree)) if (scalar(@familyTree));
			last if ($i >= $rules->{ancestorLimit} && exists $rules->{ancestorLimit});
			$i++;
                }
	}
	# let's add ourself to the list
	if (isIn("self",@{$relatives})) {
		push(@specificFamilyMembers,$self->get("lineage"));
	}
	if (scalar(@specificFamilyMembers) > 0) {
		push(@whereModifiers,"(asset.lineage in (".$self->session->db->quoteAndJoin(\@specificFamilyMembers)."))");
	}
	# we need to include descendants
	if (isIn("descendants",@{$relatives})) {
		my $mod = "(asset.lineage like ".$self->session->db->quote($lineage.'%')." and asset.lineage<>".$self->session->db->quote($lineage); 
		if (exists $rules->{endingLineageLength}) {
			$mod .= " and length(asset.lineage) <= ".($rules->{endingLineageLength}*6);
		}
		$mod .= ")";
		push(@whereModifiers,$mod);
	}
	# we need to include children
	if (isIn("children",@{$relatives})) {
		push(@whereModifiers,"(asset.parentId=".$self->session->db->quote($self->getId).")");
	}
	# now lets add in all of the siblings in every level between ourself and the asset we wish to pedigree
	if (isIn("pedigree",@{$relatives}) && exists $rules->{assetToPedigree}) {
		my @mods;
		my $lineage = $rules->{assetToPedigree}->get("lineage");
		my $length = $rules->{assetToPedigree}->getLineageLength;
		for (my $i = $length; $i > 0; $i--) {
			my $line = substr($lineage,0,$i*6);
			push(@mods,"( asset.lineage like ".$self->session->db->quote($line.'%')." and  length(asset.lineage)=".(($i+1)*6).")");
			last if ($self->getLineageLength == $i);
		}
		push(@whereModifiers, "(".join(" or ",@mods).")") if (scalar(@mods));
	}
	# deal with custom joined tables if we must
	my $tables = "asset left join assetData on asset.assetId=assetData.assetId ";
	if (exists $rules->{joinClass}) {
		my $className = $rules->{joinClass};
		my $cmd = "use ".$className;
		eval ($cmd);
		$self->session->errorHandler->fatal("Couldn't compile asset package: ".$className.". Root cause: ".$@) if ($@);
		foreach my $definition (@{$className->definition($self->session)}) {
			unless ($definition->{tableName} eq "asset") {
				my $tableName = $definition->{tableName};
				$tables .= " left join $tableName on assetData.assetId=".$tableName.".assetId and assetData.revisionDate=".$tableName.".revisionDate";
			}
			last;
		}
	}
	# formulate a where clause
	my $where;
	## custom states
	if (exists $rules->{statesToInclude}) {
		$where = "asset.state in (".$self->session->db->quoteAndJoin($rules->{statesToInclude}).")";
	} else {
		$where = "asset.state='published'";
	}
	## get only approved items or those that i'm currently working on
	my $archived = " or assetData.status='archived' " if ($rules->{includeArchived});
	$where .= " and (assetData.status='approved' $archived or assetData.tagId=".$self->session->db->quote($self->session->scratch->get("versionTag")).")";
	## class exclusions
	if (exists $rules->{excludeClasses}) {
		my @set;
		foreach my $className (@{$rules->{excludeClasses}}) {
			push(@set,"asset.className not like ".$self->session->db->quote($className.'%'));
		}
		$where .= ' and ('.join(" and ",@set).')';
	}
	## class inclusions
	if (exists $rules->{includeOnlyClasses}) {
		$where .= ' and (asset.className in ('.$self->session->db->quoteAndJoin($rules->{includeOnlyClasses}).'))';
	}
	## finish up our where clause
	$where .= ' and ('.join(" or ",@whereModifiers).')' if (scalar(@whereModifiers));
	if (exists $rules->{whereClause}) {
		$where .= ' and ('.$rules->{whereClause}.')';
	}
	# based upon all available criteria, let's get some assets
	my $columns = "asset.assetId, asset.className, asset.parentId, assetData.revisionDate";
	$where .= " and assetData.revisionDate=(SELECT max(revisionDate) from assetData where assetData.assetId=asset.assetId and (assetData.status='approved' $archived or assetData.tagId=".$self->session->db->quote($self->session->scratch->get("versionTag")).")) ";
	my $sortOrder = ($rules->{invertTree}) ? "asset.lineage desc" : "asset.lineage asc"; 
	if (exists $rules->{orderByClause}) {
		$sortOrder = $rules->{orderByClause};
	}
	my $sql = "select $columns from $tables where $where group by assetData.assetId order by $sortOrder";
	my @lineage;
	my %relativeCache;
	my $sth = $self->session->db->read($sql);
	while (my ($id, $class, $parentId, $version) = $sth->array) {
		# create whatever type of object was requested
		my $asset;
		if ($rules->{returnObjects}) {
			if ($self->getId eq $id) { # possibly save ourselves a hit to the database
				$asset =  $self;
			} else {
				$asset = WebGUI::Asset->new($self->session,$id, $class, $version);
			}
		} else {
			$asset = $id;
		}
		# since we have the relatives info now, why not cache it
		if ($rules->{returnObjects}) {
			my $parent = $relativeCache{$parentId};
			$relativeCache{$id} = $asset;
			$asset->{_parent} = $parent if exists $relativeCache{$parentId};
			$parent->{_firstChild} = $asset unless(exists $parent->{_firstChild});
			$parent->{_lastChild} = $asset;
		}
		push(@lineage,$asset);
	}
	$sth->finish;
	return \@lineage;
}


#-------------------------------------------------------------------

=head2 getLineageLength ( )

Returns the number of Asset members in an Asset's lineage.

=cut


sub getLineageLength {
	my $self = shift;
	return length($self->get("lineage"))/6;
}


#-------------------------------------------------------------------

=head2 getNextChildRank ( )

Returns a 6 digit number with leading zeros of the next rank a child will get.

=cut

sub getNextChildRank {
	my $self = shift;	
	my ($lineage) = $self->session->db->quickArray("select max(lineage) from asset where parentId=".$self->session->db->quote($self->getId));
	my $rank;
	if (defined $lineage) {
		$rank = $self->getRank($lineage);
		$self->session->errorHandler->fatal("Asset ".$self->getId." has too many children.") if ($rank >= 999998);
		$rank++;
	} else {
		$rank = 1;
	}
	return $self->formatRank($rank);
}


#-------------------------------------------------------------------

=head2 getParent ( )

Returns an asset hash of the parent of current Asset.

=cut

sub getParent {
	my $self = shift;
	return $self if ($self->getId eq "PBasset000000000000001");
	$self->{_parent} = WebGUI::Asset->newByDynamicClass($self->session,$self->get("parentId")) unless (defined $self->{_parent});
	return $self->{_parent};
}

#-------------------------------------------------------------------

=head2 getParentLineage ( [lineage] )

Returns the Lineage of parent of Asset.

=head3 lineage

Optional lineage of another Asset.

=cut

sub getParentLineage {
	my $self = shift;
	my $lineage = shift || $self->get("lineage");
	my ($parentLineage) = $lineage =~ m/^(.).{6}$/;
	return $parentLineage;
}

#-------------------------------------------------------------------

=head2 getRank ( [lineage] )

Returns the rank of current Asset by returning the last six digit-entry of a lineage without leading zeros (may return less than 6 digits).

=head3 lineage

Optional specified lineage. 

=cut

sub getRank {
	my $self = shift;
	my $lineage = shift || $self->get("lineage");
	$lineage =~ m/(.{6})$/;
	my $rank = $1 - 0; # gets rid of preceeding 0s.
	return $rank;
}


#-------------------------------------------------------------------

=head2 hasChildren ( )

Returns 1 or the count of Assets with the same parentId as current Asset's assetId (Which may be zero).

=cut

sub hasChildren {
	my $self = shift;
	unless (exists $self->{_hasChildren}) {
		if (exists $self->{_firstChild}) {
			$self->{_hasChildren} = 1;
		} elsif (exists $self->{_lastChild}) {
			$self->{_hasChildren} = 1;
		} else {
			$self->{_hasChildren} = $self->getChildCount;
		}
	}
	return $self->{_hasChildren};
}


#-------------------------------------------------------------------

=head2 newByLineage ( session, lineage )

Constructor. Returns an Asset object based upon given lineage.

=head3 session

A reference to the current session.

=head3 lineage

Lineage string.

=cut

sub newByLineage {
	my $class = shift;
	my $session = shift;
        my $lineage = shift;
	my $assetLineage = $session->stow->get("assetLineage");
	my $id = $assetLineage->{$lineage}{id};
	$class = $assetLineage->{$lineage}{class};
        unless ($id && $class) {
		($id,$class) = $session->db->quickArray("select assetId, className from asset where lineage=".$session->db->quote($lineage));
		$assetLineage->{$lineage}{id} = $id;
		$assetLineage->{$lineage}{class} = $class;
		$session->stow->set("assetLineage",$assetLineage);
	}
	return WebGUI::Asset->new($session, $id, $class);
}


#-------------------------------------------------------------------

=head2 promote ( )

Keeps the same rank of lineage, swaps with sister above. Returns 1 if there is a sister to swap. Otherwise returns 0.

=cut

sub promote {
	my $self = shift;
	my ($sisterLineage) = $self->session->db->quickArray("select max(lineage) from asset 
		where parentId=".$self->session->db->quote($self->get("parentId"))." 
		and state='published' and lineage<".$self->session->db->quote($self->get("lineage")));
	if (defined $sisterLineage) {
		$self->swapRank($sisterLineage);
		$self->{_properties}{lineage} = $sisterLineage;
		return 1;
	}
	return 0;
}


#-------------------------------------------------------------------

=head2 setParent ( newParent )

Moves an asset to a new Parent and returns 1 if successful, otherwise returns 0.

=head3 newParent

An asset object reference representing the new parent to paste the asset to.

=cut

sub setParent {
	my $self = shift;
	my $newParent = shift;
	return 0 unless $self->session->user->isInGroup('4');
	return 0 unless (defined $newParent); # can't move it if a parent object doesn't exist
	return 0 if ($newParent->getId eq $self->get("parentId")); # don't move it to where it already is
	return 0 if ($newParent->getId eq $self->getId); # don't move it to itself
	if (defined $newParent) {
		my $oldLineage = $self->get("lineage");
		return 0 unless $newParent->canEdit;
		my $lineage = $newParent->get("lineage").$newParent->getNextChildRank; 
		return 0 if ($lineage =~ m/^$oldLineage/); # can't move it to its own child
		$self->session->db->beginTransaction;
		$self->session->db->write("update asset set parentId=".$self->session->db->quote($newParent->getId)." where assetId=".$self->session->db->quote($self->getId));
		$self->cascadeLineage($lineage);
		$self->session->db->commit;
		$self->updateHistory("moved to parent ".$newParent->getId);
		$self->{_properties}{lineage} = $lineage;
		$self->purgeCache;
		return 1;
	}
	return 0;
}

#-------------------------------------------------------------------

=head2 setRank ( newRank )

Returns 1. Changes rank of Asset.

=head3 newRank

Value of new Rank.

=cut

sub setRank {
	my $self = shift;
	my $newRank = shift;
	my $currentRank = $self->getRank;
	return 1 if ($newRank == $currentRank); # do nothing if we're moving to ourself
	my $parentLineage = $self->getParentLineage;
	my $siblings = $self->getLineage(["siblings"],{returnObjects=>1});
	my $temp = substr($self->session->id->generate(),0,6);
	if ($newRank < $currentRank) { # have to do the ordering in reverse when the new rank is above the old rank
		@{$siblings} = reverse @{$siblings};
	}
	my $previous = $self->get("lineage");
	$self->session->db->beginTransaction;
	$self->cascadeLineage($temp);
	foreach my $sibling (@{$siblings}) {
		if (isBetween($sibling->getRank, $newRank, $currentRank)) {
			$sibling->cascadeLineage($previous);
			$previous = $sibling->get("lineage");
		}
	}
	$self->cascadeLineage($previous,$temp);
	$self->{_properties}{lineage} = $previous;
	$self->session->db->commit;
	$self->purgeCache;
	$self->updateHistory("changed rank");
	return 1;
}

#-------------------------------------------------------------------

=head2 swapRank ( second [,first] )

Returns 1. Swaps current rank with second rank. 

=head3 first

If specified, swaps second rank with first rank.

=cut

sub swapRank {
	my $self = shift;
	my $second = shift;
	my $first = shift || $self->get("lineage");
	my $temp = substr($self->session->id->generate(),0,6); # need a temp in order to do the swap
	$self->session->db->beginTransaction;
	$self->cascadeLineage($temp,$first);
	$self->cascadeLineage($first,$second);
	$self->cascadeLineage($second,$temp);
	$self->session->db->commit;
	$self->updateHistory("swapped lineage between ".$first." and ".$second);
	return 1;
}


#-------------------------------------------------------------------

=head2 www_demote ( )

Demotes self and returns www_view method of getContainer of self if canEdit, otherwise renders an AdminConsole as insufficient privilege.

=cut

sub www_demote {
	my $self = shift;
	return $self->session->privilege->insufficient() unless $self->canEdit;
	$self->demote;
	return $self->getContainer->www_view; 
}


#-------------------------------------------------------------------

=head2 www_promote ( )

Returns www_view method of getContainer of self. Promotes self. If canEdit is False, returns an insufficient privileges page.

=cut

sub www_promote {
	my $self = shift;
	return $self->session->privilege->insufficient() unless $self->canEdit;
	$self->promote;
	return $self->getContainer->www_view;
}


#-------------------------------------------------------------------

=head2 www_setParent ( )

Returns a www_manageAssets() method. Sets a new parent via the results of a form. If canEdit is False, returns an insufficient privileges page.

=cut

sub www_setParent {
	my $self = shift;
	return $self->session->privilege->insufficient() unless $self->canEdit;
	my $newParent = WebGUI::Asset->newByDynamicClass($self->session->form->process("assetId"));
	if (defined $newParent) {
		my $success = $self->setParent($newParent);
		return $self->session->privilege->insufficient() unless $success;
	}
	return $self->www_manageAssets();

}

#-------------------------------------------------------------------

=head2 www_setRank ( )

Returns a www_manageAssets() method. Sets a new rank via the results of a form. If canEdit is False, returns an insufficient privileges page.

=cut

sub www_setRank {
	my $self = shift;
	return $self->session->privilege->insufficient() unless $self->canEdit;
	my $newRank = $self->session->form->process("rank");
	$self->setRank($newRank) if (defined $newRank);
	$self->session->asset($self->getParent);
	return $self->getParent->www_manageAssets();
}


1;

