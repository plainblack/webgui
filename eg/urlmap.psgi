use lib '/data/WebGUI/lib';
use WebGUI;

my $wg1 = WebGUI->new;
my $wg2 = WebGUI->new;

use Plack::Builder;
my $app = builder {
    mount "http://dev.localhost.localdomain:5000/" => $wg1;
    mount "/wg1" => $wg1;
    mount "/wg2" => $wg2;
    mount "/" => sub { [ 200, [ 'Content-Type' => 'text/html' ], [ <<END_HTML ] ] };
<p>WebGUI + URLMap</p>
<ul>
<li><a href="http://dev.localhost.localdomain:5000">Virtual Host (wG instance #1)</a></li>
<li><a href=/wg1>Nested (wG instance #1)</a></li>
<li><a href=/wg2>Nested (wG instance #2)</a></li>
</ul>
END_HTML
};
