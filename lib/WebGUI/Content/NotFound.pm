package WebGUI::Content::NotFound;

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
use WebGUI::Asset;

=head1 NAME

Package WebGUI::Content::NotFound

=head1 DESCRIPTION

A content handler that displays a default page when no other content is produced.

=head1 SYNOPSIS

 use WebGUI::Content::NotFound;
 my $output = WebGUI::Content::NotFound::handler($session);

=head1 SUBROUTINES

These subroutines are available from this package:

=cut

#-------------------------------------------------------------------

=head2 handler ( session ) 

The content handler for this package.

=cut

sub handler {
    my ($session) = @_;
	$session->http->setStatus(404);
    my $output = "";
	my $notFound = WebGUI::Asset->getNotFound($session);
	if (defined $notFound) {
        $session->asset($notFound);
        $output = eval { $notFound->www_view };
	} 
    else {
        $session->log->error("The notFound page could not be instanciated!");
		$output = "An error was encountered while processing your request.";
	}
	$output = "An error was encountered while processing your request." if $output eq '';
    return $output;
}

1;

