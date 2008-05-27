package WebGUI::Content::AssetManager;

use strict;

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
    
    tie my %classes, "Tie::IxHash", (
        ""  => "Any Class", 
        $session->db->buildHash("select distinct(className) from asset"),
    );
    delete $classes{"WebGUI::Asset"}; # don't want to search for the root asset

    return WebGUI::Form::selectBox( $session, {
        name            => "class", 
        value           => $session->form->process("class","className"), 
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
    my $orderByDirection    = $session->form->get( 'orderByDirection' ) eq "DESC"
                            ? "DESC"
                            : "ASC"
                            ;

    my $p           
        = WebGUI::Paginator->new( $session, 
            '?op=assetManager;method=manage;orderByColumn=' . $orderByColumn 
            . ';orderByDirection=' . $orderByDirection 
        );

    my $orderBy     = $session->db->dbh->quote_identifier( $orderByColumn ) . ' ' . $orderByDirection;
    $p->setDataByArrayRef( $asset->getLineage( ['children'] ), { orderByClause => $orderBy } );
    
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

    my $p           = $s->getPaginatorResultSet( $session->url->page( $queryString ) );

    return $p;
}

#----------------------------------------------------------------------------

=head2 getMoreMenu ( asset, label )

Gets the "More" menu with the specified label.

=cut

sub getMoreMenu {
    my $asset           = shift;
    my $label           = shift || "More";
    my $userUiLevel     = $asset->session->user->profileField("uiLevel");
    my $toolbarUiLevel  = $asset->session->config->get("assetToolbarUiLevel");
    my $i18n            = WebGUI::International->new( $asset->session, "Asset" );

    ### The More menu
    my @more_fields = ();       # The fields to fill in the more menu
    my $more_markup = q{<span class="moreMenu"><a href="#">} . $label . q{</a>}
                    . q{<ul>}
                    ;
    # These links are shown based on UI level
    if ( $userUiLevel >= $toolbarUiLevel->{ "changeUrl" } ) {
        $more_markup    .= q{<li><a href="%s">%s</a></li>};
        push @more_fields, $asset->getUrl( 'func=changeUrl;proceed=manageAssets' ), $i18n->get( 'change url' );
    }

    if ( $userUiLevel >= $toolbarUiLevel->{ "editBranch" } ) {
        $more_markup    .= q{<li><a href="%s">%s</a></li>};
        push @more_fields, $asset->getUrl( 'func=editBranch' ), $i18n->get( 'edit branch' );
    }

    if ( $userUiLevel >= $toolbarUiLevel->{ "shortcut" } ) {
        $more_markup    .= q{<li><a href="%s">%s</a></li>};
        push @more_fields, $asset->getUrl( 'func=createShortcut;proceed=manageAssets' ), $i18n->get( 'create shortcut' );
    }

    if ( $userUiLevel >= $toolbarUiLevel->{ "revisions" } ) {
        $more_markup    .= q{<li><a href="%s">%s</a></li>};
        push @more_fields, $asset->getUrl( 'func=manageRevisions' ), $i18n->get( 'revisions' );
    }

    if ( $userUiLevel >= $toolbarUiLevel->{ "view" } ) {
        $more_markup    .= q{<li><a href="%s">%s</a></li>};
        push @more_fields, $asset->getUrl, $i18n->get( 'view' );
    }

    if ( $userUiLevel >= $toolbarUiLevel->{ "edit" } ) {
        $more_markup    .= q{<li><a href="%s">%s</a></li>};
        push @more_fields, $asset->getUrl( 'func=edit;proceed=manageAssets' ), $i18n->get( 'edit' );
    }

    if ( $userUiLevel >= $toolbarUiLevel->{ "lock" } ) {
        $more_markup    .= q{<li><a href="%s">%s</a></li>};
        push @more_fields, $asset->getUrl( 'func=lock;proceed=manageAssets' ), $i18n->get( 'lock' );
    }

    if ( $asset->session->config->get("exportPath") && $userUiLevel >= $toolbarUiLevel->{"export"} ) {
        $more_markup    .= q{<li><a href="%s">%s</a></li>};
        push @more_fields, $asset->getUrl( 'func=export' ), $i18n->get( 'Export Page' ); 
    }

    $more_markup    .= q{</ul>} 
                    . q{</span>}
                    ;

    return sprintf $more_markup, @more_fields;
}

#----------------------------------------------------------------------------

=head2 getOrderLink ( session, column, label )

Gets a link to order the results based on a column. Uses some magick
to ensure proper working no matter where we are.

=cut

sub getOrderLink {
    my $session         = shift;
    my $column          = shift;
    my $label           = shift;
    
    my $columnParam     = "orderByColumn";
    my $directionParam  = "orderByDirection";

    my $url             = URI->new( $session->env->get( "REQUEST_URI" ) );
    my $query           = $url->query;
    # Split query string into param => value hash
    my %query           = map { /(.+)=(.+)/; $1 => $2 } split /[;&]/, $query;
    
    # Delete unnecessary keys
    delete $query{ 'assetId' };

    # Add necessary keys
    $query{ $columnParam } = $column;

    if ( $session->form->get( $columnParam ) eq $column && $session->form->get( $directionParam ) eq "ASC" ) {
        $query{ $directionParam } = "DESC";
    }
    else {
        $query{ $directionParam } = "ASC";
    }

    $url->query_form( %query );
    
    return q{<a href="} . $url->as_string . q{">}
            . $label
            . q{</a>}
            ;
}

#----------------------------------------------------------------------------

=head2 handler ( session )

Handle the session, if we can. Otherwise pass it on.

Check permissions

=cut

# BAD things about procedural that would be fixed with class methods
# 1) I must use stringy eval to call my method, instead of $class->$method( args )
# 2) I must validate that method using a list of known methods instead of $class->can( $method )

sub handler {
    my ( $session ) = @_;
 
    if ( $session->form->get( 'op' ) eq 'assetManager' && getCurrentAsset( $session ) ) {

        return $session->privilege->noAccess unless getCurrentAsset( $session )->canEdit;

        my $method  = $session->form->get( 'method' )
                    ? 'www_' . $session->form->get( 'method' )
                    : 'www_manage'
                    ;
        
        # Validate the method name
        if ( !grep { $_ eq $method } qw( www_manage www_search ) ) {
            return "Invalid method";
        }
        else {
            # I hate hate hate stringy eval
            return eval "$method" . '($session)';
        }
    }
    else {
        return;
    }
}

#----------------------------------------------------------------------------

=head2 www_manage ( session )

Show the main screen of the asset manager, paginated. Also load the 
JavaScript that will take over if the browser has the cojones.

# BAD things about procedural that would be fixed with class methods
# 3) The "appendSideLinks" method would be better as simply "getAdminStyle" and would do more

=cut

sub www_manage {
    my ( $session ) = @_;
    my $ac              = WebGUI::AdminConsole->new( $session, "assets" );
    my $currentAsset    = getCurrentAsset( $session );
    my $i18n            = WebGUI::International->new( $session, "Asset" );

    ### Do Action
    if ( my $action = $session->form->get( 'action' ) ) {
        my @assetIds    = $session->form->get( 'assetId' );

        if ( $action eq "update" ) {
            for my $assetId ( @assetIds ) {
                my $asset       = WebGUI::Asset->newByDynamicClass( $session, $assetId );
                next unless $asset;
                my $rank        = $session->form->get( $assetId . '_rank' );
                next unless $rank; # There's no such thing as zero

                $asset->setRank( $rank );
            }
        }
        elsif ( $action eq "trash" ) {
            for my $assetId ( @assetIds ) {
                my $asset       = WebGUI::Asset->newByDynamicClass( $session, $assetId );
                next unless $asset;
                $asset->trash;
            }
        }
        elsif ( $action eq "cut" ) {
            for my $assetId ( @assetIds ) {
                my $asset       = WebGUI::Asset->newByDynamicClass( $session, $assetId );
                next unless $asset;
                $asset->cut;
            }
        }
        elsif ( $action eq "copy" ) {
            for my $assetId ( @assetIds ) {
                # Copy == Duplicate + Cut
		my $asset       = WebGUI::Asset->newByDynamicClass( $session, $assetId);
                my $newAsset    = $asset->duplicate( { skipAutoCommitWorkflows => 1 } );
                $newAsset->update( { title => $newAsset->getTitle . ' (copy)' } );
                $newAsset->cut;
            }
        }
        elsif ( $action eq "duplicate" ) {
            for my $assetId ( @assetIds ) {
                my $asset       = WebGUI::Asset->newByDynamicClass( $session, $assetId );
                next unless $asset;
                $asset->duplicate( { skipAutoCommitWorkflows => 1 } );
            }
        }
    }

    # Show the page
    $session->style->setLink( $session->url->extras( 'yui-webgui/build/assetManager/assetManager.css' ), { rel => "stylesheet", type => 'text/css' } );
    $session->style->setScript( $session->url->extras( 'yui/build/yahoo-dom-event/yahoo-dom-event.js' ) );
    $session->style->setScript( $session->url->extras( 'yui-webgui/build/assetManager/assetManager.js' ) );
    $session->style->setScript( $session->url->extras( 'yui-webgui/build/form/form.js' ) );
    $session->style->setRawHeadTags( <<'ENDHTML' );
    <script type="text/javascript">
        YAHOO.util.Event.onDOMReady( WebGUI.AssetManager.initManager );
    </script>
ENDHTML
    my $output          = '<div id="assetManager">' . getHeader( $session );

    ### Crumbtrail
    my $crumb_markup    = '<li> &gt; <a href="%s">%s</a></li>';
    my $ancestors       = $currentAsset->getLineage( ['ancestors'], { returnObjects => 1 } );

    $output             .=  '<ol id="crumbtrail">';
    for my $asset ( @{ $ancestors } ) {
        $output .= sprintf $crumb_markup, 
                $asset->getUrl( 'op=assetManager;method=manage' ),
                $asset->get( "menuTitle" ),
                ;
    }

    # And ourself
    $output .= sprintf '<li> &gt; %s</li>',
            getMoreMenu( $currentAsset, $currentAsset->get( "menuTitle" ) ),
            ;
    $output .= '</ol>';
    
    ### The page of assets
    $output         .= q{<form>}
                    . q{<input type="hidden" name="op" value="assetManager" />}
                    . q{<input type="hidden" name="method" value="manage" />}
                    . q{<table class="assetManager" border="0" id="assetManager">}
                    . q{<thead>}
                    . q{<tr>}
                    . q{<th class="center"><input type="checkbox" onclick="WebGUI.Form.toggleAllCheckboxesInForm( this.form, 'assetId' )" /></th>} # Checkbox column
                    . q{<th class="center">} . getOrderLink( $session, "lineage", $i18n->get( "rank" ) ) . q{</th>}              # Rank column
                    . q{<th class="center">&nbsp;</th>}            # Edit / More
                    . q{<th>} . getOrderLink( $session, "title", $i18n->get( "99" ) ) . q{</th>}             # Title
                    . q{<th>} . getOrderLink( $session, "className", $i18n->get( "type" ) ) . q{</th>}              # Type
                    . q{<th class="center">} . getOrderLink( $session, "revisionDate", $i18n->get( "last updated" ) ) . q{</th>}      # Revision Date
                    . q{<th class="center">} . getOrderLink( $session, "assetSize", $i18n->get( "size" ) ) . q{</th>}              # Size
                    . q{<th class="center">} . getOrderLink( $session, "lockedBy", $i18n->get( "locked" ) ) . q{</th>}            # Lock
                    . q{</tr>}
                    . q{</thead}
                    . q{<tbody>}
                    ;

    # The markup for a single asset
    my $row_markup  = q{<tr %s ondblclick="WebGUI.AssetManager.toggleRow( this )">}
                    . q{<td class="center"><input type="checkbox" name="assetId" value="%s" onchange="WebGUI.AssetManager.toggleHighlightForRow( this )" /></td>}
                    . q{<td class="center"><input type="text" class="rank" name="%s_rank" size="3" value="%s" onchange="WebGUI.AssetManager.selectRow( this )" /></td>}
                    . q{<td class="center">%s %s</td>}
                    . q{<td><span class="hasChildren">%s</span><a href="%s?op=assetManager;method=manage">%s</a></td>}
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
                    assetId rank
                    editLink moreMenu
                    hasChildren url title
                    iconUrl type
                    revisionDate
                    size
                    url lockIcon
    );

    my $p               = getManagerPaginator( $session, {
        orderByColumn       => $session->form->get( 'orderByColumn' ),
        orderByDirection    => $session->form->get( 'orderByDirection' ),
    } );
    my $count           = 0;
    for my $assetId ( @{ $p->getPageData } ) {
        $count++;
        my $asset       = WebGUI::Asset->newByDynamicClass( $session, $assetId );
        
        # Populate the required fields to fill in
        my %fields      = (
            alt             => ( $count % 3 == 0 ? 'class="alt"' : '' ),
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
                = sprintf '<a href="%s">' . $i18n->get( "edit" ) . '</a> |',
                $asset->getUrl( 'func=edit;proceed=manageAssets' )
                ;
        }

        # The More menu
        $fields{ moreMenu } = getMoreMenu( $asset, $i18n->get( 'menu label' ) );

        $output .= sprintf $row_markup, @fields{ @row_fields };
    }

    $output     .= q{</tbody>}
                . q{</table>}
                . q{<p class="actions">} . $i18n->get( 'with selected' )
                . q{<button name="action" value="update">} . $i18n->get( "update" ) . q{</button>}
                . q{<button name="action" value="trash">} . $i18n->get( "delete" ) . q{</button>}
                . q{<button name="action" value="cut">} . $i18n->get( 'cut' ) . q{</button>}
                . q{<button name="action" value="copy">} . $i18n->get( "copy" ) . q{</button>}
                . q{<button name="action" value="duplicate">} . $i18n->get( "duplicate" ) . q{</button>}
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
                    <a href="'.$currentAsset->getUrl("func=deployPackage;assetId=".$asset->getId).'">'.$asset->getTitle.'</a> '
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

    return $ac->render( $output );
}

