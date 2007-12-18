package WebGUI::URL::Content;

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
use WebGUI::Affiliate;
use WebGUI::Session;

=head1 NAME

Package WebGUI::URL::Content

=head1 DESCRIPTION

A URL handler that does whatever I tell it to do.

=head1 SYNOPSIS

 use WebGUI::URL::Content;
 my $status = WebGUI::URL::Content::handler($r, $s, $config);

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
        my $session = WebGUI::Session->open($server->dir_config('WebguiRoot'), $config->getFilename, $request, $server);
        foreach my $handler (@{$config->get("contentHandlers")}) {
            my $handlerPath = $handler.".pm";
            $handlerPath =~ s{::}{/}g;
            eval { require $handlerPath };
            if ( $@ ) {
                $session->errorHandler->error("Couldn't load content handler $handler.");
            }
            else {
                my $command = $handler."::handler";
                no strict qw(refs);
                my $output = &$command($session);
                use strict;
                if ($output) {
                    unless ($output eq "none" || $output eq "redirect") {
                        unless ($output eq "chunked") {
                            $session->http->sendHeader();
                            $session->output->print($output) 
                        }
                        if ($session->errorHandler->canShowDebug()) {
                            $session->output->print($session->errorHandler->showDebug(),1);
                        }
                    }
                    last;
                }
            }
        }
        WebGUI::Affiliate::grabReferral($session);	# process affiliate tracking request
        $session->close;
        return Apache2::Const::OK;
    });
    $request->push_handlers(PerlTransHandler => sub { return Apache2::Const::OK });
    return Apache2::Const::DECLINED;
}

1;

