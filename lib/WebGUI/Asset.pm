package WebGUI::Asset;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2004 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use Tie::IxHash;
use WebGUI::AdminConsole;
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

=head1 NAME

Package WebGUI::Asset

=head1 DESCRIPTION

Package to manipulate items in WebGUI's asset system. Replaces Collateral.

=head1 SYNOPSIS

An asset is the basic class of content in WebGUI. This handles security, urls, and other basic information common to all content items.

A lineage is a concatenated series of sequence numbers, each six digits long, that explain an asset's position in its familiy tree. Lineage describes who the asset's anscestors are, how many ancestors the asset has in its family tree (lineage length), and the asset's position (rank) amongst its siblings. In addition, lineage provides enough information about an asset to generate a list of its siblings and descendants.
 
 use WebGUI::Asset;

 addChild
 canEdit
 canView
 cascadeLineage
 cut
 definition
 demote
 DESTROY
 duplicate
 fixUrl
 formatRank
 get
 getAdminConsole
 getAssetAdderLinks
 getAssetManagerControl
 getEditForm
 getFirstChild
 getIcon
 getId
 getIndexerParams
 getLastChild
 getLineage
 getLineageLength
 getName
 getNextChildRank
 getParent
 getParentLineage
 getRank
 getToolbar
 getUiLevel
 getUrl
 getValue
 hasChildren
 new
 newByDynamicClass
 newByLineage
 newByPropertyHashRef
 newByUrl
 republish
 paste
 processPropertiesFromFormPost
 promote
 purge
 purgeTree
 setParent
 setRank
 setSize
 swapRank
 trash
 update
 updateHistory
 view
 www_add
 www_copy
 www_copyList
 www_cut
 www_cutList
 www_delete
 www_deleteList
 www_demote
 www_edit
 www_editSave
 www_editTree (NYI)
 www_editTreeSave (NYI)
 www_emptyClipboard
 www_emptyTrash
 www_manageAssets
 www_manageClipboard
 www_manageTrash
 www_paste
 www_pasteList
 www_promote
 www_setParent
 www_setRank
 www_view
 

=head1 METHODS

These methods are available from this class:

=cut
#-------------------------------------------------------------------

=head2 addChild ( properties )

Adds a child asset to a parent. Creates a new AssetID for child. Makes the parent know that it has children. Adds a new asset to the asset table. Returns the newly created Asset.

=head3 properties

A hash reference containing a list of properties to associate with the child. The only used property value is "className"

=cut

sub addChild {
	my $self = shift;
	my $properties = shift;
	my $id = WebGUI::Id::generate();
	my $lineage = $self->get("lineage").$self->getNextChildRank;
	$self->{_hasChildren} = 1;
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
	$self->updateHistory("added child ".$id);
	$newAsset->updateHistory("created");
	$newAsset->update($properties);
	return $newAsset;
}

#-------------------------------------------------------------------

=head2 canEdit ( [userId] )

Verifies group and user permissions to be able to edit asset. Returns 1 if owner is userId, otherwise returns the result checking if the user is a member of the group that can edit.

=head3 userId

Unique hash identifier for a user. If not supplied, current user. 

=cut

sub canEdit {
	my $self = shift;
	my $userId = shift || $session{user}{userId};
 	if ($userId eq $self->get("ownerUserId")) {
                return 1;
	}
        return WebGUI::Grouping::isInGroup($self->get("groupIdEdit"),$userId);
}
#-------------------------------------------------------------------

=head2 canView ( [userId] )

Verifies group and user permissions to be able to view asset. Returns 1 if user is owner of asset. Returns 1 if within the visibility date range of the asset AND user in the View group of asset. Otherwise, returns the result of the canEdit.

Only the owner and the editors can always see the asset, regardless of time/date restrictions on the asset.

=head3 userId

Unique hash identifier for a user. If not specified, uses current userId.

=cut


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
	WebGUI::SQL->write("update asset set lineage=concat(".quote($newLineage).", substring(lineage from ".(length($oldLineage)+1).")) 
		where lineage like ".quote($oldLineage.'%'));
}

#-------------------------------------------------------------------

=head2 cut ( )

Removes asset from lineage, places it in clipboard state. The "gap" in the lineage is changed in state to limbo.

=cut

sub cut {
	my $self = shift;
	WebGUI::SQL->beginTransaction;
	WebGUI::SQL->write("update asset set state='limbo' where lineage like ".quote($self->get("lineage").'%'));
	WebGUI::SQL->write("update asset set state='clipboard' where assetId=".quote($self->getId));
	WebGUI::SQL->commit;
	$self->updateHistory("cut");
	$self->{_properties}{state} = "clipboard";
}
 
#-------------------------------------------------------------------

=head2 definition ( [ definition ] )

Basic definition of an Asset. Properties, default values. Returns the definition containing tableName,className,properties

=head3 definition

Additional information to include with the default definition.

=cut

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

#-------------------------------------------------------------------

=head2 demote ( )

Keeps the same rank of lineage, swaps with sister below.

=cut

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

#-------------------------------------------------------------------

=head2 DESTROY ( )

Completely remove an asset from existence.

=cut

sub DESTROY {
	my $self = shift;
	$self->{_parent}->DESTROY if (exists $self->{_parent});
	$self->{_firstChild}->DESTROY if (exists $self->{_firstChild});
	$self->{_lastChild}->DESTROY if (exists $self->{_lastChild});
	$self = undef;
}
#-------------------------------------------------------------------

=head2 duplicate ( )

Duplicates an argument. Calls addChild with itself as an argument. Returns a new Asset object.

=cut

sub duplicate {
	my $self = shift;
	my $newAsset = $self->addChild($self->get);
	return $newAsset;
}

#-------------------------------------------------------------------

=head2 fixUrl ( string )

