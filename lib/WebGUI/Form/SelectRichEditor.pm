package WebGUI::Form::SelectRichEditor;

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

#-------------------------------------------------------------------

=head2 areOptionsSettable ( )

Returns 0.

=cut

sub areOptionsSettable {
    return 0;
}

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
    push @{$definition}, {
        defaultValue => {
            defaultValue    => '',
        },
        };
    return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2  getDatabaseFieldType ( )

Returns "CHAR(22) BINARY".

=cut 

sub getDatabaseFieldType {
    return "CHAR(22) BINARY";
}

#-------------------------------------------------------------------

=head2 getName ( session )

Returns the human readable name of this control.

=cut

sub getName {
    my ($self, $session) = @_;
    return WebGUI::International->new($session, 'WebGUI')->get('SelectRichEditor formName');
}

#-------------------------------------------------------------------

=head2 isDynamicCompatible ( )

A class method that returns a boolean indicating whether this control is compatible with the DynamicField control. Returns 0.

=cut

sub isDynamicCompatible {
    return 0;
}

#----------------------------------------------------------------------------

=head2 getOptions

Create a new WebGUI::Form::SelectRichEditor object and populate it with all 
the available Rich Text Editor assets.

=cut

sub getOptions {
    my $self = shift;
    my $editorIter = WebGUI::Asset->getRoot($self->session)->getLineageIterator( ['descendants'], {includeOnlyClasses => ['WebGUI::Asset::RichEdit']});
    my %options;
    while ( 1 ) {
        my $editor;
        eval { $editor = $editorIter->() };
        if ( my $x = WebGUI::Error->caught('WebGUI::Error::ObjectNotFound') ) {
            $self->session->log->error($x->full_message);
            next;
        }
        last unless $editor;
        $options{ $editor->getId } = $editor->getTitle;
    }
    return \%options;
}

#-------------------------------------------------------------------

=head2 toHtmlWithWrapper ( )

Renders the form field to HTML as a table row complete with labels, subtext, hoverhelp, etc. Also adds manage and edit icons next to the field if the current user is in the admins group.

=cut

sub toHtmlWithWrapper {
    my $self = shift;
    my $editor = WebGUI::Asset::RichEdit->new($self->session,$self->getOriginalValue);
    if (defined $editor && $editor->canEdit) {
        my $returnUrl = '';
        if (defined $self->session->asset && !$self->session->asset->isa("WebGUI::Asset::RichEdit")) {
            $returnUrl = ";proceed=goBackToPage;returnUrl=".$self->session->url->escape($self->session->asset->getUrl);
        }
        my $buttons = $self->session->icon->edit("func=edit".$returnUrl,$editor->get("url"));
        $buttons .= $self->session->icon->manage("op=assetManager",$editor->getParent->get("url"));
        $self->set("subtext", $buttons . $self->get("subtext"));
    }
    return $self->SUPER::toHtmlWithWrapper;
}

1;

