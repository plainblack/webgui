package Plack::Middleware::WGAccess;
use strict;
use warnings;
use base qw/Plack::Middleware::Static/;
use Path::Class 'dir';

=head1 NAME

Plack::Middleware::WGAccess

=head1 DESCRIPTION

Plack Middleware that delivers static files with .wgaccess awareness

=cut

sub _handle_static {
    my($self, $env) = @_;

    #######################################
    # Copied from Plack::Middleware::Static::_handle_static
    
    my $path_match = $self->path or return;

    if ($env->{PATH_INFO} =~ m!\.\.[/\\]!) {
        return $self->return_403;
    }

    my $path = do {
        my $matched;
        local $_ = $env->{PATH_INFO};
        if (ref $path_match eq 'CODE') {
            $matched = $path_match->($_);
        } else {
            $matched = $_ =~ $path_match;
        }
        return unless $matched;
        $_;
    } or return;

    my $docroot = dir($self->root || ".");
    my $file = $docroot->file(File::Spec::Unix->splitpath($path));
    my $realpath = Cwd::realpath($file->absolute->stringify);

    # Is the requested path within the root?
    if ($realpath && !$docroot->subsumes($realpath)) {
        return $self->return_403;
    }

    # Does the file actually exist?
    if (!$realpath || !-f $file) {
        return $self->return_404;
    }

    # If the requested file present but lacking the permission to read it?
    if (!-r $file) {
        return $self->return_403;
    }
    
    ###############################
    # Copied from WebGUI::URL::Uploads
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
            
            # Construct request,server,config in the usual way
            require WebGUI::Session::Plack;
            my $request = WebGUI::Session::Plack->new( env => $env );
            my $server = $request->server;
            
            my $session = $request->pnotes('wgSession');
            unless (defined $session) {
                $session = WebGUI::Session->open($server->dir_config('WebguiRoot'), $request->dir_config('WebguiConfig'), $request, $server);
            }
            my $hasPrivs = ($session->var->get("userId") eq $privs[0] || $session->user->isInGroup($privs[1]) || $session->user->isInGroup($privs[2]));
            $session->close();
            if ($hasPrivs) {
                return $self->SUPER::_handle_static($env); # serve statically
            }
            else {
                return $self->return_403;
            }
        }
    } else {
        return $self->SUPER::_handle_static($env); # serve statically
    }
}

1;