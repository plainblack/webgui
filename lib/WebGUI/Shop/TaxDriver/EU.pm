package WebGUI::Shop::TaxDriver::EU;

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

use SOAP::Lite;
use WebGUI::Content::Account;
use WebGUI::TabForm;
use WebGUI::Utility qw{ isIn };
use Business::Tax::VAT::Validation;
use Tie::IxHash;

use base qw{ WebGUI::Shop::TaxDriver };

=head1 NAME

Package WebGUI::Shop::TaxDriver::EU

=head1 DESCRIPTION

This package manages tax information, and calculates taxes on a shopping cart specifically handling
European Union VAT taxes. It allows you to define VAT groups (eg. in the Netherlands there are two VAT tariffs:
high (19%) and low (6%) ) that can be applied to SKU assets. 

=head1 SYNOPSIS

 use WebGUI::Shop::Tax;

 my $tax = WebGUI::Shop::Tax->new($session);

=head1 METHODS

These subroutines are available from this package:

=cut


tie my %EU_COUNTRIES, 'Tie::IxHash', (
    AT => 'Austria',
    BE => 'Belgium',
    BG => 'Bulgaria',
    CY => 'Cyprus',
    CZ => 'Czech Republic',
    DE => 'Germany',
    DK => 'Denmark',
    EE => 'Estonia',
    EL => 'Greece',
    ES => 'Spain',
    FI => 'Finland',
    FR => 'France ',
    GB => 'United Kingdom',
    HU => 'Hungary',
    IE => 'Ireland',
    IT => 'Italy',
    LT => 'Lithuania',
    LU => 'Luxembourg',
    LV => 'Latvia',
    MT => 'Malta',
    NL => 'Netherlands',
    PL => 'Poland',
    PT => 'Portugal',
    RO => 'Romania',
    SE => 'Sweden',
    SI => 'Slovenia',
    SK => 'Slovakia',
);

#-------------------------------------------------------------------

=head2 addGroup ( name, rate )

Adds a tax group. Returns the group id.

=head3 name

The display name of the tax group.

=head3 rate

The tax rate for this group in percents.

=cut

sub addGroup {
    my $self    = shift;
    my $name    = shift;
    my $rate    = shift;

    WebGUI::Error::InvalidParam->throw( 'A group name is required' )
        unless $name;
    WebGUI::Error::InvalidParam->throw( 'Group rate must be within 0 and 100' )
        unless defined $rate && $rate >= 0 && $rate <= 100;

    my $id      = $self->session->id->generate;
    my $groups  = $self->get( 'taxGroups' ) || [];

    push @{ $groups }, {
        name    => $name,
        rate    => $rate,
        id      => $id,
    };

    $self->update( { taxGroups => $groups } );

    return $id;
}

#-------------------------------------------------------------------

=head2 addVATNumber ( VATNumber, localCheckOnly )

Adds a VAT number to the database. Checks the number through the VIES database. Returns and error message if a
validation error occurred. If the number validates undef is returned.

=head3 VATNumber

The number that is to be added.

=head3 user

The user for which the number should be added. Defaults to the session user.

=head3 localCheckOnly

If set to a true value the the remote VAT number validation in the VIES database will not be preformed. The VAT
number will be checked against regexes, however. Mostly convenient for testing purposes. 

=cut

sub addVATNumber {
    my $self            = shift;
    my $number          = shift;
    my $user            = shift || $self->session->user; 
    my $localCheckOnly  = shift;
    my $db              = $self->session->db;

    WebGUI::Error::InvalidParam->throw( 'A VAT number is required' )
        unless $number;
    WebGUI::Error::InvalidParam->throw( 'The second argument must be an instanciated WebGUI::User object' )
        unless ref $user eq 'WebGUI::User';
    WebGUI::Error::InvalidParam->throw( 'Visitor cannot add VAT numbers' )
        if $user->isVisitor;

    # Check number
    my $validator       = Business::Tax::VAT::Validation->new;
    my $numberIsValid   = $localCheckOnly ? $validator->local_check( $number ) : $validator->check( $number );

    # Number contains syntax error does not exist. Do not write the code to the db.
    if ( !$numberIsValid && $validator->get_last_error_code <= 16 ) {
        return 'The entered VAT number is invalid.';
    }


    # Write the code to the db.
    $db->write( 'replace into tax_eu_vatNumbers (userId,countryCode,vatNumber,approved,viesErrorCode) values (?,?,?,?,?)', [
        $user->userId,
        substr( $number, 0 , 2 ),
        $number,
        $numberIsValid ? 1 : 0,
        $numberIsValid ? undef : $validator->get_last_error_code,
    ] );

    return $numberIsValid ? undef : 'Number validation currently not available. Check later.';
}

