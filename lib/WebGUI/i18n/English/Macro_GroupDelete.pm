package WebGUI::i18n::English::Macro_GroupDelete;

our $I18N = {

	'macroName' => {
		message => q|Group Delete|,
		lastUpdated => 1128838485,
	},

	'group delete title' => {
		message => q|Group Delete Macro|,
		lastUpdated => 1112466408,
	},

	'group.url' => {
		message => q|The URL with the action to add the user to the group.|,
		lastUpdated => 1149217736,
	},

	'group.text' => {
		message => q|The supplied text string for the user to click on.|,
		lastUpdated => 1149217736,
	},

	'group delete body' => {
		message => q|
<p><b>&#94;GroupDelete();</b><br />
Using this macro you can allow users to delete themselves from a group. The first parameter is the name of the group this user should be deleted from. The second parameter is a text string for the user to click on to delete themselves from this group. The third parameter allows you to specify the name of a template in the Macro/GroupDelete namespace to replace the default template.</p>

<p><b>NOTE:</b> All these conditions must be met for the link to be displayed:</p>

<div>
<ul>
<li>User must be logged in.</li>
<li>User must be a member of the group.</li>
<li>The group must exist.</li>
<li>The group must be set up to allow auto deletes.</li>
</ul>
</div>

<p>>These variables are available in the template:</p>

|,
		lastUpdated => 1149217752,
	},
};

1;
