package WebGUI::Icon;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2002 Plain Black Software.
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
our @EXPORT = qw(&helpIcon &becomeIcon &cutIcon &copyIcon &deleteIcon &editIcon &moveUpIcon &moveDownIcon
	&pageIcon &moveTopIcon &moveBottomIcon &viewIcon);

=head1 NAME

 Package WebGUI::Icon

=head1 SYNOPSIS

 use WebGUI::Icon;
 $html = becomeIcon('op=something');
 $html = copyIcon('op=something');
 $html = cutIcon('op=something');
 $html = deleteIcon('op=something');
 $html = editIcon('op=something');
 $html = helpIcon(1,"MyNamespace");
 $html = moveBottomIcon('op=something');
 $html = moveDownIcon('op=something');
 $html = moveTopIcon('op=something');
 $html = moveUpIcon('op=something');
 $html = pageIcon();
 $html = viewIcon('op=something');

=head1 DESCRIPTION

 A package for generating user interface buttons. The subroutines 
 found herein do nothing other than to create a short way of doing 
 much longer repetitive tasks. They simply make the programmer's life 
 easier through fewer keystrokes and less cluttered code.

=head1 METHODS

 These subroutines are available from this package:

=cut

#-------------------------------------------------------------------

=head2 becomeIcon ( urlParameters )

 Generates a button with the word "Become" printed on it.

=item urlParameters 

 Any URL parameters that need to be tacked on to the current URL
 to accomplish whatever function this button represents.

=cut

sub becomeIcon {
        my ($output);
        $output = '<a href="'.WebGUI::URL::page($_[0]).'">';
        $output .= '<img src="'.$session{config}{extras}.'/become.gif" align="middle" border="0" alt="Become"></a>';
        return $output;
}

#-------------------------------------------------------------------

=head2 copyIcon ( urlParameters )

 Generates a button with the word "Copy" printed on it.

=item urlParameters

 Any URL parameters that need to be tacked on to the current URL
 to accomplish whatever function this button represents.

=cut

sub copyIcon {
        my ($output);
        $output = '<a href="'.WebGUI::URL::page($_[0]).'">';
        $output .= '<img src="'.$session{config}{extras}.'/copy.gif" align="middle" border="0" alt="Copy"></a>';
        return $output;
}

#-------------------------------------------------------------------

=head2 cutIcon ( urlParameters )

 Generates a button with the word "Cut" printed on it.

=item urlParameters

 Any URL parameters that need to be tacked on to the current URL
 to accomplish whatever function this button represents.

=cut

sub cutIcon {
        my ($output);
        $output = '<a href="'.WebGUI::URL::page($_[0]).'">';
        $output .= '<img src="'.$session{config}{extras}.'/cut.gif" align="middle" border="0" alt="Cut"></a>';
        return $output;
}

#-------------------------------------------------------------------

=head2 deleteIcon ( urlParameters )

 Generates a button with an "X" printed on it.

=item urlParameters

 Any URL parameters that need to be tacked on to the current URL
 to accomplish whatever function this button represents.

=cut

sub deleteIcon {
	my ($output);
	$output = '<a href="'.WebGUI::URL::page($_[0]).'">';
	$output .= '<img src="'.$session{config}{extras}.'/delete.gif" align="middle" border="0" alt="Delete"></a>';
	return $output;
}

#-------------------------------------------------------------------

=head2 editIcon ( urlParameters )

 Generates a button with the word "Edit" printed on it.

=item urlParameters

 Any URL parameters that need to be tacked on to the current URL
 to accomplish whatever function this button represents.

=cut

sub editIcon {
        my ($output);
        $output = '<a href="'.WebGUI::URL::page($_[0]).'">';
        $output .= '<img src="'.$session{config}{extras}.'/edit.gif" align="middle" border="0" alt="Edit"></a>';
        return $output;
}

#-------------------------------------------------------------------

=head2 becomeIcon ( helpId [, namespace ] )

 Generates a button with the word "Help" printed on it.

=item helpId 

 The id in the help table that relates to the help documentation
 for your function.

=item namespace

 If your help documentation is not in the WebGUI namespace, then
 you must specify the namespace for this help.

=cut

sub helpIcon {
	my ($output, $namespace);
	$namespace = $_[1] || "WebGUI";
	$output = '<a href="'.WebGUI::URL::page('op=viewHelp&hid='.$_[0].'&namespace='.$namespace).
		'" target="_blank"><img src="'.$session{config}{extras}.'/help.gif" border="0" align="right"></a>';
	return $output;
}

#-------------------------------------------------------------------

=head2 moveBottomIcon ( urlParameters )

 Generates a button with a double down arrow printed on it.

=item urlParameters

 Any URL parameters that need to be tacked on to the current URL
 to accomplish whatever function this button represents.

=cut

sub moveBottomIcon {
        my ($output);
        $output = '<a href="'.WebGUI::URL::page($_[0]).'">';
        $output .= '<img src="'.$session{config}{extras}.'/jumpDown.gif" align="middle" border="0" alt="Move To Bottom"></a>';
        return $output;
}

#-------------------------------------------------------------------

=head2 moveDownIcon ( urlParameters )

 Generates a button with a down arrow printed on it.

=item urlParameters

 Any URL parameters that need to be tacked on to the current URL
 to accomplish whatever function this button represents.

=cut

sub moveDownIcon {
        my ($output);
        $output = '<a href="'.WebGUI::URL::page($_[0]).'">';
        $output .= '<img src="'.$session{config}{extras}.'/downArrow.gif" align="middle" border="0" alt="Move Down"></a>';
        return $output;
}

#-------------------------------------------------------------------

=head2 moveTopIcon ( urlParameters )

 Generates a button with a double up arrow printed on it.

=item urlParameters

 Any URL parameters that need to be tacked on to the current URL
 to accomplish whatever function this button represents.

=cut

sub moveTopIcon {
        my ($output);
        $output = '<a href="'.WebGUI::URL::page($_[0]).'">';
        $output .= '<img src="'.$session{config}{extras}.'/jumpUp.gif" align="middle" border="0" alt="Move To Top"></a>';
        return $output;
}

#-------------------------------------------------------------------

=head2 moveUpIcon ( urlParameters )

 Generates a button with an up arrow printed on it.

=item urlParameters

 Any URL parameters that need to be tacked on to the current URL
 to accomplish whatever function this button represents.

=cut

sub moveUpIcon {
        my ($output);
        $output = '<a href="'.WebGUI::URL::page($_[0]).'">';
        $output .= '<img src="'.$session{config}{extras}.'/upArrow.gif" align="middle" border="0" alt="Move Up"></a>';
        return $output;
}

#-------------------------------------------------------------------

=head2 pageIcon ( )

 Generates an icon that looks like a page. It's purpose is to
 represent whether you're looking at page properties or Wobject
 properties. 

=cut

sub pageIcon {
        return '<img src="'.$session{config}{extras}.'/page.gif" align="middle" border="0" alt="Page Settings">';
}

#-------------------------------------------------------------------

=head2 viewIcon ( urlParameters )

 Generates a button with the word "View" printed on it.

=item urlParameters

 Any URL parameters that need to be tacked on to the current URL
 to accomplish whatever function this button represents.

=cut

sub viewIcon {
        my ($output);
        $output = '<a href="'.WebGUI::URL::page($_[0]).'">';
        $output .= '<img src="'.$session{config}{extras}.'/view.gif" align="middle" border="0" alt="View"></a>';
        return $output;
}



1;

