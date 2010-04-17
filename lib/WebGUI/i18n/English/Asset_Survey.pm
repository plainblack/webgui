package WebGUI::i18n::English::Asset_Survey;
use strict;

our $I18N = {

	'assetName' => {
		message => q|Survey (beta)|,
		lastUpdated => 1236187015 
	},
	'edit survey' => {
		message => q|Edit Survey|,
		lastUpdated => 1224686319
	},
	'take survey' => {
		message => q|Take Survey|,
		lastUpdated => 1224686319
	},
	'visualize' => {
		message => q|Visualize|,
		lastUpdated => 0
	},
	'generate' => {
		message => q|Generate|,
		lastUpdated => 0
	},
	'survey visualization' => {
		message => q|Survey Visualization|,
		lastUpdated => 0
	},
	'visualization success' => {
		message => q|Visualization successfully generated to|,
		lastUpdated => 0
	},
	'visualization format' => {
		message => q|Visualisation Format|,
		lastUpdated => 0
	},
	'visualization format help' => {
		message => q|Choose the type of visualization file you want to generate|,
		lastUpdated => 0
	},
	'visualization layout algorithm' => {
		message => q|Visualisation Layout Algorithm|,
		lastUpdated => 0
	},
	'visualization layout algorithm help' => {
		message => q|Choose the GraphViz layout algorithm you want to use|,
		lastUpdated => 0
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
    'delete responses' => {
        message => q|Delete Responses|,
        lastUpdated => 0
    },
	'continue button' => {
		message => q|Continue|,
		lastUpdated => 1224686319
	},
    'logical section' => {
		message => q|Logical Section|,
		lastUpdated => 1224686319
    },
    'logical section help' => {
		message => q|A logical section, or its questions, are never shown.  They are used to silently execute jump commands.|,
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
	'warnings' => {
        message => q|Warnings|,
        lastUpdated => 0
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
        message => q|Whether questions are displayed on the initial page of this section or on the next page.|,
        context => q|Description of the 'questions on section page' field, used as hoverhelp in the edit section dialog.|,
        lastUpdated => 1249057316
    },

	'section name' => {
		message => q|Section title:|,
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
		message => q|Section variable name:|,
		lastUpdated => 1224686319
	},
    'section custom variable name description' => {
        message => q|Enter a variable name to identify this section, so that it can be entered as a goto variable name in another section.|,
        context => q|Description of the 'section custom variable name' field, used as hoverhelp in the edit section dialog.|,
        lastUpdated => 0
    },
	'section branch goto variable name' => {
		message => q|Jump to:|,
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
	'randomized words' => {
		message => q|Randomized words:|,
		lastUpdated => 1224686319
	},
    'question type description' => {
        message => q|Select this question's field type.|,
        context => q|Description of the 'question type' field, used as hoverhelp in the edit question dialog.|,
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
        message => q|By default multiple choice answer buttons show the answer text above each button. Change this to have the text appear inside of the buttons.|,
        context => q|Description of the 'show text in button' field, used as hoverhelp in the edit question dialog.|,
        lastUpdated => 1239251986
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
	'comment cols' => {
		message => q|Comment Cols:|,
		lastUpdated => 1224686319
	},
    'cols description' => {
        message => q|The number of columns used for the input field (for TextArea question types).|,
        context => q|Description of the 'cols' field, used as hoverhelp in the edit question dialog.|,
        lastUpdated => 1241588599
    },
    'comment rows' => {
            message => q|Comment Rows:|,
            lastUpdated => 1224686319
    },
    'rows description' => {
        message => q|The number of rows used for the input field (for TextArea question types).|,
        context => q|Description of the 'rows' field, used as hoverhelp in the edit question dialog.|,
        lastUpdated => 1241588599
    },
    'maximum number of answers' => {
            message => q|Maximum number of answers:|,
            lastUpdated => 1224686319
    },
    'maximum number of answers description' => {
        message => q|For multi-choice questions, how many answers the user can select. <br>0 = unlimited.<br>1 = radio group style.<br>2 and above = checkbox style.|,
        context => q|Description of the 'maximum number of answers' field, used as hoverhelp in the edit question dialog.|,
        lastUpdated => 1241764603,
    },
    'required label' => {
            message => q|Required|,
            lastUpdated => 1224686319
    },
    'required description' => {
        message => q|Is this a required question?|,
        context => q|Description of the 'required' field, used as hoverhelp in the edit question dialog.|,
        lastUpdated => 0
    },
    'question score' => {
            message => q|Question score:|,
            lastUpdated => 1224686319
    },
    'question score description' => {
        message => q|Default score to use for answers in this question that don't have an answer score value set.|,
        context => q|Description of the 'question value' field, used as hoverhelp in the edit question dialog.|,
        lastUpdated => 1239255403
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
        message => q|Enter a text for this answer. For multiple choice questions this answer will be displayed above the buttons.|,
        context => q|Description of the 'answer text' field, used as hoverhelp in the edit answer dialog.|,
        lastUpdated => 0
    },
    'recorded answer' => {
            message => q|Recorded Answer:|,
            lastUpdated => 1224686319
    },
    'recorded answer description' => {
        message => q|Determines what gets recorded as the response value if this answer is selected. Allows you to 'recode' recorded responses, e.g. 'Yes' could be recorded as '1' and 'No' as '0'. Relevant only for Multiple Choice questions (other question types record the input actually entered by the user: free text, selected date, etc..).|,
        context => q|Description of the 'recorded answer' field, used as hoverhelp in the edit answer dialog.|,
        lastUpdated => 1239251436
    },
    'jump to' => {
            message => q|Jump to:|,
            lastUpdated => 1224686319
    },
    'jump expression' => {
            message => q|Jump expression:|,
            lastUpdated => 1229318805
    },
    'jump to description' => {
        message => q|The section or question with this variable name will be the next to be displayed after this answer.|,
        context => q|Description of the 'jump to' field, used as hoverhelp in the edit answer dialog.|,
        lastUpdated => 0
    },
    'jump expression description' => {
        message => q|An expression used to control complex branching based user responses to previous questions. Ignored unless enableSurveyExpressionEngine enabled in your site config file.|,
        context => q|Description of the 'jump expression' field, used as hoverhelp in the edit answer dialog.|,
        lastUpdated => 1239259550
    },
	'text answer' => {
		message => q|TextArea|,
		lastUpdated => 1224686319
	},
	'is this the correct answer' => {
		message => q|Is this the correct answer|,
		lastUpdated => 1224686319
	},
    'is this the correct answer description' => {
        message => q|Select whether this is the correct answer or not.|,
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
	'min label' => {
		message => q|Min|,
		lastUpdated => 1241588065
	},
        'min description' => {
            message => q|The minimum numeric value allowed for this answer (for numeric question types such as Number and Slider). Keep this field empty if you do not want to enforce a minimum value. |,
            context => q|Description of the 'min' field, used as hoverhelp in the edit answer dialog.|,
            lastUpdated => 1241588065
        },
	'max label' => {
		message => q|Max|,
		lastUpdated => 1241588065
	},
        'max description' => {
            message => q|The maximum numeric value allowed for this answer (for Number and Slider type questions). Keep this field empty if you do not want to enforce a maximum value. |,
            context => q|Description of the 'max' field, used as hoverhelp in the edit answer dialog.|,
            lastUpdated => 1241588065
        },
	'step label' => {
		message => q|Step|,
		lastUpdated => 1241588065
	},
        'step description' => {
            message => q|The step value, that is, the numeric interval to allow between values (for Number and Slider type questions).  Keep this field empty if you do not want to enforce a step value. |,
            context => q|Description of the 'step' field, used as hoverhelp in the edit answer dialog.|,
            lastUpdated => 0
        },
	'verbatim label' => {
		message => q|Verbatim|,
		lastUpdated => 1224686319
	},
        'verbatim description' => {
            message => q|Set to yes to add an extra text input to the answer, where the user can enter a single line of text. Typically used to permit a free-text 'other' response.|,
            context => q|Description of the 'verbatim' field, used as hoverhelp in the edit answer dialog.|,
            lastUpdated => 0
        },
	'answer score' => {
		message => q|Answer score:|,
		lastUpdated => 1239251986
	},
    'answer score description' => {
        message => q|Assign a numeric score to this answer. If blank, the question score value will used instead. Used in question scoring and jump expressions.|,
        context => q|Description of the 'answer score' field, used as hoverhelp in the edit answer dialog.|,
        lastUpdated => 1239251986
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

    'Feedback Template' => {
        message     => q|Feedback Template|,
        lastUpdated => 0,
    },

    'Feedback Template help' => {
        message     => q|The template used to display response feedback.|,
        lastUpdated => 0,
    },

    'do after timelimit label' => {
        message => q|Do After Time Limit:|,
        lastUpdated => 1224686319,
        context => q|label for the 'do after timelimit' field on the Properties tab of the Survey's edit screen.|,
    },
    'do after timelimit hoverHelp' => {
        message => q|Select what happens after the time limit for finishing the survey has expired.|,
        lastUpdated => 1231193335,
        context => q|description of the 'do after timelimit' field on the Properties tab of the Survey's edit
screen|,
    }, 
    'exit url label' =>{
        message => q|Exit URL|,
        lastUpdated => 0,
        context => q|Label for the 'exit url' option of the 'do after timelimit' field on the Properties tab of the
Survey's edit screen|,
    },
    'restart survey label' =>{
        message => q|Restart Survey|,
        lastUpdated => 0,
        context => q|Label for the 'restart survey' option of the 'do after timelimit' field on the Properties tab of the
Survey's edit screen|,
    },
    'restart message' =>{
        message => q|The survey was restarted because the time limit for completing the survey was reached.|,
        lastUpdated => 0,
        context => q|The message shown to the user taking the survey when the survey is restarted after reaching
the time limit for completing the survey. This message is in the 'take survey' template.|,
    },
    'Quiz mode summaries' => {
        message     => q|Show quiz mode summaries?|,
        lastUpdated => 0,
    },
    'Quiz mode summaries help' => {
        message     => q|When set, summaries are shown to users giving their quiz results.|,
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
        message     => q|When the user finishes the survey, they will be sent to this URL.  Leave blank if no special forwarding is required.  The gateway setting from the config file will be automatically added to the URL for you.|,
        lastUpdated => 1241648155,
    },

    'Overview Report Template' => {
        message     => q|Overview Report Template|,
        lastUpdated => 0,
    },

    'Overview Report Template help' => {
        message     => q|The template used to display the Overview Report.|,
        lastUpdated => 0,
    },

    'Gradebook Report Template' => {
        message     => q|Gradebook Report Template|,
        lastUpdated => 1249056084,
    },

    'Gradebook Report Template help' => {
        message     => q|The template used to display the Gradebook Report|,
        lastUpdated => 0,
    },

    'Survey Edit Template' => {
        message     => q|Survey Edit Template|,
        lastUpdated => 0,
    },

    'Survey Edit Template help' => {
        message     => q|The template used to display the Survey Edit screen.|,
        lastUpdated => 0,
    },

    'Allow back button' => {
        message     => q|Allow back button|,
        lastUpdated => 0,
    },

    'Allow back button help' => {
        message     => q|Allow the user to navigate backwards in a Survey.|,
        lastUpdated => 0,
    },

    'Max user responses' => {
        message => q|Max user responses|,
        context => q|The maximum number of times a user may take this survey.|,
        lastUpdated => 0
    },

    'Max user responses help' => {
        message => q|The maximum number of times a user may take this survey.|,
        lastUpdated => 0
    },

    'Survey Overview Template' => {
        message => q|Survey Overview Template|,
        context => q|The template that provides an overview of the survey.|,
        lastUpdated => 0
    },

    'Survey Overview Template help' => {
        message => q|The template that provides an overview of the survey.|,
        lastUpdated => 0
    },

    'Gradebook Template' => {
        message => q|Gradebook Template|,
        context => q|The template for displaying the gradebook.|,
        lastUpdated => 0
    },

    'Gradebook Template help' => {
        message => q|The template for displaying the gradebook.|,
        lastUpdated => 0
    },

    'Edit Survey Template' => {
        message => q|Edit Survey Template|,
        context => q|The template for displaying the screen for editing the survey.|,
        lastUpdated => 0
    },

    'Edit Survey Template help' => {
        message => q|The template for displaying the screen for editing the survey.|,
        lastUpdated => 0
    },

    'Survey Summary Template' => {
        message => q|Survey Summary Template|,
        context => q|The template for displaying the summary page to users.|,
        lastUpdated => 0
    },

    'Survey Summary Template help' => {
        message => q|This is the template shown to users in quiz mode to summarize their results.|,
        context => q|The template for displaying the summary page to users.|,
        lastUpdated => 0
    },

    'Take Survey Template' => {
        message => q|Take Survey Template|,
        context => q|The template for displaying the screen where a user takes the survey.|,
        lastUpdated => 0
    },

    'Take Survey Template help' => {
        message => q|The template used to control the initial Take Survey screen, from which responses are dynamically loaded into.|,
        lastUpdated => 0
    },

    'Questions Template' => {
        message => q|Questions Template|,
        context => q|The template for rendering questions in the survey.|,
        lastUpdated => 0
    },

    'Questions Template help' => {
        message => q|The template used to display individual questions, which are dynamically loaded into the Take Survey page.|,
        lastUpdated => 0
    },

    'Section Edit Template' => {
        message => q|Section Edit Template|,
        context => q|The template for adding or editing sections.|,
        lastUpdated => 0
    },

    'Section Edit Template help' => {
        message => q|The template used to display the Section Edit dialog on the Edit Survey page.|,
        lastUpdated => 0
    },

    'Question Edit Template' => {
        message => q|Question Edit Template|,
        context => q|The template for adding or editing questions.|,
        lastUpdated => 0
    },

    'Question Edit Template help' => {
        message => q|The template used to display the Question Edit dialog on the Edit Survey page.|,
        lastUpdated => 0
    },

    'Answer Edit Template' => {
        message => q|Answer Edit Template|,
        context => q|The template for adding or editing answers.|,
        lastUpdated => 0
    },

    'Answer Edit Template help' => {
        message => q|The template used to display the Answer Edit dialog on the Edit Survey page.|,
        lastUpdated => 0
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

    response_feedback_url => {
        message => q|The URL of the individual response feedback page.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    response_id  => {
        message => q|The unique ID of the response.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    response_userId => {
        message => q|The userId of the user that completed the response.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    response_ip => {
        message => q|The IP Address of the user that completed the response.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    response_startDate => {
        message => q|The Start Date of the response.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    response_endDate => {
        message => q|The End Date of the response.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
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

    'response complete' => {
        message => q|Survey Response completed|,
        lastUpdated => 1242180657,
    },

    'response complete help' => {
        message => q|A boolean flag indicating whether the Survey Response completed|,
        lastUpdated => 1242180657,
    },

    'responseId help' => {
        message => q|The unique GUID for the response|,
        lastUpdated => 1242180657,
    },

    'response restart' => {
        message => q|Survey Response restarted|,
        lastUpdated => 1242180657,
    },

    'response restart help' => {
        message => q|A boolean flag indicating whether the Survey Response restarted|,
        lastUpdated => 1242180657,
    },

    'response timeout' => {
        message => q|Survey Response timed out|,
        lastUpdated => 1242180657,
    },

    'response timeout help' => {
        message => q|A boolean flag indicating whether the Survey Response timed out|,
        lastUpdated => 1242180657,
    },

    'response timeout restart' => {
        message => q|Survey Response restarted due to a timeout|,
        lastUpdated => 1242180657,
    },

    'response timeout restart help' => {
        message => q|A boolean flag indicating whether the Survey Response restarted as a result of a timeout|,
        lastUpdated => 1242180657,
    },

    'response endDate help' => {
        message => q|A localised date/time string indicating when the response ended|,
        lastUpdated => 1242180657,
    },

    'survey feedback template variables title' => {
        message => q|Survey Feedback Template Variables|,
        lastUpdated => 1242256111,
    },

    'survey feedback template body' => {
        message => q|All data tagged in survey expressions is also made available as template variables|,
        lastUpdated => 1242180657,
    },

    'survey test results template title' => {
        message => q|Survey Test Results Template Variables|,
        lastUpdated => 1242256111,
    },

    'survey test results template body' => {
        message => q|All TAP::Parser and TAP::Parser::Result fields are exposed as template variables|,
        lastUpdated => 0,
    },

    'maxResponsesSubmitted' => {
        message => q|A boolean indicating whether the current user has reached the maximum number of responses.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'user_canTakeSurvey' => {
        message => q|A boolean indicating whether the current user can take the survey.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'user_canViewReports' => {
        message => q|A boolean indicating whether the current user can view the survey reports.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'lastResponseFeedback help' => {
        message => q|The templated response feedback text|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'user_canEditSurvey' => {
        message => q|A boolean indicating whether the current user can edit the survey.|,
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
        message => q|The ID of the template to show the front page of the Survey.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 1236891448,
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

    'overviewTemplateId' => {
        message => q|The ID of the template used to show the overview screen.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 1168643669,
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
        message => q|The number of times the user can attempt to get the correct answer on each question. 0 means unlimited. The default is 1.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 1238131023,
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
        message => q|A boolean indicating whether the user should see the total number of answers and the number of questions that have already been answered.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'showTimeLimit' => {
        message => q|A boolean indicating whether the number of minutes until the survey times out should be displayed.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'isLastPage' => {
        message => q|A boolean indicating whether this is the last page of the survey.|,
        context => q|Description of a template variable for a template Help page.|,
    },

    'allowBackBtn' => {
        message => q|A boolean indicating whether the back button is allowed.|,
        context => q|Description of a template variable for a template Help page.|,
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
        message => q|The ID of this section/question/answer.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'displayed_id' => {
        message => q|The displayed ID of this section/question/answer.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'text' => {
        message => q|The text of this section/question/answer.|,
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

    'survey section edit template title' => {
        message => q|Survey Section Edit Template|,
        context => q|The title of a template Help page.|,
        lastUpdated => 0,
    },

    'survey question edit template title' => {
        message => q|Survey Question Edit Template|,
        context => q|The title of a template Help page.|,
        lastUpdated => 0,
    },

    'survey answer edit template title' => {
        message => q|Survey Answer Edit Template|,
        context => q|The title of a template Help page.|,
        lastUpdated => 0,
    },

    'title' => {
        message => q|The section's title.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'text' => {
        message => q|The text of this section/question/answer.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'variable' => {
        message => q|A variable name to identify a section/question, so that it can be entered as a goto variable name
in another section.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'goto' => {
        message => q|The section or question with this variable name will be the next to be displayed after this
section/answer.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'questionsPerPage' => {
        message => q|The number loop containing a number/index for each question in this section.|,
        context => q|Description of a template loop for a template Help page.|,
        lastUpdated => 0,
    },

    'index' => {
        message => q|The index/number of a question in this section.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'selected' => {
        message => q|A boolean indicating whether this is the selected number of questions per page.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'questionsOnSectionPage' => {
        message => q|A boolean indicating whether question are displayed on the initial page of this section or on the next page.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'randomizeQuestions' => {
        message => q|A boolean indicating whether the order of the questions in this section should be randomized.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'everyPageTitle' => {
        message => q|A boolean indicating whether the title should be displayed on every page of this section.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'everyPageText' => {
        message => q|A boolean indicating whether the text should be displayed on every page of this section.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'terminal' => {
        message => q|A boolean indicating whether this is a terminal section.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'terminalUrl' => {
        message => q|The url to which the Survey should redirect if this is a terminal section.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'randomizeAnswers' => {
        message => q|A boolean indicating whether this question's answers should be randomized.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'questionType' => {
        message => q|A loop containing the possible question types.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'selected' => {
        message => q|A boolean indicating whether this is the selected question type.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'value' => {
        message => q|The value of this question/answer.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'maxAnswers' => {
        message => q|The maximum number of answers that can be given to this question.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'commentRows' => {
        message => q|The number of rows for the comment textarea.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'commentCols' => {
        message => q|The number of columns for the comment textarea.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'verticalDisplay' => {
        message => q|A boolean indicating whether the answers to this question should be displayed vertically.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'textInButton' => {
        message => q|A boolean indicating whether the buttons for answers to multiple choice questions should display the answer's text inside or above.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'allowComment' => {
        message => q|A boolean indicating whether adding a comment about this question is allowed.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'required' => {
        message => q|A boolean indicating whether this question is required.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'isCorrect' => {
        message => q|A boolean indicating whether this answer is correct.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'verbatim' => {
        message => q|A boolean indicating whether this answer shows an extra text input, where the user can enter a single line of text.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'step' => {
        message => q|The step value of this answer for slider type questions..|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'recordedAnswer' => {
        message => q|The answer that gets recorded for this answer in the database.  This is relevant only for Multiple Choice questions, where the answer that is recorded may be different from what is what is displayed, e.g. 'Yes' could be recorded as '1' and 'No' as '0'.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 1249057018,
    },

    'textCols' => {
        message => q|The number of columns for TextArea questions.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 1241588599,
    },

    'textCols label' => {
        message => q|TextArea Columns|,
        lastUpdated => 1241588599
    },

    'textRows' => {
        message => q|The number of rows for TextArea questions.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 1241588599,
    },

    'textRows label' => {
        message => q|TextArea Rows|,
        lastUpdated => 1241588599
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
        message => q|A boolean that is true if the asset has been configured to show how much progress the user has made in completing this Survey.|,
        context => q|Template variable doc.|,
        lastUpdated => 1249057498,
    },

    'min' => {
        message => q|The min value of this answer for slider type questions.|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'max' => {
        message => q|The max value of this answer for slider type questions..|,
        context => q|Description of a template variable for a template Help page.|,
        lastUpdated => 0,
    },

    'year' => {
        message => q|Year (YYYY):|,
        context => q|Sub-label for "Year Month" question type|,
        lastUpdated => 0,
    },

    'month' => {
        message => q|Month:|,
        context => q|Sub-label for "Year Month" question type|,
        lastUpdated => 0,
    },

    'back' => {
        message => q|Back|,
        context => q|Back button label on Take Survey page|,
        lastUpdated => 0,
    },

    'continue' => {
        message => q|Continue|,
        context => q|Continue button label on Take Survey page|,
        lastUpdated => 0,
    },

    'finish' => {
        message => q|Finish|,
        context => q|Finish button label on Take Survey page|,
        lastUpdated => 0,
    },

    'add a test' => {
        message => q{Add a test},
        lastUpdated => 0,
    },

    'confirm delete test' => {
        message => q{Are you sure you want to delete this test?},
        lastUpdated => 0,
    },

    'test suite' => {
        message => q{Test Suite},
        lastUpdated => 0,
    },

    'edit test' => {
        message => q{Edit Test},
        lastUpdated => 0,
    },

    'run test' => {
        message => q{Run Test},
        lastUpdated => 0,
    },

    'test name' => {
        message => q{Test Name},
        lastUpdated => 0,
    },

    'tests run' => {
        message => q{Tests Run},
        lastUpdated => 0,
    },

    'test name help' => {
        message => q{A descriptive name for this test},
        lastUpdated => 0,
    },

    'test spec' => {
        message => q{Test Spec},
        lastUpdated => 0,
    },

    'test spec help' => {
        message => q{The JSON-encoded specification for your test(s)},
        lastUpdated => 0,
    },

    'run all tests' => {
        message => q{Run All Tests},
        lastUpdated => 0,
    },

    'pass' => {
        message => q{Pass},
        lastUpdated => 0,
    },

    'fail' => {
        message => q{Fail},
        lastUpdated => 0,
    },

    'test results template' => {
        message => q{Test Results Template},
        lastUpdated => 0,
    },

    'test results template help' => {
        message => q{Template used to display individual test and aggregate test results},
        lastUpdated => 0,
    },

    'test results' => {
        message => q{Test Results},
        lastUpdated => 0,
    },

    'test result' => {
        message => q{Test Result},
        lastUpdated => 0,
    },

    'details' => {
        message => q{Details},
        lastUpdated => 0,
    },

    'tests passed' => {
        message => q{Tests Passed},
        lastUpdated => 0,
    },

    'tests failed' => {
        message => q{Tests Failed},
        lastUpdated => 0,
    },

    'start date' => {
        message => q{Start Date},
        lastUpdated => 0,
    },

    'end date' => {
        message => q{End Date},
        lastUpdated => 0,
    },

    'Survey Objects' => {
        message => q{Survey Objects},
        lastUpdated => 0,
    },

    'Make Default Type' => {
        message => q{Make Default Type},
        lastUpdated => 0,
    },

    'Remove Default Type' => {
        message => q{Remove Default Type},
        lastUpdated => 0,
    },

};

1;
