package WebGUI::Icon;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2003 Plain Black LLC.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use Exporter;
use strict;
use WebGUI::Session;
use WebGUI::URL;

our @ISA = qw(Exporter);
our @EXPORT = qw(&helpIcon &becomeIcon &cutIcon &copyIcon &deleteIcon &editIcon
	&moveBottomIcon &moveDownIcon &moveLeftIcon &moveRightIcon &moveTopIcon &moveUpIcon
	&pageIcon &shortcutIcon &pasteIcon &wobjectIcon &viewIcon);

=head1 NAME

Package WebGUI::Icon

=head1 DESCRIPTION

A package for generating user interface buttons. The subroutines found herein do nothing other than to create a short way of doing much longer repetitive tasks. They simply make the programmer's life easier through fewer keystrokes and less cluttered code.

=head1 SYNOPSIS

 use WebGUI::Icon;
 $html = copyIcon('op=something');
 $html = cutIcon('op=something');
 $html = deleteIcon('op=something');
 $html = editIcon('op=something');
 $html = helpIcon(1,"MyNamespace");
 $html = moveBottomIcon('op=something');
 $html = moveDownIcon('op=something');
 $html = moveLeftIcon('op=something');
 $html = moveRightIcon('op=something');
 $html = moveTopIcon('op=something');
 $html = moveUpIcon('op=something');
 $html = pageIcon();
 $html = pasteIcon('op=something');
 $html = shortcutIcon('op=something');
 $html = viewIcon('op=something');
 $html = wobjectIcon();

=head1 METHODS

These subroutines are available from this package:

=cut

#-------------------------------------------------------------------

=head2 copyIcon ( urlParameters [, pageURL ] )

Generates a button with the word "Copy" printed on it.

=over

=item urlParameters

Any URL parameters that need to be tacked on to the current URL to accomplish whatever function this button represents.

=item pageURL

The URL to any page. Defaults to the current page.

=back

=cut

sub copyIcon {
        my ($output, $pageURL);
        $pageURL = $_[1] || $session{page}{urlizedTitle};
        $output = '<a href="'.WebGUI::URL::gateway($pageURL,$_[0]).'">';
        $output .= '<img src="'.$session{config}{extrasURL}.'/toolbar/'.$session{language}{toolbar}.'/copy.gif" align="middle" border="0" alt="Copy" title="Copy" /></a>';
        return $output;
}

#-------------------------------------------------------------------

=head2 cutIcon ( urlParameters [, pageURL ] )

Generates a button with the word "Cut" printed on it.

=over

=item urlParameters

Any URL parameters that need to be tacked on to the current URL to accomplish whatever function this button represents.

=item pageURL

The URL to any page. Defaults to the current page.

=back

=cut

sub cutIcon {
        my ($output, $pageURL);
        $pageURL = $_[1] || $session{page}{urlizedTitle};
        $output = '<a href="'.WebGUI::URL::gateway($pageURL,$_[0]).'">';
        $output .= '<img src="'.$session{config}{extrasURL}.'/toolbar/'.$session{language}{toolbar}.'/cut.gif" align="middle" border="0" alt="Cut" title="Cut" /></a>';
        return $output;
}

#-------------------------------------------------------------------

=head2 deleteIcon ( urlParameters [, pageURL ] )

Generates a button with an "X" printed on it.

=over

=item urlParameters

Any URL parameters that need to be tacked on to the current URL to accomplish whatever function this button represents.

=item pageURL

The URL to any page. Defaults to the current page.

=back

=cut

sub deleteIcon {
        my ($output, $pageURL);
        $pageURL = $_[1] || $session{page}{urlizedTitle};
        $output = '<a href="'.WebGUI::URL::gateway($pageURL,$_[0]).'">';
	$output .= '<img src="'.$session{config}{extrasURL}.'/toolbar/'.$session{language}{toolbar}.'/delete.gif" align="middle" border="0" alt="Delete" title="Delete" /></a>';
	return $output;
}

#-------------------------------------------------------------------

=head2 editIcon ( urlParameters [, pageURL ] )

Generates a button with the word "Edit" printed on it.

=over

=item urlParameters

Any URL parameters that need to be tacked on to the current URL to accomplish whatever function this button represents.

=item pageURL

The URL to any page. Defaults to the current page.

=back

=cut

sub editIcon {
        my ($output, $pageURL);
        $pageURL = $_[1] || $session{page}{urlizedTitle};
        $output = '<a href="'.WebGUI::URL::gateway($pageURL,$_[0]).'">';
        $output .= '<img src="'.$session{config}{extrasURL}.'/toolbar/'.$session{language}{toolbar}.'/edit.gif" align="middle" border="0" alt="Edit" title="Edit" /></a>';
        return $output;
}

