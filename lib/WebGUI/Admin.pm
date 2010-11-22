package WebGUI::Admin;

# The new WebGUI Admin console

=head1 NAME

WebGUI::Admin - The WebGUI Admin Console

=head1 DESCRIPTION

The WebGUI Admin Console handles editing the Assets in the site, as well
as administrative tasks like managing Users and Groups.

The base Admin Console does Assets and displays the list of Admin Plugins.
Admin Plugins do the administrative tasks.

=head1 SEE ALSO

 WebGUI::Admin::Plugin
 WebGUI::Operation
 WebGUI::AssetHelper

=cut

use Moose;
use JSON qw( from_json to_json );
use namespace::autoclean;
use Scalar::Util;
use Search::QueryParser;
use WebGUI::Pluggable;
use WebGUI::Macro;
use WebGUI::Search;

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

=head1 METHODS

=cut

#----------------------------------------------------------------------

=head2 getAdminPluginTemplateVars

Return an arrayref of hashrefs to define the Admin Plugins the current 
user is allowed to use.

=cut

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
            my $plugin = $funcDef->{className}->new( $session, id => $funcId, $funcDef );
            next unless $plugin->canView;
            $var = {
                id              => $funcId,
                title           => $plugin->title,
                icon            => $plugin->icon,
                'icon.small'    => $plugin->iconSmall,
            };

            # build the list of processed items
            $processed{$plugin->title} = $var;
        }
        # Don't know what we have (old admin console functions)
        # NOTE: This usage is deprecated and will be removed in a future version
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
            if ( $funcDef->{uiLevel} > $user->get("uiLevel") ) {
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

=head2 getAssetTypes ( )

Get a hash of className => info pairs containing information about the
asset class. Info will include at least the following keys:

    title       => The i18n title of the asset
    icon        => The small icon
    icon_full   => The full sized icon
    uiLevel     => The UI Level of the asset
    canAdd      => True if the current user can add the asset
    url         => URL to add the asset
    category    => A string or an arrayref of categories

=cut

sub getAssetTypes {
    my ( $self ) = @_;
    my $session = $self->session;
    my ( $config ) = $session->quick(qw( config ));

    my %configList = %{ $config->get('assets') };
    my %assetList  = ();
    for my $class ( keys %configList ) {
        my $assetConfig = $configList{ $class };

        # Create a dummy asset
        my $dummy = WebGUI::Asset->newByPropertyHashRef( $session, { dummy => 1, className => $class } );
        next unless defined $dummy;

        $assetList{ $class } = {
            ( %$assetConfig ),
            url         => 'func=add;className=' . $class,
            icon        => $dummy->getIcon(1), # default icon is small for back-compat
            icon_full   => $dummy->getIcon,
            title       => $dummy->getTitle,
            uiLevel     => $dummy->getUiLevel( $assetConfig->{uiLevel} ),
            canAdd      => $dummy->canAdd( $session ),
        };
    }

    return %assetList;
}

#----------------------------------------------------------------------

=head2 getKeywordString ( keywordString )

Munge the keyword string from the user into something mysql will Do The
Right Thing with

=cut

# Stolen from WebGUI::Search->search
sub getKeywordString {
    my ( $self, $keywords ) = @_;

    # do wildcards for people like they'd expect unless they are doing it themselves
    unless ($keywords =~ m/"|\*/) {
        # split into 'words'.  Ideographic characters (such as Chinese) are
        # treated as distinct words.  Everything else is space delimited.
        my @terms = grep { $_ ne q{} } split /\s+|(\p{Ideographic})/, $keywords;
        for my $term (@terms) {
            # we add padding to ideographic characters to avoid minimum word length limits on indexing
            if ($term =~ /\p{Ideographic}/) {
                $term = q{''}.$term.q{''};
            }
            $term .= q{*};
            next if WebGUI::Search->_isStopword( $term );
            next
                if $term =~ /^[+-]/;
            $term = q{+} . $term;
        }
        $keywords = join q{ }, @terms;
    }

    return $keywords;
}

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
    my $userUiLevel = $user->get('uiLevel');
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
    my %assetList   = $self->getAssetTypes;
    foreach my $assetClass ( keys %assetList ) {
        my $assetConfig = $assetList{$assetClass};

        next unless $assetConfig->{canAdd};
        next unless $assetConfig->{uiLevel} <= $userUiLevel;

        # Add the asset to all categories it should appear in
        my @assetCategories = ref $assetConfig->{category} ? @{ $assetConfig->{category} } : $assetConfig->{category};
        for my $category (@assetCategories) {
            next unless exists $categories{$category};
            $categories{$category}{items} ||= [];
            push @{ $categories{$category}{items} }, $assetConfig;
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

=head2 getSearchPaginator ( queryString )

Get a paginator for searching with the given queryString. 

=cut

sub getSearchPaginator {
    my ( $self, $queryString ) = @_;
    my $session = $self->session;

    my $sql = 'SELECT assetId FROM assetIndex JOIN asset USING (assetId) WHERE '
            . ' ( ' . $self->getSqlFromQueryString( $queryString ) . ' ) '
            ;

    my $p   = WebGUI::Paginator->new( $session );
    $p->setDataByQuery( $sql );
    return $p;
}

#----------------------------------------------------------------------------

=head2 getSqlFromQueryString ( queryString )

Parse the query string and return a SQL boolean clause suitable to be used
as a WHERE clause. Does not return WHERE, as you could also use it for HAVING

=cut

sub getSqlFromQueryString {
    my ( $self, $queryString ) = @_;

    my $dbh         = $self->session->db->dbh;
    my $sqp         = Search::QueryParser->new( defField => 'keywords' );
    my $query       = $sqp->parse( $queryString );

    my %isValidOp;
    @isValidOp{qw( = != < > <= >= : )} = 1;

    # Recursion is recursive
    my $part        = sub { 
        my ( $query, $conj ) = @_;
        my @parts;
        for my $part ( @$query ) {
            if ( ref $part->{value} ) { 
                push @parts, $self->getSqlFromQueryString( $_ );
            } 
            elsif ( $part->{field} eq 'keywords' ) {
                push @parts, "MATCH (" . $dbh->quote_identifier($part->{field}) . ") AGAINST ("
                            . $dbh->quote( $self->getKeywordString( $part->{value} ) )
                            . ")";
            }
            else {
                next unless $isValidOp{ $part->{op} };
                if ( $part->{op} eq ':' ) {
                    my $value   = '%' . $part->{value} . '%';
                    push @parts, join " ",
                        $dbh->quote_identifier($part->{field}), 
                        'LIKE',
                        $dbh->quote($value),
                        ;
                }
                elsif ( $isValidOp{ $part->{op} } ) {
                    push @parts, join " ",
                        $dbh->quote_identifier($part->{field}),
                        $part->{op},
                        $dbh->quote($part->{value}),
                        ;
                }
            }
        }
        return join " $conj ", @parts;
    };
    my $must    = $query->{'+'} ? '(' . $part->( $query->{'+'}, 'AND' ) . ')' : undef;
    my $mustNot = $query->{'-'} ? 'NOT ( ' . $part->( $query->{'-'}, 'OR' ) . ')' : undef;
    my $may     = $query->{''}  ? $part->( $query->{''}, 'OR' ) : undef;

    my $sql     = $must . ( $must && $mustNot ? " AND " : '' ) . $mustNot
                . ( $must || $mustNot ? " OR " : '' ) . $may
                ;
    return $sql;
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

=head2 www_findUser ( )

Find a user based on a partial name, username, alias, or e-mail address

=cut

sub www_findUser {
    my ( $self ) = @_;
    my $session = $self->session;
    my ( $form, $db, $url ) = $session->quick(qw( form db url ));

    my $query   = '%' . $form->get('query') . '%';

    my @places; # Places to look
    for my $col ( 'username', 'alias', 'firstName', 'lastName', 'CONCAT(firstName," ",lastName)' ) {
        push @places, $col . " LIKE ?";
    }

    my $sql     = 'SELECT userId, CONCAT(firstName,lastName) AS name, username, alias, avatar
                FROM users JOIN userProfileData USING (userId) WHERE ' . join( ' || ', @places );
    my $params  = [ ( $query ) x scalar @places ];

    my $sth = $db->read( $sql, $params );
    my @results;
    while ( my $result = $sth->hashRef ) {
        $result->{avatar} ||= $url->extras('icon/user.png');
        push @results, $result;
    }

    my $output = JSON->new->encode( { results => \@results } );
    return $output;
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
            icon            => $asset->getIcon("small"),
            className       => $asset->getName,
        );

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

    $session->response->content_type( 'application/json' );

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

=head2 www_processPlugin ( )

Process the given admin console plugin

=cut

sub www_processPlugin {
    my ( $self ) = @_;
    my $session = $self->session;
    my ( $form ) = $session->quick(qw{ form });

    my $id      = $form->get('id');
    my $def     = $session->config->get('adminConsole/' . $id );
    return JSON->new->encode( { error => 'No such admin plugin: ' . $id } )
        unless $def;
    my $class   = $def->{className};
    WebGUI::Pluggable::load( $class );
    return JSON->new->encode( $class->process( $session ) );
}

#----------------------------------------------------------------------

=head2 www_searchAssets ( ) 

Search the asset tree for the given keywords and filters

=cut

sub www_searchAssets {
    my ( $self ) = @_;
    my $session = $self->session;
    my ( $user, $form ) = $session->quick(qw{ user form });

    # Get the search
    my $queryString = $form->get('query');
    return to_json( {} ) unless $queryString;

    my $i18n        = WebGUI::International->new( $session, "Asset" );
    my $assetInfo   = { assets => [] };
    my $p           = $self->getSearchPaginator( $queryString );

    for my $result ( @{ $p->getPageData } ) {
        my $assetId = $result->{assetId};
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
            icon            => $asset->getIcon('small'),
            className       => $asset->getName,
        );

        push @{ $assetInfo->{ assets } }, \%fields;
    }

    $assetInfo->{ totalAssets   } = $p->getRowCount;
    $assetInfo->{ sort          } = $session->form->get( 'orderByColumn' );
    $assetInfo->{ dir           } = lc $session->form->get( 'orderByDirection' );

    $session->response->content_type( 'application/json' );

    return to_json( $assetInfo );
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
    $session->switchAdminOn;

    # Add vars for AdminBar
    $var->{adminPlugins} = $self->getAdminPluginTemplateVars;
    $var->{newContentTabs} = $self->getNewContentTemplateVars;

    # Add vars for current user
    $var->{username}   = $user->username;
    $var->{profileUrl} = $user->getProfileUrl;
    $var->{logoutUrl}  = $url->page("op=auth;method=logout");

    $var->{viewUrl} = $url->page;
    $var->{homeUrl} = WebGUI::Asset->getDefault( $session )->getUrl;

    # Asset types for later use
    $var->{assetTypesJson} = JSON->new->encode( { $self->getAssetTypes } );

    # All this needs to be template attachments
    $style->setCss( $url->extras('yui/build/button/assets/skins/sam/button.css'));
    $style->setCss( $url->extras('yui/build/menu/assets/skins/sam/menu.css'));
    $style->setCss( $url->extras('yui/build/tabview/assets/skins/sam/tabview.css'));
    $style->setCss( $url->extras('yui/build/paginator/assets/skins/sam/paginator.css'));
    $style->setCss( $url->extras('yui/build/datatable/assets/skins/sam/datatable.css'));
    $style->setCss( $url->extras('yui/build/container/assets/skins/sam/container.css'));
    $style->setCss( $url->extras('yui/build/autocomplete/assets/skins/sam/autocomplete.css'));
    $style->setCss( $url->extras('yui/build/menu/assets/skins/sam/menu.css'));
    $style->setCss( $url->extras('admin/admin.css'));
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
    $style->setScript($url->extras('yui/build/autocomplete/autocomplete-min.js'));
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
                <TMPL_IF className>
                    <span onclick="window.admin.requestPlugin({ className : '<tmpl_var className>' })">
                        <tmpl_var title>
                    </span>
                <TMPL_ELSE>
                    <a href="<tmpl_var url>" target="view"><tmpl_var title></a>
                </TMPL_IF>
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
            <a href="<tmpl_var homeUrl>">^International('back to site','VersionTag');</a> 
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
                    <input type="text" id="locationInput" value="" />
                    <span id="locationTitle"></span>
                </div>
                <span id="right">
                    <input type="button" id="searchDialogButton" value="S" /><input type="button" id="homeButton" value="H" />
                </span>
            </div>
            <div id="tab_content_wrapper">
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

<!-- placeholder for search form
    this form is cloned by javascript and placed into the tab div when a
    search is requested -->
<div id="searchForm" style="display: none">
    <form>
        <input type="button" class="searchButton" name="searchButton" value="^International("search","Asset");" />
        <input type="text" class="searchKeywords" name="searchKeywords" />
        <ul class="searchFilters"></ul>
        <input type="button" name="searchFilterAdd" class="searchFilterAdd" value="Add Filter" />
        <select name="searchFilterSelect">
            <option value="ownerUserId">Owner</option>
            <option value="lineage">Parent</option>
            <option value="title">Title</option>
            <option value="className">Type</option>
        </select>
    </form>
</div>

</div>

<script type="text/javascript">
YAHOO.util.Event.onDOMReady( function() { 
    window.admin = new WebGUI.Admin( {
        homeUrl : '<tmpl_var homeUrl>',
        assetTypes : <tmpl_var assetTypesJson>
    } );
    document.body.className="yui-skin-sam";
} );

</script>
