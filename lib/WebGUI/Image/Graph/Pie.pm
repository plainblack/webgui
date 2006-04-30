package WebGUI::Image::Graph::Pie;

use strict;
use WebGUI::Image::Graph;
use Data::Dumper::Simple;
use constant pi => 3.14159265358979;
use Data::Dumper;

our @ISA = qw(WebGUI::Image::Graph);

#-------------------------------------------------------------------
sub _mod2pi {
	my $angle = shift;

	if ($angle < 0) {
#		return 2*pi + $angle - 2*pi*int($angle/(2*pi));
	} else {
		return $angle - 2*pi*int($angle/(2*pi));
	}
}

#-------------------------------------------------------------------
sub addSlice {
	my (%slice, $leftMost, $rightMost, $center, $overallStartCorner, $overallEndCorner, 
		$fillColor, $strokeColor, $sideColor);
	my $self = shift;
	my $properties = shift;

	my $percentage = $properties->{percentage};
	
	# Work around a bug in imagemagick where an A path with the same start and end point will segfault.
	if ($percentage == 1) { 
		$percentage = 0.9999999;
	}
	
	my $label = $properties->{label};
	my $color = $properties->{color};
	
	my $angle = 2*pi*$percentage;
	my $startAngle = _mod2pi($self->{_currentAngle}) || _mod2pi(2*pi*$self->getStartAngle/360) || 0; 
	my $stopAngle = _mod2pi($startAngle + $angle);
	my $avgAngle = _mod2pi((2 * $startAngle + $angle) / 2);

	$self->{_currentAngle} = $stopAngle;

	my $mainStartDraw = 1;
	my $mainStopDraw = 1;

	$fillColor = $color->getFillColor;
	$strokeColor = $color->getStrokeColor;
	
	if ($self->hasShadedSides) {
		$sideColor = $color->darken->getFillColor;
	} else {
		$sideColor = $fillColor;
	}
	
	my %sliceData = (
		# color properties
		fillColor	=> $fillColor,
		strokeColor	=> $strokeColor,
		bottomColor	=> $fillColor, #$properties->{bottomColor} || $properties->{fillColor},
		topColor	=> $fillColor, #$properties->{topColor} || $properties->{fillColor},
		startPlaneColor	=> $sideColor, #$properties->{startPlaneColor} || $properties->{fillColor},
		stopPlaneColor	=> $sideColor, #$properties->{stopPlaneColor} || $properties->{fillColor},
		rimColor	=> $sideColor, #$properties->{rimColor} || $properties->{fillColor},

		# geometric properties
		topHeight	=> $self->getTopHeight,
		bottomHeight	=> $self->getBottomHeight,
		explosionLength	=> $self->getExplosionLength,
		scaleFactor	=> $self->getScaleFactor,

		# keep the slice number for debugging properties
		sliceNr		=> scalar(@{$self->{_slices}}),
		label		=> $label,
		percentage	=> $percentage,
	);

	# parttion the slice if it crosses the x-axis
	%slice = (
		startAngle	=> $startAngle,
		angle		=> $angle,
		avgAngle	=> $avgAngle,
		stopAngle	=> $stopAngle,
		%sliceData
	);

	my $hopsa = $self->calcCoordinates(\%slice);
	$sliceData{overallStartCorner} = $hopsa->{startCorner};
	$sliceData{overallEndCorner} = $hopsa->{endCorner};
	$sliceData{overallBigCircle} = $hopsa->{bigCircle};
	
	my $leftIntersect = pi;
	my $rightIntersect = $leftIntersect+pi;
	
	if ($startAngle < $leftIntersect) {
		if ($stopAngle > $leftIntersect || $stopAngle < $startAngle) {
			%slice = (
				startAngle	=> $startAngle,
				angle		=> $leftIntersect - $startAngle,
				stopAngle	=> $leftIntersect,
				avgAngle	=> $avgAngle,
				####
				drawStartPlane	=> 1,
				drawStopPlane	=> 0,
				drawTopPlane	=> 1,
				id 		=> scalar(@{$self->{_slices}}),
				%sliceData
			);
			$mainStopDraw = 0;
			$startAngle = $leftIntersect;

			$leftMost = { %slice, %{$self->calcCoordinates(\%slice)} };
			
			push (@{$self->{_slices}}, $leftMost);
		}

		if ($stopAngle < $startAngle) {
			%slice = (
				startAngle	=> $leftIntersect,
				angle		=> pi,
				stopAngle	=> $rightIntersect,
				avgAngle	=> $avgAngle,
				####
				drawStartPlane	=> 0,
				drawStopPlane	=> 0,
				drawTopPlane	=> 0,
				id 		=> scalar(@{$self->{_slices}}),
				%sliceData
			);
			$mainStopDraw = 0;
			$startAngle = 0;

			$center = { %slice, %{$self->calcCoordinates(\%slice)} };
			
			push (@{$self->{_slices}}, $center);
		}

			
		%slice = (
			mainSlice	=> 1,
			startAngle	=> $startAngle,
			angle		=> $stopAngle - $startAngle,
			stopAngle	=> $stopAngle,
			avgAngle	=> $avgAngle,
			####
			drawStartPlane	=> !defined($leftMost->{drawStartPlane}),
			drawStopPlane	=> 1,
			drawTopPlane	=> !$leftMost->{drawTopPlane},
			id 		=> scalar(@{$self->{_slices}}),
			%sliceData
		);
		$mainStopDraw = 0;
		$rightMost = { %slice, %{$self->calcCoordinates(\%slice)} };
	
		push (@{$self->{_slices}}, $rightMost );
	} else {
		if ($stopAngle < $leftIntersect || $stopAngle < $startAngle) {
			%slice = (
				startAngle	=> $startAngle,
				angle		=> $rightIntersect - $startAngle,
				stopAngle	=> $rightIntersect,
				avgAngle	=> $avgAngle,
				####
				drawStartPlane	=> 1,
				drawStopPlane	=> 0,
				drawTopPlane	=> 0,
				id 		=> scalar(@{$self->{_slices}}),
				%sliceData
			);
			$mainStopDraw = 0;
			$startAngle = 0;

			$leftMost = { %slice, %{$self->calcCoordinates(\%slice)} };
			$overallStartCorner = $leftMost->{startCorner};
			
			push (@{$self->{_slices}}, $leftMost);
		}

		if ($stopAngle < $startAngle && $stopAngle > $leftIntersect) {
			%slice = (
				startAngle	=> 0,
				angle		=> pi,
				stopAngle	=> $leftIntersect,
				avgAngle	=> $avgAngle,
				####
				drawStartPlane	=> 0,
				drawStopPlane	=> 0,
				drawTopPlane	=> 0,
				id 		=> scalar(@{$self->{_slices}}),
				%sliceData
			);
			$mainStopDraw = 0;
			$startAngle = $leftIntersect;

			$center = { %slice, %{$self->calcCoordinates(\%slice)} };
			
			push (@{$self->{_slices}}, $center);
		}

			
		%slice = (
			mainSlice	=> 1,
			startAngle	=> $startAngle,
			angle		=> $stopAngle - $startAngle,
			stopAngle	=> $stopAngle,
			avgAngle	=> $avgAngle,
			####
			drawStartPlane	=> !defined($leftMost->{drawStartPlane}),
			drawStopPlane	=> 1,
			drawTopPlane	=> !$leftMost->{drawTopPlane},
			id 		=> scalar(@{$self->{_slices}}),
			%sliceData
		);
		$mainStopDraw = 0;
		$startAngle = $leftIntersect;

		$rightMost = { %slice, %{$self->calcCoordinates(\%slice)} };
		
		push (@{$self->{_slices}}, $rightMost);
	}

}

