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

use WebGUI::Macro;
use WebGUI::Asset;
use WebGUI::Macro;
use WebGUI::HTML;
use Tie::IxHash;

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;
my $defaultAsset = WebGUI::Asset->getDefault($session);

$session->asset($defaultAsset);

##Create a non-admin user who will be in the Registered User group
my $registeredUser = WebGUI::User->new($session, "new");
$registeredUser->username('TimBob');
WebGUI::Test->addToCleanup($registeredUser);
$session->user({user => $registeredUser});

##Overwrite any local configuration so that we know how to call it.
foreach my $macro (qw/
    GroupText LoginToggle PageTitle MacroStart MacroEnd MacroNest
    ReverseParams InfiniteMacro VisualMacro MacroEmpty MacroUndef
/) {
	$session->config->addToHash('macros', $macro, $macro);
}
$session->config->addToHash('macros', "Ex'tras", "Extras");

my $macroText = "CompanyName: ^c;";
my $companyName = $session->setting->get('companyName');
WebGUI::HTML::makeParameterSafe( \$companyName );

WebGUI::Macro::process($session, \$macroText),
is(
	$macroText,
	"CompanyName: $companyName",
	"c_companyName Macro in text processed okay"
);

my $macroText = "PageTitle: ^PageTitle;";
WebGUI::Macro::process($session, \$macroText),
is(
	$macroText,
	"PageTitle: ".$session->asset->getTitle,
	"PageTitle Macro in text processed okay"
);

my $macroText = q|GroupText(Registered Users, example) : ^GroupText("Registered Users","example");|;
WebGUI::Macro::process($session, \$macroText),
is(
	$macroText,
	"GroupText(Registered Users, example) : example",
	"GroupText Macro in text processed okay for registered user"
);

my $macroText = q|GroupText(Registered Users, example: c/CompanyName Macro) : ^GroupText("Registered Users","example: ^c;");|;
WebGUI::Macro::process($session, \$macroText),
is(
	$macroText,
	"GroupText(Registered Users, example: c/CompanyName Macro) : example: $companyName",
	"GroupText Macro with nested c_companyName macro"
);

my $macroText = q|GroupText(Registered Users, example: PageTitle): ^GroupText("Registered Users","example: ^PageTitle;");|;
WebGUI::Macro::process($session, \$macroText),
is(
	$macroText,
	"GroupText(Registered Users, example: PageTitle): example: ".$session->asset->getTitle,
	"GroupText Macro with nested PageTitle macro"
);

my $macroText = q{Extras("test"): ^Extras("test");};
WebGUI::Macro::process($session, \$macroText);
is( 
    $macroText,
    q{Extras("test"): /extras/test},
    "Extras macro with quoted argument."
);

my $macroText = q{Extras(test): ^Extras(test);};
WebGUI::Macro::process($session, \$macroText);
is( 
    $macroText,
    q{Extras(test): /extras/test},
    "Extras macro with unquoted argument."
);

my $macroText = q{Extras: ^Extras;};
WebGUI::Macro::process($session, \$macroText);
is( 
    $macroText,
    q{Extras: /extras/},
    "Extras macro with no parens and no args",
);

my $macroText = q{Extras(): ^Extras();};
WebGUI::Macro::process($session, \$macroText);
is( 
    $macroText,
    q{Extras(): /extras/},
    "Extras macro with parens but no args",
);

my $macroText = q{Extras("(test"): ^Extras("\(test");};
WebGUI::Macro::process($session, \$macroText);
is(
    $macroText,
    q{Extras("(test"): /extras/(test},
    "Extras macro with escaped unbalanced opening parenthesis."
);

my $macroText = q{Extras("(test"): ^Extras("prefix \(test");};
WebGUI::Macro::process($session, \$macroText);
is(
    $macroText,
    q{Extras("(test"): /extras/prefix (test},
    "Extras macro with escaped unbalanced opening parenthesis in the middle."
);

my $macroText = q{Extras("test)"): ^Extras("test\)");};
WebGUI::Macro::process($session, \$macroText);
is(
    $macroText,
    q{Extras("test)"): /extras/test)},
    "Extras macro with escaped unbalanced closing parenthesis."
);

my $macroText = q{Extras("test)"): ^Extras("test\) suffix");};
WebGUI::Macro::process($session, \$macroText);
is(
    $macroText,
    q{Extras("test)"): /extras/test) suffix},
    "Extras macro with escaped unbalanced closing parenthesis in the middle."
);

