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
use WebGUI::Form;
use WebGUI::HTMLForm;
use WebGUI::Search;
use WebGUI::Search::Index;
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

=head1 METHODS

These methods are available from this class:

=cut


#-------------------------------------------------------------------

=head2 canAdd ( session, [userId, groupId] )

Verifies that the user has the privileges necessary to add this type of asset. Return a boolean.

=head3 session

The session variable.

=head3 userId

Unique hash identifier for a user. If not supplied, current user. 

=head3 groupId

Only developers extending this method should use this parameter. By default WebGUI will check groups in this order, whichever is defined: Group id assigned in the config file for each asset. Group assigned by the developer in the asset itself if s/he extended this method to do so. The "turn admin on" group which is group id 12.

=cut

sub canAdd {
	my $className = shift;
	my $session = shift;
	my $userId = shift || $session->user->userId;
	my $subclassGroupId = shift;
	my $addPrivs = $session->config->get("assetAddPrivilege");
	my $groupId = $addPrivs->{$className} || $subclassGroupId || '12';
        return $session->user->isInGroup($groupId,$userId);
}


#-------------------------------------------------------------------

=head2 canEdit ( [userId] )

Verifies group and user permissions to be able to edit asset. Returns 1 if owner is userId, otherwise returns the result checking if the user is a member of the group that can edit.

=head3 userId

Unique hash identifier for a user. If not supplied, current user. 

=cut

