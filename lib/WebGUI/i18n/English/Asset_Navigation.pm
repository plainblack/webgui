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
all of the classes of pages that should be included:<br />
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
                message => q|<p>Should the menus include pages which are marked as Hidden? Similar to
System Pages, if you want certain groups to be able to see Hidden Pages, then select Yes and use
the Navigation Template to determine who can see them in the menu.</p>
<p>NOTE: Any user in Admin mode will automatically be able to see all pages that they can edit regardless of whether they are hidden or the value of this property.</p>|,
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
of rewriting the templates.</p>
<p>The Navigation Asset can also be used to generate XML output by creating a
template and setting the MIME Type appropriately.  This could be useful for building
a Google sitemap of your site.</p>
|,

		lastUpdated => 1140139614,
	},

	'1096' => {
		message => q|Navigation Template|,
		lastUpdated => 1078207966
	},

	'1097' => {
		message => q| <p><strong>currentPage.menuTitle</strong><br />The pageId of the start page.</p>
<p><strong>currentPage.assetId</strong><br />The assetId of the start page.</p>
<p><strong>currentPage.parentId</strong><br />The assetId of the parent of the start page.</p>
<p><strong>currentPage.ownerUserId</strong><br />The userId of the owner of the start page.</p>
<p><strong>currentPage.synopsis</strong><br />The synopsis of the start page.</p>
<p><strong>currentPage.newWindow</strong><br />A conditional indicating whether the start page should be opened in a new window.</p>
<p><strong>currentPage.menuTitle</strong><br />The menu title of the start page.</p>
<p><strong>currentPage.title</strong><br />The title of the start page.</p>
<p><strong>currentPage.isHome</strong><br />A conditional indicating whether the base page is the default page for the site.</p>
<p><strong>currentPage.url</strong><br />The URL of the start page.</p>
<p><strong>currentPage.rank</strong><br />The position of the current page compared to its siblings.</p>
<p><strong>currentPage.hasChild</strong><br />A conditional indicating whether the start page has daughters.</p>
<p><strong>currentPage.hasSibling</strong><br />A conditional indicating whether the start page has siblings.</p>
<p><strong>currentPage.hasViewableSiblings</strong><br />A conditional indicating whether the start page has siblings that are viewable by the current user.</p>
<p><strong>currentPage.hasViewableChildren</strong><br />A conditional indicating whether the start page has children that are viewable by the current user.</p>
<p><strong>page_loop</strong><br />A loop containing page information in nested, hierarchical order.</p>
<div class="helpIndent">
<p><strong>page.assetId</strong><br />The assetId of this page.</p>
<p><strong>page.parentId</strong><br />The assetId of the parent of this page.</p>
<p><strong>page.ownerUserId</strong><br />The userId of the owner of this page.</p>
<p><strong>page.synopsis</strong><br />The synopsis of this page.</p>
<p><strong>page.newWindow</strong><br />A conditional indicating whether this page should be opened in a new window.</p>
<p><strong>page.menuTitle</strong><br />The menu title of this page.</p>
<p><strong>page.title</strong><br />The title of this page.</p>
<p><strong>page.rank</strong><br />The rank of this page compared with is siblings.</p>
<p><strong>page.absDepth</strong><br />The absolute depth of this page (relative to nameless root).</p>
<p><strong>page.relDepth</strong><br />The relative depth of this page (relative to starting point).</p>
<p><strong>page.isSystem</strong><br />A conditional indicating whether this page is a system page (Trash, Clipboard, etc).</p>
<p><strong>page.isHidden</strong><br />A conditional indicating whether this page is a hidden page.</p>
<p><strong>page.isContainer</strong><br />A conditional indicating whether this page a container asset.</p>
<p><strong>page.isUtility</strong><br />A conditional indicating whether this page is a utility asset.</p>
<p><strong>page.isViewable</strong><br />A conditional indicating whether the user has permission to view it.</p>
<p><strong>page.url</strong><br />The complete URL to this page.</p>
<p><strong>page.indent</strong><br />A variable containing the indent for the current page. The default indent is three spaces. Use the <strong>page.indent_loop</strong> if you need a more flexible indent.</p>
<p><strong>page.indent_loop</strong><br />A loop that runs <strong>page.relDepth</strong> times.</p>
<div class="helpIndent">
<p><strong>indent</strong><br />A number representing the loop count. </p></div>
<p><strong>page.isBranchRoot</strong><br />A conditional indicating whether this page is a root page.</p>
<p><strong>page.isTopOfBranch</strong><br />A conditional indicating whether this page is a top page (daughter of root).</p>
<p><strong>page.isChild</strong><br />A conditional indicating whether this page is a daughter of the base page.</p>
<p><strong>page.isParent</strong><br />A conditional indicating whether this page is the mother of the base page.</p>
<p><strong>page.isCurrent</strong><br />A conditional indicating whether this page is the base page.</p>
<p><strong>page.isDescendent</strong><br />A conditional indicating whether this page is a descendant of the base page.</p>
<p><strong>page.isAncestor</strong><br />A conditional indicating whether this page is an ancestor of the base page.</p>
<p><strong>page.inBranchRoot</strong><br />This conditional is true if this page is a descendant of the root page of the base page.</p>
<p><strong>page.isSibling</strong><br />A conditional indicating whether this page is the sister of the base page.</p>
<p><strong>page.inBranch</strong><br />A conditional that is the logical OR of <strong>isAncestor</strong>, <strong>isSister</strong>, <strong>isBasepage</strong> and <strong>isDescendent</strong>.</p>
<p><strong>page.hasChild</strong><br />A conditional indicating whether this page has a daughter. In other words, it evaluates to true if this page is a mother.</p>
<p><strong>page.hasViewableChildren</strong><br />A conditional indicating whether this page has a viewable child.</p>
<p><strong>page.depthIs1 , page.depthIs2 , page.depthIs3 , page.depthIs4 , page.depthIsN<br /></strong>A conditional indicating whether the depth of this page is N. This variable is useful if you want to style a certain level.</p>
<p>&lt;tmpl_if page.depthIs1&gt;<br />&nbsp;&nbsp; &lt;img src="level1.gif"&gt;<br />&lt;tmpl_else&gt;<br />&nbsp;&nbsp; &lt;img src="defaultBullet.gif"&gt;<br />&lt;/tmpl_if&gt;</p>
<p><strong>page.relativeDepthIs1 , page.relativeDepthIs2 , page.relativeDepthIs3 , page.relativeDepthIsN</strong><br />A conditional indicating whether the depth of this page is N, relative to the starting page.</p>
<p><strong>page.depthDiff</strong><br />The difference in depth between the previous page and this page, parent.absDepth - page.absDepth, although parent.absDepth is not a template variable.</p>
<p><strong>page.depthDiffIs1, page.depthDiffIs2, page.depthDiffIs3, page.depthDiffIsN</strong><br />True if the <strong>page.depthDiff</strong> variable is N.  N can be positive or negative.</p>
<p><strong>page.depthDiff_loop</strong><br />A loop that runs <strong>page.depthDiff</strong> times, if <strong>page.depthDiff</strong> &gt; 0. This loop contains no loop variables.</p>
<p><strong>page.isRankedFirst</strong><br />This property is true if this page is the first within this level. ie. has no left sister.</p>
<p><strong>page.isRankedLast</strong><br />This property is true if this page is the last within this level. ie. has no right sister.</p>
<p><strong>page.parent.*</strong><br />These variables will be undefined if the page is a root.</p>
<p><strong>page.parent.menuTitle</strong><br />The menu title of the mother of this page.</p>
<p><strong>page.parent.title</strong><br />The title of the mother of this page.</p>
<p><strong>page.parent.url</strong><br />The urlized title of the mother of this page.</p>
<p><strong>page.parent.assetId</strong><br />The assetId of the mother of this page.</p>
<p><strong>page.parent.parentId</strong><br />The assetId of the grandmother of this page.</p>
<p><strong>page.parent.ownerUserId</strong><br />The userId of the owner of the mother of this page.</p>
<p><strong>page.parent.synopsis</strong><br />The synopsis of the mother of this page.</p>
<p><strong>page.parent.newWindow</strong><br />A conditional indicating whether the mother of this page should be opened in a new window.</p>
</div>|,
		lastUpdated => 1145060204,
	},

	'1094' => {
		message => q|Navigation, Manage|,
		lastUpdated => 1078208044
	},

	'1095' => {
		message => q|<p>The general idea behind the navigation system is that instead of hardwiring all the various choices you might make into the code, the system manages a 'library' of these styles, just the way it does with Snippets, Images, Templates, Page Styles, and other types of reusable information.  You can create a new 'Navigation menu style', give it a name, and then use it anywhere on your site that you like.</p>
<p>The navigation system consists of two parts:</p>
<ol>
<li>The <strong>&#94;Navigation();</strong> macro, which determines which files may be included in the menu and which template to use.</li>
<li>The Navigation Template, which creates the menu and presents it to the user.</li>
</ol>
<p>To create a new menu for your site, place a <b>&#94;Navigation(myMenu);</b> macro into a style. An "edit myMenu" link will be displayed if "myMenu" is not defined. </p>
<p>Note: In this example "myMenu" is used, but you can pick any name, as long as it is unique.</p>|,
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
