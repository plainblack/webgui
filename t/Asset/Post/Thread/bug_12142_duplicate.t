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

Thread's duplicate method fails if the subscriptionGroupId isn't a valid group
(for instance, if it was imported from another site). It should just not copy
the group in that case.

=cut

use warnings;
use strict;

use Test::More tests => 4;
use Test::Exception;
use FindBin;

use lib "$FindBin::Bin/../lib";
use WebGUI::Test;
use WebGUI::Asset;

my $session = WebGUI::Test->session;
my $thread  = WebGUI::Asset->getImportNode($session)->addChild(
    {
        className => 'WebGUI::Asset::Post::Thread',
        subscriptionGroupId => $session->id->generate(),
    }
);
WebGUI::Test->addToCleanup($thread);

SKIP: {
    my $copy;
    skip('duplicate died', 3) unless
        lives_ok { $copy = $thread->duplicate() } q"duplicate() doesn't die";
    WebGUI::Test->addToCleanup($copy);
    my $groupId = $copy->get('subscriptionGroupId');
    ok $groupId, 'Copy has a group id';
    isnt $groupId, $thread->get('subscriptionGroupId'), '...a different one';
    ok(WebGUI::Group->new($session, $groupId), '...and it instantiates');
};
