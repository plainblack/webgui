package WebGUI::URL::Credits;

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

Package WebGUI::URL::Credits

=head1 DESCRIPTION

A URL handler that displays the credits file.

=head1 SYNOPSIS

 use WebGUI::URL::Credits;
 my $status = WebGUI::URL::Credits::handler($r, $s, $config);

=head1 SUBROUTINES

These subroutines are available from this package:

=cut

#-------------------------------------------------------------------

=head2 handler ( request, server, config ) 

The Apache request handler for this package.

=cut

sub handler {
    my ($request, $server, $config) = @_;
    $request->push_handlers(PerlResponseHandler => sub { 
        my $content = "";
        open(my $FILE, "<", $config->getWebguiRoot."/docs/credits.txt");
        while (my $line = <$FILE>) {
            $content .= $line;
        }
        close($FILE);
        print $content;
        return Apache2::Const::OK;
    } );
	$request->push_handlers(PerlTransHandler => sub { return Apache2::Const::OK });
    return Apache2::Const::DECLINED;
}


1;

