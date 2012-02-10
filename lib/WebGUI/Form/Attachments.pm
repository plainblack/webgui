package WebGUI::Form::Attachments;

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
use base 'WebGUI::Form::Control';
use WebGUI::Asset;
use WebGUI::International;
use WebGUI::Storage;
use WebGUI::VersionTag;

=head1 NAME

Package WebGUI::Form::File

=head1 DESCRIPTION

Creates a javascript driven file upload control for asset attachments. 

B<NOTE:> This is meant to be used in
conjunction with one or more Rich Editors (see WebGUI::Form::HTMLArea) and should be placed above them in the field
list for ease of use.

B<WARNING:> This form control is not capable of handling all aspects of the files uploaded to it. So you as the
developer need to complete the process after the form has been submitted. See the getValue() method for
details.

=head1 SEE ALSO

This is a subclass of WebGUI::Form::Control.

=head1 METHODS 

The following methods are specifically available from this class. Check the superclass for additional methods.

=cut

#-------------------------------------------------------------------

=head2 definition ( [ additionalTerms ] )

See the super class for additional details.

=head3 additionalTerms

The following additional parameters have been added via this sub class.

=head4 name

If no name is specified a default name of "attachments" will be used.

=head4 maxAttachments

How many attachments will be allowed to be uploaded.  Defaults to 1.

=head4 value

An array reference of asset objects (not ids, but objects) that should be displayed in the attachments box.

=head4 maxImageSize

An integer (in pixels) of the maximum height or width an image can be. Defaults to the size in the main settings if
not specified.

=head4 thumbnailSize

An integer (in pixels) of the proportional size of a thumbnail for an image. Defaults to the size in the main
settings if not specified.

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift || [];
	push(@{$definition}, {
		name=>{
			defaultValue=>"attachments"
			},
		maxAttachments=>{
			defaultValue=>1
			},
        maxImageSize=>{},
        thumbnailSize=>{},
		});
        return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2  getDatabaseFieldType ( )

Returns "CHAR(22) BINARY".

=cut 

sub getDatabaseFieldType {
    return "CHAR(22) BINARY";
}

#-------------------------------------------------------------------

=head2 getName ( session )

Returns the human readable name of this control.

=cut

sub getName {
    my ($self, $session) = @_;
    return WebGUI::International->new($session, 'WebGUI')->get('Attachments formName');
}

#-------------------------------------------------------------------

=head2 getValue ( )

Returns an array reference of asset ids that have been uploaded. New assets are uploaded to a temporary location,
and you must move them to the place in the asset tree you want them, or they will be automatically deleted.

=cut

