package WebGUI::Image::Graph::XYGraph::Line;

use strict;
use WebGUI::Image::Graph::XYGraph;
use List::Util;
use POSIX;
use Data::Dumper;

our @ISA = qw(WebGUI::Image::Graph::XYGraph);

#-------------------------------------------------------------------
sub drawGraph {
	my ($currentBar, %location);
	my $self = shift;

	$self->processDataSet;

	my $numberOfGroups = List::Util::max(map {scalar @$_} @{$self->{_datasets}});
	my $interval = $self->getChartWidth / ($numberOfGroups - 1);
	
	%location = %{$self->getChartOffset};
	$location{y} += $self->getChartHeight;

	foreach (@{$self->{_lines}}) {
		$self->drawLine($_, \%location, $interval);
	}
}

#-------------------------------------------------------------------
sub drawLine {
	my $self = shift;
	my $line = shift;
	my $location = shift;
	my $interval = shift;

	my %currentLocation = %$location;


	my $dataCounter;
	my $path;# = " M ".$currentLocation{x}.",".$currentLocation{y};
	foreach (@{$line->{dataset}}) {
		$path .= ($dataCounter++) ? " L " : " M ";
		$path .= $currentLocation{x}.",".($currentLocation{y} - $_*$self->getPixelsPerUnit);
		
		$currentLocation{x} += $interval;
	}
	
	$self->image->Draw(
		primitive	=> 'Path',
		stroke		=> $line->{strokeColor},
		points		=> $path,
		fill		=> 'none',
	);
}

#-------------------------------------------------------------------
sub formNamespace {
	my $self = shift;

	return $self->SUPER::formNamespace.'_Line';
}

#-------------------------------------------------------------------
sub getAnchorSpacing {
	my $self = shift;

	my $numberOfGroups = List::Util::max(map {scalar @$_} @{$self->getDataset});

	my $spacing = $self->getChartWidth / ($numberOfGroups - 1);

	return {
		x	=> $spacing,
		y	=> 0,
	};
}

#-------------------------------------------------------------------
sub getFirstAnchorLocation {
	my $self = shift;

	return {
		x	=> $self->getChartOffset->{x},
		y	=> $self->getChartOffset->{y} + $self->getChartHeight
	}
}

# palette nog laten werken!
#-------------------------------------------------------------------
sub processDataSet {
	my ($barProperties);
	my $self = shift;
	
#	my $maxElements = List::Util::max(map {scalar @$_} @{$self->{_datasets}});
#	my $numberOfDatasets = scalar @{$self->{_datasets}};

	my $palette = $self->getPalette;
	foreach (@{$self->{_datasets}}) {
		push (@{$self->{_lines}}, {
			dataset	=> $_,
			strokeColor => $palette->getColor->getStrokeColor,
		});
		$palette->getNextColor;
	}
}

1;

