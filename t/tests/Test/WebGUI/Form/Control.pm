package Test::WebGUI::Form::Control;
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use warnings;

use base qw/My::Test::Class/;

use Test::More;
use Test::Deep;
use Test::Exception;
use WebGUI::Test;
use Data::Dumper;
use List::MoreUtils;

sub _constructor : Test(2) {
    my $test    = shift;
    my $session = $test->session;

    my $form = $test->class->new($session);

    note "new for ". $test->class;
    isa_ok $form, $test->class;
    isa_ok $form->session, 'WebGUI::Session';
}

sub t_00_get_set : Test(2) {
    my $test    = shift;
    my $session = $test->session;

    my $form = $test->class->new($session);

    lives_ok { $form->set('name', 'form1'); } 'set name';
    is $form->get('name'), 'form1', 'get name';

}

sub t_01_instanced : Test(1) {
    my $test    = shift;
    my $session = $test->session;

    my $form = $test->class->new($session, {
        name => 'form1',
    });

    is $form->get('name'), 'form1', 'name set on instanciation';
}

sub t_02_method_check : Test(1) {
    my $test    = shift;
    my $session = $test->session;

    my $form = $test->class->new($session);

    can_ok $form, 'headTags';
}

1;
