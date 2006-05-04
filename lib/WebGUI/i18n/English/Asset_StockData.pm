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
		message => q|<p>Stock Lists allow users to track stocks on your site.  Data is retrieved from various sources on the internet and displayed in tabluar format.  This application allows any registered user to configure stock lists as well as to set a default stock list for visitors or for users who have not configured one themselves</p>|,
		lastUpdated => 1119066571,
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
		message => q|Choosing yes indicates that all available internet sources will be searched to find each stock.  Choosing no restricts the search to your primary source.  This greatly improves the performance of searchs, but limits your users to stocks available from only once source.|,
		lastUpdated => 1119066250
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

	'help_stock_list_template_description' => {
		message => q|<p>The following describes the list of available template variables for building StockList templates</p>

<p><b>extrasFolder</b><br />
The url to the extras folder containing css files and images used by the Stock List application
</p>

<p><b>editUrl</b><br />
The url to the page where users can customize stocks
</p>

<p><b>isVisitor</b><br />
Whether or not the current user is a visitor.  This returns true if the users is authenticated against the system
</p>

<p><b>stock.display.url</b><br />
General url to the page that displays details for individual stocks.  A stock symbol must be added to the end of this url
</p>

<p><b>lastUpdate.default</b><br />
default date and time format for the date and time stocks were updated by the returning sources
</p>

<p><b>lastUpdate.intl</b><br />
international date and time format for the date and time stocks were updated by the returning sources
</p>

<p><b>lastUpdate.us</b><br />
US date and time format for the date and time stocks were updated by the returning sources
</p>

<p><b>stocks.loop</b><br />
Loop containing all default or personalized stocks
</p>

<blockquote>

<p><b>stocks.symbol</b><br />
Stock Symbol
</p>

<p><b>stocks.name</b><br />
Company or Mutual Fund Name
</p>

<p><b>stocks.last</b><br />
Last Price
</p>

<p><b>stocks.high</b><br />
Highest trade today
</p>

<p><b>stocks.low</b><br />
Lowest trade today
</p>

<p><b>stocks.date</b><br />
Last Trade Date  (MM/DD/YY format)
</p>

<p><b>stocks.time</b><br />
Last Trade Time
</p>

<p><b>stocks.net</b><br />
Net Change
</p>

<p><b>stocks.net.isDown</b><br />
Net Change is negative
</p>

<p><b>stocks.net.isUp</b><br />
Net Change is positive
</p>

<p><b>stocks.net.noChange</b><br />
Net Change is zero
</p>

<p><b>stocks.net.icon</b><br />
Icon associated with net change (up, down, even)
</p>

<p><b>stocks.p_change</b><br />
Percent Change from previous day's close
</p>

<p><b>stocks.volume</b><br />
Day's Volume
</p>

<p><b>stocks.volume.millions</b><br />
Day's Volume In Millions
</p>

<p><b>stocks.avg_vol</b><br />
Average Daily Vol
</p>

<p><b>stocks.bid</b><br />
Bid
</p>

<p><b>stocks.ask</b><br />
Ask
</p>

<p><b>stocks.close</b><br />
Previous Close
</p>

<p><b>stocks.open</b><br />
Today's Open
</p>

<p><b>stocks.day_range</b><br />
Day's Range
</p>

<p><b>stocks.year_range</b><br />
52-Week Range
</p>

<p><b>stocks.year_high</b><br />
52-Week High
</p>

<p><b>stocks.year_low</b><br />
52-Week Low
</p>

<p><b>stocks.eps</b><br />
Earnings per Share
</p>

<p><b>stocks.pe</b><br />
P/E Ratio
</p>

<p><b>stocks.div_date</b><br />
Dividend Pay Date
</p>

<p><b>stocks.div</b><br />
Dividend per Share
</p>

<p><b>stocks.div_yield</b><br />
Dividend Yield
</p>

<p><b>stocks.cap</b><br />
Market Capitalization
</p>

<p><b>stocks.ex_div</b><br />
Ex-Dividend Date.
</p>

<p><b>stocks.nav</b><br />
Net Asset Value
</p>

<p><b>stocks.yield</b><br />
Yield (usually 30 day avg)
</p>

<p><b>stocks.exchange</b><br />
The exchange the information was obtained from.
</p>

<p><b>stocks.success</b><br />
Did the stock successfully return information? (true/false)
</p>

<p><b>stocks.errormsg</b><br />
If success is false, this field may contain the reason why.
</p>

<p><b>stocks.method</b><br />
The module (as could be passed to fetch) which found this information.
</p>

</blockquote>
		|,
		lastUpdated => 1146785833
	},

	'help_stock_list_display_template' => {
		message => q|Stock List Display Template|,
		lastUpdated => 1119066250
	},

	'help_stock_list_display_template_description' => {
		message => q|<p>The following describes the list of available template variables for building StockList templates</p>

<p><b>extrasFolder</b><br />
The url to the extras folder containing css files and images used by the Stock List application
</p>

<p><b>lastUpdate.intl</b><br />
international date and time format for the date and time stocks were updated by the returning sources
</p>

<p><b>lastUpdate.us</b><br />
US date and time format for the date and time stocks were updated by the returning sources
</p>

<p><b>stocks.symbol</b><br />
Stock Symbol
</p>

<p><b>stocks.name</b><br />
Company or Mutual Fund Name
</p>

<p><b>stocks.last</b><br />
Last Price
</p>

<p><b>stocks.high</b><br />
Highest trade today
</p>

<p><b>stocks.low</b><br />
Lowest trade today
</p>

<p><b>stocks.date</b><br />
Last Trade Date  (MM/DD/YY format)
</p>

<p><b>stocks.time</b><br />
Last Trade Time
</p>

<p><b>stocks.net</b><br />
Net Change
</p>

<p><b>stocks.net.isDown</b><br />
Net Change is negative
</p>

<p><b>stocks.net.isUp</b><br />
Net Change is positive
</p>

<p><b>stocks.net.noChange</b><br />
Net Change is zero
</p>

<p><b>stocks.net.icon</b><br />
Icon associated with net change (up, down, even)
</p>

<p><b>stocks.p_change</b><br />
Percent Change from previous day's close
</p>

<p><b>stocks.volume</b><br />
Day's Volume
</p>

<p><b>stocks.volume.millions</b><br />
Day's Volume In Millions
</p>

<p><b>stocks.avg_vol</b><br />
Average Daily Vol
</p>

<p><b>stocks.bid</b><br />
Bid
</p>

<p><b>stocks.ask</b><br />
Ask
</p>

<p><b>stocks.close</b><br />
Previous Close
</p>

<p><b>stocks.open</b><br />
Today's Open
</p>

<p><b>stocks.day_range</b><br />
Day's Range
</p>

<p><b>stocks.year_range</b><br />
52-Week Range
</p>

<p><b>stocks.year_high</b><br />
52-Week High
</p>

<p><b>stocks.year_low</b><br />
52-Week Low
</p>

<p><b>stocks.eps</b><br />
Earnings per Share
</p>

<p><b>stocks.pe</b><br />
P/E Ratio
</p>

<p><b>stocks.div_date</b><br />
Dividend Pay Date
</p>

<p><b>stocks.div</b><br />
Dividend per Share
</p>

<p><b>stocks.div_yield</b><br />
Dividend Yield
</p>

<p><b>stocks.cap</b><br />
Market Capitalization
</p>

<p><b>stocks.ex_div</b><br />
Ex-Dividend Date.
</p>

<p><b>stocks.nav</b><br />
Net Asset Value
</p>

<p><b>stocks.yield</b><br />
Yield (usually 30 day avg)
</p>

<p><b>stocks.exchange</b><br />
The exchange the information was obtained from.
</p>

<p><b>stocks.success</b><br />
Did the stock successfully return information? (true/false)
</p>

<p><b>stocks.errormsg</b><br />
If success is false, this field may contain the reason why.
</p>

<p><b>stocks.method</b><br />
The module (as could be passed to fetch) which found this information.
</p>

		|,
		lastUpdated => 1146786317
	},

};

1;
