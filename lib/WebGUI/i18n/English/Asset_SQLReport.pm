package WebGUI::i18n::English::Asset_SQLReport;
use strict;

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

        '72 description' => {
                message => q|<p>Select a template to display the results of your SQL Report.
</p>|,
                lastUpdated => 1119841649,
        },

        '16 description' => {
                message => q|<p>If you want to display debugging and error messages on the page, check this box.
</p>|,
                lastUpdated => 1119841649,
        },

        'Placeholder Parameters description' => {
                message => q|<p>Placeholders, also called parameter markers, are used to indicate values in an SQL query that will be supplied later, before the statement is executed.</p>
<p>There are four input types:</p>
<div>
<ul>
<li><b>Integer</b><br />A simple number</li>
<li><b>Form</b><br />Form fields begin with "form:".</li>
<li><b>Query results</b><br />Query results begin with "query1:" through "query4:". Query results are populated with data from prior queries. So when the second query is initiated, it can used the results returned by query1. When query 5 is initiated it can use the results from queries 1 through 4.</li>
<li><b>String</b><br />Anything else is a string</li>
</ul></div>
<p>Example:</p>
<div class="helpIndent">
<p>Query: select * from some_table where some_field = ? and some_other_field &lt; ?<br />
Placeholder Parameters: query1:pageId<br />form:field1</p>
</div>
<p>In this example the first question mark will contain the field value of pageId in query1,
while the second question mark will contain the form variable "field1".</p>
<p>Place one Placeholder Parameter on each line.  Leading and trailing whitespace will be trimmed from each parameter.</p>
|,
                lastUpdated => 1162613239,
        },

        '15 description' => {
                message => q|<p>If you're using WebGUI macros in your query you'll want to check this box.
</p>|,
                lastUpdated => 1119841649,
        },

        '4 description' => {
                message => q|<p>This is a standard SQL query. If you are unfamiliar with SQL then you'll likely not want to use this wobject.</p>
<p>A question mark ? in the query represents a placeholder. Note that the ? is not enclosed in quotation marks, even when the placeholder represents a string.</p>
<p>The keywords that are allowed are defined in the database link properties. The allowed keywords for the WebGUI database are SELECT, DESCRIBE and SHOW.</p>|,
                lastUpdated => 1119841650,
        },

        '14 description' => {
                message => q|<p>How many rows should be displayed before splitting the results into separate pages? In other words, how many rows should be displayed per page?  Setting this to 0 will not disable pagination, but will use an internal default of 25, instead.
</p>|,
                lastUpdated => 1266860050,
        },

	'17' => {
		message => q|<b>Debug:</b> Query:|,
		lastUpdated => 1031514049
	},
    'No query specified for query' => {
        message => q|No query specified for query %s|,
        lastUpdated => 1263483624,
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

	'columns_loop' => {
		message => q|A loop containing information about each column.|,
		lastUpdated => 1149633030,
	},

	'column.number' => {
		message => q|An integer starting with 1 and counting through the number of columns.|,
		lastUpdated => 1149633030,
	},

	'column.name' => {
		message => q|The name of this column as returned by the query.|,
		lastUpdated => 1149633030,
	},

	'rows.count' => {
		message => q|The total number of rows returned by the query.|,
		lastUpdated => 1149633030,
	},

	'rows.count.isZero' => {
		message => q|A boolean indicating that the query returned zero rows.|,
		lastUpdated => 1149633030,
	},

	'rows.count.isZero.label' => {
		message => q|The default label for rows.count.isZero.|,
		lastUpdated => 1149633030,
	},

	'rows_loop' => {
		message => q|A loop containing the data returned from the query.|,
		lastUpdated => 1149633030,
	},

	'row.number' => {
		message => q|An integer starting with 1 and counting through the total list of rows.|,
		lastUpdated => 1149633030,
	},

	'row.field.__NAME__.value' => {
		message => q|The data for a given field in this row where __NAME__ is the name of the field as it is returned by the query.|,
		lastUpdated => 1149633030,
	},

	'row.field_loop' => {
		message => q|A loop containing all of the fields for this row.|,
		lastUpdated => 1149633030,
	},

	'field.number' => {
		message => q|An integer starting with 1 and counting through the number of fields in this row. This is the same as column.number in the column_loop.|,
		lastUpdated => 1149633030,
	},

	'field.name' => {
		message => q|The name of the field as it is returned by the query.|,
		lastUpdated => 1149633030,
	},

	'field.value' => {
		message => q|The data in this field.|,
		lastUpdated => 1149633030,
	},

	'hasNest' => {
		message => q|A boolean indicating whether query2 has returned any results.|,
		lastUpdated => 1149633030,
	},

	'queryN.columns_loop' => {
		message => q|A loop containing information about each column for queryN.|,
		lastUpdated => 1149633030,
	},

	'column.number' => {
		message => q|An integer starting with 1 and counting through the number of columns.|,
		lastUpdated => 1149633030,
	},

	'column.name' => {
		message => q|The name of this column as returned by the query.|,
		lastUpdated => 1149633030,
	},

	'queryN.rows.count' => {
		message => q|The total number of rows returned by queryN.|,
		lastUpdated => 1149633030,
	},

	'queryN.count.isZero' => {
		message => q|A boolean indicating that queryN returned zero rows.|,
		lastUpdated => 1149633030,
	},

	'queryN.rows.count.isZero.label' => {
		message => q|The default label for rows.count.isZero.|,
		lastUpdated => 1149633030,
	},

	'queryN.rows_loop' => {
		message => q|A loop containing the data returned from queryN.|,
		lastUpdated => 1149633030,
	},

	'queryN.row.number' => {
		message => q|An integer starting with 1 and counting through the total list of rows.|,
		lastUpdated => 1149633030,
	},

	'queryN.row.field.__NAME__.value' => {
		message => q|The data for a given field in this row where __NAME__ is the name of the field as it is returned by the query.|,
		lastUpdated => 1149633030,
	},

	'queryN.row.field_loop' => {
		message => q|A loop containing all of the fields for this row.|,
		lastUpdated => 1149633030,
	},

	'field.number' => {
		message => q|An integer starting with 1 and counting through the number of fields in this row. This is the same as column.number in the column_loop.|,
		lastUpdated => 1149633030,
	},

	'field.name' => {
		message => q|The name of the field as it is returned by the query.|,
		lastUpdated => 1149633030,
	},

	'field.value' => {
		message => q|The data in this field.|,
		lastUpdated => 1149633030,
	},

	'queryN.hasNest' => {
		message => q|A boolean indicating whether the queryN+1 has returned any results.  This variable
will always be false for query5.|,
		lastUpdated => 1149633030,
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
		<div class="helpIndent">set @myVariable := 1</div>
<p>The prequery statements are separated from each other by returns and cannot use placeholders. You can use macro's within the prequery statements, however. Please note that prequery statements are only visible in the query they belong to and that you can only use statements that are allowed by the database link.</p>|,
		lastUpdated => 1167186661,
	},

	'download type' => {
		message => 'Download Type',
		lastUpdated => 0,
	},

	'download type description' => {
		message => "The type of download to create.  No download will prevent a download from being created.  CSV will cause a CSV file to be returned.  Template will use the Download Template to generate the file to download.",
		lastUpdated => 1258417417,
	},

	'No Download' => {
		message => "No Download",
		lastUpdated => 1258417417,
	},

	'CSV' => {
		message => "CSV",
		lastUpdated => 1258417417,
        context => q|Short for Comma Separated Variables|,
	},

	'Template' => {
		message => "Template",
		lastUpdated => 1258417417,
	},

	'download filename' => {
		message => 'Download File Name',
		lastUpdated => 0,
	},

	'download filename description' => {
		message => "The filename of the file to download. If left blank, a name will be created.",
		lastUpdated => 1258417288,
	},

	'download template' => {
		message => "Download Template",
		lastUpdated => 0,
	},

	'download template description' => {
		message => "The template to use to generate the download file.",
		lastUpdated => 0,
	},

	'download mimetype' => {
		message => "Download Mime-Type",
		lastUpdated => 0,
	},

	'download mimetype description' => {
		message => "Mime-Type for the downloaded template.",
		lastUpdated => 0,
	},

	'download usergroup' => {
		message => "Download User Group",
		lastUpdated => 0,
	},

	'download usergroup description' => {
		message => "Group of users allowed to download the report.",
		lastUpdated => 0,
	},

	'Download this data' => {
		message => "Download this data",
		context => "Link label to download data form the report",
		lastUpdated => 1229907351,
	},

	'sql report asset template variables title' => {
		message => q|SQL Report Asset Template Variables|,
		lastUpdated => 1168887204
	},

	'templateId' => {
		message => q|The ID of the template to display the SQL Report to the user.|,
		lastUpdated => 1168886083,
	},

	'cacheTimeout' => {
		message => q|The amount of time in seconds the output will be cached.|,
		lastUpdated => 1168886083,
	},

	'paginateAfter' => {
		message => q|The number of rows or entries to show on each page of the report.|,
		lastUpdated => 1168886083,
	},

	'dbQuery1' => {
		message => q|The first database query.|,
		lastUpdated => 1168886083,
	},

	'prequeryStatements1' => {
		message => q|The first set of prequery SQL statements.|,
		lastUpdated => 1168886083,
	},

	'preprocessMacros1' => {
		message => q|A conditional indicating whether or not the first query will have embedded Macros processed before being executed.|,
		lastUpdated => 1168886083,
	},

	'placeholderParams1' => {
		message => q|A conditional indicating whether or not the first query will have embedded Macros processed before being executed.|,
		lastUpdated => 1168886083,
	},

	'databaseLinkId1' => {
		message => q|The identifier which describes which database the first query will be executed against.|,
		lastUpdated => 1168886083,
	},

	'dbQuery2' => {
		message => q|The second database query.|,
		lastUpdated => 1168886083,
	},

	'prequeryStatements2' => {
		message => q|The second set of prequery SQL statements.|,
		lastUpdated => 1168886083,
	},

	'preprocessMacros2' => {
		message => q|A conditional indicating whether or not the second query will have embedded Macros processed before being executed.|,
		lastUpdated => 1168886083,
	},

	'placeholderParams2' => {
		message => q|A conditional indicating whether or not the second query will have embedded Macros processed before being executed.|,
		lastUpdated => 1168886083,
	},

	'databaseLinkId2' => {
		message => q|The identifier which describes which database the second query will be executed against.|,
		lastUpdated => 1168886083,
	},

	'dbQuery3' => {
		message => q|The third database query.|,
		lastUpdated => 1168886083,
	},

	'prequeryStatements3' => {
		message => q|The third set of prequery SQL statements.|,
		lastUpdated => 1168886083,
	},

	'preprocessMacros3' => {
		message => q|A conditional indicating whether or not the third query will have embedded Macros processed before being executed.|,
		lastUpdated => 1168886083,
	},

	'placeholderParams3' => {
		message => q|A conditional indicating whether or not the third query will have embedded Macros processed before being executed.|,
		lastUpdated => 1168886083,
	},

	'databaseLinkId3' => {
		message => q|The identifier which describes which database the third query will be executed against.|,
		lastUpdated => 1168886083,
	},

	'dbQuery4' => {
		message => q|The fourth database query.|,
		lastUpdated => 1168886083,
	},

	'prequeryStatements4' => {
		message => q|The fourth set of prequery SQL statements.|,
		lastUpdated => 1168886083,
	},

	'preprocessMacros4' => {
		message => q|A conditional indicating whether or not the fourth query will have embedded Macros processed before being executed.|,
		lastUpdated => 1168886083,
	},

	'placeholderParams4' => {
		message => q|A conditional indicating whether or not the fourth query will have embedded Macros processed before being executed.|,
		lastUpdated => 1168886083,
	},

	'databaseLinkId4' => {
		message => q|The identifier which describes which database the fourth query will be executed against.|,
		lastUpdated => 1168886083,
	},

	'dbQuery5' => {
		message => q|The fifth database query.|,
		lastUpdated => 1168886083,
	},

	'prequeryStatements5' => {
		message => q|The fifth set of prequery SQL statements.|,
		lastUpdated => 1168886083,
	},

	'preprocessMacros5' => {
		message => q|A conditional indicating whether or not the fifth query will have embedded Macros processed before being executed.|,
		lastUpdated => 1168886083,
	},

	'placeholderParams5' => {
		message => q|A conditional indicating whether or not the fifth query will have embedded Macros processed before being executed.|,
		lastUpdated => 1168886083,
	},

	'databaseLinkId5' => {
		message => q|The identifier which describes which database the fifth query will be executed against.|,
		lastUpdated => 1168886083,
	},

	'debugMode' => {
		message => q|A conditional indicating whether or not the SQL Report can have debug information in the output.|,
		lastUpdated => 1168886083,
	},

};

1;
