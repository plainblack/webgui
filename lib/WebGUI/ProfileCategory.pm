package WebGUI::ProfileCategory;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2012 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use WebGUI::ProfileField;
use WebGUI::SQL;
use WebGUI::Operation::Shared;


=head1 NAME

Package WebGUI::ProfileCategory

=head1 DESCRIPTION

This package is used to manipulate the organization of the user profiling system. 

=head1 SYNOPSIS

 use WebGUI::ProfileCategory;

=head1 METHODS

These methods are available from this package:

=cut

#-------------------------------------------------------------------
sub _reorderCategories {
	my $self = shift;
        my ($sth, $i, $id);
        $sth = $self->session->db->read("select profileCategoryId from userProfileCategory order by sequenceNumber");
        while (($id) = $sth->array) {
                $i++;
                $self->session->db->write("update userProfileCategory set sequenceNumber='$i' where profileCategoryId=".$self->session->db->quote($id));
        }       
        $sth->finish;
}  

#-------------------------------------------------------------------

=head2 create ( session, [ properties] ) 

Add a new category to the system. Returns a WebGUI::ProfileCategory object if created successfully, otherwise returns undef.

=head3 session

A reference to the current session.

=head3 properties

A hash reference containing the properties of this field. See the set() method for details.

=cut

sub create {
	my $class = shift;
	my $session = shift;
	my $properties = shift;
        my ($sequenceNumber) = $session->db->quickArray("select max(sequenceNumber) from userProfileCategory");
 	my $id = $session->db->setRow("userProfileCategory","profileCategoryId",{profileCategoryId=>"new", sequenceNumber=>$sequenceNumber+1});
	my $self = $class->new($session,$id);
	$self->set($properties);
	return $self;
}

#-------------------------------------------------------------------

=head2 delete ( )

Deletes this category and all fields attached to it.

=cut

sub delete {
	my $self = shift;
	foreach my $field (@{$self->getFields}) {
		$field->delete;
	}
	$self->session->db->deleteRow("userProfileCategory","profileCategoryId",$self->getId);
}

#-------------------------------------------------------------------

=head2 get ( [ property ] )

Returns a hash reference of all the properties of the category.

=head3 property

If specified, the value of an individual property is returned.

=cut

sub get {
        my $self = shift;
        my $propertyName = shift;
        if (defined $propertyName) {
                return $self->{_properties}{$propertyName};
        }
        return $self->{_properties};
}

#-------------------------------------------------------------------

=head2 getCategories ( session , options )

Returns an array reference of all WebGUI::ProfileCategory objects in order of sequence. This is a class method.

=head3 session

WebGUI::Session object

=head3 options

hash reference of options for returning categories.  Passing in more than one option will limit the results to the intersection
all the flags passed.

=head4 editable

boolean flag which which indicates a specific status of the editable flag for the profile category.
If no editable flag is passed in all editable states are returned

=head4 visible

boolean flag which indicates the status of the visible flag for the profile category.
If no visible flag is passed in all visible states are returend

=cut

sub getCategories {
	my $class       = shift;
	my $session     = shift;
    my $options     = shift || {};

	my $categories  = [];
    my $whereClause = "";
    my $bindvars    = [];

    foreach my $key (keys %{$options}) {
        next unless $key ~~ [qw(editable visible)];
        $whereClause .= " and" unless ($whereClause eq "");
        $whereClause .= " $key=?";
        push(@{$bindvars},$options->{$key});
    }

    $whereClause = "where ".$whereClause unless ($whereClause eq "");

    my $sql = qq{
        select
            profileCategoryId
        from
            userProfileCategory
        $whereClause
        order by sequenceNumber
    };

 	foreach my $id ($session->db->buildArray($sql,$bindvars)) {
		push(@{$categories},WebGUI::ProfileCategory->new($session,$id));
	}
	return $categories;
}


#-------------------------------------------------------------------

=head2 getFields ( options )

Returns an array reference of all WebGUI::ProfileField objects that are part of this category in order of sequence.

=head3 options

hash reference of options for returning fields.  Passing in more than one option will limit the results to the intersection
all the flags passed.

=head4 editable

boolean flag which which indicates a specific status of the editable flag for the profile category.
If no editable flag is passed in all editable states are returned

=head4 visible

boolean flag which indicates the status of the visible flag for the profile category.
If no visible flag is passed in all viewable states are returend

=head4 required

boolean flag which indicates the status of the required flag for the profile category.
If no required flag is passed in all required states are returend

=cut

sub getFields {
	my $self        = shift;
	my $options     = shift || {};
    my $session     = $self->session;
	my $fields      = [];
    
    my $whereClause = "where profileCategoryId=? ";
    my $bindvars    = [$self->getId];

    foreach my $key (keys %{$options}) {
        #Skip bad stuff that will crash the query
        next unless $key ~~ [qw(editable visible required)];
        $whereClause .= " and $key=?";
        push(@{$bindvars},$options->{$key});
    }

    my $sql = qq{
        select
            fieldName
        from
            userProfileField
        $whereClause
        order by sequenceNumber
    };

	foreach my $fieldName ($session->db->buildArray($sql,$bindvars)) {
		push(@{$fields},WebGUI::ProfileField->new($session,$fieldName));
	}
	return $fields;
}

