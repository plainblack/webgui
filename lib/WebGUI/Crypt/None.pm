package WebGUI::Crypt::None;
use Class::InsideOut qw{ :std };
use Crypt::CBC;

=head1 NAME

Package WebGUI::Crypt::None

=head1 DESCRIPTION

Pass-thru Crypt provider for people who don't need WebGUI database encryption

=head1 SYNOPSIS
 
=head1 METHODS

These methods are available from this package:

=cut

# InsideOut object properties
readonly session => my %session;    # WebGUI::Session object
public providerId => my %providerId;

#-------------------------------------------------------------------

=head2 new ( session, config )

Constructor.
=head3 session

A reference to the current session.

=head3 config

Crypt config object

=cut

sub new {
    my ( $session, $arg_ref ) = @_;

    # Check arguments..
    if ( !defined $session || !$session->isa('WebGUI::Session') ) {
        WebGUI::Error::InvalidParam->throw(
            param => $session,
            error => 'Need a session.'
        );
    }

    #NONE doesn't need config info.  

    # Register Class::InsideOut object..
    my $self = register 'WebGUI::Crypt::None';
    $providerId{$id} = $arg_ref->{providerId};

    # Initialise object properties..
    my $id = id $self;
    $session{$id} = $session;
    return $self;
}

#-------------------------------------------------------------------

=head2 encrypt ( $plaintext )

Pretend to encrypt some plaintext

=cut

sub encrypt {
    return $_[1];
}

#-------------------------------------------------------------------

=head2 encrypt_hex ( $plaintext )

Pretend to encrypt some plaintext

=cut

sub encrypt_hex {
    return $_[1];
}

#-------------------------------------------------------------------

=head2 decrypt ( $ciphertext )

Pretend to decrypt some ciphertext

=cut

sub decrypt {
    return $_[1];
}

#-------------------------------------------------------------------

=head2 decrypt_hex ( $ciphertext )

Pretend to decrypt some ciphertext

=cut

sub decrypt_hex {
    $_[1];
}

1;