#-------------------------------------------------------------------
sub calcCoordinates {
	my ($pieHeight, $pieWidth, $offsetX, $offsetY, $coords);
	my $self = shift;
	my $slice = shift;

	$pieHeight = $self->getRadius * cos(2 * pi * $self->getTiltAngle / 360);
	$pieWidth = $self->getRadius;
	
	# Translate the origin from the top corner to the center of the image.
	$offsetX = $self->getXOffset;
	$offsetY = $self->getYOffset;

	$offsetX += ($self->getRadius/($pieWidth+$pieHeight))*$slice->{explosionLength}*cos($slice->{avgAngle});
	$offsetY -= ($pieHeight/($pieWidth+$pieHeight))*$slice->{explosionLength}*sin($slice->{avgAngle});

	$coords->{bigCircle} = ($slice->{angle} > pi) ? '1' : '0';
	$coords->{tip}->{x} = $offsetX;
	$coords->{tip}->{y} = $offsetY;
	$coords->{startCorner}->{x} = $offsetX + $pieWidth*$slice->{scaleFactor}*cos($slice->{startAngle});
	$coords->{startCorner}->{y} = $offsetY - $pieHeight*$slice->{scaleFactor}*sin($slice->{startAngle});
	$coords->{endCorner}->{x} = $offsetX + $pieWidth*$slice->{scaleFactor}*cos($slice->{stopAngle});
	$coords->{endCorner}->{y} = $offsetY - $pieHeight*$slice->{scaleFactor}*sin($slice->{stopAngle});

	return $coords;
}

