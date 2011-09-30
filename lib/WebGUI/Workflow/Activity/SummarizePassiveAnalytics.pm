package WebGUI::Workflow::Activity::SummarizePassiveAnalytics;

use strict;
use base 'WebGUI::Workflow::Activity';

=head1 NAME

Package WebGUI::Workflow::Activity::SummarizePassiveAnalytics

=head1 DESCRIPTION

Summarize how long a user stayed on a page, using a user supplied interval.

=head1 SYNOPSIS

See WebGUI::Workflow::Activity for details on how to use any activity.

=head1 METHODS

These methods are available from this class:

=cut


#-------------------------------------------------------------------

=head2 definition ( session, definition )

See WebGUI::Workflow::Activity::definition() for details.

=cut 

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift;
	my $i18n = WebGUI::International->new($session, 'PassiveAnalytics');
	push(@{$definition}, {
		name=>$i18n->get('Summarize Passive Analytics'),
		properties=> {
			deltaInterval => {
				fieldType    => 'interval',
				label        => $i18n->get('pause interval'),
				defaultValue => 15,
				hoverHelp    => $i18n->get('pause interval help'),
				},
			}
		});
	return $class->SUPER::definition($session,$definition);
}

#-------------------------------------------------------------------

=head2 get_statement( session, counter )

Return a statement handle at the desired offset.

=cut

sub get_statement {
    my ($session, $counter) = @_;
    my $passive = q{select SQL_CALC_FOUND_ROWS * from passiveLog where userId <> '1' order by userId, sessionId, timeStamp limit ?, 500000};
    my $sth = $session->db->read($passive, [$counter+0]);
    return $sth;
}

#-------------------------------------------------------------------

=head2 execute ( [ object ] )

Analyze the passiveLog table, and generate the deltaLog table.

=head3 notes

If there is only 1 line in the table for a particular sessionId or
userId, no conclusions as to how long the user viewed a page can be
drawn from that.   Similarly, the last entry in their browsing log
yields no data, since we require another entry in the passiveLog to
determine a delta.

=cut

sub execute {
	my ($self, undef, $instance) = @_;
    my $session = $self->session;
    my $endTime = time() + $self->getTTL;
    my $deltaInterval = $self->get('deltaInterval');

    my $lastUserId;
    my $lastSessionId;
    my $lastTimeStamp;
    my $lastAssetId;
    my $lastUrl;
    my $counter = $instance->getScratch('counter');
    my $sth = get_statement($session, $counter);
    if ($counter) {
        $lastUserId    = $instance->getScratch('lastUserId');
        $lastSessionId = $instance->getScratch('lastSessionId');
        $lastTimeStamp = $instance->getScratch('lastTimeStamp');
        $lastAssetId   = $instance->getScratch('lastAssetId');
        $lastUrl       = $instance->getScratch('lastUrl');
    }
    else {
        my $logLine    = $sth->hashRef();
        $lastUserId    = $logLine->{userId};
        $lastSessionId = $logLine->{sessionId};
        $lastTimeStamp = $logLine->{timeStamp};
        $lastAssetId   = $logLine->{assetId};
        $lastUrl       = $logLine->{url};
        $session->db->write('delete from deltaLog'); ##Only if we're starting out
    }

    my $total_rows = $session->db->quickScalar('select found_rows()');

    my $deltaLog = $session->db->prepare('insert into deltaLog (userId, assetId, delta, timeStamp, url) VALUES (?,?,?,?,?)');

    my $expired = 0;
    LOG_CHUNK: while (1) {
        LOG_ENTRY: while (my $logLine = $sth->hashRef()) {
            $counter++;
            my $delta = $logLine->{timeStamp} - $lastTimeStamp;
            if (  $logLine->{userId}    eq $lastUserId 
               && $logLine->{sessionId} eq $lastSessionId
               && $delta < $deltaInterval ) {
                    $deltaLog->execute([$lastUserId, $lastAssetId, $delta, $lastTimeStamp, $lastUrl]);
            }
            $lastUserId    = $logLine->{userId};
            $lastSessionId = $logLine->{sessionId};
            $lastTimeStamp = $logLine->{timeStamp};
            $lastAssetId   = $logLine->{assetId};
            $lastUrl       = $logLine->{url};
            if (time() > $endTime) {
                $instance->setScratch('lastUserId',    $lastUserId);
                $instance->setScratch('lastSessionId', $lastSessionId);
                $instance->setScratch('lastTimeStamp', $lastTimeStamp);
                $instance->setScratch('lastAssetId',   $lastAssetId);
                $instance->setScratch('lastUrl',       $lastUrl);
                $instance->setScratch('counter',       $counter);
                $expired = 1;
                last LOG_ENTRY;
            }
        }
 
        $sth->finish;
        if ($expired) {
            return $self->WAITING(1);
        }
        last LOG_CHUNK if $counter >= $total_rows;
        $sth = get_statement($session, $counter);
    }

    $instance->deleteScratch('lastUserId');
    $instance->deleteScratch('lastSessionId');
    $instance->deleteScratch('lastTimeStamp');
    $instance->deleteScratch('lastAssetId');
    $instance->deleteScratch('lastUrl');
    $instance->deleteScratch('counter');
    return $self->COMPLETE;
}



1;

#vim:ft=perl
