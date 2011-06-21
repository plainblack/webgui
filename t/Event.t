#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#------------------------------------------------------------------

use strict;
use warnings;

use FindBin;
use Test::More tests => 12;

use lib "$FindBin::Bin/lib";
use WebGUI::Test;
use WebGUI::Session;
use WebGUI::Event;

my $session = WebGUI::Test->session;
WebGUI::Test->originalConfig('events');
my $config  = $session->config;
$config->set('events/foo', [
    'My::Events::onFoo',
    'My::Events::onFoo2'
]);
$config->set('events/bar', 'My::Events::onBar');

my ($foo, $foo2, $bar) = @_;

sub My::Events::onFoo {
    my ($session, $name, $one, $two, $three) = @_;
    isa_ok $session, 'WebGUI::Session', 'onFoo: session';
    is $name, 'foo', "onFoo: $name";
    $foo = $one;
}

sub My::Events::onFoo2 {
    my ($session, $name, $one, $two, $three) = @_;
    isa_ok $session, 'WebGUI::Session', 'onFoo2: session';
    is $name, 'foo', "onFoo2: $name";
    $foo2 = $two;
}

sub My::Events::onBar {
    my ($session, $name, $one, $two, $three) = @_;
    isa_ok $session, 'WebGUI::Session', 'onBar: session';
    is $name, 'bar', "onBar: $name";
    $bar = $three;
}

# Tell require that My::Events is already loaded.
$INC{'My/Events.pm'} = __FILE__;

fire $session, 'foo', qw(first second third);

is $foo, 'first', 'foo called';
is $foo2, 'second', 'foo2 called';
ok !defined $bar, 'bar not called';
undef $foo;
undef $foo2;

fire $session, 'bar', qw(first second third);
ok !defined $foo, 'foo not called';
ok !defined $foo2, 'foo2 not called';
is $bar, 'third', 'onBar called';

#vim:ft=perl
