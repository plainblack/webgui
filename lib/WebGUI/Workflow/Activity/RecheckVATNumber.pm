package WebGUI::Workflow::Activity::RecheckVATNumber;


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
use WebGUI::Shop::TaxDriver::EU;
use base 'WebGUI::Workflow::Activity';

=head1 NAME

Package WebGUI::Workflow::Activity::RecheckVATNumber

=head1 DESCRIPTION

Rechecks VAT number trhough the EU VIES service that could not be checked at the time they were submitted.

=head1 SYNOPSIS

See WebGUI::Workflow::Activity for details on how to use any activity.

=head1 METHODS

These methods are available from this class:

=cut


#-------------------------------------------------------------------

=head2 definition ( session, definition )

See WebGUI::Workflow::Activity::defintion() for details.

=cut 

sub definition {
	my $class       = shift;
	my $session     = shift;
	my $definition  = shift;
	my $i18n        = WebGUI::International->new($session, "Activity_RecheckVATNumber");

	push ( @{ $definition }, {
		name        =>$i18n->get("topicName"),
    } );

	return $class->SUPER::definition( $session, $definition );
}

#-------------------------------------------------------------------

=head2 execute ( [ object ] )

See WebGUI::Workflow::Activity::execute() for details.

=cut

sub execute {
	my $self        = shift;
    my $object      = shift;
    my $instance    = shift;

    my $params      = $instance->get('parameters');
    my $user        = WebGUI::User->new( $self->session, $params->{ userId } );
    my $taxDriver   = WebGUI::Shop::TaxDriver::EU->new( $self->session );

    my $result      = $taxDriver->recheckVATNumber( $params->{ vatNumber }, $user );
$self->session->log->warn( "Checked $params->{ vatNumber } for user $params->{ userId }, result: $result");


    # If the validity of the number is known we're finished.
    if ( $result eq 'VALID' || $result eq 'INVALID' ) {
        return $self->COMPLETE;
    }

    # Otherwise, try again in an hour.
    return $self->WAITING( 3600 );
}

1;

#vim:ft=perl
