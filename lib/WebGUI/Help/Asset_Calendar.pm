package WebGUI::Help::Asset_Calendar;

our $HELP   = {};

#### Edit Calendar Page
$editPage = $HELP->{'calendar add/edit'} = {};

$editPage->{ title      } = 'help add/edit title';
$editPage->{ body       } = 'help add/edit body';

push @{$editPage->{ isa }}, {
        tag         => 'asset fields',
        namespace   => 'Asset',
    },
    ;

push @{$editPage->{ fields }}, 
    {
        title       => "defaultView label",
        description => "defaultView description",
        namespace   => "Asset_Calendar",
    },
    {
        title       => "defaultDate label",
        description => "defaultDate description",
        namespace   => "Asset_Calendar",
    },
    {
        title       => "groupIdEventEdit label",
        description => "groupIdEventEdit description",
        namespace   => "Asset_Calendar",
    },
    {
        title       => "templateIdMonth label",
        description => "templateIdMonth description",
        namespace   => "Asset_Calendar",
    },
    {
        title       => "templateIdWeek label",
        description => "templateIdWeek description",
        namespace   => "Asset_Calendar",
    },
    {
        title       => "templateIdDay label",
        description => "templateIdDay description",
        namespace   => "Asset_Calendar",
    },
    {
        title       => "templateIdEvent label",
        description => "templateIdEvent description",
        namespace   => "Asset_Calendar",
    },
    {
        title       => "templateIdEventEdit label",
        description => "templateIdEventEdit description",
        namespace   => "Asset_Calendar",
    },
    {
        title       => "templateIdSearch label",
        description => "templateIdSearch description",
        namespace   => "Asset_Calendar",
    },
    {
        title       => "templateIdPrintMonth label",
        description => "templateIdPrintMonth description",
        namespace   => "Asset_Calendar",
    },
    {
        title       => "templateIdPrintWeek label",
        description => "templateIdPrintWeek description",
        namespace   => "Asset_Calendar",
    },
    {
        title       => "templateIdPrintDay label",
        description => "templateIdPrintDay description",
        namespace   => "Asset_Calendar",
    },
    {
        title       => "templateIdPrintEvent label",
        description => "templateIdPrintEvent description",
        namespace   => "Asset_Calendar",
    },
    ;

push @{$editPage->{ related }},
    "",
    "",
    ;

#### View Calendar Page

#### Search Calendar Page

#### ICal Calendar Page


#### View Month Template

#### View Week Template

#### View Day Template

#### Search Template


our $HELP = {
	'calendar add/edit' => {
		title => 'add/edit title',
		body => 'add/edit body',
		isa => [
			{
				tag => 'asset fields',
				namespace => 'Asset'
			},
		],
		fields => [
                ],
		related => [
		]
	},

};

1;
