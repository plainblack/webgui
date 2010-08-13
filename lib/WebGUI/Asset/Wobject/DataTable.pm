package WebGUI::Asset::Wobject::DataTable;

$VERSION = "1.0.0";

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use Moose;
use WebGUI::Definition::Asset;
extends 'WebGUI::Asset::Wobject';
define assetName         => ['assetName', 'Asset_DataTable'];
define icon              => 'DataTable.gif';
define tableName         => 'DataTable';
property data => (
            tab          => "data",
            fieldType    => 'DataTable',
            default      => undef,
            label        => '',
            dateFormat   => \&getDateFormat,
         );
property templateId => (
            tab          => "display",
            fieldType    => "template",
            namespace    => "DataTable",
            default      => "3rjnBVJRO6ZSkxlFkYh_ug",
            label        => ["editForm templateId label", 'Asset_DataTable'],
            hoverHelp    => ["editForm templateId description", 'Asset_DataTable'],
         );

use WebGUI::International;
use WebGUI::Form::DataTable;

#----------------------------------------------------------------------------

=head2 getDataJson ( )

Get the data as a JSON object with the following structure:

 {
    columns    => [
        {
            key         => "Column Key",
            formatter   => "Column Format",
        },
        ...
    ],
    rows        => [
        {
            "Column Key"    => "Column Value",
            ...
        },
        ...
    ],
 }

=cut

sub getDataJson {
    my $self = shift;

    return $self->data;
}

#----------------------------------------------------------------------------

=head2 getDataTable ( )

Get the YUI DataTable markup and script for this DataTable.

=cut

# TODO Have this method get from a WebGUI::DataSource object

sub getDataTable {
    my $self = shift;

    if ( !$self->{_datatable} ) {
        $self->prepareView;
    }

    return $self->{_datatable}->getValueAsHtml;
}

#----------------------------------------------------------------------------

=head2 getDataTemplateVars ( )

Get the template variables for the raw data. Returns a hash reference with
"rows" and "columns" keys.

=cut

# TODO Have this method get from a WebGUI::DataSource object

sub getDataTemplateVars {
    my $self = shift;

    my $json = $self->getDataJson;
    my $dt   = eval { JSON->new->decode($json) };

    # Make row data more friendly to templates
    my %cols = map { $_->{key} => $_ } @{ $dt->{columns} };
    for my $row ( @{ $dt->{rows} } ) {

        # Create the column loop for the row
        for my $col ( @{ $dt->{columns} } ) {
            push @{ $row->{row_columns} }, { %{$col}, value => $row->{ $col->{key} }, };
        }
    }

    return $dt;
} ## end sub getDataTemplateVars

#----------------------------------------------------------------------------

=head2 getDateFormat ( )

Get the current date format for the current user in a strftime format that YUI can
understand.

=cut

sub getDateFormat {
    my ( $self ) = @_;

    my $dateFormat
        = WebGUI::DateTime->new( $self->session )->webguiToStrftime( $self->session->user->get('dateFormat') );
    # Special handle %_varmonth_ super special WebGUI field that strftime doesn't have
    $dateFormat =~ s/%_varmonth_/%m/g;

    return $dateFormat;
}

#----------------------------------------------------------------------------

=head2 getEditTabs ( )

Add a tab for the data table.

=cut

sub getEditTabs {
    my $self = shift;
    my $i18n = WebGUI::International->new( $self->session, "Asset_DataTable" );

    return ( $self->SUPER::getEditTabs, [ "data" => $i18n->get("tab label data") ], );
}

#----------------------------------------------------------------------------

=head2 getTemplateVars ( )

Get the template vars for this asset.

=cut

sub getTemplateVars {
    my $self = shift;
    my $var  = $self->get;

    $var->{url}       = $self->getUrl;
    $var->{dataTable} = $self->getDataTable;
    $var->{dataJson}  = $self->getDataJson;

    %{$var} = ( %{$var}, %{ $self->getDataTemplateVars }, );

    return $var;
}

#----------------------------------------------------------------------------

=head2 prepareView ( ) 

Prepare the view. Add stuff to HEAD.

=cut

sub prepareView {
    my $self = shift;
    $self->SUPER::prepareView(@_);
    my $session = $self->session;

    # For now, prepare the form control.
    # TODO Use a WebGUI::DataSource
    my $dt = WebGUI::Form::DataTable->new(
        $session, {
            name         => $self->getId,
            value        => $self->data,
            defaultValue => undef,
            dateFormat   => $self->getDateFormat,
        }
    );
    $dt->prepare;
    $self->{_datatable} = $dt;

    # Prepare the template
    my $template = WebGUI::Asset::Template->newById( $session, $self->templateId );
    if (!$template) {
        WebGUI::Error::ObjectNotFound::Template->throw(
            error      => qq{Template not found},
            templateId => $self->templateId,
            assetId    => $self->getId,
        );
    }
    $template->prepare;
    $self->{_template} = $template;

    return;
} ## end sub prepareView

#----------------------------------------------------------------------------

=head2 view ( )

method called by the www_view method.  Returns a processed template
to be displayed within the page style.  

=cut

sub view {
    my $self     = shift;
    my $session  = $self->session;
    my $var      = $self->getTemplateVars;
    my $dt       = $self->{_datatable};
    my $template = $self->{_template};

    return $self->processTemplate( $var, undef, $template );
}

#----------------------------------------------------------------------------

=head2 www_ajaxGetData ( )

Get the data asynchronously.

=cut

sub www_ajaxGetData {
    my $self = shift;

    $self->session->http->setMimeType("application/json");
    return $self->getDataJson;
}

#----------------------------------------------------------------------------

=head2 www_ajaxUpdateData ( )

Update the data table asynchronously. 

=cut

sub www_ajaxUpdateData {
    my $self = shift;
    my $data = $self->session->form->get("data");

    if ( $data && $self->canEdit ) {
        $self->update( { data => $data } );
    }

    $data ||= $self->data;

    $self->session->http->setMimeType("application/json");
    return $data;
}

__PACKAGE__->meta->make_immutable;
1;
