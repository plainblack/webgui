package WebGUI::Operation::FormHelpers;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::Asset;
use WebGUI::Asset::Wobject::Folder;
use WebGUI::Form::Group;
use WebGUI::HTMLForm;
use WebGUI::Storage::Image;

=head1 NAME

Package WebGUI::Operation::FormHelpers

=head1 DESCRIPTION

Operational support for various things relating to forms and rich editors.

#-------------------------------------------------------------------

=head2 www_formAssetTree ( $session )

Returns a list of the all the current Asset's children as form.  The children can be filtered via the
form variable C<classLimiter>.  A crumb trail is provided for navigation.

=cut

sub www_formAssetTree {
	my $session = shift;
	$session->http->setCacheControl("none");
	my $base = WebGUI::Asset->newByUrl($session) || WebGUI::Asset->getRoot($session);
	my @crumb;
	my $ancestors = $base->getLineage(["self","ancestors"],{returnObjects=>1});
	foreach my $ancestor (@{$ancestors}) {
		my $url = $ancestor->getUrl("op=formAssetTree;formId=".$session->form->process("formId"));
		$url .= ";classLimiter=".$session->form->process("classLimiter") if ($session->form->process("classLimiter"));
		push(@crumb,'<a href="'.$url.'" class="crumb">'.$ancestor->get("menuTitle").'</a>');
	}
	my $output = '
		<html><head>
		<style type="text/css">
		.base {
        		font-family:  "Lucida Grande", "Lucida Sans Unicode", Tahoma, Verdana, Arial, sans-serif;
			font-size: 12px;
		}
		a {
        		color: #0f3ccc;
        		text-decoration: none;
		}
		a:hover {
			color: #000080;
			text-decoration: underline;	
		}
		.selectLink {
			color: #cc7700;
		}
		.crumb {
			color: orange;
		}
		.crumbTrail {
			padding: 3px;
			background-color: #eeeeee;
			-moz-border-radius: 10px;
		}
		.traverse {
			font-size: 15px;
		}
		</style></head><body>
		<div class="base">
		<div class="crumbTrail">'.join(" &gt; ", @crumb)."</div><br />\n";
	my $children = $base->getLineage(["children"],{returnObjects=>1});
	my $i18n = WebGUI::International->new($session);
	my $limit = $session->form->process("classLimiter");
	foreach my $child (@{$children}) {
		next unless $child->canView;
		if ($limit eq "" || $child->get("className") =~ /^$limit/) {
			$output .= '<a href="#" class="selectLink" onclick="window.opener.document.getElementById(\''.$session->form->process("formId")
				.'\').value=\''.$child->getId.'\';window.opener.document.getElementById(\''.
				$session->form->process("formId").'_display\').value=\''.$child->get("title").'\';window.close();">['.$i18n->get("select").']</a> ';
		} else {
			$output .= '<span class="selectLink">['.$i18n->get("select").']</span> ';
		}
		my $url = $child->getUrl("op=formAssetTree;formId=".$session->form->process("formId"));
		$url .= ";classLimiter=".$session->form->process("classLimiter") if ($session->form->process("classLimiter"));
		$output .= '<a href="'.$url.'" class="traverse">'.$child->get("menuTitle").'</a>'."<br />\n";	
	}
	$output .= '</div></body></html>';
	$session->style->useEmptyStyle("1");
	return $output;
}


#-------------------------------------------------------------------

=head2 www_richEditPageTree ( $session )

Asset picker for the rich editor.

=cut

