package WebGUI::Macro::FacebookLogin;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2010 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;

=head1 NAME

Package WebGUI::Macro::FacebookLogin

=head1 DESCRIPTION

Works with the Facebook Auth plugin to allow users to log in using facebook.

=cut


#-------------------------------------------------------------------

=head2 process

Return an image with a link to login into Facebook.

=cut

sub process {
	my $session = shift;
	my $url = $session->url;
	return sprintf '<a href="%s"><img src="%s" alt="login with Facebook" /></a>',
		$url->page('op=auth;authType=Facebook;method=login'),
		$url->extras('macro/FacebookLogin/login-button.png');
}

1;

#vim:ft=perl
