package WebGUI::BackgroundProcess;

use warnings;
use strict;

use Config;
use POSIX;
use WebGUI::Session;
use WebGUI::Pluggable;
use JSON;
use Getopt::Long qw(GetOptionsFromArray);
use Time::HiRes qw(sleep);

=head1 NAME

WebGUI::BackgroundProcess

=head1 DESCRIPTION

Safely and portably spawn a long running process that you can check the
status of.

=head1 SYNOPSIS

    package WebGUI::Some::Class;

    sub doWork {
        my ($process, $data) = @_;
        $process->update("Starting...");
        ...
        $process->update("About half way done...");
        ...
        $process->update("Finished!");
    }

    sub www_doWork {
        my $self = shift;
        my $session = $self->session;
        my $process = WebGUI::BackgroundProcess->start(
            $session, 'WebGUI::Some::Class', 'doWork', { some => 'data' }
        );
        # See WebGUI::Content::BackgroundProcess
        my $pairs = $process->contentPairs('DoWork');
        $session->http->setRedirect($self->getUrl($pairs));
        return 'redirect';
    }

    package WebGUI::Content::BackgroundProcess::DoWork;

    sub handler {
        my $process = shift;
        my $session = $process->session;
        return $session->style->userStyle($process->status);

        # or better yet, an ajaxy page that polls.
    }


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

=head1 METHODS

=cut

#-----------------------------------------------------------------

=head2 argv ($module, $subname, $data)

Produces an argv suitable for passing to exec (after the initial executable
name and perl switches) for running the given user routine with the supplied
data.

=cut

sub argv {
    my ( $self, $module, $subname, $data ) = @_;
    my $class   = ref $self;
    my $session = $self->session;
    my $config  = $session->config;
    my $id      = $self->getId;
    return (
        '--webguiRoot' => $config->getWebguiRoot,
        '--configFile' => $config->getFilename,
        '--sessionId'  => $session->getId,
        '--module'     => $module,
        '--subname'    => $subname,
        '--id'         => $self->getId,
        '--data'       => JSON::encode_json($data),
    );
} ## end sub argv

#-----------------------------------------------------------------

=head2 argvToHash ($argv)

Class method. Processes the passed array with GetOptions -- intended for use
from the exec() in start.  Don't call unless you know what you're doing.

=cut

sub argvToHash {
    my ( $class, $argv ) = @_;
    my $hash = {};
    GetOptionsFromArray( $argv, $hash,
        'webguiRoot=s',
        'configFile=s',
        'sessionId=s',
        'module=s',
        'subname=s',
        'id=s',
        'data=s'
    );
    $hash->{data} = JSON::decode_json( $hash->{data} );
    return $hash;
}

#-----------------------------------------------------------------

=head2 canView ($user?)

Returns whether the current user (or the user passed in, if there is one) has
permission to view the status of the background process.  By default, only
admins can view, but see setGroup.

=cut

sub canView {
    my $self    = shift;
    my $session = $self->session;
    my $user    = shift || $session->user;
    $user = WebGUI::User->new( $session, $user )
        unless eval { $user->isa('WebGUI::User') };
    return 1 if $user->isAdmin;
    my $group = $self->get('groupId');
    return $group && $user->isInGroup($group);
}

#-------------------------------------------------------------------

=head2 contentPairs ($module, $pid)

Returns a bit of query string useful for redirecting to a
WebGUI::Content::BackgroundProcess plugin.  $module should be the bit that
comes after WebGUI::Content::BackgroundProcess, e.g.
$process->contentPairs('Foo') should return something like
"op=background;module=Foo;pid=adlfjafo87ad9f78a7", which will get dispatched
to WebGUI::Content::BackgroundProcess::Foo::handler($process)

=cut

sub contentPairs {
    my ( $self, $module ) = @_;
    my $pid = $self->getId;
    return "op=background;module=$module;pid=$pid";
}

#-----------------------------------------------------------------

=head2 create ( )

Creates a new BackgroundProcess object and inserts a blank row of data into
the db.  You probably shouldn't call this -- see start().

=cut

sub create {
    my ( $class, $session ) = @_;
    my $id = $session->id->generate;
    $session->db->setRow( $class->tableName, 'id', {}, $id );
    bless { session => $session, id => $id };
}

#-----------------------------------------------------------------

=head2 delete ( )

Clean up the information for this process from the database.

=cut

sub delete {
    my $self = shift;
    my $db   = $self->session->db;
    my $tbl  = $db->dbh->quote_identifier( $self->tableName );
    $db->write( "DELETE FROM $tbl WHERE id = ?", [ $self->getId ] );
}

#-----------------------------------------------------------------

=head2 endTime ( )

Returns the epoch time indicating when the subroutine passed to run() finished
executing, or undef if it hasn't finished.  Note that even if the sub passed
to run dies, an endTime will be recorded.

=cut

sub endTime { $_[0]->get('endTime') }

