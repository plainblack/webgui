package WebGUI::Help::Asset_Survey;

our $HELP = {
    'survey template' => {
        title  => '88',
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
            { 'name' => 'question.add.url' },
            { 'name' => 'question.add.label' },
            { 'name' => 'section.add.url' },
            { 'name' => 'section.add.label' },
            { 'name' => 'user.canTakeSurvey' },
            { 'name' => 'form.header' },
            { 'name' => 'form.footer' },
            { 'name' => 'form.submit' },
            { 'name' => 'questions.sofar.label' },
            { 'name' => 'start.newresponse.label' },
            { 'name' => 'start.newresponse.url' },
            { 'name' => 'thanks.survey.label' },
            { 'name' => 'thanks.quiz.label' },
            { 'name' => 'questions.total' },
            { 'name' => 'questions.correct.count.label' },
            { 'name' => 'questions.correct.percent.label' },
            { 'name' => 'mode.isSurvey' },
            { 'name' => 'survey.noprivs.label' },
            { 'name' => 'quiz.noprivs.label' },
            { 'name' => 'response.id' },
            { 'name' => 'response.count' },
            { 'name' => 'user.isFirstResponse' },
            { 'name' => 'user.canRespondAgain' },
            { 'name' => 'questions.sofar.count' },
            { 'name' => 'questions.correct.count' },
            { 'name' => 'questions.correct.percent' },
            { 'name' => 'response.isComplete' },
            {   'name'      => 'section.edit_loop',
                'variables' => [
                    { 'name' => 'section.edit.controls' },
                    { 'name' => 'section.edit.sectionName' },
                    { 'name' => 'section.edit.id' },
                    {   'name'      => 'section.questions_loop',
                        'variables' => [
                            { 'name' => 'question.edit.controls' },
                            { 'name' => 'question.edit.question' },
                            { 'name' => 'question.edit.id' },
                        ],
                    },
                ],
                {   'name'      => 'question_loop',
                    'variables' => [
                        { 'name' => 'question.question' },
                        { 'name' => 'question.allowComment' },
                        { 'name' => 'question.id' },
                        { 'name' => 'question.comment.field' },
                        { 'name' => 'question.comment.label' },
                        { 'name' => 'question.answer.field' }
                    ]
                },
            },
        ],
        related => []
    },

    'survey template common vars' => {
        title     => '90',
        body      => '',
        fields    => [],
        variables => [
            { 'name' => 'user.canViewReports' },
            { 'name' => 'delete.all.responses.url' },
            { 'name' => 'delete.all.responses.label' },
            { 'name' => 'export.answers.url' },
            { 'name' => 'export.answers.label' },
            { 'name' => 'export.questions.url' },
            { 'name' => 'export.questions.label' },
            { 'name' => 'export.responses.url' },
            { 'name' => 'export.responses.label' },
            { 'name' => 'export.composite.url' },
            { 'name' => 'export.composite.label' },
            { 'name' => 'report.gradebook.url' },
            { 'name' => 'report.gradebook.label' },
            { 'name' => 'report.overview.url' },
            { 'name' => 'report.overview.label' },
            { 'name' => 'survey.url' },
            { 'name' => 'survey.label' }
        ],
        related => [
            {   tag       => 'survey template',
                namespace => 'Asset_Survey'
            }
        ]
    },

    'gradebook report template' => {
        title  => '1087',
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
            { 'name' => 'title' },
            { 'name' => 'question.count' },
            { 'name' => 'response.user.label' },
            { 'name' => 'response.count.label' },
            { 'name' => 'response.percent.label' },
            {   'name'      => 'response_loop',
                'variables' => [
                    { 'name' => 'response.url' },
                    { 'name' => 'response.user.name' },
                    { 'name' => 'response.count.correct' },
                    { 'name' => 'response.percent' }
                ]
            }
        ],
        related => [
            {   tag       => 'survey template',
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
        title  => '1091',
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
            { 'name' => 'title', },
            {   'name'        => 'answer.label',
                'description' => 'report answer.label'
            },
            {   'name'        => 'response.count.label',
                'description' => 'report response.count.label'
            },
            { 'name' => 'response.percent.label', },
            { 'name' => 'show.responses.label' },
            { 'name' => 'show.comments.label' },
            {   'name'      => 'question_loop',
                'variables' => [
                    { 'name' => 'question', },
                    { 'name' => 'question.id', },
                    { 'name' => 'question.isRadioList', },
                    { 'name' => 'question.response.total' },
                    { 'name' => 'question.allowComment', },
                    {   'name'      => 'answer_loop',
                        'variables' => [
                            { 'name' => 'answer.isCorrect' },
                            { 'name' => 'answer' },
                            { 'name' => 'answer.response.count' },
                            { 'name' => 'answer.response.percent' },
                            {   'name'      => 'comment_loop',
                                'variables' => [ { 'name' => 'answer.comment' } ]
                            }
                        ]
                    }
                ],
            }
        ],
        related => []
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
            { 'name' => 'Survey_id' },
            { 'name' => 'questionOrder' },
            { 'name' => 'groupToTakeSurvey' },
            { 'name' => 'groupToViewReports' },
            { 'name' => 'mode' },
            { 'name' => 'anonymous' },
            { 'name' => 'maxResponsesPerUser' },
            { 'name' => 'questionsPerPage' },
            { 'name' => 'overviewTemplateId' },
            { 'name' => 'gradebookTemplateId' },
            { 'name' => 'responseTemplateId' },
            { 'name' => 'defaultSectionId' },
        ],
    },

};

1;
