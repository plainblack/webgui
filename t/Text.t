#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::Test;
use WebGUI::Text;
use Test::More;

my @tests =
    (['basic', ['a', 'b', 'c'], 'a,b,c'],
     ['inside null', ['a', '', 'c'], 'a,,c'],
     ['end null', ['a', 'b', ''], 'a,b,'],
     ['start null', ['', 'b', 'c'], ',b,c'],
     ['all null', ['', '', ''], ',,'],
     ['single null', [], ''],
     ['escape commas', ['w,x', 'y,z'], '"w,x","y,z"'],
     ['escape double quotes', ['abc"def', 'ghi-jkl', 'mnop'], '"abc""def",ghi-jkl,mnop'],
     ['cruel embedded newlines', ['foo', 'bar', 'baz', "hello\nworld", 'how are you'], qq{foo,bar,baz,"hello\nworld","how are you"}]);
plan(tests => scalar(@tests) * 2);

foreach my $testspec (@tests) {
	my ($name, $record, $string) = @$testspec;
	is(WebGUI::Text::joinCSV(@$record), $string, "joinCSV $name");
	is_deeply($record, [WebGUI::Text::splitCSV($string)], "splitCSV $name");
}
	
# Local variables:
# mode: cperl
# End:
