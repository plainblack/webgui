package WebGUI::Help::Asset;

use WebGUI::Session;

our $HELP = {

	'asset fields' => {
		title => 'asset fields title',
		body => 'asset fields body',
		related => [
		]
	},

	'metadata manage'=> {
		title => 'content profiling',
		body => 'metadata manage body',
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
