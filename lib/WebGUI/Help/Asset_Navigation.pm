package WebGUI::Help::Asset_Navigation;
use strict

our $HELP = {
    'navigation template' => {
        title => '1096',
        body  => '1097',
        isa   => [
            {   namespace => "Asset_Navigation",
                tag       => "navigation asset template variables"
            },
        ],
        variables => [
            { 'name' => 'currentPage.menuTitle' },
            { 'name' => 'currentPage.assetId' },
            { 'name' => 'currentPage.parentId' },
            { 'name' => 'currentPage.ownerUserId' },
            { 'name' => 'currentPage.synopsis' },
            { 'name' => 'currentPage.newWindow' },
            { 'name' => 'currentPage.menuTitle' },
            { 'name' => 'currentPage.title' },
            { 'name' => 'currentPage.isHome' },
            { 'name' => 'currentPage.url' },
            { 'name' => 'currentPage.rank' },
            { 'name' => 'currentPage.hasChild' },
            { 'name' => 'currentPage.hasSibling' },
            { 'name' => 'currentPage.hasViewableSiblings' },
            { 'name' => 'currentPage.hasViewableChildren' },
            {   'name'      => 'page_loop',
                'variables' => [
                    { 'name' => 'page.assetId' },
                    { 'name' => 'page.parentId' },
                    { 'name' => 'page.ownerUserId' },
                    { 'name' => 'page.synopsis' },
                    { 'name' => 'page.newWindow' },
                    { 'name' => 'page.menuTitle' },
                    { 'name' => 'page.title' },
                    { 'name' => 'page.rank' },
                    { 'name' => 'page.absDepth' },
                    { 'name' => 'page.relDepth' },
                    { 'name' => 'page.isSystem' },
                    { 'name' => 'page.isHidden' },
                    { 'name' => 'page.isContainer' },
                    { 'name' => 'page.isUtility' },
                    { 'name' => 'page.isViewable' },
                    { 'name' => 'page.url' },
                    { 'name' => 'page.indent' },
                    {   'name'      => 'page.indent_loop',
                        'variables' => [ { 'name' => 'indent' } ]
                    },
                    { 'name' => 'page.isBranchRoot' },
                    { 'name' => 'page.isTopOfBranch' },
                    { 'name' => 'page.isChild' },
                    { 'name' => 'page.isParent' },
                    { 'name' => 'page.isCurrent' },
                    { 'name' => 'page.isDescendent' },
                    { 'name' => 'page.isAncestor' },
                    { 'name' => 'page.inBranchRoot' },
                    { 'name' => 'page.isSibling' },
                    { 'name' => 'page.inBranch' },
                    { 'name' => 'page.hasChild' },
                    { 'name' => 'page.hasViewableChildren' },
                    { 'name' => 'page.depthIsN' },
                    { 'name' => 'page.relativeDepthIsN' },
                    { 'name' => 'page.depthDiff' },
                    { 'name' => 'page.depthDiffIsN' },
                    { 'name' => 'page.depthDiff_loop' },
                    { 'name' => 'page.isRankedFirst' },
                    { 'name' => 'page.isRankedLast' },
                    { 'name' => 'page.parent.menuTitle' },
                    { 'name' => 'page.parent.title' },
                    { 'name' => 'page.parent.url' },
                    { 'name' => 'page.parent.assetId' },
                    { 'name' => 'page.parent.parentId' },
                    { 'name' => 'page.parent.ownerUserId' },
                    { 'name' => 'page.parent.synopsis' },
                    { 'name' => 'page.parent.newWindow' },
                    { 'name' => 'page.parent.rank' },
                ]
            }
        ],
        related => []
    },

    'navigation asset template variables' => {
        private => 1,
        title   => 'navigation asset template variables title',
        body    => 'navigation asset template variables body',
        isa     => [
            {   namespace => "Asset_Wobject",
                tag       => "wobject template variables"
            },
        ],
        fields    => [],
        variables => [
            { 'name' => 'templateId' },
            { 'name' => 'mimeType variable' },
            { 'name' => 'assetsToInclude' },
            { 'name' => 'startType' },
            { 'name' => 'startPoint' },
            { 'name' => 'ancestorEndPoint' },
            { 'name' => 'descendantEndPoint' },
            { 'name' => 'showSystemPages' },
            { 'name' => 'showHiddenPages' },
            { 'name' => 'showUnprivilegedPages' },
            { 'name' => 'reversePageLoop' },
        ],
        related => []
    },

};

1;
