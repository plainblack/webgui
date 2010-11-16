package WebGUI::URL::Uploads;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2009 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use Apache2::Const -compile => qw(OK DECLINED NOT_FOUND AUTH_REQUIRED FORBIDDEN);
use WebGUI::Session;

=head1 NAME

Package WebGUI::URL::Uploads;

=head1 DESCRIPTION

A URL handler that handles privileges for uploaded files.

=head1 SYNOPSIS

 use WebGUI::URL::Uploads;
 my $status = WebGUI::URL::Uploads::handler($r, $s, $config);

=head1 SUBROUTINES

These subroutines are available from this package:

=cut

#-------------------------------------------------------------------

=head2 handler ( request, server, config ) 

The Apache request handler for this package.

=cut

sub handler {
    my ($request, $server, $config) = @_;
    $request->push_handlers(PerlAccessHandler => sub {
        my $path = $request->filename;
        return Apache2::Const::NOT_FOUND
            unless -e $path;
        $path =~ s{[^/]*$}{};
        return Apache2::Const::OK
            unless -e $path . '.wgaccess';

        open my $FILE, '<' , $path . '.wgaccess';
        my $fileContents = do { local $/; <$FILE> };
        close($FILE);
        my @users;
        my @groups;
        my @assets;
        my $state;
        if ($fileContents =~ /\A(?:\d+|[A-Za-z0-9_-]{22})\n(?:\d+|[A-Za-z0-9_-]{22})\n(?:\d+|[A-Za-z0-9_-]{22})/) {
            my @privs = split("\n", $fileContents);
            push @users, $privs[0];
            push @groups, @privs[1,2];
        }
        else {
            my $privs = JSON->new->decode($fileContents);
            @users = @{ $privs->{users} };
            @groups = @{ $privs->{groups} };
            @assets = @{ $privs->{assets} };
            $state  = $privs->{state};
        }

        return Apache2::Const::FORBIDDEN
            if $state eq "trash";

        return Apache2::Const::OK
            if grep { $_ eq '1' } @users;

        return Apache2::Const::OK
            if grep { $_ eq '1' || $_ eq '7' } @groups;

        my $session = $request->pnotes('wgSession');
        unless (defined $session) {
            $session = WebGUI::Session->open($server->dir_config('WebguiRoot'), $config->getFilename, $request, $server);
        }

        my $userId = $session->var->get('userId');

        return Apache2::Const::OK
            if grep { $_ eq $userId } @users;

        my $user = $session->user;

        return Apache2::Const::OK
            if grep { $user->isInGroup($_) } @groups;

        return Apache2::Const::OK
            if grep { WebGUI::Asset->new($session, $_)->canView } @assets;

        return Apache2::Const::AUTH_REQUIRED;
    } );
    return Apache2::Const::OK;
}


1;

