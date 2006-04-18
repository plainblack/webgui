# This file is here to add new stuff just for 7.0 installs. It will be applied for the generation of create.sql, but won't be included in the official distribution.

use lib "../../lib";
use strict;
use Getopt::Long;
use WebGUI::Session;
use WebGUI::VersionTag;
use WebGUI::Asset;
use WebGUI::Utility;


my $session = start(); # this line required

my $versionTag = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"Stuff just for 7.0 installs"});
addPrototypes();
rearrangeImportNode();
addNewStyles();
addRobots();
$versionTag->commit;
purgeOldRevisions();

finish($session); # this line required

#-------------------------------------------------
sub addRobots {
	print "\tAdding robots.txt file.\n";
	my $importNode = WebGUI::Asset->getImportNode($session);
	$importNode->addChild({
		title=>"robots.txt",
		menuTitle=>"robots.txt",
		url=>"robots.txt",
		groupIdView=>'7',
		groupIdEdit=>'12',
		className=>'WebGUI::Asset::Snippet',
		assetId=>"new",
		snippet=>'User-agent: googlebot
Disallow: *?op=displayLogin
Disallow: *?op=makePrintable
'
		},"pbrobot000000000000001");
}


#-------------------------------------------------
sub addNewStyles {
	print "\tAdding new 7.0 styles.\n";
	my $assetCounter = 0;
	my $import = WebGUI::Asset->getImportNode($session);
	my $styleCounter = 0;
	foreach my $style (qw(style1 style2 style3)) {
		$styleCounter++;
		print "\t\tStyle $styleCounter\n";
		opendir(DIR,"7fixup/".$style);
		my @files = readdir(DIR);
		closedir(DIR);
		$assetCounter++;
		my $folder = $import->addChild({
			styleTemplateId=>'PBtmpl0000000000000060',
			className=>"WebGUI::Asset::Wobject::Folder",
			title=>"WebGUI 7 Style ".$styleCounter,
			menuTitle=>"WebGUI 7 Style ".$styleCounter,
			url=>'root/import/webgui-7-style-'.$styleCounter,
			ownerUserId=>'3',
			groupIdView=>'7',
			groupIdEdit=>'12',
			templateId=>'PBtmpl0000000000000078'
			},"7.0-style".sprintf("%013d",$assetCounter));
		foreach my $file (@files) {
			next if $file eq "..";
			next if $file eq ".";
			$assetCounter++;
			if ($file =~ m/\.[png|jpg|gif]+$/) {
				my $asset = $folder->addChild({
					className=>"WebGUI::Asset::File::Image",
					title=>$file,
					menuTitle=>$file,
					url=>$style."/".$file,
					ownerUserId=>'3',
					groupIdView=>'7',
					groupIdEdit=>'12',
					templateId=>'PBtmpl0000000000000088',
					filename=>$file
					},"7.0-style".sprintf("%013d",$assetCounter));
				$asset->getStorageLocation->addFileFromFilesystem("7fixup/".$style."/".$file);
				$asset->getStorageLocation->generateThumbnail($file);
			} elsif ($file =~ m/.tmpl$/) {
				open(FILE,"<7fixup/".$style."/".$file);
				my $first = 1;
				my $head = 0;
				my %properties = (className=>"WebGUI::Asset::Template");
				while (my $line = <FILE>) {
					if ($first) {
						$line =~ m/^\#(.*)$/;
						$properties{id} = $1;
						$first = 0;
					} elsif ($line =~ m/^\#create$/) {
					} elsif ($line =~ m/^\#(.*):(.*)$/) {
						$properties{$1} = $2;
					} elsif ($line =~ m/^~~~$/) {
						$head = 1;
					} elsif ($head) {
						$properties{headBlock} .= $line;
					} else {
						$properties{template} .= $line;	
					}
				}
				close(FILE);
				my $template = $folder->addChild(\%properties, $properties{id});
			} elsif ($file =~ m/.nav$/) {
				open(FILE,"<"."7fixup/".$style."/".$file);
				my $first = 1;
				my $head = 0;
				my %properties = (className=>"WebGUI::Asset::Wobject::Navigation", styleTemplateId=>'PBtmpl0000000000000060');
				while (my $line = <FILE>) {
					if ($first) {
						$line =~ m/^\#(.*)$/;
						$properties{id} = $1;
						$first = 0;
					} elsif ($line =~ m/^\#(.*):(.*)$/) {
						$properties{$1} = $2;
					}
				}
				close(FILE);
				my $template = $folder->addChild(\%properties, "7.0-style".sprintf("%013d",$assetCounter));
			} elsif ($file =~ m/.snippet$/) {
				open(FILE,"<7fixup/".$style."/".$file);
				my $head = 0;
				my %properties = (className=>"WebGUI::Asset::Snippet");
				while (my $line = <FILE>) {
					if ($line =~ m/^\#(.*):(.*)$/) {
						$properties{$1} = $2;
					} else {
						$properties{snippet} .= $line;	
					}
				}
				close(FILE);
				my $template = $folder->addChild(\%properties, "7.0-style".sprintf("%013d",$assetCounter));
			}
		}
	}
	print "\t\tSetting all pages to use new style.\n";
	$session->db->write("update wobject set styleTemplateId='stevestyle000000000001' where styleTemplateId in ('B1bNjWVtzSjsvGZh9lPz_A','9tBSOV44a9JPS8CcerOvYw')");
	print "\t\tDeleting old styles.\n";
	my $asset = WebGUI::Asset->new($session,'9tBSOV44a9JPS8CcerOvYw');
	$asset->purge if defined $asset;
	my $asset = WebGUI::Asset->new($session,'B1bNjWVtzSjsvGZh9lPz_A');
	$asset->purge if defined $asset;
}