#-------------------------------------------------------------------
sub configurationForm {
	my $self = shift;
	
	my $i18n = WebGUI::International->new($self->session, 'Image_Graph_Pie');
	
	my $f = WebGUI::HTMLForm->new($self->session);
	$f->trClass('Graph_Pie');
	$f->float(
		-name		=> 'pie_radius',
		-value		=> $self->getRadius,
		-label		=> $i18n->get('radius'),
	);
	$f->float(
		-name		=> 'pie_topHeight',
		-value		=> $self->getTopHeight,
		-label		=> $i18n->get('pie height'),
		-hoverHelp	=> 'Only has effect on 3d pies',
	);
	$f->float(
		-name		=> 'pie_tiltAngle',
		-value		=> $self->getTiltAngle,
		-label		=> $i18n->get('tilt angle'),
	);
	$f->float(
		-name		=> 'pie_startAngle',
		-value		=> $self->getStartAngle,
		-label		=> $i18n->get('start angle'),
	);
	$f->selectBox(
		-name		=> 'pie_pieMode',
		-value		=> [ $self->getPieMode ],
		-label		=> $i18n->get('pie mode'),
		-options	=> {
			normal	=> $i18n->get('normal'),
			stepped	=> $i18n->get('stepped'),
		},
	);
	$f->yesNo(
		-name		=> 'pie_shadedSides',
		-value		=> $self->hasShadedSides,
		-label		=> $i18n->get('shade sides'),
	);
	$f->float(
		-name		=> 'pie_stickLength',
		-value		=> $self->getStickLength,
		-label		=> $i18n->get('stick length'),
	);
	$f->float(
		-name		=> 'pie_stickOffset',
		-value		=> $self->getStickOffset,
		-label		=> $i18n->get('stick offset'),
	);
	$f->color(
		-name		=> 'pie_stickColor',
		-value		=> $self->getStickColor,
		-label		=> $i18n->get('stick color'),
	);
	$f->selectBox(
		-name		=> 'pie_labelPosition',
		-value		=> [ $self->getLabelPosition ],
		-label		=> $i18n->get('label position'),
		-options=> {
			center	=> $i18n->get('center'), 
			top	=> $i18n->get('top'),
			bottom	=> $i18n->get('bottom'),
		},
	);

my	$configForms = $self->SUPER::configurationForm;
	$configForms->{'graph_pie'} = $f->printRowsOnly;

	return $configForms;
}

