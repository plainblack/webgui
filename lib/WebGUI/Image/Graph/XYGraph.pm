package WebGUI::Image::Graph::XYGraph;

use strict;
use WebGUI::Image::Graph;
use WebGUI::International;
use List::Util;
use POSIX;

our @ISA = qw(WebGUI::Image::Graph);

#-------------------------------------------------------------------
sub configurationForm {
	my ($configForms, $f);
	my $self = shift;

	my $i18n = WebGUI::International->new($self->session, 'Image_Graph_XYGraph');
	
	$configForms = $self->SUPER::configurationForm;
	
	$f = WebGUI::HTMLForm->new($self->session);
	$f->trClass('Graph_XYGraph');
	$f->integer(
		name	=> 'xyGraph_chartWidth',
		value	=> $self->getChartWidth,
		label	=> $i18n->get('chart width'),
	);
	$f->integer(
		name	=> 'xyGraph_chartHeight',
		value	=> $self->getChartHeight,
		label	=> $i18n->get('chart height'),
	);
	$f->yesNo(
		name	=> 'xyGraph_drawLabels',
		value	=> $self->showLabels,
		label	=> $i18n->get('draw labels'),
	);
	$f->yesNo(
		name	=> 'xyGraph_drawAxis',
		value	=> $self->showAxis,
		label	=> $i18n->get('draw axis'),
	);
	$f->color(
		name	=> 'xyGraph_axisColor',
		value	=> $self->getAxisColor,
		label	=> $i18n->get('axis color'),
	);
	$f->yesNo(
		name	=> 'xyGraph_drawRulers',
		value	=> $self->showRulers,
		label	=> $i18n->get('draw rulers'),
	);
	$f->color(
		name	=> 'xyGraph_rulerColor',
		value	=> $self->getRulerColor,
		label	=> $i18n->get('ruler color'),
	);
	$f->selectBox(
		name	=> 'xyGraph_drawMode',
		value	=> [ $self->getDrawMode ],
		label	=> $i18n->get('draw mode'),
		multiple=> 0,
		options	=> {
			sideBySide	=> 'Side by side',
			stacked		=> 'Stacked (cumulative',
		},
	);
	$f->float(
		name	=> 'xyGraph_yGranularity',
		value	=> $self->getYGranularity,
		label	=> $i18n->get('y granularity'),	
	);
	
	$configForms->{'graph_xygraph'} = $f->printRowsOnly;
	return $configForms;
}

#-------------------------------------------------------------------
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
sub drawAxis {
	my $self = shift;

	my $chartOffset = $self->getChartOffset;
	$self->image->Draw(
		primitive	=> 'Path',
		stroke		=> $self->getAxisColor,
		points		=> 
			" M ".$chartOffset->{x}.",".$chartOffset->{y}.
			" L ".$chartOffset->{x}.",".($self->getChartHeight + $chartOffset->{y}).
			" L ".($self->getChartWidth + $chartOffset->{x}).",".($self->getChartHeight + $chartOffset->{y})
	);
}

#-------------------------------------------------------------------
sub drawLabels {
	my $self = shift;
	my $location = shift;

	my %anchorPoint = %{$self->getFirstAnchorLocation};# %$location;

	# Draw x-axis labels
	foreach (@{$self->getLabel}) {
		my $text = $self->wrapLabelToWidth($_, $self->getAnchorSpacing->{x});
		$self->drawLabel(
			text	 	=> $text,
			alignHorizontal	=> 'center',
			alignVertical	=> 'top',
			align		=> 'Center',
			x		=> $anchorPoint{x},
			y		=> $anchorPoint{y},
		);

		$anchorPoint{x} += $self->getAnchorSpacing->{x}; #$groupWidth + $self->getGroupSpacing;
		$anchorPoint{y} += $self->getAnchorSpacing->{y};
	}

	# Draw y-axis labels
	$anchorPoint{x} = $self->getChartOffset->{x} - $self->getLabelOffset;
	$anchorPoint{y} = $self->getChartOffset->{y} + $self->getChartHeight;
#	for (1 .. $self->getYRange / $self->getYGranularity) {
	foreach (@{$self->getYLabels}) {
		$self->drawLabel(
			text	 	=> $_,
			alignHorizontal	=> 'right',
			alignVertical	=> 'center',
			x		=> $anchorPoint{x}, #$self->getChartOffset->{x} - $self->getLabelOffset,
			y		=> $anchorPoint{y}, #$self->getChartOffset->{y} + $self->getChartHeight - $self->getPixelsPerUnit * $_*$self->getYGranularity,
		);
		$anchorPoint{y} -= $self->getPixelsPerUnit * $self->getYGranularity
	}
}

