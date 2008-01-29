#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------


our ($webguiRoot);

BEGIN {
        $webguiRoot = "..";
        unshift (@INC, $webguiRoot."/lib");
}

use Getopt::Long;
use strict;
use WebGUI::Session;

my $help;
my $start = 1;
my $stop = 0;
my $configFile;

GetOptions(
        'help'=>\$help,
        'start'=>\$start,
        'stop'=>\$stop,
    'configFile=s'=>\$configFile
  );

if ($help || $configFile eq ""){
        print <<STOP;


Usage: perl $0 

Options:

        --help          Display this help message and exit.

    --configFile    The config file for the site.

    --start         Turn on maintenance mode (default).

    --stop          Turn off maintenance mode.


STOP
        exit;
}

my $session = WebGUI::Session->open($webguiRoot,$configFile);
$session->setting->remove('specialState');
$session->setting->add('specialState','upgrading') unless $stop;
$session->var->end;
$session->close;

