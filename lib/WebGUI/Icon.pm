package WebGUI::Icon;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2005 Plain Black Corporation.
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
use WebGUI::International;
use WebGUI::Session;
use WebGUI::URL;

our @ISA = qw(Exporter);
our @EXPORT = qw(&helpIcon &becomeIcon &cutIcon &copyIcon &deleteIcon &editIcon &manageIcon
	&moveBottomIcon &moveDownIcon &moveLeftIcon &moveRightIcon &moveTopIcon &moveUpIcon &lockedIcon
	&pageIcon &dragIcon &shortcutIcon &pasteIcon &wobjectIcon &viewIcon &exportIcon);

=head1 NAME

Package WebGUI::Icon

=head1 DESCRIPTION

A package for generating user interface buttons. The subroutines found herein do nothing other than to create a short way of doing much longer repetitive tasks. They simply make the programmer's life easier through fewer keystrokes and less cluttered code.

=head1 SYNOPSIS

 use WebGUI::Icon;
 $html = copyIcon('op=something');
 $html = cutIcon('op=something');
 $html = deleteIcon('op=something');
 $html = dragIcon();
 $html = editIcon('op=something');
 $html = helpIcon(1,"MyNamespace");
 $html = manageIcon('op=something');
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

 $hashRef = getToolbarOptions();

=head1 METHODS

These subroutines are available from this package:

=cut

#-------------------------------------------------------------------

=head2 _getBaseURL ( )

Returns the base URL for this user's toolbar.

=cut

sub _getBaseURL {
	my $url = $session{config}{extrasURL}.'/toolbar/';
	if ($session{user}{toolbar} ne "useLanguageDefault") {
		$url .= $session{user}{toolbar};
	} else {
		$url .= WebGUI::International::getLanguage($session{user}{language},"toolbar");
	}
	$url .= '/';	
	return $url;
}


#-------------------------------------------------------------------

=head2 copyIcon ( urlParameters [, pageURL ] )

Generates a button with the word "Copy" printed on it.

=head3 urlParameters

Any URL parameters that need to be tacked on to the current URL to accomplish whatever function this button represents.

=head3 pageURL

The URL to any page. Defaults to the current page.

=cut

sub copyIcon {
        my ($output, $pageURL);
        $pageURL = $_[1] || $session{wguri};
        $output = '<a href="'.WebGUI::URL::gateway($pageURL,$_[0]).'">';
        $output .= '<img src="'._getBaseURL().'copy.gif" align="middle" border="0" alt="'.WebGUI::International::get('Copy','Icon').'" title="'.WebGUI::International::get('Copy','Icon').'" /></a>';
        return $output;
}

#-------------------------------------------------------------------

=head2 cutIcon ( urlParameters [, pageURL ] )

Generates a button with the word "Cut" printed on it.

=head3 urlParameters

Any URL parameters that need to be tacked on to the current URL to accomplish whatever function this button represents.

=head3 pageURL

The URL to any page. Defaults to the current page.

=cut

sub cutIcon {
        my ($output, $pageURL);
        $pageURL = $_[1] || $session{wguri};
        $output = '<a href="'.WebGUI::URL::gateway($pageURL,$_[0]).'">';
        $output .= '<img src="'._getBaseURL().'cut.gif" align="middle" border="0" alt="'.WebGUI::International::get('Cut','Icon').'" title="'.WebGUI::International::get('Cut','Icon').'" /></a>';
        return $output;
}

#-------------------------------------------------------------------

=head2 deleteIcon ( urlParameters [, pageURL, confirmText ] )

Generates a button that represents a delete operation.

=head3 urlParameters

Any URL parameters that need to be tacked on to the current URL to accomplish whatever function this button represents.

=head3 pageURL

The URL to any page. Defaults to the current page.

=head3 confirmText 

If defined, a confirm box will popup to ask the user if they want to delete.

=cut

sub deleteIcon {
        my ($output, $pageURL, $confirmText);
	$confirmText = $_[2];
	if($confirmText) {
		$confirmText = qq| onclick="return confirm('$confirmText')" |;
	}
	
        $pageURL = $_[1] || $session{wguri};
	
        $output = '<a href="'.WebGUI::URL::gateway($pageURL,$_[0]).'" '.$confirmText.'>';
	$output .= '<img src="'._getBaseURL().'delete.gif" align="middle" border="0" alt="'.WebGUI::International::get('Delete','Icon').'" title="'.WebGUI::International::get('Delete','Icon').'" /></a>';
	return $output;
}