#-------------------------------------------------------------------
sub draw {
	my ($currentSlice, $coordinates, $sliceData, $leftPlaneVisible, $rightPlaneVisible);
	my $self = shift;

	$self->processDataset;

	# Draw slices in the correct order or you'll get an MC Escher.
	my @slices = sort sortSlices @{$self->{_slices}};
	
	# First draw the bottom planes and the labels behind the chart.
	foreach $sliceData (@slices) {
		# Draw bottom
		$self->drawBottom($sliceData);

		if (_mod2pi($sliceData->{avgAngle}) > 0 && _mod2pi($sliceData->{avgAngle}) <= pi) {
			$self->drawLabel($sliceData);
		}
	}

	# Second draw the sides
	# If angle == 0 do a 2d pie
	if ($self->getTiltAngle != 0) {
		foreach $sliceData (@slices) {  #(sort sortSlices @{$self->{_slices}}) {
			$leftPlaneVisible = (_mod2pi($sliceData->{startAngle}) <= 0.5*pi || _mod2pi($sliceData->{startAngle} >= 1.5*pi));
			$rightPlaneVisible = (_mod2pi($sliceData->{stopAngle}) >= 0.5*pi && _mod2pi($sliceData->{stopAngle} <= 1.5*pi));

			if ($leftPlaneVisible && $rightPlaneVisible) {
				$self->drawRim($sliceData);
				$self->drawRightSide($sliceData);
				$self->drawLeftSide($sliceData);
			} elsif ($leftPlaneVisible && !$rightPlaneVisible) {
				# right plane invisible
				$self->drawRightSide($sliceData);
				$self->drawRim($sliceData);
				$self->drawLeftSide($sliceData);
			} elsif (!$leftPlaneVisible && $rightPlaneVisible) {
				# left plane invisible
				$self->drawLeftSide($sliceData);
				$self->drawRim($sliceData);
				$self->drawRightSide($sliceData);
			} else {
				$self->drawLeftSide($sliceData);
				$self->drawRightSide($sliceData);
				$self->drawRim($sliceData);
			}
		}
	}

	# Finally draw the top planes of each slice and the labels that are in front of the chart.
	foreach $sliceData (@slices) {
		$self->drawTop($sliceData) if ($self->getTiltAngle != 0);

		if (_mod2pi($sliceData->{avgAngle}) > pi) {
			$self->drawLabel($sliceData);
		}
	}
}

#-------------------------------------------------------------------
sub drawBottom {
	my $self = shift;
	my $slice = shift;

	$self->drawPieSlice($slice, -1 * $slice->{bottomHeight}, $slice->{bottomColor})  if ($slice->{drawTopPlane});
}

#-------------------------------------------------------------------
sub drawLabel {
	my ($startRadius, $stopRadius, $pieHeight, $pieWidth, $startPointX, $startPointY, 
		$endPointX, $endPointY);
	my $self = shift;
	my $slice = shift;

	# Draw labels only once
	return unless ($slice->{mainSlice});

	$startRadius = $self->getRadius * $slice->{scaleFactor}+ $self->getStickOffset;
	$stopRadius = $startRadius + $self->getStickLength;

	$pieHeight = $self->getRadius * cos(2 * pi * $self->getTiltAngle / 360);
	$pieWidth = $self->getRadius;

	$startPointX = $self->getXOffset + ($slice->{explosionLength}*$pieWidth/($pieHeight+$pieWidth)+$startRadius) * cos($slice->{avgAngle});
	$startPointY = $self->getYOffset - ($slice->{explosionLength}*$pieHeight/($pieHeight+$pieWidth)+$startRadius) * sin($slice->{avgAngle}) * cos(2 * pi * $self->getTiltAngle / 360);
	$endPointX = $self->getXOffset + ($slice->{explosionLength}*$pieWidth/($pieHeight+$pieWidth)+$stopRadius) * cos($slice->{avgAngle});
	$endPointY = $self->getYOffset - ($slice->{explosionLength}*$pieHeight/($pieHeight+$pieWidth)+$stopRadius) * sin($slice->{avgAngle}) * cos(2 * pi * $self->getTiltAngle / 360);

	if ($self->getTiltAngle) {
		if ($self->getLabelPosition eq 'center') {
			$startPointY -= ($slice->{topHeight} - $slice->{bottomHeight}) / 2;
			$endPointY -= ($slice->{topHeight} - $slice->{bottomHeight}) / 2;
		}
		elsif ($self->getLabelPosition eq 'top') {
			$startPointY -= $slice->{topHeight};
			$endPointY -= $slice->{topHeight};
		}
		elsif ($self->getLabelPosition eq 'bottom') {
			$startPointY += $slice->{bottomHeight};
			$endPointY += $slice->{bottomHeight};
		}

	}

	# Draw the stick
	if ($self->getStickLength){
		$self->image->Draw(
			primitive	=> 'Path',
			stroke		=> $self->getStickColor,
			strokewidth	=> 3,
			points		=> 
				" M $startPointX,$startPointY ".
				" L $endPointX,$endPointY ",
			fill		=> 'none',
		);
	}
	
	# Process the textlabel
	my $horizontalAlign = 'center';
	my $align = 'Center';
	if ($slice->{avgAngle} > 0.5 * pi && $slice->{avgAngle} < 1.5 * pi) {
		$horizontalAlign = 'right';
		$align = 'Right';
	}
	elsif ($slice->{avgAngle} > 1.5 * pi || $slice->{avgAngle} < 0.5 * pi) {
		$horizontalAlign = 'left';
		$align = 'Left';
	}

	my $verticalAlign = 'center';
	$verticalAlign = 'bottom' if ($slice->{avgAngle} == 0.5 * pi);
	$verticalAlign = 'top' if ($slice->{avgAngle} == 1.5 * pi);

	my $anchorX = $endPointX + $self->getLabelOffset;
	$anchorX = $endPointX - $self->getLabelOffset if ($horizontalAlign eq 'right');

	my $text = $slice->{label} || sprintf('%.1f', $slice->{percentage}*100).' %';

	my $maxWidth = $anchorX;
	$maxWidth = $self->getImageWidth - $anchorX if ($slice->{avgAngle} > 1.5 * pi || $slice->{avgAngle} < 0.5 * pi);
	
	$self->SUPER::drawLabel(
		text	 	=> $self->wrapLabelToWidth($text, $maxWidth),
		alignHorizontal	=> $horizontalAlign,
		align		=> $align,
		alignVertical	=> $verticalAlign,
		x		=> $anchorX,
		y		=> $endPointY,
	);
}

