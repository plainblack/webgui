package WebGUI::Help::Asset_Post;
use strict;

our $HELP = {
    'post add/edit template' => {    ##Asset/Post/www_edit
        title => 'add/edit post template title',
        body  => '',
        isa   => [
            {   tag       => 'collaboration template labels',
                namespace => 'Asset_Collaboration'
            },
            {   tag       => 'template variables',
                namespace => 'Asset_Template'
            },
            {   tag       => 'post asset variables',
                namespace => 'Asset_Post'
            },
        ],
        fields    => [],
        variables => [
            {   'required' => 1,
                'name'     => 'form.header'
            },
            { 'name' => 'isNewPost' },
            { 'name' => 'isReply' },
            { 'name' => 'reply.title' },
            { 'name' => 'reply.synopsis' },
            { 'name' => 'reply.content' },
            { 'name' => 'reply.userDefinedN' },
            { 'name' => 'subscribe.form' },
            { 'name' => 'isNewThread' },
            { 'name' => 'archive.form' },
            { 'name' => 'sticky.form' },
            { 'name' => 'lock.form' },
            { 'name' => 'isThread' },
            { 'name' => 'isEdit' },
            { 'name' => 'preview.title' },
            { 'name' => 'preview.synopsis' },
            { 'name' => 'preview.content' },
            { 'name' => 'preview.userDefinedN' },
            {   'required' => 1,
                'name'     => 'form.footer'
            },
            {   'required' => 1,
                'name'     => 'usePreview'
            },
            { 'name' => 'user.isModerator' },
            { 'name' => 'user.isVisitor' },
            { 'name' => 'visitorName.form' },
            { 'name' => 'userDefinedN.form' },
            { 'name' => 'userDefinedN.form.yesNo' },
            { 'name' => 'userDefinedN.form.textarea' },
            { 'name' => 'userDefinedN.form.htmlarea' },
            { 'name' => 'userDefinedN.form.float' },
            { 'name' => 'title.form' },
            { 'name' => 'title.form.textarea' },
            { 'name' => 'synopsis.form' },
            { 'name' => 'content.form' },
            { 'name' => 'skipNotification.form' },
            { 'name' => 'form.submit' },
            { 'name' => 'karmaScale.form' },
            { 'name' => 'karmaIsEnabled' },
            {   'name'      => 'meta_loop',
                'variables' => [ { 'name' => 'name' }, { 'name' => 'field' }, ]
            },
            { 'name' => 'meta_X_form' },
            { 'name' => 'form.preview' },
            { 'name' => 'attachment.form' },
            { 'name' => 'contentType.form' }
        ],
        related => [
            {   tag       => 'notification template',
                namespace => 'Asset_Post'
            },
        ]
    },

    'post template variables' => {    ##Asset/Post/getTemplateVars
        title => 'post template variables title',
        body  => '',
        isa   => [
            {   tag       => 'post asset variables',
                namespace => 'Asset_Post'
            },
        ],
        variables => [
            { 'name' => 'userId' },
            { 'name' => 'user.isPoster' },
            { 'name' => 'avatar.url' },
            { 'name' => 'userProfile.url' },
            { 'name' => 'dateSubmitted.human' },
            { 'name' => 'dateUpdated.human' },
            { 'name' => 'title.short' },
            {   'name'        => 'content',
                'description' => 'formatted.content'
            },
            { 'name' => 'user.canEdit' },
            { 'name' => 'delete.url' },
            { 'name' => 'edit.url' },
            { 'name' => 'status' },
            { 'name' => 'reply.url' },
            { 'name' => 'reply.withQuote.url' },
            { 'name' => 'url' },
            { 'name' => 'url.raw', description => 'help url.raw' },
            { 'name' => 'rating.value' },
            { 'name' => 'rate.url.thumbsUp' },
            { 'name' => 'rate.url.thumbsDown' },
            { 'name' => 'hasRated' },
            { 'name' => 'image.url' },
            { 'name' => 'image.thumbnail' },
            { 'name' => 'attachment.url' },
            { 'name' => 'attachment.icon' },
            { 'name' => 'attachment.name' },
            {   'name'      => 'attachment_loop',
                'variables' => [
                    { 'name' => 'url' },
                    { 'name' => 'icon' },
                    { 'name' => 'filename' },
                    { 'name' => 'thumbnail' },
                    { 'name' => 'isImage' }
                ]
            },
            {   'name'      => 'meta_loop',
                'variables' => [ { 'name' => 'name' }, { 'name' => 'value' }, ]
            },
            { 'name' => 'meta_X_value' },
        ],
        fields  => [],
        related => [
            {   tag       => 'collaboration template labels',
                namespace => 'Asset_Collaboration'
            },
        ]
    },

    'post asset variables' => {
        private => 1,
        title   => 'post asset variables title',
        body    => '',
        isa     => [ ],
        variables => [
            { 'name' => 'storageId' },
            { 'name' => 'threadId' },
            { 'name' => 'dateSubmitted' },
            { 'name' => 'dateUpdated' },
            { 'name' => 'username' },
            { 'name' => 'rating' },
            { 'name' => 'views' },
            { 'name' => 'contentType' },
            { 'name' => 'content' },
            { 'name' => 'title' },
            { 'name' => 'menuTitle' },
            { 'name' => 'synopsis' },
            { 'name' => 'extraHeadTags' },
            { 'name' => 'groupIdEdit' },
            { 'name' => 'groupIdView' },
            { 'name' => 'ownerUserId' },
            { 'name' => 'assetSize' },
            { 'name' => 'isPackage' },
            { 'name' => 'isPrototype' },
            { 'name' => 'isHidden' },
            { 'name' => 'newWindow' },
            { 'name' => 'userDefined1' },
            { 'name' => 'userDefined2' },
            { 'name' => 'userDefined3' },
            { 'name' => 'userDefined4' },
            { 'name' => 'userDefined5' }
        ],
        fields  => [],
        related => []
    },

    'notification template' => {
        title => 'notification template title',
        body  => 'notification template body',
        isa   => [
            {   namespace => "Asset_Post",
                tag       => "post template variables"
            },
            {   tag       => 'template variables',
                namespace => 'Asset_Template'
            },
        ],
        fields    => [],
        variables => [
            {   'name'        => 'url',
                'description' => 'notify url'
            },
            {   'name'        => 'relativeUrl',
                'description' => 'relativeUrl'
            },
            {   'name'        => 'notify.subscription.message',
                'description' => '875'
            },
            { 'name' => 'unsubscribeUrl', },
            { 'name' => 'unsubscribeLinkText', },
        ],
        related => [
            {   tag       => 'post add/edit template',
                namespace => 'Asset_Post'
            },
        ]
    },

};

1;
