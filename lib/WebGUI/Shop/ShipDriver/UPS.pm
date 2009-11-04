package WebGUI::Shop::ShipDriver::UPS;

use strict;
use base qw/WebGUI::Shop::ShipDriver/;
use WebGUI::Exception;
use WebGUI::Exception::Shop;
use XML::Simple;
use LWP;
use Tie::IxHash;
use Locales::Country qw/ en   /; 
use Class::InsideOut qw/ :std /;
use Data::Dumper;

public testMode => my %testMode;

=head1 NAME

Package WebGUI::Shop::ShipDriver::UPS

=head1 DESCRIPTION

Shipping driver for the United Parcel Service, for US Domestic shipping only.

The UPS XML interface will only do a lookup for one destination at a time.  However,
each destination may have multiple packages.  This means that if a cart holds packages
with multiple destinations, that multiple requests must be sent to the UPS server.

=head1 SYNOPSIS

=head1 METHODS

See the master class, WebGUI::Shop::ShipDriver for information about
base methods.  These methods are customized in this class:

=cut

#-------------------------------------------------------------------

=head2 buildXML ( $cart, @packages )

Returns XML for submitting to the UPS servers

=head3 $cart

A WebGUI::Shop::Cart object.  This allows us access to the user's
address book

=head3 $packages

An array reference.  Each array element is 1 set of items.  The
quantity of items will vary in each set.  All packages in the set must
go to the same zipcode.

=cut

sub buildXML {
    my ($self, $cart, $packages) = @_;
    #tie my %xmlHash, 'Tie::IxHash';
    my %xmlHash = (
        AccessRequest => {},
    );
    my $xmlAcc = $xmlHash{AccessRequest};
    $xmlAcc->{'xml:lang'}          = 'en-US';
    $xmlAcc->{AccessLicenseNumber} = [ $self->get('licenseNo') ]; 
    $xmlAcc->{UserId}              = [ $self->get('userId')    ];
    $xmlAcc->{Password}            = [ $self->get('password')  ];
    my $localizedCountry = Locales::Country->new('en');
    my $xml = XMLout(\%xmlHash,
        KeepRoot    => 1,
        NoSort      => 1,
        SuppressEmpty => 0,
        XMLDecl       => 1,
    );
    my $destination = $packages->[0]->[0]->getShippingAddress;
    %xmlHash = (
        RatingServiceSelectionRequest => {},
    );
    my $xmlRate = $xmlHash{RatingServiceSelectionRequest };
    $xmlRate->{'xml:lang'}         = 'en-US';
    $xmlRate->{Request}    = {
#   Shown in example request, but optional
#       TransactionReference => {
#           CustomerContext => [ 'Rating and Service' ],
#           XpciVersion     => [ 1.0001 ],
#       },
        RequestAction => [ 'Rate' ],
#       RequestOption => [ 'shop' ],
    };
    $xmlRate->{PickupType} = {
        Code => [ $self->get('pickupType') ],
    };
    $xmlRate->{CustomerClassification} = {
        Code => [ $self->get('customerClassification') ],
    };
    $xmlRate->{Shipment} = {
        Shipper => {
            Address => [ {
                PostalCode  => [ $self->get('sourceZip'    ) ],
                CountryCode => [ $localizedCountry->country2code($self->get('sourceCountry'), 'alpha2') ],
            }, ],
        },
        ShipTo => {
            Address => [ {
                PostalCode  => [ $destination->get('code') ],
                CountryCode => [ $localizedCountry->country2code($destination->get('country'), 'alpha2') ],
            } ],
        },
        Service => {
            Code => [ $self->get('shipService') ],
        },
        Package => [],
    };
    if ($self->get('residentialIndicator') eq 'residential') {
        $xmlRate->{Shipment}->{ShipTo}->{Address}->[0]->{ResidentialAddressIndicator} = [''];
    }
    my $packHash = $xmlRate->{Shipment}->{Package};
    PACKAGE: foreach my $package (@{ $packages }) {
        my $weight = 0;
        ITEM: foreach my $item (@{ $package }) {
            my $sku = $item->getSku();
            next ITEM unless $sku->isShippingRequired;
            ##If shipsSeparately is set, the item was placed N times in the shippingBundles,
            ##where N is the quantity.  This means that the quantity is wrong for
            ##any item where that option is set.
            my $skuWeight = $sku->getWeight;
            if (! $sku->shipsSeparately() ) {
                $skuWeight *= $item->get('quantity');
            }
            $weight += $skuWeight;
        }
        next PACKAGE unless $weight;
        $weight = sprintf "%.1f", $weight;
        $weight = '0.1' if $weight == 0;
        my $options = {
            PackagingType => [ {
                Code => [ '02' ],
            } ],
            PackageWeight => [ {
                Weight => [ $weight ], ##Required formatting from spec
            } ],
        };
        push @{ $packHash }, $options;
    }
    return '' unless scalar @{ $packHash }; ##Nothing to calculate shipping for.
    $xml .= XMLout(\%xmlHash,
        KeepRoot      => 1,
        NoSort        => 1,
        SuppressEmpty => '',
        XMLDecl       => 1,
    );

    return $xml;
}


