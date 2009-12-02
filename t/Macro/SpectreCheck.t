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
use WebGUI::Operation::Spectre;

my $original_spectreCheck = \&WebGUI::Operation::Spectre::spectreTest;
my $spectreStatus;
*WebGUI::Operation::Spectre::spectreTest = sub {
    return $spectreStatus;
};

use WebGUI::Macro::SpectreCheck;

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

plan tests => 4;

my $i18n = WebGUI::International->new($session, 'Macro_SpectreCheck');

is WebGUI::Macro::SpectreCheck::process($session), $i18n->get('spectre'), 'with no status, get an i18n message for a bad spectre';

$spectreStatus = 'success';
is WebGUI::Macro::SpectreCheck::process($session), $i18n->get('success'), 'good status';
$spectreStatus = 'subnet';
is WebGUI::Macro::SpectreCheck::process($session), $i18n->get('subnet'), 'bad subnet';
$spectreStatus = 'spectre';
is WebGUI::Macro::SpectreCheck::process($session), $i18n->get('spectre'), 'bad spectre';

*WebGUI::Operation::Spectre::spectreTest = $original_spectreCheck;
