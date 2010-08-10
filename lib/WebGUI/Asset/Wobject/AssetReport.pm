package WebGUI::Asset::Wobject::AssetReport;

$VERSION = "1.0.0";

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use Tie::IxHash;
use WebGUI::International;
use WebGUI::Paginator;
use WebGUI::Utility;
use Class::C3;
use base qw/WebGUI::AssetAspect::Installable WebGUI::Asset::Wobject/;

#-------------------------------------------------------------------

=head2 definition ( session, definition )

=cut

sub definition {
    my $class      = shift;
    my $session    = shift;
    my $definition = shift;
    my $i18n       = WebGUI::International->new( $session, 'Asset_AssetReport' );

    tie my %properties, 'Tie::IxHash', (
        settings => {
            tab          => 'properties',
            fieldType    => 'AssetReportQuery',
            defaultValue => undef,
        },
        templateId => {
            tab          => "display",
            fieldType    => "template",
            namespace    => "AssetReport",
            defaultValue => "sJtcUCfn0CVbKdb4QM61Yw",
            label        => $i18n->get("templateId label"),
            hoverHelp    => $i18n->get("templateId description"),
        },
        paginateAfter => {
            tab             => 'display',
            fieldType       => 'integer',
            defaultValue    => 25,
            label           => $i18n->get( 'paginateAfter label' ),
            hoverHelp       => $i18n->get( 'paginateAfter description' ),
        },
    );

    push @{$definition}, {
        assetName         => $i18n->get('assetName'),
        autoGenerateForms => 1,
        tableName         => 'AssetReport',
        className         => 'WebGUI::Asset::Wobject::AssetReport',
        properties        => \%properties,
    };

    return $class->SUPER::definition( $session, $definition );
} ## end sub definition


#----------------------------------------------------------------------------

=head2 prepareView ( ) 

Prepare the view. Add stuff to HEAD.

=cut

sub prepareView {
    my $self = shift;
    $self->SUPER::prepareView(@_);
    my $session = $self->session;

    # Prepare the template
    my $template = WebGUI::Asset::Template->new( $session, $self->get("templateId") );
    if (!$template) {
        WebGUI::Error::ObjectNotFound::Template->throw(
            error      => qq{Template not found},
            templateId => $self->get("templateId"),
            assetId    => $self->getId,
        );
    }
    $template->prepare;
    $self->{_template} = $template;

    return;
} ## end sub prepareView

#----------------------------------------------------------------------------

=head2 getTemplateVars ( )

Get template variables common to all views of the Asset Report.

=cut

sub getTemplateVars {
    my $self     = shift;
    my $session  = $self->session;

    my $var      = $self->get;

    #Build the lineage query
    my $settings = JSON->new->decode($self->getValue("settings"));

    #TO DO - ADD CACHE CONTROL

    my $assetId  = $settings->{startNode};
    my $asset    = WebGUI::Asset->newByDynamicClass($session,$assetId);

    my $rules               = {};
    $rules->{'isa'}         = $settings->{className};
    
    #Build where condition
    my $condition           = $settings->{anySelect};
    $rules->{'whereClause'} = undef;
    my $where               = $settings->{where};
    foreach my $key (keys %{$where}) {
        my $clause    = $where->{$key};
        my $prop      = $clause->{propSelect};
        my $op        = $clause->{opSelect};
        my $value     = $clause->{valText};
        
        $rules->{'whereClause'} .= qq{ $condition } if ($key > 1);
        $rules->{'whereClause'} .= qq{$prop $op $value};
    }

    if($rules->{'whereClause'}) {
        $rules->{'joinClass'}   = $settings->{className};
    }

    #Build the order by condition
    my $order                 = $settings->{order};
    my @order                 = keys %{$order};
    if(scalar(@order)) {
        $rules->{'orderByClause'} = undef;
        foreach my $key (@order) {
            my $orderBy     = $order->{$key};
            my $orderSelect = $orderBy->{orderSelect};
            my $dirSelect   = $orderBy->{dirSelect};

            $rules->{'orderByClause'} .= q{, } if($key > 1);
            $rules->{'orderByClause'} .= qq{$orderSelect $dirSelect};
        }
    }

    if($settings->{'limit'}) {
        $rules->{'limit'} = $settings->{'limit'};
    }
    my $sql = $asset->getLineageSql(["descendants"],$rules);

    my $p    = WebGUI::Paginator->new($session,$self->getUrl,$self->get("paginateAfter"));
    $p->setDataByQuery($sql);

    #Build the data for all the assets on the page
    $var->{'asset_loop'} = [];
    my $data = $p->getPageData;
    foreach my $row (@{$data}) {
        my $returnAsset = WebGUI::Asset->new($session,$row->{assetId},$row->{className},$row->{revisionDate});
        push(@{$var->{'asset_loop'}},$returnAsset->get);
    }

    #Append template variables
    $p->appendTemplateVars($var);

    return $var;
}

