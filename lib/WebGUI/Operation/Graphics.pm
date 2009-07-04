package WebGUI::Operation::Graphics;

use strict;
use WebGUI::Image::Palette;
use WebGUI::Image::Color;
use WebGUI::Image::Font;
use WebGUI::Storage;
use Tie::IxHash;

#-------------------------------------------------------------------
sub _submenu {
	my $session = shift;
	my $i18n = WebGUI::International->new($session, "Graphics");

	my $workarea = shift;
        my $title = shift;
        $title = $i18n->get($title) if ($title);
        my $ac = WebGUI::AdminConsole->new($session,"graphics");
	$ac->addSubmenuItem($session->url->page('op=listPalettes'), $i18n->get('manage palettes'));
	$ac->addSubmenuItem($session->url->page('op=listFonts'), $i18n->get('manage fonts'));
	$ac->addSubmenuItem($session->url->page('op=editPalette;pid=new'), $i18n->get('add palette'));
	$ac->addSubmenuItem($session->url->page('op=editFont;fid=new'), $i18n->get('add font')); 

        return $ac->render($workarea, $i18n->get('manage graphics'));
}

#### hoverhelp
#-------------------------------------------------------------------
sub _getColorForm {
	my ($color, %transparencies);
	my $session = shift;
	my $colorId = shift;

	my $i18n = WebGUI::International->new($session, "Graphics");
	
	$color = WebGUI::Image::Color->new($session, $colorId);

	# Create transparencies in 5% increments
	tie %transparencies, 'Tie::IxHash';
	$transparencies{'00'} = 'Opaque';
	for (1 .. 19) {
		$transparencies{unpack('H*', pack('C', $_*255/20))} = 5*$_.'% Transparent';
	}
	$transparencies{'ff'} = 'Invisible';

	my $f = WebGUI::HTMLForm->new($session);
	$f->text(
		-name	=> 'colorName',
		-value	=> $color->getName,
		-hoverHelp => $i18n->get('color name description'),
		-label	=> $i18n->get('color name'),
	);
	$f->color(
		-name	=> 'fillTriplet',
		-value	=> $color->getFillTriplet,
		-label	=> $i18n->get('fill color'),
		-hoverHelp => $i18n->get('fill color description'),
		-maxlength => 7,
		-size	=> 7,
	);
	$f->selectSlider(
		-name	=> 'fillAlpha',
		-value	=> $color->getFillAlpha,
		-options=> \%transparencies, 
		-label	=> $i18n->get('fill alpha'),
		-hoverHelp => $i18n->get('fill alpha description'),
		-maxlength => 2,
		-editable=>0,
		-size	=> 2,
	);
	$f->color(
		-name	=> 'strokeTriplet',
		-value	=> $color->getStrokeTriplet,
		-label	=> $i18n->get('stroke color'),
		-hoverHelp => $i18n->get('stroke color description'),
		-maxlength => 7,
		-size	=> 7,
	);
	$f->selectSlider(
		-name	=> 'strokeAlpha',
		-value	=> $color->getStrokeAlpha,
		-options=> \%transparencies,
		-label	=> $i18n->get('stroke alpha'),
		-hoverHelp => $i18n->get('stroke alpha description'),
		-maxlength => 2,
		-editable => 0,
		-size	=> 2,
	);

	return $f->printRowsOnly;
}

#----------------------------------------------------------------------------

=head2 canView ( session [, user] )

Returns true if the user can administrate this operation. user defaults to 
the current user.

=cut

sub canView {
    my $session     = shift;
    my $user        = shift || $session->user;
    return $user->isInGroup( $session->setting->get("groupIdAdminGraphics") );
}

#-------------------------------------------------------------------

=head2 www_addColorToPalette 

Build a form for the user to add a color to this palette.

=cut

sub www_addColorToPalette {
	my ($f);
	my $session = shift;

	return $session->privilege->adminOnly() unless canView($session);
	
	$f = WebGUI::HTMLForm->new($session);
	$f->hidden(
		-name	=> 'op',
		-value	=> 'addColorToPaletteSave',
	);
	$f->hidden(
		-name	=> 'pid',
		-value	=> $session->form->process('pid'),
	);
	$f->hidden(
		-name	=> 'cid',
		-value	=> $session->form->process('cid'),
	);
	$f->raw(_getColorForm($session, $session->form->process('cid')));
	$f->submit;

	return _submenu($session, $f->print);
}

