package WebGUI::Image::Graph::XYGraph::Bar;

use strict;
use WebGUI::Image::Graph::XYGraph;
use List::Util;
use POSIX;
use WebGUI::Utility;

our @ISA = qw(WebGUI::Image::Graph::XYGraph);

=head1 NAME

Package WebGUI::Image::Graph::XYGraph::Bar

=head1 DESCRIPTION

Package for creating bar graphs.

=head1 SYNOPSIS

This package privides the logic for drawing 2d bar graphs, 3d bars are in the
pipeline but not yet ready for prime time. 

This module can draw bar graph in two forms: Stacked and Side by Side. The
diffrence is noticable only if more multiple dataset is used, the behaviour is
thus identical in case of one dataset.

Stacked graphs place the bars belonging the same index within diffrent datasets
on top of each other given a grand total for all datasets.

Sid by side graphs place bars with the same index next to each other, grouped by
index. This displays a better comaprison between datasets.

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 configurationForm

Creates the configuration form for this plugin. See WebGUI::Image::Graph for
more information.

=cut

sub configurationForm {
	my $self = shift;

	my $i18n = WebGUI::International->new($self->session, 'Image_Graph_XYGraph_Bar');

	my $configForms = $self->SUPER::configurationForm;
my	$f = WebGUI::HTMLForm->new($self->session);
	$f->trClass('Graph_XYGraph_Bar');
	$f->float(
		name	=> 'xyGraph_bar_barSpacing',
		value	=> $self->getBarSpacing,
		label	=> $i18n->get('bar spacing'),
		hoverHelp => $i18n->get('bar spacing description'),
	);
	$f->float(
		name	=> 'xyGraph_bar_groupSpacing',
		value	=> $self->getGroupSpacing,
		label	=> $i18n->get('group spacing'),
		hoverHelp => $i18n->get('group spacing description'),
	);

	$configForms->{'graph_xygraph_bar'} = $f->printRowsOnly;

	return $configForms;
}

#-------------------------------------------------------------------

=head2 drawBar ( bar, location, barWidth )

Draws a bar defined by bar and with width barWidth at location.

=head3 bar

A hashref defining the bar. Must contain keys 'height', 'strokeColor' and
'fillColor'.

=head3 location

A hashref containing the location of the bottom-left corner of the bar. Keys 'x'
and 'y' must specify the x- and y-coordinates respectively.

=head3 barWidth

The width of the bar in pixels.

=cut

sub drawBar {
	my $self = shift;
	my $bar = shift;
	my $location = shift;
	my $barWidth = shift;

	my $barHeight = $bar->{height} * $self->getPixelsPerUnit;

	$self->image->Draw(
		primitive	=> 'Path',
		stroke		=> $bar->{strokeColor},
		points		=> 
			" M ".$location->{x}.",".$location->{y}.
			" L ".$location->{x}.",".($location->{y}-$barHeight).
			" L ".($location->{x}+$barWidth).",".($location->{y}-$barHeight).
			" L ".($location->{x}+$barWidth).",".$location->{y},
		fill		=> $bar->{fillColor},
	);
}

#-------------------------------------------------------------------

=head2 drawGraph

Draws all the bars.

=cut

sub drawGraph {
	my %location;
	my $self = shift;

	$self->processDataSet;

	my $numberOfGroups = List::Util::max(map {scalar @$_} @{$self->{_datasets}});
	my $numberOfDatasets = scalar @{$self->{_datasets}};
	my $groupWidth = ($self->getChartWidth - ($numberOfGroups-1) * $self->getGroupSpacing) / $numberOfGroups;

	my $barWidth = $groupWidth;
	$barWidth = ($groupWidth - ($numberOfDatasets - 1) * $self->getBarSpacing) / $numberOfDatasets if ($self->getDrawMode eq 'sideBySide');

	$location{x} = $self->getChartOffset->{x} ;
	$location{y} = $self->getChartOffset->{y} + $self->getChartHeight;
	foreach my $currentBar (@{$self->{_bars}}) {
		if ($self->getDrawMode eq 'stacked') {
			$self->drawStackedBar($currentBar, \%location, $barWidth);
		} else {
			$self->drawSideBySideBar($currentBar, \%location, $barWidth);
		}

		$location{x} += $groupWidth + $self->getGroupSpacing;
	}	
}

#-------------------------------------------------------------------

=head2 drawSideBySideBar ( bars, location, barWidth )

Draws the bars in side by side mode. Meaning that per datsetindex the bars
representing a single dataset are grouped.

=head3 bars

An arrayref containing all the bar description hashrefs as described in drawBar.

=head3 location

Hashref containing the initial coordinates of the lower-left corner of the
chart. Pass coords in keys 'x' and 'y'.

=head3 barWidth

The width of each bar in pixels.

=cut

sub drawSideBySideBar {
	my $self = shift;
	my $bars = shift;
	my $location = shift;
	my $barWidth = shift;

	my %thisLocation = %$location;

	foreach (@$bars) {
		$self->drawBar($_, \%thisLocation, $barWidth);
		$thisLocation{x} += $barWidth + $self->getBarSpacing;
	}
}

#-------------------------------------------------------------------

=head2 drawStackedBar ( bars, location, barWidth )

