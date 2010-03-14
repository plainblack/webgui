package My::Test::Class;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use FindBin;
use lib "$FindBin::Bin/lib";

use base qw/Test::Class Class::Data::Inheritable/;

BEGIN {
    __PACKAGE__->mk_classdata('class');
    __PACKAGE__->mk_classdata('session');
}

use Test::More;
use Test::Deep;
use Test::Exception;

use WebGUI::Test;
use WebGUI::Asset;

sub _00_init : Test(startup => 1) {
    my $test = shift;
    my $session = WebGUI::Test->session;
    $test->session($session);
    my $class = ref $test;
    $class =~ s/Test:://;
    $test->class($class);
    lives_ok { WebGUI::Asset->loadModule($class); } "loaded module class $class";
}

1
