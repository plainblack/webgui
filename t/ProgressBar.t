#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#------------------------------------------------------------------

{
    package WebGUI::Test::ProgressBar;
    use warnings;
    use strict;

    sub new { bless {}, shift }

    sub foo { $_[0]->{foo} = $_[1] }

    sub bar { $_[0]->{bar} = $_[1] }
}

use strict;
use warnings;


use Test::More;
use Test::MockObject::Extends;
use WebGUI::Test;
use WebGUI::Session;

my $session = WebGUI::Test->session;

# Test the run method of ProgessBar -- it does some symbol table
# manipulation...

my $TestTitle = 'test title';
my $TestIcon  = '/test/icon';
my $TestUrl   = 'http://test.com/url';

my ($started, $finished);
my @updates = qw(one two not used);

sub mockbar {
    Test::MockObject::Extends->new(WebGUI::ProgressBar->new($session));
}

my $pb = mockbar
    ->mock(start => sub {
        my ($self, $title, $icon) = @_;
        is $title, $TestTitle, 'title';
        is $icon,  $TestIcon, 'icon';
        ok !$started, q"hadn't started yet";
        $started = 1;
    })
    ->mock(update => sub {
        my ($self, $message) = @_;
        my $expected = shift(@updates);
        is $message, $expected, 'message';
    })
    ->mock(finish => sub {
        my ($self, $url) = @_;
        is $url, $TestUrl, 'url';
        ok !$finished, q"hadn't finished yet";
        $finished = 1;
        return 'chunked';
    });

my $object = WebGUI::Test::ProgressBar->new;
ok !$object->{foo}, 'no foo';
ok !$object->{bar}, 'no bar';

sub wrapper {
    my ($bar, $original, $obj, $val) = @_;
    $bar->update($val);
    $obj->$original($val);
}

is $pb->run(
    arg   => 'argument',
    title => $TestTitle,
    icon  => $TestIcon,
    code  => sub {
        my ($bar, $arg) = @_;
        isa_ok $bar, 'WebGUI::ProgressBar', 'code invocant';
        is $arg, 'argument', 'code argument';
        ok $started, 'started';
        ok !$finished, 'not finished yet';
        is $object->foo('one'), 'one', 'wrapped return';
        is $object->bar('two'), 'two', 'wrapped return (again)';
        return $TestUrl;
    },
    wrap  => {
        'WebGUI::Test::ProgressBar::foo' => \&wrapper,
        'WebGUI::Test::ProgressBar::bar' => \&wrapper,
    }
), 'chunked', 'run return value';

ok $finished, 'finished now';
is $object->{foo}, 'one', 'foo original called';
is $object->{bar}, 'two', 'bar original called';
$object->foo('foo'); 
is $object->{foo}, 'foo', 'foo still works';
$object->bar('bar');
is $object->{bar}, 'bar', 'bar still works';
is @updates, 2, 'no shifting from updates after run';

delete @{$object}{qw(foo bar)};

my $updated;
# make sure that the symbol table machinations work even when something dies
$pb = mockbar->mock(start => sub {})
    ->mock(finish => sub {})
    ->mock(update => sub { $updated = 1 });

eval {
    $pb->run(
        code => sub {
            $object->foo('foo');
            $object->bar('bar');
        },
        wrap => {
            'WebGUI::Test::ProgressBar::foo' => \&wrapper,
            'WebGUI::Test::ProgressBar::bar' => sub { die "blar!\n" }
        }
    );
};
my $e = $@;

is $e, "blar!\n", 'exception propogated';
is $object->{foo}, 'foo', 'foo after die';
ok !$object->{bar}, 'bar did not get set';
$object->bar('bar');
is $object->{bar}, 'bar', 'but it works now';

ok $updated, 'update called for foo';
$updated = 0;
$object->foo('ignored');
ok !$updated, 'update not called for foo';

done_testing;

#vim:ft=perl
