package WebGUI::Asset::Wobject::Shelf;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2008 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use List::MoreUtils;
use Tie::IxHash;
use WebGUI::International;
use base 'WebGUI::Asset::Wobject';

#-------------------------------------------------------------------

=head2 definition ( )

Add our custom properties of templateId to this asset.

=cut

sub definition {
	my ($class, $session, $definition) = @_;
	my $i18n = WebGUI::International->new($session, 'Asset_Shelf');
	my %properties;
	tie %properties, 'Tie::IxHash';
	%properties = (
		templateId =>{
			fieldType		=> "template",  
			defaultValue	=> 'nFen0xjkZn8WkpM93C9ceQ',
			tab				=> "display",
			namespace		=> "Shelf", 
			hoverHelp		=> $i18n->get('shelf template help'),
			label			=> $i18n->get('shelf template'),
		}
	);
	push(@{$definition}, {
		assetName			=> $i18n->get('assetName'),
		icon				=> 'Shelf.gif',
		autoGenerateForms	=> 1,
		tableName			=> 'Shelf',
		className			=> 'WebGUI::Asset::Wobject::Shelf',
		properties			=> \%properties
		});
        return $class->SUPER::definition($session, $definition);
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
}


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
	foreach my $child (@{$self->getLineage(['children'],{returnObjects=>1,includeOnlyClasses=>['WebGUI::Asset::Wobject::Shelf']})}) {
		my $properties = $child->get;
		$child->{url} = $self->getUrl;
		push @childShelves, $child;
	}
	
	# get other child skus
	my @childSkus = @{$self->getLineage(['children'],{isa=>'WebGUI::Asset::Sku'})};
	
	# find products based upon keywords
	my @keywords = $self->get('keywords');
	my $keywordBasedAssetIds = WebGUI::Keyword->new($session)->getMatchingAssets({
		matchAssetKeywords	=> $self,
		isa					=> 'WebGUI::Asset::Sku',
		});

	# create paginator
	my @products = List::MoreUtils::uniq(@childSkus, @{$keywordBasedAssetIds});
	my $p = WebGUI::Paginator->new($session, $self->getUrl('func=view'));
	$p->setDataByArrayRef(\@products);

	# generate template variables
	my @skus = ();
	foreach my $id (@{$p->getPageData}) {
		my $asset = WebGUI::Asset->newByDynamicClass($session, $id);
		if (defined $asset) {
			my $sku = $asset->get;
			$sku->{url} = $asset->getUrl;
			$sku->{thumbnailUrl} = $asset->getThumbnailUrl;
			$sku->{price} = sprintf("%.2f", $asset->getPrice);
			push @skus, $sku;
		}
		else {
			$session->errorHandler->error(q|Couldn't instanciate SKU with assetId |.$id.q| on shelf with assetId |.$self->getId);
		}
	}
	my %var = (
		shelves		=> \@childShelves,
		products	=> \@skus,
		);
	$p->appendTemplateVars(\%var);
	
	# render page
	return $self->processTemplate(\%var, undef, $self->{_viewTemplate});
}



1;
