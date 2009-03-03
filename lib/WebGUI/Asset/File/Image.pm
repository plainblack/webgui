package WebGUI::Asset::File::Image;

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
use WebGUI::Storage;
use WebGUI::HTMLForm;
use WebGUI::Utility;
use WebGUI::Form::Image;

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

sub applyConstraints {
    my $self = shift;
    my $options = shift;
    $self->SUPER::applyConstraints($options);
    my $maxImageSize = $options->{maxImageSize} || $self->get('maxImageSize') || $self->session->setting->get("maxImageSize");
    my $thumbnailSize = $options->{thumbnailSize} || $self->get('thumbnailSize') || $self->session->setting->get("thumbnailSize");
	my $parameters = $self->get("parameters");
    my $storage = $self->getStorageLocation;
	unless ($parameters =~ /alt\=/) {
		$self->update({parameters=>$parameters.' alt="'.$self->get("title").'"'});
	}
    my $file = $self->get("filename");
    $storage->adjustMaxImageSize($file, $maxImageSize);
    $self->generateThumbnail($thumbnailSize);
    $self->setSize;
}



#-------------------------------------------------------------------

=head2 definition ( definition )

Defines the properties of this asset.

=head3 definition

A hash reference passed in from a subclass definition.

=cut

sub definition {
    my $class       = shift;
    my $session     = shift;
    my $definition  = shift;
    my $i18n        = WebGUI::International->new($session,"Asset_Image");
    push @{$definition}, {
        assetName       => $i18n->get('assetName'),
        tableName       => 'ImageAsset',
        className       => 'WebGUI::Asset::File::Image',
        icon            => 'image.gif',
        properties => {
            thumbnailSize => {
                fieldType       => 'integer',
                defaultValue    => $session->setting->get("thumbnailSize"),
            },
            parameters => {
                fieldType       => 'textarea',
                defaultValue    => 'style="border-style:none;"',
            },
        },
    };
    return $class->SUPER::definition($session,$definition);
}



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
	$self->getStorageLocation->generateThumbnail($self->get("filename"),$self->get("thumbnailSize"));
}


#-------------------------------------------------------------------

=head2 getEditForm ( )

Returns the TabForm object that will be used in generating the edit page for this asset.

=cut

sub getEditForm {
	my $self = shift;
	my $tabform = $self->SUPER::getEditForm();
	my $i18n = WebGUI::International->new($self->session,"Asset_Image");
        $tabform->getTab("properties")->integer(
               	-name=>"thumbnailSize",
		-label=>$i18n->get('thumbnail size'),
		-hoverHelp=>$i18n->get('Thumbnail size description'),
		-value=>$self->getValue("thumbnailSize")
               	);
	$tabform->getTab("properties")->textarea(
		-name=>"parameters",
		-label=>$i18n->get('parameters'),
		-hoverHelp=>$i18n->get('Parameters description'),
		-value=>$self->getValue("parameters")
		);
	if ($self->get("filename") ne "") {
		$tabform->getTab("properties")->readOnly(
			-label=>$i18n->get('thumbnail'),
			-hoverHelp=>$i18n->get('Thumbnail description'),
			-value=>'<a href="'.$self->getFileUrl.'"><img src="'.$self->getThumbnailUrl.'?noCache='.$self->session->datetime->time().'" alt="thumbnail" /></a>'
			);
		my ($x, $y) = $self->getStorageLocation->getSizeInPixels($self->get("filename"));
        	$tabform->getTab("properties")->readOnly(
			-label=>$i18n->get('image size'),
			-value=>$x.' x '.$y
			);
	}
	return $tabform;
}

#----------------------------------------------------------------------------

=head2 getStorageClass

Returns the class name of the WebGUI::Storage we should use for this asset.

=cut

sub getStorageClass {
    return 'WebGUI::Storage';
}

#-------------------------------------------------------------------
sub getThumbnailUrl {
	my $self = shift;
	return $self->getStorageLocation->getThumbnailUrl($self->get("filename"));
}

#-------------------------------------------------------------------

=head2 getToolbar ( )

Returns a toolbar with a set of icons that hyperlink to functions that delete, edit, promote, demote, cut, and copy.

=cut

sub getToolbar {
	my $self = shift;
	return undef if ($self->getToolbarState);
	return $self->SUPER::getToolbar();
}

#-------------------------------------------------------------------

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

