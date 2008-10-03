package WebGUI::Crypt::Simple;
use Class::InsideOut qw{ :std };
use Crypt::CBC;

=head1 NAME

Package WebGUI::Crypt::Simple

=head1 DESCRIPTION

Simple Crypt provider for WebGUI

=head1 SYNOPSIS
 
=head1 METHODS

These methods are available from this package:

=cut

# InsideOut object properties
readonly session => my %session;    # WebGUI::Session object
public provider => my %provider;
private cipher => my %cipher;

#-------------------------------------------------------------------

=head2 new ( session, config )

Constructor.
=head3 session

A reference to the current session.

=head3 config

Crypt config object

=cut
sub new {
    my ($session, $arg_ref) = @_;
    
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
    if (!$arg_ref->{key}) {
        WebGUI::Error::InvalidParam->throw(
            param => $arg_ref,
            error => 'WebGUI::Crypt::Simple needs a key in the config'
        );
    }
    
    my $cipher_class = $arg_ref->{cipher} || 'Crypt::Rijndael';
    
    # Register Class::InsideOut object..
    my $self = register 'WebGUI::Crypt::Simple';

    # Initialise object properties..
    my $id = id $self;
    $session{$id} = $session;
    $cipher{$id} = Crypt::CBC->new( -key    => $arg_ref->{key}, -cipher => $cipher_class);
    return $self;
}

#-------------------------------------------------------------------

=head2 encrypt ( $plaintext )

Encrypt some plaintext

=cut

sub encrypt {
    my ($self, $plaintext) = @_;
    return $cipher{id $self}->encrypt($plaintext);
}

#-------------------------------------------------------------------

=head2 encrypt_hex ( $plaintext )

Encrypt some plaintext

=cut

sub encrypt_hex {
    my ($self, $plaintext) = @_;
    return $cipher{id $self}->encrypt_hex($plaintext);
}

#-------------------------------------------------------------------

=head2 decrypt ( $ciphertext )

Decrypt some ciphertext

=cut

sub decrypt {
    my ($self, $ciphertext) = @_;
    return $cipher{id $self}->decrypt($ciphertext);
}

#-------------------------------------------------------------------

=head2 decrypt_hex ( $ciphertext )

Decrypt some ciphertext

=cut

sub decrypt_hex {
    my ($self, $ciphertext) = @_;
    return $cipher{id $self}->decrypt_hex($ciphertext);
}

1;