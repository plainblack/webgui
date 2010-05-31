package WebGUI::Session::Id;


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
use Digest::MD5;
use Scalar::Util qw( weaken );
use Time::HiRes qw( gettimeofday usleep );
use MIME::Base64;

my $idValidator = qr/^[A-Za-z0-9_-]{22}$/;

=head1 NAME

Package WebGUI::Session::Id;

=head1 DESCRIPTION

This package generates global unique ids, sometimes called GUIDs. A global unique ID is guaranteed to be unique everywhere and at everytime.

B<NOTE:> There is no such thing as perfectly unique ID's, but the chances of a duplicate ID are so minute that they are effectively unique.

=head1 SYNOPSIS

 my $id = $session->id->generate;

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 DESTROY ( )

Deconstructor.

=cut

sub DESTROY {
        my $self = shift;
        undef $self;
}

#-------------------------------------------------------------------

=head2 fromHex ( hexId )

Returns the guid corresponding to hexId.  Converse of toHex.

=head3 hexId

Hex value to convert to guid.

=cut

sub fromHex {
    my $self  = shift;
    my $hexId = shift;
    my $binId = pack( 'H2' x 16, unpack( 'A2' x 16, $hexId ) );
    my $id    = substr( encode_base64($binId), 0, 22 );
    $id =~ tr{+/}{_-};
    return $id;
}

#-------------------------------------------------------------------

=head2 getValidator

Get the regular expression used to validate generated GUIDs.  This is just to prevent
regular expressions from being duplicated all over the place.

=cut

sub getValidator {
	return $idValidator;
}

#-------------------------------------------------------------------

=head2 generate

This function generates a global unique id.

=cut

sub generate {
	my $self = shift;
  	my($s,$us)=gettimeofday();
  	my($v)=sprintf("%09d%06d%10d%06d%255s",rand(999999999),$us,$s,$$,$self->session->config->getFilename);
	my $id = Digest::MD5::md5_base64($v);
	$id =~ tr{+/}{_-};
	return $id;
}

#-------------------------------------------------------------------

=head2 new ( session )

Constructor.

=head3 session

A reference to the current session.

=cut

sub new {
	my $class = shift;
	my $session = shift;
	my $self = bless {_session=>$session}, $class;
        weaken( $self->{_session} );
        return $self;
}

#-------------------------------------------------------------------

=head2 session ( ) 

Returns a reference to the current session.

=cut

sub session {
	my $self = shift;
	return $self->{_session};
}


#-------------------------------------------------------------------

=head2 toHex ( guid )

Returns the hex value of a guid

=head3 guid

guid to convert to hex value.

=cut

sub toHex {
	my $self = shift;
    my $id   = shift;
    $id =~ tr{_-}{+/};
    my $bin_id = decode_base64("$id==");
    my $hex_id = sprintf('%*v02x', '', $bin_id);
    return $hex_id
}


#-------------------------------------------------------------------

=head2 valid ( $idString ) 

Returns true if $idString is a valid WebGUI guid.

=cut

sub valid {
	my ($self, $idString) = @_;
	return $idString =~ m/$idValidator/;
}


1;


