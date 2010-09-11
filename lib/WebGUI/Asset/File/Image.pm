package WebGUI::Asset::File::Image;

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
use WebGUI::Storage;
use WebGUI::Form::Image;

use Moose;
use WebGUI::Definition::Asset;
extends 'WebGUI::Asset::File';
define assetName     => ['assetName', 'Asset_Image'];
define tableName     => 'ImageAsset';
define icon          => 'image.gif';
property thumbnailSize => (
                label           => ['thumbnail size', 'Asset_Image'],
                hoverHelp       => ['Thumbnail size description', 'Asset_Image'],
                fieldType       => 'integer',
                builder         => '_default_thumbnailSize',
                lazy            => 1,
         );
sub _default_thumbnailSize {
    my $self = shift;
    return $self->session->setting->get('thumbnailSize');
}
property parameters => (
                label           => ['parameters', 'Asset_Image'],
                hoverHelp       => ['Parameters description', 'Asset_Image'],
                fieldType       => 'textarea',
                default         => 'style="border-style:none;"',
         );
property annotations => (
                fieldType       => 'hidden',
                noFormPost      => 1,
                default         => '',
         );

=head1 NAME

Package WebGUI::Asset::File::Image

=head1 DESCRIPTION

Extends WebGUI::Asset::File to add image manipulation operations.

=head1 SYNOPSIS

use WebGUI::Asset::File::Image;


=head1 METHODS

These methods are available from this class:

=cut



#-------------------------------------------------------------------

=head2 applyConstraints ( options ) 

Things that are done after a new file is attached.

=head3 options

A hash reference of optional parameters.

=head4 maxImageSize

An integer (in pixels) representing the longest edge the image may have.

=head4 thumbnailSize

An integer (in pixels) representing the longest edge a thumbnail may have.

=cut

override applyConstraints => sub {
    my $self = shift;
    my $options = shift;
    super();
    my $maxImageSize  = $options->{maxImageSize}  || $self->session->setting->get("maxImageSize");
    my $thumbnailSize = $options->{thumbnailSize} || $self->thumbnailSize || $self->session->setting->get("thumbnailSize");
    my $storage = $self->getStorageLocation;
    my $file = $self->filename;
    $storage->adjustMaxImageSize($file, $maxImageSize);
    $self->generateThumbnail($thumbnailSize);
    $self->setSize;
};



#-------------------------------------------------------------------

=head2 generateThumbnail ( [ thumbnailSize ] ) 

Generates a thumbnail for this image.

=head3 thumbnailSize

A size, in pixels, of the maximum height or width of a thumbnail. If specified this will change the thumbnail size of the image. If unspecified the thumbnail size set in the properties of this asset will be used.

=cut

sub generateThumbnail {
	my $self = shift;
	my $thumbnailSize = shift;
	if (defined $thumbnailSize) {
		$self->update({thumbnailSize=>$thumbnailSize});
	}
	$self->getStorageLocation->generateThumbnail($self->filename,$self->thumbnailSize);
}


#-------------------------------------------------------------------

=head2 getEditForm ( )

Returns the WebGUI::FormBuilder object that will be used in generating the edit page for this asset.

=cut

override getEditForm => sub {
    my $self = shift;
    my $f = super();
    my $i18n = WebGUI::International->new($self->session,"Asset_Image");

    # Fix templateId to use correct namespace and default
    my $template = $f->getTab('display')->getField('templateId');
    $template->set( hoverHelp => $i18n->get('image template description') );
    $template->set( namespace => 'ImageAsset' );
    $template->set( defaultValue => 'PBtmpl0000000000000088' );


    # Add the fields defined locally and apply any overrides from the config file
    my $overrides = $self->session->config->get("assets/".$self->className);

    if ($self->filename ne "") {
          my ($x, $y) = $self->getStorageLocation->getSizeInPixels($self->filename);

          $f->getTab('properties')->addField( "ReadOnly", 
              name      => 'thumbnail',
              label     => $i18n->get('thumbnail'),
              hoverHelp => $i18n->get('Thumbnail description'),
              value     => '<a href="'.$self->getFileUrl.'"><img src="'.$self->getThumbnailUrl.'?noCache='.time().'" alt="thumbnail" /></a>',
              ( $overrides->{thumbnail} ? %{$overrides->{thumbnail}} : () ),
          );
          $f->getTab('properties')->addField( "ReadOnly", 
              name      => 'imageSize',
              label     => $i18n->get('image size'),
              value     => $x.' x '.$y,
              ( $overrides->{imageSize} ? %{$overrides->{imageSize}} : () ),
          );
    }

    return $f;
};