my $macroText = <<'EOF'
    ''=~(        '(?{'        .('`'        |'%')        .('['        ^'-')
    .('`'        |'!')        .('`'        |',')        .'"'.        '\\$'
    .'=='        .('['        ^'+')        .('`'        |'/')        .('['
    ^'+')        .'||'        .(';'        &'=')        .(';'        &'=')
    .';-'        .'-'.        '\\$'        .'=;'        .('['        ^'(')
    .('['        ^'.')        .('`'        |'"')        .('!'        ^'+')
   .'_\\{'      .'(\\$'      .';=('.      '\\$=|'      ."\|".(      '`'^'.'
  ).(('`')|    '/').').'    .'\\"'.+(    '{'^'[').    ('`'|'"')    .('`'|'/'
 ).('['^'/')  .('['^'/').  ('`'|',').(  '`'|('%')).  '\\".\\"'.(  '['^('(')).
 '\\"'.('['^  '#').'!!--'  .'\\$=.\\"'  .('{'^'[').  ('`'|'/').(  '`'|"\&").(
 '{'^"\[").(  '`'|"\"").(  '`'|"\%").(  '`'|"\%").(  '['^(')')).  '\\").\\"'.
 ('{'^'[').(  '`'|"\/").(  '`'|"\.").(  '{'^"\[").(  '['^"\/").(  '`'|"\(").(
 '`'|"\%").(  '{'^"\[").(  '['^"\,").(  '`'|"\!").(  '`'|"\,").(  '`'|(',')).
 '\\"\\}'.+(  '['^"\+").(  '['^"\)").(  '`'|"\)").(  '`'|"\.").(  '['^('/')).
 '+_,\\",'.(  '{'^('[')).  ('\\$;!').(  '!'^"\+").(  '{'^"\/").(  '`'|"\!").(
 '`'|"\+").(  '`'|"\%").(  '{'^"\[").(  '`'|"\/").(  '`'|"\.").(  '`'|"\%").(
 '{'^"\[").(  '`'|"\$").(  '`'|"\/").(  '['^"\,").(  '`'|('.')).  ','.(('{')^
 '[').("\["^  '+').("\`"|  '!').("\["^  '(').("\["^  '(').("\{"^  '[').("\`"|
 ')').("\["^  '/').("\{"^  '[').("\`"|  '!').("\["^  ')').("\`"|  '/').("\["^
 '.').("\`"|  '.').("\`"|  '$')."\,".(  '!'^('+')).  '\\",_,\\"'  .'!'.("\!"^
 '+').("\!"^  '+').'\\"'.  ('['^',').(  '`'|"\(").(  '`'|"\)").(  '`'|"\,").(
 '`'|('%')).  '++\\$="})'  );$:=('.')^  '~';$~='@'|  '(';$^=')'^  '[';$/='`'; 
EOF
;

my $macroTextOut = $macroText;
WebGUI::Macro::process($session, \$macroTextOut);
is ($macroTextOut, $macroText, "Impossibly ugly, invalid macro fails to process and fails to kill WebGUI");



my $macroText = q|^GroupText("Registered Users","Commas ',' work?");|;
WebGUI::Macro::process($session, \$macroText),
is(
	$macroText,
	"Commas ',' work?",
	"GroupText Macro with quoted comma"
);

