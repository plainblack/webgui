package WebGUI::Form::MimeType;

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
use base 'WebGUI::Form::Combo';
use WebGUI::International;

=head1 NAME

Package WebGUI::Form::MimeType

=head1 DESCRIPTION

Creates an Mime Type chooser control.

=head1 SEE ALSO

This is a subclass of WebGUI::Form::Combo.

=head1 METHODS 

The following methods are specifically available from this class. Check the superclass for additional methods.

=cut

#-------------------------------------------------------------------

=head2 areOptionsSettable ( )

Returns 0.

=cut

sub areOptionsSettable {
    return 0;
}

#-------------------------------------------------------------------

=head2 definition ( [ additionalTerms ] )

See the super class for additional details.

=head4 afterEdit

A URL that will be acted upon after editing an LDAP link. 

=head4 label

A text label that will be displayed if toHtmlWithWrapper() is called. Defaults to getName().

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift || [];
	my $i18n = WebGUI::International->new($session, 'Form_MimeType');
	push(@{$definition}, {
		label=>{
			defaultValue=>$i18n->get('mimeType'),
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
    return WebGUI::International->new($session, 'Form_MimeType')->get('mimeType');
}

#-------------------------------------------------------------------

=head2 isDynamicCompatible ( )

Returns 0.

=cut

sub isDynamicCompatible {
    return 0;
}

#-------------------------------------------------------------------

=head2 new ( )

Extend the base "new" to set options.

=cut

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new(@_);
    my $mimeTypes;
    foreach ('text/html','text/css','text/javascript','text/plain','text/xml','application/xml') {
        $mimeTypes->{$_}=$_;
    } 
    ##Handle the combo box
    my $value            = $self->getOriginalValue();
    $mimeTypes->{$value} = $value;
    $self->set("options", $mimeTypes);
    return $self;
}

1;
