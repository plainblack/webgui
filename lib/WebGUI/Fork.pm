package WebGUI::Fork;

use warnings;
use strict;

use File::Spec;
use JSON;
use POSIX;
use Config;
use IO::Pipe;
use WebGUI::Session;
use WebGUI::Pluggable;
use Time::HiRes qw(sleep);

=head1 NAME

WebGUI::Fork

=head1 DESCRIPTION

Safely and portably spawn a long running process that you can check the
status of.

=head1 SYNOPSIS

    package WebGUI::Some::Class;

    sub doWork {
        my ($process, $data) = @_;
        # Update our status
        $process->update("Starting...");
        ...
        $process->update("About half way done...");
        ...
        $process->update("Finished!");
    }

    sub www_doWork {
        my $self = shift;
        my $session = $self->session;
        my $process = WebGUI::Fork->start(
            $session, 'WebGUI::Some::Class', 'doWork', { some => 'data' }
        );
        # See WebGUI::Operation::Fork
        my $pairs = $process->contentPairs('DoWork');
        $session->response->setRedirect($self->getUrl($pairs));
        return 'redirect';
    }

    # Display a page with the status of the fork
    package WebGUI::Operation::Fork::DoWork;

    sub handler {
        my $process = shift;
        my $session = $process->session;
        return $session->style->userStyle($process->status);

        # or better yet, an ajaxy page that polls.
    }

    # For ways of displaying status from a fork, see
    # WebGUI::Fork::ProgressTree
    # WebGUI::Fork::ProgressBar

=head1 SEE ALSO

=over 4

=item L<WebGUI::Fork::ProgressTree>

=item L<WebGUI::Fork::ProgressBar>

=back

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2012 Plain Black Corporation.
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

=head2 canView ($user?)

Returns whether the current user (or the user passed in, if there is one) has
permission to view the status of the fork.  By default, only admins can view,
but see setGroup.

=cut

sub canView {
    my $self    = shift;
    my $session = $self->session;
    my $user    = shift || $session->user;
    $user = WebGUI::User->new( $session, $user )
        unless eval { $user->isa('WebGUI::User') };
    return
           $user->isAdmin
        || $user->userId eq $self->getUserId
        || $user->isInGroup( $self->getGroupId );
}

#-------------------------------------------------------------------

=head2 cleanINC(@INC)

Class method. Returns a new @INC array (but does not set it) to be used for
forked/daemonized processes. Note that you pass in @INC and new one is
returned, but doesn't replace the original. You must do that yourself.

=cut

sub cleanINC {
    # gotta get rid of hooks until we think of a way to serialize them in
    # forkAndExec (if we ever want to). Serializing coderefs is a tricky
    # business.
    map { File::Spec->rel2abs($_) } grep { !ref } @_;
}

#-------------------------------------------------------------------

=head2 contentPairs ($module, $pid, $extra)

Returns a bit of query string useful for redirecting to a
WebGUI::Operation::Fork plugin.  $module should be the bit that comes after
WebGUI::Operation::Fork, e.g.  $process->contentPairs('Foo') should return
something like "op=fork;module=Foo;pid=adlfjafo87ad9f78a7", which will
get dispatched to WebGUI::Operation::Fork::Foo::handler($process).

$extra is an optional hashref that will add further parameters onto the list
of pairs, e.g. { foo => 'bar' } becomes ';foo=bar'

=cut

sub contentPairs {
    my ( $self, $module, $extra ) = @_;
    my $url    = $self->session->url;
    my $pid    = $self->getId;
    my %params = (
        op     => 'fork',
        module => $module,
        pid    => $self->getId,
        $extra ? %$extra : ()
    );
    return join(
        ';',
        map {
            my $k = $_;
            join( '=', map { $url->escape($_) } ( $k, $params{$k} ) );
            } keys %params
    );
} ## end sub contentPairs

#-----------------------------------------------------------------

=head2 create ( )

Internal class method. Creates a new Fork object inserts it into the db.

=cut

sub create {
    my ( $class, $session ) = @_;
    my $id = $session->id->generate;
    my %data = ( userId => $session->user->userId );
    $session->db->setRow( $class->tableName, 'id', \%data, $id );
    bless { session => $session, id => $id }, $class;
}

#-----------------------------------------------------------------

=head2 daemonize ( $stdin, $sub )

Internal lass method.  Runs the given $sub in daemon, and prints $stdin to its
stdin.

=cut

