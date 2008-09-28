package WebGUI::Macro::AdminBar;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2008 Plain Black Corporation.
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
use WebGUI::International;
use WebGUI::Macro;
use WebGUI::Utility;
use WebGUI::VersionTag;

=head1 NAME

Package WebGUI::Macro::AdminBar

=head1 DESCRIPTION

Macro for displaying administrative functions to a user with Admin turned on.

=head2 process ( )

process takes one optional parameters for customizing the layout of the Admin bar.

=cut


sub process {
	my $session = shift;
	return undef unless $session->var->isAdminOn;
	my $i18n = WebGUI::International->new($session,'Macro_AdminBar');
	my ($url, $style, $asset, $user, $config) = $session->quick(qw(url style asset user config));
	$style->setScript($url->extras('yui/build/utilities/utilities.js'), {type=>'text/javascript'});
	$style->setScript($url->extras('accordion/accordion.js'), {type=>'text/javascript'});
#	$style->setLink($url->extras('accordion/accordion.css'), {type=>'text/css', rel=>'stylesheet'});
	$style->setLink($url->extras('slidePanel/slidePanel.css'), {type=>'text/css', rel=>'stylesheet'});
#	$style->setRawHeadTags(<script type="text/javascript">
#	/*	YAHOO.util.Event.addListener(window, 'load', function () {var myAccordion = new Accordion("myAccordion");} 	); */
#	</script>);

	my $out = q{<dl class="accordion-menu">};

	# admin console
	my $ac = WebGUI::AdminConsole->new($session);
    $out .= q{<dt class="a-m-t">}.$i18n->get("admin console","AdminConsole").q{</dt><dd class="a-m-d"><div class="bd">};
	foreach my $item (@{$ac->getAdminFunction}) {
		next unless $item->{canUse};
		$out .= q{<a class="link" href="}.$item->{url}.q{">}
			.q{<img src="}.$item->{'icon.small'}.q{" style="border: 0px; vertical-align: middle;" alt="icon" /> }
			.$item->{title}.q{</a>};
	}
	$out .= qq{</div></dd>\n};

	# version tags
	my $versionTags = WebGUI::VersionTag->getOpenTags($session);
	if (scalar(@$versionTags)) {
		$out .= q{<dt class="a-m-t">}.$i18n->get("version tags","VersionTag").q{</dt><dd class="a-m-d"><div class="bd">};
		my $working = WebGUI::VersionTag->getWorking($session, 1);
		my $workingId = "";
		if ($working) {
			$workingId = $working->getId;
			my $commitUrl = "";
			if ($session->setting->get("skipCommitComments")) {
				$commitUrl = $url->page("op=commitVersionTagConfirm;tagId=".$workingId);
			}
			else {
				$commitUrl = $url->page("op=commitVersionTag;tagId=".$workingId);
			}
			$out .= q{<a class="link" href="}.$commitUrl.q{">}
				.q{<img src="}.$url->extras('adminConsole/small/versionTags.gif').q{" style="border: 0px; vertical-align: middle;" alt="icon" /> }
				.$i18n->get("commit my changes").q{</a>};
		}
		foreach my $tag (@{$versionTags}) {
			next unless $user->isInGroup($tag->get("groupToUse"));
			my $switchUrl = $url->page("op=" . ($tag->getId eq $workingId ? "editVersionTag" : "setWorkingVersionTag") . ";backToSite=1;tagId=".$tag->getId);
			my $title = ($tag->getId eq $workingId) ?  '<span style="color: #000080;">* '.$tag->get("name").'</span>' : $tag->get("name");
			$out .= q{<a class="link" href="}.$switchUrl.q{">}.$title.q{</a>};
		}
		$out .= qq{</div></dd>\n};
	}

	
	# stuff to do if we're on a page with an asset
	if ($asset) {
		
		# clipboard
		my $clipboardItems = $session->asset->getAssetsInClipboard(1);
		if (scalar (@$clipboardItems)) {
			$out .= q{<dt class="a-m-t">}.$i18n->get("1082").q{</dt><dd class="a-m-d"><div class="bd">};
			foreach my $item (@{$clipboardItems}) {
				my $title = $asset->getTitle;
				$out .= q{<a class="link" href="}.$asset->getUrl("func=paste;assetId=".$item->getId).q{">}
					.q{<img src="}.$item->getIcon(1).q{" style="border: 0px; vertical-align: middle;" alt="icon" /> }
					.$item->getTitle.q{</a>};
			}
			$out .= qq{</div></dd>\n};
		}

		### new content menu

		# determine new content categories
		my %rawCategories = %{$config->get('assetCategories')};
		my %categories;
		my %categoryTitles;
		my $userUiLevel = $user->profileField('uiLevel');
		foreach my $category (keys %rawCategories) {
			next if $rawCategories{$category}{uiLevel} > $userUiLevel;
			next if (exists $rawCategories{$category}{group} && !$user->isInGroup($rawCategories{$category}{group}));
			my $title = $rawCategories{$category}{title};
			WebGUI::Macro::process($session, \$title);
			$categories{$category}{title} = $title;
			$categoryTitles{$title} = $category;
		}

		# assets
		my %assetList = %{$config->get('assets')};
		foreach my $assetClass (keys %assetList) {
			my $dummy = WebGUI::Asset->newByPropertyHashRef($session,{dummy=>1, className=>$assetClass});
			next if $dummy->getUiLevel($assetList{$assetClass}{uiLevel}) > $userUiLevel;
			next unless ($dummy->canAdd($session));
			next unless exists $categories{$assetList{$assetClass}{category}};
			$categories{$assetList{$assetClass}{category}}{items}{$dummy->getTitle} = {
				icon	=> $dummy->getIcon(1),
				url		=> $asset->getUrl("func=add;class=".$dummy->get('className')),
				};
		}

		# packages
		foreach my $package (@{$session->asset->getPackageList}) {
			next unless ($package->canView && $package->canAdd($session) && $package->getUiLevel <= $userUiLevel);
            $categories{packages}{items}{$package->getTitle} = {
				url		=> $asset->getUrl("func=deployPackage;assetId=".$package->getId),
				icon	=> $package->getIcon(1),
				};
        }
		if (scalar keys %{$categories{packages}{items}}) {
			$categories{packages}{title} = $i18n->get('packages');
			$categoryTitles{$i18n->get('packages')} = "packages";
		}
		
		# prototypes
		my $sth = $session->db->read("select asset.className,asset.assetId,assetData.revisionDate from asset
			left join assetData on asset.assetId=assetData.assetId
			where assetData.isPrototype=1 and asset.state='published' and assetData.revisionDate=(SELECT max(revisionDate) from assetData where assetData.assetId=asset.assetId)
			group by assetData.assetId");
		while (my ($class, $id, $date) = $sth->array) {
			my $prototype = WebGUI::Asset->new($session,$id,$class,$date);
			next unless ($prototype->canView && $prototype->canAdd($session) && $prototype->getUiLevel <= $userUiLevel);
            $categories{prototypes}{items}{$prototype->getTitle} = {
				url		=> $asset->getUrl("func=add;class=".$class.";prototype=".$prototype->getId),
				icon	=> $prototype->getIcon(1),
				};
		}
		if (scalar keys %{$categories{prototypes}{items}}) {
			$categories{prototypes}{title} = $i18n->get('prototypes');
			$categoryTitles{$i18n->get('prototypes')} = "prototypes";
		}
		
		# render new content menu
	    $out .= q{<dt id="newContentMenu" class="a-m-t">}.$i18n->get("1083").q{</dt><dd class="a-m-d"><div class="bd">};
		foreach my $categoryTitle (sort keys %categoryTitles) {
			$out .= '<div class="ncmct">'.$categoryTitle.'</div>';
			my $items = $categories{$categoryTitles{$categoryTitle}}{items};
			next unless (ref $items eq 'HASH'); # in case the category is empty
			foreach my $title (sort keys %{$items}) {
				$out .= q{<a class="link" href="}.$items->{$title}{url}.q{">}
					.q{<img src="}.$items->{$title}{icon}.q{" style="border: 0px; vertical-align: middle;" alt="icon" /> }
					.$title.q{</a>};
			}
			$out .= '<br />';
		}
		$out .= qq{</div></dd>\n};
	}
	
	$out .= q{</dl>
	<script type="text/javascript>
	YAHOO.util.Event.on(window, "load", function () { 
		document.body.style.marginLeft = "160px"; 
		AccordionMenu.openDtById("newContentMenu");
	});
	</script>};
	return $out;
}

#-------------------------------------------------------------------

=head2 getAssetAdderLinks ( [addToUrl, type] )

Returns an arrayref that contains a label (name of the class of Asset) and url (url link to function to add the class).

=head3 addToUrl

Any text to append to the getAssetAdderLinks URL. Usually name/variable pairs to pass in the url. If addToURL is specified, the character ";" and the text in addToUrl is appended to the returned url.

=head3 type

A string indicating which type of adders to return. Defaults to "assets". Choose from "assets", "assetContainers", or "utilityAssets".

=cut

sub getAssetAdderLinks {
	my $self = shift;
	my $addToUrl = shift;
	my $type = shift || "assets";
	my %links;
	my $classesInType = $self->session->config->get($type);
	if (ref $classesInType ne "ARRAY") {
		$classesInType = [];
	}
	foreach my $class (@{$classesInType}) {
		next unless $class;
		my %properties = (
			className=>$class,
			dummy=>1
		);
		my $newAsset = WebGUI::Asset->newByPropertyHashRef($self->session,\%properties);
		next unless $newAsset;
		my $uiLevel = eval{$newAsset->getUiLevel()};
		if ($@) {
			$self->session->errorHandler->error("Couldn't get UI level of ".$class.". Root cause: ".$@);
			next;
		}
		next if ($uiLevel > $self->session->user->profileField("uiLevel"));# && !$self->session->user->isAdmin);
		my $canAdd = eval{$class->canAdd($self->session)};
		if ($@) {
			$self->session->errorHandler->error("Couldn't determine if user can add ".$class." because ".$@);
			next;
		} 
		next unless ($canAdd);
		my $label = eval{$newAsset->getName()};
		if ($@) {
			$self->session->errorHandler->error("Couldn't get the name of ".$class."because ".$@);
			next;
		}
		my $url = $self->getUrl("func=add;class=".$class);
		$url = $self->session->url->append($url,$addToUrl) if ($addToUrl);
		$links{$label}{url} = $url;
		$links{$label}{icon} = $newAsset->getIcon;
		$links{$label}{'icon.small'} = $newAsset->getIcon(1);
	}
	my $constraint;
	if ($type eq "assetContainers") {
		$constraint = $self->session->db->quoteAndJoin($self->session->config->get("assetContainers"));
	} elsif ($type eq "utilityAssets") {
		$constraint = $self->session->db->quoteAndJoin($self->session->config->get("utilityAssets"));
	} else {
		$constraint = $self->session->db->quoteAndJoin($self->session->config->get("assets"));
	}
	if ($constraint) {
		my $sth = $self->session->db->read("select asset.className,asset.assetId,assetData.revisionDate from asset left join assetData on asset.assetId=assetData.assetId where assetData.isPrototype=1 and asset.state='published' and asset.className in ($constraint) and assetData.revisionDate=(SELECT max(revisionDate) from assetData where assetData.assetId=asset.assetId) group by assetData.assetId");
		while (my ($class,$id,$date) = $sth->array) {
			my $asset = WebGUI::Asset->new($self->session,$id,$class,$date);
			next unless ($asset->canView && $asset->canAdd($self->session) && $asset->getUiLevel <= $self->session->user->profileField("uiLevel"));
			my $url = $self->getUrl("func=add;class=".$class.";prototype=".$id);
			$url = $self->session->url->append($url,$addToUrl) if ($addToUrl);
			$links{$asset->getTitle}{url} = $url;
			$links{$asset->getTitle}{icon} = $asset->getIcon;
			$links{$asset->getTitle}{'icon.small'} = $asset->getIcon(1);
			$links{$asset->getTitle}{'isPrototype'} = 1;
			$links{$asset->getTitle}{'asset'} = $asset;
		}
		$sth->finish;
	}
	my @sortedLinks;
	foreach my $label (sort keys %links) {
		push(@sortedLinks,{
			label=>$label,
			url=>$links{$label}{url},
			icon=>$links{$label}{icon},
			'icon.small'=>$links{$label}{'icon.small'},
			isPrototype=>$links{$label}{isPrototype},
			asset=>$links{$label}{asset}
			});	
	}
	return \@sortedLinks;
}




#-------------------------------------------------------------------
sub processOld {
	my $session = shift;
	return "" unless ($session->var->isAdminOn);
    $session->style->setScript($session->url->extras('yui/build/yahoo-dom-event/yahoo-dom-event.js'), {type=>"text/javascript"});
    $session->style->setScript($session->url->extras('yui/build/animation/animation-min.js'), {type=>"text/javascript"});
	my @param = @_;
        my $templateId = $param[0] || "PBtmpl0000000000000090";
	my $i18n = WebGUI::International->new($session,'Macro_AdminBar');
	my @adminbar = ();
   	my $ac = WebGUI::AdminConsole->new($session);
	my @adminConsole = ();
	foreach my $item (@{$ac->getAdminFunction}) {
		push(@adminConsole, {
			title=>$item->{title},
			icon=>$item->{'icon.small'},
			url=>$item->{url}
			}) if ($item->{canUse});
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
                	push(@packages,{
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
        my $commitUrl = "";
        if ($session->setting->get("skipCommitComments")) {
            $session->url->page("op=commitVersionTagConfirm;tagId=".$workingId);
        }
        else {
            $session->url->page("op=commitVersionTag;tagId=".$workingId);
        }
		push(@tags, {
			url=>$session->url->page("op=commitVersionTag;tagId=".$workingId),
			title=>$i18n->get("commit my changes"),
			icon=>$session->url->extras('adminConsole/small/versionTags.gif')
			});
	}
	foreach my $tag (@{WebGUI::VersionTag->getOpenTags($session)}) {
		next unless $session->user->isInGroup($tag->get("groupToUse"));
		push(@tags, {
			url=>$session->url->page("op=" . ($tag->getId eq $workingId ? "editVersionTag" : "setWorkingVersionTag") . ";backToSite=1;tagId=".$tag->getId),
			title=>($tag->getId eq $workingId) ?  '<span style="color: #000080;">* '.$tag->get("name").'</span>' : $tag->get("name"),
			icon=>$session->url->extras('spacer.gif')
			});
	}
	if (scalar(@tags)) {
		push(@adminbar, {
			label => $i18n->get("version tags","VersionTag"),
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
		push(@assets, {icon=>$session->url->extras('spacer.gif'),label=>'<hr />'});
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
}




1;

