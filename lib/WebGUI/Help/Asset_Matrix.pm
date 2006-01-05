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
	'listing add/edit' => {
		title => 'listing add/edit help title',
		body => 'listing add/edit help body',
		fields => [
                        {
                                title => 'product name',
                                description => 'product name description',
                                namespace => 'Asset_Matrix',
                        },
                        {
                                title => 'version number',
                                description => 'version number description',
                                namespace => 'Asset_Matrix',
                        },
                        {
                                title => 'product url',
                                description => 'product url description',
                                namespace => 'Asset_Matrix',
                        },
                        {
                                title => 'manufacturer name',
                                description => 'manufacturer name description',
                                namespace => 'Asset_Matrix',
                        },
                        {
                                title => 'manufacturer url',
                                description => 'manufacturer url description',
                                namespace => 'Asset_Matrix',
                        },
                        {
                                title => 'description',
                                description => 'description description',
                                namespace => 'Asset_Matrix',
                        },
                        {
                                title => 'listing maintainer',
                                description => 'listing maintainer description',
                                namespace => 'Asset_Matrix',
                        },
                        {
                                title => 'matrix specific fields',
                                description => 'matrix specific fields description',
                                namespace => 'Asset_Matrix',
                        },
		],
		related => [
			{
				tag => 'matrix add/edit',
				namespace => 'Asset_Matrix'
			},
		],
	},
	'field add/edit' => {
		title => 'field add/edit help title',
		body => 'field add/edit help body',
		fields => [
                        {
                                title => 'field name',
                                description => 'field name description',
                                namespace => 'Asset_Matrix',
                        },
                        {
                                title => 'field label',
                                description => 'field label description',
                                namespace => 'Asset_Matrix',
                        },
                        {
                                title => 'field type',
                                description => 'field type description',
                                namespace => 'Asset_Matrix',
                        },
                        {
                                title => 'field description',
                                description => 'field description description',
                                namespace => 'Asset_Matrix',
                        },
                        {
                                title => 'default value',
                                description => 'default value description',
                                namespace => 'Asset_Matrix',
                        },
                        {
                                title => 'category',
                                description => 'category description',
                                namespace => 'Asset_Matrix',
                        },
		],
		related => [
			{
				tag => 'matrix add/edit',
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
