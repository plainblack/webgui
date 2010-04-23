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

# Write a little about what this script tests.
# 
#

use FindBin;
use strict;
use lib "$FindBin::Bin/lib";
use Test::More;
use Test::Deep;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;


#----------------------------------------------------------------------------
# Tests

plan tests => 29;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# Basic API
use_ok( 'WebGUI::Wizard' );

ok( !eval{ WebGUI::Wizard->new; 1 }, "Requires a session" );
ok( !eval{ WebGUI::Wizard->new( "not a session" ); 1 }, "Requires a session" );

my $wizard = WebGUI::Wizard->new( $session );
isa_ok( $wizard, 'WebGUI::Wizard' );
is( ref $wizard->_get_steps, "ARRAY", '_get_steps returns arrayref' );
is( $wizard->session, $session, 'session method' );

ok( !$wizard->getCurrentStep, "No current step yet" );
$wizard->setCurrentStep( "one" );
is( $wizard->getCurrentStep, "one", "SetCurrentStep" );


#----------------------------------------------------------------------------
# Form Start and End

my $o   = $wizard->getFormStart;
like( $o, qr/<form/, 'getFormStart gives form' );
like( $o, qr/wizard_class.+WebGUI::Wizard/, 'getFormStart wizard_class' );
like( $o, qr/wizard_step.+one/, 'getFormStart wizard_step' );

$o   = $wizard->getFormStart( "two" );
like( $o, qr/wizard_step.+two/, 'getFormStart wizard_step override step' );

$o  = $wizard->getFormEnd;
like( $o, qr{</form>}, 'getFormEnd' );

#----------------------------------------------------------------------------
# Steps

$wizard = WebGUI::Wizard::Test->new( $session );
$session->request->setup_body( {
    wizard_step     => "one",
} );
is( $wizard->getCurrentStep, "one", "getCurrentStep from form" );
is( $wizard->getNextStep, "two", "getNextStep" );

is( $wizard->getNextStep( "three" ), "four", "getNextStep with arg" );

#----------------------------------------------------------------------------
# Set/Get
cmp_deeply( 
    $wizard->set( { "text" => "Hello World!\n", } ),
    {
        "text" => "Hello World!\n",
    },
    "set returns all params"
);
cmp_deeply( 
    $wizard->set( { "text2" => "Goodbye!\n", } ),
    {
        "text" => "Hello World!\n",
        "text2" => "Goodbye!\n",
    },
    "set returns all params"
);
is( $wizard->get( 'text' ), "Hello World!\n", "get with arg" );
cmp_deeply( 
    $wizard->get, 
    {
        "text"  => "Hello World!\n",
        "text2" => "Goodbye!\n",
    },
    'get without arg'
);

#----------------------------------------------------------------------------
# Freeze/Thaw
$wizard->freeze;
$wizard->set( { "text" => "No!" } );
$wizard->set( { "add" => "Also No!" } );
cmp_deeply( 
    $wizard->thaw,
    {
        "text" => "Hello World!\n",
        "text2" => "Goodbye!\n",
    },
    "thaw returns params"
);
cmp_deeply( 
    $wizard->get,
    {
        "text" => "Hello World!\n",
        "text2" => "Goodbye!\n",
    },
    "thaw overwrites params"
);


#----------------------------------------------------------------------------
# dispatch

$wizard = WebGUI::Wizard::Test->new( $session );
$session->request->setup_body({});
is( $wizard->dispatch,
    "begin",
    "first step is assumed"
);
cmp_deeply( 
    $wizard->thaw,
    { },
    'scratch is cleared'
);

$session->request->setup_body({
    wizard_step     => "one",
});
is( 
    $wizard->dispatch,
    'completed',
    'dispatch success returns text of next step'
);
cmp_deeply(
    $wizard->thaw,
    {
        one     => "completed",
    },
    "dispatch froze after success"
);

$session->request->setup_body({
    wizard_step     => "two",
});
is(
    $wizard->dispatch,
    "errorcompleted",
    'dispatch error returns text of process sub and previous form',
);
cmp_deeply(
    $wizard->get,
    {
        one     => 'completed',
        two     => 'error',
    },
    'dispatch thawed and allowed new param',
);
cmp_deeply(
    $wizard->thaw,
    {
        one     => 'completed',
    },
    'dispatch did not freeze error data'
);

package WebGUI::Wizard::Test;
use base 'WebGUI::Wizard';
sub _get_steps { return [qw( one two three four five )] }

sub www_one {
    my ( $self ) = @_;
    return "begin";
}

sub www_oneSave {
    my ( $self ) = @_;
    $self->set({ "one" => "completed" });
    return;
}

sub www_two {
    my ( $self ) = @_;
    return $self->get("one");
}

sub www_twoSave {
    my ( $self ) = @_;
    $self->set({ "two" => "error" });
    return "error";
}


#vim:ft=perl
