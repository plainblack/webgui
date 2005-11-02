package WebGUI::Form::File;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2005 Plain Black Corporation.
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

=cut

sub definition {
	my $class = shift;
	my $definition = shift || [];
	push(@{$definition}, {
		name=>{
			defaultValue=>"file"
			},
		maxAttachments=>{
			defaultValue=>1
			}
		});
	return $class->SUPER::definition($definition);
}


#-------------------------------------------------------------------

=head2 getName ()

Returns the human readable name or type of this form control.

=cut

sub getName {
        return WebGUI::International::get("file","WebGUI");
}



#-------------------------------------------------------------------

=head2 getValueFromPost ( )

Returns the storageId for the storage location that the file(s) got uploaded to. Returns undef if no files were uploaded.

=cut

sub getValueFromPost {
	my $self = shift;
	my $storage = WebGUI::Storage->create;
        $storage->addFileFromFormPost($self->{name});
	my @files = @{ $storage->getFiles };
	if (scalar(@files) < 1) {
		$storage->delete;
		return undef;
	} else {
		return $storage->getId;
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
        $uploadControl .= 'var uploader = new FileUploadControl("'.$self->{name}.'", fileIcons, "'.WebGUI::International::get('removeLabel','WebGUI').'","'.$self->{maxAttachments}.'");
        uploader.addRow();
        </script>';
        return $uploadControl;
}

#-------------------------------------------------------------------

=head4 toHtmlAsHidden ( )

Returns undef.

=cut

sub toHtmlAsHidden {
	return undef;
}


1;

