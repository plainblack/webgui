function addHTTP(element) {
	if (!element.value.match(":") && !element.value.match("\^") && element.value.match(/\.\w+/)) { 
		element.value = "http://"+element.value
	}
}


