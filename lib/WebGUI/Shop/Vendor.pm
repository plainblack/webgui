package WebGUI::Shop::Vendor;

use strict;
use Class::InsideOut qw{ :std };
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

 my $vendor = WebGUI::Shop::Vendor->new($session, $vendord);

=head1 METHODS

These subroutines are available from this package:

=cut

readonly session => my %session;
readonly properties => my %properties;

#-------------------------------------------------------------------

=head2 create ( session, properties )

Constructor. Creates a new vendor.

=head3 session

A reference to the current session.

=head3 properties

A hash reference containing the properties for this vendor. See update() for details.

=cut

sub create {
    my ($class, $session, $properties) = @_;
    unless (defined $session && $session->isa("WebGUI::Session")) {
        WebGUI::Error::InvalidObject->throw(expected=>"WebGUI::Session", got=>(ref $session), error=>"Need a session.");
    }
    my $id = $session->id->generate;
    $session->db->write("insert into vendor (vendorId, dateCreated) values (?, now())",[$id]);
    my $self = $class->new($session, $id);
    $self->update($properties);
    return $self;
}

#-------------------------------------------------------------------

=head2 delete ()

Deletes this vendor.

=cut

sub delete {
    my ($self) = @_;
    $self->session->db->deleteRow("vendor","vendorId",$self->getId);
}

#-------------------------------------------------------------------

=head2 get ( [ property ] )

Returns a duplicated hash reference of this objectÕs data. See update() for details.

=head3 property

Any field returns the value of a field rather than the hash reference.

=head3 Additional properties

=head4 dateCreated

The date this vendor was created in the system.

=head4 vendorId

The id of this vendor from the database.  Use getId() instead.

=cut

sub get {
    my ($self, $name) = @_;
    if (defined $name) {
        return $properties{id $self}{$name};
    }
    my %copyOfHashRef = %{$properties{id $self}};
    return \%copyOfHashRef;
}

#-------------------------------------------------------------------

=head2 getId () 

Returns the unique id of this item.

=cut

sub getId {
    my $self = shift;
    return $self->get("vendorId");
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

=head2 new ( session, vendorId )

Constructor.   Returns a WebGUI::Shop::Vendor object.

=head3 session

A reference to the current session.  If the session variable is not passed, then an WebGUI::Error::InvalidObject
Exception will be thrown.

=head3 vendorId

A unique id for a vendor that already exists in the database.  If the vendorId is not passed
in, then a WebGUI::Error::InvalidParam Exception will be thrown.  If the requested Id cannot
be found in the database, then a WebGUI::Error::ObjectNotFound exception will be thrown.

=cut

sub new {
    my ($class, $session, $vendorId) = @_;
    unless (defined $session && $session->isa("WebGUI::Session")) {
        WebGUI::Error::InvalidObject->throw(expected=>"WebGUI::Session", got=>(ref $session), error=>"Need a session.");
    }
    unless (defined $vendorId) {
        WebGUI::Error::InvalidParam->throw( param=>$vendorId, error=>"Need a vendorId.");
    }
    my $vendor = $session->db->quickHashRef("select * from vendor where vendorId=?",[$vendorId]);
    if ($vendor->{vendorId} eq "") {
        WebGUI::Error::ObjectNotFound->throw(error=>"Vendor not found.", id=>$vendorId);
    }
    my $self = register $class;
    my $id        = id $self;
    $session{ $id } = $session;
    $properties{ $id } = $vendor;
    return $self;
}

#-------------------------------------------------------------------

=head2 newByUserId ( session, [userId] )

Constructor. 

=head3 session

A reference to the current session.

=head3 userId

A unique userId. Will pull from the session if not specified.

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

=head2 update ( properties )

Sets properties of the vendor

=head3 properties

A hash reference that contains one of the following:

=head4 name

The name of the vendor.

=head4 userId

The name of the vendor.

=head4 url

The vendor's url.

=head4 paymentInformation

????

=head4 preferredPaymentType

????

=cut

sub update {
    my ($self, $newProperties) = @_;
    my $id = id $self;
    my @fields = (qw(name userId url paymentInformation preferredPaymentType));
    foreach my $field (@fields) {
        $properties{$id}{$field} = (exists $newProperties->{$field}) ? $newProperties->{$field} : $properties{$id}{$field};
    }
    $self->session->db->setRow("vendor","vendorId",$properties{$id});
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
            .WebGUI::Form::hidden($session, { name   => "vendorId",    value => $vendor->getId })
            .WebGUI::Form::submit($session, { value  => $i18n->get("delete"), extras => 'class="backwardButton"' }) 
            .WebGUI::Form::formFooter($session)

            # Edit button
            .WebGUI::Form::formHeader($session, {extras=>'style="float: left;"' })
            .WebGUI::Form::hidden($session, { name   => "shop",              value => "vendor" })
            .WebGUI::Form::hidden($session, { name   => "method",            value => "edit" })
            .WebGUI::Form::hidden($session, { name   => "vendorId",  value => $vendor->getId })
            .WebGUI::Form::submit($session, { value  => $i18n->get("edit"), extras => 'class="normalButton"' })
            .WebGUI::Form::formFooter($session)

            # Append name
            .' '. $vendor->get("name") 
        .'</div>';        
    }

    # Wrap in admin console
    my $console = $admin->getAdminConsole;
    return $console->render($output, $i18n->get("vendors"));
}


