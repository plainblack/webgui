package WebGUI::Operation;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict qw(vars subs);

=head1 NAME

Package WebGUI::Operation

=head1 DESCRIPTION

This package is provides dynamic loading capabilities for the WebGUI operations.

B<NOTE:>After adding a new operation, the operation / package name must be added to WebGUI::Operation::getOperations.

=head1 SYNOPSIS

 use WebGUI::Operation;
 $html = WebGUI::Operation::execute($session,"switchAdminOn");
 $hashRef = WebGUI::Operation::getOperations();

=head1 METHODS

These functions are available from this package:

=cut

#-------------------------------------------------------------------

=head2 execute ( name )

Loads the corresponding module for operation <name> and executes the operation.
Returns html in most cases.

=head3 name 

The name of the operation to execute.

=cut

sub execute {
	my $session = shift;
	my $op = shift;
	my ($output, $cmd);
	my $operation = getOperations();
	if ($operation->{$op}) {
		# Load the module
		$cmd = 'use '.$operation->{$op};
		eval ($cmd);
		$session->errorHandler->error("Couldn't compile operation: ".$operation->{$op}.". Root cause: ".$@) if ($@);
		# Call the method
		$cmd = $operation->{$op} . '::www_'.$op;
		$output = eval{&{$cmd}($session)};
		$session->errorHandler->error("Couldn't execute operation : ".$cmd.". Root cause: ".$@) if ($@);
	} else {
		$session->errorHandler->security("execute an invalid operation: ".$op);
	}
	return $output;
}

#-------------------------------------------------------------------

=head2 getOperations ( )

Returns a hash reference containing operation and package names.

=cut

