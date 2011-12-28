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

use strict;
use Test::More;
use Test::Deep;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;

use WebGUI::Shop::TaxDriver::EU;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests

plan tests => 9;        # Increment this number for each test you create


#----------------------------------------------------------------------------
{
    my @args;
    my $called = 0;
    my $return = '';
    local *WebGUI::Shop::TaxDriver::EU::recheckVATNumber = sub {
        my $self = shift;
        @args    = @_;
        $called++;
        return $return;
    };

    my $number = 'NL34567890';
    my $user   = WebGUI::User->new( $session, 'new' );
    my $userId = $user->userId;
    WebGUI::Test->addToCleanup( $user );
    
    # --- valid number ----------------
    $return = 'VALID';
    my $instance = createInstance( $session, $number, $userId );

    my $response = $instance->run;
    is( $response, 'complete',  'Activity completes when recheckVATNumber found a valid VAT number' );
    $response    = $instance->run;
    is( $response, 'done',      'Workflow finishes on a valid number' );

    cmp_ok( scalar( @args ), '==', 2,       'recheckVATNumber is passed 2 params'          );
    cmp_ok( $args[0],        'eq', $number, 'first passed param is VATNumber'              );
    cmp_ok( $args[1]->getId, 'eq', $userId, 'second passed param is correct user obect'    );

    cmp_ok( $called,         '==', 1, 'recheckVATNumber is only called once per iteration'      );

    # --- Invalid number --------------
    $return = 'INVALID';
    my $instance = createInstance( $session, $number, $userId );

    my $response = $instance->run;
    is( $response, 'complete',  'Activity completes when recheckVATNumber found an invalid VAT number' );
    $response    = $instance->run;
    is( $response, 'done',      'Workflow finishes on an invalid number' );

    # --- Connection problem ----------
    $return = 'UNKNOWN';
    my $instance = createInstance( $session, $number, $userId );

    my $response = $instance->run;
    is( $response, 'waiting 3600',  'Activity waits for an hour when VIES is unavailable.' );
}


#----------------------------------------------------------------------------
sub createInstance {
    my $session = shift;
    my $number  = shift;
    my $userId  = shift;

    my $workflow  = WebGUI::Workflow->create($session, {
        enabled    => 1,
        objectType => 'None',
        mode       => 'realtime',
    } );
    my $activity = $workflow->addActivity( 'WebGUI::Workflow::Activity::RecheckVATNumber' );

    WebGUI::Test->addToCleanup( $workflow );

    my $instance = WebGUI::Workflow::Instance->create( $session, {
        workflowId                  => $workflow->getId,
        skipSpectreNotification     => 1,
        parameters                  => { 
            vatNumber   => $number,
            userId      => $userId,
        } 
    } );
    
    return $instance;
};

#vim:ft=perl
