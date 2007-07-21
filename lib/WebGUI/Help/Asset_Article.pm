package WebGUI::Help::Asset_Article;

our $HELP = {

    'article template' => {
        title => '72',
        body  => '73',
        isa   => [
            {   namespace => "Asset_Article",
                tag       => "article asset template variables"
            },
            {   namespace => "Asset_Template",
                tag       => "template variables"
            },
            {   namespace => "Asset",
                tag       => "asset template"
            },
            {   tag       => 'pagination template variables',
                namespace => 'WebGUI'
            },
        ],
        fields    => [],
        variables => [
            { 'name' => 'new.template' },
            { 'name' => 'description' },
            { 'name' => 'description.full' },
            { 'name' => 'description.first.100words' },
            { 'name' => 'description.first.75words' },
            { 'name' => 'description.first.50words' },
            { 'name' => 'description.first.25words' },
            { 'name' => 'description.first.10words' },
            { 'name' => 'description.first.paragraph' },
            { 'name' => 'description.first.2paragraphs' },
            { 'name' => 'description.first.sentence' },
            { 'name' => 'description.first.2sentences' },
            { 'name' => 'description.first.3sentences' },
            { 'name' => 'description.first.4sentences' },
            { 'name' => 'attachment.icon' },
            { 'name' => 'attachment.name' },
            { 'name' => 'attachment.url' },
            { 'name' => 'image.thumbnail' },
            { 'name' => 'image.url' },
            {   'name'      => 'attachment_loop',
                'variables' => [
                    { 'name' => 'filename' },
                    { 'name' => 'url' },
                    { 'name' => 'thumbnailUrl' },
                    { 'name' => 'iconUrl' },
                    { 'name' => 'isImage' }
                ]
            },
        ],
        related => []
    },

    'article asset template variables' => {
        private => 1,
        title   => 'article asset template variables title',
        body    => 'article asset template variables body',
        isa     => [
            {   namespace => "Asset_Wobject",
                tag       => "wobject template variables"
            },
        ],
        fields    => [],
        variables => [
            { 'name' => 'linkTitle' },
            { 'name' => 'linkURL' },
            { 'name' => 'cacheTimeout' },
            { 'name' => 'templateId' },
            { 'name' => 'storageId' },
        ],
        related => []
    },

};

1;
