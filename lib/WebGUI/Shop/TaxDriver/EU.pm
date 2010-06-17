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
use WebGUI::International;

use Business::Tax::VAT::Validation;
use JSON qw{ to_json };
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
    my $i18n            = WebGUI::International->new( $self->session, 'TaxDriver_EU' );

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
        return $i18n->get('vat number invalid');
    }

    # Write the code to the db.
    $db->write( 'replace into tax_eu_vatNumbers (userId,countryCode,vatNumber,viesValidated,viesErrorCode,approved) values (?,?,?,?,?,?)', [
        $user->userId,
        substr( $number, 0 , 2 ),
        $number,
        $numberIsValid ? 1 : 0,
        $numberIsValid ? undef : $validator->get_last_error_code,
        0,
    ] );

    return $numberIsValid ? undef : $i18n->get('vies unavailable');
}

#-------------------------------------------------------------------

=head2 appendCartItemVars ( var, cartItem )

See WebGUI::Shop::TaxDriver->appendCartItemVars.

Additionally adds VAT number to var.

=cut

sub appendCartItemVars {
    my $self    = shift;
    my $var     = shift;
    my $item    = shift;

    $self->SUPER::appendCartItemVars( $var, $item );

    my $address = eval { $item->getShippingAddress };
    unless ( WebGUI::Error->caught ) {
        my $countryCode = $self->getCountryCode( $address->get( 'country' ) );
        if ( $countryCode && $self->hasVATNumber( $countryCode ) ) {
            $var->{ VATNumber } = $self->getVATNumbers( $countryCode )->[0]->{ vatNumber };
        }
    }

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
    my $i18n    = WebGUI::International->new( $session, 'TaxDriver_EU' );

    my $taxGroups = $self->get( 'taxGroups' ) || [];

    tie my %countryOptions, 'Tie::IxHash', (
        ''  => ' - ' . $i18n->get('select country') . ' - ',
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
        label       => $i18n->get('shop country'),
        hoverHelp   => $i18n->get('shop country help'),
        options     => \%countryOptions,
    );
    $f->template(
        name        => 'userTemplateId',
        value       => $self->get('userTemplateId'),
        label       => $i18n->get('user template'),
        hoverHelp   => $i18n->get('user template help'), 
        namespace   => 'TaxDriver/EU/User',
    );
    $f->yesNo(
        name        => 'automaticViesApproval',
        value       => $self->get('automaticViesApproval'),
        label       => $i18n->get('auto vies approval'),
        hoverHelp   => $i18n->get('auto vies approval help'),
    );
    $f->yesNo(
        name        => 'acceptOnViesUnavailable',
        value       => $self->get('acceptOnViesUnavailable'),
        label       => $i18n->get('accept when vies unavailable'),
        hoverHelp   => $i18n->get('accept when vies unavailable help'),
    );

    $f->submit;
    my $general = $f->print;

    # VAT groups manager
    my $vatGroups = 
        '<b>' . $i18n->get('add vat group') . '</b>'
        . WebGUI::Form::formHeader( $session, { extras => 'id="addGroupForm"' } )
        . WebGUI::Form::hidden( $session, { name => 'shop',     value => 'tax' } )
        . WebGUI::Form::hidden( $session, { name => 'method',   value => 'do' } )
        . WebGUI::Form::hidden( $session, { name => 'do',       value => 'addGroup' } )
        . $i18n->get('group name')
        . WebGUI::Form::text(   $session, { name => 'name' } )
        . $i18n->get('rate')
        . WebGUI::Form::float(  $session, { name => 'rate' } )
        . '%'
        . WebGUI::Form::submit( $session, { value => 'Add' } )
        . WebGUI::Form::formFooter( $session );

    # Wrap output in a YUI Tab widget.
    my ($style, $url) = $session->quick( qw{ style url } );
	$style->setLink($self->{_css},{rel=>"stylesheet", rel=>"stylesheet",type=>"text/css"});
	$style->setLink($url->extras('/yui/build/fonts/fonts-min.css'),{type=>"text/css", rel=>"stylesheet"});
	$style->setLink($url->extras('/yui/build/tabview/assets/skins/sam/tabview.css'),{type=>"text/css", rel=>"stylesheet"});
	$style->setLink($url->extras('/yui/build/button/assets/skins/sam/button.css'),{type=>"text/css", rel=>"stylesheet"});
    $style->setLink($url->extras('/yui/build/container/assets/container.css'),{ type=>'text/css', rel=>"stylesheet" });
    $style->setLink($url->extras('/hoverhelp.css'),{ type=>'text/css', rel=>"stylesheet" });
    $style->setLink($url->extras('yui/build/datatable/assets/skins/sam/datatable.css'), {rel=>'stylesheet', type => 'text/CSS'});
    $style->setScript($url->extras('/yui/build/utilities/utilities.js'),{ type=>'text/javascript' });
    $style->setScript($url->extras('/yui/build/container/container-min.js'),{ type=>'text/javascript' });
    $style->setScript($url->extras('/yui/build/tabview/tabview-min.js'),{ type=>'text/javascript' });
    $style->setScript($url->extras('/hoverhelp.js'),{ type=>'text/javascript' });
    $style->setScript($url->extras('yui/build/datasource/datasource-min.js'), {type => 'text/javascript'});
    $style->setScript($url->extras('yui/build/datatable/datatable-min.js'), {type => 'text/javascript'});
    $style->setScript($url->extras('yui/build/button/button-min.js'), {type => 'text/javascript'});
   
    my $generalLabel    = $i18n->get('general configuration');
    my $groupsLabel     = $i18n->get('vat groups');
    my $numbersLabel    = $i18n->get('vat numbers');
    my $output = <<EOHTML;
        <div class="yui-skin-sam">
            <div id="webguiTabForm" class="yui-navset">
                <ul class="yui-nav">
                    <li class="selected"><a href="#tab1" ><em>$generalLabel</em></a></li>
                    <li><a href="#tab2" ><em>$groupsLabel</em></a></li>
                    <li><a href="#tab3"><em>$numbersLabel</em></a></li>
                </ul>
                <div class="yui-content">
                    <div id="tab1">$general</div>
                    <div id="tab2">
                        <div id="taxGroupTable"></div>
                        <div id="addGroup">$vatGroups</div>
                    </div>
                    <div id="tab3">
                        <div id="vatNumberManager"></div>
                    </div>
                </div>
            </div>
        </div>
        <script type="text/javascript"> var tabView = new YAHOO.widget.TabView('webguiTabForm'); </script> 
EOHTML

    # labels
    my $groupNameLabel  = $i18n->get('group name');
    my $groupRateLabel  = $i18n->get('rate');
    my $defaultLabel    = $i18n->get('default group');
    my $makeDefaultLabel= $i18n->get('make default');
    my $deleteLabel     = $i18n->get('delete group');
    my $userLabel       = $i18n->get('user');
    my $vatNumberLabel  = $i18n->get('vat number');
    my $validatedLabel  = $i18n->get('vies validated');
    my $viesErrorLabel  = $i18n->get('vies error code');
    my $approveLabel    = $i18n->get('approve');
    my $denyLabel       = $i18n->get('deny');

    # urls
    my $getTaxGroupsUrl     = $url->page( 'shop=tax;method=do;do=getTaxGroupsAsJSON'    );
    my $getVATNumbersUrl    = $url->page( 'shop=tax;method=do;do=getVATNumbersAsJSON'   );

    $output .= qq|
        <script type="text/javascript">
        var beehhh = function() {
            // Column definitions
            var groupColumDefs = [ // sortable:true enables sorting
                { key: 'name',      label:'$groupNameLabel',    sortable: true },
                { key: 'rate',      label:'$groupRateLabel',    sortable: true },
                { key: 'isDefault', label:'',                   sortable: false, formatter : 'formatMakeDefaultButton'  },
                { key: 'deleteUrl', label:'',                   sortable: false, formatter : 'formatDeleteButton'       }
            ];

            // DataSource instance
            var groupDS = new YAHOO.util.DataSource( '$getTaxGroupsUrl' );
            groupDS.responseType = YAHOO.util.DataSource.TYPE_JSON;
            groupDS.responseSchema = {
                resultsList: "records",
                fields: [
                    { key : "name",      parser : "string"  },
                    { key : "rate",      parser : "string"  },
                    { key : "isDefault", parser : "string"  },
                    { key : "deleteUrl"                     },
                    { key : 'setDefaultUrl'                 },
                    { key : 'id'                            }
                ]
            };
            
            // DataTable configuration
            var myConfigs = {
                // dynamicData : true, // Enables dynamic server-driven data
            };
            
            // DataTable instance
            var groupDT = new YAHOO.widget.DataTable( 'taxGroupTable', groupColumDefs, groupDS, myConfigs );
        
            var reloadTable = function ( dt ) {
                dt.getDataSource().sendRequest( '', { 
                    success     : dt.onDataReturnInitializeTable,
                    scope       : dt
                } );
            };

            var reloadGroupDT = function () { reloadTable( groupDT ) };

            YAHOO.widget.DataTable.Formatter.formatMakeDefaultButton = function (elCell, oRecord, oColumn, oData) {
                if ( oRecord.getData('isDefault') === '1' ) {
                    elCell.innerHTML = '$defaultLabel';
                }
                else {
                    var button  = new YAHOO.widget.Button( { label : '$makeDefaultLabel', container: elCell } );
                    button.addListener( 'click', function () {
                        YAHOO.util.Connect.asyncRequest( 'GET', oRecord.getData('setDefaultUrl'), { success : reloadGroupDT } );
                    } );
                }
            }

            YAHOO.widget.DataTable.Formatter.formatDeleteButton = function (elCell, oRecord, oColumn, oData) {
                var datatable = this;

                var button = new YAHOO.widget.Button( { label : '$deleteLabel', container: elCell } );
                button.addListener( 'click', function () {
                    YAHOO.util.Connect.asyncRequest( 'GET', oRecord.getData('deleteUrl'), { success : reloadGroupDT } );
                } );
                    
            }
        
            YAHOO.util.Event.addListener( 'addGroupForm', 'submit', function ( e ) {
                YAHOO.util.Event.stopEvent( e );
                YAHOO.util.Connect.setForm( 'addGroupForm' );
                YAHOO.util.Connect.asyncRequest( 'POST', this.action, { success : reloadGroupDT } );
                this.reset();
            } );
            
            //===============================================================
            //===============================================================
            //===============================================================

            var vatColumDefs = [
                { key: "username",      label : '$userLabel',      sortable : true, formatter : 'formatUsername' },
                { key: "vatNumber",     label : '$vatNumberLabel', sortable : true  },
                { key: "viesValidated", label : '$validatedLabel', sortable : true  },
                { key: "viesErrorCode", label : '$viesErrorLabel', sortable : false },
                { key: "approvebutton", label : '', formatter : 'formatApproveButton' },
                { key: "denyButton",    label : '', formatter : 'formatDenyButton'    }
            ];

            var vatDS = new YAHOO.util.DataSource( '$getVATNumbersUrl' );
            vatDS.responseType = YAHOO.util.DataSource.TYPE_JSON;
            vatDS.responseSchema = {
                resultsList: "records",
                fields: [
                    { key : "userId",           parser : "string" },
                    { key : "vatNumber",        parser : "string" },
                    { key : "viesValidated",    parser : "string" },
                    { key : "viesErrorCode" },
                    { key : "approveUrl" },
                    { key : "denyUrl" },
                    { key : "username" },
                    { key : "manageUserUrl" }
                ]
            };
            
            // DataTable configuration
            
            // DataTable instance
            var vatDT = new YAHOO.widget.DataTable("vatNumberManager", vatColumDefs, vatDS, myConfigs);

            var reloadVatDT = function () { reloadTable( vatDT ) };

            YAHOO.widget.DataTable.Formatter.formatUsername = function (elCell, oRecord, oColumn, oData) {
                elCell.innerHTML = 
                    '<a href="' + oRecord.getData('manageUserUrl') + '" alt="User id ' + oRecord.getData('userId') + '">'
                    + oRecord.getData('username')
                    + '</a>';
            }


            YAHOO.widget.DataTable.Formatter.formatApproveButton = function (elCell, oRecord, oColumn, oData) {
                var datatable = this;

                var button = new YAHOO.widget.Button( { label : '$approveLabel', container: elCell } );
                button.addListener( 'click', function () {
                    YAHOO.util.Connect.asyncRequest( 'GET', oRecord.getData('approveUrl'), { success : reloadVatDT } );
                } );                    
            }

            YAHOO.widget.DataTable.Formatter.formatDenyButton = function (elCell, oRecord, oColumn, oData) {
                var datatable = this;

                var button = new YAHOO.widget.Button( { label : '$denyLabel', container: elCell } );
                button.addListener( 'click', function () {
                    YAHOO.util.Connect.asyncRequest( 'GET', oRecord.getData('denyUrl'), { success : reloadVatDT } );
                } );
            }


        }();
    </script>
    |;

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
    my $var     = {};
    my $i18n    = WebGUI::International->new( $self->session, 'TaxDriver_EU' );
   
    $var->{ errorMessage } = $self->session->stow->get( 'userTaxError' );

    my @vatNumbers;
    foreach my $number ( @{ $self->getVATNumbers } ) {
        $number->{ deleteUrl    } = 
            $url->page('shop=tax;method=do;do=deleteVATNumber;vatNumber='.$number->{ vatNumber });
        $number->{ countryName  } = $self->getCountryName( $number->{ countryCode } ),
        $number->{ isUsable     } = $self->isUsableVATNumber( $number ),

        push @vatNumbers, $number;
    }

    $var->{ vatNumber_loop } = \@vatNumbers;

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
        label   => $i18n->get('vat number'),
    );
    $f->submit(
        value   => $i18n->get('add'),
    );

    $var->{ addVatNumber_form } = $f->print;

    my $template = WebGUI::Asset::Template->new( $self->session, $self->get('userTemplateId') );

    return $template->process( $var );
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

    return $self->isUsableVATNumber( $numbers->[0] );
}

