use lib "../../lib";
use strict;
use Getopt::Long;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Asset;
use WebGUI::Setting;

my $toVersion = "6.7.8";
my $configFile;
my $quiet;

start();
protectUserProfileFields();
correctEditProfileTemplate();
finish();

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
sub protectUserProfileFields {
        print "\tProtecting all default user fields.\n" unless ($quiet);
	WebGUI::SQL->write("update userProfileField set protected=1 where fieldName in ('discussionLayout','INBOXNotifications','alias','signature','publicProfile','publicEmail','toolbar')");
}

#-------------------------------------------------
sub correctEditProfileTemplate {
        print "\tFixing Edit Profile template.\n" unless ($quiet);
	my $tmplAsset = WebGUI::Asset->newByDynamicClass("PBtmpl0000000000000051");
	my $template = $tmplAsset->get('template');
	$template =~ s/create.form.footer/profile.form.footer/;
	$tmplAsset->addRevision({ template=>$template });
	$tmplAsset->commit;
}

#-------------------------------------------------
sub finish {
	WebGUI::Session::close();
}

