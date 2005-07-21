package WebGUI::i18n::English::Asset_Navigation;

our $I18N = {

	'Specific URL' => {
		message => 'Specific URL',
		lastUpdated => 0
	},

	'Relative To Current URL' => {
		message => 'Relative To Current URL',
		lastUpdated => 0
	},

	'Relative To Root' => {
		message => 'Relative To Root',
		lastUpdated => 0
	},

	'Start Point Type' => {
		message => 'Start Point Type',
		lastUpdated => 0
	},

	'Start Point' => {
		message => 'Start Point',
		lastUpdated => 0
	},

	'Infinity' => {
		message => 'Infinity',
		lastUpdated => 0
	},

	'Ancestor End Point' => {
		message => 'Ancestor End Point',
		lastUpdated => 0
	},

	'Relatives To Include' => {
		message => 'Relatives To Include',
		lastUpdated => 0
	},

	'Ancestors' => {
		message => 'Ancestors',
		lastUpdated => 0
	},

	'Siblings' => {
		message => 'Siblings',
		lastUpdated => 0
	},

	'Self' => {
		message => 'Self',
		lastUpdated => 0
	},

	'Descendants' => {
		message => 'Descendants',
		lastUpdated => 0
	},

	'Pedigree' => {
		message => 'Pedigree',
		lastUpdated => 0
	},

	'Descendant End Point' => {
		message => 'Descendant End Point',
		lastUpdated => 0
	},

	'' => {
		message => '',
		lastUpdated => 0
	},

	'' => {
		message => '',
		lastUpdated => 0
	},

	'' => {
		message => '',
		lastUpdated => 0
	},

	'' => {
		message => '',
		lastUpdated => 0
	},

	'' => {
		message => '',
		lastUpdated => 0
	},

	'32' => {
		message => q|Show unprivileged pages|,
		lastUpdated => 1077080845
	},

	'30' => {
		message => q|Show system pages|,
		lastUpdated => 1077080766
	},

	'31' => {
		message => q|Show hidden pages|,
		lastUpdated => 1077080799
	},

	'preview' => {
		message => q|Preview Navigation|,
		lastUpdated => 1077078456
	},

	'navigation' => {
		message => q|Navigation|,
		lastUpdated => 1077078526,
		context => q|Title of the navigation manager in the admin console.|
	},

	'22' => {
		message => q|Edit Navigation|,
		lastUpdated => 1078208044
	},

	'1098' => {
		message => q|Navigation, Add/Edit|,
		lastUpdated => 1078208044
	},

	'1093' => {
		message => q|<P>The Add/Edit Navigation form allows you to do choose the which pages are shown in
		your site navigation, and how to display them.  Some of the default Navigation templates that come with WebGUI are
		vertical, horizontal and crumbtrail.  These templates can often be styled via CSS to match your site's design, instead
		of rewriting the templates.</P>
<P><B>Identifier</B><BR>
This is the (unique) label you will later use to specify this Navigation definition in a &#94;Navigation(); macro.

<P><B>Base Page</B><BR>
This identifies the spot in the Page Tree where the macro should commence listing pages. The first three choices will create 'absolute' menus -- ones which will display the same pages no matter which page you use the macro from.

<P>The next four create 'relative' menus -- ones in which the items which will be displayed depend on the location in the page tree of the page in which you use the macro.</P>

<P>Use the 'Add new value' option if you want to specify a custom starting page. You can refer to a starting page by its urlized title or its pageId.</P>

<P><B>Return a Loop With</B><BR>
This determines which pages relative to the base page will be included in the menu which the macro creates.</P>
<UL>
<LI>daughters - pages below the base page 
<LI>sisters - pages at the same level as the base page, excluding the base page itself. 
<LI>self and sisters - all pages at the same level as the base page. 
<LI>descendants - all the descendants of base page (daughters, granddaughters, grand-granddaughters, etc) 
<LI>self and descendants - base page and all of it's descendants. 
<LI>childless descendants - The "leaf nodes" under base page. Also called "terminal nodes" -- i.e. pages that have no daughters. 
<LI>generation - base page, it's sisters, it's cousins, grand cousins, grand-grand cousins, etc. Technically spoken: Pages that share the same depth as "base page". 
<LI>ancestors - all base page ancestors, starting with it's mother, then grandmother, etc, up to the root page. 
<LI>self and ancestors - same as ancestors but starting at base page. 
<LI>pedigree - This is what we know as the "FlexMenu". Starting at base page, it returns its daughters, self and sisters, ancestors and the sisters of each ancestor.<BR></LI></UL>

<P><B>Stop traversing when reaching level</B><BR>
This allows you to prune a menu -- in either direction -- when it reaches a <I>specific</I> level in the page tree. It's slightly different in effect than Max Depth.

<P><B>Max Depth</B><BR>
This allows you to prune a menu -- in either direction -- when it reaches a <I>number of levels</I> in the page tree. 'Stop Traversing' is absolute; 'Max Depth' is relative. Presumably, if you set both, whichever one takes effect <I>first</I> will be the active limit (that is, they're OR'd together).

<P><B>Show System Pages</B><BR>
Should the menus the macro creates include System pages such as Trash, Clipboard, Page not found, etc.?  If you want Admins or Content Managers to be able to see System Pages, then select Yes and use the Navigation Template to hide them.

<P><B>Show Hidden Pages</B><BR>
Should the menus include pages which are marked as Hidden? Similar to
System Pages, if you want certain groups to be able to see Hidden Pages, then select Yes and use
the Navigation Template to determine who can see them in the menu.</P>
<P>NOTE: Any user in Admin mode will automatically be able to see all pages that they can edit regardless of whether they are hidden or the value of this property.

<P><B>Show Unprivileged Pages</B><BR>
Should the menus the macro creates include pages which the currently logged-in user does not have the privilege to view?

<P><B>Template</B><BR>
Select a template which is used to style the output created by the macro -- if you need the same collection of pages in multiple formats, you'll need to create multiple Navigation entries with (slightly) different names; the Copy Navigation button is useful for this.

<P><B>Reverse Output</B><BR>
When this option is switched on, the menu will be in reverse order.

<P><B>Preview</B><BR>
The Preview button allows you to view a navigation setup without actually saving it.

|,

		lastUpdated => 1116701049,
	},

	'1096' => {
		message => q|Navigation Template|,
		lastUpdated => 1078207966
	},

	'1097' => {
		message => q| <P><STRONG>currentPage.menuTitle</STRONG><BR>The pageId of the base page.</P>
<P><STRONG>currentPage.menuTitle</STRONG><BR>The menu title of the base page.</P>
<P><STRONG>currentPage.title</STRONG><BR>The title of the base page.</P>
<P><STRONG>currentPage.url</STRONG><BR>The URL of the base page.</P>
<P><STRONG>currentPage.assetId</STRONG><BR>The assetId of the base page.</P>
<P><STRONG>currentPage.parentId</STRONG><BR>The assetId of the parent of the base page.</P>
<P><STRONG>currentPage.ownerUserId</STRONG><BR>The userId of the owner of the base page.</P>
<P><STRONG>currentPage.synopsis</STRONG><BR>The synopsis of the base page.</P>
<P><STRONG>currentPage.newWindow</STRONG><BR>A conditional indicating whether the base page should be opened in a new window.</P>
<P><STRONG>currentPage.hasChild</STRONG><BR>A conditional indicating whether the base page has daughters.</P>
<P><STRONG>currentPage.isHome</STRONG><BR>A conditional indicating whether the base page is the default page for the site.</P>
<P><STRONG>currentPage.hasSibling</STRONG><BR>A conditional indicating whether the base page has siblings.</P>
<P><STRONG>currentPage.hasViewableSiblings</STRONG><BR>A conditional indicating whether the base page has siblings that are viewable by the current user.</P>
<P><STRONG>currentPage.hasViewableChildren</STRONG><BR>A conditional indicating whether the base page has children that are viewable by the current user.</P>
<P><STRONG>page_loop</STRONG><BR>A loop containing page information in nested, hierarchical order.</P>
<P><STRONG>unfolded_page_loop</STRONG><BR>This loop contains the same data as <STRONG>page_loop</STRONG> but the order is different.  <STRONG>unfolded_page_loop</STRONG> returns it's pages in an unfolded manner; grouped by parent id. You'll probably need <STRONG>page_loop</STRONG>, but there are (CSS) menus that need <STRONG>unfolded_page_loop</STRONG> to work properly.</P>
<p>Both <STRONG>page_loop</STRONG> and <STRONG>unfolded_page_loop</STRONG> have the following
loop variables:</p>
<BLOCKQUOTE dir=ltr style="MARGIN-RIGHT: 0px">
<P dir=ltr><STRONG>page.menuTitle</STRONG><BR>The menu title of this page.</P>
<P dir=ltr><STRONG>page.rank</STRONG><BR>The rank of this page compared with is siblings.</P>
<P dir=ltr><STRONG>page.title</STRONG><BR>The title of this page.</P>
<P dir=ltr><STRONG>page.url</STRONG><BR>The complete URL to this page.</P>
<P dir=ltr><STRONG>page.assetId</STRONG><BR>The assetId of this page.</P>
<P dir=ltr><STRONG>page.parentId</STRONG><BR>The assetId of the parent of this page.</P>
<P dir=ltr><STRONG>page.ownerUserId</STRONG><BR>The userId of the owner of this page.</P>
<P dir=ltr><STRONG>page.synopsis</STRONG><BR>The synopsis of this page.</P>
<P dir=ltr><STRONG>page.newWindow</STRONG><BR>A conditional indicating whether this page should be opened in a new window.</P>
<P dir=ltr><STRONG>page.absDepth</STRONG><BR>The absolute depth of this page (relative to nameless root).</P>
<P><STRONG>page.relDepth</STRONG><BR>The relative depth of this page (relative to starting point).</P>
<P><STRONG>page.isSystem</STRONG><BR>A conditional indicating whether this page is a system page (Trash, Clipboard, etc).</P>
<P><STRONG>page.isHidden</STRONG><BR>A conditional indicating whether this page is a hidden page.</P>
<P><STRONG>page.isViewable</STRONG><BR>A conditional indicating whether the user has permission to view it.</P>
<P><STRONG>page.indent</STRONG><BR>A variable containing the indent for the current page. The default indent is three spaces. Use the <STRONG>page.indent_loop</STRONG> if you need a more flexible indent.</P>
<P><STRONG>page.indent_loop</STRONG><BR>A loop that runs <STRONG>page.relDepth</STRONG> times.</P>
<BLOCKQUOTE dir=ltr style="MARGIN-RIGHT: 0px">
<P><STRONG>indent</STRONG><BR>A number representing the loop count. </P></BLOCKQUOTE>
<P dir=ltr><STRONG>page.isBranchRoot</STRONG><BR>A conditional indicating whether this page is a root page.</P>
<P dir=ltr><STRONG>page.isTopOfBranch</STRONG><BR>A conditional indicating whether this page is a top page (daughter of root).</P>
<P dir=ltr><STRONG>page.isChild</STRONG><BR>A conditional indicating whether this page is a daughter of the base page.</P>
<P dir=ltr><STRONG>page.isParent</STRONG><BR>A conditional indicating whether this page is the mother of the base page.</P>
<P dir=ltr><STRONG>page.isCurrent</STRONG><BR>A conditional indicating whether this page is the base page.</P>
<P dir=ltr><STRONG>page.isDescendent</STRONG><BR>A conditional indicating whether this page is a descendant of the base page.</P>
<P dir=ltr><STRONG>page.isAncestor</STRONG><BR>A conditional indicating whether this page is an ancestor of the base page.</P>
<P dir=ltr><STRONG>page.inBranchRoot</STRONG><BR>This conditional is true if this page is a descendant of the root page of the base page.</P>
<P dir=ltr><STRONG>page.isSibling</STRONG><BR>A conditional indicating whether this page is the sister of the base page.</P>
<P dir=ltr><STRONG>page.inBranch</STRONG><BR>A conditional that is the logical OR of <STRONG>isAncestor</STRONG>, <STRONG>isSister</STRONG>, <STRONG>isBasepage</STRONG> and <STRONG>isDescendent</STRONG>.</P>
<P dir=ltr><STRONG>page.hasChild</STRONG><BR>A conditional indicating whether this page has a daughter. In other words, it evaluates to true if this page is a mother.</P>
<P dir=ltr><STRONG>page.parent.*</STRONG><BR>These variables will be undefined if the page is a root.</P>
<P dir=ltr><STRONG>page.parent.menuTitle</STRONG><BR>The menu title of the mother of this page.</P>
<P dir=ltr><STRONG>page.parent.title</STRONG><BR>The title of the mother of this page.</P>
<P dir=ltr><STRONG>page.parent.url</STRONG><BR>The urlized title of the mother of this page.</P>
<P dir=ltr><STRONG>page.parent.assetId</STRONG><BR>The assetId of the mother of this page.</P>
<P dir=ltr><STRONG>page.parent.parentId</STRONG><BR>The assetId of the grandmother of this page.</P>
<P dir=ltr><STRONG>page.parent.ownerUserId</STRONG><BR>The userId of the owner of the mother of this page.</P>
<P dir=ltr><STRONG>page.parent.synopsis</STRONG><BR>The synopsis of the mother of this page.</P>
<P dir=ltr><STRONG>page.parent.newWindow</STRONG><BR>A conditional indicating whether the mother of this page should be opened in a new window.</P>
<P dir=ltr><STRONG>page.depthIs1 , page.depthIs2 , page.depthIs3 , page.depthIs4 , page.depthIsN<BR></STRONG>A conditional indicating whether the depth of this page is N. This variable is useful if you want to style a certain level.</P>
<P dir=ltr>&lt;tmpl_if page.depthIs1&gt;<BR>&nbsp;&nbsp; &lt;img src="level1.gif"&gt;<BR>&lt;tmpl_else&gt;<BR>&nbsp;&nbsp; &lt;img src="defaultBullet.gif"&gt;<BR>&lt;/tmpl_if&gt;</P>
<P dir=ltr><STRONG>page.relativeDepthIs1 , page.relativeDepthIs2 , page.relativeDepthIs3 , page.relativeDepthIsN</STRONG><BR>A conditional indicating whether the depth of this page is N, relative to the starting page.</P>
<P dir=ltr><STRONG>page.depthDiff</STRONG><BR>The difference in depth between the previous page and this page, parent.absDepth - page.absDepth, although parent.absDepth is not a template variable.</P>
<P dir=ltr><STRONG>page.depthDiffIs1, page.depthDiffIs2, page.depthDiffIs3, page.depthDiffIsN</STRONG><BR>True if the <STRONG>page.depthDiff</STRONG> variable is N.  N can be positive or negative.</P>
<P dir=ltr><STRONG>page.depthDiff_loop</STRONG><BR>A loop that runs <STRONG>page.depthDiff</STRONG> times, if <STRONG>page.depthDiff</STRONG> &gt 0. This loop contains no loop variables.</P></BLOCKQUOTE>
<P dir=ltr><STRONG>page.isRankedFirst</STRONG><BR>This property is true if this page is the first within this level. Ie. has no left sister.</P>
<P dir=ltr><STRONG>page.isRankedLast</STRONG><BR>This property is true if this page is the last within this level. Ie. has no right sister.</P>
|,
		lastUpdated => 1121933073,
	},

	'1094' => {
		message => q|Navigation, Manage|,
		lastUpdated => 1078208044
	},

	'1095' => {
		message => q|<P>The general idea behind the navigation system is that instead of hardwiring all the various choices you might make into the code, the system manages a 'library' of these styles, just the way it does with Snippets, Images, Templates, Page Styles, and other types of reusable information.  You can create a new 'Navigation menu style', give it a name, and then use it anywhere on your site that you like.</P>
<P>The navigation system consists of two parts:</P>
<OL>
<LI>The <STRONG>&#94;Navigation();</STRONG> macro, which determines which files may be included in the menu and which template to use.</LI>
<LI>The Navigation Template, which creates the menu and presents it to the user.</LI>
</OL>
<P>To create a new menu for your site, place a <B>&#94;Navigation(myMenu);</B> macro into a style. An "edit myMenu" link will be displayed if "myMenu" is not defined. </P>
<P>Note: In this example "myMenu" is used, but you can pick any name, as long as it is unique.</P>|,
		lastUpdated => 1101774239
	},

};

1;
