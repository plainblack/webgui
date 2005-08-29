use lib "../../lib";
use strict;
use Getopt::Long;
use WebGUI::Session;
use WebGUI::SQL;

my $toVersion = "6.7.3";
my $configFile;
my $quiet;

start();
deleteOldHelpFiles();
finish();

#-------------------------------------------------
#sub fixSomething {
#        print "\tFixing ....\n" unless ($quiet);

sub deleteOldHelpFiles {
	my @dupes = qw/Article Collaboration DataForm EventsCalendar File Folder Survey HttpProxy
		       IndexedSearch Image Layout MessageBoard Navigation Poll Post Product
		       Redirect Shortcut Snippet SQLReport SyndicatedContent Template Thread/;
	my $path = "../../lib/WebGUI/";
	print "\tDeleting old documentation\n" unless ($quiet);
	foreach my $dupe (@dupes) {
		print "\tDeleting old documentation for $dupe\n" unless ($quiet);
		foreach my $dir ("Help/", "i18n/English/") {
			my $file = join '', $path, $dir, $dupe, '.pm';
			my $files_deleted = unlink($file);
			print("\t\tUnable to delete $file: $!\n") unless $quiet or $files_deleted;
		}
	}
}


#-------------------------------------------------
sub start {
	$|=1; #disable output buffering
	GetOptions(
    		'configFile=s'=>\$configFile,
        	'quiet'=>\$quiet
	);
	WebGUI::Session::open("../..",$configFile);
	WebGUI::Session::refreshUserInfo(3);
	WebGUI::SQL->write("insert into webguiVersion values (".quote($toVersion).",'upgrade',".time().")");
}

#-------------------------------------------------
sub finish {
	WebGUI::Session::close();
}

