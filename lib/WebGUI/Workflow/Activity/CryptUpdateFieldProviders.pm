package WebGUI::Workflow::Activity::CryptUpdateFieldProviders;


=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2008 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use base 'WebGUI::Workflow::Activity';
use WebGUI::Asset;
use WebGUI::DateTime;
use DateTime::Duration;

=head1 NAME

Package WebGUI::Workflow::Activity::CryptUpdateFieldProviders

=head1 DESCRIPTION

This activity updates and re-encrypts encrypted fields with the currently chosen provider.

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
	my $class = shift;
	my $session = shift;
	my $definition = shift;
	#my $i18n = WebGUI::International->new($session, "Workflow_Activity_CryptUpdateFieldProviders");
	push(@{$definition}, {
		#name        =>  $i18n->get("name"),
		name        =>  "Workflow_Activity_CryptUpdateFieldProviders",
		properties  => {}
        });
	return $class->SUPER::definition($session,$definition);
}


#-------------------------------------------------------------------

=head2 execute ( [ object ] )

Finds all the expired Survey Responses on the system.  If delete is selected, they are removed.  Then if
email is selected, the users are emailed the template. 

=cut

sub execute {
	my $self = shift;
    my $session = $self->session;
    
    $session->db->write('update cryptStatus set startDate=NOW(), userId=?, endDate=?, running=1', [$session->user->userId, '']);

    my $endTime = time() + $self->getTTL();
    # dwindles as we progress
    my $fieldProvidersSth = $session->db->read( "select `table`, `field`, `key`, providerId from cryptFieldProviders where activeProviderIds like ?", [ '%,%' ] );

    FIELD_PROVIDER: while ( my ($table, $field, $key, $providerId) = $fieldProvidersSth->array ) {
        my $fieldSth = $session->db->read( "select `$field`, `$key` from `$table` where `$field` not like ?", ["CRYPT:$providerId:%" ] ); # dwindles as we progress
        while( my ($data, $uniqueKey) = $fieldSth->array ) {
            $data = $session->crypt->encrypt_hex( $session->crypt->decrypt_hex( $data ), { providerId => $providerId } );
            $session->db->write( "update $table set $field = ? where $key = ?", [ $data, $uniqueKey ] ); # row will no longer match $fieldSth
            return $self->WAITING(1) if (time() > $endTime);
        }
        # we finished processing a field provider without timing out, check the dataset wasn't modified while we were working..
            # Need two types of queries, one for WebGUI::Crypt::None and one for all other provider types
        my $targetField = "CRYPT:$providerId:%";
        my $sql = "select count(*) from `$table` where $field not like ?";
        if($self->session->config->get("crypt")->{$providerId}->{provider} eq "WebGUI::Crypt::None"){
            $targetField = "CRYPT:%";
            $sql = "select count(*) from `$table` where $field like ?";
        }
        if ( $session->db->quickScalar( $sql, [ $targetField ] ) ) {
            # need another pass over $fieldSth (but only for the few rows that match)
            redo FIELD_PROVIDER; 
        } else {
            # dataset now uses $providerId exclusively
            $session->db->write( "update cryptFieldProviders set activeProviderIds = concat(activeProviderIds,',',?) where `table` = ? and `field` = ?", 
                [ $providerId, $table, $field ] ); 
            # row will no longer match $fieldProvidersSth
        }
    }
    $session->db->write('update cryptStatus set endDate=NOW(), running=0');
    return $self->COMPLETE;
}

1;