#-------------------------------------------------------------------
sub drawLeftSide {
	my $self = shift;
	my $slice = shift;
	
	$self->drawSide($slice) if ($slice->{drawStartPlane});
}

#-------------------------------------------------------------------
sub drawPieSlice {
	my (%tip, %startCorner, %endCorner, $pieWidth, $pieHeight, $bigCircle,
		$strokePath);
	my $self = shift;
	my $slice = shift;
	my $offset = shift || 0;
	my $fillColor = shift;

	%tip = (
		x	=> $slice->{tip}->{x},
		y	=> $slice->{tip}->{y} - $offset,
	);
	%startCorner = (
		x	=> $slice->{overallStartCorner}->{x},
		y	=> $slice->{overallStartCorner}->{y} - $offset,
	);
	%endCorner = (
		x	=> $slice->{overallEndCorner}->{x},
		y	=> $slice->{overallEndCorner}->{y} - $offset,
	);

	$pieWidth = $self->getRadius; 
	$pieHeight = $self->getRadius * cos(2 * pi * $self->getTiltAngle / 360);
	$bigCircle = $slice->{overallBigCircle};

	$self->image->Draw(
		primitive	=> 'Path',
		stroke		=> $slice->{strokeColor},
		points		=> 
			" M $tip{x},$tip{y} ".
			" L $startCorner{x},$startCorner{y} ".
			" A $pieWidth,$pieHeight 0 $bigCircle,0 $endCorner{x},$endCorner{y} ".
			" Z ",
		fill		=> $fillColor,
	);
}

#-------------------------------------------------------------------
sub drawRightSide {
	my $self = shift;
	my $slice = shift;
	
	$self->drawSide($slice, 'endCorner', $slice->{stopPlaneColor}) if ($slice->{drawStopPlane});
}

