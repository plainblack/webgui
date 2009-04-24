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

use base qw{ WebGUI::Shop::TaxDriver };

=head1 NAME

Package WebGUI::Shop::TaxDriver::EU

=head1 DESCRIPTION

This package manages tax information, and calculates taxes on a shopping cart specifically handling
European Union VAT taxes.

=head1 SYNOPSIS

 use WebGUI::Shop::Tax;

 my $tax = WebGUI::Shop::Tax->new($session);

=head1 METHODS

These subroutines are available from this package:

=cut

my $EU_COUNTRIES = {
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
};

#-------------------------------------------------------------------

=head2 className

Returns the name of this class.

=cut

sub className {
    return 'WebGUI::Shop::TaxDriver::EU';
}

#-----------------------------------------------------------

=head2 getConfigurationScreen ( )

Returns the form that contains the configuration options for this plugin in the admin console.

=cut

sub getConfigurationScreen {
    my $self    = shift;
    my $session = $self->session;

    my $taxGroups = $self->get( 'taxGroups' ) || [];
    
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
        options     => $EU_COUNTRIES,
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
    return { reverse %{ $EU_COUNTRIES } }->{ $countryName };
}

#-------------------------------------------------------------------

=head2 getCountryName ($countryCode)

Given a 2 character country code, return the name of the country.

=head3 $countryCode

The code of the country to look up.

=cut

sub getCountryName {
    my $self = shift;
    my $countryCode = shift;
    
    return $EU_COUNTRIES->{ $countryCode };
}

#-------------------------------------------------------------------

=head2 getGroupRate ($taxGroupId)

=head3 $taxGroupId

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

=head2 getTaxRate ( sku, [ address ] )

Returns the tax rate in percents (eg. 19 for a rate of 19%) for the given sku and shipping address.  Implements
EU VAT taxes and group rates.

=cut

sub getTaxRate {
    my $self    = shift;
    my $sku     = shift;
    my $address = shift;

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

=head2 getVATNumbers ($countryCode)

=head3 $countryCode

=cut

sub getVATNumbers {
    my $self        = shift;
    my $countryCode = shift;
    my $session     = $self->session;

    my $sql = 'select * from tax_eu_vatNumbers where userId=?';
    my $placeHolders = [ $session->user->userId ];

    if ( $countryCode ) {
        $sql .= ' and countryCode=?';
        push @{ $placeHolders }, $countryCode;
    }

    my $numbers = $session->db->buildArrayRefOfHashRefs( $sql, $placeHolders );

    return $numbers;
}

#-------------------------------------------------------------------

=head2 hasVATNumber ($countrycode)

=head3 $countryCode

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

=cut

sub www_addGroup {
    my $self = shift;
    my $form = $self->session->form;

    return $self->session->privilege->insufficient unless $self->canManage;

    my $groups  = $self->get( 'taxGroups' ) || [];
    my $name    = $form->process( 'name' );
    my $rate    = $form->process( 'rate' );
    my $id      = $self->session->id->generate;

    push @{ $groups }, {
        name    => $name,
        rate    => $rate,
        id      => $id,
    };

    $self->update( { taxGroups => $groups } );

    return '';
}

#-------------------------------------------------------------------

=head2 www_addVATNumber

=cut

sub www_addVATNumber {
    my $self        = shift;
    my $session     = $self->session;
    my ($db, $form) = $session->quick( qw{ db form } );

    return $session->privilege->insufficient if $session->user->isVisitor;

    my $vatNumber              = uc $form->process( 'vatNumber' );
    my ($countryCode, $number) = $vatNumber =~ m/^([A-Z]{2})([A-Z0-9]+)$/;    

    return 'Illegal country code' unless isIn( $countryCode, keys %{ $EU_COUNTRIES } );
 
    return 'You already have a VAT number for this country.' if @{ $self->getVATNumbers( $countryCode ) };

    # Check VAT number via SOAP interface.
    # TODO: Handle timeouts.
    my $soap    = SOAP::Lite->service('http://ec.europa.eu/taxation_customs/vies/api/checkVatPort?wsdl');
    my $isValid = ( $soap->checkVat( $countryCode, $number ) )[ 3 ] || 0;

    # Write the code to the db.
    $db->write( 'replace into tax_eu_vatNumbers (userId,countryCode,vatNumber,approved) values (?,?,?,?)', [
        $self->session->user->userId,
        $countryCode,
        $vatNumber,
        $isValid,
    ] );

    my $instance = WebGUI::Content::Account->createInstance($session,"shop");
    return $instance->displayContent( $instance->callMethod("manageTaxData", [], $session->user->userId) );
}

#-------------------------------------------------------------------

=head2 www_deleteGroup

=cut

sub www_deleteGroup {
    my $self = shift;
    my $form = $self->session->form;

    return $self->session->privilege->insufficient unless $self->canManage;

    my $taxGroups       = $self->get( 'taxGroups' );
    my $removeGroupId   = $form->process( 'groupId' );
    my @newGroups       = grep { $_->{ id } ne $removeGroupId } @{ $taxGroups };

    $self->update( { taxGroups => \@newGroups } );

    return '';
}

#-------------------------------------------------------------------

=head2 www_deleteVATNumber

=cut

sub www_deleteVATNumber {
    my $self    = shift;
    my $session = $self->session;

    return $session->privilege->insufficient unless $session->user->isVisitor;

    $session->db->write( 'delete from tax_eu_vatNumbers where userId=? and vatNumber=?', [
        $session->user->userId,
        $session->form->process( 'vatNumber' ),
    ] );

    my $instance = WebGUI::Content::Account->createInstance($session,"shop");
    return $instance->displayContent( $instance->callMethod("manageTaxData", [], $session->user->userId) );
}

#-------------------------------------------------------------------

=head2 www_saveConfiguration

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

