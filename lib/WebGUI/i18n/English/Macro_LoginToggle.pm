package WebGUI::i18n::English::Macro_LoginToggle;

our $I18N = {

	'macroName' => {
		message => q|Login Toggle|,
		lastUpdated => 1128839147,
	},

	'login toggle title' => {
		message => q|Login Toggle Macro|,
		lastUpdated => 1112466408,
	},

	'login toggle body' => {
		message => q|
<po><b>&#94;LoginToggle; or &#94;LoginToggle();</b><br />
Displays a "Login" or "Logout" message depending upon whether the user is logged in or not. You can optionally specify other labels like this: &#94;LoginToggle("Click here to log in.","Click here to log out.");. You can also use the special case &#94;LoginToggle(linkonly); to return only the URL with no label.
</p>

<p><b>toggle.url</b><br />
The URL to login or logout.
</p>

<p><b>toggle.text</b><br />
The Internationalized label for logging in or logging out (depending on the state of the macro), or the text that you supply to the macro.
</p>

|,
		lastUpdated => 1146759379,
	},

	'716' => {
		message => q|Login|,
		lastUpdated => 1031514049
	},

	'717' => {
		message => q|Logout|,
		lastUpdated => 1031514049
	},

};

1;
