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

	'assetName' => {
		message => q|Navigation|,
		lastUpdated => 1128834268,
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

        '1096 description' => {
                message => q|Choose a template to use for displaying your navigation|,
                lastUpdated => 1121969610,
        },

        'Start Point Type description' => {
                message => q|Pick where the navigation should start choosing pages, via a specific URL, relative to the current
URL or at a page relative to the root page.|,
                lastUpdated => 1121969610,
        },

        'Start Point description' => {
                message => q|Based on the Start Point Type, where the navigation will begin choosing pages.|,
                lastUpdated => 1121969610,
        },

        'Ancestor End Point description' => {
                message => q|If the Start Point Type is set to relative to Current URL, how many levels above the current URL
the navigation should start.|,
                lastUpdated => 1121969610,
        },

        'Relatives To Include description' => {
                message => q|The Navigation Asset can filter out pages that you do not want to be in the navigation.  Select
all of the classes of pages that should be included:<br>
<dl>
<dt>Ancestors</dt>
<dd>Pages higher than the current page in the tree.</dd>
<dt>Self</dt>
<dd>The current page.</dd>
<dt>Siblings</dt>
<dd>Pages at the same level as the current URL.</dd>
<dt>Descendents</dt>
<dd>Pages lower than the current page in the tree.</dd>
<dt>Pedigree</dt>
<dd>When using a different start page, this option selects the Ancestors, Siblings and Descendents of that page.</dd>
</dl>|,
                lastUpdated => 1146456217,
        },

        'Descendant End Point description' => {
                message => q|The number of levels down from the Start Point where should the navigation end.|,
                lastUpdated => 1121969610,
        },

        '30 description' => {
                message => q|Should the menus the macro creates include System pages such as Trash, Clipboard, Page not found, etc.?  If you want Admins or Content Managers to be able to see System Pages, then select Yes and use the Navigation Template to hide them.|,
                lastUpdated => 1121969610,
        },

        '31 description' => {
                message => q|Should the menus include pages which are marked as Hidden? Similar to
System Pages, if you want certain groups to be able to see Hidden Pages, then select Yes and use
the Navigation Template to determine who can see them in the menu.</P>
<P>NOTE: Any user in Admin mode will automatically be able to see all pages that they can edit regardless of whether they are hidden or the value of this property.|,
                lastUpdated => 1121969610,
        },

        '32 description' => {
                message => q|Should the menus the macro creates include pages which the currently logged-in user does not have the privilege to view?|,
                lastUpdated => 1121969610,
        },


	'1093' => {
		message => q|<p>Navigation Assets will help you build sets of links so that users can get around in your
site.  You can customize a Navigation form to choose the which pages are shown in
your site navigation and how to display them.  Some of the default Navigation templates that come with WebGUI are
vertical, horizontal and crumbtrail.  These templates can often be styled via CSS to match your site's design, instead
of rewriting the templates.</P>
<p>The Navigation Asset can also be used to generate XML output by creating a
template and setting the MIME Type appropriately.  This could be useful for building
a Google sitemap of your site.
|,

		lastUpdated => 1140139614,
	},

	'1096' => {
		message => q|Navigation Template|,
		lastUpdated => 1078207966
	},

	'1097' => {
		message => q| <P><STRONG>currentPage.menuTitle</STRONG><BR>The pageId of the start page.</P>
<P><STRONG>currentPage.assetId</STRONG><BR>The assetId of the start page.</P>
<P><STRONG>currentPage.parentId</STRONG><BR>The assetId of the parent of the start page.</P>
<P><STRONG>currentPage.ownerUserId</STRONG><BR>The userId of the owner of the start page.</P>
<P><STRONG>currentPage.synopsis</STRONG><BR>The synopsis of the start page.</P>
<P><STRONG>currentPage.newWindow</STRONG><BR>A conditional indicating whether the start page should be opened in a new window.</P>
<P><STRONG>currentPage.menuTitle</STRONG><BR>The menu title of the start page.</P>
<P><STRONG>currentPage.title</STRONG><BR>The title of the start page.</P>
<P><STRONG>currentPage.isHome</STRONG><BR>A conditional indicating whether the base page is the default page for the site.</P>
<P><STRONG>currentPage.url</STRONG><BR>The URL of the start page.</P>
<P><STRONG>currentPage.rank</STRONG><BR>The position of the current page compared to its siblings.</P>
<P><STRONG>currentPage.hasChild</STRONG><BR>A conditional indicating whether the start page has daughters.</P>
<P><STRONG>currentPage.hasSibling</STRONG><BR>A conditional indicating whether the start page has siblings.</P>
<P><STRONG>currentPage.hasViewableSiblings</STRONG><BR>A conditional indicating whether the start page has siblings that are viewable by the current user.</P>
<P><STRONG>currentPage.hasViewableChildren</STRONG><BR>A conditional indicating whether the start page has children that are viewable by the current user.</P>
<P><STRONG>page_loop</STRONG><BR>A loop containing page information in nested, hierarchical order.</P>
<BLOCKQUOTE dir=ltr style="MARGIN-RIGHT: 0px">
<P dir=ltr><STRONG>page.assetId</STRONG><BR>The assetId of this page.</P>
<P dir=ltr><STRONG>page.parentId</STRONG><BR>The assetId of the parent of this page.</P>
<P dir=ltr><STRONG>page.ownerUserId</STRONG><BR>The userId of the owner of this page.</P>
<P dir=ltr><STRONG>page.synopsis</STRONG><BR>The synopsis of this page.</P>
<P dir=ltr><STRONG>page.newWindow</STRONG><BR>A conditional indicating whether this page should be opened in a new window.</P>
<P dir=ltr><STRONG>page.menuTitle</STRONG><BR>The menu title of this page.</P>
<P dir=ltr><STRONG>page.title</STRONG><BR>The title of this page.</P>
<P dir=ltr><STRONG>page.rank</STRONG><BR>The rank of this page compared with is siblings.</P>
<P dir=ltr><STRONG>page.absDepth</STRONG><BR>The absolute depth of this page (relative to nameless root).</P>
<P><STRONG>page.relDepth</STRONG><BR>The relative depth of this page (relative to starting point).</P>
<P><STRONG>page.isSystem</STRONG><BR>A conditional indicating whether this page is a system page (Trash, Clipboard, etc).</P>
<P><STRONG>page.isHidden</STRONG><BR>A conditional indicating whether this page is a hidden page.</P>
<P><STRONG>page.isContainer</STRONG><BR>A conditional indicating whether this page a container asset.</P>
<P><STRONG>page.isUtility</STRONG><BR>A conditional indicating whether this page is a utility asset.</P>
<P><STRONG>page.isViewable</STRONG><BR>A conditional indicating whether the user has permission to view it.</P>
<P dir=ltr><STRONG>page.url</STRONG><BR>The complete URL to this page.</P>
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
<P dir=ltr><STRONG>page.hasViewableChildren</STRONG><BR>A conditional indicating whether this page has a viewable child.</P>
<P dir=ltr><STRONG>page.depthIs1 , page.depthIs2 , page.depthIs3 , page.depthIs4 , page.depthIsN<BR></STRONG>A conditional indicating whether the depth of this page is N. This variable is useful if you want to style a certain level.</P>
<P dir=ltr>&lt;tmpl_if page.depthIs1&gt;<BR>&nbsp;&nbsp; &lt;img src="level1.gif"&gt;<BR>&lt;tmpl_else&gt;<BR>&nbsp;&nbsp; &lt;img src="defaultBullet.gif"&gt;<BR>&lt;/tmpl_if&gt;</P>
<P dir=ltr><STRONG>page.relativeDepthIs1 , page.relativeDepthIs2 , page.relativeDepthIs3 , page.relativeDepthIsN</STRONG><BR>A conditional indicating whether the depth of this page is N, relative to the starting page.</P>
<P dir=ltr><STRONG>page.depthDiff</STRONG><BR>The difference in depth between the previous page and this page, parent.absDepth - page.absDepth, although parent.absDepth is not a template variable.</P>
<P dir=ltr><STRONG>page.depthDiffIs1, page.depthDiffIs2, page.depthDiffIs3, page.depthDiffIsN</STRONG><BR>True if the <STRONG>page.depthDiff</STRONG> variable is N.  N can be positive or negative.</P>
<P dir=ltr><STRONG>page.depthDiff_loop</STRONG><BR>A loop that runs <STRONG>page.depthDiff</STRONG> times, if <STRONG>page.depthDiff</STRONG> &gt; 0. This loop contains no loop variables.</P>
<P dir=ltr><STRONG>page.isRankedFirst</STRONG><BR>This property is true if this page is the first within this level. ie. has no left sister.</P>
<P dir=ltr><STRONG>page.isRankedLast</STRONG><BR>This property is true if this page is the last within this level. ie. has no right sister.</P>
<P dir=ltr><STRONG>page.parent.*</STRONG><BR>These variables will be undefined if the page is a root.</P>
<P dir=ltr><STRONG>page.parent.menuTitle</STRONG><BR>The menu title of the mother of this page.</P>
<P dir=ltr><STRONG>page.parent.title</STRONG><BR>The title of the mother of this page.</P>
<P dir=ltr><STRONG>page.parent.url</STRONG><BR>The urlized title of the mother of this page.</P>
<P dir=ltr><STRONG>page.parent.assetId</STRONG><BR>The assetId of the mother of this page.</P>
<P dir=ltr><STRONG>page.parent.parentId</STRONG><BR>The assetId of the grandmother of this page.</P>
<P dir=ltr><STRONG>page.parent.ownerUserId</STRONG><BR>The userId of the owner of the mother of this page.</P>
<P dir=ltr><STRONG>page.parent.synopsis</STRONG><BR>The synopsis of the mother of this page.</P>
<P dir=ltr><STRONG>page.parent.newWindow</STRONG><BR>A conditional indicating whether the mother of this page should be opened in a new window.</P>
</BLOCKQUOTE>|,
		lastUpdated => 1145060204,
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

	'mimeType' => {
		message => q|MIME Type|,
        	lastUpdated => 1140129010,
	},


        'mimeType description' => {
                message => q|Allows you to specify the MIME type of this asset when viewed via the web; useful if you'd like to serve CSS, plain text,  javascript or other text files directly from the WebGUI asset system. Defaults to <b>text/html</b>.|,
                lastUpdated => 1140129008,
        },

};

1;
