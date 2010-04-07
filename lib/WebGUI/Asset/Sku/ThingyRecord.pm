package WebGUI::Asset::Sku::ThingyRecord;

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
use Tie::IxHash;
use Moose;
use WebGUI::Definition::Asset;
extends 'WebGUI::Asset::Sku';
define assetName         => ['assetName', 'Asset_ThingyRecord'];
define icon              => 'thingyRecord.gif';
define tableName         => 'ThingyRecord';
property templateIdView => (
            tab       => "display",
            fieldType => "template",
            namespace => "ThingyRecord/View",
            label     => ['templateIdView label', 'Asset_ThingyRecord'],
            hoverHelp => ['templateIdView description', 'Asset_ThingyRecord'],
         );
property thingId => (
            tab       => "properties",
            fieldType => "selectBox",
            options   => \&_thingId_options,
            label     => ['thingId label', 'Asset_ThingyRecord'],
            hoverHelp => ['thingId description', 'Asset_ThingyRecord'],
         );
sub _thingId_options {
    my $self = shift;
    return $self->getThingOptions($self->session);
}
property thingFields => (
            tab       => "properties",
            fieldType => "selectList",
            options   => {},                                      # populated by ajax call
            label     => ['thingFields label', 'Asset_ThingyRecord'],
            hoverHelp => ['thingFields description', 'Asset_ThingyRecord'],
         );
property thankYouText => (
            tab          => "properties",
            fieldType    => "HTMLArea",
            builder      => '_thankYouMessage_default',
            lazy         => 1,
            label        => [ "thank you message", 'Asset_Product' , 'Asset_ThingyRecord'],
            hoverHelp    => [ "thank you message help", 'Asset_Product' , 'Asset_ThingyRecord'],
         );
sub _thankYouMessage_default {
    my $session = shift->session;
	my $i18n = WebGUI::International->new($session, "Asset_Product");
    return $i18n->get( 'default thank you message', 'Asset_Product' ) . " ^ViewCart;";
}
property price => (
            tab       => "properties",
            fieldType => "float",
            label     => [ '10', "Asset_Product" , 'Asset_ThingyRecord'],      #Price
            hoverHelp => [ 'price', 'Asset_Product' , 'Asset_ThingyRecord'],
         );
property fieldPrice => (
            tab         => "properties",
            fieldType   => "textarea",
            customDrawMethod => 'drawEditFieldPrice',
            label       => [ 'fieldPrice label' , 'Asset_ThingyRecord'],
            hoverHelp   => [ 'fieldPrice description', 'Asset_ThingyRecord'],
         );
property duration => (
            tab          => "properties",
            fieldType    => "interval",
            default      => 60 * 60 * 24 * 7,                      # One week
            label        => ['duration label', 'Asset_ThingyRecord'],
            hoverHelp    => ['duration description', 'Asset_ThingyRecord'],
         );

use HTML::Entities qw( encode_entities );

# Collateral data class... very long name. Zoffix eat your heart out.
my $RECORD_CLASS = 'WebGUI::AssetCollateral::Sku::ThingyRecord::Record';

=head1 NAME

Package WebGUI::Asset::Sku::ThingyRecord

=head1 DESCRIPTION

Purchase a record in a thingy.

=head1 SYNOPSIS

use WebGUI::Asset::ThingyRecord;


=head1 METHODS

These methods are available from this class:

=cut

#----------------------------------------------------------------------------

=head2 appendVarsEditRecord ( var, recordId )

Get the template variables for the form to edit the record. Does not include
the header or footer!

=cut

