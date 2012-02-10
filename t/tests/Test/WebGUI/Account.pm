package Test::WebGUI::Account;
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
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

    my $obj = $test->class->new($session);

    note "new for ". $test->class;
    isa_ok $obj, $test->class;
    isa_ok $obj->session, 'WebGUI::Session';
}

sub t_00_method_check : Test(1) {
    my $test    = shift;
    my $session = $test->session;
    my $obj = $test->class->new($session);

    can_ok $obj, qw/session module uid bare store appendCommonVars callMethod displayContent canView
                editSettingsForm editSettingsFormSave getLayoutTemplateId getStyleTemplateId getUrl
                getUser processTemplate showError /;
}

sub t_01_editSettingsForm : Tests {
    my $test = shift;
    my $session = $test->session;
    my $obj = $test->class->new( $session );

    my $fb = $obj->editSettingsForm;
    isa_ok $fb, 'WebGUI::FormBuilder';
}

1;
