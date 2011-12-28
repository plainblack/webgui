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

use FindBin;
use strict;
use lib "$FindBin::Bin/../lib";
use Test::More;
use Test::Deep;
use Test::Exception;
use Data::Dumper;
use JSON;
use HTML::Form;

use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Shop::Credit;
use WebGUI::User;

#----------------------------------------------------------------------------
# Init
my $session = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests

plan tests => 27;

#######################################################################
#
# new
#
#######################################################################

my $credit;
my $credit_user = WebGUI::User->create($session);
WebGUI::Test->addToCleanup($credit_user);

# Test incorrect for parameters

my $e;

eval { $credit = WebGUI::Shop::Credit->new(); };
$e = Exception::Class->caught();
isa_ok      ($e, 'WebGUI::Error::InvalidParam', 'new takes exception to not giving it a session object');
cmp_deeply  (
    $e,
    methods(
        error => 'Need a session.',
    ),
    'new takes exception to not giving it a session object',
);

lives_ok { $credit = WebGUI::Shop::Credit->new($session, $credit_user->userId); } 'new works with an explicit userId';
can_ok($credit, qw/adjust purge getSum getLedger calculateDeduction session userId/);

#######################################################################
#
# session
#
#######################################################################

isa_ok ($credit->session,  'WebGUI::Session',          'session method returns a session object');
is ($session->getId,   $credit->session->getId,    'session method returns OUR session object');

#######################################################################
#
# userId
#
#######################################################################
is ($credit->userId, $credit_user->userId, 'userId accessor returns the userId we set');

$session->user({userId => 3});
lives_ok { $credit = WebGUI::Shop::Credit->new($session); } 'new works without an explicit userId';
is $credit->userId, 3, '... by default, it uses the session user';

$session->user({userId => 1});
lives_ok { $credit = WebGUI::Shop::Credit->new($session); } 'new works for visitor, too';

##Restore the original user for more testing
$credit = WebGUI::Shop::Credit->new($session, $credit_user->userId);

#######################################################################
#
# adjust, getSum, calculateDeduction
#
#######################################################################

my $credit1 = WebGUI::Shop::Credit->new($session, 1);
my $credit3 = WebGUI::Shop::Credit->new($session, 3);
WebGUI::Test->addToCleanup(sub { $credit3->purge });
WebGUI::Test->addToCleanup(sub { $credit->purge });

is $credit1->adjust(300, 'bonus for visitors'), 0, 'visitor cannot have credit';
is $credit1->getSum, "0.00", 'getSum: Formatting and amount for Visitor'; 
is $credit3->getSum, "0.00", '... for Admin'; 
is $credit->getSum,  "0.00", '... for credit user'; 

is $credit3->adjust(200, 'Admin never gets enough credit'), 200, 'Give Admin 200 credit';
is $credit3->getSum, "200.00", '... getSum for Admin'; 
is $credit->getSum,  "0.00", '... for credit user'; 

is $credit->adjust(50, 'Refund'), 50, 'Give credit user 50 credit';
is $credit3->getSum, "200.00", '... getSum for Admin, uniqueness check'; 
is $credit->getSum,  "50.00", '... for credit user'; 

is $credit->adjust(-10, 'Typo in original refund'), -10, 'Negative adustment';
is $credit3->getSum, "200.00", '... getSum for Admin, uniqueness check'; 
is $credit->getSum,  "40.00", '... for credit user'; 

#######################################################################
#
# calculateDeduction
#
#######################################################################

is $credit->calculateDeduction(10), "-10.00", 'calculateDeduction returns the max of either the amount';
is $credit->calculateDeduction(80), "-40.00", '... or the available credit';

#######################################################################
#
# purge
#
#######################################################################

$credit->purge;
is $credit->getSum,  "0.00", 'user credit purged'; 
is $credit3->getSum, "200.00", '... but only for credit user'; 
