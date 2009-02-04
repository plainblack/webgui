package WebGUI::i18n::English::Asset_Survey;
use strict;

our $I18N = {

	'assetName' => {
		message => q|Survey|,
		lastUpdated => 1224686319
	},
	'edit survey' => {
		message => q|Edit Survey|,
		lastUpdated => 1224686319
	},
	'take survey' => {
		message => q|Take Survey|,
		lastUpdated => 1224686319
	},
	'view simple results' => {
		message => q|View Simple Results|,
		lastUpdated => 1224686319
	},
	'view transposed results' => {
		message => q|View Transposed Results|,
		lastUpdated => 1224686319
	},
	'view statistical overview' => {
		message => q|View Statistical Overview|,
		lastUpdated => 1224686319
	},
	'view grade book' => {
		message => q|View Grade Book|,
		lastUpdated => 1224686319
	},
	'continue button' => {
		message => q|Continue|,
		lastUpdated => 1224686319
	},
	'add section' => {
		message => q|Add Section|,
		lastUpdated => 1224686319
	},
	'add question' => {
		message => q|Add Question|,
		lastUpdated => 1224686319
	},
	'add answer' => {
		message => q|Add Answer|,
		lastUpdated => 1224686319
	},
	'submit' => {
		message => q|Submit|,
		lastUpdated => 1224686319
	},
	'copy' => {
		message => q|Copy|,
		lastUpdated => 1224686319
	},
	'cancel' => {
		message => q|Cancel|,
		lastUpdated => 1224686319
	},
	'delete' => {
		message => q|Delete|,
		lastUpdated => 1224686319
	},
	'section number' => {
		message => q|Section Number:|,
		lastUpdated => 1224686319
	},
    'section number description' => {
        message => q|The number of this section.|,
        context => q|Description of the 'section number' field, used as hoverhelp in the edit section dialog.|,
        lastUpdated => 0
    },
	'questions on section page' => {
		message => q|Questions on section page:|,
		lastUpdated => 1224686319
	},
    'questions on section page description' => {
        message => q|Are question displayed on the initial page of this section or on the next page.|,
        context => q|Description of the 'questions on section page' field, used as hoverhelp in the edit section dialog.|,
        lastUpdated => 0
    },

	'section name' => {
		message => q|Section name:|,
		lastUpdated => 1224686319
	},
    'section name description' => {
        message => q|The name of this section of questions.|,
        context => q|Description of the 'section name' field, used as hoverhelp in the edit section dialog.|,
        lastUpdated => 0
    },
	'randomize questions' => {
		message => q|Randomize questions:|,
		lastUpdated => 1224686319
	},
    'randomize questions description' => {
        message => q|If set to Yes, then the questions will be shuffled for each user.|,
        context => q|Description of the 'randomize questions' field, used as hoverhelp in the edit section dialog.|,
        lastUpdated => 0 
    },
	'section custom variable name' => {
		message => q|Section custom variable name:|,
		lastUpdated => 1224686319
	},
    'section custom variable name description' => {
        message => q|Enter a variable name to identify this section, so that it can be entered as a goto variable name in another section.|,
        context => q|Description of the 'section custom variable name' field, used as hoverhelp in the edit section dialog.|,
        lastUpdated => 0
    },
	'section branch goto variable name' => {
		message => q|Section branch goto variable name:|,
		lastUpdated => 1224686319
	},
    'section branch goto variable name description' => {
        message => q|The section or question with this variable name will be the next to be displayed after this section.|,
        context => q|Description of the 'section branch goto variable name' field, used as hoverhelp in the edit section dialog.|,
        lastUpdated => 0
    },
	'questions per page' => {
		message => q|Questions per page:|,
		lastUpdated => 1224686319
	},
    'questions per page description' => {
        message => q|The number of questions displayed per page.|,
        context => q|Description of the 'questions per page' field, used as hoverhelp in the edit section dialog.|,
        lastUpdated => 0
    },
	'section text' => {
		message => q|Section text:|,
		lastUpdated => 1224686319
	},
    'section text description' => {
        message => q|Enter a description of this section.|,
        context => q|Description of the 'section text' field, used as hoverhelp in the edit section dialog.|,
        lastUpdated => 0
    },
	'title on every page' => {
		message => q|Title on every page:|,
		lastUpdated => 1224686319
	},
    'title on every page description' => {
        message => q|Should the title of this section be displayed on every page of this section?|,
        context => q|Description of the 'title on every page' field, used as hoverhelp in the edit section dialog.|,
        lastUpdated => 0
    },
	'text on every page' => {
		message => q|Text on every page:|,
		lastUpdated => 1224686319
	},
    'text on every page description' => {
        message => q|Should the text of this section be displayed on every page of this section?|,
        context => q|Description of the 'text on every page' field, used as hoverhelp in the edit section dialog.|,
        lastUpdated => 0
    },
	'terminal section' => {
		message => q|Terminal section:|,
		lastUpdated => 1224686319
	},
    'terminal section description' => {
        message => q|Is this a terminal section of this Survey?|,
        context => q|Description of the 'terminal section' field, used as hoverhelp in the edit section dialog.|,
        lastUpdated => 0
    },
	'terminal section url' => {
		message => q|Terminal section URL:|,
		lastUpdated => 1224686319
	},
    'terminal section url description' => {
        message => q|The url that will be displayed after this section. The terminal url setting in a question overrides the terminalUrl setting for its section.|,
        context => q|Description of the 'terminal section url' field, used as hoverhelp in the edit section dialog.|,
        lastUpdated => 0
    },
	'please enter section information' => {
		message => q|Please enter section information|,
        context => q|Title of the edit section dialog.|,
		lastUpdated => 1224686319
	},
	'please enter question information' => {
		message => q|Please enter question information|,
        context => q|Title of the edit question dialog.|,
		lastUpdated => 1224686319
	},
	'question number' => {
		message => q|Question number:|,
		lastUpdated => 1224686319
	},
    'question number description' => {
        message => q|The number of this question.|,
        context => q|Description of the 'question number' field, used as hoverhelp in the edit question dialog.|,
        lastUpdated => 0
    },
	'question text' => {
		message => q|Question text:|,
		lastUpdated => 1224686319
	},
    'question text description' => {
        message => q|Enter a text for this question.|,
        context => q|Description of the 'question text' field, used as hoverhelp in the edit question dialog.|,
        lastUpdated => 0
    },
	'question variable name' => {
		message => q|Question variable name.|,
		lastUpdated => 1224686319
	},
    'question variable name description' => {
        message => q|Enter a variable name to identify this question, so that it can be entered as a goto variable name in another section.|,
        context => q|Description of the 'question variable name' field, used as hoverhelp in the edit question dialog.|,
        lastUpdated => 0
    },
	'randomize answers' => {
		message => q|Randomize answers:|,
		lastUpdated => 1224686319
	},
    'randomize answers description' => {
        message => q|If set to Yes, then the answers will be shuffled for each user.|,
        context => q|Description of the 'randomize answers' field, used as hoverhelp in the edit question dialog.|,
        lastUpdated => 0 
    },
	'question type' => {
		message => q|Question type:|,
		lastUpdated => 1224686319
	},
    'question type description' => {
        message => q|Select this question's field type.|,
        context => q|Description of the 'question type' field, used as hoverhelp in the edit question dialog.|,
        lastUpdated => 0
    },
	'randomized words' => {
		message => q|Randomized words:|,
		lastUpdated => 1224686319
	},
    'randomized words description' => {
        message => q||,
        context => q|Description of the 'randomized words' field, used as hoverhelp in the edit question dialog.|,
        lastUpdated => 0
    },
	'vertical display' => {
		message => q|Vertical display:|,
		lastUpdated => 1224686319
	},
    'vertical display description' => {
        message => q|This property controls whether buttons of a multiple choice question are laid out horizontally or vertically.|,
        context => q|Description of the 'vertical display' field, used as hoverhelp in the edit question dialog.|,
        lastUpdated => 0
    },
	'show text in button' => {
		message => q|Show text in button:|,
		lastUpdated => 1224686319
	},
    'show text in button description' => {
        message => q|Select if the buttons of a multiple choice question display the answer values or not.|,
        context => q|Description of the 'show text in button' field, used as hoverhelp in the edit question dialog.|,
        lastUpdated => 0
    },
	'allow comment' => {
		message => q|Allow comment:|,
		lastUpdated => 1224686319
	},
    'allow comment description' => {
        message => q|Can the user add a comment about this question?|,
        context => q|Description of the 'allow comment' field, used as hoverhelp in the edit question dialog.|,
        lastUpdated => 0
    },
	'cols' => {
		message => q|Cols:|,
		lastUpdated => 1224686319
	},
    'cols description' => {
        message => q|The number of columns of the textarea input.|,
        context => q|Description of the 'cols' field, used as hoverhelp in the edit question dialog.|,
        lastUpdated => 0
    },
	'rows' => {
		message => q|Rows:|,
		lastUpdated => 1224686319
	},
    'rows description' => {
        message => q|The number of rows of the textarea input.|,
        context => q|Description of the 'rows' field, used as hoverhelp in the edit question dialog.|,
        lastUpdated => 0
    },
	'maximum number of answers' => {
		message => q|Maximum number of answers:|,
		lastUpdated => 1224686319
	},
    'maximum number of answers description' => {
        message => q|Enter the maximum number of answers.|,
        context => q|Description of the 'maximum number of answers' field, used as hoverhelp in the edit question dialog.|,
        lastUpdated => 0
    },
	'required' => {
		message => q|Required|,
		lastUpdated => 1224686319
	},
    'required description' => {
        message => q|Is this a required question?|,
        context => q|Description of the 'required' field, used as hoverhelp in the edit question dialog.|,
        lastUpdated => 0
    },
	'question value' => {
		message => q|Question value:|,
		lastUpdated => 1224686319
	},
    'question value description' => {
        message => q|Enter a value for this question.|,
        context => q|Description of the 'question value' field, used as hoverhelp in the edit question dialog.|,
        lastUpdated => 0
    },
	'please enter answer information' => {
		message => q|Please enter answer information:|,
        context => q|Title of the edit answer dialog.|,
		lastUpdated => 1224686319
	},
	'answer number' => {
		message => q|Answer number:|,
		lastUpdated => 1224686319
	},
    'answer number description' => {
        message => q|The number of this answer|,
        context => q|Description of the 'answer number' field, used as hoverhelp in the edit answer dialog.|,
        lastUpdated => 0
    },
	'answer text' => {
		message => q|Answer text:|,
		lastUpdated => 1224686319
	},
    'answer text description' => {
        message => q|Enter a text for this answer.|,
        context => q|Description of the 'answer text' field, used as hoverhelp in the edit answer dialog.|,
        lastUpdated => 0
    },
	'recorded answer' => {
		message => q|Recorded answer:|,
		lastUpdated => 1224686319
	},
    'recorded answer description' => {
        message => q|The answer that will be recorded in the database.|,
        context => q|Description of the 'recorded answer' field, used as hoverhelp in the edit answer dialog.|,
        lastUpdated => 0
    },
	'jump to' => {
		message => q|Jump to:|,
		lastUpdated => 1224686319
	},
    'jump to description' => {
        message => q|The section or question with this variable name will be the next to be displayed after this answer.|,
        context => q|Description of the 'jump to' field, used as hoverhelp in the edit answer dialog.|,
        lastUpdated => 0
    },
	'text answer' => {
		message => q|Text answer|,
		lastUpdated => 1224686319
	},
	'is this the correct answer' => {
		message => q|Is this the correct answer|,
		lastUpdated => 1224686319
	},
    'is this the correct answer description' => {
        message => q|Select wether this is the correct answer or not.|,
        context => q|Description of the 'is this the correct answer' field, used as hoverhelp in the edit answer dialog.|,
        lastUpdated => 0
    },
	'yes' => {
		message => q|Yes|,
		lastUpdated => 1224686319
	},
	'no' => {
		message => q|No|,
		lastUpdated => 1224686319
	},
	'min' => {
		message => q|Min|,
		lastUpdated => 1224686319
	},
    'min description' => {
        message => q|Set the min value of this answer for slider type questions.|,
        context => q|Description of the 'min' field, used as hoverhelp in the edit answer dialog.|,
        lastUpdated => 0
    },
	'max' => {
		message => q|Max|,
		lastUpdated => 1224686319
	},
    'max description' => {
        message => q|Set the max value of this answer for slider type questions.|,
        context => q|Description of the 'max' field, used as hoverhelp in the edit answer dialog.|,
        lastUpdated => 0
    },
	'step' => {
		message => q|Step|,
		lastUpdated => 1224686319
	},
    'step description' => {
        message => q|Set the step value of this answer for slider type questions.|,
        context => q|Description of the 'step' field, used as hoverhelp in the edit answer dialog.|,
        lastUpdated => 0
    },
	'verbatim' => {
		message => q|Verbatim|,
		lastUpdated => 1224686319
	},
    'verbatim description' => {
        message => q|Set to yes to add an extra text input to the answer, where the user can enter a single line of text.|,
        context => q|Description of the 'verbatim' field, used as hoverhelp in the edit answer dialog.|,
        lastUpdated => 0
    },
	'answer value' => {
		message => q|Answer value:|,
		lastUpdated => 1224686319
	},
    'answer value description' => {
        message => q|Enter a value for this answer.|,
        context => q|Description of the 'answer value' field, used as hoverhelp in the edit answer dialog.|,
        lastUpdated => 0
    },
	'checked' => {
		message => q|Checked|,
		lastUpdated => 1224686319
	},
	'timelimit' => {
		message => q|Time Limit:|,
		lastUpdated => 1224686319
	},
	'timelimit hoverHelp' => {
		message => q|How many minutes the user has to finish the survey from the moment they start.  0 means unlimited time.|,
		lastUpdated => 1231193335,
	},
    'survey template' => {
        message     => q|Survey Template|,
        lastUpdated => 0,
    },

    'survey template help' => {
        message     => q|The template to display the main page of the survey.|,
        lastUpdated => 0,
    },

    'Show user their progress' => {
        message     => q|Show user their progress?|,
        lastUpdated => 0,
    },

    'Show user their progress help' => {
        message     => q|Set to yes to display to the user how many questions they have answered, and how many they have left to go.|,
        lastUpdated => 0,
    },

    'Show user their time remaining' => {
        message     => q|Show user their time remaining?|,
        lastUpdated => 0,
    },

    'Show user their time remaining help' => {
        message     => q|Set to yes to display to the user how much time they have left to finish the survey.|,
        lastUpdated => 0,
    },

    'Group to edit survey' => {
        message     => q|Group to edit the survey.|,
        lastUpdated => 0,
    },

    'Group to edit survey help' => {
        message     => q|Select a group who can edit the survey.|,
        lastUpdated => 0,
    },

    'Group to take survey' => {
        message     => q|Group to take the survey.|,
        lastUpdated => 0,
    },

    'Group to take survey help' => {
        message     => q|Select a group who can take the survey.|,
        lastUpdated => 0,
    },

    'Group to view reports' => {
        message     => q|Group to view reports.|,
        lastUpdated => 0,
    },

    'Group to view reports help' => {
        message     => q|Select a group who can view reports.|,
        lastUpdated => 0,
    },

    'Survey Exit URL' => {
        message     => q|Survey Exit URL|,
        lastUpdated => 0,
    },

    'Survey Exit URL help' => {
        message     => q|When the user finishes the surevey, they will be sent to this URL.  Leave blank if no special forwarding is required.  The gateway setting from the config file will be automatically added to the URL for you.|,
        lastUpdated => 1233714385,
    },

    'percentage label' => {
        message => q|Percentage|,
        context => q|Label for the Percentage column on the gradebook screen.|,
        lastUpdated => 0
    },

    'user label' => {
        message => q|User|,
        context => q|Label for the User column on the gradebook screen.|,
        lastUpdated => 0
    },

    'score label' => {
        message => q|Score|,
        context => q|Label for the Score column on the gradebook screen.|,
        lastUpdated => 0
    },

    'answer label' => {
        message => q|Answer|,
        context => q|Label for the Answer column on the statistical overview screen.|,
        lastUpdated => 0
    },

    'response count label' => {
        message => q|Responses|,
        context => q|Label for the Response Count column on the statistical overview screen.|,
        lastUpdated => 0
    },

    'response percent label' => {
        message => q|Percentage|,
        context => q|Label for the Response Percent column on the statistical overview screen.|,
        lastUpdated => 0
    },

    'show comments label' => {
        message => q|View Comments|,
        context => q|Label for the Show Comments link on the statistical overview screen.|,
        lastUpdated => 0
    },

    'show responses label' => {
        message => q|View Responses|,
        context => q|Label for the View Responses link on the statistical overview screen.|,
        lastUpdated => 0
    },

    'statistical overview template title' => {
        message => q|Survey Statistical Overview Report Template|,
        context => q|The title of a template Help page.|,
        lastUpdated => 1149654954,
    },

    'question_loop' => {
        message => q|A loop containing questions.|,
        context => q|Description of a template loop for a template Help page.|,
        lastUpdated => 1149654954,
    },

    'question' => {
        message => q|The text of this question.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'question_id' => {
        message => q|The id of this question|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'question_allowComment' => {
        message => q|A boolean indicating whether comments about this question are allowed.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'question_response_total' => {
        message => q|The total number of responses for this answer.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 1149654954,
    },

    'question_isMultipleChoice' => {
        message => q|A boolean indicating whether this is a multiple choice question.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 1149654954,
    },

    'answer_loop' => {
        message => q|A loop containing the answers and responses for this question.|,
        context => q|Description of a template loop for a template Help page.|,
        lastUpdated => 1149654954,
    },

    'answer_isCorrect' => {
        message => q|A boolean indicating whether this answer is marked correct. Only available for multiple choice questions.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 1149654954,
    },

    'answer' => {
        message => q|The answer itself.|,
        context => q|Description of a template variable for a template Help page. Only available for multiple choice questions.|,
        lastUpdated => 1149654954,
    },

    'answer_value' => {
        message => q|The value of this answer. Not available for multiple choice questions.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'answer_response_count' => {
        message => q|The total number of responses given for this answer. Only available for multiple choice questions.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 1149654954,
    },

    'answer_response_percent' => {
        message => q|The percent of responses to this question that went to this answer. Only available for multiple choice questions.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 1149654954,
    },

    'comment_loop' => {
        message => q|A loop that contains all of the comments for this answer. Only available for multiple choice questions.|,
        context => q|Description of a template loop for a template Help page.|,
        lastUpdated => 1149654954,
    },

    'answer_comment' => {
        message => q|A comment. This tmpl_var is available in the comment_loop for multiple choice questions and
directly inside the answer_loop for other types of questions.|,
        context => q|Description of a template variable for a template Help page.|, 
        lastUpdated => 0,
    },

    'gradebook report template title' => {
        message => q|Survey Gradebook Report Template|,
        context => q|The title of a template Help page.|,
        lastUpdated => 0,
    },

    'question_count' => {
        message => q|The number of questions in the survey.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 1149654771,
    },

    'response_loop' => {
        message => q|A loop containing a list of responses.|,
        context => q|Description of a template loop for a template Help page.|,
        lastUpdated => 1149654771,
    },

    'response_user_name' => {
        message => q|The username of the user that gave this response.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 1149654771,
    },

    'response_count_correct' => {
        message => q|The total number of questions that this user got correct.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 1149654771,
    },

    'response_percent' => {
        message => q|The percentage of correct questions.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 1149654771,
    },

    'survey template common vars title' => {
        message => q|Survey Template Common Vars|,
        context => q|The title of a template Help page.|,
        lastUpdated => 1078223067
    },

    'survey template title' => {
        message => q|Survey Template|,
        context => q|The title of a template Help page.|,
        lastUpdated => 1078223096
    },

    'lastResponseCompleted' => {
        message => q|A boolean indicating wether the current user's last response was completed.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'lastResponseTimedOut' => {
        message => q|A boolean indicating wether the current user's last response timed out.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'maxResponsesSubmitted' => {
        message => q|A boolean indicating wether the current user has reached the maximum number of responses.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'user_canTakeSurvey' => {
        message => q|A boolean indicating wether the current user can take the survey.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'user_canViewReports' => {
        message => q|A boolean indicating wether the current user can view the survey reports.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'user_canEditSurvey' => {
        message => q|A boolean indicating wether the current user can edit the survey.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'edit_survey_url' => {
        message => q|The url for the survey edit screen.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'take_survey_url' => {
        message => q|The url for the take survey screen.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'view_simple_results_url' => {
        message => q|The url for the simple results screen.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'view_transposed_results_url' => {
        message => q|The url for the transposed results screen.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'view_statistical_overview_url' => {
        message => q|The url for the statistical overview screen.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'view_grade_book_url' => {
        message => q|The url for the grade book report screen.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'templateId' => {
        message => q|The ID of the template to show the Survey.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 1168639537,
    },

    'groupToTakeSurvey' => {
        message => q|The ID of the group that is allowed to take the Survey.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 1168639812,
    },

    'groupToViewReports' => {
        message => q|The ID of the group that is allowed to view reports from the Survey.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 1168639812,
    },

    'maxResponsesPerUser' => {
        message => q|The number of times the user can attempt to get the correct answer on each question. The default is 1.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 1168643566,
    },

    'overviewTemplateId' => {
        message => q|The ID of the template used to show the overview screen.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 1168643669,
    },

    'gradebookTemplateId' => {
        message => q|The ID of the template used to show the gradebook screen.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 1168643669,
    },

    'responseTemplateId' => {
        message => q|The ID of the template used to show the Survey Response screen.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 1168643669,
    },

    'survey questions template title' => {
        message => q|Survey Questions Template|,
        context => q|The title of a template Help page.|,
        lastUpdated => 0
    },

    'questionsAnswered' => {
        message => q|The number of questions that has been answered.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'totalQuestions' => {
        message => q|The total number of questions.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'totalQuestions' => {
        message => q|A boolean indicating wether the user should see the total number of answers and the number of questions that have already been answered.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'showTimeLimit' => {
        message => q|A boolean indicating wether the number of minutes until the survey times out should be displayed.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'minutesLeft' => {
        message => q|The number of minutes the user has left to finish the survey.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'questions' => {
        message => q|A loop containing the questions in this section.|,
        context => q|Description of a template loop for a template Help page.|,
        lastUpdated => 0,
    },

    'id' => {
        message => q|The ID of this question/answer.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'text' => {
        message => q|The text of this question/answer.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'sid' => {
        message => q|The section ID of this question.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'dualSlider' => {
        message => q|A boolean indicating if this is a dualSlider type question.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'a1' => {
        message => q|A loop containing the first list of answers for a dual slider type question.|,
        context => q|Description of a template loop for a template Help page.|,
        lastUpdated => 0,
    },

    'a2' => {
        message => q|A loop containing the second list of answers for a dual slider type question.|,
        context => q|Description of a template loop for a template Help page.|,
        lastUpdated => 0,
    },

    'slider' => {
        message => q|A boolean indicating if this is a slider type question.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'dateType' => {
        message => q|A boolean indicating if this is a date type question.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'multipleChoice' => {
        message => q|A boolean indicating if this is a multipleChoice type question.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'maxMoreOne' => {
        message => q|A boolean indicating if the maximum number of answers that can be given to this question is greater than one.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'maxAnswers' => {
        message => q|The maximum number of answers that can be given to this question.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'hidden' => {
        message => q|A boolean indicating if this is a hidden type question.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'textType' => {
        message => q|A boolean indicating if this is a text type question.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'fileLoader' => {
        message => q|A boolean indicating if this is a fileLoader type question.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'verticalDisplay' => {
        message => q|A boolean indicating if the answers to this question should be displayed vertically.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'verts' => {
        message => q|A paragraph opening tag.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'verte' => {
        message => q|A paragraph closing tag.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'answers' => {
        message => q|A loop containing the answers to this question.|,
        context => q|Description of a template loop for a template Help page.|,
        lastUpdated => 0,
    },

    'answers' => {
        message => q|A loop containing the answers to this question.|,
        context => q|Description of a template loop for a template Help page.|,
        lastUpdated => 0,
    },

    'survey asset template variables title' => {
        message => q|Survey Asset Template Variables.|,
        context => q|Title of the page where asset template variables are documented.|,
        lastUpdated => 0,
    },

    'showProgress' => {
        message => q|A boolean that is true if the asset has been configured to show how much progess the user has made in completing this Survey.|,
        context => q|Template variable doc.|,
        lastUpdated => 0,
    },

};

1;
