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
use WebGUI::Session;
use WebGUI::Operation::Help;

use File::Copy;
use File::Spec;

#The goal of this test is to verify Help inheritance, via the isa key field.
#isa should bring in related items, form entries and template variables,
#recursively.

use Test::More;
use Test::Deep;

my $session = WebGUI::Test->session;

plan tests => 4;

installCollateral();
WebGUI::Test->addToCleanup(sub {
	unlink File::Spec->catfile(WebGUI::Test->lib, qw/WebGUI Help HelpTest.pm/);
});

my $allHelp = WebGUI::Operation::Help::_load($session, 'HelpTest');

cmp_deeply(
    $allHelp->{'base one'},
    {
        title => 'base one title',
        body  => 'base one body',
        variables => [
            { name => 'base one var1', },
            { name => 'base one var2', },
            { name => 'base one var3', },
        ],
        related     => [],
        fields      => [],
        isa         => [],
        __PROCESSED => 1,
    },
    'fetching help with no isa relationships'
);

cmp_deeply(
    $allHelp->{'isa one'},
    {
        title => 'isa one title',
        body  => 'isa one body',
        variables => [
            { name => 'isa one var1', },
            { name => 'isa one var2', },
            { name => 'isa one var3', },
            { name => 'base one var1',
              description => undef,
              namespace   => 'HelpTest'
            },
            { name => 'base one var2',
              description => undef,
              namespace   => 'HelpTest'
            },
            { name => 'base one var3',
              description => undef,
              namespace   => 'HelpTest'
            },
        ],
        related     => [],
        fields      => [],
        isa => [
            {   namespace => "HelpTest",
                tag       => "base one"
            },
        ],
        __PROCESSED => 1,
    },
    'isa imports variables.  Imported variables have explicit description and namespaces'
);

cmp_deeply(
    $allHelp->{'isa loop one'},
    {
        title => 'isa loop one title',
        body  => 'isa loop one body',
        variables => [
            { name => 'isa loop one var1', },
            { name => 'loop one var1',
              description => undef,
              namespace   => 'HelpTest',
              variables => [
                { name => 'loop one loop1',
                  description => undef,
                  namespace   => 'HelpTest',
                },
                { name => 'loop one loop2',
                  description => undef,
                  namespace   => 'HelpTest',
                },
              ],
            },
            { name => 'loop one var2',
              description => undef,
              namespace   => 'HelpTest',
            },
        ],
        related     => [],
        fields      => [],
        isa => [
            {   namespace => "HelpTest",
                tag       => "loop one"
            },
        ],
        __PROCESSED => 1,
    },
    'isa imports variables with loops'
);

cmp_deeply(
    $allHelp->{'isa deep loop'},
    {
        title => 'isa deep loop title',
        body  => 'isa deep loop body',
        variables => [
            { name => 'isa deep loop var1', },
            { name => 'deep loop var1',
              description => undef,
              namespace   => 'HelpTest',
              variables => [
                { name => 'deep loop loop2',
                  description => undef,
                  namespace   => 'HelpTest',
                  variables => [
                    { name => 'deep loop loop3',
                      description => undef,
                      namespace   => 'HelpTest',
                      variables => [
                        { name => 'deep loop loop4',
                          description => undef,
                          namespace   => 'HelpTest',
                        },
                      ],
                    },
                  ],
                },
              ],
            },
        ],
        related     => [],
        fields      => [],
        isa => [
            {   namespace => "HelpTest",
                tag       => "deep loop"
            },
        ],
        __PROCESSED => 1,
    },
    'isa imports variables with nested loops'
);

sub installCollateral {
	copy( 
        File::Spec->catfile( WebGUI::Test->getTestCollateralPath, qw/Help HelpTest.pm/),
		File::Spec->catfile( WebGUI::Test->lib, qw/WebGUI Help/)
	);
}

#vim:ft=perl
