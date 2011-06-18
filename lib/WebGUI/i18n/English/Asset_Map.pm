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

    'canAddPoint' => {
        message     => "A boolean which is true if the current user can add a new point to the map",
        lastUpdated => 0,
        context     => "template variable help",
    },

    'canEdit' => {
        message     => "A boolean which is true if the current user can edit this Map asset",
        lastUpdated => 0,
        context     => "template variable help",
    },

    'map asset template variables' => {
        message     => "Map Asset Template Variables",
        lastUpdated => 0,
        context     => "template variable help",
    },

    'view template' => {
        message     => "Map Asset View Template",
        lastUpdated => 0,
        context     => "template variable help",
    },

    'groupIdAddPoint' => {
        message     => "The GUID of the group that can add points to the Map",
        lastUpdated => 0,
        context     => "template variable help",
    },

    'mapApiKey' => {
        message     => "The Google Maps API key",
        lastUpdated => 0,
        context     => "template variable help",
    },

    'mapHeight' => {
        message     => "The height of the map, in pixels",
        lastUpdated => 0,
        context     => "template variable help",
    },

    'mapWidth' => {
        message     => "The width of the map, in pixels",
        lastUpdated => 0,
        context     => "template variable help",
    },

    'startLatitude' => {
        message     => "The starting latitude of the map, for the center",
        lastUpdated => 0,
        context     => "template variable help",
    },

    'startLongitude' => {
        message     => "The starting longitude of the map, for the center",
        lastUpdated => 0,
        context     => "template variable help",
    },

    'startZoom' => {
        message     => "The starting zoom level of the map",
        lastUpdated => 0,
        context     => "template variable help",
    },

    'templateIdEditPoint' => {
        message     => "The GUID of the template for adding or editing a point.",
        lastUpdated => 1304717948,
        context     => "template variable help",
    },

    'templateIdView' => {
        message     => "The GUID of the template for viewing the map.",
        lastUpdated => 0,
        context     => "template variable help",
    },

    'templateIdViewPoint' => {
        message     => "The GUID of the template for viewing a point of the map.",
        lastUpdated => 0,
        context     => "template variable help",
    },

    'workflowIdPoint' => {
        message     => "The GUID of the workflow for committing a Map Point.",
        lastUpdated => 0,
        context     => "template variable help",
    },

    'mapPoints' => {
        message     => "A loop of map points.  See the MapPoint template variables for a list of available ones.",
        lastUpdated => 0,
        context     => "template variable help",
    },

    'mapPoints' => {
        message     => "A loop of map points.  See the MapPoint template variables for a list of available ones.",
        lastUpdated => 0,
        context     => "template variable help",
    },

    'button_addPoint' => {
        message     => "A templated button with internationalized label to add a button.",
        lastUpdated => 0,
        context     => "template variable help",
    },

    'button_setCenter' => {
        message     => "A templated button with internationalized label to set the center of the map back to the default.",
        lastUpdated => 0,
        context     => "template variable help",
    },

    'selectPoint' => {
        message     => "A templated dropdown to center the map on a point, and to display it's information.",
        lastUpdated => 0,
        context     => "template variable help",
    },

};

1;
#vim:ft=perl