#-------------------------------------------------------------------

=head2 helpIcon ( helpId [, namespace ] )

Generates a button with the word "Help" printed on it.

=over

=item helpId 

The id in the help table that relates to the help documentation for your function.

=item namespace

If your help documentation is not in the WebGUI namespace, then you must specify the namespace for this help.

=back

=cut

sub helpIcon {
	my ($output, $namespace);
	$namespace = $_[1] || "WebGUI";
	$output = '<a href="'.WebGUI::URL::page('op=viewHelp&hid='.$_[0].'&namespace='.$namespace).
		'" target="_blank"><img src="'.$session{config}{extrasURL}.'/toolbar/'.$session{language}{toolbar}.'/help.gif" border="0" align="right"></a>';
	return $output;
}

#-------------------------------------------------------------------

=head2 moveBottomIcon ( urlParameters [, pageURL ] )

Generates a button with a double down arrow printed on it.

=over

=item urlParameters

Any URL parameters that need to be tacked on to the current URL to accomplish whatever function this button represents.

=item pageURL

The URL to any page. Defaults to the current page.

=back

=cut

sub moveBottomIcon {
        my ($output, $pageURL);
        $pageURL = $_[1] || $session{page}{urlizedTitle};
        $output = '<a href="'.WebGUI::URL::gateway($pageURL,$_[0]).'">';
        $output .= '<img src="'.$session{config}{extrasURL}.'/toolbar/'.$session{language}{toolbar}.'/moveBottom.gif" align="middle" border="0" alt="Move To Bottom" title="Move To Bottom" /></a>';
        return $output;
}

#-------------------------------------------------------------------

=head2 moveDownIcon ( urlParameters [, pageURL ] )

Generates a button with a down arrow printed on it.

=over

=item urlParameters

Any URL parameters that need to be tacked on to the current URL to accomplish whatever function this button represents.

=item pageURL

The URL to any page. Defaults to the current page.

=back

=cut

sub moveDownIcon {
        my ($output, $pageURL);
        $pageURL = $_[1] || $session{page}{urlizedTitle};
        $output = '<a href="'.WebGUI::URL::gateway($pageURL,$_[0]).'">';
        $output .= '<img src="'.$session{config}{extrasURL}.'/toolbar/'.$session{language}{toolbar}.'/moveDown.gif" align="middle" border="0" alt="Move Down" title="Move Down" /></a>';
        return $output;
}

#-------------------------------------------------------------------

=head2 moveLeftIcon ( urlParameters [, pageURL ] )

Generates a button with a left arrow printed on it.

=over

=item urlParameters

Any URL parameters that need to be tacked on to the current URL to accomplish whatever function this button represents.

=item pageURL

The URL to any page. Defaults to the current page.

=back

=cut

sub moveLeftIcon {
        my ($output, $pageURL);
        $pageURL = $_[1] || $session{page}{urlizedTitle};
        $output = '<a href="'.WebGUI::URL::gateway($pageURL,$_[0]).'">';
        $output .= '<img src="'.$session{config}{extrasURL}.'/toolbar/'.$session{language}{toolbar}.'/moveLeft.gif" align="middle" border="0" alt="Move Left" title="Move Left" /></a>';
        return $output;
}

#-------------------------------------------------------------------

=head2 moveRightIcon ( urlParameters [, pageURL ] )

Generates a button with a right arrow printed on it.

=over

=item urlParameters

Any URL parameters that need to be tacked on to the current URL to accomplish whatever function this button represents.

=item pageURL

The URL to any page. Defaults to the current page.

=back

=cut

sub moveRightIcon {
        my ($output, $pageURL);
        $pageURL = $_[1] || $session{page}{urlizedTitle};
        $output = '<a href="'.WebGUI::URL::gateway($pageURL,$_[0]).'">';
        $output .= '<img src="'.$session{config}{extrasURL}.'/toolbar/'.$session{language}{toolbar}.'/moveRight.gif" align="middle" border="0" alt="Move Right" title="Move Right" /></a>';
        return $output;
}

#-------------------------------------------------------------------

=head2 moveTopIcon ( urlParameters [, pageURL ] )

Generates a button with a double up arrow printed on it.

=over

=item urlParameters

Any URL parameters that need to be tacked on to the current URL to accomplish whatever function this button represents.

=item pageURL

The URL to any page. Defaults to the current page.

=back

=cut

