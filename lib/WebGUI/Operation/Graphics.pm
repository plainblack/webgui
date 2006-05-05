package WebGUI::Operation::Graphics;

use strict;
use WebGUI::Image::Palette;
use WebGUI::Image::Color;
use WebGUI::Image::Font;
use WebGUI::Storage;

#-------------------------------------------------------------------
sub _submenu {
	my $session = shift;
	my $i18n = WebGUI::International->new($session, "Graphics");

	my $workarea = shift;
        my $title = shift;
        $title = $i18n->get($title) if ($title);
        my $help = shift;
        my $ac = WebGUI::AdminConsole->new($session,"graphics");
        if ($help) {
                $ac->setHelp($help, 'Commerce');
        }
	$ac->addSubmenuItem($session->url->page('op=listPalettes'), $i18n->get('manage palettes'));
	$ac->addSubmenuItem($session->url->page('op=listFonts'), $i18n->get('manage fonts'));
	$ac->addSubmenuItem($session->url->page('op=editPalette&pid=new'), $i18n->get('add palette'));
	$ac->addSubmenuItem($session->url->page('op=editFont&fid=new'), $i18n->get('add font')); 

        return $ac->render($workarea, $i18n->get('manage graphics'));
}

#### hoverhelp
#-------------------------------------------------------------------
sub _getColorForm {
	my ($f, $color);
	my $session = shift;
	my $colorId = shift;

	my $i18n = WebGUI::International->new($session, "Graphics");
	
	$color = WebGUI::Image::Color->new($session, $colorId);

	my $f = WebGUI::HTMLForm->new($session);
	$f->text(
		-name	=> 'colorName',
		-value	=> $color->getName,
		-label	=> $i18n->get('color name'),
	);
	$f->color(
		-name	=> 'fillTriplet',
		-value	=> $color->getFillTriplet,
		-label	=> $i18n->get('fill color'),
		-maxlength => 7,
		-size	=> 7,
	);
	$f->hexSlider(
		-name	=> 'fillAlpha',
		-value	=> $color->getFillAlpha,
		-label	=> $i18n->get('fill alpha'),
		-maxlength => 2,
		-size	=> 2,
	);
	$f->color(
		-name	=> 'strokeTriplet',
		-value	=> $color->getStrokeTriplet,
		-label	=> $i18n->get('stroke color'),
		-maxlength => 7,
		-size	=> 7,
	);
	$f->text(
		-name	=> 'strokeAlpha',
		-value	=> $color->getStrokeAlpha,
		-label	=> $i18n->get('stroke alpha'),
		-maxlength => 2,
		-size	=> 2,
	);

	return $f->printRowsOnly;
}

