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
use Tie::IxHash;
use WebGUI::International;
use WebGUI::Utility;
use WebGUI::Form::DataTable;
use base 'WebGUI::Asset::Wobject';

#-------------------------------------------------------------------

=head2 definition ( session, definition )

=cut

sub definition {
    my $class      = shift;
    my $session    = shift;
    my $definition = shift;
    my $i18n       = WebGUI::International->new( $session, 'Asset_DataTable' );

    tie my %properties, 'Tie::IxHash', (
        data => {
            fieldType    => 'DataTable',
            defaultValue => undef,
            autoGenerate => 0,
        },
        templateId => {
            tab          => "display",
            fieldType    => "template",
            namespace    => "DataTable",
            defaultValue => "3rjnBVJRO6ZSkxlFkYh_ug",
            label        => $i18n->get("editForm templateId label"),
            hoverHelp    => $i18n->get("editForm templateId description"),
        },
        );

    push @{$definition}, {
        assetName         => $i18n->get('assetName'),
        icon              => 'DataTable.gif',
        autoGenerateForms => 1,
        tableName         => 'DataTable',
        className         => 'WebGUI::Asset::Wobject::DataTable',
        properties        => \%properties,
        };

    return $class->SUPER::definition( $session, $definition );
} ## end sub definition

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

    return $self->get("data");
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

=head2 getEditForm ( )

Add the data table to the edit form.

=cut

# TODO Get the DataSource's edit form
sub getEditForm {
    my $self    = shift;
    my $tabform = $self->SUPER::getEditForm(@_);

    $tabform->getTab("data")->raw(
        q{<tr><td>}
      . WebGUI::Form::DataTable->new(
            $self->session, {
                name         => "data",
                value        => $self->get("data"),
                defaultValue => undef,
                showEdit     => 1,
                dateFormat   => $self->getDateFormat,
            }
            )->toHtml
      . q{</td></tr>}
    );

    return $tabform;
} ## end sub getEditForm

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
            value        => $self->get('data'),
            defaultValue => undef,
            dateFormat   => $self->getDateFormat,
        }
    );
    $dt->prepare;
    $self->{_datatable} = $dt;

    # Prepare the template
    my $template = WebGUI::Asset::Template->new( $session, $self->get("templateId") );
    if (!$template) {
        WebGUI::Error::ObjectNotFound::Template->throw(
            error      => qq{Template not found},
            templateId => $self->get("templateId"),
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

    $data ||= $self->get("data");

    $self->session->http->setMimeType("application/json");
    return $data;
}

1;
