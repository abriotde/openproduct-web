var map;
function initMap () {
    map = L.map('map').setView([48.430738, -2.214463], 10);
    L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
        maxZoom: 19,
        attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenProduct</a>'
    }).addTo(map);
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
        console.log(producer);
        var key = "m"+producer[0]+"_"+producer[1];
        var markerManager = markers[key];
        if (myfilter(producer)) {
            console.log("display");
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
            console.log("hide");
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
  /*
      Categories :
      * AM : Alimentaire - Maraichers
      * HL : Habillement - Laine
  */
initMap();
const request = new XMLHttpRequest();
request.responseType = "json";
request.onload = function() {
    producers = request.response;
    displayProducers(producers);
}
request.open("GET", "/producers_22.json");
request.send();
