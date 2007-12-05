package WebGUI::Help::Asset_EventManagementSystem;    ## Be sure to change the package name to match your filename.
use strict;

##Stub document for creating help documents.

our $HELP = {
    'event management system template' => {
        source    => 'sub view',
        title     => 'template help title',
        body      => '',
        variables => [
            { 'name' => 'checkout.url' },
            { 'name' => 'checkout.label' },
            {   'name'      => 'events_loop',
                'variables' => [
                    {   'name'        => 'event',
                        'description' => 'tmplVar event'
                    }
                ]
            },
            { 'name' => 'paginateBar' },
            { 'name' => 'Pagination variables' },
            { 'name' => 'canManageEvents' },
            { 'name' => 'manageEvents.url' },
            { 'name' => 'manageEvents.label' },
            { 'name' => 'managePurchases.url' },
            { 'name' => 'managePurchases.label' }
        ],
        fields  => [],
        related => [
            {   tag       => 'pagination template variables',
                namespace => 'WebGUI',
            },
        ],
    },

    'event management system event template' => {
        source    => 'sub www_editEvent',
        title     => 'event template help title',
        body      => '',
        variables => [
            { 'name' => 'title' },
            { 'name' => 'title.url' },
            { 'name' => 'description' },
            { 'name' => 'image' },
            {   'name'        => 'price',
                'description' => 'tmplVar price'
            },
            {   'name'        => 'sku',
                'description' => 'tmplVar sku'
            },
            {   'name'        => 'sku template',
                'description' => 'tmplVar sku template'
            },
            {   'name'        => 'weight',
                'description' => 'tmplVar weight'
            },
            { 'name' => 'numberRegistered' },
            { 'name' => 'maximumAttendees' },
            { 'name' => 'seatsRemaining' },
            { 'name' => 'eventIsFull' },
            { 'name' => 'eventIsApproved' },
            { 'name' => 'startDate.human' },
            { 'name' => 'endDate.human' },
            { 'name' => 'purchase.label' },
            { 'name' => 'purchase.url' },
            { 'name' => 'purchase.message' },
            { 'name' => 'purchase.wantToSearch.url' },
            { 'name' => 'purchase.wantToContinue.url' },
            { 'name' => 'purchase.label' }
        ],
        fields  => [],
        related => [
            {   tag       => 'event management system template',
                namespace => 'Asset_EventManagementSystem',
            },
        ],
    },

    'ems manage purchases template' => {
        source    => 'sub www_managePurchases',
        title     => 'manage purchases template help title',
        body      => '',
        variables => [
            {   'name'      => 'purchasesLoop',
                'variables' => [ { 'name' => 'purchaseUrl' }, { 'name' => 'datePurchasedHuman' } ]
            },
            { 'name' => 'managePurchasesTitle' }
        ],
        fields  => [],
        related => [],
    },

    'ems checkout template' => {
        source    => 'sub getRegistrationInfo',
        title     => 'checkout template help title',
        body      => '',
        variables => [
            {   'name'        => 'isError',
                'description' => 'tmplVar isError',
            },
            {   'name'        => 'errorLoop',
                'description' => 'tmplLoop errorLoop',
                'variables'   => [
                    {   'name'        => 'error',
                        'description' => 'tmplVar error'
                    },
                ]
            },
        ],
        fields  => [],
        related => [],
    },

    'ems view purchase template' => {
        source    => 'sub www_viewPurchases',
        title     => 'view purchase template help title',
        body      => '',
        variables => [
            {   'name'      => 'purchasesLoop',
                'variables' => [
                    {   'name'      => 'regLoop',
                        'variables' => [
                            { 'name' => 'startDateHuman' },
                            { 'name' => 'startDateHuman' },
                            { 'name' => 'endDateHuman' },
                            { 'name' => 'startDate' },
                            { 'name' => 'endDateHuman' },
                            { 'name' => 'registrationId' },
                            { 'name' => 'title', },
                            { 'name' => 'description', },
                            {   'name'        => 'price',
                                'description' => 'tmplVar price'
                            },
                            { 'name' => 'templateId' },
                            { 'name' => 'returned' },
                            {   'name'        => 'approved',
                                'description' => 'tmplVar approved'
                            },
                            { 'name' => 'templateId' },
                            { 'name' => 'maximumAttendees', },
                            { 'name' => 'userId' },
                            { 'name' => 'createdByUserId' }
                        ]
                    },
                    { 'name' => 'canReturnItinerary' },
                    { 'name' => 'canAddEvents' }
                ]
            },
            { 'name' => 'canReturnTransaction' },
            { 'name' => 'viewPurchaseTitle' },
            { 'name' => 'canReturn' },
            { 'name' => 'transactionId' },
            { 'name' => 'appUrl' }
        ],
        fields  => [],
        related => [],
    },

    'ems search template' => {
        source    => 'sub www_search',
        title     => 'search template help title',
        body      => '',
        variables => [
            { 'name' => 'calendarJS' },
            { 'name' => 'basicSearch.formHeader' },
            { 'name' => 'advSearch.formHeader' },
            { 'name' => 'isAdvSearch' },
            { 'name' => 'search.formFooter' },
            { 'name' => 'search.formSubmit' },
            {   'name'      => 'events_loop',
                'variables' => [
                    { 'name' => 'event', },
                    { 'name' => 'title', },
                    { 'name' => 'description', },
                    {   'name'        => 'price',
                        'description' => 'tmplVar price'
                    },
                    {   'name'        => 'sku',
                        'description' => 'tmplVar sku'
                    },
                    {   'name'        => 'sku template',
                        'description' => 'tmplVar sku template'
                    },
                    {   'name'        => 'weight',
                        'description' => 'tmplVar weight'
                    },
                    { 'name' => 'numberRegistered', },
                    { 'name' => 'maximumAttendees', },
                    { 'name' => 'seatsRemaining', },
                    { 'name' => 'startDate.human', },
                    { 'name' => 'startDate', },
                    { 'name' => 'endDate.human', },
                    { 'name' => 'endDate' },
                    { 'name' => 'productId' },
                    { 'name' => 'eventIsFull', },
                    { 'name' => 'eventIsApproved', },
                    { 'name' => 'manageToolbar' },
                    { 'name' => 'purchase.label', },
                    { 'name' => 'purchase.url', }
                ],
            },
            { 'name' => 'paginateBar', },
            { 'name' => 'manageEvents.url', },
            { 'name' => 'manageEvents.label', },
            { 'name' => 'managePurchases.url', },
            { 'name' => 'managePurchases.label', },
            { 'name' => 'noSearchDialog' },
            { 'name' => 'addEvent.url' },
            { 'name' => 'addEvent.label' },
            { 'name' => 'canManageEvents', },
            { 'name' => 'message' },
            { 'name' => 'numberOfSearchResults' },
            { 'name' => 'continue.url' },
            { 'name' => 'continue.label' },
            { 'name' => 'name.label' },
            { 'name' => 'starts.label' },
            { 'name' => 'ends.label' },
            { 'name' => 'price.label' },
            { 'name' => 'seats.label' },
            { 'name' => 'addToBadgeMessage' },
            { 'name' => 'search.filters.options' },
            { 'name' => 'search.data.url' },
            { 'name' => 'ems.wobject.dir' }
        ],
        fields  => [],
        related => [
            {   tag       => 'pagination template variables',
                namespace => 'WebGUI',
            },
        ],
    },

};

1;    ##All perl modules must return true
