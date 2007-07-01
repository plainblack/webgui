package WebGUI::Asset::Wobject::Dashboard;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2007 Plain Black Corporation.
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
use WebGUI::Utility;
use WebGUI::ProfileField;
use Time::HiRes;
use WebGUI::Asset::Wobject;

our @ISA = qw(WebGUI::Asset::Wobject);


#-------------------------------------------------------------------
sub canManage {
	my $self = shift;
	return 0 if $self->session->user->userId eq '1';
	return $self->session->user->isInGroup($self->get("adminsGroupId"));
}

#-------------------------------------------------------------------
sub canPersonalize {
	my $self = shift;
	return 0 if $self->session->user->userId eq '1';
	return $self->session->user->isInGroup($self->get("usersGroupId"));
}

#-------------------------------------------------------------------
sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift;
	my $i18n = WebGUI::International->new($session,"Asset_Dashboard");

	my %properties;
	tie %properties, 'Tie::IxHash';
	%properties = (
		templateId => {
			fieldType => "template",
			defaultValue => 'DashboardViewTmpl00001',
			namespace => "Dashboard",
			tab => 'display',
			label => $i18n->get('dashboard template field label'),
		        hoverHelp => $i18n->get('dashboard template description'),
		},

		adminsGroupId => {
			fieldType => "group",
			defaultValue => '4',
		        tab => 'security',
			label => $i18n->get('dashboard adminsGroupId field label'),
			hoverHelp=>$i18n->get('dashboard adminsGroupId description'),
		},

		usersGroupId => {
			fieldType => "group",
			defaultValue => '2',
			label => $i18n->get('dashboard usersGroupId field label'),
			hoverHelp => $i18n->get('dashboard usersGroupId description'),
		},

		isInitialized => {
			fieldType => "yesNo",
			defaultValue => 0,
			noFormPost => 1,
			autoGenerate => 0,
		},

		assetsToHide => {
			defaultValue => undef,
			fieldType => "checkList",
			autoGenerate => 0,
		},
	);

	push(@{$definition}, {
		assetName => $i18n->get('assetName'),
		icon => 'dashboard.gif',
		tableName => 'Dashboard',
		className => 'WebGUI::Asset::Wobject::Dashboard',
		properties => \%properties,
		autoGenerateForms => 1,
	});

	return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------
sub getContentPositions {
	my $self = shift;
	my $dummy = $self->initialize unless $self->get("isInitialized");
	my $u = WebGUI::User->new($self->session, $self->discernUserId);
	return $u->profileField($self->getId.'contentPositions');
}

#-------------------------------------------------------------------
sub discernUserId {
	my $self = shift;
	return ($self->canManage && $self->session->var->isAdminOn) ? '1' : $self->session->user->userId;
}

#-------------------------------------------------------------------
sub getEditForm {
	my $self = shift;
	my $tabform = $self->SUPER::getEditForm;
	my $i18n = WebGUI::International->new($self->session, "Asset_Dashboard");
	if ($self->session->form->process("func") ne "add") {
		my @assetsToHide = split("\n",$self->getValue("assetsToHide"));
		my $children = $self->getLineage(["children"],{"returnObjects"=>1, excludeClasses=>["WebGUI::Asset::Wobject::Layout"]});
		my %childIds;
		foreach my $child (@{$children}) {
			$childIds{$child->getId} = $child->getTitle.' ['.ref($child).']';	
		}
		$tabform->getTab("display")->checkList(
			-name=>"assetsToHide",
			-value=>\@assetsToHide,
			-options=>\%childIds,
			-label=>$i18n->get('assets to hide'),
			-hoverHelp=>$i18n->get('assets to hide description'),
			-vertical=>1,
			-uiLevel=>9
		);
	}
	return $tabform;
}

#-------------------------------------------------------------------
sub initialize {
	my $self = shift;
	my $userPrefField = WebGUI::ProfileField->create($self->session,$self->getId.'contentPositions',{
		label=>'\'Dashboard User Preference - Content Positions\'',
		visible=>0,
		protected=>1,
		editable=>0,
		required=>0,
		fieldType=>'text'
	});
	$self->update({isInitialized=>1});
}

