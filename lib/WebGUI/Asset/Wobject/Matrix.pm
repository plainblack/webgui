package WebGUI::Asset::Wobject::Matrix;

use strict;
our $VERSION = "2.0.0";

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use Tie::IxHash;
use JSON;
use WebGUI::International;
use WebGUI::Utility;
use WebGUI::Asset::MatrixListing;
use base 'WebGUI::Asset::Wobject';

#----------------------------------------------------------------------------

=head2 canAddMatrixListing (  )

Returns true if able to add MatrixListings. 

=cut

sub canAddMatrixListing {
    my $self    = shift;
    my $user    = $self->session->user;

    # Users in the groupToAdd group can add listings
    if ( $user->isInGroup( $self->get("groupToAdd") ) ) {
        return 1;
    }
    # Users who can edit matrix can add listings
    else {
        return $self->canEdit;
    }

}

#----------------------------------------------------------------------------

=head2 canEdit ( [userId] )

Returns true if the user can edit this Matrix. 

Also checks if a user is adding a Matrix Listing and allows them to if they are
part of the C<groupToAdd> group.

=cut

sub canEdit {
    my $self        = shift;
    my $userId = shift || $self->session->user->userId;

    my $form        = $self->session->form;
    if ( $form->get('func') eq "editSave" && $form->get('assetId') eq "new" && $form->get( 'class' )->isa(
'WebGUI::Asset::MatrixListing' ) ) {
        return $self->canAddMatrixListing();
    }
    else {
        if ($userId eq $self->get("ownerUserId")) {
            return 1;
        }
        my $user = WebGUI::User->new($self->session, $userId);
        return $user->isInGroup($self->get("groupIdEdit"));
    }
}

#-------------------------------------------------------------------

=head2 definition ( )

defines wobject properties for Matrix instances. 

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift;
	my $i18n = WebGUI::International->new($session, 'Asset_Matrix');

	my %properties;
	tie %properties, 'Tie::IxHash';
	%properties = (
	    templateId =>{
		    fieldType       =>"template",  
    		defaultValue    =>'matrixtmpl000000000001',
	    	tab             =>"display",
		    noFormPost      =>0,  
    		namespace       =>"Matrix", 
	    	hoverHelp       =>$i18n->get('template description'),
		    label           =>$i18n->get('template label'),
    	},
        searchTemplateId=>{
            defaultValue    =>"matrixtmpl000000000005",
            fieldType       =>"template",
            tab             =>"display",
            namespace       =>"Matrix/Search",
            hoverHelp       =>$i18n->get('search template description'),
            label           =>$i18n->get('search template label'),
        },
        detailTemplateId=>{
            defaultValue    =>"matrixtmpl000000000003",
            fieldType       =>"template",
            tab             =>"display",
            namespace       =>"Matrix/Detail",
            hoverHelp       =>$i18n->get('detail template description'),
            label           =>$i18n->get('detail template label'),
        },
        compareTemplateId=>{
            defaultValue    =>"matrixtmpl000000000002",
            fieldType       =>"template",
            tab             =>"display",
            namespace       =>"Matrix/Compare",
            hoverHelp       =>$i18n->get('compare template description'),
            label           =>$i18n->get('compare template label'),
        },
        editListingTemplateId=>{
            defaultValue    =>"matrixtmpl000000000004",
            fieldType       =>"template",
            tab             =>"display",
            namespace       =>"Matrix/EditListing",
            hoverHelp       =>$i18n->get('edit listing template description'),
            label           =>$i18n->get('edit listing template label'),
        },
        screenshotsTemplateId=>{
            defaultValue    =>"matrixtmpl000000000006",
            fieldType       =>"template",
            tab             =>"display",
            namespace       =>"Matrix/Screenshots",
            hoverHelp       =>$i18n->get('screenshots template description'),
            label           =>$i18n->get('screenshots template label'),
        },
        screenshotsConfigTemplateId=>{
            defaultValue    =>"matrixtmpl000000000007",
            fieldType       =>"template",
            tab             =>"display",
            namespace       =>"Matrix/ScreenshotsConfig",
            hoverHelp       =>$i18n->get('screenshots config template description'),
            label           =>$i18n->get('screenshots config template label'),
        },
        defaultSort=>{
            fieldType       =>"selectBox",
            tab             =>"display",
            options         =>{ 
                                score           => $i18n->get('sort by score label'),
                                title           => $i18n->get('sort alpha numeric label'),
                                lineage         => $i18n->get('sort by asset rank label'),
                                lastUpdated     => $i18n->get('sort by last updated label'),
                              },
            defaultValue    =>"title",
            hoverHelp       =>$i18n->get('default sort description'),
            label           =>$i18n->get('default sort label'),
        },
        compareColorNo=>{
            fieldType       =>"color",
            tab             =>"display",
            defaultValue    =>"#ffaaaa",
            hoverHelp       =>$i18n->get('compare color no description'),
            label           =>$i18n->get('compare color no label'),
        },
        compareColorLimited=>{
            fieldType       =>"color",
            tab             =>"display",
            defaultValue    =>"#ffffaa",
            hoverHelp       =>$i18n->get('compare color limited description'),
            label           =>$i18n->get('compare color limited label'),
        },
        compareColorCostsExtra=>{
            fieldType       =>"color",
            tab             =>"display",
            defaultValue    =>"#ffffaa",
            hoverHelp       =>$i18n->get('compare color costs extra description'),
            label           =>$i18n->get('compare color costs extra label'),
        },
        compareColorFreeAddOn=>{
            fieldType       =>"color",
            tab             =>"display",
            defaultValue    =>"#ffffaa",
            hoverHelp       =>$i18n->get('compare color free add on description'),
            label           =>$i18n->get('compare color free add on label'),
        },
        compareColorYes=>{
            fieldType       =>"color",
            tab             =>"display",
            defaultValue    =>"#aaffaa",
            hoverHelp       =>$i18n->get('compare color yes description'),
            label           =>$i18n->get('compare color yes label'),
        },
        maxScreenshotWidth=>{
            fieldType       =>"integer",
            tab             =>"display",
            defaultValue    =>"800",
            hoverHelp       =>$i18n->get('max screenshot width description'),
            label           =>$i18n->get('max screenshot width label'),
        },
        maxScreenshotHeight=>{
            fieldType       =>"integer",
            tab             =>"display",
            defaultValue    =>"600",
            hoverHelp       =>$i18n->get('max screenshot height description'),
            label           =>$i18n->get('max screenshot height label'),
        },
        categories=>{
            fieldType       =>"textarea",
            tab             =>"properties",
            defaultValue    =>$i18n->get('categories default value'),
            hoverHelp       =>$i18n->get('categories description'),
            label           =>$i18n->get('categories label'),
            subtext         =>$i18n->get('categories subtext'),
        },
        maxComparisons=>{
            fieldType       =>"integer",
            tab             =>"properties",
            defaultValue    =>25,
            hoverHelp       =>$i18n->get('max comparisons description'),       
            label           =>$i18n->get('max comparisons label'),
        },
        maxComparisonsPrivileged=>{
            fieldType       =>"integer",
            tab             =>"properties",
            defaultValue    =>10,
            hoverHelp       =>$i18n->get('max comparisons privileged description'),
            label           =>$i18n->get('max comparisons privileged label'),
        },
        maxComparisonsGroup=>{
            fieldType       =>"group",
            tab             =>"properties",
            hoverHelp       =>$i18n->get('maxgroup description'),
            label           =>$i18n->get('maxgroup label'),
        },
        maxComparisonsGroupInt=>{
            fieldType       =>"integer",
            tab             =>"properties",
            defaultValue    =>25,
            hoverHelp       =>$i18n->get('maxgroup per description'),
            label           =>$i18n->get('maxgroup per label'),
        },
        groupToAdd=>{
            fieldType       =>"group",
            tab             =>"security",
            defaultValue    =>2,
            hoverHelp       =>$i18n->get('group to add description'),
            label           =>$i18n->get('group to add label'),
        },
        submissionApprovalWorkflowId=>{
            fieldType       =>"workflow",
            tab             =>"security",
            type            =>'WebGUI::VersionTag',
            defaultValue    =>"pbworkflow000000000003",
            hoverHelp       =>$i18n->get('submission approval workflow description'),
            label           =>$i18n->get('submission approval workflow label'),
        },
        ratingsDuration=>{
            fieldType       =>"interval",
            tab             =>"properties",
            defaultValue    =>7776000, # 3 months 3*30*24*60*60
            hoverHelp       =>$i18n->get('ratings duration description'),
            label           =>$i18n->get('ratings duration label'),
        },
        statisticsCacheTimeout => {
            tab             => "display",
            fieldType       => "interval",
            defaultValue    => 3600,
            uiLevel         => 8,
            label           => $i18n->get("statistics cache timeout label"),
            hoverHelp       => $i18n->get("statistics cache timeout description")
        },
        listingsCacheTimeout => {
            tab             => "display",
            fieldType       => "interval",
            defaultValue    => 3600,
            uiLevel         => 8,
            label           => $i18n->get("listings cache timeout label"),
            hoverHelp       => $i18n->get("listings cache timeout description")
        },
	);
	push(@{$definition}, {
		assetName=>$i18n->get('assetName'),
		icon=>'matrix.gif',
		autoGenerateForms=>1,
		tableName=>'Matrix',
		className=>'WebGUI::Asset::Wobject::Matrix',
		properties=>\%properties
		});
    return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 deleteAttribute ( attributeId )