Makes string into a URL, removing invalid characters. 

=head3 string

Any text string. Most likely will have been the Asset's name or title.

=cut

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

=head2 get ( [propertyName] )

Returns a reference to a list of properties (or specified property) of an Asset.

=head3 propertyName

Any of the values associated with the properties of an Asset. Default choices are "title", "menutTitle", "synopsis", "url", "groupIdEdit", "groupIdView", "ownerUserId", "startDate", "endDate",  and "assetSize".

=cut

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

#-------------------------------------------------------------------

=head2 getAssetAdderLinks ( [addToUrl] )

Returns an array that contains a label (name of the class of Asset) and url (url link to function to add the class).

=head3 addToUrl

Any text to append to the getAssetAdderLinks URL. Usually another variable to pass in the url. If addToURL is specified, the character & and the text in addToUrl is appended to the returned url.

=cut

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
			my $uiLevel = eval{$class->getUiLevel()};
			if ($@) {
				WebGUI::ErrorHandler::warn("Couldn't get UI level of ".$class." because ".$@);
			} else {
				next if ($uiLevel > $session{user}{uiLevel});
			}
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

#-------------------------------------------------------------------

=head2 getAssetManagerControl ( children )

Returns HTML code for the Asset Manager Control Page. English only.

=cut

sub getAssetManagerControl {
	my $self = shift;
	my $children = shift;
	WebGUI::Style::setLink($session{config}{extrasURL}.'/assetManager/assetManager.css', {rel=>"stylesheet",type=>"text/css"});
	WebGUI::Style::setScript($session{config}{extrasURL}.'/assetManager/Tools.js', {type=>"text/javascript"});
	WebGUI::Style::setScript($session{config}{extrasURL}.'/assetManager/ContextMenu.js', {type=>"text/javascript"});
	WebGUI::Style::setScript($session{config}{extrasURL}.'/assetManager/Asset.js', {type=>"text/javascript"});
	WebGUI::Style::setScript($session{config}{extrasURL}.'/assetManager/Display.js', {type=>"text/javascript"});
	WebGUI::Style::setScript($session{config}{extrasURL}.'/assetManager/EventManager.js', {type=>"text/javascript"});
	WebGUI::Style::setScript($session{config}{extrasURL}.'/assetManager/AssetManager.js', {type=>"text/javascript"});
	my $output = '
		<div id="contextMenu" class="contextMenu"></div>
   		<div id="propertiesWindow" class="propertiesWindow"></div>
   		<div id="crumbtrail"></div>
   		<div id="workspace">Retrieving Assets...</div>
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
	return $output;
}


sub getAssetsInClipboard {
	my $self = shift;
	my $limitToUser = shift;
	my $userId = shift || $session{user}{userId};
	my @assets;
	my $limit;
	unless ($limitToUser) {
		$limit = "and lastUpdatedBy=".quote($userId);
	}
	my $sth = WebGUI::SQL->read("select assetId, title, className from asset where state='clipboard' $limit order by lastUpdated desc");
	while (my ($id, $title, $class) = $sth->array) {
		push(@assets, {
			title => $title,
			assetId => $id,
			className => $class
			});
	}
	$sth->finish;
	return \@assets;
}


sub getAssetsInTrash {
	my $self = shift;
	my $limitToUser = shift;
	my $userId = shift || $session{user}{userId};
	my @assets;
	my $limit;
	unless ($limitToUser) {
		$limit = "and lastUpdatedBy=".quote($userId);
	}
	my $sth = WebGUI::SQL->read("select assetId, title, className from asset where state='trash' $limit order by lastUpdated desc");
	while (my ($id, $title, $class) = $sth->array) {
		push(@assets, {
			title => $title,
			assetId => $id,
			className => $class
			});
	}
	$sth->finish;
	return \@assets;
}



#-------------------------------------------------------------------

=head2 getEditForm ( )

Creates a TabForm to edit parameters of an Asset.

=cut

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
        $tabform->getTab("properties")->textarea(
                -name=>"synopsis",
                -label=>WebGUI::International::get(412),
                -value=>$self->get("synopsis"),
                -uiLevel=>3
                );
	$tabform->addTab("display",WebGUI::International::get(105),5);
	$tabform->getTab("display")->yesNo(
                -name=>"isHidden",
                -value=>$self->get("isHidden"),
                -label=>WebGUI::International::get(886),
                -uiLevel=>6
                );
        $tabform->getTab("display")->yesNo(
                -name=>"newWindow",
                -value=>$self->get("newWindow"),
                -label=>WebGUI::International::get(940),
                -uiLevel=>6
                );
	$tabform->addTab("security",WebGUI::International::get(107),6);
        $tabform->getTab("security")->yesNo(
                -name=>"encryptPage",
                -value=>$self->get("encryptPage"),
                -label=>WebGUI::International::get('encrypt page'),
                -uiLevel=>6
                );
	$tabform->getTab("security")->dateTime(
                -name=>"startDate",
                -label=>WebGUI::International::get(497),
                -value=>$self->get("startDate"),
                -uiLevel=>6
                );
        $tabform->getTab("security")->dateTime(
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
        $tabform->getTab("security")->selectList(
               -name=>"ownerUserId",
               -options=>$users,
               -label=>WebGUI::International::get(108),
               -value=>[$self->get("ownerUserId")],
               -subtext=>$subtext,
               -uiLevel=>6
               );
        $tabform->getTab("security")->group(
               -name=>"groupIdView",
               -label=>WebGUI::International::get(872),
               -value=>[$self->get("groupIdView")],
               -uiLevel=>6
               );
        $tabform->getTab("security")->group(
               -name=>"groupIdEdit",
               -label=>WebGUI::International::get(871),
               -value=>[$self->get("groupIdEdit")],
               -excludeGroups=>[1,7],
               -uiLevel=>6
               );
	return $tabform;
}