#-------------------------------------------------------------------

=head2 isUsableVATNumber ( number ) 

Returns a boolean whether or not the given number can be used within the constraints set by the admin.

=head3 number

Hashref containing at least the keys 'approved', 'viesValidated' and 'viesErrorCode'. Usually this is just the
quickHashRef result for the row in the db corresponding to the number.

=cut

sub isUsableVATNumber {
    my $self = shift;
    my $vat  = shift;

    return 1 if $vat->{ approved };
    return 1 if $vat->{ viesValidated }         && $self->get('automaticViesApproval');
    return 1 if $vat->{ viesErrorCode } > 16    && $self->get('acceptOnViesUnavailable');
    return 0;
}

#-------------------------------------------------------------------

=head2 skuFormDefinition ( )

Returns a hash ref containing the form definition for the per sku options for this tax driver.

=cut

sub skuFormDefinition {
    my $self = shift;
    my $i18n = WebGUI::International->new( $self->session, 'TaxDriver_EU' );
    my $taxGroups = $self->get( 'taxGroups' );

    # If no tax groups are defined there's no need to add a form element.
    return {} unless $taxGroups;

    my %options = 
        map { $_->{ id } => "$_->{ name } ($_->{ rate } \%)" }
            @{ $taxGroups };
        
    tie my %definition, 'Tie::IxHash', (
        taxGroup => {
            fieldType   => 'selectBox',
            label       => $i18n->get('vat group'),
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
    my $i18n        = WebGUI::International->new( $session, 'TaxDriver_EU' );

    return $session->privilege->insufficient if $session->user->isVisitor;

    my $vatNumber              = uc $form->process( 'vatNumber' );
    my ($countryCode, $number) = $vatNumber =~ m/^([A-Z]{2})([A-Z0-9]+)$/;    

    my $errorMessage;
    $errorMessage = $i18n->get('illegal country code')      unless isIn( $countryCode, keys %EU_COUNTRIES );
    $errorMessage = $i18n->get('already has vat number')    if     @{ $self->getVATNumbers( $countryCode ) };
    $errorMessage = $self->addVATNumber( $vatNumber )       unless $errorMessage;

    $self->session->stow->set( 'userTaxError', $errorMessage );

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

=head2 www_getTaxGroupsAsJSON ( )

Returns a JSON string containg all VAT groups and their properties.

=cut

sub www_getTaxGroupsAsJSON {
    my $self = shift;
    my $url  = $self->session->url;

    return $self->session->privilege->insufficient unless $self->canManage;

    my $taxGroups = $self->get('taxGroups') || [];

    foreach my $group ( @{ $taxGroups} ) {
        my $id = $group->{ id };

        $group->{ deleteUrl     } = $url->page( 'shop=tax;method=do;do=deleteGroup;groupId=' .     $id );
        $group->{ setDefaultUrl } = $url->page( 'shop=tax;method=do;do=setDefaultGroup;groupId=' . $id );
        $group->{ isDefault     } = 1 if $id eq $self->get( 'defaultGroup' );
    }

    $self->session->http->setMimeType( 'application/json' );
    return to_json( { records => $taxGroups  } );
}

#-------------------------------------------------------------------

=head2 www_approveVatNumber ( )

Approves a VAT number.

=cut

sub www_approveVatNumber {
    my $self = shift;
    my ($db, $form) = $self->session->quick( 'db', 'form' );

    return $self->session->privilege->insufficient unless $self->canManage;

    $db->write( 'update tax_eu_vatNumbers set approved = ? where vatNumber=? and userId=?', [
        '1',
        $form->process('number'),
        $form->process('userId'),
    ] );

    return '';
}

#-------------------------------------------------------------------

=head2 www_denyVatNumber ( )

Rejects and deletes a VAT number.

=cut

sub www_denyVatNumber {
    my $self = shift;
    my ($db, $form) = $self->session->quick( 'db', 'form' );

    return $self->session->privilege->insufficient unless $self->canManage;

    $db->write( 'delete from tax_eu_vatNumbers where vatNumber=? and userId=?', [
        $form->process('number'),
        $form->process('userId'),
    ] );

    return '';
}

#-------------------------------------------------------------------

=head2 www_getVATNumbersAsJSON ( )

Returns a JSON string containing all non-approved VAT numbers and their properties.

=cut

sub www_getVATNumbersAsJSON {
    my $self = shift;
    my ($db, $url)   = $self->session->quick( 'db', 'url') ;


    return $self->session->privilege->insufficient unless $self->canManage;

    my $sth = $db->read( 
        'select username, t1.* from tax_eu_vatNumbers as t1, users as t2 where t1.userId=t2.userId and approved <> 1 order by userId' 
    );
    
    my @numbers;
    while (my $number = $sth->hashRef ) {
        $number->{ manageUserUrl } =
            $url->page( 'op=editUser;uid=' . $number->{ userId } );
        $number->{ approveUrl } = 
            $url->page( 'shop=tax;method=do;do=approveVatNumber;number='.$number->{ vatNumber }.';userId='.$number->{ userId } );
        $number->{ denyUrl } = 
            $url->page( 'shop=tax;method=do;do=denyVatNumber;number='.$number->{ vatNumber }.';userId='.$number->{ userId } );
        push @numbers, $number;
    }

    $self->session->http->setMimeType( 'application/json' );
    return to_json( { records => \@numbers } );
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
        shopCountry             => $form->process( 'shopCountry',               'selectBox' ),
        automaticViesApproval   => $form->process( 'automaticViesApproval',     'yesNo'     ),
        acceptOnViesUnavailable => $form->process( 'acceptOnViesUnavailable',   'yesNo'     ),
        userTemplateId          => $form->process( 'userTemplateId',            'template'  ),
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

