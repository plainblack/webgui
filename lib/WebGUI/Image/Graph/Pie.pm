package WebGUI::Image::Graph::Pie;

use strict;
use WebGUI::Image::Graph;
use constant pi => 3.14159265358979;

our @ISA = qw(WebGUI::Image::Graph);

=head1 NAME

Package WebGUI::Image::Graph::Pie

=head1 DESCRIPTION

Package to create pie charts, both 2d and 3d.

=head1 SYNOPSIS

Pie charts have a top height, bottom height which are the amounts of pixels the
top and bottom rise above and below the z = 0 plane respectively. These
properties can be used to create stepping effect.

Also xeplosion and scaling of individual pie slices is possible. Labels can be
connected via sticks and aligned to top, bottom and center of the pie.

The package automatically desides whether to draw in 2d or 3d mode based on the
angle by which the pie is tilted.

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 _mod2pi ( angle )

Returns the angle modulo 2*pi.

=head3 angle

The angle you want the modulo of.

=cut

sub _mod2pi {
	my $angle = shift;

	if ($angle < 0) {
#		return 2*pi + $angle - 2*pi*int($angle/(2*pi));
	} else {
		return $angle - 2*pi*int($angle/(2*pi));
	}
}

#-------------------------------------------------------------------

=head2 addSlice ( $properties )

Add 1 slice to the pie graph.

=head3 $properties

Properties that define the slice.

=head4 percentage

The percentage of the pie this slice should occupy.

=head4 label

A label for the slice.

=head4 color

The color to use to draw the slice.

=cut