#-------------------------------------------------------------------

=head2 className

Returns the name of this class.

=cut

sub className {
    return 'WebGUI::Shop::TaxDriver::EU';
}

#-------------------------------------------------------------------

=head2 deleteGroup ( groupId )

Deletes a tax group.

=head3 groupId

The id of the tax group that is to be deleted.

=cut

sub deleteGroup {
    my $self            = shift;
    my $removeGroupId   = shift;

    WebGUI::Error::InvalidParam->throw( 'A group id is required' )
        unless $removeGroupId;

    my $taxGroups       = $self->get( 'taxGroups' );
    my @newGroups       = grep { $_->{ id } ne $removeGroupId } @{ $taxGroups };

    $self->update( { taxGroups => \@newGroups } );
}

#-----------------------------------------------------------

=head2 deleteVATNumber ( VATNumber, [ user ] )

Deletes a VAT number.

=head3 VATNumber

The VATNumber to delete.

=head3 user

The user whose VATNumber must be deleted, in the form of a WebGUI::User object.

=cut

sub deleteVATNumber {
    my $self    = shift;
    my $number  = shift;
    my $user    = shift || $self->session->user;
    my $session = $self->session;

    $session->db->write( 'delete from tax_eu_vatNumbers where userId=? and vatNumber=?', [
        $user->userId,
        $number,
    ] );
}
    
#-----------------------------------------------------------

=head2 getConfigurationScreen ( )

Returns the form that contains the configuration options for this plugin in the admin console.

=cut

sub getConfigurationScreen {
    my $self    = shift;
    my $session = $self->session;

    my $taxGroups = $self->get( 'taxGroups' ) || [];

    tie my %countryOptions, 'Tie::IxHash', (
        ''  => ' - select a country - ',
        %EU_COUNTRIES,
    );

    # General setting form
    my $f = WebGUI::HTMLForm->new( $session );
    $f->hidden(
        name        => 'shop',
        value       => 'tax',
    );
    $f->hidden(
        name        => 'method',
        value       => 'do',
    );
    $f->hidden(
        name        => 'do',
        value       => 'saveConfiguration',
    );
    $f->selectBox(
        name        => 'shopCountry',
        value       => $self->get( 'shopCountry' ),
        label       => 'Residential country',
        hoverHelp   => 'The country where your shop resides.',
        options     => \%countryOptions,
    );
    $f->submit;
    my $general = $f->print;

    # VAT groups manager
    my $vatGroups = '<b>VAT groups</b><br />';
    $vatGroups   .= q{<table><thead><tr><th>Group name</th><th>Rate</th></tr></thead><tbody>};
    foreach my $group ( @{ $taxGroups} ) {
        my $deleteUrl       = $session->url->page('shop=tax;method=do;do=deleteGroup;groupId=' . $group->{ id });
        my $makeDefaultUrl  = $session->url->page('shop=tax;method=do;do=setDefaultGroup;groupId=' . $group->{ id });

        $vatGroups .= 
            q{<tr><td>}  
            . join( '</td><td>', 
                $group->{ name } . ( $group->{ id } eq $self->get( 'defaultGroup' )  ? '<i>(default)</i>' : '' ),
                $group->{ rate },
                qq{<a href="$deleteUrl">delete</a>},
                qq{<a href="$makeDefaultUrl">Set as default group</a>},
            )
            . q{</td></tr>};
    }
    $vatGroups .= q{</tbody></table>};
    $vatGroups .= 
        WebGUI::Form::formHeader( $session )
        . WebGUI::Form::hidden( $session, { name => 'shop', value => 'tax' } )
        . WebGUI::Form::hidden( $session, { name => 'method', value => 'do' } )
        . WebGUI::Form::hidden( $session, { name => 'do', value => 'addGroup' } )
        . 'Name '
        . WebGUI::Form::text(   $session, { name => 'name' } )
        . ' Rate '
        . WebGUI::Form::float(  $session, { name => 'rate' } )
        . '%'
        . WebGUI::Form::submit( $session, { value => 'Add' } )
        . WebGUI::Form::formFooter( $session );

    # Wrap output in a YUI Tab widget.
    my ($style, $url) = $session->quick( qw{ style url } );
	$style->setLink($self->{_css},{rel=>"stylesheet", rel=>"stylesheet",type=>"text/css"});
	$style->setLink($url->extras('/yui/build/fonts/fonts-min.css'),{type=>"text/css", rel=>"stylesheet"});
	$style->setLink($url->extras('/yui/build/tabview/assets/skins/sam/tabview.css'),{type=>"text/css", rel=>"stylesheet"});
    $style->setLink($url->extras('/yui/build/container/assets/container.css'),{ type=>'text/css', rel=>"stylesheet" });
    $style->setLink($url->extras('/hoverhelp.css'),{ type=>'text/css', rel=>"stylesheet" });
    $style->setScript($url->extras('/yui/build/utilities/utilities.js'),{ type=>'text/javascript' });
    $style->setScript($url->extras('/yui/build/container/container-min.js'),{ type=>'text/javascript' });
    $style->setScript($url->extras('/yui/build/tabview/tabview-min.js'),{ type=>'text/javascript' });
    $style->setScript($url->extras('/hoverhelp.js'),{ type=>'text/javascript' });
    
    my $output = <<EOHTML;
        <div class="yui-skin-sam">
            <div id="webguiTabForm" class="yui-navset">
                <ul class="yui-nav">
                    <li class="selected"><a href="#tab1" ><em>General configuration</em></a></li>
                    <li ><a href="#tab2" ><em>VAT Groups</em></a></li>
                </ul>
                <div class="yui-content">
                    <div id="tab1">$general</div>
                    <div id="tab2">$vatGroups</div>
                </div>
            </div>
        </div>
        <script type="text/javascript"> var tabView = new YAHOO.widget.TabView('webguiTabForm'); </script> 
EOHTML

    return $output;
}

