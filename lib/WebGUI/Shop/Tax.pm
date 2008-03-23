package WebGUI::Shop::Tax;

use strict;

use Class::InsideOut qw{ :std };
use WebGUI::Text;
use WebGUI::Storage;
use WebGUI::Exception::Shop;
use WebGUI::Shop::Admin;
use WebGUI::Shop::Cart;
use WebGUI::Shop::CartItem;
use List::Util qw{sum};

=head1 NAME

Package WebGUI::Shop::Tax

=head1 DESCRIPTION

This package manages tax information, and calculates taxes on a shopping cart.  It isn't a classic object
in that the only data it contains is a WebGUI::Session object, but it does provide several methods for
handling the information in the tax tables.

Taxes are accumulated through increasingly specific geographic information.  For example, you can
specify the sales tax for a whole country, then the additional sales tax for a state in the country,
all the way down to a single code inside of a city.

=head1 SYNOPSIS

 use WebGUI::Shop::Tax;

 my $tax = WebGUI::Shop::Tax->new($session);

=head1 METHODS

These subroutines are available from this package:

=cut

readonly session => my %session;

#-------------------------------------------------------------------

=head2 add ( [$params] )

Add tax information to the table.  Returns the taxId of the newly created tax information.  

=head3 $params

A hash ref of the geographic and rate information.  The country and taxRate parameters
must have defined values.

=head4 country

The country this tax information applies to.

=head4 state

The state this tax information applies to.  state and country together are unique.

=head4 city

The ciy this tax information applies to.  Cities are unique with state and country information.

=head4 code

The postal code this tax information applies to.  codes are unique with state and country information.

=head4 taxRate

This is the tax rate for the location, as specified by the geographical
fields country, state, city and/or code.  The tax rate is stored as
a percentage, like 5.5 .

=cut

sub add {
    my $self   = shift;
    my $params = shift;

    WebGUI::Error::InvalidParam->throw(error => 'Must pass in a hashref of params')
        unless ref($params) eq 'HASH';
    WebGUI::Error::InvalidParam->throw(error => "Missing required information.", param => 'country')
        unless exists($params->{country}) and $params->{country};
    WebGUI::Error::InvalidParam->throw(error => "Missing required information.", param => 'taxRate')
        unless exists($params->{taxRate}) and defined $params->{taxRate};

    $params->{taxId} = 'new';
    my $id = $self->session->db->setRow('tax', 'taxId', $params);
    return $id;
}

#-------------------------------------------------------------------

=head2 calculate ( $cart )

Calculate the tax for the contents of the cart.  The tax rate is calculated off
of the shipping address stored in the cart.  If an item in the cart has an alternate
address, that is used instead.  Finally, if the item in the cart has a Sku with a tax
rate override, that rate overrides all. Returns 0 if no shipping address has been attached to the cart yet.

=cut

sub calculate {
    my $self = shift;
    my $cart = shift;
    WebGUI::Error::InvalidParam->throw(error => 'Must pass in a WebGUI::Shop::Cart object')
        unless ref($cart) eq 'WebGUI::Shop::Cart';
    my $book = $cart->getAddressBook;
    return 0 if $cart->get('shippingAddressId') eq "";
    my $address = $book->getAddress($cart->get('shippingAddressId'));
    my $tax = 0;
    ##Fetch the tax data for the cart address so it doesn't have to look it up for every item
    ##in the cart with that address.
    my $cartTaxables = $self->getTaxRates($address);
    foreach my $item (@{ $cart->getItems }) {
        my $sku = $item->getSku;
        my $unitPrice = $sku->getPrice;
        my $quantity  = $item->get('quantity');
        ##Check for an item specific shipping address
        my $taxables;
        if (defined $item->get('shippingAddressId')) {
            my $itemAddress = $book->getAddress($item->get('shippingAddressId'));
            $taxables = $self->getTaxRates($itemAddress);
        }
        else {
            $taxables = $cartTaxables;
        }
        ##Check for a SKU specific tax override rate
        my $skuTaxRate = $sku->getTaxRate();
        my $itemTax;
        if (defined $skuTaxRate) {
            $itemTax = $skuTaxRate;
        }
        else {
            $itemTax = sum(@{$taxables});
        }
        $itemTax /= 100;
        $tax += $unitPrice * $quantity * $itemTax;
    }
    return $tax;
}

