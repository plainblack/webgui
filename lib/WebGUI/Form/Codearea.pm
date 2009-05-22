package WebGUI::Form::Codearea;

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
use base 'WebGUI::Form::Textarea';
use WebGUI::International;

=head1 NAME

Package WebGUI::Form::Codearea

=head1 DESCRIPTION

Creates a code area form field, which is just like a text area except stretches to fit it's space and allows tabs in it's content.

=head1 SEE ALSO

This is a subclass of WebGUI::Form::Textarea.

=head1 METHODS 

The following methods are specifically available from this class. Check the superclass for additional methods.

=cut


#-------------------------------------------------------------------

=head2 definition ( [ additionalTerms ] )

See the super class for additional details.

=head3 additionalTerms

=head4 width

The width of this control in pixels. Defaults to 550 pixels.

=head4 height

The height of this control in pixels.  Defaults to 450 pixels.

=head4 style

Style attributes besides width and height which should be specified using the above parameters. Be sure to escape quotes if you use any.

The following additional parameters have been added via this sub class.

=head4 syntax

The type of syntax highlighting to use by default. The types available are located at
$WEBGUI_ROOT/www/extras/editarea/edit_area/reg_syntax

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift || [];
	push(@{$definition}, {
		height=>{
			defaultValue=> 450 
			},
		width=>{
			defaultValue=> 550 
			},
		style=>{
			defaultValue => undef,
			},
        syntax => {
            defaultValue    => "html",
        },
    });
    return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2  getDatabaseFieldType ( )

Returns "MEDIUMTEXT".

=cut 

sub getDatabaseFieldType {
    return "MEDIUMTEXT";
}

#-------------------------------------------------------------------

=head2 getName ( session )

Returns the human readable name of this control.

=cut

sub getName {
    my ($self, $session) = @_;
    return WebGUI::International->new($session, 'WebGUI')->get('codearea');
}

#-------------------------------------------------------------------

=head2 isDynamicCompatible ( )

A class method that returns a boolean indicating whether this control is compatible with the DynamicField control.

=cut

sub isDynamicCompatible {
    return 1;
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders a code area field.

=cut

sub toHtml {
	my $self    = shift;
	my $output  = "";
    
    # Do our superclass's job
    my $value = $self->fixMacros($self->fixTags($self->fixSpecialCharacters(scalar $self->getOriginalValue)));
	my $width = $self->get('width') || 400;
	my $height = $self->get('height') || 150;
	my ($style, $url) = $self->session->quick(qw(style url));
	my $styleAttribute = "width: ".$width."px; height: ".$height."px; ".$self->get("style");
    $style->setRawHeadTags(qq|<style type="text/css">\ntextarea#|.$self->get('id').qq|{ $styleAttribute }\n</style>|);
	$output = '<textarea id="'.$self->get('id').'" name="'.$self->get("name").'" '.$self->get("extras").' rows="#" cols="#" style="width: '.$width.'px; height: '.$height.'px;">'.$value.'</textarea>';

    # Vars for JS below
    my $id              = $self->get( "id" );
    my $syntax          = $self->get( "syntax" );
    my $editareaPath    = $self->session->url->extras( 'editarea' );

	$self->session->style->setScript($editareaPath . '/edit_area/edit_area_full.js',{type=>"text/javascript"});
    $output .= qq~
        <script type="text/javascript">
            editAreaLoader.init({
                id              : "$id",
                syntax          : "$syntax",
                start_highlight : true,
                show_line_colors: true,
                display         : "later",
                toolbar         : "search, go_to_line, |, undo, redo, |, syntax_selection, highlight, reset_highlight, |, help"
            });
        </script>
    ~;

    return $output;
}


1;

