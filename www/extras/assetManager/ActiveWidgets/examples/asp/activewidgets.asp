<%

function activewidgets_grid(name, oRecordset)

	Dim i, columns, rows, s
	Dim column_count, row_count

	column_count = oRecordset.fields.count

	columns = "var " & name & "_columns = [" & vbNewLine
	For i=0 to (column_count-1)
		columns = columns & """" & activewidgets_html(oRecordset(i).name)  & """, "
	Next
	columns = columns & vbNewLine & "];" & vbNewLine


	row_count = 0
	rows = "var " & name & "_data = [" & vbNewLine
	Do while (Not oRecordset.eof)
		row_count = row_count + 1
		rows = rows & "["
		For i=0 to (column_count-1)
			rows = rows & """" & activewidgets_html(oRecordset(i)) & """, "
		Next
		rows = rows & "]," & vbNewLine

		oRecordset.MoveNext
	Loop
	rows = rows & "];" & vbNewLine



	s = vbNewLine
	s = s & "<" & "script" & ">" & vbNewLine
	s = s & columns & vbNewLine
	s = s & rows & vbNewLine

	s = s & "try {" & vbNewLine
	s = s & "  var " & name & "= new Active.Controls.Grid;" & vbNewLine
	s = s & "  " & name & ".setRowCount(" & row_count & ");" & vbNewLine
	s = s & "  " & name & ".setColumnCount(" & column_count & ");" & vbNewLine
	s = s & "  " & name & ".setDataText(function(i, j){return " & name & "_data[i][j]});" & vbNewLine
	s = s & "  " & name & ".setColumnText(function(i){return " & name & "_columns[i]});" & vbNewLine
	s = s & "  document.write(" & name & ");" & vbNewLine
	s = s & "}" & vbNewLine
	s = s & "catch (error){" & vbNewLine
	s = s & "  document.write(error.description);" & vbNewLine
	s = s & "}" & vbNewLine

	s = s & "</" & "script" & ">" & vbNewLine

	activewidgets_grid = s

end function


function activewidgets_html(s)

	s = Replace(s, "\", "\\")
	s = Replace(s, """", "\""")
	s = Replace(s, vbCr, "\r")
	s = Replace(s, vbLf, "\n")

	activewidgets_html = s
end function



%>