sub prepareView {
	my $self = shift;
	$self->SUPER::prepareView();
	my $template = WebGUI::Asset::Template->new($self->session, $self->get("templateId"));
	$template->prepare($self->getMetaDataAsTemplateVariables);
	$self->{_viewTemplate} = $template;
}

#-------------------------------------------------------------------
sub view {
	my $self = shift;
	if (!$self->session->var->isAdminOn && $self->get("cacheTimeout") > 10) {
		my $out = WebGUI::Cache->new($self->session,"view_".$self->getId)->get;
		return $out if $out;
	}
	my %var = %{$self->get};
	$var{controls} = $self->getToolbar;
	$var{fileUrl} = $self->getFileUrl;
	$var{fileIcon} = $self->getFileIconUrl;
	$var{thumbnail} = $self->getThumbnailUrl;
       	my $out = $self->processTemplate(\%var,undef,$self->{_viewTemplate});
	if (!$self->session->var->isAdminOn && $self->get("cacheTimeout") > 10) {
		WebGUI::Cache->new($self->session,"view_".$self->getId)->set($out,$self->get("cacheTimeout"));
	}
       	return $out;
}

#----------------------------------------------------------------------------

=head2 setFile ( filename )

Extend the superclass setFile to automatically generate thumbnails.

=cut

sub setFile {
    my $self    = shift;
    $self->SUPER::setFile(@_);
    $self->generateThumbnail;
}

#-------------------------------------------------------------------
sub www_edit {
    my $self = shift;
    return $self->session->privilege->insufficient() unless $self->canEdit;
    return $self->session->privilege->locked() unless $self->canEditIfLocked;
	my $i18n = WebGUI::International->new($self->session, 'Asset_Image');
	$self->getAdminConsole->addSubmenuItem($self->getUrl('func=resize'),$i18n->get("resize image")) if ($self->get("filename"));
	$self->getAdminConsole->addSubmenuItem($self->getUrl('func=rotate'),$i18n->get("rotate image")) if ($self->get("filename"));
	$self->getAdminConsole->addSubmenuItem($self->getUrl('func=crop'),$i18n->get("crop image")) if ($self->get("filename"));
	$self->getAdminConsole->addSubmenuItem($self->getUrl('func=annotate'),$i18n->get("annotate image")) if ($self->get("filename"));
	$self->getAdminConsole->addSubmenuItem($self->getUrl('func=undo'),$i18n->get("undo image")) if ($self->get("filename"));
	my $tabform = $self->getEditForm;
	$tabform->getTab("display")->template(
		-value=>$self->get("templateId"),
		-namespace=>"ImageAsset",
		-hoverHelp=>$i18n->get('image template description'),
		-defaultValue=>"PBtmpl0000000000000088"
		);
        return $self->getAdminConsole->render($tabform->print,$i18n->get("edit image"));
}

#-------------------------------------------------------------------
sub www_undo {
    my $self = shift;
    my $previous = (@{$self->getRevisions()})[1];
    # instantiate assetId 
    if ($previous) {
	    warn("here");
	    # my $session = $self->session;
	    warn("here");

	    # my $cache = WebGUI::Cache->new($self->session, ["asset",$self->getId,$self->getRevisionDate]);
	    warn("here");
	    # $cache->flush;
	    warn("here");
	    # my $cache = WebGUI::Cache->new($previous->session, ["asset",$previous->getId,$previous->getRevisionDate]);
	    warn("here");
	    # $cache->flush;
	    warn("here");

	    warn("$previous");
  	    warn(ref $previous);
	    warn($previous->getId);
	    $self = $self->purgeRevision();
	    # $self = undef;
	    warn("here");
	    # $self = WebGUI::Asset->new($previous->session, $previous->getId, ref $previous, $previous->getRevisionDate);
	    $self = $previous;
	    warn("$self");
  	    warn(ref $self);
	    warn($self->getId);
	    warn($self->session->cache);
	    $self->generateThumbnail;
    }
    return $self->www_edit();
}

