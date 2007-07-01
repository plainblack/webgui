package WebGUI::Help::Asset_Newsletter; ## Be sure to change the package name to match your filename.

##Stub document for creating help documents.

our $HELP = {  ##hashref of hashes
	'newsletter add/edit' => {	
		title => 'newsletter add/edit',  
		body => 'newsletter add/edit desc',
		isa => [
			{
			tag => 'collaboration add/edit',
			namespace => 'Asset_Collaboration',
			},
		],
		fields => [	
                        {
                                title => 'newsletter header',
                                description => 'newsletter header help',
                                namespace => 'Asset_Newsletter',  
                        },
                        {
                                title => 'newsletter footer',
                                description => 'newsletter footer help',
                                namespace => 'Asset_Newsletter',  
                        },
                        {
                                title => 'newsletter template',
                                description => 'newsletter template help',
                                namespace => 'Asset_Newsletter',  
                        },
                        {
                                title => 'my subscriptions template',
                                description => 'my subscriptions template help',
                                namespace => 'Asset_Newsletter',  
                        },
                        {
                                title => 'newsletter categories',
                                description => 'newsletter categories help',
                                namespace => 'Asset_Newsletter',  
                        },
		],
		variables => [
			{
				name => "mySubscriptionsUrl",
			},
		],
	},

    'my subscriptions template' => {
        title => 'my subscriptions template',
        body => 'my subscriptions template help',
        variables => [
            {
                name => "formHeader",
            },
            {
                name => "formFooter",
            },
            {
                name => "formSubmit",
            },
            {
                name => "categoriesLoop",
                variables => [
                        {
                            name => "categoryName",
                        },
                        {
                            name => "optionsLoop",
                            variables => [
                                    {
                                        name => "optionName",
                                    },
                                    {
                                        name => "optionForm",
                                    },
                                ],
                        },
                    ],
            },
		],
    },

    'newsletter template' => {
        title => 'newsletter template',
        body => 'newsletter template help',
        variables => [
            {
                name => "title",
                description => "newsletterTitle",
            },
            {
                name => "description",
                description => "newsletterDescription",
            },
            {
                name => "header",
                description => "newsletter header",
            },
            {
                name => "footer",
                description => "newsletter header",
            },
            {
                name => "thread_loop",
                variables => [
                        {
                            name => "title",
                            description => "threadTitle",
                        },
                        {
                            name => "synopsis",
                            description => "threadSynopsis",
                        },
                        {
                            name => "body",
                            description => "threadBody",
                        },
                        {
                            name => "url",
                            description => "threadUrl",
                        },
                    ],
            },
        ],
    },

};

1;  ##All perl modules must return true
