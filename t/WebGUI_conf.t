# vim:syntax=perl
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#------------------------------------------------------------------

# Test the default WebGUI.conf file to make sure it is valid JSON.

use strict;
use Test::More;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use JSON;
use Path::Class;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;


#----------------------------------------------------------------------------
# Tests

plan tests => 3;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# put your tests here

my $defaultConfigFile = Path::Class::File->new(WebGUI::Paths->configBase, 'WebGUI.conf.original');

ok (-e $defaultConfigFile->stringify, 'WebGUI.conf.original exists');

open my $jsonHandle, join('', '<', $defaultConfigFile->stringify);
my $jsonText;
{
    local $/;
    $jsonText = <$jsonHandle>;
}
close $jsonHandle;

ok($jsonText, 'The file is not empty');

my $perlScalar;
eval { $perlScalar = JSON->new->relaxed(1)->decode($jsonText) };

if ($@) {
    my $index;
    ($index) = $@ =~ /character offset (\d+)/;
    my $fragment = substr $jsonText, int($index/100)*100, 100;
    diag "Problem found in default WebGUI.conf file, look near here:";
    diag $fragment;
}

ok( defined $perlScalar, 'JSON is valid');
