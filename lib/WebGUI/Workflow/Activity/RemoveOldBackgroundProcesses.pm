package WebGUI::Workflow::Activity::RemoveOldBackgroundProcesses;

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

use warnings;
use strict;

use base 'WebGUI::Workflow::Activity';

use WebGUI::International;
use WebGUI::BackgroundProcess;

=head1 NAME

WebGUI::Workflow::Activity::RemoveOldBackgroundProcesses

=head1 DESCRIPTION

Remove background processes that are older than a configurable threshold.

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 definition ( session, definition )

See WebGUI::Workflow::Activity::definition() for details.

=cut

sub definition {
    my ( $class, $session, $definition ) = @_;
    my $i18n = WebGUI::International->new( $session, 'Workflow_Activity_RemoveOldBackgroundProcesses' );
    my %def = (
        name       => $i18n->get('activityName'),
        properties => {
            interval => {
                fieldType    => 'interval',
                label        => $i18n->get('interval'),
                defaultValue => 60 * 60 * 24 * 7,
                hoverHelp    => $i18n->get('interval help')
            }
        }
    );
    push @$definition, \%def;
    return $class->SUPER::definition( $session, $definition );
} ## end sub definition

#-------------------------------------------------------------------

=head2 execute ( [ object ] )

See WebGUI::Workflow::Activity::execute() for details.

=cut

sub execute {
    my $self = shift;
    my $db   = $self->session->db;
    my $tbl  = $db->dbh->quote_identifier( WebGUI::BackgroundProcess->tableName );
    my $time = time - $self->get('interval');
    $db->write( "DELETE FROM $tbl WHERE endTime <= ?", [$time] );
    return $self->COMPLETE;
}

1;
