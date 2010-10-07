package WebGUI::Operation::Fork;

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
use warnings;

use WebGUI::Fork;
use WebGUI::Pluggable;

=head1 NAME

WebGUI::Operation::Fork

=head1 DESCRIPTION

URL dispatching for WebGUI::Fork monitoring

=head1 SUBROUTINES

These subroutines are available from this package:

=cut

#-------------------------------------------------------------------

=head2 www_fork ( session )

Dispatches to the proper module based on the module form parameter if op is
fork.  Returns insufficient privilege page if the user doesn't pass canView on
the process before dispatching.

=cut

sub www_fork {
    my $session = shift;
    my $form    = $session->form;
    my $module  = $form->get('module') || 'Status';
    my $pid     = $form->get('pid') || return undef;

    my $process = WebGUI::Fork->new( $session, $pid );

    return $session->privilege->insufficient unless $process->canView;

    my $log = $session->log;

    unless ($process) {
        $log->error("Tried to get info for nonexistent process $pid");
        return undef;
    }

    my $output = eval { WebGUI::Pluggable::run( "WebGUI::Fork::$module", 'handler', [$process] ); };

    if ($@) {
        $log->error($@);
        return undef;
    }

    return $output;
} ## end sub www_fork

1;
