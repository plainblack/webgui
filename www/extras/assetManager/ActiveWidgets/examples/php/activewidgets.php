<?php

/*
	include this file into your PHP page
	usage example:
*/

/*
	// grid object name
	$name = "obj";

	// SQL query
	$query = "select * from `table` limit 0,20";

	// database connection
	$connection = mysql_connect("localhost", "user", "password");
	mysql_select_db("database");

	// query results
	$data = mysql_query($query, $connection);

	// add grid to the page
	echo activewidgets_grid($name, $data);
*/

function activewidgets_grid($name, &$data){

	$row_count = @mysql_num_rows($data);
	$column_count = @mysql_num_fields($data);


	$columns = "var ".$name."_columns = [\n";
	for ($i=0; $i < $column_count; $i++) {
		$columns .= "\"".@mysql_field_name($data, $i)."\", ";
	}
	$columns .= "\n];\n";

	$rows = "var ".$name."_data = [\n";
	while ($result = @mysql_fetch_array($data)) {
		$rows .= "[";
		for ($i=0; $i < $column_count; $i++) {
			$rows .= "\"".activewidgets_html($result[$i])."\", ";
		}
		$rows .= "],\n";
	}
	$rows .= "];\n";

	$html = "<"."script".">\n";
	$html .= $columns;
	$html .= $rows;
	$html .= "try {\n";
	$html .= "  var $name = new Active.Controls.Grid;\n";
	$html .= "  $name.setRowCount($row_count);\n";
	$html .= "  $name.setColumnCount($column_count);\n";
	$html .= "  $name.setDataText(function(i, j){return ".$name."_data[i][j]});\n";
	$html .= "  $name.setColumnText(function(i){return ".$name."_columns[i]});\n";
	$html .= "  document.write($name);\n";
	$html .= "}\n";
	$html .= "catch (error){\n";
	$html .= "  document.write(error.description);\n";
	$html .= "}\n";
	$html .= "</"."script".">\n";

	return $html;
}

function activewidgets_html($msg){

	$msg = addslashes($msg);
	$msg = str_replace("\n", "\\n", $msg);
	$msg = str_replace("\r", "\\r", $msg);
	$msg = htmlspecialchars($msg);

	return $msg;
}

?>
