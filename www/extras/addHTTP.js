function addHTTP(element) {
   	if (element.value != "") {
   		if (!element.value.match(/^\w+:\/\//)) {
			element.value = "http://"+element.value;
   		}
		if (!element.value.match(/^\w+:\/\/.+\..+/)){
			alert("That does not look like a proper URL. Please check if it is correct.");
   		}
	}
}
