# Copyright (c) 1998-2000 Graham Barr <gbarr@pobox.com>. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.

package Net::LDAP::Bind;

use strict;
use Net::LDAP qw(LDAP_SASL_BIND_IN_PROGRESS LDAP_DECODING_ERROR);
use Net::LDAP::Message;
use vars qw(@ISA);

@ISA = qw(Net::LDAP::Message);

sub _sasl_info {
  my $self = shift;
  @{$self}{qw(dn saslctrl sasl)} = @_;
}

sub decode {
  my $self = shift;
  my $result = shift;
  my $bind = $result->{protocolOp}{bindResponse}
     or $self->set_error(LDAP_DECODING_ERROR,"LDAP decode error")
    and return;

  return $self->SUPER::decode($result)
    unless $bind->{resultCode} == LDAP_SASL_BIND_IN_PROGRESS;

  # tell our LDAP client to forget us as this message has now completed
  # all communications with the server
  $self->parent->_forgetmesg($self);

  $self->{mesgid} = Net::LDAP::Message->NewMesgID(); # Get a new message ID

  my $sasl = $self->{sasl};
  my $ldap = $self->parent;
  my $resp = $sasl->challenge($bind->{serverSaslCreds});

  $self->encode(
    bindRequest => {
    version => $ldap->version,
    name    => $self->{dn},
    authentication => {
      sasl    => {
        mechanism   => $sasl->name,
        credentials => $resp
      }
    },
    control => $self->{saslcontrol}
  });

  $ldap->_sendmesg($self);
}

1;
