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
use Tie::IxHash;
use WebGUI::Asset::Template;
use WebGUI::AdminConsole;
use WebGUI::Cache;
use WebGUI::DateTime;
use WebGUI::ErrorHandler;
use WebGUI::Form;
use WebGUI::FormProcessor;
use WebGUI::Grouping;
use WebGUI::HTMLForm;
use WebGUI::HTTP;
use WebGUI::Icon;
use WebGUI::Id;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::TabForm;
use WebGUI::URL;
use WebGUI::Utility;

=head1 NAME

Package WebGUI::Asset

=head1 DESCRIPTION

Package to manipulate items in WebGUI's asset system. Replaces Collateral.

=head1 SYNOPSIS

An asset is the basic class of content in WebGUI. This handles security, urls, and other basic information common to all content items.

A lineage is a concatenated series of sequence numbers, each six digits long, that explain an asset's position in its familiy tree. Lineage describes who the asset's anscestors are, how many ancestors the asset has in its family tree (lineage length), and the asset's position (rank) amongst its siblings. In addition, lineage provides enough information about an asset to generate a list of its siblings and descendants.
 
 use WebGUI::Asset;

 $AssetObject=           WebGUI::Asset->addChild(\%properties);
 $integer=               WebGUI::Asset->canEdit("An_Id_AbCdeFGHiJkLMNOP");
 $integer=               WebGUI::Asset->canView("An_Id_AbCdeFGHiJkLMNOP");
                         WebGUI::Asset->cascadeLineage(100001,100101110111);
 $html=                  WebGUI::Asset->checkExportPath();
                         WebGUI::Asset->cut();
 $arrayRef=              WebGUI::Asset->definition(\@arr);
                         WebGUI::Asset->deleteMetaDataField();
 $integer=               WebGUI::Asset->demote();
                         WebGUI::Asset->DESTROY();
 $AssetObject=           WebGUI::Asset->duplicate($AssetObject);
 $html=                  WebGUI::Asset->exportAsHtml(\%params);
 $string=                WebGUI::Asset->fixUrl("Title of Page");
 $string=                WebGUI::Asset->formatRank(1);
 $hashref=               WebGUI::Asset->get();
 $AdminConsoleObject=    WebGUI::Asset->getAdminConsole();
 $arrayRef=              WebGUI::Asset->getAssetAdderLinks($string);
 $JavaScript=            WebGUI::Asset->getAssetManagerControl(\%hashref, $string, $bool);
 $arrayRef=              WebGUI::Asset->getAssetsInClipboard($boolean, $string);
 $arrayRef=              WebGUI::Asset->getAssetsInTrash($boolean, $string);
 $containerRef=          WebGUI::Asset->getContainer();
 $tabform=               WebGUI::Asset->getEditForm();
 getFirstChild
 getIcon
 getId
 getIndexerParams
 getLastChild
 getLineage
 getLineageLength
 getMetaDataFields
 getName
 getNextChildRank
 getParent
 getParentLineage
 getRank
 getRoot
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
 www_deleteMetaDataField
 www_demote
 www_deployPackage
 www_edit
 www_editMetaDataField
 www_editMetaDataFieldSave
 www_editSave
 www_editTree (NYI)
 www_editTreeSave (NYI)
 www_emptyClipboard
 www_emptyTrash
 www_export
 www_manageAssets
 www_manageClipboard
 www_manageMetaData
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

=head2 addChild ( properties [, id ] )

Adds a child asset to a parent. Creates a new AssetID for child. Makes the parent know that it has children. Adds a new asset to the asset table. Returns the newly created Asset.

=head3 properties

A hash reference containing a list of properties to associate with the child. The only required property value is "className"

=head3 id

A unique 22 character ID.  By default WebGUI will generate this and you should almost never specify it. This is mainly here for developers that want to include default templates in their plug-ins.

=cut

sub addChild {
	my $self = shift;
	my $properties = shift;
	my $id = shift || WebGUI::Id::generate();
	my $lineage = $self->get("lineage").$self->getNextChildRank;
	$self->{_hasChildren} = 1;
	WebGUI::SQL->beginTransaction;
	WebGUI::SQL->write("insert into asset (assetId, parentId, lineage, state, className, url, startDate, endDate, ownerUserId, groupIdEdit, groupIdView) 
		values (".quote($id).",".quote($self->getId).", ".quote($lineage).", 
		'published', ".quote($properties->{className}).", ".quote($id).",
		997995720, 9223372036854775807,'3','3','7')");
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

=head2 canAdd ( [userId, groupId] )

Verifies that the user has the privileges necessary to add this type of asset. Return a boolean.

=head3 userId

Unique hash identifier for a user. If not supplied, current user. 

=head3 groupId

Only developers extending this method should use this parameter. By default WebGUI will check groups in this order, whichever is defined: Group id assigned in the config file for each asset. Group assigned by the developer in the asset itself if s/he extended this method to do so. The "turn admin on" group which is group id 12.

=cut

sub canAdd {
	my $className = shift;
	my $userId = shift || $session{user}{userId};
	my $subclassGroupId = shift;
	my $groupId = $session{config}{assetAddPrivilege}{$className} || $subclassGroupId || '12';
        return WebGUI::Grouping::isInGroup($groupId,$userId);
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
	my $now = time();
        my $prepared = WebGUI::SQL->prepare("update asset set lineage=?, lastUpdatedBy=".quote($session{user}{userId}).", lastUpdated=$now where assetId=?");
	my $descendants = WebGUI::SQL->read("select assetId,lineage from asset where lineage like ".quote($oldLineage.'%'));
	while (my ($assetId, $lineage) = $descendants->array) {
		WebGUI::Cache->new("asset_".$assetId)->delete;
		WebGUI::Cache->new("lineage_".$lineage)->delete;
		my $fixedLineage = $newLineage.substr($lineage,length($oldLineage));
		$prepared->execute([$fixedLineage,$assetId]);
	}
	$descendants->finish;
}


#-------------------------------------------------------------------

=head2 checkExportPath ( )

Returns a descriptive error message (HTML) if the export path is not writable, does not exist, or is not specified in the per-domain WebGUI config file.

=cut

sub checkExportPath {
	my $error;
	if(defined $session{config}{exportPath}) {
		if(-d $session{config}{exportPath}) {
			unless (-w $session{config}{exportPath}) {
				$error .= 'Error: The export path '.$session{config}{exportPath}.' is not writable.<br>
						Make sure that the webserver has permissions to write to that directory';
			}
		} else {
			$error .= 'Error: The export path '.$session{config}{exportPath}.' does not exist.';
		}
	} else {
		$error.= 'Error: The export path is not configured. Please set the exportPath variable in the WebGUI config file';
	}
	$error = '<p><b>'.$error.'</b></p>' if $error;
	return $error;
}



#-------------------------------------------------------------------

=head2 cut ( )

Removes asset from lineage, places it in clipboard state. The "gap" in the lineage is changed in state to clipboard-limbo.

=cut

sub cut {
	my $self = shift;
	WebGUI::SQL->beginTransaction;
	WebGUI::SQL->write("update asset set state='clipboard-limbo', lastUpdatedBy=".quote($session{user}{userId}).", lastUpdated=".time()." where lineage like ".quote($self->get("lineage").'%')." and state='published'");
	WebGUI::SQL->write("update asset set state='clipboard', lastUpdatedBy=".quote($session{user}{userId}).", lastUpdated=".time()." where assetId=".quote($self->getId));
	WebGUI::SQL->commit;
	$self->updateHistory("cut");
	$self->{_properties}{state} = "clipboard";
}
 
#-------------------------------------------------------------------

=head2 definition ( [ definition ] )

Basic definition of an Asset. Properties, default values. Returns an array reference containing tableName,className,properties

=head3 definition

An array reference containing additional information to include with the default definition.

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
                                extraHeadTags=>{
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
                                        defaultValue=>997995720
                                        },
                                endDate=>{
                                        fieldType=>'dateTime',
                                        defaultValue=>32472169200
                                        },
				assetSize=>{
					noFormPost=>1,
					fieldType=>'hidden',
					defaultValue=>0
					},
				encryptPage=>{
					fieldType=>'yesNo',
					defaultValue=>0
					},
				isPackage=>{
					fieldType=>'yesNo',
					defaultValue=>0
					},
				isPrototype=>{
					fieldType=>'yesNo',
					defaultValue=>0
					},
				isHidden=>{
					fieldType=>'yesNo',
					defaultValue=>0
					},
				newWindow=>{
					fieldType=>'yesNo',
					defaultValue=>0
					}
                        }
                });
        return \@newDef;
}

#-------------------------------------------------------------------

=head2 deleteMetaDataField ( )

Deletes a field from the metadata system.

=head3 fieldId

The fieldId to be deleted.

=cut

sub deleteMetaDataField {
	my $self = shift;
	my $fieldId = shift;
	WebGUI::SQL->beginTransaction;
        WebGUI::SQL->write("delete from metaData_properties where fieldId = ".quote($fieldId));
        WebGUI::SQL->write("delete from metaData_values where fieldId = ".quote($fieldId));
	WebGUI::SQL->commit;
}


#-------------------------------------------------------------------

=head2 demote ( )

Swaps lineage with sister below. Returns 1 if there is a sister to swap. Otherwise returns 0.

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
	# something bad happens when the following is enabled, not sure why
	# must check this out later
	#$self->{_parent}->DESTROY if (exists $self->{_parent});
	$self->{_firstChild}->DESTROY if (exists $self->{_firstChild});
	$self->{_lastChild}->DESTROY if (exists $self->{_lastChild});
	$self = undef;
}


#-------------------------------------------------------------------

=head2 duplicate ( [assetToDuplicate] )

Duplicates an asset. Calls addChild with assetToDuplicate as an arguement. Returns a new Asset object.

=head3 assetToDuplicate

If not supplied, defaults to self.

=cut

sub duplicate {
	my $self = shift;
	my $assetToDuplicate = shift || $self;
	my $newAsset = $self->addChild($assetToDuplicate->get);
        my $sth = WebGUI::SQL->read("select * from metaData_values where assetId = ".quote($assetToDuplicate->getId));
        while( my $h = $sth->hashRef) {
		WebGUI::SQL->write("insert into metaData_values (fieldId, assetId, value) values (".
					quote($h->{fieldId}).",".quote($newAsset->getId).",".quote($h->{value}).")");
        }
        $sth->finish;
	return $newAsset;
}

#-------------------------------------------------------------------

=head2 duplicateTree ( [assetToDuplicate] )

Duplicates an asset and all its descendants. Calls addChild with assetToDuplicate as an argument. Returns a new Asset object.

=head3 assetToDuplicate

The asset to duplicate. Defaults to self.

=cut

sub duplicateTree {
	my $self = shift;
	my $assetToDuplicate = shift || $self;
	my $newAsset = $self->duplicate($assetToDuplicate);
	foreach my $child (@{$assetToDuplicate->getLineage(["children"],{returnObjects=>1})}) {
		$newAsset->duplicateTree($child);
	}
	return $newAsset;
}

#-------------------------------------------------------------------

=head2 exportAsHtml ( hashref )

Executes the export and returns html content.

