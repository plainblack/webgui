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
            { 'name' => 'maxResponsesSubmitted' },
            { 'name' => 'lastResponseFeedback', description => 'lastResponseFeedback help' },
        ],
        related => [
            {   tag       => 'gradebook report template',
                namespace => 'Asset_Survey'
            },
            {   tag       => 'statistical overview report template',
                namespace => 'Asset_Survey'
            },
            {   tag       => 'survey section edit template',
                namespace => 'Asset_Survey'
            },
            {   tag       => 'survey question edit template',
                namespace => 'Asset_Survey'
            },
            {   tag       => 'survey answer edit template',
                namespace => 'Asset_Survey'
            },
            {   tag       => 'survey feedback template',
                namespace => 'Asset_Survey'
            },  
            {   tag       => 'survey test results template',
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
                    { 'name' => 'response_feedback_url' },
                    { 'name' => 'response_id' },
                    { 'name' => 'response_userId' },
                    { 'name' => 'response_ip' },
                    { 'name' => 'response_startDate' },
                    { 'name' => 'response_endDate' },
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
            {   tag       => 'survey section edit template',
                namespace => 'Asset_Survey'
            },
            {   tag       => 'survey question edit template',
                namespace => 'Asset_Survey'
            },
            {   tag       => 'survey answer edit template',
                namespace => 'Asset_Survey'
            },
            {   tag       => 'survey feedback template',
                namespace => 'Asset_Survey'
            },  
            {   tag       => 'survey test results template',
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
            {   'name'  => 'isLastPage' },
            {   'name'  => 'allowBackBtn' },
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
            {   tag       => 'survey section edit template',
                namespace => 'Asset_Survey'
            },
            {   tag       => 'survey question edit template',
                namespace => 'Asset_Survey'
            },
            {   tag       => 'survey answer edit template',
                namespace => 'Asset_Survey'
            },      
            {   tag       => 'survey feedback template',
                namespace => 'Asset_Survey'
            },   
            {   tag       => 'survey test results template',
                namespace => 'Asset_Survey'
            },      
        ]
    },

    'survey section edit template' => {
        title  => 'survey section edit template title',
        body   => '',
        fields => [],
        isa    => [],
        variables => [
            { 'name' => 'id' },
            { 'name' => 'displayed_id' },
            { 'name' => 'text' },
            { 'name' => 'everyPageText' },
            { 'name' => 'title' },
            { 'name' => 'everyPageTitle' },
            { 'name' => 'variable' },
            { 'name' => 'goto' },
            { 'name' => 'randomizeQuestions' },
            { 'name' => 'terminal' },
            { 'name' => 'terminalUrl' },
            { 'name' => 'questionsOnSectionPage' },
            { 'name' => 'questionsPerPage',
                        'variables' => [
                            { 'name' => 'index' },
                            { 'name' => 'selected' },
                        ]
            }
        ],
        related => [
            {   tag       => 'survey template',
                namespace => 'Asset_Survey'
            },
            {   tag       => 'survey question edit template',
                namespace => 'Asset_Survey'
            },
            {   tag       => 'survey answer edit template',
                namespace => 'Asset_Survey'
            },
            {   tag       => 'gradebook report template',
                namespace => 'Asset_Survey'
            },
            {   tag       => 'statistical overview report template',
                namespace => 'Asset_Survey'
            },
            {   tag       => 'survey feedback template',
                namespace => 'Asset_Survey'
            },  
            {   tag       => 'survey test results template',
                namespace => 'Asset_Survey'
            }, 
        ]
    },

    'survey question edit template' => {
        title  => 'survey question edit template title',
        body   => '',
        fields => [],
        isa    => [],
        variables => [
            { 'name' => 'id' },
            { 'name' => 'displayed_id' },
            { 'name' => 'text' },
            { 'name' => 'variable' },
            { 'name' => 'randomizeAnswers' },
            { 'name' => 'questionType' ,
                        'variables' => [
                            { 'name' => 'selected' },
                        ]
            },
            { 'name' => 'textInButton' },
            { 'name' => 'required' },
            { 'name' => 'allowComment' },
            { 'name' => 'verticalDisplay' },
            { 'name' => 'commentCols' },
            { 'name' => 'commentRows' },
            { 'name' => 'maxAnswers' },
            { 'name' => 'value' },
        ],
        related => [
            {   tag       => 'survey template',
                namespace => 'Asset_Survey'
            },
            {   tag       => 'survey section edit template',
                namespace => 'Asset_Survey'
            },
            {   tag       => 'survey answer edit template',
                namespace => 'Asset_Survey'
            },
            {   tag       => 'gradebook report template',
                namespace => 'Asset_Survey'
            },
            {   tag       => 'statistical overview report template',
                namespace => 'Asset_Survey'
            },
            {   tag       => 'survey feedback template',
                namespace => 'Asset_Survey'
            },  
            {   tag       => 'survey test results template',
                namespace => 'Asset_Survey'
            }, 
        ]
    },

    'survey answer edit template' => {
        title  => 'survey answer edit template title',
        body   => '',
        fields => [],
        isa    => [],
        variables => [
            { 'name' => 'id' },
            { 'name' => 'displayed_id' },
            { 'name' => 'text' },
            { 'name' => 'goto' },
            { 'name' => 'value' },
            { 'name' => 'isCorrect' },
            { 'name' => 'textCols' },
            { 'name' => 'textRows' },
            { 'name' => 'min' },
            { 'name' => 'max' },
            { 'name' => 'step' },
            { 'name' => 'verbatim' },
            { 'name' => 'recordedAnswer' },
        ],
        related => [
            {   tag       => 'survey template',
                namespace => 'Asset_Survey'
            },
            {   tag       => 'survey section edit template',
                namespace => 'Asset_Survey'
            },
            {   tag       => 'survey question edit template',
                namespace => 'Asset_Survey'
            },
            {   tag       => 'gradebook report template',
                namespace => 'Asset_Survey'
            },
            {   tag       => 'statistical overview report template',
                namespace => 'Asset_Survey'
            },
            {   tag       => 'survey feedback template',
                namespace => 'Asset_Survey'
            },  
            {   tag       => 'survey test results template',
                namespace => 'Asset_Survey'
            }, 
        ]
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
    
    'survey feedback template' => {
        title   => 'survey feedback template variables title',
        body => 'survey feedback template body',
        isa     => [],
        fields    => [],
        variables => [
            { name => 'complete', description => 'response complete help' },
            { name => 'restart', description => 'response restart help' },
            { name => 'timeout', description => 'response timeout help' },
            { name => 'timeoutRestart', description => 'response timeout restart help' },
            { name => 'endDate', description => 'response endDate help' },
            { name => 'responseId', description => 'responseId help' },
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
            {   tag       => 'survey section edit template',
                namespace => 'Asset_Survey'
            },
            {   tag       => 'survey question edit template',
                namespace => 'Asset_Survey'
            },
            {   tag       => 'survey answer edit template',
                namespace => 'Asset_Survey'
            },          
            {   tag       => 'survey feedback template',
                namespace => 'Asset_Survey'
            },  
            {   tag       => 'survey test results template',
                namespace => 'Asset_Survey'
            },  
        ]
    },
    
    'survey test results template' => {
        title   => 'survey test results template title',
        body => 'survey test results template body',
        isa     => [],
        fields    => [],
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
            {   tag       => 'survey section edit template',
                namespace => 'Asset_Survey'
            },
            {   tag       => 'survey question edit template',
                namespace => 'Asset_Survey'
            },
            {   tag       => 'survey answer edit template',
                namespace => 'Asset_Survey'
            },          
            {   tag       => 'survey feedback template',
                namespace => 'Asset_Survey'
            },  
        ]
    },
};

1;
