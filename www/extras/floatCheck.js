function doFloatCheck(field) {
	var valid = "0123456789"
        var ok = "yes";
        var points = 0;
        var temp;
        for (var i=0; i<field.value.length; i++) {
        	temp = "" + field.value.substring(i, i+1);
                if (valid.indexOf(temp) == "-1") {
                	if (temp == ".") {
                        	points++;
                        } else {
                                ok = "no";
                        }
                }
        }
        if (points > 1) ok = "no";
        if (ok == "no") {
                field.value = field.value.substring(0, (field.value.length) - 1);
        }
}

