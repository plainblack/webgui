<%@ LANGUAGE = VBScript %>
<%  Option Explicit		%>

<html>
<head>
	<title>ActiveWidgets Grid :: ASP Example</title>
	<style> body, html {margin:0px; padding: 0px; overflow: hidden;font: menu;border: none;} </style>

	<!-- ActiveWidgets stylesheet and scripts -->
	<link href="../../runtime/styles/xp/grid.css" rel="stylesheet" type="text/css" ></link>
	<script src="../../runtime/lib/grid.js"></script>

	<!-- ActiveWidgets ASP functions -->
	<!-- #INCLUDE FILE="activewidgets.asp" -->

</head>
<body>
	<%
		Dim oConnection
		Dim oRecordset

		' Create ADO Connection
		Set oConnection = Server.CreateObject("ADODB.Connection")
		oConnection.Open "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" & Server.MapPath("database.mdb")

		' Execute a SQL query
		Set oRecordset = oConnection.Execute("SELECT * FROM authors")

		' Write grid to the page
		Response.write(activewidgets_grid("obj", oRecordset))

		' Close recordset and connection
		oRecordset.close
		oConnection.close
	%>
</body>
</html>