sub getValue {
	my $self = shift;
    my @values = $self->session->form->param($self->get("name"));
    return \@values;
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders an attachments control.

=cut

sub toHtml {
	my $self = shift;
    my @assetIds = @{$self->getOriginalValue};
    my $thumbnail = $self->get("thumbnailSize") || $self->session->setting->get("thumbnailSize");
    my $image = $self->get("maxImageSize") || $self->session->setting->get("maxImageSize");
    my $attachmentsList = "attachments=".join(";attachments=", @assetIds) if (scalar(@assetIds));
    return '<iframe src="'
        .$self->session->url->page("op=formHelper;class=Attachments;sub=show;name=".$self->get("name")
        .";maxAttachments=".$self->get("maxAttachments")).";maxImageSize=".$image.";thumbnailSize="
        .$thumbnail.";".$attachmentsList
        .'" style="width: 100%; height: 120px;"></iframe><div id="'.$self->get("name").'_formId"></div>';
}



#-------------------------------------------------------------------

=head2 www_delete () 

Deletes an attachment.

=cut

sub www_delete {
    my $session = shift;
    my $assetId = $session->form->param("assetId");
    my @assetIds = $session->form->param("attachments");
    if ($assetId ne "") {
        my $asset = WebGUI::Asset->newById($session, $assetId);
        if (defined $asset) {
            if ($asset->canEdit) {
                my $version = WebGUI::VersionTag->new($session, $asset->get("tagId"));
                $asset->purge;
                if ($version->getAssetCount == 0) {
                    $version->rollback;
                }
                my @tempAssetIds = ();
                foreach my $id (@assetIds) {
                    push(@tempAssetIds, $id) unless $id eq $assetId;
                }
                @assetIds = @tempAssetIds;
            }
        }
    } 
    return www_show($session,\@assetIds);
}

#-------------------------------------------------------------------

=head2 www_show () 

A web accessible method that displays the attachments associated with this attachments control.

=cut

sub www_show {
    my $session = shift;
    my ($form, $url, $style) = $session->quick(qw(form url style));
    my $assetIdRef = shift;
    my @assetIds = [];
    if (defined $assetIdRef) {
        $assetIdRef ||= [];
        @assetIds = @{$assetIdRef};
    }
    else {
        @assetIds = $session->form->param("attachments");
    }
	$session->response->setCacheControl("none");
    $style->setScript($url->extras("/AttachmentsControl/AttachmentsControl.js"));
    $style->setCss($url->extras("/AttachmentsControl/AttachmentsControl.css"));
    my $uploadControl = '';
	my $i18n = WebGUI::International->new($session);
	my $maxFiles = $form->param('maxAttachments') - scalar(@assetIds) ;
    my $attachmentForms = '';
    foreach my $assetId (@assetIds) {
        $attachmentForms .= '<input type="hidden" name="attachments" value="'.$assetId.'" />';
    }
    my $upload           = $i18n->get('Upload','Operation_FormHelpers');
    my $uploadAttachment = $i18n->get('Upload an attachment','WebGUI');
	if ($maxFiles > 0) {
        $uploadControl = '<div id="uploadForm">
            <a href="#" onclick="WebguiAttachmentUploadForm.hide();" id="uploadFormCloser">X</a>
            <form action="'.$url->page.'" enctype="multipart/form-data" method="post">
            <input type="hidden" name="maxAttachments" value="'.$form->param("maxAttachments").'" />
            <input type="hidden" name="maxImageSize" value="'.$form->param("maxImageSize").'" />
            <input type="hidden" name="thumbnailSize" value="'.$form->param("thumbnailSize").'" />
            <input type="hidden" name="name" value="'.$form->param("name").'" />
            <input type="hidden" name="op" value="formHelper" />
            <input type="hidden" name="class" value="Attachments" />
            <input type="hidden" name="sub" value="upload" /> '. $attachmentForms 
            .'<input type="file" name="attachment" />
            <input type="submit" value="'.$upload.'" /> </form> </div>
            <a id="upload" href="#" onclick="WebguiAttachmentUploadForm.show();">'.$uploadAttachment. '</a>
            ';
	}
    my $attachments = '';
    my $attachmentsList = "attachments=".join(";attachments=", @assetIds) if (scalar(@assetIds));
    foreach my $assetId (@assetIds) {
        my $asset = WebGUI::Asset->newById($session, $assetId);
        if (defined $asset) {
            $attachments .= '<div class="attachment"><a href="'
                .$url->page("op=formHelper;class=Attachments;sub=delete;maxAttachments=".$form->param("maxAttachments")
                .";maxImageSize=".$form->param("maxImageSize").";thumbnailSize=".$form->param("thumbnailSize").";"
                .$attachmentsList.";assetId=".$assetId.";name=".$form->param("name")).'" class="deleteAttachment">X</a>
                ';
            if ($asset->isa("WebGUI::Asset::File::Image")) {
                $attachments .= '
                    <div class="thumbnail"><img src="'.$asset->getThumbnailUrl.'" alt="'.$asset->getTitle.'" /></div>
                    <a class="imageLink" href="'.$asset->getUrl.'">'.$asset->getTitle.'</a>
                    <img src="'.$asset->getUrl.'" alt="'.$asset->getTitle.'" />';
            }
            else {
                $attachments .= '
                <div class="thumbnail"><img src="'.$asset->getFileIconUrl.'" alt="'.$asset->getTitle.'" /></div>
                <a href="'.$asset->getUrl.'">'.$asset->getTitle.'</a>';
            }
            $attachments .= '</div>';
        }
    }
    my $instructions = $i18n->get('Upload attachments here. Copy and paste attachments into the editor.','WebGUI');
    my $output = '<html><head> '.$style->generateAdditionalHeadTags.' 
          <script type="text/javascript">
            parent.document.getElementById("'.$form->get("name").'_formId").innerHTML = \''.$attachmentForms.'\';
          </script>
            </head> <body>
        '.$uploadControl.' <div id="instructions">'.$instructions.'</div>
         <div id="attachments">'.$attachments.' </div> </body> </html> ';
    return $output;
}

#-------------------------------------------------------------------

=head2 www_upload

A web accessible method that uploads an attachment to tempsace.

=cut

sub www_upload {
    my $session = shift;
    my $form = $session->form;
    my @assetIds = $form->param("attachments");
    my $storage = WebGUI::Storage->createTemp($session);
    my $filename = $storage->addFileFromFormPost("attachment");
    my $tempspace = WebGUI::Asset->getTempspace($session);
    my $asset = "";

    # prevent malicious visitors from being able to publish children things they've published to tempsace
    my $owner = ($session->user->isVisitor) ? "3" : $session->user->userId;

    my %properties = (
        title       => $filename,
        url         => "attachments/".$filename,
        filename    => $filename,
	extension   => WebGUI::Storage->getFileExtension($filename),
        ownerUserId => $owner,
        groupIdEdit => "3",
        groupIdView => "7",
        );
    if ($storage->isImage($filename)) {
        $properties{className}  = "WebGUI::Asset::File::Image";
        $properties{templateId} = "PBtmpl0000000000000088";
    }
    else {
        $properties{className}  = "WebGUI::Asset::File";
        $properties{templateId} = "PBtmpl0000000000000024";
    }
    $asset = $tempspace->addChild(\%properties);
    $asset->getStorageLocation->addFileFromFilesystem($storage->getPath($filename));
    $asset->applyConstraints;
    push(@assetIds, $asset->getId);
    WebGUI::VersionTag->autoCommitWorkingIfEnabled($session);
    $storage->delete;
    return www_show($session, \@assetIds);
}


1;

