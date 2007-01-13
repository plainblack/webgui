package WebGUI::Help::Asset_StockData;

our $HELP = {
	'stock data add/edit' => {
		title => 'help_add_edit_stocklist_title',
		body => 'help_add_edit_stocklist_body',
		isa => [
			{
				namespace => 'Asset_Wobject',
				tag => 'wobject add/edit',
			},
		],
		fields => [
			{
				title => 'template_label',
				description => 'template_label_description',
				namespace => 'Asset_StockData',
			},
			{
				title => 'display_template_label',
				description => 'display_template_label_description',
				namespace => 'Asset_StockData',
			},
			{
				title => 'default_stock_label',
				description => 'default_stock_label_description',
				namespace => 'Asset_StockData',
			},
			{
				title => 'stock_source',
				description => 'stock_source_description',
				namespace => 'Asset_StockData',
			},
			{
				title => 'failover_label',
				description => 'failover_label_description',
				namespace => 'Asset_StockData',
			},
		],
		related => [
			{
				tag => 'stock list user edit',
				namespace => 'Asset_StockData',
			},
			{
				tag => 'stock list template',
				namespace => 'Asset_StockData',
			},
			{
				tag => 'stock list display template',
				namespace => 'Asset_StockData',
			},
			{
				tag => 'wobjects using',
				namespace => 'Asset_Wobject',
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
				namespace => 'Asset_StockData',
			},
		],
		related => [
			{
				tag => 'stock list display template',
				namespace => 'Asset_StockData',
			},
		],
	},

	'stock list template' => {
		title => 'help_stock_list_template',
		body => 'help_stock_list_template_description',
		isa => [
			{
				tag => 'pagination template variables',
				namespace => 'WebGUI',
			},
			{
				tag => 'stock asset template variables',
				namespace => 'Asset_StockData',
			},
		],
		fields => [
		],
		variables => [
		          {
		            'name' => 'extrasFolder',
		          },
		          {
		            'name' => 'editUrl',
		          },
		          {
		            'name' => 'isVisitor',
		          },
		          {
		            'name' => 'stock.display.url',
		          },
		          {
		            'name' => 'lastUpdate.default',
		          },
		          {
		            'name' => 'lastUpdate.intl',
		          },
		          {
		            'name' => 'lastUpdate.us',
		          },
		          {
		            'name' => 'stocks.loop',
		            'variables' => [
		                             {
		                               'name' => 'stocks.symbol',
		                             },
		                             {
		                               'name' => 'stocks.name',
		                             },
		                             {
		                               'name' => 'stocks.last',
		                             },
		                             {
		                               'name' => 'stocks.high',
		                             },
		                             {
		                               'name' => 'stocks.low',
		                             },
		                             {
		                               'name' => 'stocks.date',
		                             },
		                             {
		                               'name' => 'stocks.time',
		                             },
		                             {
		                               'name' => 'stocks.net',
		                             },
		                             {
		                               'name' => 'stocks.net.isDown',
		                             },
		                             {
		                               'name' => 'stocks.net.isUp',
		                             },
		                             {
		                               'name' => 'stocks.net.noChange',
		                             },
		                             {
		                               'name' => 'stocks.net.icon',
		                             },
		                             {
		                               'name' => 'stocks.p_change',
		                             },
		                             {
		                               'name' => 'stocks.volume',
		                             },
		                             {
		                               'name' => 'stocks.volume.millions',
		                             },
		                             {
		                               'name' => 'stocks.avg_vol',
		                             },
		                             {
		                               'name' => 'stocks.bid',
		                             },
		                             {
		                               'name' => 'stocks.ask',
		                             },
		                             {
		                               'name' => 'stocks.close',
		                             },
		                             {
		                               'name' => 'stocks.open',
		                             },
		                             {
		                               'name' => 'stocks.day_range',
		                             },
		                             {
		                               'name' => 'stocks.year_range',
		                             },
		                             {
		                               'name' => 'stocks.year_high',
		                             },
		                             {
		                               'name' => 'stocks.year_low',
		                             },
		                             {
		                               'name' => 'stocks.eps',
		                             },
		                             {
		                               'name' => 'stocks.pe',
		                             },
		                             {
		                               'name' => 'stocks.div_date',
		                             },
		                             {
		                               'name' => 'stocks.div',
		                             },
		                             {
		                               'name' => 'stocks.div_yield',
		                             },
		                             {
		                               'name' => 'stocks.cap',
		                             },
		                             {
		                               'name' => 'stocks.ex_div',
		                             },
		                             {
		                               'name' => 'stocks.nav',
		                             },
		                             {
		                               'name' => 'stocks.yield',
		                             },
		                             {
		                               'name' => 'stocks.exchange',
		                             },
		                             {
		                               'name' => 'stocks.success',
		                             },
		                             {
		                               'name' => 'stocks.errormsg',
		                             },
		                             {
		                               'name' => 'stocks.method',
		                             }
		                           ],
		          }
		],
		related => [
			{
				tag => 'stock list display template',
				namespace => 'Asset_StockData',
			},
			{
				tag => 'wobject template',
				namespace => 'Asset_Wobject',
			},
		],
	},

	'stock list display template' => {
		title => 'help_stock_list_display_template',
		body => 'help_stock_list_display_template_description',
		isa => [
			{
				tag => 'pagination template variables',
				namespace => 'WebGUI',
			},
			{
				tag => 'stock asset template variables',
				namespace => 'Asset_StockData',
			},
		],
		fields => [
		],
		variables => [
		          {
		            'name' => 'extrasFolder',
		          },
		          {
		            'name' => 'lastUpdate.intl',
		          },
		          {
		            'name' => 'lastUpdate.us',
		          },
		          {
		            'name' => 'stocks.symbol',
		          },
		          {
		            'name' => 'stocks.name',
		          },
		          {
		            'name' => 'stocks.last',
		          },
		          {
		            'name' => 'stocks.high',
		          },
		          {
		            'name' => 'stocks.low',
		          },
		          {
		            'name' => 'stocks.date',
		          },
		          {
		            'name' => 'stocks.time',
		          },
		          {
		            'name' => 'stocks.net',
		          },
		          {
		            'name' => 'stocks.net.isDown',
		          },
		          {
		            'name' => 'stocks.net.isUp',
		          },
		          {
		            'name' => 'stocks.net.noChange',
		          },
		          {
		            'name' => 'stocks.net.icon',
		          },
		          {
		            'name' => 'stocks.p_change',
		          },
		          {
		            'name' => 'stocks.volume',
		          },
		          {
		            'name' => 'stocks.volume.millions',
		          },
		          {
		            'name' => 'stocks.avg_vol',
		          },
		          {
		            'name' => 'stocks.bid',
		          },
		          {
		            'name' => 'stocks.ask',
		          },
		          {
		            'name' => 'stocks.close',
		          },
		          {
		            'name' => 'stocks.open',
		          },
		          {
		            'name' => 'stocks.day_range',
		          },
		          {
		            'name' => 'stocks.year_range',
		          },
		          {
		            'name' => 'stocks.year_high',
		          },
		          {
		            'name' => 'stocks.year_low',
		          },
		          {
		            'name' => 'stocks.eps',
		          },
		          {
		            'name' => 'stocks.pe',
		          },
		          {
		            'name' => 'stocks.div_date',
		          },
		          {
		            'name' => 'stocks.div',
		          },
		          {
		            'name' => 'stocks.div_yield',
		          },
		          {
		            'name' => 'stocks.cap',
		          },
		          {
		            'name' => 'stocks.ex_div',
		          },
		          {
		            'name' => 'stocks.nav',
		          },
		          {
		            'name' => 'stocks.yield',
		          },
		          {
		            'name' => 'stocks.exchange',
		          },
		          {
		            'name' => 'stocks.success',
		          },
		          {
		            'name' => 'stocks.errormsg',
		          },
		          {
		            'name' => 'stocks.method',
		          },
		],
		related => [
			{
				tag => 'stock list template',
				namespace => 'Asset_StockData',
			},
			{
				tag => 'wobject template',
				namespace => 'Asset_Wobject',
			},
		],
	},

	'stock asset template variables' => {
		title => 'stock data asset template variables title',
		body => 'stock data asset template variables body',
		isa => [
			{
				namespace => 'Asset_Wobject',
				tag => 'wobject template variables',
			},
		],
		fields => [
		],
		variables => [
		          {
		            'name' => 'templateId',
		          },
		          {
		            'name' => 'displayTemplateId',
		          },
		          {
		            'name' => 'defaultStocks',
		          },
		          {
		            'name' => 'source',
		          },
		          {
		            'name' => 'failover',
		          },
		],
		related => [
		],
	},

};

1;
