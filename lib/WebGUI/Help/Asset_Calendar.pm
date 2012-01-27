package WebGUI::Help::Asset_Calendar;
use strict;

our $HELP = {

    'view calendar template' => {
        title => 'view calendar title',
        body  => 'view calendar body',
        private => '1',
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

    'calendar dateTime' => {
        title       => 'help calendar dateTime title',
        body        => 'help calendar dateTime body',
        variables   => [
            { 'name' => 'second',       description => 'helpvar dateTime second', },
            { 'name' => 'minute',       description => 'helpvar dateTime minute', },
            { 'name' => 'meridiem',     description => 'helpvar dateTime meridiem', },
            { 'name' => 'month',        description => 'helpvar dateTime month', },
            { 'name' => 'monthName',    description => 'helpvar dateTime monthName', },
            { 'name' => 'monthAbbr',    description => 'helpvar dateTime monthAbbr', },
            { 'name' => 'dayOfMonth',   description => 'helpvar dateTime dayOfMonth', },
            { 'name' => 'dayName',      description => 'helpvar dateTime dayName', },
            { 'name' => 'dayAbbr',      description => 'helpvar dateTime dayAbbr', },
            { 'name' => 'year',         description => 'helpvar dateTime year', },
            { 'name' => 'dayOfWeek',    description => 'helpvar dateTime dayOfWeek', },
            { 'name' => 'ymd',          description => 'helpvar dateTime ymd', },
            { 'name' => 'mdy',          description => 'helpvar dateTime mdy', },
            { 'name' => 'dmy',          description => 'helpvar dateTime dmy', },
            { 'name' => 'epoch',        description => 'helpvar dateTime epoch', },
        ],
    },

    'event variables' => {
        title       => 'help event variables title',
        body        => 'help event variables body',
        related     => [
            {
                namespace       => 'Asset_Event',
                tag             => 'event common variables',
            },
        ],
    },

    'view month template' => {
        title => 'view calendar month title',
        body  => 'view calendar month body',
        isa   => [
            {   namespace => "Asset_Calendar",
                tag       => "view calendar template"
            },
        ],
        fields    => [],
        variables => [
            {   'name'      => 'weeks',
                'variables' => [
                {   'name'      => 'days',
                    'variables' => [
                        { 'name' => 'dayUrl' },
                        { 'name' => 'dayMonth',
                          'description' => 'dayOfMonth' },
                        { 'name' => 'dayCurrent' },
                        {   'name'        => 'events',
                            'description' => 'events weekVar',
                        },
                    ],
                },
                ],
            },
            {   'name'        => 'pageNextUrl',
                'description' => 'pageNextUrl monthVar'
            },
            {   'name'        => 'pagePrevUrl',
                'description' => 'pagePrevUrl monthVar'
            },
            { 'name' => 'pageNextYear', },
            { 'name' => 'pagePrevYear', },
            { 'name' => 'monthName', },
            { 'name' => 'monthAbbr', },
            { 'name' => 'year' },
            {   'name'      => 'dayNames',
                'variables' => [
                    { 'name' => 'dayName' },
                    { 'name' => 'dayAbbr' },
                ],
            },
            {   'name'      => 'months',
                'variables' => [
                    { 'name' => 'monthName' },
                    { 'name' => 'monthAbbr' },
                    { 'name' => 'monthEpoch' },
                    { 'name' => 'monthUrl' },
                    { 'name' => 'monthCurrent' },
                ],
            },
        ],
        related => []
    },

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

#### List view template
    'view list template' => {
        title   => 'help view list title',
        body    => 'help view list body',
        isa     => [
            {
                namespace   => "Asset_Calendar",
                tag         => "view calendar template",
            },
            {
                namespace   => "Asset_Calendar",
                tag         => "event variables",
            },
        ],
        related  => [
            {
                namespace   => "Asset_Calendar",
                tag         => 'calendar dateTime',
            },
        ],
        variables   => [
            {
                name        => 'new_year',
                description => 'helpvar newYear',
            },
            {
                name        => 'new_month',
                description => 'helpvar newMonth',
            },
            {
                name        => 'new_day',
                description => 'helpvar newDay',
            },
            {
                name        => 'url_previousPage',
                description => 'helpvar url_previousPage',
            },
            {
                name        => 'url_nextPage',
                description => 'helpvar url_nextPage',
            },
            {
                name        => 'start',
                description => 'helpvar dateTime start',
            },
            {
                name        => 'end',
                description => 'helpvar dateTime end',
            },

        ],
    },
};


1;

