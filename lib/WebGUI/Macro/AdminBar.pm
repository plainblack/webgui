package WebGUI::Macro::AdminBar;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2004 Plain Black Corporation.
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
        my $templateId = $param[0] || 1;
        my %var;
	my (%cphash, %hash2, %hash, $r, @item, $query);
	tie %hash, "Tie::IxHash";
	tie %hash2, "Tie::IxHash";
	tie %cphash, "Tie::CPHash";
  #--packages adder
	$var{'packages.canAdd'} = ($session{user}{uiLevel} >= 7);
	$var{'packages.label'} = WebGUI::International::get(376);
	my @packages;
	my $i;
#	my $sth = WebGUI::SQL->read("select pageId,title from page where parentId='5'");
 #       while (my %data = $sth->hash) {
#		$data{title} =~ s/'//g;
#		push(@packages, {
 #       		'package.url'=>WebGUI::URL::page('op=deployPackage&pid='.$data{pageId}),
  #             		'package.label'=>$data{title},
#			'package.count'=>$i
#			});
#		$i++;
 #       }
  #      $sth->finish;
#	$var{package_loop} = \@packages;
  #--contenttypes adder
	$var{'contentTypes.label'} = WebGUI::International::get(1083);
	$var{'addcontent.label'} = WebGUI::International::get(1);
	foreach my $link (@{$session{asset}->getAssetAdderLinks}) {
                push(@{$var{'contenttypes_loop'}},{'contenttype.url'=>$link->{url},'contenttype.label'=>$link->{label}});
        }
  #--clipboard paster
	$var{'clipboard.label'} = WebGUI::International::get(1082);
	if (exists $session{asset}) {
		foreach my $item (@{$session{asset}->getAssetsInClipboard(1)}) {
			my $title = $item->{title};
			$title =~ s/'//g; # stops it from breaking the javascript menus
			push(@{$var{clipboard_loop}}, {
				'clipboard.label'=>$title,
				'clipboard.url'=>WebGUI::URL::page("func=paste&assetId=".$item->{assetId})
				});
		}
	}
   #--admin functions
	%hash = (
		'http://validator.w3.org/check?uri=referer'=>WebGUI::International::get(399),
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
		WebGUI::URL::page('op=switchOffAdmin')=>WebGUI::International::get(12),
		%hash
	);
	$var{'admin.label'} = WebGUI::International::get(82);
	my @admin;
	$i = 0;
	foreach my $key (keys %hash) {	
		push(@admin,{
			'admin.url'=>$key,
			'admin.label'=>$hash{$key},
			'admin.count'=>$i
			});
		$i++;
	}
	$var{'admin_loop'} = \@admin;
	return WebGUI::Template::process($templateId,"Macro/AdminBar",\%var);
}




1;

