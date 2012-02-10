package WebGUI::Image::Color;

use strict;
use Color::Calc;

=head1 NAME

Package WebGUI::Image::Color

=head1 DESCRIPTION

Package for managing WebGUI colors.

=head1 SYNOPSIS

Colors actually consist of two colors: fill color and stroke color. Stroke color
is the color for lines and the border of areas, while the fill color is the
color that is used to fill that area. Fill color thus have no effect on lines.

Each fill and stroke color consists of a Red, Green, Blue and Alpha component.
These values are given in hexadecimal notation. A concatenation of the Red,
Greean and Blue values, prepended with a '#' sign is called a triplet. A similar
combination that also includes the Alpha values at the end is called a quarted.

Alpha value are used to define the transparency of the color. The higher the
value the more transparent the color is. If the alpha value = 00 the color is
opaque, where the color is completely invisible for an alpha value of ff.

Colors are not saved to the database by default. If you want to do this you must
do so manually using the save and/or update methods.

=head1 METHODS

These methods are available from this class:

=cut


#-------------------------------------------------------------------

=head2 canDelete ( )

Returns true if this color can be deleted.

=cut

sub canDelete {
	my $self = shift;
	
	return 1;
}

#-------------------------------------------------------------------

=head2 copy ( )

Returns a new WebGUI::Image::Color object being an exact copy of this color,
except for the persistency. This means that the new copy will not be stored in
the database. To accomplish that use the save method on the copy.

=cut

sub copy {
	my $self = shift;

	return WebGUI::Image::Color->new($self->session, 'new', {%{$self->{_properties}}});
}

#-------------------------------------------------------------------

=head2 darken ( )

Returns a new WebGUI::Image::Color object with the same properties but the
colors darkened. This object will not be saved to the database automatically.
Use the save method on it if you want to do so.

=cut

sub darken {
	my $self = shift;
	
	my $newColor = $self->copy;

	my $c = Color::Calc->new(OutputFormat => 'hex');
	
	$newColor->setFillTriplet('#'.$c->dark($self->getFillTriplet));
	$newColor->setStrokeTriplet('#'.$c->dark($self->getStrokeTriplet));

	return $newColor;
}

#-------------------------------------------------------------------

=head2 delete ( )

Deletes the color from the database. It will only delete if canDelete returns
true.

=cut

sub delete {
	my $self = shift;
	if ($self->canDelete) {
		$self->session->db->write('delete from imageColor where colorId=?', [
			$self->getId,
		]);
	}
}

#-------------------------------------------------------------------

=head2 getFillColor ( )

Returns the the quartet of th fill color. The quartet consists of R, G, B and
Alpha values respectively in HTML format: '#rrggbbaa'.

=cut

sub getFillColor {
	my $self = shift;
	
	return $self->getFillTriplet.$self->getFillAlpha;
}

#-------------------------------------------------------------------

=head2 getFillTriplet ( )

Returns the RGB triplet of the fill color in HTML format: '#rrggbb'.

=cut

sub getFillTriplet {
	my $self = shift;

	return $self->{_properties}->{fillTriplet};
}

#-------------------------------------------------------------------

=head2 getFillAlpha ( )

Returns the hex value of the Alpha channel in this color.

=cut

sub getFillAlpha {
	my $self = shift;

	return $self->{_properties}->{fillAlpha};
}

#-------------------------------------------------------------------

=head2 getId ( )

Returns the GUID of this color.

=cut

sub getId {
	my $self = shift;

	return $self->{_properties}->{colorId};
}

#-------------------------------------------------------------------

=head2 getName ( )

Returns the name assigned to this color.

=cut

sub getName {
	my $self = shift;

	return $self->{_properties}->{name};
}

#-------------------------------------------------------------------

=head2 getStrokeColor ( )

Returns the the quartet of the stroke color. The quartet consists of R, G, B and
Alpha values respectively in HTML format: '#rrggbbaa'.

=cut

sub getStrokeColor {
	my $self = shift;
	
	return $self->getStrokeTriplet.$self->getStrokeAlpha;
}

#-------------------------------------------------------------------

=head2 getStrokeTriplet ( )

Returns the RGB triplet of the stroke color in HTML format: '#rrggbb'.

=cut

sub getStrokeTriplet {
	my $self = shift;

	return $self->{_properties}->{strokeTriplet};
}

#-------------------------------------------------------------------

=head2 getStrokeAlpha ( )

Returns the hex value of the Alpha channel in the stroke color.

=cut

sub getStrokeAlpha {
	my $self = shift;

	return $self->{_properties}->{strokeAlpha};
}

#-------------------------------------------------------------------

=head2 new ( session, colorId, [ properties ] )

Constructor for this class.

=head3 session

A WebGUI::Session object.

=head3 colorId

The id of the color you want to instanciate. If you're creating a new color
please use 'new' as id.

=head3 properties

A hashref containing configuration options to set this object to. All are also
available through methods.

=head4 name

The color name.

=head4 fillTriplet

The RGB triplet for the fill color. See setFillTriplet.

=head4 fillAlpha

The alpha value for the fill color. See setFillAlpha.

=head4 strokeTriplet

