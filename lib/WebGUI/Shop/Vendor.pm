package WebGUI::Shop::Vendor;

use strict;
use Scalar::Util qw/blessed/;
use Moose;
use WebGUI::Definition;

property 'name' => (
    is         => 'rw',
    noFormPost => 1,
    default    => '',
);

property 'userId' => (
    is         => 'rw',
    noFormPost => 1,
    default    => '',
);

property 'url' => (
    is         => 'rw',
    noFormPost => 1,
    default    => '',
);

property 'paymentInformation' => (
    is         => 'rw',
    noFormPost => 1,
    default    => '',
);

property 'preferredPaymentType' => (
    is         => 'rw',
    noFormPost => 1,
    default    => '',
);

has 'dateCreated' => (
    is => 'ro',
);
has [ qw/session vendorId/ ] => (
    is       => 'ro',
    required => 1,
);

around BUILDARGS => sub {
    my $orig  = shift;
    my $class = shift;
    if (ref $_[0] eq 'HASH') {
        ##Need same db code as below here.
        ##Session check goes here?
        ##Build a new one
        my $properties = $_[0];
        my $session = $properties->{session};
        if (! (blessed $session && $session->isa('WebGUI::Session')) ) {
            WebGUI::Error::InvalidObject->throw(expected=>"WebGUI::Session", got=>(ref $session), error=>"Need a session.");
        }
        my ($vendorId, $dateCreated) = $class->_init($session);
        $properties->{vendorId}    = $vendorId;
        $properties->{dateCreated} = $dateCreated;
        return $class->$orig($properties);
    }
    my $session = shift;
    if (! (blessed $session && $session->isa('WebGUI::Session'))) {
        WebGUI::Error::InvalidObject->throw(expected=>"WebGUI::Session", got=>(ref $session), error=>"Need a session.");
    }
    my $argument2 = shift;
    if (!defined $argument2) {
        WebGUI::Error::InvalidParam->throw( param=>$argument2, error=>"Need a vendorId.");
    }
    if (ref $argument2 eq 'HASH') {
        ##Build a new one
        my ($vendorId, $dateCreated) = $class->_init($session);
        my $properties             = $argument2;
        $properties->{session}     = $session;
        $properties->{vendorId}    = $vendorId;
        $properties->{dateCreated} = $dateCreated;
        return $class->$orig($properties);
    }
    else {
        ##Look up one in the db
        my $vendor = $session->db->quickHashRef("select * from vendor where vendorId=?", [$argument2]);
        if ($vendor->{vendorId} eq "") {
            WebGUI::Error::ObjectNotFound->throw(error=>"Vendor not found.", id=>$argument2);
        }
        $vendor->{session} = $session;
        return $class->$orig($vendor);
    }
};

use WebGUI::Shop::Admin;
use WebGUI::Exception::Shop;
use WebGUI::International;
use WebGUI::Utility qw{ isIn };
use List::Util qw{ sum };
use JSON qw{ encode_json };

=head1 NAME

Package WebGUI::Shop::Vendor

=head1 DESCRIPTION

Keeps track of vendors that sell merchandise in the store.

=head1 SYNOPSIS

 use WebGUI::Shop::Vendor;

 my $vendor = WebGUI::Shop::Vendor->new($session, $vendorId);

=head1 METHODS

These subroutines are available from this package:

=cut

#-------------------------------------------------------------------

=head2 _init ( session )

Builds a stub of object information in the database, and returns the newly created
vendorId, and the dateCreated fields so the object can be initialized correctly.

=cut

sub _init {
    my $class       = shift;
    my $session     = shift;
    my $vendorId    = $session->id->generate;
    my $dateCreated = WebGUI::DateTime->new($session)->toDatabase;
    $session->db->write("insert into vendor (vendorId, dateCreated) values (?, ?)",[$vendorId, $dateCreated]);
    return ($vendorId, $dateCreated);
}

#-------------------------------------------------------------------

=head2 create ( session, properties )

Constructor. Creates a new vendor.  Really an alias for WebGUI::Shop::Vendor->new($session, $properties)

=cut

sub create {
    my ($class, $session, $properties) = @_;
    return $class->new($session, $properties);
}

#-------------------------------------------------------------------

=head2 delete ()

Deletes this vendor.

=cut

sub delete {
    my ($self) = @_;
    $self->session->db->deleteRow("vendor", "vendorId", $self->vendorId);
}

#-------------------------------------------------------------------

=head2 getId () 

Returns the unique id of this item.  You should use $self->vendorId instead.

=cut

sub getId {
    my $self = shift;
    return $self->vendorId;
}

#-------------------------------------------------------------------

