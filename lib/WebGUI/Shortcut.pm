package WebGUI::Shortcut;




#####################################################################
#####################################################################
# NOTICE: Use of this subsystem is depricated and is not recommended.
#####################################################################
#####################################################################





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
use WebGUI::Attachment;
use WebGUI::International;
use WebGUI::Session;
use WebGUI::URL;

our @ISA = qw(Exporter);
our @EXPORT = qw(&attachmentBox &formHeader &formSave &tableFormRow &helpLink);

# The subroutines found herein do nothing other than creating a
# short way of doing much longer repetitive tasks. They simply
# make the programmer's life easier through fewer keystrokes and
# less cluttered code.


#-------------------------------------------------------------------
sub attachmentBox {
	my ($output, $attachment);
	$attachment = WebGUI::Attachment->new($_[0],$_[1],$_[2]);
	$output = '<p><table cellpadding=3 cellspacing=0 border=1><tr><td class="tableHeader">'.
		'<a href="'.$attachment->getURL.'"><img src="'.$session{setting}{lib}.
		'/attachment.gif" border=0 alt="'.
		$attachment->getFilename.'"></a></td><td><a href="'.$attachment->getURL.
		'"><img src="'.$attachment->getIcon.
		'" align="middle" width="16" height="16" border="0" alt="'.$attachment->getFilename
		.'">'.$attachment->getFilename.'</a></td></tr></table>';
	return $output;
}

#-------------------------------------------------------------------
sub formHeader {
        my ($output);
	$output = '<form method="post" enctype="multipart/form-data" action="'.WebGUI::URL::page().'">';
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
	$output = '<a href="'.WebGUI::URL::page('op=viewHelp&hid='.$_[0].'&namespace='.$namespace).
		'" target="_blank"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a>';
	return $output;
}

#-------------------------------------------------------------------
sub tableFormRow {
        my ($output);
	$output = '<tr><td class="formDescription" valign="top">'.$_[0].'</td><td>'.$_[1].'</td></tr>';
        return $output;
}


1;