sub appendVarsEditRecord {
    my ( $self, $var, $recordId ) = @_;
    my $session     = $self->session;
    my $thingy      = $self->getThingy;
    my $fieldPrice  = JSON->new->decode( $self->fieldPrice || '{}' );
    my $record      = {};
    if ($recordId) {

        # Get an existing record
        $record = $self->getThingRecord( $self->thingId, $recordId );
        if ( !%$record ) {    # Record is hidden
            $record = JSON->new->decode( $RECORD_CLASS->new( $session, $recordId )->get('fields') );
        }
    }

    my $fields = $self->getThingFields( $self->thingId );
    my @allowed = split "\n", $self->thingFields;
    for my $field ( @{$fields} ) {
        next unless grep { $_ eq $field->{fieldId} } @allowed;
        
        # Don't allow user to edit fields they didn't purchase
        next if ( 
            $recordId 
            && $fieldPrice->{ $field->{fieldId} } > 0 
            && not defined $record->{ 'field_' . $field->{fieldId} } 
        );

        $field->{value} = $record->{ 'field_' . $field->{fieldId} } || $field->{defaultValue};
        my $price       = $fieldPrice->{ $field->{fieldId} };
        my %fieldProperties = (
            "input"      => $thingy->getFormElement($field),
            "value"      => $thingy->getFieldValue( $field->{value}, $field ),
            "label"      => $field->{label},
            "isHidden"   => ( $field->{status} eq 'hidden' ),
            "isVisible"  => ( $field->{status} eq "visible" ),
            "isRequired" => ( $field->{status} eq "required" ),
            "pretext"    => $field->{pretext},
            "subtext"    => $field->{subtext},
            "price"      => $price > 0 ? $price : "",
        );
        push @{ $var->{form_fields} }, { map { "field_" . $_ => $fieldProperties{$_} } keys %fieldProperties };

        # Add a way to get the field outside of the loop
        # TODO
    } ## end for my $field ( @{$fields...})

    return $var;
} ## end sub appendVarsEditRecord

#-------------------------------------------------------------------

=head2 deleteThingRecord ( thingId, recordId )

Delete a record from a thing

=cut

sub deleteThingRecord {
    my ( $self, $thingId, $recordId ) = @_;
    my $db        = $self->session->db;
    my $dbh       = $self->session->db->dbh;
    my $tableName = $dbh->quote_identifier( 'Thingy_' . $thingId );
    $db->write( "DELETE FROM $tableName WHERE thingDataId=?", [$recordId] );
}

#-------------------------------------------------------------------

=head2 drawEditFieldPrice ( )

Draw the field to edit field prices. Add appropriate javascript.

=cut

sub drawEditFieldPrice {
    my ( $self ) = @_;

    my $fieldHtml   = sprintf <<'ENDHTML', encode_entities( $self->fieldPrice );
<div id="fieldPrice"></div><input type="hidden" name="fieldPrice" value="%s" id="fieldPrice_formId"/>
ENDHTML

    return $fieldHtml;
}

#-------------------------------------------------------------------

=head2 getEditForm ( )

Add the javascript needed for the edit form

=cut

sub getEditForm {
    my ($self) = @_;
    $self->session->style->setScript(
        $self->session->url->extras('yui/build/yahoo-dom-event/yahoo-dom-event.js'),
        { type => "text/javascript" },
    );
    $self->session->style->setScript(
        $self->session->url->extras('yui/build/connection/connection-min.js'),
        { type => "text/javascript" },
    );
    $self->session->style->setScript(
        $self->session->url->extras('yui/build/json/json-min.js'),
        { type => "text/javascript" },
    );
    $self->session->style->setScript(
        $self->session->url->extras('yui-webgui/build/thingyRecord/thingyRecord.js'),
        { type => "text/javascript" },
    );
    $self->session->style->setRawHeadTags(<<EOSCRIPT);
<script type="text/javascript">
YAHOO.util.Event.onDOMReady( function () { var thingForm = YAHOO.util.Dom.get('thingId_formId'); WebGUI.ThingyRecord.getThingFields(thingForm.options[thingForm.selectedIndex].value,'thingFields_formId')} );
</script>
EOSCRIPT
    return $self->SUPER::getEditForm;
} ## end sub getEditForm

#----------------------------------------------------------------------------

=head2 getMaxAllowedInCart ( )

One only!

=cut

sub getMaxAllowedInCart {
    my ($self) = @_;
    return 1;
}

#----------------------------------------------------------------------------

=head2 getPostPurchaseActions ( item )

Return a hash reference of "label" => "url" to do things with this item after
it is purchased. C<item> is the WebGUI::Shop::TransactionItem for this item

=cut

sub getPostPurchaseActions {
    my ( $self, $item ) = @_;
    my $session  = $self->session;
    my $opts     = $self->SUPER::getPostPurchaseActions();
    my $i18n     = WebGUI::International->new( $session, "Asset_ThingyRecord" );
    my $recordId = $item->get('options')->{recordId};

    $opts->{ $i18n->get('renew') } = $self->getUrl( 'func=renew;recordId=' . $recordId );
    $opts->{ $i18n->get( '575', 'WebGUI' ) }    # edit
        = $self->getUrl( 'func=editRecord;recordid=' . $recordId );

    return $opts;
}