sub canEdit {
	my $self = shift;
	my $userId = shift || $self->session->user->userId;
 	if ($userId eq $self->get("ownerUserId")) {
                return 1;
	}
        return $self->session->user->isInGroup($self->get("groupIdEdit"),$userId);
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
	my $userId = shift || $self->session->user->userId;
	return 0 unless ($self->get("state") eq "published");
	if ($userId eq $self->get("ownerUserId")) {
                return 1;
        } elsif ($self->session->user->isInGroup($self->get("groupIdView"),$userId)) {
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
        my $session = shift;
        my $definition = shift || [];
	my $i18n = WebGUI::International->new($session, "Asset");
        push(@{$definition}, {
		assetName=>$i18n->get("asset"),
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
	my $url = $self->session->url->urlize(shift);
	my @badUrls = ($self->session->config->get("extrasURL"), $self->session->config->get("uploadsURL"));
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
	if ($self->session->setting->get("urlExtension") ne "" #don't add an extension if one isn't set
		&& !($url =~ /\./) #don't add an extension of the url already contains a dot
		&& $self->get("url") eq $self->getId # only add it if we're creating a new url
		) {
		$url .= ".".$self->session->setting->get("urlExtension");
	}
	my ($test) = $self->session->db->quickArray("select url from assetData where assetId<>".$self->session->db->quote($self->getId)." and url=".$self->session->db->quote($url));
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

Any of the values associated with the properties of an Asset. Default choices are "title", "menutTitle", "synopsis", "url", "groupIdEdit", "groupIdView", "ownerUserId",  and "assetSize".

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
		$self->{_adminConsole} = WebGUI::AdminConsole->new($self->session,"assets");
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
	foreach my $class (@{$self->session->config->get($type)}) {
		next unless $class;
		my %properties = (
			className=>$class,
			dummy=>1
		);
		my $newAsset = WebGUI::Asset->newByPropertyHashRef($self->session,\%properties);
		next unless $newAsset;
		#use Data::Dumper; print Dumper($newAsset);
		my $uiLevel = eval{$newAsset->getUiLevel()};
		if ($@) {
			$self->session->errorHandler->error("Couldn't get UI level of ".$class."because ".$@);
			next;
		} else {
			next if ($uiLevel > $self->session->user->profileField("uiLevel") && !$self->session->user->isInGroup(3));
		}
		my $canAdd = eval{$class->canAdd($self->session)};
		if ($@) {
			$self->session->errorHandler->error("Couldn't determine if user can add ".$class." because ".$@);
			next;
		} else {
			next unless ($canAdd);
		}
		my $label = eval{$newAsset->getName()};
		if ($@) {
			$self->session->errorHandler->error("Couldn't get the name of ".$class."because ".$@);
			next;
		} else {
			my $url = $self->getUrl("func=add;class=".$class);
			$url = $self->session->url->append($url,$addToUrl) if ($addToUrl);
			$links{$label}{url} = $url;
			$links{$label}{icon} = $newAsset->getIcon;
			$links{$label}{'icon.small'} = $newAsset->getIcon(1);
		}
	}
	my $constraint;
	if ($type eq "assetContainers") {
		$constraint = $self->session->db->quoteAndJoin($self->session->config->get("assetContainers"));
	} elsif ($type eq "utilityAssets") {
		$constraint = $self->session->db->quoteAndJoin($self->session->config->get("utilityAssets"));
	} else {
		$constraint = $self->session->db->quoteAndJoin($self->session->config->get("assets"));
	}
	my $sth = $self->session->db->read("select asset.className,asset.assetId,assetData.revisionDate from asset left join assetData on asset.assetId=assetData.assetId where assetData.isPrototype=1 and asset.state='published' and asset.className in ($constraint) and assetData.revisionDate=(SELECT max(revisionDate) from assetData where assetData.assetId=asset.assetId) group by assetData.assetId");
	while (my ($class,$id,$date) = $sth->array) {
		my $asset = WebGUI::Asset->new($self->session,$id,$class,$date);
		next unless ($asset->canView && $asset->canAdd($self->session) && $asset->getUiLevel <= $self->session->user->profileField("uiLevel"));
		my $url = $self->getUrl("func=add;class=".$class.";prototype=".$id);
		$url = $self->session->url->append($url,$addToUrl) if ($addToUrl);
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
	if (WebGUI::Utility::isIn($self->get("className"), @{$self->session->config->get("assetContainers")})) {
		return $self;
	} else {
		$self->session->asset($self->getParent);
		return $self->getParent;
	}
}


#-------------------------------------------------------------------

=head2 getDefault ( session )

Constructor. Returns the default object, which is also known by some as the "Home Page". The default object is set in the settings.

=head3 session

A reference to the current session.

=cut

sub getDefault {
	my $class = shift;
	my $session = shift;
	return $class->newByDynamicClass($session, $session->setting->get("defaultPage"));
}

#-------------------------------------------------------------------

=head2 getEditForm ( )

Creates and returns a tabform to edit parameters of an Asset.

=cut

sub getEditForm {
	my $self = shift;
	my $i18n = WebGUI::International->new($self->session, "Asset");
	my $ac = $self->getAdminConsole;
	my $ago = $i18n->get("ago");
	my $rs = $self->session->db->read("select revisionDate from assetData where assetId=? order by revisionDate desc limit 5", [$self->getId]);
	$ac->addSubmenuItem($self->getUrl("func=manageRevisions"),$i18n->get("revisions").":");
	while (my ($version) = $rs->array) {
		my ($interval, $units) = $self->session->datetime->secondsToInterval(time() - $version);
		$ac->addSubmenuItem($self->getUrl("func=edit;revision=".$version), $interval." ".$units." ".$ago);
	}
	$ac->addSubmenuItem();
	my $uiLevelOverride = $self->get("className");
	$uiLevelOverride =~ s/\:\:/_/g;
	my $tabform = WebGUI::TabForm->new($self->session,undef,undef,$self->getUrl(),$uiLevelOverride);
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
			value=>$self->session->form->process("class")
			});
	}
	if ($self->session->form->process("proceed")) {
		$tabform->hidden({
			name=>"proceed",
			value=>$self->session->form->process("proceed")
			});
	}
	$tabform->addTab("properties",$i18n->get("properties"));
	$tabform->getTab("properties")->readOnly(
		-label=>$i18n->get("asset id"),
		-value=>$self->get("assetId"),
		-hoverHelp=>$i18n->get('asset id description'),
		);
	$tabform->getTab("properties")->text(
		-label=>$i18n->get(99),
		-name=>"title",
		-hoverHelp=>$i18n->get('99 description'),
		-value=>$self->get("title")
		);
	$tabform->getTab("properties")->text(
		-label=>$i18n->get(411),
		-name=>"menuTitle",
		-value=>$self->get("menuTitle"),
		-hoverHelp=>$i18n->get('411 description'),
		-uiLevel=>1
		);
        $tabform->getTab("properties")->text(
                -name=>"url",
                -label=>$i18n->get(104),
                -value=>$self->get("url"),
		-hoverHelp=>$i18n->get('104 description'),
                -uiLevel=>3
                );
	$tabform->addTab("display",$i18n->get(105),5);
	$tabform->getTab("display")->yesNo(
                -name=>"isHidden",
                -value=>$self->get("isHidden"),
                -label=>$i18n->get(886),
		-hoverHelp=>$i18n->get('886 description'),
                -uiLevel=>6
                );
        $tabform->getTab("display")->yesNo(
                -name=>"newWindow",
                -value=>$self->get("newWindow"),
                -label=>$i18n->get(940),
		-hoverHelp=>$i18n->get('940 description'),
                -uiLevel=>6
                );
	$tabform->addTab("security",$i18n->get(107),6);
        $tabform->getTab("security")->yesNo(
                -name=>"encryptPage",
                -value=>$self->get("encryptPage"),
                -label=>$i18n->get('encrypt page'),
		-hoverHelp=>$i18n->get('encrypt page description'),
                -uiLevel=>6
                );
	my $subtext;
        if ($self->session->user->isInGroup(3)) {
                 $subtext = $self->session->icon->manage('op=listUsers');
        } else {
                 $subtext = "";
        }
        my $clause;
        if ($self->session->user->isInGroup(3)) {
        	my $group = WebGUI::Group->new($self->session,4);
                my $contentManagers = $group->getUsers(1);
                push (@$contentManagers, $self->session->user->userId);
                $clause = "userId in (".$self->session->db->quoteAndJoin($contentManagers).")";
        } else {
                $clause = "userId=".$self->session->db->quote($self->get("ownerUserId"));
        }
        my $users = $self->session->db->buildHashRef("select userId,username from users where $clause order by username");
        $tabform->getTab("security")->selectBox(
               -name=>"ownerUserId",
               -options=>$users,
               -label=>$i18n->get(108),
		-hoverHelp=>$i18n->get('108 description'),
               -value=>[$self->get("ownerUserId")],
               -subtext=>$subtext,
               -uiLevel=>6
               );
        $tabform->getTab("security")->group(
               -name=>"groupIdView",
               -label=>$i18n->get(872),
		-hoverHelp=>$i18n->get('872 description'),
               -value=>[$self->get("groupIdView")],
               -uiLevel=>6
               );
        $tabform->getTab("security")->group(
               -name=>"groupIdEdit",
               -label=>$i18n->get(871),
		-hoverHelp=>$i18n->get('871 description'),
               -value=>[$self->get("groupIdEdit")],
               -excludeGroups=>[1,7],
               -uiLevel=>6
               );
	$tabform->addTab("meta",$i18n->get("Metadata"),3);
        $tabform->getTab("meta")->textarea(
                -name=>"synopsis",
                -label=>$i18n->get(412),
		-hoverHelp=>$i18n->get('412 description'),
                -value=>$self->get("synopsis"),
                -uiLevel=>3
                );
        $tabform->getTab("meta")->textarea(
                -name=>"extraHeadTags",
		-label=>$i18n->get("extra head tags"),
		-hoverHelp=>$i18n->get('extra head tags description'),
                -value=>$self->get("extraHeadTags"),
                -uiLevel=>5
                );
	$tabform->getTab("meta")->yesNo(
		-name=>"isPackage",
		-label=>$i18n->get("make package"),
		-hoverHelp=>$i18n->get('make package description'),
		-value=>$self->getValue("isPackage"),
		-uiLevel=>7
		);
	$tabform->getTab("meta")->yesNo(
		-name=>"isPrototype",
		-label=>$i18n->get("make prototype"),
		-hoverHelp=>$i18n->get('make prototype description'),
		-value=>$self->getValue("isPrototype"),
		-uiLevel=>9
		);
        if ($self->session->setting->get("metaDataEnabled")) {
                my $meta = $self->getMetaDataFields();
                foreach my $field (keys %$meta) {
                        my $fieldType = $meta->{$field}{fieldType} || "text";
                        my $options;
                        # Add a "Select..." option on top of a select list to prevent from
                        # saving the value on top of the list when no choice is made.
                        if($fieldType eq "selectList") {
                                $options = {"", $i18n->get("Select")};
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
		if ($self->session->user->isInGroup(3)) {
                	# Add a quick link to add field
                	$tabform->getTab("meta")->readOnly(
                                        -value=>'<p><a href="'.$self->session->url->page("func=editMetaDataField;fid=new").'">'.
                                                        $i18n->get('Add new field').
                                                        '</a></p>',
                                        -hoverHelp=>$i18n->get('Add new field description'),
                	);
		}
        }
	return $tabform;
}


#-------------------------------------------------------------------

=head2 getExtraHeadTags (  )

Returns the extraHeadTags stored in the asset.  Called in $self->session->style->generateAdditionalHeadTags if this asset is the $self->session->asset.  Also called in WebGUI::Layout::view for its child assets.  Overriden in Shortcut.pm.

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
	my $definition = $self->definition($self->session);
	my $icon = $definition->[0]{icon} || "assets.gif";
	return $self->session->config->get("extrasURL").'/assets/small/'.$icon if ($small);
	return $self->session->config->get("extrasURL").'/assets/'.$icon;
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

=head2 getImportNode ( session )

Constructor. Returns the import node asset object. This is where developers will templates, files, etc to the asset tree that have no other obvious attachment point.

=head3 session

A reference to the current session.

=cut

sub getImportNode {
	my $class = shift;
	my $session = shift;
	return WebGUI::Asset->newByDynamicClass($session, "PBasset000000000000002");
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
	my $definition = $self->definition($self->session);
	return $definition->[0]{assetName};
}


#-------------------------------------------------------------------

=head2 getNotFound ( session )

Constructor. Returns the not found object. The not found object is set in the settings.

=head3 session

A reference to the current session.

=cut

sub getNotFound {
	my $class = shift;
	my $session = shift;
	if ($session->url->getRequestedUrl eq "*give-credit-where-credit-is-due*") {
		my $content = "";
		open(FILE,"<".$session->config->getWebguiRoot."/docs/credits.txt");
		while (<FILE>) {
			$content .= $_;
		}
		close(FILE);
		return WebGUI::Asset->newByPropertyHashRef($session,{
			className=>"WebGUI::Asset::Snippet",
			snippet=> '<pre>'.$content.'</pre>'
			});
	} elsif ($session->url->getRequestedUrl eq "abcdefghijklmnopqrstuvwxyz") {
		return WebGUI::Asset->newByPropertyHashRef($session,{
			className=>"WebGUI::Asset::Snippet",
			snippet=>q|<div style="width: 600px; padding: 200px;">&#87;&#104;&#121;&#32;&#119;&#111;&#117;&#108;&#100;&#32;&#121;&#111;&#117;&#32;&#116;&#121;&#112;&#101;&#32;&#105;&#110;&#32;&#116;&#104;&#105;&#115;&#32;&#85;&#82;&#76;&#63;&#32;&#82;&#101;&#97;&#108;&#108;&#121;&#46;&#32;&#87;&#104;&#97;&#116;&#32;&#119;&#101;&#114;&#101;&#32;&#121;&#111;&#117;&#32;&#101;&#120;&#112;&#101;&#99;&#116;&#105;&#110;&#103;&#32;&#116;&#111;&#32;&#115;&#101;&#101;&#32;&#104;&#101;&#114;&#101;&#63;&#32;&#89;&#111;&#117;&#32;&#114;&#101;&#97;&#108;&#108;&#121;&#32;&#110;&#101;&#101;&#100;&#32;&#116;&#111;&#32;&#103;&#101;&#116;&#32;&#97;&#32;&#108;&#105;&#102;&#101;&#46;&#32;&#65;&#114;&#101;&#32;&#121;&#111;&#117;&#32;&#115;&#116;&#105;&#108;&#108;&#32;&#104;&#101;&#114;&#101;&#63;&#32;&#83;&#101;&#114;&#105;&#111;&#117;&#115;&#108;&#121;&#44;&#32;&#121;&#111;&#117;&#32;&#110;&#101;&#101;&#100;&#32;&#116;&#111;&#32;&#103;&#111;&#32;&#100;&#111;&#32;&#115;&#111;&#109;&#101;&#116;&#104;&#105;&#110;&#103;&#32;&#101;&#108;&#115;&#101;&#46;&#32;&#73;&#32;&#116;&#104;&#105;&#110;&#107;&#32;&#121;&#111;&#117;&#114;&#32;&#98;&#111;&#115;&#115;&#32;&#105;&#115;&#32;&#99;&#97;&#108;&#108;&#105;&#110;&#103;&#46;</div>|
			});
	} else {
		return WebGUI::Asset->newByDynamicClass($session, $session->setting->get("notFoundPage"));
	}
}


#-------------------------------------------------------------------

=head2 getRoot ( session )

Constructor. Returns the root asset object.

=head3 session

A reference to the current session.

=cut

sub getRoot {
	my $class = shift;
	my $session = shift;
	return WebGUI::Asset->new($session, "PBasset000000000000001");
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
	return undef unless $self->canEdit;
	return $self->{_toolbar} if (exists $self->{_toolbar});
	my $i18n = WebGUI::International->new($self->session, "Asset");
	my $toolbar = $self->session->icon->delete('func=delete',$self->get("url"),$i18n->get(43));
	my $commit;
	if (($self->canEditIfLocked && $self->session->scratch->get("versionTag") eq $self->get("tagId")) || !$self->isLocked) {
        	$toolbar .= $self->session->icon->edit('func=edit',$self->get("url"));
	} else {
		$toolbar .= $self->session->icon->locked('func=manageRevisions',$self->get("url"));
	}
        $toolbar .= $self->session->icon->cut('func=cut',$self->get("url"))
            	.$self->session->icon->copy('func=copy',$self->get("url"));
        $toolbar .= $self->session->icon->shortcut('func=createShortcut',$self->get("url")) unless ($self->get("className") =~ /Shortcut/);
	$toolbar .= $self->session->icon->export('func=export',$self->get("url")) if defined ($self->session->config->get("exportPath"));
	$self->session->style->setLink($self->session->config->get("extrasURL").'/contextMenu/contextMenu.css', {rel=>"stylesheet",type=>"text/css"});
	$self->session->style->setScript($self->session->config->get("extrasURL").'/contextMenu/contextMenu.js', {type=>"text/javascript"});
	return '<script type="text/javascript">
		//<![CDATA[
		var contextMenu = new contextMenu_createWithImage("'.$self->getIcon(1).'","'.$self->getId.'","'.$self->getName.'");
		contextMenu.addLink("'.$self->getUrl("func=editBranch").'","'.$i18n->get("edit branch").'");
		contextMenu.addLink("'.$self->getUrl("func=promote").'","'.$i18n->get("promote").'");
		contextMenu.addLink("'.$self->getUrl("func=demote").'","'.$i18n->get("demote").'");
		contextMenu.addLink("'.$self->getUrl("func=manageAssets").'","'.$i18n->get("manage").'");
		contextMenu.addLink("'.$self->getUrl("func=manageRevisions").'","'.$i18n->get("revisions").'");
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
	my $definition = $self->get("className")->definition($self->session);
	my $uilevel = $self->session->config->get("assetUiLevel");
	my $ret;
	if ($uilevel && ref $uilevel eq 'HASHREF') {
		$ret = $self->session->config->get("assetUiLevel")->{$definition->[0]{className}} || $definition->[0]{uiLevel} || 1 ;
	} else {
		$ret = $definition->[0]{uiLevel} || 1 ;
	}
	return $ret;
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
	$url = $self->session->url->gateway($url,$params);
	if ($self->get("encryptPage")) {
		$url = $self->session->url->getSiteURL().$url;
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
		my $storedValue = $self->get($key);
		return $storedValue if (defined $storedValue);
		unless (exists $self->{_propertyDefinitions}) { # check to see if the definitions have been merged and cached
			my %properties;
			foreach my $definition (@{$self->definition($self->session)}) {
				%properties = (%properties, %{$definition->{properties}});
			}
			$self->{_propertyDefinitions} = \%properties;
		}
		return $self->{_propertyDefinitions}{$key}{defaultValue};
	}
	return undef;
}


#-------------------------------------------------------------------

=head2 indexContent ( ) 

Returns an indexer object for this asset. When this method is called the asset's base content gets stored in the index. This method is often overloaded so that a particular asset can insert additional content other than the basic properties. Such uses include indexing attached files or collateral data.

=cut

sub indexContent {
	my $self = shift;
	my $indexer = WebGUI::Search::Index->create($self);
	$indexer->setIsPublic(0) if ($self->getId eq "PBasset000000000000001");
	return $indexer;
}


#-------------------------------------------------------------------

=head2 manageAssets ( )

Main page to manage assets. Renders an AdminConsole with a list of assets. If canEdit returns False, renders an insufficient privilege page. Is called by www_manageAssets

=cut

sub manageAssets {
	my $self = shift;
        my $i18n = WebGUI::International->new($self->session, "Asset");
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
         assetManager.AddColumn('".WebGUI::Form::checkbox($self->session,{extras=>'onchange="toggleAssetListSelectAll(this.form);"'})."','','center','form');
         assetManager.AddColumn('&nbsp;','','center','');
         assetManager.AddColumn('".$i18n->get("rank")."','style=\"cursor:move\"','right','numeric');
         assetManager.AddColumn('".$i18n->get("99")."','','left','');
         assetManager.AddColumn('".$i18n->get("type")."','','left','');
         assetManager.AddColumn('".$i18n->get("last updated")."','','center','');
         assetManager.AddColumn('".$i18n->get("size")."','','right','');\n
         assetManager.AddColumn('".$i18n->get("locked")."','','center','');\n";
	foreach my $child (@{$self->getLineage(["children"],{returnObjects=>1})}) {
		$output .= 'var contextMenu = new contextMenu_createWithLink("'.$child->getId.'","More");
                contextMenu.addLink("'.$child->getUrl("func=editBranch").'","'.$i18n->get("edit branch").'");
                contextMenu.addLink("'.$child->getUrl("func=createShortcut;proceed=manageAssets").'","'.$i18n->get("create shortcut").'");
		contextMenu.addLink("'.$child->getUrl("func=manageRevisions").'","'.$i18n->get("revisions").'");
                contextMenu.addLink("'.$child->getUrl.'","'.$i18n->get("view").'"); '."\n";
		my $title = $child->getTitle;
		$title =~ s/\'/\\\'/g;
		my $locked;
		my $edit;
		if ($child->isLocked) {
			$locked = '<img src="'.$self->session->config->get("extrasURL").'/assetManager/locked.gif" alt="locked" style="border: 0px;" />';
			$edit = "'<a href=\"".$child->getUrl("func=edit;proceed=manageAssets")."\">Edit</a> | '+" if ($child->canEditIfLocked && $self->session->scratch->get("versionTag") eq $self->get("tagId"));
		} else {
			$edit = "'<a href=\"".$child->getUrl("func=edit;proceed=manageAssets")."\">Edit</a> | '+";
			$locked = '<img src="'.$self->session->config->get("extrasURL").'/assetManager/unlocked.gif" alt="unlocked" style="border: 0px;" />';
		}
		my $lockLink = ", '<a href=\"".$child->getUrl("func=manageRevisions")."\">".$locked."</a>'";
         	$output .= "assetManager.AddLine('"
			.WebGUI::Form::checkbox($self->session,{
				name=>'assetId',
				value=>$child->getId
				})
			."',".$edit."contextMenu.draw()," 
			.$child->getRank
			.",'<a href=\"".$child->getUrl("func=manageAssets")."\">".$title
			."</a>','<img src=\"".$child->getIcon(1)."\" style=\"border: 0px;\" alt=\"".$child->getName."\" /> ".$child->getName
			."','".$self->session->datetime->epochToHuman($child->get("revisionDate"))
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
		<div style="float: left; padding-right: 30px; font-size: 14px;width: 28%;"><fieldset><legend>'.$i18n->get(1083).'</legend>';
	foreach my $link (@{$self->getAssetAdderLinks("proceed=manageAssets","assetContainers")}) {
		$output .= '<img src="'.$link->{'icon.small'}.'" align="middle" alt="'.$link->{label}.'" style="border: 0px;" /> 
			<a href="'.$link->{url}.'">'.$link->{label}.'</a> ';
		$output .= $self->session->icon->edit("func=edit;proceed=manageAssets",$link->{asset}->get("url")) if ($link->{isPrototype});
		$output .= '<br />';
	}
	$output .= '<hr />';
	foreach my $link (@{$self->getAssetAdderLinks("proceed=manageAssets")}) {
		$output .= '<img src="'.$link->{'icon.small'}.'" align="middle" alt="'.$link->{label}.'" style="border: 0px;" /> 
			<a href="'.$link->{url}.'">'.$link->{label}.'</a> ';
		$output .= $self->session->icon->edit("func=edit;proceed=manageAssets",$link->{asset}->get("url")) if ($link->{isPrototype});
		$output .= '<br />';
	}
	$output .= '<hr />';
	foreach my $link (@{$self->getAssetAdderLinks("proceed=manageAssets","utilityAssets")}) {
		$output .= '<img src="'.$link->{'icon.small'}.'" align="middle" alt="'.$link->{label}.'" style="border: 0px;" /> 
			<a href="'.$link->{url}.'">'.$link->{label}.'</a> ';
		$output .= $self->session->icon->edit("func=edit;proceed=manageAssets",$link->{asset}->get("url")) if ($link->{isPrototype});
		$output .= '<br />';
	}
	$output .= '</fieldset></div>'; 
	my %options;
	tie %options, 'Tie::IxHash';
	my $hasClips = 0;
        foreach my $asset (@{$self->getAssetsInClipboard(1)}) {
              	$options{$asset->getId} = '<img src="'.$asset->getIcon(1).'" alt="'.$asset->getName.'" style="border: 0px;" /> '.$asset->getTitle;
		$hasClips = 1;
        }
	if ($hasClips) {
		$output .= '<div style="width: 28%; float: left; padding-right: 30px; font-size: 14px;"><fieldset><legend>'.$i18n->get(1082).'</legend>'
			.WebGUI::Form::formHeader($self->session)
			.WebGUI::Form::hidden($self->session,{name=>"func",value=>"pasteList"})
			.WebGUI::Form::checkbox($self->session,{extras=>'onchange="toggleClipboardSelectAll(this.form);"'})
			.' '.$i18n->get("select all").'<br />'
			.WebGUI::Form::checkList($self->session,{name=>"assetId",vertical=>1,options=>\%options})
			.'<br />'
			.WebGUI::Form::submit($self->session,{value=>"Paste"})
			.WebGUI::Form::formFooter($self->session)
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
              	$packages  .= '<img src="'.$asset->getIcon(1).'" align="middle" alt="'.$asset->getName.'" style="border: 0px;" /> 
			<a href="'.$self->getUrl("func=deployPackage;assetId=".$asset->getId).'">'.$asset->getTitle.'</a> '
			.$self->session->icon->edit("func=edit;proceed=manageAssets",$asset->get("url"))
			.'<br />';
		$hasPackages = 1;
        }
	if ($hasPackages) {
		$output .= '<div style="width: 28%;float: left; padding-right: 30px; font-size: 14px;"><fieldset>
			<legend>'.$i18n->get("packages").'</legend>
			'.$packages.' </fieldset></div> ';
	}
	$output .= '
    <div class="adminConsoleSpacer">
            &nbsp;
        </div> 
		';
	return $output;
}

#-------------------------------------------------------------------

=head2 manageAssetsSearch ( )

Returns the interface for searching within the asset manager.

=cut

sub manageAssetsSearch {
	my $self = shift;
	my $i18n = WebGUI::International->new($self->session, "Asset");
	my $output = WebGUI::Form::formHeader($self->session);
	$output .= WebGUI::Form::text($self->session, { name=>"keywords", value=>$self->session->form->get("keywords")});
	my %classes = ();
	tie %classes, "Tie::IxHash";
	%classes = ("any"=>"Any Class", $self->session->db->buildHash("select distinct(className) from asset"));
	delete $classes{"WebGUI::Asset"}; # don't want to search for the root asset
	$output .= WebGUI::Form::selectBox($self->session, {name=>"class", value=>$self->session->form->get("class","selectBox"), defaultValue=>"any", options=>\%classes});
	$output .= WebGUI::Form::hidden($self->session, {name=>"func", value=>"manageAssets"});
	$output .= WebGUI::Form::hidden($self->session, {name=>"doit", value=>"1"});
	$output .= WebGUI::Form::submit($self->session, {value=>"Search"});
	$output .= WebGUI::Form::formFooter($self->session);
	return $output unless ($self->session->form->get("doit"));
	my $class = $self->session->form->get("class") eq "any" ? undef : $self->session->form->get("class");
	my $assets = WebGUI::Search->new($self->session,0)->search({
		keywords=>$self->session->form->get("keywords"),
		classes=>[$class]
		})->getAssets;
      	$output .= "<script type=\"text/javascript\">
   //<![CDATA[
     var assetManager = new AssetManager();
         assetManager.AddColumn('".WebGUI::Form::checkbox($self->session,{extras=>'onchange="toggleAssetListSelectAll(this.form);"'})."','','center','form');
         assetManager.AddColumn('&nbsp;','','center','');
         assetManager.AddColumn('".$i18n->get("99")."','','left','');
         assetManager.AddColumn('".$i18n->get("type")."','','left','');
         assetManager.AddColumn('".$i18n->get("last updated")."','','center','');
         assetManager.AddColumn('".$i18n->get("size")."','','right','');
         \n";
        foreach my $child (@{$assets}) {
		$output .= 'var contextMenu = new contextMenu_createWithLink("'.$child->getId.'","More");
                contextMenu.addLink("'.$child->getUrl("func=editBranch").'","'.$i18n->get("edit branch").'");
                contextMenu.addLink("'.$child->getUrl("func=createShortcut;proceed=manageAssets").'","'.$i18n->get("create shortcut").'");
		contextMenu.addLink("'.$child->getUrl("func=manageRevisions").'","'.$i18n->get("revisions").'");
                contextMenu.addLink("'.$child->getUrl.'","'.$i18n->get("view").'"); '."\n";
		my $title = $child->getTitle;
		$title =~ s/\'/\\\'/g;
		my $locked;
		my $edit;
		if ($child->isLocked) {
			$locked = '<img src="'.$self->session->config->get("extrasURL").'/assetManager/locked.gif" alt="locked" style="border: 0px;" />';
			$edit = "'<a href=\"".$child->getUrl("func=edit;proceed=manageAssets")."\">Edit</a> | '+" if ($child->canEditIfLocked && $self->session->scratch->get("versionTag") eq $self->get("tagId"));
		} else {
			$edit = "'<a href=\"".$child->getUrl("func=edit;proceed=manageAssets")."\">Edit</a> | '+";
			$locked = '<img src="'.$self->session->config->get("extrasURL").'/assetManager/unlocked.gif" alt="unlocked" style="border: 0px;" />';
		}
		my $lockLink = ", '<a href=\"".$child->getUrl("func=manageRevisions")."\">".$locked."</a>'";
         	$output .= "assetManager.AddLine('"
			.WebGUI::Form::checkbox($self->session,{
				name=>'assetId',
				value=>$child->getId
				})
			."',".$edit."contextMenu.draw()," 
			.$child->getRank
			.",'<a href=\"".$child->getUrl("func=manageAssets&manage=1")."\">".$title
			."</a>','<img src=\"".$child->getIcon(1)."\" style=\"border: 0px;\" alt=\"".$child->getName."\" /> ".$child->getName
			."','".$self->session->datetime->epochToHuman($child->get("revisionDate"))
			."','".formatBytes($child->get("assetSize"))."'".$lockLink.");\n";
         	$output .= "assetManager.AddLineSortData('','','','".$title."','".$child->getName
			."','".$child->get("revisionDate")."','".$child->get("assetSize")."');
			assetManager.addAssetMetaData('".$child->getUrl."', '".$child->getRank."', '".$title."');\n";
	}
        $output .= 'assetManager.AddButton("'.$i18n->get("delete").'","deleteList","manageAssets");
		assetManager.AddButton("'.$i18n->get("cut").'","cutList","manageAssets");
		assetManager.AddButton("'.$i18n->get("copy").'","copyList","manageAssets");
                assetManager.Write();        
                var assetListSelectAllToggle = false;
                function toggleAssetListSelectAll(form){
                        assetListSelectAllToggle = assetListSelectAllToggle ? false : true;
                        for(var i = 0; i < form.assetId.length; i++)
                        form.assetId[i].checked = assetListSelectAllToggle;
                 }
                 //]]>
                </script> <div class="adminConsoleSpacer"> &nbsp;</div>';
	return $output;
}

#-------------------------------------------------------------------

=head2 new ( session, assetId [, className, revisionDate ] )

Constructor. This does not create an asset. Returns a new object if it can, otherwise returns undef.

=head3 session

A reference to the current session.

=head3 assetId

The assetId of the asset you're creating an object reference for. Must not be blank. 

=head3 className

By default we'll use whatever class it is called by like WebGUI::Asset::File->new(), so WebGUI::Asset::File would be used.

=head3 revisionDate 

An epoch date that represents a specific version of an asset. By default the most recent version will be used.

=cut

sub new {
	my $class = shift;
	my $session = shift;
	my $assetId = shift;
	return undef unless ($assetId);
	my $className = shift;
	my $assetRevision = $session->stow->get("assetRevision");
	my $revisionDate = shift || $assetRevision->{$assetId}{$session->scratch->get("versionTag")||'_'};
	unless ($revisionDate) {
		($revisionDate) = $session->db->quickArray("select max(revisionDate) from assetData where assetId=? and  
			(status='approved' or status='archived' or tagId=?) order by assetData.revisionDate", 
			[$assetId, $session->scratch->get("versionTag")]);
		$assetRevision->{$assetId}{$session->scratch->get("versionTag")||'_'} = $revisionDate;
		$session->stow("assetRevision",$assetRevision);
	}
	return undef unless ($revisionDate);
        if ($className) {
		my $cmd = "use ".$className;
        	eval ($cmd);
		if ($@) {
        		$session->errorHandler->error("Couldn't compile asset package: ".$className.". Root cause: ".$@);
			return undef;
		}
		$class = $className;
	}
	my $cache = WebGUI::Cache->new($session, ["asset",$assetId,$revisionDate]);
	my $properties = $cache->get;
	if (exists $properties->{assetId}) {
		# got properties from cache
	} else { 
		my $sql = "select * from asset";
		foreach my $definition (@{$class->definition($session)}) {
			$sql .= " left join ".$definition->{tableName}." on asset.assetId="
				.$definition->{tableName}.".assetId and ".$definition->{tableName}.".revisionDate=".$revisionDate;
		}
		$sql .= " where asset.assetId=".$session->db->quote($assetId);
		$properties = $session->db->quickHashRef($sql);
		return undef unless (exists $properties->{assetId});
		$cache->set($properties,60*60*24);
	}
	if (defined $properties) {
		my $object = { _session=>$session, _properties => $properties };
		bless $object, $class;
		return $object;
	}	
	return undef;
}

#-------------------------------------------------------------------

=head2 newByDynamicClass ( session, assetId [ , revisionDate ] )

Similar to new() except that it will look up the classname of an asset rather than making you specify it. Returns undef if it can't find the classname.

=head3 session

A reference to the current session.

=head3 assetId

Must be a valid assetId

=head3 revisionDate

A specific revision date for the asset to retrieve. If not specified, the most recent one will be used.

=cut

sub newByDynamicClass {
	my $class = shift;
	my $session = shift;
	my $assetId = shift;
	my $revisionDate = shift;
	return undef unless defined $assetId;
	my $assetClass = $session->stow->get("assetClass");
	my $className = $assetClass->{$assetId};
	unless ($className) {
       		($className) = $session->db->quickArray("select className from asset where assetId=".$session->db->quote($assetId));
		$assetClass->{$assetId} = $className;
		$session->stow->set("assetClass",$assetClass);
	}
	return undef unless ($className);
	return WebGUI::Asset->new($session,$assetId,$className,$revisionDate);
}


#-------------------------------------------------------------------

=head2 newByPropertyHashRef ( session,  properties )

Constructor. 

=head3 session

A reference to the current session.

=head3 properties

A properties hash reference. The className of the properties hash must be valid.

=cut

sub newByPropertyHashRef {
	my $class = shift;
	my $session = shift;
	my $properties = shift;
	return undef unless defined $properties;
	return undef unless exists $properties->{className};
	my $className = $properties->{className};
	my $cmd = "use ".$className;
	eval ($cmd);
	if ($@) {
		$session->errorHandler->warn("Couldn't compile asset package: ".$className.". Root cause: ".$@);
		return undef;
	}
	bless {_session=>$session, _properties => $properties}, $className;
}

#-------------------------------------------------------------------

=head2 newByUrl ( session, [url, revisionDate] )

Returns a new Asset object based upon current url, given url or defaultPage.

=head3 session

A reference to the current session.

=head3 url

Optional string representing a URL. 

=head3 revisionDate

A specific revision to instanciate. By default we instanciate the newest published revision.

=cut

sub newByUrl {
	my $class = shift;
	my $session = shift;
	my $url = shift || $session->url->getRequestedUrl;
	my $revisionDate = shift;
	$url = lc($url);
	$url =~ s/\/$//;
	$url =~ s/^\///;
	$url =~ s/\'//;
	$url =~ s/\"//;
	my $asset;
	if ($url ne "") {
		my ($id, $class) = $session->db->quickArray("select distinct asset.assetId, asset.className from assetData join asset using (assetId) where assetData.url = ?", [ $url ]);
		if ($id ne "" || $class ne "") {
			return WebGUI::Asset->new($session,$id, $class, $revisionDate);
		} else {
			$session->errorHandler->warn("The URL $url was requested, but does not exist in your asset tree.");
			return undef;
		}
	}
	return WebGUI::Asset->getDefault($session);
}

#-------------------------------------------------------------------

=head2 prepareView ( )

Executes what is necessary to make the view() method work with content streaming. This includes things like processing template head tags.

=cut

sub prepareView {
	my $self = shift;
	$self->{_toolbar} = $self->getToolbar;
}

#-------------------------------------------------------------------

=head2 processPropertiesFromFormPost ( )

Updates current Asset with data from Form.

=cut

sub processPropertiesFromFormPost {
	my $self = shift;
	my %data;
	foreach my $definition (@{$self->definition($self->session)}) {
		foreach my $property (keys %{$definition->{properties}}) {
			if ($definition->{properties}{$property}{noFormPost}) {
				$data{$property} = $definition->{properties}{$property}{defaultValue} if $self->session->form->process("assetId") eq "new";
				next;
			}
			$data{$property} = $self->session->form->process(
				$property,
				$definition->{properties}{$property}{fieldType},
				$definition->{properties}{$property}{defaultValue}
				);
		}
	}
	foreach my $form ($self->session->form->param) {
		if ($form =~ /^metadata_(.*)$/) {
			$self->updateMetaData($1,$self->session->form->process($form));
		}
	}
	$data{title} = "Untitled" unless ($data{title});
	$data{menuTitle} = $data{title} unless ($data{menuTitle});
	unless ($data{url}) {
		$data{url} = $self->getParent->get("url");
		$data{url} =~ s/(.*)\..*/$1/;
		$data{url} .= '/'.$data{menuTitle};
	}
	$self->session->db->beginTransaction;
	$self->update(\%data);
	$self->session->db->commit;
}


#-------------------------------------------------------------------

=head2 processTemplate ( vars, templateId, template ) 

Returns the content generated from this template.

=head3 hashRef

A hash reference containing variables and loops to pass to the template engine.

=head3 templateId

An id referring to a particular template in the templates table. 

=head3 template

Instead of passing in a templateId, you may pass in a template object.

=cut

sub processTemplate {
	my $self = shift;
	my $var = shift;
	my $templateId = shift;
	my $template = shift;
	$template = WebGUI::Asset->new($self->session, $templateId,"WebGUI::Asset::Template") unless (defined $template);
	if (defined $template) {
        	my $meta = $self->getMetaDataFields() if ($self->session->setting->get("metaDataEnabled"));
        	foreach my $field (keys %$meta) {
			$var->{$meta->{$field}{fieldName}} = $meta->{$field}{value};
		}
		$var->{'controls'} = $self->getToolbar;
		my %vars = (
			%{$self->{_properties}},
			%{$var}
			);
		return $template->process(\%vars);
	} else {
		$self->session->errorHandler->error("Can't instantiate template $templateId for asset ".$self->getId);
		return "Error: Can't instantiate template ".$templateId;
	}
}


#-------------------------------------------------------------------

=head2 publish ( )

Sets an asset and it's descendants to a state of 'published' regardless of it's current state.

=cut

sub publish {
	my $self = shift;
	my $assetIds = $self->session->db->buildArrayRef("select assetId from asset where lineage like ".$self->session->db->quote($self->get("lineage").'%'));
        my $idList = $self->session->db->quoteAndJoin($assetIds);
        $self->session->db->write("update asset set state='published', stateChangedBy=".$self->session->db->quote($self->session->user->userId).", stateChanged=".$self->session->datetime->time()." where assetId in (".$idList.")");
	my $cache = WebGUI::Cache->new($self->session);
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
	my $stow = $self->session->stow;
	$stow->delete('assetLineage');
	$stow->delete('assetClass');
	$stow->delete('assetRevision');
	WebGUI::Cache->new($self->session,["asset",$self->getId,$self->get("revisionDate")])->deleteChunk(["asset",$self->getId]);
}


#-------------------------------------------------------------------

=head2 session ( )

Returns a reference to the current session.

=cut

sub session {
	my ($self) = @_;
	return $self->{_session};
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
	$self->session->db->write("update assetData set assetSize=".(length($sizetest)+$extra)." where assetId=".$self->session->db->quote($self->getId)." and revisionDate=".$self->session->db->quote($self->get("revisionDate")));
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
	foreach my $definition (@{$self->definition($self->session)}) {
		my @setPairs;
		foreach my $property (keys %{$definition->{properties}}) {
			next unless (exists $properties->{$property});
			my $value = $properties->{$property};
			if (exists $definition->{properties}{$property}{filter}) {
				my $filter = $definition->{properties}{$property}{filter};
				$value = $self->$filter($value);
			}
			$self->{_properties}{$property} = $value;
			push(@setPairs, $property."=".$self->session->db->quote($value));
		}
		if (scalar(@setPairs) > 0) {
			$self->session->db->write("update ".$definition->{tableName}." set ".join(",",@setPairs)." where assetId=".$self->session->db->quote($self->getId)." and revisionDate=".$self->get("revisionDate"));
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
	$self->session->http->setRedirect($self->getDefault($self->session)->getUrl) if ($self->getId eq "PBasset000000000000001");
	return $self->getToolbar if ($self->session->var->get("adminOn"));
	return undef;
}

#-------------------------------------------------------------------

=head2 www_add ( )

Adds a new Asset based upon the class of the current form. Returns the Asset calling method www_edit();

=cut

sub www_add {
	my $self = shift;
	my %prototypeProperties; 
	my $class = $self->session->form->process("class");
	unless ($class =~ m/^[A-Za-z0-9\:]+$/) {
		$self->session->errorHandler->security("tried to call an invalid class ".$class);
		return "";
	}
	if ($self->session->form->process('prototype')) {
		my $prototype = WebGUI::Asset->new($self->session->form->process("prototype"),$class);
		foreach my $definition (@{$prototype->definition($self->session)}) { # cycle through rather than copying properties to avoid grabbing stuff we shouldn't grab
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
		className=>$class,
		assetId=>"new"
		);
	$properties{isHidden} = 1 unless (WebGUI::Utility::isIn($class, @{$self->session->config->get("assetContainers")}));
	my $newAsset = WebGUI::Asset->newByPropertyHashRef($self->session,\%properties);
	$newAsset->{_parent} = $self;
	return $self->session->privilege->insufficient() unless ($newAsset->canAdd($self->session));
	return $newAsset->www_edit();
}


#-------------------------------------------------------------------

=head2 www_ajaxInlineView ( )

Returns the view() method of the asset object if the requestor canView.

=cut

sub www_ajaxInlineView {
	my $self = shift;
	return $self->session->privilege->noAccess() unless $self->canView;
	return $self->view;
}


#-------------------------------------------------------------------

=head2 www_edit ( )

Renders an AdminConsole EditForm, unless canEdit returns False.

=cut

sub www_edit {
	my $self = shift;
	return $self->session->privilege->insufficient() unless $self->canEdit;
	return $self->getAdminConsole->render($self->getEditForm->print);
}

#-------------------------------------------------------------------

=head2 www_editSave ( )

Saves and updates history. If canEdit, returns www_manageAssets() if a new Asset is created, otherwise returns www_view().  Will return an insufficient Privilege if canEdit returns False.

NOTE: Don't try to override or overload this method. It won't work. What you are looking for is processPropertiesFromFormPost().

=cut

sub www_editSave {
	my $self = shift;
	return $self->session->privilege->insufficient() unless $self->canEdit;
	my $object;
	if ($self->session->form->process("assetId") eq "new") {
		$object = $self->addChild({className=>$self->session->form->process("class")});	
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
	if ($self->session->form->process("proceed") eq "manageAssets") {
		$self->session->asset($object->getParent);
		return $self->session->asset->www_manageAssets;
	}
	if ($self->session->form->process("proceed") eq "viewParent") {
		$self->session->asset($object->getParent);
		return $self->session->asset->www_view;
	}
	if ($self->session->form->process("proceed") ne "") {
		my $method = "www_".$self->session->form->process("proceed");
		$self->session->asset($object);
		return $self->session->asset->$method();
	}
	$self->session->asset($object->getContainer);
	return $self->session->asset->www_view;
}


#-------------------------------------------------------------------

=head2 www_manageAssets ( )

Main page to manage/search assets. Renders an AdminConsole with a list of assets. If canEdit returns False, renders an insufficient privilege page. Is called by www_manageAssets

=cut

sub www_manageAssets {
	my $self = shift;
	return $self->session->privilege->insufficient() unless $self->canEdit;
  	$self->session->style->setLink($self->session->config->get("extrasURL").'/contextMenu/contextMenu.css', {rel=>"stylesheet",type=>"text/css"});
        $self->session->style->setScript($self->session->config->get("extrasURL").'/contextMenu/contextMenu.js', {type=>"text/javascript"});
  	$self->session->style->setLink($self->session->config->get("extrasURL").'/assetManager/assetManager.css', {rel=>"stylesheet",type=>"text/css"});
        $self->session->style->setScript($self->session->config->get("extrasURL").'/assetManager/assetManager.js', {type=>"text/javascript"});
	my $output = '<div style="text-align: right;"><a href="'.$self->getUrl("func=manageAssets;manage=1").'">Manage</a> | <a href="'.$self->getUrl("func=manageAssets;search=1").'">Search</a></div>';
	if ($self->session->form->get("search")) {
		$self->session->scratch->set("manageAssetsSearchToggle",1);
	} elsif ($self->session->form->get("manage")) {
		$self->session->scratch->delete("manageAssetsSearchToggle");
	}
	if ($self->session->scratch->get("manageAssetsSearchToggle")) {
		$output .= $self->manageAssetsSearch;
	} else {
		$output .= $self->manageAssets;
	}
	return $self->getAdminConsole->render($output);
}

#-------------------------------------------------------------------

=head2 www_view ( )

Returns the view() method of the asset object if the requestor canView.

=cut

sub www_view {
	my $self = shift;
	return $self->session->privilege->noAccess() unless $self->canView;
	$self->prepareView;
	$self->session->output->print($self->view);
	return undef;
}


1;

