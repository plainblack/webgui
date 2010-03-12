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
use Apache2::Const -compile => qw(OK DECLINED NOT_FOUND AUTH_REQUIRED);
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
	    if (-e $request->filename) {
		    my $path = $request->filename;
		    $path =~ s/^(\/.*\/).*$/$1/;
	    	if (-e $path.".wgaccess") {
			    my $fileContents;
			    open(my $FILE, "<" ,$path.".wgaccess");
			    while (my $line = <$FILE>) {
				    $fileContents .= $line;
			    }
			    close($FILE);
			    my @privs = split("\n", $fileContents);
			    unless ($privs[1] eq "7" || $privs[1] eq "1") {
					my $session = $request->pnotes('wgSession');
					unless (defined $session) {
#						$session = WebGUI::Session->open($server->dir_config('WebguiRoot'), $config->getFilename, $request);
					}
				    my $hasPrivs = ($session->var->get("userId") eq $privs[0] || $session->user->isInGroup($privs[1]) || $session->user->isInGroup($privs[2]));
				    $session->close();
				    if ($hasPrivs) {
					    return Apache2::Const::OK;
				    }    
                    else {
					    return Apache2::Const::AUTH_REQUIRED;
				    }
			    }
		    }
		    return Apache2::Const::OK;
	    } 
        else {
		    return Apache2::Const::NOT_FOUND;
	    }
    } );
    return Apache2::Const::OK;
}


1;

