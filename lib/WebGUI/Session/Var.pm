package WebGUI::Session::Var;

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
use Scalar::Util qw(weaken);

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

=head2 end ( )

Removes the specified user session from memory and database.

=cut

sub end {
    my $self = shift;
    my $session = $self->session;
    my $id = $self->getId;
    $session->cache->remove($id);
    $session->scratch->deleteAll;
    $session->db->write("delete from userSession where sessionId=?",[$id]);
    delete $session->{_user};
}

#-------------------------------------------------------------------

=head2 get ( varName )

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

=head2 new ( session, sessionId, noFuss )

Constructor. Overwrites the sessionId of $session with its own id.  Returns a var object.

=head3 session

A reference to the session.

=head3 sessionId

The specific sessionId you want to instantiate.

=head3 noFuss

A boolean, that if true will not update the session, or check if it's
expired. This is mainly for WebGUI session maintenance, and shouldn't
normally be used by anyone.

=cut

sub new {
    my ($class, $session, $sessionId, $noFuss) = @_;
    my $self = bless { _session => $session }, $class;
    weaken $self->{_session};
	if ($sessionId eq "") { ##New session
		$self->start(1);
	}
    else { ##existing session requested
        $self->{_var} = $session->cache->get($sessionId);
        unless ($self->{_var}{sessionId} eq $sessionId) {
            $self->{_var} = $session->db->quickHashRef("select * from userSession where sessionId=?",[$sessionId]);
        }
        ##We have to make sure that the session variable has a sessionId, otherwise downstream users of
        ##the object will break
        if ($noFuss && $self->{_var}{sessionId}) {
            $self->session->{_sessionId} = $self->{_var}{sessionId};
            return $self;
        }
		if ($self->{_var}{expires} && $self->{_var}{expires} < time()) { ##Session expired, start a new one with the same Id
			$self->end;
			$self->start(1,$sessionId);
		}
        elsif ($self->{_var}{sessionId} ne "") { ##Fetched an existing session.  Update variables with recent data.
            my $time = time();
            my $timeout = $session->setting->get("sessionTimeout");
			$self->{_var}{lastPageView} = $time;
			$self->{_var}{lastIP} = $session->env->getIp;
			$self->{_var}{expires} = $time + $timeout;
            if ($self->{_var}{nextCacheFlush} > 0 && $self->{_var}{nextCacheFlush} < $time) {
                delete $self->{_var}{nextCacheFlush};
			    $session->db->setRow("userSession","sessionId",$self->{_var});
            }
            else {
                $self->{_var}{nextCacheFlush} = $time + $session->config->get("hotSessionFlushToDb");
                $session->cache->set($sessionId, $self->{_var}, $timeout);
            }
			$self->session->{_sessionId} = $self->{_var}{sessionId};
            return $self;
		}
        else {  ##Start a new default session with the requested, non-existant id.
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

Start a new user session. Returns the user session id.  The session variable's sessionId
is set to the var object's session id.  Also sets the user's CSRF token.

=head3 userId

The user id of the user to create a session for. Defaults to 1 (Visitor).

=head3 sessionId

Session id will be generated if not specified. In almost every case you should let the system generate the session id.

=cut

sub start {
	my $self = shift;
	my $userId = shift;
	$userId = 1 if ($userId eq "");
	my $sessionId = shift;
    my $session = $self->session;
    my $id = $session->id;
	$sessionId = $id->generate if ($sessionId eq "");
    my $timeout = $session->setting->get('sessionTimeout');
	my $time = time();
	$self->{_var} = {
		expires      => $time + $timeout,
		lastPageView => $time,
		lastIP       => $session->env->getIp,
		adminOn      => 0,
		userId       => $userId
	};
    $self->session->{_sessionId} = $sessionId;
    $session->cache->set($sessionId, $self->{_var}, $timeout);
    delete $self->{_var}{nextCacheFlush};
	$session->db->setRow("userSession","sessionId",$self->{_var},$sessionId);
	$self->{_sessionId} = $sessionId;
    $session->scratch->set('webguiCsrfToken', $id->generate); # create cross site request forgery token
}

#-------------------------------------------------------------------

=head2 switchAdminOff ( )

Disables admin mode.

=cut

sub switchAdminOff {
    my $self = shift;
    $self->{_var}{adminOn} = 0;
    my $session = $self->session;
    $session->cache->set($self->getId, $self->{_var}, $session->setting->get('sessionTimeout'));
    delete $self->{_var}{nextCacheFlush};
    $session->db->setRow("userSession","sessionId", $self->{_var});
}

#-------------------------------------------------------------------

=head2 switchAdminOn ( )

Enables admin mode.

=cut

sub switchAdminOn {
    my $self = shift;
    $self->{_var}{adminOn} = 1;
    my $session = $self->session;
    $session->cache->set($self->getId, $self->{_var}, $session->setting->get('sessionTimeout'));
    delete $self->{_var}{nextCacheFlush};
    $self->session->db->setRow("userSession","sessionId", $self->{_var});
}


1;