#-------------------------------------------------------------------

=head2 getCountryCode ($countryName)

Given a country name, return a 2 character country code.

=head3 $countryName

The name of the country to look up.

=cut

sub getCountryCode {
    my $self = shift;
    my $countryName = shift;

    # Do reverse lookup on eu countries hash
    return { reverse %EU_COUNTRIES }->{ $countryName };
}

#-------------------------------------------------------------------

=head2 getCountryName ( $countryCode )

Given a 2 character country code, return the name of the country.

=head3 $countryCode

The code of the country to look up.

=cut

sub getCountryName {
    my $self = shift;
    my $countryCode = shift;
    
    return $EU_COUNTRIES{ $countryCode };
}

#-------------------------------------------------------------------

=head2 getGroupRate ( $taxGroupId )

Returns the tax rate for a given tax group.

=head3 $taxGroupId

The id of the tax group whose rate should be returned.

=cut

sub getGroupRate {
    my $self        = shift;
    my $taxGroupId  = shift;

    my $taxGroups   = $self->get( 'taxGroups' );
    my ($group)     = grep { $_->{ id } eq $taxGroupId } @{ $taxGroups };

    return $group->{ rate };
}

#-------------------------------------------------------------------

=head2 getUserScreen ( )

Returns the screen for entering per user configuration for this tax driver.

=cut

sub getUserScreen {
    my $self    = shift;
    my $url     = $self->session->url;

    my $output  = '<b>VAT Numbers</b><br />'
        . '<table><thead><tr><th>Country</th><th>VAT Number</th></tr></thead><tbody>';

    foreach my $number ( @{ $self->getVATNumbers } ) {
        my $deleteUrl = $url->page('shop=tax;method=do;do=deleteVATNumber;vatNumber='.$number->{ vatNumber });
        $output .= 
            '<tr><td>'
            . join( '</td><td>', 
                $self->getCountryName( $number->{ countryCode } ),
                $number->{ vatNumber },
                $number->{ name },
                $number->{ address },
                $number->{ approved },
                qq{<a href="$deleteUrl">delete</a>},
            )
            . '</td></tr>'
            ;
    }

    $output .= '</tbody></table>';

    my $f = WebGUI::HTMLForm->new( $self->session );
    $f->hidden(
        name    => 'shop',
        value   => 'tax',
    );
    $f->hidden(
        name    => 'method',
        value   => 'do',
    );
    $f->hidden(
        name    => 'do',
        value   => 'addVATNumber',
    );
    $f->text(
        name    => 'vatNumber',
        label   => 'VAT Number',
    );
    $f->submit(
        value   => 'Add',
    );
    $output .= $f->print;

    return $output;
}