#-------------------------------------------------------------------

=head2 www_addColorToPaletteSave 

Process the addColorToPalette form.

=cut

sub www_addColorToPaletteSave {
	my $session = shift;

	return $session->privilege->adminOnly() unless canView($session);

my	$color = WebGUI::Image::Color->new($session, $session->form->process('cid'));
	if ($session->form->process('cid') eq 'new') {
		$color->setName($session->form->process('colorName'));
		$color->setFillTriplet($session->form->process('fillTriplet'));
		$color->setFillAlpha($session->form->process('fillAlpha'));
		$color->setStrokeTriplet($session->form->process('strokeTriplet'));
		$color->setStrokeAlpha($session->form->process('strokeAlpha'));
	}
my	$palette = WebGUI::Image::Palette->new($session, $session->form->process('pid'));

	$palette->addColor($color);

	return www_editPalette($session, $palette->getId);
}

#-------------------------------------------------------------------

=head2 www_deleteFont 

Deletes a font specified by the form variable C<fid>.  Returns the user to listFonts.

=cut

sub www_deleteFont {
	my $session = shift;

	return $session->privilege->adminOnly() unless canView($session);

	my $font = WebGUI::Image::Font->new($session, $session->form->process('fid'));
	$font->delete;

	return www_listFonts($session);
}

#-------------------------------------------------------------------

=head2 www_deletePalette 

Deletes a palette specified by the form variable C<pid>.  Returns the user to listPalettes.

=cut

sub www_deletePalette {
	my $session = shift;

	return $session->privilege->adminOnly() unless canView($session);

	my $palette = WebGUI::Image::Palette->new($session, $session->form->process('pid'));
	$palette->delete;

	return www_listPalettes($session);
}

#-------------------------------------------------------------------

=head2 www_editColor 

Allows the user to add or edit a color.

=cut

sub www_editColor {
	my ($f);
	my $session = shift;

	return $session->privilege->adminOnly() unless canView($session);
	
	my $colorId = $session->form->process('cid');
	return www_listPalettes($session) if ($colorId eq 'new');
	
	$f = WebGUI::HTMLForm->new($session);
	$f->hidden(
		-name	=> 'op',
		-value	=> 'editColorSave',
	);
	$f->hidden(
		-name	=> 'pid',
		-value	=> $session->form->process('pid'),
	);
	$f->hidden(
		-name	=> 'cid',
		-value	=> $colorId,
	);
	$f->raw(_getColorForm($session, $colorId));
	$f->submit;

	return _submenu($session, $f->print);
}

#-------------------------------------------------------------------

=head2 www_editColorSave 

Processes the editColor screen.  Returns the user to editPalette.

=cut

sub www_editColorSave {
	my $session = shift;
	
	return $session->privilege->adminOnly() unless canView($session);
	
	my $colorId = $session->form->process('cid');
	return www_listPalettes($session) if ($colorId eq 'new');
	
	my $color = WebGUI::Image::Color->new($session, $colorId);

	$color->setName($session->form->process('colorName'));
	$color->setFillTriplet($session->form->process('fillTriplet'));
	$color->setFillAlpha($session->form->process('fillAlpha'));
	$color->setStrokeTriplet($session->form->process('strokeTriplet'));
	$color->setStrokeAlpha($session->form->process('strokeAlpha'));

	return www_editPalette($session, $session->form->process('pid'));
}

#-------------------------------------------------------------------

=head2 www_editFont 

Show the user a form to add a new font or edit an existing one.

=cut

sub www_editFont {
	my ($f, $fontName);
	my $session = shift;
	
	return $session->privilege->adminOnly() unless canView($session);
	
	my $i18n = WebGUI::International->new($session, "Graphics");
	
	unless ($session->form->process('fid') eq 'new') {
		my $font = WebGUI::Image::Font->new($session, $session->form->process('fid'));
		$fontName = $font->getName;		
	}
	
	$f = WebGUI::HTMLForm->new($session);
	$f->hidden(
		-name	=> 'op',
		-value	=> 'editFontSave',
	);
	$f->hidden(
		-name	=> 'fid',
		-value	=> $session->form->process('fid'),
	);
	$f->text(
		-name	=> 'fontName',
		-value	=> $fontName,
		-label	=> $i18n->get('font name'),
		-hoverHelp => $i18n->get('font name description'),
	);
	$f->file(
		-name	=> 'fontFile',
		-label	=> $i18n->get('font file'),
		-hoverHelp => $i18n->get('font file description'),
	);
	$f->submit;

	return _submenu($session, $f->print);
}

