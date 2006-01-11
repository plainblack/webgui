package WebGUI::Session::Icon;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2006 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use WebGUI::International;


=head1 NAME

Package WebGUI::Session::Icon

=head1 DESCRIPTION

A package for generating user interface buttons. The subroutines found herein do nothing other than to create a short way of doing much longer repetitive tasks. They simply make the programmer's life easier through fewer keystrokes and less cluttered code.

=head1 SYNOPSIS

 use WebGUI::Session::Icon;
 $html = $self->session->icon->copy('op=something');
 $html = $self->session->icon->cut('op=something');
 $html = $self->session->icon->delete('op=something');
 $html = $self->session->icon->drag();
 $html = $self->session->icon->edit('op=something');
 $html = $self->session->icon->help(1,"MyNamespace");
 $html = $self->session->icon->manage('op=something');
 $html = $self->session->icon->moveBottom('op=something');
 $html = $self->session->icon->moveDown('op=something');
 $html = $self->session->icon->moveLeft('op=something');
 $html = $self->session->icon->moveRight('op=something');
 $html = $self->session->icon->moveTop('op=something');
 $html = $self->session->icon->moveUp('op=something');
 $html = $self->session->icon->paste('op=something');
 $html = $self->session->icon->shortcut('op=something');
 $html = $self->session->icon->view('op=something');

 $hashRef = $self->session->icon->getToolbarOptions();

=head1 METHODS

These subroutines are available from this package:

=cut

#-------------------------------------------------------------------

=head2 _getBaseURL ( )

Returns the base URL for this user's toolbar icon set.

=cut

sub _getBaseURL {
	my $self = shift;
	my $url = $self->session->config->get("extrasURL").'/toolbar/';
	if ($self->session->user->profileField("toolbar") ne "useLanguageDefault") {
		$url .= $self->session->user->profileField("toolbar");
	} else {
		$url .= WebGUI::International::getLanguage($self->session->user->profileField("language"),"toolbar");
	}
	$url .= '/';	
	return $url;
}


#-------------------------------------------------------------------

=head2 copy ( urlParameters [, pageURL ] )

Generates a button with the word "Copy" printed on it.

=head3 urlParameters

Any URL parameters that need to be tacked on to the current URL to accomplish whatever function this button represents.

=head3 pageURL

The URL to any page. Defaults to the current page.

=cut

sub copy {
	my $self = shift;
	my $urlParams = shift;
	my $pageURL = shift || $self->session->url->getRequestedUrl;
        my $output = '<a href="'.$self->session->url->gateway($pageURL,$urlParams).'">';
        $output .= '<img src="'.$self->_getBaseURL().'copy.gif" align="middle" border="0" alt="'.WebGUI::International::get('Copy','Icon').'" title="'.WebGUI::International::get('Copy','Icon').'" /></a>';
        return $output;
}

#-------------------------------------------------------------------

=head2 cut ( urlParameters [, pageURL ] )

Generates a button with the word "Cut" printed on it.

=head3 urlParameters

Any URL parameters that need to be tacked on to the current URL to accomplish whatever function this button represents.

=head3 pageURL

The URL to any page. Defaults to the current page.

=cut

sub cut {
	 my $self = shift;
        my $urlParams = shift;
        my $pageURL = shift || $self->session->url->getRequestedUrl;
        $output = '<a href="'.$self->session->url->gateway($pageURL,$urlParams).'">';
        $output .= '<img src="'.$self->_getBaseURL().'cut.gif" align="middle" border="0" alt="'.WebGUI::International::get('Cut','Icon').'" title="'.WebGUI::International::get('Cut','Icon').'" /></a>';
        return $output;
}

#-------------------------------------------------------------------

=head2 delete ( urlParameters [, pageURL, confirmText ] )

Generates a button that represents a delete operation.

=head3 urlParameters

Any URL parameters that need to be tacked on to the current URL to accomplish whatever function this button represents.

=head3 pageURL

The URL to any page. Defaults to the current page.

=head3 confirmText 

If defined, a confirm box will popup to ask the user if they want to delete.

=cut

sub delete {
	 my $self = shift;
        my $urlParams = shift;
        my $pageURL = shift || $self->session->url->getRequestedUrl;
	$confirmText = shift; 
	if($confirmText) {
		$confirmText = qq| onclick="return confirm('$confirmText')" |;
	}
        $output = '<a href="'.$self->session->url->gateway($pageURL,$urlParams).'" '.$confirmText.'>';
	$output .= '<img src="'.$self->_getBaseURL().'delete.gif" align="middle" border="0" alt="'.WebGUI::International::get('Delete','Icon').'" title="'.WebGUI::International::get('Delete','Icon').'" /></a>';
	return $output;
}

