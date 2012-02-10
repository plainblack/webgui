use strict;
use warnings;

use WebGUI::Test;
use Test::More 'no_plan';

use WebGUI::Asset;
use WebGUI::Asset::Template::TemplateToolkit;

my $parser = WebGUI::Asset::Template::TemplateToolkit->new(WebGUI::Test->session);

my $vars = {
    _asset => WebGUI::Test->asset(
        title => 'proxied asset'
    ),
};

my $template = <<'END_TEMPLATE';
[% USE Asset -%]
[%+ Asset.title +%]
[%+ Asset.title('new title') +%]
[%+ Asset.title +%]
END_TEMPLATE

my $out = $parser->process($template, $vars);

my @lines = split /\n/, $out;

is $lines[0], 'proxied asset', 'title retrieved';
is $lines[2], 'proxied asset', 'title not able to be changed';

