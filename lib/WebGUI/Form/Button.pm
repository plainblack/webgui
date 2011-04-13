package WebGUI::Form::Button;

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

=head1 NAME

Package WebGUI::Form::Button

=head1 DESCRIPTION

Creates a form button.

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

=head4 defaultValue

The default text to appear on the button. Defaults to an internationalized version of the word "save".

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift || [];
	my $i18n = WebGUI::International->new($session,"WebGUI");
	push(@{$definition}, {
		defaultValue=>{
			defaultValue=>$i18n->get(62)
			},
                type => {
                    defaultValue     => 'button',
                },
		});
        return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 getName ( session )

Returns the human readable name of this control.

=cut

sub getName {
    my ($self, $session) = @_;
    return WebGUI::International->new($session, 'WebGUI')->get('button');
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders a button.

=cut

sub toHtml {
	my $self = shift;
 	my $value = $self->fixQuotes($self->getOriginalValue);
	my $html = '<input type="' . $self->get('type') . '" ';
	$html .= 'name="'.$self->get("name").'" ' if ($self->get("name"));
	$html .= 'id="'.$self->get('id').'" ' unless ($self->get('id') eq "_formId");
	$html .= 'value="'.$value.'" '.$self->get("extras").' />';
        my ( $style, $url ) = $self->session->quick(qw( style url ));
        $style->setCss($url->extras('yui/build/button/assets/skins/sam/button.css'));
        $style->setScript($url->extras('yui/build/yahoo-dom-event/yahoo-dom-event.js'));
        $style->setScript($url->extras('yui/build/element/element-min.js'));
        $style->setScript($url->extras('yui/build/button/button-min.js'));
        $html .= '<script type="text/javascript">new YAHOO.widget.Button("' . $self->get('id') . '");</script>';
	return $html;
}

1;

