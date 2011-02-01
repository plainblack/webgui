package WebGUI::Form::File;

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
use base 'WebGUI::Form::Control';
use WebGUI::International;
use WebGUI::Storage;
use WebGUI::Form::Hidden;

=head1 NAME

Package WebGUI::Form::File

=head1 DESCRIPTION

Creates a javascript driven file upload control for files.

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

If no name is specified a default name of "file" will be used.

=head4 maxAttachments

How many attachments will be allowed to be uploaded.  However, the file form
only supports displaying/deleting 1 attachment.

=head4 deleteFileUrl

A url that will get a filename appended to it and then links to delete the files will be generated automatically.

=head4 size

Though not all browsers support it, this will attempt to set the size (or width) of the browse for file field.

=head4 persist

The default behavior of File is to delete empty storage location.  However, this causes problems with Assets, which
expect them to stick around.  Setting persist => 1 will prevent the deletion.

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift || [];
	push(@{$definition}, {
		name=>{
			defaultValue=>"file"
			},
		maxAttachments=>{
			defaultValue=>1
			},
		deleteFileUrl=>{
			defaultValue=>undef
			},
        size=>{
            defaultValue=>40
            },
        persist=>{
            defaultValue=>0,
            },
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
    return WebGUI::International->new($session, 'WebGUI')->get('file');
}

#-------------------------------------------------------------------

=head2 getFilePreview ( storage )

Returns a preview of the files attached to this form control. 

=head3 storage

A WebGUI::Storage object.

=cut

sub getFilePreview {
    my $self = shift;
    my $storage = shift;
	my $i18n = WebGUI::International->new($self->session);
    my $preview = "";
	foreach my $file (@{$storage->getFiles}) {
		if ($self->get("deleteFileUrl")) {
			$preview .= '<p style="display:inline;vertical-align:middle;"><a href="'.$self->get("deleteFileUrl").$file.'">'
			    .'<img src="'.$self->session->icon->getBaseURL().'delete.gif" style="vertical-align:middle;border: 0px;" alt="x" /></a></p> ';
		}
		$preview .= '<p style="display:inline;vertical-align:middle;"><a href="'.$storage->getUrl($file).'">'
   		    .'<img src="'.$storage->getFileIconUrl($file).'" style="vertical-align:middle;border: 0px;" alt="'
			.$file.'" /> '.$file.'</a><br />';
	    $preview .= $i18n->get(392) .  ("&nbsp"x4) . WebGUI::Form::YesNo->new($self->session,{name=>$self->privateName('delete_'.$file), value=>0})->toHtml;
		$preview .= '</p><br /><br />';
	}
    return $preview;
}


#-------------------------------------------------------------------

=head2 getStorageLocation ( )

Returns the WebGUI::Storage object for this control.

=cut

sub getStorageLocation {
    my $self = shift;
    my $value = $self->getOriginalValue;
	my $storage = WebGUI::Storage->get($self->session, $value) if ( defined $value );
    return $storage;
}


#-------------------------------------------------------------------

=head2 getValue ( )

Returns the storageId for the storage location that the file(s) got
uploaded to. Returns undef if no files were uploaded.  Also handles
deleting the file if it was specified.

=cut

sub getValue {
	my $self = shift;
	my $value = $self->getOriginalValue;
	my $storage = WebGUI::Storage->get($self->session,$value);
	if (defined $storage) {
		foreach my $file (@{$storage->getFiles}) {
			if ($self->session->form->param($self->privateName('delete_'.$file))) {
				$storage->deleteFile($file);
			}
		}
	}
	if ($self->session->form->param($self->privateName('action')) eq 'keep') {
		return $value;
	}
	elsif ($self->session->form->param($self->privateName('action')) eq 'upload') {
		my $storage = undef;
		if ($value ne "") {
			$storage = WebGUI::Storage->get($self->session, $value);
		}
		else {
			$storage = WebGUI::Storage->create($self->session);
		}
		$storage->addFileFromFormPost($self->get("name")."_file",1000);
		my @files = @{ $storage->getFiles };
		if (scalar(@files) < 1 && !$self->get('persist')) {
			$storage->delete;
			return undef;
		}
		else {
			my $id = $storage->getId;
			$self->set("value", $id);
			return $id;
		}
	}
	return $value;
}

#-------------------------------------------------------------------

=head2 getValueAsHtml ( )

Displays the file as a link.

=cut

sub getValueAsHtml {
	my ($self) = @_;
    my $value = $self->getOriginalValue;
	return '' unless $value;
	my $location = WebGUI::Storage->get($self->session,$value);
	my $file = shift @{ $location->getFiles };
    return '' unless $file;
	my $fileValue = sprintf qq|<img src="%s" />&nbsp;<a href="%s">%s</a>|, $location->getFileIconUrl($file), $location->getUrl($file), $file; 
	return $fileValue;
}

#-------------------------------------------------------------------

=head2 headTags ( )

Set the head tags for this form plugin

=cut

sub headTags {
    my $self = shift;
    $self->session->style->setScript($self->session->url->extras('FileUploadControl.js'));
    $self->session->style->setScript($self->session->url->extras('fileIcons.js'));
}

#-------------------------------------------------------------------

=head2 isDynamicCompatible ( )

A class method that returns a boolean indicating whether this control is compatible with the DynamicField control.

=cut

sub isDynamicCompatible {
    return 1;
}

#-------------------------------------------------------------------

=head2 isInRequest ( )

=cut

sub isInRequest {
    my $self = shift;
    my $form = $self->session->form;
    my $name = $self->get('name');
    my $isInRequest = $form->hasParam($name.'_file')
                   || $form->hasParam($self->privateName('action'));
    return $isInRequest;
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders a file upload control.

=cut

sub toHtml {
	my $self = shift;
    $self->headTags;
	my $i18n = WebGUI::International->new($self->session);
	my $uploadControl = '';
	my $storage = $self->getStorageLocation;
	my @files = @{ $storage->getFiles } if (defined $storage);
	my $maxFiles = $self->get('maxAttachments') - scalar(@files);
	if ($maxFiles > 0) {
        # Add basic field, use JS to replace with better field
        $uploadControl = 
            '<input type="file" name="' . $self->get("name") . '_file" id="' . $self->get("name") . '_file" />'
            . '<script type="text/javascript">'
            . sprintf(q!var uploader = new FileUploadControl("%s", fileIcons, "%s","%d", "%s"); uploader.addRow();!
                , $self->get("name")."_file", $i18n->get("removeLabel"), $maxFiles, $self->get("size"))
            . '</script>'
            . WebGUI::Form::Hidden->new($self->session, {
                name    => $self->privateName('action'), 
                value   => 'upload',
                id      => $self->get('id')
            })->toHtml
            . "\n";
	} 
    else {
		$uploadControl .= WebGUI::Form::Hidden->new($self->session, {
            name    => $self->get("name"), 
            value   => $self->getOriginalValue,
            id      => $self->get("id")
            })->toHtml()."\n";
		$uploadControl .= WebGUI::Form::Hidden->new($self->session, {
            name    => $self->privateName('action'), 
            value   => 'keep',
            id      => $self->get("id")
            })->toHtml()."\n";
	}
	if (scalar(@files)) {
        if ($self->get('maxAttachments') == 1) {
            $self->set("");
        }
        $uploadControl .= "<br />".$self->getFilePreview($storage);
	}
    return $uploadControl;
}

1;

