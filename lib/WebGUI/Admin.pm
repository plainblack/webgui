package WebGUI::Admin;

# The new WebGUI Admin console

use Moose;
use JSON qw( from_json to_json );
use namespace::autoclean;
use Scalar::Util;
use WebGUI::Pluggable;
use WebGUI::Macro;

has 'session' => (
    is          => 'ro',
    isa         => 'WebGUI::Session',
    required    => 1,
);

sub BUILDARGS {
    my ( $class, $session, @args ) = @_;
    return { session => $session, @args };
}

# Use the template data located in our DATA block
my $tdata   = do { local $/ = undef; <WebGUI::Admin::DATA> };

#----------------------------------------------------------------------

sub getAdminPluginTemplateVars {
    my $self    = shift;
    my $session = $self->session;
    my ( $user, $url, $setting ) = $session->quick(qw(user url setting));
    my $functions = $session->config->get("adminConsole");
    my %processed;  # title => attributes

    # process the raw information from the config file
    foreach my $funcId ( keys %{$functions} ) {
        my $funcDef = $functions->{$funcId};
        my $var     = {};

        # If we have a class name, we've got a new WebGUI::Admin::Plugin
        if ( $funcDef->{className} ) {
            my $plugin = $funcDef->{className}->new( $session, $funcId, $funcDef );
            next unless $plugin->canUse;
            $var = {
                title           => $plugin->getTitle,
                icon            => $plugin->getIcon,
                'icon.small'    => $plugin->getIconSmall,
                url             => $plugin->getUrl,
            };

            # build the list of processed items
            $processed{$plugin->getTitle} = $var;
        }
        # Don't know what we have (old admin console functions)
        else {
            # make title
            my $title = $funcDef->{title};
            WebGUI::Macro::process( $session, \$title );

            # determine if the user can use this thing
            my $canUse = 0;
            if ( defined $funcDef->{group} ) {
                $canUse = $user->isInGroup( $funcDef->{group} );
            }
            elsif ( defined $funcDef->{groupSetting} ) {
                $canUse = $user->isInGroup( $setting->get( $funcDef->{groupSetting} ) );
            }
            if ( $funcDef->{uiLevel} > $user->profileField("uiLevel") ) {
                $canUse = 0;
            }
            next unless $canUse;

            # build the attributes
            $var = {
                title        => $title,
                icon         => $url->extras( "/adminConsole/" . $funcDef->{icon} ),
                'icon.small' => $url->extras( "adminConsole/small/" . $funcDef->{icon} ),
                url          => $funcDef->{url},
            };

            # build the list of processed items
            $processed{$title} = $var;

        } ## end else [ if ( $funcDef->{className...})]

    } ## end foreach my $funcId ( keys %...)

    #sort the functions alphabetically
    return [ map { $processed{$_} } sort keys %processed ];
} ## end sub getAdminFunctionTemplateVars

#----------------------------------------------------------------------

=head2 getNewContentTemplateVars 

Get an array of tabs for the new content menu. Each tab contains items
of new content that can be added to the site.

=cut