#-------------------------------------------------------------------

=head2 getFirstChild ( )

Returns the highest rank, top of the highest rank Asset under current Asset.

=cut

sub getFirstChild {
	my $self = shift;
	unless (exists $self->{_firstChild}) {
		my ($lineage) = WebGUI::SQL->quickArray("select min(lineage) from asset where parentId=".quote($self->getId));
		$self->{_firstChild} = WebGUI::Asset->newByLineage($lineage);
	}
	return $self->{_firstChild};
}

#-------------------------------------------------------------------

=head2 getIcon ( [small] )

Returns the icon located under extras/adminConsole/assets.gif

=head3 small

If this evaluates to True, then the smaller extras/adminConsole/small/assets.gif is returned.

=cut

sub getIcon {
	my $self = shift;
	my $small = shift;
	return $session{config}{extrasURL}.'/adminConsole/small/assets.gif' if ($small);
	return $session{config}{extrasURL}.'/adminConsole/assets.gif';
}

#-------------------------------------------------------------------

=head2 getId ( )

Returns the assetId of an Asset.

=cut


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

#-------------------------------------------------------------------

=head2 getLastChild ( )

Returns the lowest rank, bottom of the lowest rank Asset under current Asset.

=cut

sub getLastChild {
	my $self = shift;
	unless (exists $self->{_lastChild}) {
		my ($lineage) = WebGUI::SQL->quickArray("select max(lineage) from asset where parentId=".quote($self->getId));
		$self->{_lastChild} = WebGUI::Asset->newByLineage($lineage);
	}
	return $self->{_lastChild};
}

#-------------------------------------------------------------------

=head2 getLineage ( relatives,rules )

Returns an array of lineages of relatives based upon rules.

=head3 relatives

Square bracketed, comma separated list, quoted entries; eg ["siblings"] or ["self","ancestors"].Valid parameters are "siblings", "ancestors", "self", "descendants", "pedigree"

=head3 rules

A hash comprising limits to relative listing. Variables to rules include endingLineageLength, assetToPedigree, excludeClasses, returnQuickReadObjects, returnObjects.

=cut