#----------------------------------------------------------------------------

=head2 getPrice ( )

Get the price

=cut

sub getPrice {
    my ($self) = @_;
    my $price       = $self->price;
    my $fieldPrice  = JSON->new->decode( $self->fieldPrice || '{}' );
    my $option      = $self->getOptions;
    my $record      = $RECORD_CLASS->new( $self->session, $option->{recordId} );
    my $fields      = JSON->new->decode( $record->get('fields') );

    # Calculate field price
    for my $key ( keys %{$fields} ) {
        my $fieldId = substr $key, length("field_");
        if ( $fieldPrice->{ $fieldId } > 0 ) {
            $price += $fieldPrice->{ $fieldId };
        }
    }

    return $price;
}

#----------------------------------------------------------------------------

=head2 getTemplateVars ( )

Get common template vars for this asset.

=cut

sub getTemplateVars {
    my $self = shift;
    my $var  = $self->get;
    $var->{url} = $self->getUrl;
    return $var;
}

#----------------------------------------------------------------------------

=head2 getThingFields ( thingId )

Get the fields for a thing.

=cut

sub getThingFields {
    my ( $self, $thingId ) = @_;

    my $fields
        = $self->session->db->buildArrayRefOfHashRefs(
        'SELECT * FROM Thingy_fields WHERE thingId = ? ORDER BY sequenceNumber',
        [$thingId] );

    return $fields;
}

#----------------------------------------------------------------------------

=head2 getThingOptions ( session )

Get all the thingys and all the things in them.

=cut

sub getThingOptions {
    my ( $class, $session ) = @_;
    tie my %options, 'Tie::IxHash', ( "" => "" );
    my $thingyIter = WebGUI::Asset->getRoot($session)
        ->getLineageIterator( ['descendants'], { includeOnlyClasses => ['WebGUI::Asset::Wobject::Thingy'], } );
    while ( my $thingy = $thingyIter->() ) {
        tie my %things, 'Tie::IxHash', (
            $session->db->buildHash( "SELECT thingId, label FROM Thingy_things WHERE assetId=?", [ $thingy->getId ] ) );
        $options{ $thingy->title } = \%things;
    }

    return \%options;
}

#----------------------------------------------------------------------------

=head2 getThingRecord ( thingId, recordId ) 

Get a row of data from a thing. Returns a hashref

=cut

sub getThingRecord {
    my ( $self, $thingId, $recordId ) = @_;
    my $table = $self->session->db->dbh->quote_identifier( "Thingy_" . $thingId );
    return $self->session->db->quickHashRef( "SELECT * FROM " . $table . " WHERE thingDataId=?", [$recordId] );
}

#----------------------------------------------------------------------------

=head2 getThingy ( )

Get the thingy associated with this ThingyRecord

=cut

sub getThingy {
    my ($self) = @_;
    my $thingyId = $self->session->db->quickScalar(
        "SELECT assetId FROM Thingy_things WHERE thingId=?",
        [ $self->thingId ],
    );
    return WebGUI::Asset->newById( $self->session, $thingyId );
}

#-------------------------------------------------------------------

=head2 onCompletePurchase ( )

Purchase completed, add the record.

=cut

sub onCompletePurchase {
    my ( $self, $item ) = @_;

    my $option = $self->getOptions;
    my $record = $RECORD_CLASS->new( $self->session, $option->{recordId} );
    my $now    = time;

    if ( $option->{action} eq "buy" ) {

        # Update record
        $record->update( {
                expires         => $now + $self->duration,
                transactionId   => $item->transaction->getId,
                isHidden        => 0,
            }
        );

        # Add to thingy data
        my $data = JSON->new->decode( $record->get('fields') );
        $self->updateThingRecord( $self->thingId, $record->getId, $data );
    }
    elsif ( $option->{action} eq "renew" ) {

        # Renew a currently active record
        if ( $record->get('expires') > $now ) {
            $record->update( { expires => $record->get('expires') + $self->duration, } );
        }

        # Renew an expired but not deleted record
        else {
            $record->update( {
                    expires  => $now + $self->duration,
                    isHidden => 0,
                }
            );

            # Add to thingy data
            my $data = JSON->new->decode( $record->get('fields') );
            $self->updateThingRecord( $self->thingId, $record->getId, $data );
        }
    } ## end elsif ( $option->{action}...)
} ## end sub onCompletePurchase