sub getNewContentTemplateVars {
    my ( $self ) = @_;
    my $session = $self->session;
    my ( $user, $config ) = $session->quick(qw( user config ));
    my $i18n = WebGUI::International->new($session,'Macro_AdminBar');
    my $tabs    = [];

    # Add a dummy asset to the session to pass canAdd checks
    # The future canAdd will not check validParent, www_add will instead
    # This asset is removed before we return...
    $session->asset( WebGUI::Asset->getDefault( $session ) );

    # Build the categories
    my %rawCategories = %{ $config->get('assetCategories') };
    my %categories;     # All the categories we have
    my $userUiLevel = $user->profileField('uiLevel');
    foreach my $category ( keys %rawCategories ) {
        # Check the ui level
        next if $rawCategories{$category}{uiLevel} > $userUiLevel;
        # Check group permissions
        next if ( exists $rawCategories{$category}{group} && !$user->isInGroup( $rawCategories{$category}{group} ) );

        my $title = $rawCategories{$category}{title};

        # Process macros on the title
        WebGUI::Macro::process( $session, \$title );

        $categories{$category}{title} = $title;
    }

    # assets
    my %assetList = %{ $config->get('assets') };
    foreach my $assetClass ( keys %assetList ) {
        # Create a dummy asset
        my $dummy = WebGUI::Asset->newByPropertyHashRef( $session, { dummy => 1, className => $assetClass } );
        next unless defined $dummy;
        my $assetConfig = $assetList{$assetClass};

        # Check UI Level
        next if $dummy->getUiLevel( $assetConfig->{uiLevel} ) > $userUiLevel;

        # Check add permissions
        next unless ( $dummy->canAdd($session) );

        my $assetInfo = {
            className   => $assetClass,
            url         => 'func=add;className=' . $assetClass,
            icon        => $dummy->getIcon(1),
            title       => $dummy->getTitle,
        };

        # Add the asset to all categories it should appear in
        my @assetCategories = ref $assetConfig->{category} ? @{ $assetConfig->{category} } : $assetConfig->{category};
        for my $category (@assetCategories) {
            next unless exists $categories{$category};
            $categories{$category}{items} ||= [];
            push @{ $categories{$category}{items} }, $assetInfo;
        }
    } ## end foreach my $assetClass ( keys...)

    # packages
    foreach my $package ( @{ WebGUI::Asset::getPackageList( $session ) } ) {
        # Check permissions and UI level
        next unless ( $package->canView && $package->canAdd($session) && $package->getUiLevel <= $userUiLevel );

        # Create the "packages" category
        $categories{packages}{items} ||= [];

        push @{ $categories{packages}{items} }, {
            className   => Scalar::Util::blessed( $package ),
            url         => "func=deployPackage;assetId=" . $package->getId,
            title       => $package->getTitle,
            icon        => $package->getIcon(1),
        };
    }
    # If we have any packages, fill in the package category title
    if ( $categories{packages}{items} && @{ $categories{packages}{items} } ) {
        $categories{packages}{title} = $i18n->get('packages');
    }

    # prototypes
    foreach my $prototype ( @{ WebGUI::Asset::getPrototypeList( $session ) } ) {
        # Check permissions and UI level
        next unless ( $prototype->canView && $prototype->canAdd($session) && $prototype->getUiLevel <= $userUiLevel );

        # Create the "prototypes" category
        $categories{prototypes}{items} ||= [];

        push @{ $categories{prototypes}{items} }, {
            className   => $prototype->get('className'),
            url   => "func=add;className=" . $prototype->get('className') . ";prototype=" . $prototype->getId,
            title => $prototype->getTitle,
            icon => $prototype->getIcon(1),
        };
    }
    # If we have any prototypes, fill in the prototype category title
    if ( $categories{prototypes}{items} && @{ $categories{prototypes}{items} } ) {
        $categories{prototypes}{title} = $i18n->get('prototypes');
    }

    # sort the categories by title
    my @sortedIds   = map { $_->[0] }
                      sort { $a->[1] cmp $b->[1] }
                      map { [ $_, $categories{$_}->{title} ] }
                      grep { $categories{$_}->{items} && @{$categories{$_}->{items}} }
                      keys %categories; # Schwartzian transform

    foreach my $categoryId ( @sortedIds ) {
        my $category    = $categories{ $categoryId };
        my $tab = {
            id          => $categoryId,
            title       => $category->{title},
            items       => [],
        };
        push @{$tabs}, $tab;

        my $items = $category->{items};
        next unless ( ref $items eq 'ARRAY' );    # in case the category is empty
        foreach my $item ( sort { $a->{title} cmp $b->{title} } @{$items} ) {
            push @{ $tab->{items} }, $item;
        }
    }

    # Remove the session asset we added above
    delete $session->{_asset};

    return $tabs;
}

#----------------------------------------------------------------------------

=head2 getTreePaginator ( $asset )

Get a page for the Asset Tree view. Returns a WebGUI::Paginator object 
filled with asset IDs.

=cut