#-------------------------------------------------------------------

=head2 getId ( )

Returns the unique ID for this category.

=cut

sub getId {
	my $self = shift;
	return $self->get("profileCategoryId");
}

#-------------------------------------------------------------------

=head2 getLabel ( )

Returns the eval'd label for this category.

=cut

sub getLabel {
        my $self = shift;
        return WebGUI::Operation::Shared::secureEval($self->session,$self->get("label"));
}

#-------------------------------------------------------------------

=head2 getShortLabel ( )

Returns the eval'd label for this category.

=cut

sub getShortLabel {
    my $self = shift;
    return WebGUI::Operation::Shared::secureEval($self->session,$self->get("shortLabel"));
}


#-------------------------------------------------------------------

=head2 hasProtected ( )

Returns a boolean indicating whether any of the category's fields are protected.

=cut

sub hasProtected {
	my $self = shift;
    my $protected=0;
    FIELD: foreach my $field (@{ $self->getFields }) {
        if ($field->isProtected) {
            $protected=1;
            last FIELD;
        }
    }
	return $protected;
}


#-------------------------------------------------------------------

=head2 isEditable ( )

Returns a boolean indicating whether the category's fields may be edited by a user.

=cut

sub isEditable {
	my $self = shift;
	return $self->get("editable");
}


#-------------------------------------------------------------------

=head2 isProtected ( )

Returns a boolean indicating whether the category may be deleted.

=cut

sub isProtected {
	my $self = shift;
	return $self->get("protected");
}

#-------------------------------------------------------------------

=head2 isViewable ( )

Returns a boolean indicating whether the category's fields may be viewed by a user.

=cut

sub isViewable {
	my $self = shift;
	return $self->get("visible");
}


#-------------------------------------------------------------------

=head2 moveDown ( )

Moves this category down one position.

=cut

sub moveDown {
	my $self = shift;
        my ($id, $thisSeq);
        ($thisSeq) = $self->session->db->quickArray("select sequenceNumber from userProfileCategory where profileCategoryId=".$self->session->db->quote($self->getId));
        ($id) = $self->session->db->quickArray("select profileCategoryId from userProfileCategory where sequenceNumber=$thisSeq+1");
        if ($id ne "") {
                $self->session->db->write("update userProfileCategory set sequenceNumber=sequenceNumber+1 where profileCategoryId=".$self->session->db->quote($self->getId));
                $self->session->db->write("update userProfileCategory set sequenceNumber=sequenceNumber-1 where profileCategoryId=".$self->session->db->quote($id));
                $self->_reorderCategories();
        }
}

#-------------------------------------------------------------------

=head2 moveUp ( )

Moves this field up one position.

=cut

sub moveUp {
	my $self = shift;
	my ($id, $thisSeq);
        ($thisSeq) = $self->session->db->quickArray("select sequenceNumber from userProfileCategory where profileCategoryId=".$self->session->db->quote($self->getId));
        ($id) = $self->session->db->quickArray("select profileCategoryId from userProfileCategory where sequenceNumber=$thisSeq-1");
        if ($id ne "") {
                $self->session->db->write("update userProfileCategory set sequenceNumber=sequenceNumber-1 where profileCategoryId=".$self->session->db->quote($self->getId));
                $self->session->db->write("update userProfileCategory set sequenceNumber=sequenceNumber+1 where profileCategoryId=".$self->session->db->quote($id));
                $self->_reorderCategories();
        }
}

#-------------------------------------------------------------------

=head2 new ( session, id )

Constructor.

=head3 session

A reference to the current session.

=head3 id

The unique id of this category.

=cut

sub new {
	my $class = shift;
	my $session = shift;
	my $id = shift;
	return undef unless ($id);
	my $properties = $session->db->getRow("userProfileCategory","profileCategoryId",$id);
	bless {_session=>$session, _properties=>$properties}, $class;
}


#-------------------------------------------------------------------

=head2 session ( )

A reference to the current session.

=cut

sub session {
	my $self = shift;
	return $self->{_session};
}

#-------------------------------------------------------------------

=head2 set ( properties )

Update the profile field properties.  Any property that is missing, or empty will be
replaced with a default.

=head3 properties

A hash reference containing the properties to be updated.

=head4 label

A perl structure that will return a scalar. Defaults to 'Undefined'.

=head4 shortLabel

A perl structure that will return a scalar.  Defaults to 'Undefined'.

=head4 visible

A boolean indicating whether the fields in this category should be visible when a user views a user's profile.

=head4 editable

A boolean indicating whether the user can edit the fields under this category.

=head4 protected

A boolean indicating whether the category can be deleted.

=cut

sub set {
	my $self = shift;
	my $properties = shift;
	$properties->{visible} = 0 unless ($properties->{visible} == 1);
	$properties->{editable} = 0 unless ($properties->{editable} == 1);
	$properties->{protected} = 0 unless ($properties->{protected} == 1);
	$properties->{label} = 'Undefined' if ($properties->{label} =~ /^[\"\']*$/);
    $properties->{shortLabel} = 'Undefined' if ($properties->{shortLabel} =~ /^[\"\']*$/);
	$properties->{profileCategoryId} = $self->getId;
	$self->session->db->setRow("userProfileCategory","profileCategoryId",$properties);
}


1;


