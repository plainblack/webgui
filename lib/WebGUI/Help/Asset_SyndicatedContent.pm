package WebGUI::Help::Asset_SyndicatedContent;
use strict

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
            { 'name' => 'channel.title' },
            { 'name' => 'channel.description' },
            { 'name' => 'channel.link' },
            {   'name'      => 'rss.url',
                'variables' => [
                    { 'name' => 'rss.url.0.9' },
                    { 'name' => 'rss.url.0.91' },
                    { 'name' => 'rss.url.1.0' },
                    { 'name' => 'rss.url.2.0' }
                ]
            },
            {   'name'      => 'item_loop',
                'variables' => [
                    { 'name' => 'site_title' },
                    { 'name' => 'site_link' },
                    { 'name' => 'new_rss_site' },
                    { 'name' => 'title' },
                    { 'name' => 'link' },
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
            { 'name' => 'displayMode' },
            { 'name' => 'hasTerms' },
        ],
        related => [],
        fields  => [],
    },

};

1;