sub getTreePaginator {
    my ( $self, $asset ) = @_;
    my $session = $self->session;

    my $orderByColumn       = $session->form->get( 'orderByColumn' ) 
                            || "lineage"
                            ;
    my $orderByDirection    = lc $session->form->get( 'orderByDirection' ) eq "desc"
                            ? "DESC"
                            : "ASC"
                            ;

    my $recordOffset        = $session->form->get( 'recordOffset' ) || 1;
    my $rowsPerPage         = $session->form->get( 'rowsPerPage' ) || 100;
    my $currentPage         = int ( $recordOffset / $rowsPerPage ) + 1;

    my $p           = WebGUI::Paginator->new( $session, '', $rowsPerPage, 'pn', $currentPage );

    my $orderBy     = $session->db->quote_identifier( $orderByColumn ) . ' ' . $orderByDirection;
    $p->setDataByArrayRef( $asset->getLineage( ['children'], { orderByClause => $orderBy } ) );
    
    return $p;
}


#----------------------------------------------------------------------

=head2 www_getClipboard ( ) 

Get the assets currently on the user's clipboard

=cut

sub www_getClipboard {
    my ( $self ) = @_;
    my $session = $self->session;
    my ( $user, $form ) = $session->quick(qw{ user form });

    my $userOnly = !$form->get('all');

    my $assets      = WebGUI::Asset->getRoot( $session )->getAssetsInClipboard( $userOnly );
    my @assetInfo   = ();
    for my $asset ( @{$assets} ) {
        push @assetInfo, {
            assetId         => $asset->getId,
            url             => $asset->getUrl,
            title           => $asset->menuTitle,
            revisionDate    => $asset->revisionDate,
            icon            => $asset->getIcon("small"),
        };
    }

    return JSON->new->encode( \@assetInfo );
}

#----------------------------------------------------------------------

=head2 www_getCurrentVersionTag ( )

Get information about the current version tag

=cut

sub www_getCurrentVersionTag {
    my ( $self ) = @_;
    my $session = $self->session;
    my $currentUrl    = $session->url->getRequestedUrl;

    my $currentTag  = WebGUI::VersionTag->getWorking( $session, "nocreate" );
    return JSON->new->encode( {} ) unless $currentTag;

    my %tagInfo = (
        tagId       => $currentTag->getId,
        name        => $currentTag->get('name'),
        editUrl     => $currentTag->getEditUrl,
        commitUrl   => $currentTag->getCommitUrl,
        leaveUrl    => $currentUrl . '?op=leaveVersionTag',
    );

    return JSON->new->encode( \%tagInfo );
}

#----------------------------------------------------------------------

=head2 www_getTreeData ( ) 

Get the Tree data for a given asset URL

=cut

sub www_getTreeData {
    my ( $self ) = @_;
    my $session = $self->session;
    my ( $user, $form ) = $session->quick(qw{ user form });

    my $assetUrl    = $form->get('assetUrl');
    my $asset       = WebGUI::Asset->newByUrl( $session, $assetUrl );

    my $i18n        = WebGUI::International->new( $session, "Asset" );
    my $assetInfo   = { assets => [] };
    my $p           = $self->getTreePaginator( $asset );

    for my $assetId ( @{ $p->getPageData } ) {
        my $asset       = WebGUI::Asset->newById( $session, $assetId );

        # Populate the required fields to fill in
        my %fields      = (
            assetId         => $asset->getId,
            url             => $asset->getUrl,
            lineage         => $asset->lineage,
            title           => $asset->menuTitle,
            revisionDate    => $asset->revisionDate,
            childCount      => $asset->getChildCount,
            assetSize       => $asset->assetSize,
            lockedBy        => ($asset->isLockedBy ? $asset->lockedBy->username : ''),
            canEdit         => $asset->canEdit && $asset->canEditIfLocked,
            helpers         => $asset->getHelpers,
        );

        $fields{ className } = {};
        # The asset icon
        $fields{ icon } = $asset->getIcon("small");

        # The asset type (i18n name)
        $fields{ className } = $asset->getName;

        push @{ $assetInfo->{ assets } }, \%fields;
    }

    $assetInfo->{ totalAssets   } = $p->getRowCount;
    $assetInfo->{ sort          } = $session->form->get( 'orderByColumn' );
    $assetInfo->{ dir           } = lc $session->form->get( 'orderByDirection' );
    $assetInfo->{ currentAsset  } = { 
        assetId => $asset->getId,
        url     => $asset->getUrl,
        title => $asset->getTitle,
        icon    => $asset->getIcon("small"),
        helpers => $asset->getHelpers,
    };

    $assetInfo->{ crumbtrail    } = [];
    for my $asset ( @{ $asset->getLineage( ['ancestors'], { returnObjects => 1 } ) } ) {
        push @{ $assetInfo->{crumbtrail} }, {
            title       => $asset->getTitle,
            url         => $asset->getUrl
        };
    }

    $session->http->setMimeType( 'application/json' );

    return to_json( $assetInfo );
}

