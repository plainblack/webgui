package WebGUI::ICal;

use WebGUI;
use parent qw/Data::ICal/;

sub product_id {
    return 'WebGUI '. $WebGUI::VERSION . '-' . $WebGUI::STATUS;
}

1;
