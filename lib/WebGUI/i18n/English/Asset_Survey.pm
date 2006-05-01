package WebGUI::i18n::English::Asset_Survey;

our $I18N = {

	'100' => {
		message => q|Add a HTML Area Answer|,
		lastUpdated => 1122296097
	},
	
	'101' => {
	        message => q|Add a Text Area Answer|,
	        lastUpdated => 1122296097
        },

	'102' => {
	        message => q|Section Name|,
	        lastUpdated => 1122296097
        },
        
        '103' => {
                message => q|Survey Section, Add/Edit|,
                lastUpdated => 1122296097
        },

        '104' => {
                message => q|Add a new section|,
                lastUpdated => 1122296097
        },

        '105' => {
                message => q|Are you sure you wish to delete this section?|,
                lastUpdated => 1122296097
        },

        '106' => {
                message => q|Section|,
                lastUpdated => 1122296097
        },

        '107' => {
                message => q|None|,
                lastUpdated => 1122296097
        },


	'32' => {
		message => q|False|,
		lastUpdated => 1037498832
	},


	'33' => {
		message => q|Strongly Agree|,
		lastUpdated => 1037498857
	},

	'21' => {
		message => q|Go To|,
		lastUpdated => 1035506057
	},

	'90' => {
		message => q|Survey Template Common Vars|,
		lastUpdated => 1078223067
	},

	'63' => {
		message => q|Export questions.|,
		lastUpdated => 1037556710
	},

	'71' => {
		message => q|Grade Book|,
		lastUpdated => 1037573252
	},

	'7' => {
		message => q|Response Driven|,
		lastUpdated => 1033944729
	},

	'26' => {
		message => q|Add a frequency (always/never) answer scale.|,
		lastUpdated => 1035947924
	},

	'80' => {
		message => q|seconds|,
		lastUpdated => 1038789602
	},

	'18' => {
		message => q|Edit Answer|,
		lastUpdated => 1035436102
	},

	'72' => {
		message => q|Are you certain you wish to delete this user's responses?|,
		lastUpdated => 1037573460
	},

	'16' => {
		message => q|Randomize answers?|,
		lastUpdated => 1035429242
	},

	'44' => {
		message => q|Are you certain you wish to delete this question, its answers and responses?|,
		lastUpdated => 1035951626
	},

	'55' => {
		message => q|View responses.|,
		lastUpdated => 1037555778
	},

	'27' => {
		message => q|Add an opinion (agree/disagree) answer scale.|,
		lastUpdated => 1035948010
	},

	'84' => {
		message => q|Max Responses Per User|,
		lastUpdated => 1075639389
	},

	'74' => {
		message => q|Are you certain you wish to delete all the responses?|,
		lastUpdated => 1037574455
	},

	'57' => {
		message => q|Comments|,
		lastUpdated => 1037556124
	},

	'61' => {
		message => q|View grade book.|,
		lastUpdated => 1037556642
	},

	'20' => {
		message => q|Is this answer correct?|,
		lastUpdated => 1035436321
	},

	'89' => {
		message => q|The following template variables are available for the Survey.
<p>

<b>question.add.url</b><br>
The URL to add a new question to the survey.
<p>

<b>question.add.label</b><br>
The default label for question.add.url.
<p>

<b>user.canTakeSurvey</b><br>
A boolean indicating whether the current user has the rights to take the survey.
<p>

<b>form.header</b><br>
The required form elements that go at the top of the survey questions.
<p>

<b>form.footer</b><br>
The required form elements that go after the survey questions.
<p>

<b>form.submit</b><br>
The default submit button for the survey response.
<p>

<b>questions.sofar.label</b><br>
The default label for indicating how many questions have been answered to this point in the survey.
<p>

<b>start.newresponse.label</b><br>
The default label for start.newresponse.url.
<p>

<b>start.newresponse.url</b><br>
The URL to start a new response to the survey after the user has already taken the survey once.
<p>

<b>thanks.survey.label</b><br>
A message thanking the user for completing the survey.
<p>

<b>thanks.quiz.label</b><br>
A message thanking the user for completing the quiz.
<p>

<b>questions.total</b><br>
The total number of questions in the survey.
<p>

<b>questions.correct.count.label</b><br>
The default label for questions.correct.count.
<p>

<b>questions.correct.percent.label</b><br>
The default label for questions.correct.percent.
<p>

<b>mode.isSurvey</b><br>
A boolean indicating whether we are in survey mode or quiz mode.
<p>

<b>survey.noprivs.label</b><br>
A message telling the user that they do not have the privileges necessary  to take this survey.
<p>

<b>quiz.noprivs.label</b><br>
A message telling the user that they do not have the privileges necessary to take the quiz.
<p>

<b>response.id</b><br>
The unique id for the current response for this user.
<p>


<b>response.count</b><br>
The number of responses this user has provided for this survey.
<p>


<b>user.isFirstResponse</b><br>
A boolean indicating whether this is the first response for this user.
<p>

<b>user.canRespondAgain</b><br>
A boolean indicating whether the user is allowed to respond to this survey again.
<p>

<b>questions.sofar.count</b><br>
The number of questions that have been answered to this point in the survey.
<p>

<b>questions.correct.count</b><br>
The number of questions the user has correct in the quiz to this point.
<p>

<b>questions.correct.percent</b><br>
The percentage of questions that the user has correct in the quiz to this point.
<p>

<b>response.isComplete</b><br>
A boolean indicating whether the user has answered all of the questions for this survey response.
<p>


<b>question_loop</b><br>
A loop which contains the questions for this survey response.
<p>


<blockquote>
<b>question.question</b><br>
The survey question itself.
<p>

<b>question.allowComment</b><br>
A boolean indicating whether this question allows comments or not.
<p>

<b>question.id</b><br>
The unique id for this question.
<p>

<b>question.comment.field</b><br>
The form field to enter comments for this question.
<p>

<b>question.comment.label</b><br>
The default label for question.comment.field.
<p>

<b>question.answer.field</b><br>
The form field containing the possible answers for this question.
<p>

</blockquote>


<b>question.edit_loop</b><br>
A loop containing all the questions in the survey with edit controls.
<p>

<blockquote>
<b>question.edit.controls</b><br>
A toolbar to use to edit this question.
<p>

<b>question.edit.question</b><br>
The question to be edited.
<p>

<b>question.edit.id</b><br>
The unique id for this question.
<p>

</blockquote>
|,
		lastUpdated => 1078223096
	},

	'10' => {
		message => q|Quiz|,
		lastUpdated => 1033949566
	},

	'31' => {
		message => q|True|,
		lastUpdated => 1037498842
	},

	'35' => {
		message => q|Somewhat Agree|,
		lastUpdated => 1037498927
	},

	'11' => {
		message => q|Mode|,
		lastUpdated => 1033949647
	},

	'91' => {
		message => q|The following template variables are available in all survey templates.<p>

<b>user.canViewReports</b><br>
A boolean indicating whether the user has the privileges to view survey reports.
<p>

<b>delete.all.responses.url</b><br>
This URL will delete all of the responses to this survey.
<p>

<b>delete.all.responses.label</b><br>
The default label for delete.all.responses.url.
<p>

<b>export.answers.url</b><br>
The URL to create a tab delimited file containing all of the answers to the questions in this survey.
<p>

<b>export.answers.label</b><br>
The default label for export.answers.url.
<p>

<b>export.questions.url</b><br>
The URL to create a tab delimited file containing all of the questions in this survey.
<p>

<b>export.questions.label</b><br>
The default label for export.questions.url.
<p>

<b>export.responses.url</b><br>
The  URL to create a tab delimited file containing all of the responses to the questions in this survey.
<p>

<b>export.responses.label</b><br>
The default label for export.responses.url
<p>

<b>export.composite.url</b><br>
The URL to create a tab delimited file containing a composite view of all of the data in this survey.
<p>

<b>export.composite.label</b><br>
The default label for export.composite.url.
<p>

<b>report.gradebook.url</b><br>
The URL to view the gradebook report for this quiz.
<p>

<b>report.gradebook.label</b><br>
The default label for report.gradebook.url.
<p>

<b>report.overview.url</b><br>
The URL to view statistical overview report for this survey.
<p>

<b>report.overview.label</b><br>
The default label for report.overview.url.
<p>

<b>survey.url</b><br>
The URL to view the survey. Usually used to get back to the survey after looking at a report.
<p>

<b>survey.label</b><br>
The default label for survey.url.
<p>
|,
		lastUpdated => 1078223067
	},

	'78' => {
		message => q|Total Time|,
		lastUpdated => 1038782125
	},

	'48' => {
		message => q|You are not currently eligible to participate in this survey. |,
		lastUpdated => 1037499301
	},

	'87' => {
		message => q|Click here to start a new response.|,
		lastUpdated => 1075639972
	},

	'77' => {
		message => q|End Time|,
		lastUpdated => 1038782119
	},

	'29' => {
		message => q|Add a text answer.|,
		lastUpdated => 1035874640
	},

	'65' => {
		message => q|Export composite summary.|,
		lastUpdated => 1037556821
	},

	'50' => {
		message => q|Next|,
		lastUpdated => 1037499410
	},

	'39' => {
		message => q|Not Applicable|,
		lastUpdated => 1037574804
	},

	'64' => {
		message => q|Export responses.|,
		lastUpdated => 1037556721
	},

	'12' => {
		message => q|Who can take the survey?|,
		lastUpdated => 1033949789
	},

	'41' => {
		message => q|Frequently|,
		lastUpdated => 1037574786
	},

	'58' => {
		message => q|Statistical Overview|,
		lastUpdated => 1037556179
	},

	'15' => {
		message => q|Allow comment?|,
		lastUpdated => 1035429212
	},

	'81' => {
		message => q|Anonymous responses?|,
		lastUpdated => 1059069492
	},

	'52' => {
		message => q|Score|,
		lastUpdated => 1037506007
	},

	'60' => {
		message => q|Back to survey.|,
		lastUpdated => 1037556626
	},

	'56' => {
		message => q|View comments.|,
		lastUpdated => 1037555787
	},

	'45' => {
		message => q|Are you certain you wish to delete this answer and its responses?|,
		lastUpdated => 1035951913
	},

	'66' => {
		message => q|Responses|,
		lastUpdated => 1037557127
	},

	'73' => {
		message => q|Delete all the responses.|,
		lastUpdated => 1037573893
	},

	'86' => {
		message => q|Progress|,
		lastUpdated => 1075639914
	},

	'19' => {
		message => q|Answer|,
		lastUpdated => 1035436296
	},

	'76' => {
		message => q|Start Time|,
		lastUpdated => 1038782111
	},

	'62' => {
		message => q|Export answers.|,
		lastUpdated => 1037556697
	},

	'54' => {
		message => q|Percentage|,
		lastUpdated => 1037555267
	},

	'67' => {
		message => q|User|,
		lastUpdated => 1037558860
	},

	'70' => {
		message => q|Individual Responses|,
		lastUpdated => 1037573240
	},

	'2' => {
		message => q|Edit Survey|,
		lastUpdated => 1033943825
	},

	'17' => {
		message => q|Survey Question, Add/Edit|,
		lastUpdated => 1110068088,
	},

	'assetName' => {
		message => q|Survey|,
		lastUpdated => 1128832543
	},

	'88' => {
		message => q|Survey Template|,
		lastUpdated => 1078223096
	},

	'30' => {
		message => q|Add a new question.|,
		lastUpdated => 1035944708
	},

	'82' => {
		message => q|Terminate Survey|,
		lastUpdated => 1068901816
	},

	'25' => {
		message => q|Add a true/false answer.|,
		lastUpdated => 1035947960
	},

	'28' => {
		message => q|Add a question.|,
		lastUpdated => 1035872173
	},

	'83' => {
		message => q|Questions Per Page|,
		lastUpdated => 1075639327
	},

	'75' => {
		message => q|Edit this question.|,
		lastUpdated => 1038778819
	},

	'40' => {
		message => q|Always|,
		lastUpdated => 1037574725
	},

	'14' => {
		message => q|Question|,
		lastUpdated => 1035428770
	},

	'69' => {
		message => q|Delete this user's responses.|,
		lastUpdated => 1037573082
	},

	'59' => {
		message => q|View statistical overview.|,
		lastUpdated => 1037556614
	},

	'49' => {
		message => q|You may not take this quiz at this time.|,
		lastUpdated => 1037499363
	},

	'24' => {
		message => q|Add a multiple choice answer.|,
		lastUpdated => 1035874502
	},

	'53' => {
		message => q|Responses|,
		lastUpdated => 1037555255
	},

	'79' => {
		message => q|minutes|,
		lastUpdated => 1038789595
	},

	'42' => {
		message => q|Occasionally|,
		lastUpdated => 1037574859
	},

	'22' => {
		message => q|Answer Type|,
		lastUpdated => 1035864413
	},

	'46' => {
		message => q|Thank you for taking the time to complete our survey.|,
		lastUpdated => 1037499049
	},

	'13' => {
		message => q|Who can view reports?|,
		lastUpdated => 1033949863
	},

	'23' => {
		message => q|Add a new answer.|,
		lastUpdated => 1035864494
	},

	'6' => {
		message => q|Random|,
		lastUpdated => 1033944643
	},

	'85' => {
		message => q|Questions Per Response|,
		lastUpdated => 1075639549
	},

	'3' => {
		message => q|Survey, Add/Edit|,
		lastUpdated => 1038890559
	},

	'36' => {
		message => q|Somewhat Disagree|,
		lastUpdated => 1037498872
	},

	'9' => {
		message => q|Survey|,
		lastUpdated => 1033949540
	},

	'51' => {
		message => q|Comments?|,
		lastUpdated => 1037499470
	},

	'47' => {
		message => q|You have completed this quiz.|,
		lastUpdated => 1037499131
	},

	'8' => {
		message => q|Question Order|,
		lastUpdated => 1033949393
	},

	'38' => {
		message => q|Strongly Disagree|,
		lastUpdated => 1037498903
	},

	'4' => {
		message => q|<p>Surveys allow you to gather information from your users. In the case of WebGUI surveys, you can also use them to test your user's knowledge.</p>
<p>Surveys are Wobjects and Assets, so they have the properties of both.  Survery have these unique properties:</p>
|,
		lastUpdated => 1119849727
	},

        'view template description' => {
                message => q|This template is used to display the Survey itself.|,
                lastUpdated => 1146455534,
        },

        'response template description' => {
                message => q|This template is used to display the questions and answers for the user to pick.|,
                lastUpdated => 1146455536,
        },

        'gradebook template description' => {
                message => q|This template is used to display, on a user-by-user basis how many questions they got
correct and what percentage answered were correct.|,
                lastUpdated => 1146455538,
        },

        'overview template description' => {
                message => q|This template is used to display a statistical overview of the all responses to the Survey.|,
                lastUpdated => 1146455541,
        },

        '8 description' => {
                message => q|The order the questions will be asked. Sequential displays the questions in the order you create them. Random displays the questions randomly. Response driven displays the questions in order based on the responses of the users.|,
                lastUpdated => 1146455543,
        },

        '83 description' => {
                message => q|The number of questions that will be displayed per page.  The default is 1.|,
                lastUpdated => 1146455544,
        },

        '11 description' => {
                message => q|By default the Survey is in survey mode. This allows it to ask questions of your users. However, if you switch to Quiz mode, you can have a self-correcting test of your user's knowledge.|,
                lastUpdated => 1146455546,
        },

        '81 description' => {
                message => q|Select whether or not the survey will record and display information that can identify a user and their responses.  If left at the default value of "No", the survey will record the user's IP address as well as their WebGUI User ID and Username if logged in.  This info will then be available in the survey's reports.  If set to "Yes", these three fields will contain scrambled data that can not be traced to a particular user.|,
                lastUpdated => 1146455548,
        },

        '84 description' => {
                message => q|The number of times the user can attempt to get the correct answer on each question.  The default is 1.|,
                lastUpdated => 1146455549,
        },

        '85 description' => {
                message => q|How many questions are given to each user?|,
                lastUpdated => 1146455551,
        },

        '12 description' => {
                message => q|Which users can participate in the survey?|,
                lastUpdated => 1146455552,
        },

        '13 description' => {
                message => q|Who can view the results of the survey?|,
                lastUpdated => 1146455553,
        },

        'what next description' => {
                message => q|After creating a new Survey, you may either starting adding questions or go back to the page where
the survey was added.|,
                lastUpdated => 1146455560,
        },


	'34' => {
		message => q|Agree|,
		lastUpdated => 1037498914
	},

	'37' => {
		message => q|Disagree|,
		lastUpdated => 1037498886
	},

	'43' => {
		message => q|Never|,
		lastUpdated => 1037574752
	},

	'5' => {
		message => q|Sequential|,
		lastUpdated => 1033944535
	},

	'cannot delete the last answer' => {
		message=>q|You cannot delete the last answer from a question. Every question must have at least one answer.|,
		lastUpdated=>1083944535,
		context=>q|This message is displayed when a user is trying to delete the last answer from a survey question.|	
	},

	'1087' => {
		message => q|Gradebook Report Template|,
		lastUpdated => 1078513217
	},

	'1088' => {
		message => q|The following template variables are available in the survey's gradebook report:
<p>

<b>title</b><br>
The default title of the report.
<p>

<b>question.count</b><br>
The number of questions in the survey.
<p>

<b>response.user.label</b><br>
The default label for response.user.name.
<p>

<b>response.count.label</b><br>
The default label for response.count.correct.
<p>

<b>response.percent.label</b><br>
The default label for response.percent.
<p>

<b>response_loop</b><br>
A loop containing a list of responses.
<p>

<blockquote>

<b>response.url</b><br>
The URL to view this response.
<p>

<b>response.user.name</b><br>
The username of the user that gave this response.
<p>

<b>response.count.correct</b><br>
The total number of questions that this user got correct.
<p>

<b>response.percent</b><br>
The percentage of correct questions.
<p>

</blockquote>|,
		lastUpdated => 1078513217
	},

	'1089' => {
		message => q|Survey Response Template|,
		lastUpdated => 1078515839
	},

	'1090' => {
		message => q|The following are the variables available to display the individual response.
<p>

<b>title</b><br>
The default title for this report.
<p>

<b>delete.url</b><br>
The URL to delete this response.
<p>

<b>delete.label</b><br>
The default label for delete.url.
<p>

<b>start.date.label</b><br>
The default label for start.date.human.
<p>

<b>start.date.epoch</b><br>
The epoch representation of when the user started the survey response.
<p>

<b>start.date.human</b><br>
The human representation of the date when the user started the response.
<p>

<b>start.time.human</b><br>
The human representation of the time when the user started the response.
<p>

<b>end.date.label</b><br>
The default label for end.date.human.
<p>


<b>end.date.epoch</b><br>
The epoch representation of the date when the user completed this response.
<p>

<b>end.date.human</b><br>
The human representation of the date when the user completed this response.
<p>

<b>end.time.human</b><br>
The human representation of the time when the user completed this response.
<p>

<b>duration.label</b><br>
The default label for the duration.
<p>

<b>duration.minutes</b><br>
The number of minutes it took to complete the survey.
<p>

<b>duration.minutes.label</b><br>
A label for "minutes".
<p>


<b>duration.seconds</b><br>
The remainder seconds the duration.minutes calculations.
<p>

<b>duration.seconds.label</b><br>
A label for "seconds".
<p>


<b>answer.label</b><br>
The default label for question.answer.
<p>


<b>response.label</b><br>
The default label for question.label.
<p>

<b>comment.label</b><br>
The default label for question.comment.
<p>

<b>question_loop</b><br>
A loop that includes the list of questions in this response.
<p>

<blockquote>

<b>question</b><br>
The question itself.
<p>

<b>question.id</b><br>
The unique identifier for this question.
<p>

<b>question.isRadioList</b><br>
A boolean indicating whether this question's answers are a radio list.
<p>

<b>question.response</b><br>
The user's response to this question.
<p>

<b>question.comment</b><br>
The user's comment on this question (if any).
<p>

<b>question.isCorrect</b><br>
A boolean indicating whether the user got this question correct.
<p>


<b>question.answer</b><br>
The correct answer for this question.
<p>


</blockquote>|,
		lastUpdated => 1078515839
	},

	'1091' => {
		message => q|Statistical Overview Report Template|,
		lastUpdated => 1078517114
	},

	'1092' => {
		message => q|The following are the variables available in this template:
<p>

<b>title</b><br>
The default title for this report.
<p>

<b>answer.label</b><br>
The default label for answer_loop.
<p>

<b>response.count.label</b><br>
The default label for response.count.
<p>

<b>response.percent.label</b><br>
The default label for response.percent.
<p>

<b>show.responses.label</b><br>
The default label that will display responses.
<p>

<b>show.comments.label</b><br>
The default label that will display comments.
<p>

<b>question_loop</b><br>
A loop containing questions.
<p>

<blockquote>

<b>question</b><br>
The question itself.
<p>

<b>question.id</b><br>
The unique identifier for this question.
<p>

<b>question.isRadioList</b><br>
A boolean indicating whether the answer for this question is a radio list.
<p>

<b>question.response.total</b><br>
The total number of responses for this answer.
<p>

<b>question.allowComment</b><br>
A boolean indicating whether this question allows comments.
<p>

<b>answer_loop</b><br>
A loop containing the answers and responses for this question.
<p>
<blockquote>

<b>answer.isCorrect</b><br>
A boolean indicating whether this answer is marked correct.
<p>

<b>answer</b><br>
The answer itself.
<p>

<b>answer.response.count</b><br>
The total number of responses given for this answer.
<p>

<b>answer.response.percent</b><br>
The percent of responses to this question that went to this answer.
<p>


<b>comment_loop</b><br>
A loop that contains all of the comments for this answer.
<p>

<blockquote>
<b>answer.comment</b><br>
A comment.
<p>


</blockquote>

</blockquote>


</blockquote>|,
		lastUpdated => 1078517114
	},

	'overview template' => {
		message => q|Overview template|,
		lastUpdated => 0,
		context => q|Form label indicating the overview template.|
	},

	'gradebook template' => {
		message => q|Gradebook template|,
		lastUpdated => 0,
		context => q|Form label indicating the gradebook template.|
	},
	
	'response template' => {
		message => q|Response template|,
		lastUpdated => 0,
		context => q|Form label indicating the response template.|
	},

	'view template' => {
		message => q|View template|,
		lastUpdated => 0,
		context => q|Form label indicating the response template.|
	},

	'745' => {
		message => q|Go back to the page.|,
		lastUpdated => 1110006174,
	},

	'45' => {
		message => q|No, I made a mistake.|,
		lastUpdated => 1110006259,
	},

        'question add/edit body' => {
		message => q|WebGUI's Survey Wobject supplies you with many kinds of questions, such as multiple choice, boolean (a or b, such as Yes/No, True/False, etc.), and various kinds of essay answers.  The order of the questions can also be changed after they are entered.|,
		lastUpdated => 1132357445,
	},

        '14 description' => {
                message => q|This is the question that the user will be asked.|,
                lastUpdated => 1146455568,
        },

        '15 description' => {
                message => q|If set to Yes, then the user will be allowed to add a comment to their response to this question.|,
                lastUpdated => 1146455578,
        },

        '16 description' => {
                message => q|If set to Yes, then the answers will be shuffled for each user.|,
                lastUpdated => 1146455581,
        },

        '21 description' => {
                message => q|Used to define the question that follows this one when the question order for the survey
is set to "response".|,
                lastUpdated => 1146455589,
        },

        'what next question description' => {
                message => q|After defining the question, you may supply an answer:
<ul>
<li>Multiple Choice</li>
<li>Text</li>
<li>Frequency</li>
<li>Opinion</li>
<li>Or you may return to the survey</li>
</ul>|,
                lastUpdated => 1146455594,
        },

	'744' => {
		message => q|What next?|,
		lastUpdated => 1035864828
	},

	'answer add/edit body' => {
                message => q|Depending on the type of question, you may be able to supply more than one answer for each question.|,
                lastUpdated => 1132356704,
	},

        '19 description' => {
                message => q|The answer to this question.|,
                lastUpdated => 1119993924,
        },

        '20 description' => {
                message => q|If you have set the Survey to Quiz mode, then you can define if this answer
is correct or not.|,
                lastUpdated => 1119993924,
        },

        'what next answer description' => {
                message => q|After defining the answer, you can add an answer to this question, addi
		another question, edit the current question or go back to the page containing the
		Survey|,
                lastUpdated => 1146455600,
        },

};

1;
