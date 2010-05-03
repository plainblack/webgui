package WebGUI::FormBuilder::Tabset;

use Moose;
use MooseX::Storage;
use WebGUI::FormBuilder::Tab;

has 'name' => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);

has 'tabs' => (
    is => 'rw',
    isa => 'ArrayRef[WebGUI::FormBuilder::Tab]',
    default => sub { [] },
);

has 'session' => ( 
    is => 'ro', 
    isa => 'WebGUI::Session', 
    required => 1, 
    weak_ref => 1,
    traits => [ 'DoNotSerialize' ],
);

with Storage( format => 'JSON' );
with 'WebGUI::FormBuilder::Role::HasObjects';

#----------------------------------------------------------------------------

=head2 new ( session, properties )

Create a new Tabset object. C<properties> is a list of name => value pairs

=over 4

=item name

The name of the tabset. Required.

=back

=cut

sub BUILDARGS {
    my ( $class, $session, %properties ) = @_;
    $properties{ session    } = $session;
    return \%properties;
}

#----------------------------------------------------------------------------

sub addTab {
    my ( $self, $tab ) = @_;
    push @{$self->tabs}, $tab;
    $self->addObject( $tab );
    return $tab;
}

#----------------------------------------------------------------------------

sub toHtml {
    my ( $self ) = @_;
    my ( $style, $url ) = $self->session->quick(qw( style url ));

    $style->setLink( $url->extras("yui/build/tabview/assets/skins/sam/tabview.css"), { rel => "stylesheet", type => "text/css" } );
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

1;
