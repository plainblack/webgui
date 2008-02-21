package WebGUI::Form::HTMLArea;

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
use base 'WebGUI::Form::Textarea';
use WebGUI::Asset::File::Image;
use WebGUI::Asset::RichEdit;
use WebGUI::Asset::Wobject::Folder;
use WebGUI::HTML;
use WebGUI::International;

=head1 NAME

Package WebGUI::Form::HTMLArea

=head1 DESCRIPTION

Creates an HTML Area form control if the user's browser supports it. This basically puts a word processor in the field for them.

=head1 SEE ALSO

This is a subclass of WebGUI::Form::Textarea.

=head1 METHODS 

The following methods are specifically available from this class. Check the superclass for additional methods.

=cut


#-------------------------------------------------------------------

=head2 definition ( [ additionalTerms ] )

See the super class for additional details.

=head3 additionalTerms

The following additional parameters have been added via this sub class.

=head4 width

The width of this control in pixels. Defaults to 500 pixels.

=head4 height

The height of this control in pixels.  Defaults to 400 pixels.

=head4 style

Style attributes besides width and height which should be specified using the above parameters. Be sure to escape quotes if you use any.

=head4 richEditId

The ID of the WebGUI::Asset::RichEdit object to load. Defaults to the richEditor setting or  "PBrichedit000000000001" if that's not set.

=head4 profileEnabled

Flag that tells the User Profile system that this is a valid form element in a User Profile

=cut