#-------------------------------------------------------------------
sub drawRim {
	my (%startSideTop, %startSideBottom, %endSideTop, %endSideBottom,
		$pieWidth, $pieHeight, $bigCircle);
	my $self = shift;
	my $slice = shift;
	
	%startSideTop = (
		x	=> $slice->{startCorner}->{x},
		y	=> $slice->{startCorner}->{y} - $slice->{topHeight}
	);
	%startSideBottom = (
		x	=> $slice->{startCorner}->{x},
		y	=> $slice->{startCorner}->{y} + $slice->{bottomHeight}
	);
	%endSideTop = (
		x	=> $slice->{endCorner}->{x},
		y	=> $slice->{endCorner}->{y} - $slice->{topHeight}
	);
	%endSideBottom = (
		x	=> $slice->{endCorner}->{x},
		y	=> $slice->{endCorner}->{y} + $slice->{bottomHeight}
	);
	
	$pieWidth = $self->getRadius;
	$pieHeight = $self->getRadius * cos(2 * pi * $self->getTiltAngle / 360);
	$bigCircle = $slice->{bigCircle};
	
	# Draw curvature
	$self->image->Draw(
		primitive       => 'Path',
		stroke          => $slice->{strokeColor},
		points		=> 
			" M $startSideBottom{x},$startSideBottom{y} ".
			" A $pieWidth,$pieHeight 0 $bigCircle,0 $endSideBottom{x},$endSideBottom{y} ".
			" L $endSideTop{x}, $endSideTop{y} ".
			" A $pieWidth,$pieHeight 0 $bigCircle,1 $startSideTop{x},$startSideTop{y}".
			" Z",
		fill		=> $slice->{rimColor},
	);
}

#-------------------------------------------------------------------
sub drawSide {
	my (%tipTop, %tipBottom, %rimTop, %rimBottom);
	my $self = shift;
	my $slice = shift;
	my $cornerName = shift || 'startCorner';
	my $color = shift || $slice->{startPlaneColor};
	
	%tipTop = (
		x	=> $slice->{tip}->{x},
		y	=> $slice->{tip}->{y} - $slice->{topHeight}
	);
	%tipBottom = (
		x	=> $slice->{tip}->{x},
		y	=> $slice->{tip}->{y} + $slice->{bottomHeight}
	);
	%rimTop = (
		x	=> $slice->{$cornerName}->{x},
		y	=> $slice->{$cornerName}->{y} - $slice->{topHeight}
	);
	%rimBottom = (
		x	=> $slice->{$cornerName}->{x},
		y	=> $slice->{$cornerName}->{y} + $slice->{bottomHeight}
	);

	$self->image->Draw(
		primitive       => 'Path',
		stroke          => $slice->{strokeColor},
		points		=> 
			" M $tipBottom{x},$tipBottom{y} ". 
			" L $rimBottom{x},$rimBottom{y} ".
			" L $rimTop{x},$rimTop{y} ".
			" L $tipTop{x},$tipTop{y} ".
			" Z ",
		fill		=> $color,
	);
}

#-------------------------------------------------------------------
sub drawTop {
	my $self = shift;
	my $slice = shift;

	$self->drawPieSlice($slice, $slice->{topHeight}, $slice->{topColor}) if ($slice->{drawTopPlane});
}

#-------------------------------------------------------------------
sub formNamespace {
	my $self = shift;

	return $self->SUPER::formNamespace.'_Pie';
}

#-------------------------------------------------------------------
sub getBottomHeight {
	my $self = shift;

	return $self->{_pieProperties}->{bottomHeight} || 0;
}

#-------------------------------------------------------------------
sub getConfiguration {
	my $self = shift;

	my $config = $self->SUPER::getConfiguration;

	$config->{pie_radius}		= $self->getRadius;
	$config->{pie_tiltAngle}	= $self->getTiltAngle;
	$config->{pie_startAngle}	= $self->getStartAngle;
	$config->{pie_shadedSides}	= $self->hasShadedSides;
	$config->{pie_topHeight}	= $self->getTopHeight;
	$config->{pie_stickLength}	= $self->getStickLength;
	$config->{pie_stickOffset}	= $self->getStickOffset;
	$config->{pie_stickColor}	= $self->getStickColor;
	$config->{pie_labelPosition}	= $self->getLabelPosition;
	$config->{pie_pieMode}		= $self->getPieMode;	
	return $config;
}

#-------------------------------------------------------------------
sub getDataset {
	my $self = shift;

	return $self->SUPER::getDataset(0);
}

#-------------------------------------------------------------------
sub getExplosionLength {
	my $self = shift;

	return $self->{_pieProperties}->{explosionLength} || 0;
}

