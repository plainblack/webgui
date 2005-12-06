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
use File::Path;
use WebGUI::SQL;
use WebGUI::Asset;

my $toVersion = "6.8.1"; # make this match what version you're going to
my $quiet; # this line required


start(); # this line required

upgradeRichEditor();
fixCSFaqTemplateAnchors();

finish(); # this line required


#-------------------------------------------------
sub upgradeRichEditor {
	print "\tUpgrade rich editor\n" unless ($quiet);
	rmtree("../../www/extras/tinymce");
}

#-------------------------------------------------
sub fixCSFaqTemplateAnchors {
	print "\tFix Anchors in the CS FAQ Template\n" unless ($quiet);
	my $asset = WebGUI::Asset->new("PBtmpl0000000000000080","WebGUI::Asset::Template");
	if (defined $asset) {  ##Can't update what doesn't exist
		my $template = $asset->get("template");
		$template =~ s/(<a href="#)(<tmpl_var assetId>)/${1}id${2}/;
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