#-------------------------------------------------------------------

=head2 drag ( )

Generates an icon that can be used to drag content.

=cut

sub drag {
        return '<img id="dragTrigger" class="dragTrigger" src="'.$self->_getBaseURL().'drag.gif" align="middle" border="0" alt="'.WebGUI::International::get('Drag','Icon').'" title="'.WebGUI::International::get('Drag','Icon').'" />';
}

#-------------------------------------------------------------------

=head2 edit ( urlParameters [, pageURL ] )

Generates a button with the word "Edit" printed on it.

=head3 urlParameters

Any URL parameters that need to be tacked on to the current URL to accomplish whatever function this button represents.

=head3 pageURL

The URL to any page. Defaults to the current page.

=cut

sub edit {
	 my $self = shift;
        my $urlParams = shift;
        my $pageURL = shift || $self->session->url->getRequestedUrl;
        $output = '<a href="'.$self->session->url->gateway($pageURL,$urlParams).'">';
        $output .= '<img src="'.$self->_getBaseURL().'edit.gif" align="middle" border="0" alt="'.WebGUI::International::get('Edit','Icon').'" title="'.WebGUI::International::get('Edit','Icon').'" /></a>';
        return $output;
}

#-------------------------------------------------------------------

=head2 export ( urlParameters [, pageURL ] )

Generates an export button.

=head3 urlParameters

Any URL parameters that need to be tacked on to the current URL to accomplish whatever function this button represents.

=head3 pageURL

The URL to any page. Defaults to the current page.

=cut

sub export {
	 my $self = shift;
        my $urlParams = shift;
        my $pageURL = shift || $self->session->url->getRequestedUrl;
        $output = '<a href="'.$self->session->url->gateway($pageURL,$urlParams).'">';
        $output .= '<img src="'.$self->_getBaseURL().'export.gif" align="middle" border="0" alt="'.WebGUI::International::get('Export','Icon').'" title="'.WebGUI::International::get('Export','Icon').'" /></a>';
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
	my $dir = $self->session->config->get("extrasPath")."/toolbar";
        opendir (DIR,$dir) or $self->session->errorHandler->warn("Can't open toolbar directory!");
        my @files = readdir(DIR);
        foreach my $file (@files) {
                if (substr($file,0,1) ne ".") {
                        $options{$file} = $file;
                }
        }
        closedir(DIR);
	return \%options;
}

#-------------------------------------------------------------------

=head2 help ( helpId [, namespace ] )

Generates a button with the word "Help" printed on it.

=head3 helpId 

The id in the help table that relates to the help documentation for your function.

=head3 namespace

If your help documentation is not in the WebGUI namespace, then you must specify the namespace for this help.

=cut

sub help {
	 my $self = shift;
        my $urlParams = shift;
        my $pageURL = shift || $self->session->url->getRequestedUrl;
	my ($output, $namespace);
	$output = '<a href="'.$self->session->url->page('op=viewHelp;hid='.$urlParams.';namespace='.$namespace).
		'" target="_blank"><img src="'.$self->_getBaseURL().'help.gif" border="0" align="right" title="'.WebGUI::International::get('Help','Icon').'" Alt="'.WebGUI::International::get('Help','Icon').'"></a>';
	return $output;
}

#-------------------------------------------------------------------

=head2 locked ( urlParameters [, pageURL ] )

Generates a button that represents a management function. Is toggled out in place of the edit icon when an asset is locked.

=head3 urlParameters

Any URL parameters that need to be tacked on to the current URL to accomplish whatever function this button represents.

=head3 pageURL

The URL to any page. Defaults to the current page.

=cut

sub locked {
	 my $self = shift;
        my $urlParams = shift;
        my $pageURL = shift || $self->session->url->getRequestedUrl;
        $output = '<a href="'.$self->session->url->gateway($pageURL,$urlParams).'">';
        $output .= '<img src="'.$self->_getBaseURL().'locked.gif" align="middle" border="0" alt="'.WebGUI::International::get('locked','Icon').'" title="'.WebGUI::International::get('locked','Icon').'" /></a>';
        return $output;
}