#-------------------------------------------------------------------
sub getLabels {
	my $self = shift;

	return $self->{_labels}->{data};
}

#-------------------------------------------------------------------
sub getLabelPosition {
	my $self = shift;

	return $self->{_pieProperties}->{labelPosition} || 'top';
}

#-------------------------------------------------------------------
sub getPieMode {
	my $self = shift;

	return $self->{_pieProperties}->{pieMode} || 'normal';
}

#-------------------------------------------------------------------
sub getRadius {
	my $self = shift;

	return $self->{_pieProperties}->{radius} || 80;
}

#-------------------------------------------------------------------
sub getScaleFactor {
	my $self = shift;

	return $self->{_pieProperties}->{scaleFactor} || 1;
}

#-------------------------------------------------------------------
sub getSlice {
	my $self = shift;
	my $slice = shift || (scalar(@{$self->{_slices}}) - 1);

	return $self->{_slices}->[$slice];
}

#-------------------------------------------------------------------
sub getStartAngle {
	my $self = shift;

	return $self->{_pieProperties}->{startAngle} || 0;
}

#-------------------------------------------------------------------
sub getStickColor {
	my $self = shift;

	return $self->{_pieProperties}->{stickColor} || '#333333';
}

#-------------------------------------------------------------------
sub getStickLength {
	my $self = shift;

	return $self->{_pieProperties}->{stickLength} || 0;
}

#-------------------------------------------------------------------
sub getStickOffset {
	my $self = shift;

	return $self->{_pieProperties}->{stickOffset} || 0;
}

#-------------------------------------------------------------------
sub getTiltAngle {
	my $self = shift;
	my $angle = shift;

	return $self->{_pieProperties}->{tiltAngle} || 55;
}

#-------------------------------------------------------------------
sub getTopHeight {
	my $self = shift;

	return $self->{_pieProperties}->{topHeight} || 20;
}

#-------------------------------------------------------------------
sub hasShadedSides {
	my $self = shift;

	return $self->{_pieProperties}->{shadedSides} || '0';
}

#-------------------------------------------------------------------
sub new {
	my $class = shift;
	
	my $self = $class->SUPER::new(@_);
	$self->{_slices} = [];

	return $self;
}

#-------------------------------------------------------------------
sub processDataset {
	my $self = shift;
	my $total = 0;
	foreach (@{$self->getDataset}) {
		$total += $_;
	}

	my $dataIndex = 0;

	my $stepsize = ($self->getTopHeight + $self->getBottomHeight) / scalar(@{$self->getDataset});
	foreach (@{$self->getDataset}) {
		$dataIndex;

		$self->addSlice({
			percentage	=> $_ / $total, 
			label		=> $self->getLabel($dataIndex),
			color		=> $self->getPalette->getNextColor,
		}) if ($_);
		
		$self->setTopHeight($self->getTopHeight - $stepsize) if ($self->getPieMode eq 'stepped');

		$dataIndex++;
	}
}

#-------------------------------------------------------------------
sub setBottomHeight {
	my $self = shift;
	my $height = shift;

	$self->{_pieProperties}->{bottomHeight} = $height;
}

#-------------------------------------------------------------------
sub setCenter {
	my $self = shift;
	my $xCenter = shift || 0;
	my $yCenter = shift || 0;

	$self->{_pieProperties}->{xOffset} = $xCenter;
	$self->{_pieProperties}->{yOffset} = $yCenter;
}

#-------------------------------------------------------------------
sub setConfiguration {
	my $self = shift;
	my $config = shift;

	$self->SUPER::setConfiguration($config);

	$self->setRadius($config->{pie_radius});
	$self->setTiltAngle($config->{pie_tiltAngle});
	$self->setStartAngle($config->{pie_startAngle});
	$self->setShadedSides($config->{pie_shadedSides});
	$self->setTopHeight($config->{pie_topHeight});
	$self->setStickLength($config->{pie_stickLength});
	$self->setStickOffset($config->{pie_stickOffset});
	$self->setStickColor($config->{pie_stickColor});
	$self->setLabelPosition($config->{pie_labelPosition});
	$self->setPieMode($config->{pie_pieMode});
	
	return $config;
}

