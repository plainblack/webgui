package WebGUI::Macro::AdminBar;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
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
use WebGUI::Macro;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::Utility;

#-------------------------------------------------------------------
sub process {
	return "" unless ($session{var}{adminOn});
	my @param = WebGUI::Macro::getParams($_[0]);
        my $templateId = $param[0] || "PBtmpl0000000000000090";
        my %var;
	my (%cphash, %hash2, %hash, $r, @item, $query);
	tie %hash, "Tie::IxHash";
	tie %hash2, "Tie::IxHash";
	tie %cphash, "Tie::CPHash";
	$var{'packages.canAdd'} = ($session{user}{uiLevel} >= 7);
	$var{'packages.label'} = WebGUI::International::get(376,'Macro_AdminBar');
	$var{'contentTypes.label'} = WebGUI::International::get(1083,'Macro_AdminBar');
	$var{'clipboard.label'} = WebGUI::International::get(1082,'Macro_AdminBar');
	if (exists $session{asset}) {
		foreach my $package (@{$session{asset}->getPackageList}) {
			my $title = $package->{title};
			$title =~ s/'//g; # stops it from breaking the javascript menus
			my $asset = WebGUI::Asset->newByDynamicClass($package->{assetId},$package->{className});
                	push(@{$var{'package_loop'}},{
				'url'=>$session{asset}->getUrl("func=deployPackage&assetId=".$package->{assetId}),
				'label'=>$title,
				'icon.small'=>$asset->getIcon(1),
				'icon'=>$asset->getIcon()
				});
        	}
		$var{contentTypes_loop} = $session{asset}->getAssetAdderLinks;
		$var{container_loop} = $session{asset}->getAssetAdderLinks(undef,"assetContainers");
		foreach my $item (@{$session{asset}->getAssetsInClipboard(1)}) {
			my $title = $item->{title};
			$title =~ s/'//g; # stops it from breaking the javascript menus
			my $asset = WebGUI::Asset->newByDynamicClass($item->{assetId},$item->{className});
			push(@{$var{clipboard_loop}}, {
				'label'=>$title,
				'url'=>$session{asset}->getUrl("func=paste&assetId=".$item->{assetId}),
				'icon.small'=>$asset->getIcon(1),
				'icon'=>$asset->getIcon()
				});
		}
	} 
   #--admin functions
	$var{adminConsole_loop} = WebGUI::AdminConsole->getAdminFunction;
	return WebGUI::Asset::Template->new($templateId)->process(\%var);
	%hash = (
		'http://validator.w3.org/check?uri=referer'=>WebGUI::International::get(399,'Macro_AdminBar'),
		);
	my $acParams = WebGUI::AdminConsole->getAdminConsoleParams;
	$hash{$acParams->{url}} = $acParams->{title} if ($acParams->{canUse});
#	$acParams = WebGUI::AdminConsole->getAdminFunction("users");
#	$hash{$acParams->{url}} = $acParams->{title} if ($acParams->{canUse});
#	$acParams = WebGUI::AdminConsole->getAdminFunction("groups");
#	$hash{$acParams->{url}} = $acParams->{title} if ($acParams->{canUse});
	$acParams = WebGUI::AdminConsole->getAdminFunction("assets");
	$hash{$acParams->{url}} = $acParams->{title} if ($acParams->{canUse});

	%hash = sortHash(%hash);
        %hash = ( 
		WebGUI::URL::page('op=switchOffAdmin')=>WebGUI::International::get(12,'Macro_AdminBar'),
		%hash
	);
	$var{'admin.label'} = WebGUI::International::get(82,'Macro_AdminBar');
	my @admin;
	my $i = 0;
	foreach my $key (keys %hash) {	
		push(@admin,{
			'admin.url'=>$key,
			'admin.label'=>$hash{$key},
			'admin.count'=>$i
			});
		$i++;
	}
	$var{'admin_loop'} = \@admin;
	return WebGUI::Asset::Template->new($templateId)->process(\%var);
}




1;