#----------------------------------------------------------------------

=head2 www_getVersionTags

Get the current version tags a user can join

=cut

sub www_getVersionTags {
    my ( $self ) = @_;
    my $session = $self->session;
    my ( $user ) = $session->quick(qw( user ));
    my $vars    = [];

    my $current = WebGUI::VersionTag->getWorking( $session, "nocreate" );
    my $tags = WebGUI::VersionTag->getOpenTags($session);
    if ( @$tags ) {
        for my $tag ( @$tags ) {
            next unless $user->isInGroup( $tag->get("groupToUse") );
            my $isCurrent   = ( $current && $current->getId eq $tag->getId ) ? 1 : 0;
            my $icon        = $isCurrent
                            ? $session->url->extras( 'icon/tag_green.png' )
                            : $session->url->extras( 'icon/tag_blue.png' )
                            ;
            push @$vars, {
                tagId       => $tag->getId,
                name        => $tag->get("name"),
                isCurrent   => $isCurrent,
                joinUrl     => $tag->getJoinUrl,
                editUrl     => $tag->getEditUrl,
                icon        => $icon,
            };
        }
    }

    return JSON->new->encode( $vars );
}

#----------------------------------------------------------------------

=head2 www_processAssetHelper ( )

Process the given asset helper with the given asset

=cut

sub www_processAssetHelper {
    my ( $self ) = @_;
    my $session = $self->session;
    my ( $form ) = $session->quick(qw{ form });

    my $assetId = $form->get('assetId');
    my $class   = $form->get('className');
    WebGUI::Pluggable::load( $class );
    my $asset   = WebGUI::Asset->newById( $session, $assetId );
    return JSON->new->encode( $class->process( $asset ) );
}

#----------------------------------------------------------------------

=head2 www_view ( session )

Show the main Admin console wrapper

=cut

