function addHTTP(element) {
   	if (element.value != "") {
   		if (!element.value.match(/^\w+:\/\//) && !element.value.match(/^\^/) && !element.value.match(/^\//)) {
			element.value = "http://"+element.value;
   		}
		if (!element.value.match(/^\w+:\/\/.+\..+/) && !element.value.match(/^\^/) && !element.value.match(/^\//)){
			alert("That does not look like a proper URL. Please check if it is correct.");
   		}
	}
}
