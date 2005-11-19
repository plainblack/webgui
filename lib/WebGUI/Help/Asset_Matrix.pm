package WebGUI::Help::Asset_Matrix;

our $HELP = {
	'matrix add/edit' => {
		title => 'add/edit help title',
		body => 'add/edit help body',
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
