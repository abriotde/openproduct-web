var map;
var areas;
const MAP_MIN_ZOOM = 10;
const MAP_MAX_ZOOM = 19;
const MAP_DEFAULT_ZOOM = 12;

var loadedAreas = []; // List of producers loaded on map.
var loadingAreas = []; // List of producers wich load is running on map.
var areasToCheck = null; // List of neighbouring area not loaded.
var DEBUG = true;

function isInArea(area, point) {
	return area.min[0]<point.lat && area.max[0]>point.lat
			&& area.min[1]<point.lng && area.max[1]>point.lng;
}

/**
 * Find the area corresponding to map center and return the id.
 */
function getMainArea() {
	var center = map.getCenter();
	// Foreach areas  // Find the first where the center is in
	for (const [id, area] of Object.entries(areas)) {
		if (isInArea(area, center)) {
			return parseInt(id);
		}
	}
	console.log("Error : fail getMainArea()");
	return 0;
}
function refreshAreasToCheck() {
	if(DEBUG) console.log("refreshAreasToCheck() for ",loadedAreas);
	// Avoid duplicates : find unique neigbourhood for all loaded areas.
	var neighbours = [];
	for(const area of loadedAreas) {
		if (neighbours.length==0) {
			neighbours = areas[area].nbhd;
			// if(DEBUG) console.log("refreshAreasToCheck() for ",area,neighbours);
		} else {
			neighbours2 = areas[area].nbhd;
			// if(DEBUG) console.log("refreshAreasToCheck() for2 ",area,neighbours2);
			var i1=0, i2=0, len1=neighbours.length, len2=neighbours2.length;
			var v1 = neighbours[i1];
			var v2 = neighbours2[i2];
			var prev = 0;
			var modeCopy = false;
			var neighbours1 = [];
			// As neighbouring are sorted, we avoid to alocate unnecesary space : i.e. do not copy if nothing to add on neighbours.
			while (i1<len1 && i2<len2) {
				// if(DEBUG) console.log("refreshAreasToCheck() ",v1,v2);
				if (v1==v2) { // Go to next
					if (modeCopy) {
						// if(DEBUG) console.log("refreshAreasToCheck() modeCopy/pushV1 ",v1);
						neighbours1.push(v1);
					}
					i1++; i2++; prev = v1;
					v1 = neighbours[i1];
					v2 = neighbours2[i2];
				} else if((v1>v2)) { // Need to insert v2 in middle => modeCopy
					if (!modeCopy) {
						// if(DEBUG) console.log("refreshAreasToCheck() modeCopy ");
						for(i=0;i<i1;i++) neighbours1.push(neighbours[i]);
						modeCopy = true;
					}
					// if(DEBUG) console.log("refreshAreasToCheck() pushV2 ", v2);
					neighbours1.push(v2);
					i2++; 
					v2 = neighbours2[i2];
				} else if((v2>v1)) { // Need to increment i1;
					// if(DEBUG) console.log("refreshAreasToCheck() ++ ",v1);
					if (modeCopy) {
						// if(DEBUG) console.log("refreshAreasToCheck() modeCopy/pushV1/1 ",v1);
						neighbours1.push(v1);
					}
					i1++;
					v1 = neighbours[i1];
				}
			}
			if (modeCopy) {
				neighbours = neighbours1;
			}
			while (i2<len2) {
				// if(DEBUG) console.log("refreshAreasToCheck() fill ",i2,"/",len2," for ",neighbours2);
				neighbours.push(neighbours2[i2++]);
			}
		}
	}
	if(DEBUG) console.log("Neighbours:",neighbours);

	// Remove neigbours ever loaded.
	areasToCheck = neighbours.filter(x => !loadedAreas.includes(x));
	if(DEBUG) console.log("AreasToCheck:",areasToCheck, "; loadedAreas=",loadedAreas);
}
/**
 * check if one if a corner of the map (or the center) is not in a loaded area, and so load them
 */
