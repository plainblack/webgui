package WebGUI::Asset::Wobject::Shelf;

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
use List::MoreUtils;
use WebGUI::International;
use Moose;
use WebGUI::Definition::Asset;
extends 'WebGUI::Asset::Wobject';
use WebGUI::Text;
use WebGUI::Storage;
use WebGUI::Exception::Shop;
use WebGUI::Asset::Sku::Product;

define assetName  => ['assetName', 'Asset_Shelf'];
define icon       => 'Shelf.gif';
define tableName  => 'Shelf';

property templateId => (
            fieldType        => "template",  
            default          => 'nFen0xjkZn8WkpM93C9ceQ',
            tab              => "display",
            namespace        => "Shelf", 
            hoverHelp        => ['shelf template help', 'Asset_Shelf'],
            label            => ['shelf template', 'Asset_Shelf'],
);

#----------------------------------------------------------------------------

=head2 getHelpers ( )

Add the importCSV and exportCSV helpers to the Shelf

=cut

override getHelpers => sub {
    my ( $self ) = @_;
    my $helpers = super();

    $helpers->{import_products} = {
        className   => 'WebGUI::AssetHelper::Product::ImportCSV',
        label       => 'Import Products',
    };
    $helpers->{export_products} = {
        className   => 'WebGUI::AssetHelper::Product::ExportCSV',
        label       => 'Export Products',
    };

    return $helpers;
};

#-------------------------------------------------------------------

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

override prepareView => sub {
    my $self = shift;
    super();
    my $template = WebGUI::Asset::Template->newById($self->session, $self->templateId); # boom XXX
    if (!$template) {
        WebGUI::Error::ObjectNotFound::Template->throw(
            error      => qq{Template not found},
            templateId => $self->get("templateId"),
            assetId    => $self->getId,
        );
    }
    $template->prepare($self->getMetaDataAsTemplateVariables);
    $self->{_viewTemplate} = $template;
};


#-------------------------------------------------------------------

=head2 view ( )

method called by the www_view method.  Returns a processed template
to be displayed within the page style.  

=cut

sub view {
	my $self = shift;
	my $session = $self->session;
	
	# get other shelves
	my @childShelves = ();
        my $childIter = $self->getLineageIterator(['children'],{includeOnlyClasses=>['WebGUI::Asset::Wobject::Shelf']});
        SHELF: while ( 1 ) {
            my $child;
            eval { $child = $childIter->() };
            if ( my $x = WebGUI::Error->caught('WebGUI::Error::ObjectNotFound') ) {
                $session->log->error($x->full_message);
                next;
            }
            last unless $child;
        next SHELF unless $child->canView;
		my $properties  = $child->get;
		$properties->{url}   = $child->getUrl;
		$properties->{title} = $child->getTitle;
		push @childShelves, $properties;
	}
	
	# get other child skus
	my @childSkus = @{$self->getLineage(['children'],{isa=>'WebGUI::Asset::Sku'})};
	
	# find products based upon keywords
	my @keywords = $self->keywords;
	my $keywordBasedAssetIds = WebGUI::Keyword->new($session)->getMatchingAssets({
		matchAssetKeywords	=> $self,
		isa					=> 'WebGUI::Asset::Sku',
		});

    ##Prescreen to only paginate viewable products
	my @productIds = List::MoreUtils::uniq(@childSkus, @{$keywordBasedAssetIds});
    my @products = ();
    PRODUCT: foreach my $id (@productIds) {
		my $asset = WebGUI::Asset->newById($session, $id);
        if (!defined $asset) {
			$session->log->error(q|Couldn't instanciate SKU with assetId |.$id.q| on shelf with assetId |.$self->getId);
            next PRODUCT;
        }
        push @products, $asset if $asset->canView;
    }

	# create paginator
	my $p = WebGUI::Paginator->new($session, $self->getUrl('func=view'));
	$p->setDataByArrayRef(\@products);

	# generate template variables
    my @skus = ();
    foreach my $asset (@{$p->getPageData}) {
        my $sku               = $asset->get;
        $sku->{url}           = $asset->getUrl;
        $sku->{thumbnailUrl}  = $asset->getThumbnailUrl;
        $sku->{price}         = sprintf("%.2f", $asset->getPrice ? $asset->getPrice : 0);
        $sku->{addToCartForm} = $asset->getAddToCartForm;
        push @skus, $sku;
    }
	my %var = (
		shelves		    => \@childShelves,
		products	    => \@skus,
        noViewableSkus  => scalar(@skus)       ? 0 : 1,
        emptyShelf      => scalar(@productIds) ? 0 : 1,
		);
	$p->appendTemplateVars(\%var);
	
	# render page
	return $self->processTemplate(\%var, undef, $self->{_viewTemplate});
}

__PACKAGE__->meta->make_immutable;
1;
