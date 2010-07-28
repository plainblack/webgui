package WebGUI::i18n::English::Asset_StoryArchive;
use strict;

our $I18N = {

    'assetName' => {
        message => q|Story Archive|,
        context => q|An Asset that holds stories.|,
        lastUpdated => 0
    },

    'stories per page' => {
        message => q|Stories Per Page|,
        context => q|Label in the edit screen and template.|,
        lastUpdated => 0
    },

    'stories per page help' => {
        message => q|The number of stories displayed on a page.  If the asset is exported as HTML, then the generated page will have 10 standard pages of stories.|,
        context => q|Hoverhelp in the edit screen and template.|,
        lastUpdated => 0
    },

    'group to post' => {
        message => q|Group to Post|,
        context => q|Label in the edit screen and template.|,
        lastUpdated => 0
    },

    'group to post help' => {
        message => q|The group allowed to add stories to this Story Archive.|,
        context => q|Hoverhelp in the edit screen and template.|,
        lastUpdated => 0
    },

    'groupToPost' => {
        message => q|The GUID of the group allowed to add stories to this Story Archive.|,
        context => q|Template variable.|,
        lastUpdated => 0
    },

    'template' => {
        message => q|Story Archive Template|,
        context => q|Label in the edit screen and template.|,
        lastUpdated => 0
    },

    'template help' => {
        message => q|The Template used to display the Story Archive.|,
        context => q|Hoverhelp in the edit screen and template.|,
        lastUpdated => 0
    },

    'templateId' => {
        message => q|The GUID of the template used to display the Story Archive.|,
        context => q|Template variable|,
        lastUpdated => 0
    },

    'story template' => {
        message => q|Story Template|,
        context => q|Label in the edit screen and template.|,
        lastUpdated => 0
    },

    'story template help' => {
        message => q|The Template used to display Story assets from this Story Archive.|,
        context => q|Hoverhelp in the edit screen and template.|,
        lastUpdated => 0
    },

    'storyTemplateId' => {
        message => q|The GUID of the template used to display the Story assets.|,
        context => q|Template variable|,
        lastUpdated => 0
    },

    'edit story template' => {
        message => q|Edit Story Template|,
        context => q|Label in the edit screen and template.|,
        lastUpdated => 0
    },

    'edit story template help' => {
        message => q|The Template used to add or edit Story assets.|,
        context => q|Hoverhelp in the edit screen and template.|,
        lastUpdated => 0
    },

    'keyword list template' => {
        message => q|Keyword List Template|,
        context => q|Label in the edit screen and template.|,
        lastUpdated => 0
    },

    'keyword list template help' => {
        message => q|The Template used to render the list of assets matching a keyword when this StoryArchive is exported.|,
        context => q|Hoverhelp in the edit screen and template.|,
        lastUpdated => 0
    },

    'editStoryTemplateId' => {
        message => q|The GUID of the template used to add or edit Story assets.|,
        context => q|Template variable|,
        lastUpdated => 0
    },

    'keywordListTemplateId' => {
        message => q|The GUID of the template used to render list of assets matching a keyword when this StoryArchive is exported.|,
        context => q|Template variable|,
        lastUpdated => 0
    },

    'archive after' => {
        message => q|Archive Stories After|,
        context => q|Label in the edit screen and template.|,
        lastUpdated => 0
    },

    'archive after help' => {
        message => q|After this time, Story assets will be archived and no longer show up in the list of Stories or feeds.  Set to 0 to disable archiving.|,
        context => q|Hoverhelp in the edit screen and template.|,
        lastUpdated => 0
    },

    'archiveAfter' => {
        message => q|Amount of time in seconds.  After this time, Stories will be archived.|,
        context => q|Template variable|,
        lastUpdated => 0
    },

    'rich editor' => {
        message => q|Rich Editor|,
        context => q|Label in the edit screen and template.|,
        lastUpdated => 0
    },

    'rich editor help' => {
        message => q|The WYSIWIG editor used to edit the content of Story assets.|,
        context => q|Hoverhelp in the edit screen and template.|,
        lastUpdated => 0
    },

    'richEditorId' => {
        message => q|The GUID of the WYSIWIG editor used to edit the content of Story assets.|,
        context => q|Template variable|,
        lastUpdated => 0
    },

    'approval workflow' => {
        message => q|Story Approval Workflow|,
        context => q|Label in the edit screen and template.|,
        lastUpdated => 0,
    },

    'approval workflow help' => {
        message => q|Choose a workflow to be executed on each Story as it gets submitted.|,
        context => q|Hoverhelp in the edit screen and template.|,
        lastUpdated => 0,
    },

    'approvalWorkflowId' => {
        message => q|The GUID of the workflow to be executed on each Story as it gets submitted.|,
        context => q|Template variable|,
        lastUpdated => 0,
    },

    'storyarchive asset template variables title' => {
        message => q|Story Archive Asset Template Variables.|,
        context => q|Title of a help page for asset level template variables.|,
        lastUpdated => 0,
    },

    'keyword list template' => {
        message => q|Story Archive, Keyword List Template|,
        context => q|Title of a help page.|,
        lastUpdated => 0,
    },

    'view template' => {
        message => q|Story Archive, View Template|,
        context => q|Title of a help page.|,
        lastUpdated => 0,
    },

    'date_loop' => {
        message => q|A loop containing stories in the date they were submitted, with subloops for each day.  The loop is paginated.|,
        context => q|Template variable.|,
        lastUpdated => 0,
    },

    'epochDate' => {
        message => q|The epoch that is the beginning of the day for a day where stories were submitted to the Story Archive.|,
        context => q|Template variable.|,
        lastUpdated => 0,
    },

    'story_loop' => {
        message => q|A loop containing all stories there were submitted on the day given by epochDate.|,
        context => q|Template variable.|,
        lastUpdated => 0,
    },

    'url' => {
        message => q|The URL to view a story.|,
        context => q|Template variable.|,
        lastUpdated => 0,
    },

    'title' => {
        message => q|The title of a story.|,
        context => q|Template variable.|,
        lastUpdated => 0,
    },

    'creationDate' => {
        message => q|The epoch date when this story was created, or submitted, to the Story Archive.|,
        context => q|Template variable.|,
        lastUpdated => 0,
    },

    'deleteIcon' => {
        message => q|An icon to delete this story.  If the user is not allowed to delete the story, or their UI level is set too low, this variable will be empty.|,
        context => q|Template variable.|,
        lastUpdated => 1247068423,
    },

    'editIcon' => {
        message => q|An icon to edit this story.  If the user is not allowed to edit the story, or their UI level is set too low, this variable will be empty.|,
        context => q|Template variable.|,
        lastUpdated => 1247068422,
    },

    'add a story' => {
        message => q|Add a Story.|,
        context => q|label for the URL to add a story to the archive.|,
        lastUpdated => 0,
    },

    'searchHeader' => {
        message => q|HTML code for beginning the search form. This variable is empty when the Story Archive is being exported as HTML.|,
        context => q|Template variable.|,
        lastUpdated => 0,
    },

    'searchForm' => {
        message => q|The text field where users can enter in keywords for the search. This variable is empty when the Story Archive is being exported as HTML.|,
        context => q|Template variable.|,
        lastUpdated => 0,
    },

    'searchButton' => {
        message => q|Button with internationalized label for submitting the search form. This variable is empty when the Story Archive is being exported as HTML.|,
        context => q|Template variable.|,
        lastUpdated => 0,
    },

    'searchFooter' => {
        message => q|HTML code for ending the search form. This variable is empty when the Story Archive is being exported as HTML.|,
        context => q|Template variable.|,
        lastUpdated => 0,
    },

    'canPostStories' => {
        message => q|A boolean which is true if the user can post stories.|,
        context => q|Template variable.|,
        lastUpdated => 0,
    },

    'addStoryUrl' => {
        message => q|The URL for the user to add a Story.|,
        context => q|Template variable.|,
        lastUpdated => 0,
    },

    'rssUrl' => {
        message => q|The URL for the RSS feed for this Story Archive.|,
        context => q|Template variable.|,
        lastUpdated => 0,
    },

    'atomUrl' => {
        message => q|The URL for the Atom feed for this Story Archive.|,
        context => q|Template variable.|,
        lastUpdated => 0,
    },

    'keywordCloud' => {
        message => q|The tag cloud for the keywords for stories in this Story Archive.|,
        context => q|Template variable.|,
        lastUpdated => 0,
    },

    'asset_loop' => {
        message => q|A loop containing up to the first 50 assets that match the keyword.|,
        context => q|Template variable.|,
        lastUpdated => 0,
    },

    'asset title' => {
        message => q|The title of this asset.|,
        context => q|Template variable.|,
        lastUpdated => 0,
    },

    'asset url' => {
        message => q|The URL of this asset.|,
        context => q|Template variable.|,
        lastUpdated => 1250263822,
    },

    'keyword' => {
        message => q|The keyword for this list of assets.|,
        context => q|Template variable.|,
        lastUpdated => 0,
    },

    'photoWidth' => {
        message => q|The width that all photos uploaded into Stories for this StoryArchive will be resized to.|,
        context => q|Template variable.|,
        lastUpdated => 0,
    },

    'photo width' => {
        message => q|Photo width|,
        context => q|Label in the edit screen|,
        lastUpdated => 0,
    },

    'photo width help' => {
        message => q|Photos displayed by the YUI Carousel need to be similar sizes for it to render correctly.  This width will be used to resize all photos.  To disable this feature, set it to 0.|,
        context => q|hoverhelp for photoWidth in the edit screen|,
        lastUpdated => 0,
    },

    'sortAlphabeticallyChronologically' => {
        message => q|Sort Order|,
        context => q|Label in the edit screen|,
        lastUpdated => 1276631190,
    },

    'sortAlphabeticallyChronologically description' => {
        message => q|Set messages to appear in order of publish date or alphabetically by title|,
        context => q|Tooltip in the edit screen|,
        lastUpdated => 1276631190,
    },

    'alphabetically' => {
        message => q|Alphabetically|,
        context => q|Select option in the edit screen|,
        lastUpdated => 1276631190,
    },

    'chronologically' => {
        message => q|Chronologically|,
        context => q|Select option in the edit screen|,
        lastUpdated => 1276631190,
    },

};

1;
