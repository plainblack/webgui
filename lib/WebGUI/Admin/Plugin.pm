package WebGUI::Admin::Plugin;

use Moose;
use Scalar::Util qw(blessed);

has 'id' => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
);

has 'title' => (
    is      => 'rw',
    isa     => 'Str',
);

has 'icon' => (
    is      => 'rw',
    isa     => 'Str',
    default => '',      # Find a good default
);

has 'iconSmall' => (
    is      => 'rw',
    isa     => 'Str',
    default => '',      # Find a good default
);

sub BUILDARGS {
    my ( $class, $session, %args ) = @_;
    return { session => $session, %args };
}

sub canView {
    return 1;
}

sub getUrl {
    my ( $self, $method, $params ) = @_;
    $method ||= "view";
    return '?op=admin;plugin=' . $self->id . ';method=' . $method . ';' . $params;
}

1;

=head1 NAME

WebGUI::Admin::Plugin - Add items to the Admin Console

=head1 SYNOPSIS

 package My::Admin::Plugin;
 use Moose;
 use WebGUI::BestPractices;
 extends 'WebGUI::Admin::Plugin';

 sub www_view {
    my ( $self ) = @_;

    return "Hello, World\n";
 }

 # etc/site.conf
 {
    "adminConsole" : {
        myPlugin : {
            className   : "My::Admin::Plugin",
            title       : "My Plugin",
            icon        : "^Extras(icon/gear.gif);",
            iconSmall   : "^Extras(icon/gear.gif);"
        }
    }
 }

=head1 ATTRIBUTES

=head2 id

The identifier from the configuration file. Read-only.

=head2 title

The i18n title for the plugin, usually specified from the config file.

=head2 icon

The full-size icon for the plugin. Used on the plugin page.

=head2 iconSmall

A smaller icon for the plugin, used in the admin menu.

=head1 METHODS

=head2 canView ( [user] )

Returns true if the user can use this admin plugin. If no user is specified, 
defaults to the current session's user.

=head2 getUrl ( method [, params ] )

Get a URL to the admin plugin's given www_ method optionally with more URL params.