#-----------------------------------------------------------------

=head2 error ( $msg )

Call this to record an error status.  You probably shouldn't, though -- just
dying from your subroutine will cause this to be set.

=cut

sub error { $_[0]->set( { error => $_[1] } ) }

#-----------------------------------------------------------------

=head2 finish ( )

Mark the process as being finished.  This is called for you when your
subroutine is finished.  If update() wasn't computed on the last call, it will
be computed now.

=cut

sub finish {
    my $self = shift;
    my %props = ( finished => 1 );
    if ( my $calc = delete $self->{delay} ) {
        $props{status} = $calc->();
        $props{latch}  = 0;
    }
    $props{endTime} = time();
    $self->set( \%props );
}

#-----------------------------------------------------------------

=head2 get ( @keys )

Get data from the database record for this process (returned as a simple list,
not an arrayref).  Valid keys are: id, status, error, startTime, endTime,
finished, groupId.  They all have more specific accessors, but you can use
this to get several at once.

=cut

sub get {
    my ( $self, @keys ) = @_;
    my $db  = $self->session->db;
    my $dbh = $db->dbh;
    my $tbl = $dbh->quote_identifier( $self->tableName );
    my $key
        = @keys
        ? join( ',', map { $dbh->quote_identifier($_) } @keys )
        : '*';
    my $id     = $dbh->quote( $self->getId );
    my @values = $db->quickArray("SELECT $key FROM $tbl WHERE id = $id");
    return wantarray ? @values : $values[0];
}

#-----------------------------------------------------------------

=head2 getError ( )

If the process died, this will be set to stringified $@.

=cut

sub getError { $_[0]->get('error') }

#-----------------------------------------------------------------

=head2 getGroupId

Returns the group ID (not the actual WebGUI::Group) of users who are allowed
to view this process.

=cut

sub getGroupId {
    my $id = $_[0]->get('groupId');
    return $id || 3;
}

#-----------------------------------------------------------------

=head2 getId ( )

The unique id for this background process. Note: this is NOT the pid, but a
WebGUI guid.

=cut

sub getId { shift->{id} }

#-----------------------------------------------------------------

=head2 getStatus()

Signals the background process that it should report its next status, then
polls at $interval (can be fractional) seconds (default: .1) waiting for the
background process to claim that its status has been updated.  Returns the
updated status.  See setWait() for a way to change the interval (or disable
the waiting procedure entirely).

=cut

sub getStatus {
    my $self     = shift;
    my $interval = $self->{interval};
    if ($interval) {
        $self->set( { latch => 1 } );
        while (1) {
            sleep $interval;
            my ( $finished, $latch ) = $self->get( 'finished', 'latch' );
            last if $finished || !$latch;
        }
    }
    return $self->get('status');
}

#-----------------------------------------------------------------

=head2 isFinished ( )

A simple flag indicating that background process is no longer running.

=cut

sub isFinished { $_[0]->get('finished') }

#-----------------------------------------------------------------

=head2 new ( $session, $id )

Returns an object capable of checking on the status of the background process
indicated by $id.  Returns undef if there is no such process.

=cut

sub new {
    my ( $class, $session, $id ) = @_;
    my $db     = $session->db;
    my $tbl    = $db->dbh->quote_identifier( $class->tableName );
    my $sql    = "SELECT COUNT(*) FROM $tbl WHERE id = ?";
    my $exists = $db->quickScalar( $sql, [$id] );
    return $exists
        ? bless( { session => $session, id => $id, interval => .1 }, $class )
        : undef;
}

#-----------------------------------------------------------------

=head2 session ()

Get the WebGUI::Session this process was created with.  Note: this is safe to
call in the child process, as it is a duplicated session (same session id) and
doesn't share any handles with the parent process.

=cut

sub session { $_[0]->{session} }

#-----------------------------------------------------------------

=head2 set ($properties)

Updates the database row with the properties given by the $properties hashref.
See get() for a list of valid keys.

=cut

sub set {
    my ( $self, $values ) = @_;
    my @keys = keys %$values;
    return unless @keys;

    my $db   = $self->session->db;
    my $dbh  = $db->dbh;
    my $tbl  = $dbh->quote_identifier( $self->tableName );
    my $sets = join(
        ',',
        map {
            my $ident = $dbh->quote_identifier($_);
            my $value = $dbh->quote( $values->{$_} );
            "$ident = $value";
            } @keys
    );

    my $id = $dbh->quote( $self->getId );
    $db->write("UPDATE $tbl SET $sets WHERE id = $id");
} ## end sub set

#-----------------------------------------------------------------

=head2 setGroup($groupId)

Allow the given group (in addition to admins) the ability to check on the
status of this process

=cut

sub setGroup {
    my ( $self, $groupId ) = @_;
    $groupId = eval { $groupId->getId } || $groupId;
    $self->set( { groupId => $groupId } );
}

#-----------------------------------------------------------------

=head2 runCmd ($hashref)

