package WebGUI::Help::Asset;

use WebGUI::Session;

our $HELP = {

	'asset fields' => {
		title => 'asset fields title',
		body => 'asset fields body',
		fields => [
                        {
                                title => 'asset id',
                                description => 'asset id description'
                        },
                        {
                                title => '99',
                                description => '99 description'
                        },
                        {
                                title => '411',
                                description => '411 description'
                        },
                        {
                                title => '104',
                                description => '104 description'
                        },
                        {
                                title => '412',
                                description => '412 description'
                        },
                        {
                                title => '886',
                                description => '886 description'
                        },
                        {
                                title => '940',
                                description => '940 description'
                        },
                        {
                                title => 'encrypt page',
                                description => 'encrypt page description'
                        },
                        {
                                title => '497',
                                description => '497 description'
                        },
                        {
                                title => '498',
                                description => '498 description'
                        },
                        {
                                title => '108',
                                description => '108 description'
                        },
                        {
                                title => '872',
                                description => '872 description'
                        },
                        {
                                title => '871',
                                description => '871 description'
                        },
                        {
                                title => '412',
                                description => '412 description'
                        },
                        {
                                title => 'extra head tags',
                                description => 'extra head tags description'
                        },
                        {
                                title => 'make package',
                                description => 'make package description'
                        },
                        {
                                title => 'make prototype',
                                description => 'make prototype description'
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
                title => 'Metadata, Edit property',
                body => 'metadata edit property body',
		fields => [
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
		related => [ map {
				 my ($namespace) = /::(\w+)$/;
				 my $tag = $namespace;
				 $tag =~ s/([a-z])([A-Z])/$1 $2/g;  #Separate studly caps
				 $tag =~ s/([A-Z]+(?![a-z]))/$1 /g; #Separate acronyms
				 $tag = lc $tag;
				 $namespace = join '', 'Asset_', $namespace;
				 { tag => "$tag add/edit",
				   namespace => $namespace }
			     }
		             @{ $session{config}{assets} }, @{ $session{config}{assetContainers} }
			   ],
	},

};

1;
