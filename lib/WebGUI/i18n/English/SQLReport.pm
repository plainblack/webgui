package WebGUI::i18n::English::SQLReport;

our $I18N = {
	'1' => {
		message => q|SQL Report|,
		lastUpdated => 1031514049
	},

	'4' => {
		message => q|Query|,
		lastUpdated => 1031514049
	},

	'8' => {
		message => q|Edit SQL Report|,
		lastUpdated => 1031514049
	},

	'10' => {
		message => q|<b>Debug:</b> Error: The SQL specified is of an improper format.|,
		lastUpdated => 1031514049
	},

	'11' => {
		message => q|<b>Debug:</b> Error: There was a problem with the query.|,
		lastUpdated => 1031514049
	},

	'12' => {
		message => q|<b>Debug:</b> Error: Could not connect to the database.|,
		lastUpdated => 1031514049
	},

	'14' => {
		message => q|Paginate After|,
		lastUpdated => 1031514049
	},

	'15' => {
		message => q|Preprocess macros on query?|,
		lastUpdated => 1031514049
	},

	'16' => {
		message => q|Debug?|,
		lastUpdated => 1031514049
	},

	'17' => {
		message => q|<b>Debug:</b> Query:|,
		lastUpdated => 1031514049
	},

	'18' => {
		message => q|There were no results for this query.|,
		lastUpdated => 1031514049
	},

	'61' => {
		message => q|SQL Report, Add/Edit|,
		lastUpdated => 1082365503
	},

	'71' => {
		message => q|SQL Reports are perhaps the most powerful wobject in the WebGUI arsenal. They allow a user to query data from any database that they have access to. This is great for getting sales figures from your Accounting database or even summarizing all the message boards on your web site.
<p>


<b>Preprocess macros on query?</b><br>
If you're using WebGUI macros in your query you'll want to check this box.
<p>


<b>Debug?</b><br>
If you want to display debugging and error messages on the page, check this box.
<p>


<b>Query</b><br>
This is a standard SQL query. If you are unfamiliar with SQL then you'll likely not want to use this wobject. You can make your queries more dynamic by using the ^FormParam(); macro.
<p>

<b>Database Link</b><br>
The administrator can configure common databases on which you can run SQL Reports, freeing you from having to know or enter the connectivity information.
<p>

<b>Paginate After</b>
How many rows should be displayed before splitting the results into separate pages? In other words, how many rows should be displayed per page?
<p>


|,
		lastUpdated => 1082365503
	},

	'73' => {
		message => q|The following variables are made available from SQL Reports:
<p>

<b>columns_loop</b><br />
A loop containing information about each column.
<br /><br />
<blockquote>

<b>column.number</b><br />
An integer starting with 1 and counting through the number of columns.
<br /><br />

<b>column.name</b><br />
The name of this column as returned by the query.
<br /><br />

</blockquote>

<b>rows_loop</b><br />
A loop containing the data returned from the query.
<br /><br />
<blockquote>

<b>row.number</b><br />
An integer starting with 1 and counting through the total list of rows.
<br /><br />

<b>row.field.<b><i>NAME</i></b>.value</b><br />
The data for a given field in this row where NAME is the name of the field as it is returned by the query.
<br /><br />

<b>row.field_loop</b><br />
A loop containing all of the fields for this row.
<br /><br />
<blockquote>

<b>field.number</b><br />
An integer starting with 1 and counting through the number of fields in this row. This is the same as column.number in the column_loop.
<br /><br />

<b>field.name</b><br />
The name of the field as it is returned by the query.
<br /><br />

<b>field.value</b><br />
The data in this field.
<br /><br />

</blockquote>

</blockquote>

<b>rows.count</b><br />
The total number of rows returned by the query.
<br /><br />

<b>rows.count.isZero</b><br />
A boolean indicating that the query returned zero rows.
<br /><br />

<b>rows.count.isZero.label</b><br />
The default label for rows.count.isZero.
<br /><br />

|,
		lastUpdated => 1082365471
	},

	'72' => {
		message => q|SQL Report Template|,
		lastUpdated => 1082371148
	},

};

1;