#-------------------------------------------------------------------

=head2 getHelpers ( )

Add the image helpers

=cut

override getHelpers => sub {
    my ( $self ) = @_;

    my $helpers = super();
    $helpers->{resize} = {
        className   => 'WebGUI::AssetHelper::Image::Resize',
        label       => 'Resize Image',
    };
    $helpers->{rotate} = {
        className   => 'WebGUI::AssetHelper::Image::Rotate',
        label       => 'Rotate Image',
    };
    $helpers->{crop} = {
        className   => 'WebGUI::AssetHelper::Image::Crop',
        label       => 'Crop Image',
    };
    $helpers->{annotate} = {
        url         => $self->getUrl( 'func=annotate' ),
        label       => "Annotate Image",
    };

    return $helpers;
};

#-------------------------------------------------------------------

=head2 getThumbnailUrl 

Returns the URL to the thumbnail of the image stored in the Asset.

=cut

sub getThumbnailUrl {
	my $self = shift;
	return $self->getStorageLocation->getThumbnailUrl($self->filename);
}

#-------------------------------------------------------------------

=head2 view 

Renders this asset.

=cut

sub view {
	my $self = shift;
    my $session = $self->session;
    my $cache = $session->cache;
    my $cacheKey = $self->getWwwCacheKey('view');
    if (!$session->isAdminOn && $self->cacheTimeout > 10) {
        my $out = $cache->get( $cacheKey );
		return $out if $out;
	}
	my %var = %{$self->get};
    my ($crop_js, $domMe) = $self->annotate_js({ just_image => 1 });

    if ($crop_js) {
        my ($style, $url) = $session->quick(qw(style url));

        $style->setCss($url->extras('yui/build/fonts/fonts-min.css'));
        $style->setCss($url->extras('yui/container/assets/container.css'));
        $style->setScript($url->extras('yui/build/yahoo-dom-event/yahoo-dom-event.js'));
        $style->setScript($url->extras('yui/build/container/container-min.js'));
    }

    $var{controls}    = $self->getToolbar;
    $var{fileUrl}     = $self->getFileUrl;
    $var{fileIcon}    = $self->getFileIconUrl;
    $var{thumbnail}   = $self->getThumbnailUrl;
    $var{annotateJs}  = $crop_js . $domMe;
    $var{parameters} .= sprintf(q{ id="%s"}, $self->getId);
    my $out = $self->processTemplate(\%var,undef,$self->{_viewTemplate});
    if (!$session->isAdminOn && $self->cacheTimeout > 10) {
        $cache->set( $cacheKey, $out, $self->get("cacheTimeout") );
    }
    return $out;
}


#----------------------------------------------------------------------------

=head2 setFile ( filename )

Extend the superclass setFile to automatically generate thumbnails.

=cut

override setFile => sub {
    my $self    = shift;
    super();
    $self->generateThumbnail;
};

#-------------------------------------------------------------------

# 
# All of the images will have to change to support annotate.
# The revision system doesn't support the blobs, it seems.
# All of the image operations will have to be updated to support annotations.
#

=head2 www_annotate 

Allow the user to place some text on their image.  This is done via JS and tooltips

=cut

