package WebGUI::Asset::File::GalleryFile;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2008 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use base 'WebGUI::Asset::File';



=head1 NAME

WebGUI::Asset::File::GalleryFile - Superclass to create files for the Gallery

=head1 SYNOPSIS


=head1 DESCRIPTION

=head1 METHODS

These methods are available from this class

=cut

#----------------------------------------------------------------------------

=head2 getThumbnailUrl ( )

Gets the URL to the thumbnail for this GalleryFile. This should probably be
overridded by your child class.

=cut

sub getThumbnailUrl {
    my $self        = shift;

}

#----------------------------------------------------------------------------

=head2 getTemplateVars ( )

Gets the template vars for this GalleryFile. You should probably extend this 
method.

=cut

sub getTemplateVars {
    my $self        = shift;
    my $var         = $self->get;

    $var->{ fileUrl             } = $self->getFileUrl;
    $var->{ thumbnailUrl        } = $self->getThumbnailUrl;

    return $var;
}

#----------------------------------------------------------------------------

=head2 processStyle ( html )

Returns the HTML from the Gallery's style.

=cut

sub processStyle {
    my $self        = shift;
    return $self->getGallery->processStyle( @_ );
}

#----------------------------------------------------------------------------

=head2 www_demote

Override the default demote page to send the user back to the GalleryAlbum 
edit screen.

=cut

sub www_demote {
    my $self        = shift;

    return $self->session->privilege->insufficient unless $self->canEdit;

    $self->demote;
    
    return $self->session->asset( $self->getParent )->www_edit;
}

#----------------------------------------------------------------------------

=head2 www_promote

Override the default promote page to send the user back to the GalleryAlbum 
edit screen.

=cut

sub www_promote {
    my $self        = shift;

    return $self->session->privilege->insufficient unless $self->canEdit;

    $self->promote;
    
    return $self->session->asset( $self->getParent )->www_edit;
}

#----------------------------------------------------------------------------

=head2 www_view ( )

Show the default view, with content chunking.

=cut

sub www_view {
    my $self        = shift;
    $self->session->http->setLastModified($self->getContentLastModified);
    $self->session->http->sendHeader;
    $self->prepareView;
    my $style = $self->processStyle("~~~");
    my ($head, $foot) = split("~~~",$style);
    $self->session->output->print($head, 1);
    $self->session->output->print($self->view);
    $self->session->output->print($foot, 1);
    return "chunked";
}

1; # Who knew the truth would be so obvious?
