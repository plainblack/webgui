package WebGUI::i18n::English::SQLReport;

our $I18N = {
	1 => q|SQL Report|,

	4 => q|Query|,

	8 => q|Edit SQL Report|,

	10 => q|<b>Debug:</b> Error: The SQL specified is of an improper format.|,

	11 => q|<b>Debug:</b> Error: There was a problem with the query.|,

	12 => q|<b>Debug:</b> Error: Could not connect to the database.|,

	14 => q|Paginate After|,

	15 => q|Preprocess macros on query?|,

	16 => q|Debug?|,

	17 => q|<b>Debug:</b> Query:|,

	18 => q|There were no results for this query.|,

	61 => q|SQL Report, Add/Edit|,

	71 => q|SQL Reports are perhaps the most powerful wobject in the WebGUI arsenal. They allow a user to query data from any database that they have access to. This is great for getting sales figures from your Accounting database or even summarizing all the message boards on your web site.
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

	73 => q|The following variables are made available from SQL Reports:
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

	72 => q|SQL Report Template|,

};

1;
