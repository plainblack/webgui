package WebGUI::i18n::English::Survey;

our $I18N = {
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
		message => q|The following template variables are available in all survey templates.

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
		message => q|Edit Question|,
		lastUpdated => 1035436091
	},

	'1' => {
		message => q|Survey|,
		lastUpdated => 1033942924
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
		message => q|Surveys allow you to gather information from your users. In the case of WebGUI surveys, you can also use them to test your user's knowledge.
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
		lastUpdated => 1059069492
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

};

1;
