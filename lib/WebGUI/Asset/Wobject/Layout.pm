package WebGUI::Asset::Wobject::Layout;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2005 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use WebGUI::Asset::Wobject;
use WebGUI::ErrorHandler;
use WebGUI::Icon;
use WebGUI::Session;
use WebGUI::Utility;

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
        my $definition = shift;
        push(@{$definition}, {
		assetName=>WebGUI::International::get("assetName","Asset_Layout"),
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
        return $class->SUPER::definition($definition);
}


#-------------------------------------------------------------------

=head2 getEditForm ()

Returns the TabForm object that will be used in generating the edit page for this asset.

=cut

sub getEditForm {
	my $self = shift;
	my $tabform = $self->SUPER::getEditForm();
   	$tabform->getTab("display")->template(
      		-value=>$self->getValue('templateId'),
      		-label=>WebGUI::International::get('layout template title', 'Asset_Layout'),
      		-hoverHelp=>WebGUI::International::get('template description', 'Asset_Layout'),
      		-namespace=>"Layout"
   		);
	if ($self->get("assetId") eq "new") {
               	$tabform->getTab("properties")->whatNext(
                       	-options=>{
                               	view=>WebGUI::International::get(823, 'Asset_Layout'),
                      	 	viewParent=>WebGUI::International::get(847, 'Asset_Layout')
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
			-label=>WebGUI::International::get('assets to hide', 'Asset_Layout'),
			-hoverHelp=>WebGUI::International::get('assets to hide description', 'Asset_Layout'),
			-vertical=>1,
			-uiLevel=>9
			);
	}
	return $tabform;
}






#-------------------------------------------------------------------
sub view {
	my $self = shift;
	my $children = $self->getLineage( ["children"], { returnObjects=>1, excludeClasses=>["WebGUI::Asset::Wobject::Layout"] });
	my %vars;
	# I'm sure there's a more efficient way to do this. We'll figure it out someday.
	my @positions = split(/\./,$self->get("contentPositions"));
	my @hidden = split("\n",$self->get("assetsToHide"));
	my $i = 1;
	my $template= WebGUI::Asset->newByDynamicClass($self->get("templateId"))->get("template");
	my $numPositions = 1;
	foreach my $j (2..15) {
		$numPositions = $j if $template =~ m/position${j}\_loop/;
	}
	my @found;
	my $showPerformance = WebGUI::ErrorHandler::canShowPerformanceIndicators();
	foreach my $position (@positions) {
		my @assets = split(",",$position);
		foreach my $asset (@assets) {
			foreach my $child (@{$children}) {
				if ($asset eq $child->getId) {
					unless (isIn($asset,@hidden) || !($child->canView)) {
						WebGUI::Style::setRawHeadTags($child->getExtraHeadTags);
						my $t = [Time::HiRes::gettimeofday()] if ($showPerformance);
						my $view = $child->view;
						$view .= "Asset:".Time::HiRes::tv_interval($t) if ($showPerformance);
						if ($i > $numPositions) {
							push(@{$vars{"position1_loop"}},{
								id=>$child->getId,
								content=>$view
							});
						} else {
							push(@{$vars{"position".$i."_loop"}},{
								id=>$child->getId,
								content=>$view
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
				my $t = [Time::HiRes::gettimeofday()] if ($showPerformance);
				my $view = $child->view;
				$view .= "Asset:".Time::HiRes::tv_interval($t) if ($showPerformance);
				push(@{$vars{"position1_loop"}},{
					id=>$child->getId,
					content=>$view
					});
			}
		}
	}
	$vars{showAdmin} = ($session{var}{adminOn} && $self->canEdit);
	if ($vars{showAdmin}) {
		# under normal circumstances we don't put HTML stuff in our code, but this will make it much easier
		# for end users to work with our templates
		WebGUI::Style::setScript($session{config}{extrasURL}."/draggable.js",{ type=>"text/javascript" });
		WebGUI::Style::setLink($session{config}{extrasURL}."/draggable.css",{ type=>"text/css", rel=>"stylesheet", media=>"all" });
		WebGUI::Style::setRawHeadTags('
			<style type="text/css">
			.dragging, .empty {
				  background-image: url("'.$session{config}{extrasURL}.'/opaque.gif");
			}
			</style>
			');
		$vars{"dragger.icon"} = WebGUI::Icon::dragIcon();
		$vars{"dragger.init"} = '
			<iframe id="dragSubmitter" style="display: none;" src="'.$session{config}{extrasURL}.'/spacer.gif"></iframe>
			<script type="text/javascript">
				dragable_init("'.$self->getUrl("func=setContentPositions;map=").'");
			</script>
			';
	}

	return $self->processTemplate(\%vars,$self->get("templateId"));
}

sub www_setContentPositions {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless ($self->canEdit);
	$self->addRevision({
		contentPositions=>$session{form}{map}
		});
	return "Map set: ".$session{form}{map};
}


1;

