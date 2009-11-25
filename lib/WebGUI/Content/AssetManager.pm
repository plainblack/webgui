package WebGUI::Content::AssetManager;

use strict;

use JSON qw( from_json to_json );
use URI;
use WebGUI::Form;
use WebGUI::Paginator;
use WebGUI::Utility;

#----------------------------------------------------------------------------

=head2 getClassSelectBox ( session )

Gets a select box to choose a class name.

=cut

sub getClassSelectBox {
    my $session     = shift;
    my $i18n        = WebGUI::International->new($session, 'Asset');
    
    tie my %classes, "Tie::IxHash", (
        ""  => $i18n->get("Any Class"), 
        $session->db->buildHash("select distinct(className) from asset"),
    );
    delete $classes{"WebGUI::Asset"}; # don't want to search for the root asset

    my $className = $session->scratch->get('assetManagerSearchClassName') || $session->form->process("class","className");
    $session->scratch->set('assetManagerSearchClassName', $className);
    return WebGUI::Form::selectBox( $session, {
        name            => "class",
        value           => $className,
        defaultValue    => "",
        options         => \%classes,
    });
}

#----------------------------------------------------------------------------

=head2 getCurrentAsset ( session )

Returns the asset we would be looking at if we weren't looking at the Asset
Manager.

=cut

sub getCurrentAsset {
    my $session     = shift;
    return WebGUI::Asset->newByUrl( $session );
}

#----------------------------------------------------------------------------

=head2 getHeader ( session )

Get a header to pick "Manage" or "Search". Add other things later maybe?

=cut

sub getHeader {
    my $session     = shift;
    my $output      = '';
    my $i18n        = WebGUI::International->new( $session, "Asset" );

    if ( $session->form->get( 'method' ) eq "search" ) {
        $output     .= '<div style="float: right">'
                    . join( " | ",
                        q{<a href="?op=assetManager;method=manage">} . $i18n->get( 'manage' ) . q{</a>},
                        q{<strong>} . $i18n->get( "search" ) . q{</strong>},
                    )
                    . q{</div>}
                    ;
    }
    else {
        $output     .= '<div style="float: right">'
                    . join( " | ", 
                        q{<strong>} . $i18n->get( "manage" ) . q{</strong>},
                        q{<a href="?op=assetManager;method=search">} . $i18n->get( "search" ) . q{</a>},
                    )
                    . q{</div>}
                    ;
    }

    return $output;
}

#----------------------------------------------------------------------------

=head2 getManagerPaginator ( session )

Get a page for the Asset Manager view. Returns a WebGUI::Paginator object 
filled with asset IDs.

=cut

sub getManagerPaginator {
    my $session             = shift;
    my $asset               = getCurrentAsset( $session );

    my $orderByColumn       = $session->form->get( 'orderByColumn' ) 
                            || "lineage"
                            ;
    my $orderByDirection    = lc $session->form->get( 'orderByDirection' ) eq "desc"
                            ? "DESC"
                            : "ASC"
                            ;

    my $recordOffset        = $session->form->get( 'recordOffset' ) || 1;
    my $rowsPerPage         = $session->form->get( 'rowsPerPage' ) || 25;
    my $currentPage         = int ( $recordOffset / $rowsPerPage ) + 1;

    my $p           = WebGUI::Paginator->new( $session, '', $rowsPerPage, 'pn', $currentPage );

    my $orderBy     = $session->db->dbh->quote_identifier( $orderByColumn ) . ' ' . $orderByDirection;
    $p->setDataByArrayRef( $asset->getLineage( ['children'], { orderByClause => $orderBy } ) );
    
    return $p;
}

#----------------------------------------------------------------------------

=head2 getSearchPaginator ( session, query ) 

Get a page for the Asset Search view. Returns a WebGUI::Paginator object
filled with asset IDs.

=cut