#-------------------------------------------------------------------

=head2 www_editFontSave 

Process the editFont form.  Returns the user to listFonts.

=cut

sub www_editFontSave {
	my $session = shift;

	return $session->privilege->adminOnly() unless canView($session);
	
	if ($session->form->process('fid') eq 'new') {

        my $fileStorageId = WebGUI::Form::File->new($session,{name => 'fontFile'})->getValue;
        my $storage = WebGUI::Storage->get($session, $fileStorageId);
        my $filename = $storage->getFiles()->[0];

		if ($filename) {
			my $font = WebGUI::Image::Font->new($session, 'new');
			$font->setName($session->form->process('fontName'));
			$font->setStorageId($storage->getId);
			$font->setFilename($filename);
		}
	}

	return www_listFonts($session);
}

#-------------------------------------------------------------------

=head2 www_editPalette ($palette, $output)

Add or edit a palette.

=head3 $palette

The ID of a palette to edit.  If blank, it will use the form variable C<pid>.

=head3 $output

=cut

sub www_editPalette {
	my ($name, $palette, $output);
	my $session = shift;
	my $paletteId = shift || $session->form->process('pid');

	return $session->privilege->adminOnly() unless canView($session);
	
	my $i18n = WebGUI::International->new($session, 'Graphics');
	
	unless ($paletteId eq 'new') {
		$palette = WebGUI::Image::Palette->new($session, $paletteId);
		$name = $palette->getName;
	};
	
	my $f = WebGUI::HTMLForm->new($session);
	$f->hidden(
		-name	=> 'op',
		-value	=> 'editPaletteSave',
	);
	$f->hidden(
		-name	=> 'pid',
		-value	=> $paletteId,
	);
	$f->text(
		-name	=> 'paletteName',
		-value	=> $name,
		-label	=> $i18n->get('palette name'),
		-hoverHelp => $i18n->get('palette name description'),
	);
	$f->submit;
	$output = $f->print;
	unless ($paletteId eq 'new') {
		my $palette = WebGUI::Image::Palette->new($session, $paletteId);

		$output .= '<table>';
		$output .= '<tr><th></th><th>'.$i18n->get('fill color').'</th><th>'.$i18n->get('stroke color').'</th></tr>';
		foreach my $color (@{$palette->getColorsInPalette}) {
			$output .= '<tr>';
			$output .= '<td>';
			$output .= $session->icon->delete('op=removeColorFromPalette;pid='.$palette->getId.';index='.$palette->getColorIndex($color));
			$output .= $session->icon->edit('op=editColor;pid='.$palette->getId.';cid='.$color->getId);
			$output .= $session->icon->moveUp('op=moveColorUp;pid='.$palette->getId.';index='.$palette->getColorIndex($color));
			$output .= $session->icon->moveDown('op=moveColorDown;pid='.$palette->getId.';index='.$palette->getColorIndex($color));
			$output .= '</td>';
			$output .= '<td width="30" border="1" height="30" bgcolor="'.$color->getFillTriplet.'"></td>';
			$output .= '<td width="30" border="1" height="30" bgcolor="'.$color->getStrokeTriplet.'"></td>';
			$output .= '</tr>';
		}
		$output .= '</table>';

		$output .= '<a href="'.$session->url->page('op=addColorToPalette;cid=new;pid='.$palette->getId).'">'.$i18n->get('add color').'</a><br />';
	}
		
	return _submenu($session, $output);
}

#-------------------------------------------------------------------

=head2 www_editPaletteSave 

Process the editPalette screen.  Returns the user to editPalette.

=cut

sub www_editPaletteSave {
	my $session = shift;

	return $session->privilege->adminOnly() unless canView($session);
	
	my $palette = WebGUI::Image::Palette->new($session, $session->form->process('pid'));
	$palette->setName($session->form->process('paletteName'));
	
	return www_editPalette($session, $palette->getId);
}

#-------------------------------------------------------------------

=head2 www_listGraphicsOptions 

Provides a screen where the user can list palettes or fonts.

