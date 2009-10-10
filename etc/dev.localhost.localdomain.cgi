#!/usr/bin/perl
use Plack::Server::CGI;

my $app = Plack::Util::load_psgi("/data/WebGUI/etc/dev.localhost.localdomain.psgi");
Plack::Server::CGI->new->run($app);