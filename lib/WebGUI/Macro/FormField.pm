package WebGUI::Macro::FormField;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;

=head1 NAME

Package WebGUI::Macro::FormField

=head1 DESCRIPTION

Renders an instance of a Form object.

=head2 process( $session, $type, $field_name [, $default_value, @form_constructor_arguments ] )

C<$type> is one of the L<WebGUI::Form::Control> subclasses in L<WebGUI::Form>.

C<$field_name> is the name the field will be given in the HTML "name" attribute.

C<$default_value> is the currently selected value to use for the form field if no GET/POST parameter or field of the
current asset of the same name has a value.

A form posted form parameter of the same name as the C<$field_name>, if present, will be used instead of the default.
Failing that, an attribute of the current asset of the same name, if present, will be used instead of the default value.

C<@form_constructor_arguments> get passed to the L<WebGUI::Form> subclass constructor.

=cut


sub process {
    my $session = shift;
    my $type = shift;
    my $name = shift;
    my $default_value = shift || '';
    my @extras = @_;

    my $form_class = "WebGUI::Form::" . ucfirst $type;

    my $value = $session->form->get($name);
    $value ||= $session->asset->get($name) if $session->asset;
    $value ||= $default_value;

    my $control = eval { WebGUI::Pluggable::instanciate($form_class, 'new', [ $session, { name => $name, value => $value, @extras } ]) };
    if ($@) {
        $session->log->warn("FormField Macro could not load class ``$form_class'': $@"); 
        return '';
    }

    return $control->toHtml;
}

1;