Draws the bars in side by side mode. Meaning that per datset-index the bars
representing a single dataset are stacked on top of each other.

=head3 bars

An arrayref containing all the bar description hashrefs as described in drawBar.

=head3 location

Hashref containing the initial coordinates of the lower-left corner of the
chart. Pass coords in keys 'x' and 'y'.

=head3 barWidth

The width of each bar in pixels.

=cut



sub drawStackedBar {
	my $self = shift;
	my $bars = shift;
	my $location = shift;
	my $barWidth = shift;

	my %thisLocation = %$location;
	foreach (@$bars) {
		$self->drawBar($_, \%thisLocation, $barWidth);
		$thisLocation{y} -= $_->{height} * $self->getPixelsPerUnit;
	}

}

#-------------------------------------------------------------------

=head2 formNamespace

Returns the form namespace of this plugin. See WegBUI::Image::Graph for
more elaborate information.

=cut

sub formNamespace {
	my $self = shift;

	return $self->SUPER::formNamespace.'_Bar';
}

#-------------------------------------------------------------------

=head2 getAnchorSpacing

Returns the distance in pixels between two anchors on the x axis that define teh
placement of bars and labels.

=cut

sub getAnchorSpacing {
	my $self = shift;

	my $numberOfGroups = List::Util::max(map {scalar @$_} @{$self->getDataset});

	my $spacing = sprintf('%.0f', ($self->getChartWidth - ($numberOfGroups-1) * $self->getGroupSpacing) / $numberOfGroups + $self->getGroupSpacing);

	return {
		x	=> $spacing,
		y	=> 0,
	};
}

#-------------------------------------------------------------------

=head2 getBarSpacing

Returns the width of the gap between two bars within a group in pixels.

=cut

sub getBarSpacing {
	my $self = shift;

	return $self->{_barProperties}->{barSpacing} || 0;
}

#-------------------------------------------------------------------

=head2 getConfiguration

Returns the configuration hashref for this plugin. Refer to WebGUI::IMage::Graph
for a more detailed description.

=cut

sub getConfiguration {
	my $self = shift;

	my $config = $self->SUPER::getConfiguration;

	$config->{xyGraph_bar_barSpacing}	= $self->getBarSpacing;
	$config->{xyGraph_bar_groupSpacing}	= $self->getGroupSpacing;

	return $config;
}

#-------------------------------------------------------------------

=head2 getGroupSpacing

Returns the width of the gap between two groups of bars in pixels.

=cut

sub getGroupSpacing {
	my $self = shift;

	return $self->{_barProperties}->{groupSpacing} || $self->getBarSpacing;
}

#-------------------------------------------------------------------

=head2 getFirstAnchorLocation

Returns a hashref containing the location of the leftmost x-axis anchor.
Location coordinates are encoded in keys 'x' and 'y'.

=cut

sub getFirstAnchorLocation {
	my $self = shift;

	return {
		x	=> sprintf('%.0f', $self->getChartOffset->{x} + ($self->getAnchorSpacing->{x} - $self->getGroupSpacing) / 2),
		y	=> $self->getChartOffset->{y} + $self->getChartHeight
	}
}

#-------------------------------------------------------------------

=head2 processDataSet

Processes the dataset. Used by drawGraph.

=cut

sub processDataSet {
	my ($barProperties);
	my $self = shift;

	my $palette = $self->getPalette;

	my $maxElements = List::Util::max(map {scalar @$_} @{$self->{_datasets}});
	my $numberOfDatasets = scalar @{$self->{_datasets}};

	for my $currentElement (0 .. $maxElements-1) {
		my @thisSet = ();
		for my $currentDataset (0 .. $numberOfDatasets - 1) {
            my $color = $palette->getColor($currentDataset);
            if ($numberOfDatasets == 1) {
                $color = $palette->getNextColor;
            }
			push(@thisSet, {
				height => $self->{_datasets}->[$currentDataset]->[$currentElement] || 0,
				fillColor => $color->getFillColor,
				strokeColor => $color->getStrokeColor,
			});
		}
		push(@{$self->{_bars}}, [ @thisSet ]);
	}
}

#-------------------------------------------------------------------

=head2 setBarSpacing ( gap )

Sets the distance between two bars in a group in pixels.

=head3 gap

The distance in pixels.

=cut

sub setBarSpacing {
	my $self = shift;
	my $gap = shift;

	$self->{_barProperties}->{barSpacing} = $gap;
}

#-------------------------------------------------------------------

=head2 setConfiguration ( config )

Applies the given configuration hash to this plugin. See WebGUI::Image::Graph
for more info.

=head3 config

The configuration hash.

=cut

sub setConfiguration {
	my $self = shift;
	my $config = shift;

	$self->SUPER::setConfiguration($config);

	$self->setBarSpacing($config->{xyGraph_bar_barSpacing});
	$self->setGroupSpacing($config->{xyGraph_bar_groupSpacing});

	return $config;
}

#-------------------------------------------------------------------

=head2 setGroupSpacing ( gap )

Sets the distance between two groups of bars in pixels.

=head3 gap

The distance in pixels.

=cut

sub setGroupSpacing {
	my $self = shift;
	my $gap = shift;

	$self->{_barProperties}->{groupSpacing} = $gap;
}

1;

