package WebGUI::Asset;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2008 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use Carp qw( croak confess );
use Scalar::Util qw( blessed );

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
use WebGUI::HTML;
use WebGUI::HTMLForm;
use WebGUI::Keyword;
use WebGUI::Search::Index;
use WebGUI::TabForm;
use WebGUI::Utility;

=head1 NAME

Package WebGUI::Asset

=head1 DESCRIPTION

Package to manipulate items in WebGUI's asset system. 

=head1 SYNOPSIS

An asset is the basic class of content in WebGUI. This handles security, urls, and other basic information common to all content items.

The following modules are mixed in via declaration of the same package: AssetBranch.pm, AssetClipboard.pm, AssetExportHtml.pm, AssetLineage.pm, AssetMetaData.pm, AssetPackage.pm, AssetTrash.pm, AssetVersioning.pm.

A lineage is a concatenated series of sequence numbers, each six digits long, that explain an asset's position in its familiy tree. Lineage describes who the asset's ancestors are, how many ancestors the asset has in its family tree (lineage length), and the asset's position (rank) amongst its siblings. In addition, lineage provides enough information about an asset to generate a list of its siblings and descendants.

 use WebGUI::Asset;

=head1 METHODS

These methods are available from this class:

=cut


#-------------------------------------------------------------------

=head2 addEditLabel ( )

Generate an internationalized label for the add/edit screens that says
whether you're adding or editing an Asset, for clarity.

=cut

sub addEditLabel {
	my $self = shift;
	my $i18n = WebGUI::International->new($self->session,'Asset_Wobject');
	my $addEdit = ($self->session->form->process("func") eq 'add') ? $i18n->get('add') : $i18n->get('edit');
    return $addEdit.' '.$self->getName;
}

#-------------------------------------------------------------------

=head2 addMissing ( url )

Displays a message to the admin that they have requested a non-existent page and give them an option to create it.

=head3 url

The missing URL.

=cut

sub addMissing {
	my $self = shift;
	my $assetUrl = shift;
	return undef unless ($self->session->var->isAdminOn);
	my $ac = $self->getAdminConsole;
	my $i18n = WebGUI::International->new($self->session, "Asset");
	my $output = $i18n->get("missing page query");
	$output .= '<ul>
			<li><a href="'.$self->getUrl("func=add;class=WebGUI::Asset::Wobject::Layout;url=".$assetUrl).'">'.$i18n->get("add the missing page").'</a></li>
			<li><a href="'.$self->getUrl.'">'.$i18n->get("493","WebGUI").'</a></li>
			</ul>';
	return $ac->render($output);
}

#-------------------------------------------------------------------

=head2 assetDbProperties ( session, assetId, className, revisionDate )

Class method to return all properties in all tables used by a particular Asset.
Returns a hash ref with data from the table.

=head3 session

A reference to the current session.

=head3 assetId

The assetId of the asset you're creating an object reference for. Must not be blank.

=head3 className

By default we'll use whatever class it is called by like WebGUI::Asset::File->new(), so WebGUI::Asset::File would be used.

=head3 revisionDate

An epoch date that represents a specific version of an asset.

=cut

sub assetDbProperties {
	my $class = shift;
	my $session = shift;
    my ($assetId, $className, $revisionDate) = @_;
    my $sql = "select * from asset";
    my $where = " where asset.assetId=?";
    my $placeHolders = [$assetId];
    foreach my $definition (@{$className->definition($session)}) {
        $sql .= ",".$definition->{tableName};
        $where .= " and (asset.assetId=".$definition->{tableName}.".assetId and ".$definition->{tableName}.".revisionDate=".$revisionDate.")";
    }
    return $session->db->quickHashRef($sql.$where, $placeHolders);
}

#-------------------------------------------------------------------

=head2 assetExists ( session, assetId, className, revisionDate )

Class method that checks to see if an asset exists in all the proper tables for
the requested asset class.  Returns true or false.

=head3 session

A reference to the current session.

=head3 assetId

The assetId of the asset you're creating an object reference for. Must not be blank.

=head3 className

By default we'll use whatever class it is called by like WebGUI::Asset::File->new(), so WebGUI::Asset::File would be used.

=head3 revisionDate

An epoch date that represents a specific version of an asset.

=cut

sub assetExists {
	my $class = shift;
	my $session = shift;
    my ($assetId, $className, $revisionDate) = @_;
    my $dbProperties = $class->assetDbProperties($session, $assetId, $className, $revisionDate);
    return exists $dbProperties->{assetId};
}


#-------------------------------------------------------------------

=head2 canAdd ( session, [userId, groupId] )

Verifies that the user has the privileges necessary to add this type of asset. Return a boolean.

A class method.

=head3 session

The session variable.

=head3 userId

Unique hash identifier for a user. If not supplied, current user.

=head3 groupId

Only developers extending this method should use this parameter. By default WebGUI will check groups in this order, whichever is defined:

=over 4

=item *

Group id assigned in the config file for each asset.

=item *

Group assigned by the developer in the asset itself if s/he extended this method to do so.

=item *

The "turn admin on" group which is group id 12.

=back

=cut

sub canAdd {
    my $className = shift;
    my $session = shift;
    my $userId = shift || $session->user->userId;
    my $user = WebGUI::User->new($session, $userId);
    my $subclassGroupId = shift;
    my $addPrivs = $session->config->get("assetAddPrivilege");
    my $groupId = $addPrivs->{$className} || $subclassGroupId || '12';
    return $user->isInGroup($groupId);
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
    my $user = WebGUI::User->new($self->session, $userId);
    if ($userId eq $self->get("ownerUserId")) {
        return 1;
    }
    return $user->isInGroup($self->get("groupIdEdit"));
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
    my $userId = shift;
    my $user;
    if (defined $userId) {
        $user = WebGUI::User->new($self->session, $userId);
    }
    else {
        $user =  $self->session->user;
        $userId = $user->userId();
    }
    if ($userId eq $self->get("ownerUserId")) {
        return 1;
    }
    elsif ($user->isInGroup($self->get("groupIdView"))) {
        return 1;
    }
    return $self->canEdit($userId);
}


#-------------------------------------------------------------------

=head2 checkView ( )

Returns error messages if a user can't view due to publishing problems, otherwise it sets the cookie and returns undef. This is sort of a hack until we find something better.

=cut

sub checkView {
	my $self = shift;
	return $self->session->privilege->noAccess() unless $self->canView;
	my ($conf, $env, $var, $http) = $self->session->quick(qw(config env var http));
    if ($conf->get("sslEnabled") && $self->get("encryptPage") && $env->get("HTTPS") ne "on" && !$env->get("SSLPROXY")) {
        # getUrl already changes url to https if 'encryptPage'
        $http->setRedirect($self->getUrl);
        $http->sendHeader;
        return "chunked";
	}
    elsif ($var->isAdminOn && $self->get("state") =~ /^trash/) { # show em trash
		$http->setRedirect($self->getUrl("func=manageTrash"));
        $http->sendHeader;
		return "chunked";
	} 
    elsif ($var->isAdminOn && $self->get("state") =~ /^clipboard/) { # show em clipboard
		$http->setRedirect($self->getUrl("func=manageClipboard"));
        $http->sendHeader;
		return "chunked";
	} 
    elsif ($self->get("state") ne "published") { # tell em it doesn't exist anymore
		$http->setStatus("410");
		my $notFound = WebGUI::Asset->getNotFound($self->session);
		$self->session->asset($notFound);
		return $notFound->www_view;
	}
	$self->logView();
	return undef;
}

#-------------------------------------------------------------------

=head2 definition ( session, [ definition ] )

Basic definition of an Asset. Properties, default values. Returns an array reference containing tableName,className,properties

=head3 session

The current session object.

=head3 definition

An array reference containing additional information to include with the default definition.

=cut

