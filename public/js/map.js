var map;
var areas;
const DEBUG = false;
const MAP_MIN_ZOOM = 10;
const MAP_MAX_ZOOM = 19;
const MAP_DEFAULT_ZOOM = 12;
const FILTER_CODE_NOT = '_';

var loadedAreas = []; // List of producers loaded on map.
var loadingAreas = []; // List of producers wich load is running on map.
var areasToCheck = null; // List of neighbouring area not loaded.
var categoriesFilters = null;

const LOCALSTORAGE_MAPCENTER_KEY = "mapCenter";


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
	for (const [areaId, area] of Object.entries(areas)) {
		if (isInArea(area, center)) {
			return parseInt(areaId);
		}
	}
	console.log("Warning : fail getMainArea() with center");
	// Can't attach to an area the center, try to attach a corner (We should be close to the border)
	var bounds = map.getBounds();
	var northWest = bounds.getNorthWest(),
		northEast = bounds.getNorthEast(),
		southWest = bounds.getSouthWest(),
		southEast = bounds.getSouthEast();
	for (const [areaId, area] of Object.entries(areas)) {
		if(isInArea(area, northWest)) {
			return parseInt(areaId);
		}else if(isInArea(area, northEast)) {
			return parseInt(areaId);
		}else if(isInArea(area, southWest)) {
			return parseInt(areaId);
		}else if(isInArea(area, southEast)) {
			return parseInt(areaId);
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
		if (areas[area]==undefined) {
			console.log("Error : areas[",area,"]==undefined");
		} else if (neighbours.length==0) {
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
		if(DEBUG) console.log("checkNeighbouring() : need to load : ",toLoad, " from ", areasToCheck, 
		"; loadedAreas=",loadedAreas)
		getAllProducers(toLoad);
	}
}
function initProducers() {
	loadedAreas = [];
	loadingAreas = [];

	// Remove all previous markers
	for (key in markers) {
		// console.log("Remove marker")
		map.removeLayer(markers[key]);
	}
	markers = {};
	producers = [];

	areasToCheck = null;
	areaNumber = getMainArea();
	if (areaNumber>0) {
		getAllProducers([areaNumber]);
	}
}
function storePosition() {
	const center = map.getCenter();
	if(DEBUG) console.log("storePosition(",center,")");
	const pos = [center.lat, center.lng];
	window.localStorage.setItem(LOCALSTORAGE_MAPCENTER_KEY, JSON.stringify(pos));
}
function centerMap (latitude, longitude) {
	const pos = [latitude, longitude];
	map.setView(pos, MAP_DEFAULT_ZOOM);
	window.localStorage.setItem(LOCALSTORAGE_MAPCENTER_KEY, JSON.stringify(pos));
	initProducers();
}
function initMap (latitude, longitude) {
	if (!mapInitialized) {
		if(DEBUG) console.log("initMap(",[latitude, longitude],")");
		map = L.map('map').setView([latitude, longitude], MAP_DEFAULT_ZOOM);
		map.on('moveend zoomend', function() {
			// console.log("Map move detected : ", map.getCenter());
			checkNeighbouring();
			storePosition();
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
	} else {
		centerMap (latitude, longitude);
	}
}
var noFilter = function (producer) {return true;}
var filterChar = "";
var charFilter = function (producer) {
	var inverse = false;
	var filter = filterChar;
	if(filterChar.charAt(0)==FILTER_CODE_NOT) {
		filter = filterChar.substring(1);
		inverse = true;
	}
	if(producer && producer.cat!=null) {
		const is = producer.cat.charAt(0)==filter;
		retVal = inverse ? !is : is;
		// if(DEBUG) console.log("charFilter(",producer.cat,") (",filter,") => yes = ",(retVal));
		return retVal;
	} else {
		return false;
	}
}
var twoCharFilter = function (producer) {
	var inverse = false;
	var filter = filterChar;
	if(filterChar.charAt(0)==FILTER_CODE_NOT) {
		filter = filterChar.substring(1);
		inverse = true;
	}
	if(producer && producer.cat!=null && producer.cat.charAt(0)==filterChar.charAt(0)) {
		var subfilter = filter.charAt(1);
		for (var i=1; i<producer.cat.length; i++) {
			 if (producer.cat.charAt(1)==subfilter) {
				// if(DEBUG) console.log("twoCharFilter(",producer.cat,") (",filter,") => yes = ",(!inverse));
			 	return !inverse;
			 }
		}
	}
	// if(DEBUG) console.log("twoCharFilter(",producer.cat,") (",filter,") => no = ",inverse);
	return inverse;
}
var myfilter = noFilter;
var markers = {};
var producers = [];
/**
	Format phone number to be display
*/
function formatTel(tel) {
	len = tel.length;
	i = 0;
	output = "";
	sep = "";
	while (i+2<=len) {
		output += sep+tel[i]+tel[i+1];
		sep = " ";
		i += 2;
	}
	// console.log("formatTel("+tel+") : ",output);
	return output;
}
function getIcon(myCustomColour) {
	const markerHtmlStyles = `
		background-color: ${myCustomColour};
		width: 2rem;
		height: 2rem;
		display: block;
		left: -1rem;
		top: -1rem;
		position: relative;
		border-radius: 2rem 2rem 0;
		transform: rotate(45deg);
		border: 1px solid #FFFFFF`;
	return L.divIcon({
		className: "openproduct-pin",
		html: `<span style="${markerHtmlStyles}" />`
	});
}
function getMarkerPin(producer) {
	// console.log("getMarkerColor(",producer,", ",mapIcons,")")
	var cat = producer.cat;
	if (cat==null) {
		return mapIcons.black;
	}
	if (cat[0]=="H") { // Habillement
		return mapIcons.yellow;
	}
	if (cat[0]=="A") { // Alimentaire
		return mapIcons.green;
	}
	if (cat[0]=="P") { // Alimentaire
		return mapIcons.red;
	}
	if (cat[0]=="O") { // Artisans / Artistes
		return mapIcons.blue;
	}
	if (cat[0]=="I") { // Petites et moyennes entrepries (PME)
		return mapIcons.cyan;
	}
	return mapIcons.black;
}
function newMarker(producer) {
	// console.log(producer);
    var marker = L.marker(
		[producer.lat,producer.lng]
		, {icon: getMarkerPin(producer)}
	);
    var text = "<h3>"+producer.name+"</h3>";
    if (producer.web) {
		text = "<a href='"+producer.web+"' target='_blank'>"+text+"</a>"
	}
	if (producer.suspect==1) {
		text += "<span style='color:red'>⚠ Ce producteur semble ne plus exister. Contactez-nous si vous avez des informations.</span>"
	}
	text += "<p>"+producer.txt+"</p>";
    if (producer.wiki) {
        text += "<a href='/wiki/index.php?title="+producer.wiki+"' target='wiki'>+ d'infos</a><br>";
    } else {
    	wikiName = producer.name.toLowerCase().replace(" - ", "-").replace(" ", "_")
    		.replace(/[éèê]/i, "e")
    		.replace(/[îï]/i, "i")
    		.replace(/[öô]/i, "o")
    		.replace("à", "a")
    		.replace("ù", "u");
        text += "<a href='/wiki/index.php?title="+wikiName+"' target='wiki'>+ d'infos</a><br>";
    }
    if (producer.email) {
    	text += "EMail:<a href='mailto:"+producer.email+"'>"+producer.email+"</a><br>"
    }
    if (producer.tel) {
    	text += "Tel:<a href='tel:"+producer.tel+"'>"+formatTel(producer.tel)+"</a><br>"
    }
    if (producer.addr) {
    	text += "Adresse:<a href='geo:"+producer.lat+","+producer.lng+"'>"+producer.addr
    	if (producer.postCode) {
    		text += " - "+producer.postCode;
			if (producer.city) {
				text += " "+producer.city;
			}
    	}
    	text += "</a><br>";
	}
    marker.bindPopup(text);
    return marker;
}
function displayProducers(producers) {
    for (const producer of producers) {
    	if (producer!=undefined) {
		    var key = "m"+producer.lat+"_"+producer.lng;
		    var markerManager = markers[key];
		    if (myfilter(producer)) {
		        if (markerManager!==undefined) {
		        	// console.log("display");
		            if(!markerManager[0]) {
		                markerManager[0] = true;
		                markerManager[1].addTo(map);
		            }
		        } else {
		        	// console.log("create");
		            var marker = newMarker(producer);
		            marker.addTo(map);
		            markers[key] = [true, marker];
		        }
		    } else {
		        // console.log("hide");
		        if (markerManager!==undefined && markerManager[0]==true) {
		        	// console.log("removeLayer : ",markerManager);
		            map.removeLayer(markerManager[1]);
		            markerManager[0] = false;
		        } else {
		        	// console.log("no marker to hide : ",markerManager);
		        }
		    }
		} else {
			console.log("Error : displayProducers() : producer==undefined.");
		}
    }
}
/**
 * Ajax call to get categories filters configurations;
 * 
 * @returns categories.json as object
 */
async function getCategoriesFilters(callback) {
	if(DEBUG) console.log("getCategoriesFilters()");
	if (categoriesFilters===null) {
		const response = await fetch("data/categories.json");
		if(response.ok){
			categoriesFilters = await response.json();
			// console.log("getCategoriesFilters() => ",categoriesFilters);
		}
	}
	return categoriesFilters;
}
/**
 * Get categories filter where filter value == filter params;
 * 
 * @returns categories.json as object
 */
async function getFilterObject(myfilter, filters=null) {
	// if(DEBUG) 
	// console.log("getFilterObject(",myfilter,", ",filters,")");
	if (filters===null) {
		const catFilters = await getCategoriesFilters();
		filters = catFilters.filters;
		// console.log("getFilterObject(",myfilter,", ",filters,")");
	}
	for (cat in filters) {
		filter = filters[cat];
		if (filter.val==myfilter) {
			// console.log("getFilterObject() => ",filter);
			return filter;
		}
		if (filter.hasOwnProperty('subcategories')) {
			const sfilter = await getFilterObject(myfilter, filter.subcategories);
			if (sfilter!==null) {
				// console.log("getFilterObject() => ",sfilter);
				return sfilter;
			}
		}
	}
	return null;
}
/**
 * Filter producers on map after user change select's categories filter
 * 
 * @param {*} filter 
 */
async function filterProducers(filter) {
	// if (DEBUG) 
	console.log("filterProducers(",filter,")");
    if (filter=="") {
        myfilter = noFilter;
    } else {
        filterChar = filter;
        if ((filter.charAt(0)!=FILTER_CODE_NOT ? filter.length==1 : filter.length==2)) {
	        myfilter = charFilter;
			var subfilterDiv = document.getElementById("subfilter");
			subfilterDiv.innerHTML = '';
			const subfilter = await getFilterObject(filter);
			console.log("filterProducers(",filter,") : filter =",subfilter);
			if (subfilter!==null && subfilter.hasOwnProperty('subcategories')) {
				var subfilterSelect = document.createElement("select");
				subfilterSelect.onchange = (async (elem) => {
					await filterProducers(elem.target.value);
				});
				var option = document.createElement("option");
				option.value = filter;
				option.text = " - ";
				subfilterSelect.appendChild(option);
				for(var i in subfilter.subcategories) {
					const sfilter = subfilter.subcategories[i];
					// console.log("filterProducers(",filter,") => ",sfilter);
					var option = document.createElement("option");
					option.value = sfilter.val;
					option.text = sfilter.text;
					subfilterSelect.appendChild(option);
				}
				subfilterDiv.appendChild(subfilterSelect);
			}
        } else {
        	myfilter = twoCharFilter;
        }
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
				producers = producers.concat(request.response.producers);
				displayProducers(producers);
				area = request.response.id
				if (area!=undefined) {
					loadingAreas = loadingAreas.filter(a => a!=area);
					loadedAreas.push(area);
					if(DEBUG) console.log("loadedAreas.push(",area,")");
					areasToCheck = null;
					if (loadingAreas.length==0) {
						checkNeighbouring();
					}
				} else {
					console.log("Error : area==undefined")
				}
			}
			request.open("GET", "data/producers_"+area+".json");
			// request.setRequestHeader('Cache-Control', 'max-age=86400');
			request.setRequestHeader('Cache-Control', 'max-age=100');
			request.send();
		}
	}
}

// Gestion de la position : centrage de la carte
var mapInitialized = false;
var failUpdatePosTimeOut = 2000;
/**
	Infinite loop to try to get location, if GPS has been activated but take time to get position.
*/
function updatePos()
{
    if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(geoOk,geoNotOk);
    } else {
		failUpdatePosTimeOut *= 1.5;
        setTimeout(function() {
            updatePos();
        }, failUpdatePosTimeOut);
    }
}
// https://apicarto.ign.fr/api/codes-postaux/communes/44110
// 
function geoNotOk(error)
{
	if(DEBUG) console.log("geoNotOk(",error,")")
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
		}, failUpdatePosTimeOut
	);
	if (!mapInitialized) {
		var position = window.localStorage.getItem(LOCALSTORAGE_MAPCENTER_KEY);
		if(DEBUG) console.log("localStorage(LOCALSTORAGE_MAPCENTER_KEY) => ",position);
		if (position === null) {
			position = [48.430738, -2.214463]
		} else  {
			position = JSON.parse(position);
		}
		initMap(position[0], position[1]);
	}
}
function geoOk(position)
{
	if(DEBUG) console.log("geoOk(",position,")");
	geolocation = document.getElementById("geoMsg");
	geolocation.innerHTML = "";
    latitude = position.coords.latitude;
    longitude = position.coords.longitude;
    initMap(latitude, longitude);
}


const mapIcons = {
	black:getIcon("#000000"),
	yellow:getIcon("#fcba03"),
	red:getIcon("#fcba03"),
	green:getIcon("#0a6b1d"),
	blue:getIcon("#0a106b"),
	cyan:getIcon("#359396")
};
if (navigator.geolocation) {
	if(DEBUG) console.log("Try get position");
	navigator.geolocation.getCurrentPosition(geoOk,geoNotOk,{timeout:1000});
} else {
	geoNotOk();
}
function geoSearch()
{
	search = document.getElementById("geoSearch").value;
	getCoordinateFromAddress(search, centerMap);
}