#----------------------------------------------------------------------------

=head2 view ( )

method called by the www_view method.  Returns a processed template
to be displayed within the page style.  

=cut

sub view {
    my $self     = shift;
    my $var      = $self->getTemplateVars;
    
    return $self->processTemplate( $var, undef, $self->{_template} );
} ## end sub view

#-------------------------------------------------------------------
# Install Methods Below - Do Not Modify

#-------------------------------------------------------------------
sub install {
    my $class     = shift;
    my $session   = shift;
    $class->next::method( $session );

    ### Create a folder asset to store the default template
	my $importNode = WebGUI::Asset->getImportNode($session);
	my $folder     = $importNode->addChild({
		className   => "WebGUI::Asset::Wobject::Folder",
		title       => "Asset Report",
		menuTitle   => "Asset Report",
		url         => "pb_asset_report",
		groupIdView =>"3"
	},"AssetReportFolder00001");

    ### Add the template to the folder
    $folder->addChild({ 
        className   => "WebGUI::Asset::Template",
	    namespace   => "AssetReport",
	    title       => "Asset Report Default Template",
	    menuTitle   => "Asset Report Default Template",
	    ownerUserId => "3",
	    groupIdView => "7",
	    groupIdEdit => "4",
        isHidden    => 1,
        isDefault   => 1,
        template    => qq{
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>
 
<tmpl_if session.var.adminOn>
<p><tmpl_var controls></p>
</tmpl_if>
 
<tmpl_if displayTitle>
<h2><tmpl_var title></h2>
</tmpl_if>
 
<tmpl_if error_loop>
<ul class="errors">
<tmpl_loop error_loop>
<li><b><tmpl_var error.message></b></li>
</tmpl_loop>
</ul>
</tmpl_if>
 
<tmpl_if description>
<tmpl_var description>
<p />
</tmpl_if>
 
<table border="1" cellspacing="0" cellpadding="3">
<thead>
<tr>
<th>Title</th>
<th>Creation Date</th>
<th>Created By</th>
</tr>
</thead>
<tbody>
<tmpl_loop asset_loop>
<tr>
<td><a href="<tmpl_var url>"><tmpl_var title></a></td>
<td>^D('%C %D, %y %h:%s %p',<tmpl_var creationDate>);</td>
<td>^User('username',<tmpl_var createdBy>);</td>
</tr>
</tmpl_loop>
</tbody>
</table>
 
<tmpl_if pagination.pageCount.isMultiple>
<div class="pagination">
<tmpl_var pagination.previousPage> <tmpl_var pagination.pageList.upTo20> <tmpl_var pagination.nextPage>
</div>
</tmpl_if>
        },
        headBlock   =>"",
    }, "AssetReport00000000001");

    ### Commit version tag
    my $tag = WebGUI::VersionTag->new($session, WebGUI::VersionTag->getWorking($session)->getId);
    if (defined $tag) {
        $tag->set({comments=>"Template added/updated by Asset Install Process"});
        $tag->requestCommit;
    }
}

#-------------------------------------------------------------------
sub uninstall {
    my $class     = shift;
    my $session   = shift;
    $class->next::method( $session );
    
    my $template  = WebGUI::Asset->newByDynamicClass($session,"AssetReport00000000001");    
    $template->purge if($template);
    
    my $folder    = WebGUI::Asset->newByDynamicClass($session,"AssetReportFolder00001");
    $folder->purge if($folder);
}

1;
