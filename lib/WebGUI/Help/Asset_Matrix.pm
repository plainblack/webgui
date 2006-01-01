package WebGUI::Help::Asset_Matrix;

our $HELP = {
	'matrix add/edit' => {
		title => 'add/edit help title',
		body => 'add/edit help body',
		fields => [
                        {
                                title => 'categories',
                                description => 'categories description',
                                namespace => 'Asset_Matrix',
                        },
                        {
                                title => 'max comparisons',
                                description => 'max comparisons description',
                                namespace => 'Asset_Matrix',
                        },
                        {
                                title => 'max comparisons privileged',
                                description => 'max comparisons privileged description',
                                namespace => 'Asset_Matrix',
                        },
                        {
                                title => 'detail template',
                                description => 'detail template description',
                                namespace => 'Asset_Matrix',
                        },
                        {
                                title => 'rating timeout',
                                description => 'rating timeout description',
                                namespace => 'Asset_Matrix',
                        },
                        {
                                title => 'rating timeout privileged',
                                description => 'rating timeout privileged description',
                                namespace => 'Asset_Matrix',
                        },
                        {
                                title => 'group to add',
                                description => 'group to add description',
                                namespace => 'Asset_Matrix',
                        },
                        {
                                title => 'privileged group',
                                description => 'privileged group description',
                                namespace => 'Asset_Matrix',
                        },
                        {
                                title => 'rating group',
                                description => 'rating group description',
                                namespace => 'Asset_Matrix',
                        },
                        {
                                title => 'main template',
                                description => 'main template description',
                                namespace => 'Asset_Matrix',
                        },
                        {
                                title => 'rating detail template',
                                description => 'rating detail template description',
                                namespace => 'Asset_Matrix',
                        },
                        {
                                title => 'search template',
                                description => 'search template description',
                                namespace => 'Asset_Matrix',
                        },
                        {
                                title => 'compare template',
                                description => 'compare template description',
                                namespace => 'Asset_Matrix',
                        },
		],
		related => [
			{
				tag => 'search template',
				namespace => 'Asset_Matrix'
			},
			{
				tag => 'compare template',
				namespace => 'Asset_Matrix'
			},
			{
				tag => 'ratings detail template',
				namespace => 'Asset_Matrix'
			},
			{
				tag => 'main template',
				namespace => 'Asset_Matrix'
			},
			{
				tag => 'listing detail template',
				namespace => 'Asset_Matrix'
			},
		],
	},
	'search template' => {
		title => 'search template help title',
		body => 'search template help body',
		related => [
			{
				tag => 'matrix add/edit',
				namespace => 'Asset_Matrix'
			},
			{
				tag => 'compare template',
				namespace => 'Asset_Matrix'
			},
			{
				tag => 'ratings detail template',
				namespace => 'Asset_Matrix'
			},
			{
				tag => 'main template',
				namespace => 'Asset_Matrix'
			},
			{
				tag => 'listing detail template',
				namespace => 'Asset_Matrix'
			},
		],
	},
	'compare template' => {
		title => 'comparison template help title',
		body => 'comparison template help body',
		related => [
			{
				tag => 'matrix add/edit',
				namespace => 'Asset_Matrix'
			},
			{
				tag => 'search template',
				namespace => 'Asset_Matrix'
			},
			{
				tag => 'ratings detail template',
				namespace => 'Asset_Matrix'
			},
			{
				tag => 'main template',
				namespace => 'Asset_Matrix'
			},
			{
				tag => 'listing detail template',
				namespace => 'Asset_Matrix'
			},
		],
	},
	'ratings detail template' => {
		title => 'ratings detail template help title',
		body => 'ratings detail template help body',
		related => [
			{
				tag => 'matrix add/edit',
				namespace => 'Asset_Matrix'
			},
			{
				tag => 'search template',
				namespace => 'Asset_Matrix'
			},
			{
				tag => 'compare template',
				namespace => 'Asset_Matrix'
			},
			{
				tag => 'main template',
				namespace => 'Asset_Matrix'
			},
			{
				tag => 'listing detail template',
				namespace => 'Asset_Matrix'
			},
		],
	},
	'main template' => {
		title => 'matrix template help title',
		body => 'matrix template help body',
		related => [
			{
				tag => 'matrix add/edit',
				namespace => 'Asset_Matrix'
			},
			{
				tag => 'search template',
				namespace => 'Asset_Matrix'
			},
			{
				tag => 'compare template',
				namespace => 'Asset_Matrix'
			},
			{
				tag => 'ratings detail template',
				namespace => 'Asset_Matrix'
			},
			{
				tag => 'listing detail template',
				namespace => 'Asset_Matrix'
			},
		],
	},
	'listing detail template' => {
		title => 'detail template help title',
		body => 'detail template help body',
		related => [
			{
				tag => 'matrix add/edit',
				namespace => 'Asset_Matrix'
			},
			{
				tag => 'search template',
				namespace => 'Asset_Matrix'
			},
			{
				tag => 'compare template',
				namespace => 'Asset_Matrix'
			},
			{
				tag => 'ratings detail template',
				namespace => 'Asset_Matrix'
			},
			{
				tag => 'main template',
				namespace => 'Asset_Matrix'
			},
		],
	},
};

1;