sub www_view {
    my ( $self ) = @_;
    my $session = $self->session;
    my ( $user, $url, $style ) = $session->quick(qw{ user url style });

    my $var;
    $var->{backToSiteUrl} = $url->page;

    # temporary! We are now in admin mode!
    $session->var->switchAdminOn;

    # Add vars for AdminBar
    $var->{adminPlugins} = $self->getAdminPluginTemplateVars;
    $var->{newContentTabs} = $self->getNewContentTemplateVars;

    # Add vars for current user
    $var->{username}   = $user->username;
    $var->{profileUrl} = $user->getProfileUrl;
    $var->{logoutUrl}  = $url->page("op=auth;method=logout");

    $var->{viewUrl} = $url->page;
    $var->{homeUrl} = WebGUI::Asset->getDefault( $session )->getUrl;

    # All this needs to be template attachments
    $style->setLink( $url->extras('yui/build/button/assets/skins/sam/button.css'), {type=>"text/css",rel=>"stylesheet"});
    $style->setLink( $url->extras('yui/build/menu/assets/skins/sam/menu.css'), {type=>"text/css",rel=>"stylesheet"});
    $style->setLink( $url->extras('yui/build/tabview/assets/skins/sam/tabview.css'), {type=>"text/css",rel=>"stylesheet"});
    $style->setLink( $url->extras('yui/build/paginator/assets/skins/sam/paginator.css'), {rel=>'stylesheet', type=>'text/css'});
    $style->setLink( $url->extras('yui/build/datatable/assets/skins/sam/datatable.css'), {rel=>'stylesheet', type=>'text/css'});
    $style->setLink( $url->extras('yui/build/container/assets/skins/sam/container.css'), {rel=>'stylesheet', type=>'text/css'});
    $style->setLink( $url->extras('yui/build/menu/assets/skins/sam/menu.css'), {rel=>'stylesheet', type=>'text/css'});
    #$style->setLink( $url->extras('yui-webgui/build/assetManager/assetManager.css' ), { rel => "stylesheet", type => 'text/css' } );
    $style->setLink( $url->extras('admin/admin.css'), { type=>'text/css', rel=>'stylesheet'} );
    $style->setScript($url->extras('yui/build/yahoo-dom-event/yahoo-dom-event.js'));
    $style->setScript($url->extras('yui/build/utilities/utilities.js'));
    $style->setScript($url->extras('yui/build/element/element-min.js'));
    $style->setScript( $url->extras( 'yui/build/paginator/paginator-min.js ' ) );
    $style->setScript($url->extras('yui/build/animation/animation-min.js'));
    $style->setScript( $url->extras( 'yui/build/datasource/datasource-min.js ' ) );
    $style->setScript( $url->extras( 'yui/build/connection/connection-min.js ' ) );
    $style->setScript( $url->extras( 'yui/build/datatable/datatable-min.js ' ) );
    $style->setScript( $url->extras( 'yui/build/dragdrop/dragdrop-min.js' ) );
    $style->setScript( $url->extras( 'yui/build/container/container-min.js' ) );
    $style->setScript($url->extras('yui/build/tabview/tabview-min.js'));
    $style->setScript($url->extras('yui/build/menu/menu-min.js'));
    $style->setScript($url->extras('yui/build/button/button-min.js'));
    $style->setScript( $url->extras( 'yui/build/json/json-min.js' ) );
    $style->setScript( $url->extras( 'yui-webgui/build/i18n/i18n.js' ) );
    $style->setScript($url->extras('admin/admin.js'));

    # Use the template in our __DATA__ block
    my $tmpl    = WebGUI::Asset::Template::HTMLTemplate->new( $session );

    # Use the blank style
    my $output = $style->process( $tmpl->process( $tdata, $var ), "PBtmplBlankStyle000001" );

    return $output;
} ## end sub www_view

1;

__DATA__
<dl id="adminBar" class="accordion-menu">
    <dt id="adminConsole" class="a-m-t clickable">^International("admin console","AdminConsole");</dt>
    <dd class="a-m-d">
        <ul id="admin_list">
            <TMPL_LOOP adminPlugins>
            <li class="clickable with_icon" style="background-image: url(<tmpl_var icon.small default="^Extras('icon/cog.png');">);">
                <a href="<tmpl_var url>" target="view"><tmpl_var title></a>
            </li>
            </TMPL_LOOP>
        </ul>
    </dd>
    <!-- placeholder for version tags -->
    <dt id="versionTags" class="a-m-t clickable">^International('version tags','VersionTag');</dt>
    <dd class="a-m-d">
        <div id="versionTagItems"></div>
    </dd>
    <!-- placeholder for clipboard -->
    <dt id="clipboard" class="a-m-t clickable">^International('1082','Asset');</dt>
    <dd class="a-m-d">
        <input type="checkbox" id="clipboardShowAll" />
        <label for="clipboardShowAll" id="clipboardShowAllLabel">^International('show all','WebGUI');</label>
        <div id="clipboardItems"></div>
    </dd>
    <!-- placeholder for asset helpers -->
    <dt id="assetHelpers" class="a-m-t clickable">^International('asset helpers','WebGUI');</dt>
    <dd id="assetHelpers_pane" class="a-m-d">
        <h1 class="with_icon" id="helper_asset_name"></h1>
        <ul id="helper_list">
        </ul>
        <h2 class="with_icon" style="background-image: url(^Extras(icon/clock.png););">^International('history','Asset');</h2>
        <ul id="history_list">
        </ul>
    </dd>
    <!-- placeholder for new content menu -->
    <dt id="newContent" class="a-m-t clickable">^International('1083','Macro_AdminBar');</dt>
    <dd class="a-m-d">
        <dl id="newContentBar" class="accordion-menu">
            <tmpl_loop newContentTabs>
            <dt class="a-m-t clickable" id="<tmpl_var id>"><tmpl_var title></dt>
            <dd class="a-m-d"><div class="bd">
                <ul class="new_content_list">
                <tmpl_loop items>
                    <li class="clickable with_icon" onclick="window.admin.addNewContent('<tmpl_var url>'); return false" style="background-image: url(<tmpl_var icon default="^Extras('icon/cog.png');">);">
                        <tmpl_var title>
                    </li>
                </tmpl_loop>
                </ul>
            </div></dd>
            </tmpl_loop>
        </dl>
    </dd>