#-------------------------------------------------------------------
sub www_annotate {
    my $self = shift;
    return $self->session->privilege->insufficient() unless $self->canEdit;
    return $self->session->privilege->locked() unless $self->canEditIfLocked;
	if ($self->session->form->process("annotate_text")) {
		my $newSelf = $self->addRevision();
		delete $newSelf->{_storageLocation};
        warn("here");
		$newSelf->getStorageLocation->annotate($newSelf->get("filename"),$newSelf->session->form);
        warn("here");
		$newSelf->setSize($newSelf->getStorageLocation->getFileSize($newSelf->get("filename")));
        warn("here");
		$self = $newSelf;
        warn("here");
		$self->generateThumbnail;
        warn("here");
	}

    my ($style, $url) = $self->session->quick(qw(style url));
	# http://www.kryogenix.org/code/browser/annimg/annimg.html (creative commons)
	$style->setLink($url->extras('annotate/imageMap.css'), {rel=>'stylesheet', type=>'text/css'});

	my $imageAsset = $self->session->db->getRow("ImageAsset","assetId",$self->getId);

	warn($imageAsset->{annotations});
	my @pieces = split(/\n/, $imageAsset->{annotations});
	# my ($top_left, $width_height, $note) = split(/\n/, $imageAsset->{annotations});
	
	my $imageLoc = $self->getStorageLocation->getUrl($self->get("filename"));
	my $image = '<div align="center" class="yui-skin-sam"><img src="$imageLoc" style="border-style:none;" alt="'.$self->get("filename").'" class="image" id="yui-img" /></div>';

	my ($width, $height) = $self->getStorageLocation->getSize($self->get("filename"));

	my $hotspots = "";
	my $notes = "";
	my @checkboxes = ();
	my $i18n = WebGUI::International->new($self->session,"Asset_Image");
	my $f = WebGUI::HTMLForm->new($self->session,-action=>$self->getUrl);

	my $mouseCoord_js = qq(
		<script type = "text/javascript"> 
		   function updateMouseCoordinates(e)  
		   { 
            var posx = 0;
            var posy = 0;
            if (!e) var e = window.event;

            element1 = document.getElementById('annotate_top_formId');
            element2 = document.getElementById('annotate_left_formId');
		    if (0 == element1.value && 0 == element2.value) {
			element1.value = e.layerX || 1;
			element2.value = e.layerY || 1;
			return;
		    }
            element1 = document.getElementById('annotate_width_formId');
            element2 = document.getElementById('annotate_height_formId');
		    if (0 == element1.value && 0 == element2.value) {
			element1.value = e.layerX || 1;
			element2.value = e.layerY || 1;
			return;
		    }

	if (e.pageX || e.pageY) 	{
		posx = e.pageX;
		posy = e.pageY;
	}
	else if (e.clientX || e.clientY) 	{
		posx = e.clientX + document.body.scrollLeft
			+ document.documentElement.scrollLeft;
		posy = e.clientY + document.body.scrollTop
			+ document.documentElement.scrollTop;
	}
	// posx and posy contain the mouse position relative to the document
	// Do something with this information
		   // alert(e.clientX - document.body.scrollLeft);
		   // alert(posx);
		   // alert(posy);
		   // alert(e.offsetX);
		   // alert(e.offsetY);
	// alert(e.clientX);
		   } 
		</script>
	);

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

	for (my $i = 0; $i < $#pieces; $i += 3) {
		my $top_left = $pieces[$i];
		my $width_height = $pieces[$i + 1];
		my $note = $pieces[$i + 2];

		$hotspots .= qq(
			dd#Def_${i} { $top_left }
			dd#Def_$i a{ position: absolute; $width_height; text-decoration: none; border: 1px solid #FFFCE6; background: transparent url(/www/extras/annotate/note.png) repeat; }
			dd#Def_$i a span{ display: none; }
			dd#Def_$i a:hover{ background: transparent url(/www/extras/annotate/hover.png) repeat; border: 1px solid #BCBCBC; }
			dd#Def_$i a:hover span{
				display: block;
				text-indent: 0;
				vertical-align: top;
				color: #000;
				background-color: #F4F4F4;
				font-weight: bold;
				position: absolute;
				border: 1px solid #BCBCBC;
				bottom: 100%;
				margin: 0;
				padding: 5px;
				width: 75%;
			}
		);

		$notes .= qq(
			<dd id="Def_$i"><a href="#"><span>$note</span></a></dd>
		);

		push(@checkboxes, $f->checkbox(
				-label=>$i18n->get('delete') . " '$note'",
				-checked=>0,
				-name=>"delAnnotate$i",
				-value=>"1"
			)
		);
		$f->hidden(
			-name=>"annotates",
			-value=>"$i"
			);
	}

	my $imageMap = qq(
		<div align="center" class="yui-skin-sam">
		<dl id="imageMap" onmousedown="updateMouseCoordinates(event)">  
		  <!-- <dt class="title">Shoes</dt> -->
		  <!-- <dt id="shoe">My heel</dt> -->
		  $notes
		</dl>   
		</div>
	);

	my $imageCss = qq(
		<style type="text/css">
		/* http://www.frankmanno.com/ideas/css-imagemap-redux/ Creative Commons */
		/* ---------- hidden ONLY if CSS is enabled.  If disabled, image is rendered ---------- */
		img.image{ display: none; }
		/* 124 x 110 */
		dl#imageMap{
			id: yui-img;
			class: "yui-skin-sam"
			margin: 0;
			padding: 0;
			background: transparent url($imageLoc) top left no-repeat;
			height: ${height}px;
			width: ${width}px;
			position: relative;
		}

		dt{ margin: 0; padding: 0; position: absolute; font-size: 85%; display: none; }
		dd{ margin: 0; padding: 0; position: absolute;  font-size: 85%; }

		dl#imageMap dt.title{
			color: White;
			display: block;
			font-size: 115%;
			padding: 5px 0 0 5px;
		}

		/* ---------- Hotspot Declarations ---------- */
		$hotspots
		</style>
	);
	$self->getAdminConsole->addSubmenuItem($self->getUrl('func=edit'),$i18n->get("edit image"));
	$f->hidden(
		-name=>"func",
		-value=>"annotate"
		);
       	$f->text(
		-label=>$i18n->get('annotate image'),
		-value=>'',
		-hoverHelp=>$i18n->get('annotate image description'),
		-name=>'annotate_text'
		);
	$f->integer(
		-label=>$i18n->get('top'),
		-name=>"annotate_top",
		-value=>,
		);
	$f->integer(
		-label=>$i18n->get('left'),
		-name=>"annotate_left",
		-value=>,
		);
	$f->integer(
		-label=>$i18n->get('width'),
		-name=>"annotate_width",
		-value=>,
		);
	$f->integer(
		-label=>$i18n->get('height'),
		-name=>"annotate_height",
		-value=>,
		);
	$f->submit;
        return $self->getAdminConsole->render($f->print."$mouseCoord_js\n$crop_js\n$imageCss\n$image\n$imageMap",$i18n->get("annotate image"));
}

