package WebGUI::i18n::English::Asset_Wobject;

our $I18N = {

          '828' => {
                     lastUpdated => 1053469640,
                     message => q|<p>Most wobjects have templates that allow you to change the layout of the wobject's user interface. Those wobjects that do have templates all have a common set of template variables that you can use for layout, as well as their own custom variables. The following is a list of the common template variables shared among all wobjects.</p>

<p><b>title</b><br />
The title for this wobject.
</p>

<p><b>displayTitle</b><br />
A conditional variable for whether or not the title should be displayed.
</p>

<p><b>description</b><br />
The description of this wobject.
</p>

<p><b>assetId</b><br />
The unique identifier that WebGUI uses to control this asset.
</p>

<p><b>isShortcut</b><br />
A conditional indicating if this wobject is a shortcut to an original asset.
</p>

<p><b>originalURL</b><br />
If this wobject is a shortcut, then this URL will direct you to the original asset.
</p>

|
                   },
          '1079' => {
                      lastUpdated => 1073152790,
                      message => q|Printable Style|
                    },
          '827' => {
                     lastUpdated => 1052046436,
                     message => q|Wobject Template|
                   },
          '632' => {
                     lastUpdated => 1119410914,
                     message => q|<p>You can add wobjects by selecting from the <i>^International("1","WebGUI");</i> pulldown menu. You can edit them by clicking on the "Edit" button that appears directly above an instance of a particular wobject while in Admin mode.</p>
<p>Wobjects are Assets, so they have all of the properties that Assets do.  Additionally, most Wobjects share some basic properties. Those properties are:</p>|
                   },

          '626' => {
                     lastUpdated => 1146852133,
                     message => q|<p>Wobjects are the true power of WebGUI. Wobjects are tiny pluggable applications built to run under WebGUI. Articles, message boards and polls are examples of wobjects.
Wobjects can be standalone pages all by themselves, or can be individual parts of pages.
</p>

<p>To add a wobject to a page, first go to that page, then select <b>Add Content...</b> from the upper left corner of your screen. Each wobject has it's own help so be sure to read the help if you're not sure how to use it.
</p>
|
                   },

        '174 description' => {
                message => q|Do you wish to display the Wobject's title? On some sites, displaying the title is not necessary.|,
                lastUpdated => 1119410887,
        },

        '1073 description' => {
                message => q|Select a style template from the list to enclose your Wobject if it is viewed directly.  If the Wobject
is displayed as part of a Layout Asset, the Layout Asset's <b>Style Template</b> is used instead.|,
                lastUpdated => 1119410887,
        },

        '1079 description' => {
                message => q|This sets the printable style for this page to be something other than the WebGUI Default Printable Style.  It behaves similarly to the <b>Style Template</b> with respect to when it is used.|,
                lastUpdated => 1119410887,
        },

	'85 description' => {
                message => q|A content area in which you can place as much content as you wish. For instance, even before a FAQ there is usually a paragraph describing what is contained in the FAQ. |,
                lastUpdated => 1119410887,
        },


          '42' => {
                    lastUpdated => 1031514049,
                    message => q|Please Confirm|
                  },
          '677' => {
                     lastUpdated => 1047858650,
                     message => q|Wobject, Add/Edit|
                   },
          '174' => {
                     lastUpdated => 1031514049,
                     message => q|Display the title?|
                   },
          '1073' => {
                      lastUpdated => 1070027660,
                      message => q|Style Template|
                    },
          '44' => {
                    lastUpdated => 1031514049,
                    message => q|Yes, I'm sure.|
                  },
          '85' => {
                    lastUpdated => 1031514049,
                    message => q|Description|
                  },
          '664' => {
                     lastUpdated => 1031514049,
                     message => q|Wobject, Delete|
                   },
          '619' => {
                     lastUpdated => 1146852148,
                     message => q|<p>This function permanently deletes the selected wobject from a page. If you are unsure whether you wish to delete this content you may be better served to cut the content to the clipboard until you are certain you wish to delete it.
</p>

<p>As with any delete operation, you are prompted to be sure you wish to proceed with the delete. If you answer yes, the delete will proceed and there is no recovery possible. If you answer no you'll be returned to the prior screen.
</p>

|
                   },

	'45' => {
		lastUpdated => 1031514049,
		message => q|No, I made a mistake.|
	},

	'671' => {
		lastUpdated => 1047858549,
		message => q|Wobjects, Using|
	},

	'assetName' => {
		message => q|Wobject|,
		lastUpdated => 1128830333,
	},


        'add' => {
                message => q|Add|,
                lastUpdated => 1128575345,
        },

        'edit' => {
                message => q|Edit|,
                lastUpdated => 1128575345,
        },

};

1;
