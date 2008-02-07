package WebGUI::Form::SelectRichEditor;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2008 Plain Black Corporation.
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

=head1 NAME

WebGUI::Form::SelectRichEditor

=head1 DESCRIPTION

Creates a select box to choose a Rich Text Editor asset.

=head1 SEE ALSO

This is a subclass of WebGUI::Form::SelectBox.

=head1 METHODS 

The following methods are specifically available from this class. Check the superclass for additional methods.

=cut

#----------------------------------------------------------------------------

=head2 definition ( [ additionalTerms ] )

See the super class for additional details.

=head3 additionalTerms

The following additional parameters have been added via this sub class.

=head4 defaultValue

Defaults to the Post Rich Editor, the least-featured Rich Text Editor and the
one most likely to be selected by users of this form control.

=cut

sub definition {
    my $class       = shift;
    my $session     = shift;
    my $definition  = shift || [];
    my $i18n        = WebGUI::International->new($session);
    push @{$definition}, {
        formName => {
            defaultValue    => $i18n->get("475"),
        },
        defaultValue => {
            defaultValue    => '',
        },
    };
    return $class->SUPER::definition($session, $definition);
}

#----------------------------------------------------------------------------

=head2 new

Create a new WebGUI::Form::SelectRichEditor object and populate it with all 
the available Rich Text Editor assets.

=cut

sub new {
    my $class       = shift;
    my $self        = $class->SUPER::new(@_);
    
    # Get all the RTEs available to this site
    my $options
        = $self->session->db->buildHashRef( q{
            SELECT DISTINCT(assetData.assetId), assetData.title 
                FROM asset, assetData 
                WHERE asset.className='WebGUI::Asset::RichEdit' 
                    AND asset.assetId=assetData.assetId 
                ORDER BY assetData.title
        });
    
    $self->set( "options", $options );

    return $self;
}

1;

