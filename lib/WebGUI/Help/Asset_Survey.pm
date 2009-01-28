package WebGUI::Help::Asset_Survey;
use strict;

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
            },
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
        ],
        related => []
    },

    'survey template common vars' => {
        title     => 'survey template common vars title',
        body      => '',
        fields    => [],
        variables => [
            { 'name' => 'user_canViewReports' },
            { 'name' => 'delete_all_responses.url' },
            { 'name' => 'export_answers_url' },
            { 'name' => 'export_questions_url' },
            { 'name' => 'export_responses_url' },
            { 'name' => 'export_composite_url' },
            { 'name' => 'report_gradebook_url' },
            { 'name' => 'report_overview_url' },
            { 'name' => 'survey_url' },
        ],
        related => [
            {   tag       => 'survey template',
                namespace => 'Asset_Survey'
            }
        ]
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
                    { 'name' => 'response_url' },
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
