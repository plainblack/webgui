package WebGUI::Macro::AdminBar;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict qw(refs vars);
use Tie::CPHash;
use Tie::IxHash;
use WebGUI::AdminConsole;
use WebGUI::Asset;
use WebGUI::Asset::Template;
use WebGUI::Grouping;
use WebGUI::International;
use WebGUI::Utility;

=head1 NAME

Package WebGUI::Macro::AdminBar

=head1 DESCRIPTION

Macro for displaying administrative functions to a user with Admin turned on.

=head2 process ( [templateId ] )

process takes one optional parameters for customizing the layout
of the Admin bar.

=head3 templateId

The ID for a template to use for formatting the link.  The default template creates the sliding
Admin bar to the left of the screen.

=cut

#-------------------------------------------------------------------
sub process {
	my $session = shift;
	return "" unless ($session->var->isAdminOn);
	my @param = @_;
        my $templateId = $param[0] || "PBtmpl0000000000000090";
        my %var;
	my (%cphash, %hash2, %hash, $r, @item, $query);
	tie %hash, "Tie::IxHash";
	tie %hash2, "Tie::IxHash";
	tie %cphash, "Tie::CPHash";
	my $i18n = WebGUI::International->new($session,'Macro_AdminBar');
	$var{'packages.canAdd'} = ($session->user->profileField("uiLevel") >= 7);
	$var{'packages.label'} = $i18n->get(376);
	$var{'contentTypes.label'} = $i18n->get(1083);
	$var{'clipboard.label'} = $i18n->get(1082);
	if ($session->asset) {
		foreach my $package (@{$session->asset->getPackageList}) {
			my $title = $package->getTitle;
			$title =~ s/'//g; # stops it from breaking the javascript menus
                	push(@{$var{'package_loop'}},{
				'url'=>$session->asset->getUrl("func=deployPackage;assetId=".$package->getId),
				'label'=>$title,
				'icon.small'=>$package->getIcon(1),
				'icon'=>$package->getIcon()
				});
        	}
		$var{contentTypes_loop} = $session->asset->getAssetAdderLinks;
		$var{container_loop} = $session->asset->getAssetAdderLinks(undef,"assetContainers");
		foreach my $asset (@{$session->asset->getAssetsInClipboard(1)}) {
			my $title = $asset->getTitle;
			$title =~ s/'//g; # stops it from breaking the javascript menus
			push(@{$var{clipboard_loop}}, {
				'label'=>$title,
				'url'=>$session->asset->getUrl("func=paste;assetId=".$asset->getId),
				'icon.small'=>$asset->getIcon(1),
				'icon'=>$asset->getIcon()
				});
		}
	} 
   #--admin functions
	$var{adminConsole_loop} = WebGUI::AdminConsole->getAdminFunction;
	return WebGUI::Asset::Template->new($session,$templateId)->process(\%var);
#		'http://validator.w3.org/check?uri=referer'=>$i18n->get(399),
}




1;