sub www_annotate {
    my $self    = shift;
    my $session = $self->session;
    return $session->privilege->insufficient() unless $self->canEdit;
    return $session->privilege->locked()       unless $self->canEditIfLocked;
	if (1) {
                my $tag = WebGUI::VersionTag->getWorking( $session );
		my $newSelf = $self->addRevision({ tagId => $tag->getId, status => "pending" });
                $newSelf->setVersionLock;
		delete $newSelf->{_storageLocation};
		$newSelf->getStorageLocation->annotate($newSelf->filename,$newSelf,$session->form);
		$newSelf->setSize($newSelf->getStorageLocation->getFileSize($newSelf->filename));
		$self = $newSelf;
		$self->generateThumbnail;
        WebGUI::VersionTag->autoCommitWorkingIfEnabled($session, { allowComments => 0 });
	}

    my ($style, $url) = $session->quick(qw(style url));

	$style->setCss($url->extras('yui/build/resize/assets/skins/sam/resize.css'));
	$style->setCss($url->extras('yui/build/fonts/fonts-min.css'));
	$style->setCss($url->extras('yui/build/imagecropper/assets/skins/sam/imagecropper.css'));

	$style->setScript($url->extras('yui/build/yahoo-dom-event/yahoo-dom-event.js'));
	$style->setScript($url->extras('yui/build/element/element-min.js'));
	$style->setScript($url->extras('yui/build/dragdrop/dragdrop-min.js'));
	$style->setScript($url->extras('yui/build/resize/resize-min.js'));
	$style->setScript($url->extras('yui/build/imagecropper/imagecropper-min.js'));

	my @pieces = split(/\n/, $self->annotations);
	
    my ($img_null, $tooltip_block, $tooltip_none) = ('', '', '');
	for (my $i = 0; $i < $#pieces; $i += 3) {
        $img_null .= "YAHOO.img.container.tt$i = null;\n";
        $tooltip_block .= "YAHOO.util.Dom.setStyle('tooltip$i', 'display', 'block');\n";
        $tooltip_none .= "YAHOO.util.Dom.setStyle('tooltip$i', 'display', 'none');\n";
        my $j = $i + 2;
    }

    my $image = '<div align="center" class="yui-skin-sam"><img src="'.$self->getStorageLocation->getUrl($self->filename).'" style="border-style:none;" alt="'.$self->filename.'" id="yui_img" /></div>';

	my ($width, $height) = $self->getStorageLocation->getSizeInPixels($self->filename);

	my @checkboxes = ();
	my $i18n = WebGUI::International->new($session,"Asset_Image");
	my $f    = WebGUI::FormBuilder->new($session);

	$f->addField( "hidden", 
		-name=>"func",
		-value=>"annotate"
		);
    $f->addField( "text", 
		-label=>$i18n->get('annotate image'),
		-value=>'',
		-hoverHelp=>$i18n->get('annotate image description'),
		-name=>'annotate_text'
		);
	$f->addField( "integer", 
		-label=>$i18n->get('top'),
		-name=>"annotate_top",
		-value=>,
		);
	$f->addField( "integer", 
		-label=>$i18n->get('left'),
		-name=>"annotate_left",
		-value=>,
		);
	$f->addField( "integer", 
		-label=>$i18n->get('width'),
		-name=>"annotate_width",
		-value=>,
		);
	$f->addField( "integer", 
		-label=>$i18n->get('height'),
		-name=>"annotate_height",
		-value=>,
		);
    $f->addField( "button", 
        -value=>$i18n->get('annotate'),
        -extras=>'onclick="switchState();"',
        );
	$f->addField( "submit", name => "send" );
    my ($crop_js, $domMe) = $self->annotate_js();
    my $output = '<h1>' . $i18n->get('annotate image') . '</h1>' . $f->toHtml . $image . $crop_js . $domMe;
    return $style->process( $output, "PBtmplBlankStyle000001" );
}

#-------------------------------------------------------------------

=head2 annotate_js ($opts)

Returns some javascript and other supporting text.

=head3 $opts