#-------------------------------------------------------------------
sub setExplosionLength {
	my $self = shift;
	my $offset = shift;

	$self->{_pieProperties}->{explosionLength} = $offset;
}

#-------------------------------------------------------------------
sub setLabelPosition {
	my $self = shift;
	my $position = shift;
	
	$self->{_pieProperties}->{labelPosition} = $position;
}

#-------------------------------------------------------------------
sub setPieMode {
	my $self = shift;
	my $mode = shift;
	
	$self->{_pieProperties}->{pieMode} = $mode;
}

#-------------------------------------------------------------------
sub setRadius {
	my $self = shift;
	my $radius = shift;
	my $innerRadius = shift;

	$self->{_pieProperties}->{radius} = $radius;
	$self->{_pieProperties}->{innerRadius} = $innerRadius;
}

#-------------------------------------------------------------------
sub setStartAngle {
	my $self = shift;
	my $angle = shift;

	$self->{_pieProperties}->{startAngle} = $angle;
}

#-------------------------------------------------------------------
sub setShadedSides {
	my $self = shift;
	my $onOff = shift;

	$self->{_pieProperties}->{shadedSides} = $onOff;
}

#-------------------------------------------------------------------
sub setStickColor {
	my $self = shift;
	my $color = shift;

	$self->{_pieProperties}->{stickColor} = $color;
}

#-------------------------------------------------------------------
sub setStickLength {
	my $self = shift;
	my $length = shift;

	$self->{_pieProperties}->{stickLength} = $length;
}

#-------------------------------------------------------------------
sub setStickOffset {
	my $self = shift;
	my $offset = shift || 0;

	$self->{_pieProperties}->{stickOffset} = $offset;
}

#-------------------------------------------------------------------
sub setTiltAngle {
	my $self = shift;
	my $angle = shift;

	$angle = 0 if ($angle < 0);
	$angle = 90 if ($angle > 90);

	$self->{_pieProperties}->{tiltAngle} = $angle;
}

#-------------------------------------------------------------------
sub setTopHeight {
	my $self = shift;
	my $height = shift;

	$self->{_pieProperties}->{topHeight} = $height;
}

#-------------------------------------------------------------------
sub sortSlices {
	my ($startA, $stopA, $startB, $stopB, $distA, $distB);
	my $self = shift;

	my $aStartAngle = $a->{startAngle};
	my $aStopAngle = $a->{stopAngle};
	my $bStartAngle = $b->{startAngle};
	my $bStopAngle = $b->{stopAngle};

	# If sliceA and sliceB are in different halfplanes sorting is easy...
	return -1 if ($aStartAngle < pi && $bStartAngle >= pi);
	return 1 if ($aStartAngle >= pi && $bStartAngle < pi);

	if ($aStartAngle < pi) {
		if ($aStopAngle <= 0.5*pi && $bStopAngle <= 0.5* pi) {
			# A and B in quadrant I
			return 1 if ($aStartAngle < $bStartAngle);
			return -1;
		} elsif ($aStartAngle >= 0.5*pi && $bStartAngle >= 0.5*pi) {
			# A and B in quadrant II
			return 1 if ($aStartAngle > $bStartAngle);
			return -1;
		} elsif ($aStartAngle < 0.5*pi && $aStopAngle >= 0.5*pi) {
			# A in both quadrant I and II
			return -1;
		} else {
			# B in both quadrant I and II
			return 1;
		}
	} else {
		if ($aStopAngle <= 1.5*pi && $bStopAngle <= 1.5*pi) {
			# A and B in quadrant III
			return 1 if ($aStopAngle > $bStopAngle);
			return -1;
		} elsif ($aStartAngle >= 1.5*pi && $bStartAngle >= 1.5*pi) {
			# A and B in quadrant IV
			return 1 if ($aStartAngle < $bStartAngle);
			return -1;
		} elsif ($aStartAngle <= 1.5*pi && $aStopAngle >= 1.5*pi) {
			# A in both quadrant III and IV
			return 1;
		} else {
			# B in both quadrant III and IV
			return -1;
		}
	}
	
	return 0;
}

1;

