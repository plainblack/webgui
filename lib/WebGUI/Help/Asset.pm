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
                        {
                                title => '99',
                                description => '99 description',
                                namespace => 'Asset',
                        },
                        {
                                title => '411',
                                description => '411 description',
                                namespace => 'Asset',
                        },
                        {
                                title => '104',
                                description => '104 description',
                                namespace => 'Asset',
                        },
                        {
                                title => '412',
                                description => '412 description',
                                namespace => 'Asset',
                        },
                        {
                                title => '886',
                                description => '886 description',
                                namespace => 'Asset',
                        },
                        {
                                title => '940',
                                description => '940 description',
                                namespace => 'Asset',
                        },
                        {
                                title => 'encrypt page',
                                description => 'encrypt page description',
                                namespace => 'Asset',
                        },
                        {
                                title => '108',
                                description => '108 description',
                                namespace => 'Asset',
                        },
                        {
                                title => '872',
                                description => '872 description',
                                namespace => 'Asset',
                        },
                        {
                                title => '871',
                                description => '871 description',
                                namespace => 'Asset',
                        },
                        {
                                title => '412',
                                description => '412 description',
                                namespace => 'Asset',
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
                        },
                        {
                                title => 'make prototype',
                                description => 'make prototype description',
                                namespace => 'Asset',
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
				namespace => 'Wobject',
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
                                namespace => 'Wobject',
                        },
                ],
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