#-------------------------------------------------------------------

=head2 onRemoveFromCart ( )

Removed from cart, remove all knowledge

=cut

sub onRemoveFromCart {
    my ( $self, $item ) = @_;

    # Remove from cart
    my $option = $self->getOptions;
    if ( $option->{action} eq "buy" ) {
        my $record = $RECORD_CLASS->new( $self->session, $option->{recordId} );
        if ($record) {
            $record->delete;
        }
    }
}

#-------------------------------------------------------------------

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

sub prepareView {
    my $self = shift;
    $self->SUPER::prepareView();
    my $template = WebGUI::Asset::Template->newById( $self->session, $self->templateIdView );
    $template->prepare( $self->getMetaDataAsTemplateVariables );
    $self->{_viewTemplate} = $template;
}

#-------------------------------------------------------------------

=head2 processEditRecordForm ( )

Process the edit record form and return the record

=cut

sub processEditRecordForm {
    my ($self) = @_;
    my $var         = {};
    my $fieldPrice  = JSON->new->decode( $self->fieldPrice );

    my $fields = $self->getThingFields( $self->thingId );
    for my $field ( @{$fields} ) {
        my $fieldName = 'field_' . $field->{fieldId};
        my $fieldType = $field->{fieldType};
        $fieldType = "" if ( $fieldType =~ m/^otherThing/x );
        my $value = $self->session->form->get( $fieldName, $fieldType, $field->{defaultValue}, $field );

        # Don't save fields we didn't pay for
        if ( $fieldPrice->{ $field->{fieldId} } > 0 && !$value ) {
            next;
        }
        
        $var->{ $fieldName } = $value;
    }

    return $var;
}

#-------------------------------------------------------------------

=head2 purge ( )

Remove all collateral associated with the ThingyRecord sku

=cut

override purge => sub {
    my $self = shift;

    my $options = { constraints => [ { 'assetId = ?' => $self->getId } ] };

    my $iter = $RECORD_CLASS->getAllIterator( $self->session, $options );
    while ( my $item = $iter->() ) {
        $item->delete;
    }

    # XXX: Should we also remove the records from the Thingy?

    return super();
};

#-------------------------------------------------------------------

=head2 updateThingRecord ( thingId, data )

Update data in a thing

=cut

sub updateThingRecord {
    my ( $self, $thingId, $recordId, $data ) = @_;
    my $db        = $self->session->db;
    my $dbh       = $self->session->db->dbh;
    my $tableName = $dbh->quote_identifier( 'Thingy_' . $thingId );
    $data->{thingDataId} = $recordId;
    my $columns = join ",", map { $dbh->quote_identifier($_) } keys %{$data};
    my $values  = [ values %{$data} ];
    my $places  = join ",", ('?') x @{$values};
    $self->session->db->write( "REPLACE INTO $tableName ($columns) VALUES ($places)", $values, );
}

#-------------------------------------------------------------------

=head2 view ( options )

method called by the container www_view method. 

=cut

sub view {
    my ( $self, $options ) = @_;
    my $session = $self->session;
    my $i18n    = WebGUI::International->new( $session, "Asset_ThingyRecord" );
    my $var     = $self->getTemplateVars;
    $self->appendVarsEditRecord($var);
    $var->{isNew} = 1;
    $var->{message}
        = $options->{addedToCart}
        ? $self->thankYouText
        : $options->{message};
    if ( $options->{addedToCart} ) {
        $var->{addedToCart} = 1;
    }

    # Add form header, footer, and submit button
    $var->{form_header} = WebGUI::Form::formHeader( $session, { action => $self->getUrl('func=buy'), } );

    $var->{form_footer} = WebGUI::Form::formFooter($session);

    $var->{form_submit} = WebGUI::Form::submit( $session, { value => $i18n->get( 'add to cart', 'Shop' ), } );

    return $self->processTemplate( $var, undef, $self->{_viewTemplate} );
} ## end sub view

