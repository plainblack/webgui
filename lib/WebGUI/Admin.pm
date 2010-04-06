package WebGUI::Admin;

# The new WebGUI Admin console

use Moose;
use namespace::autoclean;

has 'session' => (
    is          => 'ro',
    isa         => 'WebGUI::Session',
    required    => 1,
);

sub BUILDARGS {
    my ( $class, $session, @args ) = @_;
    return { session => $session, @args };
}

#----------------------------------------------------------------------

sub getAdminPluginTemplateVars {
    my $self    = shift;
    my $session = $self->session;
    my ( $user, $url, $setting ) = $session->quick(qw(user url setting));
    my $functions = $session->config->get("adminConsole");
    my %processed;  # title => attributes

    # process the raw information from the config file
    foreach my $funcId ( keys %{$functions} ) {
        my $funcDef = $functions->{$funcId};
        my $var     = {};

        # If we have a class name, we've got a new WebGUI::Admin::Plugin
        if ( $funcDef->{className} ) {
            my $plugin = $funcDef->{className}->new( $session, $funcId, $funcDef );
            next unless $plugin->canUse;
            $var = {
                title           => $plugin->getTitle,
                icon            => $plugin->getIcon,
                'icon.small'    => $plugin->getIconSmall,
                url             => $plugin->getUrl,
            };

            # build the list of processed items
            $processed{$plugin->getTitle} = $var;
        }
        # Don't know what we have (old admin console functions)
        else {
            # make title
            my $title = $funcDef->{title};
            WebGUI::Macro::process( $session, \$title );

            # determine if the user can use this thing
            my $canUse = 0;
            if ( defined $funcDef->{group} ) {
                $canUse = $user->isInGroup( $funcDef->{group} );
            }
            elsif ( defined $funcDef->{groupSetting} ) {
                $canUse = $user->isInGroup( $setting->get( $funcDef->{groupSetting} ) );
            }
            if ( $funcDef->{uiLevel} > $user->profileField("uiLevel") ) {
                $canUse = 0;
            }
            next unless $canUse;

            # build the attributes
            $var = {
                title        => $title,
                icon         => $url->extras( "/adminConsole/" . $funcDef->{icon} ),
                'icon.small' => $url->extras( "adminConsole/small/" . $funcDef->{icon} ),
                url          => $funcDef->{url},
            };

            # build the list of processed items
            $processed{$title} = $var;

        } ## end else [ if ( $funcDef->{className...})]

    } ## end foreach my $funcId ( keys %...)

    #sort the functions alphabetically
    return [ map { $processed{$_} } sort keys %processed ];
} ## end sub getAdminFunctionTemplateVars

#----------------------------------------------------------------------

=head2 getClipboardTemplateVars

=cut

sub getClipboardTemplateVars {
    my ( $self ) = @_;
    my $session = $self->session;
    my $vars    = [];
    my $clipboardItems = $session->asset->getAssetsInClipboard(1);

}

#----------------------------------------------------------------------

=head2 getNewContentTemplateVars 

=cut

sub getNewContentTemplateVars {
    my ( $self ) = @_;
    my $session = $self->session;
    my ( $user ) = $session->quick(qw( user ));
    my $vars    = [];
}

#----------------------------------------------------------------------

=head2 getVersionTagTemplateVars

=cut

sub getVersionTagTemplateVars {
    my ( $self ) = @_;
    my $session = $self->session;
    my ( $user ) = $session->quick(qw( user ));
    my $vars    = [];

    my $working = WebGUI::VersionTag->getWorking( $session, "nocreate" );
    my $tags = WebGUI::VersionTag->getOpenTags($session);
    if ( @$tags ) {
        for my $tag ( @$tags ) {
            next unless $user->isInGroup( $tag->get("groupToUse") );
            push @$vars, {
                name        => $tag->get("name"),
                isWorking   => ( $working && $working->getId eq $tag->getId ) ? 1 : 0,
                joinUrl     => $tag->getJoinUrl,
                editUrl     => $tag->getEditUrl,
            };
        }
    }

    return $vars;
}

#----------------------------------------------------------------------

=head2 www_view ( session )

Show the main Admin console wrapper

=cut