#-------------------------------------------------------------------

=head2 getTaxRate ( sku, [ address, user ] )

Returns the tax rate in percents (eg. 19 for a rate of 19%) for the given sku and shipping address.  Implements
EU VAT taxes and group rates.

=cut

sub getTaxRate {
    my $self    = shift;
    my $sku     = shift;
    my $address = shift;

    WebGUI::Error::InvalidParam->throw(error => 'Must pass in a WebGUI::Asset::Sku object')
        unless $sku && $sku->isa( 'WebGUI::Asset::Sku' );
    WebGUI::Error::InvalidParam->throw(error => 'Must pass in a WebGUI::Shop::Address object')
        if $address && !$address->isa( 'WebGUI::Shop::Address' );

    my $config  = $sku->getTaxConfiguration( $self->className );

    # Fetch the tax group from the sku. If the sku has none, use the default tax group.
    my $taxGroupId  = $config->{ taxGroup } || $self->get( 'defaultGroup' );
    my $taxRate     = $self->getGroupRate( $taxGroupId );

    # No shipping address yet. Return group tax rate.
    return $taxRate unless defined $address;

    # Shipping address outside EU? That means exporting so no VAT.
    my $country = $self->getCountryCode( $address->get( 'country' ) );
    return 0 unless defined $country;

    # Shipping address in same country as shop? Pay VAT;
    return $taxRate if $country eq $self->get('shopCountry');

    # Customer has VAT number in shipping country? Exempt from paying VAT.
    return 0 if $self->hasVATNumber( $country );

    # Customer has no VAT number and resides in EU. Pay VAT;
    return $taxRate;
}

#-------------------------------------------------------------------

=head2 getTransactionTaxData ( sku, address )

See WebGUI::Shop::TaxDriver->getTransactionTaxData.

=cut

sub getTransactionTaxData {
    my $self        = shift;
    my $sku         = shift;
    my $address     = shift;
    my $countryCode = $self->getCountryCode( $address->get( 'country' ) );

    my $config = $self->SUPER::getTransactionTaxData( $sku, $address );

    if ( ! $countryCode ) {
        $config->{ outsideEU       } = 1;
    }
    elsif ( $self->hasVATNumber( $countryCode ) ) {
        $config->{ useVATNumber    } = 1;
        $config->{ VATNumber       } = $self->getVATNumbers( $countryCode )->[0]->{ vatNumber };
    }
    else {
        $config->{ useVATNumber    } = 0;
    }

    return $config;
}


#-------------------------------------------------------------------

=head2 getVATNumbers ( $countryCode )

Returns an array ref of hash refs containing the properties of the VAT numbers a user s registered for a given
country. Returns an empty array ref if the user has no VAT numbers in the requested country.

The hash keys of interest for most people are vatNumber, which contains the actual number, and approved, which
indicates whether or not the number has been approved for use yet.

=head3 $countryCode

The two letter country code of the country the VAT numbers are requested for.

=cut

sub getVATNumbers {
    my $self        = shift;
    my $countryCode = shift;
    my $user        = shift || $self->session->user;

    my $sql = 'select * from tax_eu_vatNumbers where userId=?';
    my $placeHolders = [ $user->userId ];

    if ( $countryCode ) {
        $sql .= ' and countryCode=?';
        push @{ $placeHolders }, $countryCode;
    }

    my $numbers = $self->session->db->buildArrayRefOfHashRefs( $sql, $placeHolders );

    return $numbers;
}

#-------------------------------------------------------------------

=head2 hasVATNumber ($countrycode)

Returns a boolean indicating whether or not the user has VAT numbers registered for the given country.

=head3 $countryCode

The two letter country code of contry for which the existance of VAT numbers is requested.

=cut

