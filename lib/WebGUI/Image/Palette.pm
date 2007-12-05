package WebGUI::Image::Palette;

use strict;
use WebGUI::Image::Color;

=head1 NAME

Package WebGUI::Image::Palette

=head1 DESCRIPTION

Package for managing WebGUI palettes.

=head1 SYNOPSIS

Palettes are a list of WebGUI::Image::Color objects. Selecting a specific color
can be done by either passing a palette index, or by an API that cyles through
the palette.

Along with methods for these operations methods for editing palettes are
provided from this class.

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 addColor ( color )

Adds a color to this palette. The color will be automatically saved or updated
to the database.

=head3 color

A WebGUI::Image::Color object.

=cut

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

=head2 canDelete ( )

Returns true if this palette can be deleted.

=cut

sub canDelete {
	my $self = shift;

	return 0 if ($self->getId =~ /^default/);
	return 1;
}

#-------------------------------------------------------------------

=head2 canEdit ( )

Returns true if this palette can be edited.

=cut

sub canEdit {
	my $self = shift;

	return 1;
}

#-------------------------------------------------------------------

=head2 delete ( )

Deletes the palette from the database. This is only possible if the canDelete
method returns true.

NOTE: For now the colors in the palette are not deleted automatically.

=cut

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

=head2 getColor ( [ index ] )

Returns the color at index in the palette. If index is not passed it will return
the color at the index specified by the internal palette index counter, ie. the
current color.

=cut

sub getColor {
	my $self = shift;
	my $index = shift || $self->getPaletteIndex;

	return $self->{_palette}->[$index];
}

#-------------------------------------------------------------------

=head2 getColorIndex ( color )

Returns the index of color. If the color is not in the palette it will return
undef.

=head3 color

A WebGUI::Image::Color object.

=cut

sub getColorIndex {
	my (@palette, $index);
	my $self = shift;
	my $color = shift;
	
	@palette = @{$self->getColorsInPalette};
	
	for ($index = 0; $index < scalar(@palette); $index++) {
		return $index if ($self->getColor($index)->getId eq $color->getId);
	}

	return;
}

#-------------------------------------------------------------------

=head2 getColorsInPalette ( )

Returns a arrayref containing all color objects in the palette.

=cut

sub getColorsInPalette {
	my $self = shift;

	# Copy ref so people cannot overwrite 
	return [ @{$self->{_palette}} ];
}

#-------------------------------------------------------------------

=head2 getDefaultPaletteId ( )

Returns the id of the default palette.

=cut

sub getDefaultPaletteId {
	my $self = shift;

	return 'defaultPalette';
}

#-------------------------------------------------------------------

=head2 getId ( )

Returns the guid of this palette.

=cut

sub getId {
	my $self = shift;
	
	return $self->{_properties}->{paletteId};
}

#-------------------------------------------------------------------

=head2 getName ( )

Returns the name of this palette.

=cut

sub getName {
	my $self = shift;
	
	return $self->{_properties}->{name};
}

#-------------------------------------------------------------------

=head2 getNextColor ( )

Returns the next color in the palette relative to the internal palette index
counter, and increases this counter to that color. If the counter already is at
the last color in the palette it will cycle around to the first color in the
palette.

=cut

sub getNextColor {
	my $self = shift;

	my $index = $self->getPaletteIndex + 1;
	$index = 0 if ($index >= $self->getNumberOfColors);

	$self->setPaletteIndex($index);
	return $self->getColor;
}

#-------------------------------------------------------------------

=head2 getNumberOfColors ( )

Returns the number of colors in the palette.

=cut

sub getNumberOfColors {
	my $self = shift;

	return scalar(@{$self->{_palette}});
}

#-------------------------------------------------------------------

=head2 getPaletteIndex ( )

Returns the index the internal palette index counter is set to. Ie. it returns
the current color.

=cut

sub getPaletteIndex {
	my $self = shift;

	return $self->{_paletteIndex};
}

#-------------------------------------------------------------------

=head2 getPaletteList ( )

Returns a hashref containing a list of all available palettes. The keys are the
palette id's and the value are the names of the palettes.

