package WebGUI::FormBuilder::Tabset;

use Moose;

has 'tabs' => (
    is => 'rw',
    isa => 'ArrayRef[WebGUI::FormBuilder::Tab]',
);

has 'session' => ( 
    is => 'ro', 
    isa => 'WebGUI::Session', 
    required => 1, 
    weak_ref => 1,
    traits => [ 'DoNotSerialize' ],
);

with Storage( format => 'JSON' );


sub toHtml {
    # Render the entire tabset

}

1;
