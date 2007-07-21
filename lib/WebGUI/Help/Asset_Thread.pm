package WebGUI::Help::Asset_Thread;

our $HELP = {
    'thread template variables' => {
        title => 'thread template title',
        body  => '',
        isa   => [
            {   tag       => 'template variables',
                namespace => 'Asset_Template'
            },
            {   tag       => 'post template variables',
                namespace => 'Asset_Post'
            },
            {   tag       => 'collaboration template labels',
                namespace => 'Asset_Collaboration'
            },
            {   tag       => 'pagination template variables',
                namespace => 'WebGUI'
            },
        ],
        fields    => [],
        variables => [
            { 'name' => 'karma.transfer.form' },
            { 'name' => 'karma' },
            { 'name' => 'karmaScale' },
            { 'name' => 'karmaRank' },
            { 'name' => 'thumbsUp.icon.url' },
            { 'name' => 'thumbsDown.icon.url' },
            { 'name' => 'user.isVisitor' },
            { 'name' => 'user.isModerator' },
            { 'name' => 'user.canPost' },
            { 'name' => 'user.canReply' },
            { 'name' => 'repliesAllowed' },
            { 'name' => 'userProfile.url' },
            { 'name' => 'layout.nested.url' },
            { 'name' => 'layout.flat.url' },
            { 'name' => 'layout.threaded.url' },
            { 'name' => 'layout.isFlat' },
            { 'name' => 'layout.isNested' },
            { 'name' => 'layout.isThreaded' },
            { 'name' => 'user.isSubscribed' },
            { 'name' => 'subscribe.url' },
            { 'name' => 'unsubscribe.url' },
            { 'name' => 'isArchived' },
            { 'name' => 'archive.url' },
            { 'name' => 'unarchive.url' },
            { 'name' => 'isSticky' },
            { 'name' => 'stick.url' },
            { 'name' => 'unstick.url' },
            { 'name' => 'isLocked' },
            { 'name' => 'lock.url' },
            { 'name' => 'unlock.url' },
            {   'name'      => 'post_loop',
                'variables' => [
                    { 'name' => 'isCurrent' },
                    { 'name' => 'isThreadRoot' },
                    { 'name' => 'depth' },
                    { 'name' => 'depthX10' },
                    {   'name'      => 'indent_loop',
                        'variables' => [ { 'name' => 'depth' } ]
                    }
                ]
            },
            { 'name' => 'add.url' },
            { 'name' => 'previous.url' },
            { 'name' => 'next.url' },
            { 'name' => 'search.url' },
            { 'name' => 'collaboration.url' },
            { 'name' => 'collaboration.title' },
            { 'name' => 'collaboration.description' }
        ],
        related => []
    },

    'thread asset template variables' => {
        private => 1,
        title   => 'thread asset template title',
        body    => '',
        isa     => [
            {   tag       => 'post asset variables',
                namespace => 'Asset_Post'
            },
        ],
        fields    => [],
        variables => [],
        related   => []
    },

};

1;
