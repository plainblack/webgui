package WebGUI::Session::Id;


=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2006 Plain Black Corporation.
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
use Time::HiRes qw( gettimeofday usleep );



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

=head2 generate

This function generates a global unique id.

=cut

sub generate {
	my $self = shift;
  	my($s,$us)=gettimeofday();
  	my($v)=sprintf("%09d%06d%10d%06d%255s",rand(999999999),$us,$s,$$,$self->session->config->getFilename);
	my $id = Digest::MD5::md5_base64($v);
	$id =~ s/\+/_/g;
	$id =~ s/\//-/g;
	if ($id =~ /^0/) { # Can't start with 0 because that can cause problems with 0x (hex) and 0b (bin) in perl
		$id = $self->generate();
	}
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
	srand;
	bless {_session=>$session}, $class;
}

#-------------------------------------------------------------------

=head2 session ( ) 

Returns a reference to the current session.

=cut

sub session {
	my $self = shift;
	return $self->{_session};
}


1;


