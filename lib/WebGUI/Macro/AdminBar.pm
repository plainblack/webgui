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
use WebGUI::AdminConsole;
use WebGUI::Asset;
use WebGUI::Asset::Template;
use WebGUI::International;
use WebGUI::Utility;
use WebGUI::VersionTag;

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
	my $i18n = WebGUI::International->new($session,'Macro_AdminBar');
	my @adminbar = ();
   	my $ac = WebGUI::AdminConsole->new($session);
	my @adminConsole = ();
	foreach my $item (@{$ac->getAdminFunction}) {
		push(@adminConsole, {
			title=>$item->{title},
			icon=>$item->{'icon.small'},
			url=>$item->{url}
			});
	}
	push(@adminbar, {
		label => $i18n->get("admin console","AdminConsole"),
		name => "adminConsole",
		items => \@adminConsole
		});
	if ($session->asset) {
		my @clipboard = ();
		foreach my $asset (@{$session->asset->getAssetsInClipboard(1)}) {
			my $title = $asset->getTitle;
			$title =~ s/'//g; # stops it from breaking the javascript menus
			push(@clipboard, {
				'title'=>$title,
				'url'=>$session->asset->getUrl("func=paste;assetId=".$asset->getId),
				icon=>$asset->getIcon(1),
				});
		}
		if (scalar(@clipboard)) {
			push(@adminbar, {
				label => $i18n->get(1082),
				name => "clipboard",
				items => \@clipboard
				});
		}
		my @packages = ();
		foreach my $package (@{$session->asset->getPackageList}) {
			my $title = $package->getTitle;
			$title =~ s/'//g; # stops it from breaking the javascript menus
                	push(@{$var{'package_loop'}},{
				'url'=>$session->asset->getUrl("func=deployPackage;assetId=".$package->getId),
				'title'=>$title,
				icon=>$package->getIcon(1),
				});
        	}
		if ($session->user->profileField("uiLevel") >= 7 && scalar(@packages)) {
			push(@adminbar, {
				label => $i18n->get(376),
				name => "packages",
				items => \@packages
				});
		}
	}
	my $working = WebGUI::VersionTag->getWorking($session, 1);
	my $workingId = "";
	my @tags = ();
	if ($working) {
		$workingId = $working->getId;
		push(@tags, {
			url=>$session->url->page("op=commitVersionTag;backToSite=1;tagId=".$workingId),
			title=>$i18n->get("commit my changes"),
			icon=>$session->config->get("extrasURL").'/adminConsole/small/versionTags.gif'
			});
	}
	my $rs = $session->db->read("select tagId, name from assetVersionTag where isCommitted=0 and isLocked=0 order by name");
	while (my ($id, $name) = $rs->array) {
		push(@tags, {
			url=>$session->url->page("op=setWorkingVersionTag;backToSite=1;tagId=".$id),
			title=>($id eq $workingId) ?  '<span style="color: #000080;">* '.$name.'</span>' : $name,
			icon=>$session->config->get("extrasURL").'/spacer.gif'
			});
	}
	if (scalar(@tags)) {
		push(@adminbar, {
			label => $i18n->get("version tags"),
			name => "versions",
			items => \@tags
			});
	}
	if ($session->asset) {
		my @assets = ();
		foreach my $asset (@{$session->asset->getAssetAdderLinks(undef,"assetContainers")}) {
			push(@assets, {
				title=>$asset->{label},
				icon=>$asset->{'icon.small'},
				url=>$asset->{url}
				});
		}
		push(@assets, {icon=>$session->config->get("extrasURL").'/spacer.gif',label=>'<hr />'});
		foreach my $asset (@{$session->asset->getAssetAdderLinks}) {
			push(@assets, {
				title=>$asset->{label},
				icon=>$asset->{'icon.small'},
				url=>$asset->{url}
				});
		}
		push(@adminbar, {
			label => $i18n->get(1083),
			name => "newContent",
			items => \@assets 
			});
	}
	return WebGUI::Asset::Template->new($session,$templateId)->process({adminbar_loop=>\@adminbar});
#		'http://validator.w3.org/check?uri=referer'=>$i18n->get(399),
}




1;