</dl>

<div id="wrapper" class="yui-skin-sam">
    <div id="infoMessageContainer" style="display: none" >
        <div id="infoMessage" class="with_icon" style="background-image: url(^Extras(icon/information.png););"></div>
    </div>
    <div id="versionTag" style="display: none">
        <div style="float: right">
            <span href="#" target="view" id="publishTag" class="clickable">^International('publish','VersionTag');</span>
            | <span href="#" target="view" id="leaveTag" class="clickable">^International('leave','VersionTag');</span>
        </div>
        <a href="#" id="editTag" class="with_icon" target="view" style="background-image: ^Extras(icon/tag_blue.png);;"></a>
    </div>
    <div id="user">
        <div style="float: right">
            <a href="<tmpl_var homeUrl>^International('back to site','VersionTag');</a> 
            | <a href="<tmpl_var logoutUrl>">^International('log out','WebGUI');</a>
        </div>
        <a href="<tmpl_var userEditUrl>" target="view" class="with_icon" style="background-image: url(^Extras(icon/user.png););">
            <tmpl_var userName>
        </a>
    </div>

    <div id="tabBar" class="yui-navset">
        <ul class="yui-nav">
            <li class="selected"><a href="#tab1"><em>View</em></a></li>
            <li><a href="#tab2"><em>Tree</em></a></li>
        </ul>
        <div id="tab_wrapper">
            <div id="locationBar">
                <span id="left">
                    <input type="button" id="backButton" value="&lt;" /><input type="button" id="forwardButton" value="&gt;" />
                </span>
                <div id="location">
                    <input type="text" id="locationUrl" value="" />
                    <span id="locationTitle"></span>
                </div>
                <span id="right">
                    <input type="checkbox" id="searchDialogButton" value="S" /><input type="button" id="homeButton" value="H" />
                </span>
            </div>
            <div id="tab_content_wrapper">
                <div id="search" style="display: none">
                    <input type="button" id="searchButton" value="^International("search","Asset");" />
                    <input type="text" id="searchKeywords" />
                    <ul id="searchFilters"></ul>
                    <input type="button" id="searchFilterAdd" value="Add Filter" />
                    <select id="searchFilterSelect">
                        <option value="ownerUserId">Owner</option>
                        <option value="lineage">Parent</option>
                        <option value="title">Title</option>
                        <option value="className">Type</option>
                    </select>
                </div>
                <div id="yui-tabs" class="yui-content">
                    <div id="viewTab"><iframe src="<tmpl_var viewUrl>" name="view"></iframe></div>
                    <div id="treeTab">
                        <div id="treeCrumbtrail"></div>
                        <div id="treeDataTableContainer"></div>
                        <div id="treePagination"></div>
                    </div>
                </div>
            </div>
        </div>
    </div>


</div>

<script type="text/javascript">
YAHOO.util.Event.onDOMReady( function() { 
    window.admin = new WebGUI.Admin( {
        homeUrl : '<tmpl_var homeUrl>'
    } );
    // Add all asset helpers to the admin instance
    document.body.className="yui-skin-sam";
} );

</script>