#-------------------------------------------------------------------
sub www_rotate {
    my $self = shift;
    return $self->session->privilege->insufficient() unless $self->canEdit;
    return $self->session->privilege->locked() unless $self->canEditIfLocked;
	if (defined $self->session->form->process("degree")) {
		my $newSelf = $self->addRevision();
		delete $newSelf->{_storageLocation};
		$newSelf->getStorageLocation->rotate($newSelf->get("filename"),$newSelf->session->form->process("degree"));
		$newSelf->setSize($newSelf->getStorageLocation->getFileSize($newSelf->get("filename")));
		$self = $newSelf;
		$self->generateThumbnail;
	}

	my ($x, $y) = $self->getStorageLocation->getSizeInPixels($self->get("filename"));

	##YUI specific datatable CSS
	my ($style, $url) = $self->session->quick(qw(style url));

	my $img_name = $self->getStorageLocation->getUrl($self->get("filename"));
	my $img_file = $self->get("filename");
	my $rotate_js = qq(
	    <canvas id="canvas"></canvas>

	    <script type="text/javascript">
		var can = document.getElementById('canvas');
		var ctx = can.getContext('2d');
		var deg = 0;

		var img = new Image();
		img.onload = function(){
		    can.width = img.width;
		    can.height = img.height;
		    ctx.drawImage(img, 0, 0, img.width, img.height);
		}
		img.src = '$img_name';
		img.alt = '$img_file';

		can.onclick = function() {
		    var ctx = can.getContext('2d');
		    var deg = parseInt(document.forms[0].degree.value);
		    deg += 90;
		    if (270 < deg) {
		       deg = 0;
		    }
		    document.forms[0].degree.value = deg;
		    //alert(deg);
		    ctx.clearRect(0, 0, img.width, img.height);
		    can.setAttribute('width', img.width);
    		    can.setAttribute('height', img.height);
		    var width = 0;
		    var height = 0;
		    if (0 == deg) {
			width = 0;
			height = 0;
		    } else if (90 == deg) {
			width = 0;
			height = -img.height;
		    } else if (180 == deg) {
			width = -img.width;
			height = -img.height;
		    } else if (270 == deg) {
			width = -img.width;
			height = 0;
		    }

		    ctx.rotate(deg * Math.PI / 180);
		    ctx.drawImage(img, width, height);
		    };
	    </script>
	);
	my $image = qq(<div align="center" class="yui-skin-sam">$rotate_js</div>);

	my $i18n = WebGUI::International->new($self->session,"Asset_Image");
	$self->getAdminConsole->addSubmenuItem($self->getUrl('func=edit'),$i18n->get("edit image"));
	my $f = WebGUI::HTMLForm->new($self->session,-action=>$self->getUrl);
	$f->hidden(
		-name=>"func",
		-value=>"rotate"
		);
	$f->hidden(
		-name=>"degree",
		-value=>0
		);
       	$f->readOnly(
		-value=>$i18n->get('rotate image label'),
		-hoverHelp=>$i18n->get('rotate image description'),
		);
	$f->submit;
        return $self->getAdminConsole->render($f->print.$image,$i18n->get("rotate image"));
}