Deletes an attribute and listing data for this attribute from Collateral.

=head3 attributeId

The id of the attribute that should be deleted.

=cut

sub deleteAttribute {

    my $self = shift;
    my $attributeId = shift;

    $self->deleteCollateral("Matrix_attribute","attributeId",$attributeId);
    $self->session->db->write("delete from MatrixListing_attribute where attributeId=? and matrixId=?",
        [$attributeId,$self->getId]);

    # recalculate scores for MatrixListings
    my @listings = @{ $self->getLineage(['descendants'], {
            includeOnlyClasses  => ['WebGUI::Asset::MatrixListing'],
            returnObjects       => 1,
        }) };
    foreach my $listing (@listings){
        $listing->updateScore;
    }

    return undef;
}

#-------------------------------------------------------------------

=head2 duplicate ( )

duplicates a Matrix. 

=cut

sub duplicate {
	my $self = shift;
	my $newAsset = $self->SUPER::duplicate(@_);
	return $newAsset;
}

#-------------------------------------------------------------------

=head2 editAttributeSave ( attributeProperties  )

Saves an attribute. 

=head3 attributeProperties

A hashref containing the properties of the attribute.

=cut

sub editAttributeSave {
    my $self                = shift;
    my $attributeProperties = shift;
    my $session             = $self->session;
    my $form                = $session->form;

    return $session->privilege->insufficient() unless $self->canEdit;

    my $attributeId = $self->setCollateral("Matrix_attribute","attributeId",$attributeProperties,0,1);

    return $attributeId;
}

#-------------------------------------------------------------------

=head2 getAttribute  ( attributeId )

Returns a hash reference of the properties of an attribute.

=head3 attributeId

The unique id of an attribute.

=cut

sub getAttribute {
    my ($self, $attributeId) = @_;
    return $self->session->db->quickHashRef("select * from Matrix_attribute where attributeId=?",[$attributeId]);
}

#-------------------------------------------------------------------

=head2 getCategories  (  )

Returns the categories for this Matrix as a hashref.

=cut

sub getCategories {
    my $self = shift;
    my %categories;
    tie %categories, 'Tie::IxHash';

    my $categories  = $self->getValue("categories");
    $categories     =~ s/\r//g;
    chomp($categories);

    my @categories  = split(/\n/,$categories);
    foreach my $category (@categories) {
        $categories{$category} = $category;
    }
    return \%categories;

}

#-------------------------------------------------------------------

=head2 getCompareColor  (  )

Returns the compare color for a MatrixCompare value.

=head3 value

The value of a MatrixCompare form field.

=cut

sub getCompareColor {

    my $self    = shift;
    my $value   = shift;

    if($value == 0){
        return $self->get('compareColorNo');
    }
    elsif($value == 1){
        return $self->get('compareColorLimited');
    }
    elsif($value == 2){
        return $self->get('compareColorCostsExtra');
    }
    elsif($value == 3){
        return $self->get('compareColorFreeAddOn');
    }
    elsif($value == 4){
        return $self->get('compareColorYes');
    }

}

