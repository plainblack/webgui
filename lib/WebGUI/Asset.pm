package WebGUI::Asset;

#needs documentation

use strict;
use Tie::IxHash;
use WebGUI::AdminConsole;
use WebGUI::Clipboard;
use WebGUI::DateTime;
use WebGUI::ErrorHandler;
use WebGUI::Form;
use WebGUI::FormProcessor;
use WebGUI::Grouping;
use WebGUI::HTTP;
use WebGUI::Icon;
use WebGUI::Id;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::TabForm;
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
	my $tempAsset = WebGUI::Asset->newByDynamicClass("new",$properties->{className});
	foreach my $definition (@{$tempAsset->definition}) {
		unless ($definition->{tableName} eq "asset") {
			WebGUI::SQL->write("insert into ".$definition->{tableName}." (assetId) values (".quote($id).")");
		}
	}
	WebGUI::SQL->commit;
	my $newAsset = WebGUI::Asset->newByDynamicClass($id, $properties->{className});
	$newAsset->update($properties);
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
	return 0 unless ($self->get("state") eq "published");
	if ($userId eq $self->get("ownerUserId")) {
                return 1;
        } elsif ( $self->get("startDate") < time() && 
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
        my $definition = shift || [];
	my @newDef = @{$definition};
        push(@newDef, {
                tableName=>'asset',
                className=>'WebGUI::Asset',
                properties=>{
                                title=>{
                                        fieldType=>'text',
                                        defaultValue=>$class->getName
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
				assetSize=>{
					fieldType=>'hidden',
					defaultValue=>0
					}
                        }
                });
        return \@newDef;
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
	$self->{_adminConsole}->setIcon($self->getIcon);
	return $self->{_adminConsole};
}

sub getAssetAdderLinks {
	my $self = shift;
	my $addToUrl = shift;
	my @links;
	foreach my $class (@{$session{config}{assets}}) {
		my $load = "use ".$class;
		eval ($load);
		if ($@) {
			WebGUI::ErrorHandler::warn("Couldn't compile ".$class." because ".$@);
		} else {
			my $label = eval{$class->getName()};
			if ($@) {
				WebGUI::ErrorHandler::warn("Couldn't get the name of ".$class." because ".$@);
			} else {
				my $url = $self->getUrl("func=add&class=".$class);
				$url .= "&".$addToUrl if ($addToUrl);
				push(@links, {
					label=>$label,
					url=>$url
					});
			}
		}
	}
	return \@links;
}

sub getEditForm {
	my $self = shift;
	my $tabform = WebGUI::TabForm->new();
	$tabform->hidden({
		name=>"func",
		value=>"editSave"
		});
	if ($self->getId eq "new") {
		$tabform->hidden({
			name=>"assetId",
			value=>"new"
			});
		$tabform->hidden({
			name=>"class",
			value=>$session{form}{class}
			});
	}
	if ($session{form}{afterEdit}) {
		$tabform->hidden({
			name=>"afterEdit",
			value=>$session{form}{afterEdit}
			});
	}
	$tabform->addTab("properties",WebGUI::International::get("properties","Asset"));
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
	$tabform->addTab("privileges",WebGUI::International::get(107),6);
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
        $tabform->getTab("privileges")->selectList(
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


sub getIcon {
	my $self = shift;
	my $small = shift;
	return $session{config}{extrasURL}.'/adminConsole/small/assets.gif' if ($small);
	return $session{config}{extrasURL}.'/adminConsole/assets.gif';
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


sub getLineage {
	my $self = shift;
	my $relatives = shift;
	my $rules = shift;
	my $lineage = $self->get("lineage");
	my $whereExclusion = " and state='published'";
	if (exists $rules->{excludeClasses}) {
		my @set;
		foreach my $className (@{$rules->{excludeClasses}}) {
			push(@set,"className <> ".quote($className));
		}
		$whereExclusion .= 'and ('.join(" and ",@set).')';
	}
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
		$whereDescendants .= "lineage like ".quote($lineage.'%')." and lineage<>".quote($lineage); 
		if (exists $rules->{endingLineageLength}) {
			$whereDescendants .= " and length(lineage) <= ".($rules->{endingLineageLength}*6);
		}
	}
	my $sql = "select assetId,className from asset where $whereSiblings $whereExact $whereDescendants $whereExclusion order by lineage";
	my @lineage;
	my $sth = WebGUI::SQL->read($sql);
	while (my ($assetId,$className) = $sth->array) {
		if ($rules->{returnObjects}) {
			push(@lineage,WebGUI::Asset->newByDynamicClass($assetId, $className));
		} else {
			push(@lineage,$assetId);
		}
	}
	$sth->finish;
	return \@lineage;
}

sub getLineageLength {
	my $self = shift;
	return length($self->get("lineage"))/6;
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

sub getParent {
	my $self = shift;
	$self->{_parent} = WebGUI::Asset->newByDynamicClass($self->get("parentId")) unless (exists $self->{_parent});
	return $self->{_parent};
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

sub getUrl {
	my $self = shift;
	my $params = shift;
	return WebGUI::URL::gateway($self->get("url"),$params);
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

sub hasChildren {
	my $self = shift;
	my ($hasChildren) = WebGUI::SQL->read("select count(*) from asset where parentId=".quote($self->getId));
	return $hasChildren;
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
	}
	if (defined $overrideProperties) {
		foreach my $definition (@{$class->definition}) {
			foreach my $property (keys %{$definition->{properties}}) {
				if (exists $overrideProperties->{$property}) {
					$properties->{$property} = $overrideProperties->{$property};
				}
			}
		}
	}	
	if (defined $properties) {
		my $object = { _properties => $properties };
		bless $object, $class;
		return $object;
	}	
	return undef;
}


sub newByDynamicClass {
	my $class = shift;
	my $assetId = shift;
	my $className = shift;
	my $overrideProperties = shift;
	unless (defined $className) {
        	($className) = WebGUI::SQL->quickArray("select className from asset where assetId=".quote($assetId));
	}
        if ($className eq "") {
        	WebGUI::HTTP::setStatus('404',"Page Not Found");
		WebGUI::ErrorHandler::fatalError("The page not found page doesn't exist.") if ($assetId eq $session{setting}{notFoundPage});
                return WebGUI::Asset->newByDynamicClass($session{setting}{notFoundPage});
        }
	my $cmd = "use ".$className;
        eval ($cmd);
        WebGUI::ErrorHandler::fatalError("Couldn't compile asset package: ".$className.". Root cause: ".$@) if ($@);
        my $assetObject = eval{$className->new($assetId,$overrideProperties)};
        WebGUI::ErrorHandler::fatalError("Couldn't create asset instance for ".$assetId.". Root cause: ".$@) if ($@);
	return $assetObject;
}


sub newByUrl {
	my $class = shift;
        my $url = shift || $session{env}{PATH_INFO};
        $url = lc($url);
        $url =~ s/\/$//;
        $url =~ s/^\///;
        $url =~ s/\'//;
        $url =~ s/\"//;
        my $asset;
        if ($url ne "") {
                $asset = WebGUI::SQL->quickHashRef("select assetId, className from asset where url=".quote($url));
		return WebGUI::Asset->newByDynamicClass($asset->{assetId}, $asset->{className});
        }
        return $class->newByDynamicClass($session{setting}{defaultPage});
}


sub republish {
	my $self = shift;
	WebGUI::SQL->write("update asset set state='published' where lineage like ".quote($self->get("lineage").'%'));
	$self->{_properties}{state} = "published";
}

sub paste {
	my $self = shift;
	my $assetId = shift;
	my $pastedAsset = WebGUI::Asset->new($assetId);	
	if ($self->getId eq $pastedAsset->get("parentId") || $pastedAsset->setParent($self->getId)) {
		$pastedAsset->republish;
		return 1;
	}
	return 0;
}

sub processPropertiesFromFormPost {
	my $self = shift;
	my %data;
	foreach my $definition (@{$self->definition}) {
		foreach my $property (keys %{$definition->{properties}}) {
			$data{$property} = WebGUI::FormProcessor::process(
				$property,
				$definition->{properties}{fieldType},
				$definition->{properties}{defaultValue}
				);
		}
	}
	$data{title} = "Untitled" unless ($data{title});
	$data{menuTitle} = $data{title} unless ($data{menuTitle});
	$data{url} = $self->getParent->get("url").'/'.$data{menuTitle} unless ($data{url});
	$self->update(\%data);
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
	return 1;
}

sub setParent {
	my $self = shift;
	my $newParentId = shift;
	return 0 if ($newParentId eq $self->get("parentId")); # don't move it to where it already is
	return 0 if ($newParentId eq $self->getId); # don't move it to itself
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

sub setSize {
	my $self = shift;
	my $extra = shift;
	my $sizetest;
	foreach my $key (keys %{$self->get}) {
		$sizetest .= $self->get($key);
	}
	WebGUI::SQL->write("update asset set assetSize=".(length($sizetest)+$extra)." where assetId=".quote($self->getId));
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


sub trash {
	my $self = shift;
	WebGUI::SQL->beginTransaction;
	WebGUI::SQL->write("update asset set state='limbo' where lineage like ".quote($self->get("lineage").'%'));
	WebGUI::SQL->write("update asset set state='trash' where assetId=".quote($self->getId));
	WebGUI::SQL->commit;
	$self->{_properties}{state} = "trash";
}

sub update {
	my $self = shift;
	my $properties = shift;
	WebGUI::SQL->beginTransaction;
	foreach my $definition (@{$self->definition}) {
		my @setPairs;
		if ($definition->{tableName} eq "asset") {
			push(@setPairs,"lastUpdated=".time());
		}
		foreach my $property (keys %{$definition->{properties}}) {
			my $value = $properties->{$property} || $definition->{properties}{$property}{defaultValue};
			if (defined $value) {
				if (exists $definition->{properties}{$property}{filter}) {
					my $filter = $definition->{properties}{$property}{filter};
					$value = $self->$filter($value);
				}
				$self->{_properties}{$property} = $value;
				push(@setPairs, $property."=".quote($value));
			}
		}
		if (scalar(@setPairs) > 0) {
			WebGUI::SQL->write("update ".$definition->{tableName}." set ".join(",",@setPairs)." where assetId=".quote($self->getId));
		}
	}
	$self->setSize;
	WebGUI::SQL->commit;
	return 1;
}

sub www_add {
	my $self = shift;
	my %properties = %{$self->get};
	delete $properties{title};
	delete $properties{menuTitle};
	delete $properties{url};
	delete $properties{description};
	my $newAsset = WebGUI::Asset->newByDynamicClass("new",$session{form}{class},\%properties);
	return $newAsset->www_edit();
}

sub www_copy {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
	my $newAsset = $self->duplicate;
	$newAsset->cut;
	return "";
}

sub www_copyList {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
	my $newAsset = $self->duplicate;
	$newAsset->cut;
	foreach my $assetId ($session{cgi}->param("assetId")) {
		my $asset = WebGUI::Asset->newByDynamicClass($assetId);
		if ($asset->canEdit) {
			my $newAsset = $asset->duplicate;
			$newAsset->cut;
		}
	}
	return $self->www_manageAssets();
}

sub www_cut {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
	$self->cut;
	return $self->getParent->www_view;
}

sub www_cutList {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
	foreach my $assetId ($session{cgi}->param("assetId")) {
		my $asset = WebGUI::Asset->newByDynamicClass($assetId);
		if ($asset->canEdit) {
			$asset->cut;
		}
	}
	return $self->www_manageAssets();
}

sub www_delete {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
	$self->trash;
	return $self->getParent->www_view;
}

sub www_deleteList {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
	foreach my $assetId ($session{cgi}->param("assetId")) {
		my $asset = WebGUI::Asset->newByDynamicClass($assetId);
		if ($asset->canEdit) {
			$asset->trash;
		}
	}
	return $self->www_manageAssets();
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
	return $self->getAdminConsole->render($self->getEditForm->print);
}

sub www_editSave {
	my $self = shift;
	my $object;
	if ($session{form}{assetId} eq "new") {
		$object = $self->addChild({className=>$session{form}{class}});	
		$object->{_parent} = $self;
	} else {
		$object = $self;
	}
	$object->processPropertiesFromFormPost;
	return $self->www_manageAssets if ($session{form}{afterEdit} eq "assetManager" && $session{form}{assetId} eq "new");
	return $object->getParent->www_manageAssets if ($session{form}{afterEdit} eq "assetManager");
	return $object->www_view;
}

sub www_editTree {
	return "not yet implemented";
}

sub www_editTreeSave {
	return "not yet implemented";
}

sub www_manageAssets {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
	WebGUI::Style::setLink($session{config}{extrasURL}.'/assetManager/assetManager.css', {rel=>"stylesheet",type=>"text/css"});
	WebGUI::Style::setScript($session{config}{extrasURL}.'/assetManager/Tools.js', {type=>"text/javascript"});
	WebGUI::Style::setScript($session{config}{extrasURL}.'/assetManager/ContextMenu.js', {type=>"text/javascript"});
	WebGUI::Style::setScript($session{config}{extrasURL}.'/assetManager/Asset.js', {type=>"text/javascript"});
	WebGUI::Style::setScript($session{config}{extrasURL}.'/assetManager/Display.js', {type=>"text/javascript"});
	WebGUI::Style::setScript($session{config}{extrasURL}.'/assetManager/EventManager.js', {type=>"text/javascript"});
	WebGUI::Style::setScript($session{config}{extrasURL}.'/assetManager/AssetManager.js', {type=>"text/javascript"});
	my $children = $self->getLineage(["descendants"],{returnObjects=>1, endingLineageLength=>$self->getLineageLength+1});
	my $output;
	$output = '
		<div id="contextMenu" class="contextMenu"></div>
   		<div id="propertiesWindow" class="propertiesWindow"></div>
   		<div id="crumbtrail"></div>
   		<div id="workspace" style="height: 200px;">Retrieving Assets...</div>
   		<div id="dragImage" class="dragIdentifier">hello</div>
		';
	$output .= "<script>\n";
	$output .= "/* assetId, url, title */\nvar crumbtrail = [\n";
	my $ancestors = $self->getLineage(["self","ancestors"],{returnObjects=>1});
	my @dataArray;
	foreach my $ancestor (@{$ancestors}) {
		my $title = $ancestor->get("title");
		$title =~ s/\'/\\\'/g;
		push(@dataArray,"['".$ancestor->getId."','".$ancestor->getUrl."','".$title."']\n");
	}
	$output .= join(",",@dataArray);
	$output .= "];\n";
	$output .= "var columnHeadings = ['Rank','Title','Type','Last Updated','Size'];\n";
	$output .= "/*rank, title, type, lastUpdate, size, url, assetId, icon */\nvar assets = [\n";
	@dataArray = ();
	foreach my $child (@{$children}) {
		my $title = $child->get("title");
		$title =~ s/\'/\\\'/g;
		push(@dataArray, '['.$child->getRank.",'".$title."','".$child->getName."','".WebGUI::DateTime::epochToHuman($child->get("lastUpdated"))."','".formatBytes($child->get("assetSize"))."','".$child->getUrl."','".$child->getId."','".$child->getIcon(1)."']\n");
#my $hasChildren = "false";
		#$hasChildren = "true" if ($child->hasChildren);
		#$output .= $hasChildren;
	}
	$output .= join(",",@dataArray);
	$output .= "];\n var labels = new Array();\n";
	$output .= "labels['edit'] = 'Edit';\n";
	$output .= "labels['cut'] = 'Cut';\n";
	$output .= "labels['copy'] = 'Copy';\n";
	$output .= "labels['move'] = 'Move';\n";
	$output .= "labels['view'] = 'View';\n";
	$output .= "labels['delete'] = 'Delete';\n";
	$output .= "labels['go'] = 'Go';\n";
	$output .= "labels['properties'] = 'Properties';\n";
	$output .= "labels['editTree'] = 'Edit Tree';\n";
	$output .= "var manager = new AssetManager(assets,columnHeadings,labels,crumbtrail);  manager.renderAssets();\n</script>\n";
	$output .= ' <div class="adminConsoleSpacer">
            &nbsp;
        </div>
		<div style="float: left; padding-right: 30px; font-size: 14px;"><b>'.WebGUI::International::get(1083).'</b><br />';
	foreach my $link (@{$self->getAssetAdderLinks("afterEdit=assetManager")}) {
		$output .= '<a href="'.$link->{url}.'">'.$link->{label}.'</a><br />';
	}
	$output .= '</div>'; 
	my $clipboard = WebGUI::Clipboard::getAssetsInClipboard();
	my %options;
	tie %options, 'Tie::IxHash';
	my $hasClips = 0;
        foreach my $item (@{$clipboard}) {
              	$options{$item->{assetId}} = $item->{title};
		$hasClips = 1;
        }
	if ($hasClips) {
		$output .= '<div style="float: left; padding-right: 30px; font-size: 14px;"><b>'.WebGUI::International::get(1082).'</b><br />'
			.WebGUI::Form::formHeader()
			.WebGUI::Form::hidden({name=>"func",value=>"pasteList"})
			.WebGUI::Form::checkList({name=>"assetId",options=>\%options})
			.'<br />'
			.WebGUI::Form::submit({value=>"Paste"})
			.WebGUI::Form::formFooter()
			.' </div> ';
	}
	$output .= '
    <div class="adminConsoleSpacer">
            &nbsp;
        </div> 
		';
	return $self->getAdminConsole->render($output);
}


sub www_paste {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
	$self->paste($session{form}{assetId});
	return "";
}

sub www_pasteList {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
	foreach my $clipId ($session{cgi}->param("assetId")) {
		$self->paste($clipId);
	}
	return $self->www_manageAssets();
}

sub www_promote {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
	$self->promote;
	return "";
}

sub www_setParent {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
	my $newParent = $session{form}{assetId};
	$self->setParent($newParent) if (defined $newParent);
	return $self->www_manageAssets();

}

sub www_setRank {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
	my $newRank = $session{form}{rank};
	$self->setRank($newRank) if (defined $newRank);
	return $self->www_manageAssets();
}

sub www_view {
	my $self = shift;
	return WebGUI::Privilege::noAccess() unless $self->canView;
	return "No view has been implemented for this asset.";
}


1;

