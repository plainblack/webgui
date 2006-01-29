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
use WebGUI::Asset::Wobject;
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

=head2 getEditForm ()

Returns the TabForm object that will be used in generating the edit page for this asset.

=cut

sub getEditForm {
	my $self = shift;
	my $tabform = $self->SUPER::getEditForm();
	my $i18n = WebGUI::International->new($self->session,"Asset_Layout");
   	$tabform->getTab("display")->template(
      		-value=>$self->getValue('templateId'),
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
sub viewOriginal {
	my $self = shift;
	my $children = $self->getLineage( ["children"], { returnObjects=>1, excludeClasses=>["WebGUI::Asset::Wobject::Layout"] });
	my %vars;
	# I'm sure there's a more efficient way to do this. We'll figure it out someday.
	my @positions = split(/\./,$self->get("contentPositions"));
	my @hidden = split("\n",$self->get("assetsToHide"));
	my $i = 1;
	my $template= WebGUI::Asset->newByDynamicClass($self->session,$self->get("templateId"))->get("template");
	my $numPositions = 1;
	foreach my $j (2..15) {
		$numPositions = $j if $template =~ m/position${j}\_loop/;
	}
	my @found;
	my $showPerformance = $self->session->errorHandler->canShowPerformanceIndicators();
	foreach my $position (@positions) {
		my @assets = split(",",$position);
		foreach my $asset (@assets) {
			foreach my $child (@{$children}) {
				if ($asset eq $child->getId) {
					unless (isIn($asset,@hidden) || !($child->canView)) {
						$self->session->style->setRawHeadTags($child->getExtraHeadTags);
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
	$vars{showAdmin} = ($self->session->var->get("adminOn") && $self->canEdit);
	if ($vars{showAdmin}) {
		# under normal circumstances we don't put HTML stuff in our code, but this will make it much easier
		# for end users to work with our templates
		$self->session->style->setScript($self->session->config->get("extrasURL")."/draggable.js",{ type=>"text/javascript" });
		$self->session->style->setLink($self->session->config->get("extrasURL")."/draggable.css",{ type=>"text/css", rel=>"stylesheet", media=>"all" });
		$self->session->style->setRawHeadTags('
			<style type="text/css">
			.dragging, .empty {
				  background-image: url("'.$self->session->config->get("extrasURL").'/opaque.gif");
			}
			</style>
			');
		$vars{"dragger.icon"} = $self->session->icon->drag();
		$vars{"dragger.init"} = '
			<iframe id="dragSubmitter" style="display: none;" src="'.$self->session->config->get("extrasURL").'/spacer.gif"></iframe>
			<script type="text/javascript">
				dragable_init("'.$self->getUrl("func=setContentPositions;map=").'");
			</script>
			';
	}

	return $self->processTemplate(\%vars,$self->get("templateId"));
}

#-------------------------------------------------------------------
sub view {
	my $self = shift;
	my $children = $self->getLineage( ["children"], { returnObjects=>1, excludeClasses=>["WebGUI::Asset::Wobject::Layout"] });
	my %vars;
	# I'm sure there's a more efficient way to do this. We'll figure it out someday.
	my @positions = split(/\./,$self->get("contentPositions"));
	my @hidden = split("\n",$self->get("assetsToHide"));
	my @placeHolder = ();
	my $i = 1;
	my $template= WebGUI::Asset->newByDynamicClass($self->session,$self->get("templateId"))->get("template");
	my $numPositions = 1;
	foreach my $j (2..15) {
		$numPositions = $j if $template =~ m/position${j}\_loop/;
	}
	my @found;
	my $showPerformance = $self->session->errorHandler->canShowPerformanceIndicators();
	foreach my $position (@positions) {
		my @assets = split(",",$position);
		foreach my $asset (@assets) {
			foreach my $child (@{$children}) {
				if ($asset eq $child->getId) {
					unless (isIn($asset,@hidden) || !($child->canView)) {
						$self->session->style->setRawHeadTags($child->getExtraHeadTags);
						push(@placeHolder, $child);
						if ($i > $numPositions) {
							push(@{$vars{"position1_loop"}},{
								id=>$child->getId,
								content=>"~~~"
							});
						} else {
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
				push(@placeHolder, $child);
				push(@{$vars{"position1_loop"}},{
					id=>$child->getId,
					content=>"~~~"
					});
			}
		}
	}
	$vars{showAdmin} = ($self->session->var->get("adminOn") && $self->canEdit);
	if ($vars{showAdmin}) {
		# under normal circumstances we don't put HTML stuff in our code, but this will make it much easier
		# for end users to work with our templates
		$self->session->style->setScript($self->session->config->get("extrasURL")."/draggable.js",{ type=>"text/javascript" });
		$self->session->style->setLink($self->session->config->get("extrasURL")."/draggable.css",{ type=>"text/css", rel=>"stylesheet", media=>"all" });
		$self->session->style->setRawHeadTags('
			<style type="text/css">
			.dragging, .empty {
				  background-image: url("'.$self->session->config->get("extrasURL").'/opaque.gif");
			}
			</style>
			');
		$vars{"dragger.icon"} = $self->session->icon->drag();
		$vars{"dragger.init"} = '
			<iframe id="dragSubmitter" style="display: none;" src="'.$self->session->config->get("extrasURL").'/spacer.gif"></iframe>
			<script type="text/javascript">
				dragable_init("'.$self->getUrl("func=setContentPositions;map=").'");
			</script>
			';
	}
	my @parts = split("~~~",$self->processTemplate(\%vars,$self->get("templateId")));
	foreach my $part (@parts) {
		print $part;
		my $asset = shift @placeHolder;
		if (defined $asset) {
			my $t = [Time::HiRes::gettimeofday()] if ($showPerformance);
			print $asset->view;
			print "Asset:".Time::HiRes::tv_interval($t) if ($showPerformance);
		}
	}
}

sub www_setContentPositions {
	my $self = shift;
	return $self->session->privilege->insufficient() unless ($self->canEdit);
	$self->addRevision({
		contentPositions=>$self->session->form->process("map")
		});
	return "Map set: ".$self->session->form->process("map");
}

sub www_view {
	my $self = shift;
	$self->session->http->getHeader;	
	my $style = $self->processStyle("~~~");
	my ($head, $foot) = split("~~~",$style);
	print $head;
	$self->view;
	print $foot;
}

1;

