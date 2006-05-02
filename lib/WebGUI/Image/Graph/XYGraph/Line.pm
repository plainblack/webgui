package WebGUI::Image::Graph::XYGraph::Line;

use strict;
use WebGUI::Image::Graph::XYGraph;
use List::Util;
use POSIX;
use Data::Dumper;

our @ISA = qw(WebGUI::Image::Graph::XYGraph);

#-------------------------------------------------------------------
=head1 drawGraph

Draws all the lines.

=cut

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
=head1 drawLine ( line, location, interval )

Draws a bar defined by bar and with width barWidth at location.

=head2 line

A hashref defining the line. Must contain keys 'strokeColor' and
'dataset', the latter one being an arrayref containing all points of the line.

=head2 location

A hashref containing the location of the bottom-left corner of the line's 
origin. Keys 'x' and 'y' must specify the x- and y-coordinates respectively.

=head2 interval

The distance between x-axis anchors in pixels.

=cut



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
=head1 formNamespace

Returns the form namespace of this plugin. See WegBUI::Image::Graph for
more elaborate information.

=cut

sub formNamespace {
	my $self = shift;

	return $self->SUPER::formNamespace.'_Line';
}

#-------------------------------------------------------------------
=head1 getAnchorSpacing

Returns the distance in pixels between two anchors on the x axis that define teh
placement of bars and labels.

=cut

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
=head1 getFirstAnchorLocation

Returns a hashref containing the location of the leftmost x-axis anchor.
Location coordinates are encoded in keys 'x' and 'y'.

=cut

sub getFirstAnchorLocation {
	my $self = shift;

	return {
		x	=> $self->getChartOffset->{x},
		y	=> $self->getChartOffset->{y} + $self->getChartHeight
	}
}

#-------------------------------------------------------------------
=head1 processDataset

Processes the dataset. Used by drawGraph.

=cut

sub processDataSet {
	my ($barProperties);
	my $self = shift;
	
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

