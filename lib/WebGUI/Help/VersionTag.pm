package WebGUI::Help::VersionTag;

our $HELP = {
	'versions manage' => {
		title => 'manage version tags',
		body => 'manage version tags body',
		fields => [
		],
		related => [
			{
				tag => 'commit version tag',
				namespace => 'VersionTag'
			},
			{
				tag => 'manage pending versions',
				namespace => 'VersionTag'
			},
			{
				tag => 'manage committed versions',
				namespace => 'VersionTag'
			},
			{
				tag => 'edit version tag',
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
			{
				tag => 'manage committed versions',
				namespace => 'VersionTag'
			},
			{
				tag => 'edit version tag',
				namespace => 'VersionTag'
			},
		],
	},

	'commit version tag' => {
		title => 'commit version tag',
		body => 'commit version tag body',
		fields => [
                        {
                                title => 'version tag name',
                                description => 'version tag name description commit',
                                namespace => 'VersionTag',
                        },
                        {
                                title => 'comments',
                                description => 'comments description commit',
                                namespace => 'VersionTag',
                        },
		],
		related => [
			{
				tag => 'versions manage',
				namespace => 'VersionTag'
			},
			{
				tag => 'manage committed versions',
				namespace => 'VersionTag'
			},
			{
				tag => 'edit version tag',
				namespace => 'VersionTag'
			},
		],
	},

	'manage committed versions' => {
		title => 'manage committed versions',
		body => 'manage committed versions body',
		fields => [
		],
		related => [
			{
				tag => 'versions manage',
				namespace => 'VersionTag'
			},
			{
				tag => 'manage committed versions',
				namespace => 'VersionTag'
			},
		],
	},

	'edit version tag' => {
		title => 'edit version tag',
		body => 'edit version tag body',
		fields => [
                        {
                                title => 'version tag name',
                                description => 'version tag name description',
                                namespace => 'VersionTag',
                        },
                        {
                                title => 'workflow',
                                description => 'workflow help',
                                namespace => 'VersionTag',
                        },
                        {
                                title => 'group to use',
                                description => 'group to use help',
                                namespace => 'VersionTag',
                        },
		],
		related => [
			{
				tag => 'versions manage',
				namespace => 'VersionTag'
			},
			{
				tag => 'manage committed versions',
				namespace => 'VersionTag'
			},
		],
	},

};

1;  ##All perl modules must return true
