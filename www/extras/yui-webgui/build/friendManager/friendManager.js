/*** The WebGUI Asset History Viewer 
 * Requires: YAHOO, Dom, Event
 * With all due credit to Doug Bell, who wrote the AssetManager.  FriendManager
 * is a blatant copy/paste/modify of it.
 */

//Container for functions used by many datatables.
if ( typeof WebGUI == "undefined" ) {
    WebGUI  = {};
}
if ( typeof WebGUI.FriendManager == "undefined" ) {
    WebGUI.FriendManager = {};
}

/*---------------------------------------------------------------------------
    WebGUI.FriendManager.initManager ( )
    Initialize the i18n interface
WebGUI.FriendManager.initManager = function (o) {
    WebGUI.FriendManager.i18n
    = new WebGUI.i18n( { 
            namespaces  : {
                'WebGUI' : [
                    "50",
                ],
                'Account_Friends' : [
                    "title",
                ]
            },
            onpreload   : {
                fn       : WebGUI.FriendManager.init
            }
        } );
};
*/

/*---------------------------------------------------------------------------
    Initialize objects that are shared across many datatables.
*/
WebGUI.FriendManager.responseSchema
    = {
        resultsList: 'records',
        fields: [
            { key: 'userId',      parser: 'string' },
            { key: 'username',    parser: 'string' },
            { key: 'friends',     parser: 'number' },
        ],
        metaFields: {
            totalRecords: "recordsReturned" // Access to value in the server response
        }
    };

WebGUI.FriendManager.formatUsername = function ( el, oRecord, oColumn, oData ) {
//    var link  = document.createElement('a');
//    var myId  = YAHOO.util.Dom.generateId();
//    elCell.innerHTML = '<span id="'+myId+'" class="yui-button"><span class="first-child"><button type="link">edit</button></span></span>';
//    var editButton = new YAHOO.widget.Button( myId,
//        {
//            type : "link",
//            href : "?op=account;module=friendManager;do=editFriends;uid="+oRecord.getData('userId'),
//            label : "EDIT",
//        }
//    );
    var userId = oRecord.getData('userId');
    el.innerHTML  = '<a href="?op=account;module=friendManager;do=editFriends;userId=' + userId + '">edit</a> ';
    el.innerHTML += '<a href="?op=account;module=inbox;uid=' + userId + '">' + oData + '</a>';
}

WebGUI.FriendManager.ColumnDefs = [ // sortable:true enables sorting
    //{key:"username",    label:WebGUI.FriendManager.i18n.get('WebGUI', '50' ),             sortable: true},
    //{key:"friends",     label:WebGUI.FriendManager.i18n.get('Account_Friends', 'title' ), sortable: true},
    {key:"username",    label:"username", sortable: true, formatter: WebGUI.FriendManager.formatUsername },
    {key:"friends",     label:"friends",  sortable: true},
    {key:"userId",      label:"userId",   sortable: true},
];

//Per object code

WebGUI.FriendManager.MakeTable = function (groupId, containerId) {
    var that = this;

    // Initialize the data table
    var myPaginator = new YAHOO.widget.Paginator({
        containers            : ['pagination'],
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