#-------------------------------------------------------------------

=head2 dragIcon ( )

Generates an icon that can be used to drag content.

=cut

sub dragIcon {
        return '<img id="dragTrigger" class="dragTrigger" src="'._getBaseURL().'drag.gif" align="middle" border="0" alt="'.WebGUI::International::get('Drag','Icon').'" title="'.WebGUI::International::get('Drag','Icon').'" />';
}

#-------------------------------------------------------------------

=head2 editIcon ( urlParameters [, pageURL ] )

Generates a button with the word "Edit" printed on it.

=head3 urlParameters

Any URL parameters that need to be tacked on to the current URL to accomplish whatever function this button represents.

=head3 pageURL

The URL to any page. Defaults to the current page.

=cut

sub editIcon {
        my ($output, $pageURL);
        $pageURL = $_[1] || $session{wguri};
        $output = '<a href="'.WebGUI::URL::gateway($pageURL,$_[0]).'">';
        $output .= '<img src="'._getBaseURL().'edit.gif" align="middle" border="0" alt="'.WebGUI::International::get('Edit','Icon').'" title="'.WebGUI::International::get('Edit','Icon').'" /></a>';
        return $output;
}

#-------------------------------------------------------------------

=head2 exportIcon ( urlParameters [, pageURL ] )

Generates an export button.

=head3 urlParameters

Any URL parameters that need to be tacked on to the current URL to accomplish whatever function this button represents.

=head3 pageURL

The URL to any page. Defaults to the current page.

=cut

sub exportIcon {
        my ($output, $pageURL);
        $pageURL = $_[1] || $session{wguri};
        $output = '<a href="'.WebGUI::URL::gateway($pageURL,$_[0]).'">';
	# TODO Change icon to Jeffs export icon
        $output .= '<img src="'._getBaseURL().'export.gif" align="middle" border="0" alt="'.WebGUI::International::get('Export','Icon').'" title="'.WebGUI::International::get('Export','Icon').'" /></a>';
        return $output;
}

#-------------------------------------------------------------------

=head2 getToolbarOptions ( )

Returns a hash reference containing the list of toolbar icon sets to be selected in user profile.

=cut

sub getToolbarOptions {
	my %options;
	tie %options, 'Tie::IxHash';
	$options{useLanguageDefault} = WebGUI::International::get(1084);
	my $dir = $session{config}{extrasPath}.$session{os}{slash}."toolbar";
        opendir (DIR,$dir) or WebGUI::ErrorHandler::warn("Can't open toolbar directory!");
        my @files = readdir(DIR);
        foreach my $file (@files) {
                if ($file ne ".." && $file ne ".") {
                        $options{$file} = $file;
                }
        }
        closedir(DIR);
	return \%options;
}

#-------------------------------------------------------------------

=head2 helpIcon ( helpId [, namespace ] )

Generates a button with the word "Help" printed on it.

=head3 helpId 

The id in the help table that relates to the help documentation for your function.

=head3 namespace

If your help documentation is not in the WebGUI namespace, then you must specify the namespace for this help.

=cut

sub helpIcon {
	my ($output, $namespace);
	$namespace = $_[1] || "WebGUI";
	$output = '<a href="'.WebGUI::URL::page('op=viewHelp;hid='.$_[0].';namespace='.$namespace).
		'" target="_blank"><img src="'._getBaseURL().'help.gif" border="0" align="right" title="'.WebGUI::International::get('Help','Icon').'" Alt="'.WebGUI::International::get('Help','Icon').'"></a>';
	return $output;
}

#-------------------------------------------------------------------

=head2 lockedIcon ( urlParameters [, pageURL ] )

Generates a button that represents a management function. Is toggled out in place of the edit icon when an asset is locked.

=head3 urlParameters

Any URL parameters that need to be tacked on to the current URL to accomplish whatever function this button represents.

=head3 pageURL

The URL to any page. Defaults to the current page.

=cut

sub lockedIcon {
        my ($output, $pageURL);
        $pageURL = $_[1] || $session{wguri};
        $output = '<a href="'.WebGUI::URL::gateway($pageURL,$_[0]).'">';
        $output .= '<img src="'._getBaseURL().'locked.gif" align="middle" border="0" alt="'.WebGUI::International::get('locked','Icon').'" title="'.WebGUI::International::get('locked','Icon').'" /></a>';
        return $output;
}

#-------------------------------------------------------------------

=head2 manageIcon ( urlParameters [, pageURL ] )