#-------------------------------------------------------------------

=head2 getCompareForm  (  )

Returns the compare form.

=cut

sub getCompareForm {
    my $self = shift;

    my $form = WebGUI::Form::formHeader($self->session,{action=>$self->getUrl,extras=>'name="doCompare"'})
        ."<br />"
        .WebGUI::Form::hidden($self->session, {
            name=>"func",
            value=>"compare"
            })
        .'<div id="compareForm"></div> '
        ."<br />"
        .WebGUI::Form::formFooter($self->session);

    my $maxComparisons;
    if($self->session->user->isVisitor){
        $maxComparisons = $self->get('maxComparisons');
    }
    elsif($self->session->user->isInGroup( $self->get("maxComparisonsGroup") )) { 
        $maxComparisons = $self->get('maxComparisonsGroupInt');
    }
    else{
        $maxComparisons = $self->get('maxComparisonsPrivileged');
    }
    $maxComparisons += 0;
    $form .=  "\n<script type='text/javascript'>\n".
        'var maxComparisons = '.$maxComparisons.";\n".
        "var matrixUrl = '".$self->getUrl."';\n".
        "\n</script>\n";
    return $form;
}

#-------------------------------------------------------------------

=head2 getListings  (  )

Returns the listings as an arrayRef of hashRefs.

=head3 sort 

The criterium by which the listings should be sorted.

=cut

sub getListings {

    my $self        = shift;
    my $session     = $self->session;
    my $sort        = shift || $session->scratch->get('matrixSort') || $self->get('defaultSort');
    my $versionTag  = WebGUI::VersionTag->getWorking($session, 1);
    my ($listings, $listingsEncoded);

    my $noCache =
        $session->var->isAdminOn
        || $self->get("listingsCacheTimeout") <= 10
        || ($versionTag && $versionTag->getId eq $self->get("tagId"));
    unless ($noCache) {
        $listingsEncoded = WebGUI::Cache->new($session,"matrixListings_".$self->getId)->get;
    }

    if ($listingsEncoded){
        $listings = JSON->new->decode($listingsEncoded);
    }
    else{
        my $sortDirection   = ' desc';
        if ($sort eq 'title'){
            $sortDirection = ' asc';
        }

        my $sql = "
        select
            assetData.title,
            assetData.url,
            listing.assetId,
            listing.views,
            listing.compares,
            listing.clicks,
            listing.lastUpdated
        from asset
            left join assetData using(assetId)
            left join MatrixListing as listing on listing.assetId = assetData.assetId and listing.revisionDate =
assetData.revisionDate
        where
            asset.parentId=?
            and asset.state='published'
            and asset.className='WebGUI::Asset::MatrixListing'
            and assetData.revisionDate = (SELECT max(revisionDate) from assetData where assetId=asset.assetId and status='approved')
            and status='approved'
        order by ".$sort.$sortDirection;
    
        $listings = $session->db->buildArrayRefOfHashRefs($sql,[$self->getId]);

        foreach my $listing (@{$listings}) {
            $listing->{url}      = $session->url->gateway($listing->{url});
        }

        $listingsEncoded = JSON->new->encode($listings);
            WebGUI::Cache->new($session,"matrixListings_".$self->getId)->set(
                $listingsEncoded,$self->get("listingsCacheTimeout")
            );
    }
    return $listings;
}

#-------------------------------------------------------------------

=head2 getEditForm ( )

returns the tabform object that will be used in generating the edit page for Matrix.

=cut

sub getEditForm {
	my $self    = shift;
	my $tabform = $self->SUPER::getEditForm();
	return $tabform;
}

#-------------------------------------------------------------------

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

sub prepareView {
    my $self = shift;

    $self->SUPER::prepareView();
    my $template = WebGUI::Asset::Template->new($self->session, $self->get("templateId"));
    if (!$template) {
        WebGUI::Error::ObjectNotFound::Template->throw(
            error      => qq{Template not found},
            templateId => $self->get("templateId"),
            assetId    => $self->getId,
        );
    }
    $template->prepare;
    $self->{_viewTemplate} = $template;

    return undef;
}


#-------------------------------------------------------------------

=head2 purge ( )

removes collateral data associated with a Matrix when the system
purges it's data.  

=cut

sub purge {
	my $self = shift;
	
    $self->session->db->write("delete from Matrix_attribute where assetId=?",[$self->getId]);
	return $self->SUPER::purge;
}

#-------------------------------------------------------------------

=head2 view ( )

method called by the www_view method.  Returns a processed template
to be displayed within the page style.  

=cut

