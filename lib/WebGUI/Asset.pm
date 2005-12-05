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

use WebGUI::AssetBranch;
use WebGUI::AssetClipboard;
use WebGUI::AssetExportHtml;
use WebGUI::AssetLineage;
use WebGUI::AssetMetaData;
use WebGUI::AssetPackage;
use WebGUI::AssetTrash;
use WebGUI::AssetVersioning;
use strict;
use Tie::IxHash;
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

=head1 METHODS

These methods are available from this class:

=cut


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

=head2 definition ( [ definition ] )

Basic definition of an Asset. Properties, default values. Returns an array reference containing tableName,className,properties

=head3 definition

An array reference containing additional information to include with the default definition.

=cut

sub definition {
        my $class = shift;
        my $definition = shift || [];
        push(@{$definition}, {
		assetName=>WebGUI::International::get("asset","Asset"),
                tableName=>'assetData',
                className=>'WebGUI::Asset',
		icon=>'assets.gif',
                properties=>{
                                title=>{
                                        fieldType=>'text',
                                        defaultValue=>undef
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
					filter=>'fixUrl'
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
                                        fieldType=>'selectBox',
                                        defaultValue=>'3'
                                        },
                                startDate=>{
                                        fieldType=>'dateTime',
                                        defaultValue=>997995720
                                        },
                                endDate=>{
                                        fieldType=>'dateTime',
                                        defaultValue=>4294967294
                                        },
				status=>{
					noFormPost=>1,
					fieldType=>'hidden',
					defaultValue=>'approved'
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
        return $definition;
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

=head2 fixUrl ( string )

Returns a URL, removing invalid characters and making it unique.

=head3 string

Any text string. Most likely will have been the Asset's name or title.

=cut

sub fixUrl {
	my $self = shift;
	my $url = WebGUI::URL::urlize(shift);
	my @badUrls = ($session{config}{extrasURL}, $session{config}{uploadsURL});
	foreach my $badUrl (@badUrls) {
		if ($badUrl =~ /^http/) {
			$badUrl =~ s/^http.*\/(.*)$/$1/;
		} else {
			$badUrl =~ s/^\/(.*)/$1/;
		}
		if ($url =~ /^$badUrl/) {
			$url = "_".$url;
		}
	}
	if (length($url) > 250) {
		$url = substr($url,220);
	}
	if ($session{setting}{urlExtension} ne "" #don't add an extension if one isn't set
		&& !($url =~ /\./) #don't add an extension of the url already contains a dot
		&& $self->get("url") eq $self->getId # only add it if we're creating a new url
		) {
		$url .= ".".$session{setting}{urlExtension};
	}
	my ($test) = WebGUI::SQL->quickArray("select url from assetData where assetId<>".quote($self->getId)." and url=".quote($url));
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

Any text to append to the getAssetAdderLinks URL. Usually name/variable pairs to pass in the url. If addToURL is specified, the character ";" and the text in addToUrl is appended to the returned url.

=head3 type

A string indicating which type of adders to return. Defaults to "assets". Choose from "assets", "assetContainers", or "utilityAssets".

=cut

sub getAssetAdderLinks {
	my $self = shift;
	my $addToUrl = shift;
	my $type = shift || "assets";
	my %links;
	foreach my $class (@{$session{config}{$type}}) {
		next unless $class;
		my $load = "use ".$class;
		eval ($load);
		if ($@) {
			WebGUI::ErrorHandler::error("Couldn't compile ".$class." because ".$@);
		} else {
			my $uiLevel = eval{$class->getUiLevel()};
			if ($@) {
				WebGUI::ErrorHandler::error("Couldn't get UI level of ".$class." because ".$@);
			} else {
				next if ($uiLevel > $session{user}{uiLevel} && !WebGUI::Grouping::isInGroup(3));
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
				my $url = $self->getUrl("func=add;class=".$class);
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
	my $sth = WebGUI::SQL->read("select asset.className,asset.assetId,max(assetData.revisionDate) from asset left join assetData on asset.assetId=assetData.assetId where assetData.isPrototype=1 and asset.state='published' and asset.className in ($constraint) group by assetData.assetId");
	while (my ($class,$id,$date) = $sth->array) {
		my $asset = WebGUI::Asset->new($id,$class);
		next unless ($asset->get("isPrototype") eq '1' && $asset->canView && $asset->canAdd && $asset->getUiLevel <= $session{user}{uiLevel});
		my $url = $self->getUrl("func=add;class=".$class.";prototype=".$id);
		$url = WebGUI::URL::append($url,$addToUrl) if ($addToUrl);
		$links{$asset->getTitle}{url} = $url;
		$links{$asset->getTitle}{icon} = $asset->getIcon;
		$links{$asset->getTitle}{'icon.small'} = $asset->getIcon(1);
		$links{$asset->getTitle}{'isPrototype'} = 1;
		$links{$asset->getTitle}{'asset'} = $asset;
	}
	$sth->finish;
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

=head2 getDefault ( )

Returns the default object, which is also known by some as the "Home Page". The default object is set in the settings.

=cut

sub getDefault {
	my $class = shift;
	return $class->newByDynamicClass($session{setting}{defaultPage});
}

#-------------------------------------------------------------------

=head2 getEditForm ( )

Creates and returns a tabform to edit parameters of an Asset.

=cut

sub getEditForm {
	my $self = shift;
	my $uiLevelOverride = $self->get("className");
	$uiLevelOverride =~ s/\:\:/_/g;
	my $tabform = WebGUI::TabForm->new(undef,undef,$self->getUrl(),$uiLevelOverride);
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
		-value=>$self->get("assetId"),
		-hoverHelp=>WebGUI::International::get('asset id description','Asset'),
		);
	$tabform->getTab("properties")->text(
		-label=>WebGUI::International::get(99,"Asset"),
		-name=>"title",
		-hoverHelp=>WebGUI::International::get('99 description','Asset'),
		-value=>$self->get("title")
		);
	$tabform->getTab("properties")->text(
		-label=>WebGUI::International::get(411,"Asset"),
		-name=>"menuTitle",
		-value=>$self->get("menuTitle"),
		-hoverHelp=>WebGUI::International::get('411 description',"Asset"),
		-uiLevel=>1
		);
        $tabform->getTab("properties")->text(
                -name=>"url",
                -label=>WebGUI::International::get(104,"Asset"),
                -value=>$self->get("url"),
		-hoverHelp=>WebGUI::International::get('104 description',"Asset"),
                -uiLevel=>3
                );
	$tabform->addTab("display",WebGUI::International::get(105,"Asset"),5);
	$tabform->getTab("display")->yesNo(
                -name=>"isHidden",
                -value=>$self->get("isHidden"),
                -label=>WebGUI::International::get(886,"Asset"),
		-hoverHelp=>WebGUI::International::get('886 description',"Asset"),
                -uiLevel=>6
                );
        $tabform->getTab("display")->yesNo(
                -name=>"newWindow",
                -value=>$self->get("newWindow"),
                -label=>WebGUI::International::get(940,"Asset"),
		-hoverHelp=>WebGUI::International::get('940 description',"Asset"),
                -uiLevel=>6
                );
	$tabform->addTab("security",WebGUI::International::get(107,"Asset"),6);
        $tabform->getTab("security")->yesNo(
                -name=>"encryptPage",
                -value=>$self->get("encryptPage"),
                -label=>WebGUI::International::get('encrypt page',"Asset"),
		-hoverHelp=>WebGUI::International::get('encrypt page description',"Asset"),
                -uiLevel=>6
                );
	$tabform->getTab("security")->dateTime(
                -name=>"startDate",
                -label=>WebGUI::International::get(497,"Asset"),
		-hoverHelp=>WebGUI::International::get('497 description',"Asset"),
                -value=>$self->get("startDate"),
                -uiLevel=>6
                );
        $tabform->getTab("security")->dateTime(
                -name=>"endDate",
                -label=>WebGUI::International::get(498,"Asset"),
		-hoverHelp=>WebGUI::International::get('498 description',"Asset"),
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
        $tabform->getTab("security")->selectBox(
               -name=>"ownerUserId",
               -options=>$users,
               -label=>WebGUI::International::get(108,"Asset"),
		-hoverHelp=>WebGUI::International::get('108 description',"Asset"),
               -value=>[$self->get("ownerUserId")],
               -subtext=>$subtext,
               -uiLevel=>6
               );
        $tabform->getTab("security")->group(
               -name=>"groupIdView",
               -label=>WebGUI::International::get(872,"Asset"),
		-hoverHelp=>WebGUI::International::get('872 description',"Asset"),
               -value=>[$self->get("groupIdView")],
               -uiLevel=>6
               );
        $tabform->getTab("security")->group(
               -name=>"groupIdEdit",
               -label=>WebGUI::International::get(871,"Asset"),
		-hoverHelp=>WebGUI::International::get('871 description',"Asset"),
               -value=>[$self->get("groupIdEdit")],
               -excludeGroups=>[1,7],
               -uiLevel=>6
               );
	$tabform->addTab("meta",WebGUI::International::get("Metadata","Asset"),3);
        $tabform->getTab("meta")->textarea(
                -name=>"synopsis",
                -label=>WebGUI::International::get(412,"Asset"),
		-hoverHelp=>WebGUI::International::get('412 description',"Asset"),
                -value=>$self->get("synopsis"),
                -uiLevel=>3
                );
        $tabform->getTab("meta")->textarea(
                -name=>"extraHeadTags",
		-label=>WebGUI::International::get("extra head tags","Asset"),
		-hoverHelp=>WebGUI::International::get('extra head tags description',"Asset"),
                -value=>$self->get("extraHeadTags"),
                -uiLevel=>5
                );
	$tabform->getTab("meta")->yesNo(
		-name=>"isPackage",
		-label=>WebGUI::International::get("make package","Asset"),
		-hoverHelp=>WebGUI::International::get('make package description',"Asset"),
		-value=>$self->getValue("isPackage"),
		-uiLevel=>7
		);
	$tabform->getTab("meta")->yesNo(
		-name=>"isPrototype",
		-label=>WebGUI::International::get("make prototype","Asset"),
		-hoverHelp=>WebGUI::International::get('make prototype description',"Asset"),
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
                                $options = {"", WebGUI::International::get("Select","Asset")};
                        }
                        $tabform->getTab("meta")->dynamicField(
                                                name=>"metadata_".$meta->{$field}{fieldId},
                                                label=>$meta->{$field}{fieldName},
                                                uiLevel=>5,
                                                value=>$meta->{$field}{value},
                                                extras=>qq/title="$meta->{$field}{description}"/,
                                                possibleValues=>$meta->{$field}{possibleValues},
                                                options=>$options,
						fieldType=>$fieldType
                                );
                }
		if (WebGUI::Grouping::isInGroup(3)) {
                	# Add a quick link to add field
                	$tabform->getTab("meta")->readOnly(
                                        -value=>'<p><a href="'.WebGUI::URL::page("func=editMetaDataField;fid=new").'">'.
                                                        WebGUI::International::get('Add new field','Asset').
                                                        '</a></p>',
                                        -hoverHelp=>WebGUI::International::get('Add new field description',"Asset"),
                	);
		}
        }
	return $tabform;
}


#-------------------------------------------------------------------

=head2 getExtraHeadTags (  )

Returns the extraHeadTags stored in the asset.  Called in WebGUI::Style::generateAdditionalHeadTags if this asset is the $session{asset}.  Also called in WebGUI::Layout::view for its child assets.  Overriden in Shortcut.pm.

=cut

sub getExtraHeadTags {
	my $self = shift;
	return $self->get("extraHeadTags");
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
	my $definition = $self->definition;
	my $icon = $definition->[0]{icon} || "assets.gif";
	return $session{config}{extrasURL}.'/assets/small/'.$icon if ($small);
	return $session{config}{extrasURL}.'/assets/'.$icon;
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

=head2 getName ( )

Returns the internationalization of the word "Asset".

=cut

sub getName {
	my $self = shift;
	my $definition = $self->definition;
	return $definition->[0]{assetName};
}


#-------------------------------------------------------------------

=head2 getNotFound ( )

Returns the not found object. The not found object is set in the settings.

=cut

sub getNotFound {
	if ($session{requestedUrl} eq "*give-credit-where-credit-is-due*") {
		my $content = "";
		open(FILE,"<".$session{config}{webguiRoot}."/docs/credits.txt");
		while (<FILE>) {
			$content .= $_;
		}
		close(FILE);
		return WebGUI::Asset->newByPropertyHashRef({
			className=>"WebGUI::Asset::Snippet",
			snippet=> '<pre>'.$content.'</pre>'
			});
	} elsif ($session{requestedUrl} eq "abcdefghijklmnopqrstuvwxyz") {
		return WebGUI::Asset->newByPropertyHashRef({
			className=>"WebGUI::Asset::Snippet",
			snippet=>q|<div style="width: 600px; padding: 200px;">&#87;&#104;&#121;&#32;&#119;&#111;&#117;&#108;&#100;&#32;&#121;&#111;&#117;&#32;&#116;&#121;&#112;&#101;&#32;&#105;&#110;&#32;&#116;&#104;&#105;&#115;&#32;&#85;&#82;&#76;&#63;&#32;&#82;&#101;&#97;&#108;&#108;&#121;&#46;&#32;&#87;&#104;&#97;&#116;&#32;&#119;&#101;&#114;&#101;&#32;&#121;&#111;&#117;&#32;&#101;&#120;&#112;&#101;&#99;&#116;&#105;&#110;&#103;&#32;&#116;&#111;&#32;&#115;&#101;&#101;&#32;&#104;&#101;&#114;&#101;&#63;&#32;&#89;&#111;&#117;&#32;&#114;&#101;&#97;&#108;&#108;&#121;&#32;&#110;&#101;&#101;&#100;&#32;&#116;&#111;&#32;&#103;&#101;&#116;&#32;&#97;&#32;&#108;&#105;&#102;&#101;&#46;&#32;&#65;&#114;&#101;&#32;&#121;&#111;&#117;&#32;&#115;&#116;&#105;&#108;&#108;&#32;&#104;&#101;&#114;&#101;&#63;&#32;&#83;&#101;&#114;&#105;&#111;&#117;&#115;&#108;&#121;&#44;&#32;&#121;&#111;&#117;&#32;&#110;&#101;&#101;&#100;&#32;&#116;&#111;&#32;&#103;&#111;&#32;&#100;&#111;&#32;&#115;&#111;&#109;&#101;&#116;&#104;&#105;&#110;&#103;&#32;&#101;&#108;&#115;&#101;&#46;&#32;&#73;&#32;&#116;&#104;&#105;&#110;&#107;&#32;&#121;&#111;&#117;&#114;&#32;&#98;&#111;&#115;&#115;&#32;&#105;&#115;&#32;&#99;&#97;&#108;&#108;&#105;&#110;&#103;&#46;</div>|
			});
	} else {
		return WebGUI::Asset->newByDynamicClass($session{setting}{notFoundPage});
	}
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
	my $toolbar = deleteIcon('func=delete',$self->get("url"),WebGUI::International::get(43,"Asset"));
	my $commit;
	my $i18n = WebGUI::International->new("Asset");
	if (($self->canEditIfLocked && $session{scratch}{versionTag} eq $self->get("tagId")) || !$self->isLocked) {
        	$toolbar .= editIcon('func=edit',$self->get("url"));
	} else {
		$toolbar .= lockedIcon('func=manageRevisions',$self->get("url"));
	}
	$commit = 'contextMenu.addLink("'.$self->getUrl("func=commitRevision").'","'.$i18n->get("commit").'");' if ($self->canEditIfLocked);
        $toolbar .= cutIcon('func=cut',$self->get("url"))
            	.copyIcon('func=copy',$self->get("url"));
        $toolbar .= shortcutIcon('func=createShortcut',$self->get("url")) unless ($self->get("className") =~ /Shortcut/);
	$toolbar .= exportIcon('func=export',$self->get("url")) if defined ($session{config}{exportPath});
	WebGUI::Style::setLink($session{config}{extrasURL}.'/contextMenu/contextMenu.css', {rel=>"stylesheet",type=>"text/css"});
	WebGUI::Style::setScript($session{config}{extrasURL}.'/contextMenu/contextMenu.js', {type=>"text/javascript"});
	return '<script type="text/javascript">
		//<![CDATA[
		var contextMenu = new contextMenu_createWithImage("'.$self->getIcon(1).'","'.$self->getId.'","'.$self->getName.'");
		contextMenu.addLink("'.$self->getUrl("func=editBranch").'","'.$i18n->get("edit branch").'");
		contextMenu.addLink("'.$self->getUrl("func=promote").'","'.$i18n->get("promote").'");
		contextMenu.addLink("'.$self->getUrl("func=demote").'","'.$i18n->get("demote").'");
		contextMenu.addLink("'.$self->getUrl("func=manageAssets").'","'.$i18n->get("manage").'");
		contextMenu.addLink("'.$self->getUrl("func=manageRevisions").'","'.$i18n->get("revisions").'");
		'.$commit.'
		contextMenu.addLink("'.$self->getUrl.'","'.$i18n->get("view").'");
		contextMenu.print();
		//]]>
		</script>'.$toolbar;
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

Returns the UI Level specified in the asset definition or from the config file if it's overridden. And if neither of those is specified, then it returns 1.

=cut    
        
sub getUiLevel {
        my $self = shift;
        my $definition = $self->definition;
        return $session{config}{assetUiLevel}{$definition->[0]{className}} || $definition->[0]{uiLevel} || 1;
}  


#-------------------------------------------------------------------

=head2 getUrl ( params )

Returns a URL of Asset based upon WebGUI's gateway script.

=head3 params

Name value pairs to add to the URL in the form of:

 name1=value1;name2=value2;name3=value3

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
		#	return $session{form}{$key} if (exists $session{form}{$key}); # Security Hazard!
		my $storedValue = $self->get($key);
		return $storedValue if (defined $storedValue);
		unless (exists $self->{_propertyDefinitions}) { # check to see if the definitions have been merged and cached
			my %properties;
			foreach my $definition (@{$self->definition}) {
				%properties = (%properties, %{$definition->{properties}});
			}
			$self->{_propertyDefinitions} = \%properties;
		}
		return $self->{_propertyDefinitions}{$key}{defaultValue};
	}
	return undef;
}


#-------------------------------------------------------------------

=head2 new ( assetId [, className, revisionDate ] )

Constructor. This does not create an asset. Returns a new object if it can, otherwise returns undef.

=head3 assetId

The assetId of the asset you're creating an object reference for. Must not be blank. 

=head3 className

By default we'll use whatever class it is called by like WebGUI::Asset::File->new(), so WebGUI::Asset::File would be used.

=head3 revisionDate 

An epoch date that represents a specific version of an asset. By default the most recent version will be used.

=cut

sub new {
	my $class = shift;
	my $assetId = shift;
	return undef unless ($assetId);
	my $className = shift;
	my $revisionDate = shift || $session{assetRevision}{$assetId}{$session{scratch}{versionTag}||'_'};
	unless ($revisionDate) {
		($revisionDate) = WebGUI::SQL->quickArray("select max(revisionDate) from assetData where assetId="
			.quote($assetId)." and  (status='approved' or status='archived' or tagId=".quote($session{scratch}{versionTag}).")
			group by assetData.assetId order by assetData.revisionDate");
		$session{assetRevision}{$assetId}{$session{scratch}{versionTag}||'_'} = $revisionDate unless ($session{config}{disableCache});
	}
	return undef unless ($revisionDate);
        if ($className) {
		my $cmd = "use ".$className;
        	eval ($cmd);
		if ($@) {
        		WebGUI::ErrorHandler::error("Couldn't compile asset package: ".$className.". Root cause: ".$@);
			return undef;
		}
		$class = $className;
	}
	my $cache = WebGUI::Cache->new(["asset",$assetId,$revisionDate]);
	my $properties = $cache->get;
	if (exists $properties->{assetId}) {
		# got properties from cache
	} else { 
		my $sql = "select * from asset";
		foreach my $definition (@{$class->definition}) {
			$sql .= " left join ".$definition->{tableName}." on asset.assetId="
				.$definition->{tableName}.".assetId and ".$definition->{tableName}.".revisionDate=".$revisionDate;
		}
		$sql .= " where asset.assetId=".quote($assetId);
		$properties = WebGUI::SQL->quickHashRef($sql);
		return undef unless (exists $properties->{assetId});
		$cache->set($properties,60*60*24);
	}
	if (defined $properties) {
		my $object = { _properties => $properties };
		bless $object, $class;
		return $object;
	}	
	return undef;
}

#-------------------------------------------------------------------

=head2 newByDynamicClass ( assetId [ , revisionDate ] )

Similar to new() except that it will look up the classname of an asset rather than making you specify it. Returns undef if it can't find the classname.

=head3 assetId

Must be a valid assetId

=head3 revisionDate

A specific revision date for the asset to retrieve. If not specified, the most recent one will be used.

=cut

sub newByDynamicClass {
	my $class = shift;
	my $assetId = shift;
	my $revisionDate = shift;
	return undef unless defined $assetId;
	my $className = $session{assetClass}{$assetId};
	unless ($className) {
       		($className) = WebGUI::SQL->quickArray("select className from asset where assetId=".quote($assetId));
		$session{assetClass}{$assetId} = $className unless ($session{config}{disableCache});
	}
	return undef unless ($className);
	return WebGUI::Asset->new($assetId,$className,$revisionDate);
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

=head2 newByUrl ( [url, revisionDate] )

Returns a new Asset object based upon current url, given url or defaultPage.

=head3 url

Optional string representing a URL. 

=head3 revisionDate

A specific revision to instanciate. By default we instanciate the newest published revision.

=cut

sub newByUrl {
	my $class = shift;
	my $url = shift || $session{requestedUrl};
	my $revisionDate = shift;
	$url = lc($url);
	$url =~ s/\/$//;
	$url =~ s/^\///;
	$url =~ s/\'//;
	$url =~ s/\"//;
	my $asset;
	if ($url ne "") {
		my ($id, $class) = WebGUI::SQL->quickArray("
			select 
				asset.assetId, 
				asset.className
			from 
				asset 
			left join
				assetData on asset.assetId=assetData.assetId
			where 
				assetData.url=".quote($url)." 
			group by
				assetData.assetId
			");
		if ($id ne "" || $class ne "") {
			return WebGUI::Asset->new($id, $class, $revisionDate);
		} else {
			WebGUI::ErrorHandler::warn("The URL $url was requested, but does not exist in your asset tree.");
			return undef;
		}
	}
	return WebGUI::Asset->getDefault;
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
	foreach my $form (keys %{$session{form}}) {
		if ($form =~ /^metadata_(.*)$/) {
			$self->updateMetaData($1,$session{form}{$form});
		}
	}
	$data{title} = "Untitled" unless ($data{title});
	$data{menuTitle} = $data{title} unless ($data{menuTitle});
	unless ($data{url}) {
		$data{url} = $self->getParent->get("url");
		$data{url} =~ s/(.*)\..*/$1/;
		$data{url} .= '/'.$data{menuTitle};
	}
	WebGUI::SQL->beginTransaction;
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
	WebGUI::SQL->commit;
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
	my $template = WebGUI::Asset->new($templateId,"WebGUI::Asset::Template");
	if (defined $template) {
		return $template->process(\%vars);
	} else {
		WebGUI::ErrorHandler::error("Can't instantiate template $templateId for asset ".$self->getId);
		return "Error: Can't instantiate template ".$templateId;
	}
}


#-------------------------------------------------------------------

=head2 publish ( )

Sets an asset and it's descendants to a state of 'published' regardless of it's current state.

=cut

sub publish {
	my $self = shift;
	my $assetIds = WebGUI::SQL->buildArrayRef("select assetId from asset where lineage like ".quote($self->get("lineage").'%'));
        my $idList = quoteAndJoin($assetIds);
        WebGUI::SQL->write("update asset set state='published', stateChangedBy=".quote($session{user}{userId}).", stateChanged=".time()." where assetId in (".$idList.")");
	my $cache = WebGUI::Cache->new;
        foreach my $id (@{$assetIds}) {
        	# we do the purge directly cuz it's a lot faster than instantiating all these assets
                $cache->deleteChunk(["asset",$id]);
        }
	$self->{_properties}{state} = "published";
}


#-------------------------------------------------------------------

=head2 purgeCache ( )

Purges all cache entries associated with this asset.

=cut

sub purgeCache {
	my $self = shift;
	delete $session{assetLineage};
	delete $session{assetClass};
	delete $session{assetRevision};
	WebGUI::Cache->new(["asset",$self->getId,$self->get("revisionDate")])->deleteChunk(["asset",$self->getId]);
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
	WebGUI::SQL->write("update assetData set assetSize=".(length($sizetest)+$extra)." where assetId=".quote($self->getId)." and revisionDate=".quote($self->get("revisionDate")));
	$self->purgeCache;
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

Updates the properties of an existing revision. If you want to create a new revision, please use addRevision().

=head3 properties

Hash reference of properties and values to set.

=cut

sub update {
	my $self = shift;
	my $properties = shift;
	foreach my $definition (@{$self->definition}) {
		my @setPairs;
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
			WebGUI::SQL->write("update ".$definition->{tableName}." set ".join(",",@setPairs)." where assetId=".quote($self->getId)." and revisionDate=".$self->get("revisionDate"));
			$self->setSize;
		}
	}
	$self->purgeCache;
}


#-------------------------------------------------------------------

=head2 view ( )

Returns "".

=cut

sub view {
	my $self = shift;
	WebGUI::HTTP::setRedirect($self->getDefault->getUrl) if ($self->getId eq "PBasset000000000000001");
	return $self->getToolbar if ($session{var}{adminOn});
	return undef;
}

#-------------------------------------------------------------------

=head2 www_add ( )

Adds a new Asset based upon the class of the current form. Returns the Asset calling method www_edit();

=cut

sub www_add {
	my $self = shift;
	my %prototypeProperties; 
	my $class = $session{form}{class};
	unless ($class =~ m/^[A-Za-z0-9\:]+$/) {
		WebGUI::ErrorHandler::security("tried to call an invalid class ".$class);
		return "";
	}
	if ($session{form}{'prototype'}) {
		my $prototype = WebGUI::Asset->new($session{form}{'prototype'},$class);
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
		endDate => $self->get("endDate"),
		className=>$class,
		assetId=>"new"
		);
	$properties{isHidden} = 1 unless (WebGUI::Utility::isIn($class, @{$session{config}{assetContainers}}));
	my $newAsset = WebGUI::Asset->newByPropertyHashRef(\%properties);
	$newAsset->{_parent} = $self;
	return WebGUI::Privilege::insufficient() unless ($newAsset->canAdd);
	return $newAsset->www_edit();
}


#-------------------------------------------------------------------

=head2 www_ajaxInlineView ( )

Returns the view() method of the asset object if the requestor canView.

=cut

sub www_ajaxInlineView {
	my $self = shift;
	return WebGUI::Privilege::noAccess() unless $self->canView;
	return $self->view;
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

NOTE: Don't try to override or overload this method. It won't work. What you are looking for is processPropertiesFromFormPost().

=cut

sub www_editSave {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
	my $object;
	unless($session{setting}{autoCommit} || $session{scratch}{versionTag}) {
		$self->addVersionTag;
	}
	if ($session{form}{assetId} eq "new") {
		$object = $self->addChild({className=>$session{form}{class}});	
		$object->{_parent} = $self;
	} else {
		if ($self->canEditIfLocked || !$self->isLocked) {
                        $object = $self->addRevision;
                } else {
                        return $self->getContainer->www_view;
                }
	}
	$object->processPropertiesFromFormPost;
	$object->updateHistory("edited");
	if ($session{form}{proceed} eq "manageAssets") {
		$session{asset} = $object->getParent;
		return $session{asset}->www_manageAssets;
	}
	if ($session{form}{proceed} eq "viewParent") {
		$session{asset} = $object->getParent;
		return $session{asset}->www_view;
	}
	if ($session{form}{proceed} ne "") {
		my $method = "www_".$session{form}{proceed};
		$session{asset} = $object;
		return $session{asset}->$method();
	}
	$session{asset} = $object->getContainer;
	return $session{asset}->www_view;
}


#-------------------------------------------------------------------

=head2 www_manageAssets ( )

Main page to manage assets. Renders an AdminConsole with a list of assets. If canEdit returns False, renders an insufficient privilege page.

=cut

sub www_manageAssets {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
  	WebGUI::Style::setLink($session{config}{extrasURL}.'/contextMenu/contextMenu.css', {rel=>"stylesheet",type=>"text/css"});
        WebGUI::Style::setScript($session{config}{extrasURL}.'/contextMenu/contextMenu.js', {type=>"text/javascript"});
  	WebGUI::Style::setLink($session{config}{extrasURL}.'/assetManager/assetManager.css', {rel=>"stylesheet",type=>"text/css"});
        WebGUI::Style::setScript($session{config}{extrasURL}.'/assetManager/assetManager.js', {type=>"text/javascript"});
        my $i18n = WebGUI::International->new("Asset");
	my $ancestors = $self->getLineage(["self","ancestors"],{returnObjects=>1});
        my @crumbtrail;
        foreach my $ancestor (@{$ancestors}) {
                push(@crumbtrail,'<a href="'.$ancestor->getUrl("func=manageAssets").'">'.$ancestor->getTitle.'</a>');
        }
	my $output = '<div class="am-crumbtrail">'.join(" > ",@crumbtrail).'</div>';
	$output .= "
   <script type=\"text/javascript\">
   //<![CDATA[
     var assetManager = new AssetManager();
         assetManager.AddColumn('".WebGUI::Form::checkbox({extras=>'onchange="toggleAssetListSelectAll(this.form);"'})."','','center','form');
         assetManager.AddColumn('&nbsp;','','center','');
         assetManager.AddColumn('".$i18n->get("rank")."','','right','numeric');
         assetManager.AddColumn('".$i18n->get("99")."','','left','');
         assetManager.AddColumn('".$i18n->get("type")."','','left','');
         assetManager.AddColumn('".$i18n->get("last updated")."','','center','');
         assetManager.AddColumn('".$i18n->get("size")."','','right','');\n";
         $output .= "assetManager.AddColumn('".$i18n->get("locked")."','','center','');\n" unless ($session{setting}{autoCommit});
	foreach my $child (@{$self->getLineage(["children"],{returnObjects=>1})}) {
		my $commit = 'contextMenu.addLink("'.$child->getUrl("func=commitRevision").'","'.$i18n->get("commit").'");' if ($child->canEditIfLocked);
		$output .= 'var contextMenu = new contextMenu_createWithLink("'.$child->getId.'","More");
                contextMenu.addLink("'.$child->getUrl("func=editBranch").'","'.$i18n->get("edit branch").'");
                contextMenu.addLink("'.$child->getUrl("func=createShortcut;proceed=manageAssets").'","'.$i18n->get("create shortcut").'");
		contextMenu.addLink("'.$child->getUrl("func=manageRevisions").'","'.$i18n->get("revisions").'");
		'.$commit.'
                contextMenu.addLink("'.$child->getUrl.'","'.$i18n->get("view").'"); '."\n";
		my $title = $child->getTitle;
		$title =~ s/\'/\\\'/g;
		my $locked;
		my $edit;
		if ($child->isLocked) {
			$locked = '<img src="'.$session{config}{extrasURL}.'/assetManager/locked.gif" alt="locked" border="0" />';
			$edit = "'<a href=\"".$child->getUrl("func=edit;proceed=manageAssets")."\">Edit<\\/a> | '+" if ($child->canEditIfLocked && $session{scratch}{versionTag} eq $self->get("tagId"));
		} else {
			$edit = "'<a href=\"".$child->getUrl("func=edit;proceed=manageAssets")."\">Edit<\\/a> | '+";
			$locked = '<img src="'.$session{config}{extrasURL}.'/assetManager/unlocked.gif" alt="unlocked" border="0" />';
		}
		my $lockLink = ", '<a href=\"".$child->getUrl("func=manageRevisions")."\">".$locked."<\\/a>'" unless ($session{setting}{autoCommit});
         	$output .= "assetManager.AddLine('"
			.WebGUI::Form::checkbox({
				name=>'assetId',
				value=>$child->getId
				})
			."',".$edit."contextMenu.draw()," 
			.$child->getRank
			.",'<a href=\"".$child->getUrl("func=manageAssets")."\">".$title
			."<\\/a>','<img src=\"".$child->getIcon(1)."\" border=\"0\" alt=\"".$child->getName."\" /> ".$child->getName
			."','".WebGUI::DateTime::epochToHuman($child->get("revisionDate"))
			."','".formatBytes($child->get("assetSize"))."'".$lockLink.");\n";
         	$output .= "assetManager.AddLineSortData('','','','".$title."','".$child->getName
			."','".$child->get("revisionDate")."','".$child->get("assetSize")."');
			assetManager.addAssetMetaData('".$child->getUrl."', '".$child->getRank."', '".$title."');\n";
	}
	$output .= '
		assetManager.AddButton("'.$i18n->get("delete").'","deleteList","manageAssets");
		assetManager.AddButton("'.$i18n->get("cut").'","cutList","manageAssets");
		assetManager.AddButton("'.$i18n->get("copy").'","copyList","manageAssets");
		assetManager.initializeDragEventHandlers();
		assetManager.Write();        
                var assetListSelectAllToggle = false;
                function toggleAssetListSelectAll(form){
                        assetListSelectAllToggle = assetListSelectAllToggle ? false : true;
                        for(var i = 0; i < form.assetId.length; i++)
                        form.assetId[i].checked = assetListSelectAllToggle;
                 }
		//]]>
		</script> <div class="adminConsoleSpacer">
            &nbsp;
        </div>
		<div style="float: left; padding-right: 30px; font-size: 14px;width: 28%;"><fieldset><legend>'.WebGUI::International::get(1083,"Asset").'</legend>';
	foreach my $link (@{$self->getAssetAdderLinks("proceed=manageAssets","assetContainers")}) {
		$output .= '<img src="'.$link->{'icon.small'}.'" align="middle" alt="'.$link->{label}.'" border="0" /> 
			<a href="'.$link->{url}.'">'.$link->{label}.'</a> ';
		$output .= editIcon("func=edit;proceed=manageAssets",$link->{asset}->get("url")) if ($link->{isPrototype});
		$output .= '<br />';
	}
	$output .= '<hr />';
	foreach my $link (@{$self->getAssetAdderLinks("proceed=manageAssets")}) {
		$output .= '<img src="'.$link->{'icon.small'}.'" align="middle" alt="'.$link->{label}.'" border="0" /> 
			<a href="'.$link->{url}.'">'.$link->{label}.'</a> ';
		$output .= editIcon("func=edit;proceed=manageAssets",$link->{asset}->get("url")) if ($link->{isPrototype});
		$output .= '<br />';
	}
	$output .= '<hr />';
	foreach my $link (@{$self->getAssetAdderLinks("proceed=manageAssets","utilityAssets")}) {
		$output .= '<img src="'.$link->{'icon.small'}.'" align="middle" alt="'.$link->{label}.'" border="0" /> 
			<a href="'.$link->{url}.'">'.$link->{label}.'</a> ';
		$output .= editIcon("func=edit;proceed=manageAssets",$link->{asset}->get("url")) if ($link->{isPrototype});
		$output .= '<br />';
	}
	$output .= '</fieldset></div>'; 
	my %options;
	tie %options, 'Tie::IxHash';
	my $hasClips = 0;
        foreach my $asset (@{$self->getAssetsInClipboard(1)}) {
              	$options{$asset->getId} = '<img src="'.$asset->getIcon(1).'" alt="'.$asset->getName.'" border="0" /> '.$asset->getTitle;
		$hasClips = 1;
        }
	if ($hasClips) {
		$output .= '<div style="width: 28%; float: left; padding-right: 30px; font-size: 14px;"><fieldset><legend>'.WebGUI::International::get(1082,"Asset").'</legend>'
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
			//<![CDATA[
			var clipboardItemSelectAllToggle = false;
			function toggleClipboardSelectAll(form){
			clipboardItemSelectAllToggle = clipboardItemSelectAllToggle ? false : true;
			for(var i = 0; i < form.assetId.length; i++)
			form.assetId[i].checked = clipboardItemSelectAllToggle;
			}
			//]]>
			</script>';
	}
	my $hasPackages = 0;
	my $packages;
        foreach my $asset (@{$self->getPackageList}) {
              	$packages  .= '<img src="'.$asset->getIcon(1).'" align="middle" alt="'.$asset->getName.'" border="0" /> 
			<a href="'.$self->getUrl("func=deployPackage;assetId=".$asset->getId).'">'.$asset->getTitle.'</a> '
			.editIcon("func=edit;proceed=manageAssets",$asset->get("url"))
			.'<br />';
		$hasPackages = 1;
        }
	if ($hasPackages) {
		$output .= '<div style="width: 28%;float: left; padding-right: 30px; font-size: 14px;"><fieldset>
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

=head2 www_view ( )

Returns the view() method of the asset object if the requestor canView.

=cut

sub www_view {
	my $self = shift;
	return WebGUI::Privilege::noAccess() unless $self->canView;
	return $self->view;
}


1;

