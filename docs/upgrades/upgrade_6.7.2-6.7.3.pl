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
setGuidsBinary();
finish();



#-------------------------------------------------
sub setGuidsBinary {
        print "\tSetting GUIDs to have binary flag in database.\n" unless ($quiet);
	my @sql = (
		"alter table asset change assetId assetId varchar(22) binary not null",
		"alter table asset change parentId parentId varchar(22) binary not null",
		"alter table asset change createdBy createdBy varchar(22) binary not null default '3'",
		"alter table asset change stateChangedBy stateChangedBy varchar(22) binary not null default '3'",
		"alter table asset change isLockedBy isLockedBy varchar(22) binary",
		"alter table wobject change assetId assetId varchar(22) binary not null",
		"alter table wobject change printableStyleTemplateId printableStyleTemplateId varchar(22) binary not null",
		"alter table wobject change styleTemplateId styleTemplateId varchar(22) binary not null",
		"alter table users change userId userId varchar(22) binary not null",
		"alter table users change referringAffiliate referringAffiliate varchar(22) binary not null",
		"alter table userSessionScratch change sessionId sessionId varchar(22) binary not null",
		"alter table userSession change sessionId sessionId varchar(22) binary not null",
		"alter table userSession change userId userId varchar(22) binary not null",
		"alter table userLoginLog change userId userId varchar(22) binary not null",
		"alter table userProfileCategory change profileCategoryId profileCategoryId varchar(22) binary not null",
		"alter table userProfileData change userId userId varchar(22) binary not null",
		"alter table userProfileField change profileCategoryId profileCategoryId varchar(22) binary not null",
		"alter table template change assetId assetId varchar(22) binary not null",
		"alter table transaction change transactionId transactionId varchar(22) binary not null",
		"alter table transaction change userId userId varchar(22) binary not null",
		"alter table transactionItem change transactionId transactionId varchar(22) binary not null",
		"alter table subscriptionCode change batchId batchId varchar(22) binary not null",
		"alter table subscriptionCode change code code varchar(64) binary not null",
		"alter table subscriptionCode change usedBy usedBy varchar(22) binary not null",
		"alter table subscriptionCodeBatch change batchId batchId varchar(22) binary not null",
		"alter table subscriptionCodeBatch change subscriptionId subscriptionId varchar(22) binary not null",
		"alter table subscriptionCodeSubscriptions change subscriptionId subscriptionId varchar(22) binary not null",
		"alter table subscriptionCodeSubscriptions change code code varchar(64) binary not null",
		"alter table subscription change subscriptionId subscriptionId varchar(22) binary not null",
		"alter table subscription change subscriptionGroup subscriptionGroup varchar(22) binary not null",
		"alter table snippet change assetId assetId varchar(22) binary not null",
		"alter table shoppingCart change sessionId sessionId varchar(22) binary not null",
		"alter table shoppingCart change itemId itemId varchar(64) binary not null",
		"alter table transactionItem change itemId itemId varchar(64) binary not null",
		"alter table replacements change replacementId replacementId varchar(22) binary not null",
		"alter table redirect change assetId assetId varchar(22) binary not null",
		"alter table products change productId productId varchar(22) binary not null",
		"alter table products change templateId templateId varchar(22) binary not null",
		"alter table productVariants change variantId variantId varchar(22) binary not null",
		"alter table productVariants change productId productId varchar(22) binary not null",
		"alter table passiveProfileAOI change userId userId varchar(22) binary not null",
		"alter table passiveProfileAOI change fieldId fieldId varchar(22) binary not null",
		"alter table passiveProfileLog change passiveProfileLogId passiveProfileLogId varchar(22) binary not null",
		"alter table passiveProfileLog change userId userId varchar(22) binary not null",
		"alter table passiveProfileLog change sessionId sessionId varchar(22) binary not null",
		"alter table passiveProfileLog change wobjectId assetId varchar(22) binary not null",
		"alter table passiveProfileLog change dateOfEntry dateOfEntry bigint not null",
		"alter table productParameterOptions change optionId optionId varchar(22) binary not null",
		"alter table productParameterOptions change parameterId parameterId varchar(22) binary not null",
		"alter table productParameters change parameterId parameterId varchar(22) binary not null",
		"alter table productParameters change productId productId varchar(22) binary not null",
		"alter table metaData_values change fieldId fieldId varchar(22) binary not null",
		"alter table metaData_values change assetId assetId varchar(22) binary not null",
		"alter table metaData_properties change fieldId fieldId varchar(22) binary not null",
		"alter table messageLog change messageLogId messageLogId varchar(22) binary not null",
		"alter table messageLog change userId userId varchar(22) binary not null",
		"alter table ldapLink change ldapLinkId ldapLinkId varchar(22) binary not null",
		"alter table ldapLink change ldapAccountTemplate ldapAccountTemplate varchar(22) binary not null",
		"alter table ldapLink change ldapCreateAccountTemplate ldapCreateAccountTemplate varchar(22) binary not null",
		"alter table ldapLink change ldapLoginTemplate ldapLoginTemplate varchar(22) binary not null",
		"alter table groups change groupId groupId varchar(22) binary not null",
		"alter table groups change databaseLinkId databaseLinkId varchar(22) binary not null",
		"alter table karmaLog change dateModified dateModified bigint not null",
		"alter table karmaLog change userId userId varchar(22) binary not null",
		"alter table databaseLink change databaseLinkId databaseLinkId varchar(22) binary not null",
		"alter table groupGroupings change groupId groupId varchar(22) binary not null",
		"alter table groupGroupings change inGroup inGroup varchar(22) binary not null",
		"alter table groupings change groupId groupId varchar(22) binary not null",
		"alter table groupings change expireDate expireDate bigint not null default 2114402400",
		"alter table groupings change userId userId varchar(22) binary not null",
		"alter table authentication change userId userId varchar(22) binary not null",
		"alter table assetVersionTag change tagId tagId varchar(22) binary not null",
		"alter table assetVersionTag change createdBy createdBy varchar(22) binary not null",
		"alter table assetVersionTag change committedBy committedBy varchar(22) binary not null",
		"alter table assetHistory change assetId assetId varchar(22) binary not null",
		"alter table assetHistory change userId userId varchar(22) binary not null",
		"alter table assetData change assetId assetId varchar(22) binary not null",
		"alter table assetData change revisedBy revisedBy varchar(22) binary not null",
		"alter table assetData change tagId tagId varchar(22) binary not null",
		"alter table assetData change ownerUserId ownerUserId varchar(22) binary not null",
		"alter table assetData change groupIdEdit groupIdEdit varchar(22) binary not null",
		"alter table assetData change groupIdView groupIdView varchar(22) binary not null",
		"alter table Thread change assetId assetId varchar(22) binary not null",
		"alter table Thread change lastPostId lastPostId varchar(22) binary not null",
		"alter table Thread change subscriptionGroupId subscriptionGroupId varchar(22) binary not null",
		"alter table WSClient change assetId assetId varchar(22) binary not null",
		"alter table WSClient change templateId templateId varchar(22) binary not null",
		"alter table SyndicatedContent change assetId assetId varchar(22) binary not null",
		"alter table SyndicatedContent change templateId templateId varchar(22) binary not null",
		"alter table Survey_section change Survey_id Survey_id varchar(22) binary not null",
		"alter table Survey_section change Survey_sectionId Survey_sectionId varchar(22) binary not null",
		"alter table Survey_response change Survey_id Survey_id varchar(22) binary not null",
		"alter table Survey_response change startDate startDate bigint not null",
		"alter table Survey_response change endDate endDate bigint not null",
		"alter table Survey_response change Survey_responseId Survey_responseId varchar(22) binary not null",
		"alter table Survey_question change Survey_id Survey_id varchar(22) binary not null",
		"alter table Survey_question change Survey_questionId Survey_questionId varchar(22) binary not null",
		"alter table Survey_question change Survey_sectionId Survey_sectionId varchar(22) binary not null",
		"alter table Survey_questionResponse change dateOfResponse dateOfResponse bigint not null",
		"alter table Survey_questionResponse change Survey_id Survey_id varchar(22) binary not null",
		"alter table Survey_questionResponse change Survey_questionId Survey_questionId varchar(22) binary not null",
		"alter table Survey_questionResponse change Survey_answerId Survey_answerId varchar(22) binary not null",
		"alter table Survey_questionResponse change Survey_responseId Survey_responseId varchar(22) binary not null",
		"alter table Survey change assetId assetId varchar(22) binary not null",
		"alter table Survey change groupToViewReports groupToViewReports varchar(22) binary not null default '3'",
		"alter table Survey change groupToTakeSurvey groupToTakeSurvey varchar(22) binary not null default '2'",
		"alter table Survey change responseTemplateId responseTemplateId varchar(22) binary not null",
		"alter table Survey change overviewTemplateId overviewTemplateId varchar(22) binary not null",
		"alter table Survey change gradebookTemplateId gradebookTemplateId varchar(22) binary not null",
		"alter table Survey change templateId templateId varchar(22) binary not null",
		"alter table Survey change Survey_id Survey_id varchar(22) binary not null",
		"alter table Survey_answer change Survey_id Survey_id varchar(22) binary not null",
		"alter table Survey_answer change Survey_questionId Survey_questionId varchar(22) binary not null",
		"alter table Survey_answer change Survey_answerId Survey_answerId varchar(22) binary not null",
		"alter table Survey_answer change gotoQuestion gotoQuestion varchar(22) binary not null",
		"alter table RichEdit change assetId assetId varchar(22) binary not null",
		"alter table SQLReport change assetId assetId varchar(22) binary not null",
		"alter table SQLReport change templateId templateId varchar(22) binary not null",
		"alter table SQLReport change databaseLinkId1 databaseLinkId1 varchar(22) binary not null",
		"alter table SQLReport change databaseLinkId2 databaseLinkId2 varchar(22) binary not null",
		"alter table SQLReport change databaseLinkId3 databaseLinkId3 varchar(22) binary not null",
		"alter table SQLReport change databaseLinkId4 databaseLinkId4 varchar(22) binary not null",
		"alter table SQLReport change databaseLinkId5 databaseLinkId5 varchar(22) binary not null",
		"alter table Shortcut change assetId assetId varchar(22) binary not null",
		"alter table Shortcut change templateId templateId varchar(22) binary not null",
		"alter table Shortcut change overrideTemplateId overrideTemplateId varchar(22) binary not null",
		"alter table Shortcut change shortcutToAssetId shortcutToAssetId varchar(22) binary not null",
		"alter table Product_feature change assetId assetId varchar(22) binary not null",
		"alter table Product_feature change Product_featureId Product_featureId varchar(22) binary not null",
		"alter table Product_related change assetId assetId varchar(22) binary not null",
		"alter table Product_related change relatedAssetId relatedAssetId varchar(22) binary not null",
		"alter table Product_specification change Product_specificationId Product_specificationId varchar(22) binary not null",
		"alter table Product_specification change assetId assetId varchar(22) binary not null",
		"alter table Product change assetId assetId varchar(22) binary not null",
		"alter table Product change templateId templateId varchar(22) binary not null",
		"alter table Product_accessory change assetId assetId varchar(22) binary not null",
		"alter table Product_accessory change accessoryAssetId accessoryAssetId varchar(22) binary not null",
		"alter table Product_benefit change assetId assetId varchar(22) binary not null",
		"alter table Product_benefit change Product_benefitId Product_benefitId varchar(22) binary not null",
		"alter table Post change assetId assetId varchar(22) binary not null",
		"alter table Post change threadId threadId varchar(22) binary not null",
		"alter table Post change storageId storageId varchar(22) binary not null",
		"alter table Post_rating change assetId assetId varchar(22) binary not null",
		"alter table Post_rating change userId userId varchar(22) binary not null",
		"alter table Post_read change threadId threadId varchar(22) binary not null",
		"alter table Post_read change userId userId varchar(22) binary not null",
		"alter table Post_read change postId postId varchar(22) binary not null",
		"alter table Poll change assetId assetId varchar(22) binary not null",
		"alter table Poll change templateId templateId varchar(22) binary not null",
		"alter table Poll_answer change assetId assetId varchar(22) binary not null",
		"alter table Poll_answer change userId userId varchar(22) binary not null",
		"alter table Layout change assetId assetId varchar(22) binary not null",
		"alter table Layout change templateId templateId varchar(22) binary not null",
		"alter table MessageBoard change assetId assetId varchar(22) binary not null",
		"alter table MessageBoard change templateId templateId varchar(22) binary not null",
		"alter table Navigation change assetId assetId varchar(22) binary not null",
		"alter table Navigation change templateId templateId varchar(22) binary not null",
		"alter table ITransact_recurringStatus change initDate initDate bigint not null",
		"alter table ITransact_recurringStatus change lastTransaction lastTransaction bigint not null",
		"alter table ImageAsset change assetId assetId varchar(22) binary not null",
		"alter table FileAsset change assetId assetId varchar(22) binary not null",
		"alter table FileAsset change templateId templateId varchar(22) binary not null",
		"alter table FileAsset change storageId storageId varchar(22) binary not null",
		"alter table Folder change assetId assetId varchar(22) binary not null",
		"alter table Folder change templateId templateId varchar(22) binary not null",
		"alter table HttpProxy change assetId assetId varchar(22) binary not null",
		"alter table HttpProxy change templateId templateId varchar(22) binary not null",
		"alter table HttpProxy change cookieJarStorageId cookieJarStorageId varchar(22) binary not null",
		"alter table EventsCalendar change assetId assetId varchar(22) binary not null",
		"alter table EventsCalendar change templateId templateId varchar(22) binary not null",
		"alter table EventsCalendar_event change assetId assetId varchar(22) binary not null",
		"alter table EventsCalendar_event change templateId templateId varchar(22) binary not null",
		"alter table EventsCalendar_event change EventsCalendar_recurringId EventsCalendar_recurringId varchar(22) binary not null",
		"alter table DataForm change assetId assetId varchar(22) binary not null",
		"alter table DataForm change templateId templateId varchar(22) binary not null",
		"alter table DataForm change emailTemplateId emailTemplateId varchar(22) binary not null",
		"alter table DataForm change acknowlegementTemplateId acknowlegementTemplateId varchar(22) binary not null",
		"alter table DataForm change listTemplateId listTemplateId varchar(22) binary not null",
		"alter table DataForm_entry change assetId assetId varchar(22) binary not null",
		"alter table DataForm_entry change DataForm_entryId DataForm_entryId varchar(22) binary not null",
		"alter table DataForm_entry change submissionDate submissionDate bigint not null",
		"alter table DataForm_entry change userId userId varchar(22) binary not null",
		"alter table DataForm_entryData change assetId assetId varchar(22) binary not null",
		"alter table DataForm_entryData change DataForm_entryId DataForm_entryId varchar(22) binary not null",
		"alter table DataForm_entryData change DataForm_fieldId DataForm_fieldId varchar(22) binary not null",
		"alter table DataForm_field change assetId assetId varchar(22) binary not null",
		"alter table DataForm_field change DataForm_tabId DataForm_tabId varchar(22) binary not null",
		"alter table DataForm_field change DataForm_fieldId DataForm_fieldId varchar(22) binary not null",
		"alter table DataForm_tab change assetId assetId varchar(22) binary not null",
		"alter table DataForm_tab change DataForm_tabId DataForm_tabId varchar(22) binary not null",
		"alter table Article change assetId assetId varchar(22) binary not null",
		"alter table Article change templateId templateId varchar(22) binary not null",
		"alter table Collaboration change assetId assetId varchar(22) binary not null",
		"alter table Collaboration change threadTemplateId threadTemplateId varchar(22) binary not null",
		"alter table Collaboration change postGroupId postGroupId varchar(22) binary not null default '2'",
		"alter table Collaboration change moderateGroupId moderateGroupId varchar(22) binary not null default '4'",
		"alter table Collaboration change collaborationTemplateId collaborationTemplateId varchar(22) binary not null",
		"alter table Collaboration change threadTemplateId threadTemplateId varchar(22) binary not null",
		"alter table Collaboration change postFormTemplateId postFormTemplateId varchar(22) binary not null",
		"alter table Collaboration change searchTemplateId searchTemplateId varchar(22) binary not null",
		"alter table Collaboration change notificationTemplateId notificationTemplateId varchar(22) binary not null",
		"alter table Collaboration change lastPostId lastPostId varchar(22) binary",
		"alter table Collaboration change subscriptionGroupId subscriptionGroupId varchar(22) binary",
		"alter table Collaboration change richEditor richEditor varchar(22) binary not null default 'PBrichedit000000000002'"
	);
	foreach my $query (@sql) {
		WebGUI::SQL->write($query);
	}
}

#-------------------------------------------------
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
			print("\t\tUnable to delete $file: $!\n") unless $quiet or $files_deleted or $! eq "No such file or directory";
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

