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
	WebGUI::SQL->beginTransaction;
	WebGUI::SQL->write("insert into asset (assetId, parentId, lineage, state, className, url, startDate, endDate) 
		values (".quote($id).",".quote($self->getId).", ".quote($lineage).", 
		'published', ".quote($properties->{className}).", ".quote($id).",
		997995720, 9223372036854775807)");
	foreach my $definition (@{$self->{definition}}) {
		unless ($definition->{tableName} eq "asset") {
			WebGUI::SQL->write("insert into ".$definition->{tableName}." (assetId) values (".quote($id).")");
		}
	}
	WebGUI::SQL->commit;
	my $className = $properties->{className};
	my $newAsset = $className->new($id);
	$newAsset->set($properties);
	return $newAsset;
}

sub canEdit {
	my $self = shift;
	my $userId = shift || $session{user}{userId};
 	if ($userId eq $self->get("ownerUserId")) {
                return 1;
	}
        return WebGUI::Grouping::isInGroup($self->get("groupIdEdit"),$userId);
}

sub canView {
	my $self = shift;
	my $userId = shift || $session{user}{userId};
	if ($userId eq $self->get("ownerUserId")) {
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

sub definition {
        my $class = shift;
        my $definition = shift;
        push(@{$definition}, {
                tableName=>'asset',
                className=>'WebGUI::Asset',
                properties=>{
                                title=>{
                                        fieldType=>'text',
                                        defaultValue=>$definition->[0]->{className}
                                        },
                                menuTitle=>{
                                        fieldType=>'text',
                                        defaultValue=>undef
                                        },
                                synopsis=>{
                                        fieldType=>'textarea',
                                        defaultValue=>undef
                                        },
                                url=>{
                                        fieldType=>'text',
                                        defaultValue=>undef,
					filter=>'fixUrl',
                                        },
                                groupIdEdit=>{
                                        fieldType=>'group',
                                        defaultValue=>'4'
                                        },
                                groupIdView=>{
                                        fieldType=>'group',
                                        defaultValue=>'7'
                                        },
                                ownerUserId=>{
                                        fieldType=>'selectList',
                                        defaultValue=>'3'
                                        },
                                startDate=>{
                                        fieldType=>'dateTime',
                                        defaultValue=>undef
                                        },
                                endDate=>{
                                        fieldType=>'dateTime',
                                        defaultValue=>undef
                                        },
                        }
                });
        return $definition;
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
                $url = $self->fixUrl($url);
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




#-------------------------------------------------------------------

=head2 getAdminConsole ()

Returns a reference to a WebGUI::AdminConsole object.

=cut

sub getAdminConsole {
	my $self = shift;
	unless (exists $self->{_adminConsole}) {
		$self->{_adminConsole} = WebGUI::AdminConsole->new("assets");
	}
	return $self->{_adminConsole};
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
                $clause = "userId=".quote($self->get("ownerUserId"));
        }
        my $users = WebGUI::SQL->buildHashRef("select userId,username from users where $clause order by username");
        $tabform->getTab("privileges")->select(
               -name=>"ownerUserId",
               -options=>$users,
               -label=>WebGUI::International::get(108),
               -value=>[$self->get("ownerUserId")],
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

#-------------------------------------------------------------------
                                                                                                                                                       
=head2 getIndexerParams ( )
                                                                                                                                                       
Override this method and return a hash reference that includes the properties necessary to index the content of the wobject.
                                                                                                                                                       
=cut
                                                                                                                                                       
sub getIndexerParams {
        return {};
}


sub getName {
	return WebGUI::International::get('asset','Asset');
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
	my $sql = "select assetId from asset where $whereSiblings $whereExact $whereDescendants order by lineage";
	my @lineage;
	my $sth = WebGUI::SQL->read($sql);
	while (my ($assetId) = $sth->array) {
		if ($rules->{returnOjbects}) {
			push(@lineage,WebGUI::Asset->new($assetId);
		} else {
			push(@lineage,$assetId);
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

sub getValue {
	my $self = shift;
	my $key = shift;
	if (defined $key) {
		unless (exists $self->{_propertyDefinitions}) { # check to see if the defintions have been merged and cached
			my %properties;
			foreach my $definition (@{$self->definition}) {
				%properties = (%properties, %{$definition->{properties}});
			}
			$self->{_propertyDefinitions} = \%properties;
		}
		return $session{form}{$key} || $self->get($key) || $self->{_propertiyDefinitions}{$key}{defaultValue};
	}
	return undef;
}

sub new {
	my $class = shift;
	my $assetId = shift;
	my $overrideProperties = shift;
	my $properties;
	if ($assetId eq "new") {
		$properties = $overrideProperties;
		$properties->{assetId} = "new";
		$properties->{className} = $class;
	} else {
		my $definitions = $class->definition;
		my @definitionsReversed = reverse(@{$definitions});
		shift(@definitionsReversed);
		my $sql = "select * from asset";
		foreach my $definition (@definitionsReversed) {
			$sql .= " left join ".$definition->{tableName}." on asset.assetId=".$definition->{tableName}.".assetId";
		}
		$sql .= " where asset.assetId=".quote($assetId);
		$properties = WebGUI::SQL->quickHashRef($sql);
		return undef unless (exists $properties->{assetId});
                foreach my $property (keys %{$overrideProperties}) {
                        unless (isIn($property, qw(assetId className parentId lineage state))) {
                                $properties->{$property} = $overrideProperties->{$property};
                        }
                }
	}
	if (defined $properties) {
		return bless { _properties=>$properties }, $class;
	}	
	return undef;
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

sub purge {
	my $self = shift;
	# NOTE to self, still need to delete all children too
	WebGUI::SQL->beginTransaction;
	foreach my $definition (@{$self->definition}) {
		WebGUI::SQL->write("delete from ".$definition->{tableName}." where assetId=".quote($self->getId));
	}
	WebGUI::SQL->commit;
	$self = undef;
}

sub set {
	my $self = shift;
	my $properties = shift;
	WebGUI::SQL->beginTransaction;
	foreach my $definition (@{$self->definition}) {
		my @setPairs;
		foreach my $property (keys %{$definition->{properties}}) {
			my $value = $properties->{$property} || $definition->{properties}{$property}{defaultValue};
			if (defined $value) {
				if (exists $definition->{properties}{$property}{filter}) {
					$value = $self->$definition->{properties}{$property}{filter}($value);
				}
				$self->{_properties}{$property} = $value;
				push(@setPairs, $property."=".quote($value));
			}
		}
		if (scalar(@setPairs) > 0) {
			WebGUI::SQL->write("update ".$definition->{tableName}." set ".join(",",@setPairs)." where assetId=".quote($self->getId));
		}
	}
	WebGUI::SQL->commit;
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
	my $siblings = $self->getLineage(["siblings"],{returnObjects=>1});
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
	return "";
}

sub www_cut {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
	$self->cut;
	return "";
}

sub www_delete {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
	$self->delete;
	return "";
}

sub www_demote {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
	$self->demote;
	return "";
}

sub www_edit {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
	return $self->getAdminConsole->render($self->getEditForm);
}

sub www_editSave {
	my $self = shift;
	my %data;
	foreach my $definition (@{$self->definition}) {
		foreach my $property (keys %{$definition->{properties}}) {
			my $data{$property} = WebGUI::FormProcessor::process(
				$property,
				$definition->{properties}{fieldType},
				$definition->{properties}{defaultValue}
				);
		}
	}
	$self->set(\%data);
	return "";
}

sub www_paste {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
	$self->paste($session{form}{newParentId});
	return "";
}

sub www_promote {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
	$self->promote;
	return "";
}

sub www_view {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
	return "No view has been defined for this asset.";
}

1;