sub daemonize {
    my ( $class, $stdin, $sub ) = @_;
    my $pid = fork();
    die "Cannot fork: $!" unless defined $pid;
    if ($pid) {

        # The child process will fork again and exit immediately, so we can
        # wait for it (and thus not have zombie processes).
        waitpid( $pid, 0 );
        return;
    }

    eval {

        # detach from controlling terminal, get us into a new process group
        die "Cannot become session leader: $!" if POSIX::setsid() < 0;

        # Fork again so we never get a controlling terminal
        my $worker = IO::Pipe->new;
        my $pid    = fork();
        die "Child cannot fork: $!" unless defined $pid;

        # We don't want to call any destructors, as it would mess with the
        # parent's mysql connection, etc.
        if ($pid) {
            $worker->writer;
            $worker->printflush($stdin);
            POSIX::_exit(0);
        }

        # We're now in the final target process.  STDIN should be whatever the
        # parent printed to us, and all output should go to /dev/null.
        $worker->reader();
        open STDIN,  '<&', $worker     or die "Cannot dup stdin: $!";
        open STDOUT, '>',  '/dev/null' or die "Cannot write /dev/null: $!";
        open STDERR, '>&', \*STDOUT    or die "Cannot dup stdout: $!";

        # Standard daemon-y things...
        $SIG{HUP} = 'IGNORE';
        chdir '/';
        umask 0;

        # Forcibly close any non-std open file descriptors that remain
        my $max = POSIX::sysconf(&POSIX::_SC_OPEN_MAX) || 1024;
        POSIX::close($_) for ( $^F .. $max );

        # Do whatever we're supposed to do
        &$sub();
    };

    POSIX::_exit( $@ ? -1 : 0 );
} ## end sub daemonize

#-----------------------------------------------------------------

=head2 delete ( )

Clean up the information for this process from the database.

=cut

sub delete {
    my $self = shift;
    $self->session->db->deleteRow( $self->tableName, 'id', $self->getId );
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

=head2 forkAndExec ($request)

Internal method. Forks and execs a new perl process to run $request. This is
used as a fallback if the master daemon runner is not working.

=cut

sub forkAndExec {
    my ( $self, $request ) = @_;
    my $id    = $self->getId;
    my $class = ref $self;
    my $json  = JSON::encode_json($request);
    my @inc   = map { "-I$_" } $class->cleanINC(@INC);
    my @argv  = (@inc, "-M$class", "-e$class->runCmd()" );
    $class->daemonize(
        $json,
        sub {
            exec ($Config{perlpath}, @argv) or die "Could not exec: $!";
        }
    );
}

#-----------------------------------------------------------------

=head2 get ( @keys )

Get data from the database record for this process (returned as a simple list,
not an arrayref).  Valid keys are: id, status, error, startTime, endTime,
finished, groupId, userId.  They all have more specific accessors, but you can
use this to get several at once if you're very careful.  You should probably
use the accessors, though, since some of them have extra logic.

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
    return ( @values > 1 ) ? @values : $values[0];
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

The unique id for this fork. Note: this is NOT the pid, but a WebGUI guid.

=cut

sub getId { shift->{id} }

#-----------------------------------------------------------------

=head2 getStatus()

Signals the fork that it should report its next status, then polls at a
configurable, fractional interval (default: .1 seconds) waiting for the fork
to claim that its status has been updated.  Returns the updated status.  See
setWait() for a way to change the interval (or disable the waiting procedure
entirely). We will only wait for a maximum of 100 intervals.

=cut

sub getStatus {
    my $self = shift;
    if ( my $interval = $self->{interval} ) {
        $self->set( { latch => 1 } );
        my $maxWait;
        while ($maxWait++ < 100) {
            sleep $interval;
            my ( $finished, $latch ) = $self->get( 'finished', 'latch' );
            last if $finished || !$latch;
        }
    }
    return $self->get('status');
}

#-----------------------------------------------------------------

=head2 getUserId

Returns the userId of the user who initiated this Fork.

=cut

sub getUserId { $_[0]->get('userId') }

#-----------------------------------------------------------------

=head2 init ( )

Spawn a master process from which Forks will fork(). The intent
is for this to be called once at server startup time, after you've preloaded
modules and before you start listening for requests. Returns a filehandle that
can be used to print requests to the master process, and which you almost
certainly shouldn't use (it's mostly for testing).

=cut

my $pipe;

