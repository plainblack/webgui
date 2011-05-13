package WebGUI::Operation;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::Pluggable;

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
        $output = eval { WebGUI::Pluggable::run("WebGUI::Operation::".$operation->{$op}, 'www_'.$op, [ $session ] ) };
        if ( $@ ) {
            die $@ if ($@ =~ "^fatal:");
            $session->log->error($@);
            return undef;
        }
	} else {
		$session->log->security("execute an invalid operation: ".$op);
	}
	return $output;
}

#-------------------------------------------------------------------

=head2 getOperations ( )

Returns a hash reference containing operation and package names.

=cut

sub getOperations {
	return {
		'fork' => 'Fork',
		'killSession' => 'ActiveSessions',
		'viewActiveSessions' => 'ActiveSessions',

		'adminConsole' => 'Admin',
		'switchOffAdmin' => 'Admin',
		'switchOnAdmin' => 'Admin',

		'clickAd' => 'AdSpace',
		'deleteAd' => 'AdSpace',
		'deleteAdSpace' => 'AdSpace',
		'editAd' => 'AdSpace',
		'editAdSave' => 'AdSpace',
		'editAdSpace' => 'AdSpace',
		'editAdSpaceSave' => 'AdSpace',
		'manageAdSpaces' => 'AdSpace',

		'auth' => 'Auth',

		'flushCache' => 'Cache',
		'manageCache' => 'Cache',

		'editCronJob' => 'Cron',
		'editCronJobSave' => 'Cron',
		'deleteCronJob' => 'Cron',
		'manageCron' => 'Cron',
		'runCronJob' => 'Cron',

		'copyDatabaseLink' => 'DatabaseLink',
		'deleteDatabaseLink' => 'DatabaseLink',
		'deleteDatabaseLinkConfirm' => 'DatabaseLink',
		'editDatabaseLink' => 'DatabaseLink',
		'editDatabaseLinkSave' => 'DatabaseLink',
		'listDatabaseLinks' => 'DatabaseLink',

		'formHelper' => 'FormHelpers',
		'activityHelper' => 'Workflow',

		'addGroupsToGroupSave' => 'Group',
		'addUsersToGroupSave' => 'Group',
		'autoAddToGroup' => 'Group',
		'autoDeleteFromGroup' => 'Group',
		'deleteGroup' => 'Group',
		'deleteGroupGrouping' => 'Group',
		'deleteGrouping' => 'Group',
		'editGroup' => 'Group',
		'editGroupSave' => 'Group',
		'editGrouping' => 'Group',
		'editGroupingSave' => 'Group',
		'emailGroup' => 'Group',
		'emailGroupSend' => 'Group',
		'listGroups' => 'Group',
		'manageGroupsInGroup' => 'Group',
		'manageUsersInGroup' => 'Group',
		'manageGroups' => 'Group',
		'updateGroupUsers' => 'Group',

		'viewHelp' => 'Help',
		'viewHelpIndex' => 'Help',

		'viewInbox' => 'Inbox',
		'viewInboxMessage' => 'Inbox',
        'sendPrivateMessage' => 'Inbox',

		'inviteUser'       => 'Invite',
		'acceptInvite'     => 'Invite',

		'addFriend'      => 'Friends',
		'friendRequest'     => 'Friends',
		'manageFriends'     => 'Friends',

		'copyLDAPLink' => 'LDAPLink',
		'deleteLDAPLink' => 'LDAPLink',
		'editLDAPLink' => 'LDAPLink',
		'editLDAPLinkSave' => 'LDAPLink',
		'listLDAPLinks' => 'LDAPLink',

		'viewLoginHistory' => 'LoginHistory',

		'editProfile' => 'Profile',
		'viewProfile' => 'Profile',

		'deleteProfileCategory' => 'ProfileSettings',
		'deleteProfileCategoryConfirm' => 'ProfileSettings',
		'deleteProfileField' => 'ProfileSettings',
		'deleteProfileFieldConfirm' => 'ProfileSettings',
		'editProfileCategory' => 'ProfileSettings',
		'editProfileCategorySave' => 'ProfileSettings',
		'editProfileField' => 'ProfileSettings',
		'editProfileFieldSave' => 'ProfileSettings',
		'editProfileSettings' => 'ProfileSettings',
		'moveProfileCategoryDown' => 'ProfileSettings',
		'moveProfileCategoryUp' => 'ProfileSettings',
		'moveProfileFieldDown' => 'ProfileSettings',
		'moveProfileFieldUp' => 'ProfileSettings',

		'deleteReplacement' => 'Replacements',
		'editReplacement' => 'Replacements',
		'editReplacementSave' => 'Replacements',
		'listReplacements' => 'Replacements',

		'deleteScratch' => 'Scratch',
		'setScratch' => 'Scratch',

		'editSettings' => 'Settings',
		'saveSettings' => 'Settings',

		'spectreGetSiteData' => 'Spectre',
		'spectreTest' => 'Spectre',
		'spectreStatus' => 'Spectre',

        'ssoViaSessionId' => 'SSO',

		'disableSendWebguiStats' => 'Statistics',
		'enableSendWebguiStats' => 'Statistics',
		'viewStatistics' => 'Statistics',

		'makePrintable' => 'Style',
		'setPersonalStyle' => 'Style',
		'unsetPersonalStyle' => 'Style',

        'ajaxCreateUser' => 'User',
        'ajaxDeleteUser' => 'User',
        'ajaxUpdateUser' => 'User',
		'becomeUser' => 'User',
		'deleteUser' => 'User',
		'editUser' => 'User',
		'editUserSave' => 'User',
		'editUserKarma' => 'User',
		'editUserKarmaSave' => 'User',
		'formUsers' => 'User',
		'listUsers' => 'User',

		'approveVersionTag' => 'VersionTag',
		'commitVersionTag' => 'VersionTag',
		'commitVersionTagConfirm' => 'VersionTag',
		'editVersionTag' => 'VersionTag',
		'editVersionTagSave' => 'VersionTag',
		'leaveVersionTag' => 'VersionTag',
		'manageCommittedVersions' => 'VersionTag',
		'managePendingVersions' => 'VersionTag',
		'manageRevisionsInTag' => 'VersionTag',
		'manageVersions' => 'VersionTag',
		'rollbackVersionTag' => 'VersionTag',
		'setWorkingVersionTag' => 'VersionTag',

		'genesis' => 'WebGUI',
		'theWg' => 'WebGUI',

		'addWorkflow' => 'Workflow',
		'addWorkflowSave' => 'Workflow',
		'deleteWorkflow' => 'Workflow',
		'deleteWorkflowActivity' => 'Workflow',
		'demoteWorkflowActivity' => 'Workflow',
		'editWorkflow' => 'Workflow',
		'editWorkflowSave' => 'Workflow',
		'editWorkflowActivity' => 'Workflow',
		'editWorkflowActivitySave' => 'Workflow',
		'manageWorkflows' => 'Workflow',
		'promoteWorkflowActivity' => 'Workflow',
		'runWorkflow' => 'Workflow',
		'showRunningWorkflows' => 'Workflow',

		'addColorToPalette' => 'Graphics',
		'addColorToPaletteSave' => 'Graphics',
		'deleteFont' => 'Graphics',
		'deletePalette' => 'Graphics',
		'editColor' => 'Graphics',
		'editColorSave' => 'Graphics',
		'editFont' => 'Graphics',
		'editFontSave' => 'Graphics',
		'editPalette' => 'Graphics',
		'editPaletteSave' => 'Graphics',
		'listGraphicsOptions' => 'Graphics',
		'listFonts' => 'Graphics',
		'listPalettes' => 'Graphics',
		'moveColorDown' => 'Graphics',
		'moveColorUp' => 'Graphics',
		'removeColorFromPalette' => 'Graphics',

		'spellCheck' => 'SpellCheck',
		'suggestWords' => 'SpellCheck',
		'addWordToDictionary' => 'SpellCheck',
	};
}

1;
