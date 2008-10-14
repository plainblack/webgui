package WebGUI::i18n::English::Image_Graph_Pie;
use strict;

our $I18N = {
	'radius' => {
		message => q|Radius|,
		lastUpdated => 1131394070,
	},
	'radius description' => {
		message => q|The radius of the pie in pixels.|,
		lastUpdated => 1131394070,
	},

	'pie height' => {
		message => q|Pie height|,
		lastUpdated => 1131394070,
	},
	'pie height description' => {
		message => q|The thickness of the pie in pixel. Has no effect in
case of 2d pies.|,
		lastUpdated => 1131394070,
	},

	'tilt angle' => {
		message => q|Tilt angle|,
		lastUpdated => 1131394070,
	},
	'tilt angle description' => {
		message => q|The angle the pi should be rotated over the x-axis.
Valid values are 0 - 90 degrees. Entering 0 degrees will result in a 2d pie.|,
		lastUpdated => 1131394070,
	},

	'start angle' => {
		message => q|Start angle|,
		lastUpdated => 1131394070,
	},
	'start angle description' => {
		message => q|The initial angle in degrees the first pie slic
has. The east (rightmost) side of the pie is at 0 degrees.|,
		lastUpdated => 1131394070,
	},

	'shade sides' => {
		message => q|Shade sides?|,
		lastUpdated => 1131394070,
	},
	'shade sides description' => {
		message => q|Setting this option to yes will cause the sides and
rim of pie to be drawn with a darker color than the top and bottom.|,
		lastUpdated => 1131394070,
	},

	'stick length' => {
		message => q|Stick length|,
		lastUpdated => 1131394070,
	},
	'stick length description' => {
		message => q|The length og the stick connecting the labels and
the pie. To disable label sticks, please set this value to zero.|,
		lastUpdated => 1131394070,
	},

	'stick offset' => {
		message => q|Stick offset|,
		lastUpdated => 1131394070,
	},
	'stick offset description' => {
		message => q|The distance between the label sticks and the pie
surface. If the stick length is set to 0, this option won't have any effect.|,
		lastUpdated => 1131394070,
	},

	'stick color' => {
		message => q|Stick color|,
		lastUpdated => 1131394070,
	},
	'stick color description' => {
		message => q|The color of the label sticks.|,
		lastUpdated => 1131394070,
	},

	'label position' => {
		message => q|Label position|,
		lastUpdated => 1131394070,
	},
	'label position description' => {
		message => q|The alignment of the labels (and label sticks)
relative to the sidewalls of the pie. Choose 'top' for alignment with the top
plane, 'bottom' for alignment with the bottom plane and 'center' for a position
in between.|,
		lastUpdated => 1131394070,
	},

	'top' => {
		message => q|Top|,
		lastUpdated => 1131394070,
	},
	'bottom' => {
		message => q|Bottom|,
		lastUpdated => 1131394070,
	},
	'center' => {
		message => q|Center|,
		lastUpdated => 1131394070,
	},

	'pie mode' => {
		message => q|Pie mode|,
		lastUpdated => 1131394070,
	},
	'pie mode description' => {
		message => q|The way the pie should be drawn. You can choose
between 'normal' and 'stepped'. Choosing the former option will result in a
vanilla pie, while the latter option will draw each consecutive pie slice with a
smaller thickness, causing a 'stairs' effect.|,
		lastUpdated => 1131394070,
	},

	'normal' => {
		message => q|Normal|,
		lastUpdated => 1131394070,
	},
	'stepped' => {
		message => q|Stepped|,
		lastUpdated => 1131394070,
	},
};

1;
