#!/usr/bin/perl

use lib "../../lib";
use File::Path;
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

#--------------------------------------------
print "\tPartitioning limbo\n" unless ($quiet);
my $sth = WebGUI::SQL->read("select lineage from asset where state='trash'");
while (my ($lineage) = $sth->array) {
	WebGUI::SQL->write("update asset set state='trash-limbo' where lineage like ".quote($lineage.'%')." and state='limbo'");
}
$sth->finish;
WebGUI::SQL->write("update asset set state='clipboard-limbo' where state='limbo'");


#--------------------------------------------
print "\tRemoving old files\n" unless ($quiet);
# should have been removed in the 6.2-6.3 upgrade
unlink("../../sbin/Hourly/EmptyTrash.pm");
unlink("../../lib/WebGUI/Wobject/IndexedSearch.pm");
rmtree("../../lib/WebGUI/Wobject/IndexedSearch");
unlink("../../lib/WebGUI/Wobject/Product.pm");
unlink("../../lib/WebGUI/Wobject/SyndicatedContent.pm");
unlink("../../lib/WebGUI/Wobject/Survey.pm");

WebGUI::Session::close();


