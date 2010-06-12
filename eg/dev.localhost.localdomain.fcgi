#!/usr/bin/perl
use Plack::Server::FCGI;

my $app = Plack::Util::load_psgi("../app.psgi");
Plack::Server::FCGI->new->run($app);
