package WebGUI::Workflow::Activity::BucketPassiveAnalytics;

use strict;
use base 'WebGUI::Workflow::Activity';
use WebGUI::PassiveAnalytics::Rule;
use WebGUI::Inbox;

=head1 NAME

Package WebGUI::Workflow::Activity::BucketPassiveAnalytics

=head1 DESCRIPTION

Run through a set of rules to figure out how to classify log file entries.

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
	my $i18n = WebGUI::International->new($session, "PassiveAnalytics");
	push( @{$definition}, {
		name=>$i18n->get("Bucket Passive Analytics"),
		properties=> {
            notifyUser => {
                fieldType => 'user',
                label     => $i18n->get('User'),
                hoverHelp => $i18n->get('User help'),
                defaultValue => $session->user->userId,
            },
        },
    });
	return $class->SUPER::definition($session,$definition);
}

#-------------------------------------------------------------------

=head2 get_statement( session, counter )

Return a statement handle at the desired offset.

=cut

sub get_statement {
    my ($session, $logIndex) = @_;
    my $deltaSql = q{select SQL_CALC_FOUND_ROWS userId, assetId, url, delta, from_unixtime(timeStamp) as stamp from deltaLog limit ?, 500000};
    my $sth = $session->db->read($deltaSql, [$logIndex+0]);
    return $sth;
}

#-------------------------------------------------------------------

=head2 execute ( [ object ] )

Analyze the deltaLog table, and generate the bucketLog table.

=head3 notes

=cut

sub execute {
	my ($self, undef, $instance) = @_;
    my $session = $self->session;
    my $endTime = time() + $self->getTTL;
    my $expired = 0;

    ##Load all the rules into an array
    my @rules = ();
    my $getARule = WebGUI::PassiveAnalytics::Rule->getAllIterator($session);
    while (my $rule = $getARule->()) {
        my $regexp = $rule->regexp;
        push @rules, [ $rule->bucketName, qr/$regexp/];
    }

    ##Get the index stored from the last invocation of the Activity.  If this is
    ##the first run, then clear out the table.
    my $logIndex = $instance->getScratch('lastPassiveLogIndex') || 0;
    if ($logIndex == 0) { 
        $session->db->write('delete from bucketLog');
    }
    my %bucketCache = ();

    ##Configure all the SQL
    my $deltaSth   = get_statement($session, $logIndex);
    my $total_rows = $session->db->quickScalar('select found_rows()');

    my $bucketSth  = $session->db->prepare('insert into bucketLog (userId, Bucket, duration, timeStamp) VALUES (?,?,?,?)');

    ##Walk through the log file entries, one by one.  Run each entry against
    ##all the rules until 1 matches.  If it doesn't match any rule, then bin it
    ##into the "Other" bucket.
    DELTA_CHUNK: while (1) {
        DELTA_ENTRY: while (my $entry = $deltaSth->hashRef()) {
            ++$logIndex;
            my $bucketFound = 0;
            my $url = $entry->{url};
            if (exists $bucketCache{$url}) {
               $bucketSth->execute([$entry->{userId}, $bucketCache{$url}, $entry->{delta}, $entry->{stamp}]);
            }
            else {
                RULE: foreach my $rule (@rules) {
                   next RULE unless $url =~ $rule->[1];

                   # Into the bucket she goes..
                   $bucketCache{$url} = $rule->[0];
                   $bucketSth->execute([$entry->{userId}, $rule->[0], $entry->{delta}, $entry->{stamp}]);
                   $bucketFound = 1;
                   last RULE;
                }
                if (!$bucketFound) {
                   $bucketCache{$url} = 'Other';
                   $bucketSth->execute([$entry->{userId}, 'Other', $entry->{delta}, $entry->{stamp}]);
                }
            }
            if (time() > $endTime) {
                $expired = 1;
                last DELTA_ENTRY;
            }
        }

        if ($expired) {
            $instance->setScratch('lastPassiveLogIndex', $logIndex);
            return $self->WAITING(1);
        }
        last DELTA_CHUNK if $logIndex >= $total_rows;
        $deltaSth = get_statement($session, $logIndex);
    }
    my $message = 'Passive analytics is done.';
    if ($session->setting->get('passiveAnalyticsDeleteDelta')) {
        $session->log->info('Clearing Passive Analytics delta log');
        $session->db->write('delete from deltaLog');
        $message .= '  The delta log has been cleaned up.';
    }
    ##If userId was set to 0, do not send any emails.
    if ($self->get('userId')) {
        my $inbox = WebGUI::Inbox->new($self->session);
        $inbox->addMessage({
            status  => 'unread',
            subject => 'Passive analytics is done',
            userId  => $self->get('userId'),
            message => $message,
        });
    }
    $session->db->write('update passiveAnalyticsStatus set endDate=NOW(), running=0');

    return $self->COMPLETE;
}

1;

#vim:ft=perl
