package WebGUI::AssetHelper::Image::Resize;

use strict;
use warnings;

use Moose;
extends 'WebGUI::AssetHelper';

#-------------------------------------------------------------------

=head2 process ( )

Open a dialog to resize the image

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
        openDialog  => $self->getUrl( 'resize' )
    };
}

#-------------------------------------------------------------------

=head2 www_resize 

Displays a form for the user to resize this image.

=cut

sub www_resize {
    my ( $self ) = @_;
    my $asset   = $self->asset;
    my $session = $self->session;
    return $session->privilege->insufficient() unless $asset->canEdit;
    return $session->privilege->locked()       unless $asset->canEditIfLocked;

    my ( $x, $y ) = $asset->getStorageLocation->getSizeInPixels( $asset->filename );

    ##YUI specific datatable CSS
    my ( $style, $url ) = $session->quick(qw(style url));

    $style->setCss( $url->extras('yui/build/fonts/fonts-min.css') );
    $style->setCss( $url->extras('yui/build/resize/assets/skins/sam/resize.css') );
    $style->setScript( $url->extras('yui/build/yahoo-dom-event/yahoo-dom-event.js') );
    $style->setScript( $url->extras('yui/build/element/element-min.js') );
    $style->setScript( $url->extras('yui/build/dragdrop/dragdrop-min.js') );
    $style->setScript( $url->extras('yui/build/resize/resize-min.js') );
    $style->setScript( $url->extras('yui/build/animation/animation-min.js') );

    my $resize_js = qq(
		<script>
		(function() { 
			  var Dom = YAHOO.util.Dom, 
			      Event = YAHOO.util.Event; 
		       
			      var resize = new YAHOO.util.Resize('yui_img', { 
				  handles: 'all', 
				  knobHandles: true, 
				  height: '${y}px', 
				  width: '${x}px', 
				    proxy: true, 
				    ghost: true, 
				    status: true, 
				    draggable: false, 
				    ratio: true,
				    animate: true, 
				    animateDuration: .75, 
				    animateEasing: YAHOO.util.Easing.backBoth 
				}); 
			 
				resize.on('startResize', function() { 
				    this.getProxyEl().innerHTML = '<img src="' + this.get('element').src + '" style="height: 100%; width: 100%;">'; 
				    Dom.setStyle(this.getProxyEl().firstChild, 'opacity', '.25'); 
				}, resize, true); 

				resize.on('resize', function(e) { 
				    element = document.getElementById('newWidth_formId');
				    element.value = e.width;

				    element = document.getElementById('newHeight_formId');
				    element.value = e.height;
			        }, resize, true); 
			})(); 
		</script>
	);

    my $i18n = WebGUI::International->new( $session, "Asset_Image" );
    my $f = $self->getForm( 'resizeSave' );
    $f->addField(
        "readOnly",
        label     => $i18n->get('image size'),
        hoverHelp => $i18n->get('image size description'),
        value     => $x . ' x ' . $y,
    );
    $f->addField(
        "integer",
        label     => $i18n->get('new width'),
        hoverHelp => $i18n->get('new width description'),
        name      => "newWidth",
        value     => $x,
    );
    $f->addField(
        "integer",
        label     => $i18n->get('new height'),
        hoverHelp => $i18n->get('new height description'),
        name      => "newHeight",
        value     => $y,
    );
    $f->addField( "submit", name => "send" );
    my $image
        = '<div align="center" class="yui-skin-sam"><img src="'
        . $asset->getStorageLocation->getUrl( $asset->filename )
        . '" style="border-style:none;" alt="'
        . $asset->filename
        . '" id="yui_img" /></div>'
        . $resize_js;
    my $output = '<h1>' . $i18n->get('resize image') . '</h1>' . $f->toHtml . $image;
    return $style->process( $output, "PBtmplBlankStyle000001" );
} ## end sub www_resize

#----------------------------------------------------------------------------

=head2 www_resizeSave ( )

Resize the image to the user's specifications and close the dialog

=cut

sub www_resizeSave {
    my ( $self ) = @_;
    my $asset   = $self->asset;
    my $session = $self->session;
    return $session->privilege->insufficient() unless $asset->canEdit;
    return $session->privilege->locked()       unless $asset->canEditIfLocked;
    my $tag = WebGUI::VersionTag->getWorking($session);
    $asset = $asset->addRevision( { tagId => $tag->getId, status => "pending" } );
    $asset->setVersionLock;
    delete $asset->{_storageLocation};
    $asset->getStorageLocation->resize(
        $asset->filename,
        $session->form->process("newWidth"),
        $session->form->process("newHeight")
    );
    $asset->setSize( $asset->getStorageLocation->getFileSize( $asset->filename ) );
    $asset->generateThumbnail;
    WebGUI::VersionTag->autoCommitWorkingIfEnabled( $session, { allowComments => 0 } );

    # We're in admin mode, close the dialog
    my $helper = {
        message     => 'Image Resized',
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
