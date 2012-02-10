package WebGUI::FormBuilder::Tabset;

use Moose;
use MooseX::Storage;
use WebGUI::FormBuilder::Tab;

=head1 NAME

WebGUI::FormBuilder::Tabset - A set of tabs

=head1 SYNOPSIS

    my $tabset  = WebGUI::FormBuilder::Tabset->new( $session, name => "properties" );
    my $tab = $tabset->addTab( WebGUI::FormBuilder::Tab->new( $session, name => "normal" ) );

    # Using FormBuilder
    my $f   = WebGUI::FormBuilder->new( $session );
    $f->addTabset( name => "properties" );
    $f->addTab( name => "normal", tabset => "properties" );

=head1 DESCRIPTION

A tabset holds tabs. It does nothing else. Tabs can in turn hold fields, fieldsets,
or other tabsets.

Tabs are displayed using YUI TabView.

=head1 SEE ALSO

 WebGUI::FormBuilder
 WebGUI::FormBuilder::Tab

=head1 ATTRIBUTES

=head2 name

A name string. Required.

=cut

has 'name' => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);

=head2 tabs

The array of tabs this tabset contains.

=cut

has 'tabs' => (
    is => 'rw',
    isa => 'ArrayRef',
    default => sub { [] },
);

=head2 session

The WebGUI::Session object. Required.

=cut

has 'session' => ( 
    is => 'ro', 
    isa => 'WebGUI::Session', 
    required => 1, 
    weak_ref => 1,
    traits => [ 'DoNotSerialize' ],
);

with Storage( format => 'JSON' );

#----------------------------------------------------------------------------

=head2 new ( session, properties )

Create a new Tabset object. C<properties> is a list of name => value pairs

=cut

sub BUILDARGS {
    my ( $class, $session, %properties ) = @_;
    $properties{ session    } = $session;
    return \%properties;
}

#----------------------------------------------------------------------------

sub addTab {
    my $self = shift;
    my $tab;
    if ( scalar @_ == 1 ) {
        $tab = $_[0];
    }
    else {
        $tab = WebGUI::FormBuilder::Tab->new( $self->session, @_ );
    }
    push @{$self->tabs}, $tab;
    return $tab;
}

#----------------------------------------------------------------------------

sub toHtml {
    my ( $self ) = @_;
    my ( $style, $url ) = $self->session->quick(qw( style url ));

    $style->setCss( $url->extras("yui/build/tabview/assets/skins/sam/tabview.css"));
    $style->setScript( $url->extras("yui/build/yahoo-dom-event/yahoo-dom-event.js") );
    $style->setScript( $url->extras("yui/build/element/element-min.js") );
    $style->setScript( $url->extras("yui/build/tabview/tabview-min.js") );

    my $html    = sprintf( '<div id="%s" class="yui-navset">', $self->name )
                . '<ul class="yui-nav">'
                ;

    for ( my $i = 0; $i < @{$self->tabs}; $i++ ) {
        my $tab = $self->tabs->[$i];
        $html   .= '<li' . ( $i == 0 ? ' class="selected"' : '' ) . '>'
                . sprintf( '<a href="#tab%i"><em>%s</em></a>', $i, $tab->label )
                . '</li>';
    }

    $html       .= '</ul>'
                . '<div class="yui-content">'
                ;

    for ( my $i = 0; $i < @{$self->tabs}; $i++ ) {
        my $tab = $self->tabs->[$i];
        $html   .= sprintf '<div id="tab%i">%s</div>', $i, $tab->toHtml;
    }

    $html       .= '</div>'
                . '</div>'
                . q{<script type="text/javascript">}
                . sprintf( q'YAHOO.util.Event.onContentReady( "%s", function () {', $self->name )
                . sprintf( q'new YAHOO.widget.TabView("%s");', $self->name )
                . q' } );'
                . q{</script>}
                ;

    return $html;
}

#----------------------------------------------------------------------------

=head2 toTemplateVars ( )

Return a hashref of template vars to re-create this tabset

=cut

sub toTemplateVars {
    my ( $self ) = @_;
    my $var = {};

    $var->{ name } = $self->name;
    $var->{ tabs } = [];
    for my $tab ( @{ $self->tabs } ) {
        my $name  = $tab->name;
        my $props = $tab->toTemplateVars;
        $var->{ "tabs_${name}" } = $tab->toHtml;
        push @{$var->{tabs}}, $props;
        for my $key ( keys %{$props} ) {
            $var->{ "tabs_${name}_${key}" } = $props->{$key};
        }
    }

    return $var;
}

1;
