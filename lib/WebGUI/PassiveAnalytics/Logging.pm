package WebGUI::PassiveAnalytics::Logging;

use strict;
use WebGUI::Session;
use WebGUI::Asset;

=head1 NAME

Package WebGUI::PassiveAnalytics::Logging

=head1 DESCRIPTION

Encapsulate all logging functions in here.

=cut

#----------------------------------------------------------------------------

=head2 log ( session, asset )

Log Passive Analytics data to the db.

=head3 session

A session variable.

=head3 asset

The asset to log.

=cut

sub log {
    my ($session, $asset) = @_;
    return unless $session->setting->get('passiveAnalyticsEnabled');
    my $assetClass = $asset->get('className');
    $assetClass =~ s/^WebGUI::Asset:://;
    if (  $assetClass ne 'Snippet'
       && substr($assetClass,0,4) ne 'File') {
        $session->db->write(
            q|INSERT INTO `passiveLog` (userId, sessionId, assetId, timestamp, url) VALUES (?,?,?,?,?)|,
            [ $session->user->userId, $session->getId, $asset->getId, time(), $session->request->unparsed_uri,]
        );
    }
}

1;
