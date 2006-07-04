package WebGUI::i18n::English::Macro_SQL;

our $I18N = {

	'macroName' => {
		message => q|SQL|,
		lastUpdated => 1128919058,
	},

	'sql title' => {
		message => q|SQL Macro|,
		lastUpdated => 1112466408,
	},

	'sql body' => {
		message => q|
<p><b>&#94;SQL();</b><br />
A one line SQL report. Sometimes you just need to pull something back from the database quickly. This macro is also useful in extending the SQL Report wobject. It uses the numeric macros (&#94;0; &#94;1; &#94;2; etc) to position data and can also use the &#94;&#94;rownum; macro just like the SQL Report wobject.</p>
<p>Examples:</p>
<p>&#94;SQL("select count(*) from users","There are &#94;0; users on this system.");
</p>
<p>&#94;SQL("select userId,username from users order by username","&lt;a href='&#94;/;?op=viewProfile&amp;uid=&#94;0;'&gt;&#94;1;&lt;/a&gt;&lt;br /&gt;");
</p>
<p>If there are more numeric macros than selected columns in the SQL report the extra macros will be discarded.</p>
<p>The rownum macro, &#94;rownum;, begins counting at 1.</p>
|,
		lastUpdated => 1151986323,
	},

	'illegal query' => {
		message => q|Cannot execute this type of query.|,
		lastUpdated => 1135105884,
	},

	'sql error' => {
		message => q|<p><b>SQL Macro Failed:</b>%s<p>|,
		lastUpdated => 1135105919,
	},

};

1;