Generates a button that represents a management function.

=head3 urlParameters

Any URL parameters that need to be tacked on to the current URL to accomplish whatever function this button represents.

=head3 pageURL

The URL to any page. Defaults to the current page.

=cut

sub manageIcon {
        my ($output, $pageURL);
        $pageURL = $_[1] || $session{wguri};
        $output = '<a href="'.WebGUI::URL::gateway($pageURL,$_[0]).'">';
        $output .= '<img src="'._getBaseURL().'manage.gif" align="middle" border="0" alt="'.WebGUI::International::get('Manage','Icon').'" title="'.WebGUI::International::get('Manage','Icon').'" /></a>';
        return $output;
}

#-------------------------------------------------------------------

=head2 moveBottomIcon ( urlParameters [, pageURL ] )

Generates a button with a double down arrow printed on it.

=head3 urlParameters

Any URL parameters that need to be tacked on to the current URL to accomplish whatever function this button represents.

=head3 pageURL

The URL to any page. Defaults to the current page.

=cut

sub moveBottomIcon {
        my ($output, $pageURL);
        $pageURL = $_[1] || $session{wguri};
        $output = '<a href="'.WebGUI::URL::gateway($pageURL,$_[0]).'">';
        $output .= '<img src="'._getBaseURL().'moveBottom.gif" align="middle" border="0" alt="'.WebGUI::International::get('Move To Bottom','Icon').'" title="'.WebGUI::International::get('Move To Bottom','Icon').'" /></a>';
        return $output;
}

#-------------------------------------------------------------------

=head2 moveDownIcon ( urlParameters [, pageURL ] )

Generates a button with a down arrow printed on it.

=head3 urlParameters

Any URL parameters that need to be tacked on to the current URL to accomplish whatever function this button represents.

=head3 pageURL

The URL to any page. Defaults to the current page.

=cut

sub moveDownIcon {
        my ($output, $pageURL);
        $pageURL = $_[1] || $session{wguri};
        $output = '<a href="'.WebGUI::URL::gateway($pageURL,$_[0]).'">';
        $output .= '<img src="'._getBaseURL().'moveDown.gif" align="middle" border="0" alt="'.WebGUI::International::get('Move Down','Icon').'" title="'.WebGUI::International::get('Move Down','Icon').'" /></a>';
        return $output;
}

#-------------------------------------------------------------------

=head2 moveLeftIcon ( urlParameters [, pageURL ] )

Generates a button with a left arrow printed on it.

=head3 urlParameters

Any URL parameters that need to be tacked on to the current URL to accomplish whatever function this button represents.

=head3 pageURL

The URL to any page. Defaults to the current page.

=cut

sub moveLeftIcon {
        my ($output, $pageURL);
        $pageURL = $_[1] || $session{wguri};
        $output = '<a href="'.WebGUI::URL::gateway($pageURL,$_[0]).'">';
        $output .= '<img src="'._getBaseURL().'moveLeft.gif" align="middle" border="0" alt="'.WebGUI::International::get('Move Left','Icon').'" title="'.WebGUI::International::get('Move Left','Icon').'" /></a>';
        return $output;
}

#-------------------------------------------------------------------

=head2 moveRightIcon ( urlParameters [, pageURL ] )

Generates a button with a right arrow printed on it.

=head3 urlParameters

Any URL parameters that need to be tacked on to the current URL to accomplish whatever function this button represents.

=head3 pageURL

The URL to any page. Defaults to the current page.

=cut

sub moveRightIcon {
        my ($output, $pageURL);
        $pageURL = $_[1] || $session{wguri};
        $output = '<a href="'.WebGUI::URL::gateway($pageURL,$_[0]).'">';
        $output .= '<img src="'._getBaseURL().'moveRight.gif" align="middle" border="0" alt="'.WebGUI::International::get('Move Right','Icon').'" title="'.WebGUI::International::get('Move Right','Icon').'" /></a>';
        return $output;
}

#-------------------------------------------------------------------

=head2 moveTopIcon ( urlParameters [, pageURL ] )

Generates a button with a double up arrow printed on it.

=head3 urlParameters

Any URL parameters that need to be tacked on to the current URL to accomplish whatever function this button represents.

=head3 pageURL

The URL to any page. Defaults to the current page.

=cut

