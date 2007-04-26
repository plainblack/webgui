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

=head4 profileEnabled

Flag that tells the User Profile system that this is a valid form element in a User Profile

=head4 deleteFileUrl

A url that will get a filename appended to it and then links to delete the files will be generated automatically.

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
		deleteFileUrl=>{
			defaultValue=>undef
			}
		});
        return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 displayForm ( )

If an file is uploaded, then return an icon for that file's type and a control to
delete it.  Otherwise, display a form element to upload a file.

=cut

sub displayForm {
	my ($self) = @_;
	return $self->toHtml unless $self->get("value");
	##There are files inside here, for each one, display the file icon
	##and another form control for deleting it.
	my $location = WebGUI::Storage->get($self->session,$self->get("value"));
	my $fileForm = '';
	my $i18n = WebGUI::International->new($self->session);
	my $file = shift @{ $location->getFiles };
	$fileForm .= sprintf qq!<img src="%s" /><br />!, $location->getFileIconUrl($file);
	$fileForm .= $i18n->get(392)
		  .  "&nbsp"x4
		  . WebGUI::Form::YesNo->new($self->session,{-name=>$self->privateName('delete'), -value=>0})->toHtml;
	$fileForm .= $self->toHtmlAsHidden();
	$fileForm .= WebGUI::Form::Hidden->new($self->session, {-name => $self->privateName('action'), -value => 'keep'})->toHtml();
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
	my $file = shift @{ $location->getFiles };
	my $fileValue = sprintf qq|<img src="%s" />&nbsp;%s|, $location->getFileIconUrl($file), $file; 
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
	my $value = $self->get("value");
	if ($self->session->form->param($self->privateName('delete'))) {
		my $storage = WebGUI::Storage->get($self->session,$value);
		$storage->delete if defined $storage;
		return '';
	} elsif ($self->session->form->param($self->privateName('action')) eq 'keep') {
		return $value;
	} elsif ($self->session->form->param($self->privateName('action')) eq 'upload') {
		my $storage = undef;
		if ($value ne "") {
			$storage = WebGUI::Storage::Image->get($self->session, $value);
		} else {
			$storage = WebGUI::Storage::Image->create($self->session);
		}
		$storage->addFileFromFormPost($self->get("name")."_file",1000);
		my @files = @{ $storage->getFiles };
		if (scalar(@files) < 1) {
			$storage->delete;
			return undef;
		} else {
			my $id = $storage->getId;
			$self->set("value", $id);
			return $id;
		}
	}
	return undef;
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders a file upload control.

=cut

sub toHtml {
	my $self = shift;
	my $i18n = WebGUI::International->new($self->session);
	my $uploadControl = undef;
	my $storage = WebGUI::Storage->get($self->session, $self->get("value")) if ($self->get("value"));
	my @files = $storage->getFiles if (defined $storage);
	my $maxFiles = $self->get('maxAttachments') - scalar(@files);
	if ($maxFiles > 0) {
        	$self->session->style->setScript($self->session->url->extras('FileUploadControl.js'),{type=>"text/javascript"});
        	$uploadControl = '<script type="text/javascript">
                	var fileIcons = new Array();
                	';
        	opendir(DIR,$self->session->config->get("extrasPath").'/fileIcons');
        	my @icons = readdir(DIR);
        	closedir(DIR);
        	foreach my $file (@icons) {
                	unless ($file eq "." || $file eq "..") {
                        	my $ext = $file;
	                        $ext =~ s/(.*?)\.gif/$1/;
        	                $uploadControl .= 'fileIcons["'.$ext.'"] = "'.$self->session->url->extras('fileIcons/'.$file).'";'."\n";
                	}
        	}
        	$uploadControl .= sprintf q!var uploader = new FileUploadControl("%s", fileIcons, "%s","%d"); uploader.addRow(); </script>!
			, $self->get("name")."_file", $i18n->get("removeLabel"), $maxFiles;
		$uploadControl .= WebGUI::Form::Hidden->new($self->session, {-name => $self->privateName('action'), -value => 'upload'})->toHtml()."<br />";
	} else {
		$uploadControl .= WebGUI::Form::Hidden->new($self->session, {-name => $self->get("name"), -value => $self->get("value")})->toHtml()."<br />";
		$uploadControl .= WebGUI::Form::Hidden->new($self->session, {-name => $self->privateName('action'), -value => 'keep'})->toHtml()."<br />";
	}
	if (scalar(@files)) {
		foreach my $file (@{$storage->getFiles}) {
			if ($self->get("deleteFileUrl")) {
				$uploadControl .= '<p style="display:inline;vertical-align:middle;"><a href="'.$self->get("deleteFileUrl").$file.'">'
				.'<img src="'.$self->session->icon->getBaseURL().'delete.gif" style="vertical-align:middle;border: 0px;" alt="x" /></a></p> ';
			}
			$uploadControl .= '<p style="display:inline;vertical-align:middle;"><a href="'.$storage->getUrl($file).'">'
       				.'<img src="'.$storage->getFileIconUrl($file).'" style="vertical-align:middle;border: 0px;" alt="'
				.$file.'" /> '.$file.'</a></p><br />';
		}
	}
        return $uploadControl;
}

1;