sub getOperations {
	return {
		'killSession' => 'WebGUI::Operation::ActiveSessions',
		'viewActiveSessions' => 'WebGUI::Operation::ActiveSessions',

		'adminConsole' => 'WebGUI::Operation::Admin',
		'switchOffAdmin' => 'WebGUI::Operation::Admin',
		'switchOnAdmin' => 'WebGUI::Operation::Admin',

		'clickAd' => 'WebGUI::Operation::AdSpace',
		'deleteAd' => 'WebGUI::Operation::AdSpace',
		'deleteAdSpace' => 'WebGUI::Operation::AdSpace',
		'editAd' => 'WebGUI::Operation::AdSpace',
		'editAdSave' => 'WebGUI::Operation::AdSpace',
		'editAdSpace' => 'WebGUI::Operation::AdSpace',
		'editAdSpaceSave' => 'WebGUI::Operation::AdSpace',
		'manageAdSpaces' => 'WebGUI::Operation::AdSpace',

		'auth' => 'WebGUI::Operation::Auth',

		'flushCache' => 'WebGUI::Operation::Cache',
		'manageCache' => 'WebGUI::Operation::Cache',

		'addToCart' => 'WebGUI::Operation::Commerce',
		'cancelTransaction' => 'WebGUI::Operation::Commerce',
		'checkout' => 'WebGUI::Operation::Commerce',
		'checkoutConfirm' => 'WebGUI::Operation::Commerce',
		'checkoutSubmit' => 'WebGUI::Operation::Commerce',
		'completePendingTransaction' => 'WebGUI::Operation::Commerce',
		'confirmRecurringTransaction' => 'WebGUI::Operation::Commerce',
		'deleteCartItem' => 'WebGUI::Operation::Commerce',
		'editCommerceSettings' => 'WebGUI::Operation::Commerce',
		'editCommerceSettingsSave' => 'WebGUI::Operation::Commerce',
		'listTransactions' => 'WebGUI::Operation::Commerce',
		'selectPaymentGateway' => 'WebGUI::Operation::Commerce',
		'selectPaymentGatewaySave' => 'WebGUI::Operation::Commerce',
		'selectShippingMethod' => 'WebGUI::Operation::Commerce',
		'selectShippingMethodSave' => 'WebGUI::Operation::Commerce',
		'updateCart' => 'WebGUI::Operation::Commerce',
		'viewCart' => 'WebGUI::Operation::Commerce',

		'editCronJob' => 'WebGUI::Operation::Cron',
		'editCronJobSave' => 'WebGUI::Operation::Cron',
		'deleteCronJob' => 'WebGUI::Operation::Cron',
		'manageCron' => 'WebGUI::Operation::Cron',
		'runCronJob' => 'WebGUI::Operation::Cron',

		'copyDatabaseLink' => 'WebGUI::Operation::DatabaseLink',
		'deleteDatabaseLink' => 'WebGUI::Operation::DatabaseLink',
		'deleteDatabaseLinkConfirm' => 'WebGUI::Operation::DatabaseLink',
		'editDatabaseLink' => 'WebGUI::Operation::DatabaseLink',
		'editDatabaseLinkSave' => 'WebGUI::Operation::DatabaseLink',
		'listDatabaseLinks' => 'WebGUI::Operation::DatabaseLink',

		'formAssetTree' => 'WebGUI::Operation::FormHelpers',
		'richEditAddFolder' => 'WebGUI::Operation::FormHelpers',
		'richEditAddFolderSave' => 'WebGUI::Operation::FormHelpers',
		'richEditAddImage' => 'WebGUI::Operation::FormHelpers',
		'richEditAddImageSave' => 'WebGUI::Operation::FormHelpers',
		'richEditImageTree' => 'WebGUI::Operation::FormHelpers',
		'richEditPageTree' => 'WebGUI::Operation::FormHelpers',
		'richEditViewThumbnail' => 'WebGUI::Operation::FormHelpers',
		'salesTaxTable' => 'WebGUI::Operation::FormHelpers',

		'addGroupsToGroupSave' => 'WebGUI::Operation::Group',
		'addUsersToGroupSave' => 'WebGUI::Operation::Group',
		'autoAddToGroup' => 'WebGUI::Operation::Group',
		'autoDeleteFromGroup' => 'WebGUI::Operation::Group',
		'deleteGroup' => 'WebGUI::Operation::Group',
		'deleteGroupGrouping' => 'WebGUI::Operation::Group',
		'deleteGrouping' => 'WebGUI::Operation::Group',
		'editGroup' => 'WebGUI::Operation::Group',
		'editGroupSave' => 'WebGUI::Operation::Group',
		'editGrouping' => 'WebGUI::Operation::Group',
		'editGroupingSave' => 'WebGUI::Operation::Group',
		'emailGroup' => 'WebGUI::Operation::Group',
		'emailGroupSend' => 'WebGUI::Operation::Group',
		'listGroups' => 'WebGUI::Operation::Group',
		'manageGroupsInGroup' => 'WebGUI::Operation::Group',
		'manageUsersInGroup' => 'WebGUI::Operation::Group',

		'viewHelp' => 'WebGUI::Operation::Help',
		'viewHelpChapter' => 'WebGUI::Operation::Help',
		'viewHelpIndex' => 'WebGUI::Operation::Help',
		'viewHelpTOC' => 'WebGUI::Operation::Help',

		'viewInbox' => 'WebGUI::Operation::Inbox',
		'viewInboxMessage' => 'WebGUI::Operation::Inbox',

		'copyLDAPLink' => 'WebGUI::Operation::LDAPLink',
		'deleteLDAPLink' => 'WebGUI::Operation::LDAPLink',
		'editLDAPLink' => 'WebGUI::Operation::LDAPLink',
		'editLDAPLinkSave' => 'WebGUI::Operation::LDAPLink',
		'listLDAPLinks' => 'WebGUI::Operation::LDAPLink',

		'viewLoginHistory' => 'WebGUI::Operation::LoginHistory',

		'deleteProduct' => 'WebGUI::Operation::ProductManager',
		'deleteProductParameter' => 'WebGUI::Operation::ProductManager',
		'deleteProductParameterOption' => 'WebGUI::Operation::ProductManager',
		'editProduct' => 'WebGUI::Operation::ProductManager',
		'editProductParameter' => 'WebGUI::Operation::ProductManager',
		'editProductParameterSave' => 'WebGUI::Operation::ProductManager',
		'editProductParameterOption' => 'WebGUI::Operation::ProductManager',
		'editProductParameterOptionSave' => 'WebGUI::Operation::ProductManager',
		'editProductSave' => 'WebGUI::Operation::ProductManager',
		'editProductVariant' => 'WebGUI::Operation::ProductManager',
		'editProductVariantSave' => 'WebGUI::Operation::ProductManager',
		'editSkuTemplate' => 'WebGUI::Operation::ProductManager',
		'editSkuTemplateSave' => 'WebGUI::Operation::ProductManager',
		'listProducts' => 'WebGUI::Operation::ProductManager',
		'listProductVariants' => 'WebGUI::Operation::ProductManager',
		'listProductVariantsSave' => 'WebGUI::Operation::ProductManager',
		'manageProduct' => 'WebGUI::Operation::ProductManager',

		'editProfile' => 'WebGUI::Operation::Profile',
		'editProfileSave' => 'WebGUI::Operation::Profile',
		'viewProfile' => 'WebGUI::Operation::Profile',

		'deleteProfileCategory' => 'WebGUI::Operation::ProfileSettings',
		'deleteProfileCategoryConfirm' => 'WebGUI::Operation::ProfileSettings',
		'deleteProfileField' => 'WebGUI::Operation::ProfileSettings',
		'deleteProfileFieldConfirm' => 'WebGUI::Operation::ProfileSettings',
		'editProfileCategory' => 'WebGUI::Operation::ProfileSettings',
		'editProfileCategorySave' => 'WebGUI::Operation::ProfileSettings',
		'editProfileField' => 'WebGUI::Operation::ProfileSettings',
		'editProfileFieldSave' => 'WebGUI::Operation::ProfileSettings',
		'editProfileSettings' => 'WebGUI::Operation::ProfileSettings',
		'moveProfileCategoryDown' => 'WebGUI::Operation::ProfileSettings',
		'moveProfileCategoryUp' => 'WebGUI::Operation::ProfileSettings',
		'moveProfileFieldDown' => 'WebGUI::Operation::ProfileSettings',
		'moveProfileFieldUp' => 'WebGUI::Operation::ProfileSettings',

		'deleteReplacement' => 'WebGUI::Operation::Replacements',
		'editReplacement' => 'WebGUI::Operation::Replacements',
		'editReplacementSave' => 'WebGUI::Operation::Replacements',
		'listReplacements' => 'WebGUI::Operation::Replacements',

		'deleteScratch' => 'WebGUI::Operation::Scratch',
		'setScratch' => 'WebGUI::Operation::Scratch',

		'editSettings' => 'WebGUI::Operation::Settings',
		'saveSettings' => 'WebGUI::Operation::Settings',

		'spectreTest' => 'WebGUI::Operation::Spectre',

		'viewStatistics' => 'WebGUI::Operation::Statistics',

		'makePrintable' => 'WebGUI::Operation::Style',
		'setPersonalStyle' => 'WebGUI::Operation::Style',
		'unsetPersonalStyle' => 'WebGUI::Operation::Style',

		'createSubscriptionCodeBatch' => 'WebGUI::Operation::Subscription',
		'createSubscriptionCodeBatchSave' => 'WebGUI::Operation::Subscription',
		'deleteSubscription' => 'WebGUI::Operation::Subscription',
		'deleteSubscriptionCodeBatch' => 'WebGUI::Operation::Subscription',
		'deleteSubscriptionCodes' => 'WebGUI::Operation::Subscription',
		'editSubscription' => 'WebGUI::Operation::Subscription',
		'editSubscriptionSave' => 'WebGUI::Operation::Subscription',
		'listSubscriptionCodeBatches' => 'WebGUI::Operation::Subscription',
		'listSubscriptionCodes' => 'WebGUI::Operation::Subscription',
		'listSubscriptions' => 'WebGUI::Operation::Subscription',
		'purchaseSubscription' => 'WebGUI::Operation::Subscription',
		'redeemSubscriptionCode' => 'WebGUI::Operation::Subscription',

		'cancelRecurringTransaction' => 'WebGUI::Operation::TransactionLog',
		'deleteTransaction' => 'WebGUI::Operation::TransactionLog',
		'deleteTransactionItem' => 'WebGUI::Operation::TransactionLog',
		'viewPurchaseHistory' => 'WebGUI::Operation::TransactionLog',

		'becomeUser' => 'WebGUI::Operation::User',
		'deleteUser' => 'WebGUI::Operation::User',
		'editUser' => 'WebGUI::Operation::User',
		'editUserSave' => 'WebGUI::Operation::User',
		'editUserKarma' => 'WebGUI::Operation::User',
		'editUserKarmaSave' => 'WebGUI::Operation::User',
		'formUsers' => 'WebGUI::Operation::User',
		'listUsers' => 'WebGUI::Operation::User',

		'approveVersionTag' => 'WebGUI::Operation::VersionTag',
		'commitVersionTag' => 'WebGUI::Operation::VersionTag',
		'commitVersionTagConfirm' => 'WebGUI::Operation::VersionTag',
		'editVersionTag' => 'WebGUI::Operation::VersionTag',
		'editVersionTagSave' => 'WebGUI::Operation::VersionTag',
		'manageCommittedVersions' => 'WebGUI::Operation::VersionTag',
		'managePendingVersions' => 'WebGUI::Operation::VersionTag',
		'manageRevisionsInTag' => 'WebGUI::Operation::VersionTag',
		'manageVersions' => 'WebGUI::Operation::VersionTag',
		'rollbackVersionTag' => 'WebGUI::Operation::VersionTag',
		'setWorkingVersionTag' => 'WebGUI::Operation::VersionTag',

		'genesis' => 'WebGUI::Operation::WebGUI',
		'theWg' => 'WebGUI::Operation::WebGUI',

		'addWorkflow' => 'WebGUI::Operation::Workflow',
		'addWorkflowSave' => 'WebGUI::Operation::Workflow',
		'deleteWorkflow' => 'WebGUI::Operation::Workflow',
		'deleteWorkflowActivity' => 'WebGUI::Operation::Workflow',
		'demoteWorkflowActivity' => 'WebGUI::Operation::Workflow',
		'editWorkflow' => 'WebGUI::Operation::Workflow',
		'editWorkflowSave' => 'WebGUI::Operation::Workflow',
		'editWorkflowActivity' => 'WebGUI::Operation::Workflow',
		'editWorkflowActivitySave' => 'WebGUI::Operation::Workflow',
		'manageWorkflows' => 'WebGUI::Operation::Workflow',
		'promoteWorkflowActivity' => 'WebGUI::Operation::Workflow',
		'runWorkflow' => 'WebGUI::Operation::Workflow',
		'showRunningWorkflows' => 'WebGUI::Operation::Workflow',

		'addColorToPalette' => 'WebGUI::Operation::Graphics',
		'addColorToPaletteSave' => 'WebGUI::Operation::Graphics',
		'deleteFont' => 'WebGUI::Operation::Graphics',
		'deletePalette' => 'WebGUI::Operation::Graphics',
		'editColor' => 'WebGUI::Operation::Graphics',
		'editColorSave' => 'WebGUI::Operation::Graphics',
		'editFont' => 'WebGUI::Operation::Graphics',
		'editFontSave' => 'WebGUI::Operation::Graphics',
		'editPalette' => 'WebGUI::Operation::Graphics',
		'editPaletteSave' => 'WebGUI::Operation::Graphics',
		'listGraphicsOptions' => 'WebGUI::Operation::Graphics',
		'listFonts' => 'WebGUI::Operation::Graphics',
		'listPalettes' => 'WebGUI::Operation::Graphics',
		'moveColorDown' => 'WebGUI::Operation::Graphics',
		'moveColorUp' => 'WebGUI::Operation::Graphics',
		'removeColorFromPalette' => 'WebGUI::Operation::Graphics',

		'spellCheck' => 'WebGUI::Operation::SpellCheck',
		'suggestWords' => 'WebGUI::Operation::SpellCheck',
		'addWordToDictionary' => 'WebGUI::Operation::SpellCheck',
	};
}

1;
