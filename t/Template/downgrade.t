use FindBin;
use strict;
use warnings;
use lib "$FindBin::Bin/../../lib";
use lib "$FindBin::Bin/../lib";

use Data::Dumper;
use Test::More;
use WebGUI::Test;

use WebGUI::Asset;
use WebGUI::Asset::Template::Parser;

my $funky_instance = bless {}, 'WebGUI::Asset::Template::Parser';

sub down_ok {
    my ( $down, $expected, $msg ) = @_;
    $funky_instance->downgrade($down);
    is_deeply( $down, $expected, $msg )
        or diag Dumper($down);
}

down_ok { foo => 'bar' }, { foo => 'bar' }, 'nonthreatening';
down_ok {
    code => sub { }
    },
    {},
    'code';
down_ok { obj => $funky_instance }, {}, 'object';

down_ok { hash => { foo => 'foo', bar => 'bar' } },
    { 'hash.foo' => 'foo', 'hash.bar' => 'bar' },
    'simple hash flattening';

down_ok { array => [ 1, 2, 3 ] },
    { array => [ { value => 1 }, { value => 2 }, { value => 3 }, ] }, 'simple array flattening';

down_ok {
    regular => 'simple',
    hash    => {
        quite => 'deeply',
        with  => {
            another  => 'hashref',
            and_even => [
                'an', sub { }, { obj => $funky_instance },
                'array',
                [ 'nested', 'further', { son => '!!!' } ],
                [ { oh => { wow => 'man' } } ]
            ],
            blessme => $funky_instance,
        }
    }
    }, {
    regular              => 'simple',
    'hash.quite'         => 'deeply',
    'hash.with.another'  => 'hashref',
    'hash.with.and_even' => [
        { value => 'an' },
        {}, {},
        { value => 'array' },
        { value => [ { value => 'nested' }, { value => 'further' }, { son => '!!!' }, ], },
        { value => [ { 'oh.wow' => 'man' } ] }
    ],
    },
    'twisted deep complex strucuture';

my $session = WebGUI::Test->session;

sub processed_ok {
    my ( $parser, $template, $msg ) = @_;
    my $temp = WebGUI::Asset->getTempspace($session);
    my $tmpl = $temp->addChild( {
            className => 'WebGUI::Asset::Template',
            parser    => $parser,
            template  => $template,
        }
    );
    WebGUI::Test->addToCleanup($tmpl);
    is( $tmpl->process( {
                his => { yes => 'yes', stop => 'stop' },
                my  => { yes => 'no',  stop => 'go' }
            }
        ),
        <<'END_EXPECTED', $msg );
You say yes, I say no.
You say stop, and I say go.
END_EXPECTED
} ## end sub processed_ok

processed_ok( 'WebGUI::Asset::Template::HTMLTemplate', <<'END_HT', 'HTML::Template' );
You say <tmpl_var his.yes>, I say <tmpl_var my.yes>.
You say <tmpl_var his.stop>, and I say <tmpl_var my.stop>.
END_HT

my $gotExpr = use_ok('WebGUI::Asset::Template::HTMLTemplateExpr');
SKIP: {
    skip 'No HTML::Template::Expr module', 1 unless $gotExpr;
    WebGUI::Test->originalConfig('templateParsers');
    $session->config->addToArray('templateParsers', 'WebGUI::Asset::Template::HTMLTemplateExpr');
processed_ok( 'WebGUI::Asset::Template::HTMLTemplateExpr', <<'END_HTE', 'HTML::Template::Expr' );
You say <tmpl_var his_yes>, I say <tmpl_var my_yes>.
You say <tmpl_var his_stop>, and I say <tmpl_var my_stop>.
END_HTE
}

done_testing;

#vim:ft=perl
