package WebGUI::Asset::EMSSubmissionForm;

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
use Tie::IxHash;
use base 'WebGUI::Asset';
use WebGUI::Utility;

# TODO:
# To get an installer for your wobject, add the Installable AssetAspect
# See WebGUI::AssetAspect::Installable and sbin/installClass.pl for more
# details

=head1 NAME

Package WebGUI::Asset::EMSSubmissionForm

=head1 DESCRIPTION

This Asset describes and builds a form which provides an interface for submitting a custom
subset of the EMSTicket asset.  Users create submissions which can be editted by admins
and then become EMSTicket's.

=head1 SYNOPSIS

use WebGUI::Asset::EMSSubmissionForm;

=head1 TODO

add a lastSubmissionDate -- after that the submission form will be closed
    the link will still exist but the form will just say '<title> submissions closed as of <date>'


=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 addSubmission

Creates an EMSSubmission object based on the params

=cut

sub addSubmission {
    my $self = shift;
    my $parent = $self->getParent;
    my $session = $self->session;
    my $params = shift || {};
    $self->validateSubmission($params);
    $parent->addChild({
          className => 'WebGUI::Asset::EMSSubmission',
          status => 'pending',
          title => $params->{title},
          # TODO add all the fields...
    });
}

#-------------------------------------------------------------------

=head2 addRevision

This method exists for demonstration purposes only.  The superclass
handles revisions to NewAsset Assets.

=cut

#sub addRevision {
#    my $self    = shift;
#    my $newSelf = $self->SUPER::addRevision(@_);
#    return $newSelf;
#}

#-------------------------------------------------------------------

=head2 definition ( session, definition )

defines asset properties for New Asset instances.  You absolutely need 
this method in your new Assets. 

=head3 session

=head3 definition

A hash reference passed in from a subclass definition.

=cut

sub definition {
    my $class      = shift;
    my $session    = shift;
    my $definition = shift;
    my $i18n       = WebGUI::International->new( $session, "Asset_EMSSubmissionForm" );
    tie my %properties, 'Tie::IxHash', (
        nextSubmissionId => { 
            tab          => "properties",
            fieldType    => "integer",
            defaultValue => 0,
            label        => $i18n->get("next submission id label"),
            hoverHelp    => $i18n->get("next submission id label help")
        },
        canSubmitGroupId => { 
            tab          => "security",
            fieldType    => "groupid",
            defaultValue => undef,
            label        => $i18n->get("can submit group label"),
            hoverHelp    => $i18n->get("can submit group label help")
        },
        daysBeforeCleanup => { 
            tab          => "properties",
            fieldType    => "integer",
            defaultValue => 7,
            label        => $i18n->get("days before cleanup label"),
            hoverHelp    => $i18n->get("days before cleanup label help")
        },
        deleteCreatedItems => { 
            tab          => "properties",
            fieldType    => "yesno",
            defaultValue => 'no',
            label        => $i18n->get("delete created items label"),
            hoverHelp    => $i18n->get("delete created items label help")
        },
        submissionDeadline => { 
            tab          => "properties",
            fieldType    => "Date",
            defaultValue => undef,
            label        => $i18n->get("submission deadline label"),
            hoverHelp    => $i18n->get("submission deadline label help")
        },
        formDescription => { 
            tab          => "properties",
            fieldType    => "text",
            defaultValue => undef,
            label        => $i18n->get("form dscription label"),
            hoverHelp    => $i18n->get("form dscription label help")
        },
    );
    push @{$definition}, {
        assetName         => $i18n->get('assetName'),
        icon              => 'EMSSubmissionForm.gif',
        autoGenerateForms => 1,
        tableName         => 'EMSSubmissionForm',
        className         => 'WebGUI::Asset::EMSSubmissionForm',
        properties        => \%properties,
        };
    return $class->SUPER::definition( $session, $definition );
} ## end sub definition

#-------------------------------------------------------------------

=head2 duplicate

This method exists for demonstration purposes only.  The superclass
handles duplicating NewAsset Assets.  This method will be called 
whenever a copy action is executed

=cut

#sub duplicate {
#    my $self     = shift;
#    my $newAsset = $self->SUPER::duplicate(@_);
#    return $newAsset;
#}

#-------------------------------------------------------------------

=head2 indexContent ( )

Making private. See WebGUI::Asset::indexContent() for additonal details. 

=cut

sub indexContent {
    my $self    = shift;
    my $indexer = $self->SUPER::indexContent;
    $indexer->setIsPublic(0);
}

#-------------------------------------------------------------------

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

sub prepareView {
    my $self = shift;
    $self->SUPER::prepareView();
    my $template = WebGUI::Asset::Template->new( $self->session, $self->get("templateId") );
    $template->prepare($self->getMetaDataAsTemplateVariables);
    $self->{_viewTemplate} = $template;
}

#-------------------------------------------------------------------

=head2 processPropertiesFromFormPost ( )

Used to process properties from the form posted.  Do custom things with
noFormPost fields here, or do whatever you want.  This method is called
when /yourAssetUrl?func=editSave is requested/posted.

=cut

sub processPropertiesFromFormPost {
    my $self = shift;
    $self->SUPER::processPropertiesFromFormPost;
}

#-------------------------------------------------------------------

=head2 purge ( )

This method is called when data is purged by the system.
removes collateral data associated with a NewAsset when the system
purges it's data.  This method is unnecessary, but if you have 
auxiliary, ancillary, or "collateral" data or files related to your 
asset instances, you will need to purge them here.

=cut

#sub purge {
#    my $self = shift;
#    return $self->SUPER::purge;
#}

#-------------------------------------------------------------------

=head2 purgeRevision ( )

This method is called when data is purged by the system.

=cut

#sub purgeRevision {
#    my $self = shift;
#    return $self->SUPER::purgeRevision;
#}

#-------------------------------------------------------------------

=head2 view ( )

method called by the container www_view method. 

=cut

sub view {
    my $self = shift;
    my $var  = $self->get;    # $var is a hash reference.
    $var->{controls} = $self->getToolbar;
    return $self->processTemplate( $var, undef, $self->{_viewTemplate} );
}

#-------------------------------------------------------------------

=head2 validateSubmission ( )

=cut

sub validateSubmission {
    my $self    = shift;
    my $session = $self->session;
# compare fields passed with field definition
# return true if ok, false if not ok
    return 0;
}

#-------------------------------------------------------------------

=head2 www_edit ( )

Web facing method which is the default edit page.  Unless the method needs
special handling or formatting, it does not need to be included in
the module.

=cut

sub www_edit {
    my $self    = shift;
    my $session = $self->session;
    return $session->privilege->insufficient() unless $self->canEdit;
    return $session->privilege->locked()       unless $self->canEditIfLocked;
    my $i18n = WebGUI::International->new( $session, 'Asset_EMSSubmissionForm' );
    return $self->getAdminConsole->render( $self->getEditForm->print, $i18n->get('edit asset') );
}

1;

#vim:ft=perl
