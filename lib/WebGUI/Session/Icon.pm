package WebGUI::Session::Icon;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2012 Plain Black Corporation.
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
	my $toolbar = $self->session->user->get("toolbar");
	if ($toolbar ne "useLanguageDefault") {
		$url .= $toolbar;
	} else {
		$url .= WebGUI::International->new($self->session,'Icon')->getLanguage($self->session->user->get("language"),"toolbar");
	}
	$url .= '/';	
	return $url;
}


#-------------------------------------------------------------------

=head2 _basic ( )

Returns a basic icon with i18n title and alt text.

=head3 $i18n_tag

The name of an i18n tag to show for the TITLE and ALT properties in the image tag.

=head3 $icon_name

The name of an icon, such as delete, edit, manage, moveLeft, etc.  See /data/WebGUI/www/extras/toolbar/bullet for a full list.

=head3 $url_params

Parameters to append to the URL.

=head3 $pageURL

The URL of a page to call.  If empty, defaults to the current page which is fine for most operations.

=cut

sub _basic {
    my $self       = shift;
    my $i18n_tag   = shift;
    my $icon_name  = shift;
    my $url_params = shift;
    my $pageURL    = shift || $self->session->url->getRequestedUrl;
	my $i18n       = WebGUI::International->new($self->session,'Icon');
    my $tag        = $i18n->get($i18n_tag);
    my $output     = '<span class="toolbarIcon" style="vertical-align:middle;"><a href="'
                   . $self->session->url->gateway($pageURL,$url_params)
                   . '">';
    $output        .= '<img src="'.$self->getBaseURL().$icon_name.'" style="vertical-align:middle;border: 0px;" alt="'.$tag.'" title="'.$tag.'" /></a></span>';
    return $output;
}

#-------------------------------------------------------------------

=head2 _form_with_confirmation ( )

Generates a form containing an icon.  When the icon is clicked, it pops up a confirmation window, and submits
the form if the confirmation is accepted.

=head3 $i18n_tag

The name of an i18n tag to show for the TITLE and ALT properties in the image tag.

=head3 $icon_name

The name of an icon, such as delete, edit, manage, moveLeft, etc.  See /data/WebGUI/www/extras/toolbar/bullet for a full list.

=head3 $url_params

Parameters to append to the URL.

=head3 $pageURL

The URL of a page to call.  If empty, defaults to the current page which is fine for most operations.

=head3 $confirm

Text to show to the user in the pop-up confirmation for the action.

=cut

sub _form_with_confirmation {
    my $self       = shift;
    my $session    = $self->session;
    my $i18n_tag   = shift;
    my $icon_name  = shift;
    my $url_params = shift;
    my $pageURL    = shift || $session->url->getRequestedUrl;
    my $confirm    = shift;

	my $i18n   = WebGUI::International->new($session,'Icon');
    my $tag    = $i18n->get($i18n_tag);
    ##Escape JS characters
    $confirm   =~ s/([\\\'])/\\$1/g;
    use WebGUI::Form;
    my $output = WebGUI::Form::formHeader($session, { action => $session->url->append($pageURL,$url_params), });
    $output   .= q|<span class="toolbarIcon" style="vertical-align:middle;"><a href="#" onclick="var ack = confirm('|.$confirm.q|'); if (ack) {this.form.submit();} return false;">|;
    $output   .= '<img src="'.$self->getBaseURL().$icon_name.'" style="vertical-align:middle;border: 0px;" alt="'.$tag.'" title="'.$tag.'" /></a></span>';
    $output   .= WebGUI::Form::formFooter();
    return $output;
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
    return $self->_basic('Copy', 'copy.gif', @_);
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
    return $self->_basic('Cut', 'cut.gif', @_);
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
        my $output = '<span class="toolbarIcon" style="vertical-align:middle;"><a href="'.$self->session->url->gateway($pageURL,$urlParams).'" '.$confirmText.'>';
	$output .= '<img src="'.$self->getBaseURL().'delete.gif" style="vertical-align:middle;border: 0px;" alt="'.$i18n->get('Delete').'" title="'.$i18n->get('Delete').'" /></a></span>';
	return $output;
}

#-------------------------------------------------------------------

=head2 delete_with_form ( urlParameters [, pageURL, confirmText ] )

Generates a button that represents a delete operation inside of a form for CSRF purposes.

=head3 urlParameters

Any URL parameters that need to be tacked on to the current URL to accomplish whatever function this button represents.

=head3 pageURL

The URL to any page. Defaults to the current page.  If a URL is passed, the gateway URL from the site's config
file will be prepended to it.

=head3 confirmText 

If defined, a confirm box will popup to ask the user if they want to delete.

=cut

sub delete_with_form {
    my $self = shift;
    return $self->_form_with_confirmation('Delete', 'delete.gif', @_);
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
        return '<span class="toolbarIcon" style="vertical-align:middle;"><img '.$extras.' src="'.$self->getBaseURL().'drag.gif" style="vertical-align:middle;border: 0px;" alt="'.$i18n->get('Drag').'" title="'.$i18n->get('Drag').'" /></span>';
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
    return $self->_basic('Edit', 'edit.gif', @_);
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
    return $self->_basic('Export', 'export.gif', @_);
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
        opendir (DIR,$dir) or $self->session->log->warn("Can't open toolbar directory!: $!");
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
    return $self->_basic('locked', 'locked.gif', @_);
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
    return $self->_basic('Manage', 'manage.gif', @_);
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
    return $self->_basic('Move To Bottom', 'moveBotom.gif', @_);
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
        my $output = '<span class="toolbarIcon" style="vertical-align:middle;">';
        $output .= '<a href="'.$self->session->url->gateway($pageURL,$urlParams).'">' unless $disabled;
        $output .= '<img src="'.$self->getBaseURL().'moveDown.gif" style="vertical-align:middle;border: 0px;" alt="'.$i18n->get('Move Down').'" title="'.$i18n->get('Move Down').'" />';
        $output .= '</a>' unless $disabled;
        $output .= '</span>';
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
    return $self->_basic('Move Left', 'moveLeft.gif', @_);
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
    return $self->_basic('Move Right', 'moveRight.gif', @_);
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
    return $self->_basic('Move To Top', 'moveTop.gif', @_);
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
        my $output = '<span class="toolbarIcon" style="vertical-align:middle;">';
        $output .= '<a href="'.$self->session->url->gateway($pageURL,$urlParams).'">' unless $disabled;
        $output .= '<img src="'.$self->getBaseURL().'moveUp.gif" style="vertical-align:middle;border: 0px;" alt="'.$i18n->get('Move Up').'" title="'.$i18n->get('Move Up').'" />';
        $output .= '</a>' unless $disabled;
        $output .= '</span>';
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
    return $self->_basic('Create Shortcut', 'shortcut.gif', @_);
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
    return $self->_basic('View', 'view.gif', @_);
}


1;
