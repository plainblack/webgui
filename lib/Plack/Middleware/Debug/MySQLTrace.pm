package Plack::Middleware::Debug::MySQLTrace;
use 5.008;
use strict;
use warnings;
use parent qw(Plack::Middleware::Debug::Base);
use Plack::Util::Accessor qw(skip_packages);
use Sub::Uplevel ();
our $VERSION = '0.07';

sub run {
    my($self, $env, $panel) = @_;

    my $old_trace;
    my @output;
    my $queries = 0;
    if (defined &DBI::trace) {
        $old_trace = DBI->trace;
        open my $trace_handle, '>:via(Plack::Middleware::Debug::MySQLTrace::IO)', {
            skip_packages => $self->skip_packages,
            logger => sub {
                my $sql = shift;
                $sql =~ s/\s+\z//;
                $sql =~ s/\A\s+//;
                $queries++;
                push @output, sprintf('%s - %s[%s]', $queries, (caller 1)[3], (caller 0)[2]), $sql;
            },
        };
        DBI->trace('2,SQL', $trace_handle);
    }
    else {
        return $panel->disable;
    }

    return sub {
        my $res = shift;

        if (defined $old_trace) {
            DBI->trace($old_trace);
            $panel->title('MySQL Trace');
            $panel->nav_title('MySQL Trace');
            $panel->nav_subtitle($queries . ' Queries');
            $panel->content('<div style="white-space: pre; font-family: monospace">' . $self->render_list_pairs(\@output) . '</div>');
        }
    };
}

package Plack::Middleware::Debug::MySQLTrace::IO;
use strict;
use 5.008;

our $VERSION = '0.01';

sub PUSHED {
    my ($class, $mode, $fh) = @_;
    return bless {}, $class;
}

sub OPEN {
    my ($self, $logger, $mode, $fh) = @_;
    %$self = %$logger;
    return 1;
}

sub WRITE {
    my ($self, $buf, $fh) = @_;
    if ($buf =~ /\ABinding parameters: /) {
        my $sql = $buf;
        $sql =~ s/\ABinding parameters: //;
        my $depth;
        for ( $depth = 1; caller($depth); $depth++) {
            my $package = caller($depth);
            next
                if $package =~ /\ADB[ID](?:\z|::)/;
            next
                if $package =~ /::(?:st|db)\z/;
            next
                if $self->{skip_packages} && $package =~ $self->{skip_packages};
            last;
        }

        Sub::Uplevel::uplevel $depth + 1, $self->{logger}, $sql;
    }
    return length($buf);
}

sub CLOSE {
    my $self = shift;
    return 0;
}

1;

__END__

=head1 NAME

Plack::Middleware::Debug::MySQLTrace - DBI MySQL trace panel

=head1 SEE ALSO

L<Plack::Middleware::Debug>

=cut
