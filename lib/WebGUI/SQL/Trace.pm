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
        my $depth;
        for ( $depth = 1; caller($depth); $depth++) {
            my $package = caller($depth);
            last
                if $package !~ /\A(?:WebGUI::SQL|DBI|DBD)(?:\z|::)/;
        }
        local $Log::Log4perl::caller_depth = $Log::Log4perl::caller_depth + $depth + 1;

        $$self->log->debug("Query - $sql");
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

