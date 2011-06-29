package WebGUI::AssetHelper::Image::Crop;

use strict;
use warnings;

use Moose;
extends 'WebGUI::AssetHelper';

#-------------------------------------------------------------------

=head2 process ( )

Open a dialog to crop the image

=cut

sub process {
    my ($self)  = @_;
    my $asset   = $self->asset;
    my $session = $self->session;

    my $i18n = WebGUI::International->new( $session, 'WebGUI' );
    if ( !$asset->canEdit ) {
        return { error => $i18n->get('38'), };
    }
    elsif ( !$asset->canEditIfLocked ) {
        return { error => $i18n->get('asset locked') };
    }

    return { openDialog => $self->getUrl('crop') };
}

#-------------------------------------------------------------------

=head2 www_crop 

Displays a form for the user to crop this image.

=cut

sub www_crop {
    my ($self)  = @_;
    my $asset   = $self->asset;
    my $session = $self->session;
    return $session->privilege->insufficient() unless $asset->canEdit;
    return $session->privilege->locked()       unless $asset->canEditIfLocked;

    my $filename = $asset->filename;

    ##YUI specific datatable CSS
    my ( $style, $url ) = $session->quick(qw(style url));

    my $crop_js = qq(
        <script>
        (function() {
            var Dom = YAHOO.util.Dom, Event = YAHOO.util.Event, results = null; 

            Event.onDOMReady(function() { 
                var crop = new YAHOO.widget.ImageCropper('yui_img', { 
                    initialXY: [20, 20], 
                    keyTick: 5, 
                    shiftKeyTick: 50 
                }); 
                crop.on('moveEvent', function() { 
                    var region = crop.getCropCoords(); 
                    element = document.getElementById('Width_formId');
                    element.value = region.width;
                    element = document.getElementById('Height_formId');
                    element.value = region.height;
                    element = document.getElementById('Top_formId');
                    element.value = region.top;
                    element = document.getElementById('Left_formId');
                    element.value = region.left;
                }); 
            }); 
        })(); 
        </script>
    );

    $style->setCss( $url->extras('yui/build/resize/assets/skins/sam/resize.css') );
    $style->setCss( $url->extras('yui/build/fonts/fonts-min.css') );
    $style->setCss( $url->extras('yui/build/imagecropper/assets/skins/sam/imagecropper.css') );
    $style->setScript( $url->extras('yui/build/yahoo-dom-event/yahoo-dom-event.js') );
    $style->setScript( $url->extras('yui/build/element/element-min.js') );
    $style->setScript( $url->extras('yui/build/dragdrop/dragdrop-min.js') );
    $style->setScript( $url->extras('yui/build/resize/resize-min.js') );
    $style->setScript( $url->extras('yui/build/imagecropper/imagecropper-min.js') );

    my $i18n = WebGUI::International->new( $session, "Asset_Image" );
    my $f = $self->getForm( 'cropSave' );
    $f->addField(
        "hidden",
        -name  => "degree",
        -value => "0"
    );
    $f->addField(
        "hidden",
        -name  => "func",
        -value => "crop"
    );
    my ( $x, $y ) = $asset->getStorageLocation->getSizeInPixels($filename);
    $f->addField(
        "integer",
        -label     => $i18n->get('width'),
        -hoverHelp => $i18n->get('new width description'),
        -name      => "Width",
        -value     => $x,
    );
    $f->addField(
        "integer",
        -label     => $i18n->get('height'),
        -hoverHelp => $i18n->get('new height description'),
        -name      => "Height",
        -value     => $y,
    );
    $f->addField(
        "integer",
        -label     => $i18n->get('top'),
        -hoverHelp => $i18n->get('new width description'),
        -name      => "Top",
        -value     => $x,
    );
    $f->addField(
        "integer",
        -label     => $i18n->get('left'),
        -hoverHelp => $i18n->get('new height description'),
        -name      => "Left",
        -value     => $y,
    );
    $f->addField( "submit", name => "send" );

    my $image
        = '<div align="center" class="yui-skin-sam"><img src="'
        . $asset->getStorageLocation->getUrl($filename)
        . '" style="border-style:none;" alt="'
        . $filename
        . '" id="yui_img" /></div>'
        . $crop_js;

    my $output = '<h1>' . $i18n->get('crop image') . '</h1>' . $f->toHtml . $image;
    return $style->process( $output, "PBtmplBlankStyle000001" );
} ## end sub www_crop

#----------------------------------------------------------------------------

=head2 www_cropSave ( )

crop the image to the user's specifications and close the dialog

=cut

sub www_cropSave {
    my ($self)  = @_;
    my $asset   = $self->asset;
    my $session = $self->session;
    return $session->privilege->insufficient() unless $asset->canEdit;
    return $session->privilege->locked()       unless $asset->canEditIfLocked;

    my $tag = WebGUI::VersionTag->getWorking( $session );
    $asset = $asset->addRevision({ tagId => $tag->getId, status => "pending" });
    $asset->setVersionLock;
    delete $asset->{_storageLocation};
    $asset->getStorageLocation->crop(
        $asset->filename,
        $session->form->process("Width"),
        $session->form->process("Height"),
        $session->form->process("Top"),
        $session->form->process("Left")
    );
    $asset->generateThumbnail;
    WebGUI::VersionTag->autoCommitWorkingIfEnabled($session, { allowComments => 0 });

    # We're in admin mode, close the dialog
    my $helper = { message => 'Image croped', };
    my $text = '<script type="text/javascript">';

    if ( ref $helper eq 'HASH' ) {

        # Process the output as JSON
        $text .= sprintf 'parent.admin.processPlugin( %s );', JSON->new->encode($helper);
    }

    # Close dialog last so that script above runs!
    $text .= 'parent.admin.closeModalDialog();' . '</script>';

    $self->session->output->print( $text, 1 );    # skipMacros
} ## end sub www_cropSave

1;