=head2 getPayoutTotals ( )

Returns a hash ref, containing the payout details for this vendor. The keys in the hash are:

=head3 paid

The amount of money already transfered to the vendor.

=head3 scheduled

The amount of money scheduled to be transfered to the vendor.

=head3 notPaid

The amount of money that is yet to be scheduled for payment to the vendor.

=head3 total

The sum of these three values.

=cut

sub getPayoutTotals {
    my $self    = shift;

    my %totals = $self->session->db->buildHash(
        'select vendorPayoutStatus, sum(vendorPayoutAmount) as amount from transactionItem as t1, transaction as t2 '
        .'where t1.transactionId = t2.transactionId and t2.isSuccessful <> 0 and vendorId=? group by vendorPayoutStatus ',
        [ $self->vendorId ]
    );

    # Format the payout categories and calc the total those.
    %totals          = 
        map     { lcfirst $_ => sprintf '%.2f', $totals{ $_ } } 
                qw( Paid Scheduled NotPaid );
    $totals{ total } = sprintf '%.2f', sum values %totals;

    return \%totals;
}

#-------------------------------------------------------------------

=head2 getVendors ( session, options )

Class method. Returns an array reference of WebGUI::Shop::Vendor objects.

=head3 session

A reference to the current session.

=head3 options

A hash reference of optional flags.

=head4 asHashRef

A boolean indicating that the vendors should be returned as a hash reference of id/names rather than an array of objects.

=cut

sub getVendors {
    my ($class, $session, $options) = @_;
    my $vendorList = $session->db->buildHashRef("select vendorId,name from vendor order by name");
    if ($options->{asHashRef}) {
        return $vendorList;
    }
    my @vendors = ();
    foreach my $id (keys %{$vendorList}) {
        push @vendors, $class->new($session, $id);
    }
    return \@vendors;
}

#-------------------------------------------------------------------

=head2 isVendorInfoComplete ( )

Returns a boolean indicating whether the payoutinformation entered by the vendor is complete.

=cut

sub isVendorInfoComplete {
    my $self = shift;

    my $complete = 
           defined $self->name
        && defined $self->userId
        && defined $self->preferredPaymentType
        && defined $self->paymentInformation;

    return $complete
}

#-------------------------------------------------------------------

=head2 new ( session, vendorId )

=head2 new ( session, properties )

=head2 new ( hashref )

Constructor.   Returns a WebGUI::Shop::Vendor object, either by fetching information from the database,
or using passed in properties.

=head3 session

A reference to the current session.  If the session variable is not passed, then an WebGUI::Error::InvalidObject
Exception will be thrown.

=head3 vendorId

A unique id for a vendor that already exists in the database.  If the vendorId is not passed
in, then a WebGUI::Error::InvalidParam Exception will be thrown.  If the requested Id cannot
be found in the database, then a WebGUI::Error::ObjectNotFound exception will be thrown.

=head3 properties

A hashref of properties to assign to the object when it is created.

=head3 hashref

A classic Moose-style hashref of options.  It must include a WebGUI::Session object.

=head3 Attributes

=head4 name

The name of the vendor.

=head4 userId

The unique GUID of the vendor.

=head4 url

The vendor's url.

=head4 vendorId

A unique identifier for this vendor.  This option may be included in the properties for the new object, but it will
be ignored.

=head4 dateCreated

The date this vendor was created, in database format.  This option may be included in the properties for the new object,
but it will be ignored.

=head4 paymentInformation

=head4 preferredPaymentType

=cut


#-------------------------------------------------------------------

=head2 newByUserId ( session, [userId] )

Constructor. 

=head3 session

A reference to the current session.

=head3 userId

A unique userId.  Will pull from the session if not specified.

=cut

sub newByUserId {
    my ($class, $session, $userId) = @_;
        unless (defined $session && $session->isa("WebGUI::Session")) {
        WebGUI::Error::InvalidObject->throw(expected=>"WebGUI::Session", got=>(ref $session), error=>"Need a session.");
    }
    $userId ||= $session->user->userId;
    unless (defined $userId) {
        WebGUI::Error::InvalidParam->throw( param=>$userId, error=>"Need a userId.");
    }
    return $class->new($session, $session->db->quickScalar("select vendorId from vendor where userId=?",[$userId]));
}


#-------------------------------------------------------------------

=head2 session () 

Returns a reference to the current session.

=cut

#-------------------------------------------------------------------

=head2 write ( )

Serializes the object's properties to the database

=cut

sub write {
    my ($self) = @_;
    my $properties = $self->get();
    $self->session->db->setRow("vendor", "vendorId", $properties);
}

