package WebGUI::i18n::English::SiteMap;

our $I18N = {
	'2' => {
		message => q|Site Map|,
		lastUpdated => 1031514049
	},

	'3' => {
		message => q|Start With|,
		lastUpdated => 1039908390
	},

	'4' => {
		message => q|Depth To Traverse|,
		lastUpdated => 1031514049
	},

	'5' => {
		message => q|Edit Site Map|,
		lastUpdated => 1031514049
	},

	'6' => {
		message => q|Indent|,
		lastUpdated => 1031514049
	},

	'61' => {
		message => q|Site Map, Add/Edit|,
		lastUpdated => 1038890147
	},

	'71' => {
		message => q|Site maps are used to provide additional navigation in WebGUI. You could set up a traditional site map that would display a hierarchical view of all the pages in the site. On the other hand, you could use site maps to provide extra navigation at certain levels in your site.
<br><br>

<b>Template</b><br/>
Choose a layout for this site map.
<p/>

<b>Start With</b><br>
Select the page that this site map should start from.
<br><br>

<b>Depth To Traverse</b><br>
How many levels deep of navigation should the Site Map show? If 0 (zero) is specified, it will show as many levels as there are.
<p>

<b>Indent</b><br>
How many characters should indent each level?
<p>

<b>Alphabetic?</b><br>
If this setting is true, site map entries are sorted alphabetically.  If this setting is false, site map entries are sorted by the page sequence order (editable via the up and down arrows in the page toolbar).
<p>

|,
		lastUpdated => 1039908464
	},

	'72' => {
		message => q|Site Map Template|,
		lastUpdated => 1047855100
	},

	'73' => {
		message => q|This is the list of template variables available for site map templates.
<p />

<b>page_loop</b><br />
This loop contains all of the pages in the site map.
<blockquote>

<b>page.indent</b><br />
The indent spacer for this page indicating the depth of the page in the tree.
<p />

<b>page.url</b><br />
The URL to the page.
<p />

<b>page.id</b><br />
The unique identifier for this page that WebGUI uses internally.
<p />

<b>page.title</b><br />
The title of this page.
<p />

<b>page.menutitle</b><br />
The title of this page that appears in navigation.
<p />

<b>page.synopsis</b><br />
The description of the contents of this page (if any).
<p />

<b>page.isRoot</b><br />
A condition indicating whether or not this page is a root.
<p />

<b>page.isTop</b><br />
A condition indicating whether or not this page is at the top of the navigation tree.
<p />


</blockquote>
<p />|,
		lastUpdated => 1047855100
	},

	'75' => {
		message => q|All Roots|,
		lastUpdated => 1039908572
	},

	'74' => {
		message => q|This Page|,
		lastUpdated => 1039908565
	},

	'7' => {
		message => q|Alphabetic?|,
		lastUpdated => 1057208065
	},

};

1;
