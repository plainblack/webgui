package WebGUI::i18n::English::Asset;
use strict;

our $I18N = {
	'save and commit' => {
		message => q|save &amp; commit|,
		lastUpdated => 0,
		context => q|A button added to all asset properties pages when save and commit mode is enabled.|
	},

    'apply' => {
        message     => q{apply},
        lastUpdated => 0,
        context     => q{The label for the button to save and then return to the edit page.},
    },

	'keywords' => {
		message => q|Keywords|,
		lastUpdated => 0,
		context => q|A label for the property that relates assets to keywords.|
	},

	'keywords help' => {
		message => q|Add some keywords here for this asset. They'll automatically be added to the search index, and as the keywords metatag.|,
		lastUpdated => 0,
		context => q|help for the keywords property|
	},

	'add the missing page' => {
		message => q|Add the missing page.|,
		lastUpdated => 0,
		context => q|the question asked of the admin when they click on a missing page|
	},

	'missing page query' => {
		message => q|The page you have requested does not exist. What would you like to do?|,
		lastUpdated => 0,
		context => q|the question asked of the admin when they click on a missing page|
	},

    'package extract error' => {
        message => q|Unable to extract package!  The package may be corrupt, or there may be a server error preventing packages from being imported.|,
        lastUpdated => 1206050885,
    },

	'package corrupt' => {
		message => q|The package you tried to import appears to be corrupt. We imported up to the point where we detected corruption. If you won't want this portion, roll back your current version tag.|,
		lastUpdated => 0,
		context => q|error message about package corruption|
	},

	'import' => {
		message => q|Import|,
		lastUpdated => 0,
		context => q|the title on the package import button|
	},

	'over max assets' => {
		message => q|Your administrator has limited the number of assets you may place on your site, and you have exceeded the limit. Delete some old assets in order to add more.|,
		lastUpdated => 0,
		context => q|an error message that will be displayed if the number of assets is >= to the maximumAssets defined in the config file|
	},

	'confirm change url message' => {
		message => q|Setting this to 'Yes' confirms that you want to permanently change this URL, thus deleteing all old revisions of this asset.|,
		lastUpdated => 1165449241,
		context => q|explains the implications of the change url function|
	},

	'confirm change' => {
		message => q|Are you sure?|,
		lastUpdated => 0,
		context => q|confirmation question|
	},

	'change url' => {
		message => q|Change URL|,
		lastUpdated => 0,
		context => q|the title of the change url function|
	},

	'change url help' => {
		message => q|Bring up the Change URL screen for this Asset.|,
		lastUpdated => 0,
	},

	'ago' => {
		message => q|ago|,
		lastUpdated => 0,
		context => q|a suffix for a measurement of time, like "3 seconds ago"|
	},

	'purge old trash' => {
		message => q|Purge Old Trash|,
		lastUpdated => 0,
		context => q|title of the purge trash workflow activity|
	},

	'purge trash after' => {
		message => q|Purge Old Trash After|,
		lastUpdated => 0,
		context => q|the label used in the purge old trash workflow activity|
	},

	'purge trash after help' => {
		message => q|How long should an asset stay in the trash before it's considered old enough to purge? Note that when it gets purged all its revisions and descendants will be purged as well.|,
		lastUpdated => 1227289347,
		context => q|the hover help for the purge trash after field|
	},

	'purge old asset revisions' => {
		message => q|Purge Old Asset Revisions|,
		lastUpdated => 0,
		context => q|title of the purge old asset revisions workflow activity|
	},

	'purge revision after' => {
		message => q|Purge Old Revisions After|,
		lastUpdated => 0,
		context => q|the label used in the purge expired asset revisions workflow activity|
	},

	'purge revision after help' => {
		message => q|How long should old revisions of an asset be kept? Old asset revisions are those that are no longer viewable by users, but are kept in the versioning system for rollbacks.|,
		lastUpdated => 0,
		context => q|the hover help for the purge revision after field|
	},

	'purge revision prompt' => {
		message => q|Are you certain you wish to delete this revision of this asset? It CANNOT be restored if you delete it.|,
		lastUpdated => 0,
		context => q|The prompt for purging a revision from the asset tree.|
	},

	'purge' => {
		message => q|Purge|,
		lastUpdated => 0,
		context => q|The label for the purge button in the trash manager.|
	},

	'lock' => {
		message => q|Lock|,
		lastUpdated => 0,
		context => q|A context menu item to lock an asset for editing.|
	},

	'lock help' => {
		message => q|Grab a copy of this Asset for editing, which locks the Asset to anyone not using your current version tag.  This option is only displayed if the Asset isn't currently locked.|,
		lastUpdated => 0,
	},

	'locked' => {
		message => q|Locked|,
		lastUpdated => 0,
		context => q|A label for a column in the asset manager indicating whether the asset is locked for editing.|
	},

	'revisions' => {
		message => q|Revisions|,
		lastUpdated => 0,
		context => q|Context menu item.|
	},

	'revisions help' => {
		message => q|Show a list of all revisions of this Asset.|,
		lastUpdated => 0,
	},

	'rank' => {
		message => q|Rank|,
		lastUpdated => 0,
		context => q|Column heading in asset manager.|
	},
	
	'revised by' => {
		message => q|Revised By|,
		lastUpdated => 0,
		context => q|manage revisions in tag|
	},

	'revision date' => {
		message => q|Revision Date|,
		lastUpdated => 0,
		context => q|manage revisions in tag|
	},

	'tag name' => {
		message => q|Tag Name|,
		lastUpdated => 0,
		context => q|manage revisions in tag|
	},

	'type' => {
		message => q|Type|,
		lastUpdated => 0,
		context => q|Column heading in asset manager.|
	},
	
	'size' => {
		message => q|Size|,
		lastUpdated => 0,
		context => q|Column heading in asset manager.|
	},
	
	'last updated' => {
		message => q|Last Updated|,
		lastUpdated => 0,
		context => q|Column heading in asset manager.|
	},
	
	'restore' => {
		message => q|Restore|,
		lastUpdated => 0,
		context => q|Used in asset context menus.|
	},

	'promote' => {
		message => q|Promote|,
		lastUpdated => 0,
		context => q|Used in asset context menus.|
	},

	'promote help' => {
		message => q|Move this Asset up one spot on the page.|,
		lastUpdated => 0,
	},

	'demote' => {
		message => q|Demote|,
		lastUpdated => 0,
		context => q|Used in asset context menus.|
	},

	'demote help' => {
		message => q|Move this Asset down one spot on the page.|,
		lastUpdated => 0,
	},

	'cut' => {
		message => q|Cut|,
		lastUpdated => 0,
		context => q|Used in asset context menus.|
	},

	'duplicate' => {
		message => q|Duplicate|,
		lastUpdated => 0,
		context => q|Used in asset context menus.|
	},

	'Copy' => {
		message => q|Copy|,
		lastUpdated => 1221540086,
		context => q|Used in asset context menus.|
	},

	'copy' => {
		message => q|copy|,
		lastUpdated => 1221540088,
		context => q|Same as Copy, but lower case.|
	},

	'Paste' => {
		message => q|Paste|,
		lastUpdated => 1245342798,
		context => q|To remove an item from the clipboard, and put it on the current page.|
	},

	'this asset only' => {
		message => q|This&nbsp;Asset&nbsp;Only|,
		lastUpdated => 0,
		context => q|Used in the small pop-up copy menu.|
	},
	
	'with children' => {
		message => q|With&nbsp;Children|,
		lastUpdated => 0,
		context => q|Used in the small pop-up copy menu.|
	},
	
	'with descendants' => {
		message => q|With&nbsp;Descendants|,
		lastUpdated => 0,
		context => q|Used in the small pop-up copy menu.|
	},
	
	'create shortcut' => {
		message => q|Create Shortcut|,
		lastUpdated => 0,
		context => q|Used in asset context menus.|
	},

	'view' => {
		message => q|View|,
		lastUpdated => 0,
		context => q|Used in asset context menus.|
	},

	'view help' => {
		message => q|Most Assets are viewed as part of a container Asset like a Page or Folder.  This option will allow you to view the Asset standalone.|,
		lastUpdated => 0,
	},

	'delete' => {
		message => q|Delete|,
		lastUpdated => 0,
		context => q|Used in asset context menus.|
	},
	
	'manage' => {
		message => q|Manage|,
		lastUpdated => 0,
		context => q|Used in asset context menus.|
	},

	'manage help' => {
		message => q|Bring up the Asset Manager displaying this Asset's children, if any.|,
		lastUpdated => 0,
	},

	'edit branch' => {
		message => q|Edit Branch|,
		lastUpdated => 0,
		context => q|Used in asset context menus.|
	},

	'edit branch help' => {
		message => q|Bring up the Edit Branch interface, to make changes to this Asset and Assets below it|,
		lastUpdated => 0,
		context => q|Used in asset context menus.|
	},

	'edit' => {
		message => q|Edit|,
		lastUpdated => 0,
		context => q|Used in asset context menus.|
	},
	
	'change' => {
		message => q|Change recursively?|,
		lastUpdated => 1099344172,
		context => q|Used when editing an entire branch, and asks whether the user wants to change this field recursively.|
	},

	'select all' => {
		message => q|Select All|,
		lastUpdated => 1099344172,
		context => q|A label for the select all checkbox on the asset manager|
	},

	'packages' => {
		message => q|Packages|,
		lastUpdated => 1099344172,
		context => q|The title of the package chooser in the asset manager|
	},
	
	'assets' => {
		message => q|Assets|,
		lastUpdated => 1099344172,
		context => q|The title of the asset manager for the admin console.|
	},
	
	'properties' => {
		message => q|Properties|,
		lastUpdated => 1099344172,
		context => q|The name of the properties tab on the edit asset.|
	},
	
	'make package' => {
		message => q|Make package?|,
		lastUpdated => 1099344172,
	},

	'make prototype' => {
		message => q|Make prototype?|,
		lastUpdated => 1099344172,
	},

	'asset id' => {
		message => q|Asset ID|,
		lastUpdated => 1099344172,
	},

        'asset id description' => {
                message => q|<p>This is the unique identifier WebGUI uses to keep track of this Asset instance. Normal users should never need to be concerned with the Asset ID, but some advanced users may need to know it for things like SQL Reports. The Asset ID is not editable.</p>|,
                lastUpdated => 1127426210,
        },

        '99 description' => {
                message => q|<p>The title of the asset.  This should be descriptive, but not very long.  If left
blank, this will be set to "Untitled".  Macros, HTML and javascript may not be placed in the title.</p>
<p><i>Note:</i> You should always specify a title, even if the Asset template will not use it. In various places on the site, like the Page Tree, Clipboard and Trash, the <b>Title</b> is used to distinguish this Asset from others.</p>|,
                lastUpdated => 1171324396,
        },

        '411 description' => {
                message => q|<p>A shorter title that will appear in navigation. If left blank,
this will default to the <b>Title</b>.</p>|,
                lastUpdated => 1146629570,
        },

        '104 description' => {
                message => q|<p>The URL for this asset.  It must be unique.  If this field is left blank, then
a URL will be made from the parent's URL and the <b>Menu Title</b>.</p>|,
                lastUpdated => 1146629543,
        },

        '886 description' => {
                message => q|<p>Whether or not this asset will be hidden from the navigation menu and site maps.</p>|,
                lastUpdated => 1146629520,
        },

        '940 description' => {
                message => q|<p>Select yes to open this asset in a new window. Note that there are potentially many problems with this. It may not work in some navigations, or if the user turns off Javascript, or it may be blocked by some pop-up blockers. Use this feature with care.</p>|,
                lastUpdated => 1143218834,
        },

        'encrypt page description' => {
                message => q|<p>Should the page containing this asset be served over SSL?</p>|,
                lastUpdated => 1146629489,
        },

        '108 description' => {
                message => q|<p>The owner of an asset is usually the person who created the asset. This user always has full edit and viewing rights of the asset.  This will default to the owner of the parent asset.</p>
<p><b>NOTE:</b> The owner can only be changed by an administrator.
</p>|,
                lastUpdated => 1168488001,
        },

        '872 description' => {
                message => q|<p>Choose which group can view this asset. If you want both visitors and registered users to be able to view the asset then you should choose the "Everybody" group.  This will default to the group which can view the parent of this asset.</p>|,
                lastUpdated => 1168488020,
        },

        '871 description' => {
                message => q|<p>Choose the group that can edit this asset. The group assigned editing rights can also always view the asset.  This will default to the group that can edit the parent of this asset.</p>|,
                lastUpdated => 1168488034,
        },

        '412 description' => {
                message => q|<p>A short description of this Asset.</p>|,
                lastUpdated => 1146629271,
        },

        'extra head tags description' => {
                message => q|<p>These tags will be added to the &lt;head&gt; section of each page on which the asset appears.</p>|,
                lastUpdated => 1165510986,
        },

        'make package description' => {
                message => q|<p>Many WebGUI tasks are very repetitive.  Automating such tasks in WebGUI, such as
creating an Asset, or sets of Assets, is done by creating a package that can be reused
throughout the site.  Check yes if you want this Asset to be available as a package.</p>|,
                lastUpdated => 1165365151,
        },

        'make prototype description' => {
                message => q|<p>Set this Asset to be a Content Prototype so that others can use it on your site.</p>|,
                lastUpdated => 1119149899,
        },

        'prototype using title' => {
                message => q|Content Prototypes, Using|,
                lastUpdated => 1127413710,
        },

	'controls' => {
		message => q|These are the icons and URLs that allow editing, cutting, copying, deleting and reordering the Asset.|,
		lastUpdated => 1148840768,
	},

	'asset template title' => {
	    message => q|Asset Template Variables|,
	    lastUpdated => 1100463645,
	},


	'asset' => {
		message => q|Asset|,
        	lastUpdated => 1100463645,
		context => 'The default name of all assets.'
	},

	'extra head tags' => {
		message => q|Extra &lt;head&gt; elements (tags)|,
		context => q|label for Asset form|,
        	lastUpdated => 1126381168,
	},

	'create package' => {
		message => q|Make available as package?|,
		context => q|label for Asset form|,
        	lastUpdated => 1106762073,
	},

	'errorEmptyField' => {
		message => q|<p><b>Error: Field name may not be empty.</b></p>|,
		lastUpdated => 1089039511,
	},

	'Select' => {
		message => q|Select...|,
		lastUpdated => 1127958072
	},

	'duplicateField' => {
		message => q|<p><b>Error: Fieldname "%field%" is already in use.</b></p>|,
		lastUpdated => 1089039511
	},

	'Metadata' => {
		message => q|Metadata|,
		lastUpdated => 1089039511
	},

	'Field name' => {
		message => q|Field name|,
		lastUpdated => 1089039511
	},

	'Edit Metadata' => {
		message => q|Edit Metadata property|,
		lastUpdated => 1089039511
	},

	'Add new field' => {
		message => q|Add new metadata property|,
		lastUpdated => 1089039511
	},

	'Add new field description' => {
		message => q|<p>Open up a form where new metadata fields can be added to this Asset.</p>|,
		lastUpdated => 1129329405
	},

	'deleteConfirm' => {
		message => q|Are you certain you want to delete this Metadata property ?|,
		lastUpdated => 1089039511
	},

	'Field Id' => {
		message => q|Field Id|,
		lastUpdated => 1089039511
	},

	'Delete Metadata field' => {
		message => q|Delete Metadata property|,
		lastUpdated => 1089039511
	},

	'content profiling' => {
		message => q|Content Profiling|,
		lastUpdated => 1089039511,
		context => q|The title of the content profiling manager for the admin console.|
	},

    'Field Name description' => {
        message => q|<p>The name of this metadata property.  It must be unique. <br />
It is advisable to use only letters (a-z), numbers (0-9) or underscores (_) for
the field names, and only be less than 100 characters long.</p>|,
        lastUpdated => 1213247248,
    },

    'Metadata Description description' => {
        message => q|<p>An optional description for this metadata property. This text is displayed
as mouseover text in the asset properties tab.</p>|,
        lastUpdated => 1129329870,
    },

    'Data Type description' => {
            message => q|<p>Choose the type of form element for this field.</p>|,
            lastUpdated => 1129329870,
    },

    'Possible Values description' => {
        message => q|This field is used for the list types (like Checkbox List and Select List).  Enter the values
you wish to appear, one per line.<br />
<br />If you want a different label for a value, the possible values list has to be
formatted as follows:
<pre>
label1\|value1
label2\|value2
label3\|value3
value4
...
</pre>
With a \| character separating the label and value. Do not put spaces before or after the \|.  Also, note
that you can mix lines with different labels with lines with the same label.<br />
If you are building a selectBox, a Select entry will automatically be added to the list of options.|,
        lastUpdated => 1243611956,
    },

	'metadata edit property' => {
		message => q|Metadata, Edit|,
		lastUpdated => 1089039511
	},

        '1079' => {
                    lastUpdated => 1073152790,
                    message => q|Printable Style|
                  },
        '959' => {
                   lastUpdated => 1052850265,
                   message => q|Empty system clipboard.|
                 },
        'Uploads URL' => {
                           lastUpdated => 1089039511,
                           context => q|Field label for the Export Page operation|,
                           message => q|Uploads URL|
                         },
        '99' => {
                  lastUpdated => 1031514049,
                  message => q|Title|
                },
        'Page Export Status' => {
                                  lastUpdated => 1089039511,
                                  context => q|Title for the Page Export Status operation|,
                                  message => q|Page Export Status|
                                },
        '1083' => {
                    lastUpdated => 1076866510,
                    message => q|New Content|
                  },
        '965' => {
                   lastUpdated => 1099050265,
                   message => q|System Trash|
                 },
        '966' => {
        	         lastUpdated => 1099050265,
                   message => q|System Clipboard|
        	       },
        'Extras URL' => {
                          lastUpdated => 1089039511,
                          context => q|Field label for the Export Page operation|,
                          message => q|Extras URL|
                        },
        '895' => {
                   lastUpdated => 1056292971,
                   message => q|Cache Timeout|
                 },
        '108' => {
                   lastUpdated => 1031514049,
                   message => q|Owner|
                 },
        '872' => {
                   lastUpdated => 1044218038,
                   message => q|Who can view?|
                 },
        '896' => {
                   lastUpdated => 1056292980,
                   message => q|Cache Timeout (Visitors)|
                 },
        'Export as user' => {
                              lastUpdated => 1089039511,
                              context => q|Field label for the Export Page operation|,
                              message => q|Export as user|
                            },
        '871' => {
                   lastUpdated => 1044218026,
                   message => q|Who can edit?|
                 },
        '104' => {
                   lastUpdated => 1031514049,
                   context => q|asset property|,
                   message => q|URL|
                 },
        '11' => {
                  lastUpdated => 1051514049,
                  message => q|Empty trash.|
                },
        '412' => {
                   lastUpdated => 1031514049,
                   message => q|Summary|
                 },
        '954' => {
                   lastUpdated => 1052850265,
                   message => q|Manage system clipboard.|
                 },
        '1082' => {
                    lastUpdated => 1076866475,
                    message => q|Clipboard|
                  },
        '107' => {
                   lastUpdated => 1031514049,
                   message => q|Security|,
                 },
        '174' => {
                   lastUpdated => 1031514049,
                   message => q|Display the title?|,
                 },
        '487' => {
                   lastUpdated => 1031514049,
                   message => q|Possible Values|,
                 },

    'default value' => {
        message => q|Default Value(s)|,
        lastUpdated => 0,
     },

    'default value description' => {
        message => q|The default value for this field. If there are multiple default values, as in the
case of the check box list, then enter one per line.  The total amount of data is limited to 255 characters.|,
        lastUpdated => 1213248323,
     },
        'Depth' => {
                     lastUpdated => 1089039511,
                     context => q|Field label for the Export Page operation|,
                     message => q|Depth|,
                   },
        '964' => {
                   lastUpdated => 1052850265,
                   message => q|Manage system trash.|,
                 },
        '105' => {
                   lastUpdated => 1046638916,
                   message => q|Display|
                 },
        '1073' => {
                    lastUpdated => 1070027660,
                    message => q|Style Template|
                  },
        'Export Page' => {
                           lastUpdated => 1089039511,
                           context => q|Title for the Export Page operation|,
                           message => q|Export Page|
                         },
        '951' => {
                   lastUpdated => 1052850265,
                   message => q|Are you certain that you wish to empty the clipboard to the trash?|
                 },
        '950' => {
                   lastUpdated => 1052850265,
                   message => q|Empty clipboard.|
                 },
        '85' => {
                  lastUpdated => 1031514049,
                  message => q|Description|
                },
        '486' => {
                   lastUpdated => 1031514049,
                   message => q|Data Type|
                 },
        '949' => {
                   lastUpdated => 1052850265,
                   message => q|Manage clipboard.|
                 },
        '411' => {
                   lastUpdated => 1031514049,
                   message => q|Menu Title|
                 },
        '886' => {
                   lastUpdated => 1044727952,
                   message => q|Hide from navigation?|
                 },
        '43' => {
                  message => q|Are you certain that you wish to delete this content, and all content below it? Note that this change is not versioned and will take place immediately.|,
                  lastUpdated => 1250091423,
                },
        '940' => {
                   lastUpdated => 1050438829,
                   message => q|Open in new window?|
                 },
	'encrypt page' => {
                message => q|Encrypt content?|,
                lastUpdated =>1092748557,
                context => q|asset property|
        },

	'asset list title' => {
		 lastUpdated => 1112220921,
		 message => q|Asset, List of Available|
	       },

	'directory index' => {
		 lastUpdated => 1118896675,
		 message => q|Directory Index|,
    },

    'Export site root URL' => {
        lastUpdated => 1227213703,
        message => q|Export site root URL|,
    },

    'Export site root URL description' => {
        lastUpdated => 1227213703,
        message => q|A URL to pass on to Macro Widgets.|,
    },

        'Depth description' => {
                message => q|<p>Sets the depth of the page tree to export. Use a depth of 0 to export only the current page. </p>|,
                lastUpdated => 1121361557,
        },

        'Export as user description' => {
                message => q|<p>Run the export as this user. Defaults to Visitor.</p>|,
                lastUpdated => 1121361557,
        },

        'directory index description' => {
                message => q|<p>If the URL of the Asset to be exported looks like a directory, the directory index will
be appended to it.</p>|,
                lastUpdated => 1121361557,
        },

        'Extras URL description' => {
                message => q|<p>Sets the Extras URL. Defaults to the configured extrasURL in the WebGUI
config file.</p>|,
                lastUpdated => 1121361557,
        },

        'Uploads URL description' => {
                message => q|<p>Sets the Uploads URL. Defaults to the configured uploadsURL in the WebGUI config file.</p>|,
                lastUpdated => 1121361557,
        },

	'Page Export' => {
                message => q|Page, Export|,
                lastUpdated => 1089039511,
                context => q|Help title for Page Export operation|
        },

	'exporting page' => {
		message => q|Exporting page %-s ......|,
		lastUpdated => 1129420080,
	},

	'bad user privileges' => {
		message => q|User has no privileges to view this page.<br />|,
		lastUpdated => 1129420080,
	},

	'could not create path' => {
		message => q|
Couldn't create %-s because %-s <br />
This most likely means that you have a page with the same name as folder that you're trying to create.<br />
|,
		lastUpdated => 1129436410,
	},

	'could not open path' => {
		message => q|
Couldn't open %-s because %-s <br />
|,
		lastUpdated => 1129436544,
	},

	'export information' => {
		message => q|
<p>Exported %d pages in %d seconds.</p>|,
		lastUpdated => 1129436684,
	},

	'done' => {
		message => q|DONE<br />|,
		lastUpdated => 1129420080,
	},

	'committed versions' => {
		message => q|Committed Versions|,
		lastUpdated => 0,
		context => q|Admin console label for manage versions.|
	},

	'Class Icon' => {
		message => q|Class Icon|,
		lastUpdated => 0,
	},

	'Class Icon help' => {
		message => q|Each Asset will also display a class icon.  Most Class Icons are unique to an Asset, and are smaller versions of the icons diplayed in the New Content menu of the Admin Console for that Asset.  Clicking on the Class Icon will show a drop-down menu with additional editing options.|,
		lastUpdated => 1165448677,
	},

	'parent url' => {
		message => q|Parent URL|,
		lastUpdated => 0,
	},

	'specified base' => {
		message => q|Specified Base|,
		lastUpdated => 0,
	},

	'none' => {
		message => q|None|,
		lastUpdated => 0,
	},

	'current url' => {
		message => q|Current URL|,
		lastUpdated => 0,
	},

	'edit branch url help' => {
		message => q|<p>You can change the URL via two parts, the base URL (the left field) and the file url (the right field).  For the base URL, there are three options:</p>
<div>
<dl>
<dt>Parent URL</dt>
<dd>Start this URL with the URL of the parent.</dd>
<dt>Specified Base</dt>
<dd>Enter in a new base URL via the field that appears when Specified Base is selected.</dd>
<dt>None</dt>
<dd>Make all Assets have a "top-level" URL.</dd>
</dl>
</div>
<p>There are also three options for the file URL:</p>
<div>
<dl>
<dt>Menu Title</dt>
<dd>The new URL will be based on the Asset's Menu Title field.</dd>
<dt>Title</dt>
<dd>The new URL will be based on the Asset's Title field.</dd>
<dt>Current URL</dt>
<dd>The new URL will be based on the Asset's present URL.</dd>
</dl>
</div>
<p>New URLs will be passed through the makeUrlCompliant function that is specific to the default language for your site.</p>
|,
		lastUpdated => 0,
	},

	'topicName' => {
		message => q|Assets|,
		lastUpdated => 1128920336,
	},

	'extrasUploads symlinking' => {
		message => q|Symlinking extras and uploads dirs.|,
		lastUpdated => 1160773957,
	},

	'rootUrl symlinking default' => {
		message => q|Symlinking extras and uploads dirs.|,
		lastUpdated => 1160773957,
	},

	'rootUrl default not present' => {
		message => q|Not symlinking default asset; not included in exported subtree.|,
		lastUpdated => 1160773957,
	},

	'could not create' => {
		message => q|Could not create %s: %s|,
		lastUpdated => 1160773957,
	},

	'could not unlink' => {
		message => q|Could not unlink %s: %s|,
		lastUpdated => 1160773957,
	},

	'could not rmdir' => {
		message => q|Could not remove directory at %s: %s|,
		lastUpdated => 1160773957,
	},

	'could not symlink' => {
		message => q|Could not symlink %s to %s: %s|,
		lastUpdated => 1160773957,
	},

	'extrasUploads form label' => {
		message => q|Extras and uploads directories|,
		lastUpdated => 1160773957,
	},

	'extrasUploads form hoverHelp' => {
		message => q|What action to take regarding the extras and uploads directories, which are often referenced by parts of the site.  Symlink means to use a symbolic link (not available on all systems) to the original directory.  None means to do nothing, and ignore the extras and uploads directories; this will probably cause references to them to break in the exported site unless you've prepared the directories already.|,
		lastUpdated => 1160773957,
	},

	'extrasUploads form option symlink' => {
		message => q|Symlink|,
		lastUpdated => 1160773957,
	},

	'extrasUploads form option none' => {
		message => q|None|,
		lastUpdated => 1160773957,
	},

	'rootUrl form label' => {
		message => q|Root URL|,
		lastUpdated => 1160773957,
	},

	'rootUrl form hoverHelp' => {
		message => q|What action to take regarding queries to the root URL.  Symlink Default means to create a symbolic link from the root-URL index file to the index file of the default asset (not available on all systems).  None means to do nothing, which usually causes queries to the root URL to be rejected in the exported site.|,
		lastUpdated => 1160773957,
	},

	'rootUrl form option symlinkDefault' => {
		message => q|Symlink Default|,
		lastUpdated => 1160773957,
	},

	'rootUrl form option none' => {
		message => q|None|,
		lastUpdated => 1160773957,
	},

	'asset template asset var title' => {
	    message => q|Asset Template Asset Variables|,
	    lastUpdated => 1100463645,
	},

	'title' => {
		message => q|The title of the Asset|,
		lastUpdated => 1160773957,
	},

	'menuTitle' => {
		message => q|The title of the Asset used in Navigations.|,
		lastUpdated => 1160773957,
	},

	'url' => {
		message => q|The Asset's URL.|,
		lastUpdated => 1160773957,
	},

	'isHidden' => {
		message => q|A boolean that will be true if this Asset is set not be displayed in Navigations.|,
		lastUpdated => 1160773957,
	},

	'newWindow' => {
		message => q|A boolean that will be true if this Asset is set open in a new browser window.|,
		lastUpdated => 1160773957,
	},

	'encryptPage' => {
		message => q|A boolean that will be true if this Asset is set to be served over SSL.|,
		lastUpdated => 1160773957,
	},

	'ownerUserId' => {
		message => q|The ID of the user who owns this Asset.|,
		lastUpdated => 1160773957,
	},

	'groupIdView' => {
		message => q|The ID of the group that is allowed to view this Asset.|,
		lastUpdated => 1160773957,
	},

	'groupIdEdit' => {
		message => q|The ID of the group that is allowed to edit this Asset.|,
		lastUpdated => 1160773957,
	},

	'synopsis' => {
		message => q|A short description of the contents of the Asset.|,
		lastUpdated => 1160773957,
	},

	'extraHeadTags' => {
		message => q|Extra tags that will be added to the header of the page containing the Asset.  These will be included by default so you do not need to add them youself, unless you want them to be in there twice.|,
		lastUpdated => 1160773957,
	},

	'isPackage' => {
		message => q|A boolean that will be true if this Asset is set to be a Package.|,
		lastUpdated => 1160773957,
	},

	'isPrototype' => {
		message => q|A boolean that will be true if this Asset is set to be a prototype.|,
		lastUpdated => 1160773957,
	},

	'status' => {
		message => q|With respect to version control, the status of this Asset.  Typically these are the English strings "approved", "pending", "committed".|,
		lastUpdated => 1160773957,
	},

	'assetSize' => {
		message => q|How big this asset is in bytes.  The sum of all database fields and attachments.|,
		lastUpdated => 1160773957,
	},

    'make asset exportable' => {
        message => q|Make this asset exportable?|,
        lastUpdated => 0,
    },

    'make asset exportable description' => {
        message => q|<p>Is this asset allowed to be exported as static HTML, which is different from a package? This asset, and all of its parent assets, must be exportable for this asset to be exported.  Also, exporting has to be enabled in the WebGUI config file for this site.</p>|,
        lastUpdated => 1214854199,
    },

    'does asset inherit URL from parent' => {
        message => q|Prepend URL from parent?|,
        lastUpdated => 1212183809,
    },

    'does asset inherit URL from parent description' => {
        message => q|<p>Will this asset have its URL prepended with its parent URL?</p>|,
        lastUpdated => 1212183809,
    },

    'search' => {
        message     => q{Search},
        lastUpdated => 0,
        context     => "Label for the Search function of the asset manager",
    },

    'with selected' => {
        message     => q{With Selected: },
        lastUpdated => 0,
        context     => q{Introduction to the action buttons.},
    },


    'update' => {
        message     => q{Update},
        lastUpdated => 0,
        context     => q{Label for the update action. Currently only affects rank.},
    },

    'page indicator' => {
        message     => q{Showing page %s of %s},
        lastUpdated => 0,
        context     => q{Which page we're on. First field is the current page. Second field is the total number of pages},
    },

    'no results' => {
        message     => q{No Results Found!},
        lastUpdated => 0,
        context     => q{Message when no assets match search criteria},
    },

    'More' => {
        message     => q{More},
        lastUpdated => 0,
        context     => q{Label for the menu to show actions to perform on an asset},
    },

    'export' => {
        message     => q{More},
        lastUpdated => 0,
        context     => q{Label for the menu to show actions to perform on an asset},
    },

    'Export site root URL' => {
        message     => q{Export site root URL},
        lastUpdated => 0,
        context     => q{Label for the menu to show actions to perform on an asset},
    },

    'Error: Cannot instantiate template' => {
        message     => q{Error: Cannot instantiate template},
        lastUpdated => 1221593874,
        context     => q{Error message in Asset.pm},
    },

    'inherit parent permissions' => {
        message     => q{Inherit parent's permissions},
        lastUpdated => 1221593874,
        context     => q{Error message in Asset.pm},
    },

    'need a userId parameter' => {
        message     => q{need a userId parameter},
        lastUpdated => 0,
        context     => q{Error message in exportAsHtml for an illegal parameter.},
    },

    'is not a valid userId' => {
        message     => q{is not a valid userId},
        lastUpdated => 0,
        context     => q{Error message in exportAsHtml for an illegal parameter.},
    },

    'need a depth' => {
        message     => q{need a depth},
        lastUpdated => 0,
        context     => q{Error message in exportAsHtml for an illegal parameter.},
    },

    '%s is not a valid depth' => {
        message     => q{%s is not a valid depth},
        lastUpdated => 0,
        context     => q{Error message in exportAsHtml for an illegal parameter.},
    },

    'unlocked' => {
        message     => q{unlocked},
        lastUpdated => 0,
        context     => q{Asset Manager label, when an asset is unlocked.},
    },

    'locked by' => {
        message     => q{locked by},
        lastUpdated => 0,
        context     => q{Asset Manager label, as in "locked by admin"},
    },

    'Any Class' => {
        message     => q{Any Class},
        lastUpdated => 0,
        context     => q{Class, as in name of class, or type of asset},
    },

};

1;
