package WebGUI::Profile;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2002 Plain Black LLC.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use WebGUI::International;
use WebGUI::SQL;
use WebGUI::URL;

=head1 NAME

Package WebGUI::Profile

=head1 SYNOPSIS

 use WebGUI::Profile;
 $p = WebGUI::Profile->new(39);

=head1 DESCRIPTION

Package that allows getting and setting of user profile information.

=head1 METHODS

These methods are available from this class:

=cut


#-------------------------------------------------------------------

=head2 get ( )

Returns a profile hash for this user.

=cut

sub get {
        my (%profile);
	%profile = WebGUI::SQL->buildHash("select fieldName, fieldData from profileData where userId=$_[0]->{_userId}");
	return %profile;
}


#-------------------------------------------------------------------

=head2 new ( userId )

Constructor.

=over

=item userId 

 The userId for the profile you wish to manipulate.

=back

=cut

sub new {
        my ($class);
	$class = shift;
        bless {_userId => $_[1]}, $class;
}


#-------------------------------------------------------------------

=head2 setAttribute ( attributeName, value ) 

Sets the value of an attribute.

=over

=item attributeName

An attribute of the user profile.

=item value

The value to set the above named attribute to.

=back

=cut

sub setAttribute {
	WebGUI::SQL::write("delete from profileData where userId=$_[0]->{_userId} and fieldName=".quote($_[1]));
	WebGUI::SQL::write("insert into profileData values ($_[0]->{_userId}, ".quote($_[1]).", ".quote($_[2]).")");
	if ($session{user}{userId} == $_[0]->{_userId}) {
		$session{user}{$_[1]} = $_[2];
	}
}




1;