sub init {
    my $class = shift;
    $pipe = IO::Pipe->new;

    my $pid = fork();
    die "Cannot fork: $!" unless defined $pid;

    if ($pid) {
        $pipe->writer;
        return $pipe;
    }

    $0 = 'webgui-fork-master';
    $pipe->reader;
    local $/ = "\x{0}";
    @INC = $class->cleanINC(@INC);
    while ( my $request = $pipe->getline ) {
        chomp $request;
        eval {
            $class->daemonize( $request, sub { $class->runCmd } );
        };
    }
    CORE::exit(0);
} ## end sub init

#-----------------------------------------------------------------

=head2 isFinished ( )

A simple flag indicating that the fork is no longer running.

=cut

sub isFinished { $_[0]->get('finished') }

#-----------------------------------------------------------------

=head2 new ( $session, $id )

Returns an object capable of checking on the status of the fork indicated by
$id.  Returns undef if there is no such process.

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
    my %row = ( id => $self->getId, %$values );
    $self->session->db->setRow( $self->tableName, 'id', \%row );
}

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

=head2 request ($module, $subname, $data)

Internal method. Generates a hashref suitable for passing to runRequest.

=cut

sub request {
    my ( $self, $module, $subname, $data ) = @_;
    my $session = $self->session;
    my $config  = $session->config;
    return {
        configFile => $config->pathToFile,
        sessionId  => $session->getId,
        module     => $module,
        subname    => $subname,
        id         => $self->getId,
        data       => $data,
    };
}

#-----------------------------------------------------------------

=head2 runCmd ()

Internal class method.  Decodes json off of stdin and passes it to runRequest.

=cut

sub runCmd {
    my $class = shift;
    my $slurp = do { local $/; <STDIN> };
    $class->runRequest( JSON::decode_json($slurp) );
}

#-----------------------------------------------------------------

=head2 runRequest ($hashref)

Internal class method. Expects a hash of arguments describing what to run.

=cut

sub runRequest {
    my ( $class, $args ) = @_;
    my ( $config, $sid ) = @{$args}{qw(configFile sessionId)};
    my $session = WebGUI::Session->open( $config, undef, $sid );
    my $id = $args->{id};
    my $self = $class->new( $session, $id );
    $self->set( { startTime => time } );
    $0 = "webgui-fork-$id";
    eval {
        my ( $module, $subname, $data ) = @{$args}{qw(module subname data)};
        WebGUI::Pluggable::run( $module, $subname, [ $self, $data ] );
    };
    $self->error($@) if $@;
    $self->finish();
}

#-----------------------------------------------------------------

=head2 sendRequestToMaster ($request)

Internal method. Attempts to send a request to the master daemon runner.
Returns 1 on success and 0 on failure.

=cut

sub sendRequestToMaster {
    my ( $self, $request ) = @_;
    my $json = JSON::encode_json($request);
    eval {
        die 'pipe' unless $pipe && $pipe->isa('IO::Handle');
        local $SIG{PIPE} = sub { die 'pipe' };
        $pipe->printflush("$json\x{0}") or die 'pipe';
    };
    return 1 unless $@;
    undef $pipe;
    $self->session->log->error("Problems talking to master daemon process: $@.  Please restart the web server.");
    return 0;
}

#-----------------------------------------------------------------

=head2 setWait ( $interval )

Use this to control the pace at which getStatus will poll for updated
statuses.  By default, this is a tenth of a second.  If you set it to 0,
getStatus will still signal the fork for an update, but will take whatever is
currently recorded as the status and return immediately.

=cut

sub setWait { $_[0]->{interval} = $_[1] }

#-----------------------------------------------------------------

=head2 start ( $session, $module, $subname, $data )

Class method. Executes $module::subname in a forked process with ($process,
$data) as its arguments.  The only restriction on $data is that it be
serializable by JSON.

=head3 $0

The process name (as it appears in ps) will be set to webgui-fork-$id,
where $id is the value returned by $process->getId. It thus won't look like a
modperl process to anyone monitoring the process table (wremonitor.pl, for
example).

=cut

sub start {
    my ( $class, $session, $module, $subname, $data ) = @_;
    my $self = $class->create($session);
    my $request = $self->request( $module, $subname, $data );
    $self->sendRequestToMaster($request) or $self->forkAndExec($request);
    return $self;
}

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

sub tableName {'Fork'}

#-----------------------------------------------------------------

=head2 update ( $msg )

Set a new status for the fork.  This can be anything, and will overwrite the
old status.  JSON is recommended for complex statuses.  Optionally, $msg can
be a subroutine that returns the new status -- if your status may take a long
time to compute, you should use this, as you may be able to avoid computing
some (or all) of your status updates, depending on how often they're being
asked for.  See the getStatus method for details.

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
