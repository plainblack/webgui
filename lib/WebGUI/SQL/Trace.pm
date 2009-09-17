package WebGUI::SQL::Trace;
use strict;
#use warnings;
use 5.008008;

our $VERSION = '0.0.1';

sub PUSHED {
    my ($class, $mode, $fh) = @_;
    my $logger;
    return bless \$logger, $class;
}

sub OPEN {
    my ($self, $session, $mode, $fh) = @_;
    $$self = $session;
    return 1;
}

sub WRITE {
    my ($self, $buf, $fh) = @_;
    if ($buf =~ /\ABinding parameters: /) {
        my $sql = $buf;
        $sql =~ s/\ABinding parameters: //;
        my $sub;
        my $line;
        for ( my $i = 0; caller($i); $i++) {
            (my $package, undef, $line) = caller($i);
            next
                if $package eq 'WebGUI::SQL';
            next
                if $package eq 'WebGUI::SQL::ResultSet';
            ($sub) = (caller($i + 1))[3];
            last;
        }
        $$self->log->debug("Query - $sub($line) : $sql");
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

PerlIO::via::WebGUI - Log DBI output to WebGUI

=cut

