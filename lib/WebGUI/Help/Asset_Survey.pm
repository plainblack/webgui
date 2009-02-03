package WebGUI::Help::Asset_Survey;
use strict;

our $HELP = {
    'survey template' => {
        title  => 'survey template title',
        body   => '',
        fields => [],
        isa    => [
            {   namespace => 'Asset_Survey',
                tag       => 'survey template common vars'
            },
            {   namespace => 'Asset_Survey',
                tag       => 'survey asset template variables'
            },
        ],
        variables => [
            { 'name' => 'lastResponseCompleted' },
            { 'name' => 'lastResponseTimedOut' },
            { 'name' => 'maxResponsesSubmitted' },
        ],
        related => [
            {   tag       => 'gradebook report template',
                namespace => 'Asset_Survey'
            },
            {   tag       => 'statistical overview report template',
                namespace => 'Asset_Survey'
            },
        ]
    },

    'survey template common vars' => {
        private   => 1,
        title     => 'survey template common vars title',
        body      => '',
        fields    => [],
        variables => [
            { 'name' => 'user_canTakeSurvey' },
            { 'name' => 'user_canViewReports' },
            { 'name' => 'user_canEditSurvey' },
            { 'name' => 'edit_survey_url' },
            { 'name' => 'take_survey_url' },
            { 'name' => 'view_simple_results_url' },
            { 'name' => 'view_transposed_results_url' },
            { 'name' => 'view_statistical_overview_url' },
            { 'name' => 'view_grade_book_url' },
        ],
        related => []
    },

    'gradebook report template' => {
        title  => 'gradebook report template title',
        body   => '',
        fields => [],
        isa    => [
            {   namespace => 'Asset_Survey',
                tag       => 'survey template common vars'
            },
            {   tag       => 'pagination template variables',
                namespace => 'WebGUI'
            },
            {   namespace => 'Asset_Survey',
                tag       => 'survey asset template variables'
            },
        ],
        variables => [
            { 'name' => 'question_count' },
            {   'name'      => 'response_loop',
                'variables' => [
                    { 'name' => 'response_user_name' },
                    { 'name' => 'response_count_correct' },
                    { 'name' => 'response_percent' }
                ]
            }
        ],
        related => [
            {   tag       => 'survey template',
                namespace => 'Asset_Survey'
            },
            {   tag       => 'statistical overview report template',
                namespace => 'Asset_Survey'
            },
        ]
    },

    'survey questions template' => {
        title  => 'survey questions template title',
        body   => '',
        fields => [],
        isa    => [
            {   namespace => 'Asset_Survey',
                tag       => 'survey template common vars'
            },
            {   namespace => 'Asset_Survey',
                tag       => 'survey asset template variables'
            },
        ],
        variables => [
            {   'name'  => 'questionsAnswered' },
            {   'name'  => 'totalQuestions' },
            {   'name'  => 'showProgress' },
            {   'name'  => 'showTimeLimit' },
            {   'name'  => 'minutesLeft' },
            {   'name'  => 'questions',
                'variables' => [
                    {   'name' => 'id' },
                    {   'name' => 'sid' },
                    {   'name' => 'text' },
                    {   'name' => 'fileLoader' },
                    {   'name' => 'textType' },
                    {   'name' => 'multipleChoice' },
                    {   'name' => 'maxAnswers' },
                    {   'name' => 'maxMoreOne' },
                    {   'name' => 'dateType' },
                    {   'name' => 'slider' },
                    {   'name' => 'dualSlider' },
                    {   'name' => 'a1' },
                    {   'name' => 'a2' },
                    {   'name' => 'verticalDisplay' },
                    {   'name' => 'verts' },
                    {   'name' => 'verte' },
                    {   'name' => 'answers',
                        'variables' => [
                            { 'name' => 'id' },
                            { 'name' => 'text' },
                        ]
                    }
                ]
            }
        ],
        related => [
            {   tag       => 'survey template',
                namespace => 'Asset_Survey'
            },
            {   tag       => 'statistical overview report template',
                namespace => 'Asset_Survey'
            },
            {   tag       => 'gradebook report template',
                namespace => 'Asset_Survey'
            },
        ]
    },


    'survey response template' => {
        title => '1089',
        body  => '',
        isa   => [
            {   namespace => 'Asset_Survey',
                tag       => 'survey template common vars'
            },
            {   namespace => 'Asset_Survey',
                tag       => 'survey asset template variables'
            },
        ],
        fields    => [],
        variables => [
            { 'name' => 'title', },
            { 'name' => 'delete.url' },
            { 'name' => 'delete.label' },
            { 'name' => 'start.date.label' },
            { 'name' => 'start.date.epoch' },
            { 'name' => 'start.date.human' },
            { 'name' => 'start.time.human' },
            { 'name' => 'end.date.label' },
            { 'name' => 'end.date.epoch' },
            { 'name' => 'end.date.human' },
            { 'name' => 'end.time.human' },
            { 'name' => 'duration.label' },
            { 'name' => 'duration.minutes' },
            { 'name' => 'duration.minutes.label' },
            { 'name' => 'duration.seconds' },
            { 'name' => 'duration.seconds.label' },
            { 'name' => 'answer.label' },
            { 'name' => 'response.label' },
            { 'name' => 'comment.label' },
            {   'name'      => 'question_loop',
                'variables' => [
                    { 'name' => 'question' },
                    { 'name' => 'question.id', },
                    { 'name' => 'question.isRadioList' },
                    { 'name' => 'question.response' },
                    { 'name' => 'question.comment' },
                    { 'name' => 'question.isCorrect' },
                    { 'name' => 'question.answer' }
                ],
            }
        ],
        related => []
    },

    'statistical overview report template' => {
        title  => 'statistical overview template title',
        body   => '',
        fields => [],
        isa    => [
            {   namespace => 'Asset_Survey',
                tag       => 'survey template common vars'
            },
            {   tag       => 'pagination template variables',
                namespace => 'WebGUI'
            },
            {   namespace => 'Asset_Survey',
                tag       => 'survey asset template variables'
            },
        ],
        variables => [
            {   'name'      => 'question_loop',
                'variables' => [
                    { 'name' => 'question', },
                    { 'name' => 'question_id', },
                    { 'name' => 'question_isMultipleChoice', },
                    { 'name' => 'question_response_total' },
                    { 'name' => 'question_allowComment', },
                    {   'name'      => 'answer_loop',
                        'variables' => [
                            { 'name' => 'answer_isCorrect' },
                            { 'name' => 'answer' },
                            { 'name' => 'answer_response_count' },
                            { 'name' => 'answer_response_percent' },
                            { 'name' => 'answer_comment' },
                            { 'name' => 'answer_value' },
                            {   'name'      => 'comment_loop',
                                'variables' => [ { 'name' => 'answer_comment' } ]
                            }
                        ]
                    }
                ],
            }
        ],
        related => [
            {   tag       => 'survey template',
                namespace => 'Asset_Survey'
            },
            {   tag       => 'gradebook report template',
                namespace => 'Asset_Survey'
            },
        ]
    },

    'survey asset template variables' => {
        private => 1,
        title   => 'survey asset template variables title',
        body    => '',
        isa     => [
            {   namespace => 'Asset_Wobject',
                tag       => 'wobject template variables'
            },
        ],
        fields    => [],
        variables => [
            { 'name' => 'templateId' },
            { 'name' => 'groupToTakeSurvey' },
            { 'name' => 'groupToViewReports' },
            { 'name' => 'maxResponsesPerUser' },
            { 'name' => 'overviewTemplateId' },
            { 'name' => 'gradebookTemplateId' },
            { 'name' => 'responseTemplateId' },
        ],
    },

};

1;
