package WebGUI::i18n::English::Asset_Story;
use strict;

our $I18N = {

    'assetName' => {
        message => q|Story|,
        context => q|Story, as in news story.|,
        lastUpdated => 0
    },

    'headline' => {
        message => q|Headline|,
        context => q|Usually the title of a story. Label in the edit screen and template.|,
        lastUpdated => 0
    },

    'headline help' => {
        message => q|Often the same as title.  If left blank, it will take the headline from the title.|,
        context => q|Hoverhelp in the edit screen and template.|,
        lastUpdated => 0
    },

    'headline tmplvar' => {
        message => q|The headline for the Story.|,
        context => q|Template variable help.|,
        lastUpdated => 0
    },

    'subtitle' => {
        message => q|Subtitle|,
        context => q|Similar to headline, but usually contains more information. Label in the edit screen and template.|,
        lastUpdated => 0
    },

    'subtitle help' => {
        message => q|Similar to headline, but usually contains more information.|,
        context => q|Hoverhelp in the edit screen and template.|,
        lastUpdated => 0
    },

    'subtitle tmplvar' => {
        message => q|The subtitle from the Story.|,
        context => q|Template variable help.|,
        lastUpdated => 0
    },

    'byline' => {
        message => q|By line|,
        context => q|Who wrote the story. Label in the edit screen and template.|,
        lastUpdated => 0
    },

    'byline help' => {
        message => q|Who wrote the story.|,
        context => q|Hoverhelp in the edit screen and template.|,
        lastUpdated => 0
    },

    'byline tmplvar' => {
        message => q|The byline from the Story.|,
        context => q|Template variable help.|,
        lastUpdated => 0
    },

    'location' => {
        message => q|Location|,
        context => q|Where the story takes place. Label in the edit screen and template.|,
        lastUpdated => 0
    },

    'location help' => {
        message => q|Where the story takes place.|,
        context => q|Hoverhelp in the edit screen and template.|,
        lastUpdated => 0
    },

    'location tmplvar' => {
        message => q|The location from the Story.|,
        context => q|Template variable help.|,
        lastUpdated => 0
    },

    'highlights' => {
        message => q|Story Highlights|,
        context => q|Bullet point level summaries from the story. Label in the edit screen and template.|,
        lastUpdated => 0
    },

    'highlights help' => {
        message => q|Bullet point level items from the story.  Enter 1 per line.|,
        context => q|Hoverhelp in the edit screen and template.|,
        lastUpdated => 0
    },

    'highlights tmplvar' => {
        message => q|All of the highlights from the Story.  Each highlight will be separated by a newline character.|,
        context => q|Template variable help.|,
        lastUpdated => 0
    },

    'story' => {
        message => q|Story|,
        context => q|Label in the edit screen and template.|,
        lastUpdated => 0
    },

    'story help' => {
        message => q|The story.|,
        context => q|Hoverhelp in the edit screen and template.|,
        lastUpdated => 0
    },

    'story tmplvar' => {
        message => q|The story.  Note that it may contain embedded content from the Rich Text Editor.|,
        context => q|Template variable help.|,
        lastUpdated => 0
    },

    'save story' => {
        message => q|Save Story|,
        context => q|Button label in the Edit Story form.|,
        lastUpdated => 0
    },

    'save and add another photo' => {
        message => q|Save and Add Another Photo|,
        context => q|Button label in the Edit Story form.|,
        lastUpdated => 0
    },

    'story received' => {
        message => q|Your story has been received and is being processed so it can be added to the site. It will be available for further editing after being processed. Please be patient.|,
        lastUpdated => 0,
    },

    'edit template' => {
        message => q|Edit Story Template.|,
        lastUpdated => 0,
    },

    'formHeader' => {
        message => q|HTML code to begin the form for adding or editing a Story.|,
        lastUpdated => 0,
    },

    'formTitle' => {
        message => q|Internationalized title for this form.|,
        lastUpdated => 0,
    },

    'titleForm' => {
        message => q|Form for the user to enter a title for this story.|,
        lastUpdated => 0,
    },

    'headlineForm' => {
        message => q|Form for the user to enter a headline for this story.|,
        lastUpdated => 0,
    },

    'subtitleForm' => {
        message => q|Form for the user to enter a subtitle for this story.|,
        lastUpdated => 0,
    },

    'bylineForm' => {
        message => q|Form for the user to enter a byline for this story.|,
        lastUpdated => 0,
    },

    'locationForm' => {
        message => q|Form for the user to enter a location for this story.|,
        lastUpdated => 0,
    },

    'keywordsForm' => {
        message => q|Form for the user to enter keywords for this story.|,
        lastUpdated => 0,
    },

    'summaryForm' => {
        message => q|Form for the user to enter a summary of this story.|,
        lastUpdated => 0,
    },

    'highlightsForm' => {
        message => q|Form for the user to enter highlights for this story.|,
        lastUpdated => 0,
    },

    'storyForm' => {
        message => q|Form for the user to enter the actual story.|,
        lastUpdated => 0,
    },

    'saveButton' => {
        message => q|Button for the user to save the form.|,
        lastUpdated => 0,
    },

    'saveAndAddButton' => {
        message => q|Button for the user to save the form, and then reopen the edit form to add another photo.|,
        lastUpdated => 0,
    },

    'cancelButton' => {
        message => q|Button for the user to cancel this form without saving anything.|,
        lastUpdated => 0,
    },

    'formFooter' => {
        message => q|HTML code to end the form for adding or editing a Story.|,
        lastUpdated => 0,
    },

    'view template' => {
        message => q|View Story Template.|,
        lastUpdated => 0,
    },

    'highlights_loop' => {
        message => q|A loop containing all the highlights from the story.|,
        lastUpdated => 0,
    },

    'highlight' => {
        message => q|One highlight, without formatting or extra HTML.|,
        lastUpdated => 0,
    },

    'keywords_loop' => {
        message => q|A loop containing all the keywords from the story.|,
        lastUpdated => 0,
    },

    'keyword' => {
        message => q|One keyword, with no formatting.|,
        lastUpdated => 0,
    },

    'keyword_url' => {
        message => q|A URL to view all stories in this archive related to this keyword.|,
        lastUpdated => 0,
    },

    'crumb_loop' => {
        message => q|A loop containing the crumbtrail.  The first element will be a link to the archive that contains the story.  The last element will be the story, with title and url.  If there are 3 elements, the middle element will be the topic.|,
        lastUpdated => 0,
    },

    'crumb_title' => {
        message => q|The title of a page in the crumb trail.|,
        lastUpdated => 0,
    },

    'crumb_url' => {
        message => q|The url of a page in the crumb trail.|,
        lastUpdated => 1248191458,
    },

    'updatedTime' => {
        message => q|The time this Story was last updated, as a formatted duration, like 1 Hour(s) ago.|,
        lastUpdated => 0,
    },

    'updatedTimeEpoch' => {
        message => q|The time this Story was last updated, as an epoch.|,
        lastUpdated => 0,
    },

    'photo tmplvar' => {
        message => q|The photo JSON blob from the Story asset.|,
        lastUpdated => 0,
    },

    'ago' => {
        message => q|ago|,
        context => q|As in the phrase, Last updated 3 hours ago.|,
        lastUpdated => 0,
    },

    'story asset template variables title' => {
        message => q|Story Asset Template Variables.|,
        context => q|Title of a help page for asset level template variables.|,
        lastUpdated => 0,
    },

    'photo_form_loop' => {
        message => q|A loop containing subforms for all photos that have been loaded, and a blank form for uploading new photos.|,
        context => q|Template variable for edit form.|,
        lastUpdated => 0,
    },

    'imgRemoteUrlForm' => {
        message => q|A form field to specify a remote url for a photo.|,
        context => q|Template variable for edit form.|,
        lastUpdated => 0,
    },

    'newUploadForm' => {
        message => q|A form field to upload an image.|,
        context => q|Template variable for edit form.|,
        lastUpdated => 0,
    },

    'imgCaptionForm' => {
        message => q|A form field for the caption for this image.|,
        context => q|Template variable for edit form.|,
        lastUpdated => 0,
    },

    'imgBylineForm' => {
        message => q|A form field for a by-line for this image.|,
        context => q|Template variable for edit form.|,
        lastUpdated => 0,
    },

    'imgAltForm' => {
        message => q|A form field for alternate text for the image, for the IMG tag ALT field.|,
        context => q|Template variable for edit form.|,
        lastUpdated => 0,
    },

    'imgTitleForm' => {
        message => q|A form field for the title for the image, for the IMG tag TITLE field.|,
        context => q|Template variable for edit form.|,
        lastUpdated => 0,
    },

    'imgUrlForm' => {
        message => q|A field for the URL for this image.  If present, then the image will be rendered as a link to this URL.|,
        context => q|Template variable for edit form.|,
        lastUpdated => 0,
    },

    'imgDeleteForm' => {
        message => q|A field to delete the image, along with all data attached to it.  This form will not be present in the set of variables in the loop for adding a new image.|,
        context => q|Template variable for edit form.|,
        lastUpdated => 0,
    },

    'photo remote url' => {
        message => 'Photo Remote URL',
        context => 'Label in the edit story form. Location of image (instead
        of uploaded location)',
        lastUpdated => 0,
    },

    'photo caption' => {
        message => q|Photo Caption|,
        context => q|Label in the edit story form.  Short for Photograph Caption.|,
        lastUpdated => 0,
    },

    'photo byline' => {
        message => q|Photo By Line|,
        context => q|Label in the edit story form.  The person who took, or owns this photo.|,
        lastUpdated => 0,
    },

    'photo alt' => {
        message => q|Photo Alternate Text|,
        context => q|Label in the edit story form.  Text for the ALT attribute of an IMG tag.|,
        lastUpdated => 0,
    },

    'photo title' => {
        message => q|Photo Alternate Title|,
        context => q|Label in the edit story form.  Text for the TITLE attribute of an IMG tag.|,
        lastUpdated => 0,
    },

    'photo url' => {
        message => q|Photo URL|,
        context => q|Label in the edit story form.  A link from the photo to more information about it, or referring to it.|,
        lastUpdated => 0,
    },

    'photo delete' => {
        message => q|Delete Photo and Metadata|,
        context => q|Label in the edit story form.  Request that the photo be deleted, and all information with it.|,
        lastUpdated => 1250195747,
    },

    'photo_loop' => {
        message => q|A loop containing photos and information about the photos.|,
        context => q|Template variable|,
        lastUpdated => 0,
    },

    'imageUrl' => {
        message => q|The URL to the image.|,
        context => q|Template variable|,
        lastUpdated => 0,
    },

    'imageCaption' => {
        message => q|A caption for the image.|,
        context => q|Template variable|,
        lastUpdated => 0,
    },

    'imageByline' => {
        message => q|A byline for the image.|,
        context => q|Template variable|,
        lastUpdated => 0,
    },

    'imageAlt' => {
        message => q|Alternate text for the image, suitable for use as the ALT parameter for an IMG tag.|,
        context => q|Template variable|,
        lastUpdated => 0,
    },

    'imageTitle' => {
        message => q|Alternate text for the image, suitable for use as the TITLE parameter for an IMG tag.|,
        context => q|Template variable|,
        lastUpdated => 0,
    },

    'imageLink' => {
        message => q|A URL for the image to link to.|,
        context => q|Template variable|,
        lastUpdated => 0,
    },

    'hasPhotos' => {
        message => q|This template variable will be true if the Story has photos uploaded to it.|,
        context => q|Template variable|,
        lastUpdated => 0,
    },

    'photoWidth' => {
        message => q|The width of photos, set in the Story Archive for this Story.|,
        context => q|Template variable|,
        lastUpdated => 0,
    },

    'photoHeight' => {
        message => q|The height of slides, set in the Story Archive for this Story.|,
        context => q|Template variable|,
        lastUpdated => 0,
    },

    'hasPhoto' => {
        message => q|This template variable will be true if the a photo in the photo_loop has an image in it.|,
        context => q|Template variable|,
        lastUpdated => 0,
    },

    'imgThumb' => {
        message => q|The URL to the thumbnail of the image, if this photo has an image.|,
        context => q|Template variable|,
        lastUpdated => 0,
    },

    'imgUrl' => {
        message => q|The URL to the image, if this photo has an image.|,
        context => q|Template variable|,
        lastUpdated => 0,
    },

    'imgFilename' => {
        message => q|The URL to the image, if this photo has an image.|,
        context => q|Template variable|,
        lastUpdated => 0,
    },

    'singlePhoto' => {
        message => q|This template variable will be true if the Story has just 1 photo uploaded to it.|,
        context => q|Template variable|,
        lastUpdated => 0,
    },

    'imageLink' => {
        message => q|A URL for the image to link to.|,
        context => q|Template variable|,
        lastUpdated => 0,
    },

    'Source' => {
        message => q|Source|,
        context => q|Label for story template.  Referring to who took, or who owns, a picture.|,
        lastUpdated => 0,
    },

    'canEdit' => {
        message => q|A boolean which will be true if the current user can edit this story.|,
        lastUpdated => 0,
    },

    'Replace image with new image' => {
        message => q|Replace image with new image|,
        lastUpdated => 0,
    },

};

1;
