package WebGUI::Image::Color;

use strict;
use Color::Calc;

#-------------------------------------------------------------------
sub canDelete {
	my $self = shift;
	
	return 1;
}

#-------------------------------------------------------------------
sub copy {
	my $self = shift;

	return WebGUI::Image::Color->new($self->session, 'new', {%{$self->{_properties}}});
}

#-------------------------------------------------------------------
sub darken {
	my $self = shift;
	
	my $newColor = $self->copy;

	my $c = Color::Calc->new(OutputFormat => 'hex');
	
	$newColor->setFillTriplet('#'.$c->dark($self->getFillTriplet));
	$newColor->setStrokeTriplet('#'.$c->dark($self->getStrokeTriplet));

	return $newColor;
}

#-------------------------------------------------------------------
sub delete {
	my $self = shift;
	if ($self->canDelete) {
		$self->session->db->write('delete from imageColor where colorId=?', [
			$self->getId,
		]);
	}
}

#-------------------------------------------------------------------
sub getFillColor {
	my $self = shift;
	
	return $self->getFillTriplet.$self->getFillAlpha;
}

#-------------------------------------------------------------------
sub getFillTriplet {
	my $self = shift;

	return $self->{_properties}->{fillTriplet};
}

#-------------------------------------------------------------------
sub getFillAlpha {
	my $self = shift;

	return $self->{_properties}->{fillAlpha};
}

#-------------------------------------------------------------------
sub getId {
	my $self = shift;

	return $self->{_properties}->{colorId};
}

#-------------------------------------------------------------------
sub getName {
	my $self = shift;

	return $self->{_properties}->{name};
}

#-------------------------------------------------------------------
sub getStrokeColor {
	my $self = shift;
	
	return $self->getStrokeTriplet.$self->getStrokeAlpha;
}

#-------------------------------------------------------------------
sub getStrokeTriplet {
	my $self = shift;

	return $self->{_properties}->{strokeTriplet};
}

#-------------------------------------------------------------------
sub getStrokeAlpha {
	my $self = shift;

	return $self->{_properties}->{strokeAlpha};
}

#-------------------------------------------------------------------
sub new {
	my $class = shift;
	my $session = shift;
	my $colorId = shift;
	my $properties = shift;

	if ($colorId eq 'new') {
		unless (defined $properties) {
			$properties = { 
				name 		=> 'untitled', 
				fillTriplet 	=> '#000000',
				fillAlpha 	=> '00',
				strokeTriplet	=> '#000000', 
				strokeAlpha	=> '00',
			};
		}
		$properties->{colorId} = 'new';
	} elsif (!defined $properties) {
		$properties = $session->db->quickHashRef('select * from imageColor where colorId=?', [$colorId]);
	}
		
	bless {_properties => $properties, _session => $session}, $class;
}

#-------------------------------------------------------------------
sub newByPalette {
	my ($sth, $row, @colors);
	my $class = shift;
	my $session = shift;
	my $paletteId = shift;

	my $sth = $session->db->read('select imageColor.* from imageColor, imagePaletteColors where '.
		' imageColor.colorId=imagePaletteColors.colorId and paletteId=?', [
		$paletteId
	]);

	while ($row = $sth->hashRef) {
		push(@colors, WebGUI::Image::Color->new($session, $row->{colorId}, $row));
	}
	
	return \@colors;
}

#-------------------------------------------------------------------
sub session {
	my $self = shift;

	return $self->{_session};
}

#-------------------------------------------------------------------
sub setFillColor {
	my $self = shift;
	my $color = shift;

	if ($color =~ m/^(#[\da-f]{6})([\da-f]{2})?$/i) {
		$self->setFillTriplet($1);
		$self->setFillAlpha($2 || '00');
	} else {
		$self->session->errorHandler->fatal("Invalid fill color: ($color)");
	}
}

#-------------------------------------------------------------------
sub setFillTriplet {
	my $self = shift;
	my $triplet = shift;
	
	if ($triplet =~ m/^#[\da-f]{6}$/i) {
		$self->{_properties}->{fillTriplet} = $triplet;
		$self->update;
	} else {
		$self->session->errorHandler->fatal("Invalid fill triplet: ($triplet)");
	}
}

#-------------------------------------------------------------------
sub setFillAlpha {
	my $self = shift;
	my $alpha = shift;

	if ($alpha =~ m/^[\da-f]{2}$/i) {
		$self->{_properties}->{fillAlpha} = $alpha;
		$self->update;
	} else {
		$self->session->errorHandler->fatal("Invalid fill alpha: ($alpha)");
	}
}

#-------------------------------------------------------------------
sub setName {
	my $self = shift;
	my $name = shift;
	
	$self->{_properties}->{name} = $name;
	$self->update;
}

#-------------------------------------------------------------------
sub setStrokeColor {
	my $self = shift;
	my $color = shift;

	if ($color =~ m/^(#[\da-f]{6})([\da-f]{2})?$/i) {
		$self->setStrokeTriplet($1);
		$self->setStrokeAlpha($2 || '00');
	} else {
		$self->session->errorHandler->fatal("Invalid stroke color: ($color)");
	}
}

#-------------------------------------------------------------------
sub setStrokeTriplet {
	my $self = shift;
	my $triplet = shift;
	
	if ($triplet =~ m/^#[\da-f]{6}$/i) {
		$self->{_properties}->{strokeTriplet} = $triplet;
		$self->update;
	} else {
		$self->session->errorHandler->fatal("Invalid stroke triplet: ($triplet)");
	}
}

#-------------------------------------------------------------------
sub setStrokeAlpha {
	my $self = shift;
	my $alpha = shift;

	if ($alpha =~ m/^[\da-f]{2}$/i) {
		$self->{_properties}->{strokeAlpha} = $alpha;
		$self->update;
	} else {
		$self->session->errorHandler->fatal("Invalid stroke alpha: ($alpha)");
	}
}

#-------------------------------------------------------------------
sub update {
	my $self = shift;
	
	$self->session->db->write("update imageColor set name=?, fillTriplet=?, fillAlpha=?, strokeTriplet=?, strokeAlpha=? where colorId=?", [
		$self->getName,
		$self->getFillTriplet,
		$self->getFillAlpha,
		$self->getStrokeTriplet, 
		$self->getStrokeAlpha,
		$self->getId
	]);
}

#-------------------------------------------------------------------
sub save {
	my $self = shift;
	
	if ($self->getId eq 'new') {
		$self->{_properties}->{colorId} = $self->session->id->generate;
		$self->session->db->write("insert into imageColor (colorId, name, fillTriplet, fillAlpha, strokeTriplet, strokeAlpha) values (?,?,?,?,?,?)", [
			$self->getId,
			$self->getName || 'untitled',
			$self->getFillTriplet || '#000000',
			$self->getFillAlpha || '00',
			$self->getStrokeTriplet || '#000000', 
			$self->getStrokeAlpha || '00',
		]);
	}

	$self->update;
}

1;