#-------------------------------------------------------------------
sub isManaging {
	my $self = shift;
	return 1 if ($self->canManage && $self->session->var->isAdminOn());
	return 0;
}

#-------------------------------------------------------------------

sub prepareView {
	my $self = shift;
	$self->SUPER::prepareView;
	my $children = $self->getLineage( ["children"], { returnObjects=>1, excludeClasses=>["WebGUI::Asset::Wobject::Layout","WebGUI::Asset::Wobject::Dashboard"] });
	my @hidden = split("\n",$self->get("assetsToHide"));
	foreach my $child (@{$children}) {
		unless (isIn($child->getId, @hidden) || !($child->canView)) {
			$self->session->style->setRawHeadTags($child->getExtraHeadTags);
			$child->prepareView;
		}
	}
}


#-------------------------------------------------------------------
sub processPropertiesFromFormPost {
	my $self = shift;
	$self->SUPER::processPropertiesFromFormPost;
	if ($self->session->form->process("assetId") eq "new" && $self->session->form->process("class") eq 'WebGUI::Asset::Wobject::Dashboard') {
		$self->initialize;
		if (ref $self->getParent eq 'WebGUI::Asset::Wobject::Layout') {
			$self->getParent->update({assetsToHide=>$self->getParent->get("assetsToHide")."\n".$self->getId});
		}
		$self->update({styleTemplateId=>'PBtmplBlankStyle000001'});
	}
}

#-------------------------------------------------------------------
sub view {
	my $self = shift;
	my %vars = %{$self->get()};
	my $templateId = $self->get("templateId");
	my $children = $self->getLineage( ["children"], { returnObjects=>1, excludeClasses=>["WebGUI::Asset::Wobject::Layout","WebGUI::Asset::Wobject::Dashboard"] });
	# I'm sure there's a more efficient way to do this. We'll figure it out someday.
	my @positions = split(/\./,$self->getContentPositions);
	my @hidden = split("\n",$self->get("assetsToHide"));
	foreach my $child (@{$children}) {
		push(@hidden,$child->get('shortcutToAssetId')) if ref $child eq 'WebGUI::Asset::Shortcut';
		#the following loop will initially place just-dashletted assets.
		for (my $i = 0; $i < scalar(@positions); $i++) {
			next unless isIn($child->get('shortcutToAssetId'),@hidden);
			my $newChildId = $child->getId;
			my $oldChildId = $child->get('shortcutToAssetId');
			$positions[$i] =~ s/${oldChildId}/${newChildId}/g;
		}
	}
	my $i = 1;
	my $templateAsset = WebGUI::Asset->newByDynamicClass($self->session, $templateId) || WebGUI::Asset->getImportNode($self->session);
	my $template = $templateAsset->get("template");
	my $numPositions = 1;
	foreach my $j (2..15) {
		$numPositions = $j if $template =~ m/position${j}\_loop/;
	}

	my @found;
	my $newStuff;
	my $showPerformance = $self->session->errorHandler->canShowPerformanceIndicators();
	foreach my $position (@positions) {
		my @assets = split(",",$position);
		foreach my $asset (@assets) {
			foreach my $child (@{$children}) {
				if ($asset eq $child->getId) {
					unless (isIn($asset,@hidden) || !($child->canView)) {
						$self->session->style->setRawHeadTags($child->getExtraHeadTags);
						$child->{_properties}{title} = $child->getTitle;
						$child->{_properties}{title} = $child->getShortcut->getTitle if (ref $child eq 'WebGUI::Asset::Shortcut');
						if ($i == 1 || $i > $numPositions) {
							push(@{$vars{"position1_loop"}},{
								id=>$child->getId,
								content=>'', #so things in the New Content bar don't display.
								dashletTitle=>$child->{_properties}{title},
								shortcutUrl=>$child->getUrl,
								canPersonalize=>$self->canPersonalize,
								showReloadIcon=>$child->{_properties}{showReloadIcon},
								canEditUserPrefs=>(($self->session->user->userId ne '1') && (ref $child eq 'WebGUI::Asset::Shortcut') && (scalar($child->getPrefFieldsToShow) > 0))
							});
							$newStuff .= 'available_dashlets["'.$child->getId.'"]=\''.$child->getUrl.'\';';

						} else {
							$child->prepareView;
							push(@{$vars{"position".$i."_loop"}},{
								id=>$child->getId,
								content=>$child->view,
								dashletTitle=>$child->{_properties}{title},
								shortcutUrl=>$child->getUrl,
								canPersonalize=>$self->canPersonalize,
								showReloadIcon=>$child->{_properties}{showReloadIcon},
								canEditUserPrefs=>(($self->session->user->userId ne '1') && (ref $child eq 'WebGUI::Asset::Shortcut') && (scalar($child->getPrefFieldsToShow) > 0))
							});
							$newStuff .= 'available_dashlets["'.$child->getId.'"]=\''.$child->getUrl.'\';';
						}
					}
					push(@found, $child->getId);
				}
			}
		}
		$i++;
	}
	# deal with unplaced children
	foreach my $child (@{$children}) {
		unless (isIn($child->getId, @found)||isIn($child->getId,@hidden)) {
			if ($child->canView) {
				$child->{_properties}{title} = $child->getShortcut->get("title") if (ref $child eq 'WebGUI::Asset::Shortcut');
				push(@{$vars{"position1_loop"}},{
					id=>$child->getId,
					content=>'',
					dashletTitle=>$child->getTitle,
					shortcutUrl=>$child->getUrl,
					showReloadIcon=>$child->{_properties}{showReloadIcon},
					canPersonalize=>$self->canPersonalize,
					canEditUserPrefs=>(($self->session->user->userId ne '1') && (ref $child eq 'WebGUI::Asset::Shortcut') && (scalar($child->getPrefFieldsToShow) > 0))
				});
				$newStuff .= 'available_dashlets["'.$child->getId.'"]=\''.$child->getUrl.'\';';
			}
		}
	}
	$vars{showAdmin} = ($self->session->var->get("adminOn") && $self->canEdit);
	$vars{"dragger.init"} = '
		<script type="text/javascript">
			dragable_init("'.$self->getUrl.'");
		var available_dashlets= new Array();
		'.$newStuff.'
		</script>
	';
	return $self->processTemplate(\%vars, $templateId);
}

