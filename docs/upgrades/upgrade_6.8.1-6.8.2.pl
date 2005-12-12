#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use lib "../../lib";
use strict;
use Getopt::Long;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Asset;


my $toVersion = "6.8.2"; # make this match what version you're going to
my $quiet; # this line required


start(); # this line required

fixPosts();
fixDataFormMailForm();

finish(); # this line required


#-------------------------------------------------
sub fixPosts {
	print "\tFixing posts.\n" unless ($quiet);
	WebGUI::SQL->write("update Post set dateSubmitted=dateUpdated where dateSubmitted is null");
}

#-------------------------------------------------
sub fixDataFormMailForm {
	print "\tFix bad template variable in Mail Form.\n" unless ($quiet);
	my $asset = WebGUI::Asset->new("PBtmpl0000000000000020","WebGUI::Asset::Template");
	if (defined $asset) {
		my $template = $asset->get("template");
		$template =~ s/<tmpl_if field.required>/<tmpl_if field.isRequired>/g;
		$asset->addRevision({template=>$template})->commit;
	}
}



# ---- DO NOT EDIT BELOW THIS LINE ----

#-------------------------------------------------
sub start {
	my $configFile;
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