sub getSearchPaginator {
    my $session     = shift;
    my $query       = shift;
    my %parms;
    
    my $s       = WebGUI::Search->new( $session, 0 );
    $s->search( {
        keywords        => $query->{ keywords },
        classes         => $query->{ classes },
    } );

    my $queryString = 'op=assetManager;method=search;keywords=' . $query->{ keywords };
    for my $class ( @{ $query->{ classes } } ) {
        $queryString    .= ';class=' . $class;
    }

    my $pageNumber  = $session->scratch->get('assetManagerSearchPageNumber') || $session->form->get('pn');
    my $p           = $s->getPaginatorResultSet( $session->url->page( $queryString ), undef, $pageNumber );

    $session->scratch->set('assetManagerSearchPageNumber', $pageNumber);
    return $p;
}

#----------------------------------------------------------------------------

=head2 getMoreMenu ( session, label )

Gets the "More" menu with the specified label.

=cut

sub getMoreMenu {
    my $session         = shift;
    my $label           = shift || "More";
    my $userUiLevel     = $session->user->profileField("uiLevel");
    my $toolbarUiLevel  = $session->config->get("assetToolbarUiLevel");
    my $i18n            = WebGUI::International->new( $session, "Asset" );

    ### The More menu
    my @more_fields     = ();
    # FIXME: Add a show callback with the record as first argument. If it
    # returns true, the URL will be shown.
    # These links are shown based on UI level
    if ( $userUiLevel >= $toolbarUiLevel->{ "changeUrl" } ) {
        push @more_fields, {
            url     => '<url>?func=changeUrl;proceed=manageAssets', 
            label   => $i18n->get( 'change url' ),
        };
    }

    if ( $userUiLevel >= $toolbarUiLevel->{ "editBranch" } ) {
        push @more_fields, {
            url     => '<url>?func=editBranch', 
            label   => $i18n->get( 'edit branch' ),
        };
    }

    if ( $userUiLevel >= $toolbarUiLevel->{ "shortcut" } ) {
        push @more_fields, {
            url     => '<url>?func=createShortcut;proceed=manageAssets', 
            label   => $i18n->get( 'create shortcut' ),
        };
    }

    if ( $userUiLevel >= $toolbarUiLevel->{ "revisions" } ) {
        push @more_fields, {
            url     => '<url>?func=manageRevisions',
            label   => $i18n->get( 'revisions' ),
        };
    }

    if ( $userUiLevel >= $toolbarUiLevel->{ "view" } ) {
        push @more_fields, {
            url     => '<url>',
            label   => $i18n->get( 'view' ),
        };
    }

    if ( $userUiLevel >= $toolbarUiLevel->{ "edit" } ) {
        push @more_fields, {
            url     => '<url>?func=edit;proceed=manageAssets',
            label   => $i18n->get( 'edit' ),
        };
    }

    if ( $userUiLevel >= $toolbarUiLevel->{ "lock" } ) {
        push @more_fields, {
            url     => '<url>?func=lock;proceed=manageAssets',
            label   => $i18n->get( 'lock' ),
        };
    }

    if ( $session->config->get("exportPath") && $userUiLevel >= $toolbarUiLevel->{"export"} ) {
        push @more_fields, {
            url     => '<url>?func=export',
            label   => $i18n->get( 'Export Page' ),
        };
    }

    return to_json \@more_fields;
}

#----------------------------------------------------------------------------

=head2 handler ( session )

Handle the session, if we can. Otherwise pass it on.

Check permissions

=cut

sub handler {
    my ( $session ) = @_;
 
    if ( $session->form->get( 'op' ) eq 'assetManager' && getCurrentAsset( $session ) ) {
        $session->asset(getCurrentAsset($session));

        return $session->privilege->noAccess unless getCurrentAsset( $session )->canEdit;

        my $method  = $session->form->get( 'method' )
                    ? 'www_' . $session->form->get( 'method' )
                    : 'www_manage'
                    ;
        
        # Validate the method name
        if ( !__PACKAGE__->can( $method ) ) {
            return "Invalid method";
        }
        else {
            return __PACKAGE__->can( $method )->( $session );
        }
    }
    else {
        return;
    }
}

#----------------------------------------------------------------------------

=head2 www_ajaxGetManagerPage ( session )

Get a page of Asset Manager data, ajax style. Returns a JSON array to be
formatted in a WebGUI.AssetManager data table.

=cut

