package WebGUI::Shop::Vendor;

use strict;
use Class::InsideOut qw{ :std };
use WebGUI::Shop::Admin;
use WebGUI::Exception::Shop;
use WebGUI::International;


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

A boolean indicating that the vendors should be returned as a hash reference of id/names rather than objects.

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

Constructor. 

=head3 session

A reference to the current session.

=head3 vendorId

A unique id for a vendor.

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

=cut

sub update {
    my ($self, $newProperties) = @_;
    my $id = id $self;
    my @fields = (qw(name));
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
    $f->text(name=>'name', label=>$i18n->get('name'),defaultValue=>$properties->{name});
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
        name        => $form->get("name","text"),              
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


1;
