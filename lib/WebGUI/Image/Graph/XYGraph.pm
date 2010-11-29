package WebGUI::Image::Graph::XYGraph;

use strict;
use WebGUI::Image::Graph;
use WebGUI::International;
use List::Util;
use POSIX;

our @ISA = qw(WebGUI::Image::Graph);

=head1 NAME

Package WebGUI::Image::Graph::XYGraph

=head1 DESCRIPTION

Base class for flat xy charts.

=head1 SYNOPSIS

XY charts are graphs that have a x and a y coordinate. Examples are Line and Bar
graphs. 

This package provides basics needs for such graphs like methods for drawing
axis, labels, rulers and the likes. Also it has methods to set parameters
belonging to xy charts in general such as setting chart width.

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 configurationForm ( )

The configuration form part for this object. See WebGUI::Image::Graph for
documentation.

=cut

sub configurationForm {
	my $self = shift;
    my $tab  = shift;

	my $i18n = WebGUI::International->new($self->session, 'Image_Graph_XYGraph');

	$self->SUPER::configurationForm($tab);

	$tab->addField('integer',
		name	=> 'xyGraph_chartWidth',
		value	=> $self->getChartWidth,
		label	=> $i18n->get('chart width'),
		hoverHelp => $i18n->get('chart width description'),
	);
	$tab->addField('integer',
		name	=> 'xyGraph_chartHeight',
		value	=> $self->getChartHeight,
		label	=> $i18n->get('chart height'),
		hoverHelp => $i18n->get('chart height description'),
	);
	$tab->addField('yesNo',
		name	=> 'xyGraph_drawLabels',
		value	=> $self->showLabels,
		label	=> $i18n->get('draw labels'),
		hoverHelp => $i18n->get('draw labels description'),
	);
	$tab->addField('yesNo',
		name	=> 'xyGraph_drawAxis',
		value	=> $self->showAxis,
		label	=> $i18n->get('draw axis'),
		hoverHelp => $i18n->get('draw axis description'),
	);
	$tab->addField('color',
		name	=> 'xyGraph_axisColor',
		value	=> $self->getAxisColor,
		label	=> $i18n->get('axis color'),
		hoverHelp => $i18n->get('axis color description'),
	);
	$tab->addField('yesNo',
		name	=> 'xyGraph_drawRulers',
		value	=> $self->showRulers,
		label	=> $i18n->get('draw rulers'),
		hoverHelp => $i18n->get('draw rulers description'),
	);
	$tab->addField('color',
		name	=> 'xyGraph_rulerColor',
		value	=> $self->getRulerColor,
		label	=> $i18n->get('ruler color'),
		hoverHelp => $i18n->get('ruler color description'),
	);
	$tab->addField('selectBox',
		name	=> 'xyGraph_drawMode',
		value	=> [ $self->getDrawMode ],
		label	=> $i18n->get('draw mode'),
		hoverHelp => $i18n->get('draw mode description'),
		multiple=> 0,
		options	=> {
			sideBySide	=> 'Side by side',
			stacked		=> 'Stacked (cumulative',
		},
	);
	$tab->addField('float',
		name	=> 'xyGraph_yGranularity',
		value	=> $self->getYGranularity,
		label	=> $i18n->get('y granularity'),	
		hoverHelp => $i18n->get('y granularity description'),
	);
}

#-------------------------------------------------------------------

=head2 draw ( )

Draws the graph.

=cut

sub draw {
	my $self = shift;

	# Automagically set the chart offset.
	my $maxYLabelWidth = List::Util::max(map {$self->getLabelDimensions($_)->{width}} @{$self->getYLabels});
	$self->setChartOffset({
		x=> $maxYLabelWidth + 2*$self->getLabelOffset,
		y=> $self->getLabelOffset
	});

	$self->drawRulers if ($self->showRulers);
	$self->drawGraph;
	$self->drawAxis if ($self->showAxis);
	$self->drawLabels if ($self->showLabels);
}

#-------------------------------------------------------------------

=head2 drawAxis ( )

Draws the axis.

=cut

