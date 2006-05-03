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

<p><b>&#94;GroupAdd();</b><br />
Using this macro you can allow users to add themselves to a group. The first parameter is the name of the group this user should be added to. The second parameter is a text string for the user to click on to add themselves to this group. The third parameter allows you to specify the name of a template in the Macro/GroupAdd namespace to replace the default template.  These variables are available in the template:</p>

<p><b>group.url</b><br />
The URL with the action to add the user to the group.
</p>

<p><b>group.text</b><br />
The supplied text string for the user to click on.
</p>

<p><b>NOTE:</b> All these conditions must be met for the link to be displayed:
</p>

<div>
<ul>
<li>User must be logged in.</li>
<li>User must not already belong to the group.</li>
<li>The group must exist.</li>
<li>The group must be set up to allow auto adds.</li>
</ul>
</div>
|,
		lastUpdated => 1146679385,
	},
};

1;
