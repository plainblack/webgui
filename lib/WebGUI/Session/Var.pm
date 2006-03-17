package WebGUI::Session::Var;

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

Package WebGUI::Session::Var

=head1 DESCRIPTION

This package is the persistence layer for WebGUI session variables.

=head1 SYNOPSIS

$var = WebGUI::Session::Var->new($session);

$value = $var->get('lastIP');

$var->start;
$var->end;

$boolean = $var->isAdminOn;

$var->switchAdminOff;
$var->switchAdminOn;


=head1 METHODS

These methods are available from this package:

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
        
=head2 end ( ) 

Removes the specified user session from memory and database.

=cut

sub end {
        my $self = shift;
        $self->session->scratch->deleteAll;
        $self->session->db->write("delete from userSession where sessionId=".$self->session->db->quote($self->getId));
        delete $self->session->{_user};
	$self->DESTROY;
}

#-------------------------------------------------------------------

=head2 get( varName ) 

Retrieves the current value of a session variable.

=head3 varName

The name of the variable.

=head4 lastIP

The last IP address the user came from.

=head4 lastPageView

The epoch date of the last interaction with the session.

=head4 userId

The unique id of the user this session currently bound to.

=head4 adminOn

A boolean indicating whether this session has admin mode enabled or not.

=head4 sessionId

The sessionId associated with this session.

=head4 expires

The epoch date when this user session will expire if it's not accessed again by then.

=cut

sub get {
	my $self = shift;
	my $var = shift;
	return $self->{_var}{$var};
}

#-------------------------------------------------------------------

=head2 getId ( )

Returns the ID of the current session.

=cut

sub getId {
	my $self = shift;
	$self->get("sessionId");
}


#-------------------------------------------------------------------
        
=head2 isAdminOn  ( )
        
Returns a boolean indicating whether admin mode is on or not.

=cut

sub isAdminOn {
        my $self = shift;
        return $self->get("adminOn");
}

#-------------------------------------------------------------------

=head2 new ( session, noFuss )

Constructor. Returns a var object.

=head3 session

A reference to the session.

=head3 noFuss

A boolean, that if true will not update the session, or check if it's expired. This is mainly for WebGUI session maintenance, and shouldn't normally be used by anyone.

=cut

sub new {
	my $class = shift;
	my $session = shift;
	my $self = bless {_session=>$session}, $class;
	my $sessionId = shift;
	my $noFuss = shift;
	if ($sessionId eq "") {
		$self->start(1);
	} else {
		$self->{_var} = $session->db->quickHashRef("select * from userSession where sessionId=?",[$sessionId]);
		return $self if $noFuss && $self->{_var}{sessionId};
		if ($self->{_var}{expires} && $self->{_var}{expires} < $session->datetime->time()) {
			$self->end;
			$self->start(1,$sessionId);
		} elsif ($self->{_var}{sessionId} ne "") {
			$self->{_var}{lastPageView} = $session->datetime->time();
			$self->{_var}{lastIP} = $session->env->get("REMOTE_ADDR");
			$self->{_var}{expires} = $session->datetime->time() + $session->setting->get("sessionTimeout");
			$self->session->{_sessionId} = $self->{_var}{sessionId};
			$session->db->setRow("userSession","sessionId",$self->{_var});
		} else {
			$self->start(1,$sessionId);
		}
	}
	return $self;
}


#-------------------------------------------------------------------

=head2 session ( )

Returns a reference to the session object.

=cut

sub session {
	my $self = shift;
	return $self->{_session};
}


#-------------------------------------------------------------------
                
=head2 start ( [ userId, sessionId ] )
                
Start a new user session. Returns the session id.

=head3 userId

The user id of the user to create a session for. Defaults to 1 (Visitor).

=head3 sessionId

Session id will be generated if not specified. In almost every case you should let the system generate the session id.

=cut

sub start {
	my $self = shift;
	my $userId = shift || 1;
	my $sessionId = shift || $self->session->id->generate;
	$self->{_var} = {
		expires=>$self->session->datetime->time() + $self->session->setting->get("sessionTimeout"),
		lastPageView=>$self->session->datetime->time(),
		lastIP => $self->session->env->get("REMOTE_ADDR"),
		adminOn => 0,
		userId => $userId
	};
	$self->{_var}{sessionId} = $sessionId;
	$self->session->db->setRow("userSession","sessionId",$self->{_var},$sessionId);
	$self->session->{_sessionId} = $sessionId;
}

#-------------------------------------------------------------------

=head2 switchAdminOff ( )

Disables admin mode.

=cut

sub switchAdminOff {
        my $self = shift;
        $self->{_var}{adminOn} = 0;
        $self->session->db->setRow("userSession","sessionId", $self->{_var});
}

#-------------------------------------------------------------------

=head2 switchAdminOn ( )

Enables admin mode.

=cut

sub switchAdminOn {
        my $self = shift;
        $self->{_var}{adminOn} = 1;
        $self->session->db->setRow("userSession","sessionId", $self->{_var});
}



1;