#-------------------------------------------------------------------
sub www_addColorToPalette {
	my ($f);
	my $session = shift;

	return $session->privilege->adminOnly() unless ($session->user->isInGroup(3));
	
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
sub www_addColorToPaletteSave {
	my $session = shift;

	return $session->privilege->adminOnly() unless ($session->user->isInGroup(3));

my	$color = WebGUI::Image::Color->new($session, $session->form->process('cid'));
	if ($session->form->process('cid') eq 'new') {
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
sub www_deleteFont {
	my $session = shift;

	return $session->privilege->adminOnly() unless ($session->user->isInGroup(3));

	my $font = WebGUI::Image::Font->new($session, $session->form->process('fid'));
	$font->delete;

	return www_listFonts($session);
}

#-------------------------------------------------------------------
sub www_deletePalette {
	my $session = shift;

	return $session->privilege->adminOnly() unless ($session->user->isInGroup(3));

	my $palette = WebGUI::Image::Palette->new($session, $session->form->process('pid'));
	$palette->delete;

	return www_listPalettes($session);
}

#-------------------------------------------------------------------
sub www_editColor {
	my ($f);
	my $session = shift;

	return $session->privilege->adminOnly() unless ($session->user->isInGroup(3));
	
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
sub www_editColorSave {
	my $session = shift;
	
	return $session->privilege->adminOnly() unless ($session->user->isInGroup(3));
	
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
sub www_editFont {
	my ($f, $fontName);
	my $session = shift;
	
	return $session->privilege->adminOnly() unless ($session->user->isInGroup(3));
	
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
	);
	$f->file(
		-name	=> 'fontFile',
		-label	=> $i18n->get('font file'),
	);
	$f->submit;

	return _submenu($session, $f->print);
}

#-------------------------------------------------------------------
sub www_editFontSave {
	my $session = shift;

	return $session->privilege->adminOnly() unless ($session->user->isInGroup(3));
	
	if ($session->form->process('fid') eq 'new') {
		my $storage = WebGUI::Storage->create($session, 'new');
		my $filename = $storage->addFileFromFormPost('fontFile');
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
sub www_editPalette {
	my ($name, $palette, $output, $color);
	my $session = shift;
	my $paletteId = shift || $session->form->process('pid');

	return $session->privilege->adminOnly() unless ($session->user->isInGroup(3));
	
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
	);
	$f->submit;
	$output = $f->print;
	unless ($paletteId eq 'new') {
		my $palette = WebGUI::Image::Palette->new($session, $paletteId);

		$output .= '<table>';
		$output .= '<th><td>'.$i18n->get('fill color').'</td><td>'.$i18n->get('stroke color').'</td></th>';
		foreach $color (@{$palette->getColorsInPalette}) {
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

		$output .= '<a href="'.$session->url->page('op=addColorToPalette&cid=new&pid='.$palette->getId).'">'.$i18n->get('add color').'</a><br>';
	}
		
	return _submenu($session, $output);
}

#-------------------------------------------------------------------
sub www_editPaletteSave {
	my $session = shift;

	return $session->privilege->adminOnly() unless ($session->user->isInGroup(3));
	
	my $palette = WebGUI::Image::Palette->new($session, $session->form->process('pid'));
	$palette->setName($session->form->process('paletteName'));
	
	return www_editPalette($session, $palette->getId);
}

#-------------------------------------------------------------------
sub www_listGraphicsOptions {
	my ($output);
	my $session = shift;

	return $session->privilege->adminOnly() unless ($session->user->isInGroup(3));

	my $i18n = WebGUI::International->new($session, 'Graphics');	
	
	$output .= '<a href="'.$session->url->page('op=listPalettes').'">'.$i18n->get('manage palettes').'</a><br />';
	$output .= '<a href="'.$session->url->page('op=listFonts').'">'.$i18n->get('manage fonts').'</a><br />';

	return _submenu($session, $output);
}

#-------------------------------------------------------------------
sub www_listPalettes {
	my ($output);
	my $session = shift;

	return $session->privilege->adminOnly() unless ($session->user->isInGroup(3));
	
	my $i18n = WebGUI::International->new($session, 'Graphics');
	
	my $palettes = WebGUI::Image::Palette->getPaletteList($session);
	
	$output .= '<table>';
	$output .= '<th><td>'.$i18n->get('palette name').'</td></th>';
	foreach (keys %$palettes) {
		$output .= '<tr>';
		$output .= '<td>';
		$output .= $session->icon->delete('op=deletePalette&pid='.$_);
		$output .= $session->icon->edit('op=editPalette&pid='.$_);
		$output .= '</td>';
		$output .= '<td>'.$palettes->{$_}.'</td>';
		$output .= '</tr>';
	}
	$output .= '</table>';

	$output .= '<a href="'.$session->url->page('op=editPalette&pid=new').'">'.$i18n->get('add color').'</a><br>';

	return _submenu($session, $output);
}

#-------------------------------------------------------------------
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
sub www_listFonts {
	my ($output);
	my $session = shift;

	return $session->privilege->adminOnly() unless ($session->user->isInGroup(3));

	my $i18n = WebGUI::International->new($session, 'Graphics');
	
	my %fonts = $session->db->buildHash('select fontId, name from imageFont');
	
	$output .= '<table>';
	$output .= '<th><td></td><td>'.$i18n->get('font name').'</td></th>';
	foreach (keys %fonts) {
		$output .= '<tr>';
		$output .= '<td>';
		$output .= $session->icon->delete('op=deleteFont&fid='.$_);
#		$output .= $session->icon->edit('op=editFont&fid='.$_);
		$output .= '</td>';
		$output .= '<td>'.$fonts{$_}.'</td>';
		$output .= '</tr>';
	}
	$output .= '</table>';

	$output .= '<a href="'.$session->url->page('op=editFont&fid=new').'">'.$i18n->get('add font').'</a><br>';

	return _submenu($session, $output);
}

#-------------------------------------------------------------------
sub www_removeColorFromPalette {
	my $session = shift;

	return $session->privilege->adminOnly() unless ($session->user->isInGroup(3));
	
	my $palette = WebGUI::Image::Palette->new($session, $session->form->process('pid'));
	$palette->removeColor($session->form->process('index'));

	return www_editPalette($session, $session->form->process('pid'));
}

1;

