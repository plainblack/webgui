package WebGUI::i18n::English::Asset_SQLForm;

our $I18N = {
	'change field warning' => {
		message => q|Changing the following properties can result in permanent loss of data in this field:\n\n
\t - Database field type.\n
\t - Decreasing the Maximum field length.\n
\t - Switching the Sign.\n\n\n
Are you sure to continue?|, 
		lastUpdated => 0,
	},

	'ef field name' => {
		message => q|Field name (column name)|,
		lastUpdated => 0,
	},

	'ef field name description' => {
		message => q|<p>This sets the name of the column in the database
tied to this field.</p>|,
		lastUpdated => 0,
	},

	'ef display name' => {
		message => q|Display name|,
		lastUpdated => 0,
	},

	'ef display name description' => {
		message => q|<p>Use this property to set the name of this field
that is shown to users.</p>|,
		lastUpdated => 0,
	},

	'ef field type' => {
		message => q|Field type|,
		lastUpdated => 0,
	},

	'ef field type description' => {
		message => q|<p>This property defines the column type of the field
in the database as well as the type of form element that is used for input of
new records. You can only select field type combinations that are defined in the
field type manager. For more information please read the help on <b>Manage field
types</b>, which you can visit using the link in the menu on the right.</p>

<p>Please note that some other field properties like <b>Auto increment</b> and
<b>Read only</b> will force the field to be readonly and thus render the form
type of no importance. The database field type is very important, though, and
should chosen with proper care.</p>|,
		lastUpdated => 0,
	},
	
	'ef signed' => {
		message => q|Sign|,
		lastUpdated => 0,
	},
	
	'ef signed description' => {
		message => q|<p>This property determines wheter this field
interprets number as signed or unsigned. The difference lies in the boundaries
of allowed values.</p>

<p>This property is available only for numeric fieldtypes like <i>int</i>.</p>|,
		lastUpdated => 0,
	},
	
	'ef signed label' => {
		message => q|Signed|,
		lastUpdated => 0,
	},
	
	'ef unsigned label' => {
		message => q|Unsigned|,
		lastUpdated => 0,
	},
	
	'ef autoincrement' => {
		message => q|Autoincrement|,
		lastUpdated => 0,
	},

	'ef autoincrement description' => {
		message => q|<p>Setting a field will cause it to assign itself a
value that is the highest value of the field that is already in the database
plus one. In other words each record will have a succesive number for this
field. The field value will increment automatically.</p>

<p>Enabling autincrement for a field will mean necessarily that the field is
forced read only and will not accept user input. Therefore the choice of
form field type is irrelevant if autoincrement is enabled.</p>|,
		lastUpdated => 0,
	},

	'ef form height' => {
		message => q|Height of form element|,
		lastUpdated => 0,
	},
	
	'ef form height description' => {
		message => q|<p>This property sets the height of the form
element, if applicable for the chosen form field type. Not all form elements
have a settable height.</p>|,
		lastUpdated => 0,
	},

	'ef form width' => {
		message => q|Width of form element|,
		lastUpdated => 0,
	},
	
	'ef form width description' => {
		message => q|<p>This property sets the width of the form
element, if applicable for the chosen form field type. Not all form elements
have a settable width.</p>|,
		lastUpdated => 0,
	},

	'ef max field length' => {
		message => q|Maximum field length|,
		lastUpdated => 0,
	},

	'ef max field length description' => {
		message => q|<p>This property defines the number of characters that
the value that is inputted into this field is allowed to have. This property
applies only to form elements that allow a user to actually type. So if you
chose, for instance, a select list a form field type this option will have no
effect.</p>

<p>Please note that some database type define a limit for the value of this
property.</p>|,
		lastUpdated => 0,
	},

	'ef regex' => {
		message => q|Regex|,
		lastUpdated => 0,
	},

	'ef regex description' => {
		message => q|<p>Regex is short for regular expression. A regex
is used to precisely match data against a specific pattern. The regex property
thus allows you to check the input user assign to this field.</p>

<p>The list of regexes you can choose from is defined in the <b>Regex
manager</b> of the SQLForm asset. For more information regarding it please read
the help on <b>Manage regexes</b>, which you can access by clicking on the link
in the menu on the right.</p>|,
		lastUpdated => 0,
	},

	'ef required' => {
		message => q|Required|,
		lastUpdated => 0,
	},

	'ef required description' => {
		message => q|<p>Setting this property to yes will force users to
fill in a value for this field when adding a record. If set to no users are
allowed to leave the field empty.</p>|,
		lastUpdated => 0,
	},

	'ef read only' => {
		message => q|Read only|,
		lastUpdated => 0,
	},

	'ef read only description' => {
		message => q|<p>Setting this property to will cause the field to
be read only, meaning that users cannot input a value for it when adding or
editing a record. The value that is stored in this field on record addition is
the value given by the <b>Default value</b> property.</p>|,
		lastUpdated => 0,
	},

	'ef default value' => {
		message => q|Default value|,
		lastUpdated => 0,
	},

	'ef default value description' => {
		message => q|<p>This property can be used to prepopulate the form
element tied to this field on record addition. If the field is set read only the
value of this property will be used to put in the database.</p>

<p>You can use macro's for this property, to make your default value dynamic.
For instance, if you want a field to default to the username of the person
adding a record, you can use <i>&hat;User(username);</i> in this property.</p>

<p>If the field is set to autoincrement, the default value property is
neglected.</p>|,
		lastUpdated => 0,
	},

	'ef field constraint' => {
		message => q|Field constraint|,
		lastUpdated => 0,
	},

	'ef field constraint description' => {
		message => q|<p>The field constraint property has a similar use
as the regex. The big diffrence, however, is that you can use the field
constraint to apply a constraint on the actual value that is input by the user
who adds a record, while a regex is used to constrain the form (or the pattern)
of the input.</p>

<p>There are a number of operators available to define your constraint. If you
set the constraint to another value than <i>none</i> you will be able to select
what you want to compare against. You can use a custom value for comparison, but
if you have defined joins with other tables in the <b>define table(-joins)</b>
you can also match against one of the columns of those tables.</p>

<p>The field constrained property is ignored if the read only or the
autoincrement property is set.</p>|,
		lastUpdated => 0,
	},

	'ef searchable' => {
		message => q|Searchable|,
		lastUpdated => 0,
	},

	'ef searchable description' => {
		message => q|<p>You can include this field in search queries by
setting to 'yes'. If set to 'no' users will be unable to search on this
field.</p>|,
		lastUpdated => 0,
	},

	'ef fulltext' => {
		message => q|Use fulltext index|,
		lastUpdated => 0,
	},

	'ef fulltext description' => {
		message => q|<p>Fulltext indices are used too speed up search
queries, so setting this property to yes may increase performance of the SQLForm
asset. Adding or editing records, however, will be somewhat slowed down by using
a fulltext index.</p>

<p>Fulltext indices are only apllicable to certain database field types like
<i>text</i> or <i>longtext</i> but enabling this property on another field type
won't affect the operation of the SQLForm.</p>|,
		lastUpdated => 0,
	},

	'ef show in search' => {
		message => q|Show in search results|,
		lastUpdated => 0,
	},

	'ef show in search description' => {
		message => q|<p>By setting this property to 'yes' this field will
be shown in the list of search results. If you set it to 'no' users will not be
able to see the value of this field in the search results. Users can view the
field when viewing or editing this field regardless of this property
however.</p>|,
		lastUpdated => 0,
	},

	'ef summary length' => {
		message => q|Summary length|,
		lastUpdated => 0,
	},

	'ef summary length description' => {
		message => q|<p>This property determines how much characters of the
value of this field should shown in the search result list. The field value will
be truncated to the number of characters you enter here. Setting this property
to zero will disable this property and cause field value not to be truncated in
the search results list.</p>|,
		lastUpdated => 0,
	},

	'ef populate keys' => {
		message => q|Keys of form element options|,
		lastUpdated => 0,
	},

	'ef populate keys description' => {
		message => q|<p>You can use this property to populate option based
form elements, like select-, radio- and check lists. Each option consists of a
key and a value. Keys are the values that are stored in the database and values
are the text labels that are shown in the form element to identify the
option.</p>

<p>Use this property to define the keys for the available options. Fill in one
key per line, and make sure that the number of keys here matches the number of
values entered in the <b>Values of form element options</b> property.</p>

<p>Please note that if a connection to another table is defined in the <b>Define
table(-joins)</b> property, the <b>Keys of form element options</b> property is
neglected.</p>|,
		lastUpdated => 0,
	},

	'ef populate values' => {
		message => q|Values of form element options|,
		lastUpdated => 0,
	},

	'ef populate values description' => {
		message => q|<p>You can use this property to populate option based
form elements, like select-, radio- and check lists. Each option consists of a
key and a value. Keys are the values that are stored in the database and values
are the text labels that are shown in the form element to identify the
option.</p>

<p>Use this property to define the values for the available options. Fill in one
value per line, and make sure that the number of values here matches the number of
keys entered in the <b>Keys of form element options</b> property.</p>

<p>Please note that if a connection to another table is defined in the <b>Define
table(-joins)</b> property, the <b>Values of form element options</b> property is
neglected.</p>|,
		lastUpdated => 0,
	},

	'ef join selector' => {
		message => q|Define table(-joins)|,
		lastUpdated => 0,
	},

	'ef join selector description' => {
		message => q|<p>You can connect this field to other tables using
this property. This connection can be used for constraing field values and
setting the keys and values of options of form elements like select list, radio
lists and check lists.</p>

<p>In order to do so you must select 
the database in which the table of your choice resides and, of course, the table
itself. You can add more tables by clicking on the join button that appears
below the table selection. In order to do this you must choose the columns that
connect the tables you have selected and the type of that connection. 

<p>These columns should identify the rows they are in in exectly the same way so
that the SQLForm knows which record in one table belongs to a record in another.
You can choose from two connection methods: by set-intersection and by
set-difference.</p>

<p>Suppose we have two tables, A and B, that we want to connect to eachother in
order to get dat out of them into a select list. If you use an intersection the
tables are connected in such a way that only the elements that are in A as well
as B are returned. If you use the difference method, only the rows that are in A
but not B are returned.</p>|,
		lastUpdated => 0,
	},

	'ef join constraint' => {
		message => q|Constraint|,
		lastUpdated => 0,
	},

	'ef join constraint description' => {
		message => q|<p>You can use this property to limit the results from
the definition in the <b>Define table(-joins)</b> property by selecting a
column, a constraint type and a value.</p>|,
		lastUpdated => 0,
	},

	'ef join keys' => {
		message => q|Get keys from column|,
		lastUpdated => 0,
	},

	'ef join keys description' => {
		message => q|<p>Use this property to generate the keys of the
options of option based form elements like select list from the table
definition.</p>|,
		lastUpdated => 0,
	},

	'ef join values' => {
		message => q|Get values from column|,
		lastUpdated => 0,
	},

	'ef join values description' => {
		message => q|<p>Use this property to generate the values of the
options of option based form elements like select list from the table
definition.</p>|,
		lastUpdated => 0,
	},


	'ef errors occurred' => {
		message => q|Some errors occured:|,
		lastUpdated => 0,
	},

	'efs height error' => {
		message => q|Invalid value for Form field height|,
		lastUpdated => 0,
	},

	'efs width error' => {
		message => q|Invalid value for Form field width|,
		lastUpdated => 0,
	},

	'efs populate error' => {
		message => q|Number of keys and values of form population keys
does not match|,
		lastUpdated => 0,
	},

	'efs constraint error' => {
		message => q|You must enter a constraint value|,
		lastUpdated => 0,
	},

	'efs jf1 error' => {
		message => q|You cannot select Join field 1 without defining it|,
		lastUpdated => 0,
	},

	'efs jf2 error' => {
		message => q|You cannot select Join field 2 without defining it|,
		lastUpdated => 0,
	},

	'efs join populate error' => {
		message => q|You should select the key and value columns in the
field population tab|,
		lastUpdated => 0,
	},

	'efs left join column error' => {
		message => q|You have to specify the left join column for table|,
		lastUpdated => 0,
	},

	'efs right join column error' => {
		message => q|You have to specify the right join column for table|,
		lastUpdated => 0,
	},

	'efs column name error' => {
		message => q|Illegal column name in join clause:|,
		lastUpdated => 0,
	},

	'efs table error' => {
		message => q|Illegal table selected.|,
		lastUpdated => 0,
	},

	'efs database error' => {
		message => q|Illegal database selected.|,
		lastUpdated => 0,
	},

	'efs field type error' => {
		message => q|Illegal field type.|,
		lastUpdated => 0,
	},

	'efs fulltext error' => {
		message => q|Column type does not support full text search.|,
		lastUpdated => 0,
	},

	'efs column name exists error' => {
		message => q|The field name already exists in the table.|,
		lastUpdated => 0,
	},

	'efs column name is reserved error' => {
		message => q|The field name is the same as a reserved keyword,
which is not allowed.|,
		lastUpdated => 0,
	},

	'efs field name error' => {
		message => q|Illegal field name.|,
		lastUpdated => 0,
	},

	'eft db field type' => {
		message => q|Database field type|,
		lastUpdated => 0,
	},

	'eft db field type description' => {
		message => q|<p>This property sets the MySQL column type of the
column in the database that will store the data entered in field with this field
type.</p>|,
		lastUpdated => 0,
	},

	'eft form field type' => {
		message => q|Form element type|,
		lastUpdated => 0,
	},

	'eft form field type description' => {
		message => q|<p>You can select the form element that will be used
to enter data in field with this field type. Please note that some combinations
of form and db types do not make much sense.</p>|,
		lastUpdated => 0,
	},

	'click here for file' => {
		message => q|Click here for file|,
		lastUpdated => 0,
	},

	'keep' => {
		message => q|Keep|,
		lastUpdated => 0,
	},
	
	'overwrite' => {
		message => q|Overwrite|,
		lastUpdated => 0,
	},
	
	'delete' => {
		message => q|Delete|,
		lastUpdated => 0,
	},

	'invalid record id' => {
		message => q|Not a valid record id.|,
		lastUpdated => 0,
	},

	'view history' => {
		message => q|View record history|,
		lastUpdated => 0,
	},
	'no fields defined message' => {
		message => q|There are no fields defined yet. You can add field
by going to|,
		lastUpdated => 0,
	},

	'manage fields title' => {
		message => q|Manage fields|,
		lastUpdated => 0,
	},

	'ers file too large' => {
		message => q|File too large|,
		lastUpdated => 0,
	},

	'ers field required' => {
		message => q|Field is required:|,
		lastUpdated => 0,
	},

	'ers regex mismatch' => {
		message => q|Field does not match its regex:|,
		lastUpdated => 0,
	},

	'ers too long' => {
		message => q|Field is too long. Maximum number of characters:|,
		lastUpdated => 0,
	},

	'ers value not allowed' => {
		message => q|Value is not allowed for field:|,
		lastUpdated => 0,
	},

	'ers out of range' => {
		message => q|The value for this field is out of range:|,
		lastUpdated => 0,
	},

	'er error message' => {
		message => q|An error occurred:|,
		lastUpdated => 0,
	},

	'er name' => {
		message => q|Name|,
		lastUpdated => 0,
	},

	'er name description' => {
		message => q|<p>Use this property to set the name by which the
regex will be shown on the screen.</p>|,
		lastUpdated => 0,
	},

	'er regex' => {
		message => q|Regex|,
		lastUpdated => 0,
	},

	'er regex description' => {
		message => q|<p>This property defines the actual regular
expression. The regex you enter here should be perl style.</p>|,
		lastUpdated => 0,
	},

	'ers no name' => {
		message => q|Please supply a name for this regex.|,
		lastUpdated => 0,
	},

	'ers no regex' => {
		message => q|Please supply a regex.|,
		lastUpdated => 0,
	},

	'no field types message' => {
		message => q|In order to add fields to a SQLForm field types
must be defined. Currently there are no field types defined, and therfore it is
not possible ta add fields. Please add at least one field type by going to|,
		lastUpdated => 0,
	},

	'manage field types title' => {
		message => q|Manage field types|,
		lastUpdated => 0,
	},

	'lf add field' => {
		message => q|Add field|,
		lastUpdated => 0,
	},

	'lft delete confirm message' => {
		message => q|Are you sure to delete this field type?|,
		lastUpdated => 0,
	},

	'lft show assets using' => {
		message => q|Click <b>here</b> to show SQLForms that use this field type.|,
		lastUpdated => 0,
	},

	'lft in field' => {
		message => q|in field|,
		lastUpdated => 0,
	},

	'lft unused field types' => {
		message => q|Unused field types|,
		lastUpdated => 0,
	},

	'lft db type' => {
		message => q|Database type|,
		lastUpdated => 0,
	},

	'lft form type' => {
		message => q|Form element|,
		lastUpdated => 0,
	},

	'lft used field types' => {
		message => q|Field types in use|,
		lastUpdated => 0,
	},

	'lft add field type' => {
		message => q|Add a new field type|,
		lastUpdated => 0,
	},

	'lr show assets using' => {
		message => q|Click <b>here</b> to show SQLForms that use this regular expression.|,
		lastUpdated => 0,
	},

	'lr in field' => {
		message => q|in field|,
		lastUpdated => 0,
	},

	'lr unused regexes' => {
		message => q|Unused regular expressions|,
		lastUpdated => 0,
	},

	'lr name' => {
		message => q|Name|,
		lastUpdated => 0,
	},

	'lr regex' => {
		message => q|Regular expression|,
		lastUpdated => 0,
	},

	'lr used regexes' => {
		message => q|Regular expressions in use|,
		lastUpdated => 0,
	},

	'lr add regex' => {
		message => q|Add a new regular expression|,
		lastUpdated => 0,
	},

	'vh init date' => {
		message => q|Init date|,
		lastUpdated => 0,
	},

	'vh user' => {
		message => q|User|,
		lastUpdated => 0,
	},

	's query' => {
		message => q|Search for|,
		lastUpdated => 0,
	},

	's mode' => {
		message => q|Search mode|,
		lastUpdated => 0,
	},

	's type' => {
		message => q|Search type|,
		lastUpdated => 0,
	},

	's search in fields' => {
		message => q|Search in fields|,
		lastUpdated => 0,
	},

	's location' => {
		message => q|Search location|,
		lastUpdated => 0,
	},

	's search button' => {
		message => q|Search|,
		lastUpdated => 0,
	},

	's query error' => {
		message => q|Your query contains an error:|,
		lastUpdated => 0,
	},

	's advanced search' => {
		message => q|Advanced search|,
		lastUpdated => 0,
	},

	's normal search' => {
		message => q|Normal search|,
		lastUpdated => 0,
	},

	's restore' => {
		message => q|Restore|,
		lastUpdated => 0,
	},

	's purge' => {
		message => q|Purge|,
		lastUpdated => 0,
	},

	's search type' => {
		message => q|Search Type|,
		lastUpdated => 0,
	},

	'_csf only normal' => {
		message => q|Only normal|,
		lastUpdated => 0,
	},

	'_csf only trash' => {
		message => q|Only trash|,
		lastUpdated => 0,
	},

	'_csf normal and trash' => {
		message => q|Normal and trash|,
		lastUpdated => 0,
	},

	'and' => {
		message => q|and|,
		lastUpdated => 0,
	},

	'or' => {
		message => q|or|,
		lastUpdated => 0,
	},

	'_psq confirm delete message' => {
		message => q|Are you sure you want to delete this record?|,
		lastUpdated => 0,
	},

	'add record title' => {
		message => q|Add record|,
		lastUpdated => 0,
	},

	'search records title' => {
		message => q|Search records|,
		lastUpdated => 0,
	},

	'none' => {
		message => q|None|,
		lastUpdated => 0,
	},

	'gef no db links' => {
		message => q|You can only use this asset if you define databaselinks. Please define databases in the database links.|,
		lastUpdated => 0,
	},

	'gef table name' => {
		message => q|Table name|,
		lastUpdated => 0,
	},

	'gef table name description' => {
		message => q|<p>This is the name the table you want to attach
should get in the database, or if you want to attach the SQLForm to an existing
table, the name of that table.</p>|,
		lastUpdated => 0,
	},

	'gef database to use' => {
		message => q|Database to use|,
		lastUpdated => 0,
	},

	'gef database to use description' => {
		message => q|<p>This property defines the link to the database
where the table should reside or resides in. Database links can be added and
edited in the <b>Databases</b> section of the <b>Admin Console</b></p>|,
		lastUpdated => 0,
	},

	'gef max file size' => {
		message => q|Maximum file size|,
		lastUpdated => 0,
	},

	'gef max file size description' => {
		message => q|<p>Using this property you can define the maximum
size of files users can upload through the SQLForm. Specify the size in
kilobytes.</p>

<p>Please note that WebGUI also has a system wide maximum file size setting,
which cannot be overridden by this property. In other words, if you set this
property to a larger value than that of the system wide setting, the maximum
upload size will be the system wide.|,
		lastUpdated => 0,
	},

	'gef send mail to' => {
		message => q|Send notification mail to|,
		lastUpdated => 0,
	},

	'gef send mail to description' => {
		message => q|<p>The SQLForm sends a notification email to the
email address specified in this property every time a record is added or edited.
If you do not want to use this feature, simply leave the field blank.</p>|,
		lastUpdated => 0,
	},

	'gef show meta data' => {
		message => q|Show metadata|,
		lastUpdated => 0,
	},

	'gef show meta data description' => {
		message => q|<p>In the SQLForm each record has special meta data
containing the state of the record. If you want some of this this information to
be shown in search results, please set this property to yes.</p>|,
		lastUpdated => 0,
	},

	'gef edit template' => {
		message => q|View/Edit template|,
		lastUpdated => 0,
	},

	'gef edit template description' => {
		message => q|<p>This property sets the template that is used to
layout the record edit or view screen.</p>|,
		lastUpdated => 0,
	},

	'gef search template' => {
		message => q|Search template|,
		lastUpdated => 0,
	},

	'gef search template description' => {
		message => q|<p>This property sets the template that formats the
search results.</p>|,
		lastUpdated => 0,
	},

	'gef default view' => {
		message => q|Default view|,
		lastUpdated => 0,
	},
		
	'gef default view description' => {
		message => q|<p>This property switches the default view between normal and advanced search.</p>|,
		lastUpdated => 0,
	},
												
	'gef submit group' => {
		message => q|Group to submit records|,
		lastUpdated => 0,
	},

	'gef submit group description' => {
		message => q|<p>This is the group of user that can add, edit,
delete and restore but not purge records.</p>|,
		lastUpdated => 0,
	},

	'assetName' => {
		message => q|SQLForm|,
		lastUpdated => 0,
	},

	'edit sqlform' => {
		message => q|SQLForm, Add/Edit|,
		lastUpdated => 0,
	},

	'sqlform description' => {
		message => q|<p>The SQLForm asset allows you to dynamically
create data input and storage functionality in your site. All data is put in a
table of your choice in a database of your choice. An arbitrary form element can
be tied to each field and input forms can be built in diffrent ways to ensure
optimal adaptability to your needs.</p>

<p>The SQLForm features creation of new tables, import of existing tables and
re-importing previously imported tables. Fields can be linked to other fields in
other tables in serveral ways, making it possible to dynamically resolve id's to
values using joins, add constraints to inputted data or connect different
SQLForms together.</p>

<p>User input can also be checked against regular expressions and manual
constraints that are definable by you. In addition it's possible to add an
autoincrement flag and macros to fields, among other functionality.</p>

<p>All inputted data is versioned and a two level (delete/purge) trash is build
in. Three privilege layers are available to split access to different
actions.</p>|,
		lastUpdated => 0,
	},

	'edit field title' => {
		message => q|SQLForm, Add/Edit Field|,
		lastUpdated => 0,
	},

	'edit field description' => {
		message => q|<p>Fields are the basis of SQLForms. Each form
consists of one or more fields. Please note that in order to define fields, at
least one field type has to be defined. For information considering field types
please see the <b>Manage field types</b> help section.</p>|,
		lastUpdated => 0,
	},

	'edit field type title' =>{
		message => q|SQLForm, Add/Edit Field Type|,
		lastUpdated => 0,
	},

	'edit field type description' => {
		message => q|<p>Field types are combinations of a database column
type and a form element for data input. These field types are used to define the
basis of the fields in your SQLForm. Field types can only be deleted if they are
not in use by any SQLForm in the system. Please note that this also includes
SQLForm assets that are in the trash and are not yet purged.</p>|,
		lastUpdated => 0,
	},

	'edit regex title' => {
		message => q|SQLForm, Add/Edit Regex|,
		lastUpdated => 0,
	},

	'edit regex description' => {
		message => q|<p>Regular expressions are strings that represent a
pattern of text. Regexes used in the SQLForm are of the perl-variant. The syntax
of perl-style regular expressions can be found <a
href="http://perldoc.perl.org/perlretut.html">here</a>. To ensure data integrity, 
regular expressions can only be deleted if they're not is use by any SQLForm in
the system. Please note this also includes SQLForm that are in the trash and not
have been purged yet.|,
		lastUpdated => 0,
	},

	'manage fields' => {
		message => q|Manage fields|,
		lastUpdated => 0,
	},
	
	'manage fields title' => {
		message => q|SQLForm, Manage Fields|,
		lastUpdated => 0,
	},

	'manage field types title' => {
		message => q|SQLForm, Manage Field Types|,
		lastUpdated => 0,
	},

	'manage field types' => {
		message => q|Manage field types|,
		lastUpdated => 0,
	},
	
	'manage regexes title' => {
		message => q|SQLForm, Manage Regexes|,
		lastUpdated => 0,
	},

	'manage regexes' => {
		message => q|Manage regexes|,
		lastUpdated => 0,
	},

	'edit template help title' => {
		message => q|SQLForm, Add/Edit Record Template|,
		lastUpdated => 0,
	},

	'edit template help' => {
		message => q|<p>The SQLForm provides you with three
methods to construct record input and edit forms, offering three
levels of flexibility. Please note that more flexibilty has the
downside of increased complexity.</p>

<p>The three methods you can use are:
<b>completeForm</b>, <b>formloop</b> or manual placement of form
elements using <b>field.&lt;fieldname&gt;.formElement</b> and
<b>field.&lt;fieldname&gt;.label</b></p>


<p><b>completeForm</b><br />
This contains the entire form, complete
and layouted in a WebGUI style table. You don't need to add a
seperate form header, footer or anything else.</p>

<p><b>formLoop</b><br />
A loop containing each field. Using
this loop will allow you to use a different layout than that of
<b>completeForm</b>. The <b>formLoop</b> loop provides the following
variables:</p>

<blockquote>
<p>	<b>field.label</b><br />
The display name of the field.</p>


<p>	<b>field.formElement</b><br />
The form Element for the field<br />
In view mode this is the same as <b>field.value</b>.
</p>

<p>     <b>field.value</b><br />
The value of the field</p>


</blockquote>

<p>Finally there is the option of placing
each seperate field by hand. This allows you to define the order and
place of each form element. Please note, however, that using this
method will not automatically follow changes you make to the SQLForm.
If you add, delete or rename a field you must update the template by
hand. Using this method also implies the use of <b>formHeader</b> and
<b>formFooter.</b> You should use the following two template
variables:</p>


<p><b>field.&lt;fieldname&gt;.formElement</b><br />
Contains the form element of the field
&lt;fieldname&gt;. You must substitute &lt;fieldname&gt; with the
field name of the field you intend to place.<br />
In view mode this is the same as <b>field&lt;fieldname&gt;.value</b>.
</p>


<p><b>field.&lt;fieldname&gt;.label</b><br />
Contains the display name of the field
&lt;fieldname&gt;. You must substitute &lt;fieldname&gt; with the
field name of the field you intend to place.</p>

<p><b>field.&lt;fieldname&gt;.value</b><br />
Contains the value of the field
&lt;fieldname&gt;. You must substitute &lt;fieldname&gt; with the
field name of the field you intend to place.</p>


<p><b>formHeader</b><br />
The header of the form. If you are
not using the <b>completeForm</b> You must include this variable
before any other form variable. If you do use the <b>completeForm
</b>variable, however, you must not use the <b>formHeader</b>
variable.</p>


<p><b>formFooter</b><br />
The footer of the form. If you are
not using the <b>completeForm</b> You must include this variable
after every other form variable. If you do use the <b>completeForm</b>
variable, however, you must not use the <b>formFooter</b> variable.</p>

<p>This template also provides some other
variables:</p>


<p><b>errorOccurred</b><br />
Conditional indicating whether an error
occurred in the submitted data.</p>


<p><b>errorLoop</b><br />
Loop containing the errors.</p>

<blockquote>
<p>	<b>error.message</b><br />
The actual error message.</p>
</blockquote>

<p><b>isNew</b><br />
Conditional idicating whether the user
is adding a new record or editing an existing one. True is the record
is new.</p>


<p><b>viewHistory.url</b><br />
The url to the history of this record.</p>


<p><b>viewHistory.label</b><br />
The label of the link to the history of
this record.</p>


<p><b>managementLinks</b><br />
A string of links to all of the
management functions.</p>

<p><b>record.controls</b><br />
Delete, edit and copy buttons for theis record. Only available if the user is 
allowed to edit the record.</p>|,
		lastUpdated => 0,
	},

	'search template help title' => {
		message => q|SQLForm, Search Record Template|,
		lastUpdated => 0,
	},

	'search template help' => {
		message => q|<p>The search template of the SQLForm asset
provides you with a way to customize the looks of the search
functionality that the SQLForm offers.</p>

<p>There are two separate search methods, being normal and advanced search, but
both use the same template. In both cases a complete <b>searchForm</b> is available. 
The individual form Elements are also available, but note that different form Elements are used for normal and advanced search.</p>

<p>The following template variable are available to you:</p>

<p><b>showFieldsDefined</b><br />
Conditional which returns true if there are field that are defined to be shown.
In other words, this is false if every field is configured not to be displayed
in the search results.</p>

<p><b>searchForm</b><br />
Contains the complete form which allows users to search.</p>

<p><b>searchFormHeader</b><br />
The header of the form, available in normal and advanced search. If you are
not using the complete <b>searchForm</b> You must include this variable
before any other form variable. If you do use the complete <b>searchForm
</b> variable, however, you must not use the <b>searchFormHeader</b>
variable.</p>

<p><b>searchFormTrash.label</b><br />
The label for the search in trash option. Available in normal and advanced search. Only use this if you are
not using the complete <b>searchForm</b>.</p>                                                                                                                                                             
<p><b>searchFormTrash.form</b><br />
The form Element for the search in trash option. Available in normal and advanced search. Only use this if you are
not using the complete <b>searchForm</b>.</p>

<p><b>searchFormMode.label</b><br />
The label for the search mode option (with regex or not). Available in normal search. Only use this if you are
not using the complete <b>searchForm</b>.</p>                                                                                                                                                              
<p><b>searchFormMode.form</b><br />
The form Element for the search mode option (with regex or not). Available in normal search. Only use this if you are
not using the complete <b>searchForm</b>.</p>

<p><b>searchFormQuery.label</b><br />
The label for the search query. Available in normal search. Only use this if you are
not using the complete <b>searchForm</b>.</p>                                                                                                                                                              
<p><b>searchFormQuery.form</b><br />
The form Element for the search query. Available in normal search. Only use this if you are
not using the complete <b>searchForm</b>.</p>

<p><b>searchFormSearchIn.label</b><br />
The label for the search in fields select list. Available in normal search. Only use this if you are
not using the complete <b>searchForm</b>.</p>                                                                                                                                                              
<p><b>searchFormSearchIn.form</b><br />
The form Element for the search in fields select list. Available in normal search. Only use this if you are
not using the complete <b>searchForm</b>.</p>

<p><b>searchFormType.label</b><br />
The label for the search type option (or/and). Available in advanced search. Only use this if you are
not using the complete <b>searchForm</b>.</p>                                                                                                                                                              
<p><b>searchFormType.form</b><br />
The form Element for the search type option (or/and). Available in advanced search. Only use this if you are
not using the complete <b>searchForm</b>.</p>
                                                                                                                                                             
<p><b>searchFormFooter</b><br />
The footer of the form, available in normal and advanced search. If you are
not using the complete <b>searchForm</b> You must use this variable
after every other searchForm variable. If you do use the complete <b>searchForm</b>
variable, however, you must not use the <b>searchFormFooter</b> variable.</p>

<p><b>searchFormSubmit</b><br />
The submit button of the form, available in normal and advanced search. Only use this if you are
not using the complete <b>searchForm</b>.</p>

<p><b>searchFormJavascript</b><br />
Only used for advanced search. This links the SQLFormSearch.js file and contains some inline javascript that is used by advanced search. If you are
not using the complete <b>searchForm</b> you must include this variable
for advanced search. If you do use the complete <b>searchForm</b>
variable, however, you must not use the <b>searchFormJavascript</b> variable.</p>

<p><b>searchForm.field_loop</b><br />
A loop containing each field, only available in advanced search. 
The <b>field_loop</b> provides the following
variables:</p>
                                                                                                                                                             
<blockquote>
<p>     <b>field.label</b><br />
The display name of the field.</p>
                                                                                                                                                             
<p>     <b>field.conditionalForm</b><br />
The form Element for the conditional for this field</p>

<p>     <b>field.conditional</b><br />
The value of the conditional form Element for this field</p>
                                                                                                                                                             
<p>     <b>field.searchForm1</b><br />
The first search form Element for this field</p>

<p>     <b>field.searchForm1</b><br />
The second search form Element for this field</p>                                                                                                                                                             
<p>     <b>field.formValue1</b><br />
The value of first search form Element for this field</p>

<p>     <b>field.formValue2</b><br />
The value of second search form Element for this field</p>

<p>	<b>field.&lt;fieldname&gt;.id</b><br />
Contains the id of the field
&lt;fieldname&gt;. You must substitute &lt;fieldname&gt; with the
field name of the field.<br />
You can use this if you want to create a custom Advanced search form that completely overrides the default search form.
</p>

</blockquote>

<p>The template provides variables for the search results that are the same for normal and advanced search.

<p><b>headerLoop</b><br />
A loop containing the display names of each field, inclding sort controls. The
following variables are provided within this loop:</p>

<blockquote>
	<p><b>header.title</b><br />
	The display name of the current field.</p>
	
	<p><b>header.sort.url</b><br />
	The url that allows you to sort on this field.</p>
	
	<p><b>header.sort.onThis</b><br />
	Conditional indicating whether the search results are sorted on this
	field.</p>
	
	<p><b>header.sort.ascending</b><br />
	Conditional indicating whether the search results are sorted ascending
	or descending.</p>
</blockquote>

<p><b>searchResults.header</b><br />
Contains the form header for the batch restore and purge functions in the search
results. You should put this somewhere before the searchResults loop.</p>

<p><b>searchResults.footer</b><br />
Contains the form footer for the search results batch functions. Put this
template variable somewhere after the searchResults loop.</p>

<p><b>searchResults.actionButtons</b><br />
Contains the restore and purge buttons for the batch operations. Put this
variable between searchResults.header and searchResults.footer.</p>

<p><b>searchResults.recordLoop</b><br />
The loop containg the results of the search query. This should be between
searchResults.header and searchResults.footer. Within this loop the following
variables are available for use:</p>

<blockquote>
	<p><b>record.controls</b><br />
	Contains the edit/view, delete and purge restore controls for this
	record.</p>
	
	<p><b>record.deletionDate</b><br />
	Contains the date this record was deleted. Only available for records
	that are deleted.</p>
	
	<p><b>record.deletedBy</b><br />
	Contains the username of the person that deleted this record. Only
	available for records that are deleted.</p>
	
	<p><b>record.updateDate</b><br />
	The date of the last time this record has been updated.</p>
	
	<p><b>record.updatedBy</b><br />
	The username of the person that made the most recent update to this
	record.</p>
	
	<p><b>record.valueLoop</b><br />
	A loop containing the values for each field of this record. This loop
	provides the following variables:</p>
	
	<blockquote>
		<p><b>record.value</b><br />
		The value the record has for this field.</p>
		
		<p><b>record.value.isFile</b><br />
		Conditional being true if this field contains an uploaded file.
		Also returns true if the file is an image.</p>
		
		<p><b>record.value.isImage</b><br />
		Conditional indicating if the uploaded file is an image.</p>
		
		<p><b>record.value.downloadUrl</b><br />
		The url to download the uploaded file in this field. Only
		available for files and images.</p>
	</blockquote>
</blockquote>

<p><b>superSearch.url</b><br />
The url to the advanced search mode.</p>

<p><b>superSearch.label</b><br />
The internationalized name of the advanced search.</p>

<p><b>normalSearch.url</b><br />
The url to the normal search mode.</p>

<p><b>normalSearch.label</b><br />
The internationalized name of the normal search.</p>

<p><b>showMetaData</b><br />
A conditional indictating whether the show meta data flag is turned on.</p>

<p><b>managementLinks</b><br />
A collection of links to the admin functions of the SQLForm like manage fields,
as well as links to add record and search record.</p>

<p><b>errorOccurred</b><br />
Conditional which is true if some error happened while processing the search query.</p>

<p><b>errorLoop</b><br />
A loop containing the errors that have occurred while processing the search
query. The following variable is available in this loop:</p>

<blockquote>
	<p><b>error.message</b><br />
	Contains the actual error message.</p>
</blockquote>|,
		lastUpdated => 0,
	},

	'dft cannot delete' => {
		message => q|This field type cannot by deleted beacause it still is in use by|,
		lastUpdated => 0,
	},

	'sqlforms' => {
		message => q|SQLForms|,
		lastUpdated => 0,
	},

	'clear' => {
		message => q|Clear|,
		lastUpdated => 0,
	},

	'cancel' => {
		message => q|Cancel|,
		lastUpdated => 0,
	},

	'gef import table' => {
		message => q|Import this table|,
		lastUpdated => 0,
	},

	'gef import table description' => {
		message => q|<p>This option is a safety measure against
accidentally importing existing tables. Importing existing tables <b>will alter
the table by removing primary keys and addinng columns</b>. Therefore make sure
that altering the table you want to import will not break other systems. If
you're sure no harm can be done you must select this option to allow importing
the table.</p>|,
		lastUpdated => 0,
	},

	'ers change notification' => {
		message => q|Change notification|,
		lastUpdated => 0,
	},

	'ers change on table' => {
		message => q|A change has been made on table|,
		lastUpdated => 0,
	},

	'ers by user' => {
		message => q|by user|,
		lastUpdated => 0,
	},

	'ers view url' => {
		message => q|You can view this change by clicking on this url:|,
		lastUpdated => 0,
	},


};

1;

