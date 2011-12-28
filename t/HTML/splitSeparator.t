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
use WebGUI::HTML;
use WebGUI::Session;

use Test::More;
use Test::Deep;
use Data::Dumper;

my $session = WebGUI::Test->session;

my @testArray = (
    {
        inputText => q!section_1!,
        output    => [ qw/section_1/ ],
        comment   => 'bare text, no macro',
    },
    {
        inputText => q!section_1^-;section_2!,
        output    => [ qw/section_1 section_2/ ],
        comment   => 'bare text, 2 sections',
    },
    {
        inputText => q!<p>section_1</p><p>^-;</p><p>section_2</p>!,
        output    => [ qw{<p>section_1</p>   <p>section_2</p>} ],
        comment   => 'paragraph text, 2 sections, macro in separate paragraph',
    },
    {
        inputText => q!<p>section_1</p><p>   ^-;</p><p>section_2</p>!,
        output    => [ qw{<p>section_1</p>   <p>section_2</p>} ],
        comment   => 'paragraph text, 2 sections, macro in separate paragraph with whitespace',
    },
    {
        inputText => q!<p>section_1</p><p>   ^-;</p><p>section_2</p><p>^-;</p><p>section_3</p>!,
        output    => [ qw{<p>section_1</p>   <p>section_2</p> <p>section_3</p>} ],
        comment   => 'paragraph text, 3 sections, macros in separate paragraphs with whitespace',
    },
    {
        inputText => q!<p>section_1^-;section_2</p>!,
        output    => [ qw{<p>section_1</p>   <p>section_2</p>} ],
        comment   => 'paragraph text, 2 sections, macro inside tags',
    },
    {
        inputText => q!<p><b>section_1^-;section_2</b>trailer</p>!,
        output    => [ qw{<p><b>section_1</b></p>   <p><b>section_2</b>trailer</p>} ],
        comment   => 'paragraph text, 2 sections, macro inside 2 nested tags',
    },
    {
        inputText => q!<p>section_1^-;<br />section_2</p>!,
        output    => [ '<p>section_1</p>', '<p><br />section_2</p>' ],
        comment   => 'paragraph text, 2 sections, macro inside tags, with br self-close',
    },
    {
        inputText => q!<p>section_1^-;<br>section_2</p>!,
        output    => [ '<p>section_1</p>', '<p><br>section_2</p>' ],
        comment   => 'paragraph text, 2 sections, macro inside tags, with br unclosed',
    },
    {
        inputText => q!<p>section_1<br>trailer_1^-;section_2</p>!,
        output    => [ '<p>section_1<br>trailer_1</p>', '<p>section_2</p>' ],
        comment   => 'paragraph text, 2 sections, macro inside tags, with br unclosed in first section',
    },
    {
        inputText => q!<p>Very^-;long^-;paragraph</p>!,
        output    => [ '<p>Very</p>', '<p>long</p>', '<p>paragraph</p>' ],
        comment   => 'paragraph text, 3 sections, macros inside tags',
    },
    {
        inputText => q!<p><b>Very^-;long</b>^-;paragraph</p>!,
        output    => [ '<p><b>Very</b></p>', '<p><b>long</b></p>', '<p>paragraph</p>' ],
        comment   => 'paragraph text, 3 sections, macros inside tags, nesting first two tags',
    },
    {
        inputText => q!<p><b>Very^-;long^-;paragraph</b></p>!,
        output    => [ '<p><b>Very</b></p>', '<p><b>long</b></p>', '<p><b>paragraph</b></p>' ],
        comment   => 'paragraph text, 3 sections, macros inside tags, nesting all 3 sections',
    },
    {
        inputText => q!<p><b>Very^-;long^-;</b>paragraph</p>!,
        output    => [ '<p><b>Very</b></p>', '<p><b>long</b></p>', '<p><b></b>paragraph</p>' ],
        comment   => 'paragraph text, 3 sections, macros inside tags, bridge right after macro',
    },
);

my $numTests = scalar @testArray;

plan tests => $numTests;

foreach my $testSet (@testArray) {
    my @output = WebGUI::HTML::splitSeparator($testSet->{inputText});
    my $ok = cmp_deeply(
        \@output,
        $testSet->{output},
        $testSet->{comment}
    );
    if (!$ok) {
        diag explain \@output;
    }
}

