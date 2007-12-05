package WebGUI::Help::Asset_Newsletter;    ## Be sure to change the package name to match your filename.
use strict

##Stub document for creating help documents.

our $HELP = {                              ##hashref of hashes
    'my subscriptions template' => {
        title     => 'my subscriptions template',
        body      => '',
        variables => [
            { name => "formHeader", },
            { name => "formFooter", },
            { name => "formSubmit", },
            {   name      => "categoriesLoop",
                variables => [
                    { name => "categoryName", },
                    {   name      => "optionsLoop",
                        variables => [ { name => "optionName", }, { name => "optionForm", }, ],
                    },
                ],
            },
        ],
    },

    'newsletter template' => {
        title     => 'newsletter template',
        body      => '',
        variables => [
            {   name        => "title",
                description => "newsletterTitle",
            },
            {   name        => "description",
                description => "newsletterDescription",
            },
            {   name        => "header",
                description => "newsletter header",
            },
            {   name        => "footer",
                description => "newsletter header",
            },
            {   name      => "thread_loop",
                variables => [
                    {   name        => "title",
                        description => "threadTitle",
                    },
                    {   name        => "synopsis",
                        description => "threadSynopsis",
                    },
                    {   name        => "body",
                        description => "threadBody",
                    },
                    {   name        => "url",
                        description => "threadUrl",
                    },
                ],
            },
        ],
    },

};

1;    ##All perl modules must return true
