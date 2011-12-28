package WebGUI::Event;

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

use Exporter qw(import);
use WebGUI::Pluggable;
use Try::Tiny;

our @EXPORT = qw(fire);

=head1 NAME

WebGUI::Event

=head1 DESCRIPTION

Run custom code when things happen in WebGUI.

=head1 SUBSCRIBERS

If you're trying to handle an event, this is you.

=head2 CONFIG FILE

The C<events> hash in the config file maps names to lists of event handlers.
They will be run in the order they are defined. Instead of a list, you can
just specify one handler, and it will be treated as a list of one element.
The handlers are subroutines and must be able to be found by
WebGUI::Pluggable::run.

    #...
    "events" : {
        "asset::export"    : "My::Events::onExport",
        "storage::addFile" : "My::Events::onFile"
    },
    #...

=head2 PERL CODE

Your code will be called with the arguments that are passed to
WebGUI::Event::Fire by the publisher.

    package My::Events;

    sub onExport {
        my ($session, $name, $asset, $path) = @_;
        #...
    }

    sub onFile {
        my ($session, $name, $storage, $filename) = @_;
        #...
    }

=head1 PUBLISHERS

If you want to let people hook some behavior in the code you're writing, this
is you.

    package WebGUI::Something;

    use WebGUI::Event;

    sub someThing {
        #...
        fire $session, 'something::happened', $with, $some, $arguments;
        #...
    }

=head1 SUBROUTINES

These subroutines are available from this package:

=cut

#-------------------------------------------------------------------

=head2 fire($session, $name, ...)

Exported by default. Calls all the subroutines defined in C<$session>'s config
file for C<$name> in order with these same arguments.

=cut

our %cache;

sub fire {
    my ($session, $name) = splice @_, 0, 2;
    my $config = $session->config;
    my $path   = $config->getFilePath;
    unless (exists $cache{$path}{$name}) {
        my $events = $config->get('events') or return;
        my $names  = $events->{$name}       or return;
        $names     = [ $names ] unless ref $names eq 'ARRAY';
        $cache{$path}{$name} = [
            grep { $_ } map {
                if ($_) {
                    my ($package, $subname) = /^(.*)::([^:]+)$/;
                    try {
                        WebGUI::Pluggable::load($package);
                        $package->can($subname);
                    }
                    catch {
                        $session->log->error(
                            "Couldn't load event handler for $name: $_"
                        );
                        undef;
                    };
                }
            } @$names
        ];
    }
    $_->($session, $name, @_) for @{ $cache{$path}{$name} };
}

=head1 RATIONALE

=head2 Why can't I register listeners at runtime? or...

=head2 Why is there no subscribe method? or...

=head2 Why is this in the config file instead of somewhere else?

WebGUI::Events are conceptually per-site things. The code to be called is
static and hopefully controlled someone by with access to the config file.

That being said, you could certainly build something more dynamic on top of
this system. Writing an event handler that publishes messages to a broker
service like DBus or RabbitMQ is entirely possible.

=cut

1;
