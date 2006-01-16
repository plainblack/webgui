package WebGUI::Session::Scratch;

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

=head1 NAME

Package WebGUI::Session::Scratch

=head1 DESCRIPTION

This package allows you to attach arbitrary data to the session that lasts until the session dies.

=head1 SYNOPSIS

$scratch = WebGUI::Session::Scratch->new($session);

$scratch->delete('temp');
$scratch->set('temp',$value);
$value = $scratch->get('temp');

$scratch->deleteAll;
$scratch->deleteName('temp');


=head1 METHODS

These methods are available from this package:

=cut



#-------------------------------------------------------------------

=head2 delete ( name )

Deletes a scratch variable.

=head3 name

The name of the scratch variable.

=cut

sub delete {
	my $self = shift;
	my $name = shift;
	return undef unless ($name);
	delete $self->{_data}{$name};
	$self->session->db->deleteRow("userSessionScratch","sessionId",$self->{_sessionId});
}


#-------------------------------------------------------------------

=head2 deleteAll ( )

Deletes all scratch variables for this session.

=cut

sub deleteAll {
	my $self = shift;
	delete $self->{_data};
	$self->session->db->write("delete from userSessionScratch where sessionId=".$self->session->db->quote($self->{_sessionId}));
}


#-------------------------------------------------------------------

=head2 deleteName ( name )

Deletes a scratch variable for all users. This function must be used with care.

=head3 name

The name of the scratch variable.

=cut

sub deleteName {
	my $self = shift;
	my $name = shift;
	return undef unless ($name);	
	delete $self->{_data}{$name};
	$self->session->db->write("delete from userSessionScratch where name=".$self->session->db->quote($name));
}


#-------------------------------------------------------------------

=head DESTROY ( )

Deconstructor.

=cut

sub DESTROY {
        my $self = shift;
        undef $self;
}


#-------------------------------------------------------------------

=head2 get( varName ) 

Retrieves the current value of a scratch variable.

=head3 varName

The name of the variable.

=cut

sub get {
	my $self = shift;
	my $var = shift;
	return $self->{_data}{$var};
}


#-------------------------------------------------------------------

=head2 new ( session )

Constructor. Returns a scratch object.

=head3 session

The current session.

=cut

sub new {
	my $class = shift;
	my $session = shift; use WebGUI; WebGUI::dumpSession($session);
	my $data = $session->db->buildHashRef("select name,value from userSessionScratch where sessionId=".$session->db->quote($session->getId));
	bless {_session=>$session,_sessionId=>$session->getId, _data=>$data}, $class;
}


#-------------------------------------------------------------------

=head2 session ( )

Returns a reference to the WebGUI::Session object.

=cut

sub session {
	my $self = shift;
	return $self->{_session};
}


#-------------------------------------------------------------------

=head2 set ( name, value )

Sets a scratch variable for this user session. 

=head3 name

The name of the scratch variable.

=head3 value

The value of the scratch variable.  Must be a string no longer than 16000 characters.

=cut

sub set {
	my $self = shift;
	my $name = shift;
	my $value = shift;
	return undef unless ($name);
	$self->{_data}{$name} = $value;
	$self->session->db->write("replace into userSessionScratch (sessionId, name, value) values (".$self->session->db->quoteAndJoin([$self->{_sessionId}, $name, $value]).")");
}


1;
