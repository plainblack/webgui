package WebGUI::i18n::English::Asset_StockData;

our $I18N = {

	'template_label' => {
		message => q|Stock List Template|,
		lastUpdated => 1121703035,
	},

	'display_template_label' => {
		message => q|Stock Display Template|,
		lastUpdated => 1121703035,
	},

	'assetName' => {
		message => q|Stock Data|,
		lastUpdated => 1119068745
	},

	'default_stock_label' => {
		message => q|Default Stocks|,
		lastUpdate => 1119068745
	},

	'default_stock_description' => {
		message => q|Enter the default stocks you wish to show visitors and users who do not have their stock lists personalized.  One stock symbol per line|,
		lastUpdate => 1119068745
	},

	'edit_title' => {
		message => q|Edit Stock List|,
		lastUpdate => 1119068745
	},

	'add_button_label' => {
		message => q|Add >>|,
		lastUpdate => 1119068745
	},

	'finish_button_label' => {
		message => q|Finish|,
		lastUpdate => 1119068745
	},

	'symbol_label' => {
		message => q|Stock Symbol|,
		lastUpdate => 1119068745
	},

	'symbol_header' => {
		message => q|Stock Symbol List|,
		lastUpdate => 1119068745
	},

	'symbol_edit_label' => {
		message => q|Add/Edit Stock Symbols|,
		lastUpdate => 1119068745
	},

	'stock_source' => {
		message => q|Primary Source|,
		lastUpdate => 1119068745
	},

	'stock_source_description' => {
		message => q|The Stock List application gets stock quotes from various internet sources.  Choose the primary source you wish to have stocks returned from.  Choosing the market most of your users will choose stocks from greatly improves the performance of stock retrieval|,
		lastUpdate => 1119068745
	},

	'failover_label' => {
		message => q|Use Multiple Sources|,
		lastUpdate => 1119068745
	},

	'failover_description' => {
		message => q|If this option is marked yes, all available stock sources will be searched (starting with the primary source).  If marked no, only the primary source selected will be searched.  This will reduce the number of available stocks available to your users, but will greatly improve the performance of stock retrieval.|,
		lastUpdate => 1119068745
	},

	'no_symbol' => {
		message => q|Symbol %s could not be found from the list available market search sources.|,
		lastUpdate => 1119068745
	},

	'no_symbol_error' => {
		message => q|"You have not entered a stock symbol to add to your list"|,
		lastUpdate => 1119068745
	},

	'symbol_exists' => {
		message => q|Symbol %s is already in your Stock List.|,
		lastUpdate => 1119068745
	},

	'delete_confirm' => {
		message => q|Are you sure you wish to remove %s from your Stock List?|,
		lastUpdate => 1119068745
	},

	#Help Messages
	'help_add_edit_stocklist_title' => {
		message => q|Stock List, Add/Edit|,
		lastUpdated => 1066583066
	},

	'help_add_edit_stocklist_body' => {
		message => q|<p>Stock Lists allow users to track stocks on your site.  Data is retrieved from various sources on the internet and displayed in tabular format.  This application allows any registered user to configure stock lists as well as to set a default stock list for visitors or for users who have not configured one themselves</p>|,
		lastUpdated => 1167190305,
	},

	'template_label_description' => {
		message => q|Select a template from the list to layout your Stock List.  Each Stock List may only use templates with namespace "StockList".|,
		lastUpdated => 1119066250
	},

	'display_template_label_description' => {
		message => q|Select a template from the list to layout the display for individual Stocks.  Stock List Display templates use templates with namespace "StockList/Display".|,
		lastUpdated => 1119066250
	},

	'default_stock_label_description' => {
		message => q|Enter a list of default stocks (one per line) to display in cases where the user is not logged in or the user has not personalized the Stock List|,
		lastUpdated => 1119066250
	},

	'stock_source_description' => {
		message => q|Choose the primary source from which to retrieve stocks.  This is the first internet location the application will search.  Choosing the source that contains stocks which the majority of your users will be watching greatly increases the performance of the Stock List.|,
		lastUpdated => 1119066250
	},

	'failover_label_description' => {
		message => q|Choosing yes indicates that all available internet sources will be searched to find each stock.  Choosing no restricts the search to your primary source.  This greatly improves the performance of searches, but limits your users to stocks available from only once source.|,
		lastUpdated => 1167190356
	},

	'help_add_edit_stock_title' => {
		message => q|Stock List, Add/Edit Stocks|,
		lastUpdated => 1119066250
	},

	'help_add_edit_stock_description' => {
		message => q|<p>The stock edit page allows you to customize your stock lists.  Add to, remove from, and order your personalized list of stocks to display on the site</p>|,
		lastUpdated => 1119066250
	},

	'symbol_label_description' => {
		message => q|Enter a valid stock symbol.  If your symbol cannot be found, contact your administrator.  It is likely that your site restricts stocks to a certain market (US market, European market, etc)|,
		lastUpdated => 1119066250
	},

	'help_stock_list_template' => {
		message => q|Stock List Template|,
		lastUpdated => 1119066250
	},

	'extrasFolder' => {
		message => q|The url to the extras folder containing css files and images used by the Stock List application|,
		lastUpdated => 1149565312,
	},

	'editUrl' => {
		message => q|The url to the page where users can customize stocks|,
		lastUpdated => 1149565312,
	},

	'isVisitor' => {
		message => q|Whether or not the current user is a visitor.  This returns true if the users is authenticated against the system|,
		lastUpdated => 1149565312,
	},

	'stock.display.url' => {
		message => q|General url to the page that displays details for individual stocks.  A stock symbol must be added to the end of this url|,
		lastUpdated => 1149565312,
	},

	'lastUpdate.default' => {
		message => q|default date and time format for the date and time stocks were updated by the returning sources|,
		lastUpdated => 1149565312,
	},

	'lastUpdate.intl' => {
		message => q|international date and time format for the date and time stocks were updated by the returning sources|,
		lastUpdated => 1149565312,
	},

	'lastUpdate.us' => {
		message => q|US date and time format for the date and time stocks were updated by the returning sources|,
		lastUpdated => 1149565312,
	},

	'stocks.loop' => {
		message => q|Loop containing all default or personalized stocks|,
		lastUpdated => 1149565312,
	},

	'stocks.symbol' => {
		message => q|Stock Symbol|,
		lastUpdated => 1149565312,
	},

	'stocks.name' => {
		message => q|Company or Mutual Fund Name|,
		lastUpdated => 1149565312,
	},

	'stocks.last' => {
		message => q|Last Price|,
		lastUpdated => 1149565312,
	},

	'stocks.high' => {
		message => q|Highest trade today|,
		lastUpdated => 1149565312,
	},

	'stocks.low' => {
		message => q|Lowest trade today|,
		lastUpdated => 1149565312,
	},

	'stocks.date' => {
		message => q|Last Trade Date  (MM/DD/YY format)|,
		lastUpdated => 1149565312,
	},

	'stocks.time' => {
		message => q|Last Trade Time|,
		lastUpdated => 1149565312,
	},

	'stocks.net' => {
		message => q|Net Change|,
		lastUpdated => 1149565312,
	},

	'stocks.net.isDown' => {
		message => q|Net Change is negative|,
		lastUpdated => 1149565312,
	},

	'stocks.net.isUp' => {
		message => q|Net Change is positive|,
		lastUpdated => 1149565312,
	},

	'stocks.net.noChange' => {
		message => q|Net Change is zero|,
		lastUpdated => 1149565312,
	},

	'stocks.net.icon' => {
		message => q|Icon associated with net change (up, down, even)|,
		lastUpdated => 1149565312,
	},

	'stocks.p_change' => {
		message => q|Percent Change from previous day's close|,
		lastUpdated => 1149565312,
	},

	'stocks.volume' => {
		message => q|Day's Volume|,
		lastUpdated => 1149565312,
	},

	'stocks.volume.millions' => {
		message => q|Day's Volume In Millions|,
		lastUpdated => 1149565312,
	},

	'stocks.avg_vol' => {
		message => q|Average Daily Vol|,
		lastUpdated => 1149565312,
	},

	'stocks.bid' => {
		message => q|Bid|,
		lastUpdated => 1149565312,
	},

	'stocks.ask' => {
		message => q|Ask|,
		lastUpdated => 1149565312,
	},

	'stocks.close' => {
		message => q|Previous Close|,
		lastUpdated => 1149565312,
	},

	'stocks.open' => {
		message => q|Today's Open|,
		lastUpdated => 1149565312,
	},

	'stocks.day_range' => {
		message => q|Day's Range|,
		lastUpdated => 1149565312,
	},

	'stocks.year_range' => {
		message => q|52-Week Range|,
		lastUpdated => 1149565312,
	},

	'stocks.year_high' => {
		message => q|52-Week High|,
		lastUpdated => 1149565312,
	},

	'stocks.year_low' => {
		message => q|52-Week Low|,
		lastUpdated => 1149565312,
	},

	'stocks.eps' => {
		message => q|Earnings per Share|,
		lastUpdated => 1149565312,
	},

	'stocks.pe' => {
		message => q|P/E Ratio|,
		lastUpdated => 1149565312,
	},

	'stocks.div_date' => {
		message => q|Dividend Pay Date|,
		lastUpdated => 1149565312,
	},

	'stocks.div' => {
		message => q|Dividend per Share|,
		lastUpdated => 1149565312,
	},

	'stocks.div_yield' => {
		message => q|Dividend Yield|,
		lastUpdated => 1149565312,
	},

	'stocks.cap' => {
		message => q|Market Capitalization|,
		lastUpdated => 1149565312,
	},

	'stocks.ex_div' => {
		message => q|Ex-Dividend Date.|,
		lastUpdated => 1149565312,
	},

	'stocks.nav' => {
		message => q|Net Asset Value|,
		lastUpdated => 1149565312,
	},

	'stocks.yield' => {
		message => q|Yield (usually 30 day avg)|,
		lastUpdated => 1149565312,
	},

	'stocks.exchange' => {
		message => q|The exchange the information was obtained from.|,
		lastUpdated => 1149565312,
	},

	'stocks.success' => {
		message => q|Did the stock successfully return information? (true/false)|,
		lastUpdated => 1149565312,
	},

	'stocks.errormsg' => {
		message => q|If success is false, this field may contain the reason why.|,
		lastUpdated => 1149565312,
	},

	'stocks.method' => {
		message => q|The module (as could be passed to fetch) which found this information.|,
		lastUpdated => 1149565312,
	},

	'help_stock_list_template_description' => {
		message => q|<p>The following describes the list of available template variables for building StockList templates</p>
		|,
		lastUpdated => 1149565354
	},

	'help_stock_list_display_template' => {
		message => q|Stock List Display Template|,
		lastUpdated => 1119066250
	},

	'help_stock_list_display_template_description' => {
		message => q|<p>The following describes the list of available template variables for building StockList templates</p>
		|,
		lastUpdated => 1149567007
	},

	'stock data asset template variables title' => {
		message => q|Stock Data Asset Template Variables|,
		lastUpdated => 1164841146
	},

	'stock data asset template variables body' => {
		message => q|Every asset provides a set of variables to most of its
templates based on the internal asset properties.  Some of these variables may
be useful, others may not.|,
		lastUpdated => 1168646697
	},

	'templateId' => {
		message => q|The ID of the template used to show the main screen for this Asset.|,
		lastUpdated => 1168646698
	},

	'displayTemplateId' => {
		message => q|The ID of the template used to show the user details about their stocks.|,
		lastUpdated => 1168646698
	},

	'defaultStocks' => {
		message => q|The default list of stocks if the user has not chosen any.  This is a string separated by newlines.|,
		lastUpdated => 1168646896
	},

	'source' => {
		message => q|The internet source to be used as the source of stock information.|,
		lastUpdated => 1168646986
	},

	'failover' => {
		message => q|A conditional indicating whether or not failover has been set for this Stock Data Asset.|,
		lastUpdated => 1168646986
	},

};

1;
