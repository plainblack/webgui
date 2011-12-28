package WebGUI::Fork::Status;

use JSON;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2012 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use warnings;

=head1 NAME

WebGUI::Fork::Status

=head1 DESCRIPTION

Returns a json response of the following form:

    {
        "finished" : true,
        "elapsed"  : 10,
        "status"   : "whatever is in the status field.  Could be anything.",
        "error"    : "whatever is in the error field"
    }

Note that if your status is JSON, you'll have to decode that seperately, so
something like:

    decoded = JSON.parse(r.responseText);
    status = JSON.parse(decoded.status);

Finished is obviously true or false.  Notably, it will be true in the error
case: so to status.finished && !status.error means successful completion.
Error will only be present if the process died for some reason.

Status will always be present, mostly so you can see what the last status was
before it died.

Elapsed will be the number of seconds since the process started (or until the
process finished, if it is finished).

=head1 SUBROUTINES

These subroutines are available from this package:

=cut

#-------------------------------------------------------------------

=head2 handler ( process )

See the synopsis for what kind of response this generates.

=cut

sub handler {
    my $process = shift;
    my $status  = $process->getStatus;
    my ( $finished, $startTime, $endTime, $error ) = $process->get( 'finished', 'startTime', 'endTime', 'error' );

    $endTime = time() unless $finished;

    my %status = (
        status   => $status,
        elapsed  => ( $endTime - $startTime ),
        finished => ( $finished ? \1 : \0 ),
    );
    $status{error} = $error if $finished;
    $process->session->response->content_type('text/plain');
    JSON::encode_json( \%status );
} ## end sub handler

1;
