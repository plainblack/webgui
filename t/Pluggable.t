#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
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

use strict;
use Test::More;
use WebGUI::Test;
use File::Find;
use File::Spec;
use Test::Deep;

# Must load some Test::Deep modules before we start modifying @INC
use Test::Deep::Array;
use Test::Deep::ArrayLength;
use Test::Deep::ArrayLengthOnly;
use Test::Deep::ArrayElementsOnly;
use Test::Deep::RefType;
use Test::Deep::Shallow;
use Test::Deep::Blessed;
use Test::Deep::Isa;
use Test::Deep::Set;
use Test::Exception;

use WebGUI::Pluggable;

#----------------------------------------------------------------------------
# Init


#----------------------------------------------------------------------------
# Tests

plan tests => 19;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# put your tests here
eval { WebGUI::Pluggable::load("No::Way::In::Hell") };
isnt($@, '', "Module shouldn't load.");
eval { WebGUI::Pluggable::load("Config::JSON") };
is($@, '', "Module should load.");
my $string = WebGUI::Pluggable::run("Data::Dumper","Dumper",[ {color=>"black", make=>"honda"}]);
is($string, q|$VAR1 = {
          'make' => 'honda',
          'color' => 'black'
        };
|, "Can run a function.");
my $dumper = WebGUI::Pluggable::instanciate("Data::Dumper","new",[ [{color=>"black", make=>"honda"}]]);
is($dumper->Dump, q|$VAR1 = {
          'make' => 'honda',
          'color' => 'black'
        };
|, "Can instanciate an object.");

dies_ok { WebGUI::Pluggable::load( '::HA::HA' ) } 'load dies on bad input';
like( $@, qr/^\QInvalid module name: ::HA::HA/, 'helpful error message' );

dies_ok { WebGUI::Pluggable::load( 'HA::HA::' ) } 'load dies on bad input';
dies_ok { WebGUI::Pluggable::load( 'HA::..::..::HA' ) } 'load dies on bad input';
dies_ok { WebGUI::Pluggable::load( '..::..::..::HA' ) } 'load dies on bad input';
dies_ok { WebGUI::Pluggable::load( 'uploads::ik::jo::ikjosdfwefsdfsefwef::myfile.txt\0.pm' ) } 'load dies on bad input';
dies_ok { WebGUI::Pluggable::load( 'HA::::HA' ) } 'load dies on bad input';

#----------------------------------------------------------------------------
# Test find and findAndLoad
{ # Block to localize @INC
    my $lib = File::Spec->catdir( WebGUI::Test->getTestCollateralPath, 'Pluggable', 'lib' );
    local @INC  = ( $lib );

    # Use the i18n files to test
    my @testFiles   = ();
    File::Find::find(
        sub {
            if ( !/^[.]/ && /[.]pm$/ ) {
                my $name    = $File::Find::name;
                $name   =~ s{^$lib[/]}{};
                $name   =~ s/[.]pm$//;
                $name   =~ s{/}{::}g;
                push @testFiles, $name;
            }
        },
        File::Spec->catfile( $lib, 'WebGUI', 'Test', 'Pluggable' ),
    );

    cmp_deeply(
        [ WebGUI::Pluggable::find( 'WebGUI::Test::Pluggable' ) ],
        bag( @testFiles ),
        "find() finds all modules by default",
    );

    cmp_deeply(
        [ WebGUI::Pluggable::find( 'WebGUI::Test::Pluggable', { onelevel => 1 } ) ],
        bag( grep { /^WebGUI::Test::Pluggable::[^:]+$/ } @testFiles ),
        "find() with onelevel",
    );

    cmp_deeply(
        [ WebGUI::Pluggable::find( 'WebGUI::Test::Pluggable', { exclude => [ 'WebGUI::Test::Pluggable::Second' ] } ) ],
        bag( grep { $_ ne 'WebGUI::Test::Pluggable::Second' } @testFiles ),
        "find() with exclude",
    );

    cmp_deeply(
        [ WebGUI::Pluggable::find( 'WebGUI::Test::Pluggable', { exclude => [ 'WebGUI::Test::Pluggable::First*' ] } ) ],
        bag( grep { $_ ne 'WebGUI::Test::Pluggable::First' && $_ ne 'WebGUI::Test::Pluggable::FirstOne' } @testFiles ),
        "find() with exclude with glob",
    );

    cmp_deeply(
        [ WebGUI::Pluggable::find( 'WebGUI::Test::Pluggable', { exclude => [ 'WebGUI::Test::Pluggable*' ] } ) ],
        [], 
        "find() with exclude with massive glob",
    );

    cmp_deeply(
        [ WebGUI::Pluggable::find( 'WebGUI::Test::Pluggable', { exclude => [ 'WebGUI::Test::Pluggable::First.*' ] } ) ],
        bag( grep { $_ ne 'WebGUI::Test::Pluggable::First' && $_ ne 'WebGUI::Test::Pluggable::FirstOne' } @testFiles ),
        "find() with exclude with regex",
    );

    cmp_deeply(
        [ WebGUI::Pluggable::find( 'WebGUI::Test::Pluggable', { exclude => [ qw/WebGUI::Test::Pluggable::First WebGUI::Test::Pluggable::Second::Child/ ] } ) ],
        bag( grep {
            $_ ne 'WebGUI::Test::Pluggable::First'
         && $_ ne 'WebGUI::Test::Pluggable::Second::Child'
        } @testFiles ),
        "find() with multiple excludes",
    );

    cmp_deeply(
        [ WebGUI::Pluggable::find( 'WebGUI::Test::Pluggable', { onelevel => 1, return => "name" } ) ],
        bag( map { /::([^:]+)$/; $1 } grep { /^WebGUI::Test::Pluggable::[^:]+$/ } @testFiles ),
        "find() with return => name",
    );
};

#vim:ft=perl