sub drawAxis {
	my $self = shift;

	my $chartOffset = $self->getChartOffset;
	$self->image->Draw(
		primitive	=> 'Path',
		stroke		=> $self->getAxisColor,
		points		=> 
			" M ".$chartOffset->{x}.",".$chartOffset->{y}.
			" L ".$chartOffset->{x}.",".($self->getChartHeight + $chartOffset->{y}).
			" L ".($self->getChartWidth + $chartOffset->{x}).",".($self->getChartHeight + $chartOffset->{y}),
        fill        => 'none',
	);
}

#-------------------------------------------------------------------

=head2 drawLabels ( )

Draws the labels.

=cut

sub drawLabels {
	my $self = shift;
	my $location = shift;

	my %anchorPoint = %{$self->getFirstAnchorLocation}; 

	# Draw x-axis labels
	foreach my $text (@{$self->getLabel}) {
		$self->drawLabel($text, (
			alignVertical	=> 'top',
			align		=> 'left',
            rotate      => 90,
			x		=> $anchorPoint{x},
			y		=> $anchorPoint{y},
		));

		$anchorPoint{x} += $self->getAnchorSpacing->{x};
		$anchorPoint{y} += $self->getAnchorSpacing->{y};
	}

	# Draw y-axis labels
	$anchorPoint{x} = $self->getChartOffset->{x} - $self->getLabelOffset;
	$anchorPoint{y} = $self->getChartOffset->{y} + $self->getChartHeight;
	foreach (@{$self->getYLabels}) {
		$self->drawLabel($_, (
			alignHorizontal	=> 'right',
			alignVertical	=> 'center',
			x		=> $anchorPoint{x}, 
			y		=> $anchorPoint{y}, 
		));
		$anchorPoint{y} -= $self->getPixelsPerUnit * $self->getYGranularity
	}
}

#-------------------------------------------------------------------

=head2 drawRulers ( )

Draws the rulers.

=cut

sub drawRulers {
	my $self = shift;

	my $chartOffset = $self->getChartOffset;
	my $dist = $self->getLabelOffset;

	for (1 .. $self->getYRange / $self->getYGranularity) {
		$self->image->Draw(
			primitive	=> 'Path',
			stroke		=> $self->getRulerColor,
			points		=>
				" M ".$chartOffset->{x}.",".($chartOffset->{y}+$self->getChartHeight - $self->getPixelsPerUnit * $_*$self->getYGranularity).
				" L ".($chartOffset->{x}+$self->getChartWidth).",".($chartOffset->{y}+$self->getChartHeight - $self->getPixelsPerUnit * $_*$self->getYGranularity)
		);
	}
}

#-------------------------------------------------------------------

=head2 formNamespace ( )

Extends the form namespace for this object. See WebGUI::Image::Graph for
documentation.

=cut

sub formNamespace {
	my $self = shift;

	return $self->SUPER::formNamespace.'_XYGraph';
}

#-------------------------------------------------------------------

=head2 getAnchorSpacing () 

This method MUST be overridden by all sub classes.

=cut

sub getAnchorSpacing {
    die "You were supposed to override this method in the sub class.";
}


#-------------------------------------------------------------------

=head2 getAxisColor ( )

Returns the color triplet for the axis. Defaults to '#222222'.

=cut

sub getAxisColor {
	my $self = shift;

	return $self->{_axisProperties}->{axisColor} || '#222222';
}

#-------------------------------------------------------------------

=head2 getChartHeight ( )

Returns the height of the chart. Defaults to 200.

=cut

sub getChartHeight {
	my $self = shift;

	return $self->{_properties}->{chartHeight} || 200;
}

#-------------------------------------------------------------------

=head2 getChartOffset ( )

Returns the coordinates of the top-left corner of the chart. he coordinates are
contained in a hasref with keys 'x' and 'y'.

=cut

sub getChartOffset {
	my $self = shift;

	return $self->{_properties}->{chartOffset} || { x=>0, y=>0 }
}

#-------------------------------------------------------------------

=head2 getChartWidth ( )

Returns the width of the chart. Defaults to 200.

=cut

sub getChartWidth {
	my $self = shift;

	return $self->{_properties}->{chartWidth} || 200;
}