#-------------------------------------------------------------------

=head2 delete ( [$params] )

Deletes data from the tax table by taxId.

=head3 $params

A hashref containing the taxId of the data to delete from the table.

=head4 taxId

The taxId of the data to delete from the table.

=cut

sub delete {
    my $self   = shift;
    my $params = shift;
    WebGUI::Error::InvalidParam->throw(error => 'Must pass in a hashref of params')
        unless ref($params) eq 'HASH';
    WebGUI::Error::InvalidParam->throw(error => "Hash ref must contain a taxId key with a defined value")
        unless exists($params->{taxId}) and defined $params->{taxId};
    $self->session->db->write('delete from tax where taxId=?', [$params->{taxId}]);
    return;
}

#-------------------------------------------------------------------

=head2 exportTaxData ( )

Creates a tab deliniated file containing all the information from
the tax table.  Returns a temporary WebGUI::Storage object containing
the file.  The file will be named "siteTaxData.csv".

=cut

sub exportTaxData {
    my $self = shift;
    my $taxIterator = $self->getItems;
    my @columns = grep { $_ ne 'taxId' } $taxIterator->getColumnNames;
    my $taxData = WebGUI::Text::joinCSV(@columns) . "\n";
    while (my $taxRow = $taxIterator->hashRef() ) {
        my @taxData = @{ $taxRow }{@columns};
        foreach my $column (@taxData) {
            $column =~ tr/,/|/;  ##Convert to the alternation syntax for the text file
        }
        $taxData .= WebGUI::Text::joinCSV(@taxData) . "\n";
    }
    my $storage = WebGUI::Storage->createTemp($self->session);
    $storage->addFileFromScalar('siteTaxData.csv', $taxData);
    return $storage;
}

#-------------------------------------------------------------------

=head2 getAllItems ( )

Returns an arrayref of hashrefs, where each hashref is the data for one row of
tax data.  taxId is dropped from the dataset.

=cut

sub getAllItems {
    my $self = shift;
    my $taxes = $self->session->db->buildArrayRefOfHashRefs('select country,state,city,code,taxRate from tax order by country, state');
    return $taxes;
}

#-------------------------------------------------------------------

=head2 getItems ( )

Returns a WebGUI::SQL::Result object for accessing all of the data in the tax table.  This
is a convenience method for listing and/or exporting tax data.

=cut

sub getItems {
    my $self = shift;
    my $result = $self->session->db->read('select * from tax order by country, state');
    return $result;
}

#-------------------------------------------------------------------

=head2 getTaxRates ( $address )

Given a WebGUI::Shop::Address object, return all rates associated with the address as an arrayRef.

=cut

sub getTaxRates {
    my $self = shift;
    my $address = shift;
    WebGUI::Error::InvalidObject->throw(error => 'Need an address.', expected=>'WebGUI::Shop::Address', got=>(ref $address))
        unless ref($address) eq 'WebGUI::Shop::Address';
    my $country = $address->get('country');
    my $state   = $address->get('state');
    my $city    = $address->get('city');
    my $code    = $address->get('code');
    my $result = $self->session->db->buildArrayRef(
    q{
        select taxRate from tax where find_in_set(?, country)
        and (state='' or find_in_set(?, state))
        and (city=''  or find_in_set(?, city))
        and (code=''  or find_in_set(?, code))
    },
    [ $country, $state, $city, $code, ]);
    return $result;
}

#-------------------------------------------------------------------

=head2 importTaxData ( $filePath )

Import tax information from the specified file in CSV format.  The
first line of the file should contain the name of the columns, in
any order.  The first line may not contain comments in it, or
before it.

The following lines will contain tax information.  Blank
lines and anything following a '#' sign will be ignored from
the second line of the file, on to the end.

Returns 1 if the import has taken place.  This is to help you know
if old data has been deleted and new has been inserted.

=cut