=head3 hashref

A hashref containing one of the following properties:

=head4 extrasUrl

The URL where the page will be able to find the WebGUI extras folder. Defaults to the extrasURL in the config file.

=head4 stripHtml

A boolean indicating whether the resulting output should be stripped of HTML tags.

=head4 uploadsUrl

The URL where the page will be able to find the files uploaded to WebGUI. Defaults to the uploadsURL in the config file.

=head4 userId

The unique id of the user to become when exporting this page. Defaults to '1' (Visitor).

=cut

sub exportAsHtml {
	my $self = shift;
	my $params = shift;
	my $uploadsUrl = $params->{uploadsUrl} || $session{config}{uploadsUrl};
	my $extrasUrl = $params->{extrasUrl} || $session{config}{extrasUrl};
	my $userId = $params->{userId} || 1;
	my $stripHtml = $params->{stripHtml} || undef;

	# Save current session information because we need to restore current session after the export has finished.
	my %oldSession = %session;

	# Change the stuff we need to change to do the export
	WebGUI::Session::refreshUserInfo($userId) unless ($userId == $session{user}{userId});
	delete $session{form}; 
	$session{var}{adminOn} = $self->get('adminOn');
	WebGUI::Session::refreshPageInfo($self->get('pageId'));
	$self->{_properties}{cacheTimeout} = $self->{_properties}{cacheTimeoutVisitor} = 1;
	$session{config}{uploadsURL} = $uploadsUrl;
	$session{config}{extrasURL} = $extrasUrl;

	# Generate the page
	my $content = $self->www_view;
	if($stripHtml) {
		$content = WebGUI::HTML::html2text($content);
	}

	# Restore session
	%session = %oldSession;
	delete $session{page}{noHttpHeader};
	return $content;
}

#-------------------------------------------------------------------

=head2 fixUrl ( string )

Returns a URL, removing invalid characters and making it unique.

=head3 string

Any text string. Most likely will have been the Asset's name or title.

=cut

