#!/usr/bin/perl

use lib "../../lib";
use Getopt::Long;
use strict;
use WebGUI::Id;
use WebGUI::Page;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;


my $configFile;
my $quiet;

GetOptions(
        'configFile=s'=>\$configFile,
	'quiet'=>\$quiet
);

WebGUI::Session::open("../..",$configFile);



#--------------------------------------------
print "\tMigrating USS submission URLs\n" unless ($quiet);
WebGUI::SQL->write("alter table USS_submission add column pageId char(22) not null");
my $a = WebGUI::SQL->read("select USS.USS_id,wobject.pageId,wobject.wobjectId,wobject.title from USS left join wobject on USS.wobjectId=wobject.wobjectId");
while (my $uss = $a->hashRef) {
	my $b = WebGUI::SQL->read("select USS_submissionId,title from USS_submission where USS_id=".$uss->{USS_id});
	while (my $submission = $b->hashRef) {
		my $parentPage = WebGUI::Page->new($uss->{pageId});
		my %pageVars = %{$parentPage->get};
		delete $pageVars{pageId};
		delete $pageVars{nestedSetLeft};
		delete $pageVars{nestedSetRight};
		delete $pageVars{depth};
		delete $pageVars{parentId};
		delete $pageVars{sequenceNumber};
		$pageVars{hideFromNavigation} = 1;
		$pageVars{title} = $pageVars{menuTitle} = $submission->{title};
		$pageVars{subroutine} = "viewSubmissionAsPage";
		$pageVars{subroutinePackage} = "WebGUI::Wobject::USS";
		$pageVars{subroutineParams} = "{wobjectId=>'".$uss->{wobjectId}."',submissionId=>'".$submission->{USS_submissionId}."'}";
		$pageVars{urlizedTitle} .= "/".$uss->{title}."/".$submission->{title};
		$pageVars{isSystem} = 1;
		my $newPage = $parentPage->add;
		$pageVars{urlizedTitle} = WebGUI::Page::makeUnique(WebGUI::URL::urlize($pageVars{urlizedTitle},$newPage->get("pageId")));
		$newPage->set(\%pageVars);
		WebGUI::SQL->write("update USS_submission set pageId=".quote($newPage->get("pageId"))." where USS_submissionId=".quote($submission->{USS_submissionId}));
	}
	$b->finish;
}
$a->finish;

#--------------------------------------------
print "\tUpdating config file.\n" unless ($quiet);
my $pathToConfig = '../../etc/'.$configFile;
my $conf = Parse::PlainConfig->new('DELIM' => '=', 'FILE' => $pathToConfig);
my $macros = $conf->get("macros");
delete $macros->{"\\"};
$macros->{"\\\\"} = "Backslash_pageUrl";
$macros->{"JavaScript"} = "JavaScript";
$macros->{"StyleSheet"} = "StyleSheet";
$macros->{"RawHeadTags"} = "RawHeadTags";
$conf->set("macros"=>$macros);
$conf->write;


#--------------------------------------------
print "\tMaking page templates faster.\n" unless ($quiet);
use WebGUI::Template;
my $templates = WebGUI::Template::getList("page");
foreach my $templateId (keys %{$templates}) {
	my $template = WebGUI::Template::get($templateId,"page");
	$template->{template} =~ s/\<script language=JavaScript1\.2 src=\"\^Extras\;draggable\.js\"\>\<\/script\>/\^JavaScript\(\"\<tmpl_var session\.config\.extrasURL\>\/draggable.js\"\)\;/;
	WebGUI::Template::set({
		templateId=>$templateId,
		namespace=>"page",
		template=>$template->{template}
		});
}


WebGUI::Session::close();


