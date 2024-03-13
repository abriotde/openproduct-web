/**
 * 
 * @param {*} address 
 * @param {*} functionCB 
 * @param {*} onErrorCB 
 */
function getCoordinateFromAddress(address, functionCB, onErrorCB) {
	if(address!="") {
		search = encodeURI(address);
		url = "https://api-adresse.data.gouv.fr/search/?q="+search;
		const request = new XMLHttpRequest();
		request.responseType = "json";
		request.onload = function() {
			var vals = request.response;
			vals = vals.features;
			if (vals.length>0) {
				vals = vals[0].geometry.coordinates;
				functionCB(vals[1], vals[0]);
			} else if(onErrorCB!=undefined) {
				onErrorCB();
			}
		}
		request.open("GET", url);
		request.send();
	}
}
/**
 * TODO : Redirect to https if https://openproduct.fr/true return true
 */
function checkHttps() {
	if (window.location.protocol != "https:") {
		console.log(window.location.protocol);
		window.location.protocol = "https:";
		// window.location.reload();
	}
}
checkHttps();