sub view {
	my $self    = shift;
	my $session = $self->session;	
    my $db      = $session->db; 
    my $i18n    = WebGUI::International->new($session, 'Asset_Matrix');

    # javascript and css files for compare form datatable
    $session->style->setLink(  $session->url->extras('yui/build/datatable/assets/skins/sam/datatable.css'), {type =>'text/css', rel=>'stylesheet'});
    $session->style->setScript($session->url->extras('yui/build/yahoo-dom-event/yahoo-dom-event.js'), {type => 'text/javascript'});
    $session->style->setScript($session->url->extras('yui/build/json/json-min.js'), {type => 'text/javascript'});
    $session->style->setScript($session->url->extras('yui/build/connection/connection-min.js'), {type => 'text/javascript'});
    $session->style->setScript($session->url->extras('yui/build/get/get-min.js'), {type => 'text/javascript'});
    $session->style->setScript($session->url->extras('yui/build/element/element-beta-min.js'), {type => 'text/javascript'});
    $session->style->setScript($session->url->extras('yui/build/datasource/datasource-min.js'), {type => 'text/javascript'});
    $session->style->setScript($session->url->extras('yui/build/datatable/datatable-min.js'), {type => 'text/javascript'});
    $session->style->setScript($session->url->extras('yui/build/button/button-min.js'), {type => 'text/javascript'});
    
    my ($varStatistics,$varStatisticsEncoded);
	my $var = $self->get;
    $var->{isLoggedIn}              = ($session->user->userId ne "1");
    $var->{addMatrixListing_url}    = $self->getUrl('func=add;class=WebGUI::Asset::MatrixListing'); 
    $var->{exportAttributes_url}    = $self->getUrl('func=exportAttributes');
    $var->{listAttributes_url}      = $self->getUrl('func=listAttributes');
    $var->{search_url}              = $self->getUrl('func=search');
    $var->{matrix_url}              = $self->getUrl();

    my $maxComparisons;
    if($session->user->isVisitor){
        $maxComparisons = $self->get('maxComparisons');
    }
    elsif($session->user->isInGroup( $self->get("maxComparisonsGroup") )) {
        $maxComparisons = $self->get('maxComparisonsGroupInt');
    }
    else{
        $maxComparisons = $self->get('maxComparisonsPrivileged');
    }
    $maxComparisons += 0;
    $var->{maxComparisons} = $maxComparisons;
   
    if ($self->canEdit){
        # Get all the MatrixListings that are still pending.
        my @pendingListings = @{ $self->getLineage(['descendants'], {
                includeOnlyClasses  => ['WebGUI::Asset::MatrixListing'],
                orderByClause       => "revisionDate asc",
                returnObjects       => 1,
                statusToInclude     => ['pending'],
            }) };
        foreach my $pendingListing (@pendingListings){
            push (@{ $var->{pending_loop} }, {
                            url     => $pendingListing->getUrl
                                       ."?func=view;revision=".$pendingListing->get('revisionDate'),
                            name    => $pendingListing->get('title'),
                        });
        }
    } 
   
    my $versionTag = WebGUI::VersionTag->getWorking($session, 1); 
    my $noCache =
        $session->var->isAdminOn
        || $self->get("statisticsCacheTimeout") <= 10
        || ($versionTag && $versionTag->getId eq $self->get("tagId"));
    unless ($noCache) {
        $varStatisticsEncoded = WebGUI::Cache->new($session,"matrixStatistics_".$self->getId)->get;
    }

    if ($varStatisticsEncoded){
        $varStatistics = JSON->new->decode($varStatisticsEncoded);
    }
    else{
        $varStatistics->{alphanumeric_sortButton}   = "<span id='sortByName'><button type='button'>"
                                                    . $i18n->get('Sort by name')
                                                    . "</button></span><br />";

        # Get the MatrixListing with the most views as an object using getLineage.
        my ($bestViews_listing) = @{ $self->getLineage(['descendants'], {
            includeOnlyClasses  => ['WebGUI::Asset::MatrixListing'],
            joinClass           => "WebGUI::Asset::MatrixListing",
            orderByClause       => "views desc",
            limit               => 1,
            returnObjects       => 1,
        }) };
        if($bestViews_listing){
            $varStatistics->{bestViews_url}           = $bestViews_listing->getUrl;
            $varStatistics->{bestViews_count}         = $bestViews_listing->get('views');
            $varStatistics->{bestViews_name}          = $bestViews_listing->get('title');
            $varStatistics->{bestViews_sortButton}    = "<span id='sortByViews'><button type='button'>"
                                                      . $i18n->get('Sort by views')
                                                      . "</button></span><br />";
        }

        # Get the MatrixListing with the most compares as an object using getLineage.

        my ($bestCompares_listing) = @{ $self->getLineage(['descendants'], {
            includeOnlyClasses  => ['WebGUI::Asset::MatrixListing'],
            joinClass           => "WebGUI::Asset::MatrixListing",
            orderByClause       => "compares desc",
            limit               => 1,   
            returnObjects       => 1,   
        }) };   
        if($bestCompares_listing){
            $varStatistics->{bestCompares_url}        = $bestCompares_listing->getUrl;
            $varStatistics->{bestCompares_count}      = $bestCompares_listing->get('compares');
            $varStatistics->{bestCompares_name}       = $bestCompares_listing->get('title');
            $varStatistics->{bestCompares_sortButton} = "<span id='sortByCompares'><button type='button'>"
                                                      . $i18n->get('Sort by compares')
                                                      . "</button></span><br />";
        }

        # Get the MatrixListing with the most clicks as an object using getLineage.
        my ($bestClicks_listing) = @{ $self->getLineage(['descendants'], {
            includeOnlyClasses  => ['WebGUI::Asset::MatrixListing'],
            joinClass           => "WebGUI::Asset::MatrixListing",
            orderByClause       => "clicks desc",
            limit               => 1,   
            returnObjects       => 1,   
        }) };   
        if($bestClicks_listing){
            $varStatistics->{bestClicks_url}          = $bestClicks_listing->getUrl;
            $varStatistics->{bestClicks_count}        = $bestClicks_listing->get('clicks');
            $varStatistics->{bestClicks_name}         = $bestClicks_listing->get('title');
            $varStatistics->{bestClicks_sortButton}   = "<span id='sortByClicks'><button type='button'>"
                                                      . $i18n->get('Sort by clicks')
                                                      . "</button></span><br />";
        }

        # Get the 5 MatrixListings that were last updated as objects using getLineage.

        my @lastUpdatedListings = @{ $self->getLineage(['descendants'], {
            includeOnlyClasses  => ['WebGUI::Asset::MatrixListing'],
            joinClass           => "WebGUI::Asset::MatrixListing",
            orderByClause       => "lastUpdated desc",
            limit               => 5,
            returnObjects       => 1,
        }) };
        foreach my $lastUpdatedListing (@lastUpdatedListings){
            push (@{ $varStatistics->{last_updated_loop} }, {
                        url         => $lastUpdatedListing->getUrl,
                        name        => $lastUpdatedListing->get('title'),
                        lastUpdated => $session->datetime->epochToHuman($lastUpdatedListing->get('lastUpdated'),"%z")
                    });
        }
        $varStatistics->{lastUpdated_sortButton}  = "<span id='sortByUpdated'><button type='button'>"
                                                  . $i18n->get('Sort by updated')
                                                  . "</button></span><br />";

        # For each category, get the MatrixListings with the best ratings.

        foreach my $category (keys %{$self->getCategories}) {
        my $data;
        my $sql = "
        select 
            assetData.title as productName,
            assetData.url,
            rating.listingId, 
            rating.meanValue,
            rating.medianValue,
            rating.countValue, 
            asset.parentId 
        from 
            MatrixListing_ratingSummary as rating 
            left join asset on (rating.listingId = asset.assetId)
            left join assetData on assetData.assetId = rating.listingId 
        where 
            rating.category =? 
            and asset.parentId=? 
            and asset.state='published' 
            and rating.countValue >= 10
            and assetData.revisionDate=(
                select
                    max(revisionDate)
                from
                    assetData
                where
                    assetData.assetId=asset.assetId
                    and (status='approved' or status='archived')
            )
        group by
            assetData.assetId
        order by rating.meanValue ";
        
        $data = $db->quickHashRef($sql." desc limit 1",[$category,$self->getId]);
        push(@{ $varStatistics->{best_rating_loop} },{
            url      => $session->url->gateway($data->{url}),
            category => $category,
            name     => $data->{productName},
            mean     => 0+$data->{meanValue},
            median   => 0+$data->{medianValue},
            count    => 0+$data->{countValue}
            });
        $data = $db->quickHashRef($sql." asc limit 1",[$category,$self->getId]);
        push(@{ $varStatistics->{worst_rating_loop} },{
            url      => $session->url->gateway($data->{url}),
            category => $category,
            name     => $data->{productName},
            mean     => 0+$data->{meanValue},
            median   => 0+$data->{medianValue},
            count    => 0+$data->{countValue}
            });
        }

        $varStatistics->{listingCount} = scalar $db->buildArray("
        select  * 
        from    asset, assetData
        where   asset.assetId=assetData.assetId
                and asset.parentId=?
                and asset.state='published'
                and asset.className='WebGUI::Asset::MatrixListing'
                and assetData.status='approved'
        group by asset.assetId",
        [$self->getId]);

        $varStatisticsEncoded = JSON->new->encode($varStatistics);
        WebGUI::Cache->new($session,"matrixStatistics_".$self->getId)->set(
            $varStatisticsEncoded,$self->get("statisticsCacheTimeout")
        );
    }

    foreach my $statistic (keys %{$varStatistics}) {
        $var->{$statistic} = $varStatistics->{$statistic};
    }

	return $self->processTemplate($var, undef, $self->{_viewTemplate});
}

