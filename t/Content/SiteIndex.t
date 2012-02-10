#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::Test;
use WebGUI::Session;
use WebGUI::Content::SiteIndex;

# load your modules here

use Test::More tests => 5; # increment this value for each test you create
use Test::Deep;
use XML::Simple;

my $session = WebGUI::Test->session;

# put your tests here

my $output = WebGUI::Content::SiteIndex::handler($session);
is $output, undef, 'no content returned unless sitemap.xml is requested';

$session->request->env->{PATH_INFO} = '/sitemap.xml';
delete $session->url->{_requestedUrl};
$output = WebGUI::Content::SiteIndex::handler($session);
my $xmlData = XMLin($output,
    KeepRoot   => 1,
    ForceArray => ['url'],
);
my @actual_urls = map { $_->{loc} } @{ $xmlData->{urlset}->{url} };
my @expected_urls = map { $session->url->getSiteURL . '/' . $_ } qw{ home getting_started your_next_step documentation join_us site_map };
cmp_deeply(
    \@actual_urls,
    \@expected_urls,
    'correct set of urls'
);

my $hiddenPage = WebGUI::Asset->getDefault($session)->addChild({
    className => 'WebGUI::Asset::Wobject::Layout',
    isHidden  => 1,
    title     => 'seekrit hidden page',
    url       => 'hidden_page',
});
WebGUI::Test->addToCleanup($hiddenPage);

$output = WebGUI::Content::SiteIndex::handler($session);
$xmlData = XMLin($output,
    KeepRoot   => 1,
    ForceArray => ['url'],
);
cmp_deeply(
    \@actual_urls,
    \@expected_urls,
    'hidden pages hidden'
);

$session->config->set('siteIndex', { showHiddenPages => 1} );

is $session->config->get('siteIndex')->{showHiddenPages}, 1, 'showHiddenPages set to true';

$output = WebGUI::Content::SiteIndex::handler($session);
$xmlData = XMLin($output,
    KeepRoot   => 1,
    ForceArray => ['url'],
);
@actual_urls = map { $_->{loc} } @{ $xmlData->{urlset}->{url} };
@expected_urls = map { $session->url->getSiteURL . '/' . $_ } qw{ home getting_started your_next_step documentation join_us site_map hidden_page };
cmp_deeply(
    \@actual_urls,
    \@expected_urls,
    'hidden pages shown'
);