sub www_richEditPageTree {
	my $session = shift;
	$session->http->setCacheControl("none");
	my $i18n = WebGUI::International->new($session);
	my $f = WebGUI::HTMLForm->new($session,-action=>"#",-extras=>'name"linkchooser"');
	$f->text(
		-name=>"url",
		-label=>$i18n->get(104),
		-hoverHelp=>$i18n->get('104 description'),
		);
	$f->selectBox(
		-name=>"target",
		-label=>$i18n->get('target'),
		-hoverHelp=>$i18n->get('target description'),
		-options=>{"_self"=>$i18n->get('link in same window'),
		           "_blank"=>$i18n->get('link in new window')},
		);
	$f->button(
		-value=>$i18n->get('done'),
		-extras=>'onclick="createLink()"'
		);
	$session->style->setScript($session->url->extras('tinymce2/jscripts/tiny_mce/tiny_mce_popup.js'),{type=>"text/javascript"});
	my $output = '<fieldset><legend>'.$i18n->get('insert a link').'</legend>
		<fieldset><legend>'.$i18n->get('insert a link').'</legend>'.$f->print.'</fieldset>
	<script type="text/javascript">
function createLink() {
    if (window.opener) {        
        if (document.getElementById("url_formId").value == "") {
           alert("'.$i18n->get("link enter alert").'");
           document.getElementById("url_formId").focus();
        }
	var link = \'<a href="\'+"^" + "/" + ";" + document.getElementById("url_formId").value+\'">\';
	link += window.opener.tinyMceSelectedText; 
	link += \'</a>\';
	window.opener.tinyMCE.execCommand("mceInsertContent",false,link);
     window.close();
    }
}
</script><fieldset><legend>'.$i18n->get('pages').'</legend> ';
	my $base = WebGUI::Asset->newByUrl($session) || WebGUI::Asset->getRoot($session);
	my @crumb;
	my $ancestors = $base->getLineage(["self","ancestors"],{returnObjects=>1});
	foreach my $ancestor (@{$ancestors}) {
		push(@crumb,'<a href="'.$ancestor->getUrl("op=richEditPageTree").'">'.$ancestor->get("menuTitle").'</a>');
	}	
	$output .= '<p>'.join(" &gt; ", @crumb)."</p>\n";
	my $children = $base->getLineage(["children"],{returnObjects=>1});
	foreach my $child (@{$children}) {
		next unless $child->canView;
		$output .= '<a href="#" onclick="document.getElementById(\'url_formId\').value=\''.$child->get("url").'\'">['.$i18n->get("select").']</a> <a href="'.$child->getUrl("op=richEditPageTree").'">'.$child->get("menuTitle").'</a>'."<br />\n";	
	}
	$session->style->useEmptyStyle("1");
	return $output.'</fieldset></fieldset>';
}



#-------------------------------------------------------------------

=head2 www_richEditImageTree ( $session )

Similar to www_formAssetTree, except it is limited to only display assets of class WebGUI::Asset::File::Image.
Each link display a thumbnail of the image via www_richEditViewThumbnail.

=cut

sub www_richEditImageTree {
	my $session = shift;
	$session->http->setCacheControl("none");
	my $base = WebGUI::Asset->newByUrl($session) || WebGUI::Asset->getRoot($session);
	my @crumb;
	my $ancestors = $base->getLineage(["self","ancestors"],{returnObjects=>1});
	my $media;
	my @output;
	my $i18n = WebGUI::International->new($session, 'Operation_FormHelpers');
	foreach my $ancestor (@{$ancestors}) {
		push(@crumb,'<a href="'.$ancestor->getUrl("op=richEditImageTree").'">'.$ancestor->get("menuTitle").'</a>');
		# check if we are in (a subdirectory of) Media
		if ($ancestor->get('assetId') eq 'PBasset000000000000003') {
			$media = $ancestor;
		}
	}	
	if ($media) {
		# if in (a subdirectory of) Media, give user the ability to create folders or upload images
		push(@output, '<p>[ <a href="');
		push(@output, $base->getUrl('op=richEditAddFolder'));
		push(@output, '">'.$i18n->get('Create new folder').'</a> ] &nbsp; [ <a href="');
		push(@output, $base->getUrl('op=richEditAddImage'));
		push(@output, '">'.$i18n->get('Upload new image').'</a> ]</p>');
	} else {
		$media = WebGUI::Asset->getMedia($session);
		# if not in Media, provide a direct link to it
		push(@output, '<p>[ <a href="'.$media->getUrl('op=richEditImageTree').'">'.$media->get('title').'</a> ]</p>');
	}
	push(@output, '<p>'.join(" &gt; ", @crumb)."</p>\n");
	my $children = $base->getLineage(["children"],{returnObjects=>1});
	foreach my $child (@{$children}) {
		next unless $child->canView;
		if ($child->get("className") =~ /^WebGUI::Asset::File::Image/) {
			push(@output, '<a href="'.$child->getUrl("op=richEditViewThumbnail").'" target="viewer">['.$i18n->get("select","WebGUI").']</a> ');
		} else {
			push(@output, "[".$i18n->get("select","WebGUI")."] ");
		}
		push(@output, '<a href="'.$child->getUrl("op=richEditImageTree").'">'.$child->get("menuTitle").'</a>'."<br />\n");
	}
	$session->style->useEmptyStyle("1");
	return join('', @output);
}