#-------------------------------------------------------------------

=head2 www_compare ( )

Returns the compare screen

=head3 listingIds

An array of listingIds that should be selected in the compare form.

=cut

sub www_compare {

    my $self        = shift;
    my $var         = $self->get;
    my @listingIds  = @_;
    my @responseFields;

    unless (scalar(@listingIds)) {
        @listingIds = $self->session->form->checkList("listingId");
    }

    $self->session->style->setScript($self->session->url->extras('yui/build/yahoo/yahoo-min.js'),
        {type => 'text/javascript'});
    $self->session->style->setScript($self->session->url->extras('yui/build/dom/dom-min.js'),
        {type => 'text/javascript'});
    $self->session->style->setScript($self->session->url->extras('yui/build/event/event-min.js'),
        {type => 'text/javascript'});    
    $self->session->style->setScript($self->session->url->extras('yui/build/json/json-min.js'), {type =>
    'text/javascript'});
    $self->session->style->setScript($self->session->url->extras('yui/build/connection/connection-min.js'), 
        {type => 'text/javascript'});
    $self->session->style->setScript($self->session->url->extras('yui/build/get/get-min.js'), {type =>
    'text/javascript'});
    $self->session->style->setScript($self->session->url->extras('yui/build/element/element-beta-min.js'), {type =>
    'text/javascript'});
    $self->session->style->setScript($self->session->url->extras('yui/build/datasource/datasource-min.js'),
    {type => 'text/javascript'});
    $self->session->style->setScript($self->session->url->extras('yui/build/datatable/datatable-min.js'),
    {type =>'text/javascript'});
    $self->session->style->setScript($self->session->url->extras('yui/build/button/button-min.js'),
    {type =>'text/javascript'});
    $self->session->style->setScript($self->session->url->extras('yui/build/container/container-min.js'),
    {type =>'text/javascript'});
    $self->session->style->setLink($self->session->url->extras('yui/build/datatable/assets/skins/sam/datatable.css'),
        {type =>'text/css', rel=>'stylesheet'});
    $self->session->style->setScript($self->session->url->extras('hoverhelp.js'), {type =>
    'text/javascript'});
    $self->session->style->setLink($self->session->url->extras('hoverhelp.css'),
        {type =>'text/css', rel=>'stylesheet'});

    my $maxComparisons;
    if($self->session->user->isVisitor){
        $maxComparisons = $self->get('maxComparisons');
    }
    elsif($self->session->user->isInGroup( $self->get("maxComparisonsGroup") )) { 
        $maxComparisons = $self->get('maxComparisonsGroupInt');
    }
    else{
        $maxComparisons = $self->get('maxComparisonsPrivileged');
    }
    $maxComparisons += 0;

    foreach my $listingId (@listingIds){
        my $listingId_safe = $listingId;
        $listingId_safe =~ s/-/_____/g;
        push(@responseFields, $listingId_safe, $listingId_safe."_compareColor");
    }

    $var->{maxComparisons}  = $maxComparisons;
    $var->{matrixUrl}       = $self->getUrl;
    $var->{listingIds}      = join(", ",map {'"'.$_.'"'} @listingIds);
    $var->{responseFields}  = '"attributeId", "name", "description","fieldType", "checked", '
                              .join(", ",map{'"'.$_.'"'} @responseFields);

    return $self->processStyle($self->processTemplate($var,$self->get("compareTemplateId")));
}

#-------------------------------------------------------------------

=head2 www_deleteAttribute ( )

Deletes an Attribute, including listing data for this attribute.

=cut

sub www_deleteAttribute {
    my $self        = shift;
    my $attributeId = $self->session->form->process("attributeId");

    return $self->session->privilege->insufficient() unless $self->canEdit;

    $self->deleteAttribute($attributeId);

    return $self->www_listAttributes;
}

#-------------------------------------------------------------------

=head2 www_deleteStickied  (  )

Sets the sort scratch variable.

=cut

sub www_deleteStickied {

    my $self = shift;

    if(my $attributeId = $self->session->form->process("attributeId")){
        $self->session->scratch->delete('stickied_'.$attributeId);
    }
    return undef;
}

#-------------------------------------------------------------------

=head2 www_editAttribute ( )

Shows a form to edit or add an attribute. 

=cut