#-------------------------------------------------------------------
sub getPayoutTotals {
    my $self    = shift;

    my %totals = $self->session->db->buildHash(
        'select vendorPayoutStatus, sum(vendorPayoutAmount) as amount from transactionItem '
        .'where vendorId=? group by vendorPayoutStatus ',
        [ $self->getId ]
    );

    # Format the payout categories and calc the total those.
    %totals          = 
        map     { lcfirst $_ => sprintf '%.2f', $totals{ $_ } } 
                qw( Paid Scheduled NotPaid );
    $totals{ total } = sprintf '%.2f', sum values %totals;

    return \%totals;
}

#-------------------------------------------------------------------
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
sub www_setPayoutStatus {
    my $class   = shift;
    my $session = shift;

    my $admin   = WebGUI::Shop::Admin->new($session);
    return $session->privilege->adminOnly() unless ($admin->canManage);

    my @itemIds = $session->form->process('itemId');
    my $status  = $session->form->process('status');
    return "error: wrong status [$status]" unless isIn( $status, qw{ NotPaid Scheduled } );

    foreach  my $itemId (@itemIds) {
       my $item = WebGUI::Shop::TransactionItem->newByDynamicTransaction( $session, $itemId );
       return "error: invalid transactionItemId [$itemId]" unless $item;
       return "error: cannot change status of a Paid item" if $item->get('vendorPayoutStatus') eq 'Paid';
    
       $item->update({ vendorPayoutStatus => $status });
    }

    return $status;
}

#-------------------------------------------------------------------
sub www_vendorTotalsAsJSON {
    my $class       = shift;
    my $session     = shift;

    my $admin   = WebGUI::Shop::Admin->new($session);
    return $session->privilege->adminOnly() unless ($admin->canManage);

    my $vendorId    = $session->form->process('vendorId');
    my ($vendorPayoutData, @placeholders);
  
    my @sql;
    push @sql,
        'select vendorId, vendorPayoutStatus, sum(vendorPayoutAmount) as total from transactionItem';
    push @sql, ' where vendorId=? ' if $vendorId;
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

        push @dataset, {
            %{ $vendor->get },
            %{ $vendorPayoutData->{ $vendorId } },
        }
    }

    $session->http->setMimeType( 'application/json' );
    return JSON::to_json( { vendors => \@dataset } );
}

#-------------------------------------------------------------------
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
        ." where vendorId=? and vendorPayoutAmount > 0 and vendorPayoutStatus <> 'Paid' order by t2.orderNumber";
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
sub www_managePayouts {
    my $class   = shift;
    my $session = shift;

    my $admin   = WebGUI::Shop::Admin->new($session);
    return $session->privilege->adminOnly() unless ($admin->canManage);
    
    # Load the required YUI stuff.
    $session->style->setLink('/extras/yui/build/paginator/assets/skins/sam/paginator.css', {type=>'text/css', rel=>'stylesheet'});
    $session->style->setLink('/extras/yui/build/datatable/assets/skins/sam/datatable.css', {type=>'text/css', rel=>'stylesheet'});
    $session->style->setLink('/extras/yui/build/button/assets/skins/sam/button.css', {type=>'text/css', rel=>'stylesheet'});
    $session->style->setScript('/extras/yui/build/yahoo-dom-event/yahoo-dom-event.js', {type=>'text/javascript'});
    $session->style->setScript('/extras/yui/build/element/element-beta-min.js', {type=>'text/javascript'});
    $session->style->setScript('/extras/yui/build/connection/connection-min.js', {type=>'text/javascript'});
    $session->style->setScript('/extras/yui/build/json/json-min.js', {type=>'text/javascript'});
    $session->style->setScript('/extras/yui/build/paginator/paginator-min.js', {type=>'text/javascript'});
    $session->style->setScript('/extras/yui/build/datasource/datasource.js', {type=>'text/javascript'});
    $session->style->setScript('/extras/yui/build/datatable/datatable-min.js', {type=>'text/javascript'});
    $session->style->setScript('/extras/yui/build/button/button-min.js', {type=>'text/javascript'});
    $session->style->setScript('/extras/VendorPayout/vendorPayout.js', {type=>'text/javascript'});

    # Add css for scheduled payout highlighting
    $session->style->setRawHeadTags(<<CSS);
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
    return $console->render($output, 'Vendor payout'); #$i18n->get("vendors"));
}

1;
