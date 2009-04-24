package WebGUI::i18n::English::Workflow_Activity_ExpirePurchasedThingyRecords;

use strict; 

our $I18N = { 
    'topicName' => {
        message     => "Expire Purchased Thingy Records",
        lastUpdated => 0,
    },
    'default notification' => {
        message     => q{Your subscription is about to expire!},
        lastUpdated => 0,
        context     => "The default notification message when a ThingyRecord is about to expire.",
    },
    'default notification subject' => {
        message     => q{Important notice about your subscription},
        lastUpdated => 0,
        context     => "The default notification message subject",
    },
    'notificationOffset label' => {
        message     => q{Notification Offset},
        lastUpdated => 0,
        context     => "Label for workflow activity property",
    },
    'notificationOffset description' => {
        message     => q{The amount of time before the ThingyRecord expires when the notification is sent.},
        lastUpdated => 0,
        context     => "Description of workflow activity property",
    },
    'notificationMessage label' => {
        message     => q{Notification Message},
        lastUpdated => 0,
        context     => "Label for workflow activity property",
    },
    'notificationMessage description' => {
        message     => q{The message to send for the notification},
        lastUpdated => 0,
        context     => "Description of workflow activity property",
    },
    'notificationSubject label' => {
        message     => q{Notification Message Subject},
        lastUpdated => 0,
        context     => "Label for workflow activity property",
    },
    'notificationSubject description' => {
        message     => q{The subject of the message to send},
        lastUpdated => 0,
        context     => "Description of workflow activity property",
    },
};

1;
#vim:ft=perl
