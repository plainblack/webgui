package WebGUI::Crypt;

use strict;
use Tie::IxHash;
use Class::InsideOut qw{ :std };
use WebGUI::Exception;
use WebGUI::Pluggable;
use English qw( -no_match_vars );

=head1 NAME

Package WebGUI::Crypt

=head1 DESCRIPTION

Package for interfacing with Crypt provider.

=head1 SYNOPSIS

 use WebGUI::Crypt;

 my $crypt = WebGUI::Crypt->new($session,$config);
 my $crypt2 = $session->crypt;
 my $ciphertext = $crypt->encrypt("Plain Text");
 my $plaintext = $crypt->decrypt($ciphertext);
 $crypt->disconnect;
 
=head1 METHODS

These methods are available from this package:

=cut

# InsideOut object properties
readonly session => my %session;    # WebGUI::Session object
public provider => my %provider;

#-------------------------------------------------------------------

=head2 new ( session, config )

Constructor.
=head3 session

A reference to the current session.

=head3 config

Crypt config

=cut

sub new {
    my ( $class, $session, $arg_ref ) = @_;

    # Check arguments..
    if ( !defined $session || !$session->isa('WebGUI::Session') ) {
        WebGUI::Error::InvalidParam->throw(
            param => $session,
            error    => 'Need a session.'
        );
    }
    if ( ref $arg_ref ne 'HASH' ) {
        WebGUI::Error::InvalidParam->throw(
            param => $arg_ref,
            error => 'Need a valid WebGUI::Crypt config.'
        );
    }
    if (!$arg_ref->{provider}) {
        WebGUI::Error::InvalidParam->throw(
            param => $arg_ref,
            error => 'WebGUI::Crypt provider must be specified in config.'
        );
    }
    
    my $module = $arg_ref->{provider};
    # Try loading the Provider..
    eval {WebGUI::Pluggable::load($module)};
    if (Exception::Class->caught()) {
        WebGUI::Error::Pluggable::LoadFailed->throw(
            error  => $EVAL_ERROR,
            module => $module,
        );
    }
    
    # Instantiate the Provider..
    my $provider = eval { WebGUI::Pluggable::run( $module, 'new', [$session, $arg_ref] ); };
    if (Exception::Class->caught()) {
        WebGUI::Error::Pluggable::RunFailed->throw(
            error      => $EVAL_ERROR,
            module     => $module,
            subroutine => 'new',
            params     => [$session, $arg_ref],
        );
    }

    # Register Class::InsideOut object..
    my $self = register $class;

    # Initialise object properties..
    my $id = id $self;
    $session{$id} = $session;
    $provider{$id} = $provider;
    return $self;
}

#-------------------------------------------------------------------

=head2 encrypt ( $plaintext )

Encrypt some plaintext

=cut

sub encrypt {
    my ($self, $plaintext) = @_;
    return $self->provider->encrypt($plaintext);
}

#-------------------------------------------------------------------

=head2 encrypt_hex ( $plaintext )

Encrypt some plaintext

=cut

sub encrypt_hex {
    my ($self, $plaintext) = @_;
    return $self->provider->encrypt_hex($plaintext);
}

#-------------------------------------------------------------------

=head2 decrypt ( $ciphertext )

Decrypt some ciphertext

=cut

sub decrypt {
    my ($self, $ciphertext) = @_;
    return $self->provider->decrypt($ciphertext);
}

#-------------------------------------------------------------------

=head2 decrypt_hex ( $ciphertext )

Decrypt some ciphertext

=cut

sub decrypt_hex {
    my ($self, $ciphertext) = @_;
    return $self->provider->decrypt_hex($ciphertext);
}

1;