#-------------------------------------------------------------------

=head2 www_delete (  )

Deletes a vendor.

=cut

sub www_delete {
    my ($class, $session)    = @_;
    my $admin   = WebGUI::Shop::Admin->new($session);
    return $session->privilege->adminOnly() unless ($admin->canManage);
    my $self = $class->new($session, $session->form->get("vendorId"));
    if (defined $self) {
        $self->delete;
    }
    return $class->www_manage($session);
}

#-------------------------------------------------------------------

=head2 www_edit (  )

Displays an edit form for a vendor.

=cut

sub www_edit {
    my ($class, $session)    = @_;
    my $admin   = WebGUI::Shop::Admin->new($session);
    return $session->privilege->adminOnly() unless ($admin->canManage);
    
    # get properties
    my $self = eval{$class->new($session, $session->form->get("vendorId"))};
    my $properties = {};
    if (!WebGUI::Error->caught && defined $self) {
        $properties = $self->get;
    }
    
    # draw form
    my $i18n    = WebGUI::International->new($session, "Shop");
    my $f = WebGUI::HTMLForm->new($session);
    $f->hidden(name=>'shop',value=>'vendor');
    $f->hidden(name=>'method',value=>'editSave');
    $f->hidden(name=>'vendorId',value=>$properties->{vendorId});
    $f->readOnly(label=>$i18n->get('date created'),value=>$properties->{dateCreated});
    $f->text(name=>'name', label=>$i18n->get('name'),value=>$properties->{name});
    $f->user(name=>'userId',label=>$i18n->get('username'),value=>$properties->{userId},defaultValue=>3);
    $f->url(name=>'url', label=>$i18n->get('company url'),value=>$properties->{url});
    $f->text(name=>'preferredPaymentType', label=>$i18n->get('Preferred Payment Type'),value=>$properties->{preferredPaymentType});
    $f->textarea(name=>'paymentInformation', label=>$i18n->get('Payment Information'),value=>$properties->{paymentInformation});
    $f->submit();

    # Wrap in admin console
    my $console = $admin->getAdminConsole;
    return $console->render($f->print, $i18n->get("vendors"));
}

#-------------------------------------------------------------------

=head2 www_editSave (  )

Saves the results of www_edit()

=cut

sub www_editSave {
    my ($class, $session)    = @_;
    my $admin   = WebGUI::Shop::Admin->new($session);
    return $session->privilege->adminOnly() unless ($admin->canManage);
    my $form = $session->form;
    my $properties = {
        name                    => $form->get("name","text"),              
        preferredPaymentType    => $form->get("preferredPaymentType","text"),              
        paymentInformation      => $form->get("paymentInformation","textarea"),              
        userId                  => $form->get("userId","user",'3'),              
        url                     => $form->get("url","url"),              
        };
    my $self = eval{$class->new($session, $form->get("vendorId"))};
    if (!WebGUI::Error->caught && defined $self) {
        $self->update($properties);
    }
    else {
        $class->create($session, $properties);
    }
    return $class->www_manage($session);
}


#-------------------------------------------------------------------

=head2 www_manage (  )

Displays the list of vendors.

=cut

sub www_manage {
    my ($class, $session)    = @_;
    my $admin   = WebGUI::Shop::Admin->new($session);
    my $i18n    = WebGUI::International->new($session, "Shop");

    return $session->privilege->adminOnly() unless ($admin->canManage);

    # Button for adding a vendor
    my $output = WebGUI::Form::formHeader($session)
        .WebGUI::Form::hidden($session,     { name  => "shop",      value   => "vendor" })
        .WebGUI::Form::hidden($session,     { name  => "method",    value   => "edit" })
        .WebGUI::Form::submit($session,     { value => $i18n->get("add a vendor") })
        .WebGUI::Form::formFooter($session);

    # Add a row with edit/delete buttons for each 
    foreach my $vendor (@{$class->getVendors($session)}) {
        $output .= '<div style="clear: both;">'
            # Delete button 
			.WebGUI::Form::formHeader($session, {extras=>'style="float: left;"' })
            .WebGUI::Form::hidden($session, { name   => "shop",                value => "vendor" })
            .WebGUI::Form::hidden($session, { name   => "method",              value => "delete" })
            .WebGUI::Form::hidden($session, { name   => "vendorId",    value => $vendor->vendorId })
            .WebGUI::Form::submit($session, { value  => $i18n->get("delete"), extras => 'class="backwardButton"' }) 
            .WebGUI::Form::formFooter($session)

            # Edit button
            .WebGUI::Form::formHeader($session, {extras=>'style="float: left;"' })
            .WebGUI::Form::hidden($session, { name   => "shop",              value => "vendor" })
            .WebGUI::Form::hidden($session, { name   => "method",            value => "edit" })
            .WebGUI::Form::hidden($session, { name   => "vendorId",  value => $vendor->vendorId })
            .WebGUI::Form::submit($session, { value  => $i18n->get("edit"), extras => 'class="normalButton"' })
            .WebGUI::Form::formFooter($session)

            # Append name
            .' '. $vendor->name 
        .'</div>';        
    }

    # Wrap in admin console
    my $console = $admin->getAdminConsole;
    return $console->render($output, $i18n->get("vendors"));
}

