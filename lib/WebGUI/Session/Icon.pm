package WebGUI::Session::Icon;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2009 Plain Black Corporation.
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
use Tie::IxHash;
use Scalar::Util qw(weaken);

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
 $html = $self->session->icon->manage('op=something');
 $html = $self->session->icon->moveBottom('op=something');
 $html = $self->session->icon->moveDown('op=something');
 $html = $self->session->icon->moveLeft('op=something');
 $html = $self->session->icon->moveRight('op=something');
 $html = $self->session->icon->moveTop('op=something');
 $html = $self->session->icon->moveUp('op=something');
 $html = $self->session->icon->shortcut('op=something');
 $html = $self->session->icon->view('op=something');

 $hashRef = $self->session->icon->getToolbarOptions();

=head1 METHODS

These subroutines are available from this package:

=cut

#-------------------------------------------------------------------

=head2 getBaseURL ( )

Returns the base URL for this user's toolbar icon set.

=cut

sub getBaseURL {
	my $self = shift;
	my $url = $self->session->url->extras('toolbar/');
	my $toolbar = $self->session->user->profileField("toolbar");
	if ($toolbar ne "useLanguageDefault") {
		$url .= $toolbar;
	} else {
		$url .= WebGUI::International->new($self->session,'Icon')->getLanguage($self->session->user->profileField("language"),"toolbar");
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

The URL to any page. Defaults to the current page.  If a URL is passed, the gateway URL from the site's config
file will be prepended to it.

=cut

sub copy {
	my $self = shift;
	my $urlParams = shift;
	my $pageURL = shift || $self->session->url->getRequestedUrl;
	my $i18n = WebGUI::International->new($self->session,'Icon');
        my $output = '<p class="toolbarIcon" style="display:inline;vertical-align:middle;"><a href="'.$self->session->url->gateway($pageURL,$urlParams).'">';
        $output .= '<img src="'.$self->getBaseURL().'copy.gif" style="vertical-align:middle;border: 0px;" alt="'.$i18n->get('Copy').'" title="'.$i18n->get('Copy').'" /></a></p>';
        return $output;
}

#-------------------------------------------------------------------

=head2 cut ( urlParameters [, pageURL ] )

Generates a button with the word "Cut" printed on it.

=head3 urlParameters

Any URL parameters that need to be tacked on to the current URL to accomplish whatever function this button represents.

=head3 pageURL

The URL to any page. Defaults to the current page.  If a URL is passed, the gateway URL from the site's config
file will be prepended to it.

=cut

sub cut {
	 my $self = shift;
        my $urlParams = shift;
        my $pageURL = shift || $self->session->url->getRequestedUrl;
	my $i18n = WebGUI::International->new($self->session,'Icon');
        my $output = '<p class="toolbarIcon" style="display:inline;vertical-align:middle;"><a href="'.$self->session->url->gateway($pageURL,$urlParams).'">';
        $output .= '<img src="'.$self->getBaseURL().'cut.gif" style="vertical-align:middle;border: 0px;" alt="'.$i18n->get('Cut').'" title="'.$i18n->get('Cut').'" /></a></p>';
        return $output;
}

#-------------------------------------------------------------------

=head2 delete ( urlParameters [, pageURL, confirmText ] )

Generates a button that represents a delete operation.

=head3 urlParameters

Any URL parameters that need to be tacked on to the current URL to accomplish whatever function this button represents.

=head3 pageURL

The URL to any page. Defaults to the current page.  If a URL is passed, the gateway URL from the site's config
file will be prepended to it.


=head3 confirmText 

If defined, a confirm box will popup to ask the user if they want to delete.

=cut

sub delete {
	my $self = shift;
        my $urlParams = shift;
        my $pageURL = shift || $self->session->url->getRequestedUrl;
	my $confirmText = shift; 
	if($confirmText) {
		$confirmText = qq| onclick="return confirm('$confirmText');" |;
	}
	my $i18n = WebGUI::International->new($self->session,'Icon');
        my $output = '<p class="toolbarIcon" style="display:inline;vertical-align:middle;"><a href="'.$self->session->url->gateway($pageURL,$urlParams).'" '.$confirmText.'>';
	$output .= '<img src="'.$self->getBaseURL().'delete.gif" style="vertical-align:middle;border: 0px;" alt="'.$i18n->get('Delete').'" title="'.$i18n->get('Delete').'" /></a></p>';
	return $output;
}

#-------------------------------------------------------------------

=head2 drag ( extras )

Generates an icon that can be used to drag content.

=head2 extras

Classes, Ids, Javascript triggers, or whatever else you need to add to the image to make it a drag trigger.

=cut

sub drag {
	my $self = shift;
	my $extras = shift;
	my $i18n = WebGUI::International->new($self->session,'Icon');
        return '<p class="toolbarIcon" style="display:inline;vertical-align:middle;"><img '.$extras.' src="'.$self->getBaseURL().'drag.gif" style="vertical-align:middle;border: 0px;" alt="'.$i18n->get('Drag').'" title="'.$i18n->get('Drag').'" /></p>';
}

#-------------------------------------------------------------------

=head2 edit ( urlParameters [, pageURL ] )

Generates a button with the word "Edit" printed on it.

=head3 urlParameters

Any URL parameters that need to be tacked on to the current URL to accomplish whatever function this button represents.

=head3 pageURL

The URL to any page. Defaults to the current page.  If a URL is passed, the gateway URL from the site's config
file will be prepended to it.

=cut

sub edit {
	 my $self = shift;
        my $urlParams = shift;
        my $pageURL = shift || $self->session->url->getRequestedUrl;
	my $i18n = WebGUI::International->new($self->session,'Icon');
        my $output = '<p class="toolbarIcon" style="display:inline;vertical-align:middle;"><a href="'.$self->session->url->gateway($pageURL,$urlParams).'">';
        $output .= '<img src="'.$self->getBaseURL().'edit.gif" style="vertical-align:middle;border: 0px;" alt="'.$i18n->get('Edit').'" title="'.$i18n->get('Edit').'" /></a></p>';
        return $output;
}

#-------------------------------------------------------------------

=head2 export ( urlParameters [, pageURL ] )

Generates an export button.

=head3 urlParameters

Any URL parameters that need to be tacked on to the current URL to accomplish whatever function this button represents.

=head3 pageURL

The URL to any page. Defaults to the current page.  If a URL is passed, the gateway URL from the site's config
file will be prepended to it.


=cut

sub export {
	 my $self = shift;
        my $urlParams = shift;
        my $pageURL = shift || $self->session->url->getRequestedUrl;
	my $i18n = WebGUI::International->new($self->session,'Icon');
        my $output = '<p class="toolbarIcon" style="display:inline;vertical-align:middle;"><a href="'.$self->session->url->gateway($pageURL,$urlParams).'">';
        $output .= '<img src="'.$self->getBaseURL().'export.gif" style="vertical-align:middle;border: 0px;" alt="'.$i18n->get('Export').'" title="'.$i18n->get('Export').'" /></a></p>';
        return $output;
}

#-------------------------------------------------------------------

=head2 getToolbarOptions ( )

Returns a hash reference containing the list of toolbar icon sets to be selected in user profile.

=cut

sub getToolbarOptions {
	my %options;
	tie %options, 'Tie::IxHash';
	my $self = shift;
	$options{useLanguageDefault} = WebGUI::International->new($self->session,'WebGUI')->get(1084);
	my $dir = $self->session->config->get("extrasPath")."/toolbar";
        opendir (DIR,$dir) or $self->session->errorHandler->warn("Can't open toolbar directory!: $!");
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

=head2 locked ( urlParameters [, pageURL ] )

Generates a button that represents a management function. Is toggled out in place of the edit icon when an asset is locked.

=head3 urlParameters

Any URL parameters that need to be tacked on to the current URL to accomplish whatever function this button represents.

=head3 pageURL

The URL to any page. Defaults to the current page.  If a URL is passed, the gateway URL from the site's config
file will be prepended to it.


=cut

sub locked {
	 my $self = shift;
        my $urlParams = shift;
        my $pageURL = shift || $self->session->url->getRequestedUrl;
	my $i18n = WebGUI::International->new($self->session,'Icon');
        my $output = '<p class="toolbarIcon" style="display:inline;vertical-align:middle;"><a href="'.$self->session->url->gateway($pageURL,$urlParams).'">';
        $output .= '<img src="'.$self->getBaseURL().'locked.gif" style="vertical-align:middle;border: 0px;" alt="'.$i18n->get('locked').'" title="'.$i18n->get('locked').'" /></a></p>';
        return $output;
}

#-------------------------------------------------------------------

=head2 manage ( urlParameters [, pageURL ] )

Generates a button that represents a management function.

=head3 urlParameters

Any URL parameters that need to be tacked on to the current URL to accomplish whatever function this button represents.

=head3 pageURL

The URL to any page. Defaults to the current page.  If a URL is passed, the gateway URL from the site's config
file will be prepended to it.


=cut

sub manage {
	 my $self = shift;
        my $urlParams = shift;
        my $pageURL = shift || $self->session->url->getRequestedUrl;
	my $i18n = WebGUI::International->new($self->session,'Icon');
        my $output = '<p class="toolbarIcon" style="display:inline;vertical-align:middle;"><a href="'.$self->session->url->gateway($pageURL,$urlParams).'">';
        $output .= '<img src="'.$self->getBaseURL().'manage.gif" style="vertical-align:middle;border: 0px;" alt="'.$i18n->get('Manage').'" title="'.$i18n->get('Manage').'" /></a></p>';
        return $output;
}

#-------------------------------------------------------------------

=head2 moveBottom ( urlParameters [, pageURL ] )

Generates a button with a double down arrow printed on it.

=head3 urlParameters

Any URL parameters that need to be tacked on to the current URL to accomplish whatever function this button represents.

=head3 pageURL

The URL to any page. Defaults to the current page.  If a URL is passed, the gateway URL from the site's config
file will be prepended to it.


=cut

sub moveBottom {
	 my $self = shift;
        my $urlParams = shift;
        my $pageURL = shift || $self->session->url->getRequestedUrl;
	my $i18n = WebGUI::International->new($self->session,'Icon');
        my $output = '<p class="toolbarIcon" style="display:inline;vertical-align:middle;"><a href="'.$self->session->url->gateway($pageURL,$urlParams).'">';
        $output .= '<img src="'.$self->getBaseURL().'moveBottom.gif" style="vertical-align:middle;border: 0px;" alt="'.$i18n->get('Move To Bottom').'" title="'.$i18n->get('Move To Bottom').'" /></a></p>';
        return $output;
}

#-------------------------------------------------------------------

=head2 moveDown ( urlParameters [, pageURL ] )

Generates a button with a down arrow printed on it.

=head3 urlParameters

Any URL parameters that need to be tacked on to the current URL to accomplish whatever function this button represents.

=head3 pageURL

The URL to any page. Defaults to the current page.  If a URL is passed, the gateway URL from the site's config
file will be prepended to it.


=head3 disabled

If this flag is true, the icon will be generated but no action link will be wrapped around it.

=cut

sub moveDown {
	 my $self = shift;
        my $urlParams = shift;
        my $pageURL = shift || $self->session->url->getRequestedUrl;
	my $disabled = shift;
	my $i18n = WebGUI::International->new($self->session,'Icon');
        my $output = '<p class="toolbarIcon" style="display:inline;vertical-align:middle;">';
        $output .= '<a href="'.$self->session->url->gateway($pageURL,$urlParams).'">' unless $disabled;
        $output .= '<img src="'.$self->getBaseURL().'moveDown.gif" style="vertical-align:middle;border: 0px;" alt="'.$i18n->get('Move Down').'" title="'.$i18n->get('Move Down').'" />';
        $output .= '</a>' unless $disabled;
        $output .= '</p>';
        return $output;
}

#-------------------------------------------------------------------

=head2 moveLeft ( urlParameters [, pageURL ] )

Generates a button with a left arrow printed on it.

=head3 urlParameters

Any URL parameters that need to be tacked on to the current URL to accomplish whatever function this button represents.

=head3 pageURL

The URL to any page. Defaults to the current page.  If a URL is passed, the gateway URL from the site's config
file will be prepended to it.


=cut

sub moveLeft {
	 my $self = shift;
        my $urlParams = shift;
        my $pageURL = shift || $self->session->url->getRequestedUrl;
	my $i18n = WebGUI::International->new($self->session,'Icon');
        my $output = '<p class="toolbarIcon" style="display:inline;vertical-align:middle;"><a href="'.$self->session->url->gateway($pageURL,$urlParams).'">';
        $output .= '<img src="'.$self->getBaseURL().'moveLeft.gif" style="vertical-align:middle;border: 0px;" alt="'.$i18n->get('Move Left').'" title="'.$i18n->get('Move Left').'" /></a></p>';
        return $output;
}

#-------------------------------------------------------------------

=head2 moveRight ( urlParameters [, pageURL ] )

Generates a button with a right arrow printed on it.

=head3 urlParameters

Any URL parameters that need to be tacked on to the current URL to accomplish whatever function this button represents.

=head3 pageURL

The URL to any page. Defaults to the current page.  If a URL is passed, the gateway URL from the site's config
file will be prepended to it.


=cut

sub moveRight {
	 my $self = shift;
        my $urlParams = shift;
        my $pageURL = shift || $self->session->url->getRequestedUrl;
	my $i18n = WebGUI::International->new($self->session,'Icon');
        my $output = '<p class="toolbarIcon" style="display:inline;vertical-align:middle;"><a href="'.$self->session->url->gateway($pageURL,$urlParams).'">';
        $output .= '<img src="'.$self->getBaseURL().'moveRight.gif" style="vertical-align:middle;border: 0px;" alt="'.$i18n->get('Move Right').'" title="'.$i18n->get('Move Right').'" /></a></p>';
        return $output;
}

#-------------------------------------------------------------------

=head2 moveTop ( urlParameters [, pageURL ] )

Generates a button with a double up arrow printed on it.

=head3 urlParameters

Any URL parameters that need to be tacked on to the current URL to accomplish whatever function this button represents.

=head3 pageURL

The URL to any page. Defaults to the current page.  If a URL is passed, the gateway URL from the site's config
file will be prepended to it.


=cut

sub moveTop {
	 my $self = shift;
        my $urlParams = shift;
        my $pageURL = shift || $self->session->url->getRequestedUrl;
	my $i18n = WebGUI::International->new($self->session,'Icon');
        my $output = '<p class="toolbarIcon" style="display:inline;vertical-align:middle;"><a href="'.$self->session->url->gateway($pageURL,$urlParams).'">';
        $output .= '<img src="'.$self->getBaseURL().'moveTop.gif" style="vertical-align:middle;border: 0px;" alt="'.$i18n->get('Move To Top').'" title="'.$i18n->get('Move To Top').'" /></a></p>';
        return $output;
}

#-------------------------------------------------------------------

=head2 moveUp ( urlParameters [, pageURL ] )

Generates a button with an up arrow printed on it.

=head3 urlParameters

Any URL parameters that need to be tacked on to the current URL to accomplish whatever function this button represents.

=head3 pageURL

The URL to any page. Defaults to the current page.  If a URL is passed, the gateway URL from the site's config
file will be prepended to it.


=head3 disabled

If this flag is true, the icon will be generated but no action link will be wrapped around it.

=cut

sub moveUp {
	 my $self = shift;
        my $urlParams = shift;
        my $pageURL = shift || $self->session->url->getRequestedUrl;
	my $disabled = shift;
	my $i18n = WebGUI::International->new($self->session,'Icon');
        my $output = '<p class="toolbarIcon" style="display:inline;vertical-align:middle;">';
        $output .= '<a href="'.$self->session->url->gateway($pageURL,$urlParams).'">' unless $disabled;
        $output .= '<img src="'.$self->getBaseURL().'moveUp.gif" style="vertical-align:middle;border: 0px;" alt="'.$i18n->get('Move Up').'" title="'.$i18n->get('Move Up').'" />';
        $output .= '</a>' unless $disabled;
        $output .= '</p>';
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
    my $self = bless { _session => $session }, $class;
    weaken $self->{_session};
    return $self;
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

The URL to any page. Defaults to the current page.  If a URL is passed, the gateway URL from the site's config
file will be prepended to it.


=cut

sub shortcut {
	 my $self = shift;
        my $urlParams = shift;
        my $pageURL = shift || $self->session->url->getRequestedUrl;
	my $i18n = WebGUI::International->new($self->session,'Icon');
        my $output = '<p class="toolbarIcon" style="display:inline;vertical-align:middle;"><a href="'.$self->session->url->gateway($pageURL,$urlParams).'">';
        $output .= '<img src="'.$self->getBaseURL().'shortcut.gif" style="vertical-align:middle;border: 0px;" alt="'.$i18n->get('Create Shortcut').'" title="'.$i18n->get('Create Shortcut').'" /></a></p>';
        return $output;
}

#-------------------------------------------------------------------

=head2 view ( urlParameters [, pageURL ] )

Generates a button with the word "View" printed on it.

=head3 urlParameters

Any URL parameters that need to be tacked on to the current URL to accomplish whatever function this button represents.

=head3 pageURL

The URL to any page. Defaults to the current page.  If a URL is passed, the gateway URL from the site's config
file will be prepended to it.


=cut

sub view {
	 my $self = shift;
        my $urlParams = shift;
        my $pageURL = shift || $self->session->url->getRequestedUrl;
	my $i18n = WebGUI::International->new($self->session,'Icon');
        my $output = '<p class="toolbarIcon" style="display:inline;vertical-align:middle;"><a href="'.$self->session->url->gateway($pageURL,$urlParams).'">';
        $output .= '<img src="'.$self->getBaseURL().'view.gif" style="vertical-align:middle;border: 0px;" alt="'.$i18n->get('View').'" title="'.$i18n->get('View').'" /></a></p>';
        return $output;
}


1;
