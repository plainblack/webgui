my $toVersion = "6.7.2";

$|=1; #disable output buffering

use lib "../../lib";
use Getopt::Long;
use strict;
use WebGUI::Session;
use WebGUI::SQL;

my $configFile;
my $quiet;

GetOptions(
    'configFile=s'=>\$configFile,
	'quiet'=>\$quiet
);

WebGUI::Session::open("../..",$configFile);
WebGUI::Session::refreshUserInfo(3);

WebGUI::SQL->write("insert into webguiVersion values (".quote($toVersion).",'upgrade',".time().")");

WebGUI::Session::close();


