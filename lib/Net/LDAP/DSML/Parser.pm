package Net::LDAP::DSML::Parser; 

use Net::LDAP::Entry;
#use Net::LDAP::Schema;
use vars qw($VERSION);

$VERSION = "0.06";


# dsml:entry

*{'dsml:entry'} = sub {
  my ($self,$tag, %attr) = @_;
  my $entry = $self->{net_ldap_entry} = Net::LDAP::Entry->new;
  $entry->dn( $attr{dn} );
};

*{'dsml:entry_'} = sub {
  my $self = shift;
  if ($self->{net_ldap_entry_handler}) {
    &{$self->{net_ldap_entry_handler}}(delete $self->{net_ldap_entry});
  }
};

# dsml:attr

*{'dsml:attr'} = sub {
  my ($self,$tag, %attr) = @_;
  $self->{net_ldap_attr} = $attr{name};
};

*{'dsml:attr_'} = sub {
  my $self = shift;
  delete $self->{net_ldap_attr};
};


# dsml:value

*{'dsml:value'} = sub {
  my ($self,$tag, %attr) = @_;
  $self->{net_ldap_base64} =
    (exists $attr{encoding} && lc($attr{encoding}) eq 'base64')
      and require MIME::Base64;
};

*{'dsml:value_'} = sub {
  my $self = shift;
  delete $self->{net_ldap_base64};
};



*{'dsml:oc-value'}  = \&{'dsml:value'};
*{'dsml:oc-value_'} = \&{'dsml:value_'};

*{'dsml:objectclass'}  = sub {};
*{'dsml:objectclass_'} = sub {};

*{'dsml:dsml'}  = sub {};
*{'dsml:dsml_'} = sub {};

*{'dsml:directory-entries'}  = sub {};
*{'dsml:directory-entries_'} = sub {};

sub AUTOLOAD {
  my $tag = substr($AUTOLOAD,25);
  die "Unknown tag '$tag'";
}

1;

