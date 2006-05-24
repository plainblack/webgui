package WebGUI::Help::VersionTag;

our $HELP = {
	'versions manage' => {
		title => 'manage version tags',
		body => 'manage version tags body',
		fields => [
		],
		related => [
			{
				tag => 'manage pending versions',
				namespace => 'VersionTag'
			},
		],
	},

	'manage pending versions' => {
		title => 'manage pending versions',
		body => 'manage pending versions body',
		fields => [
		],
		related => [
			{
				tag => 'versions manage',
				namespace => 'VersionTag'
			},
		],
	},

};

1;  ##All perl modules must return true