#----------------------------------------------------------------------------

=head2 www_buy ( )

Create a new record and add it to the cart

=cut

sub www_buy {
    my ($self) = @_;
    my $session = $self->session;

    # Get data for row
    my $recordFields = $self->processEditRecordForm;
    my $recordData   = {
        userId  => $session->user->userId,
        assetId => $self->getId,
        fields  => JSON->new->encode($recordFields),
    };

    # Add row to cart collateral
    my $record = $RECORD_CLASS->create( $session, $recordData );

    # Add item to cart with appropriate action and recordId
    $self->addToCart( {
            action   => "buy",
            recordId => $record->getId,
        }
    );

    # Return thank you screen
    $self->prepareView;
    return $self->processStyle( $self->view( { addedToCart => 1 } ) );
} ## end sub www_buy

#----------------------------------------------------------------------------

=head2 www_editRecord ( options )

Edit the record after is has been purchased. Allow the user to show/hide the 
record while it is still active.

=cut

sub www_editRecord {
    my ( $self, $options ) = @_;
    my $session  = $self->session;
    my $recordId = $session->form->get('recordId');
    my $record   = $RECORD_CLASS->new( $session, $recordId );
    return $self->session->privilege->insufficient
        unless $self->session->user->userId eq $record->get('userId');
    my $i18n = WebGUI::International->new( $session, "Asset_ThingyRecord" );
    my $var = $self->getTemplateVars;
    $self->appendVarsEditRecord( $var, $recordId );
    $var->{message} = $options->{message};

    # Add form header, footer, and submit button
    $var->{form_header} = WebGUI::Form::formHeader( $session,
        { action => $self->getUrl( 'func=editRecordSave;recordId=' . $recordId ), } );

    $var->{form_footer} = WebGUI::Form::formFooter($session);

    $var->{form_submit} = WebGUI::Form::submit( $session, { value => $i18n->get( 'save', 'WebGUI' ), } );

    # Add record information
    my $recordData = $record->get;
    for my $key ( keys %{$recordData} ) {
        $var->{ "record_" . $key } = $recordData->{$key};
    }

    # Add field to hide/show
    # Don't allow user to show expired record
    if ( time < $record->get('expires') ) {
        $var->{form_hide} = WebGUI::Form::yesNo(
            $session, {
                name  => "hide",
                value => $record->get('isHidden'),
            }
        );
    }

    return $self->processStyle( $self->processTemplate( $var, $self->templateIdView ) );
} ## end sub www_editRecord

#----------------------------------------------------------------------------

=head2 www_editRecordSave ( )

Save the record

=cut

sub www_editRecordSave {
    my ($self)   = @_;
    my $session  = $self->session;
    my $form     = $self->session->form;
    my $recordId = $form->get('recordId');
    my $record = $RECORD_CLASS->new( $session, $recordId );
    return $self->session->privilege->insufficient
        unless $self->session->user->userId eq $record->get('userId');
    my $i18n       = WebGUI::International->new( $session, "Asset_ThingyRecord" );
    my $hide       = $form->get('hide');
    my $recordData = $self->processEditRecordForm;
    $record->update( {
            fields   => JSON->new->encode($recordData),
            isHidden => $hide,
        }
    );

    if ($hide) {
        $self->deleteThingRecord( $self->thingId, $recordId );
    }
    else {
        $self->updateThingRecord( $self->thingId, $recordId, $recordData );
    }

    return $self->www_editRecord( { message => $i18n->get('saved') } );
} ## end sub www_editRecordSave

#----------------------------------------------------------------------------

=head2 www_renew ( )

Add more time to an existing record.

=cut

sub www_renew {
    my ($self) = @_;
    my $session = $self->session;
    my $i18n     = WebGUI::International->new( $session, "Asset_ThingyRecord" );
    my $recordId = $self->session->form->get('recordId');
    my $record   = $RECORD_CLASS->new( $session, $recordId );
    return $session->privilege->insufficient
        unless $session->user->userId eq $record->get('userId');

    $self->addToCart( {
            action   => "renew",
            recordId => $recordId,
        }
    );

    return $self->www_editRecord( { message => $i18n->get('renewal added to cart') . ' ^ViewCart;' } );
} ## end sub www_renew

1;

#vim:ft=perl
