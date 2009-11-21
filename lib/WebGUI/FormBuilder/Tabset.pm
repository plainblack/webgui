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

sub new {
    my ( $class, $session, %properties ) = @_;
    $properties{ session    } = $session;
    return $class->SUPER::new( %properties );
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
    my $html    = sprintf( '<div id="%s" class="yui-navset">', $self->name )
                . '<ul class="yui-nav">'
                ;
    
    for ( my $i = 0; $i < @{$self->tabs}; $i++ ) {
        my $tab = $self->tabs->[$i];
        $html   .= sprintf '<li><a href="#tab%i"><em>%s</em></a></li>', $i, $tab->label;
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
                . sprintf( q{var tabView = new YAHOO.widget.TabView('%s');}, $self->name )
                . q{</script>}
                ;

    return $html;
}

1;
