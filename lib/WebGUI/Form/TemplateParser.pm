package WebGUI::Form::TemplateParser;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2012 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use base 'WebGUI::Form::SelectBox';
use WebGUI::International;
use Tie::IxHash;

=head1 NAME

Package WebGUI::Form::TemplateParser

=head1 DESCRIPTION

A dropdown list for selecting a template parser.

=head1 SEE ALSO

This is a subclass of WebGUI::Form::SelectBox.

=head1 METHODS

The following methods are specifically available from this class. Check the superclass for additional methods.

=cut

#-------------------------------------------------------------------

=head2 areOptionsSettable

No, they aren't.

=cut

sub areOptionsSettable { 0 }

#----------------------------------------------------------------------------

=head2 definition ( [ additionalTerms ] )

See the super class for additional details.

=head3 additionalTerms

The following additional parameters have been added via this sub class.

=head3 allowNone

Set to true if "None" is an acceptable option for this dropdown. Defaults to
false.

=head4 defaultValue

Defaults to the default parser selected in the config file

=cut

sub definition {
    my ($class, $session, $definition) = @_;
    push @{$definition ||= []}, {
        allowNone => {
            defaultValue => 0,
        },
        defaultValue => {
            defaultValue => $session->config->get('defaultTemplateParser')
        }
    };
    return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 getName ( session )

Returns the human readable name of this control.

=cut

sub getName {
    my ($self, $session) = @_;
    return WebGUI::International->new($session, 'WebGUI')->get('Template Parser');
}

#-------------------------------------------------------------------

=head2 getOptions

Called by the superclass to determine which options are presented.

=cut

sub getOptions {
    my $self    = shift;
    my $session = $self->session;
    tie my %o, 'Tie::IxHash';
    if ($self->get('allowNone')) {
        $o{''} = WebGUI::International->new($session, 'WebGUI')->get('881');
    }
    return \%o unless my $parsers = $session->config->get('templateParsers');

    for my $class (@$parsers) {
        my $parser = WebGUI::Asset::Template->getParser($session, $class);
        $o{$class} = $parser->getName;
    }

    return \%o;
}

1;