#-------------------------------------------------------------------

=head2 getConfiguration ( )

Returns a configuration hashref. See WebGUI::Image::Graph for documentation.

=cut

sub getConfiguration {
	my $self = shift;

	my $config = $self->SUPER::getConfiguration;

	$config->{xyGraph_chartWidth}	= $self->getChartWidth;
	$config->{xyGraph_chartHeight}	= $self->getChartHeight;
	$config->{xyGraph_drawLabels}	= $self->showLabels;
	$config->{xyGraph_drawAxis}	= $self->showAxis;
	$config->{xyGraph_drawRulers}	= $self->showRulers;
	$config->{xyGraph_drawMode}	= $self->getDrawMode;
	$config->{xyGraph_yGranularity}	= $self->getYGranularity;

	return $config;
}

#-------------------------------------------------------------------

=head2 getDrawMode ( )

Returns the drawmode. Currently supported are 'stacked' and 'sideBySide'.
Defaults to 'sideBySide'.

=cut

sub getDrawMode {
	my $self = shift;

	return $self->{_barProperties}->{drawMode} || 'sideBySide';
}

#-------------------------------------------------------------------

=head2 getPixelsPerUnit ( )

Returns the number of pixels that correspond with one unit of the dataset
values.

=cut

sub getPixelsPerUnit {
	my $self = shift;

	return $self->getChartHeight / $self->getYRange;
}

#-------------------------------------------------------------------

=head2 getRulerColor ( )

Returns the color triplet of the rulers in the graph. Defaults to '#777777'.

=cut

sub getRulerColor {
	my $self = shift;

	return $self->{_axisProperties}->{rulerColor} || '#777777';
}

#-------------------------------------------------------------------

=head2 getYGranularity ( )

Returns the granularity of the labels and rulers in the Y direction. Defaults to
10. This is value is in terms of the values in the dataset and has no direct
relation to pixels.

=cut

sub getYGranularity {
	my $self = shift;

	return $self->{_properties}->{yGranularity} || 10;
}

#-------------------------------------------------------------------

=head2 getYLabels ( )

Returns an arrayref containing the labels for the Y axis.

=cut

sub getYLabels {
	my $self = shift;

	my @yLabels;
	for (0 .. $self->getYRange / $self->getYGranularity) {
		push(@yLabels, $_ * $self->getYGranularity);
	}

	return \@yLabels;
}

#-------------------------------------------------------------------

=head2 getYRange ( )

Returns the maxmimal value of the range that contains a whole number of times
the y granularity and is bigger than the maximum value in the dataset.

=cut

sub getYRange {
	my $self = shift;

	return $self->getYGranularity*ceil($self->getMaxValueFromDataset / $self->getYGranularity) || 1;
}

#-------------------------------------------------------------------

=head2 setAxisColor ( color )

Sets the color of the axis to the supplied value.

=head3 color

The triplet of the color you want to set the axis to. Must have the following
form: #ffffff.

=cut

sub setAxisColor {
	my $self = shift;
	my $color = shift;

	$self->{_axisProperties}->{axisColor} = $color;
}

#-------------------------------------------------------------------

=head2 setChartHeight ( height )

Sets the height of the chart to the specified value.

=head3 height

The desired height in pixels.

=cut

sub setChartHeight {
	my $self = shift;
	my $height = shift;

	$self->{_properties}->{chartHeight} = $height;
}

#-------------------------------------------------------------------

=head2 setChartOffset ( location )

Sets the location of the top-left corner of the graph within the image.

=head3 location

A hashref containing the desired location. Use the 'x' and 'y' as keys for the x
and y coordinate respectively.

=cut

sub setChartOffset {
	my $self = shift;
	my $point = shift;

	$self->{_properties}->{chartOffset} = {%$point};
}

#-------------------------------------------------------------------

=head2 setChartWidth ( width )

Sets the width of the chart to the specified value.

=head3 width

The desired width in pixels.

=cut

sub setChartWidth {
	my $self = shift;
	my $width = shift;

	$self->{_properties}->{chartWidth} =$width;
}