#-------------------------------------------------------------------

=head2 manage ( urlParameters [, pageURL ] )

Generates a button that represents a management function.

=head3 urlParameters

Any URL parameters that need to be tacked on to the current URL to accomplish whatever function this button represents.

=head3 pageURL

The URL to any page. Defaults to the current page.

=cut

sub manage {
	 my $self = shift;
        my $urlParams = shift;
        my $pageURL = shift || $self->session->url->getRequestedUrl;
        $output = '<a href="'.$self->session->url->gateway($pageURL,$urlParams).'">';
        $output .= '<img src="'.$self->_getBaseURL().'manage.gif" align="middle" border="0" alt="'.WebGUI::International::get('Manage','Icon').'" title="'.WebGUI::International::get('Manage','Icon').'" /></a>';
        return $output;
}

#-------------------------------------------------------------------

=head2 moveBottom ( urlParameters [, pageURL ] )

Generates a button with a double down arrow printed on it.

=head3 urlParameters

Any URL parameters that need to be tacked on to the current URL to accomplish whatever function this button represents.

=head3 pageURL

The URL to any page. Defaults to the current page.

=cut

sub moveBottom {
	 my $self = shift;
        my $urlParams = shift;
        my $pageURL = shift || $self->session->url->getRequestedUrl;
        $output = '<a href="'.$self->session->url->gateway($pageURL,$urlParams).'">';
        $output .= '<img src="'.$self->_getBaseURL().'moveBottom.gif" align="middle" border="0" alt="'.WebGUI::International::get('Move To Bottom','Icon').'" title="'.WebGUI::International::get('Move To Bottom','Icon').'" /></a>';
        return $output;
}

#-------------------------------------------------------------------

=head2 moveDown ( urlParameters [, pageURL ] )

Generates a button with a down arrow printed on it.

=head3 urlParameters

Any URL parameters that need to be tacked on to the current URL to accomplish whatever function this button represents.

=head3 pageURL

The URL to any page. Defaults to the current page.

=cut

sub moveDown {
	 my $self = shift;
        my $urlParams = shift;
        my $pageURL = shift || $self->session->url->getRequestedUrl;
        $output = '<a href="'.$self->session->url->gateway($pageURL,$urlParams).'">';
        $output .= '<img src="'.$self->_getBaseURL().'moveDown.gif" align="middle" border="0" alt="'.WebGUI::International::get('Move Down','Icon').'" title="'.WebGUI::International::get('Move Down','Icon').'" /></a>';
        return $output;
}

#-------------------------------------------------------------------

=head2 moveLeft ( urlParameters [, pageURL ] )

Generates a button with a left arrow printed on it.

=head3 urlParameters

Any URL parameters that need to be tacked on to the current URL to accomplish whatever function this button represents.

=head3 pageURL

The URL to any page. Defaults to the current page.

=cut

sub moveLeft {
	 my $self = shift;
        my $urlParams = shift;
        my $pageURL = shift || $self->session->url->getRequestedUrl;
        $output = '<a href="'.$self->session->url->gateway($pageURL,$urlParams).'">';
        $output .= '<img src="'.$self->_getBaseURL().'moveLeft.gif" align="middle" border="0" alt="'.WebGUI::International::get('Move Left','Icon').'" title="'.WebGUI::International::get('Move Left','Icon').'" /></a>';
        return $output;
}

#-------------------------------------------------------------------

=head2 moveRight ( urlParameters [, pageURL ] )

Generates a button with a right arrow printed on it.

=head3 urlParameters

Any URL parameters that need to be tacked on to the current URL to accomplish whatever function this button represents.

=head3 pageURL

The URL to any page. Defaults to the current page.

=cut

sub moveRight {
	 my $self = shift;
        my $urlParams = shift;
        my $pageURL = shift || $self->session->url->getRequestedUrl;
        $output = '<a href="'.$self->session->url->gateway($pageURL,$urlParams).'">';
        $output .= '<img src="'.$self->_getBaseURL().'moveRight.gif" align="middle" border="0" alt="'.WebGUI::International::get('Move Right','Icon').'" title="'.WebGUI::International::get('Move Right','Icon').'" /></a>';
        return $output;
}

#-------------------------------------------------------------------

=head2 moveTop ( urlParameters [, pageURL ] )

Generates a button with a double up arrow printed on it.

=head3 urlParameters

Any URL parameters that need to be tacked on to the current URL to accomplish whatever function this button represents.