#-------------------------------------------------------------------

=head2 www_richEditViewThumbnail ( $session )

Displays a thumbnail of an Image Asset in the Image manager for the Rich Editor.  The current
URL in the session object is used to determine which Image is used.

=cut

sub www_richEditViewThumbnail {
	my $session = shift;
	$session->http->setCacheControl("none");
	my $image = WebGUI::Asset->newByUrl($session);
	my $i18n = WebGUI::International->new($session);
	$session->style->useEmptyStyle("1");
	if ($image->get("className") =~ /WebGUI::Asset::File::Image/) {
		my $output = '<div align="center">';
		$output .= '<img src="'.$image->getThumbnailUrl.'" style="border-style:none;" alt="'.$i18n->get('preview').'" />';
		$output .= '<br />';
		$output .= $image->get("filename");
		$output .= '</div>';
		$output .= '<script type="text/javascript">';
		$output .= "\nvar src = '".$image->getFileUrl."';\n";
		$output .= "if(src.length > 0) {
				var manager=window.parent;
   				if(manager)		      	
		      		manager.document.getElementById('txtFileName').value = src;
    			}
    		    </script>\n";
		return $output;
	}
	return '<div align="center"><img src="'.$session->url->extras('tinymce2/images/icon.gif').'" style="border-style:none;" alt="'.$i18n->get('image manager').'" /></div>';
}

#-------------------------------------------------------------------

=head2 www_richEditAddFolder ( $session )

Returns a form to add a folder using the rich editor. The purpose of this feature is to provide a very simple way for end-users to create a folder from within the rich editor, in stead of having to leave the rich editor and use the asset manager. A very minimal set of options is supplied, all other options should be derived from the current asset.

=cut

sub www_richEditAddFolder {
	my $session = shift;
	$session->http->setCacheControl("none");
	my $i18n = WebGUI::International->new($session, 'Operation_FormHelpers');
	my $f = WebGUI::HTMLForm->new($session);
	$f->hidden(
		name		=> 'op',
		value		=> 'richEditAddFolderSave',
		);
	$f->text(
		label		=> $i18n->get('Folder name'),
		name		=> 'filename',
		);
	$f->submit(
		value		=> $i18n->get('Create'),
		);
	$f->button(
		value		=> $i18n->get('Cancel'),
		extras		=> 'onclick="history.go(-1);"',
		);
	my $html = '<h1>'.$i18n->get('Create new folder').'</h1>'.$f->print;
	return $session->style->process($html, 'PBtmpl0000000000000137');
}


#-------------------------------------------------------------------

=head2 www_richEditAddFolderSave ( $session )

Creates a directory under the current asset. The filename should be specified in the form. The Edit and View rights from the current asset are used if not specified in the form. All other properties are copied from the current asset.

=cut

