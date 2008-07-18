package WebGUI::Help::Asset_EventManagementSystem;    ## Be sure to change the package name to match your filename.
use strict;

##Stub document for creating help documents.

our $HELP = {

    'event management system main template' => {
        source    => 'sub view',
        title     => 'main template help title',
        body      => 'main template help body',
        variables => [
            { 'name' => 'addBadgeUrl',          required => 1 },
            { 'name' => 'buildBadgeUrl',        required => 1 },
            { 'name' => 'manageBadgeGroupsUrl', required => 1  },
            { 'name' => 'getBadgesUrl',         required => 1  },
            { 'name' => 'canEdit' },
            { 'name' => 'lookupRegistrantUrl',  required => 1  },
        ],
        isa   => [
            {   namespace => "Asset_EventManagementSystem",
                tag       => "ems asset template variables"
            },
            {   namespace => "Asset_Template",
                tag       => "template variables"
            },
            {   namespace => "Asset_Wobject",
                tag       => "wobject template variables"
            },
        ],
        fields  => [],
        related => [],
    },

    'ems badge builder template' => {
        source    => 'sub www_buildBadge',
        title     => 'badge builder template',
        body      => '',
        variables => [
            { 'name' => 'addTicketUrl'},
            { 'name' => 'addRibbonUrl'},
            { 'name' => 'addTokenUrl'},
            { 'name' => 'importTicketsUrl'},
            { 'name' => 'exportTicketsUrl'},
            { 'name' => 'canEdit'},
            { 'name' => 'hasBadge'},
            { 'name' => 'badgeId'},
            { 'name' => 'getTicketsUrl', required => 1,},
            { 'name' => 'getRibbonsUrl', required => 1,},
            { 'name' => 'whichTab',      required => 1,},
            { 'name' => 'getTokensUrl',  required => 1,},
            { 'name' => 'whichTab',      required => 1,},
            {
                name        => 'lookupBadgeUrl',
                description => 'lookupRegistrantUrl',
            },
            { 'name' => 'url',      required => 1,},
            { 'name' => 'viewCartUrl'},
            { 'name' => 'customRequestUrl',      required => 1,},
            { 'name' => 'manageEventMetaFieldsUrl'},
            { 'name' => 'otherBadgesInCart',
              'variables' => [
                { 'name' => 'badgeUrl'},
                { 'name' => 'badgeLabel'},
              ],
            },
        ],
        isa   => [
            {   namespace => "Asset_EventManagementSystem",
                tag       => "ems asset template variables"
            },
            {   namespace => "Asset_Template",
                tag       => "template variables"
            },
            {   namespace => "Asset_Wobject",
                tag       => "wobject template variables"
            },
        ],
        fields  => [],
        related => [],
    },

    'ems lookup registrant template' => {
        source    => 'sub www_lookupRegistrant',
        title     => 'lookup registrant template',
        body      => '',
        variables => [
            { 'name' => 'buyBadgeUrl'},
            { 'name' => 'viewEventsUrl'},
            { 'name' => 'viewCartUrl'},
            { 'name' => 'getRegistrantsUrl', required => 1},
            { 'name' => 'isRegistrationStaff'},
        ],
        isa   => [
            {   namespace => "Asset_Template",
                tag       => "template variables"
            },
        ],
        fields  => [],
        related => [],
    },

    'ems print badge template' => {
        source    => 'sub www_printBadge',
        title     => 'print badge template',
        body      => '',
        variables => [
            { 'name' => 'badgeTitle'},
            { 'name' => 'badgeId'},
            { 'name' => 'badgeNumber'},
            { 'name' => 'badgeAssetId'},
            { 'name' => 'emsAssetId'},
            { 'name' => 'userId'},
            { 'name' => 'name'},
            { 'name' => 'address1'},
            { 'name' => 'address2'},
            { 'name' => 'address3'},
            { 'name' => 'city'},
            { 'name' => 'state'},
            { 'name' => 'zipcode'},
            { 'name' => 'country'},
            { 'name' => 'phoneNumber'},
            { 'name' => 'organization'},
            { 'name' => 'email'},
            { 'name' => 'notes'},
            { 'name' => 'purchaseComplete'},
            { 'name' => 'hasCheckedIn'},
            { 'name' => 'transactionItemId'},
        ],
        isa   => [
            {   namespace => "Asset_Template",
                tag       => "template variables"
            },
        ],
        fields  => [],
        related => [],
    },

    'ems print ticket template' => {
        source    => 'sub www_printTicket',
        title     => 'print ticket template',
        body      => '',
        variables => [
            { 'name' => 'ticketTitle'},
            { 'name' => 'ticketStart'},
            { 'name' => 'ticketDuration'},
            { 'name' => 'ticketLocation'},
            { 'name' => 'ticketEventNumber'},
            { 'name' => 'badgeId'},
            { 'name' => 'badgeNumber'},
            { 'name' => 'badgeAssetId'},
            { 'name' => 'emsAssetId'},
            { 'name' => 'userId'},
            { 'name' => 'name'},
            { 'name' => 'address1'},
            { 'name' => 'address2'},
            { 'name' => 'address3'},
            { 'name' => 'city'},
            { 'name' => 'state'},
            { 'name' => 'zipcode'},
            { 'name' => 'country'},
            { 'name' => 'phoneNumber'},
            { 'name' => 'organization'},
            { 'name' => 'email'},
            { 'name' => 'notes'},
            { 'name' => 'purchaseComplete'},
            { 'name' => 'hasCheckedIn'},
            { 'name' => 'transactionItemId'},
        ],
        isa   => [
            {   namespace => "Asset_Template",
                tag       => "template variables"
            },
        ],
        fields  => [],
        related => [],
    },

    'ems asset template variables' => {
        source    => 'sub definition',
        title     => 'ems asset template variables',
        body      => '',
        variables => [
            {
                name        => 'timezone',
                description => 'timezone help',
            },
            {
                name        => 'templateId',
                description => 'templateId help',
            },
            {
                name        => 'badgeBuilderTemplateId',
                description => 'badgeBuilderTemplateId help',
            },
            {
                name        => 'lookupRegistrantTemplateId',
                description => 'lookupRegistrantTemplateId help',
            },
            {
                name        => 'printBadgeTemplateId',
                description => 'printBadgeTemplateId help',
            },
            {
                name        => 'printTicketTemplateId',
                description => 'printTicketTemplateId help',
            },
            {
                name        => 'badgeInstructions',
                description => 'badgeInstructions help',
            },
            {
                name        => 'ticketInstructions',
                description => 'ticketInstructions help',
            },
            {
                name        => 'ribbonInstructions',
                description => 'ribbonInstructions help',
            },
            {
                name        => 'tokenInstructions',
                description => 'tokenInstructions help',
            },
            {
                name        => 'registrationStaffGroupId',
                description => 'registrationStaffGroupId help',
            },
        ],
        fields  => [],
        related => [],
    },

};

1;    ##All perl modules must return true
