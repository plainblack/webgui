package WebGUI::Flux::Expression;

use strict;
use warnings;

use Class::InsideOut qw{ :std };

=head1 NAME

Package WebGUI::Flux::Expression

=head1 DESCRIPTION

Expression to be used as a building block in Flux Rules 

=head1 SYNOPSIS

 use WebGUI::Flux::Expression;
 
 my $rule = WebGUI::Flux::Expression->build_from_json(
    $session,
    '...JSON....'
 );

=head1 METHODS

These methods are available from this class:

=cut

# InsideOut object properties and accessors
readonly session => my %session;

#-------------------------------------------------------------------

=head2 build_from_json ( session, json )

Constructor.

=head3 session

A reference to the current session.

=head3 json

JSON string

=cut

sub build_from_json {
    my ( $class, $session, $json ) = @_;
    if ( !defined $session || !$session->isa('WebGUI::Session') ) {
        WebGUI::Error::InvalidObject->throw(

            expected => 'WebGUI::Session',
            got      => ( ref $session ),
            error    => 'Need a Session.'
        );
    }
    
    my $self = register $class;
    $session{ id $self } = $session;
    
    # TODO: Parse JSON
    return $self;
}

#-------------------------------------------------------------------

=head2 find_using ( session, id )

Constructor.

=head3 session

A reference to the current session.

=head3 id

Expression id

=cut

sub find_using {
    my ( $class, $session, $id ) = @_;
    if ( !defined $session || !$session->isa('WebGUI::Session') ) {
        WebGUI::Error::InvalidObject->throw(

            expected => 'WebGUI::Session',
            got      => ( ref $session ),
            error    => 'Need a Session.'
        );
    }
    
    my %rule;
    tie %rule, 'Tie::CPHash';
}

#-------------------------------------------------------------------

=head2 delete ( )

Delete Rule.

=cut

sub delete {
    my ( $selft ) = @_;
    
    # TODO
}

1;

