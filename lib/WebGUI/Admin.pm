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
        $var->{tagName}    = $tag->get("name");
        $var->{publishUrl} = "";                  #TODO
        $var->{leaveUrl}   = "";                  #TODO
    }

    $style->setScript($url->extras('yui/build/utilities/utilities.js'), {type=>'text/javascript'});
    $style->setScript($url->extras('accordion/accordion.js'), {type=>'text/javascript'});
    $style->setLink($url->extras('macro/AdminBar/slidePanel.css'), {type=>'text/css', rel=>'stylesheet'});

    # Use the template in our __DATA__ block
    my $tdata   = do { local $/ = undef; <WebGUI::Admin::DATA> };
    my $tmpl    = WebGUI::Asset::Template::HTMLTemplate->new( $session );

    # Use the blank style
    my $output = $style->process( $tmpl->process( $tdata, $var ), "PBtmplBlankStyle000001" );

    return $output;
} ## end sub www_view

1;

__DATA__
<div id="wrapper" class="yui-skin-sam">

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

<p>This is where cool stuff goes</p>

<!-- Put this in style where belongs -->
<script type="text/javascript">
    YAHOO.util.Event.onDOMReady(function () { document.body.style.marginLeft = "160px"; });
</script>

</div>