#-------------------------------------------------------------------
sub www_setContentPositions {
	my $self = shift;
	return 'Visitors cannot save settings' if($self->session->user->userId eq '1');
	return $self->session->privilege->insufficient() unless ($self->canPersonalize);
	return 'empty' unless $self->get("isInitialized");
	my $dummy = $self->initialize unless $self->get("isInitialized");
	my $u = WebGUI::User->new($self->session, $self->discernUserId);
	my $success = $u->profileField($self->getId.'contentPositions',$self->session->form->process("map")) eq $self->session->form->process("map");
	return "Map set: ".$self->session->form->process("map") if $success;
	return "Map failed to set.";
}

#-------------------------------------------------------------------

=head2 www_view (  )

Renders self->view based upon current style, subject to timeouts. Returns Privilege::noAccess() if canView is False.

=cut

sub www_view {
        my $self = shift;
        unless ($self->canView) {
                if ($self->get("state") eq "published") { # no privileges, make em log in
                        return $self->session->privilege->noAccess();
                } elsif ($self->session->var->get("adminOn") && $self->get("state") =~ /^trash/) { # show em trash
                        $self->session->http->setRedirect($self->getUrl("func=manageTrash"));
                        return "";
                } elsif ($self->session->var->get("adminOn") && $self->get("state") =~ /^clipboard/) { # show em clipboard
                        $self->session->http->setRedirect($self->getUrl("func=manageClipboard"));
                        return "";
                } else { # tell em it doesn't exist anymore
                        $self->session->http->setStatus("410");
                        return WebGUI::Asset->getNotFound($self->session)->www_view;
                }
        }
        $self->logView();
        $self->prepareView;
        my $style = $self->processStyle($self->view);
}



1;