#-------------------------------------------------------------------

=head2 www_managePayouts ( )

Displays the payout manager.

=cut

sub www_managePayouts {
    my $class   = shift;
    my $session = shift;
    my $style   = $session->style;
    my $url     = $session->url;

    my $admin   = WebGUI::Shop::Admin->new($session);
    return $session->privilege->adminOnly() unless ($admin->canManage);
    
    # Load the required YUI stuff.
    $style->setLink($url->extras('yui/build/paginator/assets/skins/sam/paginator.css'), {type=>'text/css', rel=>'stylesheet'});
    $style->setLink($url->extras('yui/build/datatable/assets/skins/sam/datatable.css'), {type=>'text/css', rel=>'stylesheet'});
    $style->setLink($url->extras('yui/build/button/assets/skins/sam/button.css'),       {type=>'text/css', rel=>'stylesheet'});

    $style->setScript($url->extras('yui/build/yahoo-dom-event/yahoo-dom-event.js'));
    $style->setScript($url->extras('yui/build/element/element-min.js'));
    $style->setScript($url->extras('yui/build/connection/connection-min.js'));
    $style->setScript($url->extras('yui/build/json/json-min.js'));
    $style->setScript($url->extras('yui/build/paginator/paginator-min.js'));
    $style->setScript($url->extras('yui/build/datasource/datasource-min.js'));
    $style->setScript($url->extras('yui/build/datatable/datatable-min.js'));
    $style->setScript($url->extras('yui/build/button/button-min.js'));
    $style->setScript($url->extras('yui-webgui/build/i18n/i18n.js'));
    $style->setScript($url->extras('VendorPayout/vendorPayout.js'));

    # Add css for scheduled payout highlighting
    $style->setRawHeadTags(<<CSS);
        <style type="text/css">
            .yui-skin-sam .yui-dt tr.scheduled,
            .yui-skin-sam .yui-dt tr.scheduled td.yui-dt-asc,
            .yui-skin-sam .yui-dt tr.scheduled td.yui-dt-desc,
            .yui-skin-sam .yui-dt tr.scheduled td.yui-dt-asc,
            .yui-skin-sam .yui-dt tr.scheduled td.yui-dt-desc {
                background-color    : #080;
                color               : #fff;
            }
        </style>
CSS

    my $output = q{<div id="vendorPayoutContainer" class="yui-skin-sam"></div>}
        .q{<script type="text/javascript">var vp = new WebGUI.VendorPayout( 'vendorPayoutContainer' );</script>};

    my $console = WebGUI::Shop::Admin->new($session)->getAdminConsole;
    my $i18n = WebGUI::International->new($session, 'Shop');
    return $console->render($output, $i18n->get('vendor payouts'));
}

#-------------------------------------------------------------------

=head2 www_payoutDataAsJSON ( )

Returns a JSON string containing paginated payout data for a specific vendor. 
The following form params should be passed:

=head3 vendorId

The vendorId of the vendor you want the payout data for.

=head3 results

The number of results to be returned. Defaults to 100.

=head3 startIndex

The index of the record at which the payout data should start.

=cut

sub www_payoutDataAsJSON {
    my $class   = shift;
    my $session = shift;

    my $admin   = WebGUI::Shop::Admin->new($session);
    return $session->privilege->adminOnly() unless ($admin->canManage);

    my $vendorId    = $session->form->process('vendorId');
    my $startIndex  = $session->form->process('startIndex');
    my $rowsPerPage = $session->form->process('results') || 100;
    my $pageNumber  = int( $startIndex / $rowsPerPage ) + 1;
    
    my $sql         = 
        "select t1.* from transactionItem as t1 join transaction as t2 on t1.transactionId=t2.transactionId "
        ." where t2.isSuccessful <> 0 and vendorId=? and vendorPayoutAmount > 0 and vendorPayoutStatus <> 'Paid' order by t2.orderNumber";
    my $placeholders =  [ $vendorId ];

    my $paginator   = WebGUI::Paginator->new( $session, '', $rowsPerPage, '', $pageNumber ); 
    $paginator->setDataByQuery( $sql, undef, 0, $placeholders );

    my $data = {
        totalRecords    => $paginator->getRowCount,
        results         => $paginator->getPageData,
    };

    $session->http->setMimeType( 'application/json' );

    return JSON::to_json( $data );
}