=cut

sub getPaletteList {
	my $self = shift;
	my $session = shift || $self->session;

	return $session->db->buildHashRef('select paletteId, name from imagePalette');
}

#-------------------------------------------------------------------

=head2 getPreviousColor ( )

Returns the previous color in the palette relative to the internal palette index
counter, and decreases this counter to that color. If the counter already is at
the first color in the palette it will cycle around to the last color in the
palette.

=cut

sub getPreviousColor {
	my $self = shift;

	my $index = $self->{_paletteIndex} - 1;
	$index = $self->getNumberOfColors - 1 if ($index < 0);

	$self->setPaletteIndex($index);
	return $self->getColor($index);
}

#-------------------------------------------------------------------

=head2 new ( session, paletteId, [ name ] )

Constructor for this class. 

=head3 session

A WebGUI::Session object.

=head3 paletteId

The guid of the palette you want to instanciate. If you want to create a new
palette use 'new' for this value.

=head3 name

The name of this palette. If not given it will default to 'untitled'. You can
also adjust this parameter through the setName method.

=cut

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

=head2 removeColor ( index )

Removes color at index.

NOTE: This method does not delete the color from the database. If you want to do
this you must do it manually.

=head3 index

The index of the color you want to remove. If not given nothing will happen.

=cut

sub removeColor {
	my $self = shift;
	my $paletteIndex = shift;

	return unless (defined $paletteIndex);
	
	my $color = $self->getColor($paletteIndex);
	
	splice(@{$self->{_palette}}, $paletteIndex, 1);
	
	$self->session->db->write('delete from imagePaletteColors where paletteId=? and colorId=?', [
		$self->getId,
		$color->getId,
	]);
	$self->session->db->write('update imagePaletteColors set paletteOrder=paletteOrder-1 where paletteId=? and paletteOrder > ?', [
		$self->getId,
		$paletteIndex,
	]);
	
}

#-------------------------------------------------------------------

=head2 session ( )

Returns the WebGUI::Session object.

=cut

sub session {
	my $self = shift;

	return $self->{_session};
}

#-------------------------------------------------------------------

=head2 setColor ( index, color )

Sets palette position index to color. This method will automatically save or
update the color. Index must be within the current palette. To add additional
colors use the addColor method.

=head3 index

The index within the palette where you want to put the color.

=head3 color

The WebGUI::Image::Color object.

=cut

sub setColor {
	my $self = shift;
	my $index = shift;
	my $color = shift;

	return if ($index >= $self->getNumberOfColors);
	return if ($index < 0);
	return unless (defined $index);
	return unless (defined $color);

	$color->save;

	$self->session->db->write('update imagePaletteColors set colorId=? where paletteId=? and paletteOrder=?', [
		$color->getId,
		$self->getId, 
		$index + 1,
	]);
	
	$self->{_palette}->[$index] = $color;
}

#-------------------------------------------------------------------

=head2 setName ( name )

Set the name of this palette.

=head3 name

A scalar containing the desired name.

=cut

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

=head2 setPaletteIndex ( index )

Set the internal palette index counter. In other words, it sets the current
color to the specified index. If index exceeds the maximum index number it will
be set to the maximum index.

=head3 index

The index you want to set the counter to.

=cut

sub setPaletteIndex {
	my $self = shift;
	my $index = shift;
	
	return unless (defined $index);
	
	$index = ($self->getNumberOfColors - 1) if ($index >= $self->getNumberOfColors);
	$index = 0 if ($index < 0);
	
	$self->{_paletteIndex} = $index;
}

#-------------------------------------------------------------------

=head2 swapColors ( firstIndex, secondIndex )

Swaps the position of two colors within the palette.

=head3 firstIndex

The index of one of the colors to swap.

=head3 secondIndex

The index of the other color to swap.

=cut

sub swapColors {
	my $self = shift;
	my $indexA = shift;
	my $indexB = shift;

	my $colorA = $self->getColor($indexA);
	my $colorB = $self->getColor($indexB);

	$self->setColor($indexA, $colorB);
	$self->setColor($indexB, $colorA);
}

1;

