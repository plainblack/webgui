function addHTTP(element) {
   if (!element.value.match("http://")) {
	element.value = "http://"+element.value;
   }
   if (!element.value.match(/^http:\/\/.+\..+/)){
	alert("This is not a valid url. Please check if it is correct.");
   }
}
