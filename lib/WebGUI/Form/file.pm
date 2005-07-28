package WebGUI::Form::text;

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

=head1 NAME

Package WebGUI::Form::text

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

=head4 maxlength

Defaults to 255. Determines the maximum number of characters allowed in this field.

=head4 size

Defaults to the setting textBoxSize or 30 if that's not set. Specifies how big of a text box to display.

=cut

sub definition {
	my $class = shift;
	my $definition = shift || [];
	push(@{$definition}, {
		maxlength=>{
			defaultValue=> 255
			},
		size=>{
			defaultValue=>$session{setting}{textBoxSize} || 30
			}
		});
	return $class->SUPER::definition($definition);
}


#-------------------------------------------------------------------

=head2 getName ()

Returns the human readable name or type of this form control.

=cut

sub getName {
        return WebGUI::International::get("475","WebGUI");
}



#-------------------------------------------------------------------

=head2 toHtml ( )

Renders an input tag of type text.

=cut

sub toHtml {
	my $self = shift;
 	my $value = $self->fixMacros($self->fixQuotes($self->fixSpecialCharacters($self->{value})));
        return '<input type="text" name="'.$self->{name}.'" value="'.$value.'" size="'.$self->{size}.'" maxlength="'.$self->{maxlength}.'" '.$self->{extras}.' />';
}


#-------------------------------------------------------------------

=head2 files ( hashRef )

Returns a multiple file upload control.

=head3 name

The name field for this form element.

=cut

sub files {
        WebGUI::Style::setScript($session{config}{extrasURL}.'/FileUploadControl.js',{type=>"text/javascript"});
        my $uploadControl = '<div id="fileUploadControl"> </div>
                <script>
                var images = new Array();
                ';
        opendir(DIR,$session{config}{extrasPath}.'/fileIcons');
        my @files = readdir(DIR);
        closedir(DIR);
        foreach my $file (@files) {
                unless ($file eq "." || $file eq "..") {
                        my $ext = $file;
                        $ext =~ s/(.*?)\.gif/$1/;
                        $uploadControl .= 'images["'.$ext.'"] = "'.$session{config}{extrasURL}.'/fileIcons/'.$file.'";'."\n";
                }
        }
        $uploadControl .= 'var uploader = new FileUploadControl("fileUploadControl", images, "'.WebGUI::International::get('removeLabel','WebGUI').'");
        uploader.addRow();
        </script>';
        return $uploadControl;
}

1;

