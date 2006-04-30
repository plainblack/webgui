package WebGUI::Image::Palette;

use strict;
use WebGUI::Image::Color;

#-------------------------------------------------------------------
sub addColor {
	my $self = shift;
	my $color = shift;
	
	$color->save;

	$self->session->db->write('insert into imagePaletteColors (paletteId, colorId, paletteOrder) values (?,?,?)', [
		$self->getId, 
		$color->getId, 
		$self->getNumberOfColors + 1
	]);
	
	push (@{$self->{_palette}}, $color);
}

#-------------------------------------------------------------------
sub canDelete {
	my $self = shift;

	return 0 if ($self->getId =~ /^default/);
	return 1;
}

#-------------------------------------------------------------------
sub canEdit {
	my $self = shift;

	return 1;
}

#-------------------------------------------------------------------
sub delete {
	my $self = shift;
	
	if ($self->canDelete) {
		$self->session->db->write('delete from imagePaletteColors where paletteId=?', [
			$self->getId,
		]);
		$self->session->db->write('delete from imagePalette where paletteId=?', [
			$self->getId,
		]);
	}
}

#-------------------------------------------------------------------
sub getColor {
	my $self = shift;
	my $index = shift || $self->getPaletteIndex;

	return $self->{_palette}->[$index];
}

#-------------------------------------------------------------------
sub getColorsInPalette {
	my $self = shift;

	return $self->{_palette};
}

#-------------------------------------------------------------------
sub getDefaultPaletteId {
	my $self = shift;

	return 'defaultPalette';
}

#-------------------------------------------------------------------
sub getId {
	my $self = shift;
	
	return $self->{_properties}->{paletteId};
}

#-------------------------------------------------------------------
sub getName {
	my $self = shift;
	
	return $self->{_properties}->{name};
}

#-------------------------------------------------------------------
sub getNextColor {
	my $self = shift;

	my $index = $self->getPaletteIndex + 1;
	$index = 0 if ($index >= $self->getNumberOfColors);

	$self->setPaletteIndex($index);
	return $self->getColor;
}

#-------------------------------------------------------------------
sub getNumberOfColors {
	my $self = shift;

	return scalar(@{$self->{_palette}});
}

#-------------------------------------------------------------------
sub getPaletteIndex {
	my $self = shift;

	return $self->{_paletteIndex};
}

#-------------------------------------------------------------------
sub getPaletteList {
	my $self = shift;
	my $session = shift || $self->session;

	return $session->db->buildHashRef('select paletteId, name from imagePalette');
}

#-------------------------------------------------------------------
sub getPreviousColor {
	my $self = shift;

	my $index = $self->{_paletteIndex} - 1;
	$index = $self->getNumberOfColors - 1 if ($index < 0);

	$self->setPaletteIndex($index);
	return $self->getColor($index);
}

#-------------------------------------------------------------------
sub new {
	my ($properties, $colors);
	my $class = shift;
	my $session = shift;
	my $paletteId = shift;
	my $name = shift || 'untitled';

	if ($paletteId eq 'new') {
		$paletteId = $session->id->generate;
		$session->db->write('insert into imagePalette (paletteId, name) values (?,?)', [
			$paletteId,
			$name
		]);
		$properties = {
			paletteId 	=> $paletteId,
			name		=> 'paletteName',
		};
		$colors = [];
	} else {
		$properties = $session->db->quickHashRef('select * from imagePalette where paletteId = ?', [
			$paletteId,
		]);
		
		unless ($properties->{paletteId}) {
			$properties = $session->db->quickHashRef('select * from imagePalette where paletteId = ?', [
				'defaultPalette'	#$self->getDefaultPaletteId
			]);
			$paletteId = 'defaultPalette';
		}	
		
		$colors = WebGUI::Image::Color->newByPalette($session, $paletteId);
	}

	bless {_paletteIndex => 0, _palette => $colors, _properties => $properties, _session => $session}, $class;
}

#-------------------------------------------------------------------
sub removeColor {
	my $self = shift;
	my $color = shift;

	my $newColors = shift;

	foreach (@{$self->{_palette}}) {
		push(@$newColors, $_) unless ($_->getId eq $color->getId);
	}
	$self->{_palette} = $newColors;
	
	$self->session->db->write('delete from imagePaletteColors where paletteId=? and colorId=?', [
		$self->getId,
		$color->getId,
	]);
}

#-------------------------------------------------------------------
sub session {
	my $self = shift;

	return $self->{_session};
}

#-------------------------------------------------------------------
sub setName {
	my $self = shift;
	my $name = shift;
	
	$self->session->db->write('update imagePalette set name=? where paletteId=?', [
		$name,
		$self->getId,
	]);

	$self->{_properties}->{name} = $name;
}

#-------------------------------------------------------------------
sub setPaletteIndex {
	my $self = shift;
	my $index = shift;
	
	$self->{_paletteIndex} = $index;
}

#-------------------------------------------------------------------
sub swapColors {
	#### Implementeren!
}

1;