sub www_editAttribute {
    my $self    = shift;
    my $session = $self->session;
    my ($attributeId, $attribute);
    
    return $session->privilege->insufficient() unless $self->canEdit;
    my $i18n = WebGUI::International->new($session, "Asset_Matrix");

    $attributeId = $session->form->process("attributeId") || 'new';

    unless($attributeId eq 'new'){
        $attribute = $self->getAttribute($attributeId); 
    }

    my $form = WebGUI::HTMLForm->new($self->session,-action=>$self->getUrl);
    $form->hidden(
        -name       =>"func",
        -value      =>"editAttributeSave"
        );
    $form->hidden(
        -name       =>"attributeId",
        -value      =>$attributeId,
        );
    $form->text(
        -name       =>"name",
        -value      =>$attribute->{name},
        -label      =>$i18n->get('attribute name label'),
        -hoverHelp  =>$i18n->get('attribute name description'),
        );
    $form->textarea(
        -name       =>"description",
        -value      =>$attribute->{description},    
        -label      =>$i18n->get('attribute description label'),
        -hoverHelp  =>$i18n->get('attribute description description'),
        );
    $form->matrixFieldType(
        -name       =>"fieldType",
        -value      =>$attribute->{fieldType},
        -label      =>$i18n->get('fieldType label'),
        -hoverHelp  =>$i18n->get('fieldType description'),
        );
    my $defaultValueForm = WebGUI::Form::Text($self->session, {
                name=>"defaultValue",
                value=>$attribute->{defaultValue},
                resizable=>0,
            });
    my $optionsForm = WebGUI::Form::Textarea($self->session, {
                name=>"options",
                value=>$attribute->{options},
                });

    my $html =  "\n<tr><td colspan='2'>\n";
    $html .=    "\t<div id='optionsAndDefaultValue_module'>\n";
    $html .=    "\t<div class='bd' style='padding:0px;'>\n";
    $html .=    "\t<table cellpadding='0' cellspacing='0' style='width: 100%;'>\n";

    $html .=    "\t<tr><td class='formDescription' valign='top' style='width:180px'>"
                .$i18n->get('attribute defaultValue label')
                ."<div class='wg-hoverhelp'>".$i18n->get('attribute defaultValue description')."</div></td>"
                ."<td valign='top' class='tableData' style='padding-left:4px'>"
                .$defaultValueForm."</td>"
                ."\t\n</tr>\n";

    $html .=    "\t<tr><td class='formDescription' valign='top' style='width:180px'>"
                .$i18n->get('attribute options label')
                ."<div class='wg-hoverhelp'>".$i18n->get('attribute options description')."</div></td>"
                ."<td valign='top' class='tableData' style='padding-left:4px'>"
                .$optionsForm."</td>"
                ."\t\n</tr>\n";


    $html .=    "\t</table>";
    $html .=    "\t\n</div>\t\n</div>\n";
    $html .=    "</td></tr>";

    $html .=    "<script type='text/javascript'>\n"
                ."var optionsAndDefaultValue_module = new YAHOO.widget.Module('optionsAndDefaultValue_module',"
                ."{visible:false});\n"
                ."optionsAndDefaultValue_module.render();\n"
                ."YAHOO.util.Event.onContentReady('fieldType_formId', checkFieldType);\n"
                ."YAHOO.util.Event.addListener('fieldType_formId', 'change', checkFieldType);\n"
                ."var hasOptions = {'SelectBox': true,'Combo': true};\n"
                ."function checkFieldType(){\n"
                ."  if (this.value in hasOptions){\n"
                ."      optionsAndDefaultValue_module.show();\n"
                ."  }else{\n"
                ."      optionsAndDefaultValue_module.hide();\n"
                ."  }\n"
                ."}\n"
                ."</script>\n";

    $form->raw($html);

    $form->selectBox(
        -name       =>"category",
        -value      =>[$attribute->{category}],
        -label      =>$i18n->get('category label'),
        -hoverHelp  =>$i18n->get('category description'),
        -options    =>$self->getCategories,
        );
    $form->submit;
    return $self->getAdminConsole->render($form->print, $i18n->get('edit attribute title'));
}

#-------------------------------------------------------------------

=head2 www_editAttributeSave ( )

Processes and saves an attribute. 

=cut

sub www_editAttributeSave {
    my $self                = shift;
    my $session             = $self->session;
    my $form                = $session->form;
    
    return $session->privilege->insufficient() unless $self->canEdit;

    my $attributeProperties = {
        attributeId     =>$form->process("attributeId") || 'new',
        assetId         =>$self->getId,
        name            =>$form->process('name'),
        description     =>$form->process('description'),
        fieldType       =>$form->process('fieldType'),
        options         =>$form->process('options'),
        defaultValue    =>$form->process('defaultValue'),
        category        =>$form->process('category'),
   };
    
    $self->editAttributeSave($attributeProperties);

    return $self->www_listAttributes;
}

#-------------------------------------------------------------------

=head2 www_exportAttributes ( )

Exports search attributes as csv.

=cut