sub moveTopIcon {
        my ($output, $pageURL);
        $pageURL = $_[1] || $session{page}{urlizedTitle};
        $output = '<a href="'.WebGUI::URL::gateway($pageURL,$_[0]).'">';
        $output .= '<img src="'.$session{config}{extrasURL}.'/toolbar/'.$session{language}{toolbar}.'/moveTop.gif" align="middle" border="0" alt="Move To Top" title="Move To Top" /></a>';
        return $output;
}

#-------------------------------------------------------------------

=head2 moveUpIcon ( urlParameters [, pageURL ] )

Generates a button with an up arrow printed on it.

=over

=item urlParameters

Any URL parameters that need to be tacked on to the current URL to accomplish whatever function this button represents.

=item pageURL

The URL to any page. Defaults to the current page.

=back

=cut

sub moveUpIcon {
        my ($output, $pageURL);
        $pageURL = $_[1] || $session{page}{urlizedTitle};
        $output = '<a href="'.WebGUI::URL::gateway($pageURL,$_[0]).'">';
        $output .= '<img src="'.$session{config}{extrasURL}.'/toolbar/'.$session{language}{toolbar}.'/moveUp.gif" align="middle" border="0" alt="Move Up" title="Move Up" /></a>';
        return $output;
}

#-------------------------------------------------------------------

=head2 pageIcon ( )

Generates an icon that looks like a page. It's purpose is to represent whether you're looking at page properties or Wobject properties. 

=cut

sub pageIcon {
        return '<img src="'.$session{config}{extrasURL}.'/toolbar/'.$session{language}{toolbar}.'/page.gif" align="middle" border="0" alt="Page Settings" title="Page Settings" />';
}

#-------------------------------------------------------------------

=head2 pasteIcon ( urlParameters [, pageURL ] )

Generates a button with the word "Paste" printed on it.

=over

=item urlParameters

Any URL parameters that need to be tacked on to the current URL to accomplish whatever function this button represents.

=item pageURL

The URL to any page. Defaults to the current page.

=back

=cut

sub pasteIcon {
        my ($output, $pageURL);
        $pageURL = $_[1] || $session{page}{urlizedTitle};
        $output = '<a href="'.WebGUI::URL::gateway($pageURL,$_[0]).'">';
        $output .= '<img src="'.$session{config}{extrasURL}.'/toolbar/'.$session{language}{toolbar}.'/paste.gif" align="middle" border="0" alt="Paste" title="Paste" /></a>';
        return $output;
}

#-------------------------------------------------------------------

=head2 shortcutIcon ( urlParameters [, pageURL ] )

Generates a button with a shortcut symbol printed on it, similar to the shortcut icon in Microsoft Windows or the link Icon in Gnome.

=over

=item urlParameters

Any URL parameters that need to be tacked on to the current URL to accomplish whatever function this button represents.

=item pageURL

The URL to any page. Defaults to the current page.

=back

=cut

sub shortcutIcon {
        my ($output, $pageURL);
        $pageURL = $_[1] || $session{page}{urlizedTitle};
        $output = '<a href="'.WebGUI::URL::gateway($pageURL,$_[0]).'">';
        $output .= '<img src="'.$session{config}{extrasURL}.'/toolbar/'.$session{language}{toolbar}.'/shortcut.gif" align="middle" border="0" alt="Shortcut" title="Create Shortcut" /></a>';
        return $output;
}

#-------------------------------------------------------------------

=head2 viewIcon ( urlParameters [, pageURL ] )

Generates a button with the word "View" printed on it.

=over

=item urlParameters

Any URL parameters that need to be tacked on to the current URL to accomplish whatever function this button represents.

=item pageURL

The URL to any page. Defaults to the current page.

=back

=cut

sub viewIcon {
        my ($output, $pageURL);
        $pageURL = $_[1] || $session{page}{urlizedTitle};
        $output = '<a href="'.WebGUI::URL::gateway($pageURL,$_[0]).'">';
        $output .= '<img src="'.$session{config}{extrasURL}.'/toolbar/'.$session{language}{toolbar}.'/view.gif" align="middle" border="0" alt="View" title="View" /></a>';
        return $output;
}

#-------------------------------------------------------------------

=head2 wobjectIcon ( )

Generates an icon that looks like a wobject. It's purpose is to represent whether you're looking at page properties or Wobject properties.

=cut

sub wobjectIcon {
        return '<img src="'.$session{config}{extrasURL}.'/toolbar/'.$session{language}{toolbar}.'/wobject.gif" align="middle" border="0" alt="Wobject Settings" title="Wobject Settings" />';
}



1;

