package WebGUI::Icon;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2004 Plain Black LLC.
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
	&moveBottomIcon &moveDownIcon &moveLeftIcon &moveRightIcon &moveTopIcon &moveUpIcon
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
        $output .= '<img src="'._getBaseURL().'copy.gif" align="middle" border="0" alt="Copy" title="Copy" /></a>';
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
        $output .= '<img src="'._getBaseURL().'cut.gif" align="middle" border="0" alt="Cut" title="Cut" /></a>';
        return $output;
}

#-------------------------------------------------------------------

=head2 deleteIcon ( urlParameters [, pageURL ] )

Generates a button that represents a delete operation.

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
	$output .= '<img src="'._getBaseURL().'delete.gif" align="middle" border="0" alt="Delete" title="Delete" /></a>';
	return $output;
}

#-------------------------------------------------------------------

=head2 dragIcon ( )

Generates an icon that can be used to drag content.

=cut

sub dragIcon {
        return '<img id="dragTrigger" class="dragTrigger" src="'._getBaseURL().'drag.gif" align="middle" border="0" alt="Drag" title="Drag" />';
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
        $output .= '<img src="'._getBaseURL().'edit.gif" align="middle" border="0" alt="Edit" title="Edit" /></a>';
        return $output;
}

#-------------------------------------------------------------------

=head2 exportIcon ( urlParameters [, pageURL ] )

Generates an export button.

=over

=item urlParameters

Any URL parameters that need to be tacked on to the current URL to accomplish whatever function this button represents.

=item pageURL

The URL to any page. Defaults to the current page.

=back

=cut

sub exportIcon {
        my ($output, $pageURL);
        $pageURL = $_[1] || $session{page}{urlizedTitle};
        $output = '<a href="'.WebGUI::URL::gateway($pageURL,$_[0]).'">';
	# TODO Change icon to Jeffs export icon
        $output .= '<img src="'._getBaseURL().'export.gif" align="middle" border="0" alt="Export" title="Export" /></a>';
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
		'" target="_blank"><img src="'._getBaseURL().'help.gif" border="0" align="right" title="Help" Alt="Help"></a>';
	return $output;
}

#-------------------------------------------------------------------

=head2 manageIcon ( urlParameters [, pageURL ] )

Generates a button that represents a management function.

=over

=item urlParameters

Any URL parameters that need to be tacked on to the current URL to accomplish whatever function this button represents.

=item pageURL

The URL to any page. Defaults to the current page.

=back

=cut

sub manageIcon {
        my ($output, $pageURL);
        $pageURL = $_[1] || $session{page}{urlizedTitle};
        $output = '<a href="'.WebGUI::URL::gateway($pageURL,$_[0]).'">';
        $output .= '<img src="'._getBaseURL().'manage.gif" align="middle" border="0" alt="Manage" title="Manage" /></a>';
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
        $output .= '<img src="'._getBaseURL().'moveBottom.gif" align="middle" border="0" alt="Move To Bottom" title="Move To Bottom" /></a>';
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
        $output .= '<img src="'._getBaseURL().'moveDown.gif" align="middle" border="0" alt="Move Down" title="Move Down" /></a>';
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
        $output .= '<img src="'._getBaseURL().'moveLeft.gif" align="middle" border="0" alt="Move Left" title="Move Left" /></a>';
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
        $output .= '<img src="'._getBaseURL().'moveRight.gif" align="middle" border="0" alt="Move Right" title="Move Right" /></a>';
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
        $output .= '<img src="'._getBaseURL().'moveTop.gif" align="middle" border="0" alt="Move To Top" title="Move To Top" /></a>';
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
        $output .= '<img src="'._getBaseURL().'moveUp.gif" align="middle" border="0" alt="Move Up" title="Move Up" /></a>';
        return $output;
}

#-------------------------------------------------------------------

=head2 pageIcon ( )

Generates an icon that looks like a page. It's purpose is to represent whether you're looking at page properties or Wobject properties. 

=cut

sub pageIcon {
        return '<img src="'._getBaseURL().'page.gif" align="middle" border="0" alt="Page Settings" title="Page Settings" />';
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
        $output .= '<img src="'._getBaseURL().'paste.gif" align="middle" border="0" alt="Paste" title="Paste" /></a>';
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
        $output .= '<img src="'._getBaseURL().'shortcut.gif" align="middle" border="0" alt="Shortcut" title="Create Shortcut" /></a>';
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
        $output .= '<img src="'._getBaseURL().'view.gif" align="middle" border="0" alt="View" title="View" /></a>';
        return $output;
}

#-------------------------------------------------------------------

=head2 wobjectIcon ( )

Generates an icon that looks like a wobject. It's purpose is to represent whether you're looking at page properties or Wobject properties.

=cut

sub wobjectIcon {
        return '<img src="'._getBaseURL().'wobject.gif" align="middle" border="0" alt="Wobject Settings" title="Wobject Settings" />';
}



1;