my $macroText = qq|^ReverseParams(1,"here's a quote: \\"",2);|;
WebGUI::Macro::process($session, \$macroText),
is(
	$macroText,
	"2here's a quote: \"1",
	"Escaped double quotes work properly"
);

my $macroText = q|^MacroNest();|;
WebGUI::Macro::process($session, \$macroText),
is(
	$macroText,
	"/extras/",
	"Nested macro evaluates results to extras",
);

my $macroText = q|^MacroStart;^MacroEnd;|;
WebGUI::Macro::process($session, \$macroText),
is(
	$macroText,
	"^MacroNest();",
	"Combined macro calls don't get evaluated",
);

my $macroText = q|^InfiniteMacro;|;
WebGUI::Macro::process($session, \$macroText),
is(
	$macroText,
	"Too many levels of macro recursion. Stopping.",
	"Infinite recursion gets broken",
);

my $macroText = qq|^ReverseParams(1,"carriage returns\npass through as needed",2);|;
WebGUI::Macro::process($session, \$macroText),
is(
	$macroText,
	"2carriage returns\npass through as needed1",
	"Carriage returns pass through as needed."
);

my $macroText = qq|^ReverseParams(1,'Single quoted parameters work properly',2);|;
WebGUI::Macro::process($session, \$macroText),
is(
	$macroText,
	"2Single quoted parameters work properly1",
	"Single quoted parameters work properly."
);

my $macroText = qq|^ReverseParams(1,'Escaped single\\' quotes work',2);|;
WebGUI::Macro::process($session, \$macroText),
is(
	$macroText,
	"2Escaped single' quotes work1",
	"Escaped single quotes work."
);


tie my %quotingEdges, 'Tie::IxHash';
%quotingEdges = (
    '^VisualMacro(text);'                           => '@MacroCall[`text`]:',
    '^VisualMacro(^VisualMacro("something);");'     => '@MacroCall[`@MacroCall[`"something`]:"`]:',
    '^VisualMacro("^VisualMacro("something););'     => '@MacroCall[`"@MacroCall[`"something`]:`]:',
    '^VisualMacro("^VisualMacro(something"););'     => '@MacroCall[`"@MacroCall[`something"`]:`]:',
    '^VisualMacro^VisualMacro(this);;'              => '^VisualMacro@MacroCall[`this`]:;',
    '^VisualMacro(^VisualMacro);'                   => '@MacroCall[`^VisualMacro`]:',
    '^VisualMacro(^VisualMacro(this));'             => '@MacroCall[`^VisualMacro(this)`]:',
    '^VisualMacro("quotes\\");'                     => '@MacroCall[`"quotes"`]:',
    '^VisualMacro("^VisualMacro(\"something\",\"something else\");","more still");'
        => '@MacroCall[`@MacroCall[`something`.`something else`]:`.`more still`]:',
    '^VisualMacro("^VisualMacro(\"something\", \"something else\");", "more still");'
        => '@MacroCall[`@MacroCall[`something`.`something else`]:`.`more still`]:',
    q{^VisualMacro("^VisualMacro('something','something else');","more still");}
        => '@MacroCall[`@MacroCall[`something`.`something else`]:`.`more still`]:',
    q{^VisualMacro("^VisualMacro('something', 'something else');", "more still");}
        => '@MacroCall[`@MacroCall[`something`.`something else`]:`.`more still`]:',
    '^VisualMacro(,,);'                             => '@MacroCall[``.``]:',
    '^VisualMacro("","",);'                         => '@MacroCall[``.``]:',
    '^VisualMacro(,,"");'                           => '@MacroCall[``.``.``]:',
    '^ReverseParams(^VisualMacro("something","else"););'
        => '"else");^VisualMacro("something"',
    '^ReverseParams(^VisualMacro(something,else););'
        => 'else);^VisualMacro(something',
    '^ReverseParams("^VisualMacro(first word,second word);");'
        => '@MacroCall[`first word`.`second word`]:',
);
while (my ($inText, $outText) = each %quotingEdges) {
    my $procText = $inText;
    WebGUI::Macro::process($session, \$procText),
    is(
        $procText,
        $outText,
        "Quoting/Nesting edge case: $inText",
    );
}

my @invalidCalls = (
    '^;',
    '^();',
    '^MacroThatDoesntExist;',
    "^Ex'tras;",
    '^Extras(;',
    '^Extras);',
    '^Extras(;)',
);
for my $inText (@invalidCalls) {
    my $outText = $inText;
    WebGUI::Macro::process($session, \$outText),
    is(
        $outText,
        $inText,
        "Invalid macro call: $inText",
    );
}

my $macroText = "^MacroEmpty;";
WebGUI::Macro::process($session, \$macroText);
is(
    $macroText,
    '',
    "Macro can return empty string",
);

my $macroText = "^MacroUndef;";
WebGUI::Macro::process($session, \$macroText);
is(
    $macroText,
    '',
    "Macro can return undef",
);

my $macroText = '^VisualMacro(1,2,3,);';
WebGUI::Macro::process($session, \$macroText);
is (
    $macroText,
    '@MacroCall[`1`.`2`.`3`]:',
    'dangling commas are okay'
);

my $macroText = '^VisualMacro(1, 2,3);';
WebGUI::Macro::process($session, \$macroText);
is (
    $macroText,
    '@MacroCall[`1`.` 2`.`3`]:',
    'internal spaces are okay'
);

my $macroText = 'before ^VisualMacro("1", 2,); after';
my $macroData;
WebGUI::Macro::transform($session, \$macroText, sub {
    $macroData = shift;
    return "replace";
});

is (
    $macroText,
    'before replace after',
    'transform replaces macro calls'
);

is_deeply($macroData, {
    session => $session,
    macro => 'VisualMacro',
    macroPackage => 'WebGUI::Macro::VisualMacro',
    originalString => '^VisualMacro("1", 2,);',
    parameters => [
        '1',
        ' 2',
    ],
    parameterString => '("1", 2,)',
}, 'transform passes sub correct data');

done_testing;

