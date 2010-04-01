package WebGUI::Admin;

# The new WebGUI Admin console

use Moose;
use namespace::autoclean;

has 'session' => (
    is          => 'ro',
    isa         => 'WebGUI::Session',
    required    => 1,
);

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
            $var = {
                title           => $plugin->getTitle,
                icon            => $plugin->getIcon,
                'icon.small'    => $plugin->getIconSmall,
                url             => $plugin->getUrl,
                canUse          => $plugin->canUse,
            };
        }
        # Don't know what we have (old admin console functions)
        else {
            # make title
            my $title = $functions->{$function}{title};
            WebGUI::Macro::process( $session, \$title );

            # determine if the user can use this thing
            my $canUse = 0;
            if ( defined $functions->{$function}{group} ) {
                $canUse = $user->isInGroup( $functions->{$function}{group} );
            }
            elsif ( defined $functions->{$function}{groupSetting} ) {
                $canUse = $user->isInGroup( $setting->get( $functions->{$function}{groupSetting} ) );
            }
            if ( $functions->{$function}{uiLevel} > $user->profileField("uiLevel") ) {
                $canUse = 0;
            }

            # build the attributes
            $var = {
                title        => $title,
                icon         => $url->extras( "/adminConsole/" . $functions->{$function}{icon} ),
                'icon.small' => $url->extras( "adminConsole/small/" . $functions->{$function}{icon} ),
                url          => $functions->{$function}{url},
                canUse       => $canUse,
            };
        } ## end else [ if ( $funcDef->{className...})]

        # build the list of processed items
        $processed{$title} = $var;

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
        next unless $user->isInGroup( $tag->get("groupToUse") );
        push @$vars, {
            name        => $tag->get("name"),
            isWorking   => ( $working && $working->getId eq $tag->getId ) ? 1 : 0,
            joinUrl     => $tag->getJoinUrl,
            editUrl     => $tag->getEditUrl,
        };
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
    my ( $user, $url ) = $session->quick(qw{ user url });

    my $var;
    $var->{backToSiteUrl} = $url->page;

    # Add vars for AdminBar
    $var->{adminPlugins} = $self->getAdminPluginTemplateVars;
    $var->{versionTags} = $self->getVersionTagTemplateVars;
    $var->{clipboardAssets} = $self->getClipboardTemplateVars;
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

    # Use the template in our __DATA__ block
    # Use the blank style

    return $output;
} ## end sub www_view

1;
