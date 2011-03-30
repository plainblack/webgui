package WebGUI::Help::Asset_SyndicatedContent;
use strict;

our $HELP = {
    'syndicated content template' => {
        title => '72',
        body  => '',
        isa   => [
            {   namespace => 'Asset_SyndicatedContent',
                tag       => 'syndicated content asset template variables',
            },
            {   namespace => 'Asset_Template',
                tag       => 'template variables'
            },
            {   namespace => 'Asset',
                tag       => 'asset template'
            },
        ],
        variables => [
            { 'name' => 'channel_title' },
            { 'name' => 'channel_description' },
            { 'name' => 'channel_link' },
            { 'name' => 'channel_date' },
            { 'name' => 'channel_copyright' },
            { 'name' => 'channel_image_url' },
            { 'name' => 'channel_image_title' },
            { 'name' => 'channel_image_link' },
            { 'name' => 'channel_image_description' },
            { 'name' => 'channel_image_width' },
            { 'name' => 'channel_image_height' },
			{ 'name' => 'rss_url' },
			{ 'name' => 'rdf_url' },
			{ 'name' => 'atom_url' },
            {   'name'      => 'item_loop',
                'variables' => [
                    { 'name' => 'title' },
                    { 'name' => 'link' },
                    { 'name' => 'date' },
                    { 'name' => 'category' },
                    { 'name' => 'author' },
                    { 'name' => 'guid' },
                    { 'name' => 'media' },
                    { 'name' => 'description' },
                    { 'name' => 'descriptionFirst100words' },
                    { 'name' => 'descriptionFirst75words' },
                    { 'name' => 'descriptionFirst50words' },
                    { 'name' => 'descriptionFirst25words' },
                    { 'name' => 'descriptionFirst10words' },
                    { 'name' => 'descriptionFirst2paragraphs' },
                    { 'name' => 'descriptionFirstParagraph' },
                    { 'name' => 'descriptionFirst4sentences' },
                    { 'name' => 'descriptionFirst3sentences' },
                    { 'name' => 'descriptionFirst2sentences' },
                    { 'name' => 'descriptionFirstSentence' },
                ]
            }
        ],
        related => [
            {   tag       => 'wobject template',
                namespace => 'Asset_Wobject'
            }
        ],
        fields => [],
    },

    'syndicated content asset template variables' => {
        private => 1,
        title   => 'syndicated content asset template variables title',
        body    => '',
        isa     => [
            {   namespace => 'Asset_Wobject',
                tag       => 'wobject template variables'
            },
        ],
        variables => [
            { 'name' => 'cacheTimeout' },
            { 'name' => 'templateId' },
            { 'name' => 'rssUrl' },
            { 'name' => 'processMacrosInRssUrl' },
            { 'name' => 'maxHeadlines' },
            { 'name' => 'hasTerms' },
        ],
        related => [],
        fields  => [],
    },

};

1;
