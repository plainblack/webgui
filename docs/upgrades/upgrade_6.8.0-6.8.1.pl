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
updateProfileSystem();
convertDashboardPrefs();
fixPosts();
fixIOB();

finish(); # this line required


#-------------------------------------------------
sub fixIOB  {
	print "\tFixing IOB.\n" unless ($quiet);
	WebGUI::SQL->write("alter table InOutBoard_statusLog add column createdBy varchar(22) binary");
}

#-------------------------------------------------
sub fixPosts {
	print "\tFixing posts.\n" unless ($quiet);
	WebGUI::SQL->write("update Post set dateUpdated=".time()." where dateUpdated=0");
}

#-------------------------------------------------
sub updateProfileSystem {
	print "\tUpdating user profile system.\n" unless ($quiet);
	WebGUI::SQL->write("alter table userProfileField change fieldLabel label varchar(255) not null default 'Undefined'");
	WebGUI::SQL->write("alter table userProfileField change dataType fieldType varchar(128) not null default 'text'");
	WebGUI::SQL->write("alter table userProfileField change dataValues possibleValues text");
	WebGUI::SQL->write("alter table userProfileCategory change categoryName label varchar(255) not null default 'Undefined'");
	WebGUI::SQL->write("alter table userProfileCategory add column protected int not null default 0");
	WebGUI::SQL->write("update userProfileCategory set protected=1 where profileCategoryId in ('1','2','3','4','5','6','7')");
}

#-------------------------------------------------
sub upgradeRichEditor {
	print "\tUpgrade rich editor\n" unless ($quiet);
	rmtree("../../www/extras/tinymce");
}

#-------------------------------------------------
sub convertDashboardPrefs {
	print "\tConverting Dashboard preferences\n" unless ($quiet);
	#purge all Fields.
	my $a = WebGUI::SQL->read("select assetId from asset where className='WebGUI::Asset::Field'");
	while (my ($assetId) = $a->array) {
		WebGUI::Asset::Field->new($assetId)->purge;
	}
	unlink("../../lib/WebGUI/Asset/Field.pm");
	WebGUI::SQL->write("DROP TABLE `wgField`");
	WebGUI::SQL->write("ALTER TABLE `Dashboard` DROP COLUMN mapFieldId");
	WebGUI::SQL->write("ALTER TABLE `Dashboard` ADD COLUMN `isInitialized` TINYINT UNSIGNED NOT NULL DEFAULT 0");
	WebGUI::SQL->write("ALTER TABLE `Dashboard` ADD COLUMN `assetsToHide` TEXT");
	WebGUI::SQL->write("ALTER TABLE `Shortcut` ADD COLUMN `prefFieldsToShow` TEXT");
	WebGUI::SQL->write("ALTER TABLE `Shortcut` ADD COLUMN `prefFieldsToImport` TEXT");
	WebGUI::SQL->write("ALTER TABLE `Shortcut` ADD COLUMN `showReloadIcon` TINYINT UNSIGNED NOT NULL DEFAULT 0");
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

