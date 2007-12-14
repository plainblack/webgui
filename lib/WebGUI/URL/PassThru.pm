package WebGUI::URL::PassThru;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2007 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use Apache2::Const -compile => qw(OK DECLINED DIR_MAGIC_TYPE);


=head1 NAME

Package WebGUI::URL::PassThru

=head1 DESCRIPTION

A URL handler that just passes the URLs back to Apache.

=head1 SYNOPSIS

 use WebGUI::URL::PassThru;
 my $status = WebGUI::URL::PassThru::handler($r, $s, $config);

=head1 SUBROUTINES

These subroutines are available from this package:

=cut

#-------------------------------------------------------------------

=head2 handler ( request, server, config ) 

=cut

sub handler {
    my ($request, $server, $config) = @_;
	if ($request->handler eq 'perl-script' &&  # Handler is Perl
	    -d $request->filename              &&  # Filename requested is a directory
	    $request->is_initial_req)		     # and this is the initial request
	{
	    $request->handler(Apache2::Const::DIR_MAGIC_TYPE);  # Hand off to mod_dir
	    return Apache2::Const::OK;
	}
    return Apache2::Const::DECLINED;
}

1;

