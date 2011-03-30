/*** The WebGUI Friend Manager
 * Requires: YAHOO, Dom, Event
 */

//Container for functions used by many datatables.
if ( typeof WebGUI == "undefined" ) {
    WebGUI  = {};
}
if ( typeof WebGUI.FriendManager == "undefined" ) {
    WebGUI.FriendManager = {};
}
if ( typeof WebGUI.FriendManager.tables == "undefined" ) {
    WebGUI.FriendManager.tables = {};
}

/*---------------------------------------------------------------------------
    WebGUI.FriendManager.initManager ( )
    Initialize the i18n interface, and then call the function to build
    the DataTables.
*/
WebGUI.FriendManager.initI18N = function (o) {
    WebGUI.FriendManager.i18n
        = new WebGUI.i18n( { 
                namespaces  : {
                    "WebGUI" : [
                        "50",
                        "89",
                    ],
                    "Account_Friends" : [
                        "title",
                    ],
                    "Account_FriendManager" : [
                        "friends count",
                    ]
                },
                onpreload   : {
                    fn       : WebGUI.FriendManager.initTables
                }
            } );
};

/*---------------------------------------------------------------------------
    Initialize objects that are shared across many datatables.
*/
WebGUI.FriendManager.responseSchema
    = {
        resultsList: 'records',
        fields: [
            { key: 'userId',       parser: 'string' },
            { key: 'username',     parser: 'string' },
            { key: 'friendsCount', parser: 'number' },
            { key: 'friends',      parser: 'string' },
            { key: 'groups',       parser: 'string' },
        ],
        metaFields: {
            totalRecords: "recordsReturned" // Access to value in the server response
        }
    };

WebGUI.FriendManager.formatUsername = function ( el, oRecord, oColumn, oData ) {
    var userId = oRecord.getData('userId');
    el.innerHTML = '<a href="?op=account;module=inbox;uid=' + userId + '">' + oData + '</a>';
}

WebGUI.FriendManager.formatGroups = function ( el, oRecord, oColumn, oData ) {
    var userId = oRecord.getData('userId');
    el.innerHTML = '';
    var groups = oData.split("\n");
    for (var idx=0; idx < groups.length; idx++) {
        var group     = groups[idx];
        var groupUri  = encodeURI(group);
        if (el.innerHTML) {
            el.innerHTML += ' ';
        }
        el.innerHTML += '<a href="?op=account;module=friendManager;do=editFriends;userId=' + userId + ';groupName='+groupUri+'">'+group+'</a>';
    }
}

//Per object code

WebGUI.FriendManager.MakeTable = function (groupId, containerId) {
    var that = this;

    if (typeof WebGUI.FriendManager.ColumnDefs == "undefined" ) {
        WebGUI.FriendManager.ColumnDefs = [ // sortable:true enables sorting
            { key:"groups",       sortable: false, formatter: WebGUI.FriendManager.formatGroups,
              label:WebGUI.FriendManager.i18n.get('WebGUI', '89' ), },
            { key:"username",     sortable: true,  formatter: WebGUI.FriendManager.formatUsername,
              label:WebGUI.FriendManager.i18n.get('WebGUI', '50' ), },
            { key:"friendsCount", sortable: true,
              label:WebGUI.FriendManager.i18n.get('Account_FriendManager', 'friends count' ), },
            { key:"friends",      sortable: false,
              label:WebGUI.FriendManager.i18n.get('Account_Friends', 'title' ), },
            { key:"userId",       label:"userId",       sortable: true},
        ];
    }

    // Initialize the data table
    var myPaginator = new YAHOO.widget.Paginator({
        containers            : [containerId+'_pagination'],
        pageLinks             : 7,
        rowsPerPage           : 15,
        template              : "<strong>{CurrentPageReport}</strong> {PreviousPageLink} {PageLinks} {NextPageLink}"
    });

    that.DataSource
        = new YAHOO.util.DataSource('?op=account;module=friendManager;do=getFriendsAsJson;groupId='+groupId+';',{connTimeout:30000} );
    that.DataSource.responseType   = YAHOO.util.DataSource.TYPE_JSON;
    that.DataSource.responseSchema = WebGUI.FriendManager.responseSchema;
    that.DataTable = new YAHOO.widget.DataTable(
                            containerId, 
                            WebGUI.FriendManager.ColumnDefs, 
                            that.DataSource, 
                            {
                                initialRequest          : '',
                                paginator               : myPaginator,
                                sortedBy                : { "key" : "username", "dir" : YAHOO.widget.DataTable.CLASS_ASC },
                            }
    );

    that.DataTable.handleDataReturnPayload = function(oRequest, oResponse, oPayload) {
        oPayload.totalRecords = oResponse.meta.totalRecords;
        return oPayload;
    }

    return that;

};

