#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
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
use WebGUI::Workflow;

my $toVersion = "7.2.0"; # make this match what version you're going to
my $quiet; # this line required


my $session = start(); # this line required

commerceSalesTax($session);
createDictionaryStorage($session);
addRssUrlMacroProcessing($session);
addLastExportedAs($session);
addDeletionWorkflows($session);
addRSSFromParent($session);
reorderSurveyCollateral($session);
addMailExcludeGroups($session);

finish($session); # this line required

#--------------------------------------------------
sub addRssUrlMacroProcessing {
	my $session = shift;
	print "\tAdding option to process macros in a Syndicated Content RSS Url.\n" unless ($quiet);
	$session->db->write("alter table SyndicatedContent add column processMacroInRssUrl int(11) default 0");

}

##-------------------------------------------------
sub commerceSalesTax {
	my $session = shift;
	print "\tAdding tables and columns to support sales tax in the Commerce System.\n" unless ($quiet);
	$session->db->write(<<EOS1);
CREATE TABLE commerceSalesTax (commerceSalesTaxId varchar(22) NOT NULL, regionIdentifier varchar(50) NOT NULL, salesTax float NOT NULL, PRIMARY KEY (commerceSalesTaxId) ) ENGINE MyISAM DEFAULT CHARSET=utf8;
EOS1
	$session->db->write(<<EOS2);
ALTER TABLE products
ADD COLUMN useSalesTax INTEGER DEFAULT 0;
EOS2
	$session->db->write(<<EOS3);
ALTER TABLE subscription
ADD COLUMN useSalesTax INTEGER DEFAULT 0;
EOS3
	$session->db->write(<<EOS3);
INSERT INTO settings (name,value) VALUES ('commerceEnableSalesTax','0');
EOS3
}

#-------------------------------------------------
sub createDictionaryStorage {
	my $session = shift;
	print "\tCreating the directory for the personal dictionaries.\n" unless ($quiet);

	my $dictionaryDirectory = $session->config->get('uploadsPath') .'/dictionaries';

	mkdir $dictionaryDirectory unless (-e $dictionaryDirectory);
	mkdir $dictionaryDirectory.'/oldIds' unless (-e $dictionaryDirectory.'/oldIds');
}

#-------------------------------------------------
sub addLastExportedAs {
	my $session = shift;
	print "\tAdding lastExportedAs field for assets.\n" unless $quiet;

	$session->db->write($_) for(<<'EOT',
  ALTER TABLE asset
   ADD COLUMN lastExportedAs varchar(255) NULL DEFAULT NULL
EOT
				   );
}

#-------------------------------------------------
sub addDeletionWorkflows {
	my $session = shift;
	print "\tAdding deletion workflows and activities.\n" unless $quiet;

	my $nullAssetWorkflow = WebGUI::Workflow->create
	    ($session, { type => "None",
			 enabled => 1,
			 description => "Does nothing extra.  Default for deletion workflow settings.",
			 title => "Do Nothing on Deletion" },
	     "DPWwf20061030000000001");
	my $deleteExportsWorkflow = WebGUI::Workflow->create
	    ($session, { type => "None",
			 enabled => 1,
			 description => "Deletes exported files from an asset being deleted or moved.",
			 title => "Delete Exported Files" },
	     "DPWwf20061030000000002");
	my $deleteExportsActivity = $deleteExportsWorkflow->addActivity
	    ("WebGUI::Workflow::Activity::DeleteExportedFiles", "DPWwfa2006103000000002");
	$deleteExportsActivity->set('title', 'Delete Exported Files');

	$session->db->write("INSERT INTO settings (name, value) VALUES (?, ?)", $_) for
	    (['trashWorkflow', $nullAssetWorkflow->getId], ['purgeWorkflow', $nullAssetWorkflow->getId],
	     ['changeUrlWorkflow', $nullAssetWorkflow->getId]);

	my $activityHash = $session->config->get('workflowActivities');
	push @{$activityHash->{None}}, 'WebGUI::Workflow::Activity::DeleteExportedFiles';
	$session->config->set('workflowActivities', $activityHash);
}


