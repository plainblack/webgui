package WebGUI::Collateral;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2003 Plain Black LLC.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use WebGUI::Attachment;
use WebGUI::DateTime;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Utility;

our @ISA = qw(WebGUI::Attachment);

=head1 NAME

Package WebGUI::Collateral

=head1 DESCRIPTION

Package to manipulate items in WebGUI's collateral manager.

=head1 SYNOPSIS

 use WebGUI::Collateral;

 $collateral = WebGUI::Collateral->new(1234);

 $collateral = WebGUI::Collateral->find("My Snippet");

 $collateral->delete;
 $collateral->deleteFile;
 $collateral->get("parameters");
 $collateral->set(\%hash);

=head1 SEE ALSO

This package is derived from WebGUI::Attachment. See that package for documentation of its methods.

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------
# extended only to save info to database
sub createThumbnail {
        $_[0]->SUPER::createThumbnail($_[1]);
        if ($_[1] != $_[0]->get("thumbnailSize")) {
		$_[0]->set({thumbnailSize=>$_[1]});
        }
}


#-------------------------------------------------------------------

=head2 delete ( )

Delete's this collateral item.

=cut

sub delete {
        $_[0]->deleteNode;
	WebGUI::SQL->write("delete from collateral where collateralId=".$_[0]->get("collateralId"));
}


#-------------------------------------------------------------------

=head2 deleteFile ( )

Deletes the file attached to this collateral item.

=cut

sub deleteFile {
        $_[0]->SUPER::delete;
	WebGUI::SQL->write("update collateral set filename='' where collateralId=".$_[0]->get("collateralId"));
	$_[0]->{_properties}{filename}='';
}


#-------------------------------------------------------------------

=head2 find ( name )

An alternative to the constructor "new", use find as a constructor by name rather than id.

=over

=item name

The name of the collateral item you wish to instanciate.

=back

=cut

sub find {
	my ($collateralId) = WebGUI::SQL->quickArray("select collateralId from collateral where name=".quote($_[1]));
	return WebGUI::Collateral->new($collateralId);
}

#-------------------------------------------------------------------

=head2 get ( [ propertyName ] )

Returns a hash reference containing all of the properties of this collateral item.

=over

=item propertyName

If an individual propertyName is specified, then only that property value is returned as a scalar.

=back

=cut

sub get {
        if ($_[1] ne "") {
                return $_[0]->{_properties}{$_[1]};
        } else {
                return $_[0]->{_properties};
        }
}


#-------------------------------------------------------------------

=head2 new ( collateralId )

Constructor.

=over

=item collateralId 

The unique identifier for this piece of collateral. If set to "new" an id will be generated.

=back

=cut

sub new {
	my ($class, $collateralId) = @_;
	my $properties;
	if ($collateralId eq "new") {
		$properties = {
			collateralId=>getNextId("collateralId"),
			collateralFolderId=>0,
			collateralType=>"image",
			userId=>$session{user}{userId},
			dateUploaded=>time(),
			thumbnailSize=>$session{setting}{thumbnailSize},
			name=>"untitled",
			username=>$session{user}{username}
			};
		WebGUI::SQL->write("insert into collateral (collateralId, collateralFolderId, collateraltype, userId,
			dateUploaded, thumbnailSize, name, username) values ( ".$properties->{collateralId}.",
			".$properties->{collateralFolderId}.", ".quote($properties->{collateralType}).", 
			".$properties->{userId}.", ".$properties->{dateUploaded}.", ".$properties->{thumbnailSize}.",
			".quote($properties->{name}).", ".quote($properties->{username}).")");
	} else {
		$properties = WebGUI::SQL->quickHashRef("select * from collateral where collateralId=".$collateralId);
	}
	my $self = WebGUI::Attachment->new($properties->{filename},"images",$properties->{collateralId});
	$self->{_properties} = $properties;
	bless $self, $class;
}


#-------------------------------------------------------------------

=head2 set ( properties )

Sets the value of a property for this collateral item. 

=over

=item properties 

A hash reference containing the list of properties to set. The valid property names are "name", "parameters", "userId", "username", "collateralFolderId", "collateralType", and "thumbnailSize". 

If username or userId are not specified, the current user will be used.

=back

=cut

sub set {
        my ($key, $sql, @update, $i);
        my $self = shift;
        my $properties = shift;
        $self->{_properties}->{dateUploaded} = time();
        $properties->{userId} = $session{user}{userId} if ($properties->{userId} eq "");
        $properties->{username} = $session{user}{username} if ($properties->{username} eq "");
        $properties->{thumbnailSize} = $session{setting}{thumbnailSize} if ($properties->{thumbnailSize} eq "");
        $sql = "update collateral set";
        foreach $key (keys %{$properties}) {
                $self->{_property}{$key} = $properties->{$key};
                if (isIn($key, qw(name parameters userId username collateralFolderId collateralType thumbnailSize))) {
                        $sql .= " ".$key."=".quote($properties->{$key}).",";
                }
        }
        $sql .= " dateUploaded=".$self->{_properties}{dateUploaded}."
                where collateralid=".$self->get("collateralId");
        WebGUI::SQL->write($sql);
}


#-------------------------------------------------------------------
# extended only to save info to database
sub save {
	my $filename = $_[0]->SUPER::save($_[1],$_[2],$_[3]);
	if ($filename) {
		WebGUI::SQL->write("update collateral set filename=".quote($filename)
			." where collateralId=".$_[0]->get("collateralId"));
		$_[0]->{_properties}{filename} = $filename;
	}
	return $filename;
}

#-------------------------------------------------------------------
# extended only to save info to database
sub saveFromFilesystem {
        my $filename = $_[0]->SUPER::saveFromFilesystem($_[1],$_[2],$_[3]);
        if ($filename) {
                WebGUI::SQL->write("update collateral set filename=".quote($filename)
                        ." where collateralId=".$_[0]->get("collateralId"));
		$_[0]->{_properties}{filename} = $filename;
        }
        return $filename;
}



1;


