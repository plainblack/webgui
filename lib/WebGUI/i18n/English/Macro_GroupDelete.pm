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

	'group delete body' => {
		message => q|

<b>&#94;GroupDelete();</b><br>
Using this macro you can allow users to delete themselves from a group. The first parameter is the name of the group this user should be deleted from. The second parameter is a text string for the user to click on to delete themselves from this group. The third parameter allows you to specify the name of a template in the Macro/GroupDelete namespace to replace the default template.  These variables are available in the template:
<p/>
<b>group.url</b><br/>
The URL with the action to add the user to the group.
<p/>
<b>group.text</b><br/>
The supplied text string for the user to click on.


<p>
<b>NOTE:</b> If the user is not logged in or the user does not belong to the group, or the group is not set to allow auto deletes, then no link will be displayed.
<p>

|,
		lastUpdated => 1112466919,
	},
};

1;
