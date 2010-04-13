package WebGUI::i18n::English::Asset_Map;

use strict; 

our $I18N = { 
    'groupIdAddPoint label' => {
        message     => 'Group to Add Points',
        lastUpdated => 0,
        context     => 'Label for asset property',
    },
    'groupIdAddPoint description' => {
        message     => 'Group that is allowed to add points to the map',
        lastUpdated => 0,
        context     => 'Description of asset property',
    },
    'mapApiKey label' => {
        message     => "Google Maps API Key",
        lastUpdated => 0,
        context     => 'Label for asset property',
    },
    'mapApiKey description' => {
        message     => 'The generated Google Maps API key for this site',
        lastUpdated => 0,
        context     => 'Description of asset property',
    },
    'mapApiKey link' => {
        message     => 'Get your Google Maps API key',
        lastUpdated => 0,
        context     => 'Label for link to create a Google Maps API key',
    },
    'mapHeight label' => {
        message     => 'Map Height',
        lastUpdated => 0,
        context     => 'Label for asset property',
    },
    'mapHeight description' => {
        message     => 'The height of the generated map. Make sure to include the units (px = pixels or % = percent).',
        lastUpdated => 0,
        context     => 'Description of asset property',
    },
    'mapWidth label' => {
        message     => 'Map Width',
        lastUpdated => 0,
        context     => 'Label for asset property',
    },
    'mapWidth description' => {
        message     => 'The width of the generated map. Make sure to include the units (px = pixels or % = percent).',
        lastUpdated => 0,
        context     => 'Description of asset property',
    },
    'startLatitude label' => {
        message     => 'Starting Latitude',
        lastUpdated => 0,
        context     => 'Label for asset property',
    },
    'startLatitude description' => {
        message     => 'Latitude of the default starting point of the map.',
        lastUpdated => 0,
        context     => 'Description of asset property',
    },
    'startLongitude label' => {
        message     => 'Starting Longitude',
        lastUpdated => 0,
        context     => 'Label for asset property',
    },
    'startLongitude description' => {
        message     => 'Longitude of the default starting point of the map',
        lastUpdated => 0,
        context     => 'Description of asset property',
    },
    'startZoom label' => {
        message     => 'Starting Zoom Level',
        lastUpdated => 0,
        context     => 'Label for asset property',
    },
    'startZoom description' => {
        message     => 'Zoom level of the default starting point of the map',
        lastUpdated => 0,
        context     => 'Description of asset property',
    },
    'templateIdEditPoint label' => {
        message     => 'Template to Edit Point',
        lastUpdated => 0,
        context     => 'Label for asset property',
    },
    'templateIdEditPoint description' => {
        message     => 'Template to edit a map point. Will appear inside of the map.',
        lastUpdated => 0,
        context     => 'Description of asset property',
    },
    'templateIdView label' => {
        message     => 'Template to View Map',
        lastUpdated => 0,
        context     => 'Label for asset property',
    },
    'templateIdView description' => {
        message     => 'Template to view the map.',
        lastUpdated => 0,
        context     => 'Description of asset property',
    },
    'templateIdViewPoint label' => {
        message     => 'Template to View Point',
        lastUpdated => 0,
        context     => 'Label for asset property',
    },
    'templateIdViewPoint description' => {
        message     => 'Template to view a map point. Will appear inside the map.',
        lastUpdated => 0,
        context     => 'Description of asset property',
    },
    'workflowIdPoint label' => {
        message     => 'Workflow to Commit Map Points',
        lastUpdated => 0,
        context     => 'Label for asset property',
    },
    'workflowIdPoint description' => {
        message     => 'The workflow that will be run when a map point is added or edited.',
        lastUpdated => 0,
        context     => 'Description of asset property',
    },
    'add point label' => {
        message     => "Add Point",
        lastUpdated => 0,
        context     => 'Label for button to add point',
    },
    'set default viewing area label' => {
        message     => 'Set Default Viewing Area',
        lastUpdated => 0,
        context     => 'Label for button to set starting latitude, longitude, and zoom level',
    },
    'error delete unauthorized' => {
        message     => 'You are not allowed to remove this point',
        lastUpdated => 0,
        context     => 'Error message for user not allowed to remove a point',
    },
    'message delete success' => {
        message     => 'Point deleted',
        lastUpdated => 0,
        context     => 'Message when point deleted successfully',
    },
    'error add unauthorized' => {
        message     => 'You are not allowed to add points',
        lastUpdated => 0,
        context     => 'Error for user not allowed to add a point',
    },
    'error edit unauthorized' => {
        message     => 'You are not allowed to edit this point',
        lastUpdated => 0,
        context     => 'Error for user not allowed to edit a point',
    },
    'error set center unauthorized' => {
        message     => 'You are not allowed to set the default viewing area',
        lastUpdated => 0,
        context     => 'Error message',
    },
    'message set center success' => {
        message     => 'Default viewing area set successfully',
        lastUpdated => 0,
        context     => "Success message",
    },
    'message set point location' => {
        message     => 'Point location saved',
        lastUpdated => 0,
        context     => 'Success message',
    },
    'select a point' => {
        message     => "Select a point",
        lastUpdated => 0,
        context     => "Choose from the list of points that existon the map",
    },
    'assetName' => {
        message     => "Map",
        lastUpdated => 0,
        context     => "Name of this asset",
    },
};

1;
#vim:ft=perl