sub www_exportAttributes {
    my $self    = shift;
    my $session = $self->session;
    my $output  = WebGUI::Text::joinCSV("name","description","category");

    my $attributes = $session->db->read("select name, description, category 
            from Matrix_attribute where assetId = ? order by category, name",[$self->getId]);

    while (my $attribute = $attributes->hashRef) {
        $output .= "\n".WebGUI::Text::joinCSV($attribute->{name},$attribute->{description},$attribute->{category});
    }

    my $fileName = "export_matrix_attributes.csv";
    $self->session->http->setFilename($fileName,"application/octet-stream");
    $self->session->http->sendHeader;
    return $output;
}

#-------------------------------------------------------------------

=head2 www_getCompareFormData  (  )

Returns the compare form data as JSON.

=head3 sort 

The criterium by which the listings should be sorted.

=cut

sub www_getCompareFormData {

    my $self            = shift;
    my $session         = $self->session;
    my $form            = $session->form;
    my $sort            = shift || $session->scratch->get('matrixSort') || $self->get('defaultSort');
    my $sortDirection   = ' desc';
    if ($sort eq 'title'){
        $sortDirection = ' asc';
    }
    
    my @listingIds = $session->form->checkList("listingId");
    
    $session->http->setMimeType("application/json");
    my $db = $session->db;

    my (@searchParams,@searchParams_sorted,@searchParamList,$searchParamList);
    if($form->process("search")){
        foreach my $param ($form->param) {
            if($param =~ m/^search_/){
                my $parameter;
                $parameter->{name}  = $param;
                $parameter->{value} = $form->process($param);
                my $attributeId = $param;
                $attributeId =~ s/^search_//;
                $attributeId =~ s/_____/-/g;
                $parameter->{attributeId} = $attributeId;
                push(@searchParamList,  $db->quote($parameter->{attributeId}) );
                push(@searchParams,     $parameter);
            }
        }
        if (! scalar @searchParamList) {
            ##Use defaults for all form values
            foreach my $category (keys %{$self->getCategories}) {
                my $attributes = $db->read("select * from Matrix_attribute where category =? and assetId = ?",
                    [$category,$self->getId]);
                while (my $attribute = $attributes->hashRef) {
                    push @searchParamList, $db->quote($attribute->{attributeId});
                    push @searchParams, {
                        name        => $attribute->{name},
                        value       => $attribute->{defaultValue},
                        attributeId => $attribute->{attributeId},
                    };
                }
            }
        }
        $searchParamList        = join(',',@searchParamList);
        @searchParams_sorted    = sort { $b->{value} <=> $a->{value} } @searchParams;
    }

    my @results;
    if($form->process("search")) {
        if ($searchParamList) {
            RESULT: foreach my $result (@{$self->getListings}) {
                my $checked = '';
                my $matrixListing_attributes = $session->db->buildHashRefOfHashRefs("
                            select value, fieldType, attributeId from Matrix_attribute
                            left join MatrixListing_attribute as listing using(attributeId)
                            where listing.matrixListingId = ? 
                            and attributeId IN(".$searchParamList.")",
                            [$result->{assetId}],'attributeId');
                ##Searching is AND based.
                PARAM: foreach my $param (@searchParams_sorted) {
                        my $fieldType       = $matrixListing_attributes->{$param->{attributeId}}->{fieldType};
                        my $listingValue    = $matrixListing_attributes->{$param->{attributeId}}->{value};
                        if(($fieldType eq 'MatrixCompare') && ($listingValue < $param->{value})){
                            $checked = '';
                            last PARAM;
                        }
                        elsif(($fieldType ne 'MatrixCompare' && $fieldType ne '') && ($param->{value} ne $listingValue)){
                            $checked = '';
                            last PARAM;
                        }
                        else{
                            $checked = 'checked';
                        }
                }
                $result->{assetId}  =~ s/-/_____/g;
                push @results, $result if $checked eq 'checked';
            }
        }
        else {   
            foreach my $result (@{$self->getListings}) {
                $result->{assetId}  =~ s/-/_____/g;
                push @results, $result;
            }
        }
    }
    else {
        foreach my $result (@{$self->getListings}) {
            $result->{assetId}  =~ s/-/_____/g;
            if(WebGUI::Utility::isIn($result->{assetId},@listingIds)){
                $result->{checked} = 'checked';
            }
            push @results, $result;
        }
    }

    my $jsonOutput;
    $jsonOutput->{ResultSet} = {Result=>\@results};

    my $encodedOutput = JSON->new->encode($jsonOutput);

    return $encodedOutput;
}

#-------------------------------------------------------------------

=head2 www_getCompareListData  (  )

Returns the compare list data as JSON.

=head3 listingIds

An array of listingIds that should be shown in the compare list datatable.

=cut

sub www_getCompareListData {

    my $self        = shift;
    my $listingIds  = shift;
    my $session     = $self->session;
    my $i18n        = WebGUI::International->new($session,'Asset_Matrix');
    my (@results,@columnDefs,@listingIds);

    if ($listingIds) {
        @listingIds = @{$listingIds};
    }
    else{
        @listingIds = $self->session->form->checkList("listingId");
    }
    my @responseFields = ("attributeId", "name", "description","fieldType", "checked");
    
    foreach my $listingId (@listingIds){
        $listingId =~ s/_____/-/g;
        my $listing = WebGUI::Asset::MatrixListing->new($session,$listingId);
        $listing->incrementCounter("compares");
        my $listingId_safe = $listingId;
        $listingId_safe =~ s/-/_____/g;
        push(@columnDefs,{
            key         =>$listingId_safe,
            label       =>$listing->get('title').' '.$listing->get('version'),
            formatter   =>"formatColors",
            url         =>$listing->getUrl,
            lastUpdated =>$session->datetime->epochToHuman( $listing->get('lastUpdated'),"%z" ),
        });
        push(@responseFields, $listingId_safe, $listingId_safe."_compareColor");
    }
    push(@results,{name=>$i18n->get('last updated label'),fieldType=>'lastUpdated'});
    
    my $jsonOutput;
    $jsonOutput->{ColumnDefs}       = \@columnDefs;
    $jsonOutput->{ResponseFields}   = \@responseFields;

    foreach my $category (keys %{$self->getCategories}) {
        push(@results,{name=>$category,fieldType=>'category'});
        my $fields = " a.name, a.fieldType, a.attributeId, a.description ";
        my $from = "from Matrix_attribute a";
        my $tableCount = "b";
        my $where;
        foreach my $listingId (@listingIds) {
            my $listingId_safe = $listingId;
            $listingId_safe =~ s/-/_____/g;
            $fields .= ", ".$tableCount.".value as `$listingId_safe`";
            $from .= " left join MatrixListing_attribute ".$tableCount." on a.attributeId=".$tableCount.".attributeId";
            $where .=  "and ".$tableCount.".matrixListingId=?";
            $tableCount++;
        }
        push(@results, @{ $self->session->db->buildArrayRefOfHashRefs(
            "select $fields $from where a.category=? and a.assetId=? ".$where." order by a.name",
            [$category,$self->getId,@listingIds]
        ) });
    }

    foreach my $result (@results){
        if($result->{fieldType} eq 'category'){
            # Row starting with a category label shows the listing name in each column
            foreach my $columnDef (@columnDefs) {
                $result->{$columnDef->{key}} = $columnDef->{label}; 
            }
        }
        elsif($result->{fieldType} eq 'lastUpdated'){
            foreach my $columnDef (@columnDefs) {
                $result->{$columnDef->{key}} = $columnDef->{lastUpdated};
            }
        }
        else{
            foreach my $listingId (@listingIds) {
                $result->{attributeId} =~ s/-/_____/g;
                my $listingId_safe = $listingId;
                $listingId_safe =~ s/-/_____/g;
                if ($result->{fieldType} eq 'MatrixCompare'){
                    my $originalValue = $result->{$listingId_safe};
                    $result->{$listingId_safe.'_compareColor'} = $self->getCompareColor($result->{$listingId_safe});
                    $result->{$listingId_safe} = WebGUI::Form::MatrixCompare->new( $self->session, 
                        { value=>$result->{$listingId_safe} },defaultValue=>0)->getValueAsHtml;
                }
                if($session->scratch->get('stickied_'.$result->{attributeId})){
                    # $self->session->errorHandler->warn("found checked stickie: ".$result->{attributeId});
                    $result->{checked} = 'checked';
                }
                else{
                    $result->{checked} = '';
                }
            }
        }
    }

    $jsonOutput->{ResultSet} = {Result=>\@results};
    $session->http->setMimeType("application/json");

    return JSON->new->encode($jsonOutput);
}
#-------------------------------------------------------------------

=head2 www_listAttributes ( )

Lists all attributes of this Matrix. 

=cut

sub www_listAttributes {
    my $self    = shift;
    my $session = $self->session;
    
    return $session->privilege->insufficient() unless($self->canEdit);
    
    my $i18n       = WebGUI::International->new($session,'Asset_Matrix');
    my $console    = $self->getAdminConsole();
    my $attributes = $session->db->read("select attributeId, name from Matrix_attribute where assetId=? order by name"
        ,[$self->getId]);
    my $output = '';
    while (my $attribute = $attributes->hashRef) {
        $output .= $session->icon->delete(
                       "func=deleteAttribute;attributeId=".$attribute->{attributeId},
                       $self->getUrl,$i18n->get("delete attribute confirm message")
                   )
                . $session->icon->edit("func=editAttribute;attributeId=".$attribute->{attributeId})
                . ' '
                . $attribute->{name}
                ."<br />\n";
    }
    $console->addSubmenuItem($self->getUrl("func=editAttribute;attributeId=new"), $i18n->get('add attribute label'));
    $console->addSubmenuItem($self->getUrl, $i18n->get('Return to Matrix'));
    return $console->render($output, $i18n->get('list attributes title'));
}

#-------------------------------------------------------------------

=head2 www_search  (  )

Returns the search screen.  Uses www_getCompareFormData with search=1 for doing AJAX requests.

=cut

sub www_search {

    my $self    = shift;
    my $var     = $self->get;
    my $db      = $self->session->db;
    
    $var->{compareForm}     = $self->getCompareForm;
    $self->session->style->setScript($self->session->url->extras('yui/build/yahoo/yahoo-min.js'),
        {type => 'text/javascript'});
    $self->session->style->setScript($self->session->url->extras('yui/build/dom/dom-min.js'),
        {type => 'text/javascript'});
    $self->session->style->setScript($self->session->url->extras('yui/build/event/event-min.js'),
        {type => 'text/javascript'});
    $self->session->style->setScript($self->session->url->extras('yui/build/json/json-min.js'), {type =>
    'text/javascript'});
    $self->session->style->setScript($self->session->url->extras('yui/build/connection/connection-min.js'),
        {type => 'text/javascript'});
    $self->session->style->setScript($self->session->url->extras('yui/build/get/get-min.js'), {type =>
    'text/javascript'});
    $self->session->style->setScript($self->session->url->extras('yui/build/element/element-beta-min.js'), {type =>
    'text/javascript'});
    $self->session->style->setScript($self->session->url->extras('yui/build/datasource/datasource-min.js'),
    {type => 'text/javascript'});
    $self->session->style->setScript($self->session->url->extras('yui/build/datatable/datatable-min.js'),
    {type =>'text/javascript'});
    $self->session->style->setScript($self->session->url->extras('yui/build/button/button-min.js'),
    {type =>'text/javascript'});
    $self->session->style->setLink($self->session->url->extras('yui/build/datatable/assets/skins/sam/datatable.css'),
        {type =>'text/css', rel=>'stylesheet'});

    foreach my $category (keys %{$self->getCategories}) {
        my $attributes;
        my @attribute_loop;
        my $categoryLoopName = $self->session->url->urlize($category)."_loop";
        $attributes = $db->read("select * from Matrix_attribute where category =? and assetId = ?",
            [$category,$self->getId]);
        while (my $attribute = $attributes->hashRef) {
            $attribute->{label} = $attribute->{name};
            $attribute->{id} = $attribute->{attributeId};
            $attribute->{id} =~ s/-/_____/g;
            $attribute->{extras} = " class='attributeSelect'";
            if($attribute->{fieldType} eq 'Combo'){
                $attribute->{fieldType} = 'SelectBox';
                my %options;
                tie %options, 'Tie::IxHash';
                %options = $db->buildHash('select value, value from MatrixListing_attribute 
                    where attributeId = ? order by value',[$attribute->{attributeId}]);
                $options{'blank'}       = 'blank';
                $attribute->{options}   = \%options;
                $attribute->{value}     = 'blank';
                $attribute->{extras}    .= " style='width:120px'";
            }
            $attribute->{form} = WebGUI::Form::DynamicField->new($self->session,%{$attribute})->toHtml;
            push(@attribute_loop,$attribute);
        }
        $var->{$categoryLoopName} = \@attribute_loop;
        push(@{$var->{category_loop}},{
            categoryLabel   => $category,
            attribute_loop  => \@attribute_loop,
        });
    }

    return $self->processStyle($self->processTemplate($var,$self->get("searchTemplateId")));
}

#-------------------------------------------------------------------

=head2 www_setSort  (  )

Sets the sort scratch variable.

=cut

sub www_setSort {

    my $self = shift;

    if(my $sort = $self->session->form->process("sort")){
        $self->session->scratch->set('matrixSort',$sort);
    }        
    return undef;
}

#-------------------------------------------------------------------

=head2 www_setStickied  (  )

Sets the stickied scratch variable.

=cut

sub www_setStickied {

    my $self = shift;

    if(my $attributeId = $self->session->form->process("attributeId")){
        $self->session->scratch->set('stickied_'.$attributeId,1);
    }     
    return undef;
}

1;