sub importTaxData {
    my $self     = shift;
    my $filePath = shift;
    WebGUI::Error::InvalidParam->throw(error => q{Must provide the path to a file})
        unless $filePath;
    WebGUI::Error::InvalidFile->throw(error => qq{File could not be found}, brokenFile => $filePath)
        unless -e $filePath;
    WebGUI::Error::InvalidFile->throw(error => qq{File is not readable}, brokenFile => $filePath)
        unless -r $filePath;
    open my $table, '<', $filePath or
        WebGUI::Error->throw(error => qq{Unable to open $filePath for reading: $!\n});
    my $headers;
    $headers = <$table>;
    chomp $headers;
    my @headers = WebGUI::Text::splitCSV($headers);
    WebGUI::Error::InvalidFile->throw(error => qq{Bad header found in the CSV file}, brokenFile => $filePath)
        unless (join(q{-}, sort @headers) eq 'city-code-country-state-taxRate')
           and (scalar @headers == 5);
    my @taxData = ();
    my $line = 1;
    while (my $taxRow = <$table>) {
        chomp $taxRow;
        $taxRow =~ s/\s*#.+$//;
        next unless $taxRow;
        local $_;
        my @taxRow = map { tr/|/,/; $_; } WebGUI::Text::splitCSV($taxRow);
        WebGUI::Error::InvalidFile->throw(error => qq{Error found in the CSV file}, brokenFile => $filePath, brokenLine => $line)
            unless scalar @taxRow == 5;
        push @taxData, [ @taxRow ];
    }
    ##Okay, if we got this far, then the data looks fine.
    return unless scalar @taxData;
    $self->session->db->beginTransaction;
    $self->session->db->write('delete from tax');
    foreach my $taxRow (@taxData) {
        my %taxRow;
        @taxRow{ @headers } = @{ $taxRow }; ##Must correspond 1:1, or else...
        $self->add(\%taxRow);
    }
    $self->session->db->commit;
    return 1;
}

#-------------------------------------------------------------------

=head2 new ( $session )

Constructor for the WebGUI::Shop::Tax.  Returns a WebGUI::Shop::Tax object.

=cut

sub new {
    my $class   = shift;
    my $session = shift;
    my $self    = {};
    bless $self, $class;
    register $self;
    $session{ id $self } = $session;
    return $self;
}

#-------------------------------------------------------------------

=head2 session (  )

Accessor for the session object.  Returns the session object.

=cut

#-------------------------------------------------------------------

=head2 www_getTaxesAsJson (  )

Servers side pagination for tax data that is sent as JSON back to the browser to be
displayed in a YUI DataTable.

=cut

sub www_getTaxesAsJson {
    my ($self) = @_;
    my $session = $self->session;
    my $admin = WebGUI::Shop::Admin->new($session);
    return $session->privilege->insufficient
        unless $admin->canManage;
    my ($db, $form) = $session->quick(qw(db form));
    my $startIndex = $form->get('startIndex') || 0;
    my $numberOfResults = $form->get('results') || 25;
    my @placeholders = ();
    my $sql = 'select SQL_CALC_FOUND_ROWS * from tax';
    my $keywords = $form->get("keywords");
    if ($keywords ne "") {
        ($sql, @placeholders) = $db->buildSearchQuery($sql, $keywords, [qw{country state city code}])
    }
    push(@placeholders, $startIndex, $numberOfResults);
    $sql .= ' order by country desc limit ?,?';
    my %results = $db->buildDataTableStructure($sql, \@placeholders);
    $results{'startIndex'} = $startIndex;
    $results{'sort'}       = undef;
    $results{'dir'}        = "desc";
    $session->http->setMimeType('text/json');
    return JSON::to_json(\%results);
}

#-------------------------------------------------------------------

=head2 www_manage (  )

User interface to manage taxes.  Provides a list of current taxes, and forms for adding
new tax info, exporting and importing sets of taxes, and deleting individual tax data.

=cut