#----------------------------------------------------------------------------

=head2 www_search ( session )

Search assets underneath this asset.

=cut

sub www_search {
    my $session     = shift;
    my $ac          = WebGUI::AdminConsole->new( $session, "assets" ); 
    my $i18n        = WebGUI::International->new( $session, "Asset" );
    my $output      = '<div id="assetManager">' . getHeader( $session );
    
    $session->style->setLink( $session->url->extras( 'yui-webgui/build/assetManager/assetManager.css' ), { rel => "stylesheet", type => 'text/css' } );
    $session->style->setScript( $session->url->extras( 'yui/build/yahoo-dom-event/yahoo-dom-event.js' ) );
    $session->style->setScript( $session->url->extras( 'yui-webgui/build/assetManager/assetManager.js' ) );
    $session->style->setScript( $session->url->extras( 'yui-webgui/build/form/form.js' ) );
    $session->style->setRawHeadTags( <<'ENDHTML' );
    <script type="text/javascript">
        YAHOO.util.Event.onDOMReady( WebGUI.AssetManager.initSearch );
    </script>
ENDHTML

    ### Show the form
    $output     .= q{<form><p>}
                . q{<input type="hidden" name="op" value="assetManager" />}
                . q{<input type="hidden" name="method" value="search" />}
                . q{<input type="text" size="45" name="keywords" value="} . $session->form->get('keywords') . q{" />}
                . getClassSelectBox( $session )
                . q{<button name="action" value="search">} . $i18n->get( "search" ) . q{</button>}
                . q{</p></form>}
                ;

    ### Actions
    if ( my $action = $session->form->get( 'action' ) ) {
        my @assetIds    = $session->form->get( 'assetId' );

        if ( $action eq "trash" ) {
            for my $assetId ( @assetIds ) {
                my $asset       = WebGUI::Asset->newByDynamicClass( $session, $assetId );
                next unless $asset;
                $asset->trash;
            }
        }
        elsif ( $action eq "cut" ) {
            for my $assetId ( @assetIds ) {
                my $asset       = WebGUI::Asset->newByDynamicClass( $session, $assetId );
                next unless $asset;
                $asset->cut;
            }
        }
        elsif ( $action eq "copy" ) {
            for my $assetId ( @assetIds ) {
                # Copy == Duplicate + Cut
		my $asset       = WebGUI::Asset->newByDynamicClass( $session, $assetId);
                my $newAsset    = $asset->duplicate( { skipAutoCommitWorkflows => 1 } );
                $newAsset->update( { title => $newAsset->getTitle . ' (copy)' } );
                $newAsset->cut;
            }
        }
    }

    ### Run the search
    if ( $session->form->get( 'keywords' ) || $session->form->get( 'class' ) ) {
        my $keywords        = $session->form->get( 'keywords' );
        my @classes         = $session->form->get( 'class' );

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
            $output         .= q{<form>}
                            . q{<input type="hidden" name="op" value="assetManager" />}
                            . q{<input type="hidden" name="method" value="search" />}
                            . q{<input type="hidden" name="pn" value="} . $session->form->get('pn') . q{" />}
                            . q{<input type="hidden" name="keywords" value="} . $keywords . q{" />}
                            ;

            # Add classes to the form
            for my $class ( @classes ) {
                $output     .= q{<input type="hidden" name="class" value="} . $class . q{" />};
            }

            $output         .= q{<table class="assetManager" border="0">}
                            . q{<thead>}
                            . q{<tr>}
                            . q{<th class="center"><input type="checkbox" onclick="WebGUI.Form.toggleAllCheckboxesInForm( this.form, 'assetId' )" /></th>} # Checkbox column
                            . q{<th class="center">&nbsp;</th>}            # Edit / More
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
                            . q{<td class="center">%s %s</td>}
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
                            editLink moreMenu
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
                    alt             => ( $count % 3 == 0 ? 'class="alt"' : '' ),
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
                        = sprintf '<a href="%s">' . $i18n->get( "edit" ) . '</a> |',
                        $asset->getUrl( 'func=edit' )
                        ;
                }

                # The More menu
                $fields{ moreMenu } = getMoreMenu( $asset, $i18n->get( "menu label" ) );

                $output .= sprintf $row_markup, @fields{ @row_fields };
            }

            $output     .= q{</tbody>}
                        . q{</table>}
                        . q{<p class="actions">} . $i18n->get( 'with selected' )
                        . q{<button name="action" value="trash">} . $i18n->get( 'delete' ) . q{</button>}
                        . q{<button name="action" value="cut">} . $i18n->get( "cut" ) . q{</button>}
                        . q{<button name="action" value="copy">} . $i18n->get( "copy" ) . q{</button>}
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

    return $ac->render( $output );
}

1;