sub fixUrl {
	my $self = shift;
	my $url = WebGUI::URL::urlize(shift);
	if (length($url) > 250) {
		$url = substr($url,220);
	}
	if ($session{setting}{urlExtension} ne "" && !($url =~ /\./)) {
		$url .= ".".$session{setting}{urlExtension};
	}
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

=head2 getAssetAdderLinks ( [addToUrl, type] )

Returns an arrayref that contains a label (name of the class of Asset) and url (url link to function to add the class).

=head3 addToUrl

Any text to append to the getAssetAdderLinks URL. Usually name/variable pairs to pass in the url. If addToURL is specified, the character "&" and the text in addToUrl is appended to the returned url.

=head3 type

A string indicating which type of adders to return. Defaults to "assets". Choose from "assets", "assetContainers", or "utilityAssets".

=cut

sub getAssetAdderLinks {
	my $self = shift;
	my $addToUrl = shift;
	my $type = shift || "assets";
	my %links;
	foreach my $class (@{$session{config}{$type}}) {
		my $load = "use ".$class;
		eval ($load);
		if ($@) {
			WebGUI::ErrorHandler::error("Couldn't compile ".$class." because ".$@);
		} else {
			my $uiLevel = eval{$class->getUiLevel()};
			if ($@) {
				WebGUI::ErrorHandler::error("Couldn't get UI level of ".$class." because ".$@);
			} else {
				next if ($uiLevel > $session{user}{uiLevel});
			}
			my $canAdd = eval{$class->canAdd()};
			if ($@) {
				WebGUI::ErrorHandler::error("Couldn't determine if user can add ".$class." because ".$@);
			} else {
				next unless ($canAdd);
			}
			my $label = eval{$class->getName()};
			if ($@) {
				WebGUI::ErrorHandler::error("Couldn't get the name of ".$class." because ".$@);
			} else {
				my $url = $self->getUrl("func=add&class=".$class);
				$url = WebGUI::URL::append($url,$addToUrl) if ($addToUrl);
				$links{$label}{url} = $url;
				$links{$label}{icon} = $class->getIcon;
				$links{$label}{'icon.small'} = $class->getIcon(1);
			}
		}
	}
	my $constraint;
	if ($type eq "assetContainers") {
		$constraint = quoteAndJoin($session{config}{assetContainers});
	} elsif ($type eq "utilityAssets") {
		$constraint = quoteAndJoin($session{config}{utilityAssets});
	} else {
		$constraint = quoteAndJoin($session{config}{assets});
	}
	my $sth = WebGUI::SQL->read("select className,assetId from asset where isPrototype=1 and state='published' and className in ($constraint)");
	while (my ($class,$id) = $sth->array) {
		my $asset = WebGUI::Asset->newByDynamicClass($id,$class);
		next unless ($asset->canView && $asset->canAdd && $asset->getUiLevel <= $session{user}{uiLevel});
		my $url = $self->getUrl("func=add&class=".$class."&prototype=".$id);
		$url = WebGUI::URL::append($url,$addToUrl) if ($addToUrl);
		$links{$asset->getTitle}{url} = $url;
		$links{$asset->getTitle}{icon} = $asset->getIcon;
		$links{$asset->getTitle}{'icon.small'} = $asset->getIcon(1);
		$links{$asset->getTitle}{'isPrototype'} = 1;
		$links{$asset->getTitle}{'asset'} = $asset;
	}
	my @sortedLinks;
	foreach my $label (sort keys %links) {
		push(@sortedLinks,{
			label=>$label,
			url=>$links{$label}{url},
			icon=>$links{$label}{icon},
			'icon.small'=>$links{$label}{'icon.small'},
			isPrototype=>$links{$label}{isPrototype},
			asset=>$links{$label}{asset}
			});	
	}
	return \@sortedLinks;
}

#-------------------------------------------------------------------

=head2 getAssetManagerControl ( children [,controlType,removeRank] )

Returns a text string of HTML code (Javascript) for the Asset Manager Control Page. English only.

=head3 children

A hashref of the children of the Asset to be managed.

=head3 controlType

An optional string representing the controlType (manager.assetType) to be passed to the assetManager script.

=head3 removeRank

manager.disableDisplay(0) is added to the script if parameter is defined.

=cut

sub getAssetManagerControl {
	my $self = shift;
	my $children = shift;
	my $controlType = shift;
	my $removeRank = shift;
	WebGUI::Style::setLink($session{config}{extrasURL}.'/assetManager/assetManager.css', {rel=>"stylesheet",type=>"text/css"});
	WebGUI::Style::setScript($session{config}{extrasURL}.'/assetManager/Tools.js', {type=>"text/javascript"});
	WebGUI::Style::setScript($session{config}{extrasURL}.'/assetManager/ContextMenu.js', {type=>"text/javascript"});
	WebGUI::Style::setScript($session{config}{extrasURL}.'/assetManager/Asset.js', {type=>"text/javascript"});
	WebGUI::Style::setScript($session{config}{extrasURL}.'/assetManager/Display.js', {type=>"text/javascript"});
	WebGUI::Style::setScript($session{config}{extrasURL}.'/assetManager/EventManager.js', {type=>"text/javascript"});
	WebGUI::Style::setScript($session{config}{extrasURL}.'/assetManager/AssetManager.js', {type=>"text/javascript"});
	WebGUI::Style::setScript($session{config}{extrasURL}.'/assetManager/AssetManagerAsset.js', {type=>"text/javascript"});
	WebGUI::Style::setScript($session{config}{extrasURL}.'/assetManager/CrumbTrailAsset.js', {type=>"text/javascript"});
	WebGUI::Style::setScript($session{config}{extrasURL}.'/assetManager/'.$controlType.'.js', {type=>"text/javascript"}) if (defined $controlType);
	my $output = '
		<div id="contextMenu" class="contextMenu"></div>
   		<div id="propertiesWindow" class="propertiesWindow"></div>
   		<div id="crumbtrail"></div>
   		<div id="workspace">Retrieving Assets...</div>
   		<div id="dragImage" class="dragIdentifier">hello</div>
		';
	$output .= "<script>\n";
	$output .= "/* assetId, url, title */\nvar crumbtrail = [\n";
	my $ancestors = $self->getLineage(["self","ancestors"],{returnQuickReadObjects=>1});
	my @dataArray;
	foreach my $ancestor (@{$ancestors}) {
		my $title = $ancestor->getTitle;
		$title =~ s/\'/\\\'/g;
		push(@dataArray,"['".$ancestor->getId."','".$ancestor->getUrl."','".$title."']\n");
	}
	$output .= join(",",@dataArray);
	$output .= "];\n";
	$output .= "var columnHeadings = ['Rank','Title','Type','Last Updated','Size'];\n";
	$output .= "/*rank, title, type, lastUpdate, size, url, assetId, icon */\nvar assets = [\n";
	@dataArray = ();
	foreach my $child (@{$children}) {
		my $title = $child->getTitle;
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
	$output .= "labels['restore'] = 'Restore';\n";
	$output .= "labels['purge'] = 'Purge';\n";
	$output .= "labels['go'] = 'Go';\n";
	$output .= "labels['properties'] = 'Properties';\n";
	$output .= "labels['editTree'] = 'Edit Branch';\n";
	$output .= "var manager = new AssetManager(assets,columnHeadings,labels,crumbtrail);\n";
	$output .= "manager.assetType='".$controlType."';\n" if (defined $controlType);
	$output .= "manager.disableDisplay(0);\n" if (defined $removeRank);
	if ($controlType eq "ManageTrash" || $controlType eq "ManageClipboard") {
		$output .= "manager.displayCrumbTrail = false;\n";
	#	$output .= "manager.sortEnabled = false;\n";
	}
	$output .= "manager.renderAssets();\n";
	$output .= "</script>\n";
	return $output;
}

#-------------------------------------------------------------------

=head2 getAssetsInClipboard ( [limitToUser,userId] )

Returns an array reference of title, assetId, and classname to the assets in the clipboard.

=head3 limitToUser

If True, only return assets last updated by userId.

=head3 userId

If not specified, uses current user.

=cut

sub getAssetsInClipboard {
	my $self = shift;
	my $limitToUser = shift;
	my $userId = shift || $session{user}{userId};
	my @assets;
	my $limit;
	if ($limitToUser) {
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

=head2 getContainer  ()

Returns a reference to the container asset. If this asset is a container it returns a reference to itself. If this asset is not attached to a container it returns its parent.

=cut

sub getContainer {
	my $self = shift;
	if (WebGUI::Utility::isIn($self->get("className"), @{$session{config}{assetContainers}})) {
		return $self;
	} else {
		$session{asset} = $self->getParent;
		return $self->getParent;
	}
}


#-------------------------------------------------------------------

=head2 getEditForm ( )

Creates and returns a tabform to edit parameters of an Asset.

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
	if ($session{form}{proceed}) {
		$tabform->hidden({
			name=>"proceed",
			value=>$session{form}{proceed}
			});
	}
	$tabform->addTab("properties",WebGUI::International::get("properties","Asset"));
	$tabform->getTab("properties")->readOnly(
		-label=>WebGUI::International::get("asset id","Asset"),
		-value=>$self->get("assetId")
		);
	$tabform->getTab("properties")->text(
		-label=>WebGUI::International::get(99,"Asset"),
		-name=>"title",
		-value=>$self->get("title")
		);
	$tabform->getTab("properties")->text(
		-label=>WebGUI::International::get(411,"Asset"),
		-name=>"menuTitle",
		-value=>$self->get("menuTitle"),
		-uiLevel=>1
		);
        $tabform->getTab("properties")->text(
                -name=>"url",
                -label=>WebGUI::International::get(104,"Asset"),
                -value=>$self->get("url"),
                -uiLevel=>3
                );
	$tabform->addTab("display",WebGUI::International::get(105,"Asset"),5);
	$tabform->getTab("display")->yesNo(
                -name=>"isHidden",
                -value=>$self->get("isHidden"),
                -label=>WebGUI::International::get(886,"Asset"),
                -uiLevel=>6
                );
        $tabform->getTab("display")->yesNo(
                -name=>"newWindow",
                -value=>$self->get("newWindow"),
                -label=>WebGUI::International::get(940,"Asset"),
                -uiLevel=>6
                );
	$tabform->addTab("security",WebGUI::International::get(107,"Asset"),6);
        $tabform->getTab("security")->yesNo(
                -name=>"encryptPage",
                -value=>$self->get("encryptPage"),
                -label=>WebGUI::International::get('encrypt page',"Asset"),
                -uiLevel=>6
                );
	$tabform->getTab("security")->dateTime(
                -name=>"startDate",
                -label=>WebGUI::International::get(497,"Asset"),
                -value=>$self->get("startDate"),
                -uiLevel=>6
                );
        $tabform->getTab("security")->dateTime(
                -name=>"endDate",
                -label=>WebGUI::International::get(498,"Asset"),
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
               -label=>WebGUI::International::get(108,"Asset"),
               -value=>[$self->get("ownerUserId")],
               -subtext=>$subtext,
               -uiLevel=>6
               );
        $tabform->getTab("security")->group(
               -name=>"groupIdView",
               -label=>WebGUI::International::get(872,"Asset"),
               -value=>[$self->get("groupIdView")],
               -uiLevel=>6
               );
        $tabform->getTab("security")->group(
               -name=>"groupIdEdit",
               -label=>WebGUI::International::get(871,"Asset"),
               -value=>[$self->get("groupIdEdit")],
               -excludeGroups=>[1,7],
               -uiLevel=>6
               );
	$tabform->addTab("meta","Meta",3);
        $tabform->getTab("meta")->textarea(
                -name=>"synopsis",
                -label=>WebGUI::International::get(412,"Asset"),
                -value=>$self->get("synopsis"),
                -uiLevel=>3
                );
        $tabform->getTab("meta")->textarea(
                -name=>"extraHeadTags",
		-label=>WebGUI::International::get("extra head tags","Asset"),
                -value=>$self->get("extraHeadTags"),
                -uiLevel=>5
                );
	$tabform->getTab("meta")->yesNo(
		-name=>"isPackage",
		-label=>WebGUI::International::get("make package","Asset"),
		-value=>$self->getValue("isPackage"),
		-uiLevel=>7
		);
	$tabform->getTab("meta")->yesNo(
		-name=>"isPrototype",
		-label=>WebGUI::International::get("make prototype","Asset"),
		-value=>$self->getValue("isPrototype"),
		-uiLevel=>9
		);
        if ($session{setting}{metaDataEnabled}) {
                my $meta = $self->getMetaDataFields();
                foreach my $field (keys %$meta) {
                        my $fieldType = $meta->{$field}{fieldType} || "text";
                        my $options;
                        # Add a "Select..." option on top of a select list to prevent from
                        # saving the value on top of the list when no choice is made.
                        if($fieldType eq "selectList") {
                                $options = {"", WebGUI::International::get("Select...","Asset")};
                        }
                        $tabform->getTab("meta")->dynamicField($fieldType,
                                                -name=>"metadata_".$meta->{$field}{fieldId},
                                                -label=>$meta->{$field}{fieldName},
                                                -uiLevel=>5,
                                                -value=>$meta->{$field}{value},
                                                -extras=>qq/title="$meta->{$field}{description}"/,
                                                -possibleValues=>$meta->{$field}{possibleValues},
                                                -options=>$options
                                );
                }
                # Add a quick link to add field
                $tabform->getTab("meta")->readOnly(
                                        -value=>'<p><a href="'.WebGUI::URL::page("func=editMetaDataField&fid=new").'">'.
                                                        WebGUI::International::get('Add new field','Asset').
                                                        '</a></p>'
                );
        }
	return $tabform;
}

#-------------------------------------------------------------------

=head2 getFirstChild ( )

Returns the highest rank, top of the highest rank Asset under current Asset.

=cut

sub getFirstChild {
	my $self = shift;
	unless (exists $self->{_firstChild}) {
		my $lineage = WebGUI::Cache->new("firstchild_".$self->getId)->get;
		unless ($lineage) {
			($lineage) = WebGUI::SQL->quickArray("select min(lineage) from asset where parentId=".quote($self->getId));
			WebGUI::Cache->new("firstchild_".$self->getId)->set($lineage);
		}
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

=head2 getImportNode ()

Returns the import node asset object. This is where developers will templates, files, etc to the asset tree that have no other obvious attachment point.

=cut

sub getImportNode {
	return WebGUI::Asset->newByDynamicClass("PBasset000000000000002");
}

#-------------------------------------------------------------------
                                                                                                                                                       
=head2 getIndexerParams ( )
                                                                                                                                                       
Override this method and return a hash reference that includes the properties necessary to index the content of the wobject.
Currently does nothing.
                                                                                                                                                       
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
		my $lineage = WebGUI::Cache->new("lastchild_".$self->getId)->get;
		unless ($lineage) {
			($lineage) = WebGUI::SQL->quickArray("select max(lineage) from asset where parentId=".quote($self->getId));
			WebGUI::Cache->new("lastchild_".$self->getId)->set($lineage);
		}
		$self->{_lastChild} = WebGUI::Asset->newByLineage($lineage);
	}
	return $self->{_lastChild};
}

#-------------------------------------------------------------------

=head2 getLineage ( relatives,rules )

Returns an array reference of lineages of relatives based upon rules.

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

=head4 returnQuickReadObjects

A boolean indicating that we should return objects that contain only base asset information rather than asset ids. This is mainly useful for navigation, clipboard, trash, and other system level functions.

=head4 returnObjects

A boolean indicating that we should return objects rather than asset ids.

=head4 invertTree

A boolean indicating whether the resulting asset tree should be returned in reverse order.

=head4 includeOnlyClasses

An array reference containing a list of asset classes to include in the result. If this is specified then no other classes except these will be returned. The opposite of the excludeClasses rule.

=head4 joinClass

An array reference containing asset classes to join in. There is no real reason to use a joinClass without a whereClause, but it's trivial to use a whereClause if you don't use a joinClass.  You will only be able to filter on the asset table, however.

=head4 whereClause

A string containing extra where clause information for the query.

=cut

sub getLineage {
	my $self = shift;
	my $relatives = shift;
	my $rules = shift;
	my $lineage = $self->get("lineage");
	my @whereModifiers;
	# let's get those siblings
	if (isIn("siblings",@{$relatives})) {
		push(@whereModifiers, " (asset.parentId=".quote($self->get("parentId"))." and asset.assetId<>".quote($self->getId).")");
	}
	# ancestors too
	my @specificFamilyMembers = ();
	if (isIn("ancestors",@{$relatives})) {
		my $i = 1;
		my @familyTree = ($lineage =~ /(.{6})/g);
                while (pop(@familyTree)) {
                        push(@specificFamilyMembers,join("",@familyTree)) if (scalar(@familyTree));
			last if ($i >= $rules->{ancestorLimit});
			$i++;
                }
	}
	# let's add ourself to the list
	if (isIn("self",@{$relatives})) {
		push(@specificFamilyMembers,$self->get("lineage"));
	}
	if (scalar(@specificFamilyMembers) > 0) {
		push(@whereModifiers,"(asset.lineage in (".quoteAndJoin(\@specificFamilyMembers)."))");
	}
	# we need to include descendants
	if (isIn("descendants",@{$relatives})) {
		my $mod = "(asset.lineage like ".quote($lineage.'%')." and asset.lineage<>".quote($lineage); 
		if (exists $rules->{endingLineageLength}) {
			$mod .= " and length(asset.lineage) <= ".($rules->{endingLineageLength}*6);
		}
		$mod .= ")";
		push(@whereModifiers,$mod);
	}
	# we need to include children
	if (isIn("children",@{$relatives})) {
		push(@whereModifiers,"(asset.parentId=".quote($self->getId).")");
	}
	# now lets add in all of the siblings in every level between ourself and the asset we wish to pedigree
	if (isIn("pedigree",@{$relatives}) && exists $rules->{assetToPedigree}) {
		my @mods;
		my $lineage = $rules->{assetToPedigree}->get("lineage");
		my $length = $rules->{assetToPedigree}->getLineageLength;
		for (my $i = $length; $i > 0; $i--) {
			my $line = substr($lineage,0,$i*6);
			push(@mods,"( asset.lineage like ".quote($line.'%')." and  length(asset.lineage)=".(($i+1)*6).")");
			last if ($self->getLineageLength == $i);
		}
		push(@whereModifiers, "(".join(" or ",@mods).")") if (scalar(@mods));
	}
	# formulate a where clause
	my $where = "state='published'";
	$where = "state in (".quoteAndJoin($rules->{statesToInclude}).")" if (exists $rules->{statesToInclude});
	if (exists $rules->{excludeClasses}) { # deal with exclusions
		my @set;
		foreach my $className (@{$rules->{excludeClasses}}) {
			push(@set,"asset.className not like ".quote($className.'%'));
		}
		$where .= ' and ('.join(" and ",@set).')';
	}
	if (exists $rules->{includeOnlyClasses}) {
		$where .= ' and (asset.className in ('.quoteAndJoin($rules->{includeOnlyClasses}).'))';
	}
	$where .= " and ".join(" or ",@whereModifiers) if (scalar(@whereModifiers));
	my $tables = "asset ";
	if (exists $rules->{joinClass}) {
		my $className = $rules->{joinClass};
		my $cmd = "use ".$className;
		eval ($cmd);
		WebGUI::ErrorHandler::fatal("Couldn't compile asset package: ".$className.". Root cause: ".$@) if ($@);
		foreach my $definition (@{$className->definition}) {
			unless ($definition->{tableName} eq "asset") {
				my $tableName = $definition->{tableName};
				$tables .= ", $tableName ";
				$where .= " and (asset.assetId = $tableName.assetId) "; 
			}
			last;
		}
	}
	if (exists $rules->{whereClause}) {
		$where .= ' and ('.$rules->{whereClause}.')';
	}
	# based upon all available criteria, let's get some assets
	my $columns = "asset.assetId, asset.className, asset.parentId";
	my $slavedb;
	if ($rules->{returnQuickReadObjects}) {
		$columns = "*";
		$slavedb = WebGUI::SQL->getSlave;
	}
	my $sortOrder = ($rules->{invertTree}) ? "desc" : "asc"; 
	my $sql = "select $columns from $tables where $where order by lineage $sortOrder";
	my @lineage;
	my %relativeCache;
	my $sth = WebGUI::SQL->read($sql, $slavedb);
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

=head2 getMenuTitle ( )

Returns the menu title of this asset. If it's not specified or it's "Untitled" then the asset's name will be returned instead.

=cut

sub getMenuTitle {
	my $self = shift;
	if ($self->get("menuTitle") eq "" || lc($self->get("menuTitle")) eq "untitled") {
		return $self->getName;
	} 
	return $self->get("menuTitle");
}


#-------------------------------------------------------------------

=head2 getMetaDataFields ( [fieldId] )

Returns a hash reference containing all metadata field properties.  You can limit the output to a certain field by specifying a fieldId.

=head3 fieldId

If specified, the hashRef will contain only this field.

=cut

sub getMetaDataFields {
	my $self = shift;
	my $fieldId = shift;
	my $sql = "select
		 	f.fieldId, 
			f.fieldName, 
			f.description, 
			f.defaultValue,
			f.fieldType,
			f.possibleValues,
			d.value
		from metaData_properties f
		left join metaData_values d on f.fieldId=d.fieldId and d.assetId=".quote($self->getId);
	$sql .= " where f.fieldId = ".quote($fieldId) if ($fieldId);
	$sql .= " order by f.fieldName";
	if ($fieldId) {
		return WebGUI::SQL->quickHashRef($sql);	
	} else {
		tie my %hash, 'Tie::IxHash';
		my $sth = WebGUI::SQL->read($sql);
	        while( my $h = $sth->hashRef) {
			foreach(keys %$h) {
				$hash{$h->{fieldId}}{$_} = $h->{$_};
			}
		}
       	 	$sth->finish;
        	return \%hash;
	}
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

=head2 getPackageList ( )

Returns an array of hashes containing title, assetId, and className for all assets defined as packages.

=cut

sub getPackageList {
	my $self = shift;
	my @assets;
	my $sth = WebGUI::SQL->read("select assetId, title, className from asset where isPackage=1 order by lastUpdated desc");
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

=head2 getParent ( )

Returns an asset hash of the parent of current Asset.

=cut

sub getParent {
	my $self = shift;
	return $self if ($self->get("assetId") eq "PBasset000000000000001");
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
	$lineage =~ m/(.{6})$/;
	my $rank = $1 - 0; # gets rid of preceeding 0s.
	return $rank;
}

#-------------------------------------------------------------------

=head2 getRoot ()

Returns the root asset object.

=cut

sub getRoot {
	return WebGUI::Asset->new("PBasset000000000000001");
}


#-------------------------------------------------------------------

=head2 getTitle ( )

Returns the title of this asset. If it's not specified or it's "Untitled" then the asset's name will be returned instead.

=cut

sub getTitle {
	my $self = shift;
	if ($self->get("title") eq "" || lc($self->get("title")) eq "untitled") {
		return $self->getName;
	} 
	return $self->get("title");
}


#-------------------------------------------------------------------

=head2 getToolbar ( )

Returns a toolbar with a set of icons that hyperlink to functions that delete, edit, promote, demote, cut, and copy.

=cut

sub getToolbar {
	my $self = shift;
	my $toolbar = deleteIcon('func=delete',$self->get("url"),WebGUI::International::get(43,"Asset"))
              	.editIcon('func=edit',$self->get("url"))
             	.moveUpIcon('func=promote',$self->get("url"))
             	.moveDownIcon('func=demote',$self->get("url"))
            	.cutIcon('func=cut',$self->get("url"))
            	.copyIcon('func=copy',$self->get("url"));
        $toolbar .= shortcutIcon('func=createShortcut',$self->get("url")) unless ($self->get("className") =~ /Shortcut/);
	return '<img src="'.$self->getIcon(1).'" border="0" title="'.$self->getName.'" alt="'.$self->getName.'" align="absmiddle">'.$toolbar;
}

#-------------------------------------------------------------------

=head2 getToolbarState ( )

Returns 0 if the state is normal, and 1 if the toolbar state has been toggled. See toggleToolbar() for details.

=cut

sub getToolbarState {
	my $self = shift;
	return $self->{_toolbarState};
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
	my $url = $self->get("url");
	$url = WebGUI::URL::gateway($url,$params);
	if ($self->get("encryptPage")) {
		$url = WebGUI::URL::getSiteURL().$url;
		$url =~ s/http:/https:/;
	}
	return $url;
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
		return $session{form}{$key} if (exists $session{form}{$key});
		my $storedValue = $self->get($key);
		return $storedValue if (defined $storedValue);
		return $self->{_propertyDefinitions}{$key}{defaultValue};
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
			my $hasChildren = WebGUI::Cache->new("childCount_".$self->getId)->get;
			unless (defined $hasChildren) {
				($hasChildren) = WebGUI::SQL->quickArray("select count(*) from asset where parentId=".quote($self->getId));
				WebGUI::Cache->new("childCount_".$self->getId)->set($hasChildren);
			}
			$self->{_hasChildren} = $hasChildren;
		}
	}
	return $self->{_hasChildren};
}

#-------------------------------------------------------------------

=head2 new ( assetId||"new" [,overrideProperties] )

Constructor. This does not create an asset. Returns a new object if it can, otherwise returns undef.

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
	$properties = WebGUI::Cache->new("asset_".$assetId)->get unless($session{var}{adminOn});
	if ($assetId eq "new") {
		$properties = $overrideProperties;
		$properties->{assetId} = "new";
		$properties->{className} = $class;
	} elsif (exists $properties->{assetId}) {
		# got properties from cache
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
		WebGUI::Cache->new("asset_".$assetId)->set($properties,$properties->{cacheTimeout});
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

=head2 newByDynamicClass ( assetId [,className,overrideProperties] )

Returns a new Asset object based upon the className. Returns a "notFoundPage" Asset if className is not specified and can't be looked up.

=head3 assetId

Must be a valid assetId

=head3 className

String of class to use. Defaults to className of assetId, if it can be found in the asset table. 

=head3 overrideProperties

Any properties to set besides defaults.

=cut

sub newByDynamicClass {
	my $class = shift;
	my $assetId = shift;
	return undef unless defined $assetId;
	my $className = shift;
	my $overrideProperties = shift;
	unless (defined $className) {
		my $asset = WebGUI::Cache->new("asset_".$assetId)->get;
		if (exists $asset->{className}) {
			$className = $asset->{className};
		} else {
        		($className) = WebGUI::SQL->quickArray("select className from asset where assetId=".quote($assetId));
		}
	}
        if ($className eq "") {
        	WebGUI::HTTP::setStatus('404',"Page Not Found");
		WebGUI::ErrorHandler::fatal("The page not found page doesn't exist.") if ($assetId eq $session{setting}{notFoundPage});
                return WebGUI::Asset->newByDynamicClass($session{setting}{notFoundPage});
        }
	my $cmd = "use ".$className;
        eval ($cmd);
        WebGUI::ErrorHandler::fatal("Couldn't compile asset package: ".$className.". Root cause: ".$@) if ($@);
        my $assetObject = eval{$className->new($assetId,$overrideProperties)};
        WebGUI::ErrorHandler::fatal("Couldn't create asset instance for ".$assetId.". Root cause: ".$@) if ($@);
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
	my $asset = WebGUI::Cache->new("lineage_".$lineage)->get;
	unless (exists $asset->{assetId}) {
        	$asset = WebGUI::SQL->quickHashRef("select assetId, className from asset where lineage=".quote($lineage));
		WebGUI::Cache->new("lineage_".$lineage)->set($asset);
	}
	return WebGUI::Asset->newByDynamicClass($asset->{assetId}, $asset->{className});
}

#-------------------------------------------------------------------

=head2 newByPropertyHashRef ( properties )

Constructor. 

=head3 properties

A properties hash reference. The className of the properties hash must be valid.

=cut

sub newByPropertyHashRef {
	my $class = shift;
	my $properties = shift;
	return undef unless defined $properties;
	return undef unless exists $properties->{className};
	my $className = $properties->{className};
	my $cmd = "use ".$className;
        eval ($cmd);
        WebGUI::ErrorHandler::fatal("Couldn't compile asset package: ".$className.". Root cause: ".$@) if ($@);
	bless {_properties => $properties}, $className;
}

#-------------------------------------------------------------------

=head2 newByUrl ( [url] )

Returns a new Asset object based upon current url, given url or defaultPage.

=head3 url

Optional string representing a URL. 

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
		my $asset = WebGUI::Cache->new("asseturl_".$url)->get;
		unless (exists $asset->{assetId}) {
                	$asset = WebGUI::SQL->quickHashRef("select assetId, className from asset where url=".quote($url));
			WebGUI::Cache->new("asseturl_".$url)->set($asset,3600);
		}
		if ($asset->{assetId} ne "" || $asset->{className} ne "") {
			return WebGUI::Asset->newByDynamicClass($asset->{assetId}, $asset->{className});
		} else {
        		return $class->newByDynamicClass($session{setting}{notFoundPage});
		}
        }
        return $class->newByDynamicClass($session{setting}{defaultPage});
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
	my $pastedAsset = WebGUI::Asset->newByDynamicClass($assetId);	
	if ($self->getId eq $pastedAsset->get("parentId") || $pastedAsset->setParent($self)) {
		WebGUI::SQL->write("update asset set state='published', lastUpdatedBy=".quote($session{user}{userId}).", lastUpdated=".time()." where lineage like ".quote($self->get("lineage").'%')." and (state='clipboard' or state='clipboard-limbo')");
		$self->{_properties}{state} = "published";
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
			next if ($definition->{properties}{$property}{noFormPost});
			$data{$property} = WebGUI::FormProcessor::process(
				$property,
				$definition->{properties}{$property}{fieldType},
				$definition->{properties}{$property}{defaultValue}
				);
		}
	}
	$data{title} = "Untitled" unless ($data{title});
	$data{menuTitle} = $data{title} unless ($data{menuTitle});
	unless ($data{url}) {
		$data{url} = $self->getParent->get("url");
		$data{url} =~ s/(.*)\..*/$1/;
		$data{url} .= '/'.$data{menuTitle};
	}
	$self->update(\%data);
	foreach my $form (keys %{$session{form}}) {
		if ($form =~ /^metadata_(.*)$/) {
			my $fieldId = $1; 
			my ($exists) = WebGUI::SQL->quickArray("select count(*) from metaData_values
							where assetId = ".quote($self->getId)."
							and fieldId = ".quote($fieldId));
			if(! $exists && $session{form}{$form} ne "") {
				WebGUI::SQL->write("insert into metaData_values (fieldId, assetId)
							values (".quote($fieldId).",".quote($self->getId).")");
			}
			if($session{form}{$form} eq "") {
				# Keep it clean
				WebGUI::SQL->write("delete from metaData_values where assetId = ".
							quote($self->getId)." and fieldId = ".quote($fieldId));
			} else {
				WebGUI::SQL->write("update metaData_values set value = ".quote($session{form}{$form})."
							where assetId = ".quote($self->getId)." and fieldId = ".
							quote($fieldId));
			}
		}
	}
}


#-------------------------------------------------------------------

=head2 processTemplate ( vars, templateId ) 

Returns the content generated from this template.

=head3 hashRef

A hash reference containing variables and loops to pass to the template engine.

=head3 templateId

An id referring to a particular template in the templates table. 

=cut

sub processTemplate {
	my $self = shift;
	my $var = shift;
	my $templateId = shift;
        my $meta = $self->getMetaDataFields() if ($session{setting}{metaDataEnabled});
        foreach my $field (keys %$meta) {
		$var->{$meta->{$field}{fieldName}} = $meta->{$field}{value};
	}
	$var->{'controls'} = $self->getToolbar;
	my %vars = (
		%{$self->{_properties}},
		%{$var}
		);
	my $template = WebGUI::Asset::Template->new($templateId);
	if (defined $template) {
		return $template->process(\%vars);
	} else {
		WebGUI::ErrorHandler::error("Can't instanciate template $templateId for asset ".$self->getId);
		return "Error: Can't instanciate template ".$templateId;
	}
}

#-------------------------------------------------------------------

=head2 promote ( )

Keeps the same rank of lineage, swaps with sister above. Returns 1 if there is a sister to swap. Otherwise returns 0.

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

=head2 publish ( )

Sets an asset and it's descendants to a state of 'published' regardless of it's current state.

=cut

sub publish {
	my $self = shift;
	WebGUI::SQL->write("update asset set state='published', lastUpdatedBy=".quote($session{user}{userId}).", lastUpdated=".time()." where lineage like ".quote($self->get("lineage").'%'));
	$self->{_properties}{state} = "published";
}

#-------------------------------------------------------------------

=head2 purge ( )

Returns 1. Deletes an asset from tables and removes anything bound to that asset.

=cut

sub purge {
	my $self = shift;
	WebGUI::Cache->new("asset_".$self->getId)->delete;
	$self->updateHistory("purged");
	WebGUI::SQL->beginTransaction;
	foreach my $definition (@{$self->definition}) {
		WebGUI::SQL->write("delete from ".$definition->{tableName}." where assetId=".quote($self->getId));
	}
	WebGUI::SQL->write("delete from metaData_values where assetId = ".quote($self->getId));
	WebGUI::SQL->commit;
	$self = undef;
	return 1;
}

#-------------------------------------------------------------------

=head2 purgeTree ( )

Returns 1. Purges self and all descendants.

=cut

sub purgeTree {
	my $self = shift;
	my $descendants = $self->getLineage(["self","descendants"],{returnObjects=>1, invertTree=>1, statesToInclude=>['trash','trash-limbo']});
	foreach my $descendant (@{$descendants}) {
		$descendant->purge;
	}
	return 1;
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
	return 0 unless (defined $newParent); # can't move it if a parent object doesn't exist
	return 0 if ($newParent->getId eq $self->get("parentId")); # don't move it to where it already is
	return 0 if ($newParent->getId eq $self->getId); # don't move it to itself
	if (defined $newParent) {
		my $oldLineage = $self->get("lineage");
		my $lineage = $newParent->get("lineage").$newParent->getNextChildRank; 
		return 0 if ($lineage =~ m/^$oldLineage/); # can't move it to its own child
		WebGUI::SQL->beginTransaction;
		WebGUI::SQL->write("update asset set parentId=".quote($newParent->getId).", lastUpdatedBy=".quote($session{user}{userId}).", lastUpdated=".time()." where assetId=".quote($self->getId));
		$self->cascadeLineage($lineage);
		WebGUI::SQL->commit;
		$self->updateHistory("moved to parent ".$newParent->getId);
		$self->{_properties}{lineage} = $lineage;
		return 1;
	}
	return 0;
}

#-------------------------------------------------------------------

=head2 setrank ( newRank )

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

#-------------------------------------------------------------------

=head2 setSize ( [extra] )

Updates the asset table with the size of the Asset.

=head3 extra

Optional numeric value to adjust the calculated asset size.

=cut

sub setSize {
	my $self = shift;
	my $extra = shift;
	my $sizetest;
	foreach my $key (keys %{$self->get}) {
		$sizetest .= $self->get($key);
	}
	WebGUI::SQL->write("update asset set assetSize=".(length($sizetest)+$extra).", lastUpdatedBy=".quote($session{user}{userId}).", lastUpdated=".time()." where assetId=".quote($self->getId));
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
	my $temp = substr(WebGUI::Id::generate(),0,6); # need a temp in order to do the swap
	WebGUI::SQL->beginTransaction;
	$self->cascadeLineage($temp,$first);
	$self->cascadeLineage($first,$second);
	$self->cascadeLineage($second,$temp);
	WebGUI::SQL->commit;
	$self->updateHistory("swapped lineage between ".$first." and ".$second);
	return 1;
}

#-------------------------------------------------------------------

=head2 trash ( )

Removes asset from lineage, places it in trash state. The "gap" in the lineage is changed in state to trash-limbo.

=cut

sub trash {
	my $self = shift;
	WebGUI::SQL->beginTransaction;
	WebGUI::SQL->write("update asset set state='trash-limbo', lastUpdatedBy=".quote($session{user}{userId}).", lastUpdated=".time()." where lineage like ".quote($self->get("lineage").'%'));
	WebGUI::SQL->write("update asset set state='trash', lastUpdatedBy=".quote($session{user}{userId}).", lastUpdated=".time()." where assetId=".quote($self->getId));
	WebGUI::SQL->commit;
	$self->{_properties}{state} = "trash";
	$self->updateHistory("trashed");
}

#-------------------------------------------------------------------

=head2 toggleToolbar ( ) 

Toggles a toolbar to a special state so that custom toolbars can be rendered under special circumstances. This is mostly useful for macros that wish to proxy an asset but not display the toolbar.

=cut

sub toggleToolbar {
	my $self = shift;
	if ($self->{_toolbarState}) {
		$self->{_toolbarState} = 0;
	} else {
		$self->{_toolbarState} = 1;
	}
}

#-------------------------------------------------------------------

=head2 update ( properties )

Returns 1. Updates properties of an Asset to given or default values.

=head3 properties

Hash reference of properties and values to set.

=cut

sub update {
        my $self = shift;
        my $properties = shift;
	WebGUI::Cache->new("asset_".$self->getId)->delete;
        WebGUI::SQL->beginTransaction;
        foreach my $definition (@{$self->definition}) {
                my @setPairs;
                if ($definition->{tableName} eq "asset") {
                        push(@setPairs,"lastUpdated=".time());
                        push(@setPairs,"lastUpdatedBy=".quote($session{user}{userId}));
                }
                foreach my $property (keys %{$definition->{properties}}) {
                        next unless (exists $properties->{$property});
                        my $value = $properties->{$property};
                        if (exists $definition->{properties}{$property}{filter}) {
                                my $filter = $definition->{properties}{$property}{filter};
                                $value = $self->$filter($value);
                        }
                        $self->{_properties}{$property} = $value;
                        push(@setPairs, $property."=".quote($value));
                }
                if (scalar(@setPairs) > 0) {
                        WebGUI::SQL->write("update ".$definition->{tableName}." set ".join(",",@setPairs)." where assetId=".quote($self->getId));
        		$self->setSize;
                }
        }
        WebGUI::SQL->commit;
        return 1;
}

#-------------------------------------------------------------------

=head2 updateHistory ( action [,userId] )

Updates the assetHistory table with the asset, user, action, and timestamp.

=head3 action

String representing type of action taken on an Asset.

=head3 userId

If not specified, current user is used.

=cut

sub updateHistory {
	my $self = shift;
	my $action = shift;
	my $userId = shift || $session{user}{userId} || '3';
	my $dateStamp = time();
	WebGUI::SQL->beginTransaction;
	WebGUI::SQL->write("insert into assetHistory (assetId, userId, actionTaken, dateStamp) values (
		".quote($self->getId).", ".quote($userId).", ".quote($action).", ".$dateStamp.")");
	WebGUI::SQL->write("update asset set lastUpdated=".$dateStamp.", lastUpdatedBy=".quote($userId)." where assetId=".quote($self->getId));
	WebGUI::SQL->commit;
}

#-------------------------------------------------------------------

=head2 view ( )

Returns "".

=cut

sub view {
	my $self = shift;
	if ($session{var}{adminOn}) {
		return $self->getToolbar;
	}
	return undef;
}

#-------------------------------------------------------------------

=head2 www_add ( )

Adds a new Asset based upon the class of the current form. Returns the Asset calling method www_edit();

=cut

sub www_add {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless ($self->canAdd);
	my %prototypeProperties; 
	if ($session{form}{'prototype'}) {
		my $prototype = WebGUI::Asset->newByDynamicClass($session{form}{'prototype'},$session{form}{class});
		foreach my $definition (@{$prototype->definition}) { # cycle through rather than copying properties to avoid grabbing stuff we shouldn't grab
			foreach my $property (keys %{$definition->{properties}}) {
				next if (isIn($property,qw(title menuTitle url isPrototype isPackage)));
				next if ($definition->{properties}{$property}{noFormPost});
				$prototypeProperties{$property} = $prototype->get($property);
			}
		}
		
	}
	my %properties = (
		%prototypeProperties,
		groupIdView => $self->get("groupIdView"),
		groupIdEdit => $self->get("groupIdEdit"),
		ownerUserId => $self->get("ownerUserId"),
		encryptPage => $self->get("encryptPage"),
		styleTemplateId => $self->get("styleTemplateId"),
		printableStyleTemplateId => $self->get("printableStyleTemplateId"),
		isHidden => $self->get("isHidden"),
		startDate => $self->get("startDate"),
		endDate => $self->get("endDate")
		);
	$properties{isHidden} = 1 unless (WebGUI::Utility::isIn($session{form}{class}, @{$session{config}{assetContainers}}));
	my $newAsset = WebGUI::Asset->newByDynamicClass("new",$session{form}{class},\%properties);
	$newAsset->{_parent} = $self;
	return $newAsset->www_edit();
}

#-------------------------------------------------------------------

=head2 www_copy ( )

Duplicates self, cuts duplicate, returns self->getContainer->www_view if canEdit. Otherwise returns an AdminConsole rendered as insufficient privilege.

=cut

sub www_copy {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
	my $newAsset = $self->duplicate;
	$newAsset->update({ title=>$newAsset->getTitle.' (copy)'});
	$newAsset->cut;
	return $self->getContainer->www_view;
}

#-------------------------------------------------------------------

=head2 www_copyList ( )

Copies to clipboard assets in a list, then returns self calling method www_manageAssets(), if canEdit. Otherwise returns AdminConsole rendered insufficient privilege.

=cut

sub www_copyList {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
	foreach my $assetId ($session{cgi}->param("assetId")) {
		my $asset = WebGUI::Asset->newByDynamicClass($assetId);
		if ($asset->canEdit) {
			my $newAsset = $asset->duplicate;
			$newAsset->update({ title=>$newAsset->getTitle.' (copy)'});
			$newAsset->cut;
		}
	}
	return $self->www_manageAssets();
}

#-------------------------------------------------------------------

=head2 www_createShortcut ()

=cut

sub www_createShortcut () {
	my $self = shift;
	my $child = $self->addChild({
		className=>'WebGUI::Asset::Shortcut',
		shortcutToAssetId=>$self->getId,
		title=>$self->getTitle,
		menuTitle=>$self->getMenuTitle,
		isHidden=>$self->get("isHidden"),
		newWindow=>$self->get("newWindow"),
		startDate=>$self->get("startDate"),
		endDate=>$self->get("endDate"),
		ownerUserId=>$self->get("ownerUserId"),
		groupIdEdit=>$self->get("groupIdEdit"),
		groupIdView=>$self->get("groupIdView"),
		url=>$self->get("title"),
		templateId=>'PBtmpl0000000000000140'
		});
	$child->cut;
	return $self->getContainer->www_view;
}

#-------------------------------------------------------------------

=head2 www_cut ( )

Cuts (removes to clipboard) self, returns the www_view of the Parent if canEdit. Otherwise returns AdminConsole rendered insufficient privilege.

=cut

sub www_cut {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
	$self->cut;
	$session{asset} = $self->getParent;
	return $self->getParent->www_view;
}

#-------------------------------------------------------------------

=head2 www_cutList ( )

Cuts assets in a list (removes to clipboard), then returns self calling method www_manageAssets(), if canEdit. Otherwise returns AdminConsole rendered insufficient privilege.

=cut

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
	foreach my $assetId ($session{cgi}->param("assetId")) {
		my $asset = WebGUI::Asset->newByDynamicClass($assetId);
		if ($asset->canEdit) {
			$asset->trash;
		}
	}
	return $self->www_manageAssets();
}

#-------------------------------------------------------------------

=head2 www_deleteMetaDataField ( )

Deletes a MetaDataField and returns www_manageMetaData on self, if user isInGroup(4), if not, renders a "content profiling" AdminConsole as insufficient privilege. 

=cut

sub www_deleteMetaDataField {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless (WebGUI::Grouping::isInGroup(4));
	$self->deleteMetaDataField($session{form}{fid});
	return $self->www_manageMetaData;
}

#-------------------------------------------------------------------

=head2 www_demote ( )

Demotes self and returns www_view method of getContainer of self if canEdit, otherwise renders an AdminConsole as insufficient privilege.

=cut

sub www_demote {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
	$self->demote;
	return $self->getContainer->www_view; 
}

#-------------------------------------------------------------------

=head2 www_deployPackage ( ) 

Returns "". Deploys a Package. If canEdit is Fales, renders an insufficient Privilege page. 

=cut

sub www_deployPackage {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
	my $packageMasterAssetId = $session{form}{assetId};
	if (defined $packageMasterAssetId) {
		my $packageMasterAsset = WebGUI::Asset->newByDynamicClass($packageMasterAssetId);
		my $masterLineage = $packageMasterAsset->get("lineage");
                if (defined $packageMasterAsset && $packageMasterAsset->canView && $self->get("lineage") !~ /^$masterLineage/) {
			my $deployedTreeMaster = $self->duplicateTree($packageMasterAsset);
			$deployedTreeMaster->update({isPackage=>0});
		}
	}
	return "";
}



#-------------------------------------------------------------------

=head2 www_edit ( )

Renders an AdminConsole EditForm, unless canEdit returns False.

=cut

sub www_edit {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
	return $self->getAdminConsole->render($self->getEditForm->print);
}

#-------------------------------------------------------------------

=head2 www_editSave ( )

Saves and updates history. If canEdit, returns www_manageAssets() if a new Asset is created, otherwise returns www_view().  Will return an insufficient Privilege if canEdit returns False.

=cut

sub www_editSave {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
	my $object;
	if ($session{form}{assetId} eq "new") {
		$object = $self->addChild({className=>$session{form}{class}});	
		$object->{_parent} = $self;
	} else {
		$object = $self;
	}
	$object->processPropertiesFromFormPost;
	$object->updateHistory("edited");
	if ($session{form}{proceed} eq "manageAssets") {
		$session{asset} = $object->getParent;
		return $object->getParent->www_manageAssets;
	}
	if ($session{form}{proceed} ne "") {
		my $method = "www_".$session{form}{proceed};
		$session{asset} = $object;
		return $object->$method();
	}
	$session{asset} = $object->getContainer;
	return $self->getContainer->www_view;
}

#-------------------------------------------------------------------

=head2 www_editMetaDataField ( )

Returns a rendered page to edit MetaData.  Will return an insufficient Privilege if not InGroup(4).

=cut

sub www_editMetaDataField {
	my $self = shift;
	my $ac = WebGUI::AdminConsole->new("contentProfiling");
	return WebGUI::Privilege::insufficient() unless (WebGUI::Grouping::isInGroup(4));
        my $fieldInfo;
	if($session{form}{fid} && $session{form}{fid} ne "new") {
		$fieldInfo = $self->getMetaDataFields($session{form}{fid});
	}
	my $fid = $session{form}{fid} || "new";
        my $f = WebGUI::HTMLForm->new(-action=>$self->getUrl);
        $f->hidden("func", "editMetaDataFieldSave");
        $f->hidden("fid", $fid);
        $f->readOnly(
                -value=>$fid,
                -label=>WebGUI::International::get('Field Id','Asset'),
                );
        $f->text("fieldName", WebGUI::International::get('Field name','Asset'), $fieldInfo->{fieldName});
	$f->textarea("description", WebGUI::International::get(85,"Asset"), $fieldInfo->{description});
        $f->fieldType(
                -name=>"fieldType",
                -label=>WebGUI::International::get(486,"Asset"),
                -value=>[$fieldInfo->{fieldType} || "text"],
		-types=> [ qw /text integer yesNo selectList radioList/ ]
                );
	$f->textarea("possibleValues",WebGUI::International::get(487,"Asset"),$fieldInfo->{possibleValues});
        $f->submit();
	$ac->setHelp("metadata edit property","Asset");
	return $ac->render($f->print, WebGUI::International::get('Edit Metadata',"Asset"));
}

#-------------------------------------------------------------------

=head2 www_editMetaDataFieldSave ( )

Verifies that MetaData fields aren't duplicated or blank, assigns default values, and returns the www_manageMetaData() method. Will return an insufficient Privilege if not InGroup(4).

=cut

sub www_editMetaDataFieldSave {
	my $self = shift;
	my $ac = WebGUI::AdminConsole->new("content profiling");
	return WebGUI::Privilege::insufficient() unless (WebGUI::Grouping::isInGroup(4));
	$ac->setHelp("metadata edit property","Asset");
	# Check for duplicate field names
	my $sql = "select count(*) from metaData_properties where fieldName = ".
                                quote($session{form}{fieldName});
	if ($session{form}{fid} ne "new") {
		$sql .= " and fieldId <> ".quote($session{form}{fid});
	}
	my ($isDuplicate) = WebGUI::SQL->buildArray($sql);
	if($isDuplicate) {
		my $error = WebGUI::International::get("duplicateField", "Asset");
		$error =~ s/\%field\%/$session{form}{fieldName}/;
		return $ac->render($error,WebGUI::International::get('Edit Metadata',"Asset"));
	}
	if($session{form}{fieldName} eq "") {
		return $ac->render(WebGUI::International::get("errorEmptyField", "Asset"),WebGUI::International::get('Edit Metadata',"Asset"));
	}
	if($session{form}{fid} eq 'new') {
		$session{form}{fid} = WebGUI::Id::generate();
		WebGUI::SQL->write("insert into metaData_properties (fieldId, fieldName, defaultValue, description, fieldType, possibleValues) values (".
					quote($session{form}{fid}).",".
					quote($session{form}{fieldName}).",".
					quote($session{form}{defaultValue}).",".
					quote($session{form}{description}).",".
					quote($session{form}{fieldType}).",".
					quote($session{form}{possibleValues}).")");
	} else {
                WebGUI::SQL->write("update metaData_properties set fieldName = ".quote($session{form}{fieldName}).", ".
					"defaultValue = ".quote($session{form}{defaultValue}).", ".
					"description = ".quote($session{form}{description}).", ".
					"fieldType = ".quote($session{form}{fieldType}).", ".
					"possibleValues = ".quote($session{form}{possibleValues}).
					" where fieldId = ".quote($session{form}{fid}));
	}

	return $self->www_manageMetaData; 
}



#-------------------------------------------------------------------

=head2 www_editTree ( )

Creates a tabform to edit the Asset Tree. If canEdit returns False, returns insufficient Privilege page. 

=cut

sub www_editTree {
	my $self = shift;
	my $ac = WebGUI::AdminConsole->new("assets");
	return WebGUI::Privilege::insufficient() unless ($self->canEdit);
	my $tabform = WebGUI::TabForm->new;
	$tabform->hidden({name=>"func",value=>"editTreeSave"});
	$tabform->addTab("properties",WebGUI::International::get("properties","Asset"),9);
        $tabform->getTab("properties")->readOnly(
                -label=>WebGUI::International::get(104,"Asset"),
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
					menuTitle=>WebGUI::International::get(411,"Asset"),
					title=>WebGUI::International::get(99,"Asset"),
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
	$tabform->addTab("display",WebGUI::International::get(105,"Asset"),5);
	$tabform->getTab("display")->yesNo(
                -name=>"isHidden",
                -value=>$self->get("isHidden"),
                -label=>WebGUI::International::get(886,"Asset"),
                -uiLevel=>6,
		-subtext=>'<br />'.WebGUI::International::get("change","Asset").' '.WebGUI::Form::yesNo({name=>"change_isHidden"})
                );
        $tabform->getTab("display")->yesNo(
                -name=>"newWindow",
                -value=>$self->get("newWindow"),
                -label=>WebGUI::International::get(940,"Asset"),
                -uiLevel=>6,
		-subtext=>'<br />'.WebGUI::International::get("change","Asset").' '.WebGUI::Form::yesNo({name=>"change_newWindow"})
                );
	$tabform->getTab("display")->yesNo(
                -name=>"displayTitle",
                -label=>WebGUI::International::get(174,"Asset"),
                -value=>$self->getValue("displayTitle"),
                -uiLevel=>5,
		-subtext=>'<br />'.WebGUI::International::get("change","Asset").' '.WebGUI::Form::yesNo({name=>"change_displayTitle"})
                );
         $tabform->getTab("display")->template(
		-name=>"styleTemplateId",
		-label=>WebGUI::International::get(1073,"Asset"),
		-value=>$self->getValue("styleTemplateId"),
		-namespace=>'style',
		-afterEdit=>'op=editPage&amp;npp='.$session{form}{npp},
		-subtext=>'<br />'.WebGUI::International::get("change","Asset").' '.WebGUI::Form::yesNo({name=>"change_styleTemplateId"})
		);
         $tabform->getTab("display")->template(
		-name=>"printableStyleTemplateId",
		-label=>WebGUI::International::get(1079,"Asset"),
		-value=>$self->getValue("printableStyleTemplateId"),
		-namespace=>'style',
		-afterEdit=>'op=editPage&amp;npp='.$session{form}{npp},
		-subtext=>'<br />'.WebGUI::International::get("change","Asset").' '.WebGUI::Form::yesNo({name=>"change_printableStyleTemplateId"})
		);
        $tabform->getTab("display")->interval(
                -name=>"cacheTimeout",
                -label=>WebGUI::International::get(895,"Asset"),
                -value=>$self->getValue("cacheTimeout"),
                -uiLevel=>8,
		-subtext=>'<br />'.WebGUI::International::get("change","Asset").' '.WebGUI::Form::yesNo({name=>"change_cacheTimeout"})
                );
        $tabform->getTab("display")->interval(
                -name=>"cacheTimeoutVisitor",
                -label=>WebGUI::International::get(896,"Asset"),
                -value=>$self->getValue("cacheTimeoutVisitor"),
                -uiLevel=>8,
		-subtext=>'<br />'.WebGUI::International::get("change","Asset").' '.WebGUI::Form::yesNo({name=>"change_cacheTimeoutVisitor"})
                );
	$tabform->addTab("security",WebGUI::International::get(107,"Asset"),6);
        $tabform->getTab("security")->yesNo(
                -name=>"encryptPage",
                -value=>$self->get("encryptPage"),
                -label=>WebGUI::International::get('encrypt page',"Asset"),
                -uiLevel=>6,
		-subtext=>'<br />'.WebGUI::International::get("change","Asset").' '.WebGUI::Form::yesNo({name=>"change_encryptPage"})
                );
	$tabform->getTab("security")->dateTime(
                -name=>"startDate",
                -label=>WebGUI::International::get(497,"Asset"),
                -value=>$self->get("startDate"),
                -uiLevel=>6,
		-subtext=>'<br />'.WebGUI::International::get("change","Asset").' '.WebGUI::Form::yesNo({name=>"change_startDate"})
                );
        $tabform->getTab("security")->dateTime(
                -name=>"endDate",
                -label=>WebGUI::International::get(498,"Asset"),
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
               -label=>WebGUI::International::get(108,"Asset"),
               -value=>[$self->get("ownerUserId")],
               -subtext=>$subtext,
               -uiLevel=>6,
		-subtext=>'<br />'.WebGUI::International::get("change","Asset").' '.WebGUI::Form::yesNo({name=>"change_ownerUserId"})
               );
        $tabform->getTab("security")->group(
               -name=>"groupIdView",
               -label=>WebGUI::International::get(872,"Asset"),
               -value=>[$self->get("groupIdView")],
               -uiLevel=>6,
		-subtext=>'<br />'.WebGUI::International::get("change","Asset").' '.WebGUI::Form::yesNo({name=>"change_groupIdView"})
               );
        $tabform->getTab("security")->group(
               -name=>"groupIdEdit",
               -label=>WebGUI::International::get(871,"Asset"),
               -value=>[$self->get("groupIdEdit")],
               -excludeGroups=>[1,7],
               -uiLevel=>6,
		-subtext=>'<br />'.WebGUI::International::get("change","Asset").' '.WebGUI::Form::yesNo({name=>"change_groupIdEdit"})
		);
	return $ac->render($tabform->print, "Edit Branch");
}

#-------------------------------------------------------------------

=head2 www_editTreeSave ( )

Verifies proper inputs in the Asset Tree and saves them. Returns ManageAssets method. If canEdit returns False, returns an insufficient privilege page.

=cut

sub www_editTreeSave {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless ($self->canEdit);
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
		$urlBaseBy = WebGUI::FormProcessor::selectList("baseUrlBy");
		$urlBase = WebGUI::FormProcessor::text("baseUrl");
		$endOfUrl = WebGUI::FormProcessor::selectList("endOfUrl");
	}
	my $descendants = $self->getLineage(["self","descendants"],{returnObjects=>1});	
	foreach my $descendant (@{$descendants}) {
		my $url;
		if ($changeUrl) {
			if ($urlBaseBy eq "parentUrl") {
				delete $descendant->{_parent};
				$data{url} = $descendant->getParent->get("url")."/";
			} elsif ($urlBaseBy eq "specifiedBase") {
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
	delete $self->{_parent};
	$session{asset} = $self->getParent;
	return $self->getParent->www_manageAssets;
}

#-------------------------------------------------------------------

=head2 www_emptyClipboard ( )

Moves assets in clipboard to trash. Returns www_manageClipboard() when finished. If isInGroup(4) returns False, insufficient privilege is rendered.

=cut

sub www_emptyClipboard {
	my $self = shift;
	my $ac = WebGUI::AdminConsole->new("clipboard");
	return WebGUI::Privilege::insufficient() unless (WebGUI::Grouping::isInGroup(4));
	foreach my $assetData (@{$self->getAssetsInClipboard(!($session{form}{systemClipboard} && WebGUI::Grouping::isInGroup(3)))}) {
		my $asset = WebGUI::Asset->newByDynamicClass($assetData->{assetId},$assetData->{className});
		$asset->trash;
	}
	return $self->www_manageClipboard();
}

#-------------------------------------------------------------------

=head2 www_emptyTrash ( )

Calls the purgeTree() method to delete all items in Trash. Returns the www_manageTrash() method. If isInGroup(4) returns false, renders insufficient privilege page.

=cut

sub www_emptyTrash {
	my $self = shift;
	my $ac = WebGUI::AdminConsole->new("trash");
	return WebGUI::Privilege::insufficient() unless (WebGUI::Grouping::isInGroup(4));
	foreach my $assetData (@{$self->getAssetsInTrash(!($session{form}{systemTrash} && WebGUI::Grouping::isInGroup(3)))}) {
		my $asset = WebGUI::Asset->newByDynamicClass($assetData->{assetId},$assetData->{className});
		$asset->purgeTree;
	}
	return $self->www_manageTrash();
}

#-------------------------------------------------------------------

=head2 www_export

Displays the export page administrative interface

=cut

sub www_export {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless (WebGUI::Grouping::isInGroup(13));
        $self->getAdminConsole->setHelp("page export");
        my $f = WebGUI::HTMLForm->new(-action=>$self->getUrl);
        $f->hidden("func","exportStatus");
	$f->integer(
			-label=>WebGUI::International::get('Depth',"Asset"),
			-name=>"depth",
			-value=>99,
		);
	$f->selectList(
			-label=>WebGUI::International::get('Export as user',"Asset"),
			-name=>"userId",
			-options=>WebGUI::SQL->buildHashRef("select userId, username from users"),
			-value=>[1],
		);
	$f->text(
			-label=>"Directory Index",
			-name=>"index",
			-value=>"index.html"
		);
	$f->text(
			-label=>WebGUI::International::get('Extras URL',"Asset"),
			-name=>"extrasURL",
			-value=>$session{config}{extrasURL}
		);
	$f->text(
                        -label=>WebGUI::International::get('Uploads URL',"Asset"),
                        -name=>"uploadsURL",
                        -value=>$session{config}{uploadsURL}
                );
        $f->submit;
        $self->getAdminConsole->render($self->checkExportPath.$f->print,WebGUI::International::get('Export Page'),"Asset");
}


#-------------------------------------------------------------------

=head2 www_exportStatus

Displays the export status page

=cut

sub www_exportStatus {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless (WebGUI::Grouping::isInGroup(13));
	my $iframeUrl = $self->getUrl('func=exportGenerate');
	$iframeUrl = WebGUI::URL::append($iframeUrl, 'index='.$session{form}{index});
	$iframeUrl = WebGUI::URL::append($iframeUrl, 'depth='.$session{form}{depth});
	$iframeUrl = WebGUI::URL::append($iframeUrl, 'userId='.$session{form}{userId});
	$iframeUrl = WebGUI::URL::append($iframeUrl, 'extrasURL='.$session{form}{extrasURL});
	$iframeUrl = WebGUI::URL::append($iframeUrl, 'uploadsURL='.$session{form}{uploadsURL});
	my $output = '<IFRAME SRC="'.$iframeUrl.'" TITLE="'.WebGUI::International::get('Page Export Status',"Asset").'" WIDTH="410" HEIGHT="200"></IFRAME>';
        $self->getAdminConsole->render($output,WebGUI::International::get('Page Export Status'),"Asset");
}

#-------------------------------------------------------------------

=head2 www_exportPageGenerate

Executes the export process and displays real time status. This operation is displayed by exportPageStatus in an IFRAME.

=cut

sub www_exportGenerate {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless (WebGUI::Grouping::isInGroup(13));
	# This routine is called in an IFRAME and prints status output directly to the browser.
	$|++;				# Unbuffered data output
        $session{page}{empty} = 1;      # Write directly to the browser
	print WebGUI::HTTP::getHeader();
	my $startTime = time();	
	my $error = $self->checkExportPath();
	if ($error) {
		print $error;
		return;
	}
	my $userId = $session{form}{userId};
	my $extrasURL = $session{form}{extrasURL};
	my $uploadsURL = $session{form}{uploadsURL};
	my $index = $session{form}{index};
	my $assets = $self->getLineage(["self","descendants"],{returnObjects=>1,endingLineageLength=>$self->getLineageLength+$session{form}{depth}});
	foreach my $asset (@{$assets}) {
		my $url = $asset->get("url");
		print "Exporting page ".$url."......";
		unless ($asset->canView($userId)) {
			print "User has no privileges to view.<br />\n";
			next;
		}
		my $path;
		my $filename;
		if ($url =~ /\./) {
			$url =~ /^(.*)\/(.*)$/;
			$path = $1;
			$filename = $2;
			if ($filename eq "") {
				$filename = $path;
				$path = undef;
			}
		} else {
			$path = $url;
			$filename = $index;
		}
		if($path) {
			$path = $session{config}{exportPath} . $session{os}{slash} . $path;
			eval { mkpath($path) };
			if($@) {
				print "Couldn't create $path because $@ <br />\n";
				print "This most likely means that you have a page with the same name as folder that you're trying to create.<br />\n";
				return;
			}
		} 
		$path .= $session{os}{slash}.$filename;
                eval { open(FILE, "> $path") or die "$!" };
		if ($@) {
			print "Couldn't open $path because $@ <br />\n";
			return;
		} else {
			print FILE $self->exportAsHtml({userId=>$userId,extrasUrl=>$extrasURL,uploadsUrl=>$uploadsURL});
			close(FILE);
		}
		print "DONE<br />";
	}
	print "<p>Exported ".scalar(@{$assets})." pages in ".(time()-$startTime)." seconds.</p>";
	print '<a target="_parent" href="'.$self->getUrl.'">'.WebGUI::International::get(493,"Asset").'</a>';
	return;
}


#-------------------------------------------------------------------

=head2 www_manageAssets ( )

Main page to manage assets. Renders an AdminConsole with a list of assets. If canEdit returns False, renders an insufficient privilege page.

=cut

sub www_manageAssets {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
	my $children = $self->getLineage(["children"],{returnObjects=>1});
	my $output = $self->getAssetManagerControl($children);
	$output .= ' <div class="adminConsoleSpacer">
            &nbsp;
        </div>
		<div style="float: left; padding-right: 30px; font-size: 14px;"><fieldset><legend>'.WebGUI::International::get(1083,"Asset").'</legend>';
	foreach my $link (@{$self->getAssetAdderLinks("proceed=manageAssets","assetContainers")}) {
		$output .= '<img src="'.$link->{'icon.small'}.'" align="middle" alt="'.$link->{label}.'" border="0" /> 
			<a href="'.$link->{url}.'">'.$link->{label}.'</a> ';
		$output .= editIcon("func=edit&proceed=manageAssets",$link->{asset}->get("url")) if ($link->{isPrototype});
		$output .= '<br />';
	}
	$output .= '<hr />';
	foreach my $link (@{$self->getAssetAdderLinks("proceed=manageAssets")}) {
		$output .= '<img src="'.$link->{'icon.small'}.'" align="middle" alt="'.$link->{label}.'" border="0" /> 
			<a href="'.$link->{url}.'">'.$link->{label}.'</a> ';
		$output .= editIcon("func=edit&proceed=manageAssets",$link->{asset}->get("url")) if ($link->{isPrototype});
		$output .= '<br />';
	}
	$output .= '<hr />';
	foreach my $link (@{$self->getAssetAdderLinks("proceed=manageAssets","utilityAssets")}) {
		$output .= '<img src="'.$link->{'icon.small'}.'" align="middle" alt="'.$link->{label}.'" border="0" /> 
			<a href="'.$link->{url}.'">'.$link->{label}.'</a> ';
		$output .= editIcon("func=edit&proceed=manageAssets",$link->{asset}->get("url")) if ($link->{isPrototype});
		$output .= '<br />';
	}
	$output .= '</fieldset></div>'; 
	my %options;
	tie %options, 'Tie::IxHash';
	my $hasClips = 0;
        foreach my $item (@{$self->getAssetsInClipboard(1)}) {
		my $asset = WebGUI::Asset->newByDynamicClass($item->{assetId},$item->{className});
              	$options{$item->{assetId}} = '<img src="'.$asset->getIcon(1).'" alt="'.$asset->getName.'" border="0" /> '.$item->{title};
		$hasClips = 1;
        }
	if ($hasClips) {
		$output .= '<div style="float: left; padding-right: 30px; font-size: 14px;"><fieldset><legend>'.WebGUI::International::get(1082,"Asset").'</legend>'
			.WebGUI::Form::formHeader()
			.WebGUI::Form::hidden({name=>"func",value=>"pasteList"})
			.WebGUI::Form::checkbox({extras=>'onchange="toggleClipboardSelectAll(this.form);"'})
			.' '.WebGUI::International::get("select all","Asset").'<br />'
			.WebGUI::Form::checkList({name=>"assetId",vertical=>1,options=>\%options})
			.'<br />'
			.WebGUI::Form::submit({value=>"Paste"})
			.WebGUI::Form::formFooter()
			.' </fieldset></div> '
			.'<script type="text/javascript">
			var clipboardItemSelectAllToggle = false;
			function toggleClipboardSelectAll(form){
			clipboardItemSelectAllToggle = clipboardItemSelectAllToggle ? false : true;
			for(var i = 0; i < form.assetId.length; i++)
			form.assetId[i].checked = clipboardItemSelectAllToggle;
			}
			</script>';
	}
	my $hasPackages = 0;
	my $packages;
        foreach my $item (@{$self->getPackageList}) {
		my $asset = WebGUI::Asset->newByDynamicClass($item->{assetId},$item->{className});
              	$packages  .= '<img src="'.$asset->getIcon(1).'" align="middle" alt="'.$asset->getName.'" border="0" /> 
			<a href="'.$self->getUrl("func=deployPackage&assetId=".$item->{assetId}).'">'.$item->{title}.'</a> '
			.editIcon("func=edit&proceed=manageAssets",$asset->get("url"))
			.'<br />';
		$hasPackages = 1;
        }
	if ($hasPackages) {
		$output .= '<div style="float: left; padding-right: 30px; font-size: 14px;"><fieldset>
			<legend>'.WebGUI::International::get("packages","Asset").'</legend>
			'.$packages.' </fieldset></div> ';
	}
	$output .= '
    <div class="adminConsoleSpacer">
            &nbsp;
        </div> 
		';
	return $self->getAdminConsole->render($output);
}

#-------------------------------------------------------------------

=head2 www_manageClipboard ( )

Returns an AdminConsole to deal with assets in the Clipboard. If isInGroup(12) is False, renders an insufficient privilege page.

=cut

sub www_manageClipboard {
	my $self = shift;
	my $ac = WebGUI::AdminConsole->new("clipboard");
	return WebGUI::Privilege::insufficient() unless (WebGUI::Grouping::isInGroup(12));
	my @assets;
	my ($header,$limit);
        $ac->setHelp("clipboard manage");
	if ($session{form}{systemClipboard} && WebGUI::Grouping::isInGroup(3)) {
		$header = WebGUI::International::get(966,"Asset");
		$ac->addSubmenuItem($self->getUrl('func=manageClipboard'), WebGUI::International::get(949),"Asset");
		$ac->addSubmenuItem($self->getUrl('func=emptyClipboard&systemClipboard=1'), WebGUI::International::get(959,"Asset"), 
			'onclick="return window.confirm(\''.WebGUI::International::get(951).'\')"',"Asset");
	} else {
		$ac->addSubmenuItem($self->getUrl('func=manageClipboard&systemClipboard=1'), WebGUI::International::get(954),"Asset");
		$ac->addSubmenuItem($self->getUrl('func=emptyClipboard'), WebGUI::International::get(950,"Asset"),
			'onclick="return window.confirm(\''.WebGUI::International::get(951).'\')"',"Asset");
		$limit = 1;
	}
	foreach my $assetData (@{$self->getAssetsInClipboard($limit)}) {
		push(@assets,WebGUI::Asset->newByDynamicClass($assetData->{assetId},$assetData->{className}));
	}
	return $ac->render($self->getAssetManagerControl(\@assets,"ManageClipboard"), $header);
}

#-------------------------------------------------------------------

=head2 www_manageMetaData ( )

Returns an AdminConsole to deal with MetaDataFields. If isInGroup(4) is False, renders an insufficient privilege page.

=cut

sub www_manageMetaData {
	my $self = shift;
	my $ac = WebGUI::AdminConsole->new("contentProfiling");
	return WebGUI::Privilege::insufficient() unless (WebGUI::Grouping::isInGroup(4));
	$ac->addSubmenuItem($self->getUrl('func=editMetaDataField'), WebGUI::International::get("Add new field","Asset"),"Asset");
	my $output;
	my $fields = $self->getMetaDataFields();
	foreach my $fieldId (keys %{$fields}) {
		$output .= deleteIcon("func=deleteMetaDataField&fid=".$fieldId,$self->getUrl,WebGUI::International::get('deleteConfirm','Asset'));
		$output .= editIcon("func=editMetaDataField&fid=".$fieldId,$self->getUrl);
		$output .= " <b>".$fields->{$fieldId}{fieldName}."</b><br>";
	}	
        $ac->setHelp("metadata manage","Asset");
	return $ac->render($output);
}

#-------------------------------------------------------------------

=head2 www_manageTrash ( )

Returns an AdminConsole to deal with assets in the Trash. If isInGroup(4) is False, renders an insufficient privilege page.

=cut

sub www_manageTrash {
	my $self = shift;
	my $ac = WebGUI::AdminConsole->new("trash");
	return WebGUI::Privilege::insufficient() unless (WebGUI::Grouping::isInGroup(4));
	my @assets;
	my ($header, $limit);
        $ac->setHelp("trash manage");
	if ($session{form}{systemTrash} && WebGUI::Grouping::isInGroup(3)) {
		$header = WebGUI::International::get(965,"Asset");
		$ac->addSubmenuItem($self->getUrl('func=manageTrash'), WebGUI::International::get(10),"Asset");
		$ac->addSubmenuItem($self->getUrl('func=emptyTrash&systemTrash=1'), WebGUI::International::get(967,"Asset"), 
			'onclick="return window.confirm(\''.WebGUI::International::get(651).'\')"',"Asset");
	} else {
		$ac->addSubmenuItem($self->getUrl('func=manageTrash&systemTrash=1'), WebGUI::International::get(964),"Asset");
		$ac->addSubmenuItem($self->getUrl('func=emptyTrash'), WebGUI::International::get(11,"Asset"),
			'onclick="return window.confirm(\''.WebGUI::International::get(651).'\')"',"Asset");
		$limit = 1;
	}
	foreach my $assetData (@{$self->getAssetsInTrash($limit)}) {
		push(@assets,WebGUI::Asset->newByDynamicClass($assetData->{assetId},$assetData->{className}));
	}
	return $ac->render($self->getAssetManagerControl(\@assets,"ManageTrash",1), $header);
}


#-------------------------------------------------------------------

=head2 www_paste ( )

Returns "". Pastes an asset. If canEdit is False, returns an insufficient privileges page.

=cut

sub www_paste {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
	$self->paste($session{form}{assetId});
	return "";
}

#-------------------------------------------------------------------

=head2 www_pasteList ( )

Returns a www_manageAssets() method. Pastes a selection of assets. If canEdit is False, returns an insufficient privileges page.

=cut

sub www_pasteList {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
	foreach my $clipId ($session{cgi}->param("assetId")) {
		$self->paste($clipId);
	}
	return $self->www_manageAssets();
}

#-------------------------------------------------------------------

=head2 www_promote ( )

Returns www_view method of getContainer of self. Promotes self. If canEdit is False, returns an insufficient privileges page.

=cut

sub www_promote {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
	$self->promote;
	return $self->getContainer->www_view;
}


#-------------------------------------------------------------------

=head2 www_purgeList ( )

Purges assets from "trash".  Returns the Manage Trash asset list.

=cut

sub www_purgeList {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
	foreach my $id ($session{cgi}->param("assetId")) {
		my $asset = WebGUI::Asset->newByDynamicClass($id);
		$asset->purge;
	}
	return $self->www_manageTrash();
}

#-------------------------------------------------------------------

=head2 www_restoreList ( )

Restores a piece of content from the trash back to it's original location.

=cut

sub www_restoreList {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
	foreach my $id ($session{cgi}->param("assetId")) {
		my $asset = WebGUI::Asset->newByDynamicClass($id);
		$asset->publish;
	}
	return $self->www_manageTrash();
}


#-------------------------------------------------------------------

=head2 www_setParent ( )

Returns a www_manageAssets() method. Sets a new parent via the results of a form. If canEdit is False, returns an insufficient privileges page.

=cut

sub www_setParent {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
	my $newParent = WebGUI::Asset->new($session{form}{assetId});
	$self->setParent($newParent) if (defined $newParent);
	return $self->www_manageAssets();

}

#-------------------------------------------------------------------

=head2 www_setRank ( )

Returns a www_manageAssets() method. Sets a new rank via the results of a form. If canEdit is False, returns an insufficient privileges page.

=cut

sub www_setRank {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
	my $newRank = $session{form}{rank};
	$self->setRank($newRank) if (defined $newRank);
	$session{asset} = $self->getParent;
	return $self->getParent->www_manageAssets();
}

#-------------------------------------------------------------------

=head2 www_view ( )

Returns "". If canView is False, returns WebGUI::Privilege::noAccess().

=cut

sub www_view {
	my $self = shift;
	return WebGUI::Privilege::noAccess() unless $self->canView;
	return $self->view;
}


1;

