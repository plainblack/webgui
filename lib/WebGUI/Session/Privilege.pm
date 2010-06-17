package WebGUI::Session::Privilege;

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
use WebGUI::International;
use WebGUI::Operation::Auth;
use Scalar::Util qw(weaken);

=head1 NAME

Package WebGUI::Session::Privilege

=head1 DESCRIPTION

This package provides access to the WebGUI security system and security messages.

=head1 SYNOPSIS



 use WebGUI::Session::Privilege;

 $privilege = $session->privilege;
 $privilege = WebGUI::Session::Privilege->new($session);
 
 $html = $privilege->adminOnly();
 $html = $privilege->insufficient();
 $html = $privilege->noAccess();
 $html = $privilege->notMember();
 $html = $privilege->vitalComponent();

=head1 METHODS 

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 adminOnly ( )

Returns a message stating that this functionality can only be used by administrators. This method also sets the HTTP header status to 401.

=cut

sub adminOnly {
	my $self = shift;
	my $i18n = WebGUI::International->new($self->session);
    $self->session->http->setStatus(401);
        my $output = '<h1>'.$i18n->get(35).'</h1>';
	$output .= $i18n->get(36);
	return $self->session->style->userStyle($output);
}

#-------------------------------------------------------------------

=head2 insufficient ( )

Returns a message stating that the user does not have the required privileges to perform the operation they requested. This method also sets the HTTP header status to 401. 

=cut

sub insufficient {
	my $self = shift;
    my $noStyle = shift;
	my $i18n = WebGUI::International->new($self->session);
	$self->session->http->setStatus(401);
	my $output = '<h1>'.$i18n->get(37).'</h1>';
    if ($noStyle) {
        $self->session->style->useEmptyStyle(1);
        $output .= $i18n->get('bare insufficient');
    }
    else {
        $output .= $i18n->get(38);
    }
	return $self->session->style->userStyle($output);
}

#-------------------------------------------------------------------

=head2 locked ( )

Returns a message stating that Asset is locked.  This is a variation of insufficient with
a different error message.

=cut

sub locked {
	my $self = shift;
    my $noStyle = shift;
	my $i18n = WebGUI::International->new($self->session);
	$self->session->http->setStatus(401);
	my $output = '<h1>'.$i18n->get(37).'</h1>';
    if ($noStyle) {
        $self->session->style->useEmptyStyle(1);
        $output .= $i18n->get('asset locked');
    }
    else {
        $output .= $i18n->get('asset locked');
    }
	return $self->session->style->userStyle($output);
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
    my $self = bless { _session => $session }, $class;
    weaken $self->{_session};
    return $self;
}


#-------------------------------------------------------------------

=head2 noAccess ( )

Returns a message stating that the user does not have the privileges necessary to access this page. This method also sets the HTTP header status to 401.

=cut

sub noAccess {
	my $self = shift;
	$self->session->http->setStatus(401);
   	if ($self->session->user->isVisitor) {
      		return WebGUI::Operation::Auth::www_auth($self->session, "init");
   	} else {
		my $i18n = WebGUI::International->new($self->session);
      		my $output = '<h1>'.$i18n->get(37).'</h1>';
      		$output .= $i18n->get(39);
      		$output .= '<p>';
		return $self->session->style->userStyle($output);
   	}
}

#-------------------------------------------------------------------

=head2 notMember ( )

Returns a message stating that the user they requested information about is no longer active on this server. This method also sets the HTTP header status to 400.

=cut

sub notMember {
	my $self = shift;
	my $i18n = WebGUI::International->new($self->session);
	$self->session->http->setStatus(400);
	my ($output);
	$output = '<h1>'.$i18n->get(345).'</h1>';
	$output .= $i18n->get(346);
	return $self->session->style->userStyle($output);
}

#-------------------------------------------------------------------

=head2 session 

Returns a reference to the current session.

=cut

sub session {
	my $self = shift;
	return $self->{_session};
}


#-------------------------------------------------------------------

=head2 vitalComponent ( )

Returns a message stating that the user made a request to delete something that should never delete. This method also sets the HTTP header status to 403. 

=cut

sub vitalComponent {
	my $self = shift;
	my $i18n = WebGUI::International->new($self->session);
	$self->session->http->setStatus(403);
	my ($output);
        $output = '<h1>'.$i18n->get(40).'</h1>';
	$output .= $i18n->get(41);
	$output .= '<p>';
	return $self->session->style->userStyle($output);
}



1;