=head3 pageURL

The URL to any page. Defaults to the current page.

=cut

sub moveTop {
	 my $self = shift;
        my $urlParams = shift;
        my $pageURL = shift || $self->session->url->getRequestedUrl;
        $output = '<a href="'.$self->session->url->gateway($pageURL,$urlParams).'">';
        $output .= '<img src="'.$self->_getBaseURL().'moveTop.gif" align="middle" border="0" alt="'.WebGUI::International::get('Move To Top','Icon').'" title="'.WebGUI::International::get('Move To Top','Icon').'" /></a>';
        return $output;
}

#-------------------------------------------------------------------

=head2 moveUp ( urlParameters [, pageURL ] )

Generates a button with an up arrow printed on it.

=head3 urlParameters

Any URL parameters that need to be tacked on to the current URL to accomplish whatever function this button represents.

=head3 pageURL

The URL to any page. Defaults to the current page.

=cut

sub moveUp {
	 my $self = shift;
        my $urlParams = shift;
        my $pageURL = shift || $self->session->url->getRequestedUrl;
        $output = '<a href="'.$self->session->url->gateway($pageURL,$urlParams).'">';
        $output .= '<img src="'.$self->_getBaseURL().'moveUp.gif" align="middle" border="0" alt="'.WebGUI::International::get('Move Up','Icon').'" title="'.WebGUI::International::get('Move Up','Icon').'" /></a>';
        return $output;
}


#-------------------------------------------------------------------

=head2 new ( session )

Constructor.

=head3 session

A reference to the current session.

=cut

sub new {
	my $class = shift;
	my $session = shift;
	bless {_session=>$session}, $class;
}


#-------------------------------------------------------------------

=head2 paste ( urlParameters [, pageURL ] )

Generates a button with the word "Paste" printed on it.

=head3 urlParameters

Any URL parameters that need to be tacked on to the current URL to accomplish whatever function this button represents.

=head3 pageURL

The URL to any page. Defaults to the current page.

=cut

sub paste {
	 my $self = shift;
        my $urlParams = shift;
        my $pageURL = shift || $self->session->url->getRequestedUrl;
        $output = '<a href="'.$self->session->url->gateway($pageURL,$urlParams).'">';
        $output .= '<img src="'.$self->_getBaseURL().'paste.gif" align="middle" border="0" alt="'.WebGUI::International::get('Paste','Icon').'" title="'.WebGUI::International::get('Paste','Icon').'" /></a>';
        return $output;
}

#-------------------------------------------------------------------

=head2 session ( )

Returns a reference to the current session.

=cut

sub session {
	my $self = shift;
	return $self->{_session};
}


#-------------------------------------------------------------------

=head2 shortcut ( urlParameters [, pageURL ] )

Generates a button with a shortcut symbol printed on it, similar to the shortcut icon in Microsoft Windows or the link Icon in Gnome.

=head3 urlParameters

Any URL parameters that need to be tacked on to the current URL to accomplish whatever function this button represents.

=head3 pageURL

The URL to any page. Defaults to the current page.

=cut

sub shortcut {
	 my $self = shift;
        my $urlParams = shift;
        my $pageURL = shift || $self->session->url->getRequestedUrl;
        $output = '<a href="'.$self->session->url->gateway($pageURL,$urlParams).'">';
        $output .= '<img src="'.$self->_getBaseURL().'shortcut.gif" align="middle" border="0" alt="'.WebGUI::International::get('Create Shortcut','Icon').'" title="'.WebGUI::International::get('Create Shortcut','Icon').'" /></a>';
        return $output;
}

#-------------------------------------------------------------------

=head2 view ( urlParameters [, pageURL ] )

Generates a button with the word "View" printed on it.

=head3 urlParameters

Any URL parameters that need to be tacked on to the current URL to accomplish whatever function this button represents.

=head3 pageURL

The URL to any page. Defaults to the current page.

=cut

sub view {
	 my $self = shift;
        my $urlParams = shift;
        my $pageURL = shift || $self->session->url->getRequestedUrl;
        $output = '<a href="'.$self->session->url->gateway($pageURL,$urlParams).'">';
        $output .= '<img src="'.$self->_getBaseURL().'view.gif" align="middle" border="0" alt="'.WebGUI::International::get('View','Icon').'" title="'.WebGUI::International::get('View','Icon').'" /></a>';
        return $output;
}



1;

