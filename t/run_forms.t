#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

BEGIN {

    use File::Spec::Functions qw( catdir rel2abs );
    use File::Basename;
    use Test::More;
    use Test::Class;
    use Module::Find;
    use lib rel2abs( catdir ( dirname( __FILE__ ), 'tests' ) );

#    plan skip_all => "Extremely slow asset tests only run if WEBGUI_ASSET_TESTS set"
#        unless $ENV{WEBGUI_ASSET_TESTS};
    useall('Test::WebGUI::Form');
}

Test::Class->runtests;

