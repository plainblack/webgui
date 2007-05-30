package WebGUI::Asset::Wobject::Layout;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2006 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use WebGUI::AdSpace;
use WebGUI::Asset::Wobject;
use WebGUI::Utility;
use WebGUI::Cache;

our @ISA = qw(WebGUI::Asset::Wobject);

=head1 NAME

Package WebGUI::Asset::Wobject::Layout

=head1 DESCRIPTION

Provides a mechanism to layout multiple assets on a single page.

=head1 SYNOPSIS

use WebGUI::Asset::Wobject::Layout;


=head1 METHODS

These methods are available from this class:

=cut



#-------------------------------------------------------------------

=head2 definition ( definition )

Defines the properties of this asset.

=head3 definition

A hash reference passed in from a subclass definition.

=cut

sub definition {
        my $class = shift;
	my $session = shift;
        my $definition = shift;
	my $i18n = WebGUI::International->new($session,"Asset_Layout");
        push(@{$definition}, {
		assetName=>$i18n->get("assetName"),
		icon=>'layout.gif',
                tableName=>'Layout',
                className=>'WebGUI::Asset::Wobject::Layout',
                properties=>{
			templateId =>{
				fieldType=>"template",
				defaultValue=>'PBtmpl0000000000000054'
				},
			contentPositions => {
				noFormPost=>1,
				defaultValue=>undef,
				fieldType=>"hidden"
				},
			assetsToHide => {
				defaultValue=>undef,
				fieldType=>"checkList"
				}
                        }
                });
        return $class->SUPER::definition($session, $definition);
}


#-------------------------------------------------------------------

=head2 getEditForm ( )

Returns the TabForm object that will be used in generating the edit page for this asset.

=cut

