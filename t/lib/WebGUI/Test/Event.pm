package WebGUI::Test::Event;

use List::Util qw(first);
use Exporter qw(import);

our @EXPORT = qw(trap);

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

=head1 SYNOPSIS

Temporarily handle WebGUI::Events.

=head1 METHODS

These methods are available from this class:

=cut

our $session;
our @names;
our @trap;

my $handlerName = __PACKAGE__ . '::handler';

sub handler {
    my ($s, $n) = @_;
    return unless first { $_ eq $n } @names;
    push @trap, \@_;
};

#-------------------------------------------------------------------

=head2 trap ($code, $session, @names)

Traps the events named by @names and returns them as a list of arrayrefs in
the order they occured. The arrayrefs are all arguments passed to the event
handler.

=cut

sub trap(&$@) {
    my $block = shift;
    local ($session, @names) = @_;
    local @trap;

    my $config  = $session->config;
    my $events  = $config->get('events');
    local %WebGUI::Event::cache;
    for my $name (@names) {
        $config->set("events/$name", $handlerName);
    }
    eval { $block->() };
    my $err = $@;
    if ($events) {
        $config->set(events => $events);
    }
    else {
        $config->delete('events');
    }
    die $err if $err;
    return @trap;
}
