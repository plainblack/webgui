package WebGUI::URL::Snoop;

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
use Apache2::Const -compile => qw(OK DECLINED);
use WebGUI::Session;

=head1 NAME

Package WebGUI::URL::Snoop

=head1 DESCRIPTION

A URL handler that should never be called.

=head1 SYNOPSIS

 use WebGUI::URL::Snoop;
 my $status = WebGUI::URL::Snoop::handler($r, $configFile);

=head1 SUBROUTINES

These subroutines are available from this package:

=cut

#-------------------------------------------------------------------

=head2 handler ( request, configFile ) 

The Apache request handler for this package.

=cut

sub handler {
    my ($request, $server, $config) = @_;
    $request->content_type("text/html"); 
    $request->push_handlers(PerlResponseHandler => sub { 
        print q|<html><head><title>Snoopy</title></head><body><div style="width: 600px; padding: 200px;">&#87;&#104;&#121;&#32;&#119;&#111;&#117;&#108;&#100;&#32;&#121;&#111;&#117;&#32;&#116;&#121;&#112;&#101;&#32;&#105;&#110;&#32;&#116;&#104;&#105;&#115;&#32;&#85;&#82;&#76;&#63;&#32;&#82;&#101;&#97;&#108;&#108;&#121;&#46;&#32;&#87;&#104;&#97;&#116;&#32;&#119;&#101;&#114;&#101;&#32;&#121;&#111;&#117;&#32;&#101;&#120;&#112;&#101;&#99;&#116;&#105;&#110;&#103;&#32;&#116;&#111;&#32;&#115;&#101;&#101;&#32;&#104;&#101;&#114;&#101;&#63;&#32;&#89;&#111;&#117;&#32;&#114;&#101;&#97;&#108;&#108;&#121;&#32;&#110;&#101;&#101;&#100;&#32;&#116;&#111;&#32;&#103;&#101;&#116;&#32;&#97;&#32;&#108;&#105;&#102;&#101;&#46;&#32;&#65;&#114;&#101;&#32;&#121;&#111;&#117;&#32;&#115;&#116;&#105;&#108;&#108;&#32;&#104;&#101;&#114;&#101;&#63;&#32;&#83;&#101;&#114;&#105;&#111;&#117;&#115;&#108;&#121;&#44;&#32;&#121;&#111;&#117;&#32;&#110;&#101;&#101;&#100;&#32;&#116;&#111;&#32;&#103;&#111;&#32;&#100;&#111;&#32;&#115;&#111;&#109;&#101;&#116;&#104;&#105;&#110;&#103;&#32;&#101;&#108;&#115;&#101;&#46;&#32;&#73;&#32;&#116;&#104;&#105;&#110;&#107;&#32;&#121;&#111;&#117;&#114;&#32;&#98;&#111;&#115;&#115;&#32;&#105;&#115;&#32;&#99;&#97;&#108;&#108;&#105;&#110;&#103;&#46;</div></body></html>|;
        return Apache2::Const::OK;
    } );
	$request->push_handlers(PerlTransHandler => sub { return Apache2::Const::OK });
    return Apache2::Const::DECLINED;
}


1;

