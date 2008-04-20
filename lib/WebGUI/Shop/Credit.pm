package WebGUI::Shop::Credit;

use strict;
use Class::InsideOut qw{ :std };
use WebGUI::Shop::Admin;
use WebGUI::Exception::Shop;
use WebGUI::International;


=head1 NAME

Package WebGUI::Shop::Credit

=head1 DESCRIPTION

Keeps track of what in-store credit is owed a customer. All refunds are issued as in-store credit.

=head1 SYNOPSIS

 use WebGUI::Shop::Credit;

 my $credit = WebGUI::Shop::Credit->new($session, $userId);

=head1 METHODS

These subroutines are available from this package:

=cut

readonly session => my %session;
readonly userId => my %userId;

#-------------------------------------------------------------------

=head2 adjust ( amount, [ comment ] )

Adjusts the amount of credit this user has by a specified amount.

=head3 amount

The amount to adjust the credit by.  A positive number adds credit, and a negative number removes credit.

=head3 comment

The reason for this adjustment. 

=cut

sub adjust {
    my ($self, $amount, $comment) = @_;
    $self->session->db->write("insert into shopCredit (creditId, userId, amount, comment, dateOfAdjustment) values (?,?,?,?,now())",
        [$self->session->id->generate, $self->userId, $amount, $comment]);
}

#-------------------------------------------------------------------

=head2 getGeneralLedger ( session )

A class method. Returns a WebGUI::SQL::ResultSet containing the data from the shopCredit table for all users.

=head3 session

A reference to the current session.

=cut

sub getGeneralLedger {
    my ($class, $session) = @_;
    return $session->db->read("select * from shopCredit order by dateOfAdjustment");
}

#-------------------------------------------------------------------

=head2 getLedger ()

Returns a WebGUI::SQL::ResultSet containing the data from the shopCredit table for this user.

=cut

sub getLedger {
    my $self = shift;
    return $self->session->db->read("select * from shopCredit where userId=?",[$self->userId]);
}

#-------------------------------------------------------------------

=head2 getSum ()

Returns the amount of credit that is owed to this user.

=cut

sub getSum {
    my $self = shift;
    my $credit = $self->session->db->getScalar("select sum(amount) from shopCredit where userId=? order by dateOfAdjustment",[$self->userId]);
    return sprintf("%.2f", $credit);
}

#-------------------------------------------------------------------

=head2 new ( session, userId )

Constructor. 

=head3 session

A reference to the current session.

=head3 userId

A unique id for a user that you want to adjust the credit of.

=cut

sub new {
    my ($class, $session, $userId) = @_;
    unless (defined $session && $session->isa("WebGUI::Session")) {
        WebGUI::Error::InvalidObject->throw(expected=>"WebGUI::Session", got=>(ref $session), error=>"Need a session.");
    }
    unless (defined $userId) {
        WebGUI::Error::InvalidParam->throw( param=>$userId, error=>"Need a userId.");
    }
    my $self = register $class;
    my $id        = id $self;
    $session{ $id } = $session;
    $userId{ $id } = $userId;
    return $self;
}

#-------------------------------------------------------------------

=head2 session () 

Returns a reference to the current session.

=cut

#-------------------------------------------------------------------

=head2 userId () 

Returns a reference to the userId.

=cut




1;
