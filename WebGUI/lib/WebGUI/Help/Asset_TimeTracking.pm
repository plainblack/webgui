package WebGUI::Help::Asset_TimeTracking;
use strict;

our $HELP = {
    'user view template variables' => {
        title => 'user view template title',
        body  => '',
        isa   => [
            {   namespace => 'Asset_Wobject',
                tag       => 'wobject template variables'
            },
            {   namespace => 'Asset_Template',
                tag       => 'template variables'
            },
            {   namespace => 'Asset',
                tag       => 'asset template'
            },
            {   namespace => 'Asset_TimeTracking',
                tag       => 'time tracking asset template variables'
            },
        ],
        variables => [
            { 'name' => 'extras', },
            { 'name' => 'project.manage.url', },
            { 'name' => 'project.manage.label', },
            {   'name'     => 'form.header',
                'required' => 1,
            },
            {   'name'     => 'form.footer',
                'required' => 1,
            },
            {   'name'     => 'project.task.array',
                'required' => 1,
            },
            { 'name' => 'js.alert.removeRow.error', },
            { 'name' => 'js.alert.validate.hours.error', },
            { 'name' => 'js.alert.validate.incomplete.error', },
            { 'name' => 'form.isComplete', },
            { 'name' => 'time.report.rows.total', },
            { 'name' => 'form.timetracker', },
        ],
        fields  => [],
        related => [],
    },

    'time row template variables' => {
        title => 'time row template title',
        body  => '',
        isa   => [
            {   namespace => 'Asset_Wobject',
                tag       => 'wobject template variables'
            },
            {   namespace => 'Asset_Template',
                tag       => 'template variables'
            },
            {   namespace => 'Asset',
                tag       => 'asset template'
            },
            {   namespace => 'Asset_TimeTracking',
                tag       => 'time tracking asset template variables'
            },
        ],
        variables => [
            { 'name' => 'extras', },
            { 'name' => 'report.nextWeek.url', },
            { 'name' => 'report.lastWeek.url', },
            { 'name' => 'time.report.header', },
            { 'name' => 'time.report.totalHours.label', },
            { 'name' => 'time.report.date.label', },
            { 'name' => 'time.report.project.label', },
            { 'name' => 'time.report.task.label', },
            { 'name' => 'time.report.hours.label', },
            { 'name' => 'time.report.comments.label', },
            { 'name' => 'time.add.row.label', },
            { 'name' => 'time.save.label', },
            { 'name' => 'time.report.complete.label', },
            { 'name' => 'report.isComplete', },
            { 'name' => 'time.totalHours', },
            {   'name'      => 'time.entry.loop',
                'variables' => [
                    { 'name' => 'row.id', },
                    {   'name'     => 'form.taskEntryId',
                        'required' => 1,
                    },
                    {   'name'     => 'form.project',
                        'required' => 1,
                    },
                    {   'name'     => 'form.task',
                        'required' => 1,
                    },
                    {   'name'     => 'form.date',
                        'required' => 1,
                    },
                    {   'name'     => 'form.hours',
                        'required' => 1,
                    },
                    {   'name'     => 'form.comments',
                        'required' => 1,
                    },
                    { 'name' => 'entry.hours', },
                ],
            },
        ],
        fields  => [],
        related => [],
    },

    'time tracking asset template variables' => {
        private => 1,
        title   => 'time tracking asset template variables title',
        body    => '',
        isa     => [
            {   namespace => 'Asset_Wobject',
                tag       => 'wobject template variables'
            },
        ],
        fields    => [],
        variables => [
            { 'name' => 'userViewTemplateId' },
            { 'name' => 'managerViewTemplateId' },
            { 'name' => 'timeRowTemplateId' },
            { 'name' => 'groupToManage', },
            { 'name' => 'pmIntegration' },
        ],
        related => []
    },

};

1;    ##All perl modules must return true