function checkNeighbouring() {
	if(DEBUG) console.log("checkNeighbouring()");
	if (areasToCheck == null) { // Neighbouring has change only if we have loaded more producers
		refreshAreasToCheck();
	}

	// Check strategic points.
	var toLoad = [];
	var center = map.getCenter();
	var bounds = map.getBounds();
	var northWest = bounds.getNorthWest(),
		northEast = bounds.getNorthEast(),
		southWest = bounds.getSouthWest(),
		southEast = bounds.getSouthEast();
	for (areaId of areasToCheck) {
		var area = areas[areaId];
		if(isInArea(area, center)) { // Should be unnecessary [48.533839, 1.526993]
			// console.log("checkNeighbouring() : center in ",areaId,area);
			toLoad.push(areaId);
		}else if(isInArea(area, northWest)) { // There is maybe a better way than test 4 points.
			// console.log("checkNeighbouring() : northWest in ",areaId,area);
			toLoad.push(areaId);
		}else if(isInArea(area, northEast)) {
			// console.log("checkNeighbouring() : northEast in ",areaId,area);
			toLoad.push(areaId);
		}else if(isInArea(area, southWest)) {
			// console.log("checkNeighbouring() : southWest in ",areaId,area);
			toLoad.push(areaId);
		}else if(isInArea(area, southEast)) {
			// console.log("checkNeighbouring() : southEast in ",areaId,area);
			toLoad.push(areaId);
		}
	}

	// Load needed areas
	if (toLoad.length>0) {
		console.log("checkNeighbouring() : need to load : ",toLoad, " from ", areasToCheck, 
		"; loadedAreas=",loadedAreas)
		getAllProducers(toLoad);
	}
}
function initProducers() {
	loadedAreas = [];
	loadingAreas = [];
	areasToCheck = null;
	areaNumber = getMainArea();
	if (areaNumber>0) {
		getAllProducers([areaNumber]);
	}
}
function centerMap (latitude, longitude) {
    map.setView([latitude, longitude], MAP_DEFAULT_ZOOM);
    initProducers();
}
function initMap (latitude, longitude) {
	if(DEBUG) console.log("initMap(",[latitude, longitude],")");
    map = L.map('map').setView([latitude, longitude], MAP_DEFAULT_ZOOM);
    map.on('moveend zoomend', function() {
       	console.log("Map move detected : ", map.getCenter());
		checkNeighbouring();
    });
    // Get areas locations (to manage witch producers's area to GET)
	const request = new XMLHttpRequest();
	request.responseType = "json";
	request.onload = function() {
		areas = request.response;
		initProducers();
	}
	request.open("GET", "data/departements.json");
	request.send();
	// Get background layer
    L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
        maxZoom: MAP_MAX_ZOOM,
        minZoom: MAP_MIN_ZOOM,
        attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenProduct</a>'
    }).addTo(map);
	mapInitialized = true;
}
var noFilter = function (producer) {return true;}
var filterChar = "a";
var charFilter = function (producer) {
	if(producer && producer[4]!=null) {
		return producer[4][0]==filterChar;
	} else {
		return false;
	}
}
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
function getAllProducers(areas) {
	if(DEBUG) console.log("getAllProducers(",areas,")");
	if (loadedAreas.length + areas.length + loadingAreas.length>10) {
		// TODO : Re-Init all
	}
	for(area of areas) {
		if ((!loadingAreas.includes(area)) && (!loadedAreas.includes(area))) {
			if(DEBUG) console.log("getProducers(",area,")");
			loadingAreas.push(area);
			const request = new XMLHttpRequest();
			request.responseType = "json";
			request.onload = function() {
				producers = request.response;
				displayProducers(producers);
				loadingAreas = loadingAreas.filter(a => a!=area);
				loadedAreas.push(area);
				areasToCheck = null;
				if(DEBUG) console.log("loadedAreas = ",loadedAreas);
				if (loadingAreas.length==0) {
					checkNeighbouring();
				}
			}
			request.open("GET", "data/producers_"+area+".json");
			request.send();
		}
	}
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
// https://apicarto.ign.fr/api/codes-postaux/communes/44110
// 
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
	geolocation = document.getElementById("geoMsg");
	geolocation.innerHTML = errMsg+". Activez la géolocalisation sur le navigateur pour centrer automatiquement la carte sur votre position.";
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
function search()
{
	search = document.getElementById("geoSearch").value;
	console.log(search);
	search = encodeURI(search);
	if(search!="") {
		url = "https://api-adresse.data.gouv.fr/search/?q="+search;
		const request = new XMLHttpRequest();
		request.responseType = "json";
		request.onload = function() {
			var vals = request.response;
			vals = vals.features;
			if (vals.length>0) {
				vals = vals[0].geometry.coordinates;
				console.log(vals);
				centerMap (vals[1], vals[0]);
			}
		}
		request.open("GET", url);
		request.send();
	}
}