sub hasVATNumber {
    my $self        = shift;
    my $countryCode = shift;

    my $numbers = $self->getVATNumbers( $countryCode );
    return 0 unless @{ $numbers };

    return $numbers->[0]->{ approved };
}

#-------------------------------------------------------------------

=head2 skuFormDefinition ( )

Returns a hash ref containing the form defintion for the per sku options for this tax driver.

=cut

sub skuFormDefinition {
    my $self = shift;

    my $taxGroups = $self->get( 'taxGroups' );

    # If no tax groups are defined there's no need to add a form element.
    return {} unless $taxGroups;

    my %options = 
        map { $_->{ id } => "$_->{ name } ($_->{ rate } \%)" }
            @{ $taxGroups };
        
    tie my %definition, 'Tie::IxHash', (
        taxGroup => {
            fieldType   => 'selectBox',
            label       => 'Tax group',
            options     => \%options,
        }
    );
        
    return \%definition;
}

#-------------------------------------------------------------------

=head2 www_addGroup

Adds a VAT group.

=cut

sub www_addGroup {
    my $self = shift;
    my $form = $self->session->form;

    return $self->session->privilege->insufficient unless $self->canManage;

    $self->addGroup( $form->process( 'name' ), $form->process( 'rate' ) );

    return '';
}

#-------------------------------------------------------------------

=head2 www_addVATNumber

Allows a user to add a VAT number. The validity of VAT numbers will be automatically checked using the VIES service
provided by the European Union. See http://ec.europa.eu/taxation_customs/vies/vieshome.do for more information
conerning the service. Please also read the disclamer information located at
http://ec.europa.eu/taxation_customs/vies/viesdisc.do.

=cut

sub www_addVATNumber {
    my $self        = shift;
    my $session     = $self->session;
    my ($db, $form) = $session->quick( qw{ db form } );

    return $session->privilege->insufficient if $session->user->isVisitor;

    my $vatNumber              = uc $form->process( 'vatNumber' );
    my ($countryCode, $number) = $vatNumber =~ m/^([A-Z]{2})([A-Z0-9]+)$/;    

    return 'Illegal country code' unless isIn( $countryCode, keys %EU_COUNTRIES );

    return 'You already have a VAT number for this country.' if @{ $self->getVATNumbers( $countryCode ) };

    #### TODO: Handle errorMessage.
    my $errorMessage = $self->addVATNumber( $vatNumber );

    my $instance = WebGUI::Content::Account->createInstance($session,"shop");
    return $instance->displayContent( $instance->callMethod("manageTaxData", [], $session->user->userId) );
}

#-------------------------------------------------------------------

=head2 www_deleteGroup

Deletes a VAT group.

=cut

sub www_deleteGroup {
    my $self = shift;
    my $form = $self->session->form;

    return $self->session->privilege->insufficient unless $self->canManage;

    $self->deleteGroup( $form->process( 'groupId' ) );

    return '';
}

#-------------------------------------------------------------------

=head2 www_deleteVATNumber

Deletes a VAT number.

=cut

sub www_deleteVATNumber {
    my $self    = shift;
    my $session = $self->session;

    return $session->privilege->insufficient if $session->user->isVisitor;

    $self->deleteVATNumber( $session->form->process( 'vatNumber' ) );
    
    my $instance = WebGUI::Content::Account->createInstance($session,"shop");
    return $instance->displayContent( $instance->callMethod("manageTaxData", [], $session->user->userId) );
}

#-------------------------------------------------------------------

=head2 www_saveConfiguration

Updates the configuration properties for this plugin, as passed by the form on the configuration screen.

=cut

sub www_saveConfiguration {
    my $self = shift;
    my $form = $self->session->form;

    return $self->session->privilege->insufficient unless $self->canManage;

    $self->update( {
        shopCountry => $form->process( 'shopCountry', 'selectBox' ),
    } );

    return '';
}

#-------------------------------------------------------------------

=head2 www_setDefaultGroup

Sets a VAT group to be used as default for SKU's that do not have a VAT group defined yet.

=cut

sub www_setDefaultGroup {
    my $self = shift;
    my $form = $self->session->form;

    return $self->session->privilege->insufficient unless $self->canManage;

    $self->update( {
        defaultGroup    => $form->process( 'groupId' ),        
    } );

    return '';
}

1;

