#!/usr/bin/perl
use Plack::Server::FCGI;

my $app = Plack::Util::load_psgi("/data/WebGUI/etc/dev.localhost.localdomain.psgi");
Plack::Server::FCGI->new->run($app);
