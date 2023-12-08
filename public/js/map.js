var map;
function initMap (latitude, longitude) {
    map = L.map('map').setView([48.430738, -2.214463], 10);
    L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
        maxZoom: 19,
        attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenProduct</a>'
    }).addTo(map);
	getProducers(22);
	mapInitialized = true;
}
var noFilter = function (producer) {return true;}
var filterChar = "a";
var charFilter = function (producer) {return producer[4][0]==filterChar;}
var myfilter = noFilter;
var markers = {};
var producers = [];
function newMarker(producer) {
    var marker = L.marker([producer[0],producer[1]]);
    var text = producer[2];
    if (producer[3]) {
        text += "<a href='/wiki/index.php?title="+producer[3]+"' target='wiki'>+ d'infos</a>";
    }
    marker.bindPopup(text);
    return marker;
}
function displayProducers(producers) {
    for (const producer of producers) {
        // console.log(producer);
        var key = "m"+producer[0]+"_"+producer[1];
        var markerManager = markers[key];
        if (myfilter(producer)) {
            // console.log("display");
            if (markerManager!==undefined) {
                if(!markerManager[0]) {
                    markerManager[0] = true;
                    markerManager[1].addTo(map);
                }
            } else {
                var marker = newMarker(producer);
                marker.addTo(map);
                markers[key] = [true, marker];
            }
        } else {
            // console.log("hide");
            if (markerManager!==undefined && markerManager[0]==true) {
                map.removeLayer(markerManager[1]);
                markerManager[0] = false;
            }
        }
    }
}
function filterProducers(filter) {
    if (filter=="") {
        myfilter = noFilter;
    } else {
        filterChar = filter;
        myfilter = charFilter;
    }
    displayProducers(producers);
}
function getProducers(area) {
	const request = new XMLHttpRequest();
	request.responseType = "json";
	request.onload = function() {
		producers = request.response;
		displayProducers(producers);
	}
	request.open("GET", "/producers_"+area+".json");
	request.send();
}

// Gestion de la position : centrage de la carte
var mapInitialized = false;
var failUpdatePosTimeOut = 2500;
function updatePos()
{
    if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(geoOk,geoNotOk);
    } else {
        setTimeout(function() {
            updatePos();
        }, 5000);
    }
}
function geoNotOk(error)
{
	// console.log("geoNotOk(",error,")")
	var errMsg = "";
	if (error) {
		switch(error.code) 
		{
			case error.PERMISSION_DENIED:
				errMsg = "Désactivé";
				break;
			case error.POSITION_UNAVAILABLE:
				errMsg = "Position indisponible";
				break;
			case error.TIMEOUT:
				errMsg = "Délai dépassé";
				break;
			case error.UNKNOWN_ERROR:
				break;
		}
	}
	geolocation = document.getElementById("geolocation")
	geolocation.innerHTML = "Erreur de géolocation "+errMsg+". Activez la géolocalisation sur le navigateur pour centrer automatiquement la carte sur votre position.";
	setTimeout(function() {
		updatePos();
	}, failUpdatePosTimeOut);
	failUpdatePosTimeOut *= 2;
	if (!mapInitialized) {
		initMap(48.430738, -2.214463);
	}
}
function geoOk(position)
{
	// console.log("geoOk(",position,")")
    latitude = position.coords.latitude;
    longitude = position.coords.longitude;
    initMap(latitude, longitude);
}
if (navigator.geolocation) {
	// console.log("Try get position");
	navigator.geolocation.getCurrentPosition(geoOk,geoNotOk,{timeout:10000});
} else {
	geoNotOk();
	initMap(48.430738, -2.214463);
}


