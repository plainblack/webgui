package WebGUI::Asset::Wobject::Matrix;

use strict;
our $VERSION = "2.0.0";

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2008 Plain Black Corporation.
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

    return 0 if $self->session->user->isVisitor;

    return 1;
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
        defaultSort=>{
            fieldType       =>"selectBox",
            tab             =>"display",
            options         =>{ 
                                score           => $i18n->get('sort by score label'),
                                title           => $i18n->get('sort alpha numeric label'),
                                lineage         => $i18n->get('sort by asset rank label'),
                                revisionDate    => $i18n->get('sort by last updated label'),
                              },
            defaultValue    =>"score",
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
    else{
        $maxComparisons = $self->get('maxComparisonsPrivileged');
    }        
    $form .=  "\n<script type='text/javascript'>\n".
        'var maxComparisons = '.$maxComparisons.";\n".
        "var matrixUrl = '".$self->getUrl."';\n".
        "\n</script>\n";
    return $form;
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

    # javascript and css files for compare form datatable
    $self->session->style->setLink($self->session->url->extras('yui/build/datatable/assets/skins/sam/datatable.css'), 
        {type =>'text/css', rel=>'stylesheet'});
    $self->session->style->setScript($self->session->url->extras('yui/build/json/json-min.js'), {type =>
    'text/javascript'});
    $self->session->style->setScript($self->session->url->extras('yui/build/connection/connection-min.js'), {type =>
    'text/javascript'});
    $self->session->style->setScript($self->session->url->extras('yui/build/get/get-min.js'), {type =>
    'text/javascript'});
    $self->session->style->setScript($self->session->url->extras('yui/build/element/element-beta-min.js'), {type =>
    'text/javascript'});
    $self->session->style->setScript($self->session->url->extras('yui/build/datasource/datasource-min.js'), {type =>
    'text/javascript'});
    $self->session->style->setScript($self->session->url->extras('yui/build/datatable/datatable-min.js'), {type =>
    'text/javascript'});
    $self->session->style->setScript($self->session->url->extras('yui/build/button/button-min.js'), {type =>
    'text/javascript'});
    $self->session->style->setScript($self->session->url->extras('wobject/Matrix/matrix.js'), {type =>
    'text/javascript'});
    
	my $var = $self->get;
    $var->{isLoggedIn}              = ($self->session->user->userId ne "1");
    $var->{addMatrixListing_url}    = $self->getUrl('func=add;class=WebGUI::Asset::MatrixListing'); 
    $var->{compareForm}             = $self->getCompareForm;
    $var->{exportAttributes_url}    = $self->getUrl('func=exportAttributes');
    $var->{listAttributes_url}      = $self->getUrl('func=listAttributes');
    $var->{search_url}              = $self->getUrl('func=search');
    
    # Get the MatrixListing with the most views as an object using getLineage.
    my ($bestViews_listing) = @{ $self->getLineage(['descendants'], {
            includeOnlyClasses  => ['WebGUI::Asset::MatrixListing'],
            joinClass           => "WebGUI::Asset::MatrixListing",
            orderByClause       => "views desc",
            limit               => 1,
            returnObjects       => 1,
        }) };
    if($bestViews_listing){
        $var->{bestViews_url}           = $bestViews_listing->getUrl;
        $var->{bestViews_count}         = $bestViews_listing->get('views');
        $var->{bestViews_name}          = $bestViews_listing->get('title');
        $var->{bestViews_sortButton}    = "<span id='sortByViews'><button type='button'>Sort by views</button></span><br />";
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
        $var->{bestCompares_url}        = $bestCompares_listing->getUrl;
        $var->{bestCompares_count}      = $bestCompares_listing->get('compares');
        $var->{bestCompares_name}       = $bestCompares_listing->get('title');
        $var->{bestCompares_sortButton} = "<span id='sortByCompares'><button type='button'>Sort by compares</button></span><br />";
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
        $var->{bestClicks_url}          = $bestClicks_listing->getUrl;
        $var->{bestClicks_count}        = $bestClicks_listing->get('clicks');
        $var->{bestClicks_name}         = $bestClicks_listing->get('title');
        $var->{bestClicks_sortButton}   = "<span id='sortByClicks'><button type='button'>Sort by clicks</button></span><br />";
    }
    # Get the 5 MatrixListings that were last updated as objects using getLineage.

    my @lastUpdatedListings = @{ $self->getLineage(['descendants'], {
            includeOnlyClasses  => ['WebGUI::Asset::MatrixListing'],
            orderByClause       => "revisionDate desc",
            limit               => 5,
            returnObjects       => 1,
        }) };
    foreach my $lastUpdatedListing (@lastUpdatedListings){
        push (@{ $var->{last_updated_loop} }, {
                        url         => $lastUpdatedListing->getUrl,
                        name        => $lastUpdatedListing->get('title'),
                        lastUpdated => $self->session->datetime->epochToHuman($lastUpdatedListing->get('revisionDate'),"%z")
                    });
    }
    $var->{lastUpdated_sortButton}  = "<span id='sortByUpdated'><button type='button'>Sort by updated</button></span><br />";


    # Get all the MatrixListings that are still pending.

    my @pendingListings = @{ $self->getLineage(['descendants'], {
            includeOnlyClasses  => ['WebGUI::Asset::MatrixListing'],
            orderByClause       => "revisionDate asc",
            returnObjects       => 1,
            statusToInclude     => ['pending'],
        }) };
    foreach my $pendingListing (@pendingListings){
        push (@{ $var->{pending_loop} }, {
                        url     => $pendingListing->getUrl,
                        name    => $pendingListing->get('title'),
                    });
    }   
 
    # For each category, get the MatrixListings with the best ratings.

    foreach my $category (keys %{$self->getCategories}) {
        my $data;
        my $sql = "
        select 
            assetData.title as productName,
            assetData.url,
            rating.listingId, 
            rating.meanValue, 
            asset.parentId 
        from 
            MatrixListing_ratingSummary as rating 
            left join asset on (rating.listingId = asset.assetId)
            left join assetData on assetData.assetId = rating.listingId 
        where 
            rating.category =? 
            and asset.parentId=? 
            and asset.state='published' 
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
        push(@{ $var->{best_rating_loop} },{
            url=>'/'.$data->{url},
            category=>$category,
            name=>$data->{productName},
            mean=>$data->{meanValue},
            median=>$data->{medianValue},
            count=>$data->{countValue}
            });
        $data = $db->quickHashRef($sql." asc limit 1",[$category,$self->getId]);
        push(@{ $var->{worst_rating_loop} },{
            url=>'/'.$data->{url},
            category=>$category,
            name=>$data->{productName},
            mean=>$data->{meanValue},
            median=>$data->{medianValue},
            count=>$data->{countValue}
            });
    }

    $var->{listingCount} = scalar $db->buildArray("
        select  * 
        from    asset, assetData
        where   asset.assetId=assetData.assetId
                and asset.parentId=?
                and asset.state='published'
                and asset.className='WebGUI::Asset::MatrixListing'
                and assetData.status='approved'
        group by asset.assetId",
        [$self->getId]);
	
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
    $self->session->style->setScript($self->session->url->extras('wobject/Matrix/matrixCompareList.js'), {type =>
    'text/javascript'});
    $self->session->style->setScript($self->session->url->extras('wobject/Matrix/matrix.js'), {type =>
    'text/javascript'});
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
    else{
        $maxComparisons = $self->get('maxComparisonsPrivileged');
    }

    foreach my $listingId (@listingIds){
        my $listingId_safe = $listingId;
        $listingId_safe =~ s/-/_____/g;
        push(@responseFields, $listingId_safe, $listingId_safe."_compareColor");
    }
    
    $var->{javascript} = "<script type='text/javascript'>\n".
        'var listingIds = new Array('.join(", ",map {'"'.$_.'"'} @listingIds).");\n".
        'var responseFields = new Array("attributeId", "name", "description","fieldType", "checked", '.join(", ",map {'"'.$_.'"'} @responseFields).");\n".
        "var maxComparisons = ".$maxComparisons.";\n".
        "var matrixUrl = '".$self->getUrl."';\n".
        "</script>";

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
#    if ( WebGUI::Utility::isIn($sort, qw(revisionDate score)) ) {
#        $sortDirection = " desc";
#    }
    my @results;
    my @listingIds = $self->session->form->checkList("listingId");
    
    $self->session->http->setMimeType("application/json");

    my $sql = "
        select
            assetData.title,
            assetData.url,
            listing.assetId,
            listing.views,
            listing.compares,
            listing.clicks,
            listing.lastUpdated
        from MatrixListing as listing
            left join asset on listing.assetId = asset.assetId
            left join assetData on assetData.assetId = listing.assetId and listing.revisionDate =
assetData.revisionDate
        where
            asset.parentId=?
            and asset.state='published'
            and asset.className='WebGUI::Asset::MatrixListing'
            and assetData.revisionDate=(
                select
                    max(revisionDate)
                from
                    assetData
                where
                    assetData.assetId=asset.assetId
                    and (status='approved' or status='archived')
            )
            and status='approved'
        group by
            assetData.assetId
        order by ".$sort.$sortDirection;

    @results = @{ $session->db->buildArrayRefOfHashRefs($sql,[$self->getId]) };
    foreach my $result (@results){
            if($form->process("search")){
                # $self->session->errorHandler->warn("checking listing: ".$result->{title});
                my $matrixListing_attributes = $session->db->buildHashRefOfHashRefs("
                            select value, fieldType, attributeId from MatrixListing_attribute as listing
                            left join Matrix_attribute using(attributeId)
                            where listing.matrixListingId = ?
                        ",[$result->{assetId}],'attributeId');
                foreach my $param ($form->param) {
                    if($param =~ m/^search_/){
                        my $attributeId = $param;
                        $attributeId =~ s/^search_//;
                        $attributeId =~ s/_____/-/;
                        my $fieldType       = $matrixListing_attributes->{$attributeId}->{fieldType};
                        my $listingValue    = $matrixListing_attributes->{$attributeId}->{value};
                        # $self->session->errorHandler->warn("fieldType:".$fieldType.", attributeValue: ".$form->process($param).", listingvalue: ".$listingValue);
                        if(($fieldType eq 'MatrixCompare') && ($listingValue < $form->process($param))){
                            $result->{checked} = '';
                            last;
                        }
                        elsif(($fieldType ne 'MatrixCompare') && ($form->process($param) ne $listingValue)){
                            $result->{checked} = '';
                            last;
                        }
                        else{
                            $result->{checked} = 'checked';
                        }
                    }
                }
            }
            else{
                $result->{assetId}  =~ s/-/_____/g;
                if(WebGUI::Utility::isIn($result->{assetId},@listingIds)){
                    $result->{checked} = 'checked';
                }
            }
            $result->{assetId}  =~ s/-/_____/g;
            $result->{url}      = $session->url->gateway($result->{url});
    }

    my $jsonOutput;
    $jsonOutput->{ResultSet} = {Result=>\@results};

    return JSON->new->utf8->encode($jsonOutput);
}

#-------------------------------------------------------------------

=head2 www_getCompareListData  (  )

Returns the compare list data as JSON.

=head3 listingIds

An array of listingIds that should be shown in the compare list datatable.

=cut

sub www_getCompareListData {

    my $self        = shift;
    my @listingIds  = @_;
    my $session     = $self->session;
    my $i18n        = WebGUI::International->new($session,'Asset_Matrix');
    my (@results,@columnDefs);

    unless (scalar(@listingIds)) {
        @listingIds = $self->session->form->checkList("listingId");
    }


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
            lastUpdated =>$session->datetime->epochToHuman( $listing->get('revisonDate'),"%z" ),
        });
    }
    push(@results,{name=>$i18n->get('last updated label'),fieldType=>'lastUpdated'});
    
    my $jsonOutput;
    $jsonOutput->{ColumnDefs} = \@columnDefs;

    foreach my $category (keys %{$self->getCategories}) {
        push(@results,{name=>$category,fieldType=>'category'});
        my $fields = " a.name, a.fieldType, a.attributeId, a.description ";
        my $from = "from Matrix_attribute a";
        my $tableCount = "b";
        foreach my $listingId (@listingIds) {
            my $listingId_safe = $listingId;
            $listingId_safe =~ s/-/_____/g;
            $fields .= ", ".$tableCount.".value as `$listingId_safe`";
            $from .= " left join MatrixListing_attribute ".$tableCount." on a.attributeId="
                .$tableCount.".attributeId and ".$tableCount.".matrixListingId=? ";
            $tableCount++;
        }
        push(@results, @{ $self->session->db->buildArrayRefOfHashRefs(
            "select $fields $from where a.category=? and a.assetId=? order by a.name",
            [@listingIds,$category,$self->getId]
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

    return JSON->new->utf8->encode($jsonOutput);
}
#-------------------------------------------------------------------

=head2 www_listAttributes ( )

Lists all attributes of this Matrix. 

=cut

sub www_listAttributes {
    my $self    = shift;
    my $session = $self->session;
    
    return $session->privilege->insufficient() unless($self->canEdit);
    
    my $i18n = WebGUI::International->new($session,'Asset_Matrix');
    my $output = "<br /><a href='".$self->getUrl("func=editAttribute;attributeId=new")."'>"
                .$i18n->get('add attribute label')."</a><br /><br />";
    
    my $attributes = $session->db->read("select attributeId, name from Matrix_attribute where assetId=? order by name"
        ,[$self->getId]);
    while (my $attribute = $attributes->hashRef) {
        $output .= $session->icon->delete("func=deleteAttribute;attributeId=".$attribute->{attributeId}
            , $self->getUrl,$i18n->get("delete attribute confirm message"))
            .$session->icon->edit("func=editAttribute;attributeId=".$attribute->{attributeId})
            .' '.$attribute->{name}."<br />\n";
    }
    return $self->getAdminConsole->render($output, $i18n->get('list attributes title'));
}

#-------------------------------------------------------------------

=head2 www_search  (  )

Returns the search screen.

=cut

sub www_search {

    my $self    = shift;
    my $var     = $self->get;
    
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
    $self->session->style->setScript($self->session->url->extras('wobject/Matrix/matrixSearch.js'), {type =>
    'text/javascript'});
    $self->session->style->setLink($self->session->url->extras('yui/build/datatable/assets/skins/sam/datatable.css'),
        {type =>'text/css', rel=>'stylesheet'});

    foreach my $category (keys %{$self->getCategories}) {
        my $attributes;
        my @attribute_loop;
        my $categoryLoopName = $self->session->url->urlize($category)."_loop";
        $attributes = $self->session->db->read("select * from Matrix_attribute where category =? and assetId = ?",
            [$category,$self->getId]);
        while (my $attribute = $attributes->hashRef) {
            $attribute->{label} = $attribute->{name};
            $attribute->{id} = $attribute->{attributeId};
            $attribute->{id} =~ s/-/_____/g;
            $attribute->{extras} = " class='attributeSelect'";
            if($attribute->{fieldType} eq 'Combo'){
                $attribute->{fieldType} = 'SelectBox';
            }
            if($attribute->{fieldType} eq 'SelectBox'){    
                $attribute->{options}   = "blank\n".$attribute->{options};
                $attribute->{value}     = 'blank';
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
