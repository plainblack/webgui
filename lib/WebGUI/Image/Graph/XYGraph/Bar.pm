package WebGUI::Image::Graph::XYGraph::Bar;

use strict;
use WebGUI::Image::Graph::XYGraph;
use List::Util;
use POSIX;
use Data::Dumper;

our @ISA = qw(WebGUI::Image::Graph::XYGraph);

#-------------------------------------------------------------------
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
	);
	$f->float(
		name	=> 'xyGraph_bar_groupSpacing',
		value	=> $self->getGroupSpacing,
		label	=> $i18n->get('group spacing'),
	);

	$configForms->{'graph_xygraph_bar'} = $f->printRowsOnly;
	
	return $configForms;
}

#-------------------------------------------------------------------
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
sub drawGraph {
	my ($currentBar, %location);
	my $self = shift;

	$self->processDataSet;

	my $numberOfGroups = List::Util::max(map {scalar @$_} @{$self->{_datasets}});
	my $numberOfDatasets = scalar @{$self->{_datasets}};
	my $groupWidth = ($self->getChartWidth - ($numberOfGroups-1) * $self->getGroupSpacing) / $numberOfGroups;

	my $barWidth = $groupWidth;
	$barWidth = ($groupWidth - ($numberOfDatasets - 1) * $self->getBarSpacing) / $numberOfDatasets if ($self->getDrawMode eq 'sideBySide');
		
	$location{x} = $self->getChartOffset->{x} ;
	$location{y} = $self->getChartOffset->{y} + $self->getChartHeight;
	foreach $currentBar (@{$self->{_bars}}) {
		if ($self->getDrawMode eq 'stacked') {
			$self->drawStackedBar($currentBar, \%location, $barWidth);
		} else {
			$self->drawSideBySideBar($currentBar, \%location, $barWidth);
		}
		
		$location{x} += $groupWidth + $self->getGroupSpacing;
	}	
}

#-------------------------------------------------------------------
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
sub formNamespace {
	my $self = shift;

	return $self->SUPER::formNamespace.'_Bar';
}

#-------------------------------------------------------------------
sub getAnchorSpacing {
	my $self = shift;

	my $numberOfGroups = List::Util::max(map {scalar @$_} @{$self->getDataset});

	my $spacing = ($self->getChartWidth - ($numberOfGroups-1) * $self->getGroupSpacing) / $numberOfGroups + $self->getGroupSpacing;

	return {
		x	=> $spacing,
		y	=> 0,
	};
}

#-------------------------------------------------------------------
sub getBarSpacing {
	my $self = shift;

	return $self->{_barProperties}->{barSpacing} || 0;
}

#-------------------------------------------------------------------
sub getConfiguration {
	my $self = shift;

	my $config = $self->SUPER::getConfiguration;

	$config->{xyGraph_bar_barSpacing}	= $self->getBarSpacing;
	$config->{xyGraph_bar_groupSpacing}	= $self->getGroupSpacing;
	
	return $config;
}

#-------------------------------------------------------------------
sub getGroupSpacing {
	my $self = shift;

	return $self->{_barProperties}->{groupSpacing} || $self->getBarSpacing;
}

#-------------------------------------------------------------------
sub getFirstAnchorLocation {
	my $self = shift;

	return {
		x	=> $self->getChartOffset->{x} + ($self->getAnchorSpacing->{x} - $self->getGroupSpacing) / 2,
		y	=> $self->getChartOffset->{y} + $self->getChartHeight
	}
}

#-------------------------------------------------------------------
sub processDataSet {
	my ($barProperties);
	my $self = shift;

	my $palette = $self->getPalette;
	
	my $maxElements = List::Util::max(map {scalar @$_} @{$self->{_datasets}});
	my $numberOfDatasets = scalar @{$self->{_datasets}};

	for my $currentElement (0 .. $maxElements-1) {
		my @thisSet = ();
		for my $currentDataset (0 .. $numberOfDatasets - 1) {
			push(@thisSet, {
				height => $self->{_datasets}->[$currentDataset]->[$currentElement] || 0,
				fillColor => $palette->getColor($currentDataset)->getFillColor,
				strokeColor => $palette->getColor($currentDataset)->getStrokeColor,
			});
		}
		push(@{$self->{_bars}}, [ @thisSet ]);
	}
}

#-------------------------------------------------------------------
sub setBarSpacing {
	my $self = shift;
	my $gap = shift;
	
	$self->{_barProperties}->{barSpacing} = $gap;
}

#-------------------------------------------------------------------
sub setConfiguration {
	my $self = shift;
	my $config = shift;

	$self->SUPER::setConfiguration($config);

	$self->setBarSpacing($config->{xyGraph_bar_barSpacing});
	$self->setGroupSpacing($config->{xyGraph_bar_groupSpacing});
	
	return $config;
}

#-------------------------------------------------------------------
sub setGroupSpacing {
	my $self = shift;
	my $gap = shift;
	
	$self->{_barProperties}->{groupSpacing} = $gap;
}

1;

