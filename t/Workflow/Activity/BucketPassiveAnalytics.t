
use FindBin;
use strict;
use lib "$FindBin::Bin/../../lib";
#use DB;

use WebGUI::Test;
use WebGUI::Asset;
use WebGUI::PassiveAnalytics::Rule;
use WebGUI::Workflow::Activity::BucketPassiveAnalytics;
use WebGUI::Text;

use Test::More;

plan tests => 1; # increment this value for each test you create

my $session = WebGUI::Test->session;
$session->user({userId => 3});

WebGUI::Test->addToCleanup(SQL => 'delete from passiveLog');
WebGUI::Test->addToCleanup(SQL => 'delete from analyticRule');

my $workflow = WebGUI::Workflow->new($session, 'PassiveAnalytics000001');
my $activities = $workflow->getActivities();
##Note, they're in order, and the order is known.
$activities->[0]->set('deltaInterval', 100);
$activities->[1]->set('userId',          0); ##To disable sending emails
    
my $instance = WebGUI::Workflow::Instance->create($session,
    {
        workflowId              => $workflow->getId,
        skipSpectreNotification => 1,
        priority                => 1,
    }
);
WebGUI::Test->addToCleanup($instance);
##Rule label, url, and regexp
my @ruleSets = (
    ['home',       '/home',               '^\/home'             ],
    ['one',        '/one',                '^\/one$'             ],
    ['two',        '/two',                '^\/two$'             ],
    ['three',      '/three',              '^\/three$'           ],
    ['end',        '/blah/blah/end',      'end$'                ],
    ['casa',       '/home/casa',          'casa$'               ],
    ['uno',        '/one/uno',            'uno$'                ],
    ['dos',        '/two/dos',            'dos$'                ],
    ['tres',       '/three/tres',         'tres$'               ],
    ['alpha',      '/alpha/aee',          '.alpha.aee'          ],
    ['beta',       '/beta/bee',           '.beta.bee'           ],
    ['gamma',      '/gamma/cee',          '.gamma.cee'          ],
    ['delta',      '/delta/dee',          '.delta.dee'          ],
    ['eee',        '/epsilon/eee',        'eee$'                ],
    ['thingy1',    '/thingy?thingId=1',   '^.thingy\?thingId=1' ],
    ['rogerRoger', '/roger/roger',        '(?:\/roger){2}'      ],
    ['roger',      '/roger',              '^\/roger'            ],
    ['thingy2',    '/thingy?thingId=2',   '^.thingy\?thingId=2' ],
    ['beet',       '/beta/beet',          '.beta.beet'          ],
    ['zero',       '/yelnats',            'yelnats'             ],
);

my @url2 = @ruleSets;
while (my $spec = shift @url2) {
    my ($bucket, undef, $regexp) = @{ $spec };
    WebGUI::PassiveAnalytics::Rule->create($session, { bucketName => $bucket, regexp => $regexp });
}

my @urls = map {$_->[1]} @ruleSets;
loadLogData($session, @urls);

##Build rulesets

##Now, run it and wait for it to finish
my $counter = 0;
#DB::enable_profile();
PAUSE: while (my $retval = $instance->run()) {
    last PAUSE if $retval eq 'done';
    last PAUSE if $counter++ >= 16;
}
#DB::disable_profile();

ok(1, 'One test');

sub loadLogData {
    my ($session, @urls) = @_;
    $session->db->write('delete from passiveLog');
    my $insert = $session->db->prepare(
        q!insert into passiveLog (userId, sessionId, timeStamp, url, assetId) VALUES (?,?,?,?,'assetId')!
    );
    my $logCount = 15000;
    my $counter;
    my $startTime = 1000;
    my $numUrls = scalar @urls;
    while ($counter++ < $logCount) {
        my $index = int rand($numUrls);
        my $url = $urls[$index];
        $insert->execute([2, 25, $startTime, $url]);
        $startTime += int(rand(10))+1;
    }
}

#vim:ft=perl