sub getLineage {
	my $self = shift;
	my $relatives = shift;
	my $rules = shift;
	my $lineage = $self->get("lineage");
	my @whereModifiers;
	# let's get those siblings
	if (isIn("siblings",@{$relatives})) {
		push(@whereModifiers, " (parentId=".quote($self->get("parentId"))." and assetId<>".quote($self->getId).")");
	}
	# ancestors too
	my @specificFamilyMembers = ();
	if (isIn("ancestors",@{$relatives})) {
		my @familyTree = ($lineage =~ /(.{6})/g);
                while (pop(@familyTree)) {
                        push(@specificFamilyMembers,join("",@familyTree)) if (scalar(@familyTree));
                }
	}
	# let's add ourself to the list
	if (isIn("self",@{$relatives})) {
		push(@specificFamilyMembers,$self->get("lineage"));
	}
	if (scalar(@specificFamilyMembers) > 0) {
		push(@whereModifiers,"(lineage in (".quoteAndJoin(\@specificFamilyMembers)."))");
	}
	# we need to include descendants
	if (isIn("descendants",@{$relatives})) {
		my $mod = "(lineage like ".quote($lineage.'%')." and lineage<>".quote($lineage); 
		if (exists $rules->{endingLineageLength}) {
			$mod .= " and length(lineage) <= ".($rules->{endingLineageLength}*6);
		}
		$mod .= ")";
		push(@whereModifiers,$mod);
	}
	# we need to include children
	if (isIn("children",@{$relatives})) {
		push(@whereModifiers,"(parentId=".quote($self->getId).")");
	}
	# now lets add in all of the siblings in every level between ourself and the asset we wish to pedigree
	if (isIn("pedigree",@{$relatives}) && exists $rules->{assetToPedigree}) {
		my @mods;
		my $lineage = $rules->{assetToPedigree}->get("lineage");
		my $length = $rules->{assetToPedigree}->getLineageLength;
		for (my $i = $length; $i > 0; $i--) {
			my $line = substr($lineage,0,$i*6);
			push(@mods,"( lineage like ".quote($line.'%')." and  length(lineage)=".(($i+1)*6).")");
			last if ($self->getLineageLength == $i);
		}
		push(@whereModifiers, "(".join(" or ",@mods).")");
	}
	# formulate a where clause
	my $where = "state='published'";
	if (exists $rules->{excludeClasses}) { # deal with exclusions
		my @set;
		foreach my $className (@{$rules->{excludeClasses}}) {
			push(@set,"className <> ".quote($className));
		}
		$where .= 'and ('.join(" and ",@set).')';
	}
	$where .= " and ".join(" or ",@whereModifiers) if (scalar(@whereModifiers));
	# based upon all available criteria, let's get some assets
	my $columns = "assetId, className, parentId";
	$columns = "*" if ($rules->{returnQuickReadObjects});
	my $sortOrder = ($rules->{invertTree}) ? "desc" : "asc"; 
	my $sql = "select $columns from asset where $where order by lineage $sortOrder";
	my @lineage;
	my %relativeCache;
	my $sth = WebGUI::SQL->read($sql);
	while (my $properties = $sth->hashRef) {
		# create whatever type of object was requested
		my $asset;
		if ($rules->{returnObjects}) {
			if ($self->getId eq $properties->{assetId}) { # possibly save ourselves a hit to the database
				$asset =  $self;
			} else {
				$asset = WebGUI::Asset->newByDynamicClass($properties->{assetId}, $properties->{className});
			}
		} elsif ($rules->{returnQuickReadObjects}) {
			$asset = WebGUI::Asset->newByPropertyHashRef($properties);
		} else {
			$asset = $properties->{assetId};
		}
		# since we have the relatives info now, why not cache it
		if ($rules->{returnObjects} || $rules->{returnQuickReadObjects}) {
			my $parent = $relativeCache{$properties->{parentId}};
			$relativeCache{$properties->{assetId}} = $asset;
			$asset->{_parent} = $parent;
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

=head2 getName ( )

Returns the internationalization of the word "Asset".

=cut

sub getName {
	return WebGUI::International::get("asset","Asset");
}

#-------------------------------------------------------------------

=head2 getNextChildRank ( )

Returns a 6 digit number with leading zeros of the next rank a child will get.

=cut

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

#-------------------------------------------------------------------

=head2 getParent ( )

Returns an asset hash of the parent of current Asset.

=cut

sub getParent {
	my $self = shift;
	$self->{_parent} = WebGUI::Asset->newByDynamicClass($self->get("parentId")) unless (exists $self->{_parent});
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
	my ($rank) = $lineage =~ m/(.{6})$/;
	my $rank = $rank - 0; # gets rid of preceeding 0s.
	return $rank;
}

#-------------------------------------------------------------------

=head2 getToolbar ( )

Returns a toolbar with a set of icons that hyperlink to functions that delete, edit, promote, demote, cut, and copy.

=cut

sub getToolbar {
	my $self = shift;
	my $toolbar = deleteIcon('func=delete',$self->get("url"),WebGUI::International::get(43))
              	.editIcon('func=edit',$self->get("url"))
             	.moveUpIcon('func=promote',$self->get("url"))
             	.moveDownIcon('func=demote',$self->get("url"))
            	.cutIcon('func=cut',$self->get("url"))
            	.copyIcon('func=copy',$self->get("url"));
              #	.moveTopIcon('func=moveTop&wid='.${$wobject}{wobjectId})
              #	.moveBottomIcon('func=moveBottom&wid='.${$wobject}{wobjectId})
       # if (${$wobject}{namespace} ne "WobjectProxy" && isIn("WobjectProxy",@{$session{config}{wobjects}})) {
        #     	$wobjectToolbar .= shortcutIcon('func=createShortcut');
        #}
	return $toolbar;
}

#-------------------------------------------------------------------

=head2 getUiLevel ( )

Always returns zero.

=cut

sub getUiLevel {
	my $self = shift;
	return 0;
}

#-------------------------------------------------------------------

=head2 getUrl ( params )

Returns a URL of Asset based upon WebGUI's gateway script.

=head3 params

Name value pairs to add to the URL in the form of:

 name1=value1&name2=value2&name3=value3

=cut

sub getUrl {
	my $self = shift;
	my $params = shift;
	return WebGUI::URL::gateway($self->get("url"),$params);
}

#-------------------------------------------------------------------

=head2 getValue ( key )

Returns the value of anything it can find with an index of key, or else it returns undefined.

=head3 key

A form variable, an asset property name, or a propertyDefinition.

=cut

sub getValue {
	my $self = shift;
	my $key = shift;
	if (defined $key) {
		unless (exists $self->{_propertyDefinitions}) { # check to see if the definitions have been merged and cached
			my %properties;
			foreach my $definition (@{$self->definition}) {
				%properties = (%properties, %{$definition->{properties}});
			}
			$self->{_propertyDefinitions} = \%properties;
		}
		return $session{form}{$key} || $self->get($key) || $self->{_propertyDefinitions}{$key}{defaultValue};
	}
	return undef;
}

#-------------------------------------------------------------------

=head2 hasChildren ( )

Returns 1 or the count of Assets with the same parentId as current Asset (Which may be zero).

=cut

sub hasChildren {
	my $self = shift;
	unless (exists $self->{_hasChildren}) {
		if (exists $self->{_firstChild}) {
			$self->{_hasChildren} = 1;
		} elsif (exists $self->{_lastChild}) {
			$self->{_hasChildren} = 1;
		} else {
			my ($hasChildren) = WebGUI::SQL->read("select count(*) from asset where parentId=".quote($self->getId));
			$self->{_hasChildren} = $hasChildren;
		}
	}
	return $self->{_hasChildren};
}

#-------------------------------------------------------------------

=head2 new ( class,assetId||"new" [,overrideProperties] )

Constructor. This does not create an asset. 

=head class

A hash of a class.

=head3 assetId

The assetId of the asset you're creating an object reference for. Must not be blank. If specified as "new" then the object properties returns an assetId of new.

=head3 overrideProperties

A hash of properties to set besides defaults.

=cut

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

#-------------------------------------------------------------------

=head2 newByDynamicClass ( assetId,className [,overrideProperties] )

Returns an Asset object.

=head3 className

String of class to use. 

=head3 overrideProperties

Any properties to set besides defaults.

=cut

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


#-------------------------------------------------------------------

=head2 newByLineage ( lineage )

Returns an Asset object based upon given lineage.

=head3 lineage

Lineage string.

=cut

sub newByLineage {
	my $class = shift;
        my $lineage = shift;
        my $asset = WebGUI::SQL->quickHashRef("select assetId, className from asset where lineage=".quote($lineage));
	return WebGUI::Asset->newByDynamicClass($asset->{assetId}, $asset->{className});
}

#-------------------------------------------------------------------

=head2 newByPropertyHashRef ( properties )

Constructor. 

=head3 properties

A Properties Hash Ref.

=cut

sub newByPropertyHashRef {
	my $class = shift;
	my $properties = shift;
	my $className = $properties->{className};
	my $cmd = "use ".$className;
        eval ($cmd);
        WebGUI::ErrorHandler::fatalError("Couldn't compile asset package: ".$className.". Root cause: ".$@) if ($@);
	bless {_properties => $properties}, $className;
}

#-------------------------------------------------------------------

=head2 newByUrl ( url )

Returns a new Asset object based upon current url, given url or defaultPage.

=head3 url

String representing a URL. 

=cut

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

#-------------------------------------------------------------------

=head2 republish ( )

Sets Asset properties state to published.

=cut

sub republish {
	my $self = shift;
	WebGUI::SQL->write("update asset set state='published' where lineage like ".quote($self->get("lineage").'%'));
	$self->{_properties}{state} = "published";
}

#-------------------------------------------------------------------

=head2 paste ( assetId )

Returns 1 if can paste to a Parent. Sets the Asset to published. Otherwise returns 0.

=head3 assetId

Alphanumeric ID tag of Asset.

=cut

sub paste {
	my $self = shift;
	my $assetId = shift;
	my $pastedAsset = WebGUI::Asset->new($assetId);	
	if ($self->getId eq $pastedAsset->get("parentId") || $pastedAsset->setParent($self->getId)) {
		$pastedAsset->republish;
		$pastedAsset->updateHistory("pasted to parent ".$self->getId);
		return 1;
	}
	return 0;
}

#-------------------------------------------------------------------

=head2 processPropertiesFromFormPost ( )

Updates current Asset with data from Form.

=cut

sub processPropertiesFromFormPost {
	my $self = shift;
	my %data;
	foreach my $definition (@{$self->definition}) {
		foreach my $property (keys %{$definition->{properties}}) {
			$data{$property} = WebGUI::FormProcessor::process(
				$property,
				$definition->{properties}{$property}{fieldType},
				$definition->{properties}{$property}{defaultValue}
				);
		}
	}
	$data{title} = "Untitled" unless ($data{title});
	$data{menuTitle} = $data{title} unless ($data{menuTitle});
	$data{url} = $self->getParent->get("url").'/'.$data{menuTitle} unless ($data{url});
	$self->update(\%data);
}

#-------------------------------------------------------------------

=head2 promote ( )

Keeps the same rank of lineage, swaps with sister above.

=cut

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

#-------------------------------------------------------------------

=head2 purge ( )

Returns 1. Deletes an asset from tables and removes anything bound to that asset.

=cut

sub purge {
	my $self = shift;
	$self->updateHistory("purged");
	WebGUI::SQL->beginTransaction;
	foreach my $definition (@{$self->definition}) {
		WebGUI::SQL->write("delete from ".$definition->{tableName}." where assetId=".quote($self->getId));
	}
	WebGUI::SQL->commit;
	# eliminate anything bound to this asset
	my $sth = WebGUI::SQL->read("select assetId,className from asset where boundToId=".quote($self->getId));
	while (my ($id, $class) = $sth->array) {
		my $asset = WebGUI::Asset->newByDynamicClass($id,$class);
		if (defined $asset) {
			$asset->purgeTree;
		}	
	}
	$self = undef;
	return 1;
}

#-------------------------------------------------------------------

=head2 purgeTree ( )

Updates current Asset with data from Form.

=cut

sub purgeTree {
	my $self = shift;
	my $descendants = $self->getLineage(["self","descendants"],{returnObjects=>1, invertTree=>1});
	foreach my $descendant (@{$descendants}) {
		$descendant->purge;
	}
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
		$self->updateHistory("moved to parent ".$parent->getId);
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
	$self->updateHistory("changed rank");
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
	$self->updateHistory("swapped lineage between ".$first." and ".$second);
	return 1;
}


sub trash {
	my $self = shift;
	WebGUI::SQL->beginTransaction;
	WebGUI::SQL->write("update asset set state='limbo' where lineage like ".quote($self->get("lineage").'%'));
	WebGUI::SQL->write("update asset set state='trash' where assetId=".quote($self->getId));
	WebGUI::SQL->commit;
	$self->{_properties}{state} = "trash";
	$self->updateHistory("trashed");
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
			next unless (exists $properties->{$property});
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

sub updateHistory {
	my $self = shift;
	my $action = shift;
	my $userId = shift || $session{user}{userId};
	my $dateStamp = time();
	WebGUI::SQL->beginTransaction;
	WebGUI::SQL->write("insert into assetHistory (assetId, userId, actionTaken, dateStamp) values (
		".quote($self->getId).", ".quote($userId).", ".quote($action).", ".$dateStamp.")");
	$self->update({lastUpdated=>$dateStamp,lastUpdatedBy=>$userId});
	WebGUI::SQL->commit;
}

sub view {
	return "";
}

sub www_add {
	my $self = shift;
	my %properties = (
		groupIdView => $self->get("groupIdView"),
		groupIdEdit => $self->get("groupIdEdit"),
		ownerUserId => $self->get("ownerUserId"),
		encryptPage => $self->get("encryptPage"),
		isHidden => $self->get("isHidden"),
		startDate => $self->get("startDate"),
		endDate => $self->get("endDate")
		);
	my $newAsset = WebGUI::Asset->newByDynamicClass("new",$session{form}{class},\%properties);
	return $newAsset->www_edit();
}

sub www_copy {
	my $self = shift;
	return $self->getAdminConsole->render(WebGUI::Privilege::insufficient()) unless $self->canEdit;
	my $newAsset = $self->duplicate;
	$newAsset->cut;
	return "";
}

sub www_copyList {
	my $self = shift;
	return $self->getAdminConsole->render(WebGUI::Privilege::insufficient()) unless $self->canEdit;
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
	return $self->getAdminConsole->render(WebGUI::Privilege::insufficient()) unless $self->canEdit;
	$self->cut;
	return $self->getParent->www_view;
}

sub www_cutList {
	my $self = shift;
	return $self->getAdminConsole->render(WebGUI::Privilege::insufficient()) unless $self->canEdit;
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
	return $self->getAdminConsole->render(WebGUI::Privilege::insufficient()) unless $self->canEdit;
	$self->trash;
	return $self->getParent->www_view;
}

sub www_deleteList {
	my $self = shift;
	return $self->getAdminConsole->render(WebGUI::Privilege::insufficient()) unless $self->canEdit;
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
	return $self->getAdminConsole->render(WebGUI::Privilege::insufficient()) unless $self->canEdit;
	$self->demote;
	return "";
}

sub www_edit {
	my $self = shift;
	return $self->getAdminConsole->render(WebGUI::Privilege::insufficient()) unless $self->canEdit;
	return $self->getAdminConsole->render($self->getEditForm->print);
}

sub www_editSave {
	my $self = shift;
	return $self->getAdminConsole->render(WebGUI::Privilege::insufficient()) unless $self->canEdit;
	my $object;
	if ($session{form}{assetId} eq "new") {
		$object = $self->addChild({className=>$session{form}{class}});	
		$object->{_parent} = $self;
	} else {
		$object = $self;
	}
	$object->processPropertiesFromFormPost;
	$object->updateHistory("edited");
	return $self->www_manageAssets if ($session{form}{afterEdit} eq "assetManager" && $session{form}{assetId} eq "new");
	return $object->getParent->www_manageAssets if ($session{form}{afterEdit} eq "assetManager");
	return $object->www_view;
}

sub www_editTree {
	my $self = shift;
	my $ac = WebGUI::AdminConsole->new("assets");
	return $ac->render(WebGUI::Privilege::insufficient()) unless ($self->canEdit);
	my $tabform = WebGUI::TabForm->new;
	$tabform->hidden({name=>"func",value=>"editTreeSave"});
	$tabform->addTab("properties",WebGUI::International::get("properties","Asset"),9);
        $tabform->getTab("properties")->readOnly(
                -label=>WebGUI::International::get(104),
                -uiLevel=>9,
		-subtext=>'<br />'.WebGUI::International::get("change","Asset").' '.WebGUI::Form::yesNo({name=>"change_url"}),
		-value=>WebGUI::Form::selectList({
                	name=>"baseUrlBy",
			extras=>'id="baseUrlBy" onchange="toggleSpecificBaseUrl()"',
			options=>{
				parentUrl=>"Parent URL",
				specifiedBase=>"Specified Base",
				none=>"None"
				}
			}).'<span id="baseUrl"></span> / '.WebGUI::Form::selectList({
				name=>"endOfUrl",
				options=>{
					menuTitle=>WebGUI::International::get(411),
					title=>WebGUI::International::get(99),
					currentUrl=>"Current URL"
					}
				})."<script type=\"text/javascript\">
			function toggleSpecificBaseUrl () {
				if (document.getElementById('baseUrlBy').options[document.getElementById('baseUrlBy').selectedIndex].value == 'specifiedBase') {
					document.getElementById('baseUrl').innerHTML='<input type=\"text\" name=\"baseUrl\" />';
				} else {
					document.getElementById('baseUrl').innerHTML='';
				}
			}
			toggleSpecificBaseUrl();
				</script>"
                );
	$tabform->addTab("display",WebGUI::International::get(105),5);
	$tabform->getTab("display")->yesNo(
                -name=>"isHidden",
                -value=>$self->get("isHidden"),
                -label=>WebGUI::International::get(886),
                -uiLevel=>6,
		-subtext=>'<br />'.WebGUI::International::get("change","Asset").' '.WebGUI::Form::yesNo({name=>"change_isHidden"})
                );
        $tabform->getTab("display")->yesNo(
                -name=>"newWindow",
                -value=>$self->get("newWindow"),
                -label=>WebGUI::International::get(940),
                -uiLevel=>6,
		-subtext=>'<br />'.WebGUI::International::get("change","Asset").' '.WebGUI::Form::yesNo({name=>"change_newWindow"})
                );
	$tabform->getTab("display")->yesNo(
                -name=>"displayTitle",
                -label=>WebGUI::International::get(174),
                -value=>$self->getValue("displayTitle"),
                -uiLevel=>5,
		-subtext=>'<br />'.WebGUI::International::get("change","Asset").' '.WebGUI::Form::yesNo({name=>"change_displayTitle"})
                );
         $tabform->getTab("display")->template(
		-name=>"styleTemplateId",
		-label=>WebGUI::International::get(1073),
		-value=>$self->getValue("styleTemplateId"),
		-namespace=>'style',
		-afterEdit=>'op=editPage&amp;npp='.$session{form}{npp},
		-subtext=>'<br />'.WebGUI::International::get("change","Asset").' '.WebGUI::Form::yesNo({name=>"change_styleTemplateId"})
		);
         $tabform->getTab("display")->template(
		-name=>"printableStyleTemplateId",
		-label=>WebGUI::International::get(1079),
		-value=>$self->getValue("printableStyleTemplateId"),
		-namespace=>'style',
		-afterEdit=>'op=editPage&amp;npp='.$session{form}{npp},
		-subtext=>'<br />'.WebGUI::International::get("change","Asset").' '.WebGUI::Form::yesNo({name=>"change_printableStyleTemplateId"})
		);
        $tabform->getTab("display")->interval(
                -name=>"cacheTimeout",
                -label=>WebGUI::International::get(895),
                -value=>$self->getValue("cacheTimeout"),
                -uiLevel=>8,
		-subtext=>'<br />'.WebGUI::International::get("change","Asset").' '.WebGUI::Form::yesNo({name=>"change_cacheTimeout"})
                );
        $tabform->getTab("display")->interval(
                -name=>"cacheTimeoutVisitor",
                -label=>WebGUI::International::get(896),
                -value=>$self->getValue("cacheTimeoutVisitor"),
                -uiLevel=>8,
		-subtext=>'<br />'.WebGUI::International::get("change","Asset").' '.WebGUI::Form::yesNo({name=>"change_cacheTimeoutVisitor"})
                );
	$tabform->addTab("security",WebGUI::International::get(107),6);
        $tabform->getTab("security")->yesNo(
                -name=>"encryptPage",
                -value=>$self->get("encryptPage"),
                -label=>WebGUI::International::get('encrypt page'),
                -uiLevel=>6,
		-subtext=>'<br />'.WebGUI::International::get("change","Asset").' '.WebGUI::Form::yesNo({name=>"change_encryptPage"})
                );
	$tabform->getTab("security")->dateTime(
                -name=>"startDate",
                -label=>WebGUI::International::get(497),
                -value=>$self->get("startDate"),
                -uiLevel=>6,
		-subtext=>'<br />'.WebGUI::International::get("change","Asset").' '.WebGUI::Form::yesNo({name=>"change_startDate"})
                );
        $tabform->getTab("security")->dateTime(
                -name=>"endDate",
                -label=>WebGUI::International::get(498),
                -value=>$self->get("endDate"),
                -uiLevel=>6,
		-subtext=>'<br />'.WebGUI::International::get("change","Asset").' '.WebGUI::Form::yesNo({name=>"change_endDate"})
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
        $tabform->getTab("security")->selectList(
               -name=>"ownerUserId",
               -options=>$users,
               -label=>WebGUI::International::get(108),
               -value=>[$self->get("ownerUserId")],
               -subtext=>$subtext,
               -uiLevel=>6,
		-subtext=>'<br />'.WebGUI::International::get("change","Asset").' '.WebGUI::Form::yesNo({name=>"change_ownerUserId"})
               );
        $tabform->getTab("security")->group(
               -name=>"groupIdView",
               -label=>WebGUI::International::get(872),
               -value=>[$self->get("groupIdView")],
               -uiLevel=>6,
		-subtext=>'<br />'.WebGUI::International::get("change","Asset").' '.WebGUI::Form::yesNo({name=>"change_groupIdView"})
               );
        $tabform->getTab("security")->group(
               -name=>"groupIdEdit",
               -label=>WebGUI::International::get(871),
               -value=>[$self->get("groupIdEdit")],
               -excludeGroups=>[1,7],
               -uiLevel=>6,
		-subtext=>'<br />'.WebGUI::International::get("change","Asset").' '.WebGUI::Form::yesNo({name=>"change_groupIdEdit"})
		);
	return $ac->render($tabform->print, "Edit Branch");
}

sub www_editTreeSave {
	my $self = shift;
	return $self->getAdminConsole->render(WebGUI::Privilege::insufficient()) unless ($self->canEdit);
	my %data;
	$data{isHidden} = WebGUI::FormProcessor::yesNo("isHidden") if (WebGUI::FormProcessor::yesNo("change_isHidden"));
	$data{newWindow} = WebGUI::FormProcessor::yesNo("newWindow") if (WebGUI::FormProcessor::yesNo("change_newWindow"));
	$data{displayTitle} = WebGUI::FormProcessor::yesNo("displayTitle") if (WebGUI::FormProcessor::yesNo("change_displayTitle"));
	$data{styleTemplateId} = WebGUI::FormProcessor::template("styleTemplateId") if (WebGUI::FormProcessor::yesNo("change_styleTemplateId"));
	$data{printableStyleTemplateId} = WebGUI::FormProcessor::template("printableStyleTemplateId") if (WebGUI::FormProcessor::yesNo("change_printableStyleTemplateId"));
	$data{cacheTimeout} = WebGUI::FormProcessor::interval("cacheTimeout") if (WebGUI::FormProcessor::yesNo("change_cacheTimeout"));
	$data{cacheTimeoutVisitor} = WebGUI::FormProcessor::interval("cacheTimeoutVisitor") if (WebGUI::FormProcessor::yesNo("change_cacheTimeoutVisitor"));
	$data{encryptPage} = WebGUI::FormProcessor::yesNo("encryptPage") if (WebGUI::FormProcessor::yesNo("change_encryptPage"));
	$data{startDate} = WebGUI::FormProcessor::dateTime("startDate") if (WebGUI::FormProcessor::yesNo("change_startDate"));
	$data{endDate} = WebGUI::FormProcessor::dateTime("endDate") if (WebGUI::FormProcessor::yesNo("change_endDate"));
	$data{ownerUserId} = WebGUI::FormProcessor::selectList("ownerUserId") if (WebGUI::FormProcessor::yesNo("change_ownerUserId"));
	$data{groupIdView} = WebGUI::FormProcessor::group("groupIdView") if (WebGUI::FormProcessor::yesNo("change_groupIdView"));
	$data{groupIdEdit} = WebGUI::FormProcessor::group("groupIdEdit") if (WebGUI::FormProcessor::yesNo("change_groupIdEdit"));
	my ($urlBaseBy, $urlBase, $endOfUrl);
	my $changeUrl = WebGUI::FormProcessor::yesNo("change_url");
	if ($changeUrl) {
		$urlBaseBy = WebGUI::FormProcessor::selectList("urlBaseBy");
		$urlBase = WebGUI::FormProcessor::text("urlBase");
		$endOfUrl = WebGUI::FormProcessor::selectList("endOfUrl");
	}
	my $descendants = $self->getLineage(["self","descendants"],{returnObjects=>1});	
	foreach my $descendant (@{$descendants}) {
		my $url;
		if ($changeUrl) {
			if ($urlBaseBy eq "parentUrl") {
				delete $descendant->{_parent};
				$data{url} = $descendant->getParent->get("url")."/";
			} elsif ($urlBaseBy eq "specifiedUrl") {
				$data{url} = $urlBase."/";
			} else {
				$data{url} = "";
			}
			if ($endOfUrl eq "menuTitle") {
				$data{url} .= $descendant->get("menuTitle");
			} elsif ($endOfUrl eq "title") {
				$data{url} .= $descendant->get("title");
			} else {
				$data{url} .= $descendant->get("url");
			}
		}
		$descendant->update(\%data);
	}
	return $self->www_manageAssets;
}

sub www_emptyClipboard {
	my $self = shift;
	my $ac = WebGUI::AdminConsole->new("clipboard");
	return $ac->render(WebGUI::Privilege::insufficient()) unless (WebGUI::Grouping::isInGroup(4));
	foreach my $assetData (@{$self->getAssetsInClipboard($session{form}{systemClipboard} && WebGUI::Grouping::isInGroup(3))}) {
		my $asset = WebGUI::Asset->newByDynamicClass($assetData->{assetId},$assetData->{className});
		$asset->trash;
	}
	return $self->www_manageClipboard();
}

sub www_emptyTrash {
	my $self = shift;
	my $ac = WebGUI::AdminConsole->new("trash");
	return $ac->render(WebGUI::Privilege::insufficient()) unless (WebGUI::Grouping::isInGroup(4));
	foreach my $assetData (@{$self->getAssetsInTrash($session{form}{systemTrash} && WebGUI::Grouping::isInGroup(3))}) {
		my $asset = WebGUI::Asset->newByDynamicClass($assetData->{assetId},$assetData->{className});
		$asset->purgeTree;
	}
	return $self->www_manageTrash();
}


sub www_manageAssets {
	my $self = shift;
	return $self->getAdminConsole->render(WebGUI::Privilege::insufficient()) unless $self->canEdit;
	my $children = $self->getLineage(["descendants"],{returnObjects=>1, endingLineageLength=>$self->getLineageLength+1});
	my $output = $self->getAssetManagerControl($children);
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

sub www_manageClipboard {
	my $self = shift;
	my $ac = WebGUI::AdminConsole->new("clipboard");
	return $ac->render(WebGUI::Privilege::insufficient()) unless (WebGUI::Grouping::isInGroup(4));
	my @assets;
	my ($header,$limit);
        $ac->setHelp("clipboard manage");
	if ($session{form}{systemClipboard} && WebGUI::Grouping::isInGroup(3)) {
		$header = WebGUI::International::get(965);
		$ac->addSubmenuItem($self->getUrl('func=manageClipboard'), WebGUI::International::get(949));
		$ac->addSubmenuItem($self->getUrl('func=emptyClipboard&systemClipboard=1'), WebGUI::International::get(959), 
			'onclick="return window.confirm(\''.WebGUI::International::get(951).'\')"');
	} else {
		$ac->addSubmenuItem($self->getUrl('func=manageClipboard&systemClipboard=1'), WebGUI::International::get(954));
		$ac->addSubmenuItem($self->getUrl('func=emptyClipboard'), WebGUI::International::get(950),
			'onclick="return window.confirm(\''.WebGUI::International::get(951).'\')"');
		$limit = 1;
	}
	foreach my $assetData (@{$self->getAssetsInClipboard($limit)}) {
		push(@assets,WebGUI::Asset->newByDynamicClass($assetData->{assetId},$assetData->{className}));
	}
	return $ac->render($self->getAssetManagerControl(\@assets), $header);
}


sub www_manageTrash {
	my $self = shift;
	my $ac = WebGUI::AdminConsole->new("trash");
	return $ac->render(WebGUI::Privilege::insufficient()) unless (WebGUI::Grouping::isInGroup(4));
	my @assets;
	my ($header, $limit);
        $ac->setHelp("trash manage");
	if ($session{form}{systemTrash} && WebGUI::Grouping::isInGroup(3)) {
		$header = WebGUI::International::get(965);
		$ac->addSubmenuItem($self->getUrl('func=manageTrash'), WebGUI::International::get(10));
		$ac->addSubmenuItem($self->getUrl('func=emptyTrash&systemTrash=1'), WebGUI::International::get(967), 
			'onclick="return window.confirm(\''.WebGUI::International::get(651).'\')"');
	} else {
		$ac->addSubmenuItem($self->getUrl('func=manageTrash&systemTrash=1'), WebGUI::International::get(964));
		$ac->addSubmenuItem($self->getUrl('func=emptyTrash'), WebGUI::International::get(11),
			'onclick="return window.confirm(\''.WebGUI::International::get(651).'\')"');
		$limit = 1;
	}
	foreach my $assetData (@{$self->getAssetsInTrash($limit)}) {
		push(@assets,WebGUI::Asset->newByDynamicClass($assetData->{assetId},$assetData->{className}));
	}
	return $ac->render($self->getAssetManagerControl(\@assets), $header);
}


sub www_paste {
	my $self = shift;
	return $self->getAdminConsole->render(WebGUI::Privilege::insufficient()) unless $self->canEdit;
	$self->paste($session{form}{assetId});
	return "";
}

sub www_pasteList {
	my $self = shift;
	return $self->getAdminConsole->render(WebGUI::Privilege::insufficient()) unless $self->canEdit;
	foreach my $clipId ($session{cgi}->param("assetId")) {
		$self->paste($clipId);
	}
	return $self->www_manageAssets();
}

sub www_promote {
	my $self = shift;
	return $self->getAdminConsole->render(WebGUI::Privilege::insufficient()) unless $self->canEdit;
	$self->promote;
	return "";
}

sub www_setParent {
	my $self = shift;
	return $self->getAdminConsole->render(WebGUI::Privilege::insufficient()) unless $self->canEdit;
	my $newParent = $session{form}{assetId};
	$self->setParent($newParent) if (defined $newParent);
	return $self->www_manageAssets();

}

sub www_setRank {
	my $self = shift;
	return $self->getAdminConsole->render(WebGUI::Privilege::insufficient()) unless $self->canEdit;
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