#-------------------------------------------------------------------

=head2 calculate ( $cart )

Returns a shipping price.  Since the UPS will only allow a lookup from one source
to one destination at a time, this method may make several XML requests from the
UPS server.

=head3 $cart

A WebGUI::Shop::Cart object.  The contents of the cart are analyzed to calculate
the shipping costs.  If no items in the cart require shipping, then no shipping
costs are assessed.

=cut

sub calculate {
    my ($self, $cart) = @_;
    if (! $self->get('sourceZip')) {
        WebGUI::Error::InvalidParam->throw(error => q{Driver configured without a source zipcode.});
    }
    if (! $self->get('sourceCountry')) {
        WebGUI::Error::InvalidParam->throw(error => q{Driver configured without a source country.});
    }
    if (! $self->get('userId')) {
        WebGUI::Error::InvalidParam->throw(error => q{Driver configured without a UPS userId.});
    }
    if (! $self->get('password')) {
        WebGUI::Error::InvalidParam->throw(error => q{Driver configured without a UPS password.});
    }
    if (! $self->get('licenseNo')) {
        WebGUI::Error::InvalidParam->throw(error => q{Driver configured without a UPS license number.});
    }
    my $cost = 0;
    ##Sort the items into shippable bundles.
    my @shippableUnits = $self->_getShippableUnits($cart);
    my $packageCount = scalar @shippableUnits;
    my $anyShippable = $packageCount > 0 ? 1 : 0;
    return $cost unless $anyShippable;
    #$cost = scalar @shippableUnits * $self->get('flatFee');
    ##Build XML ($cart, @shippableUnits)
    foreach my $unit (@shippableUnits) {
        if ($packageCount > 200) {
            WebGUI::Error::InvalidParam->throw(error => q{Cannot do UPS lookups for more than 200 items.});
        }
        my $xml = $self->buildXML($cart, $unit);
        ##Do request ($xml)
        my $response = $self->_doXmlRequest($xml);
        ##Error handling
        if (! $response->is_success) {
            WebGUI::Error::Shop::RemoteShippingRate->throw(error => 'Problem connecting to UPS Web Tools: '. $response->status_line);
        }
        my $returnedXML = $response->content;
        my $xmlData     = XMLin($returnedXML, ForceArray => [qw/RatedPackage/]);
        if (! $xmlData->{Response}->{ResponseStatusCode}) {
            WebGUI::Error::Shop::RemoteShippingRate->throw(error => 'Problem with UPS Online Tools XML: '. $xmlData->{Response}->{Error}->{ErrorDescription});
        }
        ##Summarize costs from returned data
        $cost += $self->_calculateFromXML($xmlData);
    }
    return $cost;
}

#-------------------------------------------------------------------

=head2 _calculateFromXML ( $xmlData )

Takes data from the UPS and returns the calculated shipping price.

=head3 $xmlData

Processed data from an XML rate request, as a perl data structure.  The data is expected to
have this structure:

    {
        RatedShipment => {
            TotalCharges => {
                MonetaryValue => xx.yy
            }
        }
    }

=cut

sub _calculateFromXML {
    my ($self, $xmlData) = @_;
    ##Additional error checking on the XML data can be done in here.  Or, in the future,
    ##individual elements of the cost can be parsed and returned.
    return $xmlData->{RatedShipment}->{TotalCharges}->{MonetaryValue};
}

#-------------------------------------------------------------------

=head2 definition ( $session )

This subroutine returns an arrayref of hashrefs, used to validate data put into
the object by the user, and to automatically generate the edit form to show
the user.

=cut

