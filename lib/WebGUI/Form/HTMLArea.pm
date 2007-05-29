package WebGUI::Form::HTMLArea;

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
use base 'WebGUI::Form::Textarea';
use WebGUI::Asset::RichEdit;
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
	#return $self->SUPER::toHtml.WebGUI::Asset::RichEdit->new($self->session,$self->get("richEditId"))->getRichEditor($self->get('id'));
	my $i18n = WebGUI::International->new($self->session);
	my $richEdit = WebGUI::Asset::RichEdit->new($self->session,$self->get("richEditId"));
	if (defined $richEdit) {
       $self->session->style->setScript($self->session->url->extras('textFix.js'),{ type=>'text/javascript' });
	   $self->set("extras", $self->get('extras') . ' onblur="fixChars(this.form.'.$self->get("name").')" mce_editable="true" ');
	   $self->set("resizeable", 0);
	   return $self->SUPER::toHtml.$richEdit->getRichEditor($self->get('id'));
    } else {
	   $self->session->errorHandler->warn($i18n->get('rich editor load error','Form_HTMLArea'));
	   return $self->SUPER::toHtml;
	}

}


1;

