# vim:syntax=perl
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#------------------------------------------------------------------

# Write a little about what this script tests.
# 
#

use Path::Class;
use strict;
use Test::More;
plan skip_all => 'set CODE_COP to enable this test' unless $ENV{CODE_COP};

use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;

##Delay this so that the skip_all can work the way it should
eval { require Test::Perl::Critic; };
if ($@) {
    plan skip_all => "Test::Perl::Critic not installed";
}

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

my $label_profile = Path::Class->dir(WebGUI::Test->lib)->parent->subdir('t')->subdir('i18n')->file('perlcritic');
Test::Perl::Critic->import(-profile => $label_profile->stringify);
all_critic_ok(WebGUI::Test->lib);
