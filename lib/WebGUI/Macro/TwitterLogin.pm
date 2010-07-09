package WebGUI::Macro::TwitterLogin;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use List::MoreUtils qw( any );

=head1 NAME

Package WebGUI::Macro::TwitterLogin

=head1 DESCRIPTION

Display a twitter login button

=head2 process( $session )

=over 4

=item *

A session variable

=item *

A URL to an image to log in via Twitter

=back

=cut


#-------------------------------------------------------------------
sub process {
    my $session = shift;

    return "" unless any { $_ eq 'Twitter' } @{ $session->config->get( 'authMethods' ) };
    return "" unless $session->user->isVisitor;
    return "" unless $session->setting->get('twitterEnabled'); # Don't allow if twitter login is disabled

    my $loginUrl    = $session->url->page('op=auth;authType=Twitter;method=login');
    my $imgUrl      = shift || $session->url->extras( 'twitter_login.png' );

    my $output   = sprintf '<a href="%s"><img src="%s" border="0" /></a>', $loginUrl, $imgUrl;
    return $output;
}

1;

#vim:ft=perl
