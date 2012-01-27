
use strict;
#use DB;

use WebGUI::Test;
use WebGUI::PassiveAnalytics::Rule;

use Test::More;
use Test::Deep;
use Data::Dumper;

plan tests => 2; # increment this value for each test you create

my $session = WebGUI::Test->session;
$session->user({userId => 3});

WebGUI::Test->addToCleanup(SQL => 'delete from passiveLog');
WebGUI::Test->addToCleanup(SQL => 'delete from deltaLog');
WebGUI::Test->addToCleanup(SQL => 'delete from bucketLog');
WebGUI::Test->addToCleanup(SQL => 'delete from analyticRule');
WebGUI::Test->addToCleanup(SQL => 'delete from PA_lastLog');

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
    WebGUI::PassiveAnalytics::Rule->new($session, { bucketName => $bucket, regexp => $regexp });
}

my @urls = map {$_->[1]} @ruleSets;
#loadLogData($session, @urls);
repeatableLogData($session, 'passiveAnalyticsLog');

##Build rulesets

##Now, run it and wait for it to finish
my $counter = 0;
#DB::enable_profile();
PAUSE: while (my $retval = $instance->run()) {
    last PAUSE if $retval eq 'done';
    last PAUSE if $counter++ >= 16;
}
#DB::disable_profile();

cmp_ok $counter, '<', 16, 'Successful completion of PA';

my $get_line = $session->db->read('select userId, Bucket, duration from bucketLog');

my @database_dump = ();
ROW: while ( 1 ) {
    my @datum = $get_line->array();
    last ROW unless @datum;
    push @database_dump, [ @datum ];
}

cmp_bag(
    [ @database_dump ],
    [
        ['user1', 'one', 10],
        ['user1', 'two', 15],
        ['user2', 'zero', 2],
        ['user2', 'uno', 3],
        ['user2', 'Other', 5],
    ],
    'PA analysis completed, and calculated correctly'
) or diag Dumper(\@database_dump);

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

sub repeatableLogData {
    my ($session, $dataLogName) = @_;
    $session->db->write('delete from passiveLog');
    my $insert = $session->db->prepare(
        q!insert into passiveLog (userId, sessionId, timeStamp, url, assetId) VALUES (?,?,?,?,'assetId')!
    );
    my $data_name = WebGUI::Test::collateral('passiveAnalyticsLog');
    open my $log_data, '<', $data_name or
        die "Unable to open $data_name for reading: $!";
    local $_;
    while (<$log_data>) {
        next if /^\s*#/;
        s/#\.*$//;
        chomp;
        my @data = split;
        $insert->execute([@data]);
    }
    $insert->finish;
}

#vim:ft=perl
