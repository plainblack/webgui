package WebGUI::i18n::English::Asset_SQLReport;

our $I18N = {
	'cache timeout description' => {
		message => q|How long should we cache the results of the query before fetching it again?|,
		lastUpdated => 1047837230
	},

	'cache timeout' => {
		message => q|Cache Timeout|,
		lastUpdated => 1047837230
	},

	'11' => {
		message => q|<b>Debug:</b> Error: There was a problem with the query.|,
		lastUpdated => 1031514049
	},

	'71' => {
		message => q|<p>SQL Reports are perhaps the most powerful wobject in the WebGUI arsenal. They allow a user to query data from any database that they have access to. This is great for getting sales figures from your Accounting database or even summarizing all the message boards on your web site.</p>
<p><b>Nested query support</b><br />
The SQL Report wobject supports up to 5 nested queries (1 base query and 4 subqueries). Each subsequent query is executed for each row in the previous query results. For example, if you have two queries: query1 and query2, then query2 will be executed once for each row returned in query1. You can use placeholder parameters to compose subqueries with data from prior queries. 
</p>
<p>
SQL Reports are Wobjects and Assets, so they share the properties of both.  SQL Reports also have these unique properties:
</p>|,
		lastUpdated => 1146785522,
	},

        '72 description' => {
                message => q|Select a template to display the results of your SQL Report.
<p>|,
                lastUpdated => 1119841649,
        },

        '16 description' => {
                message => q|If you want to display debugging and error messages on the page, check this box.
<p>|,
                lastUpdated => 1119841649,
        },

        'Placeholder Parameters description' => {
                message => q|<p>Placeholders, also called parameter markers, are used to indicate values in a SQL query that will be supplied later, before the statement is executed.</p>
<p>There are four input types:</p>
<div>
<ul>
<li><b>Integer</b><br />A simple number</li>
<li><b>Form</b><br />Form fields begin with "form:".</li>
<li><b>Query results</b><br />Query results begin with "query1:" through "query4:". Query results are populated with data from prior queries. So when the second query is initiated, it can used the results returned by query1. When query 5 is initiated it can use the results from queries 1 through 4.</li>
<li><b>String</b><br />Anything else is a string</li>
</ul></div>
<p>Example:</p>
<blockquote>
<p>Query: select * from some_table where some_field = ? and some_other_field &lt; ?<br />
Placeholder Parameters: query1:pageId<br />form:field1</p>
</blockquote>
<p>In this example the first question mark will contain the field value of pageId in query1,
while the second question mark will contain the form variable "field1".</p>
<p>Place one Placeholder Parameter on each line.</p>
|,
                lastUpdated => 1146785541,
        },

        '15 description' => {
                message => q|If you're using WebGUI macros in your query you'll want to check this box.
<p>|,
                lastUpdated => 1119841649,
        },

        '4 description' => {
                message => q|<p>This is a standard SQL query. If you are unfamiliar with SQL then you'll likely not want to use this wobject.</p>
<p>A question mark ? in the query represents a placeholder. Note that the ? is not enclosed in quotation marks, even when the placeholder represents a string.</p>
<p>The keywords that are allowed are defined in the database link properties. The allowed keywords for the WebGUI database are SELECT, DESCRIBE and SHOW.</p>|,
                lastUpdated => 1119841650,
        },

        '14 description' => {
                message => q|<p>How many rows should be displayed before splitting the results into separate pages? In other words, how many rows should be displayed per page?
</p>|,
                lastUpdated => 1119841649,
        },

	'61' => {
		message => q|SQL Report, Add/Edit|,
		lastUpdated => 1082365503
	},

	'17' => {
		message => q|<b>Debug:</b> Query:|,
		lastUpdated => 1031514049
	},
	'debug placeholder parameters' => {
                message => q|<b>Debug:</b> Processed Placeholder parameters:|,
                lastUpdated => 1031514049
        },
	'12' => {
		message => q|<b>Debug:</b> Error: Could not connect to the database.|,
		lastUpdated => 1031514049
	},

	'15' => {
		message => q|Preprocess macros on query?|,
		lastUpdated => 1031514049
	},

	'14' => {
		message => q|Paginate After|,
		lastUpdated => 1031514049
	},

	'8' => {
		message => q|Edit SQL Report|,
		lastUpdated => 1031514049
	},

	'assetName' => {
		message => q|SQL Report|,
		lastUpdated => 1128834150
	},

	'4' => {
		message => q|Query|,
		lastUpdated => 1031514049
	},

	'18' => {
		message => q|There were no results for this query.|,
		lastUpdated => 1031514049
	},

	'72' => {
		message => q|SQL Report Template|,
		lastUpdated => 1082371148
	},

	'73' => {
		message => q|<p>The following variables are made available in SQL Reports:
</p>

<p><b>columns_loop</b><br />
A loop containing information about each column.
</p>

<blockquote>

<p><b>column.number</b><br />
An integer starting with 1 and counting through the number of columns.
</p>

<p><b>column.name</b><br />
The name of this column as returned by the query.
</p>

</blockquote>

<p><b>rows.count</b><br />
The total number of rows returned by the query.
</p>

<p><b>rows.count.isZero</b><br />
A boolean indicating that the query returned zero rows.
</p>

<p><b>rows.count.isZero.label</b><br />
The default label for rows.count.isZero.
</p>

<p><b>rows_loop</b><br />
A loop containing the data returned from the query.
</p>

<blockquote>

<p><b>row.number</b><br />
An integer starting with 1 and counting through the total list of rows.
</p>

<p><b>row.field.</b><i>NAME</i><b>.value</b><br />
The data for a given field in this row where NAME is the name of the field as it is returned by the query.
</p>

<p><b>row.field_loop</b><br />
A loop containing all of the fields for this row.
</p>

<blockquote>

<p><b>field.number</b><br />
An integer starting with 1 and counting through the number of fields in this row. This is the same as column.number in the column_loop.
</p>

<p><b>field.name</b><br />
The name of the field as it is returned by the query.
</p>

<p><b>field.value</b><br />
The data in this field.
</p>

</blockquote>

</blockquote>

<p><b>hasNest</b><br />
A boolean indicating whether query2 has returned any results.
</p>

<p>Any subqueries will have exactly the same format as the loops
and variables above, but will be prefixed with queryN where N
goes from 2 to 5.</p>

<p><b>queryN.columns_loop</b><br />
A loop containing information about each column for queryN.
</p>

<blockquote>

<p><b>column.number</b><br />
An integer starting with 1 and counting through the number of columns.
</p>

<p><b>column.name</b><br />
The name of this column as returned by the query.
</p>

</blockquote>

<p><b>queryN.rows.count</b><br />
The total number of rows returned by queryN.
</p>

<p><b>queryN.count.isZero</b><br />
A boolean indicating that queryN returned zero rows.
</p>

<p><b>queryN.rows.count.isZero.label</b><br />
The default label for rows.count.isZero.
</p>

<p><b>queryN.rows_loop</b><br />
A loop containing the data returned from queryN.
</p>

<blockquote>

<p><b>queryN.row.number</b><br />
An integer starting with 1 and counting through the total list of rows.
</p>

<b>queryN.row.field.</b><i>NAME</i><b>.value</b><br />
The data for a given field in this row where NAME is the name of the field as it is returned by the query.
<p>

<p><b>queryN.row.field_loop</b><br />
A loop containing all of the fields for this row.
</p>

<blockquote>

<p><b>field.number</b><br />
An integer starting with 1 and counting through the number of fields in this row. This is the same as column.number in the column_loop.
</p>

<p><b>field.name</b><br />
The name of the field as it is returned by the query.
</p>

<p><b>field.value</b><br />
The data in this field.
</p>

</blockquote>

</blockquote>

<p><b>queryN.hasNest</b><br />
A boolean indicating whether the queryN+1 has returned any results.  This variable
will always be false for query5.
</p>

|,
		lastUpdated => 1146785660,
	},

	'16' => {
		message => q|Debug?|,
		lastUpdated => 1031514049
	},

	'10' => {
		message => q|<b>Debug:</b> Error: The SQL specified is of an improper format.|,
		lastUpdated => 1031514049
	},
	'Placeholder Parameters' => {
		message => q|Placeholder Parameters|,
		lastUpdated => 1031514049
	},
	'Add another query' => {
		message => q|Add another query|,
		lastUpdated => 1031514049
	},
	'Prequery not allowed' => {
		message => q|<b>Debug:</b> Prequery statement is not allowed: |,
		lastUpdated => 0,
	},
	'Prequery error' => {
		message => q|<b>Debug:</b> An error occured in prequery|,
		lastUpdated => 0,
	},
	'Prequery statements' => {
		message => q|Prequery statements|,
		lastUpdated => 0,
	},
	'Prequery statements description' => {
		message => q|<p>Prequery statements are sql statements executed before the real query. You can use prequery statements for instance to set variables that you want to use in the real query. For example:</p>
		<blockquote>set @myVariable := 1</blockquote>
<p>The prequery statements are seperated from each other by returns and cannot use placeholders. You can use macro's within the prequery statements, however. Please note that prequery statements are only visible in the query they belong to and that you can only use statements that are allowed by the database link.</p>|,
		lastUpdated => 0,
	},
};

1;
