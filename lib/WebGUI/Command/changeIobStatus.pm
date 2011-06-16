package WebGUI::Command::changeIobStatus;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use WebGUI::Command -command;
use strict;
use warnings;

sub opt_spec {
    return (
        [ 'configFile=s', 'The WebGUI config file to use.  This parameter is required.'],
        [ 'quiet', q{Disable all output unless there's an error.} ],
        [ 'whatsHappening:s', q{The message attached to the InOut Board when changing status.  If left unspecified it defaults to 'Automatically signed out.'}],
        [ 'userMessage:s', q{Text of the message to be sent to the user after changing the status.  If left unspecified it will default to 'You were logged out of the In/Out Board automatically.'}],
        [ 'userMessageFile:s', q{Pathname to a file whose contents will be sent to the user after changing the status. Using this option overrides whatever messages is set with --userMessage (see above).}],
        [ 'currentStatus:s', q{Check users in the IOB having status status. If left unspecified, it will default to In.}],
        [ 'newStatus:s', q{Change users status in the IOB to status status. If left unspecified, it will default to Out.}],
    );
}

sub validate_args {
    my ($self, $opt, $args) = @_;
    if (! $opt->{configfile}) {
        $self->usage_error('You must specify the --configFile option.');
    }
}

sub run {
    my ($self, $opt, $args) = @_;

my ($configFile, $help, $quiet, $whatsHappening, $newStatus, $currentStatus, $userMessage, $userMessageFile) =
    @{$opt}{qw(configfile help quiet whatshappening newstatus currentstatus usermessage usermessagefile)};
$whatsHappening ||= "Automatically signed out.";
$newStatus ||= "Out";
$currentStatus ||= "In";
$userMessage ||= "You were logged out of the In/Out Board automatically.";

print "Starting up...\n" unless ($quiet);
my $session = WebGUI::Session->open($configFile);

if ($userMessageFile) {
	print "Opening message file.." unless ($quiet);
	if (open(FILE,"<".$userMessageFile)) {
		print "OK\n" unless ($quiet);
		my $contents;
		while (<FILE>) {
			$contents .= $_;
		}
		close(FILE);
		if (length($contents) == 0) {
			print "Message file empty, reverting to original message.\n";
		} else {
			$userMessage = $contents;
		}
	} else {
		print "Failed to open message file.\n";
	}
}

print "Searching for users with a status of $currentStatus ...\n" unless ($quiet);
my $userList;
my $now = time();
my $inbox = WebGUI::Inbox->new($session);
my $sth = $session->db->read("select userId,assetId from InOutBoard_status where status=?",[$currentStatus]);
while (my ($userId,$assetId) = $sth->array) {
	my $user = WebGUI::User->new($session, $userId);
	print "\tFound user ".$user->username."\n" unless ($quiet);
	$userList .= $user->username." (".$userId.")\n";
	$session->db->write("update InOutBoard_status set dateStamp=?, message=?, status=? where userId=? and assetId=?",[$now, $whatsHappening, $newStatus, $userId, $assetId]);
	$session->db->write("insert into InOutBoard_statusLog (userId, createdBy, dateStamp, message, status, assetId) values (?,?,?,?,?,?)",
		[$userId,3,$now, $whatsHappening, $newStatus, $assetId]);
	$inbox->addMessage({
		userId=>$userId,
		subject=>"IOB Update",
		message=>$userMessage
		});
}

if (length($userList) > 0) {
	print "Alerting admins of changes\n" unless ($quiet);
	my $message = "The following users had their status changed:\n\n".$userList;
	$inbox->addMessage({
		groupId=>3,
		subject=>"IOB Update",
		message=>$userMessage
		});
}

print "Cleaning up..." unless ($quiet);
$session->var->end;
$session->close;
print "OK\n" unless ($quiet);

}

1;

__END__

=head1 NAME

WebGUI::Command::changeIobStatus - Automate WebGUI's InOut Board User status switching.

=head1 SYNOPSIS

 webgui.pl changeiobstatus --configFile config.conf
                 [--currentStatus status]
                 [--newStatus status]
                 [--userMessage text|--userMessageFile pathname]
                 [--whatsHappening text]
                 [--quiet]

 webgui.pl changeiobstatus --help

=head1 DESCRIPTION

This WebGUI utility script helps you switch one or more user status
in the InOut Board (IOB). For instance, you might want to run it
from cron each night to automatically mark out all users that haven't
already marked out.

=over

=item B<--configFile config.conf>

The WebGUI config file to use. Only the file name needs to be specified,
since it will be looked up inside WebGUI's configuration directory.
This parameter is required.

=item B<--currentStatus status>

Check users in the IOB having B<status> status. If left unspecified,
it will default to C<In>.

=item B<--newStatus status>

Change users status in the IOB to B<status> status. If left unspecified,
it will default to C<Out>.

=item B<--userMessage msg>

Text of the message to be sent to the user after changing the status.
If left unspecified it will default to

    You were logged out of the In/Out Board automatically.

=item B<--userMessageFile pathname>

Pathname to a file whose contents will be sent to the user after changing
the status. Using this option overrides whatever messages is set
with B<--userMessage> (see above).

=item B<--whatsHappening text>

The message attached to the InOut Board when changing status. If left
unspecified it defaults to

    Automatically signed out.

=item B<--quiet>

Disable all output unless there's an error.

=item B<--help>

Shows this documentation, then exits.

=back

=head1 AUTHOR

Copyright 2001-2009 Plain Black Corporation.

=cut

