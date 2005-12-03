package WebGUI::Help::StockData;

our $HELP = {
	'stock data add/edit' => {
		title => 'help_add_edit_stocklist_title',
		body => 'help_add_edit_stocklist_body',
		fields => [
			{
				title => 'template_label',
				description => 'template_label_description',
				namespace => 'StockList',
			},
			{
				title => 'display_template_label',
				description => 'display_template_label_description',
				namespace => 'StockList',
			},
			{
				title => 'default_stock_label',
				description => 'default_stock_label_description',
				namespace => 'StockList',
			},
			{
				title => 'stock_source',
				description => 'stock_source_description',
				namespace => 'StockList',
			},
			{
				title => 'failover_label',
				description => 'failover_label_description',
				namespace => 'StockList',
			},
		],
		related => [
			{
				tag => 'stock list user edit',
				namespace => 'StockList'
			},
			{
				tag => 'stock list template',
				namespace => 'StockList'
			},
			{
				tag => 'stock list display template',
				namespace => 'StockList'
			},
			{
				tag => 'wobjects using',
				namespace => 'Wobject'
			},
			{
				tag => 'asset fields',
				namespace => 'Asset'
			},
		],
	},
	'stock list user edit' => {
		title => 'help_add_edit_stock_title',
		body => 'help_add_edit_stock_description',
		fields => [
			{
				title => 'symbol_label',
				description => 'symbol_label_description',
				namespace => 'StockList',
			},
		],
		related => [
			{
				tag => 'stock list display template',
				namespace => 'StockList'
			},
		]
	},
	'stock list template' => {
		title => 'help_stock_list_template',
		body => 'help_stock_list_template_description',
		fields => [
		],
		related => [
			{
				tag => 'stock list display template',
				namespace => 'StockList'
			},
			{
				tag => 'pagination template variables',
				namespace => 'WebGUI'
			},
			{
				tag => 'wobject template',
				namespace => 'Wobject'
			}
		]
	},
	'stock list display template' => {
		title => 'help_stock_list_display_template',
		body => 'help_stock_list_display_template_description',
		fields => [
		],
		related => [
			{
				tag => 'stock list template',
				namespace => 'StockList'
			},
			{
				tag => 'pagination template variables',
				namespace => 'WebGUI'
			},
			{
				tag => 'wobject template',
				namespace => 'Wobject'
			}
		]
	},
};

1;
