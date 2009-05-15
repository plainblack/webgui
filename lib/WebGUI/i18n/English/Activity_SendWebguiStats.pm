package WebGUI::i18n::English::Activity_SendWebguiStats;

use strict; 

our $I18N = {

	'why to send' => {
		message     => q|You can choose to send information about your WebGUI site to the central webgui.org stats repository. This helps the developers make WebGUI better by understanding the size of the sites out there, how quickly they grow, and what assets they use most. And you have nothing to worry about because no personally identifiable information is sent.|,
		lastUpdated => 0,
		context     => q|A description of the stats program, what we're sending, and why it's important.|
	},

	'would you participate' => {
		message     => q|Would you like to enable or disable participation in the WebGUI community statistics program?|,
		lastUpdated => 0,
		context     => q|A call to action for the statistics program.|
	},

	'topicName' => {
		message     => q|Send WebGUI Statistics|,
		lastUpdated => 0,
		context     => q|The title of the workflow activity.|
	},

	'enable' => {
		message     => q|Enable|,
		lastUpdated => 0,
		context     => q|A link label to start the sending of stats.|
	},

	'disable' => {
		message     => q|Disable|,
		lastUpdated => 0,
		context     => q|A link label to end the sending of stats.|
	},

};

1;
#vim:ft=perl
