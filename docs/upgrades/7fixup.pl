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
deleteOldContent();
addNewContent();
$versionTag->commit;
purgeOldRevisions();

finish($session); # this line required

#-------------------------------------------------
sub addNewContent {
	print "\tAdding new content.\n";
	my $home = WebGUI::Asset->getDefault($session);
	$home->addChild({
		className=>"WebGUI::Asset::Wobject::Article",
		styleTemplateId=>"stevestyle000000000003",
		printableStyleTemplateId=>"stevestyle000000000003",
		isHidden=>1,
		title=>"Welcome",
		menuTitle=>"Welcome",
		url=>"home/welcome",
		ownerUserId=>'3',
		groupIdView=>'7',
		groupIdEdit=>'4',
		description=>q|<p>The <a href="http://www.webgui.org">WebGUI Content Engine</a> is a powerful and easy to use system for managing web sites, and building web applications. It provides thousands of features out of the box, and lots of plug-in points so you can extend it to match your needs. It's easy enough for the average business user, but powerful enough for any large enterprise.</p>

<p>There are thousands of <a href="http://www.jeffmillerphotography.com">small</a> and <a href="http://www.brunswicknt.com">large</a> businesses, <a href="http://phila.k12.pa.us">schools</a>, <a href="http://www.csumathsuccess.org">universities</a>, <a href="http://beijing.usembassy.gov/">governments</a>, <a href="http://www.gama.org">associations</a>, <a href="http://www.monashwushu.com">clubs</a>, <a href="http://www.sunsetpres.org">churches</a>, <a href="http://www.k3b.org">projects</a>, and <a href="http://www.comparehangouts.com">communities</a> using WebGUI all over the world today. A brief list of some of them can be found <a href="http://www.plainblack.com/webgui/campaigns/sightings">here</a>. Your site should be on that list.</p>|,
		templateId=>'PBtmpl0000000000000002'
		});
	$home->addChild({
		className=>"WebGUI::Asset::Wobject::Article",
		styleTemplateId=>"stevestyle000000000003",
		printableStyleTemplateId=>"stevestyle000000000003",
		title=>"Key Benefits",
		menuTitle=>"Key Benefits",
		isHidden=>1,
		url=>"home/key-benefits",
		ownerUserId=>'3',
		groupIdView=>'7',
		groupIdEdit=>'4',
		description=>q|
<p>
<b>Easy To Use</b> - WebGUI is absolutely easy to use. WebGUI 7 has a completely revamped user interface to make it even easier to use. There are lots of visual cues, consistent icons, helper apps, and a huge repository of built-in help files.
</p>
<p>
<b>Workflow &amp; Versioning</b> - Never again worry about content getting put on your site that you don't want there. Never again lose your old content after making an edit. And never again push out new changes until you're absolutely ready to release them. WebGUI's workflow and versioning system if fast, flexible, powerful, and easy to use.
</p>
<p>
<b>Everything's a Template</b> - Worry nevermore about your CMS forcing you into a mould that doesn't suit you. With WebGUI everything a site visitor can see is a customizable template, so you can make it look exactly how you want. Moreover if you're the type that strives for excellence rest in the knowledge that all the templates that come with WebGUI are XHTML 1.0 strict compliant.
</p>
<p>
<b>Localization</b> - WebGUI's entire user interface is set up to be internationalized. Visit one of the WebGUI Worldwide member sites to get translations for your language. Stay there to get support and services in your native language. Feel confident in the knowledge that WebGUI will work with your native characters because it's UTF-8 compliant. On top of that WebGUI allows you to customize dates, currency, and weights to match your locale. 
</p>
<p>
<b>Pluggable By Design</b> - With WebGUI 7 you have many plug-in points to add your own functionality. And best of all, the API is stable and standardized. Write it today and it will still work years from now and survive all upgrades.
</p>
|,
		templateId=>'PBtmpl0000000000000002'
		});
	my $gs = WebGUI::Asset->new($session,"_iHetEvMQUOoxS-T2CM0sQ","WebGUI::Asset::Wobject::Layout");
	$gs->addChild({
		className=>"WebGUI::Asset::Wobject::Article",
		styleTemplateId=>"stevestyle000000000003",
		printableStyleTemplateId=>"stevestyle000000000003",
		title=>"Getting Started",
		isHidden=>1,
		menuTitle=>"Getting Started",
		url=>"getting_started/getting-started",
		ownerUserId=>'3',
		groupIdView=>'7',
		groupIdEdit=>'4',
		description=>q|
<p>
If you're reading this message that means you've successfully installed and configured WebGUI. Great job!
</p>
<p>
Now you should <a href="^/;?op=auth">log in</a> and <a href="^LoginToggle(linkonly);">go into admin mode</a>. The default username is "admin" and the default password is "123qwe", but you probably customized both of those when you visited this site for the very first time.
</p>
<p>
Now that you're logged in, we recommend <a href="^/;?op=listUsers">creating a secondary account</a> for yourself with admin privileges just in case you forget the login information for your primary admin account. Don't worry if you lock yourself out, you can always contact <a href="http://www.plainblack.com">Plain Black</a> support to get instructions to get back in.
</p>
<p>
No doubt after you enabled admin mode you saw a menu along the left side of the screen, that's called the Admin Bar. Use that to add content and access administrative functions. To get started with managing content, watch the short instructional video below.
</p>
<p>
[wink flash video here]
</p>
<p>
For more information about services related to WebGUI <a href="http://www.plainblack.com/services">click here</a>.
</p>
<p>
Enjoy your new WebGUI site!
</p>
|,
		templateId=>'PBtmpl0000000000000002'
		});
	my $yns = WebGUI::Asset->new($session, "8Bb8gu-me2mhL3ljFyiWLg", "WebGUI::Asset::Wobject::Layout");
	$yns->addChild({
		className=>"WebGUI::Asset::Wobject::Article",
		styleTemplateId=>"stevestyle000000000003",
		printableStyleTemplateId=>"stevestyle000000000003",
		title=>"Talk to the Experts",
		menuTitle=>"Talk to the Experts",
		isHidden=>1,
		url=>"yns/experts",
		ownerUserId=>'3',
		groupIdView=>'7',
		groupIdEdit=>'4',
		description=>q|<p>Plain Black created WebGUI and is here to answer your questions and provide you with services to make sure your WebGUI implementation is entirely successful. We bend over backwards to make sure you're a success. <a href="http://www.plainblack.com/contact_us">Contact us</a> today to see how we can help you.</p>|,
		templateId=>'PBtmpl0000000000000002'
		});
	$yns->addChild({
		className=>"WebGUI::Asset::Wobject::Article",
		title=>"Get Documentation",
		styleTemplateId=>"stevestyle000000000003",
		printableStyleTemplateId=>"stevestyle000000000003",
		menuTitle=>"Get Documentation",
		isHidden=>1,
		url=>"yns/docs",
		ownerUserId=>'3',
		groupIdView=>'7',
		groupIdEdit=>'4',
		description=>q|<p><a href="http://www.plainblack.com/services/wdr">WebGUI Done Right</a> is the ultimate compendium to WebGUI. It is more than just documentation, it's also a library of hundreds of videos that show you exactly how to get stuff done. This is a must for anyone working in WebGUI, and Plain Black offers vast bulk discounts so you can give it to everyone in your organization.</p>|,
		templateId=>'PBtmpl0000000000000002'
		});
	$yns->addChild({
		className=>"WebGUI::Asset::Wobject::Article",
		styleTemplateId=>"stevestyle000000000003",
		printableStyleTemplateId=>"stevestyle000000000003",
		title=>"Get Support",
		menuTitle=>"Get Support",
		isHidden=>1,
		url=>"yns/support",
		ownerUserId=>'3',
		groupIdView=>'7',
		groupIdEdit=>'4',
		description=>q|<p>Plain Black provides <a href="http://www.plainblack.com/services/support">support packages</a> to fit any budget or need. Start out with online support which costs only $500 per year! And grow support as your needs grow. We build custom support packages to match our client's needs. And no matter what level of support you purchase, you get WebGUI Done Right included in your purchase.</p>|,
		templateId=>'PBtmpl0000000000000002'
		});
	$yns->addChild({
		className=>"WebGUI::Asset::Wobject::Article",
		styleTemplateId=>"stevestyle000000000003",
		printableStyleTemplateId=>"stevestyle000000000003",
		title=>"Get Hosting",
		isHidden=>1,
		menuTitle=>"Get Hosting",
		url=>"yns/hosting",
		ownerUserId=>'3',
		groupIdView=>'7',
		groupIdEdit=>'4',
		description=>q|<p>Who better to host your WebGUI sites than Plain Black. Let us deal with upgrades, security, and server management. Doing so lets you focus on building your WebGUI site, which is where your time and expertise should be spent. And when you <a href="http://www.plainblack.com/services/hosting">sign up with hosting</a>, online support and WebGUI Done Right are both included!</p>|,
		templateId=>'PBtmpl0000000000000002'
		});
	$yns->addChild({
		className=>"WebGUI::Asset::Wobject::Article",
		styleTemplateId=>"stevestyle000000000003",
		printableStyleTemplateId=>"stevestyle000000000003",
		title=>"Get Style",
		isHidden=>1,
		menuTitle=>"Get Style",
		url=>"yns/style",
		ownerUserId=>'3',
		groupIdView=>'7',
		groupIdEdit=>'4',
		description=>q|<p>Not a designer? No problem! Plain Black's professional <a href="http://www.plainblack.com/services/design">design</a> team can make your site look great. Our team is fast, easy to work with, and can even migrate your existing content into your new WebGUI site.</p>|,
		templateId=>'PBtmpl0000000000000002'
		});
	$yns->addChild({
		className=>"WebGUI::Asset::Wobject::Article",
		title=>"Get Features",
		styleTemplateId=>"stevestyle000000000003",
		printableStyleTemplateId=>"stevestyle000000000003",
		isHidden=>1,
		menuTitle=>"Get Features",
		url=>"yns/features",
		ownerUserId=>'3',
		groupIdView=>'7',
		groupIdEdit=>'4',
		description=>q|<p>What's that you say? WebGUI's thousands of features are still missing some important ones? No problem, our professional development team can <a href="http://www.plainblack.com/services/development">add any features you need</a> for your site. We've built hundreds of custom apps for people. From simple macros, to custom single sign on systems, to applications that will manage your entire company, our team can do it.</p>|,
		templateId=>'PBtmpl0000000000000002'
		});
	$yns->addChild({
		className=>"WebGUI::Asset::Wobject::Article",
		title=>"Get Translated",
		styleTemplateId=>"stevestyle000000000003",
		printableStyleTemplateId=>"stevestyle000000000003",
		isHidden=>1,
		menuTitle=>"Get Translated",
		url=>"yns/translated",
		ownerUserId=>'3',
		groupIdView=>'7',
		groupIdEdit=>'4',
		description=>q|<p>Let our team of professional translators bring your site to new customers by <a href="http://www.plainblack.com/services/translation">translating your content</a> into additional languages. Our translation services are never machine automated. They're always done by professional translators that have years of experience reading, writing, and speaking many languages.</p>|,
		templateId=>'PBtmpl0000000000000002'
		});
	$yns->addChild({
		className=>"WebGUI::Asset::Wobject::Article",
		styleTemplateId=>"stevestyle000000000003",
		printableStyleTemplateId=>"stevestyle000000000003",
		title=>"Get Promoted",
		menuTitle=>"Get Promoted",
		isHidden=>1,
		url=>"yns/promotion",
		ownerUserId=>'3',
		groupIdView=>'7',
		groupIdEdit=>'4',
		description=>q|<p>Now that you have a brilliant WebGUI site, you need to get people to visit it. We can help there too. Our marketing specialists can work with you to develop and execute the right combination of search engine placement, advertising buys, and affilliate programs to <a href="http://www.plainblack.com/services/promotion">ensure your site gets the traffic it needs</a>.</p>|,
		templateId=>'PBtmpl0000000000000002'
		});
}

#-------------------------------------------------
sub deleteOldContent {
	print "\tDeleting old content\n";
	foreach my $id (qw(PBtmpl0000000000000071 PBtmpl0000000000000075 f2bihDeMoI-Ojt2dutJNQA KZ2UytxNpbF-3Eg3RNvQQQ G0wlShbk_XruYVfbXqWq_w TKzUMeIxRLrZ3NAEez6CXQ sWVXMZGibxHe2Ekj1DCldA x_WjMvFmilhX-jvZuIpinw  DC1etlIaBRQitXnchZKvUw wCIc38CvNHUK7aY92Ww4SQ)) {
		my $asset = WebGUI::Asset->newByDynamicClass($session, $id);
		$asset->purge if (defined $asset);
	}
}


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
			next if $file eq ".svn";
			$assetCounter++;
			print "\t\t\tAdding $file\n";
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
	$session->db->write("update wobject set styleTemplateId='stevestyle000000000003' where styleTemplateId in ('B1bNjWVtzSjsvGZh9lPz_A','9tBSOV44a9JPS8CcerOvYw')");
	$session->setting->set("userFunctionStyleId","stevestyle000000000003");
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

