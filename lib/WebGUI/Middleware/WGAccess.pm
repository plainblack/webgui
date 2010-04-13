package WebGUI::Middleware::WGAccess;
use strict;
use Plack::App::File;
use parent qw(Plack::Middleware);
use Path::Class 'dir';

=head1 NAME

WebGUI::Middleware::WGAccess - control access to .wgaccess protected uploads

=head1 DESCRIPTION

This is PSGI middleware for WebGUI that delivers static files (uploads) with .wgaccess
awareness.

This middleware should really only be used in development, for production you want
to be serving static files with something a lot faster.

=cut

use Plack::Util::Accessor qw( config );

sub call {
    my $self = shift;
    my $env  = shift;
    my $app = $self->app;
    my $config = $self->config or die 'Mandatory config parameter missing';
    my $uploadsPath = $config->get('uploadsPath');
    my $uploadsURL = $config->get('uploadsURL');
    
    my $path = $env->{PATH_INFO};
    my $matched = $path =~ s{^\Q$uploadsURL\E/}{};
    return $app->($env) unless $matched;
    
    my $root = dir($uploadsPath);
    my $file = $root->file(File::Spec::Unix->splitpath($path));
    my $wgaccess = File::Spec::Unix->catfile($file->dir, '.wgaccess');
    
    if (-e $wgaccess) {
        my $fileContents;
        open(my $FILE, "<", $wgaccess);
        while (my $line = <$FILE>) {
            $fileContents .= $line;
        }
        close($FILE);
        my @privs = split("\n", $fileContents);
        
        unless ($privs[1] eq "7" || $privs[1] eq "1") {
            my $session = $env->{'webgui.session'};
            my $hasPrivs = ($session->var->get("userId") eq $privs[0] || $session->user->isInGroup($privs[1]) || $session->user->isInGroup($privs[2]));
            warn "has: $hasPrivs";
            warn $session->var->get("userId");
            warn $session->user->isInGroup($privs[1]);
            warn $session->user->isInGroup($privs[2]);
            if ($hasPrivs) {
                $self->{file} ||= Plack::App::File->new;
                return $self->{file}->serve_path($env, $file); # serve statically
            }
            else {
                return [403, ['Content-Type' => 'text/plain'], ['Forbidden']];
            }
        }
    }
    
    $self->{file} ||= Plack::App::File->new;
    return $self->{file}->serve_path($env, $file); # serve statically
}

1;