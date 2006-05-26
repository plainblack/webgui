package WebGUI::Help::Asset;


our $HELP = {

	'asset fields' => {
		title => 'asset fields title',
		body => 'asset fields body',
		fields => [
                        {
                                title => 'asset id',
                                namespace => 'Asset',
                                description => 'asset id description'
                        },
                        {	#title
                                title => '99',
                                description => '99 description',
                                namespace => 'Asset',
                        },
                        {	#menuTitle
                                title => '411',
                                description => '411 description',
                                namespace => 'Asset',
				uiLevel => 1,
                        },
                        {	#url
                                title => '104',
                                description => '104 description',
                                namespace => 'Asset',
				uiLevel => 3,
                        },
                        {	#isHidden
                                title => '886',
                                description => '886 description',
                                namespace => 'Asset',
				uiLevel => 6,
                        },
                        {	#newWindow
                                title => '940',
                                description => '940 description',
                                namespace => 'Asset',
				uiLevel => 9,
                        },
                        {
                                title => 'encrypt page',
                                description => 'encrypt page description',
                                namespace => 'Asset',
				uiLevel => 6,
                        },
                        {	#ownerUserId
                                title => '108',
                                description => '108 description',
                                namespace => 'Asset',
				uiLevel => 6,
                        },
                        {	#groupIdView
                                title => '872',
                                description => '872 description',
                                namespace => 'Asset',
				uiLevel => 6,
                        },
                        {	#groupIdEdit
                                title => '871',
                                description => '871 description',
                                namespace => 'Asset',
				uiLevel => 6,
                        },
                        {	#synopsis
                                title => '412',
                                description => '412 description',
                                namespace => 'Asset',
				uiLevel => 3,
                        },
                        {
                                title => 'extra head tags',
                                description => 'extra head tags description',
                                namespace => 'Asset',
                        },
                        {
                                title => 'make package',
                                description => 'make package description',
                                namespace => 'Asset',
				uiLevel => 7,
                        },
                        {
                                title => 'make prototype',
                                description => 'make prototype description',
                                namespace => 'Asset',
				uiLevel => 9,
                        },
		],
		related => [
			{
				tag => 'template language',
				namespace => 'Asset_Template',
			},
		]
	},

	'asset template' => {
		title => 'asset template title',
		body => 'asset template body',
		fields => [
		],
		related => [
		]
	},

	'asset toolbar' => {
		title => 'asset toolbar title',
		body => 'asset toolbar body',
		fields => [
                        {
                                title => 'Delete',
                                description => 'Delete help',
                                namespace => 'Icon',
				uiLevel => 1,
                        },
                        {
                                title => 'Edit',
                                description => 'Edit help',
                                namespace => 'Icon',
				uiLevel => 1,
                        },
                        {
                                title => 'locked',
                                description => 'locked help',
                                namespace => 'Icon',
				uiLevel => 5,
                        },
                        {
                                title => 'Cut',
                                description => 'Cut help',
                                namespace => 'Icon',
				uiLevel => 1,
                        },
                        {
                                title => 'Copy',
                                description => 'Copy help',
                                namespace => 'Icon',
				uiLevel => 1,
                        },
                        {
                                title => 'Create Shortcut',
                                description => 'Create Shortcut help',
                                namespace => 'Icon',
				uiLevel => 5,
                        },
                        {
                                title => 'Class Icon',
                                description => 'Class Icon help',
                                namespace => 'Asset',
                        },
                        {
                                title => 'lock',
                                description => 'lock help',
                                namespace => 'Asset',
				uiLevel => 5,
                        },
                        {
                                title => 'change url',
                                description => 'change url help',
                                namespace => 'Asset',
				uiLevel => 9,
                        },
                        {
                                title => 'Export',
                                description => 'Export help',
                                namespace => 'Icon',
				uiLevel => 9,
                        },
                        {
                                title => 'edit branch',
                                description => 'edit branch help',
                                namespace => 'Asset',
				uiLevel => 9,
                        },
                        {
                                title => 'promote',
                                description => 'promote help',
                                namespace => 'Asset',
				uiLevel => 3,
                        },
                        {
                                title => 'demote',
                                description => 'demote help',
                                namespace => 'Asset',
				uiLevel => 3,
                        },
                        {
                                title => 'manage',
                                description => 'manage help',
                                namespace => 'Asset',
				uiLevel => 5,
                        },
                        {
                                title => 'revisions',
                                description => 'revisions help',
                                namespace => 'Asset',
				uiLevel => 5,
                        },
                        {
                                title => 'view',
                                description => 'view help',
                                namespace => 'Asset',
				uiLevel => 1,
                        },
		],
		related => [
			{
				tag => 'change url',
				namespace => 'Asset',
			},
			{
				tag => 'page export',
				namespace => 'Asset',
			},
			{
				tag => 'manage versions',
				namespace => 'Asset',
			},
		]
	},

	'edit branch' => {
		title => 'edit branch',
		body => 'edit branch body',
		fields => [
                        {
                                title => '104',
                                description => 'edit branch url help',
                                namespace => 'Asset',
				uiLevel => 9,
                        },
                        {
                                title => '886',
                                description => '886 description',
                                namespace => 'Asset',
				uiLevel => 6,
                        },
                        {
                                title => '940',
                                description => '940 description',
                                namespace => 'Asset',
				uiLevel => 6,
                        },
                        {
                                title => '174',
                                description => '174 description',
                                namespace => 'Asset_Wobject',
				uiLevel => 5,
                        },
                        {
                                title => '1073',
                                description => '1073 description',
                                namespace => 'Asset_Wobject',
				uiLevel => 5,
                        },
                        {
                                title => '1079',
                                description => '1079 description',
                                namespace => 'Asset_Wobject',
				uiLevel => 5,
                        },
                        {
                                title => 'encrypt page',
                                description => 'encrypt page description',
                                namespace => 'Asset',
				uiLevel => 6,
                        },
                        {
                                title => '108',
                                description => '108 description',
                                namespace => 'Asset',
				uiLevel => 6,
                        },
                        {
                                title => '872',
                                description => '872 description',
                                namespace => 'Asset',
				uiLevel => 6,
                        },
                        {
                                title => '871',
                                description => '871 description',
                                namespace => 'Asset',
				uiLevel => 6,
                        },
                        {
                                title => 'extra head tags',
                                description => 'extra head tags description',
                                namespace => 'Asset',
				uiLevel => 5,
                        },
		],
		related => [
		]
	},

	'change url' => {
		title => 'change url',
		body => 'change url body',
		fields => [
                        {
                                title => '104',
                                description => '104 description',
                                namespace => 'Asset',
                        },
                        {
                                title => 'confirm change',
                                description => 'confirm change url message',
                                namespace => 'Asset',
                        },
		],
		related => [
		]
	},

	'content prototypes' => {
		title => 'prototype using title',
		body => 'prototype using body',
		fields => [
		],
		related => [
		]
	},

	'page export' => {
                title => 'Page Export',
                body => 'Page Export body',
		fields => [
                        {
                                title => 'Depth',
                                description => 'Depth description',
                                namespace => 'Asset',
                        },
                        {
                                title => 'Export as user',
                                description => 'Export as user description',
                                namespace => 'Asset',
                        },
                        {
                                title => 'directory index',
                                description => 'directory index description',
                                namespace => 'Asset',
                        },
                        {
                                title => 'Extras URL',
                                description => 'Extras URL description',
                                namespace => 'Asset',
                        },
                        {
                                title => 'Uploads URL',
                                description => 'Uploads URL description',
                                namespace => 'Asset',
                        },
		],
                related => [
                ],
	},

	'metadata manage'=> {
		title => 'content profiling',
		body => 'metadata manage body',
		fields => [
		],
		related => [
			{
				tag => 'metadata edit property',
				namespace => 'Asset'
			},
			{
				tag => 'aoi hits',
				namespace => 'Macro_AOIHits'
			},
			{
				tag => 'aoi rank',
				namespace => 'Macro_AOIRank'
			},
			{
				tag => 'wobject add/edit',
				namespace => 'Asset_Wobject',
			},
		],
	},

	'metadata edit property' => {
                title => 'metadata edit property',
                body => 'metadata edit property body',
		fields => [
                        {
                                title => 'Field name',
                                description => 'Field Name description',
                                namespace => 'Asset',
                        },
                        {
                                title => '85',
                                description => 'Metadata Description description',
                                namespace => 'Asset',
                        },
                        {
                                title => '486',
                                description => 'Data Type description',
                                namespace => 'Asset',
                        },
                        {
                                title => '487',
                                description => 'Possible Values description',
                                namespace => 'Asset',
                        },
		],
                related => [
			{
				tag => 'metadata manage',
				namespace => 'Asset'
                        },
			{
				tag => 'aoi hits',
				namespace => 'Macro_AOIHits'
			},
			{
				tag => 'aoi rank',
				namespace => 'Macro_AOIRank'
			},
                        {
                                tag => 'wobject add/edit',
                                namespace => 'Asset_Wobject',
                        },
                ],
        },

	'manage versions' => {
		title => 'committed versions',
		body => 'manage versions body',
		fields => [
		],
		related => [
		]
	},

	'asset list' => {
		title => 'asset list title',
		body => 'asset list body',
		fields => [
		],
		related => sub {
				my ($session) = @_;
				map {
					my ($namespace) = /::(\w+)$/;
					my $tag = $namespace;
					$tag =~ s/([a-z])([A-Z])/$1 $2/g;  #Separate studly caps
					$tag =~ s/([A-Z]+(?![a-z]))/$1 /g; #Separate acronyms
					$tag = lc $tag;
					$namespace = join '', 'Asset_', $namespace;
					{ tag => "$tag add/edit",
					namespace => $namespace }
				}
					grep { $_ } ##Filter out empty entries
						@{ $session->config->get("assets") },
						@{ $session->config->get("assetContainers") },
						@{ $session->config->get("utilityAssets") },
			   },
	},

};

1;