sub getEditForm {
	my $self = shift;
	my $tabform = $self->SUPER::getEditForm();
	my $i18n = WebGUI::International->new($self->session,"Asset_Layout");

	my ($templateId);
	if (($self->get("assetId") eq "new") && ($self->getParent->get('className') eq 'WebGUI::Asset::Wobject::Layout')) {
		$templateId = $self->getParent->getValue('templateId');
	} else {
		$templateId = $self->getValue('templateId');
	}
   	$tabform->getTab("display")->template(
      		-value=>$templateId,
      		-label=>$i18n->get('layout template title'),
      		-hoverHelp=>$i18n->get('template description'),
      		-namespace=>"Layout"
   		);
	if ($self->get("assetId") eq "new") {
               	$tabform->getTab("properties")->whatNext(
                       	-options=>{
                               	view=>$i18n->get(823),
                      	 	viewParent=>$i18n->get(847)
                              	},
			-value=>"view"
			);
	} else {
		my @assetsToHide = split("\n",$self->getValue("assetsToHide"));
		my $children = $self->getLineage(["children"],{"returnObjects"=>1, excludeClasses=>["WebGUI::Asset::Wobject::Layout"]});
		my %childIds;
		foreach my $child (@{$children}) {
			$childIds{$child->getId} = $child->getTitle;	
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

sub prepareView {
	my $self = shift;
	$self->SUPER::prepareView;
	my $children = $self->getLineage( ["children"], { returnObjects=>1, excludeClasses=>["WebGUI::Asset::Wobject::Layout"] });
	my %vars;
	# I'm sure there's a more efficient way to do this. We'll figure it out someday.
	my @positions = split(/\./,$self->get("contentPositions"));
	my @hidden = split("\n",$self->get("assetsToHide"));
	my @placeHolder1 = ();
	my @placeHolderN = ();
	my $i = 1;
	my $template = WebGUI::Asset->new($self->session,$self->get("templateId"),"WebGUI::Asset::Template");
	my $templateContent = $template->get("template");
	$self->{_viewTemplate} = $template;
	my $numPositions = 1;
	foreach my $j (2..15) {
		$numPositions = $j if $templateContent =~ m/position${j}\_loop/;
	}
	my @found;
	foreach my $position (@positions) {
		my @assets = split(",",$position);
		foreach my $asset (@assets) {
			foreach my $child (@{$children}) {
				if ($asset eq $child->getId) {
					unless (isIn($asset,@hidden) || !($child->canView)) {
						$child->prepareView;
						if ($i > $numPositions || $i==1) {
							push(@placeHolder1, $child);
							push(@{$vars{"position1_loop"}},{
								id=>$child->getId,
								content=>"~~~"
							});
						} else {
							push(@placeHolderN, $child);
							push(@{$vars{"position".$i."_loop"}},{
								id=>$child->getId,
								content=>"~~~"
							});
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
				$self->session->style->setRawHeadTags($child->getExtraHeadTags);
				$child->prepareView;
				push(@placeHolder1, $child);
				push(@{$vars{"position1_loop"}},{
					id=>$child->getId,
					content=>"~~~"
					});
			}
		}
	}
	@{$self->{_viewPlaceholders}} = (@placeHolder1, @placeHolderN);
	$vars{showAdmin} = ($self->session->var->isAdminOn && $self->canEdit);
	$self->{_viewVars} = \%vars;
	if ($vars{showAdmin}) {
		# under normal circumstances we don't put HTML stuff in our code, but this will make it much easier
		# for end users to work with our templates
		$self->session->style->setScript($self->session->url->extras("draggable.js"),{ type=>"text/javascript" });
		$self->session->style->setLink($self->session->url->extras("draggable.css"),{ type=>"text/css", rel=>"stylesheet", media=>"all" });
		$self->session->style->setRawHeadTags('
			<style type="text/css">
			.dragging, .empty {
				  background-image: url("'.$self->session->url->extras('opaque.gif').'");
			}
			</style>
			');
	}
}

#-------------------------------------------------------------------
sub view {
	my $self = shift;
	if ($self->{_viewVars}{showAdmin} && $self->canEditIfLocked) {
		# under normal circumstances we don't put HTML stuff in our code, but this will make it much easier
		# for end users to work with our templates
		$self->{_viewVars}{"dragger.icon"} = '<div id="dragTrigger" class="dragTrigger">'.$self->session->icon->drag('class="dragTrigger"').'</div>';
		$self->{_viewVars}{"dragger.init"} = '
			<iframe id="dragSubmitter" style="display: none;" src="'.$self->session->url->extras('spacer.gif').'"></iframe>
			<script type="text/javascript">
				dragable_init("'.$self->getUrl("func=setContentPositions;map=").'");
			</script>
			';
	}
	my $showPerformance = $self->session->errorHandler->canShowPerformanceIndicators();
	my @parts = split("~~~",$self->processTemplate($self->{_viewVars},undef,$self->{_viewTemplate}));
	my $output = "";
	foreach my $part (@parts) {
		if ($self->{_viewPrintOverride}) {
			$self->session->output->print($part);
		} else {
			$output .= $part;
		}
		my $asset = shift @{$self->{_viewPlaceholders}};
		if (defined $asset) {
			my $t = [Time::HiRes::gettimeofday()] if ($showPerformance);
			my $assetOutput = $asset->view;
			$assetOutput .= "Asset:".Time::HiRes::tv_interval($t) if ($showPerformance);
			if ($self->{_viewPrintOverride}) {
				$self->session->output->print($assetOutput);
			} else {
				$output .= $assetOutput;
			}
		}
	}
	return $output;
}

#-------------------------------------------------------------------
sub www_setContentPositions {
	my $self = shift;
	return $self->session->privilege->insufficient() unless ($self->canEdit);
	$self->addRevision({
		contentPositions=>$self->session->form->process("map")
		});
	if ($self->session->setting->get("autoRequestCommit")) {
            WebGUI::VersionTag->getWorking($self->session)->requestCommit;
    }
	return "Map set: ".$self->session->form->process("map");
}

#-------------------------------------------------------------------
sub getContentLastModified {
        # Buggo: this is a little too conservative.  Children that are hidden maybe shouldn't count.  Hm.
	my $self = shift;
	my $mtime = $self->get("revisionDate");
	foreach my $child (@{$self->getLineage(["children"],{returnObjects=>1, excludeClasses=>['WebGUI::Asset::Wobject::Layout']})}) {
		my $child_mtime = $child->getContentLastModified;
		$mtime = $child_mtime if ($child_mtime > $mtime);
	}
	return $mtime;
}

#-------------------------------------------------------------------
sub www_view {
	my $self = shift;
	# slashdot / burst protection hack
	if ($self->session->var->get("userId") eq "1" && $self->session->form->param() == 0) { 
		my $check = $self->checkView;
		return $check if (defined $check);
		my $cache = WebGUI::Cache->new($self->session, "view_".$self->getId);
		my $out = $cache->get if defined $cache;
		unless ($out) {
			$self->prepareView;
			$self->session->stow->set("cacheFixOverride", 1);
			$out = $self->processStyle($self->view);
			$cache->set($out, 60);
			$self->session->stow->delete("cacheFixOverride");
		}
		# keep those ads rotating
		while ($out =~ /(\[AD\:(\w+)\])/gs) {
			my $code = $1;
			my $adSpace = WebGUI::AdSpace->newByName($self->session, $2);
			my $ad = $adSpace->displayImpression if (defined $adSpace);
			$out =~ s/\Q$code/$ad/ges;
		}
		$self->session->http->setLastModified($self->getContentLastModified);
		$self->session->http->sendHeader;	
		$self->session->output->print($out, 1);
		return "chunked";	
	}
	$self->{_viewPrintOverride} = 1; # we do this to make it output each asset as it goes, rather than waiting until the end
	return $self->SUPER::www_view;
}

1;

