package WebGUI::i18n::English::Survey;

our $I18N = {
	88 => q|Survey Template|,

	91 => q|The following template variables are available in all survey templates.

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

	83 => q|Questions Per Page|,

	84 => q|Max Responses Per User|,

	76 => q|Start Time|,

	80 => q|seconds|,

	85 => q|Questions Per Response|,

	77 => q|End Time|,

	78 => q|Total Time|,

	48 => q|You are not currently eligible to participate in this survey. |,

	47 => q|You have completed this quiz.|,

	46 => q|Thank you for taking the time to complete our survey.|,

	74 => q|Are you certain you wish to delete all the responses?|,

	72 => q|Are you certain you wish to delete this user's responses?|,

	57 => q|Comments|,

	66 => q|Responses|,

	65 => q|Export composite summary.|,

	64 => q|Export responses.|,

	63 => q|Export questions.|,

	62 => q|Export answers.|,

	61 => q|View grade book.|,

	90 => q|Survey Template Common Vars|,

	79 => q|minutes|,

	52 => q|Score|,

	51 => q|Comments?|,

	50 => q|Next|,

	49 => q|You may not take this quiz at this time.|,

	58 => q|Statistical Overview|,

	73 => q|Delete all the responses.|,

	71 => q|Grade Book|,

	70 => q|Individual Responses|,

	69 => q|Delete this user's responses.|,

	67 => q|User|,

	56 => q|View comments.|,

	55 => q|View responses.|,

	54 => q|Percentage|,

	53 => q|Responses|,

	59 => q|View statistical overview.|,

	75 => q|Edit this question.|,

	60 => q|Back to survey.|,

	45 => q|Are you certain you wish to delete this answer and its responses?|,

	44 => q|Are you certain you wish to delete this question, its answers and responses?|,

	34 => q|Agree|,

	33 => q|Strongly Agree|,

	32 => q|False|,

	31 => q|True|,

	27 => q|Add an opinion (agree/disagree) answer scale.|,

	25 => q|Add a true/false answer.|,

	26 => q|Add a frequency (always/never) answer scale.|,

	43 => q|Never|,

	42 => q|Occasionally|,

	41 => q|Frequently|,

	40 => q|Always|,

	39 => q|Not Applicable|,

	38 => q|Strongly Disagree|,

	37 => q|Disagree|,

	36 => q|Somewhat Disagree|,

	35 => q|Somewhat Agree|,

	30 => q|Add a new question.|,

	29 => q|Add a text answer.|,

	24 => q|Add a multiple choice answer.|,

	28 => q|Add a question.|,

	23 => q|Add a new answer.|,

	22 => q|Answer Type|,

	21 => q|Go To|,

	20 => q|Is this answer correct?|,

	19 => q|Answer|,

	18 => q|Edit Answer|,

	17 => q|Edit Question|,

	16 => q|Randomize answers?|,

	15 => q|Allow comment?|,

	14 => q|Question|,

	13 => q|Who can view reports?|,

	12 => q|Who can take the survey?|,

	11 => q|Mode|,

	10 => q|Quiz|,

	9 => q|Survey|,

	8 => q|Question Order|,

	7 => q|Response Driven|,

	6 => q|Random|,

	5 => q|Sequential|,

	3 => q|Survey, Add/Edit|,

	4 => q|Surveys allow you to gather information from your users. In the case of WebGUI surveys, you can also use them to test your user's knowledge.
<p/>

<b>Question Order</b><br/>
The order the questions will be asked. Sequential displays the questions in the order you create them. Random displays the questions randomly. Response driven displays the questions in order based on the responses of the users.
<p/>

<b>Mode</b><br/>
By default the Survey is in survey mode. This allows it to ask questions of your users. However, if you switch to Quiz mode, you can have a self-correcting test of your user's knowledge.
<p/>

<b>Anonymous responses?</b><br/>
Select whether or not the survey will record and display information that can identify a user and their responses.  If left at the default value of "No", the survey will record the user's IP address as well as their WebGUI User ID and Username if logged in.  This info will then be available in the survey's reports.  If set to "Yes", these three fields will contain scrambled data that can not be traced to a particular user.
<p/>

<b>Who can take the survey?</b><br/>
Which users can participate in the survey?
<p/>


<b>Who can view reports?</b><br/>
Who can view the results of the survey?
<p/>


<b>What next?</b><br/>
If you leave this set at its default, then you will add a question directly after adding the survey.
<p/>
|,

	2 => q|Edit Survey|,

	1 => q|Survey|,

	87 => q|Click here to start a new response.|,

	86 => q|Progress|,

	89 => q|The following template variables are available for the Survey.
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

	81 => q|Anonymous responses?|,

	82 => q|Terminate Survey|,

};

1;
