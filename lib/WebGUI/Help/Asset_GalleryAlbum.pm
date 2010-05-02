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
                name        => 'isPending',
                description => 'helpvar isPending',
            },
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
                name        => 'nextAlbum_url',
                description => 'helpvar nextAlbum_url',
            },
            {
                name        => 'nextAlbum_title',
                description => 'helpvar nextAlbum_title',
            },
            {
                name        => 'nextAlbum_thumbnailUrl',
                description => 'helpvar nextAlbum_thumbnailUrl',
            },
            {
                name        => 'previousAlbum_url',
                description => 'helpvar previousAlbum_url',
            },
            {
                name        => 'previousAlbum_title',
                description => 'helpvar previousAlbum_title',
            },
            {
                name        => 'previousAlbum_thumbnailUrl',
                description => 'helpvar previousAlbum_thumbnailUrl',
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
            {
                name        => 'gallery_title',
                description => 'helpvar gallery_title',
            },
            {
                name        => 'gallery_menuTitle',
                description => 'helpvar gallery_menuTitle',
            },
            {
                name        => 'gallery_url',
                description => 'helpvar gallery_url',
            },
            {
                name        => 'gallery_displayTitle',
                description => 'helpvar gallery_displayTitle',
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
        variables   => [ ],
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
        variables   => [ ],
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
                name        => 'form_location',
                description => 'helpvar form_location',
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
                    {
                        name        => 'form_promote',
                        description => 'helpvar form_promote',
                    },
                    {
                        name        => 'form_demote',
                        description => 'helpvar form_demote',
                    },
                    {
                        name        => 'form_rotateLeft',
                        description => 'helpvar form_rotateLeft',
                    },
                    {
                        name        => 'form_rotateRight',
                        description => 'helpvar form_rotateRight',
                    },                                                            
                    {
                        name        => 'form_synopsis',
                        description => 'helpvar form_synopsis',
                    },
                    {
                        name        => 'form_delete',
                        description => 'helpvar form_delete',
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