#-------------------------------------------------
sub rearrangeImportNode {
	print "\tRearranging import node.\n";
	my @oldFolders = $session->db->buildArray("select assetId from asset where className='WebGUI::Asset::Wobject::Folder' and assetId<>'PBasset000000000000002'");
	my $import = WebGUI::Asset->getImportNode($session);
	my $rs1 = $session->db->read("select distinct namespace from template order by namespace");
	while (my ($namespace) = $rs1->array) {
		next if (isIn($namespace, qw(Matrix/Compare Matrix/Detail Matrix/RatingDetail Matrix/Search EventManagementSystem_checkout EventManagementSystem_product Collaboration/Notification Collaboration/PostForm Collaboration/RSS Collaboration/Search Collaboration/Thread EventsCalendar/Event Inbox/Message InOutBoard/Report StockData/Display Survey/Gradebook Survey/Overview Survey/Response Commerce/CheckoutCanceled Commerce/ConfirmCheckout Commerce/Product Commerce/SelectPaymentGateway Commerce/SelectShippingMethod Commerce/TransactionError Commerce/ViewPurchaseHistory Commerce/ViewShoppingCart DataForm/List)));
		my $folder = $import->addChild({
			assetId=>"new",
			styleTemplateId=>'PBtmpl0000000000000060',
			className=>"WebGUI::Asset::Wobject::Folder",
			title=>$namespace,
			menuTitle=>$namespace,
			url=>'root/import/'.$namespace,
			ownerUserId=>'3',
			groupIdView=>'7',
			groupIdEdit=>'12',
			templateId=>'PBtmpl0000000000000078'
			});
		my $rs2 = "";
		if (isIn($namespace, qw(Matrix EventManagementSystem Collaboration EventsCalendar Inbox InOutBoard StockData Survey DataForm))) {
			$rs2 = $session->db->read("select assetId from template where namespace like ?",[$namespace.'%']);
		} else {
			$rs2 = $session->db->read("select assetId from template where namespace=?",[$namespace]);
		}
		while (my ($id) = $rs2->array) {
			my $asset = WebGUI::Asset->new($session, $id, "WebGUI::Asset::Template");
			$asset->setParent($folder) if defined $asset;
		}
		if ($namespace eq "SyndicatedContent") {
			foreach my $id (qw(SynConXSLT000000000001 SynConXSLT000000000002 SynConXSLT000000000003 SynConXSLT000000000004)) {
				my $asset = WebGUI::Asset->new($session, $id, "WebGUI::Asset::Snippet");
				$asset->setParent($folder) if defined $asset;
			}
		} elsif ($namespace eq "Navigation") {
			my $navFolder = WebGUI::Asset->new($session, "Wmjn6I1fe9DKhiIR39YC0g", "WebGUI::Asset::Wobject::Folder");
			foreach my $asset (@{$navFolder->getLineage(["children"],{returnObjects=>1})}) {
				$asset->setParent($folder) if defined $asset;
			}
		} elsif ($namespace eq "Collaboration") {
			foreach my $id (qw(pbproto000000000000001)) {
				my $asset = WebGUI::Asset->new($session, $id, "WebGUI::Asset::Wobject::Collaboration");
				$asset->setParent($folder) if defined $asset;
			}
		}
	}
	my $folder = $import->addChild({
		assetId=>"new",
		styleTemplateId=>'PBtmpl0000000000000060',
		className=>"WebGUI::Asset::Wobject::Folder",
		title=>'Commerce',
		menuTitle=>'Commerce',
		url=>'root/import/commerce',
		ownerUserId=>'3',
		groupIdView=>'7',
		groupIdEdit=>'12',
		templateId=>'PBtmpl0000000000000078'
		});
	foreach my $id (qw(PBtmpl0000000000000015 PBtmpl0000000000000016 PBtmplCP00000000000001 PBtmpl0000000000000017 PBtmplCSSM000000000001 PBtmpl0000000000000018 PBtmpl0000000000000019 PBtmplVSC0000000000001)) {
		my $asset = WebGUI::Asset->new($session, $id, "WebGUI::Asset::Template");
		$asset->setParent($folder) if defined $asset;
	}
	my $folder = $import->addChild({
		assetId=>"new",
		styleTemplateId=>'PBtmpl0000000000000060',
		className=>"WebGUI::Asset::Wobject::Folder",
		title=>'RichEdit',
		menuTitle=>'RichEdit',
		url=>'root/import/richedit',
		ownerUserId=>'3',
		groupIdView=>'7',
		groupIdEdit=>'12',
		templateId=>'PBtmpl0000000000000078'
		});
	foreach my $id (qw(PBrichedit000000000001 PBrichedit000000000002)) {
		my $asset = WebGUI::Asset->new($session, $id, "WebGUI::Asset::RichEdit");
		$asset->setParent($folder) if defined $asset;
	}
	foreach my $id (@oldFolders) {
		my $folder = WebGUI::Asset->new($session, $id, "WebGUI::Asset::Wobject::Folder");
		$folder->purge if (defined $folder);
	}
}

#-------------------------------------------------
sub purgeOldRevisions {
	print "\tGetting rid of the old cruft.\n";
	my $rs1 = $session->db->read("select assetId, className from asset");
	while (my ($id, $class) = $rs1->array) {
		my $asset = WebGUI::Asset->new($session, $id, $class);
		if (defined $asset) {
			if ($asset->getRevisionCount > 1) {
				my $rs2 = $session->db->read("select revisionDate from assetData where assetId=? and revisionDate<>?",[$id, $asset->get("revisionDate")]);
				while (my ($version) = $rs2->array) {
					my $old = WebGUI::Asset->new($session, $id, $class, $version);
					$old->purgeRevision if defined $old;
				}
			}	
		}
	}
}

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
	return $session;
}

#-------------------------------------------------
sub finish {
	my $session = shift;
	$session->close();
}

