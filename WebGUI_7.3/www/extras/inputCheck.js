function doInputCheck(field,valid) {
        var ok = "yes";
        var temp;
        for (var i=0; i<field.value.length; i++) {
        	temp = "" + field.value.substring(i, i+1);
                if (valid.indexOf(temp) == "-1") ok = "no";
        
        	if (ok == "no") {
        	 field.value = field.value.substring(0, i);
		}
        }
}
