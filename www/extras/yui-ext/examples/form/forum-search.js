/*
 * Ext JS Library 1.0.1
 * Copyright(c) 2006-2007, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://www.extjs.com/license
 */

Ext.onReady(function(){

    Ext.MessageBox.alert("Sorry", "This example is not compatible with the new site, no longer functions and is for reference only");

    var ds = new Ext.data.Store({
        proxy: new Ext.data.HttpProxy({
            url: '/forum2/topics-remote.php'
        }),
        reader: new Ext.data.JsonReader({
            root: 'topics',
            totalProperty: 'totalCount',
            id: 'post_id'
        }, [
            {name: 'title', mapping: 'topic_title'},
            {name: 'topicId', mapping: 'topic_id'},
            {name: 'author', mapping: 'author'},
            {name: 'lastPost', mapping: 'post_time', type: 'date', dateFormat: 'timestamp'},
            {name: 'excerpt', mapping: 'post_text'}
        ])
    });

    // Custom rendering Template
    var resultTpl = new Ext.Template(
        '<div class="search-item">',
            '<h3><span>{lastPost:date("M j, Y")}<br />by {author}</span>{title}</h3>',
            '{excerpt}',
        '</div>'
    );
    
    var search = new Ext.form.ComboBox({
        store: ds,
        displayField:'title',
        typeAhead: false,
        loadingText: 'Searching...',
        width: 570,
        pageSize:10,
        hideTrigger:true,
        tpl: resultTpl,
        onSelect: function(record){ // override default onSelect to do redirect
            window.location =
                String.format('/forum/viewtopic.php?t={0}#{1}', record.data.topicId, record.id);
        }
    });
    // apply it to the exsting input element
    search.applyTo('search');
});