A hash reference of options

=head4 just_image

=cut

sub annotate_js {
    my $self = shift;
    my $opts = shift;

	my @pieces = split(/\n/, $self->annotations);

    # warn("pieces: $#pieces: ". $self->getId());
    return "" if !@pieces && $opts->{just_image};

    my ($img_null, $tooltip_block, $tooltip_none) = ('', '', '');
	for (my $i = 0; $i < $#pieces; $i += 3) {
        $img_null .= "YAHOO.img.container.tt$i = null;\n";
        $tooltip_block .= "YAHOO.util.Dom.setStyle('tooltip$i', 'display', 'block');\n";
        $tooltip_none .= "YAHOO.util.Dom.setStyle('tooltip$i', 'display', 'none');\n";
        my $j = $i + 2;
        # warn("i: $i: ", $self->session->form->process("delAnnotate$i"));
    }

    my $id = $$opts{just_image} ? $self->getId : "yui_img";

	my $crop_js = qq(
        <script type="text/javascript">
        var crop;
        function switchState() {
            $img_null

            if (crop) {
                crop.destroy();
                crop = null;
                $tooltip_block
            }
            else {
                crop = new YAHOO.widget.ImageCropper('$id', { 
                    initialXY: [20, 20], 
                    keyTick: 5, 
                    shiftKeyTick: 50 
                }); 
                crop.on('moveEvent', function() { 
                    var region = crop.getCropCoords();
                    element = document.getElementById('annotate_width_formId');
                    element.value = region.width;
                    element = document.getElementById('annotate_height_formId');
                    element.value = region.height;
                    element = document.getElementById('annotate_top_formId');
                    element.value = region.top;
                    element = document.getElementById('annotate_left_formId');
                    element.value = region.left;
                }); 
                $tooltip_none
            }
        }
		</script>
    );

    my $hotspots = '';
    my $domMe = '';

	for (my $i = 0; $i < $#pieces; $i += 3) {
		my $top_left = $pieces[$i];
		my $width_height = $pieces[$i + 1];
		my $note = $pieces[$i + 2];

        if ($top_left =~ /top: (\d+)px; left: (\d+)px;/) {
            $top_left = "xy[0]+$1, xy[1]+$2";
        }

        my ($width, $height) = ("", "");
        if ($width_height =~ /width: (\d+)px; height: (\d+)px;/) {
            ($width, $height) = ("$1px", "$2px");
        }

        # next if 3 == $i;

        $domMe .= qq(
                <style type="text/css">
                    div#tooltip$i { position: absolute; border:1px solid; }
                </style>

                <span id=span_tooltip$i>
                </span>

                <script type="text/javascript">
                    function on_load_$i() {
                        var xy = YAHOO.util.Dom.getXY('$id'); 

                        document.getElementById('span_tooltip$i').innerHTML = "<div id=tooltip$i style='border:1px solid;'></div>";
                        YAHOO.util.Dom.setStyle('tooltip$i', 'display', 'block');
                        YAHOO.util.Dom.setStyle('tooltip$i', 'height', '$height');
                        YAHOO.util.Dom.setStyle('tooltip$i', 'width', '$width');
                        YAHOO.util.Dom.setXY('span_tooltip$i', [$top_left]); 
                        YAHOO.util.Dom.setXY('tooltip$i', [$top_left]); 

                        YAHOO.namespace("img.container");
                        YAHOO.img.container.tt$i = new YAHOO.widget.Tooltip("tt$i", { showdelay: 0, visible: true, context:"tooltip$i", position:"relative", container:"tooltip$i", text:"$note" });
                    }
                    if (document.addEventListener) {
                        document.addEventListener("DOMContentLoaded", on_load_$i, false);
                    }
                    else if (window.attachEvent){
                        window.attachEvent('onload', on_load_$i);
                    }

                </script>
        );
    }

    return($crop_js, $domMe);
}

__PACKAGE__->meta->make_immutable;
1;
