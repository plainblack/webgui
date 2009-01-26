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
        message     => q|When the user finishes the surevey, they will be sent to this URL.  Leave blank if no special forwarding is required.|,
        lastUpdated => 0,
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

};

1;
