package WebGUI::Shop::PayDriver::Cash;

use strict;

use WebGUI::Shop::PayDriver;
use WebGUI::Exception;

use base qw/WebGUI::Shop::PayDriver/;

#-------------------------------------------------------------------

sub definition {
    my $class       = shift;
    my $session     = shift;
    my $definition  = shift;

    my $i18n = WebGUI::International->new($session, 'PayDriver_Cash');

    tie my %fields, 'Tie::IxHash';
    %fields = (
        sendReceipt     => {
            fieldType       => 'yesNo',
            label           => $i18n->echo('sendReceipt'),
            hoverHelp       => $i18n->echo('sendReceipt help'),
            defaultValue    => 0,
        },
    );

    push @{ $definition }, {
        name    => $i18n->echo('Cash'),
        fields  => \%fields,
    };

    return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

sub getButton {

}

#-------------------------------------------------------------------

sub www_collectPaymentInfo {

}

#-------------------------------------------------------------------

sub www_displayStatus {

}

1;

