package WebGUI::Shop::ShipDriver::USPS;

use strict;
use base qw/WebGUI::Shop::ShipDriver/;
use WebGUI::Exception;
use XML::Simple;
use LWP;
use Tie::IxHash;
use Data::Dumper;

=head1 NAME

Package WebGUI::Shop::ShipDriver::USPS

=head1 DESCRIPTION

Shipping driver for the United States Postal Service, domestic shipping services.

=head1 SYNOPSIS

=head1 METHODS

See the master class, WebGUI::Shop::ShipDriver for information about
base methods.  These methods are customized in this class:

=cut

#-------------------------------------------------------------------

=head2 buildXML ( $cart, @packages )

Returns XML for submitting to the US Postal Service servers

=head3 $cart

A WebGUI::Shop::Cart object.  This allows us access to the user's
address book

=head3 @packages

An array of array references.  Each array element is 1 set of items.  The
quantity of items will vary in each set.  If the quantity of an item
is more than 1, then we will check for shipping 1 item, and multiple the
result by the quantity, rather than doing several identical checks.

=cut

sub buildXML {
    my ($self, $cart, @packages) = @_;
    tie my %xmlHash, 'Tie::IxHash';
    %xmlHash = ( RateV3Request => {}, );
    my $xmlTop = $xmlHash{RateV3Request};
    $xmlTop->{USERID}  = $self->get('userId');
    $xmlTop->{Package} = [];
    ##Do a request for each package.
    my $packageIndex;
    my $shipType = $self->get('shipType');
    my $service  = $shipType eq 'PRIORITY VARIABLE' ? 'PRIORITY'
                 : $shipType;
    PACKAGE: for(my $packageIndex = 0; $packageIndex < scalar @packages; $packageIndex++) {
        my $package = $packages[$packageIndex];
        next PACKAGE unless scalar @{ $package };
        tie my %packageData, 'Tie::IxHash';
        my $weight = 0;
        foreach my $item (@{ $package }) {
            my $sku = $item->getSku;
            my $itemWeight = $sku->getWeight();
            ##Items that ship separately with a quantity > 1 are rate estimated as 1 item and then the
            ##shipping cost is multiplied by the quantity.
            if (! $sku->shipsSeparately ) {
                $itemWeight *= $item->get('quantity');
            }
            $weight += $itemWeight;
        }
        my $pounds = int($weight);
        my $ounces = int(16 * ($weight - $pounds));
        my $destination = $package->[0]->getShippingAddress;
        my $destZipCode = $destination->get('code');
        $packageData{ID}              = $packageIndex;
        $packageData{Service}         = [ $service                ];
        $packageData{ZipOrigination}  = [ $self->get('sourceZip') ];
        $packageData{ZipDestination}  = [ $destZipCode            ];
        $packageData{Pounds}          = [ $pounds                 ];
        $packageData{Ounces}          = [ $ounces                 ];
        if ($shipType eq 'PRIORITY') {
            $packageData{Container}   = [ 'FLAT RATE BOX'         ];
        }
        elsif ($shipType eq 'PRIORITY VARIABLE') {
            #$packageData{Container}   = [ 'VARIABLE'           ];
        }
        $packageData{Size}            = [ 'REGULAR'               ];
        $packageData{Machinable}      = [ 'true'                  ];
        push @{ $xmlTop->{Package} }, \%packageData;
    }
    my $xml = XMLout(\%xmlHash,
        KeepRoot    => 1,
        NoSort      => 1,
        NoIndent    => 1,
        KeyAttr     => {
            Package       => 'ID',
        },
        SuppressEmpty => 0,
    );
    return $xml;
}


#-------------------------------------------------------------------

=head2 calculate ( $cart )

