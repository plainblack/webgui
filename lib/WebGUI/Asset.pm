package WebGUI::Asset;

#needs documentation

use strict;
use WebGUI::DateTime;
use WebGUI::Grouping;
use WebGUI::Id;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Utility;


sub addChild {
	my $self = shift;
	my $properties = shift;
	my $id = WebGUI::Id::generate();
	my $lineage = $self->get("lineage").$self->getNextChildRank;
	WebGUI::SQL->write("insert into asset (assetId, parentId, lineage, state, namespace, url, startDate, endDate) 
		values (".quote($id).",".quote($self->getId).", ".quote($lineage).", 
		'published', ".quote($properties->{namespace}).", ".quote($id).",
		997995720, 9223372036854775807)");
	my $newAsset = WebGUI::Asset->new($id);
	$newAsset->set($properties);
	return $newAsset;
}

sub canEdit {
	my $self = shift;
	my $userId = shift || $session{user}{userId};
 	if ($userId eq $self->get("ownerId")) {
                return 1;
	}
        return WebGUI::Grouping::isInGroup($self->get("groupIdEdit"),$userId);
}

sub canView {
	my $self = shift;
	my $userId = shift || $session{user}{userId};
	if ($userId eq $self->get("ownerId")) {
                return 1;
        } elsif ($self->get("startDate") < time() && 
		$self->get("endDate") > time() && 
		WebGUI::Grouping::isInGroup($self->get("groupIdView"),$userId)) {
                return 1;
        }
        return $self->canEdit($userId);
}

sub cascadeLineage {
	my $self = shift;
	my $newLineage = shift;
	my $oldLineage = shift || $self->get("lineage");
	WebGUI::SQL->write("update asset set lineage=concat(".quote($newLineage).", substring(lineage from ".(length($oldLineage)+1).")) 
		where lineage like ".quote($oldLineage.'%'));
}

sub cut {
	my $self = shift;
	WebGUI::SQL->beginTransaction;
	WebGUI::SQL->write("update asset set state='limbo' where lineage like ".quote($self->get("lineage").'%'));
	WebGUI::SQL->write("update asset set state='clipboard' where assetId=".quote($self->getId));
	WebGUI::SQL->commit;
	$self->{_properties}{state} = "clipboard";
}

sub delete {
	my $self = shift;
	WebGUI::SQL->beginTransaction;
	WebGUI::SQL->write("update asset set state='limbo' where lineage like ".quote($self->get("lineage").'%'));
	WebGUI::SQL->write("update asset set state='trash' where assetId=".quote($self->getId));
	WebGUI::SQL->commit;
	$self->{_properties}{state} = "trash";
}

sub demote {
	my $self = shift;
	my ($sisterLineage) = WebGUI::SQL->quickArray("select min(lineage) from asset 
		where parentId=".quote($self->get("parentId"))." 
		and lineage>".quote($self->get("lineage")));
	if (defined $sisterLineage) {
		$self->swapRank($sisterLineage);
		$self->{_properties}{lineage} = $sisterLineage;
	}
}

sub duplicate {
	my $self = shift;
	my $newAsset = $self->addChild($self->get);
	return $newAsset;
}

sub fixUrl {
	my $self = shift;
	my $url = WebGUI::URL::urlize(shift);
	$url .= ".".$session{setting}{urlExtension} if ($url =~ /\./ && $session{setting}{urlExtension} ne "");
	my ($test) = WebGUI::SQL->quickArray("select url from asset where assetId<>".quote($self->getId)." and url=".quote($url));
        if ($test) {
                my @parts = split(/\./,$url);
                if ($parts[0] =~ /(.*)(\d+$)/) {
                        $parts[0] = $1.($2+1);
                } elsif ($test ne "") {
                        $parts[0] .= "2";
                }
                $url = join(".",@parts);
                $url = $self->setUrl($url);
        }
	return $url;
}

sub formatRank {
	my $self = shift;
	my $value = shift;
	return sprintf("%06d",$value);
}

sub get {
	my $self = shift;
	my $propertyName = shift;
	if (defined $propertyName) {
		return $self->{_properties}{$propertyName};
	}
	return $self->{_properties};
}

sub getAdminConsole {
	my $self = shift;
	my $ac = WebGUI::AdminConsole->set("assets");
	return $ac;
}

sub getEditForm {
	my $self = shift;
	my $tabform = WebGUI::TabForm->new();
	$tabform->hidden({
		name=>"func",
		value=>"editSave"
		});
	if ($session{form}{addNew}) {
		$tabform->hidden({
			name=>"addNew",
			value=>"1"
			});
	}
	$tabform->add("properties",WebGUI::International::get("properties","Asset"));
	$tabform->getTab("properties")->readOnly(
		-label=>WebGUI::International::get("asset id","Asset"),
		-value=>$self->get("assetId")
		);
	$tabform->getTab("properties")->text(
		-label=>WebGUI::International::get(99),
		-name=>"title",
		-value=>$self->get("title")
		);
	$tabform->getTab("properties")->text(
		-label=>WebGUI::International::get(411),
		-name=>"menuTitle",
		-value=>$self->get("menuTitle"),
		-uiLevel=>1
		);
        $tabform->getTab("properties")->text(
                -name=>"url",
                -label=>WebGUI::International::get(104),
                -value=>$self->get("url"),
                -uiLevel=>3
                );
	$tabform->getTab("properties")->yesNo(
                -name=>"hideFromNavigation",
                -value=>$self->get("hideFromNavigation"),
                -label=>WebGUI::International::get(886),
                -uiLevel=>6
                );
        $tabform->getTab("properties")->yesNo(
                -name=>"newWindow",
                -value=>$self->get("newWindow"),
                -label=>WebGUI::International::get(940),
                -uiLevel=>6
                );
        $tabform->getTab("properties")->yesNo(
                -name=>"encryptPage",
                -value=>$self->get("encryptPage"),
                -label=>WebGUI::International::get('encrypt page'),
                -uiLevel=>6
                );
        $tabform->getTab("properties")->textarea(
                -name=>"synopsis",
                -label=>WebGUI::International::get(412),
                -value=>$self->get("synopsis"),
                -uiLevel=>3
                );
	my @data = WebGUI::DateTime::secondsToInterval($self->get("cacheTimeout"));
        $tabform->getTab("properties")->interval(
       	        -name=>"cacheTimeout",
               	-label=>WebGUI::International::get(895),
                -intervalValue=>$data[0],
       	        -unitsValue=>$data[1],
		-uiLevel=>8
               	);
        @data = WebGUI::DateTime::secondsToInterval($self->get("cacheTimeoutVisitor"));
       	$tabform->getTab("properties")->interval(
               	-name=>"cacheTimeoutVisitor",
                -label=>WebGUI::International::get(896),
       	        -intervalValue=>$data[0],
               	-unitsValue=>$data[1],
		-uiLevel=>8
               	);
	$tabform->add("privileges",WebGUI::International::get(107),6);
	$tabform->getTab("privileges")->dateTime(
                -name=>"startDate",
                -label=>WebGUI::International::get(497),
                -value=>$self->get("startDate"),
                -uiLevel=>6
                );
        $tabform->getTab("privileges")->dateTime(
                -name=>"endDate",
                -label=>WebGUI::International::get(498),
                -value=>$self->get("endDate"),
                -uiLevel=>6
                );
	my $subtext;
        if (WebGUI::Grouping::isInGroup(3)) {
                 $subtext = manageIcon('op=listUsers');
        } else {
                 $subtext = "";
        }
        my $clause;
        if (WebGUI::Grouping::isInGroup(3)) {
                my $contentManagers = WebGUI::Grouping::getUsersInGroup(4,1);
                push (@$contentManagers, $session{user}{userId});
                $clause = "userId in (".quoteAndJoin($contentManagers).")";
        } else {
                $clause = "userId=".quote($self->get("ownerId"));
        }
        my $users = WebGUI::SQL->buildHashRef("select userId,username from users where $clause order by username");
        $tabform->getTab("privileges")->select(
               -name=>"ownerId",
               -options=>$users,
               -label=>WebGUI::International::get(108),
               -value=>[$self->get("ownerId")],
               -subtext=>$subtext,
               -uiLevel=>6
               );
        $tabform->getTab("privileges")->group(
               -name=>"groupIdView",
               -label=>WebGUI::International::get(872),
               -value=>[$self->get("groupIdView")],
               -uiLevel=>6
               );
        $tabform->getTab("privileges")->group(
               -name=>"groupIdEdit",
               -label=>WebGUI::International::get(871),
               -value=>[$self->get("groupIdEdit")],
               -excludeGroups=>[1,7],
               -uiLevel=>6
               );
	return $tabform;
}

sub getId {
	my $self = shift;
	return $self->get("assetId");
}

sub getNextChildRank {
	my $self = shift;
	my ($lineage) = WebGUI::SQL->quickArray("select max(lineage) from asset where parentId=".quote($self->getId));
	my $rank;
	if (defined $lineage) {
		$rank = $self->getRank($lineage);
		$rank++;
	} else {
		$rank = 1;
	}
	return $self->formatRank($rank);
}

sub getLineage {
	my $self = shift;
	my $relatives = shift;
	my $rules = shift;
	my $lineage = $self->get("lineage");
	my $whereSiblings;
	if (isIn("siblings",@{$relatives})) {
		$whereSiblings = "(parentId=".quote($self->get("parentId"))." and assetId<>".quote($self->getId).")";
	}
	my @specificFamilyMembers = ();
	if (isIn("ancestors",@{$relatives})) {
		my @familyTree = ($lineage =~ /(.{6})/g);
                while (pop(@familyTree)) {
                        push(@specificFamilyMembers,join("",@familyTree)) if (scalar(@familyTree));
                }
	}
	if (isIn("self",@{$relatives})) {
		push(@specificFamilyMembers,$self->get("lineage"));
	}
	my $whereExact;
	if (scalar(@specificFamilyMembers) > 0) {
		if ($whereSiblings ne "") {
			$whereExact = " or ";
		}
		$whereExact .= "lineage in (";
		$whereExact .= quoteAndJoin(\@specificFamilyMembers);
		$whereExact .= ")";
	}
	my $whereDescendants;
	if (isIn("descendants",@{$relatives})) {
		if ($whereSiblings ne "" || $whereExact ne "") {
			$whereDescendants = " or ";
		}
		my $lineageLength = length($lineage);
		$whereDescendants .= "lineage like ".quote($lineage.'%')." and length(lineage)> ".$lineageLength; 
	}
	my $select = "*";
	$select = "assetId" if ($rules->{returnIds});
	my $sql = "select $select from asset where $whereSiblings $whereExact $whereDescendants order by lineage";
	my @lineage;
	my $sth = WebGUI::SQL->read($sql);
	while (my $asset = $sth->hashRef) {
		if ($rules->{returnIds}) {
			push(@lineage,$asset->{assetId});
		} else {
			push(@lineage,WebGUI::Asset->new($asset->{assetId},$asset));
		}
	}
	$sth->finish;
	return \@lineage;
}

sub getParent {
	my $self = shift;
	return WebGUI::Asset->new($self->get("parentId"));	
}

sub getParentLineage {
	my $self = shift;
	my $lineage = shift || $self->get("lineage");
	my ($parentLineage) = $lineage =~ m/^(.).{6}$/;
	return $parentLineage;
}

sub getRank {
	my $self = shift;
	my $lineage = shift || $self->get("lineage");
	my ($rank) = $lineage =~ m/(.{6})$/;
	my $rank = $rank - 0; # gets rid of preceeding 0s.
	return $rank;
}

sub getUiLevel {
	my $self = shift;
	return 0;
}

sub new {
	my $class = shift;
	my $assetId = shift;
	my $properties = shift;
	if (defined $properties) {
		return bless { _properties=>$properties }, $class;
	} else {
		$properties = WebGUI::SQL->quickHashRef("select * from asset where assetId=".quote($assetId));
		if (exists $properties->{assetId}) {
			return bless { _properties=>$properties}, $class;
		} else {	
			return undef;
		}
	}	
}

sub paste {
	my $self = shift;
	my $newParentId = shift;
	if ($self->setParent($newParentId)) {
		WebGUI::SQL->write("update asset set state='published' where lineage like ".quote($self->get("lineage").'%'));
		return 1;
	}
	return 0;
}

sub promote {
	my $self = shift;
	my ($sisterLineage) = WebGUI::SQL->quickArray("select max(lineage) from asset 
		where parentId=".quote($self->get("parentId"))." 
		and lineage<".quote($self->get("lineage")));
	if (defined $sisterLineage) {
		$self->swapRank($sisterLineage);
		$self->{_properties}{lineage} = $sisterLineage;
		return 1;
	}
	return 0;
}

sub set {
	my $self = shift;
	my $properties = shift;
	my %props = %{$properties}; # make a copy so we don't disturb the original as we make changes
	my @setPairs;
	foreach my $property (keys %props) {
		if (isIn($property, qw(groupIdEdit groupIdView ownerId startDate endDate url title menuTitle synopsis))) {
			if ($property eq "url") {
				$props{url} = $self->fixUrl($props{url});
			}
			$self->{_properties}{$property} = $props{$property};
			push(@setPairs ,$property."=".quote($props{$property}));
		}
	}
	WebGUI::SQL->write("update asset set ".join(",",@setPairs)." where assetId=".quote($self->getId));
	return 1;
}

sub setParent {
	my $self = shift;
	my $newParentId = shift;
	return 0 if ($newParentId eq $self->get("parentId")); # don't move it to where it already is
	my $parent = WebGUI::Asset->new($newParentId);
	if (defined $parent) {
		my $oldLineage = $self->get("lineage");
		my $lineage = $parent->get("lineage").$parent->getNextChildRank; 
		return 0 if ($lineage =~ m/^$oldLineage/); # can't move it to its own child
		WebGUI::SQL->beginTransaction;
		WebGUI::SQL->write("update asset set parentId=".quote($parent->getId)." where assetId=".quote($self->getId));
		$self->cascadeLineage($lineage);
		WebGUI::SQL->commit;
		$self->{_properties}{lineage} = $lineage;
		return 1;
	}
	return 0;
}

sub setRank {
	my $self = shift;
	my $newRank = shift;
	my $currentRank = $self->getRank;
	return 1 if ($newRank == $currentRank); # do nothing if we're moving to ourself
	my $parentLineage = $self->getParentLineage;
	my $siblings = $self->getLineage(["siblings"]);
	my $temp = substr(WebGUI::Id::generate(),0,6);
	if ($newRank < $currentRank) { # have to do the ordering in reverse when the new rank is above the old rank
		@{$siblings} = reverse @{$siblings};
	}
	my $previous = $self->get("lineage");
	WebGUI::SQL->beginTransaction;
	$self->cascadeLineage($temp);
	foreach my $sibling (@{$siblings}) {
		if (isBetween($sibling->getRank, $newRank, $currentRank)) {
			$sibling->cascadeLineage($previous);
			$previous = $sibling->get("lineage");
		}
	}
	$self->cascadeLineage($previous,$temp);
	$self->{_properties}{lineage} = $previous;
	WebGUI::SQL->commit;
	return 1;
}

sub swapRank {
	my $self = shift;
	my $second = shift;
	my $first = shift || $self->get("lineage");
	my $temp = substr(WebGUI::Id::generate(),0,6); # need a temp in order to do the swap
	WebGUI::SQL->beginTransaction;
	$self->cascadeLineage($temp,$first);
	$self->cascadeLineage($first,$second);
	$self->cascadeLineage($second,$temp);
	WebGUI::SQL->commit;
	return 1;
}


sub www_copy {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
	my $newAsset = $self->duplicate;
	$newAsset->cut;
}

sub www_cut {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
	$self->cut;
}

sub www_delete {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
	$self->delete;
}

sub www_demote {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
	$self->demote;
}

sub www_edit {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
	return "No editor has been defined for this asset.";
}

sub www_paste {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
	$self->paste($session{form}{newParentId});
}

sub www_promote {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
	$self->promote;
}

sub www_view {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
	return "No view has been defined for this asset.";
}

1;