#-------------------------------------------------------------------

=head2 setConfiguration ( config )

Applies the settings in the given configuration hash. See WebGUI::Image::Graph
for more information.

=head3 config

A configuration hash.

=cut

sub setConfiguration {
	my $self = shift;
	my $config = shift;

	$self->SUPER::setConfiguration($config);

	$self->setChartWidth($config->{xyGraph_chartWidth});
	$self->setChartHeight($config->{xyGraph_chartHeight});
	$self->setShowLabels($config->{xyGraph_drawLabels});
	$self->setShowAxis($config->{xyGraph_drawAxis});
	$self->setShowRulers($config->{xyGraph_drawRulers});
	$self->setDrawMode($config->{xyGraph_drawMode});
	$self->setYGranularity($config->{xyGraph_yGranularity});
	$self->setAxisColor($config->{xyGraph_axisColor});
	$self->setRulerColor($config->{xyGraph_rulerColor});

	return $config;
}

#-------------------------------------------------------------------

=head2 setDrawMode ( mode )

Set the way the datasets are drawn. Currently supported are 'stacked' and
'sideBySide' which correspond to respectivly cumulative drawing and normal
processing.

=head3 mode

The desired mode. Can be 'sideBySide' or 'stacked'.

=cut

sub setDrawMode {
	my $self = shift;
	my $mode = shift;

	if ($mode eq 'stacked' || $mode eq 'sideBySide') {
		$self->{_barProperties}->{drawMode} = $mode;
	} else {
		$self->{_barProperties}->{drawMode} = 'sideBySide';
	}
}

#-------------------------------------------------------------------

=head2 setRulerColor ( color )

Set the color of the rulers.

=head3 color

The triplet of the desired ruler color. Must be in the following format:
'#ffffff'.

=cut

sub setRulerColor {
	my $self = shift;
	my $color = shift;

	$self->{_axisProperties}->{rulerColor} = $color;
}

#-------------------------------------------------------------------

=head2 setShowAxis ( boolean )

Set whether or not to draw the axis.

=head3 boolean

If set to false the axis won't be drawn.

=cut

sub setShowAxis {
	my $self = shift;
	my $yesNo = shift;

	$self->{_properties}->{showAxis} = $yesNo;
}

#-------------------------------------------------------------------

=head2 setShowLabels ( boolean )

Set whether or not to draw the labels.

=head3 boolean

If set to false the labels won't be drawn.

=cut

sub setShowLabels {
	my $self = shift;
	my $yesNo = shift;

	$self->{_properties}->{showLabels} = $yesNo;
}

#-------------------------------------------------------------------

=head2 setShowRulers ( boolean )

Set whether or not to draw the rulers.

=head3 boolean

If set to false the rulers won't be drawn.

=cut

sub setShowRulers {
	my $self = shift;
	my $yesNo = shift;

	$self->{_properties}->{showRulers} = $yesNo;
}

#-------------------------------------------------------------------

=head2 setYGranularity ( value )

Sets the y granularity. See getYGranularity for explanation of this concept.

=head3 value

The granularity in dataset units, not pixels.

=cut

sub setYGranularity {
	my $self = shift;
	my $granularity = shift;

	$self->{_properties}->{yGranularity} = $granularity;
}

#-------------------------------------------------------------------

=head2 showAxis ( )

Returns a boolean indicating whether to draw the axis.

=cut

sub showAxis {
	my $self = shift;

	return 1 unless (defined $self->{_properties}->{showAxis});
	return $self->{_properties}->{showAxis};
}

#-------------------------------------------------------------------

=head2 showLabels ( )

Returns a boolean indicating whether to draw the labels.

=cut

sub showLabels {
	my $self = shift;

	return 1 unless (defined $self->{_properties}->{showLabels});
	return $self->{_properties}->{showLabels};
}

#-------------------------------------------------------------------

=head2 showRulers ( )

Returns a boolean indicating whether to draw the rulers.

=cut

sub showRulers {
	my $self = shift;

	return 1 unless (defined $self->{_properties}->{showRulers});
	return $self->{_properties}->{showRulers};
}

1;