Returns a shipping price.

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
    if (! $self->get('userId')) {
        WebGUI::Error::InvalidParam->throw(error => q{Driver configured without a USPS userId.});
    }
    if ($cart->getShippingAddress->get('country') ne 'United States') {
        WebGUI::Error::InvalidParam->throw(error => q{Driver only handles domestic shipping});
    }
    my $cost = 0;
    ##Sort the items into shippable bundles.
    my @shippableUnits = $self->_getShippableUnits($cart);
    my $packageCount = scalar @shippableUnits;
    if ($packageCount > 25) {
        WebGUI::Error::InvalidParam->throw(error => q{Cannot do USPS lookups for more than 25 items.});
    }
    my $anyShippable = $packageCount > 0 ? 1 : 0;
    return $cost unless $anyShippable;
    #$cost = scalar @shippableUnits * $self->get('flatFee');
    ##Build XML ($cart, @shippableUnits)
    my $xml = $self->buildXML($cart, @shippableUnits);
    ##Do request ($xml)
    my $response = $self->_doXmlRequest($xml);
    ##Error handling
    if (! $response->is_success) {
        WebGUI::Error::Shop::RemoteShippingRate->throw(error => 'Problem connecting to USPS Web Tools: '. $response->status_line);
    }
    my $returnedXML = $response->content;
    my $xmlData     = XMLin($returnedXML, KeepRoot => 1, ForceArray => [qw/Package/]);
    if (exists $xmlData->{Error}) {
        WebGUI::Error::Shop::RemoteShippingRate->throw(error => 'Problem with USPS Web Tools XML: '. $xmlData->{Error}->{Description});
    }
    ##Summarize costs from returned data
    $cost = $self->_calculateFromXML($xmlData, @shippableUnits);
    $cost += $self->_calculateInsurance(@shippableUnits);
    return $cost;
}

#-------------------------------------------------------------------

=head2 _calculateFromXML ( $xmlData, @shippableUnits )

Takes data from the USPS and returns the calculated shipping price.

=head3 $xmlData

Processed XML data from an XML rate request, processed in perl data structure.  The data is expected to
have this structure:

    {
        RateV3Response => {
            Package => [
                {
                    ID => 0,
                    Postage => {
                        Rate => some_number
                    }
                },
            ]
        }
    }

=head3 @shippableUnits

The set of shippable units, which are required to do quantity lookups.

=cut

sub _calculateFromXML {
    my ($self, $xmlData, @shippableUnits) = @_;
    my $cost = 0;
    foreach my $package (@{ $xmlData->{RateV3Response}->{Package} }) {
        my $id   = $package->{ID};
        my $rate = $package->{Postage}->{Rate};
        ##Error check for invalid index
        if ($id < 0 || $id > $#shippableUnits) {
            WebGUI::Error::Shop::RemoteShippingRate->throw(error => "Illegal package index returned by USPS: $id");
        }
        my $unit = $shippableUnits[$id];
        if ($unit->[0]->getSku->shipsSeparately) {
            ##This is a single item due to ships separately.  Since in reality there will be
            ## N things being shipped, multiply the rate by the quantity.
            $cost += $rate * $unit->[0]->get('quantity');
        }
        else {
            ##This is a loose bundle of items, all shipped together
            $cost += $rate;
        }
    }
    return $cost;
}

#-------------------------------------------------------------------

=head2 _calculateInsurance ( @shippableUnits )

Takes data from the USPS and returns the calculated shipping price.

=head3 @shippableUnits

The set of shippable units, which are required to do quantity and cost lookups.

=cut

sub _calculateInsurance {
    my ($self, @shippableUnits) = @_;
    my $insuranceCost  = 0;
    return $insuranceCost unless $self->get('addInsurance') && $self->get('insuranceRates');
    my @insuranceTable = _parseInsuranceRates($self->get('insuranceRates'));
    ##Sort by decreasing value for easy post processing
    @insuranceTable = sort { $a->[0] <=> $b->[0] } @insuranceTable;
    foreach my $package (@shippableUnits) {
        my $value = 0;
        ITEM: foreach my $item (@{ $package }) {
            $value += $item->getSku->getPrice() * $item->get('quantity');
        }
        my $pricePoint;
        POINT: foreach my $point (@insuranceTable) {
            if ($value < $point->[0]) {
                $pricePoint = $point;
                last POINT;
            }
        }
        if (!defined $pricePoint) {
            $pricePoint = $insuranceTable[-1];
        }
        $insuranceCost += $pricePoint->[1];
    }
    return $insuranceCost;
}

#-------------------------------------------------------------------

=head2 _parseInsuranceRates ( $rates )

Take the user entered data, a string, and turn it into an array.

=head3 $rates

The rate data entered by the user.  One set of data per line.  Each line has the value of
shipment, a colon, and the cost of insuring a shipment of that value.