sub www_view {
    my ($self) = @_;
    my $session = $self->session;
    my ( $user, $url, $style ) = $session->quick(qw{ user url style });

    my $var;
    $var->{backToSiteUrl} = $url->page;

    # Add vars for AdminBar
    $var->{adminPlugins} = $self->getAdminPluginTemplateVars;
    $var->{versionTags} = $self->getVersionTagTemplateVars;
    #$var->{clipboardAssets} = $self->getClipboardTemplateVars;
    $var->{newContentTabs} = $self->getNewContentTemplateVars;

    # Add vars for current user
    $var->{username}   = $user->username;
    $var->{profileUrl} = $user->getProfileUrl;
    $var->{logoutUrl}  = $url->page("op=auth;method=logout");

    # Add vars for current version tag
    if ( my $tag = WebGUI::VersionTag->getWorking( $session, "nocreate" ) ) {
        $var->{tagName}         = $tag->get("name");
        $var->{tagEditUrl}      = $tag->getEditUrl;
        $var->{tagPublishUrl}   = "";                  #TODO
        $var->{tagLeaveUrl}     = "";                  #TODO
    }

    $var->{viewUrl} = $url->page;

    $style->setScript($url->extras('yui/build/yahoo-dom-event/yahoo-dom-event.js'), {type=>'text/javascript'});
    $style->setScript($url->extras('yui/build/utilities/utilities.js'), {type=>'text/javascript'});
    $style->setScript($url->extras('accordion/accordion.js'), {type=>'text/javascript'});
    $style->setScript($url->extras('admin/admin.js'), {type=>'text/javascript'});
    $style->setScript($url->extras('yui/build/element/element-min.js'), {type=>"text/javascript"});
    $style->setScript($url->extras('yui/build/tabview/tabview-min.js'), {type=>"text/javascript"});
    $style->setScript($url->extras('yui/build/container/container_core-min.js'), {type=>"text/javascript"});
    $style->setScript($url->extras('yui/build/menu/menu-min.js'), {type=>"text/javascript"});
    $style->setScript($url->extras('yui/build/button/button-min.js'), {type=>"text/javascript"});
    $style->setLink( $url->extras('yui/build/button/assets/skins/sam/button.css'), {type=>"text/css",rel=>"stylesheet"});
    $style->setLink( $url->extras('yui/build/menu/assets/skins/sam/menu.css'), {type=>"text/css",rel=>"stylesheet"});
    $style->setLink( $url->extras('yui/build/tabview/assets/skins/sam/tabview.css'), {type=>"text/css",rel=>"stylesheet"});
    $style->setLink($url->extras('macro/AdminBar/slidePanel.css'), {type=>'text/css', rel=>'stylesheet'});
    $style->setLink( $url->extras('admin/admin.css'), { type=>'text/css', rel=>'stylesheet'} );

    # Use the template in our __DATA__ block
    my $tdata   = do { local $/ = undef; <WebGUI::Admin::DATA> };
    my $tmpl    = WebGUI::Asset::Template::HTMLTemplate->new( $session );

    # Use the blank style
    my $output = $style->process( $tmpl->process( $tdata, $var ), "PBtmplBlankStyle000001" );

    return $output;
} ## end sub www_view

1;

__DATA__
<dl class="accordion-menu">
    <dt class="a-m-t">^International("admin console","AdminConsole");</dt>
    <dd class="a-m-d"><div class="bd">
        <TMPL_LOOP adminPlugins>
        <a class="link" href="<tmpl_var url>">
            <img src="<tmpl_var icon.small>" style="border: 0px; vertical-align: middle;" alt="icon" />
            <tmpl_var title>
        </a>
        </TMPL_LOOP>
    </div></dd>
</dl>

<div id="wrapper" class="yui-skin-sam">

    <div id="versionTag" <TMPL_UNLESS tagName>style="display: none"</TMPL_UNLESS> >
        <div style="float: right">Publish | Leave</div>
        <a href="<tmpl_var tagEditUrl>" id="tagEditLink" target="view">
            <img src="^Extras(icon/tag_blue.png);" class="icon"/>
            <tmpl_var tagName>
        </a>
    </div>
    <div id="user">
        <div style="float: right">Back to Site | Log Out</div>
        <a href="<tmpl_var userEditUrl>" target="view">
            <img src="^Extras(icon/user.png);" class="icon" />
            <tmpl_var userName>
        </a>
    </div>

    <div id="tabs" class="yui-navset">
        <ul class="yui-nav">
            <li class="selected"><a href="#tab1"><em>View</em></a></li>
            <li><a href="#tab2"><em>Tree</em></a></li>
        </ul>
        <div id="locationBar"></div>
        <div class="yui-content">
            <div id="viewTab"><iframe src="<tmpl_var viewUrl>" name="view" style="width: 100%; height: 80%"></iframe></div>
            <div id="treeTab"><p>Tab Two Content</p></div>
        </div>
    </div>


</div>

<script type="text/javascript">
YAHOO.util.Event.onDOMReady( function() { 
    var myTabs = new YAHOO.widget.TabView("tabs");
    var bar = new WebGUI.Admin.LocationBar("locationBar");
} );
</script>