sub moveTopIcon {
        my ($output, $pageURL);
        $pageURL = $_[1] || $session{wguri};
        $output = '<a href="'.WebGUI::URL::gateway($pageURL,$_[0]).'">';
        $output .= '<img src="'._getBaseURL().'moveTop.gif" align="middle" border="0" alt="'.WebGUI::International::get('Move To Top','Icon').'" title="'.WebGUI::International::get('Move To Top','Icon').'" /></a>';
        return $output;
}

#-------------------------------------------------------------------

=head2 moveUpIcon ( urlParameters [, pageURL ] )

Generates a button with an up arrow printed on it.

=head3 urlParameters

Any URL parameters that need to be tacked on to the current URL to accomplish whatever function this button represents.

=head3 pageURL

The URL to any page. Defaults to the current page.

=cut

sub moveUpIcon {
        my ($output, $pageURL);
        $pageURL = $_[1] || $session{wguri};
        $output = '<a href="'.WebGUI::URL::gateway($pageURL,$_[0]).'">';
        $output .= '<img src="'._getBaseURL().'moveUp.gif" align="middle" border="0" alt="'.WebGUI::International::get('Move Up','Icon').'" title="'.WebGUI::International::get('Move Up','Icon').'" /></a>';
        return $output;
}

#-------------------------------------------------------------------

=head2 pageIcon ( )

Generates an icon that looks like a page. It's purpose is to represent whether you're looking at page properties or Wobject properties. 

=cut

sub pageIcon {
        return '<img src="'._getBaseURL().'page.gif" align="middle" border="0" alt="'.WebGUI::International::get('Page Settings','Icon').'" title="'.WebGUI::International::get('Page Settings','Icon').'" />';
}

#-------------------------------------------------------------------

=head2 pasteIcon ( urlParameters [, pageURL ] )

Generates a button with the word "Paste" printed on it.

=head3 urlParameters

Any URL parameters that need to be tacked on to the current URL to accomplish whatever function this button represents.

=head3 pageURL

The URL to any page. Defaults to the current page.

=cut

sub pasteIcon {
        my ($output, $pageURL);
        $pageURL = $_[1] || $session{wguri};
        $output = '<a href="'.WebGUI::URL::gateway($pageURL,$_[0]).'">';
        $output .= '<img src="'._getBaseURL().'paste.gif" align="middle" border="0" alt="'.WebGUI::International::get('Paste','Icon').'" title="'.WebGUI::International::get('Paste','Icon').'" /></a>';
        return $output;
}

#-------------------------------------------------------------------

=head2 shortcutIcon ( urlParameters [, pageURL ] )

Generates a button with a shortcut symbol printed on it, similar to the shortcut icon in Microsoft Windows or the link Icon in Gnome.

=head3 urlParameters

Any URL parameters that need to be tacked on to the current URL to accomplish whatever function this button represents.

=head3 pageURL

The URL to any page. Defaults to the current page.

=cut

sub shortcutIcon {
        my ($output, $pageURL);
        $pageURL = $_[1] || $session{wguri};
        $output = '<a href="'.WebGUI::URL::gateway($pageURL,$_[0]).'">';
        $output .= '<img src="'._getBaseURL().'shortcut.gif" align="middle" border="0" alt="'.WebGUI::International::get('Create Shortcut','Icon').'" title="'.WebGUI::International::get('Create Shortcut','Icon').'" /></a>';
        return $output;
}

#-------------------------------------------------------------------

=head2 viewIcon ( urlParameters [, pageURL ] )

Generates a button with the word "View" printed on it.

=head3 urlParameters

Any URL parameters that need to be tacked on to the current URL to accomplish whatever function this button represents.

=head3 pageURL

The URL to any page. Defaults to the current page.

=cut

sub viewIcon {
        my ($output, $pageURL);
        $pageURL = $_[1] || $session{wguri};
        $output = '<a href="'.WebGUI::URL::gateway($pageURL,$_[0]).'">';
        $output .= '<img src="'._getBaseURL().'view.gif" align="middle" border="0" alt="'.WebGUI::International::get('View','Icon').'" title="'.WebGUI::International::get('View','Icon').'" /></a>';
        return $output;
}

#-------------------------------------------------------------------

=head2 wobjectIcon ( )

Generates an icon that looks like a wobject. It's purpose is to represent whether you're looking at page properties or Wobject properties.

=cut

sub wobjectIcon {
        return '<img src="'._getBaseURL().'wobject.gif" align="middle" border="0" alt="'.WebGUI::International::get('Wobject Settings','Icon').'" title="'.WebGUI::International::get('Wobject Settings','Icon').'" />';
}



1;

