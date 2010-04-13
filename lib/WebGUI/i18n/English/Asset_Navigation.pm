package WebGUI::i18n::English::Asset_Navigation;
use strict;

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
<dt>Descendants</dt>
<dd>Pages lower than the current page in the tree.</dd>
<dt>Pedigree</dt>
<dd>When using a different start page, this option selects the Ancestors, Siblings and Descendants of that page.</dd>
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

	'1096' => {
		message => q|Navigation Template|,
		lastUpdated => 1078207966
	},

	'currentPage.menuTitle' => {
		message => q|The pageId of the current page.|,
		lastUpdated => 1163720613,
	},

	'currentPage.assetId' => {
		message => q|The assetId of the current page.|,
		lastUpdated => 1163720616,
	},

	'currentPage.parentId' => {
		message => q|The assetId of the parent of the current page.|,
		lastUpdated => 1163720617,
	},

	'currentPage.ownerUserId' => {
		message => q|The userId of the owner of the current page.|,
		lastUpdated => 1163720620,
	},

	'currentPage.synopsis' => {
		message => q|The summary, or synopsis, of the current page.|,
		lastUpdated => 1202861338,
	},

	'currentPage.newWindow' => {
		message => q|A conditional indicating whether the current page should be opened in a new window.|,
		lastUpdated => 1163720622,
	},

	'currentPage.menuTitle' => {
		message => q|The menu title of the current page.|,
		lastUpdated => 1163720624,
	},

	'currentPage.title' => {
		message => q|The title of the current page.|,
		lastUpdated => 1163720625,
	},

	'currentPage.isHome' => {
		message => q|A conditional indicating whether the current page is the default page for the site.|,
		lastUpdated => 1163720628,
	},

	'currentPage.url' => {
		message => q|The URL of the current page.|,
		lastUpdated => 1163720631,
	},

	'currentPage.rank' => {
		message => q|The position of the current page compared to its siblings.|,
		lastUpdated => 1163720636,
	},

	'currentPage.hasChild' => {
		message => q|A conditional indicating whether the current page has daughters.|,
		lastUpdated => 1163720639,
	},

	'currentPage.hasSibling' => {
		message => q|A conditional indicating whether the current page has siblings.|,
		lastUpdated => 1163720640,
	},

	'currentPage.hasViewableSiblings' => {
		message => q|A conditional indicating whether the current page has siblings that are viewable by the current user.|,
		lastUpdated => 1163720642,
	},

	'currentPage.hasViewableChildren' => {
		message => q|A conditional indicating whether the current page has children that are viewable by the current user.|,
		lastUpdated => 1163720645,
	},

	'page_loop' => {
		message => q|A loop containing pages in nested, hierarchical order.  Every property of each asset is available, with the name <b>page.<i>propertyName</i></b>, where <i>propertyName</i> should be replaced with the name of the property you want to use, like className, or assetSize.  A handfull of them are listed below.  Please consult the template variables for each Asset type for a full list.|,
		lastUpdated => 1244495609,
	},

	'page.assetId' => {
		message => q|The assetId of this page.|,
		lastUpdated => 1149394665,
	},

	'page.parentId' => {
		message => q|The assetId of the parent of this page.|,
		lastUpdated => 1149394665,
	},

	'page.ownerUserId' => {
		message => q|The userId of the owner of this page.|,
		lastUpdated => 1149394665,
	},

	'page.synopsis' => {
		message => q|The summary, or synopsis, of this page.|,
		lastUpdated => 1202861328,
	},

	'page.newWindow' => {
		message => q|A conditional indicating whether this page should be opened in a new window.|,
		lastUpdated => 1149394665,
	},

	'page.menuTitle' => {
		message => q|The menu title of this page.|,
		lastUpdated => 1149394665,
	},

	'page.title' => {
		message => q|The title of this page.|,
		lastUpdated => 1149394665,
	},

	'page.rank' => {
		message => q|The rank of this page compared with is siblings.|,
		lastUpdated => 1149394665,
	},

	'page.absDepth' => {
		message => q|The absolute depth of this page (relative to nameless root).|,
		lastUpdated => 1149394665,
	},

	'page.relDepth' => {
		message => q|The relative depth of this page (relative to starting point).|,
		lastUpdated => 1149394665,
	},

	'page.isSystem' => {
		message => q|A conditional indicating whether this page is a system page (Trash, Clipboard, etc).|,
		lastUpdated => 1149394665,
	},

	'page.isHidden' => {
		message => q|A conditional indicating whether this page is a hidden page.|,
		lastUpdated => 1149394665,
	},

	'page.isContainer' => {
		message => q|A conditional indicating whether this page a container asset.  Container assets are those assets which contain other assets, like Pages, Folders and Dashboards.|,
		lastUpdated => 1160064240,
	},

	'page.isUtility' => {
		message => q|A conditional indicating whether this page is a utility asset.  Utility assets are assets that typically may not be viewed directly, like Images, Files, Templates and RichEditors.|,
		lastUpdated => 1160064177,
	},

	'page.isViewable' => {
		message => q|A conditional indicating whether the user has permission to view it.|,
		lastUpdated => 1149394665,
	},

	'page.url' => {
		message => q|The complete URL to this page.|,
		lastUpdated => 1149394665,
	},

	'page.indent' => {
		message => q|A variable containing the indent for the current page. The default indent is three spaces. Use the <strong>page.indent_loop</strong> if you need a more flexible indent.|,
		lastUpdated => 1163720649,
	},

	'page.indent_loop' => {
		message => q|A loop that runs <strong>page.relDepth</strong> times.|,
		lastUpdated => 1149394665,
	},

	'indent' => {
		message => q|A number representing the loop count.|,
		lastUpdated => 1149394665,
	},

	'page.isBranchRoot' => {
		message => q|A conditional indicating whether this page is a root page.|,
		lastUpdated => 1149394665,
	},

	'page.isTopOfBranch' => {
		message => q|A conditional indicating whether this page is a top page (daughter of root).|,
		lastUpdated => 1149394665,
	},

	'page.isChild' => {
		message => q|A conditional indicating whether this page is a daughter of the current page.|,
		lastUpdated => 1163720652,
	},

	'page.isParent' => {
		message => q|A conditional indicating whether this page is the mother of the current page.|,
		lastUpdated => 1163720145,
	},

	'page.isCurrent' => {
		message => q|A conditional indicating whether this page is the current page.|,
		lastUpdated => 1163720148,
	},

	'page.isDescendant' => {
		message => q|A conditional indicating whether this page is a descendant of the current page.|,
		lastUpdated => 1163720154,
	},

	'page.isAncestor' => {
		message => q|A conditional indicating whether this page is an ancestor of the current page.|,
		lastUpdated => 1163720164,
	},

	'page.inBranchRoot' => {
		message => q|This conditional is true if this page is a descendant of the root page of the current page.|,
		lastUpdated => 1163720167,
	},

	'page.isSibling' => {
		message => q|A conditional indicating whether this page is the sister of the current page.|,
		lastUpdated => 1163720172,
	},

	'page.inBranch' => {
		message => q|A conditional that is the logical OR of <strong>isAncestor</strong>, <strong>isSibling</strong>, <strong>isBasepage</strong> and <strong>isDescendant</strong>.|,
		lastUpdated => 1157647394,
	},

	'page.hasChild' => {
		message => q|A conditional indicating whether this page has a daughter. In other words, it evaluates to true if this page is a mother.|,
		lastUpdated => 1149394665,
	},

	'page.hasViewableChildren' => {
		message => q|A conditional indicating whether this page has a viewable child.|,
		lastUpdated => 1149394665,
	},

	'page.depthIsN' => {
		message => q|A conditional indicating whether the depth of this page is N. This variable is useful if you want to style a certain level.
<br />
<br />&lt;tmpl_if page.depthIs1&gt;<br />
&nbsp;&nbsp; &lt;img src="level1.gif"&gt;<br />&lt;tmpl_else&gt;<br />&nbsp;&nbsp; &lt;img src="defaultBullet.gif"&gt;<br />&lt;/tmpl_if&gt;|,
		lastUpdated => 1149394665,
	},

	'page.relativeDepthIsN' => {
		message => q|A conditional indicating whether the depth of this page is N, relative to the starting page.|,
		lastUpdated => 1149394665,
	},

	'page.depthDiff' => {
		message => q|The difference in depth between the previous page and this page, parent.absDepth - page.absDepth, although parent.absDepth is not a template variable.|,
		lastUpdated => 1149394665,
	},

	'page.depthDiffIsN' => {
		message => q|True if the <strong>page.depthDiff</strong> variable is N.  N can be positive or negative.|,
		lastUpdated => 1149394665,
	},

	'page.depthDiff_loop' => {
		message => q|A loop that runs <strong>page.depthDiff</strong> times, if <strong>page.depthDiff</strong> &gt; 0. This loop contains no loop variables.|,
		lastUpdated => 1149394665,
	},

	'page.isRankedFirst' => {
		message => q|This property is true if this page is the first within this level(ie. has no left sister).|,
		lastUpdated => 1167186300,
	},

	'page.isRankedLast' => {
		message => q|This property is true if this page is the last within this level(ie. has no right sister).|,
		lastUpdated => 1167186302,
	},

	'page.parent.menuTitle' => {
		message => q|The menu title of the mother of this page.|,
		lastUpdated => 1149394665,
	},

	'page.parent.title' => {
		message => q|The title of the mother of this page.|,
		lastUpdated => 1149394665,
	},

	'page.parent.url' => {
		message => q|The urlized title of the mother of this page.|,
		lastUpdated => 1149394665,
	},

	'page.parent.assetId' => {
		message => q|The assetId of the mother of this page.|,
		lastUpdated => 1149394665,
	},

	'page.parent.parentId' => {
		message => q|The assetId of the grandmother of this page.|,
		lastUpdated => 1149394665,
	},

	'page.parent.ownerUserId' => {
		message => q|The userId of the owner of the mother of this page.|,
		lastUpdated => 1149394665,
	},

	'page.parent.synopsis' => {
		message => q|The summary, or synopsis,  of the mother of this page.|,
		lastUpdated => 1202861334,
	},

	'page.parent.newWindow' => {
		message => q|A conditional indicating whether the mother of this page should be opened in a new window.|,
		lastUpdated => 1149394665,
	},

	'page.parent.rank' => {
		message => q|The rank of the mother of this page.|,
		lastUpdated => 1153314572,
	},

	'reverse page loop' => {
		message => q|Reverse page loop|,
		lastUpdated => 1153314572,
	},
	
	'reverse page loop description' => {
		message => q|Reverses the order of all pages while maintaining hierarchy.|,
		lastUpdated => 1153314572,
	},

	'1097' => {
		message => q|<p>These variables are available in Navigation Templates:</p>
<p><b>currentPage</b> refers to the page that the user is currently looking at. <b>page</b> refers to any
given page inside of the <b>page_loop</b></p>.
<p>When referring to a page every Asset property is available.  Only the most useful
ones are listed below.</p>
	|,
		lastUpdated => 1221602772,
	},

	'mimeType' => {
		message => q|MIME Type|,
        	lastUpdated => 1140129010,
	},


        'mimeType description' => {
                message => q|Allows you to specify the MIME type of this asset when viewed via the web; useful if you'd like to serve CSS, plain text,  javascript or other text files directly from the WebGUI asset system. Defaults to <b>text/html</b>.|,
                lastUpdated => 1140129008,
        },

	'navigation asset template variables title' => {
		message => q|Navigation Asset Template Variables|,
		lastUpdated => 1164841146
	},

	'navigation asset template variables body' => {
		message => q|Every asset provides a set of variables to most of its
templates based on the internal asset properties.  Some of these variables may
be useful, others may not.|,
		lastUpdated => 1164841201
	},

	'templateId' => {
		message => q|The ID of the template used to display this Navigation|,
		lastUpdated => 1164841201
	},

	'mimeType variable' => {
		message => q|The MIME type of the page containing the Navigation.|,
		lastUpdated => 1164841201
	},

	'assetsToInclude' => {
		message => q|A newline separated string containing the kids of assets to include in the Navigation, by relationship.  Ancestors, the asset itself, siblings, descendants and/or pedigree.|,
		lastUpdated => 1254329336,
	},

	'startType' => {
		message => q|A string that describes how the Navigation will be told to start finding Assets to display, "specificUrl", "relateiveToCurrentUrl", "relativeToRoot"|,
		lastUpdated => 1164841201,
		context => q|Note to translators, the strings in quotes should not be translated.|
	},

	'startPoint' => {
		message => q|Depending on startType, this is specifies at which page the Navigation will begin listing Assets.|,
		lastUpdated => 1164841201,
	},

	'ancestorEndPoint' => {
		message => q|Depending on the startType, how many levels up to begin listing Assets in the Navigation.|,
		lastUpdated => 1164841201,
	},

	'descendantEndPoint' => {
		message => q|Depending on the startType, how many levels down to go before stopping the list of Assets for the Navigation.|,
		lastUpdated => 1164841201,
	},

	'showSystemPages' => {
		message => q|Whether or not the Navigation has been configured to display system pages, like the Trash.|,
		lastUpdated => 1164841201,
	},

	'showHiddenPages' => {
		message => q|Whether or not the Navigation has been configured to display Assets that are set to be hidden from Navigations.|,
		lastUpdated => 1164841201,
	},

	'showUnprivilegedPages' => {
		message => q|Whether or not the Navigation has been configured to display Assets that the current user is not allowed to see.|,
		lastUpdated => 1164841201,
	},

	'reversePageLoop' => {
		message => q|Whether or not the Navigation has been configured to display Assets depth first, instead of top to bottom.|,
		lastUpdated => 1164841201,
	},

	'Where do you want to go?' => {
		message => q|Where do you want to go?|,
		context => q|i18n label for the drop down nav, asking the user which link they want to visit.|,
		lastUpdated => 1229580897,
	},

};

1;
