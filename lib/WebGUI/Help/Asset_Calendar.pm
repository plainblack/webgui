package WebGUI::Help::Asset_Calendar;
use strict;

use strict;;
use warnings;

our $HELP = {

#### View Calendar Page

    'view calendar template' => {
        title => 'view calendar title',
        body  => 'view calendar body',
        isa   => [
            {   namespace => "Asset_Template",
                tag       => "template variables"
            },
            {   namespace => "Asset",
                tag       => "asset template"
            },
        ],
        fields    => [],
        variables => [
            { 'name' => 'admin' },
            { 'name' => 'adminControls' },
            { 'name' => 'editor' },
            { 'name' => 'urlAdd' },
            { 'name' => 'urlDay' },
            { 'name' => 'urlWeek' },
            { 'name' => 'urlMonth' },
            { 'name' => 'urlSearch' },
            { 'name' => 'urlPrint' },
            { 'name' => 'urlIcal' },
            { 'name' => 'paramStart' },
            { 'name' => 'paramType' },
            { 'name' => 'extrasUrl' },
        ],
        related => []
    },

#### Search Calendar Page

#### ICal Calendar Page

#### View Month Template

#### View Week Template

    'view week template' => {
        title => 'view calendar week title',
        body  => 'view calendar week body',
        isa   => [
            {   namespace => "Asset_Calendar",
                tag       => "view calendar template"
            },
        ],
        fields    => [],
        variables => [
            {   'name'      => 'days',
                'variables' => [
                    { 'name' => 'dayName' },
                    { 'name' => 'dayAbbr' },
                    { 'name' => 'dayOfMonth' },
                    { 'name' => 'dayOfWeek' },
                    { 'name' => 'monthName' },
                    { 'name' => 'monthAbbr' },
                    { 'name' => 'year' },
                    { 'name' => 'ymd' },
                    { 'name' => 'mdy' },
                    { 'name' => 'dmy' },
                    { 'name' => 'epoch' },
                    {   'name'        => 'events',
                        'description' => 'events weekVar',
                    },
                ],
            },
            {   'name'        => 'pageNextUrl',
                'description' => 'pageNextUrl weekVar'
            },
            {   'name'        => 'pagePrevUrl',
                'description' => 'pagePrevUrl weekVar'
            },
            { 'name' => 'startMonth', },
            { 'name' => 'startMonthName' },
            { 'name' => 'startMonthAbbr' },
            { 'name' => 'startDayOfMonth' },
            { 'name' => 'startDayName' },
            { 'name' => 'startDayAbbr' },
            { 'name' => 'startYear' },
            { 'name' => 'endMonth', },
            { 'name' => 'endMonthName' },
            { 'name' => 'endMonthAbbr' },
            { 'name' => 'endDayOfMonth' },
            { 'name' => 'endDayName' },
            { 'name' => 'endDayAbbr' },
            { 'name' => 'endYear' },
        ],
        related => []
    },

#### View Day Template

    'view day template' => {
        title => 'view calendar day title',
        body  => 'view calendar day body',
        isa   => [
            {   namespace => "Asset_Calendar",
                tag       => "view calendar template"
            },
        ],
        fields    => [],
        variables => [
            {   'name'      => 'hours',
                'variables' => [
                    { 'name' => 'hour12' },
                    { 'name' => 'hour24' },
                    { 'name' => 'hourM' },
                    {   'name'        => 'events',
                        'description' => 'events dayVar'
                    },
                ],
            },
            { 'name' => 'pageNextStart' },
            {   'name'        => 'pageNextUrl',
                'description' => 'pageNextUrl dayVar'
            },
            { 'name' => 'pagePrevStart' },
            {   'name'        => 'pagePrevUrl',
                'description' => 'pagePrevUrl dayVar'
            },
            { 'name' => 'dayName' },
            { 'name' => 'dayAbbr' },
            { 'name' => 'dayOfMonth' },
            { 'name' => 'dayOfWeek' },
            { 'name' => 'monthName' },
            { 'name' => 'monthAbbr' },
            { 'name' => 'year' },
            { 'name' => 'ymd' },
            { 'name' => 'mdy' },
            { 'name' => 'dmy' },
            { 'name' => 'epoch' },
        ],
        related => []
    },

};

#### Search Template

1;

