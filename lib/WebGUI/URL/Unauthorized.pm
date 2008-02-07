package WebGUI::URL::Unauthorized;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2008 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use Apache2::Const -compile => qw(AUTH_REQUIRED);


=head1 NAME

Package WebGUI::URL::Unauthorized

=head1 DESCRIPTION

A URL handler that deals with requests where the user cannot access what they requested. 

=head1 SYNOPSIS

 use WebGUI::URL::Unauthorized;
 my $status = WebGUI::URL::Unauthorized::handler($r, $s, $config);

=head1 SUBROUTINES

These subroutines are available from this package:

=cut

#-------------------------------------------------------------------

=head2 handler ( request, server, config ) 

The Apache request handler for this package.

=cut

sub handler {
    my ($request, $server, $config) = @_;
    return Apache2::Const::AUTH_REQUIRED; 
}

1;