#-------------------------------------------------------------------
sub www_resize {
    my $self = shift;
    return $self->session->privilege->insufficient() unless $self->canEdit;
    return $self->session->privilege->locked() unless $self->canEditIfLocked;
	if ($self->session->form->process("newWidth") || $self->session->form->process("newHeight")) {
		my $newSelf = $self->addRevision();
		delete $newSelf->{_storageLocation};
		$newSelf->getStorageLocation->resize($newSelf->get("filename"),$newSelf->session->form->process("newWidth"),$newSelf->session->form->process("newHeight"));
		$newSelf->setSize($newSelf->getStorageLocation->getFileSize($newSelf->get("filename")));
		$self = $newSelf;
		$self->generateThumbnail;
	}

	my ($x, $y) = $self->getStorageLocation->getSizeInPixels($self->get("filename"));

	##YUI specific datatable CSS
	my ($style, $url) = $self->session->quick(qw(style url));

	$style->setLink($url->extras('yui/build/fonts/fonts-min.css'), {rel=>'stylesheet', type=>'text/css'});
	$style->setLink($url->extras('yui/build/resize/assets/skins/sam/resize.css'), {rel=>'stylesheet', type=>'text/css'});
	$style->setScript($url->extras('yui/build/yahoo-dom-event/yahoo-dom-event.js'), {type=>'text/javascript'});
	$style->setScript($url->extras('yui/build/element/element-beta-min.js'), {type=>'text/javascript'});
	$style->setScript($url->extras('yui/build/dragdrop/dragdrop-min.js'), {type=>'text/javascript'});
	$style->setScript($url->extras('yui/build/resize/resize-min.js'), {type=>'text/javascript'});
	$style->setScript($url->extras('yui/build/animation/animation-min.js'), {type=>'text/javascript'});

	my $resize_js = qq(
		<script>
		(function() { 
			  var Dom = YAHOO.util.Dom, 
			      Event = YAHOO.util.Event; 
		       
			      var resize = new YAHOO.util.Resize('yui_img', { 
				  handles: 'all', 
				  knobHandles: true, 
				  height: '${x}px', 
				  width: '${y}px', 
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

	my $i18n = WebGUI::International->new($self->session,"Asset_Image");
	$self->getAdminConsole->addSubmenuItem($self->getUrl('func=edit'),$i18n->get("edit image"));
	my $f = WebGUI::HTMLForm->new($self->session,-action=>$self->getUrl);
	$f->hidden(
		-name=>"func",
		-value=>"resize"
		);
       	$f->readOnly(
		-label=>$i18n->get('image size'),
		-hoverHelp=>$i18n->get('image size description'),
		-value=>$x.' x '.$y,
		);
	$f->integer(
		-label=>$i18n->get('new width'),
		-hoverHelp=>$i18n->get('new width description'),
		-name=>"newWidth",
		-value=>$x,
		);
	$f->integer(
		-label=>$i18n->get('new height'),
		-hoverHelp=>$i18n->get('new height description'),
		-name=>"newHeight",
		-value=>$y,
		);
	$f->submit;
	my $image = '<div align="center" class="yui-skin-sam"><img src="'.$self->getStorageLocation->getUrl($self->get("filename")).'" style="border-style:none;" alt="'.$self->get("filename").'" id="yui_img" /></div>'.$resize_js;
        return $self->getAdminConsole->render($f->print.$image,$i18n->get("resize image"));
}

#-------------------------------------------------------------------
# feel free to take over typing
sub www_crop {
    my $self = shift;
    return $self->session->privilege->insufficient() unless $self->canEdit;
    return $self->session->privilege->locked() unless $self->canEditIfLocked;

	if ($self->session->form->process("Width") || $self->session->form->process("Height") 
        || $self->session->form->process("Top") || $self->session->form->process("Left")) {
            my $newSelf = $self->addRevision();
            delete $newSelf->{_storageLocation};
            $newSelf->getStorageLocation->crop(
            $newSelf->get("filename"),
            $newSelf->session->form->process("Width"),
            $newSelf->session->form->process("Height"),
            $newSelf->session->form->process("Top"),
            $newSelf->session->form->process("Left")
        );
		$self = $newSelf;
		$self->generateThumbnail;
	}

	my $filename = $self->get("filename");

	##YUI specific datatable CSS
    my ($style, $url) = $self->session->quick(qw(style url));

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

	$style->setLink($url->extras('yui/build/resize/assets/skins/sam/resize.css'), {rel=>'stylesheet', type=>'text/css'});
	$style->setLink($url->extras('yui/build/fonts/fonts-min.css'), {rel=>'stylesheet', type=>'text/css'});
	$style->setLink($url->extras('yui/build/imagecropper/assets/skins/sam/imagecropper.css'), {rel=>'stylesheet', type=>'text/css'});
	$style->setScript($url->extras('yui/build/yahoo-dom-event/yahoo-dom-event.js'), {type=>'text/javascript'});
	$style->setScript($url->extras('yui/build/element/element-beta-min.js'), {type=>'text/javascript'});
	$style->setScript($url->extras('yui/build/dragdrop/dragdrop-min.js'), {type=>'text/javascript'});
	$style->setScript($url->extras('yui/build/resize/resize-min.js'), {type=>'text/javascript'});
	$style->setScript($url->extras('yui/build/imagecropper/imagecropper-beta-min.js'), {type=>'text/javascript'});

	my $i18n = WebGUI::International->new($self->session,"Asset_Image");

	$self->getAdminConsole->addSubmenuItem($self->getUrl('func=edit'),$i18n->get("edit image"));
	my $f = WebGUI::HTMLForm->new($self->session,-action=>$self->getUrl);
	$f->hidden(
		-name=>"degree",
		-value=>"0"
		);
	$f->hidden(
		-name=>"func",
		-value=>"crop"
		);
	my ($x, $y) = $self->getStorageLocation->getSizeInPixels($filename);
	$f->integer(
		-label=>$i18n->get('width'),
		-hoverHelp=>$i18n->get('new width description'),
		-name=>"Width",
		-value=>$x,
		);
	$f->integer(
		-label=>$i18n->get('height'),
		-hoverHelp=>$i18n->get('new height description'),
		-name=>"Height",
		-value=>$y,
		);
	$f->integer(
		-label=>$i18n->get('top'),
		-hoverHelp=>$i18n->get('new width description'),
		-name=>"Top",
		-value=>$x,
		);
	$f->integer(
		-label=>$i18n->get('left'),
		-hoverHelp=>$i18n->get('new height description'),
		-name=>"Left",
		-value=>$y,
		);
	$f->submit;

	my $image = '<div align="center" class="yui-skin-sam"><img src="'.$self->getStorageLocation->getUrl($filename).'" style="border-style:none;" alt="'.$filename.'" id="yui_img" /></div>'.$crop_js;

    return $self->getAdminConsole->render($f->print.$image,$i18n->get("crop image"));
}

#-------------------------------------------------------------------
# Use superclass method for now.
sub www_view {
	my $self = shift;
	$self->SUPER::www_view;
}

#sub www_view {
#	my $self = shift;
#	my $storage = $self->getStorageLocation;
#	$self->session->http->setRedirect($storage->getUrl($self->get("filename")));
#	$self->session->http->setStreamedFile($storage->getPath($self->get("filename")));
#	return "1";
#}


1;

