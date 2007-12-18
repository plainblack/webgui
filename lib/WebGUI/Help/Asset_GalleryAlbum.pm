package WebGUI::Help::Asset_GalleryAlbum;

our $HELP = {

    'help common' => {
        title       => 'help common title',
        body        => 'help common body',
        isa         => [
            {
                tag         => 'help searchForm',
                namespace   => 'Asset_Gallery',
            },
        ],
        variables   => [
            {
                name        => 'canAddFile',
                description => 'helpvar canAddFile',
            },
            {
                name        => 'canEdit',
                description => 'helpvar canEdit',
            },
            {
                name        => 'url_listAlbums',
                description => 'helpvar url_listAlbums',
            },
            {
                name        => 'url_listAlbumsRss',
                description => 'helpvar url_listAlbumsRss',
            },
            {
                name        => 'url_listFilesForCurrentUser',
                description => 'helpvar url_listFilesForCurrentUser',
            },
            {
                name        => 'url_search',
                description => 'helpvar url_search',
            },
            {
                name        => 'url_addArchive',
                description => 'helpvar url_addArchive',
            },
            {
                name        => 'url_addPhoto',
                description => 'helpvar url_addPhoto',
            },
            {
                name        => 'url_addNoClass',
                description => 'helpvar url_addNoClass',
            },
            {
                name        => 'url_delete',
                description => 'helpvar url_delete',
            },
            {
                name        => 'url_edit',
                description => 'helpvar url_edit',
            },
            {
                name        => 'url_listFilesForOwner',
                description => 'helpvar url_listFilesForOwner',
            },
            {
                name        => 'url_viewRss',
                description => 'helpvar url_viewRss',
            },
            {
                name        => 'url_slideshow',
                description => 'helpvar url_slideshow',
            },
            {
                name        => 'url_thumbnails',
                description => 'helpvar url_thumbnails',
            },
            {
                name        => 'fileCount',
                description => 'helpvar fileCount',
            },
            {
                name        => 'ownerUsername',
                description => 'helpvar ownerUsername',
            },
            {
                name        => 'thumbnailUrl',
                description => 'helpvar thumbnailUrl',
            },
        ],
    },

    'help fileLoop' => {
        title       => 'help fileLoop title',
        body        => 'help fileLoop body',
        variables   => [
            {
                name        => 'file_loop',
                description => 'helpvar file_loop',
            },
        ],

        # ADD ALL GalleryAlbum FILE CLASSES HERE!!!
        related     => [
            {
                tag         => 'help common',
                namespace   => 'Asset_Photo',
            },
        ],
    },

    'help view' => {
        title       => 'help view title',
        body        => 'help view body',
        isa         => [
            { 
                tag         => 'help common',
                namespace   => 'Asset_GalleryAlbum',
            },
            {
                tag         => 'help fileLoop',
                namespace   => 'Asset_GalleryAlbum',
            },
        ],
    },
    
    'help slideshow' => {
        title       => 'help slideshow title',
        body        => 'help slideshow body',
        isa         => [
            {
                tag         => 'help common',
                namespace   => 'Asset_GalleryAlbum',
            },
            {
                tag         => 'help fileLoop',
                namespace   => 'Asset_GalleryAlbum',
            },
        ],
    },

    'help thumbnails' => {
        title       => 'help thumbnails title',
        body        => 'help thumbnails body',
        isa         => [
            {
                tag         => 'help common',
                namespace   => 'Asset_GalleryAlbum',
            },
            {
                tag         => 'help fileLoop',
                namespace   => 'Asset_GalleryAlbum',
            },
        ],

        variables => [
            {
                name        => 'file_*',
                description => 'helpvar file_*',
            },
        ],

        # PUT ALL GalleryAlbum FILE CLASSES HERE ALSO!!!
        related     => [
            {
                tag         => 'help common',
                namespace   => 'Asset_Photo',
            },
        ],
    },

    'help addArchive' => {
        title       => 'help addArchive title',
        body        => 'help addArchive body',
        isa         => [
            { 
                tag         => 'help common',
                namespace   => 'Asset_GalleryAlbum',
            },
        ],
        variables   => [
            {
                name        => 'error',
                description => 'helpvar error',
                required    => 1,
            },
            {
                name        => 'form_start',
                description => 'helpvar form_start',
                required    => 1,
            },
            {
                name        => 'form_end',
                description => 'helpvar form_end',
                required    => 1,
            },
            {
                name        => 'form_submit',
                description => 'helpvar form_submit',
            },
            {
                name        => 'form_archive',
                description => 'helpvar form_archive',
                required    => 1,
            },
            {
                name        => 'form_keywords',
                description => 'helpvar form_keywords',
            },
            {
                name        => 'form_friendsOnly',
                description => 'helpvar form_friendsOnly',
            },
        ],
    },

    'help delete' => {
        title       => 'help delete title',
        body        => 'help delete body',
        isa         => [
            { 
                tag         => 'help common',
                namespace   => 'Asset_GalleryAlbum',
            },
        ],
        variables   => [
            {
                name        => 'url_yes',
                description => 'helpvar url_yes',
            },
        ],
    },

    'help edit' => {
        title       => 'help edit title',
        body        => 'help edit body',
        isa         => [
            { 
                tag         => 'help common',
                namespace   => 'Asset_GalleryAlbum',
            },
            {
                tag         => 'help fileLoop',
                namespace   => 'Asset_GalleryAlbum',
            },
        ],
        variables   => [
            {
                name        => 'form_start',
                description => 'helpvar form_start',
                required    => 1,
            },
            {
                name        => 'form_end',
                description => 'helpvar form_end',
                required    => 1,
            },
            {
                name        => 'form_cancel',
                description => 'helpvar form_cancel',
            },
            {
                name        => 'form_submit',
                description => 'helpvar form_submit',
            },
            {
                name        => 'form_title',
                description => 'helpvar form_title',
            },
            {
                name        => 'form_description',
                description => 'helpvar form_description',
                required    => 1,
            },
            {
                name        => 'file_loop',
                description => 'helpvar file_loop edit',
                variables   => [
                    {
                        name        => 'isAlbumThumbnail',
                        description => 'helpvar isAlbumThumbnail',
                    },
                ],
            },
        ],
    },

    'help viewRss' => {
        title       => 'help viewRss title',
        body        => 'help viewRss body',
        isa         => [
            {
                tag         => 'help common',
                namespace   => 'Asset_GalleryAlbum',
            },
            {
                tag         => 'help fileLoop',
                namespace   => 'Asset_GalleryAlbum',
            },
        ],
        variables   => [
            {
                name        => 'file_loop',
                description => 'helpvar file_loop viewRss',
                variables   => [
                    {
                        name        => 'rssDate',
                        description => 'helpvar rssDate',
                    },
                ],
            },
        ],
    },

};

1;
