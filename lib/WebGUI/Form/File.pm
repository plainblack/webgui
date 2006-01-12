package WebGUI::Form::File;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2006 Plain Black Corporation.
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
use WebGUI::Session;
use WebGUI::Storage;
use WebGUI::Style;

=head1 NAME

Package WebGUI::Form::File

=head1 DESCRIPTION

Creates a text input box form field.

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

Defaults to 1. Determines how many files the user can upload with this form control.

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
			defaultValue=>$i18n->get("file")
			},
		name=>{
			defaultValue=>"file"
			},
		maxAttachments=>{
			defaultValue=>1
			},
		profileEnabled=>{
			defaultValue=>1
			},
		});
        return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 displayForm ( )

If an image is uploaded, then return the image and a control to
delete it.  Otherwise, display a form element to upload a file.

=cut

sub displayForm {
	my ($self) = @_;
	return $self->toHtml unless $self->get("value");
	##There are files inside here, for each one, display the image
	##and another form control for deleting it.
	my $location = WebGUI::Storage->get($self->session,$self->get("value"));
	my $id = $location->getId;
	my $fileForm = '';
	foreach my $file ( @{ $location->getFiles } ) {
		$fileForm .= sprintf qq!<img src="%s" /><br />!, $location->getUrl($file);
		my $action = join '_', '_', $self->get("name"), 'delete';
		$fileForm .= WebGUI::International::get(392)
			  .  "&nbsp"x4
			  . WebGUI::Form::YesNo->new({-name=>$action, -value=>0})->toHtml;
	}
	my $hid = $self->toHtmlAsHidden();
	$fileForm .= $hid;
	return $fileForm;
}

#-------------------------------------------------------------------

=head2 displayValue ( )

This utility method is used to format values for the Profile system.  Most
form elements will just return their value. 

=cut

sub displayValue {
	my ($self) = @_;
	return '' unless $self->get("value");
	my $location = WebGUI::Storage->get($self->session,$self->get("value"));
	local $_;
	my @files = map { sprintf qq!<img src="%s" />&nbsp;%s!, $location->getFileIconUrl($_), $_; } @{ $location->getFiles };
	my $fileValue = join "<br />\n", @files;
return $fileValue;
}

#-------------------------------------------------------------------

=head2 getValueFromPost ( )

Returns the storageId for the storage location that the file(s) got
uploaded to. Returns undef if no files were uploaded.  Also handles
deleting the file if it was specified.

=cut

sub getValueFromPost {
	my $self = shift;
	my $value = $self->session->request->param($self->get("name"));
	if ($self->session->request->param(join '_', '_', $self->get("name"), 'delete')) {
		my $storage = WebGUI::Storage->get($self->session,$value);
		$storage->delete;
		return '';
	}
	else {
		my $storage;
		if ($value) {
			$storage = WebGUI::Storage::Image->get($self->session,$value);
		}
		else {
			$storage = WebGUI::Storage::Image->create;
		}
		$storage->addFileFromFormPost($self->get("name"));
		my @files = @{ $storage->getFiles };
		if (scalar(@files) < 1) {
			$storage->delete;
			return undef;
		} else {
			my $id = $storage->getId;
			return $id;
		}
	}
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders a file upload control.

=cut

sub toHtml {
	my $self = shift;
        $self->session->style->setScript($self->session->config->get("extrasURL").'/FileUploadControl.js',{type=>"text/javascript"});
        my $uploadControl = '<script type="text/javascript">
                var fileIcons = new Array();
                ';
        opendir(DIR,$self->session->config->get("extrasPath").'/fileIcons');
        my @files = readdir(DIR);
        closedir(DIR);
        foreach my $file (@files) {
                unless ($file eq "." || $file eq "..") {
                        my $ext = $file;
                        $ext =~ s/(.*?)\.gif/$1/;
                        $uploadControl .= 'fileIcons["'.$ext.'"] = "'.$self->session->config->get("extrasURL").'/fileIcons/'.$file.'";'."\n";
                }
        }
        $uploadControl .= 'var uploader = new FileUploadControl("'.$self->get("name").'", fileIcons, "'.WebGUI::International::get('removeLabel','WebGUI').'","'.$self->get("maxAttachments").'");
        uploader.addRow();
        </script>';
        return $uploadControl;
}

1;