sub definition {
    my $class = shift;
    my $session = shift;
    my $definition = shift || [];
	my $i18n = WebGUI::International->new($session, "Asset");
	my %properties;
	tie %properties, 'Tie::IxHash';
	%properties = (
                    title=>{
					    tab=>"properties",
					    label=>$i18n->get(99),
					    hoverHelp=>$i18n->get('99 description'),
                        fieldType=>'text',
                        defaultValue=>'Untitled',
					    filter=>'fixTitle',
                    },
                    menuTitle=>{
					    tab=>"properties",
					    label=>$i18n->get(411),
					    hoverHelp=>$i18n->get('411 description'),
					    uiLevel=>1,
                        fieldType=>'text',
					    filter=>'fixTitle',
                        defaultValue=>'Untitled',
                    },
                    url=>{
					    tab=>"properties",
					    label=>$i18n->get(104),
					    hoverHelp=>$i18n->get('104 description'),
					    uiLevel=>3,
                        fieldType=>'text',
                        defaultValue=>'',
					    filter=>'fixUrl'
                    },
				    isHidden=>{
					    tab=>"display",
					    label=>$i18n->get(886),
					    hoverHelp=>$i18n->get('886 description'),
					    uiLevel=>6,
					    fieldType=>'yesNo',
					    defaultValue=>0,
					},
				    newWindow=>{
					    tab=>"display",
					    label=>$i18n->get(940),
					    hoverHelp=>$i18n->get('940 description'),
					    uiLevel=>9,
					    fieldType=>'yesNo',
					    defaultValue=>0
					},
				    encryptPage=>{
					    fieldType       => ($session->config->get("sslEnabled") ? 'yesNo' : 'hidden'),
					    tab             => "security",
					    label           => $i18n->get('encrypt page'),
					    hoverHelp       => $i18n->get('encrypt page description'),
					    uiLevel         => 6,
					    defaultValue    => 0,
					},
                    ownerUserId=>{
					    tab=>"security",
					    label=>$i18n->get(108),
					    hoverHelp=>$i18n->get('108 description'),
					    uiLevel=>6,
                        fieldType=>'user',
					    filter=>'fixId',
                        defaultValue=>'3'
                    },
                    groupIdView=>{
					    tab=>"security",
					    label=>$i18n->get(872),
					    hoverHelp=>$i18n->get('872 description'),
					    uiLevel=>6,
                        fieldType=>'group',
					    filter=>'fixId',
                        defaultValue=>'7'
                    },
                    groupIdEdit=>{
					    tab=>"security",
					    label=>$i18n->get(871),
					    excludeGroups=>[1,7],
					    hoverHelp=>$i18n->get('871 description'),
					    uiLevel=>6,
                        fieldType=>'group',
					    filter=>'fixId',
                        defaultValue=>'4'
                    },
                    synopsis=>{
					    tab=>"meta",
					    label=>$i18n->get(412),
					    hoverHelp=>$i18n->get('412 description'),
					    uiLevel=>3,
                        fieldType=>'textarea',
                        defaultValue=>undef
                    },
                    extraHeadTags=>{
					    tab=>"meta",
					    label=>$i18n->get("extra head tags"),
					    hoverHelp=>$i18n->get('extra head tags description'),
					    uiLevel=>5,
                        fieldType=>'textarea',
                        defaultValue=>undef
                    },
				    isPackage=>{
					    label=>$i18n->get("make package"),
					    tab=>"meta",
					    hoverHelp=>$i18n->get('make package description'),
					    uiLevel=>7,
					    fieldType=>'yesNo',
					    defaultValue=>0
					},
				    isPrototype=>{
					    tab=>"meta",
					    label=>$i18n->get("make prototype"),
					    hoverHelp=>$i18n->get('make prototype description'),
					    uiLevel=>9,
					    fieldType=>'yesNo',
					    defaultValue=>0
					},
                    isExportable=>{
                        tab=>'meta',
                        label=>$i18n->get('make asset exportable'),
                        hoverHelp=>$i18n->get('make asset exportable description'),
                        uiLevel=>9,
                        fieldType=>'yesNo',
                        defaultValue=>1,
                    },
                    inheritUrlFromParent=>{
                        tab=>'meta',
                        label=>$i18n->get('does asset inherit URL from parent'),
                        hoverHelp=>$i18n->get('does asset inherit URL from parent description'),
                        uiLevel=>9,
                        fieldType=>'yesNo',
                        defaultValue=>0,
                    },
				    status=>{
					    noFormPost=>1,
					    fieldType=>'hidden',
					    defaultValue=>'pending'
					},
				    assetSize=>{
					    noFormPost=>1,
					    fieldType=>'hidden',
					    defaultValue=>0
					},
    );
    push(@{$definition}, {
	    assetName=>$i18n->get("asset"),
        tableName=>'assetData',
		autoGenerateForms=>1,
        className=>'WebGUI::Asset',
		icon=>'assets.gif',
        properties=>\%properties
        }
    );
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

=head2 fixId ( id, fieldName )

Returns the default Id for a field if we get an invalid Id, otherwise returns the id passed in. An valid id either looks like a GUID or is an integer.

=head3 id

The id to check.

=head3 fieldName

The name of the property we're checking. This is used to retrieve whatever the default is set to in the definition.

=cut

sub fixId {
	my $self = shift;
    my $id = shift;
    my $field = shift;
    if ($id =~ m/\A \d{1,22} \z/xms || $id =~ m/\A [A-Za-z0-9\-\_]{22} \z/xms) {
        return $id;
    }
	return $self->getValue($field);
}


#-------------------------------------------------------------------

=head2 fixTitle ( string )

Fixes a title by eliminating HTML from it.

=head3 string

Any text string. Most likely will have been the Asset's name or title.  If
no string is supplied, then it will fetch the default title for the asset,
or the word Untitled.

=cut

sub fixTitle {
	my $self = shift;
    my $string = shift;
    if (lc($string) eq "untitled" || $string eq "") {
        $string = $self->getValue("title") || 'Untitled';
    }
	return WebGUI::HTML::filter($string, 'all');
}


#-------------------------------------------------------------------

=head2 fixUrl ( url )

Returns a URL, removing invalid characters and making it unique by
adding a digit to the end if necessary.  URLs are not allowed to be
children of the extrasURL, the uploadsURL, or any defined passthruURL.
If not URL is passed, a URL will be constructed from the Asset's
parent and the menuTitle.

Assets have a maximum length of 250 characters.  Any URL longer than
250 characters will be truncated to the initial 220 characters.

URLs will be passed through $session->url->urlize to make them WebGUI compliant.
That includes any languages specific constraints set up in the default language pack.

=head3 url

Any text string. Most likely will have been the Asset's name or title.  If the string is not passed
in, then a url will be constructed from

=cut

sub fixUrl {
	my $self = shift;
	my $url = shift;

	# build a URL from the parent
	unless ($url) {
		$url = $self->getParent->get("url");
		$url =~ s/(.*)\..*/$1/;
		$url .= '/'.$self->getValue("menuTitle");
	}
	$url = $self->session->url->urlize($url);

    # if we're inheriting the URL from our parent, set that appropriately
    if($self->get('inheritUrlFromParent')) {
       $url = $self->fixUrlFromParent($url); 
    }

	# fix urls used by uploads and extras
	# and those beginning with http
	my @badUrls = (
        $self->session->config->get("extrasURL"),
        $self->session->config->get("uploadsURL"),
    );
    foreach my $badUrl (@badUrls) {
        $badUrl =~ s{ / $ }{}x; # Remove trailing slashes from the end of the URL
		if ($badUrl =~ /^http/) {
			$badUrl =~ s{ ^ http .* / } {}x; #Remove everything but the final path fragment from the badUrl
		}
        else {
			$badUrl =~ s{ ^ / }{}x; #Remove leading slashes from bare URLs
		}
		if ($url =~ /^$badUrl/) {
			$url = "_".$url;
		}
	}

	# urls can't be longer than 250 characters
	if (length($url) > 250) {
		$url = substr($url,0,220);
	}

	# remove multiple extensions from the url if there are some
    $url =~ s{
                (\.\w+)* # Strip off any number of extensions
                (?=/)    # Followed by a slash
            }{}xg;       # And delete all of them in the string

	# add automatic extension if we're supposed to
	if ($self->session->setting->get("urlExtension") ne "" #don't add an extension if one isn't set
	&&  !($url =~ /\./)                           # don't add an extension of the url already contains a dot
    &&  !$self->get("url")                        # Only add it if this is a new asset.
    &&  $url ne lc($self->getId)                  # but don't assign it the original time
	) {
		$url .= ".".$self->session->setting->get("urlExtension");
	}

    # make sure the url isn't empty after all that filtering
    if ($url eq "") {
        $url = $self->getId;
    }

	# check to see if the url already exists or not, and increment it if it does
    if ($self->urlExists($self->session, $url, {assetId=>$self->getId})) {
        my @parts = split(/\./,$url);
        if ($parts[0] =~ /(.*)(\d+$)/) {
            $parts[0] = $1.($2+1);
        }
        else {
            $parts[0] .= "2";
        }
        $url = join(".",@parts);
        $url = $self->fixUrl($url);
    }
    return $url;
}


#-------------------------------------------------------------------

=head2 fixUrlFromParent ( url )

URLs will be passed through $session->url->urlize to make them WebGUI compliant.
That includes any languages specific constraints set up in the default language pack.

=head3 url

Any text string.

=cut

sub fixUrlFromParent {
	my $self      = shift;
	my $url       = shift;

    # if we're inheriting the URL from our parent, set that appropriately
    my @parts = split(m{/}, $url);

    # don't do anything unless we need to
    if("/$url" ne $self->getParent->getUrl . '/' . $parts[-1]) {
        $url = $self->getParent->getUrl . '/' . $parts[-1];
    }

    ##Note we do not need to call fixUrl on the url argument.  Here's the reasoning why.
    ##If a URL has not been set to updated at the same time that inheritUrlFromParent is
    ##called, then it has already been "fixed".
    ##On the other hand, if it has, the sideEffect nature of this method guarantees that
    ##the URL was "fixed" before it was called.
    return $url;
}


#-------------------------------------------------------------------

=head2 get ( [propertyName] )

Returns a reference to a list of properties (or specified property) of an Asset.

If C<propertyName> is omitted, it will return a safe copy of the entire property hash.

=head3 propertyName

Any of the values associated with the properties of an Asset. Default choices are "title", "menutTitle",
"synopsis", "url", "groupIdEdit", "groupIdView", "ownerUserId",  "keywords", and "assetSize".

=cut

sub get {
	my $self = shift;
	my $propertyName = shift;
	if (defined $propertyName) {
        if ($propertyName eq "keywords") {
            return WebGUI::Keyword->new($self->session)->getKeywordsForAsset({asset => $self});
        }
		return $self->{_properties}{$propertyName};
	}
	my %copyOfHashRef = %{$self->{_properties}};
        my $keywords = WebGUI::Keyword->new($self->session)->getKeywordsForAsset({asset => $self});
        if( $keywords ne '' ) { $copyOfHashRef{ keywords } = $keywords ; }
	return \%copyOfHashRef;
}



#-------------------------------------------------------------------

=head2 getAdminConsole ( )

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
	my $classesInType = $self->session->config->get($type);
	if (ref $classesInType ne "ARRAY") {
		$classesInType = [];
	}
	foreach my $class (@{$classesInType}) {
		next unless $class;
		my %properties = (
			className=>$class,
			dummy=>1
		);
		my $newAsset = WebGUI::Asset->newByPropertyHashRef($self->session,\%properties);
		next unless $newAsset;
		my $uiLevel = eval{$newAsset->getUiLevel()};
		if ($@) {
			$self->session->errorHandler->error("Couldn't get UI level of ".$class.". Root cause: ".$@);
			next;
		}
		next if ($uiLevel > $self->session->user->profileField("uiLevel"));# && !$self->session->user->isInGroup(3));
		my $canAdd = eval{$class->canAdd($self->session)};
		if ($@) {
			$self->session->errorHandler->error("Couldn't determine if user can add ".$class." because ".$@);
			next;
		} 
		next unless ($canAdd);
		my $label = eval{$newAsset->getName()};
		if ($@) {
			$self->session->errorHandler->error("Couldn't get the name of ".$class."because ".$@);
			next;
		}
		my $url = $self->getUrl("func=add;class=".$class);
		$url = $self->session->url->append($url,$addToUrl) if ($addToUrl);
		$links{$label}{url} = $url;
		$links{$label}{icon} = $newAsset->getIcon;
		$links{$label}{'icon.small'} = $newAsset->getIcon(1);
	}
	my $constraint;
	if ($type eq "assetContainers") {
		$constraint = $self->session->db->quoteAndJoin($self->session->config->get("assetContainers"));
	} elsif ($type eq "utilityAssets") {
		$constraint = $self->session->db->quoteAndJoin($self->session->config->get("utilityAssets"));
	} else {
		$constraint = $self->session->db->quoteAndJoin($self->session->config->get("assets"));
	}
	if ($constraint) {
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

=head2 getContainer ( )

Returns a reference to the container asset. If this asset is a container it returns a reference to itself. If this asset is not attached to a container it returns its parent.

=cut

sub getContainer {
	my $self = shift;
	if (WebGUI::Utility::isIn($self->get("className"), @{$self->session->config->get("assetContainers")})) {
		return $self;
	} else {
#		$self->session->asset($self->getParent);
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

=head2 getEditTabs ()

Returns a list of arrayrefs, one per extra tab to add to the edit
form.  The default is no extra tabs.  Override this in a subclass to
add extra tabs.

Each array ref will have 3 fields:

=over 4

=item tabName

This is the name of the tab that you will use in the definition subroutine to
add fields to the new tab.

=item label

This should be an internationalized label that will be displayed on the tab.

=item uiLevel

This is the UI level for the tab.

=back

Please see the example below for adding 1 tab.

    sub getEditTabs {
        my $self = shift;
        my $i18n = WebGUI::International->new($self->session,"myNamespace");
        return ($self->SUPER::getEditTabs, ['myTab', $i18n->get('myTabName'), 9]);
    }

=cut

sub getEditTabs {
	my $self = shift;
	return ();
}

#-------------------------------------------------------------------

=head2 getEditForm ()

Creates and returns a tabform to edit parameters of an Asset. See L<getEditTabs> for
adding additional tabs.

=cut

sub getEditForm {
	my $self = shift;
	my $i18n = WebGUI::International->new($self->session, "Asset");
	my $ago = $i18n->get("ago");
	my $rs = $self->session->db->read("select revisionDate from assetData where assetId=? order by revisionDate desc limit 5", [$self->getId]);
	my $uiLevelOverride = $self->get("className");
	$uiLevelOverride =~ s/\:\:/_/g;
	my $tabform = WebGUI::TabForm->new($self->session,undef,undef,$self->getUrl(),$uiLevelOverride);
	if ($self->session->config->get("enableSaveAndCommit")) {
		$tabform->submitAppend(WebGUI::Form::submit($self->session, {
            name    => "saveAndCommit", 
            value   => $i18n->get("save and commit"),
            }));
	}
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
			value=>$self->session->form->process("class","className")
			});
	} else {
		my $ac = $self->getAdminConsole;
		$ac->addSubmenuItem($self->getUrl("func=manageRevisions"),$i18n->get("revisions").":");
		while (my ($version) = $rs->array) {
			my ($interval, $units) = $self->session->datetime->secondsToInterval(time() - $version);
			$ac->addSubmenuItem($self->getUrl("func=edit;revision=".$version), $interval." ".$units." ".$ago);
		}
	}
	if ($self->session->form->process("proceed")) {
		$tabform->hidden({
			name=>"proceed",
			value=>$self->session->form->process("proceed")
			});
	}
	# create tabs
	$tabform->addTab("properties",$i18n->get("properties"));
	$tabform->addTab("display",$i18n->get(105),5);
	$tabform->addTab("security",$i18n->get(107),6);
	$tabform->addTab("meta",$i18n->get("Metadata"),3);
	# process errors
	my $errors = $self->session->stow->get('editFormErrors');
	if ($errors) {
		$tabform->getTab("properties")->readOnly(
			-value=>"<p>Some error(s) occurred:<ul><li>".join('</li><li>', @$errors).'</li></ul></p>',
		)
	}
	$tabform->getTab("properties")->readOnly(
		-label=>$i18n->get("asset id"),
		-value=>$self->get("assetId"),
		-hoverHelp=>$i18n->get('asset id description'),
		);

	foreach my $tabspec ($self->getEditTabs) {
		$tabform->addTab(@$tabspec);
	}

	foreach my $definition (reverse @{$self->definition($self->session)}) {
		my $properties = $definition->{properties};
		next unless ($definition->{autoGenerateForms});

		foreach my $fieldName (keys %{$properties}) {
			my %fieldHash = %{$properties->{$fieldName}};
			my %params = (name => $fieldName,
				      value => $self->getValue($fieldName));
			next if exists $fieldHash{autoGenerate} and not $fieldHash{autoGenerate};

			# Kludge.
			if (isIn($fieldHash{fieldType}, 'selectBox', 'workflow') and ref $params{value} ne 'ARRAY') {
				$params{value} = [$params{value}];
			}

			if (exists $fieldHash{visible} and not $fieldHash{visible}) {
				$params{fieldType} = 'hidden';
			} else {
				%params = (%params, %fieldHash);
				delete $params{tab};
			}

			my $tab = $fieldHash{tab} || "properties";

            # use a custom draw method
            my $drawMethod = $properties->{$fieldName}{customDrawMethod};
            if ($drawMethod) {
                $params{value} = $self->$drawMethod(\%params);
                $params{fieldType} = "readOnly";
            }

            #draw the field
		    $tabform->getTab($tab)->dynamicField(%params);
		}
	}

    # display keywords field
    $tabform->getTab('meta')->text(
        name        => 'keywords',
        label       => $i18n->get('keywords'),
        hoverHelp   => $i18n->get('keywords help'),
        value       => $self->get('keywords'),
        );

    # metadata / content profiling
    if ($self->session->setting->get("metaDataEnabled")) {
                my $meta = $self->getMetaDataFields();
                foreach my $field (keys %$meta) {
                        my $fieldType = $meta->{$field}{fieldType} || "text";
                        my $options = $meta->{$field}{possibleValues};
                        # Add a "Select..." option on top of a select list to prevent from
                        # saving the value on top of the list when no choice is made.
                        if("\l$fieldType" eq "selectBox") {
                            $options = "|" . $i18n->get("Select") . "\n" . $options;
                        }
                        $tabform->getTab("meta")->dynamicField(
                                                name         => "metadata_".$meta->{$field}{fieldId},
                                                label        => $meta->{$field}{fieldName},
                                                uiLevel      => 5,
                                                value        => $meta->{$field}{value},
                                                extras       => qq/title="$meta->{$field}{description}"/,
                                                options      => $options,
                                                defaultValue => $meta->{$field}{defaultValue},
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

Returns the extraHeadTags stored in the asset.  Called in $self->session->style->generateAdditionalHeadTags if this asset is the current session asset.  Also called in WebGUI::Layout::view for its child assets.  Overriden in Shortcut.pm.

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
	return $self->session->url->extras('assets/small/'.$icon) if ($small);
	return $self->session->url->extras('assets/'.$icon);
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

=head2 getIsa ( $session )

A class method to return an iterator for getting all Assets by class (and all sub-classes)
as Asset objects, one at a time.  When the end of the assets is reached, then the iterator
will close the database handle that it uses and return undef.

It should be used like this:

my $productIterator = WebGUI::Asset::Product->getIsa($session);
while (my $product = $productIterator->()) {
  ##Do something useful with $product
}

=cut

sub getIsa {
    my $class    = shift;
    my $session  = shift;
    my $offset   = shift;
    my $def = $class->definition($session);
    my $tableName = $def->[0]->{tableName};
    my $sql = "select distinct(assetId) from $tableName";
    if (defined $offset) {
        $sql .= ' LIMIT '. $offset . ',1234567890';
    }
    my $sth = $session->db->read($sql);
    return sub {
        my ($assetId) = $sth->array;
        if (!$assetId) {
            $sth->finish;
            return undef;
        }
        return WebGUI::Asset->newPending($session, $assetId);
    };
}


#-------------------------------------------------------------------

=head2 getMedia ( session )

Constructor. Returns the media folder.

=head3 session

A reference to the current session.

=cut

sub getMedia {
	my $class = shift;
	my $session = shift;
	return WebGUI::Asset->newByDynamicClass($session, "PBasset000000000000003");
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
	return WebGUI::Asset->newByDynamicClass($session, $session->setting->get("notFoundPage"));
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

=head2 getSearchUrl ( )

Returns the URL for the search screen of the asset manager.

=cut

sub getSearchUrl {
	my $self = shift;
	return $self->getUrl( 'op=assetManager;method=search' );
}



#-------------------------------------------------------------------

=head2 getSeparator

Returns a very unique string that can be used for splitting head and body apart
from the style template.  Made into a method in case it ever has to be changed
again.

=cut

sub getSeparator {
	my $self = shift;
    my $padCharacter = shift || '~';
    my $pad = $padCharacter x 3;
	return $pad.$self->getId.$pad
}

#-------------------------------------------------------------------

=head2 getTempspace ( session )

Constructor. Returns the tempspace folder.

=head3 session

A reference to the current session.

=cut

sub getTempspace {
	my $class = shift;
	my $session = shift;
	return WebGUI::Asset->newByDynamicClass($session, "tempspace0000000000000");
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
    return undef unless $self->canEdit && $self->session->var->isAdminOn;
    return $self->{_toolbar}
        if (exists $self->{_toolbar});
    my $userUiLevel = $self->session->user->profileField("uiLevel");
    my $uiLevels = $self->session->config->get("assetToolbarUiLevel");
    my $i18n = WebGUI::International->new($self->session, "Asset");
    my $toolbar = "";
    my $commit;
    if ($self->canEditIfLocked) {
        $toolbar .= $self->session->icon->delete('func=delete',$self->get("url"),$i18n->get(43))
            if ($userUiLevel >= $uiLevels->{"delete"});
        $toolbar .= $self->session->icon->edit('func=edit',$self->get("url"))
            if ($userUiLevel >= $uiLevels->{"edit"});
    }
    else {
        $toolbar .= $self->session->icon->locked('func=manageRevisions',$self->get("url"))
            if ($userUiLevel >= $uiLevels->{"revisions"});
    }
    $toolbar .= $self->session->icon->cut('func=cut',$self->get("url"))
        if ($userUiLevel >= $uiLevels->{"cut"});

    if ($userUiLevel >= $uiLevels->{"copy"}) {
        $toolbar .= $self->session->icon->copy('func=copy',$self->get("url"));
        # if this asset has children, create a more full-featured menu for copying
        if ($self->getChildCount) {
            $toolbar
                .= '<div class="yuimenu wg-contextmenu">'
                . '<div class="bd">'
                . '<ul class="first-of-type">'
                . '<li class="yuimenuitem"><a class="yuimenuitemlabel" href="'
                . $self->getUrl("func=copy") . '">' . $i18n->get("this asset only") . '</a></li>'
                . '<li class="yuimenuitem"><a class="yuimenuitemlabel" href="'
                . $self->getUrl("func=copy;with=children") . '">' . $i18n->get("with children") . '</a></li>'
                . '<li class="yuimenuitem"><a class="yuimenuitemlabel" href="'
                . $self->getUrl("func=copy;with=descendants") . '">' . $i18n->get("with descendants") . '</a></li>'
                . '</ul></div></div>';
        }
    }
    $toolbar .= $self->session->icon->shortcut('func=createShortcut',$self->get("url"))
        if ($userUiLevel >= $uiLevels->{"shortcut"} && !$self->isa('WebGUI::Asset::Shortcut'));

    $self->session->style->setLink($self->session->url->extras('assetToolbar/assetToolbar.css'), {rel=>"stylesheet",type=>"text/css"});
    $self->session->style->setLink($self->session->url->extras('yui/build/menu/assets/skins/sam/menu.css'), {rel=>"stylesheet",type=>"text/css"});
    $self->session->style->setScript($self->session->url->extras('yui/build/yahoo-dom-event/yahoo-dom-event.js'), {type=>"text/javascript"});
    $self->session->style->setScript($self->session->url->extras('yui/build/container/container_core-min.js'), {type=>"text/javascript"});
    $self->session->style->setScript($self->session->url->extras('yui/build/menu/menu-min.js'), {type=>"text/javascript"});
    $self->session->style->setScript($self->session->url->extras('assetToolbar/assetToolbar.js'), {type=>"text/javascript"});
    my $output
        = '<div class="yui-skin-sam wg-toolbar">'
        . '<img src="' . $self->getIcon(1) . '" title="' . $self->getName . '" alt="' . $self->getName . '" class="wg-toolbar-icon" />'
        . '<div class="yuimenu wg-contextmenu">'
        . '<div class="bd">'
        . '<ul class="first-of-type">';
    if ($userUiLevel >= $uiLevels->{"changeUrl"}) {
        $output
            .= '<li class="yuimenuitem"><a class="yuimenuitemlabel" href="'
            . $self->getUrl("func=changeUrl") . '">' . $i18n->get("change url") . '</a></li>';
    }
    if ($userUiLevel >= $uiLevels->{"editBranch"}) {
        $output
            .= '<li class="yuimenuitem"><a class="yuimenuitemlabel" href="'
            . $self->getUrl("func=editBranch") . '">' . $i18n->get("edit branch") . '</a></li>';
    }
    if ($userUiLevel >= $uiLevels->{"revisions"}) {
        $output
            .= '<li class="yuimenuitem"><a class="yuimenuitemlabel" href="'
            . $self->getUrl("func=manageRevisions") . '">' . $i18n->get("revisions") . '</a></li>';
    }
    if ($userUiLevel >= $uiLevels->{"view"}) {
        $output
            .= '<li class="yuimenuitem"><a class="yuimenuitemlabel" href="'
            . $self->getUrl . '">' . $i18n->get("view") . '</a></li>';
    }
    if ($userUiLevel >= $uiLevels->{"lock"} && !$self->isLocked) {
        $output
            .= '<li class="yuimenuitem"><a class="yuimenuitemlabel" href="'
            . $self->getUrl('func=lock') . '">' . $i18n->get("lock") . '</a></li>';
    }
    if ($userUiLevel >= $uiLevels->{"export"} && $self->session->config->get("exportPath")) {
        $output
            .= '<li class="yuimenuitem"><a class="yuimenuitemlabel" href="'
            . $self->getUrl('func=export') . '">' . $i18n->get('Export','Icon') . '</a></li>';
    }
    if ($userUiLevel >= $uiLevels->{"promote"}) {
        $output
            .= '<li class="yuimenuitem"><a class="yuimenuitemlabel" href="'
            . $self->getUrl("func=promote") . '">' . $i18n->get("promote") . '</a></li>';
    }
    if ($userUiLevel >= $uiLevels->{"demote"}) {
        $output
            .= '<li class="yuimenuitem"><a class="yuimenuitemlabel" href="'
            . $self->getUrl("func=demote") . '">' . $i18n->get("demote") . '</a></li>';
    }
    if ($userUiLevel >= $uiLevels->{"manage"}) {
        $output
            .= '<li class="yuimenuitem"><a class="yuimenuitemlabel" href="'
            . $self->getUrl("op=assetManager") . '">' . $i18n->get("manage") . '</a></li>';
    }
    $output .= '</ul></div></div>' . $toolbar . '</div>';
    $self->{_toolbar} = $output;
    return $output;
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
	my $uiLevel = $self->session->config->get("assetUiLevel");
	if ($uiLevel && ref $uiLevel eq 'HASH') {
		return $uiLevel->{$definition->[0]{className}} || $definition->[0]{uiLevel} || 1 ;
	} else {
		return $definition->[0]{uiLevel} || 1 ;
	}
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

=head2 getContentLastModified

Returns the overall modification time of the object and its content in Unix
epoch format, for the purpose of the Last-Modified HTTP header.  Override this
for subclasses that contain content that is not solely dependent on the
revisionDate of the asset.

=cut

sub getContentLastModified {
	my $self = shift;
	return $self->get("revisionDate");
}


#-------------------------------------------------------------------

=head2 getValue ( key )

Tries to look up C<key> in the asset object's property cache.  If it can't find it in there, then it
tries to look it up in the definition sub for the asset.

Unlike get, it will not return the whole property hash if you omit the key.

=head3 key

An asset property name, or a propertyDefinition.

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

=head2 isValidRssItem ( )

Returns true iff this asset should be included in RSS feeds from the
RSS From Parent asset.  If false, this asset will be ignored when
generating feeds, even if it appears in the item list.  Defaults to
true.

=cut

sub isValidRssItem { 1 }

#-------------------------------------------------------------------

=head2 loadModule ( $session, $className ) 

Loads an asset module if it's not already in memory. This is a class method. Returns undef on failure to load, otherwise returns the classname.

=cut

sub loadModule {
    my ($class, $session, $className) = @_;
    # refuse to load non-assets
    if ($className !~ /^WebGUI::Asset(?:$|::)/) {
        return;
    }
    (my $module = $className . '.pm') =~ s{::|'}{/}g;
    if (eval { require $module; 1 }) {
        return $className;
    }
    $session->errorHandler->error("Couldn't compile asset package: ".$className.". Root cause: ".$@);
    return undef;
}

#-------------------------------------------------------------------

=head2 logView ( )

Logs the view of this asset to the passive profiling mechanism.   If the asset is a Layout, it will also index
all of the children (not descendents) of the Layout.

=cut

sub logView {
	my $self = shift;
	if ($self->session->setting->get("passiveProfilingEnabled")) {
		WebGUI::PassiveProfiling::add($self->session,$self->getId);
		WebGUI::PassiveProfiling::addPage($self->session,$self->getId) if ($self->get("className") eq "WebGUI::Asset::Wobject::Layout");
	}
	return undef;
}

#-------------------------------------------------------------------

=head2 new ( session, assetId [, className, revisionDate ] )

Constructor. This does not create an asset.

=head3 session

A reference to the current session.

=head3 assetId

The assetId of the asset you're creating an object reference for. Must not be blank.

=head3 className

By default we'll use whatever class it is called by like WebGUI::Asset::File->new(), so WebGUI::Asset::File would be used.

=head3 revisionDate

An epoch date that represents a specific version of an asset. By default the most recent version will be used.  If
no revision date is available it will return undef.

=cut

sub new {
    my $class           = shift;
    my $session         = shift;
    my $assetId         = shift;
    my $className       = shift;
    my $revisionDate    = shift;

    unless (defined $assetId) {
        $session->errorHandler->error("Asset constructor new() requires an assetId.");
        return undef;
    }

    if ($class eq 'WebGUI::Asset' && !$className) {
        ($className) = $session->db->quickArray("select className from asset where assetId=?", [$assetId]);
        unless ($className) {
            $session->errorHandler->error("Couldn't instantiate asset: ".$assetId. ": couldn't find class name");
            return undef;
        }
    }

    if ($className) {
        $class = $class->loadModule($session, $className);        
        return undef unless (defined $class);
    }
    
    if ( !$revisionDate ) {
        $revisionDate   = $className
                        ? $className->getCurrentRevisionDate( $session, $assetId )
                        : $class->getCurrentRevisionDate( $session, $assetId );
        return undef unless $revisionDate;
    }
    
    my $cache = WebGUI::Cache->new($session, ["asset",$assetId,$revisionDate]);
    my $properties = $cache->get;
    if (exists $properties->{assetId}) {
        # got properties from cache
    } 
    else {
        $properties = WebGUI::Asset->assetDbProperties($session, $assetId, $class, $revisionDate);
        unless (exists $properties->{assetId}) {
            $session->errorHandler->error("Asset $assetId $class $revisionDate is missing properties. Consult your database tables for corruption. ");
            return undef;
        }
        $cache->set($properties,60*60*24);
    }
    if (defined $properties) {
        my $object = { _session=>$session, _properties => $properties };
        bless $object, $class;
        return $object;
    }	
    $session->errorHandler->error("Something went wrong trying to instanciate a '$className' with assetId '$assetId', but I don't know what!");
    return undef;
}

#-------------------------------------------------------------------

=head2 newByDynamicClass ( session, assetId [ , revisionDate ] )

Instances an existing Asset, by looking up the classname of the asset specified by the assetId, and then calling new.
Returns undef if it can't find the classname.

=head3 session

A reference to the current session.

=head3 assetId

Must be a valid assetId

=head3 revisionDate

A specific revision date for the asset to retrieve. If not specified, the most recent one will be used.

=cut

sub newByDynamicClass {
    my $class           = shift;
    my $session         = shift;
    my $assetId         = shift;
    my $revisionDate    = shift;
 
# Some code requires that these situations not die.
#    confess "newByDynamicClass requires WebGUI::Session" 
#        unless $session && blessed $session eq 'WebGUI::Session';
#    confess "newByDynamicClass requires assetId"
#        unless $assetId;
# So just return instead
    return undef unless ( $session && blessed $session eq 'WebGUI::Session' ) 
        && $assetId;

    # Cache the className lookup
    my $assetClass  = $session->stow->get("assetClass");
    my $className   = $assetClass->{$assetId};

    unless ($className) {
        $className 
            = $session->db->quickScalar(
                "select className from asset where assetId=?",
                [$assetId]
            );
        $assetClass->{ $assetId } = $className;
        $session->stow->set("assetClass", $assetClass);
    }
        
    unless ( $className ) {
        $session->errorHandler->error("Couldn't find className for asset '$assetId'");
        return undef;
    }

    return WebGUI::Asset->new($session,$assetId,$className,$revisionDate);
}


#-------------------------------------------------------------------

=head2 newByPropertyHashRef ( session,  properties )

Constructor.  This creates a standalone asset with no parent.  It does not update the database.

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
    my $className = $class->loadModule($session, $properties->{className});
    return undef unless (defined $className);
	bless {_session=>$session, _properties => $properties}, $className;
}

#-------------------------------------------------------------------

=head2 newByUrl ( session, [url, revisionDate] )

Instances an existing Asset, by looking up the classname of the asset specified by the url, and then calling new.
Returns undef if it can't find a classname with that url.  If no URL is specified, and the requested url cannot
be found, it returns the default asset.

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
	if ($url ne "") {
		my ($id, $class) = $session->db->quickArray("select asset.assetId, asset.className from assetData join asset using (assetId) where assetData.url = ? limit 1", [ $url ]);
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

=head2 newPending ( session, assetId )

Instances an existing Asset by assetId, ignoring the status and always selecting the most recent revision.

=head3 session

A reference to the current session.

=head3 assetId

The asset's id

=cut

sub newPending {
    my $class = shift;
    my $session = shift;
    my $assetId = shift;
    croak "First parameter to newPending needs to be a WebGUI::Session object"
        unless $session && $session->isa('WebGUI::Session');
    croak "Second parameter to newPending needs to be an assetId"
        unless $assetId;
    my ($className, $revisionDate) = $session->db->quickArray("SELECT asset.className, assetData.revisionDate FROM asset INNER JOIN assetData ON asset.assetId = assetData.assetId WHERE asset.assetId = ? ORDER BY assetData.revisionDate DESC LIMIT 1", [ $assetId ]);
    if ($className ne "" || $revisionDate ne "") {
        return WebGUI::Asset->new($session, $assetId, $className, $revisionDate);
    }
    else {
        croak "Invalid asset id '$assetId' requested!";
    }
}

#-------------------------------------------------------------------

=head2 outputWidgetMarkup ( width, height, templateId )

Output the markup required for the widget view. Includes markup to handle the
widget macro in the iframe holding the widgetized asset. This does the following: 

=over 4

=item *

retrieves the content for this asset using its L</view> method

=item *

processes macros in that content

=item *

serializes the processed content in JSON

=item *

writes the JSON to a storage location

=item *

refers the user to download this JSON

=item *

references the appropriate JS files for the templating engine and the widget macro

=item *

invokes the templating engine on this JSON

=back

=head3 width

The width of the iframe. Required for making widget-in-widget function properly.

=head3 height

The height of the iframe. Required for making widget-in-widget function properly.

=head3 templateId

The templateId for this widgetized asset to use. Required for making
widget-in-widget function properly.

=cut

sub outputWidgetMarkup {
    # get our parameters.
    my $self            = shift;
    my $width           = shift;
    my $height          = shift;
    my $templateId      = shift;

    # construct / retrieve the values we'll use later.
    my $assetId         = $self->getId;
    my $session         = $self->session;
    my $conf            = $session->config;
    my $extras          = $conf->get('extrasURL');

    # the widgetized version of content that has the widget macro in it is
    # executing in an iframe. this iframe doesn't have a style object.
    # therefore, the macro won't be able to output the stylesheet and JS
    # information it needs to do its work. because of this, we need to output
    # that content manually. construct the filesystem paths for those files.
    my $containerCss    = $extras . '/yui/build/container/assets/container.css';
    my $containerJs     = $extras . '/yui/build/container/container-min.js';
    my $yahooDomJs      = $extras . '/yui/build/yahoo-dom-event/yahoo-dom-event.js';
    my $wgWidgetJs      = $extras . '/wgwidget.js';
    my $ttJs            = $extras . '/tt.js';
    
    # the templating engine requires its source data to be in json format.
    # write this out to disk and then serve the URL to the user. in this case,
    # we'll be serializing the content of the asset which is being widgetized. 
    my $storage         = WebGUI::Storage->get($session, $assetId);
    my $content         = $self->view;
    WebGUI::Macro::process($session, \$content);
    my $jsonContent     = to_json( { "asset$assetId" => { content => $content } } );
    $storage->addFileFromScalar("$assetId.js", "data = $jsonContent");
    my $jsonUrl         = $storage->getUrl("$assetId.js");

    # WebGUI.widgetBox.initButton() needs the full URL of the asset being
    # widgetized, and also the full URL of the JS file that does most of the
    # work.
    my $fullUrl         = "http://" . $conf->get("sitename")->[0] . $self->getUrl;
    my $wgWidgetPath    = 'http://' . $conf->get('sitename')->[0] . $extras . '/wgwidget.js';

    # finally, given all of the above, construct our output. WebGUI outputs
    # fully valid XHTML 1.0 Strict, and there's no reason this should be any
    # different.
    my $output          = <<OUTPUT;
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <title></title>
        <link rel="stylesheet" type="text/css" href="$containerCss" />
        <script type="text/javascript" src="$jsonUrl"></script>
        <script type="text/javascript" src="$ttJs"></script>
        <script type='text/javascript' src='$yahooDomJs'></script>
        <script type='text/javascript' src='$containerJs'></script>
        <script type='text/javascript' src='$wgWidgetJs'></script>
        <script type='text/javascript'>
            function setupPage() {
                WebGUI.widgetBox.doTemplate('widget$assetId'); WebGUI.widgetBox.retargetLinksAndForms();
                WebGUI.widgetBox.initButton( { 'wgWidgetPath' : '$wgWidgetPath', 'fullUrl' : '$fullUrl', 'assetId' : '$assetId', 'width' : $width, 'height' : $height, 'templateId' : '$templateId' } );
            }
            YAHOO.util.Event.addListener(window, 'load', setupPage);
        </script>
    </head>
    <body id="widget$assetId">
        \${asset$assetId.content}
    </body>
</html>
OUTPUT
    return $output;
}

#-------------------------------------------------------------------

=head2 prepareView ( )

Executes what is necessary to make the view() method work with content chunking. This includes things like processing template head tags.

=cut

sub prepareView {
	my $self = shift;
    ##Make the toolbar now and stick it in the cache.
    $self->getToolbar;
    my $style = $self->session->style;
    my @keywords = @{WebGUI::Keyword->new($self->session)->getKeywordsForAsset({asset=>$self, asArrayRef=>1})};
    if (scalar @keywords) {
        $style->setMeta( {
            name    => 'keywords',
            content => join(',', @keywords),
            }); 
    }
	$style->setRawHeadTags($self->getExtraHeadTags);
}

#-------------------------------------------------------------------

=head2 prepareWidgetView ( )

Prepares the widget view for this asset. Specifically, sets up some JS to
ensure that links selected / forms submitted in the widgetized form of the
asset open in a new window.

=cut

sub prepareWidgetView {
    my $self            = shift;
    my $templateId      = shift;
    my $template        = WebGUI::Asset::Template->new($self->session, $templateId);
    my $extras          = $self->session->config->get('extrasURL');

    $template->prepare;

    $self->{_viewTemplate} = $template;
}

#-------------------------------------------------------------------

=head2 processPropertiesFromFormPost ( )

Updates current Asset with data from Form. You can feed back errors by returning an
arrayref containing the error messages. If there is no error you do not have to return
anything.

=cut

sub processPropertiesFromFormPost {
	my $self = shift;
	my %data;
    my $form = $self->session->form;
	foreach my $definition (@{$self->definition($self->session)}) {
		foreach my $property (keys %{$definition->{properties}}) {
			if ($definition->{properties}{$property}{noFormPost}) {
				if ($form->process("assetId") eq "new" && $self->get($property) eq "") {
					$data{$property} = $definition->{properties}{$property}{defaultValue};
				}
				next;
			}
			my %params = %{$definition->{properties}{$property}};
			$params{name} = $property;
			$params{value} = $self->get($property);
			$data{$property} = $form->process(
				$property,
				$definition->{properties}{$property}{fieldType},
				$definition->{properties}{$property}{defaultValue},
				\%params
				);
		}
	}
    $data{keywords} = $form->process("keywords");
    if ($self->session->setting->get("metaDataEnabled")) {
        my $meta = $self->getMetaDataFields;
	    foreach my $field (keys %{$meta}) {
            my $value = $form->process("metadata_".$field, $meta->{$field}{fieldType}, $meta->{$field}{defaultValue});
		   	$self->updateMetaData($field, $value);
	    }
    }
	$self->session->db->beginTransaction;
	$self->update(\%data);
	$self->session->db->commit;
    return undef;
}


#-------------------------------------------------------------------

=head2 processTemplate ( vars, templateId, template )

Returns the content generated from this template.  It adds the Asset control
bar to the template variables, as well as all Asset properties and metadata.

=head3 vars

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

    # Sanity checks
    if (ref $var ne "HASH") {
        $self->session->errorHandler->error("First argument to processTemplate() should be a hash reference.");
        return "Error: Can't process template for asset ".$self->getId." of type ".$self->get("className");
    }

    $template = WebGUI::Asset->new($self->session, $templateId,"WebGUI::Asset::Template") unless (defined $template);
    if (defined $template) {
        $var = { %{ $var }, %{ $self->getMetaDataAsTemplateVariables } };
        $var->{'controls'} = $self->getToolbar;
        my %vars = (
			%{$self->{_properties}},
			%{$var}
        );
        return $template->process(\%vars);
    }
    else {
		$self->session->errorHandler->error("Can't instantiate template $templateId for asset ".$self->getId);
		return "Error: Can't instantiate template ".$templateId;
	}
}

#-------------------------------------------------------------------

=head2 processStyle ( html )

Returns some HTML wrappered in a style. Should be overridden by subclasses, because this one actually doesn't do anything other than return the html back to you.

=head3 html

The content to wrap up.

=cut

sub processStyle {
	my ($self, $output) = @_;
	return $output;
}

#-------------------------------------------------------------------

=head2 publish ( arrayref )

Sets an asset and it's descendants to a state of 'published' regardless of it's current state by default.
Otherwise sets state to published only for assets matching one of the states passed in.

=head3 arrayref

[ 'clipboard', 'clipboard-limbo', 'trash', 'trash-limbo', 'published' ]

=cut

sub publish {
	my $self = shift;
	my $statesToPublish = shift;
	
	my $stateList = $self->session->db->quoteAndJoin($statesToPublish);
	my $where = ($statesToPublish) ? "and state in (".$stateList.")" : "";
	
	my $assetIds = $self->session->db->buildArrayRef("select assetId from asset where lineage like ".$self->session->db->quote($self->get("lineage").'%')." $where");
        my $idList = $self->session->db->quoteAndJoin($assetIds);
        
	$self->session->db->write("update asset set state='published', stateChangedBy=".$self->session->db->quote($self->session->user->userId).", stateChanged=".$self->session->datetime->time()." where assetId in (".$idList.")");
	my $cache = WebGUI::Cache->new($self->session);
        foreach my $id (@{$assetIds}) {
        	# we do the purge directly cuz it's a lot faster than instantiating all these assets
                $cache->deleteChunk(["asset",$id]);
        }
	$self->{_properties}{state} = "published";

    # Also publish any shortcuts to this asset that are in the trash
    my $shortcuts 
        = WebGUI::Asset::Shortcut->getShortcutsForAssetId($self->session, $self->getId, { 
            returnObjects   => 1,
            statesToInclude => ['trash','trash-limbo'],
        });
    for my $shortcut ( @$shortcuts ) {
        $shortcut->publish;
    }
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
    my $size = length($sizetest) + $extra;
	$self->session->db->write("update assetData set assetSize=".$size." where assetId=".$self->session->db->quote($self->getId)." and revisionDate=".$self->session->db->quote($self->get("revisionDate")));
	$self->purgeCache;
    $self->{_properties}{assetSize} = $size;
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

NOTE: C<keywords> is a special property that uses the WebGUI::Keyword API
to set the keywords for this asset.

=cut

sub update {
	my $self = shift;
	my $properties = shift;

    # if keywords were specified, then let's set them the right way
    if (exists $properties->{keywords}) {
        WebGUI::Keyword->new($self->session)->setKeywordsForAsset(
            {keywords=>$properties->{keywords}, asset=>$self});
    }

    ##If inheritUrlFromParent was sent, and it is true, then muck with the url
    ##The URL may have been sent too, so use it or the current Asset's URL.
    if (exists $properties->{inheritUrlFromParent} and $properties->{inheritUrlFromParent}) {
        $properties->{'url'} = $self->fixUrlFromParent($properties->{'url'} || $self->get('url'));
    }

    # check the definition of all properties against what was given to us
    foreach my $definition (reverse @{$self->definition($self->session)}) {
		my %setPairs = ();

		# get a list of the fields available in this table so we don't try to insert
		# something for a field that doesn't exist
		my %tableFields = ();
		my $sth = $self->session->db->read('DESCRIBE `'.$definition->{tableName}.'`');
		while (my ($col) = $sth->array) {
			$tableFields{$col} = 1;
		}

        # deal with all the properties in this part of the definition
		foreach my $property (keys %{$definition->{properties}}) {

#            # skip a property unless it was specified to be set by the properties field or has a default value
#			next unless (exists $properties->{$property} || exists $definition->{properties}{$property}{defaultValue});
            # skip a property unless it was specified to be set by the properties field
			next unless (exists $properties->{$property});

            # skip a property if it has the display only flag set
            next if ($definition->{properties}{$property}{displayOnly});

            # skip properties that aren't yet in the table
            if (!exists $tableFields{$property}) {
				$self->session->log->error("update() tried to set field named '".$property."' which doesn't exist in table '".$definition->{tableName}."'");
                next;
            }


            # use the update value
			my $value = $properties->{$property};
            # use the current value because the update value was undef
            unless (defined $value) {
                $value = $self->get($property);
            }

            # apply filter logic on a property to validate or fix it's value
			if (exists $definition->{properties}{$property}{filter}) {
				my $filter = $definition->{properties}{$property}{filter};
				$value = $self->$filter($value, $property);
			}

            # use the default value because default and update were both undef
            if ($value eq "" && exists $definition->{properties}{$property}{defaultValue}) {
                $value = $definition->{properties}{$property}{defaultValue};
                if (ref($value) eq 'ARRAY') {
                    $value = $value->[0];
                }
            }

            # set the property
			$self->{_properties}{$property} = $value;
			$setPairs{$property} = $value;
		}

        # if there's anything to update, then do so
		if (scalar(keys %setPairs) > 0) {
			my @values = values %setPairs;
            my @columnNames = map { $_.'=?' } keys %setPairs;
			push(@values, $self->getId, $self->get("revisionDate"));
			$self->session->db->write("update ".$definition->{tableName}." set ".join(",",@columnNames)." where assetId=? and revisionDate=?",\@values);
		}
	}

    # we've changed something so we need to update our size
    $self->setSize();

    # we've changed something so cache is no longer valid
	$self->purgeCache;
}

#-------------------------------------------------------------------


=head2 urlExists ( session, url [, options] )

Returns true if the asset URL is used within the system. This is a class method.

=head3 session

A reference to the current session.

head3 url

The asset url you'd like to check for.

head3 options

A hash reference of optional parameters that can be passed to refine the search.

head4 assetId

Excludes an asset, by assetId, for the search for the existance of the url.

=cut

sub urlExists {
	my $class = shift;
	my $session = shift;
	my $url = lc(shift);
	my $options = shift || {};
	my $limit = "";
    my $placeholders = [ $url ];
	if (exists $options->{assetId}) {
		$limit = "and assetId<>?";
        push @{ $placeholders }, $options->{assetId};
	}
	my ($test) = $session->db->quickArray("select count(url) from assetData where url=? $limit", $placeholders);
	return $test;
}


#-------------------------------------------------------------------

=head2 view ( )

The default view method for any asset that doesn't define one. Under all normal circumstances this should be overridden or your asset won't have any output.

=cut

sub view {
	my $self = shift;
	if ($self->session->var->get("adminOn")) {
		return $self->getToolbar.' '.$self->getTitle;
	} else {
		return "";
	}
}

#-------------------------------------------------------------------

=head2 www_add ( )

Adds a new Asset based upon the class of the current form. Returns the Asset calling method www_edit();  The
new Asset will inherit security and style properties from the current asset, the parent.

=cut

sub www_add {
	my $self = shift;
	my %prototypeProperties;
    my $class = $self->loadModule($self->session, $self->session->form->process("class","className"));
    return undef unless (defined $class);
	return $self->session->privilege->insufficient() unless ($class->canAdd($self->session));
	if ($self->session->form->process('prototype')) {
		my $prototype = WebGUI::Asset->new($self->session, $self->session->form->process("prototype"),$class);
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
		parentId => $self->getId,
		groupIdView => $self->get("groupIdView"),
		groupIdEdit => $self->get("groupIdEdit"),
		ownerUserId => $self->get("ownerUserId"),
		encryptPage => $self->get("encryptPage"),
		styleTemplateId => $self->get("styleTemplateId"),
		printableStyleTemplateId => $self->get("printableStyleTemplateId"),
		isHidden => $self->get("isHidden"),
		className=>$class,
		assetId=>"new",
		url=>$self->session->form->param("url")
		);
	$properties{isHidden} = 1 unless (WebGUI::Utility::isIn($class, @{$self->session->config->get("assetContainers")}));
	my $newAsset = WebGUI::Asset->newByPropertyHashRef($self->session,\%properties);
	$newAsset->{_parent} = $self;
	return $newAsset->www_edit();
}

#-------------------------------------------------------------------

=head2 www_ajaxInlineView ( )

Returns the view() method of the asset object if the requestor canView.

=cut

sub www_ajaxInlineView {
	my $self = shift;
	return $self->session->privilege->noAccess() unless $self->canView;
	$self->prepareView;
	return $self->view;
}


#-------------------------------------------------------------------

=head2 www_changeUrl ( )

Allows a user to change a url permanently to something else.

=cut

sub www_changeUrl {
	my $self = shift;
	return $self->session->privilege->insufficient() unless $self->canEdit;
	my $i18n = WebGUI::International->new($self->session, "Asset");
	my $f = WebGUI::HTMLForm->new($self->session, action=>$self->getUrl);
	$f->hidden(name=>"func", value=>"changeUrlConfirm");
	$f->hidden(name=>"proceed", value=>$self->session->form->param("proceed"));
	$f->text(name=>"url", value=>$self->get('url'), label=>$i18n->get("104"), hoverHelp=>$i18n->get('104 description'));
	$f->yesNo(name=>"confirm", value=>0, label=>$i18n->get("confirm change"), hoverHelp=>$i18n->get("confirm change url message"), subtext=>'<br />'.$i18n->get("confirm change url message"));
	$f->submit;
	return $self->getAdminConsole->render($f->print,$i18n->get("change url"));
}

#-------------------------------------------------------------------

=head2 www_changeUrlConfirm ( )

This actually does the change url of the www_changeUrl() function.

=cut

sub www_changeUrlConfirm {
	my $self = shift;
	return $self->session->privilege->insufficient() unless $self->canEdit;
	$self->_invokeWorkflowOnExportedFiles($self->session->setting->get('changeUrlWorkflow'), 1);

	if ($self->session->form->process("confirm","yesNo") && $self->session->form->process("url","text")) {
		$self->update({url=>$self->session->form->process("url","text")});
	 	my $rs = $self->session->db->read("select revisionDate from assetData where assetId=? and revisionDate<>?",[$self->getId, $self->get("revisionDate")]);
                while (my ($version) = $rs->array) {
                	my $old = WebGUI::Asset->new($self->session, $self->getId, $self->get("className"), $version);
                        $old->purgeRevision if defined $old;
                }
	}

	if ($self->session->form->param("proceed") eq "manageAssets") {
		$self->session->http->setRedirect($self->getUrl('op=assetManager'));
	} else {
		$self->session->http->setRedirect($self->getUrl());
	}

	return undef;
}

#-------------------------------------------------------------------

=head2 www_edit ( )

Renders an AdminConsole EditForm, unless canEdit returns False.

=cut

sub www_edit {
	my $self = shift;
	return $self->session->privilege->insufficient() unless $self->canEdit;
	return $self->session->privilege->locked() unless $self->canEditIfLocked;
	return $self->getAdminConsole->render($self->getEditForm->print, $self->addEditLabel);
}

#-------------------------------------------------------------------

=head2 www_editSave ( )

Saves and updates history. If canEdit, returns www_manageAssets() if a new Asset is created, otherwise returns www_view().  Will return an insufficient Privilege if canEdit returns False.

NOTE: Don't try to override or overload this method. It won't work. What you are looking for is processPropertiesFromFormPost().

=cut

sub www_editSave {
    my $self = shift;
    ##If this is a new asset (www_add), the parent may be locked.  We should still be able to add a new asset.
    my $isNewAsset = $self->session->form->process("assetId") eq "new" ? 1 : 0;
    return $self->session->privilege->locked() if (!$self->canEditIfLocked and !$isNewAsset);
    return $self->session->privilege->insufficient() unless $self->canEdit;
    if ($self->session->config("maximumAssets")) {
        my ($count) = $self->session->db->quickArray("select count(*) from asset");
        my $i18n = WebGUI::International->new($self->session, "Asset");
        return $self->session->style->userStyle($i18n->get("over max assets")) if ($self->session->config("maximumAssets") <= $count);
    }
    my $object;
    if ($isNewAsset) {
        $object = $self->addChild({className=>$self->session->form->process("class","className")});	
        return $self->www_view unless defined $object;
        $object->{_parent} = $self;
        $object->{_properties}{url} = undef;
    } 
    else {
        if ($self->canEditIfLocked) {
            $object = $self->addRevision;
        } 
        else {
            return $self->session->asset($self->getContainer)->www_view;
        }
    }

    # Process properties from form post
    my $errors = $object->processPropertiesFromFormPost;
    if (ref $errors eq 'ARRAY') {
        $self->session->stow->set('editFormErrors', $errors);
        if ($self->session->form->process('assetId') eq 'new') {
            $object->purge;
            return $self->www_add();
        } else {
            $object->purgeRevision;
            return $self->www_edit();
        }
    }
    
    $object->updateHistory("edited");

    # Handle Save & Commit button
    if ($self->session->form->process("saveAndCommit") ne "") {
        if ($self->session->setting->get("skipCommitComments")) {
            $self->session->http->setRedirect(
                $self->getUrl("op=commitVersionTagConfirm;tagId=".WebGUI::VersionTag->getWorking($self->session)->getId)
            );
        } 
        else {
            $self->session->http->setRedirect(
                $self->getUrl("op=commitVersionTag;tagId=".WebGUI::VersionTag->getWorking($self->session)->getId)
            );
        }
        return undef;
    }

    # Handle Auto Request Commit setting
    if ($self->session->setting->get("autoRequestCommit")) {
        # Make sure version tag hasn't already been committed by another process
        my $versionTag = WebGUI::VersionTag->getWorking($self->session, "nocreate");

        if ($versionTag && $self->session->setting->get("skipCommitComments")) {
            $versionTag->requestCommit;
        }
        elsif ($versionTag) {
            $self->session->http->setRedirect(  
                $self->getUrl("op=commitVersionTag;tagId=".WebGUI::VersionTag->getWorking($self->session)->getId)
            );
            return undef;
        }
    }

    # Handle "proceed" form parameter
    if ($self->session->form->process("proceed") eq "manageAssets") {
        $self->session->asset($object->getParent);
        return $self->session->asset->www_manageAssets;
    }
    elsif ($self->session->form->process("proceed") eq "viewParent") {
        $self->session->asset($object->getParent);
        return $self->session->asset->www_view;
    }
    elsif ($self->session->form->process("proceed") ne "") {
        my $method = "www_".$self->session->form->process("proceed");
        $self->session->asset($object);
        return $self->session->asset->$method();
    }
            
    $self->session->asset($object->getContainer);
    return $self->session->asset->www_view;
}

                

#-------------------------------------------------------------------

=head2 www_manageAssets ( )

Redirect to the asset manager content handler (for backwards compatibility)

=cut

sub www_manageAssets {
    my $self = shift;
    $self->session->http->setRedirect( $self->getUrl( 'op=assetManager' ) );
    return "redirect";
}

#-------------------------------------------------------------------

=head2 www_searchAssets ( )

Redirect to the asset manager content handler (for backwards 
compatibility)

=cut

sub www_searchAssets {
    my $self = shift;
    $self->session->http->setRedirect( $self->getSearchUrl );
    return "redirect";
}

#-------------------------------------------------------------------

=head2 www_view ( )

Returns the view() method of the asset object if the requestor canView.

=cut

sub www_view {
	my $self = shift;
    
    # don't allow viewing of the root asset
	if ($self->getId eq "PBasset000000000000001") {
		$self->session->http->setRedirect($self->getDefault($self->session)->getUrl);
		return undef;
	}

    # check view privs
	my $check = $self->checkView;
	return $check if (defined $check);

    # if all else fails 
    if ($self->get('synopsis')) {
        $self->session->style->setMeta({
                name    => 'Description',
                content => $self->get('synopsis'),
        });
    }
    $self->prepareView;
	$self->session->output->print($self->view);
	return undef;
}

#-------------------------------------------------------------------

=head2 www_widgetView ( )

Returns the view() method of the asset object suitable for widgetizing.

=cut

sub www_widgetView {
    my $self    = shift;
    my $session = $self->session;
    my $style   = $session->style;

    return $session->privilege->noAccess() unless $self->canView;

    my $templateId  = $session->form->process('templateId');
    my $width       = $session->form->process('width');
    my $height      = $session->form->process('height');

    if($templateId eq 'none') {
        $self->prepareView;
    }
    else {
        $self->prepareWidgetView($templateId);
    }
        return $self->outputWidgetMarkup($width, $height, $templateId);
}

1;
