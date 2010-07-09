package WebGUI::i18n::English::Asset_Photo;  

our $I18N = { 
    'assetName' => {
        message     => q{Photo},
        lastUpdated => 0,
    },

    'delete message' => {
        message     => q{The photo has been deleted. <a href="%s">Return to Album</a>},
        lastUpdated => 0,
    },

    'save message'  => {
        message     => q{Your photo has been submitted for approval and commit. <a href="%s">View Photo</a>. <a href="%s">Add another photo</a>.},
        lastUpdated => 0,
    },

    'comment message' => {
        message     => q{Your comment has been added. <a href="%s">Back to Photo</a>.},
        lastUpdated => 0,
    },

    'editCommentSave message' => {
        message     => q{The comment has been updated. <a href="%s">Back to Photo</a>.},
        lastUpdated => 0,
        context     => q{Message after a comment is edited.},
    },

    'help commentForm title' => {
        message     => 'Photo -- Comment Form',
        lastUpdated => 0,
    },

    'help commentForm body' => {
        message     => 'These template variables make up the form to allow users to post comments on Photos',
        lastUpdated => 0,
    },

    'help common title' => {
        message     => 'Photo -- Common',
        lastUpdated => 0,
    },

    'help common body' => {
        message     => 'These template variables are shared by all views of the Photo asset.',
        lastUpdated => 0,
    },

    'help edit title' => {
        message     => 'Photo -- Edit Form',
        lastUpdated => 0,
    },

    'help edit body' => {
        message     => 'These template variables make up the form to add / edit Photo assets',
        lastUpdated => 0,
    },

    'help delete title' => {
        message     => 'Photo -- Delete Form',
        lastUpdated => 0,
    },

    'help delete body' => {
        message     => 'Confirm the delete of a Photo asset.',
        lastUpdated => 0,
    },

    'help makeShortcut title' => {
        message     => 'Photo -- Make Shortcut Form',
        lastUpdated => 0,
    },

    'help makeShortcut body' => {
        message     => 'These template variables make up the form to cross-post Photo assets',
        lastUpdated => 0,
    },

    'help view title' => {
        message     => 'Photo -- Normal View',
        lastUpdated => 0,
    },

    'help view body' => {
        message     => 'These template variables make up the normal view of Photo assets',
        lastUpdated => 0,
    },

    'helpvar isNewPhoto' => {
        message     => 'This variable is true if the user is adding a new Photo.',
        lastUpdated => 0,
    },

    'helpvar commentForm_start' => {
        message     => 'Begin the comment form.',
        lastUpdated => 0,
    }, 

    'helpvar commentForm_end' => {
        message     => 'End the comment form.',
        lastUpdated => 0,
    },

    'helpvar commentForm_bodyText' => {
        message     => 'The body of the comment. A rich editor as configured by the parent Gallery.',
        lastUpdated => 0,
    },

    'helpvar commentForm_submit' => {
        message     => 'Submit the comment form.',
        lastUpdated => 0,
    },

    'helpvar canComment' => {
        message     => 'This is true if the current user can comment on this photo.',
        lastUpdated => 0,
    },

    'helpvar canEdit' => {
        message     => 'This is true if the current user can edit this photo.',
        lastUpdated => 0,
    },

    'helpvar fileUrl' => {
        message     => 'The URL to the normal-sized photo.',
        lastUpdated => 0,
    },

    'helpvar numberOfComments' => {
        message     => 'The total number of comments on this photo.',
        lastUpdated => 0,
    },

    'helpvar ownerUsername' => {
        message     => 'The username of the user who posted this photo.',
        lastUpdated => 0,
    },

    'helpvar ownerAlias' => {
        message     => 'The alias of the user who posted this photo. Defaults to the username if not available.',
        lastUpdated => 0,
    },

    'helpvar ownerId' => {
        message     => 'The Id of the user who posted this photo.',
        lastUpdated => 0,
    },

    'helpvar ownerProfileUrl' => {
        message     => 'The URL to the profile of the user who posted this photo.',
        lastUpdated => 0,
    },

    'helpvar thumbnailUrl' => {
        message     => 'The URL to the thumbnail of this photo.',
        lastUpdated => 0,
    },

    'helpvar url_delete' => {
        message     => 'The URL to delete this photo.',
        lastUpdated => 0,
    },

    'helpvar url_demote' => {
        message     => 'The URL to demote this photo in rank. Will return the user directly to the parent GalleryAlbum edit form.',
        lastUpdated => 0,
    },

    'helpvar url_edit' => {
        message     => 'The URL to edit this photo.',
        lastUpdated => 0,
    },

    'helpvar url_gallery' => {
        message     => 'The URL to the Gallery that contains this photo.',
        lastUpdated => 0,
    },

    'helpvar url_makeShortcut' => {
        message     => 'The URL to make a shortcut to this photo.',
        lastUpdated => 0,
    },

    'helpvar url_listFilesForOwner' => {
        message     => 'The URL to list files and albums posted by the owner of this photo.',
        lastUpdated => 0,
    },

    'helpvar url_promote' => {
        message     => 'The URL to promote this photo in rank. Will return the user directly to the parent GalleryAlbum edit form.',
        lastUpdated => 0,
    },

    'helpvar resolutions_loop' => {
        message     => 'The available resolutions this photo has for download.',
        lastUpdated => 0,
    },

    'helpvar resolutions_loop url_download' => {
        message     => 'The URL to the resolution to download.',
        lastUpdated => 0,
    },

    'helpvar exif_' => {
        message     => 'Each EXIF tag can be referenced by name.',
        lastUpdated => 0,
    },

    'helpvar exifLoop' => {
        message     => 'A loop of EXIF tags.',
        lastUpdated => 0,
    },

    'helpvar exifLoop tag' => {
        message     => 'The name of the EXIF tag.',
        lastUpdated => 0,
    },

    'helpvar exifLoop value' => {
        message     => 'The value of the EXIF tag.',
        lastUpdated => 0,
    },

    'helpvar url_addArchive' => {
        message     => 'The URL to add an archive to the parent Album.',
        lastUpdated => 0,
    },

    'helpvar form_start' => {
        message     => 'Start the form.',
        lastUpdated => 0,
    },

    'helpvar form_end' => {
        message     => 'End the form.',
        lastUpdated => 0,
    },

    'helpvar form_submit' => {
        message     => 'Submit the form.',
        lastUpdated => 0,
    },

    'helpvar form_title' => {
        message     => 'The title of the Photo.',
        lastUpdated => 0,
    },

    'helpvar form_synopsis' => {
        message     => 'The caption for the Photo.',
        lastUpdated => 0,
    },

    'helpvar form_photo' => {
        message     => 'The photo to upload.',
        lastUpdated => 0,
    },

    'helpvar form_keywords' => {
        message     => 'The keywords for the Photo.',
        lastUpdated => 0,
    },

    'helpvar form_location' => {
        message     => 'The location the photo was taken.',
        lastUpdated => 0,
    },

    'helpvar form_friendsOnly' => {
        message     => 'Make this photo friends only?',
        lastUpdated => 0,
    },

    'helpvar form_parentId' => {
        message     => 'Select which Album the shortcut should be made in.',
        lastUpdated => 0,
    },

    'helpvar commentLoop' => {
        message     => 'Loop over a page of comments to this photo.',
        lastUpdated => 0,
    },

    'helpvar commentLoop userId' => {
        message     => 'The userId of the user who made the comment.',
        lastUpdated => 0,
    },

    'helpvar commentLoop visitorIp' => {
        message     => 'If the user is a visitor, the IP address of the user.',
        lastUpdated => 0,
    },

    'helpvar commentLoop creationDate' => {
        message     => 'The creation date of the comment.',
        lastUpdated => 0,
    },

    'helpvar commentLoop bodyText' => {
        message     => 'The body of the comment.',
        lastUpdated => 0,
    },

    'helpvar commentLoop username' => {
        message     => 'The username of the user who made the comment.',
        lastUpdated => 0,
    },

    'helpvar commentLoop url_deleteComment' => {
        message     => 'The URL to delete this comment.',
        lastUpdated => 0,
    },

    'helpvar commentLoop_pageBar' => {
        message     => 'The bar to navigate through pages of comments.',
        lastUpdated => 0,
    },

    'helpvar url_yes' => {
        message     => 'Confirm the deleting of this Photo.',
        lastUpdated => 0,
    },

    'helpvar firstFile_url' => {
        message     => 'The URL of the first file in the album.',
        lastUpdated => 0,
    },

    'helpvar firstFile_title' => {
        message     => 'The title of the first file in the album.',
        lastUpdated => 0,
    },

    'helpvar firstFile_thumbnailUrl' => {
        message     => 'The URL of the thumbnail of the first file in the album.',
        lastUpdated => 0,
    },

    'helpvar nextFile_url' => {
        message     => 'The URL of the next file in the album. Undefined if no next file.',
        lastUpdated => 0,
    },

    'helpvar nextFile_title' => {
        message     => 'The title of the next file in the album. Undefined if no next file.',
        lastUpdated => 0,
    },

    'helpvar nextFile_thumbnailUrl' => {
        message     => 'The URL of the thumbnail of the next file in the album. Undefined if no next file.',
        lastUpdated => 0,
    },

    'helpvar previousFile_url' => {
        message     => 'The URL of the previous file in the album. Undefined if no previous file.',
        lastUpdated => 0,
    },

    'helpvar previousFile_title' => {
        message     => 'The title of the previous file in the album. Undefined if no previous file.',
        lastUpdated => 0,
    },

    'helpvar previousFile_thumbnailUrl' => {
        message     => 'The URL of the thumbnail of the previous file in the album. Undefined if no previous file.',
        lastUpdated => 0,
    },

    'helpvar lastFile_url' => {
        message     => 'The URL of the last file in the album.',
        lastUpdated => 0,
    },

    'helpvar lastFile_title' => {
        message     => 'The title of the last file in the album.',
        lastUpdated => 0,
    },

    'helpvar lastFile_thumbnailUrl' => {
        message     => 'The URL of the thumbnail of the last file in the album.',
        lastUpdated => 0,
    },

    'template view title' => {
        message     => 'Photo Details',
        lastUpdated => 0,
        context     => 'The title of the default view of Photo assets.',
    },

    'template view details' => {
        message     => 'Details',
        lastUpdated => 0,
        context     => 'List of information about the photo.',
    },

    'more details' => {
        message     => 'More Details',
        lastUpdated => 0,
        context     => 'List of more information about the photo',
    },

    'hide' => {
        message     => 'Hide',
        lastUpdated => 0,
        context     => 'To make hidden',
    },

    'template view available resolutions' => {
        message     => 'Available Resolutions',
        lastUpdated => 0,
        context     => 'List of resolutions, in pixels, that this photo is available in',
    },

    'template url_edit'  => {
        message     => 'Edit Photo',
        lastUpdated => 0,
        context     => 'The label for the Edit Photo button',
    },

    'template url_delete' => {
        message     => 'Delete Photo',
        lastUpdated => 0,
        context     => 'The label for the delete photo button',
    },

    'template url_makeShortcut' => {
        message     => 'Cross Publish',
        lastUpdated => 0,
        context     => 'The label for the button to make a shortcut in another album',
    },

    'template url_album' => {
        message     => 'Back to Album',
        lastUpdated => 0,
        context     => 'Label for the link to go back to the album',
    },

    'template fileUrl' => {
        message     => 'View Full Size Image',
        lastUpdated => 0,
        context     => 'Link to the full size image',
    },

    'template comments title' => {
        message     => 'Comments',
        lastUpdated => 0,
        context     => 'Title for the comments section of the photo page.',
    },

    'template comment creationDate' => {
        message     => 'Posted On',
        lastUpdated => 0,
        context     => 'Label for creation date of comment',
    },

    'template comment delete confirm' => {
        message     => 'Are you sure you want to delete this comment?',
        lastUpdated => 0,
        context     => 'Confirmation message for deleting a comment.',
    },

    'template url_deleteComment' => {
        message     => 'delete',
        lastUpdated => 0,
        context     => 'Label for delete link for comments.',
    },

    'template creationDate' => {
        message     => 'Uploaded on',
        lastUpdated => 0,
        context     => 'Label for creation date of photo',
    },

    'template views' => {
        message     => 'Views',
        lastUpdated => 0,
        context     => 'Label for number of views of photo',
    },

    'template keywords' => {
        message     => 'Tags',
        lastUpdated => 0,
        context     => 'Label for the keywords of the photo',
    },

    'template location' => {
        message     => 'Location',
        lastUpdated => 0,
        context     => 'Label for the location of the photo',
    },

    'template friendsOnly label' => {
        message     => 'Privacy',
        lastUpdated => 0,
        context     => 'Label for the friends only setting.',
    },

    'template friendsOnly yes' => {
        message     => 'Friends Only',
        lastUpdated => 0,
        context     => 'Label for photos that are friends only',
    },

    'template friendsOnly no' => {
        message     => 'Public',
        lastUpdated => 0,
        context     => 'Label for photos that are not friends only',
    },
    
    'template filesForUser' => {
        message     => 'more photos',
        lastUpdated => 0,
        context     => 'Label for the link to the users\' photos.',
    },    

    'template assetName' => {
        message     => 'Photo',
        lastUpdated => 0,
        context     => 'Asset name for templates.',
    },

    'editForm title label' => {
        message     => 'Title',
        lastUpdated => 0,
        context     => 'Label for "title" property',
    },

    'editForm synopsis label' => {
        message     => 'Photo Caption',
        lastUpdated => 0,
        context     => 'Label for "synopsis" property',
    },

    'editForm photo new' => {
        message     => 'New Photo',
        lastUpdated => 0,
        context     => 'Label for upload field when adding a new photo',
    },

    'editForm photo replace' => {
        message     => 'Replace Photo',
        lastUpdated => 0,
        context     => 'Label for upload field when replacing an existing photo',
    },

    'editForm keywords' => {
        message     => 'Tags',
        lastUpdated => 0,
        context     => 'Label for "keywords" field',
    },

    'editForm location' => {
        message     => 'Location',
        lastUpdated => 0,
        context     => 'Label for "location" field',
    },

    'editForm friendsOnly' => {
        message     => 'Friends Only',
        lastUpdated => 0,
        context     => 'Label for "friends only" field',
    },

    'editForm cancel' => {
        message     => 'Cancel',
        lastUpdated => 0,
        context     => 'Label for "cancel" button',
    },

    'editForm save' => {
        message     => 'Save',
        lastUpdated => 0,
        context     => 'Label for "save" button',
    },

    'help editComment title' => {
        message     => 'Photo Edit Comment Template',
        lastUpdated => 0,
        context     => 'Help page title',
    },

    'help editComment body' => {
        message     => 'These variables are available to the Photo Edit Comment page',
        lastUpdated => 0,
        context     => 'Help page body text',
    },

    'helpvar errors' => {
        message     => 'A loop of error messages to show the user',
        lastUpdated => 0,
        context     => 'Description of template variable',
    },

    'helpvar error' => {
        message     => 'The i18n error message',
        lastUpdated => 0,
        context     => 'Description of template variable',
    },

    'template error happened' => {
        message     => q{An error occurred while processing your request.},
        lastUpdated => 0,
        context     => "Text shown when friendly error messages are being displayed",
    },

    'commentForm error no commentId' => {
        message     => q{No comment ID was given. This indicates a problem with the template. Please notify an administrator.},
        lastUpdated => 0,
        context     => q{Error message when no comment ID was given. This should never happen unless the template is made wrong.},
    },

    'commentForm error no bodyText' => {
        message     => q{No text was entered. Please enter some text to create a comment.},
        lastUpdated => 0,
        context     => q{Error message for Photo comments},
    },

    'helpvar keywords' => {
        message     => q{A loop over the keywords associated with this photo},
        lastUpdated => 0,
        context     => q{Description of template loop},
    },

    'helpvar keyword' => {
        message     => q{The keyword},
        lastUpdated => 0,
        context     => q{Description of template variable},
    },

    'helpvar url_searchKeyword' => {
        message     => q{A URL to the Gallery search page for this keyword},
        lastUpdated => 0,
        context     => q{Description of template variable},
    },

    'helpvar url_searchKeywordUser' => {
        message     => q{A URL to the Gallery search page for this keyword. Limits the search to Photos by this user.},
        lastUpdated => 0,
        context     => q{Description of template variable},
    },

    'template makeShortcut title' => {
        message     => q{Cross Publish},
        lastUpdated => 0,
        context     => q{Title for the make shortcut page},
    },

    'template makeShortcut file' => {
        message     => q{File},
        lastUpdated => 0,
        context     => q{Label for the file we're making a shortcut of},
    },

    'template makeShortcut album' => {
        message     => q{Album},
        lastUpdated => 0,
        context     => q{Label for the album in which to make the shortcut},
    },

    'template delete message' => {
        message     => q{Are you sure you wish to delete this?},
        lastUpdated => 0,
        context     => q{The message for the delete page},
    },

    'template delete albums' => {
        message     => q{Photo is currently in these albums:},
        lastUpdated => 0,
        context     => q{Label for the albums the photo will be removed from.},
    },

    'helpvar synopsis_textonly' => {
        message     => q{The "synopsis" field with all HTML removed},
        lastUpdated => 0,
        context     => q{Description of template variable},
    },

    'helpvar url_album' => {
        message     => q{The URL of the Album containing this file},
        lastUpdated => 0,
        context     => q{Description of template variable},
    },

    'helpvar url_thumbnails' => {
        message     => q{The URL to the Thumbnails view of the Album containing this file},
        lastUpdated => 0,
        context     => q{Description of template variable},
    },

    'helpvar url_slideshow' => {
        message     => q{The URL to the Slideshow view of the Album containing this file},
        lastUpdated => 0,
        context     => q{Description of template variable},
    },

    'helpvar gallery_title' => {
        message     => q{The title of the Gallery containing this File},
        lastUpdated => 0,
        context     => q{Description of template variable},
    },

    'helpvar gallery_menuTitle' => {
        message     => q{The menu title of the Gallery containing this File},
        lastUpdated => 0,
        context     => q{Description of template variable},
    },

    'helpvar gallery_url' => {
        message     => q{The URL of the Gallery containing this File},
        lastUpdated => 0,
        context     => q{Description of template variable},
    },

    'helpvar album_title' => {
        message     => q{The title of the album containing this File},
        lastUpdated => 0,
        context     => q{Description of template variable},
    },

    'helpvar album_menuTitle' => {
        message     => q{The menu title of the album containing this File},
        lastUpdated => 0,
        context     => q{Description of template variable},
    },

    'helpvar album_url' => {
        message     => q{The URL of the album containing this File},
        lastUpdated => 0,
        context     => q{Description of template variable},
    },

    'helpvar album_thumbnailUrl' => {
        message     => q{The URL for the thumbnail of the album containing this File},
        lastUpdated => 0,
        context     => q{Description of template variable},
    },

    'helpvar resolutions_loop resolution' => {
        message     => q{The resolution of the photo.},
        lastUpdated => 0,
        context     => q{Description of template variable},
    },

    'helpvar resolutions_' => {
        message     => q{A URL direct to a known resolution. "800" resolution would be "resolutions_800".},
        lastUpdated => 0,
        context     => q{Description of template variable},
    },

    'helpvar isPending' => {
        message     => q{A flag to set if the Photo is not yet approved. Users who can edit the photo are allowed to see them before they are approved.},
        lastUpdated => 0,
        context     => q{Description of template variable},
    },

    'error no space' => {
        message     => q{You do not have enough disk space to upload this file.},
        lastUpdated => 0,
        context     => q{Error when user is out of disk space.},
    },
    
    'error no image' => {
        message     => q{You need to select an image to upload.},
        lastUpdated => 0,
        context     => q{Error when user tries to add photo without selecting image.},
    },    

    'template comment add title' => {
        message     => q{Add comment},
        lastUpdated => 0,
        context     => q{Title for the edit comment screen.},
    },

    'template comment edit title' => {
        message     => q{Edit comment.},
        lastUpdated => 0,
        context     => q{Title for the edit comment screen.},
    },

    'template comment edit comment' => {
        message     => q{Edit Comment},
        lastUpdated => 0,
        context     => q{Title for the edit comment screen.},
    },

    'form comment save comment' => {
        message     => q{Save Comment.},
        lastUpdated => 0,
        context     => q{Title for the edit comment screen.},
    },

};

1;