sub definition {
        my $class = shift;
	my $session = shift;
        my $definition = shift || [];
	my $i18n = WebGUI::International->new($session);
        push(@{$definition}, {
                formName=>{
                        defaultValue=>$i18n->get("477")
                        },
		height=>{
			defaultValue=> 400
			},
		width=>{
			defaultValue=> 500
			},
		style=>{
			defaultValue => undef,
			},
                richEditId=>{
                        defaultValue=>$session->setting->get("richEditor") || "PBrichedit000000000001"
                        },
		profileEnabled=>{
			defaultValue=>1
			},
        dbDataType  => {
            defaultValue    => "LONGTEXT",
        },
                });
        return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 getValueFromPost ( [ value ] )

Returns the value of this form field after stipping unwanted tags like <body>.

=head3 value

An optional value to process, instead of POST input.

=cut

sub getValueFromPost {
	my $self = shift;
	return WebGUI::HTML::cleanSegment($self->SUPER::getValueFromPost(@_));
}


#-------------------------------------------------------------------

=head2 toHtml ( )

Renders an HTML area field.

=cut

sub toHtml {
	my $self = shift;
	my $i18n = WebGUI::International->new($self->session);
	my $richEdit = WebGUI::Asset::RichEdit->new($self->session,$self->get("richEditId"));
	if (defined $richEdit) {
       $self->session->style->setScript($self->session->url->extras('textFix.js'),{ type=>'text/javascript' });
	   $self->set("extras", $self->get('extras') . ' onblur="fixChars(this.form.'.$self->get("name").')" mce_editable="true" ');
	   $self->set("resizable", 0);
	   return $self->SUPER::toHtml.$richEdit->getRichEditor($self->get('id'));
    } else {
	   $self->session->errorHandler->warn($i18n->get('rich editor load error','Form_HTMLArea'));
	   return $self->SUPER::toHtml;
	}

}

#-------------------------------------------------------------------

=head2 www_pageTree ( session )

Asset picker for the rich editor.

=cut

sub www_pageTree {
	my $session = shift;
	$session->http->setCacheControl("none");
	$session->style->setRawHeadTags(q|<style type="text/css">
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
                </style>
		|);
	$session->style->setScript($session->url->extras('tinymce2/jscripts/tiny_mce/tiny_mce_popup.js'),{type=>"text/javascript"});
	my $i18n = WebGUI::International->new($session);
	my $f = WebGUI::HTMLForm->new($session,-action=>"#");
	$f->text(
		-name=>"url",
		-label=>$i18n->get(104),
		-hoverHelp=>$i18n->get('104 description'),
		);
	my %options = ();
	tie %options, 'Tie::IxHash';
	%options = ("_self"=>$i18n->get('link in same window'),
		           "_blank"=>$i18n->get('link in new window'));
	$f->selectBox(
		-name=>"target",
		-label=>$i18n->get('target'),
		-hoverHelp=>$i18n->get('target description'),
		-options=>\%options
		);
	$f->button(
		-name=>"button",
		-value=>$i18n->get('done'),
		-extras=>'onclick="createLink()"'
		);
	my $output = ' <fieldset><legend>'.$i18n->get('insert a link').'</legend>'.$f->print.'</fieldset>'.<<"JS"
	<script type="text/javascript">
//<![CDATA[
function createLink() {
    if (window.opener) {        
        if (document.getElementById("url_formId").value == "") {
           alert("@{[$i18n->get("link enter alert")]}");
           document.getElementById("url_formId").focus();
        }
	var link = '<a href="'+"^" + "/(" + document.getElementById("url_formId").value+');"';
        var target = document.getElementById('target_formId').value;
        if (target != '_self') link += ' target="' + target + '"';
	link += '>' + window.opener.tinyMCE.selectedInstance.selection.getSelectedHTML() + '</a>';
	window.opener.tinyMCE.execCommand("mceInsertContent",false,link);
     window.close();
    }
}
//]]>
</script>
JS
	.'<fieldset><legend>'.$i18n->get('pages').'</legend> ';
	$output .= '<div class="base">';
	my $base = WebGUI::Asset->newByUrl($session) || WebGUI::Asset->getRoot($session);
	my @crumb;
	my $ancestors = $base->getLineage(["self","ancestors"],{returnObjects=>1});
	foreach my $ancestor (@{$ancestors}) {
		push(@crumb,'<a href="'.$ancestor->getUrl("op=formHelper;class=HTMLArea;sub=pageTree").'" class="crumb">'.$ancestor->get("menuTitle").'</a>');
	}	
	$output .= '<div class="crumbTrail">'.join(" &gt; ", @crumb)."</div><br />\n";
	my $children = $base->getLineage(["children"],{returnObjects=>1});
	foreach my $child (@{$children}) {
		next unless $child->canView;
		$output .= '<a href="#" class="selectLink"
onclick="document.getElementById(\'url_formId\').value=\''.$child->get("url").'\'">['.$i18n->get("select").']</a>
<a href="'.$child->getUrl("op=formHelper;class=HTMLArea;sub=pageTree").'" class="traverse">'.$child->get("menuTitle").'</a>'."<br />\n";	
	}
	$output .= '</div></fieldset>';
	return $session->style->process($output, 'PBtmpl0000000000000137');
}

#-------------------------------------------------------------------

=head2 www_imageTree ( session )

Similar to www_pageTree, except it is limited to only display assets of class WebGUI::Asset::File::Image.
Each link display a thumbnail of the image via www_viewThumbnail.

=cut

sub www_imageTree {
	my $session = shift;
	$session->http->setCacheControl("none");
	$session->style->setRawHeadTags(q| <style type="text/css">
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
                </style>|);
	my $base = WebGUI::Asset->newByUrl($session) || WebGUI::Asset->getMedia($session);
	my @crumb;
	my $ancestors = $base->getLineage(["self","ancestors"],{returnObjects=>1});
	my $media;
	my @output;
	push(@output, '<div class="base">');
	my $i18n = WebGUI::International->new($session, 'Operation_FormHelpers');
	foreach my $ancestor (@{$ancestors}) {
		push(@crumb,'<a class="crumb" href="'.$ancestor->getUrl("op=formHelper;class=HTMLArea;sub=imageTree").'">'.$ancestor->get("menuTitle").'</a>');
		# check if we are in (a subdirectory of) Media
		if ($ancestor->get('assetId') eq 'PBasset000000000000003') {
			$media = $ancestor;
		}
	}	
	if ($media) {
		# if in (a subdirectory of) Media, give user the ability to create folders or upload images
		push(@output, '<p>[ <a href="');
		push(@output, $base->getUrl('op=formHelper;class=HTMLArea;sub=addFolder'));
		push(@output, '">'.$i18n->get('Create new folder').'</a> ] &nbsp; [ <a href="');
		push(@output, $base->getUrl('op=formHelper;class=HTMLArea;sub=addImage'));
		push(@output, '">'.$i18n->get('Upload new image').'</a> ]</p>');
	} else {
		$media = WebGUI::Asset->getMedia($session);
		# if not in Media, provide a direct link to it
		push(@output, '<p>[ <a href="'.$media->getUrl('op=formHelper;class=HTMLArea;sub=imageTree').'">'.$media->get('title').'</a> ]</p>');
	}
	push(@output, '<div class="crumbTrail">'.join(" &gt; ", @crumb)."</div><br />\n");
	my $children = $base->getLineage(["children"],{returnObjects=>1});
	foreach my $child (@{$children}) {
		next unless $child->canView;
		if ($child->get("className") =~ /^WebGUI::Asset::File::Image/) {
			push(@output, '<a class="selectLink" href="'.$child->getUrl("op=formHelper;class=HTMLArea;sub=viewThumbnail").'" target="viewer">['.$i18n->get("select","WebGUI").']</a> ');
		} else {
			push(@output, ' ['.$i18n->get("select","WebGUI")."] ");
		}
		push(@output, '<a class="traverse" href="'.$child->getUrl("op=formHelper;class=HTMLArea;sub=imageTree").'">'.$child->get("menuTitle").'</a>'."<br />\n");
	}
	push(@output, '</div>');
	return $session->style->process(join('', @output), 'PBtmpl0000000000000137');
}

#-------------------------------------------------------------------

=head2 www_viewThumbnail ( session )

Displays a thumbnail of an Image Asset in the Image manager for the Rich Editor.  The current
URL in the session object is used to determine which Image is used.

=cut

sub www_viewThumbnail {
	my $session = shift;
	$session->http->setCacheControl("none");
	my $image = WebGUI::Asset->newByUrl($session);
	my $i18n = WebGUI::International->new($session);
	my $output;
	if ($image->get("className") =~ /WebGUI::Asset::File::Image/) {
		$output = '<div align="center">';
		$output .= '<img src="'.$image->getThumbnailUrl.'" style="border-style:none;" alt="'.$i18n->get('preview').'" />';
		$output .= '<br />';
		$output .= $image->get("filename");
		$output .= '</div>';
		$output .= '<script type="text/javascript">';
		$output .= "//<![CDATA[\n";
		if ( $session->config->get("richEditorsUseAssetUrls")) {
			$output .= "\nvar src = '".$image->getUrl."';\n";
		} else {
			$output .= "\nvar src = '".$image->getFileUrl."';\n";
		}
		$output .= "if(src.length > 0) {
				var manager=window.parent;
   				if(manager)		      	
		      		manager.document.getElementById('txtFileName').value = src;
    			}
                    //]]>
    		    </script>\n";
	} else {
		$output = '<div align="center"><img src="'.$session->url->extras('tinymce2/images/icon.gif').'" style="border-style:none;" alt="'.$i18n->get('image manager').'" /></div>';
	}
	return $session->style->process($output, 'PBtmpl0000000000000137');
}