sub www_ajaxGetManagerPage {
    my $session         = shift;
    my $i18n            = WebGUI::International->new( $session, "Asset" );
    my $assetInfo       = { assets => [] };
    my $p               = getManagerPaginator( $session );

    for my $assetId ( @{ $p->getPageData } ) {
        my $asset       = WebGUI::Asset->newByDynamicClass( $session, $assetId );
        
        # Populate the required fields to fill in
        my %fields      = (
            assetId         => $asset->getId,
            url             => $asset->getUrl,
            lineage         => $asset->get( "lineage" ),
            title           => $asset->get( "title" ),
            revisionDate    => $asset->get( "revisionDate" ),
            childCount      => $asset->getChildCount,
            assetSize       => $asset->get( 'assetSize' ),
            lockedBy        => $asset->get( 'isLockedBy' ),
            actions         => $asset->canEdit && $asset->canEditIfLocked,
        );

        $fields{ className } = {};
        # The asset icon
        my $icon    = [ grep { $_->{ icon } } @{ $asset->definition( $session ) } ]->[ 0 ]->{ icon };
        $fields{ icon } = $session->url->extras( '/assets/small/' . $icon );

        # The asset type (i18n name)
        my $type    = [ grep { $_->{ assetName } } @{ $asset->definition( $session ) } ]->[ 0 ]->{ assetName };
        $fields{ className } = $type;

        push @{ $assetInfo->{ assets } }, \%fields;
    }

    $assetInfo->{ totalAssets   } = $p->getRowCount;
    $assetInfo->{ sort          } = $session->form->get( 'orderByColumn' );
    $assetInfo->{ dir           } = lc $session->form->get( 'orderByDirection' );
    
    $session->http->setMimeType( 'application/json' );
    return to_json( $assetInfo );
}

#----------------------------------------------------------------------------

=head2 www_manage ( session )

Show the main screen of the asset manager, paginated. Also load the 
JavaScript that will take over if the browser has the cojones.

=cut