=cut

sub www_listGraphicsOptions {
	my ($output);
	my $session = shift;

	return $session->privilege->adminOnly() unless canView($session);

	my $i18n = WebGUI::International->new($session, 'Graphics');	
	
	$output .= '<a href="'.$session->url->page('op=listPalettes').'">'.$i18n->get('manage palettes').'</a><br />';
	$output .= '<a href="'.$session->url->page('op=listFonts').'">'.$i18n->get('manage fonts').'</a><br />';

	return _submenu($session, $output);
}

#-------------------------------------------------------------------

=head2 www_listPalettes 

Lists all palettes in the system, along with controls to delete, edit or add palettes.

=cut

sub www_listPalettes {
	my ($output);
	my $session = shift;

	return $session->privilege->adminOnly() unless canView($session);
	
	my $i18n = WebGUI::International->new($session, 'Graphics');
	
	my $palettes = WebGUI::Image::Palette->getPaletteList($session);
	
	$output .= '<table>';
	$output .= '<tr><th></th><th>'.$i18n->get('palette name').'</th></tr>';
	foreach (keys %$palettes) {
		$output .= '<tr>';
		$output .= '<td>';
		$output .= $session->icon->delete('op=deletePalette;pid='.$_);
		$output .= $session->icon->edit('op=editPalette;pid='.$_);
		$output .= '</td>';
		$output .= '<td>'.$palettes->{$_}.'</td>';
		$output .= '</tr>';
	}
	$output .= '</table>';

	$output .= '<a href="'.$session->url->page('op=editPalette;pid=new').'">'.$i18n->get('add palette').'</a><br />';

	return _submenu($session, $output);
}

#-------------------------------------------------------------------

=head2 www_moveColorDown 

Move the color given by the form variable C<pid> down one position.

=cut

sub www_moveColorDown {
	my ($palette, $index);
	my $session = shift;

	$palette = WebGUI::Image::Palette->new($session, $session->form->process('pid'));
	$index = $session->form->process('index');
	
	if ($index < ($palette->getNumberOfColors - 1) && $index >=0) {
		$palette->swapColors($index, $index + 1);
	}

	return www_editPalette($session, $session->form->process('pid'));
}

#-------------------------------------------------------------------

=head2 www_moveColorUp 

Move the color given by the form variable C<pid>, up one position.

=cut

sub www_moveColorUp {
	my ($palette, $index);
	my $session = shift;

	$palette = WebGUI::Image::Palette->new($session, $session->form->process('pid'));
	$index = $session->form->process('index');

	if ($index <= ($palette->getNumberOfColors - 1) && $index > 0) {
		$palette->swapColors($index, $index - 1);
	}

	return www_editPalette($session, $session->form->process('pid'));
}

#-------------------------------------------------------------------

=head2 www_listFonts 

Lists all fonts in the system, with controls to delete them or add new ones.

=cut

sub www_listFonts {
	my ($output);
	my $session = shift;

	return $session->privilege->adminOnly() unless canView($session);

	my $i18n = WebGUI::International->new($session, 'Graphics');
	
	my %fonts = $session->db->buildHash('select fontId, name from imageFont');
	
	$output .= '<table>';
	$output .= '<tr><th></th><th>'.$i18n->get('font name').'</th></tr>';
	foreach (keys %fonts) {
		$output .= '<tr>';
		$output .= '<td>';
		$output .= $session->icon->delete('op=deleteFont;fid='.$_);
#		$output .= $session->icon->edit('op=editFont;fid='.$_);
		$output .= '</td>';
		$output .= '<td>'.$fonts{$_}.'</td>';
		$output .= '</tr>';
	}
	$output .= '</table>';

	$output .= '<a href="'.$session->url->page('op=editFont;fid=new').'">'.$i18n->get('add font').'</a><br />';

	return _submenu($session, $output);
}

#-------------------------------------------------------------------

=head2 www_removeColorFromPalette 

Removes the color given by the form variable C<index> from palette described by the
form variable C<pid>.

=cut

sub www_removeColorFromPalette {
	my $session = shift;

	return $session->privilege->adminOnly() unless canView($session);
	
	my $palette = WebGUI::Image::Palette->new($session, $session->form->process('pid'));
	$palette->removeColor($session->form->process('index'));

	return www_editPalette($session, $session->form->process('pid'));
}

1;