#-------------------------------------------------------------------

=head2 www_addFolder ( session )

Returns a form to add a folder using the rich editor. The purpose of this feature is to provide a very simple way for end-users to create a folder from within the rich editor, in stead of having to leave the rich editor and use the asset manager. A very minimal set of options is supplied, all other options should be derived from the current asset.

=cut

sub www_addFolder {
	my $session = shift;
	$session->http->setCacheControl("none");
	my $i18n = WebGUI::International->new($session, 'Operation_FormHelpers');
	my $f = WebGUI::HTMLForm->new($session);
	$f->hidden(
		name		=> 'op',
		value		=> 'formHelper',
		);
	$f->hidden(
		name		=> 'class',
		value		=> 'HTMLArea',
		);
	$f->hidden(
		name		=> 'sub',
		value		=> 'addFolderSave',
		);
	$f->text(
		label		=> $i18n->get('Folder name'),
		name		=> 'filename',
        size        => 15,
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

=head2 www_addFolderSave ( session )

Creates a directory under the current asset. The filename should be specified in the form. The Edit and View rights from the current asset are used if not specified in the form. All other properties are copied from the current asset.

=cut

sub www_addFolderSave {
	my $session = shift;
	$session->http->setCacheControl("none");
	# get base url
	my $base = WebGUI::Asset->newByUrl($session) || WebGUI::Asset->getRoot($session);
	# check if user can edit the current asset
	return $session->privilege->insufficient('bare') unless $base->canEdit;

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
	$session->http->setRedirect($base->getUrl('op=formHelper;class=HTMLForm;sub=imageTree'));
	return undef;
}

#-------------------------------------------------------------------

=head2 www_addImage ( session )

Returns a form to add an image using the rich editor. The purpose of this feature is to provide a very simple way for end-users to upload new images from within the rich editor, in stead of having to leave the rich editor and use the asset manager. A very minimal set of options is supplied, all other options should be derived from the current asset.

=cut

sub www_addImage {
	my $session = shift;
	$session->http->setCacheControl("none");
	my $i18n = WebGUI::International->new($session, 'Operation_FormHelpers');
	my $f = WebGUI::HTMLForm->new($session);
	$f->hidden(
		name		=> 'op',
		value		=> 'formHelper',
		);
	$f->hidden(
		name		=> 'class',
		value		=> 'HTMLArea',
		);
	$f->hidden(
		name		=> 'sub',
		value		=> 'addImageSave',
		);
	$f->image(
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

=head2 www_addImageSave ( session )

Creates an Image asset under the current asset. The filename should be specified in the form. The Edit and View rights from the current asset are used if not specified in the form. All other properties are copied from the current asset.

=cut

sub www_addImageSave {
	my $session = shift;
	$session->http->setCacheControl("none");
	# get base asset
	my $base = WebGUI::Asset->newByUrl($session) || WebGUI::Asset->getRoot($session);

	# check if user can edit the current asset
	return $session->privilege->insufficient('bare') unless $base->canEdit;

	#my $imageId = WebGUI::Form::Image->create($session);
	my $imageId = WebGUI::Form::Image->new($session,{name => 'filename'})->getValueFromPost;
    my $imageObj = WebGUI::Storage::Image->get($session, $imageId);
	##This is a hack.  It should use the WebGUI::Form::File API to insulate
	##us from future form name changes.
	my $filename = $imageObj->getFiles->[0];
	if ($filename) {
		$base->addChild({
			assetId     => 'new',
			className   => 'WebGUI::Asset::File::Image',
			storageId   => $imageObj->getId,
			filename    => $filename,
			title       => $filename,
			menuTitle   => $filename,
			templateId  => 'PBtmpl0000000000000088',
			groupIdEdit => $session->form->process('groupIdEdit') || $base->get('groupIdEdit'),
			groupIdView => $session->form->process('groupIdView') || $base->get('groupIdView'),
			ownerUserId => $session->user-userId,
			isHidden    => 1,
			});
	}
	$session->http->setRedirect($base->getUrl('op=formHelper;class=HTMLArea;sub=imageTree'));
	return undef;
}


1;