sub www_richEditAddFolderSave {
	my $session = shift;
	$session->http->setCacheControl("none");
	# get base url
	my $base = WebGUI::Asset->newByUrl($session) || WebGUI::Asset->getRoot($session);
	# check if user can edit the current asset
	return WebGUI::Privilege::insufficient() unless $base->canEdit;

	my $filename = $session->form->process('filename') || 'untitled';
	$base->addChild({
		# Asset properties
		title                    => $filename,
		menuTitle                => $filename,
		url                      => $base->getUrl.'/'.$filename,
		groupIdEdit              => $session->form->process('groupIdEdit') || $base->get('groupIdEdit'),
		groupIdView              => $session->form->process('groupIdView') || $base->get('groupIdView'),
		ownerUserId              => $session->user->userId,
		startDate                => $base->get('startDate'),
		endDate                  => $base->get('endDate'),
		encryptPage              => $base->get('encryptPage'),
		isHidden                 => 1,
		newWindow                => 0,

		# Asset/Wobject properties
		displayTitle             => 1,
		cacheTimeout             => $base->get('cacheTimeout'),
		cacheTimeoutVisitor      => $base->get('cacheTimeoutVisitor'),
		styleTemplateId          => $base->get('styleTemplateId'),
		printableStyleTemplateId => $base->get('printableStyleTemplateId'),

		# Asset/Wobject/Folder properties
		templateId               => 'PBtmpl0000000000000078',

		# Other properties
		#assetId                  => 'new',
		className                => 'WebGUI::Asset::Wobject::Folder',
		#filename                 => $filename,
		});
	$session->http->setRedirect($base->getUrl('op=richEditImageTree'));
	return "";
}

#-------------------------------------------------------------------

=head2 www_richEditAddImage ( $session )

Returns a form to add an image using the rich editor. The purpose of this feature is to provide a very simple way for end-users to upload new images from within the rich editor, in stead of having to leave the rich editor and use the asset manager. A very minimal set of options is supplied, all other options should be derived from the current asset.

=cut

sub www_richEditAddImage {
	my $session = shift;
	$session->http->setCacheControl("none");
	my $i18n = WebGUI::International->new($session, 'Operation_FormHelpers');
	my $f = WebGUI::HTMLForm->new($session);
	$f->hidden(
		name		=> 'op',
		value		=> 'richEditAddImageSave',
		);
	$f->file(
		label		=> $i18n->get('File'),
		name		=> 'filename',
		size		=> 10,
		);
	$f->submit(
		value		=> $i18n->get('Upload'),
		);
	$f->button(
		value		=> $i18n->get('Cancel'),
		extras		=> 'onclick="history.go(-1);"',
		);
	my $html = '<h1>'.$i18n->get('Upload new image').'</h1>'.$f->print;
	return $session->style->process($html, 'PBtmpl0000000000000137');
}

#-------------------------------------------------------------------

=head2 www_richEditAddImageSave ( $session )

Creates an Image asset under the current asset. The filename should be specified in the form. The Edit and View rights from the current asset are used if not specified in the form. All other properties are copied from the current asset.

=cut

sub www_richEditAddImageSave {
	my $session = shift;
	$session->http->setCacheControl("none");
	# get base url
	my $base = WebGUI::Asset->newByUrl($session) || WebGUI::Asset->getRoot($session);
	#my $base = $session->asset;
	my $url = $base->getUrl;
	# check if user can edit the current asset
	return WebGUI::Privilege::insufficient() unless $base->canEdit;

	my $storage = WebGUI::Storage::Image->create($session);
	my $filename = $storage->addFileFromFormPost('filename');
	if ($filename) {
		$base->addChild({
			assetId     => 'new',
			className   => 'WebGUI::Asset::File::Image',
			storageId   => $storage->getId,
			filename    => $filename,
			title       => $filename,
			menuTitle   => $filename,
			templateId  => 'PBtmpl0000000000000088',
			url         => $url.'/'.$filename,
			groupIdEdit => $session->form->process('groupIdEdit') || $base->get('groupIdEdit'),
			groupIdView => $session->form->process('groupIdView') || $base->get('groupIdView'),
			ownerUserId => $session->var->get('userId'),
			isHidden    => 1,
			});
		$storage->generateThumbnail($filename);
	}
	$session->http->setRedirect($url.'?op=richEditImageTree');
	return "";
}


1;

