# This file is here to add new stuff just for 7.0 installs. It will be applied for the generation of create.sql, but won't be included in the official distribution.

use lib "../../lib";
use strict;
use Getopt::Long;
use WebGUI::Session;




my $session = start(); # this line required

addPrototypes();

finish($session); # this line required


#-------------------------------------------------
sub addPrototypes {
	print "\tAdding default prototypes to make finding things easier for noobs.\n";
	my $importNode = WebGUI::Asset->getImportNode($session);
	$importNode->addChild({
		title=>"Photo Gallery",
		menuTitle=>"Photo Gallery",
		url=>"photo-gallery-prototype",
		groupIdView=>'7',
		groupIdEdit=>'12',
		className=>'WebGUI::Asset::Wobject::Collaboration',
		assetId=>"new",
		allowReplies=>0,
		attachmentsPerPost=>10,
		isPrototype=>1,
		usePreview=>0,
		collaborationTemplateId=>"PBtmpl0000000000000121",
		threadTemplateId=>"PBtmpl0000000000000067",
		postFormTemplateId=>"PBtmpl0000000000000068"	
		},"pbproto000000000000001");
}



# ---- DO NOT EDIT BELOW THIS LINE ----

#-------------------------------------------------
sub start {
	my $configFile;
	$|=1; #disable output buffering
	GetOptions(
    		'configFile=s'=>\$configFile
	);
	my $session = WebGUI::Session->open("../..",$configFile);
	$session->user({userId=>3});
	my $versionTag = WebGUI::VersionTag->getWorking($session);
	$versionTag->set({name=>"Stuff just for 7.0 installs"});
	return $session;
}

#-------------------------------------------------
sub finish {
	my $session = shift;
	my $versionTag = WebGUI::VersionTag->getWorking($session);
	$versionTag->commit;
	$session->close();
}

