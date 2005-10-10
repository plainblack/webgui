package WebGUI::i18n::English::Macro_GroupAdd;

our $I18N = {

	'macroName' => {
		message => q|Group Add|,
		lastUpdated => 1128838422,
	},

	'group add title' => {
		message => q|Group Add Macro|,
		lastUpdated => 1112466408,
	},

	'group add body' => {
		message => q|

<b>&#94;GroupAdd();</b><br>
Using this macro you can allow users to add themselves to a group. The first parameter is the name of the group this user should be added to. The second parameter is a text string for the user to click on to add themselves to this group. The third parameter allows you to specify the name of a template in the Macro/GroupAdd namespace to replace the default template.  These variables are available in the template:
<p/>
<b>group.url</b><br/>
The URL with the action to add the user to the group.
<p/>
<b>group.text</b><br/>
The supplied text string for the user to click on.

<p>
<b>NOTE:</b> If the user is not logged in, or or already belongs to the group, or the group is not set to allow auto adds, then no link will be displayed.
<p>

|,
		lastUpdated => 1112466919,
	},
};

1;
