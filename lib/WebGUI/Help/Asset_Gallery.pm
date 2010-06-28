package WebGUI::Help::Asset_Gallery;

our $HELP = {
    'help searchForm' => {
        title       => 'help searchForm title',
        body        => 'help searchForm body',
        variables   => [
            {
                name        => 'searchForm_start',
                description => 'helpvar searchForm_start',
            },
            {
                name        => 'searchForm_end',
                description => 'helpvar searchForm_end',
            },
            {
                name        => 'searchForm_basicSearch',
                description => 'helpvar searchForm_basicSearch',
            },
            {
                name        => 'searchForm_title',
                description => 'helpvar searchForm_title',
            },
            {
                name        => 'searchForm_description',
                description => 'helpvar searchForm_description',
            },
            {
                name        => 'searchForm_keywords',
                description => 'helpvar searchForm_keywords',
            },
            {
                name        => 'searchForm_location',
                description => 'helpvar searchForm_location',
            },            
            {
                name        => 'searchForm_className',
                description => 'helpvar searchForm_className',
            },
            {
                name        => 'searchForm_creationDate_after',
                description => 'helpvar searchForm_creationDate_after',
            },
            {
                name        => 'searchForm_creationDate_before',
                description => 'helpvar searchForm_creationDate_before',
            },
            {
                name        => 'searchForm_submit',
                description => 'helpvar searchForm_submit',
            },
        ],
    },

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
                name        => 'url_addAlbum',
                description => 'helpvar url_addAlbum',
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
                name        => 'canEdit',
                description => 'helpvar canEdit',
            },
            {
                name        => 'canAddFile',
                description => 'helpvar canAddFile',
            },
        ],
    },

    'help listAlbums' => {
        title       => 'help listAlbums title',
        body        => 'help listAlbums body',
        isa         => [
            {
                tag         => 'help common',
                namespace   => 'Asset_Gallery',
            },
        ],
        variables   => [
            {
                name        => 'albums',
                description => 'helpvar albums',
            },
        ],
        related     => [
            {
                tag         => 'help common',
                namespace   => 'Asset_GalleryAlbum',
            },
        ],
    },

    'help listAlbumsRss' => {
        title       => 'help listAlbumsRss title',
        body        => 'help listAlbumsRss body',
        isa         => [
            {
                tag         => 'help common',
                namespace   => 'Asset_Gallery',
            },
        ],
        variables   => [
            {
                name        => 'albums',
                description => 'helpvar albums rss',
                variables   => [
                    {
                        name        => 'rssDate',
                        description => 'helpvar rssDate',
                    },
                ],
            },
        ],
        related     => [
            {
                tag         => 'help common',
                namespace   => 'Asset_GalleryAlbum',
            },
        ],
    },

    'help search' => {
        title       => 'help search title',
        body        => 'help search body',
        isa         => [
            {
                tag         => 'help common',
                namespace   => 'Asset_Gallery',
            },
        ],
        variables   => [
            {
                name        => 'search_results',
                description => 'helpvar search_results',
                variables   => [
                    {
                        name        => 'isAlbum',
                        description => 'helpvar isAlbum',
                    },
                ],
            },
        ],
        # All classes that can be found by a Gallery search go in here
        related     => [
            {
                tag         => 'help common',
                namespace   => 'Asset_GalleryAlbum',
            },
            {
                tag         => 'help common',
                namespace   => 'Asset_Photo',
            },
        ],
    },

    'help listFilesForUser' => {
        title       => 'help listFilesForUser title',
        body        => 'help listFilesForUser body',
        isa         => [
            {
                tag         => 'help common',
                namespace   => 'Asset_Gallery',
            },
        ],
        variables   => [
            {
                name        => 'user_albums',
                description => 'helpvar user_albums',
            },
            {
                name        => 'user_files',
                description => 'helpvar user_files',
            },
            {
                name        => 'userId',
                description => 'helpvar userId',
            },
            {
                name        => 'url_rss',
                description => 'helpvar url_rss',
            },
            {
                name        => 'username',
                description => 'helpvar username',
            },
        ],
        # All classes that can be found by a Gallery search go in here
        related     => [
            {
                tag         => 'help common',
                namespace   => 'Asset_GalleryAlbum',
            },
            {
                tag         => 'help common',
                namespace   => 'Asset_Photo',
            },
        ],
    },

    'help listFilesForUserRss' => {
        title       => 'help listFilesForUserRss title',
        body        => 'help listFilesForUserRss body',
        isa         => [
            {
                tag         => 'help listFilesForUser',
                namespace   => 'Asset_Gallery',
            },
        ],
    },

};

1;
