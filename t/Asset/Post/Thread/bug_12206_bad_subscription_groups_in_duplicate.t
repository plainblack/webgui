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

=head1 BUG DESCRIPTION

When Thread assets are copied, a new subscription group gets created for them,
but not by calling $thread->createSubscriptionGroup. Instead, a "blank" group
is created, and then the users from the old group are added to it -- which by
default has Admins subscribed in it. So, every time we copy a thread, our
admins start getting spammed with subscription updates.

=cut

use warnings;
use strict;

use Test::More tests => 2;
use Test::Exception;
use FindBin;

use lib "$FindBin::Bin/../../../lib";
use WebGUI::Test;
use WebGUI::Asset;

my $session = WebGUI::Test->session;
my $cs      = WebGUI::Asset->getImportNode($session)->addChild(
    {
        className => 'WebGUI::Asset::Wobject::Collaboration',
    }
);
my $thread  = $cs->addChild(
    {
        className => 'WebGUI::Asset::Post::Thread',
    }
);
WebGUI::Test->addToCleanup($cs);
$thread->createSubscriptionGroup();
my $admin = WebGUI::User->new($session, 3);
ok !$admin->isInGroup($thread->get('subscriptionGroupId'));

$thread = $thread->duplicate();
WebGUI::Test->addToCleanup($thread);
ok !$admin->isInGroup($thread->get('subscriptionGroupId'));