sub definition {
    my $class      = shift;
    my $session    = shift;
    WebGUI::Error::InvalidParam->throw(error => q{Must provide a session variable})
        unless ref $session eq 'WebGUI::Session';
    my $definition = shift || [];
    my $i18n = WebGUI::International->new($session, 'ShipDriver_UPS');

    tie my %shippingTypes, 'Tie::IxHash';
    ##Other shipping types can be added below, but also need to be handled by the
    ##javascript.
    $shippingTypes{'us domestic'}      = $i18n->get('us domestic');
    $shippingTypes{'us international'} = $i18n->get('us international');

    tie my %shippingServices, 'Tie::IxHash';
    ##Note, these keys are required XML keywords in the UPS XML API.
    ##It needs a one of every key, regardless of the correct label.
    ##The right set of options is set via JavaScript in the form.
    $shippingServices{'01'} = $i18n->get('us domestic 01');
    $shippingServices{'02'} = $i18n->get('us domestic 02');
    $shippingServices{'03'} = $i18n->get('us domestic 03');
    $shippingServices{'07'} = $i18n->get('us international 07');
    $shippingServices{'08'} = $i18n->get('us international 08');
    $shippingServices{'11'} = $i18n->get('us international 11');
    $shippingServices{'12'} = $i18n->get('us domestic 12');
    $shippingServices{'13'} = $i18n->get('us domestic 13');
    $shippingServices{'14'} = $i18n->get('us domestic 14');
    $shippingServices{'54'} = $i18n->get('us international 54');
    $shippingServices{'59'} = $i18n->get('us domestic 59');
    $shippingServices{'65'} = $i18n->get('us international 65');

    tie my %pickupTypes, 'Tie::IxHash';
    ##Note, these keys are required XML keywords in the UPS XML API.
    $pickupTypes{'01'} = $i18n->get('pickup code 01');
    $pickupTypes{'03'} = $i18n->get('pickup code 03');
    $pickupTypes{'06'} = $i18n->get('pickup code 06');
    $pickupTypes{'07'} = $i18n->get('pickup code 07');
    $pickupTypes{'11'} = $i18n->get('pickup code 11');
    $pickupTypes{'19'} = $i18n->get('pickup code 19');
    $pickupTypes{'20'} = $i18n->get('pickup code 20');

    tie my %customerClassification, 'Tie::IxHash';
    ##Note, these keys are required XML keywords in the UPS XML API.
    $customerClassification{'01'} = $i18n->get('customer classification 01');
    $customerClassification{'03'} = $i18n->get('customer classification 03');
    $customerClassification{'04'} = $i18n->get('customer classification 04');

    my $localizedCountries = Locales::Country->new('en'); ##Note, for future i18n change the locale
    tie my %localizedCountries, 'Tie::IxHash';
    %localizedCountries = map { $_ => $_ } grep { !ref $_ } $localizedCountries->all_country_names();

    tie my %fields, 'Tie::IxHash';
    %fields = (
        instructions => {
            fieldType     => 'readOnly',
            label         => $i18n->get('instructions'),
            defaultValue  => $i18n->get('ups instructions'),
            noFormProcess => 1,
        },
        userId => {
            fieldType    => 'text',
            label        => $i18n->get('userid'),
            hoverHelp    => $i18n->get('userid help'),
            defaultValue => '',
        },
        password => {
            fieldType    => 'password',
            label        => $i18n->get('password'),
            hoverHelp    => $i18n->get('password help'),
            defaultValue => '',
        },
        licenseNo => {
            fieldType    => 'text',
            label        => $i18n->get('license'),
            hoverHelp    => $i18n->get('license help'),
            defaultValue => '',
        },
        sourceZip => {
            fieldType    => 'zipcode',
            label        => $i18n->get('source zipcode'),
            hoverHelp    => $i18n->get('source zipcode help'),
            defaultValue => '',
        },
        sourceCountry => {
            fieldType    => 'selectBox',
            label        => $i18n->get('source country'),
            hoverHelp    => $i18n->get('source country help'),
            options      => \%localizedCountries,
            defaultValue => 'US',
        },
        shipType => {
            fieldType    => 'selectBox',
            label        => $i18n->get('ship type'),
            hoverHelp    => $i18n->get('ship type help'),
            options      => \%shippingTypes,
            defaultValue => 'us domestic',
            extras       => q{onchange="WebGUI.ShipDriver.UPS.changeServices(this.options[this.selectedIndex].value,'shipService_formId')"},
        },
        shipService => {
            fieldType    => 'selectBox',
            label        => $i18n->get('ship service'),
            hoverHelp    => $i18n->get('ship service help'),
            options      => \%shippingServices,
            defaultValue => '03',
        },
        pickupType => {
            fieldType    => 'selectBox',
            label        => $i18n->get('pickup type'),
            hoverHelp    => $i18n->get('pickup type help'),
            options      => \%pickupTypes,
            defaultValue => '01',
        },
        customerClassification => {
            fieldType    => 'selectBox',
            label        => $i18n->get('customer classification'),
            hoverHelp    => $i18n->get('customer classification help'),
            options      => \%customerClassification,
            defaultValue => '01',
        },
        residentialIndicator => {
            fieldType    => 'radioList',
            label        => $i18n->get('residential'),
            hoverHelp    => $i18n->get('residential help'),
            options      => {
                residential => $i18n->get('residential'),
                commercial  => $i18n->get('commercial'),
            },
            defaultValue => 'commercial',
        },
##Note, if a flat fee is added to this driver, then according to the license
##terms the website must display a note to the user (shop customer) that additional
##fees have been added.
#        flatFee => {
#            fieldType    => 'float',
#            label        => $i18n->get('flatFee'),
#            hoverHelp    => $i18n->get('flatFee help'),
#            defaultValue => 0,
#        },
    );
    my %properties = (
        name        => 'UPS',
        properties  => \%fields,
    );
    push @{ $definition }, \%properties;
    return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 _doXmlRequest ( $xml )

Contact the UPS website and submit the XML for a shipping rate lookup.
Returns a LWP::UserAgent response object.

=head3 $xml

XML to send.  It has some very high standards, including XML components in
the right order and sets of allowed tags.

=cut

sub _doXmlRequest {
    my ($self, $xml) = @_;
    my $userAgent = LWP::UserAgent->new;
    $userAgent->env_proxy;
    $userAgent->agent('WebGUI');
    #
    my $url;
    if ($self->testMode) {
        $url = 'https://wwwcie.ups.com/ups.app/xml/Rate';
    }
    else {
        $url = 'https://wwwcie.ups.com/ups.app/xml/Rate';
    }
    my $request = HTTP::Request->new(POST => $url);
	$request->content_type( 'text/xml' );
	$request->content( $xml );

    my $response = $userAgent->request($request);
    return $response;
}

#-------------------------------------------------------------------

=head2 getEditForm ( )

Override the master method to stuff in some javascript.

=cut

sub getEditForm {
    my $self = shift;
    $self->session->style->setScript(
        $self->session->url->extras('yui/build/utilities/utilities.js'),
        { type => 'text/javascript', },
    );
    $self->session->style->setScript(
        $self->session->url->extras('yui/build/yahoo-dom-event/yahoo-dom-event.js'),
        { type => 'text/javascript', },
    );
    $self->session->style->setScript(
        $self->session->url->extras('yui/build/json/json-min.js'),
        { type => 'text/javascript', },
    );
    $self->session->style->setScript(
        $self->session->url->extras('yui-webgui/build/i18n/i18n.js'),
        { type => 'text/javascript', },
    );
    $self->session->style->setScript(
        $self->session->url->extras('yui-webgui/build/ShipDriver/UPS.js'),
        { type => 'text/javascript', },
    );
    $self->session->style->setRawHeadTags(<<EOL);
<script type="text/javascript">
    YAHOO.util.Event.onDOMReady( WebGUI.ShipDriver.UPS.initI18n );
</script>
EOL
    return $self->SUPER::getEditForm();
}

#-------------------------------------------------------------------

=head2 _getShippableUnits ( $cart )

This is a private method.

Sorts items into the cart by how they must be shipped; together, separate,
etc, following these rules:

=over 4

=item *

Each item which ships separately is 1 shippable unit. 

=item *

All loose items are bundled together by zip code.

=back

This method returns a 

For an empty cart (which shouldn't ever happen), it would return an empty array.

=head3 $cart

A WebGUI::Shop::Cart object.  It provides access to the items in the cart
that must be sorted.

=cut

sub _getShippableUnits {
    my ($self, $cart) = @_;
    ##All units sorted by zip code.  Loose units kept separately so they
    ##can be easily bundled together by zip code.
    my %shippableUnits = ();
    my %looseUnits = ();
    ITEM: foreach my $item (@{$cart->getItems}) {
        my $sku = $item->getSku;
        next ITEM unless $sku->isShippingRequired;
        my $zip = $item->getShippingAddress->get('code');
        if ($sku->shipsSeparately) {
            push @{ $shippableUnits{$zip} }, ( [ $item ] ) x $item->get('quantity');
        }
        else {
            push @{ $looseUnits{$zip} }, $item;
        }
    }
    ##Merge the two together now
    while (my ($zip, $units) = each %looseUnits) {
        push @{ $shippableUnits{$zip} }, $units;
    }
    return values %shippableUnits;
}

1;