sub www_manage {
    my ( $session ) = @_;
    my $ac              = WebGUI::AdminConsole->new( $session, "assets" );
    my $currentAsset    = getCurrentAsset( $session );
    my $i18n            = WebGUI::International->new( $session, "Asset" );

    ### Do Action
    my @assetIds    = $session->form->get( 'assetId' );

    if ( $session->form->get( 'action_update' ) ) {
        for my $assetId ( @assetIds ) {
            my $asset       = WebGUI::Asset->newByDynamicClass( $session, $assetId );
            next unless $asset;
            my $rank        = $session->form->get( $assetId . '_rank' );
            next unless $rank; # There's no such thing as zero

            $asset->setRank( $rank );
        }
    }
    elsif ( $session->form->get( 'action_delete' ) ) {
        for my $assetId ( @assetIds ) {
            my $asset       = WebGUI::Asset->newByDynamicClass( $session, $assetId );
            next unless $asset;
            $asset->trash;
        }
    }
    elsif ( $session->form->get( 'action_cut' ) ) {
        for my $assetId ( @assetIds ) {
            my $asset       = WebGUI::Asset->newByDynamicClass( $session, $assetId );
            next unless $asset;
            $asset->cut;
        }
    }
    elsif ( $session->form->get( 'action_copy' ) ) {
        for my $assetId ( @assetIds ) {
            # Copy == Duplicate + Cut
            my $asset       = WebGUI::Asset->newByDynamicClass( $session, $assetId);
            my $newAsset    = $asset->duplicate( { skipAutoCommitWorkflows => 1 } );
            $newAsset->update( { title => $newAsset->getTitle . ' (copy)' } );
            $newAsset->cut;
        }
    }
    elsif ( $session->form->get( 'action_duplicate' ) ) {
        for my $assetId ( @assetIds ) {
            my $asset       = WebGUI::Asset->newByDynamicClass( $session, $assetId );
            next unless $asset;
            $asset->duplicate( { skipAutoCommitWorkflows => 1 } );
        }
    }

    # Handle Auto Request Commit setting
    if ($session->setting->get("autoRequestCommit")) {
        # Make sure version tag hasn't already been committed by another process
        my $versionTag = WebGUI::VersionTag->getWorking($session, "nocreate");

        if ($versionTag && $session->setting->get("skipCommitComments")) {
            $versionTag->requestCommit;
        }
        elsif ($versionTag) {
            $session->http->setRedirect(
                $currentAsset->getUrl("op=commitVersionTag;tagId=".WebGUI::VersionTag->getWorking($session)->getId)
            );
            return undef;
        }
    }

    # Show the page
    # i18n we'll need later
    # TODO: Add all i18n to this hash so we can better format our JS code
    my %i18n    = (
        "select all"    => $i18n->get( "select all" ),
    );

    # Add script and stylesheets
    $session->style->setLink( $session->url->extras('yui/build/datatable/assets/skins/sam/datatable.css'), {rel=>'stylesheet', type=>'text/css'});
    $session->style->setLink( $session->url->extras('yui/build/menu/assets/skins/sam/menu.css'), {rel=>'stylesheet', type=>'text/css'});
    $session->style->setLink( $session->url->extras( 'yui-webgui/build/assetManager/assetManager.css' ), { rel => "stylesheet", type => 'text/css' } );
    $session->style->setScript( $session->url->extras( 'yui/build/yahoo-dom-event/yahoo-dom-event.js' ) );
    $session->style->setScript( $session->url->extras( 'yui/build/element/element-beta-min.js ' ) );
    $session->style->setScript( $session->url->extras( 'yui/build/connection/connection-min.js ' ) );
    $session->style->setScript( $session->url->extras( 'yui/build/datasource/datasource-beta-min.js ' ) );
    $session->style->setScript( $session->url->extras( 'yui/build/datatable/datatable-beta-min.js ' ) );
    $session->style->setScript( $session->url->extras( 'yui/build/container/container-min.js' ) );
    $session->style->setScript( $session->url->extras( 'yui/build/menu/menu-min.js' ) );
    $session->style->setScript( $session->url->extras( 'yui-webgui/build/assetManager/assetManager.js' ) );
    $session->style->setScript( $session->url->extras( 'yui-webgui/build/form/form.js' ) );

    my $extras      = $session->url->extras;
    $session->style->setRawHeadTags( <<ENDHTML );
    <script type="text/javascript">
        WebGUI.AssetManager.extrasUrl   = '$extras';
        YAHOO.util.Event.onDOMReady( WebGUI.AssetManager.initManager );
    </script>
ENDHTML
    my $output          = '<div class="yui-skin-sam" id="assetManager">' . getHeader( $session );

    ### Crumbtrail
    my $crumb_markup    = '<li><a href="%s">%s</a> &gt;</li>';
    my $ancestors       = $currentAsset->getLineage( ['ancestors'], { returnObjects => 1 } );

    $output             .=  '<ol id="crumbtrail">';
    for my $asset ( @{ $ancestors } ) {
        $output .= sprintf $crumb_markup, 
                $asset->getUrl( 'op=assetManager;method=manage' ),
                $asset->get( "menuTitle" ),
                ;
    }

    # And ourself
    $output .= sprintf q{<li><a href="#" onclick="WebGUI.AssetManager.showMoreMenu('%s','crumbMoreMenuLink'); return false;"><span id="crumbMoreMenuLink">%s</span></a></li>},
            $currentAsset->getUrl,
            $currentAsset->get( "menuTitle" ),
            ;
    $output .= '</ol>';
    
    ### The page of assets
    $output         .= q{<div>}
                    . q{<form method="post" enctype="multipart/form-data">}
                    . q{<input type="hidden" name="op" value="assetManager" />}
                    . q{<input type="hidden" name="method" value="manage" />}
                    . q{<div id="dataTableContainer">}
                    . q{</div>} 
                    . q{<p class="actions">} . $i18n->get( 'with selected' )
                    . q{<input type="submit" name="action_update" value="} . $i18n->get( "update" ) . q{" />}
                    . q{<input type="submit" name="action_delete" value="} . $i18n->get( "delete" ) . q{" onclick="return confirm('} . $i18n->get( 43 ) . q{')" />}
                    . q{<input type="submit" name="action_cut" value="} . $i18n->get( 'cut' ) . q{" />}
                    . q{<input type="submit" name="action_copy" value="} . $i18n->get( "copy" ) . q{" />}
                    . q{<input type="submit" name="action_duplicate" value="} . $i18n->get( "duplicate" ) . q{" />}
                    . q{</p>}
                    . q{</form>}
                    . q{<div id="pagination"> } 
                    . q{</div>}
                    . q{</div>}
                    ;
    
    ### Clearing div
    $output         .= q{<div style="clear: both;">&nbsp;</div>};

    ### New Content
    $output         .= q{<div class="functionPane"><fieldset><legend>} . $i18n->get( '1083' ) . '</legend>';
    foreach my $link (@{$currentAsset->getAssetAdderLinks("proceed=manageAssets","assetContainers")}) {
        $output .= '<p style="display:inline;vertical-align:middle;"><img src="'.$link->{'icon.small'}.'" alt="'.$link->{label}.'" style="border: 0px;vertical-align:middle;" /></p>
                <a href="'.$link->{url}.'">'.$link->{label}.'</a> ';
        $output .= $session->icon->edit("func=edit;proceed=manageAssets",$link->{asset}->get("url")) if ($link->{isPrototype});
        $output .= '<br />';
    }
    $output .= '<hr />';
    foreach my $link (@{$currentAsset->getAssetAdderLinks("proceed=manageAssets")}) {
        $output .= '<p style="display:inline;vertical-align:middle;"><img src="'.$link->{'icon.small'}.'" alt="'.$link->{label}.'" style="border: 0px;vertical-align:middle;" /></p>
                <a href="'.$link->{url}.'">'.$link->{label}.'</a> ';
        $output .= $session->icon->edit("func=edit;proceed=manageAssets",$link->{asset}->get("url")) if ($link->{isPrototype});
        $output .= '<br />';
    }
    $output .= '<hr />';
    foreach my $link (@{$currentAsset->getAssetAdderLinks("proceed=manageAssets","utilityAssets")}) {
        $output .= '<p style="display:inline;vertical-align:middle;"><img src="'.$link->{'icon.small'}.'" alt="'.$link->{label}.'" style="border: 0px;vertical-align:middle;" /></p>
                <a href="'.$link->{url}.'">'.$link->{label}.'</a> ';
        $output .= $session->icon->edit("func=edit;proceed=manageAssets",$link->{asset}->get("url")) if ($link->{isPrototype});
        $output .= '<br />';
    }
    $output .= '</fieldset></div>';

    tie my %options, 'Tie::IxHash';
    my $hasClips = 0;
    foreach my $asset (@{$currentAsset->getAssetsInClipboard(1)}) {
            $options{$asset->getId} = '<img src="'.$asset->getIcon(1).'" alt="'.$asset->getName.'" style="border: 0px;" /> '.$asset->getTitle;
            $hasClips = 1;
    }
    if ($hasClips) {
            $output .= '<div class="functionPane"><fieldset><legend>'.$i18n->get(1082).'</legend>'
                    .WebGUI::Form::formHeader($session, {action=>$currentAsset->getUrl})
                    .WebGUI::Form::hidden($session,{name=>"func",value=>"pasteList"})
                    .WebGUI::Form::checkbox($session,{extras=>'onclick="toggleClipboardSelectAll(this.form);"'})
                    .' '.$i18n->get("select all").'<br />'
                    .WebGUI::Form::checkList($session,{name=>"assetId",vertical=>1,options=>\%options})
                    .'<br />'
                    .WebGUI::Form::submit($session,{value=>"Paste"})
                    .WebGUI::Form::formFooter($session)
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

    ## Packages
    $output .= '<div class="functionPane"><fieldset> <legend>'.$i18n->get("packages").'</legend>';
    foreach my $asset (@{$currentAsset->getPackageList}) {
            $output .= '<p style="display:inline;vertical-align:middle;"><img src="'.$asset->getIcon(1).'" alt="'.$asset->getName.'" style="vertical-align:middle;border: 0px;" /></p>
                    <a href="'.$currentAsset->getUrl("func=deployPackage;assetId=".$asset->getId.";proceed=manageAssets").'">'.$asset->getTitle.'</a> '
                    .$session->icon->edit("func=edit;proceed=manageAssets",$asset->get("url"))
                    .$session->icon->export("func=exportPackage",$asset->get("url"))
                    .'<br />';
    }
    $output .= '<br />'.WebGUI::Form::formHeader($session, {action=>$currentAsset->getUrl})
            .WebGUI::Form::hidden($session, {name=>"func", value=>"importPackage"})
            .'<input type="file" name="packageFile" size="10" style="font-size: 10px;" />'
            .WebGUI::Form::submit($session, {value=>$i18n->get("import"), extras=>'style="font-size: 10px;"'})
            .WebGUI::Form::formFooter($session);
    $output .= ' </fieldset></div>';

    ### Clearing div
    $output         .= q{<div style="clear: both;">&nbsp;</div>};
    $output         .= q{</div>};

    ### Write the JavaScript that will take over
    $output         .= '<script type="text/javascript">'
                    . 'WebGUI.AssetManager.MoreMenuItems = ' . getMoreMenu( $session ) . ';'
                    ;

    $output         .= <<"ENDJS";
    // Start the data source
    WebGUI.AssetManager.DataSource
        = new YAHOO.util.DataSource( '?op=assetManager;method=ajaxGetManagerPage' );
    WebGUI.AssetManager.DataSource.responseType
        = YAHOO.util.DataSource.TYPE_JSON;
    WebGUI.AssetManager.DataSource.responseSchema
        = {
            resultsList: 'assets',
            totalRecords: 'totalAssets',
            fields: [
                { key: 'assetId' },
                { key: 'lineage' },
                { key: 'actions' },
                { key: 'title' },
                { key: 'className' },
                { key: 'revisionDate' },
                { key: 'assetSize' },
                { key: 'lockedBy' },
                { key: 'icon' },
                { key: 'url' },
                { key: 'childCount' }
            ]
        };

    WebGUI.AssetManager.DefaultSortedBy = { 
        "key"       : "lineage",
        "dir"       : YAHOO.widget.DataTable.CLASS_ASC
    };
    
    WebGUI.AssetManager.BuildQueryString
    = function ( state, dt ) {
        var query = ";recordOffset=" + state.pagination.recordOffset 
                + ';orderByDirection=' + ((state.sorting.dir === YAHOO.widget.DataTable.CLASS_DESC) ? "DESC" : "ASC")
                + ';rowsPerPage=' + state.pagination.rowsPerPage
                + ';orderByColumn=' + state.sorting.key
                ;
            return query;
        };

    var selectAllButton = "<input type=\\"checkbox\\" title=\\"$i18n{"select all"}\\" onclick=\\"WebGUI.Form.toggleAllCheckboxesInForm( document.forms[0], 'assetId' );\\" />";
ENDJS

    # Column defs have i18n, so be careful
    # Can't be Perl datastructure because formatter must be a function ref not a string
    $output .= q(
    WebGUI.AssetManager.ColumnDefs
        = [ 
            { key: 'assetId', label: selectAllButton, formatter: WebGUI.AssetManager.formatAssetIdCheckbox },
            { key: 'lineage', label: ") . $i18n->get( 'rank' ) . q(", sortable: true, formatter: WebGUI.AssetManager.formatRank },
            { key: 'actions', label: "", formatter: WebGUI.AssetManager.formatActions },
            { key: 'title', label: ") . $i18n->get( 99 ) . q(", formatter: WebGUI.AssetManager.formatTitle, sortable: true },
            { key: 'className', label: ") . $i18n->get( 'type' ) . q(", sortable: true, formatter: WebGUI.AssetManager.formatClassName },
            { key: 'revisionDate', label: ") . $i18n->get( 'revision date' ) . q(", formatter: WebGUI.AssetManager.formatRevisionDate, sortable: true },
            { key: 'assetSize', label: ") . $i18n->get( 'size' ) . q(", formatter: WebGUI.AssetManager.formatAssetSize, sortable: true },
            { key: 'lockedBy', label: ") . $i18n->get( 'locked' ) . q(", formatter: WebGUI.AssetManager.formatLockedBy }
        ];
    );

    $output .= <<'ENDJS';
</script>
ENDJS

    return $ac->render( $output );
}

#----------------------------------------------------------------------------

=head2 www_search ( session )

Search assets underneath this asset.

=cut

sub www_search {
    my $session      = shift;
    my $ac           = WebGUI::AdminConsole->new( $session, "assets" ); 
    my $i18n         = WebGUI::International->new( $session, "Asset" );
    my $currentAsset = getCurrentAsset($session);
    my $output       = '<div id="assetSearch">' . getHeader( $session );
    
    $session->style->setLink( $session->url->extras( 'yui-webgui/build/assetManager/assetManager.css' ), { rel => "stylesheet", type => 'text/css' } );
    $session->style->setScript( $session->url->extras( 'yui/build/yahoo-dom-event/yahoo-dom-event.js' ) );
    $session->style->setScript( $session->url->extras( 'yui-webgui/build/assetManager/assetManager.js' ) );
    $session->style->setScript( $session->url->extras( 'yui-webgui/build/form/form.js' ) );
    my $keywords = $session->scratch->get('assetManagerSearchKeywords') || $session->form->get('keywords');

    ### Show the form
    $output     .= q{<form method="post" enctype="multipart/form-data" action="} . $currentAsset->getUrl . q{"><p>}
                . q{<input type="hidden" name="op" value="assetManager" />}
                . q{<input type="hidden" name="method" value="search" />}
                . q{<input type="text" size="45" name="keywords" value="} . $keywords . q{" />}
                . getClassSelectBox( $session )
                . q{<input type="submit" name="action" value="}.$i18n->get( "search" ).q{" />}
                . q{</p></form>}
                ;

    ### Run the search
    if ( $keywords || $session->form->get( 'class' ) ) {
        my @classes          = $session->form->get( 'class' );
        my $keywordsScrubbed = $keywords;

        my $p       = getSearchPaginator( $session, { 
            keywords            => $keywords,
            classes             => \@classes,
            orderByColumn       => $session->form->get( 'orderByColumn' ),
            orderByDirection    => $session->form->get( 'orderByDirection' ),
        } );
        
        if ( $p->getRowCount == 0 ) {
            $output     .= q{<p class="error">} . $i18n->get( 'no results' ) . q{</p>};
        }
        else {
            ### Display the search results 
            $output         .= q{<form method="post" enctype="multipart/form-data" action="}.$currentAsset->getUrl.q{">}
                            . q{<input type="hidden" name="func"    value="searchAssets" />}
                            . q{<input type="hidden" name="proceed" value="searchAssets" />}
                            . WebGUI::Form::CsrfToken->new($session)->toHtml
                            . q{<input type="hidden" name="pn" value="} . $session->form->get('pn') . q{" />}
                            . q{<input type="hidden" name="keywords" value="} . $keywords . q{" />}
                            ;

            # Add classes to the form
            for my $class ( @classes ) {
                $output     .= q{<input type="hidden" name="class" value="} . $class . q{" />};
            }

            $output         .= q{<table class="assetSearch" border="0">}
                            . q{<thead>}
                            . q{<tr>}
                            . q{<th class="center"><input type="checkbox" onclick="WebGUI.Form.toggleAllCheckboxesInForm( this.form, 'assetId' )" /></th>} # Checkbox column
                            . q{<th class="center">&nbsp;</th>}            # Edit 
                            . q{<th>} . $i18n->get( '99' ) . q{</th>}             # Title
                            . q{<th>} . $i18n->get( "type" ) . q{</th>}              # Type
                            . q{<th class="center">} . $i18n->get( "last updated" ) . q{</th>}      # Revision Date
                            . q{<th class="center">} . $i18n->get( "size" ) . q{</th>}              # Size
                            . q{<th class="center">} . $i18n->get( "locked" ) . q{</th>}            # Lock
                            . q{</tr>}
                            . q{</thead}
                            . q{<tbody>}
                            ;

            # The markup for a single asset
            my $row_markup  = q{<tr %s ondblclick="WebGUI.AssetManager.toggleRow( this )">}
                            . q{<td class="center"><input type="checkbox" name="assetId" value="%s" onchange="WebGUI.AssetManager.toggleHighlightForRow( this )" /></td>}
                            . q{<td class="center">%s</td>}
                            . q{<td>%s</td>}
                            . q{<td><img src="%s" /> %s</td>}
                            . q{<td class="center">%s</td>}
                            . q{<td class="right">%s</td>}
                            . q{<td class="center"><a href="%s?func=manageRevisions">%s</a></td>}
                            . q{</tr>}
                            ;
            
            # The field keys to fill in the placeholders
            my @row_fields  = qw(
                            alt
                            assetId
                            editLink 
                            title
                            iconUrl type
                            revisionDate
                            size
                            url lockIcon
            );

            my $count           = 0;
            for my $assetInfo ( @{ $p->getPageData } ) {
                $count++;
                my $asset       = WebGUI::Asset->newByDynamicClass( $session, $assetInfo->{ assetId } );
                
                # Populate the required fields to fill in
                my %fields      = (
                    alt             => ( $count % 2 == 0 ? 'class="alt"' : '' ),
                    assetId         => $asset->getId,
                    url             => $asset->getUrl,
                    title           => $asset->get( "title" ),
                    revisionDate    => $session->datetime->epochToHuman( $asset->get( "revisionDate" ) ),
                    hasChildren     => ( $asset->hasChildren ? "+&nbsp;" : "&nbsp;&nbsp;" ),
                    rank            => $asset->getRank,
                    size            => formatBytes( $asset->get( 'assetSize' ) ),
                );

                # The asset icon
                my $icon    = [ grep { $_->{ icon } } @{ $asset->definition( $session ) } ]->[ 0 ]->{ icon };
                $fields{ iconUrl    } = $session->url->extras( '/assets/small/' . $icon );

                # The asset type (i18n name)
                my $type    = [ grep { $_->{ assetName } } @{ $asset->definition( $session ) } ]->[ 0 ]->{ assetName };
                $fields{ type       } = $type;

                # The lock
                if ( $asset->lockedBy ) { # lockedBy in case someone overrides isLocked (like the Collab System Thread )	
                    $fields{ lockIcon } 
                        = sprintf '<img src="%s" alt="locked by %s" title="locked by %s" style="border: 0px;" />',
                        $session->url->extras( 'assetManager/locked.gif' ),
                        WebGUI::HTML::format( $asset->lockedBy->username, "text" ),
                        WebGUI::HTML::format( $asset->lockedBy->username, "text" ),
                        ;
                } 
                else {
                    $fields{ lockIcon } 
                        = sprintf '<img src="%s" alt="unlocked" title="unlocked" style="border: 0px;" />',
                        $session->url->extras( 'assetManager/unlocked.gif' ),
                        ;
                }

                # The edit link
                if ( !$asset->lockedBy || $asset->canEditIfLocked ) {
                    $fields{ editLink } 
                        = sprintf '<a href="%s">' . $i18n->get( "edit" ) . '</a>',
                        $asset->getUrl( 'func=edit;proceed=manageAssets' )
                        ;
                }

                $output .= sprintf $row_markup, @fields{ @row_fields };
            }

            $output     .= q{</tbody>}
                        . q{</table>}
                        . q{<p class="actions">} . $i18n->get( 'with selected' )
                        . q{<input type="submit" name="action" value="}.$i18n->get( 'delete' ) . q[" onclick="if(confirm('].$i18n->get('43').q[')){this.form.func.value='deleteList'; this.form.submit();}{ return false; }" />]
                        . q{<input type="submit" name="action" value="}.$i18n->get( "cut" )    . q{" onclick="this.form.func.value='cutList'; this.form.submit();" />}
                        . q{<input type="submit" name="action" value="}.$i18n->get( "Copy" )    .q{" onclick="this.form.func.value='copyList'; this.form.submit();" />}
                        . q{</p>}
                        . q{</form>}
                        ;

            ### Page links
            $output         .= q{<div id="pageLinks">} . $p->getBarAdvanced . q{</div>};

            ### Page description
            $output         .= sprintf q{<div id="pageStats">} . $i18n->get( 'page indicator' ) . q{</div>},
                            $p->getPageNumber,
                            $p->getNumberOfPages,
                            ;
            
            ### Clearing div
            $output         .= q{<div style="clear: both;">&nbsp;</div>};
        }
    }

    $output         .= '</div>';

    $session->scratch->set('assetManagerSearchKeywords',  $keywords);
    return $ac->render( $output );
}

1;