#-------------------------------------------------------------------

=head2 www_setPayoutStatus ( )

Sets the vendorPayoutStatus flag for each transaction passed by the form param 'itemId'. The new status is passed
by the form param 'status'. Status can either be 'NotPaid' or 'Scheduled' and may only be applied on items that do
not have their vendorPayoutStatus set to 'Paid'.

Returns the status to which the item(s) are set.

=cut

sub www_setPayoutStatus {
    my $class           = shift;
    my $session         = shift;
    my ( $form, $db )   = $session->quick( qw{ form db } );

    my $admin   = WebGUI::Shop::Admin->new($session);
    return $session->privilege->adminOnly() unless ($admin->canManage);

    my $status  = $form->process('status');
    return "error: wrong status [$status]" unless isIn( $status, qw{ NotPaid Scheduled } );

    my @itemIds;
    if ( $form->process( 'all' ) ) {
        @itemIds = $session->db->buildArray( 'select itemId from transactionItem where vendorPayoutStatus = ?' , [
            ( $status eq 'NotPaid' ) ? 'Scheduled' : 'NotPaid'
        ] );
    }
    else {
        @itemIds = $form->process('itemId');
    }

    foreach  my $itemId (@itemIds) {
       my $item = WebGUI::Shop::TransactionItem->newByDynamicTransaction( $session, $itemId );
       return "error: invalid transactionItemId [$itemId]" unless $item;
       return "error: cannot change status of a Paid item" if $item->get('vendorPayoutStatus') eq 'Paid';
    
       $item->update({ vendorPayoutStatus => $status });
    }

    $session->http->setMimeType( 'text/plain' );
    return $status;
}

#-------------------------------------------------------------------

=head2 www_submitScheduledPayouts ()

Sets the vendorPayoutStatus flag of scheduled payments to 'Paid'. 

NOTE: This method does no payments at all. In the future this method should trigger some automated payout
mechanism.

=cut

sub www_submitScheduledPayouts {
    my $class   = shift;
    my $session = shift;

    my $admin   = WebGUI::Shop::Admin->new($session);
    return $session->privilege->adminOnly() unless ($admin->canManage);

    $session->db->write(
        q{ update transactionItem set vendorPayoutStatus = 'Paid' where vendorPayoutStatus = 'Scheduled' }
    );

    return $class->www_managePayouts( $session );
}

#-------------------------------------------------------------------

=head2 www_vendorTotalsAsJSON ( )

Returns a JSON string containing all vendors and their payout details. The following
form parameters can be passed:

=head3 vendorId

If passed, the results will include only the totals of this vendor.

=cut

sub www_vendorTotalsAsJSON {
    my $class       = shift;
    my $session     = shift;

    my $admin   = WebGUI::Shop::Admin->new($session);
    return $session->privilege->adminOnly() unless ($admin->canManage);

    my $vendorId    = $session->form->process('vendorId');
    my ($vendorPayoutData, @placeholders);
  
    my @sql;
    push @sql, ' select vendorId, vendorPayoutStatus, sum(vendorPayoutAmount) as total ';
    push @sql, ' from transactionItem as t1, transaction as t2 ';
    push @sql, ' where t1.transactionId=t2.transactionId and isSuccessful <> 0 ';
    push @sql, ' and vendorId=? ' if $vendorId;
    push @sql, ' group by vendorId, vendorPayoutStatus ';

    push @placeholders, $vendorId if $vendorId;

    my $sth = $session->db->read( join( ' ', @sql) , \@placeholders );
    while (my $row = $sth->hashRef) {
        $vendorPayoutData->{ $row->{vendorId} }->{ $row->{vendorPayoutStatus} } = $row->{total};
    }
    $sth->finish;

    my @dataset;
    foreach my $vendorId (keys %{ $vendorPayoutData }) {
        my $vendor = WebGUI::Shop::Vendor->new( $session, $vendorId );

        my $dataset = {
            %{ $vendor->get },
            %{ $vendorPayoutData->{ $vendorId } },
        };
        my $user = WebGUI::User->new($session, $vendor->get('userId'));
        $dataset->{name} .= ' ('.$user->username.')';
        push @dataset, $dataset;
    }

    $session->http->setMimeType( 'application/json' );
    return JSON::to_json( { vendors => \@dataset } );
}

1;