sub www_manage {
    my $self = shift;
    my $session = $self->session;
    my $admin = WebGUI::Shop::Admin->new($session);
    return $session->privileges->insufficient
        unless $admin->canManage;
    ##YUI specific datatable CSS
    my ($style, $url) = $session->quick(qw(style url));
    $style->setLink($url->extras('/yui/build/fonts/fonts-min.css'), {rel=>'stylesheet', type=>'text/css'});
    $style->setLink($url->extras('yui/build/datatable/assets/skins/sam/datatable.css'), {rel=>'stylesheet', type => 'text/CSS'});
    ##YUI basics
    $style->setScript($url->extras('yui/build/yahoo-dom-event/yahoo-dom-event.js'), {type => 'text/javascript'});
    $style->setScript($url->extras('yui/build/element/element-beta-min.js'), {type => 'text/javascript'});
    $style->setScript($url->extras('yui/build/datasource/datasource-beta-min.js'), {type => 'text/javascript'});
    ##YUI Datatable
    $style->setScript($url->extras('yui/build/datatable/datatable-beta-min.js'), {type => 'text/javascript'});
    ##YUI JSON handler
    $style->setScript($url->extras('yui/build/json/json-min.js'), {type => 'text/javascript'});
    ##Default CSS
    $style->setRawHeadTags('<style type="text/css"> #paging a { color: #0000de; } #search, #export form { display: inline; } </style>');
    my $i18n=WebGUI::International->new($session, 'Tax');

    my $output =sprintf <<EODIV, $i18n->get(364, 'WebGUI'), $i18n->get('export');
<div class=" yui-skin-sam">
    <div id="search"><form id="keywordSearchForm"><input type="text" name="keywords" id="keywordsField" /><input type="submit" value="%s" /></form></div>
    <div id="paging"></div>
    <div id="dt"></div>
    <div id="import"></div>
    <div id="export"><form id="exportForm"><input type="submit" value="%s" /></form></div>
</div>

<script type="text/javascript">
YAHOO.util.Event.onDOMReady(function () {
    var DataSource = YAHOO.util.DataSource,
        Dom        = YAHOO.util.Dom,
        DataTable  = YAHOO.widget.DataTable,
        Paginator  = YAHOO.widget.Paginator;
EODIV

    ##Build datasource with URL.
    $output .= sprintf <<'EODSURL', $url->page('shop=tax;method=getTaxesAsJson');
    var mySource = new DataSource('%s');
    mySource.responseType   = DataSource.TYPE_JSON;
    mySource.responseSchema = {
        resultsList : 'records',
        totalRecords: 'totalRecords',
        fields      : [ 'taxId', 'country', 'state', 'city', 'code', 'taxRate']
    };
EODSURL
    $output .= <<STOP;
    //Tell YUI how to get back to the site
    var buildQueryString = function (state,dt) {
        return ";startIndex=" + state.pagination.recordOffset +
               ";keywords=" + Dom.get('keywordsField').value +
               ";results=" + state.pagination.rowsPerPage;
    };

    //Build and configure a paginator
    var myPaginator = new Paginator({
        containers         : ['paging'],
        pageLinks          : 5,
        rowsPerPage        : 25,
        rowsPerPageOptions : [10,25,50,100],
        template           : "<strong>{CurrentPageReport}</strong> {PreviousPageLink} {PageLinks} {NextPageLink} {RowsPerPageDropdown}"
    });

    //Configure the table to use the paginator.
    var myTableConfig = {
        initialRequest         : ';startIndex=0',
        generateRequest        : buildQueryString,
        paginationEventHandler : DataTable.handleDataSourcePagination,
        paginator              : myPaginator
    };
STOP

    $output .= sprintf <<'EOCHJS', $i18n->get('country'), $i18n->get('state'), $i18n->get('city'), $i18n->get('code'), $i18n->get('tax rate');
    //Build column headers.
    var taxColumnDefs = [
        {key:"taxId", label:"taxId"},
        {key:"country", label:"%s"},
        {key:"state",   label:"%s"},
        {key:"city",    label:"%s"},
        {key:"code",    label:"%s"},
        {key:"taxRate", label:"%s"},

    ];
EOCHJS
    $output .= <<STOP;
    //Now, finally, the table
    var myTable = new DataTable('dt', taxColumnDefs, mySource, myTableConfig);

    //Setup the form to submit an AJAX request back to the site.
    Dom.get('keywordSearchForm').onsubmit = function () {
        mySource.sendRequest(';keywords=' + Dom.get('keywordsField').value + ';startIndex=0', 
            myTable.onDataReturnInitializeTable, myTable);
        return false;
    };

});
</script>
STOP
    return $admin->getAdminConsole->render($output, $i18n->get('taxes', 'Shop'));
}

1;