Class method.  Processes ARGV and passes it to runFromHash.  Don't call this
unless you're the start() method.

=cut

sub runCmd {
    my $class = shift;
    $class->runFromHash( $class->argvToHash( \@ARGV ) );
}

#-----------------------------------------------------------------

=head2 runFromHash ($hashref)

Class method. Expects a hash of arguments describing what to run.  Don't call
this unless you know what you're doing.

=cut

sub runFromHash {
    my ( $class, $args ) = @_;
    my $module = $args->{module};
    WebGUI::Pluggable::load($module);
    my $code = $module->can( $args->{subname} );
    my $session = WebGUI::Session->open( $args->{webguiRoot}, $args->{configFile}, undef, undef, $args->{sessionId} );

    my $self = $class->new( $session, $args->{id} );
    $self->set( { startTime => time } );
    eval { $self->$code( $args->{data} ) };
    $self->error($@) if $@;
    $self->finish();
}

#-----------------------------------------------------------------

=head2 setWait ( $interval )

Use this to control the pace at which getStatus will poll for updated
statuses.  By default, this is a tenth of a second.  If you set it to 0,
getStatus will still signal the background process for an update, but will
take whatever is currently recorded as the status and return immediately.

=cut

sub setWait { $_[0]->{interval} = $_[1] }

#-----------------------------------------------------------------

=head2 start ( $session, $module, $subname, $data )

Class method. The first thing this method does is daemonize (double-fork,
setsid, chdir /, umask 0, all that good stuff).  It then executes
$module::subname in a fresh perl interpreter (exec'd $^X) with ($process,
$data) as its arguments.  The only restriction on $data is that it be
serializable by JSON.

=head3 $0

The process name (as it appears in ps) will be set to webgui-background-$id,
where $id is the value returned by $process->getId.  It thus won't look like a
modperl process to anyone monitoring the process table (wremonitor.pl, for
example).

=cut

sub start {
    my ( $class, $session, $module, $subname, $data ) = @_;
    my $self = $class->create($session);
    my $id   = $self->getId;

    my $pid = fork();
    die "Cannot fork: $!" unless defined $pid;
    if ($pid) {

        # The child process will fork again and exit immediately, so we can
        # wait for it (and thus not have zombie processes).
        waitpid( $pid, 0 );

        return $self;
    }

    # We don't want destructors called, so POSIX exit on errors.
    eval {

        # detach from controlling terminal, get us into a new process group
        die "Cannot become session leader: $!" if POSIX::setsid() < 0;

        # Fork again so we never get a controlling terminal
        $pid = fork();
        die "Child cannot fork: $!" unless defined $pid;

        # We don't want to call any destructors, as it would mess with the
        # parent's mysql connection, etc.
        POSIX::_exit(0) if $pid;

        # We're now in the final target process. Standard daemon-y things...
        $SIG{HUP} = 'IGNORE';
        chdir '/';
        umask 0;

        # Forcibly close any open file descriptors that remain
        my $max = POSIX::sysconf(&POSIX::_SC_OPEN_MAX) || 1024;
        POSIX::close($_) for ( 0 .. $max );

        # Get us some reasonable STD handles
        my $null = '/dev/null';
        open STDIN,  '<', $null or die "Cannot read $null: $!";
        open STDOUT, '>', $null or die "Cannot write $null: $!";
        open STDERR, '>', $null or die "Cannot write $null: $!";

        # Now we're ready to run the user's code.
        my $perl = $Config{perlpath};
        exec {$perl} (
            "webgui-background-$id",
            ( map {"-I$_"} @INC ),
            "-M$class", "-e$class->runCmd();",
            '--', $self->argv( $module, $subname, $data )
        ) or POSIX::_exit(-1);
    };
    POSIX::_exit(-1) if ($@);
} ## end sub start

#-----------------------------------------------------------------

=head2 startTime ( )

Returns the time this process started running in epoch format.

=cut

sub startTime { $_[0]->get('startTime') }

#-----------------------------------------------------------------

=head2 tableName ( )

Class method: a constant, for convenience.  The name of the table that process
data is stored in.

=cut

sub tableName {'BackgroundProcess'}

#-----------------------------------------------------------------

=head2 update ( $msg )

Set a new status for the background process.  This can be anything, and will
overwrite the old status.  JSON is recommended for complex statuses.
Optionally, $msg can be a subroutine that returns the new status -- if your
status may take a long time to compute, you should use this, as you may be
able to avoid computing some (or all) of your status updates, depending on how
often they're being asked for.  See the getStatus method for details.

=cut

sub update {
    my ( $self, $msg ) = @_;
    if ( ref $msg eq 'CODE' ) {
        if ( $self->get('latch') ) {
            $msg = $msg->();
        }
        else {
            $self->{delay} = $msg;
            return;
        }
    }
    delete $self->{delay};
    $self->set( { latch => 0, status => $msg } );
}

1;