sub addSlice {
	my (%slice, $leftMost, $rightMost, $center, $overallStartCorner, $overallEndCorner, 
		$fillColor, $strokeColor, $sideColor);
	my $self = shift;
	my $properties = shift;

	my $percentage = $properties->{percentage};

	# Work around a bug in imagemagick where an A path with the same start and end point will segfault.
	if ($percentage == 1) { 
		$percentage = 0.99999;
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

=head2 calcCoordinates ( slice )

Calcs the coordinates of the corners of the given pie slice.

=head3 slice

Hashref containing the information that defines the slice. Must be formatted
like the slices built by addSlice.

=cut

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

=head2 configurationForm ( )

The configuration form part for this object. See WebGUI::Image::Graph for
documentation.

=cut

sub configurationForm {
	my $self = shift;
	
	my $i18n = WebGUI::International->new($self->session, 'Image_Graph_Pie');
	
	my $f = WebGUI::HTMLForm->new($self->session);
	$f->trClass('Graph_Pie');
	$f->float(
		-name		=> 'pie_radius',
		-value		=> $self->getRadius,
		-label		=> $i18n->get('radius'),
		-hoverHelp	=> $i18n->get('radius description'),
	);
	$f->float(
		-name		=> 'pie_topHeight',
		-value		=> $self->getTopHeight,
		-label		=> $i18n->get('pie height'),
		-hoverHelp	=> $i18n->get('pie height description'),
	);
	$f->float(
		-name		=> 'pie_tiltAngle',
		-value		=> $self->getTiltAngle,
		-label		=> $i18n->get('tilt angle'),
		-hoverHelp	=> $i18n->get('tilt angle description'),
	);
	$f->float(
		-name		=> 'pie_startAngle',
		-value		=> $self->getStartAngle,
		-label		=> $i18n->get('start angle'),
		-hoverHelp	=> $i18n->get('start angle description'),
	);
	$f->selectBox(
		-name		=> 'pie_pieMode',
		-value		=> [ $self->getPieMode ],
		-label		=> $i18n->get('pie mode'),
		-hoverHelp	=> $i18n->get('pie mode description'),
		-options	=> {
			normal	=> $i18n->get('normal'),
			stepped	=> $i18n->get('stepped'),
		},
	);
	$f->yesNo(
		-name		=> 'pie_shadedSides',
		-value		=> $self->hasShadedSides,
		-label		=> $i18n->get('shade sides'),
		-hoverHelp	=> $i18n->get('shade sides description'),
	);
	$f->float(
		-name		=> 'pie_stickLength',
		-value		=> $self->getStickLength,
		-label		=> $i18n->get('stick length'),
		-hoverHelp	=> $i18n->get('stick length description'),
	);
	$f->float(
		-name		=> 'pie_stickOffset',
		-value		=> $self->getStickOffset,
		-label		=> $i18n->get('stick offset'),
		-hoverHelp	=> $i18n->get('stick offset description'),
	);
	$f->color(
		-name		=> 'pie_stickColor',
		-value		=> $self->getStickColor,
		-label		=> $i18n->get('stick color'),
		-hoverHelp	=> $i18n->get('stick color description'),
	);
	$f->selectBox(
		-name		=> 'pie_labelPosition',
		-value		=> [ $self->getLabelPosition ],
		-label		=> $i18n->get('label position'),
		-hoverHelp	=> $i18n->get('label position description'),	
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

=head2 draw ( )

Draws the pie chart.

=cut

sub draw {
	my ($currentSlice, $coordinates, $leftPlaneVisible, $rightPlaneVisible);
	my $self = shift;
	
	$self->processDataset;

	# Draw slices in the correct order or you'll get an MC Escher.
	my @slices = sort sortSlices @{$self->{_slices}};
	
	# First draw the bottom planes and the labels behind the chart.
	foreach my $sliceData (@slices) {
		# Draw bottom
		$self->drawBottom($sliceData);

		if (_mod2pi($sliceData->{avgAngle}) > 0 && _mod2pi($sliceData->{avgAngle}) <= pi) {
			$self->drawLabel($sliceData);
		}
	}

	# Second draw the sides
	# If angle == 0 do a 2d pie
	if ($self->getTiltAngle != 0) {
		foreach my $sliceData (@slices) {  #(sort sortSlices @{$self->{_slices}}) {
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
	foreach my $sliceData (@slices) {
		$self->drawTop($sliceData) if ($self->getTiltAngle != 0);

		if (_mod2pi($sliceData->{avgAngle}) > pi) {
			$self->drawLabel($sliceData);
		}
	}
}

#-------------------------------------------------------------------

=head2 drawBottom ( slice )

Draws the bottom of the given pie slice.

=head3 slice

A slice hashref. See addSlice for more information.

=cut

sub drawBottom {
	my $self = shift;
	my $slice = shift;

	$self->drawPieSlice($slice, -1 * $slice->{bottomHeight}, $slice->{bottomColor})  if ($slice->{drawTopPlane});
}

#-------------------------------------------------------------------

=head2 drawLabel ( slice )

Draws the label including stick if needed for the given pie slice.

=head3 slice

A slice properties hashref.

=cut

sub drawLabel {
	my ($startRadius, $stopRadius, $pieHeight, $pieWidth, $startPointX, $startPointY, 
		$endPointX, $endPointY);
	my $self = shift;
	my $slice = shift;

	# Draw labels only once
	return undef unless ($slice->{mainSlice});

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
	
	$self->SUPER::drawLabel($self->wrapLabelToWidth($text, $maxWidth), (
		alignHorizontal	=> $horizontalAlign,
		align		=> $align,
		alignVertical	=> $verticalAlign,
		x		=> $anchorX,
		y		=> $endPointY,
	));
}

#-------------------------------------------------------------------

=head2 drawLeftSide ( slice )

Draws the side connected to the startpoint of the slice.

=head3 slice

A slice properties hashref.

=cut

sub drawLeftSide {
	my $self = shift;
	my $slice = shift;
	
	$self->drawSide($slice) if ($slice->{drawStartPlane});
}

#-------------------------------------------------------------------

=head2 drawPieSlice ( slice, offset, fillColor )

Draws a pie slice shape, ie. the bottom or top of a slice.

=head3 slice

A slice properties hashref.

=head3 offset

The offset in pixels for the y-direction. This is used to create the thickness
of the pie.

=head3 fillColor

The color with which the slice should be filled.

=cut

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

=head2 drawRightSide ( slice )

Draws the side connected to the endpoint of the slice.

=head3 slice

A slice properties hashref.

=cut

sub drawRightSide {
	my $self = shift;
	my $slice = shift;
	
	$self->drawSide($slice, 'endCorner', $slice->{stopPlaneColor}) if ($slice->{drawStopPlane});
}

#-------------------------------------------------------------------

=head2 drawRim ( slice )

Draws the rim of the slice.

=head3 slice

A slice properties hashref.

=cut

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

=head2 drawSide ( slice, [ cornerName ], [ fillColor ] )

Draws the sides connecting the rim and tip of a pie slice.

=head3 slice

A slice properties hashref.

=head3 cornerName

Specifies which side you want to draw, identified by the name of the corner that
attaches it to the rim. Can be either 'startCorner' or 'endCorner'. If ommitted
it will default to 'startCorner'.

=head3 fillColor

The color with which the side should be filled. If not passed the color for the
'startCorner' side will be defaulted to.

=cut

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

=head2 drawTop ( slice )

Draws the top of the given pie slice.

=head3 slice

A slice hashref. See addSlice for more information.

=cut

sub drawTop {
	my $self = shift;
	my $slice = shift;

	$self->drawPieSlice($slice, $slice->{topHeight}, $slice->{topColor}) if ($slice->{drawTopPlane});
}

#-------------------------------------------------------------------

=head2 formNamespace ( )

Extends the form namespace for this object. See WebGUI::Image::Graph for
documentation.

=cut

sub formNamespace {
	my $self = shift;

	return $self->SUPER::formNamespace.'_Pie';
}

#-------------------------------------------------------------------

=head2 getBottomHeight ( )

Returns the thickness of the bottom. Defaults to 0.

=cut

sub getBottomHeight {
	my $self = shift;

	return $self->{_pieProperties}->{bottomHeight} || 0;
}

#-------------------------------------------------------------------

=head2 getConfiguration ( )

Returns a configuration hashref. See WebGUI::Image::Graph for documentation.

=cut

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

=head2 getDataset ( )

Returns the first dataset that is added. Pie charts can only handle one dataset
and therefore the first added dataset is used.

=cut

sub getDataset {
	my $self = shift;

	return $self->SUPER::getDataset(0);
}

#-------------------------------------------------------------------

=head2 getExplosionLength ( )

Returns the explosion length. This value indicates how much a slice will be
shifted from the center of the pie. Defaults to 0.

=cut

sub getExplosionLength {
	my $self = shift;

	return $self->{_pieProperties}->{explosionLength} || 0;
}

#-------------------------------------------------------------------

=head2 getLabels ( )

Returns an arrayref containing the labels that belong to the slices.

=cut

sub getLabels {
	my $self = shift;

	return $self->{_labels}->{data};
}

#-------------------------------------------------------------------

=head2 getLabelPosition ( )

Returns the position of the labels relative to the thickness of the pie.
Allowed positions are 'bottom', 'center' and 'top'. Defaults to 'top'.

=cut

sub getLabelPosition {
	my $self = shift;

	return $self->{_pieProperties}->{labelPosition} || 'top';
}

#-------------------------------------------------------------------

=head2 getPieMode ( )

Returns the mode in which the pie is drawn. Currently available are 'normal' and
'stepped'. The latter mode draws each pie slice with a smaller thickness,
creating a stairs like pie chart. Defaults to 'normal' which will cause the
graph to be drawn as a vanilla pie chart.

=cut

sub getPieMode {
	my $self = shift;

	return $self->{_pieProperties}->{pieMode} || 'normal';
}

#-------------------------------------------------------------------

=head2 getRadius ( )

Returns the radius of the pie in pixels. Defaults to 80.

=cut

sub getRadius {
	my $self = shift;

	return $self->{_pieProperties}->{radius} || 80;
}

#-------------------------------------------------------------------

=head2 getScaleFactor ( )

Returns the factor with which the pies that are added afterwards should be
scaled. In effect this will cause the radius of the slice to grow or shrink, and
thus make slices stick out. 

Defaults to 1.

=cut

sub getScaleFactor {
	my $self = shift;

	return $self->{_pieProperties}->{scaleFactor} || '1';
}

#-------------------------------------------------------------------

=head2 getSlice ( [ sliceNumber ] )

Returns the sliceNumber'th slice properties hashref. Defaults to the slice last
added.

=head3 sliceNumber

The index of the slice you want.

=cut

sub getSlice {
	my $self = shift;
	my $slice = shift || (scalar(@{$self->{_slices}}) - 1);

	return $self->{_slices}->[$slice];
}

#-------------------------------------------------------------------

=head2 getStartAngle ( )

Rteurn the initial angle of the first slice. In effect all slices are rotated by
this value.

=cut

sub getStartAngle {
	my $self = shift;

	return $self->{_pieProperties}->{startAngle} || 0;
}

#-------------------------------------------------------------------

=head2 getStickColor ( )

Returns the color of the sticks connecting pie and labels. Defaults to #333333.

=cut

sub getStickColor {
	my $self = shift;

	return $self->{_pieProperties}->{stickColor} || '#333333';
}

#-------------------------------------------------------------------

=head2 getStickLength ( )

Return the length of the sticks connecting the labels with the pie. Defaults to
0.

=cut

sub getStickLength {
	my $self = shift;

	return $self->{_pieProperties}->{stickLength} || 0;
}

#-------------------------------------------------------------------

=head2 getStickOffset ( )

Returns the distance between the label sticks and the pie. Defaults to 0.

=cut

sub getStickOffset {
	my $self = shift;

	return $self->{_pieProperties}->{stickOffset} || 0;
}

#-------------------------------------------------------------------

=head2 getTiltAngle ( )

Returns the angle between the screen and the pie chart. Valid angles are 0 to 90
degrees. Zero degrees results in a 2d pie where other values will generate a 3d
pie chart. Defaults to 55 degrees.

=cut

sub getTiltAngle {
	my $self = shift;
	my $angle = shift;

	return 55 unless (defined $self->{_pieProperties}->{tiltAngle});
	return $self->{_pieProperties}->{tiltAngle};
}

#-------------------------------------------------------------------

=head2 getTopHeight ( )

Returns the thickness of the top of the pie in pixels. Defaults to 20 pixels.

=cut

sub getTopHeight {
	my $self = shift;

	return 20 unless (defined $self->{_pieProperties}->{topHeight});
	return $self->{_pieProperties}->{topHeight};
}

#-------------------------------------------------------------------

=head2 hasShadedSides ( )

A boolean value indicating whether the sides and the rim of the pie should be
drawn with a darkened color.

=cut

sub hasShadedSides {
	my $self = shift;

	return $self->{_pieProperties}->{shadedSides} || '0';
}

#-------------------------------------------------------------------

=head2 new ( )

Contstructor. See SUPER classes for additional parameters.

=cut

sub new {
	my $class = shift;
	
	my $self = $class->SUPER::new(@_);
	$self->{_slices} = [];

	return $self;
}

#-------------------------------------------------------------------

=head2 processDataset ( )

Takes the dataset and takes the necesarry steps for the pie to be drawn.

=cut

sub processDataset {
	my $self = shift;
	my $total = 0;
	foreach (@{$self->getDataset}) {
		$total += $_;
	}

	my $dataIndex = 0;
    my $divisor = scalar(@{$self->getDataset}) || 1; # avoid division by zero
	my $stepsize = ($self->getTopHeight + $self->getBottomHeight) / $divisor;
	foreach (@{$self->getDataset}) {
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

=head2 setBottomHeight ( thickness )

Sets the thickness of the bottom.

=head3 thickness

The thickness of the bottom.

=cut

sub setBottomHeight {
	my $self = shift;
	my $height = shift;

	$self->{_pieProperties}->{bottomHeight} = $height;
}

#-------------------------------------------------------------------

=head2 setCenter( [ xOffset ], [ yOffset ] )

Sets the offset of the center of the graph relative to the center of the image.

=head3 xOffset

The offset in the x direction. Defaults to 0.

=head3 yOffset

The offset in the y direction. Defaults to 0.

=cut

sub setCenter {
	my $self = shift;
	my $xCenter = shift || 0;
	my $yCenter = shift || 0;

	$self->{_pieProperties}->{xOffset} = $xCenter;
	$self->{_pieProperties}->{yOffset} = $yCenter;
}

#-------------------------------------------------------------------

=head2 setConfiguration ( config )

Applies the settings in the given configuration hash. See WebGUI::Image::Graph
for more information.

=head2 config

A configuration hash.

=cut

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

=head2 setExplosionLength ( length )

Sets the explosion length. This value indicates how much a slice will be
shifted from the center of the pie. Defaults to 0.

=head3 length

The amount by which the slices should be exploded.

=cut

sub setExplosionLength {
	my $self = shift;
	my $offset = shift;

	$self->{_pieProperties}->{explosionLength} = $offset;
}

#-------------------------------------------------------------------

=head2 setLabelPosition ( position )

Sets the position of the labels relative to the thickness of the pie.
Allowed positions are 'bottom', 'center' and 'top'. Defaults to 'top'.

=head3 position

The position of the labels.

=cut

sub setLabelPosition {
	my $self = shift;
	my $position = shift;
	
	$self->{_pieProperties}->{labelPosition} = $position;
}

#-------------------------------------------------------------------

=head2 setPieMode ( mode )

Sets the mode in which the pie is drawn. Currently available are 'normal' and
'stepped'. The latter mode draws each pie slice with a smaller thickness,
creating a stairs like pie chart. Defaults to 'normal' which will cause the
graph to be drawn as a vanilla pie chart.

=head3 mode

The mode. Either 'normal' or 'stepped'.

=cut

sub setPieMode {
	my $self = shift;
	my $mode = shift;
	
	$self->{_pieProperties}->{pieMode} = $mode;
}

#-------------------------------------------------------------------

=head2 setRadius ( radius )

Sets the radius of the pie in pixels. Defaults to 80.

=head3 radius

The desired radius.

=cut

sub setRadius {
	my $self = shift;
	my $radius = shift;
	my $innerRadius = shift;

	$self->{_pieProperties}->{radius} = $radius;
	$self->{_pieProperties}->{innerRadius} = $innerRadius;
}

#-------------------------------------------------------------------

=head2 setScaleFactor ( multiplier )

Sets the factor with which the pies that are added afterwards should be
scaled. In effect this will cause the radius of the slice to grow or shrink, and
thus make slices stick out. 

Defaults to 1.

=head3 multiplier

The figure with which the the normal radius if the slices should be multiplied. 

=cut

sub setScaleFactor {
	my $self = shift;
	my $scaleFactor = shift;
	
	$self->{_pieProperties}->{scaleFactor} = $scaleFactor;
}

#-------------------------------------------------------------------

=head2 setStartAngle ( angle )

Sets the initial angle of the first slice. In effect all slices are rotated by
this value.

=head3 angle

The desired start angle in degrees.

=cut

sub setStartAngle {
	my $self = shift;
	my $angle = shift;

	$self->{_pieProperties}->{startAngle} = $angle;
}

#-------------------------------------------------------------------

=head2 setShadedSides ( shaded )

A boolean value indicating whether the sides and the rim of the pie should be
drawn with a darkened color.

=head3 shaded

The boolean switch. Set to 0 for normal sides. Set to 1 for shaded sides.

=cut

sub setShadedSides {
	my $self = shift;
	my $onOff = shift;

	$self->{_pieProperties}->{shadedSides} = $onOff;
}

#-------------------------------------------------------------------

=head2 setStickColor ( color )

Sets the color of the sticks connecting pie and labels. Defaults to #333333.

=head3 color

The desired color value.

=cut

sub setStickColor {
	my $self = shift;
	my $color = shift;

	$self->{_pieProperties}->{stickColor} = $color;
}

#-------------------------------------------------------------------

=head2 setStickLength ( length )

Sets the length of the sticks connecting the labels with the pie. Defaults to
0.

=head3 length

The length in pixels.

=cut

sub setStickLength {
	my $self = shift;
	my $length = shift;

	$self->{_pieProperties}->{stickLength} = $length;
}

#-------------------------------------------------------------------

=head2 setStickOffset ( offset )

Sets the distance between the label sticks and the pie. Defaults to 0.

=head3 offset

The distance in pixels.

=cut

sub setStickOffset {
	my $self = shift;
	my $offset = shift || 0;

	$self->{_pieProperties}->{stickOffset} = $offset;
}

#-------------------------------------------------------------------

=head2 setTiltAngle ( angle )

Sets the angle between the screen and the pie chart. Valid angles are 0 to 90
degrees. Zero degrees results in a 2d pie where other values will generate a 3d
pie chart. Defaults to 55 degrees.

=head3 angle

The tilt angle. Must be in the range from  0 to 90. If a value less than zero is
passed the angle will be set to 0. If a value greater than 90 is passed the
angle will be set to 90.

=cut

sub setTiltAngle {
	my $self = shift;
	my $angle = shift;

	$angle = 0 if ($angle < 0);
	$angle = 90 if ($angle > 90);

	$self->{_pieProperties}->{tiltAngle} = $angle;
}

#-------------------------------------------------------------------

=head2 setTopHeight ( thickness )

Sets the thickness of the top of the pie in pixels. Defaults to 20 pixels.

=head3 thickness

The thickness of the top in pixels.

=cut

sub setTopHeight {
	my $self = shift;
	my $height = shift;

	$self->{_pieProperties}->{topHeight} = $height;
}

#-------------------------------------------------------------------

=head2 sortSlices

A sort routine for sorting the slices in drawing order. Must be run from within
the sort command.

=cut

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