#-------------------------------------------------------------------
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
sub formNamespace {
	my $self = shift;

	return $self->SUPER::formNamespace.'_XYGraph';
}

#-------------------------------------------------------------------
sub getAxisColor {
	my $self = shift;

	return $self->{_axisProperties}->{axisColor} || '#222222';
}
	
#-------------------------------------------------------------------
sub getChartHeight {
	my $self = shift;

	return $self->{_properties}->{chartHeight};
}

#-------------------------------------------------------------------
sub getChartOffset {
	my $self = shift;

	return $self->{_properties}->{chartOffset} || { x=>0, y=>0 }
}

#-------------------------------------------------------------------
sub getChartWidth {
	my $self = shift;

	return $self->{_properties}->{chartWidth};
}

#-------------------------------------------------------------------
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
sub getDrawMode {
	my $self = shift;

	return $self->{_barProperties}->{drawMode} || 'sideBySide';
}

#-------------------------------------------------------------------
sub getPixelsPerUnit {
	my $self = shift;
	
	return $self->getChartHeight / $self->getYRange;
}

#-------------------------------------------------------------------
sub getRulerColor {
	my $self = shift;

	return $self->{_axisProperties}->{rulerColor} || '#777777';
}

#-------------------------------------------------------------------
sub getYGranularity {
	my $self = shift;

	return $self->{_properties}->{yGranularity} || 50;
}

#-------------------------------------------------------------------
sub getYLabels {
	my $self = shift;

	my @yLabels;
	for (0 .. $self->getYRange / $self->getYGranularity) {
		push(@yLabels, $_ * $self->getYGranularity);
	}

	return \@yLabels;
}

#-------------------------------------------------------------------
sub getYRange {
	my $self = shift;

	return $self->getYGranularity*ceil($self->getMaxValueFromDataset / $self->getYGranularity) || 1;
}

#-------------------------------------------------------------------
sub setAxisColor {
	my $self = shift;
	my $color = shift;
	
	$self->{_axisProperties}->{axisColor} = $color;
}

#-------------------------------------------------------------------
sub setChartHeight {
	my $self = shift;
	my $height = shift;

	$self->{_properties}->{chartHeight} = $height;
}

#-------------------------------------------------------------------
sub setChartOffset {
	my $self = shift;
	my $point = shift;

	$self->{_properties}->{chartOffset} = {%$point};
}

#-------------------------------------------------------------------
sub setChartWidth {
	my $self = shift;
	my $width = shift;

	$self->{_properties}->{chartWidth} =$width;
}

#-------------------------------------------------------------------
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
sub setRulerColor {
	my $self = shift;
	my $color = shift;
	
	$self->{_axisProperties}->{rulerColor} = $color;
}

#-------------------------------------------------------------------
sub setShowAxis {
	my $self = shift;
	my $yesNo = shift;

	$self->{_properties}->{showAxis} = $yesNo;
}

#-------------------------------------------------------------------
sub setShowLabels {
	my $self = shift;
	my $yesNo = shift;

	$self->{_properties}->{showLabels} = $yesNo;
}

#-------------------------------------------------------------------
sub setShowRulers {
	my $self = shift;
	my $yesNo = shift;

	$self->{_properties}->{showRulers} = $yesNo;
}

#-------------------------------------------------------------------
sub setYGranularity {
	my $self = shift;
	my $granularity = shift;
	
	$self->{_properties}->{yGranularity} = $granularity;
}

#-------------------------------------------------------------------
sub showAxis {
	my $self = shift;

	return 1 unless (defined $self->{_properties}->{showAxis});
	return $self->{_properties}->{showAxis};
}

#-------------------------------------------------------------------
sub showLabels {
	my $self = shift;

	return 1 unless (defined $self->{_properties}->{showLabels});
	return $self->{_properties}->{showLabels};
}

#-------------------------------------------------------------------
sub showRulers {
	my $self = shift;

	return 1 unless (defined $self->{_properties}->{showRulers});
	return $self->{_properties}->{showRulers};
}

1;

