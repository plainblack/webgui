package WebGUI::i18n::English::HttpProxy;

our $I18N = {
	10 => q|HTTP Proxy, Add/Edit|,

	11 => q|The HTTP Proxy wobject is a very powerful tool. It enables you to embed external sites and applications into your site. For example, if you have a web mail system that you wish your staff could access through the intranet, then you could use the HTTP Proxy to accomplish that.

<p>

<b>URL</b><br>
The starting URL for the proxy.
<p>

<b>Follow redirects?</b><br>
Sometimes the URL to a page, is actually a redirection to another page. Do you wish to follow those redirections when they occur?
<p>

<b>Rewrite urls?</b><br>
Switch this to No if you want to deeplink an external page.
<p>

<b>Timeout</b><br>
The amount of time (in seconds) that WebGUI should wait for a connection before giving up on an external page.
<p>

<b>Remove style?</b><br>
Do you wish to remove the stylesheet from the proxied content in favor of the stylesheet from your site?
<p>

<b>Filter Content</b><br>
Choose the level of HTML filtering you wish to apply to the proxied content.
<p>

<b>Search for</b><br>
A search string used as starting point. Use this when you want to display only a part of the proxied content. Content before this point is not displayed
<p>

<b>Stop at</b><br>
A search string used as ending point. Content after this point is not displayed.
<p>
<i>Note: The <b>Search for</b> and <b>Stop at</b> strings are included in the content. You can change this by editing the template for HttpProxy.</i>
<p>

<b>Allow proxying of other domains?</b><br>
If you proxy a site like Yahoo! that links to other domains, do you wish to allow the user to follow the links to those other domains, or should the proxy stop them as they try to leave the original site you specified?
<p>
|,

	3 => q|HTTP Proxy|,

	2 => q|Edit HTTP Proxy|,

	1 => q|URL|,

	4 => q|Timeout|,

	5 => q|Allow proxying of other domains?|,

	6 => q|Remove style?|,

	8 => q|Follow redirects?|,

	9 => q|Cookie Jar|,

	12 => q|Rewrite urls ?|,

	13 => q|Search for|,

	14 => q|Stop at|,

};

1;
