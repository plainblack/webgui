package WebGUI::Shortcut;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black Software.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use Exporter;
use strict;
use WebGUI::International;
use WebGUI::Session;

our @ISA = qw(Exporter);
our @EXPORT = qw(&formHeader &formSave &tableFormRow &helpLink);

# The subroutines found herein do nothing other than creating a
# short way of doing much longer repetitive tasks. They simply
# make the programmer's life easier through fewer keystrokes and
# less cluttered code.


#-------------------------------------------------------------------
sub formHeader {
        my ($output);
	$output = '<form method="post" enctype="multipart/form-data" action="'.$session{page}{url}.'">';
        return $output;
}

#-------------------------------------------------------------------
sub formSave {
        my ($output);
	$output = '<tr><td></td><td>'.WebGUI::Form::submit(WebGUI::International::get(62)).'</td></tr>';
        return $output;
}

#-------------------------------------------------------------------
sub helpLink {
	my ($output, $namespace);
	$namespace = $_[1] || "WebGUI";
	$output = '<a href="'.$session{page}{url}.'?op=viewHelp&hid='.$_[0].'&namespace='.$namespace.'"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a>';
	return $output;
}

#-------------------------------------------------------------------
sub tableFormRow {
        my ($output);
	$output = '<tr><td class="formDescription" valign="top">'.$_[0].'</td><td>'.$_[1].'</td></tr>';
        return $output;
}


1;

