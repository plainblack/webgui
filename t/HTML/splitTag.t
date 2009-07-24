#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use FindBin;
use strict;
use lib "$FindBin::Bin/../lib";

use WebGUI::Test;
use WebGUI::HTML;
use WebGUI::Session;

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

# the style param below refers to how the callis made.  the function has two optional params
# by testing with each style we can test the default for thsee params.
# also array/scalar return type are tested.

# call type = 1: all three params; return array
# call type = 2: only tag and text; return scalar
# call type = 3: only text and count; return array
# call type = 4: only the text; return scalar

my @testArray = (
    {
        inputText => q!<p>First Paragraph</p> <p>Second Paragraph</p>!,
        output => q!First Paragraph!,
        style => 1,
        tag => 'p',
        count => 1,
        comment => 'get one paragraph, no defaults',
    },
    {
        inputText => q!<p>First Paragraph</p> <p>Second Paragraph</p>!,
        output => q!First Paragraph!,
        style => 4,
        tag => 'p',
        count => 1,
        comment => 'get one paragraph, all defaults',
    },
    {
        inputText => q!<p>First Paragraph</p> <p>Second Paragraph</p>!,
        output => q!First Paragraph;Second Paragraph!,
        style => 1,
        tag => 'p',
        count => -1,
        comment => 'get all paragraphs, no defaults',
    },
    {
        inputText => q!<p>First Paragraph</p> <p>Second Paragraph</p>!,
        output => q!First Paragraph;Second Paragraph!,
        style => 3,
        tag => 'p',
        count => -1,
        comment => 'get all paragraphs, default tag',
    },
    {
        inputText => q!<p> </p><p>First nonblank Paragraph</p> <p>Second Paragraph</p>!,
        output => q!First nonblank Paragraph!,
        style => 4,
        tag => 'p',
        count => -1,
        comment => 'get nonblank paragraph, all defaults',
    },
    {
        inputText => q!<p> &nbsp;</p><p>First nonblank Paragraph</p> <p>Second Paragraph</p>!,
        output => q!First nonblank Paragraph!,
        style => 4,
        tag => 'p',
        count => -1,
        comment => 'first nonblank(nbsp) paragraph, all defaults',
    },
    {
        inputText => q!<li>First List Item</li> <li>Second List Item</li> <li>Third List Item</li>!,
        output => q!First List Item;Second List Item;Third List Item!,
        style => 1,
        tag => 'li',
        count => -1,
        comment => 'get all list items, no defaults',
    },
    {
        inputText => q!<li>First List Item</li> <li>Second List Item</li> <li>Third List Item</li>!,
        output => q!First List Item;Second List Item!,
        style => 1,
        tag => 'li',
        count => 2,
        comment => 'get first 2 list items, no defaults',
    },
    {
        inputText => q!<tr><td>First Item</td> <td>Second Item</td></tr>!,
        output => q!First Item Second Item!,
        style => 1,
        tag => 'tr',
        count => -1,
        comment => 'get table row ignore table data',
    },
    {
        inputText => q!<tr><td>First Item</td> <td>Second Item</td></tr>!,
        output => q!First Item;Second Item!,
        style => 1,
        tag => 'td',
        count => -1,
        comment => 'get table data ignore table row',
    },
    {
        inputText => q!<p>less than &lt; greater than &gt;</p>!,
        output => q!less than < greater than >!,
        style => 1,
        tag => 'p',
        count => -1,
        comment => 'Entities get decoded',
    },
    {
        inputText => q!<p>Brandheiße Neuigkeiten rund um's Klettern für euch aus der Region </p>!,
        output => q!Brandheiße Neuigkeiten rund um's Klettern für euch aus der Region!,
        style => 1,
        tag => 'p',
        count => -1,
        comment => 'Get a paragraph tag with long characters',
    },
);

my $numTests = scalar @testArray;

plan tests => $numTests;

my $output;
foreach my $testSet (@testArray) {
    if( $testSet->{style} == 1 ) {
    $output = join ';',WebGUI::HTML::splitTag($testSet->{tag},$testSet->{inputText}, $testSet->{count});
    } elsif( $testSet->{style} == 2 ) {
    $output = WebGUI::HTML::splitTag($testSet->{tag},$testSet->{inputText});
    } elsif( $testSet->{style} == 3 ) {
    $output = join ';', WebGUI::HTML::splitTag($testSet->{inputText}, $testSet->{count});
    } elsif( $testSet->{style} == 4 ) {
    $output = WebGUI::HTML::splitTag($testSet->{inputText});
    }
    is($output, $testSet->{output}, $testSet->{comment});
}

