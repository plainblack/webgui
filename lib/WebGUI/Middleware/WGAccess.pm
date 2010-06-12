package WebGUI::Middleware::WGAccess;
use strict;
use parent qw(Plack::Middleware);
use Path::Class::File;
use Scalar::Util;
use JSON ();

=head1 NAME

WebGUI::Middleware::WGAccess - control access to .wgaccess protected uploads

=head1 DESCRIPTION

This is PSGI middleware for WebGUI that delivers static files (uploads) with .wgaccess
awareness.

This middleware should really only be used in development, for production you want
to be serving static files with something a lot faster.

=cut

sub call {
    my $self = shift;
    my $env  = shift;
    my $session = $env->{'webgui.session'};
    if (! $session) {
        my $logger = $env->{'psgix.logger'};
        $logger && $logger->({ level => 'error', message => 'WebGUI session missing!'});
        return [500, ['Content-Type' => 'text/plain'], 'Internal Server Error'];
    }

    my $r = $self->app->($env);
    $self->response_cb($r, sub {
        my ($status, $headers, $body) = @$r;
        return
            unless Scalar::Util::blessed($body) && $body->can('path');

        my $file = Path::Class::File->new($body->path);
        my $wgaccess = $file->dir->file('.wgaccess');
        return
            unless -e $wgaccess;
        my $contents = $wgaccess->slurp;
        my $privs;
        if ($contents =~ /\A(\d+|[A-Za-z0-9_-]{22})\n(\d+|[A-Za-z0-9_-]{22})\n(\d+|[A-Za-z0-9_-]{22})/) {
            $privs = {
                users => [ $1 ],
                groups => [ $2, $3 ],
                assets => [],
            };
        }
        else {
            $privs = JSON->new->utf8->decode($contents);
        }

        require WebGUI::Asset;
        my $userId = $session->var->get('userId');

        return
            if grep { $_ eq '1' || $_ eq $userId }                      @{ $privs->{users} }
            or grep { $_ eq '1' || $_ eq '7' }                          @{ $privs->{groups} }
            or grep { $session->user->isInGroup($_) }                   @{ $privs->{groups} }
            or grep { WebGUI::Asset->newById($session, $_)->canView }   @{ $privs->{assets} }
            ;

        # failed auto, change response into auth failure
        @$r = (401, [ 'Content-Type' => 'text/plain' ], [ 'Authorization Required' ]);
    });
}

1;