=cut

sub _parseInsuranceRates {
    my $rates = shift;
    $rates =~ tr/\r//d;
    my $number = qr/\d+(?:\.\d+)?/;
    my $rate   = qr{ \s* $number \s* : \s* $number \s* }x;
    return () if ($rates !~ m{ \A (?: $rate \r?\n )* $rate (?:\r\n)? \Z }x);
    my @lines = split /\n/, $rates;
    my @table = ();
    foreach my $line (@lines) {
        $line =~ s/\s+//g;
        my ($value, $cost) = split /:/, $line;
        push @table, [ $value, $cost ];
    }
    return @table;
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
    my $i18n = WebGUI::International->new($session, 'ShipDriver_USPS');
    tie my %shippingTypes, 'Tie::IxHash';
    ##Note, these keys are used by buildXML
    $shippingTypes{'PRIORITY VARIABLE'} = $i18n->get('priority variable');
    $shippingTypes{'PRIORITY'}          = $i18n->get('priority');
    $shippingTypes{'EXPRESS' }          = $i18n->get('express');
    $shippingTypes{'PARCEL'  }          = $i18n->get('parcel post');
    tie my %fields, 'Tie::IxHash';
    %fields = (
        instructions => {
            fieldType     => 'readOnly',
            label         => $i18n->get('instructions'),
            defaultValue  => $i18n->get('usps instructions'),
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
        sourceZip => {
            fieldType    => 'zipcode',
            label        => $i18n->get('source zipcode'),
            hoverHelp    => $i18n->get('source zipcode help'),
            defaultValue => '',
        },
        shipType => {
            fieldType    => 'selectBox',
            label        => $i18n->get('ship type'),
            hoverHelp    => $i18n->get('ship type help'),
            options      => \%shippingTypes,
            defaultValue => 'PARCEL',
        },
        addInsurance => {
            fieldType    => 'yesNo',
            label        => $i18n->get('add insurance'),
            hoverHelp    => $i18n->get('add insurance help'),
            defaultValue => 0,
        },
        insuranceRates => {
            fieldType    => 'textarea',
            label        => $i18n->get('insurance rates'),
            hoverHelp    => $i18n->get('insurance rates help'),
            defaultValue => "50:1.75\n100:2.25",
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
        name        => 'U.S. Postal Service',
        properties  => \%fields,
    );
    push @{ $definition }, \%properties;
    return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 _doXmlRequest ( $xml )

Contact the USPS website and submit the XML for a shipping rate lookup.
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
    my $url = 'http://production.shippingapis.com/ShippingAPI.dll?API=RateV3&XML=';
    $url .= $xml;
    my $request = HTTP::Request->new(GET => $url);
    my $response = $userAgent->request($request);
    return $response;
}

#-------------------------------------------------------------------

=head2 _getShippableUnits ( $cart )

This is a private method.

Sorts items into the cart by how they must be shipped, together, separate,
etc.  Returns an array of array references of cart items grouped by
whether or not they ship separately, and then sorted by destination
zip code.

If an item in the cart must be shipped separately, but has a quantity greater
than 1, then for the purposes of looking up shipping costs it is returned
as 1 bundle, since the total cost can now be calculated by multiplying the
quantity together with the cost for a single unit.

For an empty cart (which shouldn't ever happen), it would return an empty array.

=head3 $cart

A WebGUI::Shop::Cart object.  It provides access to the items in the cart
that must be sorted.

=cut

sub _getShippableUnits {
    my ($self, $cart) = @_;
    my @shippableUnits = ();
    ##Loose units are sorted by zip code.
    my %looseUnits = ();
    ITEM: foreach my $item (@{$cart->getItems}) {
        my $sku = $item->getSku;
        next ITEM unless $sku->isShippingRequired;
        if ($sku->shipsSeparately) {
            push @shippableUnits, [ $item ];
        }
        else {
            my $zip = $item->getShippingAddress->get('code');
            if ($item->getShippingAddress->get('country') ne 'United States') {
                WebGUI::Error::InvalidParam->throw(error => q{Driver only handles domestic shipping});
            }
            push @{ $looseUnits{$zip} }, $item;
        }
    }
    push @shippableUnits, values %looseUnits;
    return @shippableUnits;
}

1;