The RGB triplet for the stroke color. See setStrokeTriplet.

=head4 strokeAlpha

The alpha value for the stroke color. See setStrokeAlpha.

=cut

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

=head2 newByPalette ( session, paletteId )

Returns an arrayref containg instanciated WebGUI::Image::Color objects for each
color in the sepcified palette.

=head3 session

A WebGUI::Session object.

=head3 paletteId

The id of the palette that is to be loaded.

=cut

sub newByPalette {
	my ($sth, $row, @colors);
	my $class = shift;
	my $session = shift;
	my $paletteId = shift;

	$sth = $session->db->read('select imageColor.* from imageColor, imagePaletteColors where '.
		' imageColor.colorId=imagePaletteColors.colorId and paletteId=?', [
		$paletteId
	]);

	while ($row = $sth->hashRef) {
		push(@colors, WebGUI::Image::Color->new($session, $row->{colorId}, $row));
	}
	
	return \@colors;
}

#-------------------------------------------------------------------

=head2 session ( )

Returns the WebGUI::Session object;

=cut

sub session {
	my $self = shift;

	return $self->{_session};
}

#-------------------------------------------------------------------

=head2 setFillColor ( quartet )

Sets the the fill color to the specified quartet.

=head3 quartet

The quartet consists of R, G, B and Alpha values respectively in HTML format: '#rrggbbaa'.

=cut

sub setFillColor {
	my $self = shift;
	my $color = shift;

	if ($color =~ m/^(#[\da-f]{6})([\da-f]{2})?$/i) {
		$self->setFillTriplet($1);
		$self->setFillAlpha($2 || '00');
	} else {
		$self->session->log->fatal("Invalid fill color: ($color)");
	}
}

#-------------------------------------------------------------------

=head2 setFillTriplet ( triplet )

Sets the RGB triplet of the fill color.

=head3 triplet

The RGB triplet in HTML format: '#rrggbb'.

=cut

sub setFillTriplet {
	my $self = shift;
	my $triplet = shift;
	
	if ($triplet =~ m/^#[\da-f]{6}$/i) {
		$self->{_properties}->{fillTriplet} = $triplet;
		$self->update;
	} else {
		$self->session->log->fatal("Invalid fill triplet: ($triplet)");
	}
}

#-------------------------------------------------------------------

=head2 setFillAlpha ( alpha )

Sets the alpha channel for the fill color.

=head3 alpha

The alpha value in hexadecimal notation: 'ff';

=cut

sub setFillAlpha {
	my $self = shift;
	my $alpha = shift;

	if ($alpha =~ m/^[\da-f]{2}$/i) {
		$self->{_properties}->{fillAlpha} = $alpha;
		$self->update;
	} else {
		$self->session->log->fatal("Invalid fill alpha: ($alpha)");
	}
}

#-------------------------------------------------------------------

=head2 setName ( name )

Sets the name of this color.

=head3 name

A scalar containing the name of this color.

=cut

sub setName {
	my $self = shift;
	my $name = shift;
	
	$self->{_properties}->{name} = $name;
	$self->update;
}

#-------------------------------------------------------------------

=head2 setStrokeColor ( quartet )

Sets the the stroke color to the specified quartet.

=head3 quartet

The quartet consists of R, G, B and Alpha values respectively in HTML format: '#rrggbbaa'.

=cut

sub setStrokeColor {
	my $self = shift;
	my $color = shift;

	if ($color =~ m/^(#[\da-f]{6})([\da-f]{2})?$/i) {
		$self->setStrokeTriplet($1);
		$self->setStrokeAlpha($2 || '00');
	} else {
		$self->session->log->fatal("Invalid stroke color: ($color)");
	}
}

#-------------------------------------------------------------------

=head2 setStrokeTriplet ( triplet )

Sets the RGB triplet of the stroke color.

=head3 triplet

The RGB triplet in HTML format: '#rrggbb'.

=cut

sub setStrokeTriplet {
	my $self = shift;
	my $triplet = shift;
	
	if ($triplet =~ m/^#[\da-f]{6}$/i) {
		$self->{_properties}->{strokeTriplet} = $triplet;
		$self->update;
	} else {
		$self->session->log->fatal("Invalid stroke triplet: ($triplet)");
	}
}

#-------------------------------------------------------------------

=head2 setStrokeAlpha ( alpha )

Sets the alpha channel for the stroke color.

=head3 alpha

The alpha value in hexadecimal notation: 'ff';

=cut

sub setStrokeAlpha {
	my $self = shift;
	my $alpha = shift;

	if ($alpha =~ m/^[\da-f]{2}$/i) {
		$self->{_properties}->{strokeAlpha} = $alpha;
		$self->update;
	} else {
		$self->session->log->fatal("Invalid stroke alpha: ($alpha)");
	}
}

#-------------------------------------------------------------------

=head2 update ( )

Will update the database to the current state of the object. If your object has
not yet been saved to the database, you must first use the save method, which
has the same functionality.

=cut

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

=head2 save ( )

Will save the state of the object to the database if the color is not yet in the
database. If it already is in the database this method will do exactly the same
as update.

=cut

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

