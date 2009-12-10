package WebGUI::i18n::English::Asset_Matrix;
use strict;

our $I18N = {
	'product_loop' => {
		message => q|A loop containing the product information (not contained in categories) for this listing.|,
		lastUpdated => 1149783768,
	},

	'name' => {
		message => q|The name of the product.|,
		lastUpdated => 1149783768,
	},

	'category_loop' => {
		message => q|A loop containing all of the categories in this Matrix.|,
		lastUpdated => 0,
        context => q|Description of the category_loop tmpl_var for the template help.|,
	},

    'attribute_loop' => {
        message => q|A loop containing all of the attributes in a category of this Matrix.|,
        lastUpdated => 0,
        context => q|Description of the attribute_loop tmpl_var for the template help.|,
    },

    'categoryLabel' => {
        message => q|The label of a category.|,
        lastUpdated => 0,
        context => q|Description of the categoryLabel tmpl_var for the template help.|,
    },

    'compareForm' => {
        message => q|The compare box form. The list of matrix listings in this form is a yui datatable. See the <a href='http://developer.yahoo.com/yui/examples/datatable/dt_skinning.html'>yui docs</a> for information about skinning yui datatables.|,
        lastUpdated => 0,
        context => q|Description of the compareForm tmpl_var for the template help.|,
    },

	'value' => {
		message => q|The value of this field.|,
		lastUpdated => 1149783768,
	},

    'comparison template help title' => {
        message => q|Matrix Comparison Template Variables|,
        lastUpdated => 1184949083,
    },

    'comparison template help body' => {
        message => q|Both the compare box form and the comparison list on the matrix compare page are dynamically
generated yui datatables. See the <a href='http://developer.yahoo.com/yui/examples/datatable/dt_skinning.html'>yui
docs</a> for information about skinning yui datatables.|,
        lastUpdated => 0,
    },

    'javascript' => {
        message => q|The inline javascript for this template.|,
        lastUpdated => 0,
        context => q|Description of the javascript tmpl_var for the template help.|,
    },

    'views label' => {
        message => q|Views|,
        lastUpdated => 0,
    },

    'compares label' => {
        message => q|Compares|,
        lastUpdated => 0,
    },

    'clicks label' => {
        message => q|Clicks|,
        lastUpdated => 0,
    },

	'search_url' => {
		message => q|The URL to the matrix search page.|,
		lastUpdated => 0,
	},

    'search label' => {
        message => q|Search|,
        lastUpdated => 0,
    },

    'listing statistics label' => {
        message => q|Listing Statistics|,
        lastUpdated => 0,
    },

    'most clicks label' => {
        message => q|Most clicks|,
        lastUpdated => 0,
    },

    'most views label' => {
        message => q|Most views|,
        lastUpdated => 0,
    },

    'most compares label' => {
        message => q|Most compares|,
        lastUpdated => 0,
    },

    'most recently updated label' => {
        message => q|Most recently updated|,
        lastUpdated => 0,
    },

    'best rated label' => {
        message => q|Best Rated By Users|,
        lastUpdated => 0,
    },

    'worst rated label' => {
        message => q|Worst Rated by Users|,
        lastUpdated => 0,
    },

    'site statistics label' => {
        message => q|Site Statistics|,
        lastUpdated => 0,
    },

    'listing count label' => {
        message => q|Listing Count|,
        lastUpdated => 0,
    },

    'pending listings label' => {
        message => q|Pending Listings|,
        lastUpdated => 0,
    },

    'add new listing label' => {
        message => q|Click here to add a new listing.|,
        lastUpdated => 0,
    },

    'add new listing text' => {
        message => q|Please note that you will be the official maintainer of the listing, and will be responsible
for keeping it up to date.|,
        lastUpdated => 0,
    },

    'create account part1 text' => {
        message => q|If you are the maker of a product, or are an expert user and are willing to maintain the
listing,|,
        lastUpdated => 0,
    },

    'create account label' => {
        message => q|create an account|,
        lastUpdated => 0,
    },

    'create account part2 text' => {
        message => q|so you can register your listing.|,
        lastUpdated => 0,
    },

	'isLoggedIn' => {
		message => q|A condition indicating whether the current user is logged in to the site.|,
		lastUpdated => 0,
	},

	'listAttributes_url' => {
		message => q|The URL to the page where you configure new listing attributes for this matrix.|,
		lastUpdated => 0,
        context => q|Description of the listAttributes_url tmpl_var for the template help.|,
	},

    'list attributes label' => {
        message => q|List Attributes|,
        lastUpdated => 0,
    },

    'exportAttributes_url' => {
        message => q|The URL to export the listing attributes for this matrix.|,
        lastUpdated => 0,
    },

    'export attributes label' => {
        message => q|Export Attributes|,
        lastUpdated => 0,
    },

	'addMatrixListing_url' => {
		message => q|The URL to the page where a user can add a new listing to the matrix.|,
		lastUpdated => 0,
        context => q|Description of the addMatrixListing_url tmpl_var for the template help.|,
	},

	'bestViews_url' => {
		message => q|The URL to the listing that has the most views.|,
		lastUpdated => 0,
        context => q|Description of the bestViews_url tmpl_var for the template help.|,
	},

	'bestViews_count' => {
		message => q|The total number of views of the listing that has the most views.|,
		lastUpdated => 0,
        context => q|Description of the bestViews_count tmpl_var for the template help.|,
	},

	'bestViews_name' => {
		message => q|The name of the listing that has the most views.|,
		lastUpdated => 0,
        context => q|Description of the bestViews_name tmpl_var for the template help.|,
	},

	'bestCompares_url' => {
		message => q|The URL to the listing that has the most compares.|,
		lastUpdated => 0,
        context => q|Description of the  tmpl_var for the template help.|,        
	},

	'bestCompares_count' => {
		message => q|The number of compares of the listing that has the most compares.|,
		lastUpdated => 0,
        context => q|Description of the bestCompares_count tmpl_var for the template help.|,
	},

	'bestCompares_name' => {
		message => q|The name of the listing that has the most compares.|,
		lastUpdated => 0,
        context => q|Description of the bestCompares_name tmpl_var for the template help.|,
	},

	'bestClicks_url' => {
		message => q|The URL of the listing that has the most clicks.|,
		lastUpdated => 0,
        context => q|Description of the bestClicks_url tmpl_var for the template help.|,
	},

	'bestClicks_count' => {
		message => q|The number of clicks of the listing that has the most clicks.|,
		lastUpdated => 0,
        context => q|Description of the bestClicks_count tmpl_var for the template help.|,
	},

	'bestClicks_name' => {
		message => q|The name of the listing that has the most clicks.|,
		lastUpdated => 0,
        context => q|Description of the bestClicks_name tmpl_var for the template help.|,
	},

	'best_rating_loop' => {
		message => q|A loop containing the best rated listings for each categories of this matrix.|,
		lastUpdated => 0,
        context => q|Description of the best_rating_loop tmpl_loop for the template help.|,
	},

	'url' => {
		message => q|The URL of the listing.|,
		lastUpdated => 0,
        context => q|Description of the url tmpl_var for the template help.|,        
	},

	'category' => {
		message => q|The category of the listing.|,
		lastUpdated => 0,
        context => q|Description of the category tmpl_var for the template help.|,        
	},

	'name' => {
		message => q|The name of the listing.|,
		lastUpdated => 0,
        context => q|Description of the name tmpl_var for the template help.|,
	},

	'mean' => {
		message => q|The mean (or average) rating of the best/worst listing in this category.|,
		lastUpdated => 0,
        context => q|Description of the mean tmpl_var for the template help.|,
	},

	'median' => {
		message => q|The median (or middle) rating of the best/worst listing in this category.|,
		lastUpdated => 0,
        context => q|Description of the median tmpl_var for the template help.|,
	},

	'count' => {
		message => q|The sum of all the votes of the best/worst listing in this category.|,
		lastUpdated => 0,
        context => q|Description of the count tmpl_var for the template help.|,
	},

	'worst_rating_loop' => {
		message => q|A loop containing the worst rated listings for each categories of this matrix.|,
		lastUpdated => 0,
        context => q|Description of the worst_rating_loop tmpl_loop for the template help.|,
	},

	'last_updated_loop' => {
		message => q|A loop containing the 20 most recently updated listings.|,
		lastUpdated => 0,
        context => q|Description of the last_updated_loop tmpl_loop for the template help.|,
	},

	'lastUpdated' => {
		message => q|The date this listing was updated.|,
		lastUpdated => 1149795214,
        context => q|Description of lastUpdated the tmpl_var for the template help.|,
	},

	'listingCount' => {
		message => q|The number of listings in this matrix.|,
		lastUpdated => 0,
        context => q|Description of listingCount the tmpl_var for the template help.|,
	},

	'pending_loop' => {
		message => q|A loop containing the list of pending listing.|,
		lastUpdated => 0,
        context => q|Description of the pending_loop tmpl_loop for the template help.|,
	},

    'expand the matrix label' => {
        message => q|Expand The Matrix|,
        lastUpdated => 0,
    },

    'matrix template help title' => {
        message => q|Matrix Main Template Variables|,
        lastUpdated => 1184949132,
    },

	'fieldType' => {
		message => q|The type of field specified for this matrix field.|,
		lastUpdated => 1149996685,
	},

	'label' => {
		message => q|The label given to this attribute that describes what the attribtute represents.|,
		lastUpdated => 0,
        context => q|Description of the listing label tmpl_var inside the attribute loop in the search screen.|,
	},

	'description' => {
		message => q|A description of the attribute that gives more detail about the attribute and is used in the hover over tool tips.|,
		lastUpdated => 0,
        context => q|Description of the description tmpl_var inside the attribute loop in the search screen.|,
	},

	'form' => {
		message => q|The form element representing this attribute.|,
		lastUpdated => 0,
        context => q|Description of the form tmpl_var inside the attribute loop in the search screen.|,
	},

    'search template help title' => {
        message => q|Matrix Search Template Variables|,
        lastUpdated => 1184949060,
    },

	'categories description' => {
        message => q|Specify one category per line here to define the categories for this matrix. Categories are used to subdivide fields and also represent the things users can rate each listing on.|,
        lastUpdated => 0,
     },

    'categories default value' => {
        message => qq|Features\nBenefits|,
        lastUpdated => 0,
     },

    'submission approval workflow description' => {
        message => q|Select the  workflow that is used to approve submissions.|,
        lastUpdated => 0,
    },

    'group to add description' => {
        message => q|Select the group that is allowed to add listings to this matrix.|,
        lastUpdated => 0,
    },

    'ratings duration description' => {
        message => q|Select the interval after which old ratings are cleaned out.|,
        lastUpdated => 0,
    },

    'default sort description' => {
        message => q|Select the default sort order for the listings in the compare box.|,
        lastUpdated => 0,
    },

    'max screenshot width description' => {
        message => q|Select the maximum width of the screenshots in this matrix. Screenshots that are larger will be resized.|,
        lastUpdated => 0,
    },

    'max screenshot height description' => {
        message => q|Select the maximum height of the screenshots in this matrix. Screenshots that are larger will be resized.|,
        lastUpdated => 0,
    },

    'compare color no description' => {
        message => q|Select the color for compare result 'No'  in the compare display.|,
        lastUpdated => 0,
    },

    'compare color limited description' => {
        message => q|Select the color for compare result 'Limited'  in the compare display.|,
        lastUpdated => 0,
    },

    'compare color costs extra description' => {
        message => q|Select the color for compare result 'Costs Extra'  in the compare display.|,
        lastUpdated => 0,
    },

    'compare color free add on description' => {
        message => q|Select the color for compare result 'Free Add On'  in the compare display.|,
        lastUpdated => 0,
    },

    'compare color yes description' => {
        message => q|Select the color for compare result 'Yes'  in the compare display.|,
        lastUpdated => 0,
    },

	'categories subtext' => {
                message => q|<br />Enter one per line in the order you want them to appear. Be sure to watch leading and trailing whitespace.|,
                lastUpdated => 1135271460,
        },

    'maxgroup per description' => {
        message => q|Specifies how many comparisons are allowed for the privileged group.|,
        lastUpdated => 0,
    },

    'maxgroup description' => {
        message => q|Select a group for which a specific maximum comparisons can be selected.|,
        lastUpdated => 0,
    },

    'max comparisons description' => {
        message => q|Specifies how many comparisons are allowed in searches and comparisons.|,
        lastUpdated => 0,
    },

    'max comparisons privileged description' => {
        message => q|Specifies how many comparisons are allowed in searches and comparisons for users who have accounts on the site.|,
        lastUpdated => 1235681965,
    },

    'statistics cache timeout label' => {
        message => q|Statistics Cache Timeout|,
        lastUpdated => 0,
    },

    'statistics cache timeout description' => {
        message => q|Since all users will see the matrix statistics the same way, we can cache them for some time
to increase performance. How long should we cache them?|,
        lastUpdated => 0,
    },

    'listings cache timeout label' => {
        message => q|Listings Cache Timeout|,
        lastUpdated => 0,
    },

    'listings cache timeout description' => {
        message => q|The complete list of Matrix listings can be cached for some time to increase performance. How long should we cache it?|,
        lastUpdated => 0,
    },

        'rating timeout description' => {
                message => q|Set a timeout so that users are prevented from rating a given listing too often.|,
                lastUpdated => 1135271460,
        },

        'rating timeout privileged description' => {
                message => q|Privileged users may have a different rating timeout than general users who are allowed to rate.|,
                lastUpdated => 1135271460,
        },

        'group to add description' => {
                message => q|This group will be allowed to add or edit listings|,
                lastUpdated => 1135271460,
        },

        'privileged group description' => {
                message => q|This group will have special privileges with respect to the maximum number of comparisons allowed and frequency of rating|,
                lastUpdated => 1135271460,
        },

        'rating group description' => {
                message => q|This group will be allowed to rate listings in the Matrix.|,
                lastUpdated => 1135271460,
        },

        'template description' => {
                message => q|Select a template to be used to display the default view of the Matrix.|,
                lastUpdated => 0,
        },

        'detail template description' => {
                message => q|Select a template to be used to display the detailed information about a listing.|,
                lastUpdated => 0,
        },

        'rating detail template description' => {
                message => q|Select a template to be used to display the detailed ratings information.|,
                lastUpdated => 0,
        },

    'search template description' => {
        message => q|Select a template to be used to display the search engine interface.|,
        lastUpdated => 0,
    },

    'compare template description' => {
        message => q|Select a template to be used to show the listing comparison data.|,
        lastUpdated => 0,
    },

    'edit listing template description' => {
        message => q|Select a template to be used to show the listing edit screen.|,
        lastUpdated => 0,
    },

    'screenshots template description' => {
        message => q|Select a template to be used to show a listing's screenshots.|,
        lastUpdated => 0,
    },

    'screenshots config template description' => {
        message => q|Select a template for a listing's screenshots configuration.|,
        lastUpdated => 0,
    },
	
    'categories label' => {
		message => q|Categories|,
		lastUpdated => 0,
	},

    'submission approval workflow label' => {
        message => q|Submission Approval Workflow|,
        lastUpdated => 0,
    },

    'group to add label' => {
        message => q|Group To Add|,
        lastUpdated => 0,
    },

    'ratings duration label' => {
        message => q|Ratings Duration|,
        lastUpdated => 0,
    },

    'default sort label' => {
        message => q|Default Sort|,
        lastUpdated => 0,
    },

    'max screenshot height label' => {
        message => q|Maximum Screenshot Height|,
        lastUpdated => 0,
    },

    'max screenshot width label' => {
        message => q|Maximum Screenshot Width|,
        lastUpdated => 0,
    },

    'sort by score label' => {
        message => q|Score|,
        lastUpdated => 0,
    },

    'sort alpha numeric label' => {
        message => q|Alpha Numeric|,
        lastUpdated => 0,
    },

    'sort by asset rank label' => {
        message => q|Asset Rank|,
        lastUpdated => 0,
    },

    'sort by last updated label' => {
        message => q|Most Recent Update|,
        lastUpdated => 0,
    },

	'compare color no label' => {
        message => q|Compare Color: No|,
        lastUpdated => 0,
    },

    'compare color limited label' => {
        message => q|Compare Color: Limited|,
        lastUpdated => 0,
    },

    'compare color costs extra label' => {
        message => q|Compare Color: Costs Extra|,
        lastUpdated => 0,
    },

    'compare color free add on label' => {
        message => q|Compare Color: Free Add On|,
        lastUpdated => 0,
    },

    'compare color yes label' => {
        message => q|Compare Color: Yes|,
        lastUpdated => 0,
    },

    'maxgroup per label' => {
        message => q|Maximum for Privileged Group|,
        lastUpdated => 0,
    },

    'maxgroup label' => {
        message => q|Privileged Maximum Group|,
        lastUpdated => 0,
    },
    
    'max comparisons label' => {
		message => q|Maximum Comparisons|,
		lastUpdated => 0,
	},

	'max comparisons privileged label' => {
		message => q|Maximum Comparisons (For Registered Users)|,
		lastUpdated => 1235681967,
	},

	'rating timeout' => {
		message => q|Time Required Between Ratings|,
		lastUpdated => 1133758944,
	},

	'rating timeout privileged' => {
		message => q|Time Required Between Ratings (For Privileged Users)|,
		lastUpdated => 1133758944,
	},

	'group to add' => {
		message => q|Who can add listings?|,
		lastUpdated => 1133758944,
	},

	'privileged group' => {
		message => q|Who should have privileged rights?|,
		lastUpdated => 1133758944,
	},

	'rating group' => {
		message => q|Who can rate listings?|,
		lastUpdated => 1133758944,
	},

	'template label' => {
		message => q|Matrix Template|,
		lastUpdated => 0,
	},

	'detail template label' => {
		message => q|Detail Template|,
		lastUpdated => 0,
	},

	'rating detail template label' => {
		message => q|Rating Detail Template|,
		lastUpdated => 0,
	},

	'search template label' => {
		message => q|Search Template|,
		lastUpdated => 0,
	},

	'compare template label' => {
		message => q|Compare Template|,
		lastUpdated => 0,
	},

    'screenshots template label' => {
        message => q|Listing Screenshots Template|,
        lastUpdated => 0,
    },

    'screenshots config template label' => {
        message => q|Listing Screenshots Config Template|,
        lastUpdated => 0,
    },

    'edit listing template label' => {
        message => q|Edit Listing Template|,
        lastUpdated => 0,
    },

	'product name' => {
		message => q|Product Name|,
		lastUpdated => 1133758944,
	},

	'attribute name label' => {
		message => q|Name|,
		lastUpdated => 0,
	},
	
    'fieldType label' => {
		message => q|Field Type|,
		lastUpdated => 0,
	},

	'attribute defaultValue label' => {
		message => q|Default Value|,
		lastUpdated => 0,
	},

    'attribute options label' => {
        message => q|Options|,
        lastUpdated => 0,
    },

	'category label' => {
		message => q|Category|,
		lastUpdated => 0,
	},

	'no edit rights' => {
		message => q|You don't have the rights to edit this listing.|,
		lastUpdated => 1133758944,
	},

        'assetName' => {
                lastUpdated => 1134256651,
                message => q|Matrix|
        },

        'edit matrix' => {
                lastUpdated => 1135279558,
                message => q|Edit Matrix|
        },

        'edit listing' => {
                lastUpdated => 1135279558,
                message => q|<h1>Edit Listing</h1>|
        },

        'edit attribute title' => {
                lastUpdated => 0,
                message => q|Edit/Add Attribute|
        },

        'delete listing confirmation' => {
                lastUpdated => 1135289632,
                message => q|<h1>Confirm Delete</h1>
	<p>Are you absolutely sure you wish to delete this listing? This operation cannot be undone.</p>
	<p>
	<a href="%s">Yes!</a>
	</p>
	<p><a href="%s">No, I made a mistake.</a></p>|,
        },

    'list attributes title' => {
        lastUpdated => 0,
        message => q|Attribute List|,
    },

    'delete attribute confirm message' => {
        message => q|Are you certain you wish to delete this attribute and all the data linked to it?|,
        lastUpdated => 0,
    },

    'add attribute label' => {
        lastUpdated => 0,
        message => q|Add Attribute|,
    },

        'product name description' => {
                lastUpdated => 1135279558,
                message => q|Enter the name of the product.  If there are entries for the product with different revisions, it would be best to make sure the names are the same.|
        },

        'attribute name description' => {
                lastUpdated => 0,
                message => q|The name of the attribute that you are creating.  It is case sensitive and must be unique.|
        },

        'fieldType description' => {
                lastUpdated => 0,
                message => q|<p>The field type of attribute you are creating.  Please select the field type from the options in the drop-down list.</p>|
        },

        'attribute description label' => {
                lastUpdated => 0,
                message => q|Description|
        },

        'attribute description description' => {
                lastUpdated => 0,
                message => q|Please give a general description of the attribute.|
        },

        'attribute defaultValue description' => {
                lastUpdated => 0,
                message => q|<p>Enter in a default value for the attribute that will be used if the fieldType is
selectBox.</p>|
        },

        'attribute options description' => {
                lastUpdated => 0,
                message => q|<p>Enter in options (one per line) for the attribute that will be used if the fieldType is
selectBox.</p>|
        },

        'category description' => {
                lastUpdated => 0,
                message => q|Select the category which this attribute falls into.|
        },

    'comparison label' => {
        lastUpdated => 0,
        message => q|Comparison|,
    },

    'compare button label' => {
        lastUpdated => 0,
        message => q|Compare|,
    },

    'last updated label' => {
        lastUpdated => 0,
        message => q|Last Updated|,
        context => q|The label of the last updated field in the comparison table on the compare screen.|,
    },

    'hide stickied button label' => {
        lastUpdated => 0,
        message => q|Hide/show stickied|,
    },

    'approve or deny label' => {
        lastUpdated => 0,
        message => q|Approve/Deny|,
        context => q|Label for the approve or deny link on the matrix listing detail screen.|,
    },

    'matrix asset template variables title' => {
        lastUpdated => 0,
        message => q|Matrix Asset Template Variables|,
    },

    'matrix fieldtype' => {
        lastUpdated => 0,
        message => q|Matrix Fieldtype|,
    },

    'too many message' => {
        lastUpdated => 1260478380,
        message => q|You can only compare up to %d items at a time. Please adjust your selections and try again.|,
        context => q|A message shown to the user when they have selected too many listings to compare.|,
    },

    'too few message' => {
        lastUpdated => 1260478343,
        message => q|To compare, at least two listings must be selected. If you want to view just one listing, click on its name.|,
        context => q|A message shown to the user when they have selected only one listing to compare.|,
    },

    'Sort by name' => {
        lastUpdated => 1250146133,
        message => q|Sort by name|,
        context => q|To order a list of items by name|,
    },

    'Sort by views' => {
        lastUpdated => 1250146133,
        message => q|Sort by views|,
        context => q|To order a list of items by the number of times it has been viewed|,
    },

    'Sort by compares' => {
        lastUpdated => 1250146133,
        message => q|Sort by compares|,
        context => q|To order a list of items by the number of times it has been compared|,
    },

    'Sort by clicks' => {
        lastUpdated => 1250146133,
        message => q|Sort by clicks|,
        context => q|To order a list of items by the number of times it has been clicked|,
    },

    'Sort by updated' => {
        lastUpdated => 1250146133,
        message => q|Sort by updated|,
        context => q|To order a list of items by the number of times it was last updated|,
    },

    'Return to Matrix' => {
        lastUpdated => 1250146133,
        message => q|Return to Matrix|,
        context => q|To go back to the Matrix main screen.|,
    },

};

1;
