package WebGUI::Help::Asset_Poll;

our $HELP = {
    'poll template' => {
        title => '73',
        body  => '',
        isa   => [
            {   namespace => "Asset_Poll",
                tag       => "poll asset template variables"
            },
            {   namespace => "Asset_Template",
                tag       => "template variables"
            },
            {   namespace => "Asset",
                tag       => "asset template"
            },
        ],
        fields    => [],
        variables => [
            { 'name' => 'canVote', },
            { 'name' => 'question', },
            {   'name'     => 'form.start',
                'required' => 1,
            },
            {   'name'      => 'answer_loop',
                'variables' => [
                    { 'name' => 'answer.form', },
                    { 'name' => 'answer.text', },
                    { 'name' => 'answer.number', },
                    { 'name' => 'answer.graphWidth', },
                    { 'name' => 'answer.percent', },
                    { 'name' => 'answer.total', }
                ]
            },
            {   'name'     => 'form.submit',
                'required' => 1,
            },
            {   'name'     => 'form.end',
                'required' => 1,
            },
            { 'name' => 'responses.label', },
            { 'name' => 'responses.total', },
            { 'name' => 'graphUrl', },
            { 'name' => 'hasImageGraph', }
        ],
        related => []
    },

    'poll asset template variables' => {
        private => 1,
        title   => 'poll asset template variables title',
        body    => 'poll asset template variables body',
        isa     => [
            {   namespace => 'Asset_Wobject',
                tag       => 'wobject template variables',
            },
        ],
        fields    => [],
        variables => [
            { 'name' => 'templateId', },
            { 'name' => 'active', },
            { 'name' => 'karmaPerVote', },
            { 'name' => 'graphWidth', },
            { 'name' => 'voteGroup', },
            { 'name' => 'question', },
            { 'name' => 'randomizeAnswers', },
            { 'name' => 'aN', },
            { 'name' => 'graphConfiguration', },
            { 'name' => 'generateGraph', },
        ],
        related => [],
    },

};

1;
