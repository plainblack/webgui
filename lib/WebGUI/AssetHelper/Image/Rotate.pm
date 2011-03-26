package WebGUI::AssetHelper::Image::Rotate;

use strict;
use warnings;

use Moose;
extends 'WebGUI::AssetHelper';

#-------------------------------------------------------------------

=head2 process ( )

Open a dialog to rotate the image

=cut

sub process {
    my ( $self ) = @_;
    my $asset   = $self->asset;
    my $session = $self->session;

    my $i18n = WebGUI::International->new($session, 'WebGUI');
    if (! $asset->canEdit) {
        return { error => $i18n->get('38'), };
    }
    elsif ( ! $asset->canEditIfLocked ) {
        return { error => $i18n->get('asset locked') };
    }

    return {
        openDialog  => $self->getUrl( 'rotate' )
    };
}

#-------------------------------------------------------------------

=head2 www_rotate 

Displays a form for the user to rotate this image.

=cut

sub www_rotate {
    my ( $self ) = @_;
    my $asset   = $self->asset;
    my $session = $self->session;
    return $session->privilege->insufficient() unless $asset->canEdit;
    return $session->privilege->locked()       unless $asset->canEditIfLocked;

    ##YUI specific datatable CSS
    my ($style, $url) = $session->quick(qw(style url));

    my $img_file = $asset->filename;
    my $img_name = $asset->getStorageLocation->getUrl($img_file);
    my $image = '<div align="center" class="yui-skin-sam"><img src="'.$img_name.'" style="border-style:none;" alt="'.$img_name.'" id="yui_img" /></div>';

    my $i18n = WebGUI::International->new($session,"Asset_Image");
    my $f = $self->getForm( 'rotateSave' );
    $f->addField( "button", 
        value=>"Left",
        extras=>qq{onclick="var deg = document.getElementById('Rotate_formId').value; deg = parseInt(deg) + 90; document.getElementById('Rotate_formId').value = deg;"},
    );
    $f->addField( "button", 
        value=>"Right",
        extras=>qq{onclick="var deg = document.getElementById('Rotate_formId').value; deg = parseInt(deg) - 90; document.getElementById('Rotate_formId').value = deg;"},
    );
    $f->addField( "integer", 
        label=>$i18n->get('degree'),
        name=>"Rotate",
        value=>0,
    );
    $f->addField( "submit", name => "submit" );

    my $output = '<h1>' . $i18n->get("rotate image") . '</h1>' . $f->toHtml . $image;
    return $style->process( $output, "PBtmplBlankStyle000001" );
} ## end sub www_rotate

#----------------------------------------------------------------------------

=head2 www_rotateSave ( )

Rotate the image to the user's specifications and close the dialog

=cut

sub www_rotateSave {
    my ( $self ) = @_;
    my $asset   = $self->asset;
    my $session = $self->session;
    return $session->privilege->insufficient() unless $asset->canEdit;
    return $session->privilege->locked()       unless $asset->canEditIfLocked;

    my $tag = WebGUI::VersionTag->getWorking( $session );
    $asset = $asset->addRevision({ tagId => $tag->getId, status => "pending" });
    $asset->setVersionLock;
    delete $asset->{_storageLocation};
    $asset->getStorageLocation->rotate($asset->filename,$session->form->process("Rotate"));
    $asset->setSize($asset->getStorageLocation->getFileSize($asset->filename));
    $asset->generateThumbnail;
    WebGUI::VersionTag->autoCommitWorkingIfEnabled($session, { allowComments => 0 });

    # We're in admin mode, close the dialog
    my $helper = {
        message     => 'Image Rotated',
    };
    my $text = '<script type="text/javascript">';

    if ( ref $helper eq 'HASH' ) {
        # Process the output as JSON
        $text .= sprintf 'parent.admin.processPlugin( %s );', JSON->new->encode( $helper );
    }

    # Close dialog last so that script above runs!
    $text .= 'parent.admin.closeModalDialog();'
           . '</script>';

    $self->session->output->print( $text, 1); # skipMacros
}

1;