#-------------------------------------------------
sub addRSSFromParent {
	my $session = shift;
	print "\tAdding RSS From Parent capability.\n" unless $quiet;

	$session->db->write($_) for (<<'EOT',
  CREATE TABLE RSSFromParent (
    assetId varchar(22) character set utf8 collate utf8_bin NOT NULL,
    revisionDate bigint(20) NOT NULL,
    PRIMARY KEY (assetId, revisionDate)
  ) ENGINE=MyISAM DEFAULT CHARSET=utf8;
EOT
				     <<'EOT',
  CREATE TABLE RSSCapable (
    assetId varchar(22) character set utf8 collate utf8_bin NOT NULL,
    revisionDate bigint(20) NOT NULL,
    rssCapableRssEnabled int(11) NOT NULL DEFAULT 1,
    rssCapableRssTemplateId varchar(22) character set utf8 collate utf8_bin NOT NULL
                            DEFAULT 'PBtmpl0000000000000142',
    rssCapableRssFromParentId varchar(22) character set utf8 collate utf8_bin NULL DEFAULT NULL,
    PRIMARY KEY (assetId, revisionDate)
  ) ENGINE=MyISAM DEFAULT CHARSET=utf8;
EOT
				    );

	my $oldTag = WebGUI::VersionTag->getWorking($session, 0);
	my $templateTag = WebGUI::VersionTag->create($session, { name => '7.2.0 RSS template update' });
	$templateTag->setWorking;
	foreach my $templateId ($session->db->buildArray("SELECT assetId FROM template WHERE namespace = 'Collaboration/RSS'")) {
		my $template = WebGUI::Asset->newByDynamicClass($session, $templateId)->addRevision;
		$template->update({ namespace => 'RSSCapable/RSS' });
	}

	WebGUI::Asset->newByDynamicClass($session, 'PBtmpl0000000000000142')
					     ->update({ title => 'Default RSS', menuTitle => 'Default RSS' });
	$templateTag->commit;

	# Need to get the Collaborations, since those now have RSS capability.
	$session->db->write($_) for (<<'EOT',
  INSERT INTO RSSCapable (assetId, revisionDate, rssCapableRssEnabled, rssCapableRssTemplateId,
                          rssCapableRssFromParentId)
    SELECT assetId, revisionDate, 0, 'PBtmpl0000000000000142', NULL
      FROM Collaboration
EOT
				     <<'EOT',
  ALTER TABLE Collaboration
  DROP COLUMN rssTemplateId
EOT
				    );

	my $csTag = WebGUI::VersionTag->create($session, { name => '7.2.0 Collaboration RSS update' });
	$csTag->setWorking;
	foreach my $csId ($session->db->buildArray("SELECT assetId FROM Collaboration")) {
		# Blah, some duplication with RSSCapable.pm.
		my $cs = WebGUI::Asset->newByDynamicClass($session, $csId)->addRevision;
		next if $cs->get('isPrototype'); # Uh.
		my $rssFromParent =
		    $cs->addChild({ className => 'WebGUI::Asset::RSSFromParent',
				    title => $cs->get('title'),
				    menuTitle => $cs->get('menuTitle'),
				    url => $cs->get('url').'.rss'
				  });
		$cs->update({ rssCapableRssFromParentId => $rssFromParent->getId });
	}
	$csTag->commit;

	$oldTag->setWorking if $oldTag;
}

##-------------------------------------------------
sub reorderSurveyCollateral {
	my $session = shift;
	print "\tFixing ordering problems with Survey answers.\n" unless ($quiet);
	# and here's our code
	my $sth1 = $session->db->prepare("select distinct(assetId) from Survey");
	my $sth2 = $session->db->prepare("select Survey_questionId from Survey_question where Survey_Id=?");
	$sth1->execute();
	while (my ($assetId) = $sth1->array) {  ##Iterate over all surveys
		my $survey = WebGUI::Asset->new($session, $assetId, 'WebGUI::Asset::Wobject::Survey');
		my $Survey_Id = $survey->get('Survey_id');
		$sth2->execute([$Survey_Id]);
		while (my ($questionId) = $sth2->array) { ##iterate over all questions in the survey
			$session->errorHandler->warn($questionId);
			$survey->reorderCollateral("Survey_answer", "Survey_answerId","Survey_questionId", $questionId);
		}
		$sth2->finish;
	}
	$sth1->finish;
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
	my $session = WebGUI::Session->open("../..",$configFile);
	$session->user({userId=>3});
	my $versionTag = WebGUI::VersionTag->getWorking($session);
	$versionTag->set({name=>"Upgrade to ".$toVersion});
	$session->db->write("insert into webguiVersion values (".$session->db->quote($toVersion).",'upgrade',".$session->datetime->time().")");
	updateTemplates($session);
	return $session;
}

#-------------------------------------------------
sub finish {
	my $session = shift;
	my $versionTag = WebGUI::VersionTag->getWorking($session);
	$versionTag->commit;
	$session->close();
}

#-------------------------------------------------
sub updateTemplates {
	my $session = shift;
	return undef unless (-d "templates-".$toVersion);
        print "\tUpdating templates.\n" unless ($quiet);
	opendir(DIR,"templates-".$toVersion);
	my @files = readdir(DIR);
	closedir(DIR);
	my $importNode = WebGUI::Asset->getImportNode($session);
	my $newFolder = undef;
	foreach my $file (@files) {
		next unless ($file =~ /\.tmpl$/);
		open(FILE,"<templates-".$toVersion."/".$file);
		my $first = 1;
		my $create = 0;
		my $head = 0;
		my %properties = (className=>"WebGUI::Asset::Template");
		while (my $line = <FILE>) {
			if ($first) {
				$line =~ m/^\#(.*)$/;
				$properties{id} = $1;
				$first = 0;
			} elsif ($line =~ m/^\#create$/) {
				$create = 1;
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
		if ($create) {
			$newFolder = createNewTemplatesFolder($importNode) unless (defined $newFolder);
			my $template = $newFolder->addChild(\%properties, $properties{id});
		} else {
			my $template = WebGUI::Asset->new($session,$properties{id}, "WebGUI::Asset::Template");
			if (defined $template) {
				my $newRevision = $template->addRevision(\%properties);
			}
		}
	}
}

#-------------------------------------------------
sub createNewTemplatesFolder {
	my $importNode = shift;
	my $newFolder = $importNode->addChild({
		className=>"WebGUI::Asset::Wobject::Folder",
		title => $toVersion." New Templates",
		menuTitle => $toVersion." New Templates",
		url=> $toVersion."_new_templates",
		groupIdView=>"12"
		});
	return $newFolder;
}



