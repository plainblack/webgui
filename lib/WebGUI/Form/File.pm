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
use WebGUI::Form::Hidden;

=head1 NAME

Package WebGUI::Form::File

=head1 DESCRIPTION

Creates a form for uploading and displaying 1 file.

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

=head4 profileEnabled

Flag that tells the User Profile system that this is a valid form element in a User Profile

=cut

sub definition {
	my $class = shift;
	my $definition = shift || [];
	push(@{$definition}, {
		formName=>{
			defaultValue=>WebGUI::International::get("file","WebGUI")
			},
		name=>{
			defaultValue=>"file"
			},
		profileEnabled=>{
			defaultValue=>1
			},
		});
	return $class->SUPER::definition($definition);
}

#-------------------------------------------------------------------

=head2 displayForm ( )

If an file is uploaded, then return the a file Icon and a control to
delete it.  Otherwise, display a form element to upload a file.

=cut

sub displayForm {
	my ($self) = @_;
	return $self->toHtml unless $self->{value};
	##There is a file inside here, display a file icon for it
	##and another form control for deleting it.
	my $location = WebGUI::Storage->get($self->{value});
	my $id = $location->getId;
	my $fileForm = '';
	my $file = shift @{ $location->getFiles };
	$fileForm .= sprintf qq!<img src="%s" /><br />!, $location->getFileIconUrl($file);
	$fileForm .= WebGUI::International::get(392)
		  .  "&nbsp"x4
		  . WebGUI::Form::YesNo->new({-name=>$self->privateName('delete'), -value=>0})->toHtml;
	$fileForm .= $self->toHtmlAsHidden();
	$fileForm .= WebGUI::Form::Hidden->new({-name => $self->privateName('action'), -value => 'keep'})->toHtml();
	return $fileForm;
}

#-------------------------------------------------------------------

=head2 displayValue ( )

This utility method is used to format values for the Profile system.  Most
form elements will just return their value. 

=cut

sub displayValue {
	my ($self) = @_;
	return '' unless $self->{value};
	my $location = WebGUI::Storage->get($self->{value});
	my $file = shift @{ $location->getFiles };
	my $fileValue = sprintf qq!<img src="%s" />&nbsp;%s!, $location->getFileIconUrl($file), $file; 
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
	my $value = $session{req}->param($self->{name});
	if ($session{req}->param($self->privateName('delete'))) {
		my $storage = WebGUI::Storage->get($value);
		$storage->delete;
		return '';
	}
	elsif ($session{req}->param($self->privateName('action')) eq 'keep') {
		return $value;
	}
	elsif ($session{req}->param($self->privateName('action')) eq 'upload') {
		my $storage;
		$storage = WebGUI::Storage::Image->create;
		$storage->addFileFromFormPost($self->{name}, 1);
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
        WebGUI::Style::setScript($session{config}{extrasURL}.'/FileUploadControl.js',{type=>"text/javascript"});
        my $uploadControl = '<script type="text/javascript">
                var fileIcons = new Array();
                ';
        opendir(DIR,$session{config}{extrasPath}.'/fileIcons');
        my @files = readdir(DIR);
        closedir(DIR);
        foreach my $file (@files) {
                unless ($file eq "." || $file eq "..") {
                        my $ext = $file;
                        $ext =~ s/(.*?)\.gif/$1/;
                        $uploadControl .= 'fileIcons["'.$ext.'"] = "'.$session{config}{extrasURL}.'/fileIcons/'.$file.'";'."\n";
                }
        }
        $uploadControl .= 'var uploader = new FileUploadControl("'.$self->{name}.'", fileIcons, "'.WebGUI::International::get('removeLabel','WebGUI').'","'.1.'");
        uploader.addRow();
        </script>';
	$uploadControl .= WebGUI::Form::Hidden->new({-name => $self->privateName('action'), -value => 'upload'})->toHtml();
        return $uploadControl;
}

1;

